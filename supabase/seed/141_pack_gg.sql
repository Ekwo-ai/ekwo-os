-- Ekwo OS — Guernsey: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/gg at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build gg`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Companies (Guernsey) Law, 2008 (Guernsey Legal Resources (Law Officers of the Crown))
--     https://guernseylegalresources.gg/laws/guernsey-bailiwick/c/companies-and-commercial/companies-guernsey-law-2008/
--   Tax information for companies (States of Guernsey — Revenue Service)
--     https://gov.gg/RevenueService/Companies
--   Understanding income tax (States of Guernsey — Revenue Service)
--     https://www.gov.gg/tax
--   Revenue Service (States of Guernsey — Revenue Service)
--     https://www.gov.gg/revenueservice
--   Guernsey — Corporate — Other taxes (worldwide tax summaries) (PwC)
--     https://taxsummaries.pwc.com/guernsey/corporate/other-taxes
--   Pillar Two in Guernsey (Legal 500)
--     https://www.legal500.com/intelligence/guernsey/tax/pillar-two-in-guernsey
--   GST is agreed at 3% but soon rising to 5% (Guernsey Press)
--     https://guernseypress.com/news/2026/10/02/gst-is-agreed-at-3percent-but-soon-rising-to-5percent
--   Guernsey Company Law Series: Financial Records, Accounts, Annual Validations and Audit Requirements (Walkers)
--     https://www.walkersglobal.com/en/Insights/2024/10/Guernsey-Company-Law-Series--Financial-Records--Accounts-Annual-Validations-and-Audit-Requirements
--   FRS 102 The Financial Reporting Standard applicable in the UK and Republic of Ireland (Section 1A Small Entities) (Financial Reporting Council)
--     https://www.frc.org.uk/library/standards-codes-policy/accounting-and-reporting/uk-accounting-standards/frs-102/
--   my.gov.gg — online tax services (company income tax return) (States of Guernsey — Revenue Service)
--     https://my.gov.gg
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GG', 'Guernsey', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, 'a9251675343c7ade2be1e4986c8a57ee9fc955b072008eaba497c4e33ba5c079', '[{"key":"gg-companies-law","title":"Companies (Guernsey) Law, 2008","publisher":"Guernsey Legal Resources (Law Officers of the Crown)","url":"https://guernseylegalresources.gg/laws/guernsey-bailiwick/c/companies-and-commercial/companies-guernsey-law-2008/","consulted_on":"2026-10-10","kind":"law"},{"key":"gg-rs-companies","title":"Tax information for companies","publisher":"States of Guernsey — Revenue Service","url":"https://gov.gg/RevenueService/Companies","consulted_on":"2026-10-10","kind":"guidance"},{"key":"gg-tax","title":"Understanding income tax","publisher":"States of Guernsey — Revenue Service","url":"https://www.gov.gg/tax","consulted_on":"2026-10-10","kind":"guidance"},{"key":"gg-revenue-service","title":"Revenue Service","publisher":"States of Guernsey — Revenue Service","url":"https://www.gov.gg/revenueservice","consulted_on":"2026-10-10","kind":"guidance"},{"key":"gg-pwc-other-taxes","title":"Guernsey — Corporate — Other taxes (worldwide tax summaries)","publisher":"PwC","url":"https://taxsummaries.pwc.com/guernsey/corporate/other-taxes","consulted_on":"2026-10-10","kind":"guidance"},{"key":"gg-pillar-two","title":"Pillar Two in Guernsey","publisher":"Legal 500","url":"https://www.legal500.com/intelligence/guernsey/tax/pillar-two-in-guernsey","consulted_on":"2026-10-10","kind":"guidance"},{"key":"gg-gst-vote","title":"GST is agreed at 3% but soon rising to 5%","publisher":"Guernsey Press","url":"https://guernseypress.com/news/2026/10/02/gst-is-agreed-at-3percent-but-soon-rising-to-5percent","consulted_on":"2026-10-10","kind":"guidance"},{"key":"gg-walkers-accounts","title":"Guernsey Company Law Series: Financial Records, Accounts, Annual Validations and Audit Requirements","publisher":"Walkers","url":"https://www.walkersglobal.com/en/Insights/2024/10/Guernsey-Company-Law-Series--Financial-Records--Accounts-Annual-Validations-and-Audit-Requirements","consulted_on":"2026-10-10","kind":"guidance"},{"key":"frs-102","title":"FRS 102 The Financial Reporting Standard applicable in the UK and Republic of Ireland (Section 1A Small Entities)","publisher":"Financial Reporting Council","url":"https://www.frc.org.uk/library/standards-codes-policy/accounting-and-reporting/uk-accounting-standards/frs-102/","consulted_on":"2026-10-10","kind":"standard"},{"key":"gg-my-gov","title":"my.gov.gg — online tax services (company income tax return)","publisher":"States of Guernsey — Revenue Service","url":"https://my.gov.gg","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('GG', 'default', 'Guernsey reference chart of accounts', '{}'::jsonb, true, 'companies', array['GG-FRS102-1A-BS', 'GG-FRS102-1A-IS']::text[], null, 'There is no legal chart of accounts in Guernsey. The Companies (Guernsey) Law, 2008 requires every company to keep accounting records sufficient to show and explain its transactions, to preserve them for at least six years from the date they are made, and to have its directors prepare, for each financial year, accounts that include a balance sheet and a profit and loss account, give a true and fair view, and are prepared in accordance with generally accepted accounting principles that the accounts state (Walkers, consulted 2026-10-10; the text of the Law itself could not be opened, see the README). The Law prescribes no chart and no format. This chart is original and follows British bookkeeping practice, as the pack for the United Kingdom does, because the generally accepted accounting principles most Guernsey companies declare are UK GAAP (FRS 102), with IFRS or US GAAP the other options: four digits, blocked so that each range reaches one line of the balance sheet and the profit and loss account of FRS 102 Section 1A (small entities) in the layout statements.json carries. It has no value added tax, goods and services tax or sales tax account of any kind, because Guernsey levies none today; the States of Deliberation voted on 2 October 2026 for a GST from 2029, which is enacted nowhere yet — see ''From Guernsey'' in docs/international.md.', 'gg-companies-law')
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
  ('GG', 'default', '0000', 'Called up share capital not paid', '{}'::jsonb, 'asset_current', false, null, 10),
  ('GG', 'default', '0010', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('GG', 'default', '0011', 'Goodwill — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('GG', 'default', '0020', 'Development costs', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('GG', 'default', '0021', 'Development costs — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('GG', 'default', '0030', 'Patents, trade marks and licences', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('GG', 'default', '0031', 'Patents, trade marks and licences — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('GG', 'default', '0040', 'Other intangible assets', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('GG', 'default', '0041', 'Other intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('GG', 'default', '0100', 'Freehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('GG', 'default', '0101', 'Freehold land and buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 110),
  ('GG', 'default', '0110', 'Leasehold property and improvements', '{}'::jsonb, 'asset_fixed', false, null, 120),
  ('GG', 'default', '0111', 'Leasehold property and improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 130),
  ('GG', 'default', '0120', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 140),
  ('GG', 'default', '0121', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 150),
  ('GG', 'default', '0130', 'Fixtures and fittings', '{}'::jsonb, 'asset_fixed', false, null, 160),
  ('GG', 'default', '0131', 'Fixtures and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 170),
  ('GG', 'default', '0140', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 180),
  ('GG', 'default', '0141', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 190),
  ('GG', 'default', '0150', 'Computer equipment', '{}'::jsonb, 'asset_fixed', false, null, 200),
  ('GG', 'default', '0151', 'Computer equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 210),
  ('GG', 'default', '0160', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('GG', 'default', '0161', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('GG', 'default', '0200', 'Shares in group undertakings and participating interests', '{}'::jsonb, 'asset_non_current', false, null, 240),
  ('GG', 'default', '0210', 'Loans to group undertakings and undertakings in which the company has a participating interest', '{}'::jsonb, 'asset_non_current', false, null, 250),
  ('GG', 'default', '0220', 'Other investments other than loans', '{}'::jsonb, 'asset_non_current', false, null, 260),
  ('GG', 'default', '0230', 'Other investments', '{}'::jsonb, 'asset_non_current', false, null, 270),
  ('GG', 'default', '1000', 'Stock — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 280),
  ('GG', 'default', '1010', 'Stock — work in progress', '{}'::jsonb, 'asset_current', false, null, 290),
  ('GG', 'default', '1020', 'Stock — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 300),
  ('GG', 'default', '1030', 'Payments on account — stocks', '{}'::jsonb, 'asset_prepayments', false, null, 310),
  ('GG', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 320),
  ('GG', 'default', '1105', 'Provision for doubtful debts', '{}'::jsonb, 'asset_current', false, null, 330),
  ('GG', 'default', '1110', 'Amounts owed by group undertakings and undertakings in which the company has a participating interest', '{}'::jsonb, 'asset_current', false, null, 340),
  ('GG', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 350),
  ('GG', 'default', '1130', 'Directors'' loan account — debit', '{}'::jsonb, 'asset_current', false, null, 360),
  ('GG', 'default', '1150', 'Income tax recoverable', '{}'::jsonb, 'asset_current', false, null, 370),
  ('GG', 'default', '1160', 'Employee advances and expense claims', '{}'::jsonb, 'asset_current', false, null, 380),
  ('GG', 'default', '1200', 'Shares in group undertakings — held as a current asset', '{}'::jsonb, 'asset_current', false, null, 390),
  ('GG', 'default', '1210', 'Other investments — held as a current asset', '{}'::jsonb, 'asset_current', false, null, 400),
  ('GG', 'default', '1300', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 410),
  ('GG', 'default', '1310', 'Bank deposit account', '{}'::jsonb, 'asset_cash', false, null, 420),
  ('GG', 'default', '1320', 'Bank account in a foreign currency', '{}'::jsonb, 'asset_cash', false, null, 430),
  ('GG', 'default', '1330', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 440),
  ('GG', 'default', '1340', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 450),
  ('GG', 'default', '1350', 'Card acquirer settlement account', '{}'::jsonb, 'asset_cash', false, null, 460),
  ('GG', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 470),
  ('GG', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 480),
  ('GG', 'default', '1420', 'Payments on account to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 490),
  ('GG', 'default', '2000', 'Bank loans — due within one year', '{}'::jsonb, 'liability_current', false, null, 500),
  ('GG', 'default', '2010', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 510),
  ('GG', 'default', '2020', 'Credit card account', '{}'::jsonb, 'liability_credit_card', false, null, 520),
  ('GG', 'default', '2100', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 530),
  ('GG', 'default', '2110', 'Amounts owed to group undertakings and undertakings in which the company has a participating interest', '{}'::jsonb, 'liability_current', false, null, 540),
  ('GG', 'default', '2220', 'Income tax (employees) and social security contributions payable', '{}'::jsonb, 'liability_current', false, null, 550),
  ('GG', 'default', '2240', 'Pension contributions payable', '{}'::jsonb, 'liability_current', false, null, 560),
  ('GG', 'default', '2250', 'Net wages payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('GG', 'default', '2260', 'Directors'' loan account — credit', '{}'::jsonb, 'liability_current', false, null, 580),
  ('GG', 'default', '2270', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('GG', 'default', '2280', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('GG', 'default', '2290', 'Other creditors', '{}'::jsonb, 'liability_current', false, null, 610),
  ('GG', 'default', '2300', 'Obligations under finance leases and hire purchase — due within one year', '{}'::jsonb, 'liability_current', false, null, 620),
  ('GG', 'default', '2400', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 630),
  ('GG', 'default', '3000', 'Bank loans — due after more than one year', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('GG', 'default', '3010', 'Other loans — due after more than one year', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('GG', 'default', '3020', 'Trade creditors — due after more than one year', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('GG', 'default', '3030', 'Amounts owed to group undertakings and undertakings in which the company has a participating interest — due after more than one year', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('GG', 'default', '3040', 'Obligations under finance leases and hire purchase — due after more than one year', '{}'::jsonb, 'liability_non_current', false, null, 680),
  ('GG', 'default', '3050', 'Other creditors — due after more than one year', '{}'::jsonb, 'liability_non_current', false, null, 690),
  ('GG', 'default', '3100', 'Provision for deferred taxation', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('GG', 'default', '3110', 'Other provisions for liabilities', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('GG', 'default', '3200', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 720),
  ('GG', 'default', '3210', 'Deferred income', '{}'::jsonb, 'liability_current', false, null, 730),
  ('GG', 'default', '3300', 'Called up share capital', '{}'::jsonb, 'equity', false, null, 740),
  ('GG', 'default', '3310', 'Share premium account', '{}'::jsonb, 'equity', false, null, 750),
  ('GG', 'default', '3320', 'Revaluation reserve', '{}'::jsonb, 'equity', false, null, 760),
  ('GG', 'default', '3330', 'Capital redemption reserve', '{}'::jsonb, 'equity', false, null, 770),
  ('GG', 'default', '3340', 'Other reserves', '{}'::jsonb, 'equity', false, null, 780),
  ('GG', 'default', '3400', 'Profit and loss account', '{}'::jsonb, 'equity_retained', false, null, 790),
  ('GG', 'default', '3410', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 800),
  ('GG', 'default', '4000', 'Sales — goods', '{}'::jsonb, 'income', false, null, 810),
  ('GG', 'default', '4010', 'Sales — services', '{}'::jsonb, 'income', false, null, 820),
  ('GG', 'default', '4050', 'Sales — exports of goods', '{}'::jsonb, 'income', false, null, 830),
  ('GG', 'default', '4070', 'Retail takings', '{}'::jsonb, 'income', false, null, 840),
  ('GG', 'default', '4100', 'Sales returns and allowances', '{}'::jsonb, 'income', false, null, 850),
  ('GG', 'default', '4110', 'Discounts allowed', '{}'::jsonb, 'income', false, null, 860),
  ('GG', 'default', '4200', 'Other operating income', '{}'::jsonb, 'income_other', false, null, 870),
  ('GG', 'default', '4210', 'Rental income', '{}'::jsonb, 'income_other', false, null, 880),
  ('GG', 'default', '4220', 'Grants receivable', '{}'::jsonb, 'income_other', false, null, 890),
  ('GG', 'default', '4230', 'Profit on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 900),
  ('GG', 'default', '4240', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 910),
  ('GG', 'default', '4300', 'Income from shares in group undertakings', '{}'::jsonb, 'income_other', false, null, 920),
  ('GG', 'default', '4310', 'Income from participating interests', '{}'::jsonb, 'income_other', false, null, 930),
  ('GG', 'default', '4320', 'Income from other fixed asset investments', '{}'::jsonb, 'income_other', false, null, 940),
  ('GG', 'default', '4330', 'Other interest receivable and similar income', '{}'::jsonb, 'income_other', false, null, 950),
  ('GG', 'default', '5000', 'Purchases — goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('GG', 'default', '5010', 'Purchases — raw materials and consumables', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('GG', 'default', '5020', 'Carriage inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('GG', 'default', '5030', 'Import duty and freight', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('GG', 'default', '5040', 'Purchase returns and allowances', '{}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('GG', 'default', '5050', 'Discounts received', '{}'::jsonb, 'expense_direct_cost', false, null, 1010),
  ('GG', 'default', '5100', 'Opening stock', '{}'::jsonb, 'expense_direct_cost', false, null, 1020),
  ('GG', 'default', '5110', 'Closing stock', '{}'::jsonb, 'expense_direct_cost', false, null, 1030),
  ('GG', 'default', '5200', 'Subcontractor costs', '{}'::jsonb, 'expense_direct_cost', false, null, 1040),
  ('GG', 'default', '5210', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 1050),
  ('GG', 'default', '5220', 'Direct expenses — plant and equipment hire', '{}'::jsonb, 'expense_direct_cost', false, null, 1060),
  ('GG', 'default', '5230', 'Direct expenses — materials', '{}'::jsonb, 'expense_direct_cost', false, null, 1070),
  ('GG', 'default', '5240', 'Direct expenses — other', '{}'::jsonb, 'expense_direct_cost', false, null, 1080),
  ('GG', 'default', '6000', 'Advertising', '{}'::jsonb, 'expense', false, null, 1090),
  ('GG', 'default', '6010', 'Marketing and promotion', '{}'::jsonb, 'expense', false, null, 1100),
  ('GG', 'default', '6020', 'Website and online advertising', '{}'::jsonb, 'expense', false, null, 1110),
  ('GG', 'default', '6100', 'Carriage outwards', '{}'::jsonb, 'expense', false, null, 1120),
  ('GG', 'default', '6110', 'Packaging', '{}'::jsonb, 'expense', false, null, 1130),
  ('GG', 'default', '6200', 'Distribution staff — wages and salaries', '{}'::jsonb, 'expense', false, null, 1140),
  ('GG', 'default', '6210', 'Distribution staff — employer''s social security contributions', '{}'::jsonb, 'expense', false, null, 1150),
  ('GG', 'default', '6220', 'Distribution staff — employer''s pension contributions', '{}'::jsonb, 'expense', false, null, 1160),
  ('GG', 'default', '6230', 'Sales commission', '{}'::jsonb, 'expense', false, null, 1170),
  ('GG', 'default', '6300', 'Delivery vehicle running costs', '{}'::jsonb, 'expense', false, null, 1180),
  ('GG', 'default', '6310', 'Travelling — distribution', '{}'::jsonb, 'expense', false, null, 1190),
  ('GG', 'default', '6400', 'Warehouse rent and property rates', '{}'::jsonb, 'expense', false, null, 1200),
  ('GG', 'default', '6410', 'Warehouse light and heat', '{}'::jsonb, 'expense', false, null, 1210),
  ('GG', 'default', '6420', 'Warehouse insurance', '{}'::jsonb, 'expense', false, null, 1220),
  ('GG', 'default', '6500', 'Depreciation — distribution assets', '{}'::jsonb, 'expense_depreciation', false, null, 1230),
  ('GG', 'default', '7000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1240),
  ('GG', 'default', '7010', 'Wages and salaries', '{}'::jsonb, 'expense', false, null, 1250),
  ('GG', 'default', '7020', 'Employer''s social security contributions', '{}'::jsonb, 'expense', false, null, 1260),
  ('GG', 'default', '7030', 'Employer''s pension contributions', '{}'::jsonb, 'expense', false, null, 1270),
  ('GG', 'default', '7040', 'Staff training', '{}'::jsonb, 'expense', false, null, 1280),
  ('GG', 'default', '7050', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1290),
  ('GG', 'default', '7060', 'Recruitment costs', '{}'::jsonb, 'expense', false, null, 1300),
  ('GG', 'default', '7070', 'Temporary and agency staff', '{}'::jsonb, 'expense', false, null, 1310),
  ('GG', 'default', '7100', 'Rent', '{}'::jsonb, 'expense', false, null, 1320),
  ('GG', 'default', '7110', 'Tax on Real Property and rates', '{}'::jsonb, 'expense', false, null, 1330),
  ('GG', 'default', '7120', 'Light and heat', '{}'::jsonb, 'expense', false, null, 1340),
  ('GG', 'default', '7130', 'Water rates', '{}'::jsonb, 'expense', false, null, 1350),
  ('GG', 'default', '7140', 'Insurance', '{}'::jsonb, 'expense', false, null, 1360),
  ('GG', 'default', '7150', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1370),
  ('GG', 'default', '7160', 'Cleaning', '{}'::jsonb, 'expense', false, null, 1380),
  ('GG', 'default', '7170', 'Security', '{}'::jsonb, 'expense', false, null, 1390),
  ('GG', 'default', '7200', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1400),
  ('GG', 'default', '7210', 'Postage and carriage', '{}'::jsonb, 'expense', false, null, 1410),
  ('GG', 'default', '7220', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1420),
  ('GG', 'default', '7230', 'Software and subscriptions', '{}'::jsonb, 'expense', false, null, 1430),
  ('GG', 'default', '7240', 'Computer and IT costs', '{}'::jsonb, 'expense', false, null, 1440),
  ('GG', 'default', '7250', 'Equipment hire', '{}'::jsonb, 'expense', false, null, 1450),
  ('GG', 'default', '7260', 'Sundry expenses', '{}'::jsonb, 'expense', false, null, 1460),
  ('GG', 'default', '7300', 'Motor vehicle running costs', '{}'::jsonb, 'expense', false, null, 1470),
  ('GG', 'default', '7310', 'Motor vehicle leasing and hire', '{}'::jsonb, 'expense', false, null, 1480),
  ('GG', 'default', '7320', 'Travel and subsistence', '{}'::jsonb, 'expense', false, null, 1490),
  ('GG', 'default', '7330', 'Business entertainment', '{}'::jsonb, 'expense', false, null, 1500),
  ('GG', 'default', '7400', 'Accountancy fees', '{}'::jsonb, 'expense', false, null, 1510),
  ('GG', 'default', '7410', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 1520),
  ('GG', 'default', '7420', 'Consultancy fees', '{}'::jsonb, 'expense', false, null, 1530),
  ('GG', 'default', '7430', 'Audit fee', '{}'::jsonb, 'expense', false, null, 1540),
  ('GG', 'default', '7440', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1550),
  ('GG', 'default', '7450', 'Card processing charges', '{}'::jsonb, 'expense', false, null, 1560),
  ('GG', 'default', '7460', 'Subscriptions to professional bodies', '{}'::jsonb, 'expense', false, null, 1570),
  ('GG', 'default', '7470', 'Charitable donations', '{}'::jsonb, 'expense', false, null, 1580),
  ('GG', 'default', '7500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1590),
  ('GG', 'default', '7510', 'Movement in the provision for doubtful debts', '{}'::jsonb, 'expense', false, null, 1600),
  ('GG', 'default', '7600', 'Depreciation — freehold land and buildings', '{}'::jsonb, 'expense_depreciation', false, null, 1610),
  ('GG', 'default', '7610', 'Depreciation — leasehold property and improvements', '{}'::jsonb, 'expense_depreciation', false, null, 1620),
  ('GG', 'default', '7620', 'Depreciation — plant and machinery', '{}'::jsonb, 'expense_depreciation', false, null, 1630),
  ('GG', 'default', '7630', 'Depreciation — fixtures and fittings', '{}'::jsonb, 'expense_depreciation', false, null, 1640),
  ('GG', 'default', '7640', 'Depreciation — office equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1650),
  ('GG', 'default', '7650', 'Depreciation — computer equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1660),
  ('GG', 'default', '7660', 'Depreciation — motor vehicles', '{}'::jsonb, 'expense_depreciation', false, null, 1670),
  ('GG', 'default', '7670', 'Amortisation of goodwill', '{}'::jsonb, 'expense_depreciation', false, null, 1680),
  ('GG', 'default', '7680', 'Amortisation of other intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1690),
  ('GG', 'default', '7690', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1700),
  ('GG', 'default', '7700', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1710),
  ('GG', 'default', '7710', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1720),
  ('GG', 'default', '8000', 'Bank interest payable', '{}'::jsonb, 'expense', false, null, 1730),
  ('GG', 'default', '8010', 'Loan interest payable', '{}'::jsonb, 'expense', false, null, 1740),
  ('GG', 'default', '8020', 'Finance lease and hire purchase interest', '{}'::jsonb, 'expense', false, null, 1750),
  ('GG', 'default', '8030', 'Other interest payable and similar expenses', '{}'::jsonb, 'expense', false, null, 1760),
  ('GG', 'default', '8040', 'Interest and recovery costs on late payment', '{}'::jsonb, 'expense', false, null, 1770),
  ('GG', 'default', '8100', 'Amounts written off investments', '{}'::jsonb, 'expense', false, null, 1780),
  ('GG', 'default', '8200', 'Income tax on profit or loss', '{}'::jsonb, 'expense', false, null, 1790),
  ('GG', 'default', '8210', 'Income tax — adjustment in respect of prior periods', '{}'::jsonb, 'expense', false, null, 1800),
  ('GG', 'default', '8220', 'Deferred taxation charge', '{}'::jsonb, 'expense', false, null, 1810),
  ('GG', 'default', '8300', 'Other taxes not shown under the above items', '{}'::jsonb, 'expense', false, null, 1820)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GG', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('GG', 'CSH', 'Cash book', '{}'::jsonb, 'cash', 40),
  ('GG', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('GG', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('GG', 'PUR', 'Purchase day book', '{}'::jsonb, 'purchase', 20),
  ('GG', 'SAL', 'Sales day book', '{}'::jsonb, 'sales', 10)
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
  ('GG', 'GG-P-NA', 'Purchase, not subject to any tax on turnover', '{}'::jsonb, 'Every purchase a Guernsey business books — domestic, imported, or delivered from outside Guernsey to a place outside Guernsey', 'percent', 0, 'purchase', 'not_subject', date '2000-01-01', null, 'The purchase side of GG-S-NA: nothing a Guernsey business buys carries a value added tax, goods and services tax or general sales tax to recover today, whether the seller is in Guernsey or abroad (States of Guernsey Revenue Service and PwC worldwide tax summaries, consulted 2026-10-10). Imports carry customs duty at rates from 0 % to 22 % by commodity under the customs rules Guernsey applies (PwC worldwide tax summaries, consulted 2026-10-10), plus excise duties on specific goods; these are duties on goods and not a general tax an invoice line can carry a code for, and this pack does not model them. Document Duty is charged on transfers of real property (same source) and is not modelled either. The GST voted in principle on 2 October 2026 for 2029 is not enacted; no purchase-side code exists for it. See ''From Guernsey'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'gg-pwc-other-taxes', null, null, null, null),
  ('GG', 'GG-S-NA', 'Sale, not subject to any tax on turnover', '{}'::jsonb, 'Every sale a Guernsey business makes — domestic, exported, or delivered from outside Guernsey to a place outside Guernsey', 'percent', 0, 'sale', 'not_subject', date '2000-01-01', null, 'Guernsey levies no value added tax, goods and services tax or general tax on the sale of goods or services today: the States of Guernsey Revenue Service describes its taxes as income tax and social security contributions (https://www.gov.gg/tax, consulted 2026-10-10), and the PwC worldwide tax summaries state that ''Guernsey does not currently operate a VAT or goods and service tax (GST)'' (consulted 2026-10-10). On 2 October 2026 the States of Deliberation voted, 22 to 17, for the principle of a GST of 3 % from 2029, with a pathway to 4 % and then 5 % subject to an independent fiscal review (Guernsey Press, consulted 2026-10-10); no GST law is enacted or in force and no rate is promulgated, so this pack creates no GST code. The official resolution on the States voting records site (statesvoting-records.gov.gg) could not be opened from the environment that wrote this pack. What a Guernsey company pays on its trading is income tax at 0 % (standard), 10 % (banking, domestic insurance, fiduciary and similar regulated activities) or 20 % (property, utilities, retail with taxable profits over £500,000, hydrocarbon oil and gas) under the Income Tax (Guernsey) Law, 1975, filed online (https://gov.gg/RevenueService/Companies); a domestic top-up tax for in-scope multinational groups since 1 January 2025; and social security contributions. None of them is a tax any single invoice carries, so the code exists only so that every sale line carries a tax code the engine can post, and states plainly that this jurisdiction has none. See ''From Guernsey'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'gg-tax', null, null, null, null)
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
    ('GG-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GG-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GG-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GG-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GG' and t.code = v.tax_code
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
  ('GG-FRS102-1A-BS', 'GG', 'default', 'Balance sheet — FRS 102 Section 1A, Format 1', 'balance_sheet', 'UK-FRS102', date '1970-01-01', null, 'FRS 102 The Financial Reporting Standard applicable in the UK and Republic of Ireland, Section 1A (Small Entities), is the framework this statement follows: the Companies (Guernsey) Law, 2008 requires accounts including a balance sheet that give a true and fair view and state the generally accepted accounting principles adopted (Walkers, consulted 2026-10-10), and names no format; UK GAAP is one of the principles a Guernsey company may declare. The layout is the one Section 1A shows for small entities, the Format 1 balance sheet (fixed assets, current assets, creditors due within and after one year, provisions, capital and reserves) in its summarised form. It is a layout borrowed from the United Kingdom standard, not a format Guernsey law imposes, and the lines are the pack''s own groupings of its original chart. Line K.IV carries the year''s result not yet closed to retained earnings, so that the statement ties to the cent on an open year. The text of the Law itself could not be opened; see the README.', 'frs-102'),
  ('GG-FRS102-1A-IS', 'GG', 'default', 'Profit and loss account — FRS 102 Section 1A, Format 1', 'income_statement', 'UK-FRS102', date '1970-01-01', null, 'FRS 102 Section 1A (Small Entities): the profit and loss account in the Format 1 layout (turnover, cost of sales, gross profit, distribution costs, administrative expenses, other operating income, investment income, interest, tax). Guernsey law requires a profit and loss account that gives a true and fair view and names no format (Companies (Guernsey) Law, 2008, per Walkers, consulted 2026-10-10); the layout is borrowed from the United Kingdom standard. The tax line carries Guernsey income tax on the company''s profit (0 %, 10 % or 20 %, States of Guernsey Revenue Service, consulted 2026-10-10), booked by the company: nothing in this pack computes it.', 'frs-102')
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
  ('GG-FRS102-1A-BS', 'A', null, 'Called up share capital not paid', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'B.I', 'B', 'Intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'B.II', 'B', 'Tangible assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'B.III', 'B', 'Investments', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'B', null, 'Fixed assets', '{}'::jsonb, 50, 1, true, array['B.I', 'B.II', 'B.III']::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'C.I', 'C', 'Stocks', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'C.II', 'C', 'Debtors', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'C.III', 'C', 'Investments', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'C.IV', 'C', 'Cash at bank and in hand', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['C.I', 'C.II', 'C.III', 'C.IV']::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'D', null, 'Prepayments and accrued income', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'E.1', 'E', 'Bank loans and overdrafts', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'E.2', 'E', 'Trade creditors', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'E.3', 'E', 'Amounts owed to group undertakings', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'E.4', 'E', 'Other creditors including taxation and social security', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'E', null, 'Creditors: amounts falling due within one year', '{}'::jsonb, 160, 1, true, array['E.1', 'E.2', 'E.3', 'E.4']::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'J', null, 'Accruals and deferred income', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'F', null, 'Net current assets (liabilities)', '{}'::jsonb, 180, 1, true, array['C', 'D']::text[], array['E', 'J']::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'G', null, 'Total assets less current liabilities', '{}'::jsonb, 190, 1, true, array['A', 'B', 'F']::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'H', null, 'Creditors: amounts falling due after more than one year', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'I', null, 'Provisions for liabilities', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'NET', null, 'Net assets (liabilities)', '{}'::jsonb, 220, 1, true, array['G']::text[], array['H', 'I']::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'K.I', 'K', 'Called up share capital', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'K.II', 'K', 'Share premium account and other reserves', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'K.III', 'K', 'Profit and loss account brought forward', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'K.IV', 'K', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-BS', 'K', null, 'Capital and reserves', '{}'::jsonb, 270, 1, true, array['K.I', 'K.II', 'K.III', 'K.IV']::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '1', null, 'Turnover', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '2', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '3', null, 'Gross profit or loss', '{}'::jsonb, 30, 1, true, array['1']::text[], array['2']::text[], null, null, null),
  ('GG-FRS102-1A-IS', '4', null, 'Distribution costs', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '5', null, 'Administrative expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '6', null, 'Other operating income', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '7', null, 'Income from investments', '{}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '8', null, 'Other interest receivable and similar income', '{}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '9', null, 'Amounts written off investments', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '10', null, 'Interest payable and similar expenses', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '11', null, 'Tax on profit or loss', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '12', null, 'Other taxes not shown under the above items', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GG-FRS102-1A-IS', '13', null, 'Profit or loss for the financial year', '{}'::jsonb, 130, 1, true, array['3', '6', '7', '8']::text[], array['4', '5', '9', '10', '11', '12']::text[], null, null, null)
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
    ('GG-FRS102-1A-BS', 'A', 10, 'account_code', '0000', null, null, 'any'),
    ('GG-FRS102-1A-BS', 'B.I', 10, 'code_range', '0010', '0041', null, 'any'),
    ('GG-FRS102-1A-BS', 'B.II', 10, 'code_range', '0100', '0161', null, 'any'),
    ('GG-FRS102-1A-BS', 'B.III', 10, 'code_range', '0200', '0230', null, 'any'),
    ('GG-FRS102-1A-BS', 'C.I', 10, 'code_range', '1000', '1030', null, 'any'),
    ('GG-FRS102-1A-BS', 'C.II', 10, 'code_range', '1100', '1160', null, 'any'),
    ('GG-FRS102-1A-BS', 'C.III', 10, 'code_range', '1200', '1210', null, 'any'),
    ('GG-FRS102-1A-BS', 'C.IV', 10, 'code_range', '1300', '1350', null, 'any'),
    ('GG-FRS102-1A-BS', 'D', 10, 'code_range', '1400', '1420', null, 'any'),
    ('GG-FRS102-1A-BS', 'E.1', 10, 'code_range', '2000', '2020', null, 'any'),
    ('GG-FRS102-1A-BS', 'E.2', 10, 'account_code', '2100', null, null, 'any'),
    ('GG-FRS102-1A-BS', 'E.3', 10, 'account_code', '2110', null, null, 'any'),
    ('GG-FRS102-1A-BS', 'E.4', 10, 'code_range', '2200', '2400', null, 'any'),
    ('GG-FRS102-1A-BS', 'J', 10, 'code_range', '3200', '3210', null, 'any'),
    ('GG-FRS102-1A-BS', 'H', 10, 'code_range', '3000', '3050', null, 'any'),
    ('GG-FRS102-1A-BS', 'I', 10, 'code_range', '3100', '3110', null, 'any'),
    ('GG-FRS102-1A-BS', 'K.I', 10, 'account_code', '3300', null, null, 'any'),
    ('GG-FRS102-1A-BS', 'K.II', 10, 'code_range', '3310', '3340', null, 'any'),
    ('GG-FRS102-1A-BS', 'K.III', 10, 'code_range', '3400', '3410', null, 'any'),
    ('GG-FRS102-1A-BS', 'K.IV', 10, 'code_range', '4000', '8399', null, 'any'),
    ('GG-FRS102-1A-IS', '1', 10, 'code_range', '4000', '4110', null, 'any'),
    ('GG-FRS102-1A-IS', '2', 10, 'code_range', '5000', '5240', null, 'any'),
    ('GG-FRS102-1A-IS', '4', 10, 'code_range', '6000', '6500', null, 'any'),
    ('GG-FRS102-1A-IS', '5', 10, 'code_range', '7000', '7710', null, 'any'),
    ('GG-FRS102-1A-IS', '6', 10, 'code_range', '4200', '4240', null, 'any'),
    ('GG-FRS102-1A-IS', '7', 10, 'code_range', '4300', '4320', null, 'any'),
    ('GG-FRS102-1A-IS', '8', 10, 'account_code', '4330', null, null, 'any'),
    ('GG-FRS102-1A-IS', '9', 10, 'account_code', '8100', null, null, 'any'),
    ('GG-FRS102-1A-IS', '10', 10, 'code_range', '8000', '8040', null, 'any'),
    ('GG-FRS102-1A-IS', '11', 10, 'code_range', '8200', '8220', null, 'any'),
    ('GG-FRS102-1A-IS', '12', 10, 'account_code', '8300', null, null, 'any')
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
  ('GG', 'Guernsey', '{}'::jsonb, array['en']::text[], 'GBP', '1100', '2100', '2400', '7710', '3400', '4000', '5000', '1300', '1330', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4240', '7700', '4230', '7690', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Guernsey levies no value added tax, goods and services tax or general sales tax today (States of Guernsey Revenue Service, consulted 2026-10-10: income tax and social security contributions are the taxes it collects; PwC worldwide tax summaries: ''Guernsey does not currently operate a VAT or goods and service tax (GST)''), so no tax statute conditions anything on an invoice carrying a sequential number. The only record-keeping duty found is that of the Companies (Guernsey) Law, 2008: accounting records sufficient to show and explain the company''s transactions, kept for at least six years (Walkers, consulted 2026-10-10) — a duty about what is kept and not about how a document already issued is numbered. `numbering` is therefore `free`; `number_format` is a convention this pack proposes. A GST, if it is enacted, will probably bring its own invoice rules; none exists to cite.',
  numbering_source_key          = 'gg-companies-law',
  payment_terms_legal_reference = 'No Guernsey statute was found that sets a payment term between two businesses in the absence of an agreement, or a rate of interest on a commercial debt paid late; the Late Payment of Commercial Debts (Interest) Act 1998 is a United Kingdom statute and no source consulted says it extends to Guernsey. `legal_payment_days` and `late_payment_reference` are therefore empty, and a seller''s own terms are a matter of contract. This is an absence of a source found, not a proof of absence: a Guernsey lawyer should confirm it.',
  payment_terms_source_key      = 'gg-companies-law',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in Guernsey today: it names the day a country''s general rule makes its own turnover tax chargeable, and Guernsey charges none. `invoice_date` is declared as the closest general commercial convention — revenue is ordinarily invoiced at or shortly after the point FRS 102 recognises it — and not as a rule read from a text. If the GST voted in principle on 2 October 2026 is enacted, its own time-of-supply rule will replace this convention; see ''From Guernsey'' in docs/international.md.',
  tax_point_source_key          = 'frs-102',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Guernsey statute was found that obliges a business to issue or accept an electronic invoice, and no Peppol Authority is listed for Guernsey (OpenPeppol list of Peppol Authorities, not re-opened for this pack: the absence is as of the author''s knowledge and must be re-checked). `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name and no VAT identifier for a scheme to carry, since Guernsey levies no value added tax or goods and services tax today (States of Guernsey Revenue Service and PwC worldwide tax summaries, consulted 2026-10-10).',
  einvoice_source_key           = 'gg-pwc-other-taxes',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'GG';
