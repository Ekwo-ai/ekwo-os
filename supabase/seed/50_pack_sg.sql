-- Ekwo OS — Singapore: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sg at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build sg`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Goods and Services Tax Act 1993, current version as at 21 September 2026 (Attorney-General's Chambers — Singapore Statutes Online)
--     https://sso.agc.gov.sg/Act/GSTA1993
--   Goods and Services Tax (General) Regulations, current version as at 21 September 2026 (Attorney-General's Chambers — Singapore Statutes Online)
--     https://sso.agc.gov.sg/SL/GSTA1993-RG1
--   Companies Act 1967, ss. 199, 201 and 205C (Attorney-General's Chambers — Singapore Statutes Online)
--     https://sso.agc.gov.sg/Act/CoA1967
--   Income Tax Act 1947, s. 45 — withholding of tax on interest and other payments to non-residents (Attorney-General's Chambers — Singapore Statutes Online)
--     https://sso.agc.gov.sg/Act/ITA1947
--   Accounting standards — the financial reporting frameworks issued by the Accounting Standards Committee, SFRS for Small Entities among them (Accounting and Corporate Regulatory Authority (ACRA))
--     https://www.acra.gov.sg/regulations/accounting-standards-financial-reporting-surveillance/accounting-standards/
--   Completing GST returns — form GST F5, boxes 1 to 21 (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/filing-gst/completing-gst-returns
--   Due dates and requests for extension (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/filing-gst/due-dates-and-requests-for-extension
--   Changing GST accounting periods (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/other-services/changing-gst-accounting-periods
--   Current GST rates — prevailing rate and historical rates since 1 April 1994 (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/basics-of-gst/current-gst-rates
--   Importing of goods — claiming GST paid on imports (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/claiming-gst-(input-tax)/importing-of-goods
--   Local businesses importing services and importing or supplying low-value goods (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/gst-and-digital-economy/local-businesses
--   Customer accounting for prescribed goods (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-to-charge-goods-and-services-tax-(gst)/customer-accounting-for-prescribed-goods
--   Supplies exempt from GST (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-is-gst-not-charged/supplies-exempt-from-gst
--   Out-of-scope supplies (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-is-gst-not-charged/out-of-scope-supplies
--   Exporting of goods — zero-rating and the documents to keep (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-to-charge-0-gst-(zero-rate)/exporting-of-goods
--   Providing international services (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-to-charge-0-gst-(zero-rate)/providing-international-services
--   Types of payment and withholding tax rates (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/withholding-tax/basics-of-withholding-tax/types-of-payment-and-withholding-tax-rates
--   GST InvoiceNow Requirement (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/gst-invoicenow-requirement
--   e-Tax Guide: Adopting GST InvoiceNow Requirement for GST-registered Businesses (Second Edition, 9 March 2026) (Inland Revenue Authority of Singapore)
--     https://www.iras.gov.sg/docs/default-source/e-tax/etaxguide_gst_invoicenow_requirement.pdf
--   InvoiceNow — Singapore's nationwide e-invoicing network (Infocomm Media Development Authority — Singapore Peppol Authority)
--     https://www.imda.gov.sg/how-we-can-help/nationwide-e-invoicing-framework/invoicenow
--   PINT SG Billing v1.4.1 — Singapore billing specification, with its GST category code list (OpenPeppol, with IMDA as the Singapore Peppol Authority)
--     https://docs.peppol.eu/poac/sg/pint-sg/bis/
--   Electronic Address Scheme (EAS) code list — 0195, Singapore Nationwide E-Invoice Framework (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   myTax Portal — where form GST F5 is filed (Inland Revenue Authority of Singapore)
--     https://mytax.iras.gov.sg/
--   Bizfile — the UEN, the annual return and the financial statements lodged with ACRA (Accounting and Corporate Regulatory Authority (ACRA))
--     https://www.bizfile.gov.sg/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SG', 'Singapore', '0.1.0', date '2026-09-21', '20260917170000', 'community', null, null, '1d81c10839b2fb75b1a00bcf2d834442b0010e1df57acec15c655b3cc4d8b5e3', '[{"key":"gst-act","title":"Goods and Services Tax Act 1993, current version as at 21 September 2026","publisher":"Attorney-General''s Chambers — Singapore Statutes Online","url":"https://sso.agc.gov.sg/Act/GSTA1993","consulted_on":"2026-09-21","kind":"law"},{"key":"gst-general-regs","title":"Goods and Services Tax (General) Regulations, current version as at 21 September 2026","publisher":"Attorney-General''s Chambers — Singapore Statutes Online","url":"https://sso.agc.gov.sg/SL/GSTA1993-RG1","consulted_on":"2026-09-21","kind":"regulation"},{"key":"companies-act","title":"Companies Act 1967, ss. 199, 201 and 205C","publisher":"Attorney-General''s Chambers — Singapore Statutes Online","url":"https://sso.agc.gov.sg/Act/CoA1967","consulted_on":"2026-09-21","kind":"law"},{"key":"ita-1947","title":"Income Tax Act 1947, s. 45 — withholding of tax on interest and other payments to non-residents","publisher":"Attorney-General''s Chambers — Singapore Statutes Online","url":"https://sso.agc.gov.sg/Act/ITA1947","consulted_on":"2026-09-21","kind":"law"},{"key":"acra-standards","title":"Accounting standards — the financial reporting frameworks issued by the Accounting Standards Committee, SFRS for Small Entities among them","publisher":"Accounting and Corporate Regulatory Authority (ACRA)","url":"https://www.acra.gov.sg/regulations/accounting-standards-financial-reporting-surveillance/accounting-standards/","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-f5","title":"Completing GST returns — form GST F5, boxes 1 to 21","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/filing-gst/completing-gst-returns","consulted_on":"2026-09-21","kind":"form"},{"key":"iras-due","title":"Due dates and requests for extension","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/filing-gst/due-dates-and-requests-for-extension","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-periods","title":"Changing GST accounting periods","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/other-services/changing-gst-accounting-periods","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-rates","title":"Current GST rates — prevailing rate and historical rates since 1 April 1994","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/basics-of-gst/current-gst-rates","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-imports","title":"Importing of goods — claiming GST paid on imports","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/claiming-gst-(input-tax)/importing-of-goods","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-reverse-charge","title":"Local businesses importing services and importing or supplying low-value goods","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/gst-and-digital-economy/local-businesses","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-customer-accounting","title":"Customer accounting for prescribed goods","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-to-charge-goods-and-services-tax-(gst)/customer-accounting-for-prescribed-goods","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-exempt","title":"Supplies exempt from GST","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-is-gst-not-charged/supplies-exempt-from-gst","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-out-of-scope","title":"Out-of-scope supplies","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-is-gst-not-charged/out-of-scope-supplies","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-exports","title":"Exporting of goods — zero-rating and the documents to keep","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-to-charge-0-gst-(zero-rate)/exporting-of-goods","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-international-services","title":"Providing international services","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/charging-gst-(output-tax)/when-to-charge-0-gst-(zero-rate)/providing-international-services","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-wht-rates","title":"Types of payment and withholding tax rates","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/withholding-tax/basics-of-withholding-tax/types-of-payment-and-withholding-tax-rates","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-invoicenow","title":"GST InvoiceNow Requirement","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/taxes/goods-services-tax-(gst)/gst-invoicenow-requirement","consulted_on":"2026-09-21","kind":"guidance"},{"key":"iras-invoicenow-guide","title":"e-Tax Guide: Adopting GST InvoiceNow Requirement for GST-registered Businesses (Second Edition, 9 March 2026)","publisher":"Inland Revenue Authority of Singapore","url":"https://www.iras.gov.sg/docs/default-source/e-tax/etaxguide_gst_invoicenow_requirement.pdf","consulted_on":"2026-09-21","kind":"guidance"},{"key":"imda-invoicenow","title":"InvoiceNow — Singapore''s nationwide e-invoicing network","publisher":"Infocomm Media Development Authority — Singapore Peppol Authority","url":"https://www.imda.gov.sg/how-we-can-help/nationwide-e-invoicing-framework/invoicenow","consulted_on":"2026-09-21","kind":"guidance"},{"key":"pint-sg","title":"PINT SG Billing v1.4.1 — Singapore billing specification, with its GST category code list","publisher":"OpenPeppol, with IMDA as the Singapore Peppol Authority","url":"https://docs.peppol.eu/poac/sg/pint-sg/bis/","consulted_on":"2026-09-21","kind":"standard"},{"key":"peppol-eas","title":"Electronic Address Scheme (EAS) code list — 0195, Singapore Nationwide E-Invoice Framework","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-21","kind":"standard"},{"key":"mytax","title":"myTax Portal — where form GST F5 is filed","publisher":"Inland Revenue Authority of Singapore","url":"https://mytax.iras.gov.sg/","consulted_on":"2026-09-21","kind":"portal"},{"key":"bizfile","title":"Bizfile — the UEN, the annual return and the financial statements lodged with ACRA","publisher":"Accounting and Corporate Regulatory Authority (ACRA)","url":"https://www.bizfile.gov.sg/","consulted_on":"2026-09-21","kind":"portal"}]'::jsonb)
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
  ('SG', 'default', 'Singapore reference chart of accounts', '{}'::jsonb, true, 'companies', array['SG-SFRSSE-IS', 'SG-SFRSSE-SFP']::text[], null, 'There is no legal chart of accounts in Singapore. Companies Act 1967, s. 199(1) requires a company to keep such accounting and other records as will sufficiently explain its transactions and financial position and enable true and fair financial statements to be prepared, for at least five years (s. 199(2)), and prescribes no ledger; s. 201(1) and (2) require the directors to lay before the annual general meeting financial statements that comply with the Accounting Standards, which the Accounting Standards Committee under ACRA issues — SFRS(I), FRS, and SFRS for Small Entities; s. 205C exempts a small company, as the Thirteenth Schedule defines it, from audit and not from preparing statements. This chart is original: four digits, blocked so that each range reaches one line item of the SFRS for Small Entities statements, with the accounts a Singapore company actually keeps — GST input and output tax, import GST owed to Singapore Customs, CPF contributions, the Skills Development Levy and the foreign worker levy, withholding tax, amounts due to directors.', 'companies-act')
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
  ('SG', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('SG', 'default', '1010', 'Current account — SGD', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('SG', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('SG', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('SG', 'default', '1040', 'Cash in transit — card and PayNow settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('SG', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('SG', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('SG', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', true, null, 80),
  ('SG', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('SG', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('SG', 'default', '1150', 'GST input tax', '{}'::jsonb, 'asset_current', false, null, 110),
  ('SG', 'default', '1155', 'GST refundable by IRAS — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 120),
  ('SG', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 130),
  ('SG', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 140),
  ('SG', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 150),
  ('SG', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 160),
  ('SG', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 170),
  ('SG', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 180),
  ('SG', 'default', '1350', 'Income tax recoverable', '{}'::jsonb, 'asset_current', false, null, 190),
  ('SG', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('SG', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 210),
  ('SG', 'default', '1600', 'Leasehold property — cost', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('SG', 'default', '1601', 'Leasehold property — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('SG', 'default', '1610', 'Renovation — cost', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('SG', 'default', '1611', 'Renovation — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('SG', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('SG', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('SG', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('SG', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('SG', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('SG', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('SG', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('SG', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('SG', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('SG', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('SG', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('SG', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('SG', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('SG', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('SG', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('SG', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('SG', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('SG', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('SG', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('SG', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('SG', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('SG', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 470),
  ('SG', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 480),
  ('SG', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', true, null, 490),
  ('SG', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 500),
  ('SG', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 510),
  ('SG', 'default', '2100', 'GST output tax', '{}'::jsonb, 'liability_current', false, null, 520),
  ('SG', 'default', '2110', 'GST payable to IRAS — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 530),
  ('SG', 'default', '2125', 'Import GST payable to Singapore Customs', '{}'::jsonb, 'liability_current', true, null, 540),
  ('SG', 'default', '2140', 'Withholding tax payable to IRAS', '{}'::jsonb, 'liability_current', true, null, 550),
  ('SG', 'default', '2150', 'CPF contributions payable', '{}'::jsonb, 'liability_current', true, null, 560),
  ('SG', 'default', '2160', 'Skills Development Levy payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('SG', 'default', '2170', 'Foreign worker levy payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('SG', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', true, null, 590),
  ('SG', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('SG', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 610),
  ('SG', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 620),
  ('SG', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 630),
  ('SG', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('SG', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 650),
  ('SG', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 660),
  ('SG', 'default', '2300', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('SG', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 680),
  ('SG', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 690),
  ('SG', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('SG', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('SG', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('SG', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('SG', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('SG', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('SG', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 760),
  ('SG', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 770),
  ('SG', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 780),
  ('SG', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 790),
  ('SG', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 800),
  ('SG', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 810),
  ('SG', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 820),
  ('SG', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 830),
  ('SG', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 840),
  ('SG', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('SG', 'default', '4030', 'International services', '{}'::jsonb, 'income', false, null, 860),
  ('SG', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 870),
  ('SG', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 880),
  ('SG', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 890),
  ('SG', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 900),
  ('SG', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 910),
  ('SG', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 920),
  ('SG', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 930),
  ('SG', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('SG', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('SG', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('SG', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('SG', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 980),
  ('SG', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 990),
  ('SG', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1000),
  ('SG', 'default', '6030', 'CPF contributions — employer', '{}'::jsonb, 'expense', false, null, 1010),
  ('SG', 'default', '6040', 'Skills Development Levy', '{}'::jsonb, 'expense', false, null, 1020),
  ('SG', 'default', '6050', 'Foreign worker levy', '{}'::jsonb, 'expense', false, null, 1030),
  ('SG', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1040),
  ('SG', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1050),
  ('SG', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1060),
  ('SG', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('SG', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('SG', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1090),
  ('SG', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1100),
  ('SG', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1110),
  ('SG', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1120),
  ('SG', 'default', '6330', 'Cleaning and conservancy', '{}'::jsonb, 'expense', false, null, 1130),
  ('SG', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1140),
  ('SG', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1150),
  ('SG', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1160),
  ('SG', 'default', '6370', 'Overseas travelling', '{}'::jsonb, 'expense', false, null, 1170),
  ('SG', 'default', '6380', 'Motor car expenses', '{}'::jsonb, 'expense', false, null, 1180),
  ('SG', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1190),
  ('SG', 'default', '6400', 'Club subscriptions', '{}'::jsonb, 'expense', false, null, 1200),
  ('SG', 'default', '6410', 'Insurance', '{}'::jsonb, 'expense', false, null, 1210),
  ('SG', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1220),
  ('SG', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1230),
  ('SG', 'default', '6440', 'Corporate secretarial fees', '{}'::jsonb, 'expense', false, null, 1240),
  ('SG', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1250),
  ('SG', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1260),
  ('SG', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1270),
  ('SG', 'default', '6480', 'Licences permits and ACRA fees', '{}'::jsonb, 'expense', false, null, 1280),
  ('SG', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1290),
  ('SG', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1300),
  ('SG', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1310),
  ('SG', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1320),
  ('SG', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1330),
  ('SG', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1340),
  ('SG', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1350),
  ('SG', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1360),
  ('SG', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1370),
  ('SG', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1380),
  ('SG', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1390),
  ('SG', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1400),
  ('SG', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1410),
  ('SG', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1420)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SG', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('SG', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('SG', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('SG', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('SG', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('SG', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('SG', 'SG-P-BL-7', 'Purchase, GST 7 %, input tax disallowed', '{}'::jsonb, 'Motor cars, club subscriptions, staff medical expenses and insurance, family benefits, betting', 'percent', 7, 'purchase', 'domestic', date '2007-07-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. GST (General) Regulations, reg. 26 — input tax on club subscription fees, medical and accident insurance premiums, medical expenses, family benefits and betting is excluded from credit; reg. 27 — so is input tax on a motor car and on goods and services directly in connection with it, with the exceptions that regulation lists. The GST is part of the cost and lands on the account of the line. IRAS, Completing GST returns, box 5: expenses where input tax is disallowed are not reported, so this code reaches no box.', 'S', null, 160, 'gst', false, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-general-regs', null, null, null, null),
  ('SG', 'SG-P-BL-8', 'Purchase, GST 8 %, input tax disallowed', '{}'::jsonb, 'Motor cars, club subscriptions, staff medical expenses and insurance, family benefits, betting', 'percent', 8, 'purchase', 'domestic', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. GST (General) Regulations, reg. 26 — input tax on club subscription fees, medical and accident insurance premiums, medical expenses, family benefits and betting is excluded from credit; reg. 27 — so is input tax on a motor car and on goods and services directly in connection with it, with the exceptions that regulation lists. The GST is part of the cost and lands on the account of the line. IRAS, Completing GST returns, box 5: expenses where input tax is disallowed are not reported, so this code reaches no box.', 'S', null, 170, 'gst', false, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-general-regs', null, null, null, null),
  ('SG', 'SG-P-BL-9', 'Purchase, GST 9 %, input tax disallowed', '{}'::jsonb, 'Motor cars, club subscriptions, staff medical expenses and insurance, family benefits, betting', 'percent', 9, 'purchase', 'domestic', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. GST (General) Regulations, reg. 26 — input tax on club subscription fees, medical and accident insurance premiums, medical expenses, family benefits and betting is excluded from credit; reg. 27 — so is input tax on a motor car and on goods and services directly in connection with it, with the exceptions that regulation lists. The GST is part of the cost and lands on the account of the line. IRAS, Completing GST returns, box 5: expenses where input tax is disallowed are not reported, so this code reaches no box.', 'S', null, 180, 'gst', false, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-general-regs', null, null, null, null),
  ('SG', 'SG-P-CA-7', 'Purchase of prescribed goods, customer accounting, GST 7 %', '{}'::jsonb, 'Mobile phones, memory cards or off-the-shelf software above $10,000, bought for the business', 'percent', 7, 'purchase', 'domestic_reverse_charge', date '2019-01-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 38A(2) — the GST-registered customer accounts for and pays the tax on a relevant supply as if it were the supplier; GST (General) Regulations, regs. 66A and 66C. IRAS, Customer accounting for prescribed goods: the customer reports the value without GST in box 1 and the GST in box 6, and, where it may claim the input tax, the value in box 5 and the GST in box 7. PINT SG category SRCA-C.', 'AE', null, 320, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-CA-8', 'Purchase of prescribed goods, customer accounting, GST 8 %', '{}'::jsonb, 'Mobile phones, memory cards or off-the-shelf software above $10,000, bought for the business', 'percent', 8, 'purchase', 'domestic_reverse_charge', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 38A(2) — the GST-registered customer accounts for and pays the tax on a relevant supply as if it were the supplier; GST (General) Regulations, regs. 66A and 66C. IRAS, Customer accounting for prescribed goods: the customer reports the value without GST in box 1 and the GST in box 6, and, where it may claim the input tax, the value in box 5 and the GST in box 7. PINT SG category SRCA-C.', 'AE', null, 330, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-CA-9', 'Purchase of prescribed goods, customer accounting, GST 9 %', '{}'::jsonb, 'Mobile phones, memory cards or off-the-shelf software above $10,000, bought for the business', 'percent', 9, 'purchase', 'domestic_reverse_charge', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 38A(2) — the GST-registered customer accounts for and pays the tax on a relevant supply as if it were the supplier; GST (General) Regulations, regs. 66A and 66C. IRAS, Customer accounting for prescribed goods: the customer reports the value without GST in box 1 and the GST in box 6, and, where it may claim the input tax, the value in box 5 and the GST in box 7. PINT SG category SRCA-C.', 'AE', null, 340, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-ES', 'Purchase, exempt', '{}'::jsonb, 'Bank charges, interest, residential rent', 'percent', 0, 'purchase', 'exempt', date '2007-07-01', null, 'Goods and Services Tax Act 1993, s. 22(1) and Fourth Schedule, Part 1 — the supply bought is exempt. IRAS, Completing GST returns, box 5: purchases exempted from GST, such as bank charges and the purchase or lease of residential property, are not reported.', 'E', null, 200, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-IMP-7', 'Import of goods, GST 7 % paid to Singapore Customs', '{}'::jsonb, 'Import GST shown on the import permit and claimed as input tax', 'percent', 7, 'purchase', 'import', date '2007-07-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 16(e) — tax is charged on the importation of goods by reference to their value under s. 18; IRAS, Importing of goods — import GST is collected by Singapore Customs on the value plus duties, and is claimed on the import permit: its value in box 5, its GST in box 7. The GST is owed to Singapore Customs and not to the supplier, so it waits on 2125 until the permit is paid; it reaches no output box. The pack computes it on the value of the line, which is the import permit value only when the two agree — IRAS asks for them to be reconciled when they do not.', null, null, 220, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'iras-imports', null, null, null, null),
  ('SG', 'SG-P-IMP-8', 'Import of goods, GST 8 % paid to Singapore Customs', '{}'::jsonb, 'Import GST shown on the import permit and claimed as input tax', 'percent', 8, 'purchase', 'import', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 16(e) — tax is charged on the importation of goods by reference to their value under s. 18; IRAS, Importing of goods — import GST is collected by Singapore Customs on the value plus duties, and is claimed on the import permit: its value in box 5, its GST in box 7. The GST is owed to Singapore Customs and not to the supplier, so it waits on 2125 until the permit is paid; it reaches no output box. The pack computes it on the value of the line, which is the import permit value only when the two agree — IRAS asks for them to be reconciled when they do not.', null, null, 230, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'iras-imports', null, null, null, null),
  ('SG', 'SG-P-IMP-9', 'Import of goods, GST 9 % paid to Singapore Customs', '{}'::jsonb, 'Import GST shown on the import permit and claimed as input tax', 'percent', 9, 'purchase', 'import', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 16(e) — tax is charged on the importation of goods by reference to their value under s. 18; IRAS, Importing of goods — import GST is collected by Singapore Customs on the value plus duties, and is claimed on the import permit: its value in box 5, its GST in box 7. The GST is owed to Singapore Customs and not to the supplier, so it waits on 2125 until the permit is paid; it reaches no output box. The pack computes it on the value of the line, which is the import permit value only when the two agree — IRAS asks for them to be reconciled when they do not.', null, null, 240, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'iras-imports', null, null, null, null),
  ('SG', 'SG-P-IMP-SUSP', 'Import of goods, GST suspended under MES, A3PL or another approved scheme', '{}'::jsonb, 'An import by a business approved under the Major Exporter Scheme or a similar scheme', 'percent', 0, 'purchase', 'import', date '2007-07-01', null, 'IRAS, Completing GST returns, box 9 — a business approved under the Major Exporter Scheme, the Approved Third Party Logistics Company Scheme or another approved scheme reports the value of its imports under the scheme in box 9 and in box 5, since it is still a taxable import; the GST is suspended, so there is nothing in box 7. GST (General) Regulations, regs. 45 and 45A.', null, null, 250, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'iras-f5', null, null, null, null),
  ('SG', 'SG-P-NR', 'Purchase with no GST — supplier not registered or supply out of scope', '{}'::jsonb, 'A supplier who is not GST-registered, a government fee, a supply outside the Act', 'percent', 0, 'purchase', 'not_subject', date '2007-07-01', null, 'IRAS, Completing GST returns, box 5 — purchases from businesses that are not GST-registered are not reported; no tax is charged on them and none may be claimed. PINT SG category NG on the supplier''s side where it issues one.', 'O', null, 210, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'iras-f5', null, null, null, null),
  ('SG', 'SG-P-RC-7', 'Imported service or low-value goods, reverse charge, GST 7 %, claimable', '{}'::jsonb, 'For a business not entitled to full input tax: the share attributable to taxable supplies', 'percent', 7, 'purchase', 'foreign_services_received', date '2020-01-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 14(1)(b) and (2) — a GST-registered recipient belonging in Singapore that is not entitled to credit for the full amount of its input tax accounts for tax on services supplied by a person belonging outside Singapore as if it had supplied them itself; s. 14(1)(a) extends this to distantly taxable goods, the low-value goods, from 1 January 2023. IRAS, Local businesses importing services: in force from 1 January 2020; IRAS, Completing GST returns: the value in box 1, box 14 and box 5, the GST in box 6, and in box 7 the part the input tax recovery rules allow. This code is for an acquisition wholly used for taxable supplies, whose GST is claimed in full. PINT SG category SRRC on the recipient''s own record.', null, null, 260, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-RC-8', 'Imported service or low-value goods, reverse charge, GST 8 %, claimable', '{}'::jsonb, 'For a business not entitled to full input tax: the share attributable to taxable supplies', 'percent', 8, 'purchase', 'foreign_services_received', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 14(1)(b) and (2) — a GST-registered recipient belonging in Singapore that is not entitled to credit for the full amount of its input tax accounts for tax on services supplied by a person belonging outside Singapore as if it had supplied them itself; s. 14(1)(a) extends this to distantly taxable goods, the low-value goods, from 1 January 2023. IRAS, Local businesses importing services: in force from 1 January 2020; IRAS, Completing GST returns: the value in box 1, box 14 and box 5, the GST in box 6, and in box 7 the part the input tax recovery rules allow. This code is for an acquisition wholly used for taxable supplies, whose GST is claimed in full. PINT SG category SRRC on the recipient''s own record.', null, null, 270, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-RC-9', 'Imported service or low-value goods, reverse charge, GST 9 %, claimable', '{}'::jsonb, 'For a business not entitled to full input tax: the share attributable to taxable supplies', 'percent', 9, 'purchase', 'foreign_services_received', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 14(1)(b) and (2) — a GST-registered recipient belonging in Singapore that is not entitled to credit for the full amount of its input tax accounts for tax on services supplied by a person belonging outside Singapore as if it had supplied them itself; s. 14(1)(a) extends this to distantly taxable goods, the low-value goods, from 1 January 2023. IRAS, Local businesses importing services: in force from 1 January 2020; IRAS, Completing GST returns: the value in box 1, box 14 and box 5, the GST in box 6, and in box 7 the part the input tax recovery rules allow. This code is for an acquisition wholly used for taxable supplies, whose GST is claimed in full. PINT SG category SRRC on the recipient''s own record.', null, null, 280, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-RC-NC-7', 'Imported service or low-value goods, reverse charge, GST 7 %, not claimable', '{}'::jsonb, 'For a business not entitled to full input tax: the share attributable to exempt supplies', 'percent', 7, 'purchase', 'foreign_services_received', date '2020-01-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 14(1) and (2), as for SG-P-RC; s. 20 — input tax attributable to exempt supplies is not credited. The recipient owes the GST in box 6 and claims nothing in box 7, so the GST is part of the cost and lands on the account of the line; the value is still reported in box 1, box 14 and box 5 (IRAS, Completing GST returns). An acquisition used for both kinds of supply needs the apportionment of regs. 28 to 30 of the GST (General) Regulations, which no code can hold.', null, null, 290, 'gst', false, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-RC-NC-8', 'Imported service or low-value goods, reverse charge, GST 8 %, not claimable', '{}'::jsonb, 'For a business not entitled to full input tax: the share attributable to exempt supplies', 'percent', 8, 'purchase', 'foreign_services_received', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 14(1) and (2), as for SG-P-RC; s. 20 — input tax attributable to exempt supplies is not credited. The recipient owes the GST in box 6 and claims nothing in box 7, so the GST is part of the cost and lands on the account of the line; the value is still reported in box 1, box 14 and box 5 (IRAS, Completing GST returns). An acquisition used for both kinds of supply needs the apportionment of regs. 28 to 30 of the GST (General) Regulations, which no code can hold.', null, null, 300, 'gst', false, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-RC-NC-9', 'Imported service or low-value goods, reverse charge, GST 9 %, not claimable', '{}'::jsonb, 'For a business not entitled to full input tax: the share attributable to exempt supplies', 'percent', 9, 'purchase', 'foreign_services_received', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 14(1) and (2), as for SG-P-RC; s. 20 — input tax attributable to exempt supplies is not credited. The recipient owes the GST in box 6 and claims nothing in box 7, so the GST is part of the cost and lands on the account of the line; the value is still reported in box 1, box 14 and box 5 (IRAS, Completing GST returns). An acquisition used for both kinds of supply needs the apportionment of regs. 28 to 30 of the GST (General) Regulations, which no code can hold.', null, null, 310, 'gst', false, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-TX-7', 'Purchase, standard-rated, GST 7 %', '{}'::jsonb, 'A taxable purchase whose GST is claimed as input tax', 'percent', 7, 'purchase', 'domestic', date '2007-07-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 19 and s. 20 — input tax on a supply used for making taxable supplies is credited against output tax, on a valid tax invoice (IRAS, Conditions for claiming input tax). Box 5 takes the value without GST and box 7 the input tax. A capital purchase is reported in the same boxes: form GST F5 has no box for it.', 'S', null, 130, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-TX-8', 'Purchase, standard-rated, GST 8 %', '{}'::jsonb, 'A taxable purchase whose GST is claimed as input tax', 'percent', 8, 'purchase', 'domestic', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 19 and s. 20 — input tax on a supply used for making taxable supplies is credited against output tax, on a valid tax invoice (IRAS, Conditions for claiming input tax). Box 5 takes the value without GST and box 7 the input tax. A capital purchase is reported in the same boxes: form GST F5 has no box for it.', 'S', null, 140, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-TX-9', 'Purchase, standard-rated, GST 9 %', '{}'::jsonb, 'A taxable purchase whose GST is claimed as input tax', 'percent', 9, 'purchase', 'domestic', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. Goods and Services Tax Act 1993, s. 19 and s. 20 — input tax on a supply used for making taxable supplies is credited against output tax, on a valid tax invoice (IRAS, Conditions for claiming input tax). Box 5 takes the value without GST and box 7 the input tax. A capital purchase is reported in the same boxes: form GST F5 has no box for it.', 'S', null, 150, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-P-WHT-INT-15', 'Interest paid to a non-resident — 15 % withheld', '{}'::jsonb, 'Interest on a loan from a person not known to be resident in Singapore', 'percent', 15, 'purchase', 'not_subject', date '2026-01-01', null, 'Income Tax Act 1947, s. 45(1) — a person liable to pay interest to a person not known to be resident in Singapore deducts tax from it, at the rate s. 43(3) specifies where it applies, and pays it to the Comptroller; s. 45(4) — by the 15th day of the second month following the month of payment. IRAS, Types of payment and withholding tax rates, gives 15 % for interest in connection with a loan, unless a tax treaty reduces it. The amount waits on 2140 and is filed on the withholding tax form, not on form GST F5, so it reaches no box. The interest itself is an exempt financial service (Fourth Schedule, Part 1, paragraph 1(g)) and reaches no box either. The rate is dated from the first year this pack was written for; the day it started is not carried.', null, null, 350, 'withholding', true, array['buyer_status']::tax_condition[], null, false, false, null, 'ita-1947', null, null, null, null),
  ('SG', 'SG-P-WHT-ROY-10', 'Royalty paid to a non-resident — 10 % withheld', '{}'::jsonb, 'A royalty for the use of movable property or intellectual property', 'percent', 10, 'purchase', 'not_subject', date '2026-01-01', null, 'Income Tax Act 1947, s. 45(1), as for SG-P-WHT-INT-15; IRAS, Types of payment and withholding tax rates, gives 10 % for royalties or other lump sum payments for the use of movable properties, unless a tax treaty reduces it. A business that is not entitled to full input tax also reverse charges the royalty as an imported service, which is a second line, since a line carries one code. No box of form GST F5.', null, null, 360, 'withholding', true, array['buyer_status']::tax_condition[], null, false, false, null, 'ita-1947', null, null, null, null),
  ('SG', 'SG-P-ZR', 'Purchase, zero-rated', '{}'::jsonb, 'A zero-rated purchase from a GST-registered supplier: international freight, air tickets', 'percent', 0, 'purchase', 'domestic', date '2007-07-01', null, 'IRAS, Completing GST returns, box 5 — the value of zero-rated purchases from GST-registered suppliers, such as international freight and air tickets, is a taxable purchase and is reported in box 5; there is no input tax. Goods and Services Tax Act 1993, s. 21(2): a zero-rated supply is a taxable supply at a rate of nil.', 'Z', null, 190, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'iras-f5', null, null, null, null),
  ('SG', 'SG-S-CA', 'Sale of prescribed goods subject to customer accounting', '{}'::jsonb, 'Mobile phones, memory cards or off-the-shelf software above $10,000, sold to a GST-registered business customer', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2019-01-01', null, 'Goods and Services Tax Act 1993, s. 38A(1) and (2) — on a relevant supply to a GST-registered customer in connection with its business, the customer accounts for and pays the tax as if it were the supplier, and the supplier must not require payment of the tax; GST (General) Regulations, reg. 66A — the prescribed goods are mobile phones, memory cards and off-the-shelf software; reg. 66C(1) — the threshold is $10,000; reg. 11(4) — the tax invoice also carries the customer''s registration number and a statement that the customer must account for the tax. IRAS, Customer accounting for prescribed goods: in force from 1 January 2019; the supplier reports the value without GST in box 1 and nothing in box 6. PINT SG category SRCA-S.', 'AE', null, 120, 'gst', true, array['supply_nature', 'buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-ES-FIN', 'Financial service, exempt', '{}'::jsonb, 'An exempt supply of financial services', 'percent', 0, 'sale', 'exempt', date '2007-07-01', null, 'Goods and Services Tax Act 1993, s. 22(1) and Fourth Schedule, Part 1, paragraph 1 — the financial services listed there, among them the operation of an account, the exchange of currency, the issue or transfer of a debt or equity security and the provision of any loan, advance or credit, are exempt supplies. Box 3 of form GST F5. PINT SG category ES33 or ESN33, as reg. 33 of the GST (General) Regulations classifies the supply.', 'E', null, 90, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-ES-RES', 'Sale or lease of residential property, exempt', '{}'::jsonb, 'An exempt supply of residential land or buildings', 'percent', 0, 'sale', 'exempt', date '2007-07-01', null, 'Goods and Services Tax Act 1993, s. 22(1) and Fourth Schedule, Part 1, paragraph 2 — the grant, assignment or surrender of an interest in or right over land used or to be used principally for residential purposes, or of a licence to occupy it, is an exempt supply, the letting of a flat included. Box 3 of form GST F5. PINT SG category ESN33.', 'E', null, 100, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-OS', 'Out-of-scope supply', '{}'::jsonb, 'Goods delivered from a place outside Singapore to another place outside Singapore, and other supplies outside the Act', 'percent', 0, 'sale', 'not_subject', date '2007-07-01', null, 'IRAS, Completing GST returns, box 1 — ''out-of-scope supplies'', such as goods shipped from a place outside Singapore to another place outside Singapore, are not reported in the return; IRAS, Out-of-scope supplies. No box of form GST F5. PINT SG category OS.', 'O', null, 110, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'iras-f5', null, null, null, null),
  ('SG', 'SG-S-SR-7', 'Sale, standard-rated, GST 7 %', '{}'::jsonb, 'A taxable supply made in Singapore', 'percent', 7, 'sale', 'domestic', date '2007-07-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. The value without GST is reported in box 1 of form GST F5 and the GST charged in box 6 (IRAS, Completing GST returns, boxes 1 and 6). PINT SG category SR.', 'S', null, 10, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-SR-8', 'Sale, standard-rated, GST 8 %', '{}'::jsonb, 'A taxable supply made in Singapore', 'percent', 8, 'sale', 'domestic', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. The value without GST is reported in box 1 of form GST F5 and the GST charged in box 6 (IRAS, Completing GST returns, boxes 1 and 6). PINT SG category SR.', 'S', null, 20, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-SR-9', 'Sale, standard-rated, GST 9 %', '{}'::jsonb, 'A taxable supply made in Singapore', 'percent', 9, 'sale', 'domestic', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. The value without GST is reported in box 1 of form GST F5 and the GST charged in box 6 (IRAS, Completing GST returns, boxes 1 and 6). PINT SG category SR.', 'S', null, 30, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-SR-INC-7', 'Retail sale, standard-rated, GST 7 %, the price includes the GST', '{}'::jsonb, 'For a price displayed with the GST in it, as a shop price is', 'percent', 7, 'sale', 'domestic', date '2007-07-01', date '2022-12-31', 'Goods and Services Tax Act 1993, s. 16(c) — 7 % for the period from 1 July 2007 to 31 December 2022, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. GST (General) Regulations, reg. 77(1) — a price a taxable person displays, advertises, publishes or quotes includes the tax chargeable, unless the Comptroller approves otherwise; reg. 77(3) — except a quotation made solely for a supply to a taxable person and not ordinarily available to the public. The engine takes the GST out of the gross, rounded once, and box 1 takes the value left, box 6 the GST. PINT SG category SR.', 'S', null, 40, 'gst', true, '{}'::tax_condition[], null, true, false, null, 'gst-general-regs', null, null, null, null),
  ('SG', 'SG-S-SR-INC-8', 'Retail sale, standard-rated, GST 8 %, the price includes the GST', '{}'::jsonb, 'For a price displayed with the GST in it, as a shop price is', 'percent', 8, 'sale', 'domestic', date '2023-01-01', date '2023-12-31', 'Goods and Services Tax Act 1993, s. 16(ca) — 8 % for the period from 1 January 2023 to 31 December 2023, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. GST (General) Regulations, reg. 77(1) — a price a taxable person displays, advertises, publishes or quotes includes the tax chargeable, unless the Comptroller approves otherwise; reg. 77(3) — except a quotation made solely for a supply to a taxable person and not ordinarily available to the public. The engine takes the GST out of the gross, rounded once, and box 1 takes the value left, box 6 the GST. PINT SG category SR.', 'S', null, 50, 'gst', true, '{}'::tax_condition[], null, true, false, null, 'gst-general-regs', null, null, null, null),
  ('SG', 'SG-S-SR-INC-9', 'Retail sale, standard-rated, GST 9 %, the price includes the GST', '{}'::jsonb, 'For a price displayed with the GST in it, as a shop price is', 'percent', 9, 'sale', 'domestic', date '2024-01-01', null, 'Goods and Services Tax Act 1993, s. 16(cb) — 9 % from and including 1 January 2024, as amended by Act 35 of 2022; IRAS, Current GST rates, gives the same three periods. A new rate is a new code and the old one closes the day before, so a return of a past period keeps giving the same answer. GST (General) Regulations, reg. 77(1) — a price a taxable person displays, advertises, publishes or quotes includes the tax chargeable, unless the Comptroller approves otherwise; reg. 77(3) — except a quotation made solely for a supply to a taxable person and not ordinarily available to the public. The engine takes the GST out of the gross, rounded once, and box 1 takes the value left, box 6 the GST. PINT SG category SR.', 'S', null, 60, 'gst', true, '{}'::tax_condition[], null, true, false, null, 'gst-general-regs', null, null, null, null),
  ('SG', 'SG-S-ZR-EXP', 'Export of goods, zero-rated', '{}'::jsonb, 'Goods exported out of Singapore', 'percent', 0, 'sale', 'export', date '2007-07-01', null, 'Goods and Services Tax Act 1993, s. 21(1) — a supply of goods is zero-rated if the goods are exported; s. 21(2) — no tax is charged and the supply is in all other respects a taxable supply, at a rate of nil. The supplier must hold the export documents IRAS lists (Exporting of goods). Box 2 of form GST F5, and nothing in box 6. PINT SG category ZR.', 'G', null, 70, 'gst', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('SG', 'SG-S-ZR-INTL', 'International service, zero-rated', '{}'::jsonb, 'A service of one of the descriptions of s. 21(3)', 'percent', 0, 'sale', 'export', date '2007-07-01', null, 'Goods and Services Tax Act 1993, s. 21(1) and s. 21(3) — a supply of services is zero-rated only if it is an international service, and s. 21(3) lists the descriptions, among them (j): services supplied under a contract with a person who belongs outside Singapore and which directly benefit a person who belongs outside Singapore and is outside Singapore when they are performed, or a GST-registered person in Singapore. Which paragraph applies depends on the service and on where the customer belongs, which the ledger does not hold. Box 2 of form GST F5. PINT SG category ZR.', 'G', null, 80, 'gst', true, array['supply_nature', 'buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null)
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
    ('SG-P-BL-7', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-BL-7', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-BL-7', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-BL-7', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-BL-8', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-BL-8', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-BL-8', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-BL-8', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-BL-9', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-BL-9', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-BL-9', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-BL-9', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-CA-7', 'invoice', 'base', 100, null, '5', array['5', '1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-CA-7', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-CA-7', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-CA-7', 'credit_note', 'base', 100, null, '5', array['5', '1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-CA-7', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-CA-7', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-CA-8', 'invoice', 'base', 100, null, '5', array['5', '1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-CA-8', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-CA-8', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-CA-8', 'credit_note', 'base', 100, null, '5', array['5', '1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-CA-8', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-CA-8', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-CA-9', 'invoice', 'base', 100, null, '5', array['5', '1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-CA-9', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-CA-9', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-CA-9', 'credit_note', 'base', 100, null, '5', array['5', '1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-CA-9', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-CA-9', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-ES', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-ES', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-IMP-7', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-IMP-7', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-IMP-7', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SG-P-IMP-7', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-IMP-7', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-IMP-7', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SG-P-IMP-8', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-IMP-8', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-IMP-8', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SG-P-IMP-8', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-IMP-8', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-IMP-8', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SG-P-IMP-9', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-IMP-9', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-IMP-9', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SG-P-IMP-9', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-IMP-9', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-IMP-9', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('SG-P-IMP-SUSP', 'invoice', 'base', 100, null, '5', array['5', '9']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-IMP-SUSP', 'credit_note', 'base', 100, null, '5', array['5', '9']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-NR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-NR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-RC-7', 'invoice', 'base', 100, null, '5', array['5', '1', '14']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-RC-7', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-RC-7', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-RC-7', 'credit_note', 'base', 100, null, '5', array['5', '1', '14']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-RC-7', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-RC-7', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-RC-8', 'invoice', 'base', 100, null, '5', array['5', '1', '14']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-RC-8', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-RC-8', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-RC-8', 'credit_note', 'base', 100, null, '5', array['5', '1', '14']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-RC-8', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-RC-8', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-RC-9', 'invoice', 'base', 100, null, '5', array['5', '1', '14']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-RC-9', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-RC-9', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-RC-9', 'credit_note', 'base', 100, null, '5', array['5', '1', '14']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-RC-9', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-RC-9', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-RC-NC-7', 'invoice', 'base', 100, null, '5', array['5', '1', '14']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-RC-NC-7', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-RC-NC-7', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-RC-NC-7', 'credit_note', 'base', 100, null, '5', array['5', '1', '14']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-RC-NC-7', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-RC-NC-7', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-RC-NC-8', 'invoice', 'base', 100, null, '5', array['5', '1', '14']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-RC-NC-8', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-RC-NC-8', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-RC-NC-8', 'credit_note', 'base', 100, null, '5', array['5', '1', '14']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-RC-NC-8', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-RC-NC-8', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-RC-NC-9', 'invoice', 'base', 100, null, '5', array['5', '1', '14']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-RC-NC-9', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-RC-NC-9', 'invoice', 'tax', -100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 30),
    ('SG-P-RC-NC-9', 'credit_note', 'base', 100, null, '5', array['5', '1', '14']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-RC-NC-9', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SG-P-RC-NC-9', 'credit_note', 'tax', -100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 30),
    ('SG-P-TX-7', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-TX-7', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-TX-7', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-TX-7', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-TX-8', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-TX-8', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-TX-8', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-TX-8', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-TX-9', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-TX-9', 'invoice', 'tax', 100, '1150', '7', array['7']::text[], 100, 'SG-GST-F5', 20),
    ('SG-P-TX-9', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-P-TX-9', 'credit_note', 'tax', 100, '1150', '7', array['7']::text[], -100, 'SG-GST-F5', 20),
    ('SG-P-WHT-INT-15', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-WHT-INT-15', 'invoice', 'tax', -100, '2140', null, null, 100, null, 20),
    ('SG-P-WHT-INT-15', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-WHT-INT-15', 'credit_note', 'tax', -100, '2140', null, null, 100, null, 20),
    ('SG-P-WHT-ROY-10', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-WHT-ROY-10', 'invoice', 'tax', -100, '2140', null, null, 100, null, 20),
    ('SG-P-WHT-ROY-10', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-P-WHT-ROY-10', 'credit_note', 'tax', -100, '2140', null, null, 100, null, 20),
    ('SG-P-ZR', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'SG-GST-F5', 10),
    ('SG-P-ZR', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-CA', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-CA', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-ES-FIN', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-ES-FIN', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-ES-RES', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-ES-RES', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-OS', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SG-S-OS', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SG-S-SR-7', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-SR-7', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 20),
    ('SG-S-SR-7', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-SR-7', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 20),
    ('SG-S-SR-8', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-SR-8', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 20),
    ('SG-S-SR-8', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-SR-8', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 20),
    ('SG-S-SR-9', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-SR-9', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 20),
    ('SG-S-SR-9', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-SR-9', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 20),
    ('SG-S-SR-INC-7', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-SR-INC-7', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 20),
    ('SG-S-SR-INC-7', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-SR-INC-7', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 20),
    ('SG-S-SR-INC-8', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-SR-INC-8', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 20),
    ('SG-S-SR-INC-8', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-SR-INC-8', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 20),
    ('SG-S-SR-INC-9', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-SR-INC-9', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'SG-GST-F5', 20),
    ('SG-S-SR-INC-9', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-SR-INC-9', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'SG-GST-F5', 20),
    ('SG-S-ZR-EXP', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-ZR-EXP', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'SG-GST-F5', 10),
    ('SG-S-ZR-INTL', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'SG-GST-F5', 10),
    ('SG-S-ZR-INTL', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'SG-GST-F5', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SG' and t.code = v.tax_code
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
  ('SG', 'SG-GST-F5', 'GST return (form GST F5)', array['month', 'quarter', 'half_year']::declaration_period[], 'quarter'::declaration_period, date '2007-07-01', null, 'GST (General) Regulations, reg. 52(1) and (2) — a registered person furnishes a return for every period of a quarter; reg. 52(3)(a) — the Comptroller may allow or direct returns for a single calendar month, for three consecutive months that are not a quarter, or for six consecutive months; reg. 52(12) — in the form the Comptroller determines, which is form GST F5 (IRAS, Completing GST returns). A quarter is what the law gives everybody, which is what period_default says. IRAS, Changing GST accounting periods: the quarters follow the month the financial year ends in — January to March, February to April or March to May — and a quarter here is always January to March; see docs/international.md. The pack carries boxes 1 to 17 as the return prints them in 2026: box 14 dates from 1 January 2020 and boxes 15 to 17 from 1 January 2023, and the boxes 18 to 21 of the Import GST Deferment Scheme appear only on the return of an approved importer and are not carried.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'GST (General) Regulations, reg. 52(5) — the return for a standard or special period is furnished no later than the last day of the month immediately following the end of the period; reg. 59(1) — the tax is paid by the same day. IRAS, Due dates and requests for extension: returns and payment are due one month after the end of the accounting period, 30 April for January to March.', 'gst-general-regs', null)
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
  ('SG', 'SG-GST-F5', '1', 'base', 'Total value of standard-rated supplies', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 1, and IRAS, Completing GST returns — the value, without GST, of supplies subject to GST at the standard rate, net of credit notes issued. It also takes the value of relevant supplies made or received under customer accounting, and of imported services and low-value goods subject to reverse charge, which is why those codes post their base here as well.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '2', 'base', 'Total value of zero-rated supplies', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 2 — exports of goods and international services under s. 21(3) of the Act, net of credit notes.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '3', 'base', 'Total value of exempt supplies', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 3 — sales and leases of residential property and the financial services of the Fourth Schedule, and supplies of investment precious metals and digital payment tokens. IRAS asks for the absolute value of the net exchange gain or loss of each period here too; that figure is not a document and the pack does not post it.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '4', 'total', 'Total value of (1) + (2) + (3)', '{}'::jsonb, 40, null, array['1', '2', '3']::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 4 — the total supplies of the period, which the form computes from boxes 1, 2 and 3.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '5', 'base', 'Total value of taxable purchases', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 5 — standard-rated purchases whose GST can be claimed, imports at the value of the import permit, zero-rated purchases from GST-registered suppliers, and imported services and low-value goods subject to reverse charge, without GST and net of credit notes. Purchases whose input tax is disallowed, exempt purchases and purchases from suppliers that are not GST-registered are not reported.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '6', 'tax', 'Output tax due', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 6 — the GST charged on the supplies of box 1, the GST a customer accounts for under customer accounting and the GST on reverse charge supplies, net of credit notes. A supplier does not report the GST of a supply under customer accounting.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '7', 'tax', 'Input tax and refunds claimed', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 7 — the input tax claimable on the purchases of box 5, the GST on the import permits, the claimable part of the GST on reverse charge supplies, and the refunds of boxes 10 to 12, net of credit notes.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '8', 'total', 'Net GST to be paid to or claimed from IRAS', '{}'::jsonb, 80, null, array['6']::text[], array['7']::text[], null, null, false, false, null, 'Form GST F5, box 8 — box 6 less box 7, which the form computes. Goods and Services Tax Act 1993, s. 41(7): a net amount of less than $5 either way is zero, which the pack does not apply — it reports the difference.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '9', 'base', 'Total value of goods imported under MES / A3PL / other approved schemes', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 9 — filled only by a business approved under the Major Exporter Scheme, the Approved Third Party Logistics Company Scheme or another approved scheme: the value of its imports under the scheme, which are also in box 5.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '10', 'tax', 'Tourist refund claimed', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 10 — ''Did you claim for GST you had refunded to tourists?'', and the amount included in box 7. Declared and empty: the Tourist Refund Scheme is not a document of the ledger.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '11', 'tax', 'Bad debt relief and reverse charge refund claims', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 11 — bad debt relief claims and refund claims for reverse charge transactions not paid within 12 months, included in box 7. Declared and empty: neither is a document the pack posts.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '12', 'tax', 'Pre-registration claims', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 12 — input tax claimed on purchases made before registration, in the first return only. Declared and empty.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '13', 'base', 'Revenue', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 13 — the revenue of the period from the profit and loss account: sales of goods, services and other operating income, excluding disposals of fixed assets and grants. It is an accounting figure and not a tax base, and IRAS accepts a best estimate; no tax posts to it, so it is declared and empty. See docs/international.md.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '14', 'base', 'Value of imported services and low-value goods subject to reverse charge', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 14 — filled by a business that must account for GST under the reverse charge: the value of those services and goods, which is also in box 1 and box 5.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '15', 'base', 'Remote services supplied as an electronic marketplace operator', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 15 — the value of remote services an electronic marketplace operator supplies on behalf of third-party suppliers, also in box 1. Declared and empty: the pack carries no marketplace code.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '16', 'base', 'Low-value goods supplied as a redeliverer or electronic marketplace operator', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 16 — the value of imported low-value goods a redeliverer or electronic marketplace operator supplies on behalf of third-party suppliers, also in box 1. Declared and empty.', 'iras-f5'),
  ('SG', 'SG-GST-F5', '17', 'base', 'Own supplies of imported low-value goods', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST F5, box 17 — the value of the supplier''s own supplies of imported low-value goods subject to GST, also in box 1. Declared and empty: such a supply is a standard-rated sale the pack posts to box 1 alone.', 'iras-f5')
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
  ('SG-SFRSSE-IS', 'SG', 'default', 'Income statement — SFRS for Small Entities, expenses by nature', 'income_statement', 'SG-SFRS-SE', date '1970-01-01', null, 'Companies Act 1967, s. 201(2); SFRS for Small Entities, Section 5 — the minimum line items of the income statement (revenue, finance costs, the share of associates and joint ventures, tax expense, discontinued operations and profit or loss) and an analysis of expenses by nature or by function; this one is by nature, which a small company''s ledger holds without an allocation. Paragraph numbers are those of the IFRS for SMEs Accounting Standard the SFRS for Small Entities is based on, for the reason given on the statement of financial position.', 'companies-act'),
  ('SG-SFRSSE-SFP', 'SG', 'default', 'Statement of financial position — SFRS for Small Entities', 'balance_sheet', 'SG-SFRS-SE', date '1970-01-01', null, 'Companies Act 1967, s. 201(1) and (2) — the directors lay before the annual general meeting financial statements that comply with the Accounting Standards and give a true and fair view; the Accounting Standards Committee under ACRA issues SFRS for Small Entities, which is based on the IFRS for SMEs Accounting Standard (ACRA, Accounting standards). Section 4 of that standard lists the line items of the statement of financial position as a minimum and prescribes neither their order nor their format; the lines below are those items in the order a Singapore statement prints them, current and non-current apart. The text of the standard is served to Singapore addresses only and was not read for this pack: every paragraph number here is the IFRS for SMEs numbering and is the first thing a reviewer should check. Biological assets, non-controlling interests and assets held for sale are not lines, because the chart holds no account for them.', 'companies-act')
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
  ('SG-SFRSSE-IS', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, Section 5, paragraph 5.5(a).', 'acra-standards'),
  ('SG-SFRSSE-IS', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.9 — an additional line item: interest, dividends, rent, grants, exchange gains and gains on disposal.', 'acra-standards'),
  ('SG-SFRSSE-IS', '3', null, 'Purchases and changes in inventories', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.11(a) — expenses analysed by their nature.', 'acra-standards'),
  ('SG-SFRSSE-IS', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.11(a) — employee benefits, CPF contributions and the levies among them.', 'acra-standards'),
  ('SG-SFRSSE-IS', '5', null, 'Depreciation and amortisation', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.11(a).', 'acra-standards'),
  ('SG-SFRSSE-IS', '6', null, 'Other operating expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.11(a) — the other expenses by nature, exchange losses and losses on disposal among them.', 'acra-standards'),
  ('SG-SFRSSE-IS', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.5(b).', 'acra-standards'),
  ('SG-SFRSSE-IS', '8', null, 'Profit before income tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('SG-SFRSSE-IS', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 5.5(d) — tax expense.', 'acra-standards'),
  ('SG-SFRSSE-IS', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'SFRS for Small Entities, paragraph 5.5(f) — profit or loss. The pack carries no item of other comprehensive income, so it is also the total comprehensive income.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'SFRS for Small Entities, Section 4, paragraphs 4.4 to 4.6 — current and non-current assets are presented as separate classifications.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(a).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(b). The GST input tax and the refund due from IRAS are presented here rather than as current tax, which paragraph 4.2(n) keeps for income tax.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(d).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(c), the part realised within twelve months.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(n) — assets for current tax, which is income tax.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CA.6', 'CA', 'Prepayments and accrued income', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.3 — an additional line item, relevant to an understanding of the financial position.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraphs 4.4 and 4.6 — every asset that is not current is non-current.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(e). Right-of-use assets are presented within it.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.2', 'NCA', 'Investment property', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(f).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.3', 'NCA', 'Intangible assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(g), goodwill with them.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.4', 'NCA', 'Investments in associates', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(j).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.5', 'NCA', 'Investments in joint ventures', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(k).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.6', 'NCA', 'Financial assets', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(c), the part not realised within twelve months.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCA.7', 'NCA', 'Deferred tax assets', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(o) — deferred tax assets are always non-current.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 160, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('SG-SFRSSE-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 170, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraphs 4.4, 4.7 and 4.8 — current and non-current liabilities are presented as separate classifications.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(l). GST output tax, the GST payable to IRAS, import GST owed to Singapore Customs, withholding tax, CPF contributions and the levies are presented here.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CL.2', 'CL', 'Borrowings and other financial liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(m), the part due within twelve months, the credit card and amounts due to directors among them.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(n) — liabilities for current tax.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'CL.4', 'CL', 'Provisions', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(p), the part expected to be settled within twelve months.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 220, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.8 — every liability that is not current is non-current.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCL.1', 'NCL', 'Borrowings and other financial liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(m), the part not due within twelve months.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCL.2', 'NCL', 'Deferred tax liabilities', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(o).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'NCL.3', 'NCL', 'Provisions', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(p), the part not expected to be settled within twelve months.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 260, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('SG-SFRSSE-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 270, 1, true, array['TA']::text[], array['TL']::text[], null, 'SFRS for Small Entities, paragraph 4.3 — an additional subtotal. It equals total equity once the year is closed; before, it exceeds equity by the result of the open year.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 280, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.2(r) — equity attributable to the owners of the parent, and paragraph 4.12(b) for its classes.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'EQ.1', 'EQ', 'Share capital', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.12(a). Shares of a Singapore company have no par value, so share capital is one line and treasury shares are deducted from it.', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'EQ.2', 'EQ', 'Other reserves', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.12(b).', 'acra-standards'),
  ('SG-SFRSSE-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'SFRS for Small Entities, paragraph 4.12(b) — retained earnings, after the dividends paid booked beside them.', 'acra-standards')
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
    ('SG-SFRSSE-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('SG-SFRSSE-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('SG-SFRSSE-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('SG-SFRSSE-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('SG-SFRSSE-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('SG-SFRSSE-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('SG-SFRSSE-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('SG-SFRSSE-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('SG-SFRSSE-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('SG-SFRSSE-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('SG-SFRSSE-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('SG-SFRSSE-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('SG-SFRSSE-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('SG-SFRSSE-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('SG-SFRSSE-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('SG-SFRSSE-SFP', 'CL.2', 10, 'code_range', '2200', '2250', null, 'any'),
    ('SG-SFRSSE-SFP', 'CL.3', 10, 'account_code', '2300', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'CL.4', 10, 'code_range', '2350', '2360', null, 'any'),
    ('SG-SFRSSE-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('SG-SFRSSE-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('SG-SFRSSE-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('SG-SFRSSE-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('SG-SFRSSE-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('SG', 'Singapore', '{}'::jsonb, array['en']::text[], 'SGD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = 'GST (General) Regulations, reg. 11(1)(b) — a tax invoice states an identifying number, and reg. 13(1)(b) asks the same of a simplified invoice. The regulation asks that each invoice be identified and not that the series have no gap, which is why the style is `sequential` and not a gapless one; the pattern in number_format is one a business may choose.',
  numbering_source_key          = 'gst-general-regs',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Goods and Services Tax Act 1993, s. 11(2) — a supply other than a reverse charge supply is treated as taking place when the supplier issues an invoice or receives any consideration for it, whichever comes first, to the extent the invoice or the consideration covers it; s. 11(3) and (4) move a sale of land, and a supplier the Comptroller allows, to removal or performance unless an invoice or a payment comes first. Delivery plays no part in the general rule. `invoice_date` is right whenever the invoice comes first, which is the ordinary case between businesses, and wrong for a deposit received before any invoice, which Ekwo has no document for.',
  tax_point_source_key          = 'gst-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'pint-sg',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Singapore statute obliges a business to send an electronic invoice to another business or to accept one, so the obligation is `none` and mandatory_from is empty. What Singapore has instead is the GST InvoiceNow Requirement: a GST-registered business submits the data of its sales and purchase invoices to IRAS through InvoiceNow, the Peppol network IMDA runs as the Singapore Peppol Authority, by the earlier of the day it files the relevant GST return and that return''s due date. IRAS, GST InvoiceNow Requirement, and its e-Tax Guide (second edition, 9 March 2026, paragraph 2.3): from 1 November 2025 for companies registering voluntarily within six months of incorporation, from 1 April 2026 for every new voluntary registrant, as a condition of voluntary registration; then, in phases on 1 April 2028 (new compulsory registrants, and existing ones with annual supplies up to $200,000), 1 April 2029 (up to $1 million), 1 April 2030 (up to $4 million) and 1 April 2031 (the rest), by legislative amendments the e-Tax Guide says will be enacted at a later date. It is a transmission to the tax administration, which a buyer''s invoice may or may not travel with, and not an exchange between businesses; the vocabulary has no word for it, which docs/international.md records. The profile is PINT SG Billing (customization urn:peppol:pint:billing-1@sg-1), the data format of the requirement. A party is addressed by its UEN under ICD 0195, Singapore Nationwide E-Invoice Framework, the Peppol ID the e-Tax Guide asks every business to register in the SG Peppol Directory. The GST registration number — the UEN for most companies, an M-prefixed number for others — has no ISO 6523 scheme of its own, so vat_scheme is empty. PINT SG carries its own GST category codes (SR, ZR, ES33, ESN33, OS, NG, SRCA-S, SRCA-C, SRRC and others), which are not the UNCL5305 letters vat_category holds: each tax names its PINT SG code in its legal_reference.',
  einvoice_source_key           = 'iras-invoicenow-guide',
  party_scheme                  = '0195',
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'SG';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('SG', 'zero_rated', 'export', 'Zero-rated supply under section 21 of the Goods and Services Tax Act 1993.', '{}'::jsonb, 10, date '1970-01-01', null, 'GST (General) Regulations, reg. 11(3) — an invoice that includes a zero-rated or exempt supply distinguishes it from the other supplies and states the gross total of each separately. The sentence says why no GST is charged on an export of goods or an international service.'),
  ('SG', 'exempt', 'exempt', 'Exempt supply under section 22 and the Fourth Schedule of the Goods and Services Tax Act 1993.', '{}'::jsonb, 20, date '1970-01-01', null, 'GST (General) Regulations, reg. 11(3), as for the zero-rated mention; Goods and Services Tax Act 1993, s. 22(1) and the Fourth Schedule, Part 1, name the exempt supplies.'),
  ('SG', 'customer_accounting', 'reverse_charge', 'Customer accounting — the customer must account for and pay the GST on this supply of prescribed goods under section 38A of the Goods and Services Tax Act 1993.', '{}'::jsonb, 30, date '1970-01-01', null, 'GST (General) Regulations, reg. 11(4) — where section 38A of the Act applies, the tax invoice also includes the customer''s registration number and a statement sufficient to inform the customer that it must account for and pay the tax; IRAS, Customer accounting for prescribed goods, adds the GST amount to that statement, which a sentence cannot carry and a renderer prints beside it.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
