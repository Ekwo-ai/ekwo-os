-- Ekwo OS — New Zealand: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/nz at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build nz`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Goods and Services Tax Act 1985 (No 141), as compiled (Parliamentary Counsel Office — New Zealand Legislation)
--     https://www.legislation.govt.nz/act/public/1985/0141/latest/whole.html
--   Income Tax Act 2007 (No 97) — the income year and its standard balance date (Parliamentary Counsel Office — New Zealand Legislation)
--     https://www.legislation.govt.nz/act/public/2007/0097/latest/whole.html
--   Tax Administration Act 1994 (No 166) (Parliamentary Counsel Office — New Zealand Legislation)
--     https://www.legislation.govt.nz/act/public/1994/0166/latest/whole.html
--   Companies Act 1993 (No 105), Part 11 — financial statements and annual reports (Parliamentary Counsel Office — New Zealand Legislation)
--     https://www.legislation.govt.nz/act/public/1993/0105/latest/whole.html
--   Financial Reporting Act 2013 (No 101) — reporting entities and the External Reporting Board (Parliamentary Counsel Office — New Zealand Legislation)
--     https://www.legislation.govt.nz/act/public/2013/0101/latest/whole.html
--   XRB A1 Application of the Accounting Standards Framework (For-profit Entities Update) (External Reporting Board (XRB))
--     https://www.xrb.govt.nz/standards/accounting-standards/for-profit-standards/a1/
--   IR375 — GST guide: Working with GST (March 2026) (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/-/media/project/ir/home/documents/forms-and-guides/ir300---ir399/ir375/ir375.pdf
--   Taxable supply information for GST (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst/tax-invoices-for-gst
--   Changing your GST filing frequency (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst/changing-your-filing-frequency-or-accounting-basis/changing-your-gst-filing-frequency
--   myIR — file and manage GST (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst
--   GST for overseas businesses (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst/gst-for-overseas-businesses
--   Exempt supplies (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst/charging-gst/exempt-supplies
--   Zero-rated supplies (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst/charging-gst/zero-rated-supplies
--   Filing a GST return (Inland Revenue Te Tari Taake)
--     https://www.ird.govt.nz/gst/filing-a-gst-return
--   XRB A1 Application of the Accounting Standards Framework (For-profit Entities Update), effective 1 January 2026 (External Reporting Board (XRB))
--     https://www.xrb.govt.nz/dmsdocument/5470/
--   PINT A-NZ Billing BIS — Peppol International specification for Australia and New Zealand (OpenPeppol, with the ATO and the New Zealand Peppol Authority)
--     https://docs.peppol.eu/poac/aunz/pint-aunz/bis/
--   Electronic Address Scheme (EAS) code list (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   UNCL5305 — duty or tax or fee category code (OpenPEPPOL — the list itself is published by UN/CEFACT)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   New Zealand Business Number (NZBN) register (Ministry of Business, Innovation and Employment (MBIE))
--     https://www.nzbn.govt.nz/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('NZ', 'New Zealand', '0.1.0', date '2026-09-21', '20260921145425', 'community', null, null, '43c2b19fb5b68b837da8ac4dbe517c59ce9bf40b2e8d3189df041fe64c989531', '[{"key":"gst-act","title":"Goods and Services Tax Act 1985 (No 141), as compiled","publisher":"Parliamentary Counsel Office — New Zealand Legislation","url":"https://www.legislation.govt.nz/act/public/1985/0141/latest/whole.html","consulted_on":"2026-09-21","kind":"law"},{"key":"income-tax-act","title":"Income Tax Act 2007 (No 97) — the income year and its standard balance date","publisher":"Parliamentary Counsel Office — New Zealand Legislation","url":"https://www.legislation.govt.nz/act/public/2007/0097/latest/whole.html","consulted_on":"2026-09-21","kind":"law"},{"key":"tax-admin-act","title":"Tax Administration Act 1994 (No 166)","publisher":"Parliamentary Counsel Office — New Zealand Legislation","url":"https://www.legislation.govt.nz/act/public/1994/0166/latest/whole.html","consulted_on":"2026-09-21","kind":"law"},{"key":"companies-act","title":"Companies Act 1993 (No 105), Part 11 — financial statements and annual reports","publisher":"Parliamentary Counsel Office — New Zealand Legislation","url":"https://www.legislation.govt.nz/act/public/1993/0105/latest/whole.html","consulted_on":"2026-09-21","kind":"law"},{"key":"financial-reporting-act","title":"Financial Reporting Act 2013 (No 101) — reporting entities and the External Reporting Board","publisher":"Parliamentary Counsel Office — New Zealand Legislation","url":"https://www.legislation.govt.nz/act/public/2013/0101/latest/whole.html","consulted_on":"2026-09-21","kind":"law"},{"key":"xrb-framework","title":"XRB A1 Application of the Accounting Standards Framework (For-profit Entities Update)","publisher":"External Reporting Board (XRB)","url":"https://www.xrb.govt.nz/standards/accounting-standards/for-profit-standards/a1/","consulted_on":"2026-09-21","kind":"standard"},{"key":"ir375","title":"IR375 — GST guide: Working with GST (March 2026)","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/-/media/project/ir/home/documents/forms-and-guides/ir300---ir399/ir375/ir375.pdf","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-taxable-supply-information","title":"Taxable supply information for GST","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst/tax-invoices-for-gst","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-filing-frequency","title":"Changing your GST filing frequency","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst/changing-your-filing-frequency-or-accounting-basis/changing-your-gst-filing-frequency","consulted_on":"2026-09-21","kind":"guidance"},{"key":"ird-gst-portal","title":"myIR — file and manage GST","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst","consulted_on":"2026-09-21","kind":"portal"},{"key":"gst-overseas-businesses","title":"GST for overseas businesses","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst/gst-for-overseas-businesses","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-exempt-supplies","title":"Exempt supplies","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst/charging-gst/exempt-supplies","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-zero-rated-supplies","title":"Zero-rated supplies","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst/charging-gst/zero-rated-supplies","consulted_on":"2026-09-21","kind":"guidance"},{"key":"gst-return-filing","title":"Filing a GST return","publisher":"Inland Revenue Te Tari Taake","url":"https://www.ird.govt.nz/gst/filing-a-gst-return","consulted_on":"2026-09-21","kind":"guidance"},{"key":"xrb-a1","title":"XRB A1 Application of the Accounting Standards Framework (For-profit Entities Update), effective 1 January 2026","publisher":"External Reporting Board (XRB)","url":"https://www.xrb.govt.nz/dmsdocument/5470/","consulted_on":"2026-09-21","kind":"standard"},{"key":"pint-aunz","title":"PINT A-NZ Billing BIS — Peppol International specification for Australia and New Zealand","publisher":"OpenPeppol, with the ATO and the New Zealand Peppol Authority","url":"https://docs.peppol.eu/poac/aunz/pint-aunz/bis/","consulted_on":"2026-09-21","kind":"standard"},{"key":"peppol-eas","title":"Electronic Address Scheme (EAS) code list","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-21","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — duty or tax or fee category code","publisher":"OpenPEPPOL — the list itself is published by UN/CEFACT","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-21","kind":"standard"},{"key":"nzbn-register","title":"New Zealand Business Number (NZBN) register","publisher":"Ministry of Business, Innovation and Employment (MBIE)","url":"https://www.nzbn.govt.nz/","consulted_on":"2026-09-21","kind":"portal"}]'::jsonb)
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
  ('NZ', 'default', 'New Zealand reference chart of accounts', '{}'::jsonb, true, 'companies', array['NZ-XRB-PL', 'NZ-XRB-SFP']::text[], null, 'There is no legal chart of accounts in New Zealand. Companies Act 1993, s. 194 requires a company to keep accounting records that correctly record and explain its transactions and would enable financial statements to be readily and properly audited, and prescribes none; s. 201 requires the board of every company that is a ''large'' company (Financial Reporting Act 2013, s. 45 — a company, together with its subsidiaries, whose total assets or total revenue exceed the amounts the Act and its regulations set, or that is an FMC reporting entity), or that is not large but whose shareholders have not unanimously resolved against it under s. 207I of the Companies Act, to ensure that financial statements are prepared that comply with generally accepted accounting practice within the meaning of the Financial Reporting Act 2013. A small company with no such shareholders and no such size prepares no statutory financial statements at all; its books still feed the income tax return and the GST return, which is what this pack is mostly for. This chart is original: four digits, blocked so that each range reaches one line item of the minimum line items a Tier 2 for-profit entity presents under NZ IFRS (Reduced Disclosure Regime), which XRB A1 assigns to a reporting entity that has no public accountability and elects the reduced disclosure regime.', 'companies-act')
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
  ('NZ', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('NZ', 'default', '1010', 'Business cheque account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('NZ', 'default', '1020', 'Business savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('NZ', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('NZ', 'default', '1040', 'Merchant card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('NZ', 'default', '1050', 'Term deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('NZ', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('NZ', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('NZ', 'default', '1105', 'Provision for doubtful debts', '{}'::jsonb, 'asset_current', false, null, 90),
  ('NZ', 'default', '1110', 'Amounts receivable from related parties', '{}'::jsonb, 'asset_current', false, null, 100),
  ('NZ', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('NZ', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('NZ', 'default', '1140', 'Employee advances', '{}'::jsonb, 'asset_current', false, null, 130),
  ('NZ', 'default', '1150', 'GST paid on purchases — Box 11', '{}'::jsonb, 'asset_current', false, null, 140),
  ('NZ', 'default', '1152', 'GST on purchases accounted for on a payments basis — awaiting payment', '{}'::jsonb, 'asset_current', false, null, 150),
  ('NZ', 'default', '1155', 'GST refund due from Inland Revenue — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 160),
  ('NZ', 'default', '1160', 'Provisional tax paid', '{}'::jsonb, 'asset_current', false, null, 170),
  ('NZ', 'default', '1170', 'RWT deducted at source — imputation credits carried forward', '{}'::jsonb, 'asset_current', false, null, 180),
  ('NZ', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 190),
  ('NZ', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 200),
  ('NZ', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 210),
  ('NZ', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 220),
  ('NZ', 'default', '1300', 'Term deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 230),
  ('NZ', 'default', '1310', 'Listed securities held for trading', '{}'::jsonb, 'asset_current', false, null, 240),
  ('NZ', 'default', '1320', 'Loans to related parties — current', '{}'::jsonb, 'asset_current', false, null, 250),
  ('NZ', 'default', '1350', 'Income tax refundable', '{}'::jsonb, 'asset_current', false, null, 260),
  ('NZ', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('NZ', 'default', '1410', 'Deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('NZ', 'default', '1420', 'Payments on account to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 290),
  ('NZ', 'default', '1600', 'Freehold land', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('NZ', 'default', '1610', 'Buildings', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('NZ', 'default', '1611', 'Buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('NZ', 'default', '1620', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('NZ', 'default', '1621', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('NZ', 'default', '1630', 'Plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('NZ', 'default', '1631', 'Plant and equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('NZ', 'default', '1640', 'Office furniture and equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('NZ', 'default', '1641', 'Office furniture and equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('NZ', 'default', '1650', 'Computer equipment', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('NZ', 'default', '1651', 'Computer equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('NZ', 'default', '1660', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('NZ', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 420),
  ('NZ', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('NZ', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 440),
  ('NZ', 'default', '1680', 'Capital works in progress', '{}'::jsonb, 'asset_fixed', false, null, 450),
  ('NZ', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('NZ', 'default', '1750', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 470),
  ('NZ', 'default', '1751', 'Goodwill — accumulated impairment', '{}'::jsonb, 'asset_fixed', false, null, 480),
  ('NZ', 'default', '1760', 'Software and development costs', '{}'::jsonb, 'asset_fixed', false, null, 490),
  ('NZ', 'default', '1761', 'Software and development costs — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 500),
  ('NZ', 'default', '1770', 'Patents, trade marks and licences', '{}'::jsonb, 'asset_fixed', false, null, 510),
  ('NZ', 'default', '1771', 'Patents, trade marks and licences — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 520),
  ('NZ', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 530),
  ('NZ', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 540),
  ('NZ', 'default', '1820', 'Shares in unlisted entities', '{}'::jsonb, 'asset_non_current', false, null, 550),
  ('NZ', 'default', '1830', 'Loans to related parties — non-current', '{}'::jsonb, 'asset_non_current', false, null, 560),
  ('NZ', 'default', '1840', 'Security deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 570),
  ('NZ', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 580),
  ('NZ', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 590),
  ('NZ', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 600),
  ('NZ', 'default', '2020', 'Amounts payable to related parties', '{}'::jsonb, 'liability_current', false, null, 610),
  ('NZ', 'default', '2030', 'Other creditors', '{}'::jsonb, 'liability_current', false, null, 620),
  ('NZ', 'default', '2040', 'Customer deposits and contract liabilities', '{}'::jsonb, 'liability_current', false, null, 630),
  ('NZ', 'default', '2050', 'Wages and salaries payable', '{}'::jsonb, 'liability_current', false, null, 640),
  ('NZ', 'default', '2060', 'KiwiSaver employer contributions payable', '{}'::jsonb, 'liability_current', false, null, 650),
  ('NZ', 'default', '2065', 'ACC levies payable', '{}'::jsonb, 'liability_current', false, null, 660),
  ('NZ', 'default', '2070', 'PAYE deducted from employees — payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('NZ', 'default', '2075', 'Employer superannuation contribution tax (ESCT) payable', '{}'::jsonb, 'liability_current', false, null, 680),
  ('NZ', 'default', '2080', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 690),
  ('NZ', 'default', '2085', 'Resident withholding tax (RWT) deducted — payable', '{}'::jsonb, 'liability_current', false, null, 700),
  ('NZ', 'default', '2090', 'Non-resident withholding tax (NRWT) deducted — payable', '{}'::jsonb, 'liability_current', false, null, 710),
  ('NZ', 'default', '2100', 'GST collected on sales — Box 5', '{}'::jsonb, 'liability_current', false, null, 720),
  ('NZ', 'default', '2105', 'GST on sales accounted for on a payments basis — awaiting payment', '{}'::jsonb, 'liability_current', false, null, 730),
  ('NZ', 'default', '2110', 'GST payable to Inland Revenue — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 740),
  ('NZ', 'default', '2130', 'Fringe benefit tax (FBT) payable', '{}'::jsonb, 'liability_current', false, null, 750),
  ('NZ', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 760),
  ('NZ', 'default', '2210', 'Business credit card', '{}'::jsonb, 'liability_credit_card', false, null, 770),
  ('NZ', 'default', '2220', 'Bank loans — current', '{}'::jsonb, 'liability_current', false, null, 780),
  ('NZ', 'default', '2230', 'Lease liabilities — current', '{}'::jsonb, 'liability_current', false, null, 790),
  ('NZ', 'default', '2240', 'Hire purchase liabilities — current', '{}'::jsonb, 'liability_current', false, null, 800),
  ('NZ', 'default', '2300', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 810),
  ('NZ', 'default', '2310', 'Provisional tax payable', '{}'::jsonb, 'liability_current', false, null, 820),
  ('NZ', 'default', '2350', 'Provision for annual leave', '{}'::jsonb, 'liability_current', false, null, 830),
  ('NZ', 'default', '2360', 'Provision for long service and sick leave', '{}'::jsonb, 'liability_current', false, null, 840),
  ('NZ', 'default', '2370', 'Provision for warranties and other provisions — current', '{}'::jsonb, 'liability_current', false, null, 850),
  ('NZ', 'default', '2400', 'Bank loans — non-current', '{}'::jsonb, 'liability_non_current', false, null, 860),
  ('NZ', 'default', '2410', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 870),
  ('NZ', 'default', '2420', 'Hire purchase liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 880),
  ('NZ', 'default', '2430', 'Loans from shareholders and related parties — non-current', '{}'::jsonb, 'liability_non_current', false, null, 890),
  ('NZ', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 900),
  ('NZ', 'default', '2550', 'Provision for long service leave — non-current', '{}'::jsonb, 'liability_non_current', false, null, 910),
  ('NZ', 'default', '2560', 'Provision for make good and restoration', '{}'::jsonb, 'liability_non_current', false, null, 920),
  ('NZ', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 930),
  ('NZ', 'default', '3000', 'Issued share capital — ordinary shares', '{}'::jsonb, 'equity', false, null, 940),
  ('NZ', 'default', '3010', 'Issued share capital — preference shares', '{}'::jsonb, 'equity', false, null, 950),
  ('NZ', 'default', '3100', 'Asset revaluation reserve', '{}'::jsonb, 'equity', false, null, 960),
  ('NZ', 'default', '3110', 'Other reserves', '{}'::jsonb, 'equity', false, null, 970),
  ('NZ', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 980),
  ('NZ', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 990),
  ('NZ', 'default', '4000', 'Sales — goods', '{}'::jsonb, 'income', false, null, 1010),
  ('NZ', 'default', '4010', 'Sales — services', '{}'::jsonb, 'income', false, null, 1020),
  ('NZ', 'default', '4020', 'Sales — zero-rated goods and services', '{}'::jsonb, 'income', false, null, 1030),
  ('NZ', 'default', '4025', 'Sales — land and buildings held as trading stock', '{}'::jsonb, 'income', false, null, 1035),
  ('NZ', 'default', '4030', 'Sales — exports', '{}'::jsonb, 'income', false, null, 1040),
  ('NZ', 'default', '4035', 'Sale of a taxable activity as a going concern', '{}'::jsonb, 'income', false, null, 1045),
  ('NZ', 'default', '4040', 'Residential rental income', '{}'::jsonb, 'income', false, null, 1050),
  ('NZ', 'default', '4050', 'Retail takings', '{}'::jsonb, 'income', false, null, 1060),
  ('NZ', 'default', '4080', 'Sales returns and allowances', '{}'::jsonb, 'income', false, null, 1070),
  ('NZ', 'default', '4090', 'Discounts allowed', '{}'::jsonb, 'income', false, null, 1080),
  ('NZ', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 1090),
  ('NZ', 'default', '4510', 'Commercial rental income', '{}'::jsonb, 'income_other', false, null, 1100),
  ('NZ', 'default', '4520', 'Government grants and subsidies', '{}'::jsonb, 'income_other', false, null, 1110),
  ('NZ', 'default', '4530', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 1120),
  ('NZ', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 1130),
  ('NZ', 'default', '4750', 'Gain on disposal of non-current assets', '{}'::jsonb, 'income_other', false, null, 1140),
  ('NZ', 'default', '5000', 'Purchases — goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1150),
  ('NZ', 'default', '5010', 'Purchases — raw materials and consumables', '{}'::jsonb, 'expense_direct_cost', false, null, 1160),
  ('NZ', 'default', '5020', 'Freight and cartage inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 1170),
  ('NZ', 'default', '5030', 'Customs duty and import charges', '{}'::jsonb, 'expense_direct_cost', false, null, 1180),
  ('NZ', 'default', '5040', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1190),
  ('NZ', 'default', '5100', 'Subcontractors', '{}'::jsonb, 'expense_direct_cost', false, null, 1200),
  ('NZ', 'default', '6000', 'Wages and salaries', '{}'::jsonb, 'expense', false, null, 1210),
  ('NZ', 'default', '6010', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1220),
  ('NZ', 'default', '6020', 'KiwiSaver employer contributions', '{}'::jsonb, 'expense', false, null, 1230),
  ('NZ', 'default', '6030', 'ACC levies', '{}'::jsonb, 'expense', false, null, 1240),
  ('NZ', 'default', '6040', 'Employer superannuation contribution tax (ESCT)', '{}'::jsonb, 'expense', false, null, 1250),
  ('NZ', 'default', '6050', 'Annual and long service leave expense', '{}'::jsonb, 'expense', false, null, 1260),
  ('NZ', 'default', '6060', 'Fringe benefit tax (FBT)', '{}'::jsonb, 'expense', false, null, 1270),
  ('NZ', 'default', '6070', 'Staff training and amenities', '{}'::jsonb, 'expense', false, null, 1280),
  ('NZ', 'default', '6200', 'Depreciation — buildings and leasehold improvements', '{}'::jsonb, 'expense_depreciation', false, null, 1290),
  ('NZ', 'default', '6210', 'Depreciation — plant, equipment and motor vehicles', '{}'::jsonb, 'expense_depreciation', false, null, 1300),
  ('NZ', 'default', '6220', 'Depreciation — right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1310),
  ('NZ', 'default', '6230', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1320),
  ('NZ', 'default', '6300', 'Rent and outgoings', '{}'::jsonb, 'expense', false, null, 1330),
  ('NZ', 'default', '6310', 'Electricity, gas and water', '{}'::jsonb, 'expense', false, null, 1340),
  ('NZ', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1350),
  ('NZ', 'default', '6330', 'Insurance', '{}'::jsonb, 'expense', false, null, 1360),
  ('NZ', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1370),
  ('NZ', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1380),
  ('NZ', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1390),
  ('NZ', 'default', '6370', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1400),
  ('NZ', 'default', '6380', 'Travel and accommodation', '{}'::jsonb, 'expense', false, null, 1410),
  ('NZ', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1420),
  ('NZ', 'default', '6400', 'Accounting and audit fees', '{}'::jsonb, 'expense', false, null, 1430),
  ('NZ', 'default', '6410', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 1440),
  ('NZ', 'default', '6420', 'Consulting fees', '{}'::jsonb, 'expense', false, null, 1450),
  ('NZ', 'default', '6430', 'Bank fees and merchant charges', '{}'::jsonb, 'expense', false, null, 1460),
  ('NZ', 'default', '6440', 'Printing, postage and stationery', '{}'::jsonb, 'expense', false, null, 1470),
  ('NZ', 'default', '6450', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1480),
  ('NZ', 'default', '6460', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1490),
  ('NZ', 'default', '6470', 'Donations', '{}'::jsonb, 'expense', false, null, 1500),
  ('NZ', 'default', '6480', 'Rates', '{}'::jsonb, 'expense', false, null, 1510),
  ('NZ', 'default', '6490', 'Sundry expenses', '{}'::jsonb, 'expense', false, null, 1520),
  ('NZ', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1530),
  ('NZ', 'default', '6960', 'Loss on disposal of non-current assets', '{}'::jsonb, 'expense', false, null, 1540),
  ('NZ', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1550),
  ('NZ', 'default', '7000', 'Interest on bank loans and overdraft', '{}'::jsonb, 'expense', false, null, 1560),
  ('NZ', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1570),
  ('NZ', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1580),
  ('NZ', 'default', '7030', 'Use-of-money interest to Inland Revenue', '{}'::jsonb, 'expense', false, null, 1590),
  ('NZ', 'default', '8000', 'Income tax expense — current', '{}'::jsonb, 'expense', false, null, 1600),
  ('NZ', 'default', '8010', 'Income tax expense — deferred', '{}'::jsonb, 'expense', false, null, 1610),
  ('NZ', 'default', '8020', 'Income tax — under or over provision of prior years', '{}'::jsonb, 'expense', false, null, 1620)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('NZ', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('NZ', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('NZ', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('NZ', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('NZ', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('NZ', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('NZ', 'NZ-P-EXEMPT', 'Purchase, exempt', '{}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 14 — an exempt supply carries no GST: bank fees and residential rent paid by the business among them. Kept out of Box 11 for the same reason as a zero-rated purchase.', 'E', null, 150, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-P-GST', 'Purchase, GST 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 20(3) — a registered person may deduct input tax on a good or service acquired for the principal purpose of making taxable supplies, subject to holding taxable supply information. Inland Revenue, GST guide (IR375): Box 11 is the total of purchases and expenses for which a GST deduction is claimed, GST-inclusive, excluding imported goods, so the GST-exclusive value of the purchase is grossed to 115 % and written into Box 11; the credit itself is the real ledger amount, posted straight to Box 12, the box the return''s own ''3/23 of Box 11'' instruction would otherwise reconstruct.', 'S', null, 110, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'ir375', null, null, null, null),
  ('NZ', 'NZ-P-GST-ITS', 'Purchase, GST 15 %, not deductible — relates to exempt supplies', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 20(3) and s. 21 — input tax is deductible only to the extent the good or service is used for, or is available for use in, making taxable supplies; a good or service acquired to make an exempt supply — residential renting among them — carries no deduction, subject to the apportionment rules of s. 21, which this pack does not carry. Box 11 is itself the total of purchases for which a credit is claimed, so an amount with no credit to claim is kept out of it entirely, the way a zero-rated or exempt purchase is; the GST is part of what the thing cost and lands on the account of the line through tax_on_base.', 'S', null, 130, 'gst', false, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-P-GST-PAY', 'Purchase, GST 15 %, accounted for on the payments basis', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 20(3) — under the payments basis, an input tax deduction is claimed only to the extent the consideration has been paid, and only where the registered person holds taxable supply information. The condition is the purchasing entity''s own choice of basis, which no word of `conditions` names for a purchase, so the reference carries it, the way the equivalent Australian and Irish codes do. The tax posting names Box 12, where the settled credit is declared once payment moves it off the transition account.', 'S', null, 120, 'gst', true, '{}'::tax_condition[], null, false, true, '1152', 'ir375', null, null, null, null),
  ('NZ', 'NZ-P-NOGST', 'Purchase with no GST in the price', '{}'::jsonb, null, 'percent', 0, 'purchase', 'not_subject', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 8(1) — a supply by a person who is not registered carries no GST, and neither does a payment that is not consideration for a supply at all: most statutory rates, fines and penalty interest. Kept out of Box 11.', 'O', null, 160, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-P-RC-IMPORTED', 'Imported service reverse charged under section 8(4B), not deductible', '{}'::jsonb, null, 'percent', 15, 'purchase', 'foreign_services_received', date '2016-10-01', null, 'Goods and Services Tax Act 1985, s. 8(4B) — a recipient of imported services is treated as having supplied the services to themselves, and GST is charged accordingly, where the recipient''s intended or actual percentage of taxable use of the services is less than 95 %, inserted with effect from 1 October 2016. Because the section reaches precisely the recipient who cannot deduct the whole of the GST back, this code models the simplest case — taxable use assumed at nil, a financial institution or a residential landlord being the ordinary case — and carries no matching credit at all: the self-assessed value is grossed into Box 5 and the self-assessed GST posted to Box 8 exactly as an ordinary sale''s would be, because s. 8(4B) deems the recipient the supplier of the services to itself, while the whole of it is also a cost of the acquisition through tax_on_base, on the account of the line. It is kept out of Box 11 entirely, the way any non-creditable purchase is: no credit is ever claimed on it. A recipient whose actual taxable use is between 0 % and 95 % needs the apportionment of s. 20(3), which this pack does not carry.', null, null, 170, 'gst', false, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-P-ZERO', 'Purchase, zero-rated', '{}'::jsonb, null, 'percent', 0, 'purchase', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, ss. 11, 11A — the supplier charged no GST because the supply was zero-rated, so there is none to claim. Kept out of Box 11, which the return works into a credit at Box 12 through a fixed 3/23 fraction of a GST-inclusive figure: an amount that carried no GST would manufacture a credit out of nothing if it were included, and the form gives no Box 11 equivalent of Box 6 to net it back out.', 'Z', null, 140, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-S-EXEMPT-FIN', 'Financial services, exempt', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 14(1)(a) — the supply of financial services is an exempt supply. Inland Revenue, Exempt supplies (ird.govt.nz/gst/charging-gst/exempt-supplies): paying or collecting interest, arranging a mortgage or loan, dealing in securities and in currency, and financial options are financial services. An exempt supply is not a taxable supply at all and IR375 says it is ''not included in your GST return''; it carries no GST and gives no credit for what went into it. No exemption reason code: VATEX names articles of a Directive that does not bind a New Zealand supplier, and territories carries no row that would let one be borrowed.', 'E', null, 80, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-exempt-supplies', null, null, null, null),
  ('NZ', 'NZ-S-EXEMPT-RES', 'Residential rent, exempt', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 14(1)(c) — the supply of accommodation in a dwelling under a residential tenancy is an exempt supply. Inland Revenue, Exempt supplies: ''GST cannot be charged on the rent for a residential dwelling. A landlord cannot claim any GST on dwelling expenses.'' Not included in the GST return at all.', 'E', null, 90, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gst-exempt-supplies', null, null, null, null),
  ('NZ', 'NZ-S-GST', 'Sale, GST 15 %', '{}'::jsonb, 'A taxable supply made in New Zealand, standard-rated', 'percent', 15, 'sale', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 8(1) — GST is charged on the supply of goods and services in New Zealand by a registered person in the course or furtherance of a taxable activity, currently at 15 % of the value of the supply. Inland Revenue, GST guide (IR375), confirms the current rate. GST101A''s Box 5 prints one GST-inclusive figure, so the GST-exclusive value of the supply is grossed to 115 % on the posting itself and written into Box 5; the GST itself is the real ledger amount, posted straight to Box 8, which is the box the return''s own ''3/23 of Box 7'' instruction would otherwise reconstruct — see tax_report.json. A community pack: the exact dates the rate moved from 10 % (1 October 1986) to 12.5 % (1 July 1989) to 15 % (1 October 2010) were not confirmed against the operative text of s. 8(1) itself in this session — legislation.govt.nz refused every automated read attempted, scripted and browser-driven alike — only against Inland Revenue''s current-rate statement and general knowledge of the Act''s amendment history; a reviewer should read s. 8(1) and its amendment schedules before relying on the two earlier dates.', 'S', null, 10, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-S-GST-INC', 'Retail sale, GST 15 %, the price includes the GST', '{}'::jsonb, 'For a price set with the GST already in it, as a shelf price is', 'percent', 15, 'sale', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 78(1) — a price is presumed GST-inclusive unless the parties agree otherwise, which a retail shelf price ordinarily is. Inland Revenue, GST guide (IR375): to find the GST component of a GST-inclusive price, multiply by 3 and divide by 23. price_include records that the unit price of a line is the GST-inclusive price; the engine takes the fraction out to find the value of the supply, which this posting then grosses straight back to 115 % for Box 5 — recovering the GST-inclusive figure the till rang up — exactly as NZ-S-GST does, with the GST itself posted to Box 8.', 'S', null, 20, 'gst', true, '{}'::tax_condition[], null, true, false, null, 'ir375', null, null, null, null),
  ('NZ', 'NZ-S-GST-PAY', 'Sale, GST 15 %, accounted for on the payments basis', '{}'::jsonb, null, 'percent', 15, 'sale', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, ss. 19 and 20 — a registered person accounts for GST on one of three bases: payments, invoice or hybrid. Inland Revenue, GST guide (IR375): the payments basis is open to a person whose total taxable supplies are $2,000,000 or less in the last 12 months, or are likely to be $2,000,000 or less in the next 12 months; under it, a sale is returned only to the extent it has been paid for. The choice is the registered person''s own and covers the whole of their taxable activity; the pack carries it as a code beside the invoice-basis one, as the payments-basis condition below the threshold cannot be read off a single document. The tax posting names Box 8, which is where the settled amount is declared once collection moves it off the transition account.', 'S', null, 30, 'gst', true, array['seller_threshold']::tax_condition[], null, false, true, '2105', 'ir375', null, null, null, null),
  ('NZ', 'NZ-S-NOGST', 'Sale not in the course of a taxable activity, or made by an unregistered supplier', '{}'::jsonb, null, 'percent', 0, 'sale', 'not_subject', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 8(1) — GST is charged only on a supply made by a registered person in the course or furtherance of a taxable activity. Inland Revenue, GST guide (IR375): sales by an unregistered person, and sales of private property outside any taxable activity, are not charged GST and are not shown in the GST return, so the base names no box.', 'O', null, 100, 'gst', true, '{}'::tax_condition[], null, false, false, null, 'ir375', null, null, null, null),
  ('NZ', 'NZ-S-ZERO-EXPORT', 'Export of goods, zero-rated', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 11(1)(a) — the supply of goods is zero-rated where the supplier has entered them for export, or supplies them by way of a lease or bailment and the goods are exported, within the time limits and conditions of the section. Inland Revenue, GST guide (IR375) and Zero-rated supplies (ird.govt.nz/gst/charging-gst/zero-rated-supplies): exported goods are the standard example of a zero-rated supply, reported at Box 5 and Box 6 of the GST101A, both at the value''s own figure, since a zero-rated supply carries no GST to gross up. A zero-rated supply is a taxable supply at a nil rate and not an exempt one: the credit on what went into it stays claimable.', 'G', null, 40, 'gst', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-S-ZERO-GOINGCONCERN', 'Sale of a taxable activity as a going concern, zero-rated', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 11(1)(m) — the supply of a taxable activity, or of a part of a taxable activity capable of separate operation, is zero-rated where it is supplied to a registered person as a going concern, both parties agree in writing that it is so supplied, and the other conditions of the paragraph are met. Inland Revenue, GST guide (IR375), sets out the conditions in practice. Whether a given sale meets them is a fact about the transaction the ledger does not hold, which is what `conditions` records. Reported at Box 5 and Box 6.', 'Z', null, 60, 'gst', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ir375', null, null, null, null),
  ('NZ', 'NZ-S-ZERO-LAND', 'Sale of land between GST-registered persons, zero-rated', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2011-04-01', null, 'Goods and Services Tax Act 1985, s. 11(1)(mb) — the compulsory zero-rating of land rules, in force from 1 April 2011, zero-rate the supply of land where the recipient is, or is required to be, registered and acquires the land with the intention of using it for making taxable supplies, and the supply is not intended to be used as a principal place of residence of the recipient or an associate. A community pack: the full cross-reference to s. 5(24), s. 11(1)(mc), s. 60B and s. 78F, which together make up the compulsory zero-rating of land regime, was not independently confirmed against the operative text of the Act in this session; a reviewer should read s. 11(1)(mb) and its neighbouring provisions before relying on the paragraph letter. Reported at Box 5 and Box 6.', 'Z', null, 70, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null),
  ('NZ', 'NZ-S-ZERO-SERVICES', 'Supply of services to a non-resident outside New Zealand, zero-rated', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 11A(1) — zero-rating of services, which reaches a supply of services to a person who is not resident in New Zealand and is outside New Zealand when the services are performed, subject to the exclusions of the section — services supplied directly in connection with land or movable property situated in New Zealand among them. Reported at Box 5 and Box 6, the way the exported-goods code is; the EN 16931 category is G, the one PINT A-NZ gives an export.', 'G', null, 50, 'gst', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gst-act', null, null, null, null)
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
    ('NZ-P-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-EXEMPT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-GST', 'invoice', 'base', 100, null, '11', array['11']::text[], 115, 'NZ-GST101A', 10),
    ('NZ-P-GST', 'invoice', 'tax', 100, '1150', '12', array['12']::text[], 100, 'NZ-GST101A', 20),
    ('NZ-P-GST', 'credit_note', 'base', 100, null, '11', array['11']::text[], -115, 'NZ-GST101A', 10),
    ('NZ-P-GST', 'credit_note', 'tax', 100, '1150', '12', array['12']::text[], -100, 'NZ-GST101A', 20),
    ('NZ-P-GST-ITS', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-GST-ITS', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('NZ-P-GST-ITS', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-GST-ITS', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('NZ-P-GST-PAY', 'invoice', 'base', 100, null, '11', array['11']::text[], 115, 'NZ-GST101A', 10),
    ('NZ-P-GST-PAY', 'invoice', 'tax', 100, '1150', '12', array['12']::text[], 100, 'NZ-GST101A', 20),
    ('NZ-P-GST-PAY', 'credit_note', 'base', 100, null, '11', array['11']::text[], -115, 'NZ-GST101A', 10),
    ('NZ-P-GST-PAY', 'credit_note', 'tax', 100, '1150', '12', array['12']::text[], -100, 'NZ-GST101A', 20),
    ('NZ-P-NOGST', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-NOGST', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-RC-IMPORTED', 'invoice', 'base', 100, null, '5', array['5']::text[], 115, 'NZ-GST101A', 10),
    ('NZ-P-RC-IMPORTED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('NZ-P-RC-IMPORTED', 'invoice', 'tax', -100, '2100', '8', array['8']::text[], 100, 'NZ-GST101A', 30),
    ('NZ-P-RC-IMPORTED', 'credit_note', 'base', 100, null, '5', array['5']::text[], -115, 'NZ-GST101A', 10),
    ('NZ-P-RC-IMPORTED', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('NZ-P-RC-IMPORTED', 'credit_note', 'tax', -100, '2100', '8', array['8']::text[], -100, 'NZ-GST101A', 30),
    ('NZ-P-ZERO', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-P-ZERO', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-EXEMPT-FIN', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-EXEMPT-FIN', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-EXEMPT-RES', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-EXEMPT-RES', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-GST', 'invoice', 'base', 100, null, '5', array['5']::text[], 115, 'NZ-GST101A', 10),
    ('NZ-S-GST', 'invoice', 'tax', 100, '2100', '8', array['8']::text[], 100, 'NZ-GST101A', 20),
    ('NZ-S-GST', 'credit_note', 'base', 100, null, '5', array['5']::text[], -115, 'NZ-GST101A', 10),
    ('NZ-S-GST', 'credit_note', 'tax', 100, '2100', '8', array['8']::text[], -100, 'NZ-GST101A', 20),
    ('NZ-S-GST-INC', 'invoice', 'base', 100, null, '5', array['5']::text[], 115, 'NZ-GST101A', 10),
    ('NZ-S-GST-INC', 'invoice', 'tax', 100, '2100', '8', array['8']::text[], 100, 'NZ-GST101A', 20),
    ('NZ-S-GST-INC', 'credit_note', 'base', 100, null, '5', array['5']::text[], -115, 'NZ-GST101A', 10),
    ('NZ-S-GST-INC', 'credit_note', 'tax', 100, '2100', '8', array['8']::text[], -100, 'NZ-GST101A', 20),
    ('NZ-S-GST-PAY', 'invoice', 'base', 100, null, '5', array['5']::text[], 115, 'NZ-GST101A', 10),
    ('NZ-S-GST-PAY', 'invoice', 'tax', 100, '2100', '8', array['8']::text[], 100, 'NZ-GST101A', 20),
    ('NZ-S-GST-PAY', 'credit_note', 'base', 100, null, '5', array['5']::text[], -115, 'NZ-GST101A', 10),
    ('NZ-S-GST-PAY', 'credit_note', 'tax', 100, '2100', '8', array['8']::text[], -100, 'NZ-GST101A', 20),
    ('NZ-S-NOGST', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-NOGST', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NZ-S-ZERO-EXPORT', 'invoice', 'base', 100, null, '5', array['5', '6']::text[], 100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-EXPORT', 'credit_note', 'base', 100, null, '5', array['5', '6']::text[], -100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-GOINGCONCERN', 'invoice', 'base', 100, null, '5', array['5', '6']::text[], 100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-GOINGCONCERN', 'credit_note', 'base', 100, null, '5', array['5', '6']::text[], -100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-LAND', 'invoice', 'base', 100, null, '5', array['5', '6']::text[], 100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-LAND', 'credit_note', 'base', 100, null, '5', array['5', '6']::text[], -100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-SERVICES', 'invoice', 'base', 100, null, '5', array['5', '6']::text[], 100, 'NZ-GST101A', 10),
    ('NZ-S-ZERO-SERVICES', 'credit_note', 'base', 100, null, '5', array['5', '6']::text[], -100, 'NZ-GST101A', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'NZ' and t.code = v.tax_code
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
  ('NZ', 'NZ-GST101A', 'Goods and services tax return', array['month', 'bimonth', 'half_year']::declaration_period[], 'bimonth'::declaration_period, date '2010-10-01', null, 'Goods and Services Tax Act 1985, s. 15 — the taxable period of a registered person is two months ending on the dates the Commissioner sets, unless s. 15A lets the person elect a one-month period, or s. 15B lets a person whose taxable supplies do not exceed, and are not likely to exceed, $500,000 in a twelve-month period elect a six-month period; s. 15C requires a monthly period once taxable supplies exceed $24 million in a twelve-month period (IR375, GST guide: ''You must file monthly returns if your sales are over $24 million in any 12-month period''; ''Anyone with sales under $500,000 in any 12-month period'' may choose six-monthly). This pack declares the two-monthly cadence, `bimonth`, as the one the Act gives everybody who elects nothing else, and the monthly and six-monthly cadences it authorises above and below that. This is form GST101A, filed by a registered person not liable for provisional tax; a registered person who is liable for provisional tax files a form of the GST103 series instead, which folds in the provisional tax instalment and is not carried by this pack.', true,'day_of_month_after_period'::filing_deadline_rule, 28, null, 'IR375, GST guide, ''When to file your returns'' — ''The due date is usually the 28th of the month following the end of your taxable period, except for return periods ending: 30 November – the due date is 15 January of the following year; 31 March – the due date is 7 May of the same year. If the due date for your GST return falls on a weekend or public holiday, it will be due the next working day.'' A form carries one deadline rule, so the pack declares the 28th, which holds for ten of the six two-monthly periods and every monthly and six-monthly period; the two calendar exceptions and the weekend roll-forward are recorded in docs/international.md and are not expressible here.', 'ir375', null)
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
  ('NZ', 'NZ-GST101A', '5', 'base', 'Total sales and income', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 5 — ''Total sales and income for the period (including GST and any zero-rated supplies)''. IR375, GST guide, page 12: ''Add up all sales and income for your taxable activity including any zero-rated supplies. This includes the GST amount of the sales and income.'' Unlike the Australian Business Activity Statement, which lets a filer choose to report GST-exclusive, GST101A prints one GST-inclusive figure and offers no choice: a standard-rated sale therefore posts its GST-exclusive value here grossed to 115 % — the value plus the 15 % GST — and a zero-rated sale posts its value at 100 %, since it carries no GST to add. An exempt supply and a supply not connected with New Zealand are not included at all, because they are not taxable supplies and IR375 says ''GST is not charged on exempt supplies, and they''re not included in your GST return.''', 'ir375'),
  ('NZ', 'NZ-GST101A', '6', 'base', 'Zero-rated supplies included in Box 5', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 6 — ''Zero-rated supplies included in Box 5''. IR375, GST guide, page 12: ''Separate out the amount of zero-rated supplies. (You''re most likely to have zero-rated supplies if you''re an exporter.)'' A zero-rated supply carries no GST, so its GST-exclusive and GST-inclusive values are the same figure, and every zero-rated sale code posts its base here as well as to Box 5, at 100 % in both places.', 'ir375'),
  ('NZ', 'NZ-GST101A', '7', 'total', 'Sales and income subject to GST', '{}'::jsonb, 30, null, array['5']::text[], array['6']::text[], null, null, false, false, null, 'Form GST101A, Box 7 — ''Subtract Box 6 from Box 5 and enter the difference here''.', 'ir375'),
  ('NZ', 'NZ-GST101A', '8', 'tax', 'GST collected on taxable sales and income', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 8 — ''Multiply the amount in Box 7 by three (3) and then divide by twenty-three (23)'', which recovers the GST inside a GST-inclusive figure taxed wholly at 15 %. This pack''s ledger already holds the GST of every sale as its own posting, so Box 8 is that amount summed directly rather than reconstructed by the form''s own worksheet arithmetic; the two agree to the cent whenever every rate charged is 0 % or 15 %, which is every rate this pack carries, because 3/23 of 115 % of a value is exactly 15 % of it. `golden/expectations.json` states the substitution explicitly.', 'ir375'),
  ('NZ', 'NZ-GST101A', '9', 'tax', 'Sales adjustments from the calculation sheet', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 9 — ''Adjustments from your calculation sheet'' (private use, a change in use, a bad debt recovered, a wash-up under s. 21FB). Declared and left empty: none of it is a posting of a document or a payment this pack''s taxes carry.', 'ir375'),
  ('NZ', 'NZ-GST101A', '10', 'total', 'Total GST collected on sales and income', '{}'::jsonb, 60, null, array['8', '9']::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 10 — ''Add Box 8 and Box 9. This is your total GST collected on sales and income.''', 'ir375'),
  ('NZ', 'NZ-GST101A', '11', 'base', 'Total purchases and expenses', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 11 — ''Total purchases and expenses (including GST) – excluding any imported goods. Keep the records required to support your claims.'' A creditable standard-rated purchase posts its GST-exclusive value here grossed to 115 %, the same way a sale posts to Box 5; a purchase that carries no deduction at all — zero-rated, exempt, no GST in the price, or not creditable under s. 20(3) and s. 21 — is kept out of this box entirely, because Box 12 is the credit the return actually claims, and an amount with no GST or no entitlement to deduct it has no place feeding it. A purchase of goods imported from outside New Zealand and cleared through Customs is not carried by this pack — see README.md.', 'ir375'),
  ('NZ', 'NZ-GST101A', '12', 'tax', 'GST credit on purchases and expenses', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 12 — ''Multiply the amount in Box 11 by three (3) and then divide by twenty-three (23)'', held to the ledger''s own figure for the reason given at Box 8.', 'ir375'),
  ('NZ', 'NZ-GST101A', '13', 'tax', 'Purchase adjustments from the calculation sheet', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 13 — ''Credit adjustments from your calculation sheet''. Declared and left empty, for the reason given at Box 9.', 'ir375'),
  ('NZ', 'NZ-GST101A', '14', 'total', 'Total GST credit for purchases and expenses', '{}'::jsonb, 100, null, array['12', '13']::text[], '{}'::text[], null, null, false, false, null, 'Form GST101A, Box 14 — ''Add Box 12 and Box 13. This is your total GST credit for purchases and expenses.''', 'ir375'),
  ('NZ', 'NZ-GST101A', '15', 'total', 'GST to pay or GST refund', '{}'::jsonb, 110, null, array['10']::text[], array['14']::text[], null, null, false, false, null, 'Form GST101A, Box 15 — ''Print the difference between Box 10 and Box 14 here.'' The form prints a positive figure and a tick box: ''If Box 14 is larger than Box 10 the difference is your GST refund. If Box 10 is larger than Box 14 the difference is GST to pay.'' The pack writes the signed subtraction, Box 10 minus Box 14, so a refund reads as a negative Box 15.', 'ir375')
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
  ('NZ-XRB-PL', 'NZ', 'default', 'Statement of profit or loss — NZ IFRS, Tier 2 Reduced Disclosure Regime, expenses by nature', 'income_statement', 'NZ-IFRS-RDR', date '1970-01-01', null, 'NZ IAS 1 (RDR), paragraphs 82 and 99 to 105. Paragraph 82 lists the minimum line items — revenue, finance costs, the share of associates and joint ventures, tax expense, discontinued operations and profit or loss — and paragraph 99 requires an analysis of expenses by nature or by function, whichever is reliable and more relevant; this statement analyses them by nature, which a small company''s ledger holds without any allocation. The share of the profit or loss of equity-accounted investments and discontinued operations are not lines here, because the chart carries no account for them.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NZ', 'default', 'Statement of financial position — NZ IFRS, Tier 2 Reduced Disclosure Regime', 'balance_sheet', 'NZ-IFRS-RDR', date '1970-01-01', null, 'NZ IAS 1 Presentation of Financial Statements (with RDR disclosure concessions), paragraph 54, lists the line items a statement of financial position presents as a minimum, and paragraph 57 prescribes neither their order nor their format, so the lines below are those items in the order New Zealand practice prints them, classified current and non-current under paragraphs 60 to 76. Companies Act 1993, s. 201, and Financial Reporting Act 2013, s. 8 and s. 19 — a reporting entity that has to prepare financial statements prepares them in accordance with generally accepted accounting practice, which XRB A1 assigns to Tier 2 (NZ IFRS with reduced disclosure) for a for-profit entity that has no public accountability and elects the reduced disclosure regime. Biological assets, non-controlling interests and assets held for sale are not lines here, because the chart carries no account for them.', 'xrb-framework')
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
  ('NZ-XRB-PL', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 82(a).', 'xrb-framework'),
  ('NZ-XRB-PL', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 85 — an additional line item: income that is not revenue from contracts with customers: interest, rent, grants, foreign exchange gains and gains on disposal.', 'xrb-framework'),
  ('NZ-XRB-PL', '3', null, 'Raw materials, consumables and goods for resale used', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 102 — expenses analysed by their nature: purchases of materials and goods, freight inwards, import charges, the change in inventories and subcontractors.', 'xrb-framework'),
  ('NZ-XRB-PL', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 102 — employee benefits costs, KiwiSaver employer contributions and ACC levies among them.', 'xrb-framework'),
  ('NZ-XRB-PL', '5', null, 'Depreciation and amortisation expense', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 102 — depreciation.', 'xrb-framework'),
  ('NZ-XRB-PL', '6', null, 'Other expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 102 — the other expenses by nature, foreign exchange losses and losses on disposal among them.', 'xrb-framework'),
  ('NZ-XRB-PL', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 82(b).', 'xrb-framework'),
  ('NZ-XRB-PL', '8', null, 'Profit before income tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('NZ-XRB-PL', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 82(d) — tax expense.', 'xrb-framework'),
  ('NZ-XRB-PL', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'NZ IAS 1 (RDR), paragraph 82(f) — profit or loss. The pack carries no item of other comprehensive income, so this is also the total comprehensive income of paragraph 82(i), which the paragraph allows to be called profit or loss.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraphs 60 to 65 — an entity presents current and non-current assets as separate classifications, an asset being current when it is expected to be realised within the operating cycle or twelve months, or is cash.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(i).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(h). GST paid on purchases and the GST refund due from Inland Revenue are receivables from the Commissioner and not current tax, which paragraph 54(n) keeps for income tax; the suspense account reports here while it is in debit.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(g).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(d), the part realised within twelve months.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(n) — assets for current tax, which in New Zealand is provisional and terminal income tax, not GST: provisional tax paid, resident withholding tax deducted at source and imputation credits carried forward, and income tax refundable.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CA.6', 'CA', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 55 — an additional line item, relevant to an understanding of the entity''s financial position: prepayments and deposits paid, which are neither receivables nor financial assets.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraphs 60 and 66 — every asset that is not current is non-current.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(a). Right-of-use assets are presented within this line, beside the assets of the same nature, which NZ IFRS 16 allows where they are disclosed in the notes; each cost account has its accumulated depreciation on the next code so that one range reaches the carrying amount.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.2', 'NCA', 'Investment property', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(b).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.3', 'NCA', 'Intangible assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(c).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.4', 'NCA', 'Investments in associates', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(e).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.5', 'NCA', 'Investments in joint ventures', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(e).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.6', 'NCA', 'Financial assets', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(d), the part not realised within twelve months.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCA.7', 'NCA', 'Deferred tax assets', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(o) — deferred tax assets are always classified as non-current (NZ IAS 12).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 160, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('NZ-XRB-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 170, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraphs 60, 69 and 70 — an entity presents current and non-current liabilities as separate classifications.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(k). GST collected, the GST payable to Inland Revenue, PAYE and resident withholding tax withheld are owed to the Commissioner and are not income tax, so they report here and not under paragraph 54(n); the suspense account reports here while it is in credit.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CL.2', 'CL', 'Financial liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(m), the part due within twelve months, the credit card among them.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(n) — liabilities for current tax: income tax payable and provisional tax payable.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'CL.4', 'CL', 'Provisions', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(l), the part expected to be settled within twelve months, employee leave among it.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 220, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 60 — every liability that is not current is non-current.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCL.1', 'NCL', 'Financial liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(m), the part not due within twelve months.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCL.2', 'NCL', 'Deferred tax liabilities', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(o).', 'xrb-framework'),
  ('NZ-XRB-SFP', 'NCL.3', 'NCL', 'Provisions', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(l), the part not expected to be settled within twelve months.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 260, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('NZ-XRB-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 270, 1, true, array['TA']::text[], array['TL']::text[], null, 'Not a line NZ IAS 1 lists: the subtotal a New Zealand statement of financial position prints above equity, which paragraph 55 allows. It equals total equity once the year is closed, and exceeds it by the profit of the year until then.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 280, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 54(r) — equity attributable to the owners of the parent; paragraph 79 asks for its classes, which are the three lines below.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'EQ.1', 'EQ', 'Issued capital', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 79(a) — classes of equity, such as paid-in capital.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'EQ.2', 'EQ', 'Reserves', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 79(b) — reserves.', 'xrb-framework'),
  ('NZ-XRB-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'NZ IAS 1 (RDR), paragraph 79(b) — retained earnings, after the dividends paid that are booked beside them.', 'xrb-framework')
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
    ('NZ-XRB-PL', '1', 10, 'code_range', '4000', '4090', null, 'any'),
    ('NZ-XRB-PL', '2', 10, 'code_range', '4500', '4750', null, 'any'),
    ('NZ-XRB-PL', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('NZ-XRB-PL', '4', 10, 'code_range', '6000', '6070', null, 'any'),
    ('NZ-XRB-PL', '5', 10, 'code_range', '6200', '6230', null, 'any'),
    ('NZ-XRB-PL', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('NZ-XRB-PL', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('NZ-XRB-PL', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('NZ-XRB-SFP', 'CA.1', 10, 'code_range', '1000', '1060', null, 'any'),
    ('NZ-XRB-SFP', 'CA.2', 10, 'code_range', '1100', '1155', null, 'any'),
    ('NZ-XRB-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('NZ-XRB-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('NZ-XRB-SFP', 'CA.4', 10, 'code_range', '1300', '1320', null, 'any'),
    ('NZ-XRB-SFP', 'CA.5', 10, 'code_range', '1160', '1170', null, 'any'),
    ('NZ-XRB-SFP', 'CA.5', 20, 'account_code', '1350', null, null, 'any'),
    ('NZ-XRB-SFP', 'CA.6', 10, 'code_range', '1400', '1420', null, 'any'),
    ('NZ-XRB-SFP', 'NCA.1', 10, 'code_range', '1600', '1680', null, 'any'),
    ('NZ-XRB-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('NZ-XRB-SFP', 'NCA.3', 10, 'code_range', '1750', '1771', null, 'any'),
    ('NZ-XRB-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('NZ-XRB-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('NZ-XRB-SFP', 'NCA.6', 10, 'code_range', '1820', '1840', null, 'any'),
    ('NZ-XRB-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('NZ-XRB-SFP', 'CL.1', 10, 'code_range', '2000', '2130', null, 'any'),
    ('NZ-XRB-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('NZ-XRB-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('NZ-XRB-SFP', 'CL.3', 10, 'code_range', '2300', '2310', null, 'any'),
    ('NZ-XRB-SFP', 'CL.4', 10, 'code_range', '2350', '2370', null, 'any'),
    ('NZ-XRB-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('NZ-XRB-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('NZ-XRB-SFP', 'NCL.3', 10, 'code_range', '2550', '2560', null, 'any'),
    ('NZ-XRB-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('NZ-XRB-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('NZ-XRB-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('NZ', 'New Zealand', '{}'::jsonb, array['en']::text[], 'NZD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'bimonth'::declaration_period)
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
  numbering_legal_reference     = 'Goods and Services Tax Act 1985, ss. 19E to 19N — the taxable supply information a supplier and a buyer must provide and keep, in force from 1 April 2023 (Taxation (Annual Rates for 2022–23, Platform Economy, and Remedial Matters) Act 2022). Below $200 the seller''s name or trade name, the date, a description and the consideration are enough; above $200 the GST number is added, and above $1,000 the GST-registered buyer''s name and one further identifying particular. None of the three tiers asks for a document number, so numbering is `free`; the pattern in number_format is one a business may choose, not one the law asks for.',
  numbering_source_key          = 'gst-taxable-supply-information',
  payment_terms_legal_reference = 'No New Zealand statute sets a payment term between businesses in the absence of an agreement, and none sets statutory interest on a late business-to-business payment, so legal_payment_days and late_payment_reference are empty.',
  payment_terms_source_key      = 'gst-act',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Goods and Services Tax Act 1985, s. 9(1) — a supply of goods and services is deemed to take place at the earlier of the time an invoice is issued and the time any payment is received; s. 20(3) applies the same time to the deduction of input tax on the invoice basis. The rule is the earlier of the invoice and the first payment, which `invoice_if_issued` states as the supply displaced by an invoice where one is issued; a taxpayer who files on the payments basis, which s. 20(3)(a)(ii) and s. 20(4) allow below a turnover threshold, attributes GST to the period of actual payment instead, which the taxes that declare cash_basis carry.',
  tax_point_source_key          = 'gst-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'pint-aunz',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No New Zealand statute obliges a business to issue or to accept an electronic invoice from another business, so the obligation is `none` and mandatory_from is empty. New Zealand exchanges electronic invoices on the Peppol network under the PINT A-NZ Billing specification it shares with Australia (customization urn:peppol:pint:billing-1@aunz-1); the New Zealand Peppol Authority function sits with MBIE. Government agencies have been encouraged onto eInvoicing since 2019 by policy rather than by statute, and central government suppliers are increasingly asked to send them, which binds no supplier by itself. A New Zealand party is addressed on the network by its NZBN and taxed on its IRD/GST number; this pack leaves party_scheme and vat_scheme null because the ISO 6523 ICD code the New Zealand Business Number carries on the Peppol network could not be confirmed against an open official register in this session — see the note in README.md, and treat the value as unverified until a reviewer supplies it.',
  einvoice_source_key           = 'pint-aunz',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'april'
 where country = 'NZ';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('NZ', 'export', 'export', 'Zero-rated export under section 11 or section 11A of the Goods and Services Tax Act 1985.', '{}'::jsonb, 10, date '1970-01-01', null, 'Goods and Services Tax Act 1985, ss. 19E to 19N — the taxable supply information for a supply above $200 states the extent to which each supply is a taxable supply; where GST is charged at 0 % the sentence states why none is included in the price.'),
  ('NZ', 'exempt', 'exempt', 'Exempt supply — no GST charged (section 14, Goods and Services Tax Act 1985).', '{}'::jsonb, 20, date '1970-01-01', null, 'Goods and Services Tax Act 1985, s. 14 — an exempt supply is not a taxable supply and is not included in a GST return at all; the sentence records on the document why no GST was charged, for a reader who was not expecting the exemption.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
