-- Ekwo OS — Lao PDR: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/la at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build la`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Law on Value Added Tax (Amended) No. 48/NA, 20 June 2018 — summary page; the full text is published in Lao only (Department of Foreign Trade, Ministry of Industry and Commerce, Lao PDR (Lao Trade Portal))
--     https://www.laotradeportal.gov.la/en-gb/site/display/1846
--   Lao PDR Tax Alert: New Amended Law on VAT — rate (article 17), exemptions (article 12), return and payment (article 30), input tax (articles 22 to 24), refunds (article 28) (DFDL (law firm), reading the Law on Value Added Tax No. 48/NA of 2018)
--     https://www.dfdl.com/insights/legal-and-tax-updates/lao-pdr-tax-alert-new-amended-law-on-vat
--   Laos reinstates 10% VAT rate — Ordinance of the President No. 003/PDT of 19 March 2024 (Tilleke & Gibbins (law firm), reporting the Ordinance)
--     https://www.tilleke.com/insights/laos-reinstates-10-vat-rate/2/
--   Lao PDR — Corporate — Other taxes (value added tax: rate, exports, exemptions, three-month rule, withholding on services from abroad) (PwC, Worldwide Tax Summaries)
--     https://taxsummaries.pwc.com/lao-pdr/corporate/other-taxes
--   IFRS for SMEs Accounting Standard — the basis of the Lao financial reporting standards for entities that are not public interest entities (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Ministry of Finance of the Lao PDR — the Tax Department and the Accounting Department sit under it (Ministry of Finance, Lao PDR)
--     https://www.mof.gov.la
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('LA', 'Lao PDR', '0.1.0', date '2026-10-21', '20261011120000', 'community', null, null, '6dc45e4edb7875dd7ece6462121b556a2d94190bba837dba0e0e129b8ba12d1e', '[{"key":"vat-law","title":"Law on Value Added Tax (Amended) No. 48/NA, 20 June 2018 — summary page; the full text is published in Lao only","publisher":"Department of Foreign Trade, Ministry of Industry and Commerce, Lao PDR (Lao Trade Portal)","url":"https://www.laotradeportal.gov.la/en-gb/site/display/1846","consulted_on":"2026-10-21","kind":"law"},{"key":"vat-law-articles","title":"Lao PDR Tax Alert: New Amended Law on VAT — rate (article 17), exemptions (article 12), return and payment (article 30), input tax (articles 22 to 24), refunds (article 28)","publisher":"DFDL (law firm), reading the Law on Value Added Tax No. 48/NA of 2018","url":"https://www.dfdl.com/insights/legal-and-tax-updates/lao-pdr-tax-alert-new-amended-law-on-vat","consulted_on":"2026-10-21","kind":"regulation"},{"key":"vat-rate-2024","title":"Laos reinstates 10% VAT rate — Ordinance of the President No. 003/PDT of 19 March 2024","publisher":"Tilleke & Gibbins (law firm), reporting the Ordinance","url":"https://www.tilleke.com/insights/laos-reinstates-10-vat-rate/2/","consulted_on":"2026-10-21","kind":"regulation"},{"key":"tax-summary","title":"Lao PDR — Corporate — Other taxes (value added tax: rate, exports, exemptions, three-month rule, withholding on services from abroad)","publisher":"PwC, Worldwide Tax Summaries","url":"https://taxsummaries.pwc.com/lao-pdr/corporate/other-taxes","consulted_on":"2026-10-21","kind":"regulation"},{"key":"ifrs-sme","title":"IFRS for SMEs Accounting Standard — the basis of the Lao financial reporting standards for entities that are not public interest entities","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-21","kind":"standard"},{"key":"mof-portal","title":"Ministry of Finance of the Lao PDR — the Tax Department and the Accounting Department sit under it","publisher":"Ministry of Finance, Lao PDR","url":"https://www.mof.gov.la","consulted_on":"2026-10-21","kind":"portal"}]'::jsonb)
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
  ('LA', 'default', 'Reference chart of accounts for commercial enterprises (the pack''s own grouping by the classes of the IFRS for SMEs statements)', '{}'::jsonb, true, 'companies', array['LA-BS', 'LA-IS']::text[], null, 'The Law on Accounting (amended 2013, in force July 2014) has the Ministry of Finance set the accounting standards: public interest entities apply IFRS and the other enterprises the Lao financial reporting standards for non-public interest entities, which follow the IFRS for SMEs. The enterprise chart of accounts that the Ministry of Finance prescribes (the 1992 Lao general accounting plan, modelled on the French plan) could not be read from an open source, nor the decision that currently approves it. The classes (1 current assets, 2 non-current assets, 3 current liabilities, 4 non-current liabilities, 5 equity, 6 income, 7 to 9 expenses) and every code are this pack''s grouping by the items an IFRS for SMEs balance sheet and income statement present, not a copy of the official plan. A Lao accountant must check it against the official plan before a company keeps its books on it. See README.md.', 'ifrs-sme')
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
  ('LA', 'default', '1000', 'Current assets', '{}'::jsonb, 'asset_current', false, null, 10),
  ('LA', 'default', '1100', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, '1000', 20),
  ('LA', 'default', '1110', 'Cash in national currency', '{}'::jsonb, 'asset_cash', false, '1100', 30),
  ('LA', 'default', '1120', 'Cash in foreign currency', '{}'::jsonb, 'asset_cash', false, '1100', 40),
  ('LA', 'default', '1200', 'Cash at bank', '{}'::jsonb, 'asset_cash', false, '1000', 50),
  ('LA', 'default', '1210', 'Current accounts in national currency', '{}'::jsonb, 'asset_cash', false, '1200', 60),
  ('LA', 'default', '1220', 'Accounts in foreign currency', '{}'::jsonb, 'asset_cash', false, '1200', 70),
  ('LA', 'default', '1230', 'Cash restricted in use', '{}'::jsonb, 'asset_cash', false, '1200', 80),
  ('LA', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, '1000', 90),
  ('LA', 'default', '1310', 'Short-term securities', '{}'::jsonb, 'asset_current', false, '1300', 100),
  ('LA', 'default', '1320', 'Short-term deposits', '{}'::jsonb, 'asset_current', false, '1300', 110),
  ('LA', 'default', '1400', 'Accounts and notes receivable', '{}'::jsonb, 'asset_current', false, '1000', 120),
  ('LA', 'default', '1410', 'Accounts receivable (customers)', '{}'::jsonb, 'asset_receivable', true, '1400', 130),
  ('LA', 'default', '1420', 'Receivables from related parties', '{}'::jsonb, 'asset_current', false, '1400', 140),
  ('LA', 'default', '1491', 'Allowance for doubtful debts', '{}'::jsonb, 'asset_current', false, '1400', 150),
  ('LA', 'default', '1500', 'Other short-term receivables', '{}'::jsonb, 'asset_current', false, '1000', 160),
  ('LA', 'default', '1510', 'Notes receivable', '{}'::jsonb, 'asset_current', false, '1500', 170),
  ('LA', 'default', '1520', 'Advances paid', '{}'::jsonb, 'asset_prepayments', false, '1500', 180),
  ('LA', 'default', '1530', 'Amounts held by accountable persons', '{}'::jsonb, 'asset_current', false, '1500', 190),
  ('LA', 'default', '1540', 'VAT recoverable', '{}'::jsonb, 'asset_current', false, '1500', 200),
  ('LA', 'default', '1541', 'Input VAT on purchased goods, work and services', '{}'::jsonb, 'asset_current', false, '1540', 210),
  ('LA', 'default', '1542', 'VAT settlement with the budget (refundable)', '{}'::jsonb, 'asset_current', true, '1540', 220),
  ('LA', 'default', '1543', 'Input VAT on services from non-residents (after payment)', '{}'::jsonb, 'asset_current', false, '1540', 230),
  ('LA', 'default', '1550', 'Interest receivable', '{}'::jsonb, 'asset_current', false, '1500', 240),
  ('LA', 'default', '1560', 'Dividends receivable', '{}'::jsonb, 'asset_current', false, '1500', 250),
  ('LA', 'default', '1570', 'Overpaid other taxes', '{}'::jsonb, 'asset_current', false, '1500', 260),
  ('LA', 'default', '1590', 'Other short-term receivables, miscellaneous', '{}'::jsonb, 'asset_current', false, '1500', 270),
  ('LA', 'default', '1600', 'Inventories', '{}'::jsonb, 'asset_current', false, '1000', 280),
  ('LA', 'default', '1610', 'Goods for resale', '{}'::jsonb, 'asset_current', false, '1600', 290),
  ('LA', 'default', '1620', 'Raw materials', '{}'::jsonb, 'asset_current', false, '1600', 300),
  ('LA', 'default', '1625', 'Auxiliary materials', '{}'::jsonb, 'asset_current', false, '1600', 310),
  ('LA', 'default', '1630', 'Work in progress', '{}'::jsonb, 'asset_current', false, '1600', 320),
  ('LA', 'default', '1635', 'Production overheads', '{}'::jsonb, 'asset_current', false, '1600', 330),
  ('LA', 'default', '1640', 'Finished goods', '{}'::jsonb, 'asset_current', false, '1600', 340),
  ('LA', 'default', '1700', 'Prepaid expenses and other current assets', '{}'::jsonb, 'asset_current', false, '1000', 350),
  ('LA', 'default', '1710', 'Prepaid expenses', '{}'::jsonb, 'asset_current', false, '1700', 360),
  ('LA', 'default', '1750', 'Low-value and short-life items', '{}'::jsonb, 'asset_current', false, '1700', 370),
  ('LA', 'default', '1790', 'Other current assets', '{}'::jsonb, 'asset_current', false, '1700', 380),
  ('LA', 'default', '2000', 'Non-current assets', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('LA', 'default', '2100', 'Property, plant and equipment', '{}'::jsonb, 'asset_fixed', false, '2000', 400),
  ('LA', 'default', '2110', 'Land', '{}'::jsonb, 'asset_fixed', false, '2100', 410),
  ('LA', 'default', '2120', 'Buildings and structures', '{}'::jsonb, 'asset_fixed', false, '2100', 420),
  ('LA', 'default', '2130', 'Machinery and equipment', '{}'::jsonb, 'asset_fixed', false, '2100', 430),
  ('LA', 'default', '2140', 'Vehicles', '{}'::jsonb, 'asset_fixed', false, '2100', 440),
  ('LA', 'default', '2150', 'Furniture and office equipment', '{}'::jsonb, 'asset_fixed', false, '2100', 450),
  ('LA', 'default', '2160', 'Other property, plant and equipment', '{}'::jsonb, 'asset_fixed', false, '2100', 460),
  ('LA', 'default', '2193', 'Accumulated depreciation, production', '{}'::jsonb, 'asset_fixed', false, '2100', 470),
  ('LA', 'default', '2199', 'Accumulated depreciation, other', '{}'::jsonb, 'asset_fixed', false, '2100', 480),
  ('LA', 'default', '2700', 'Long-term receivables', '{}'::jsonb, 'asset_non_current', false, '2000', 490),
  ('LA', 'default', '2800', 'Long-term investments', '{}'::jsonb, 'asset_non_current', false, '2000', 500),
  ('LA', 'default', '2900', 'Intangible assets', '{}'::jsonb, 'asset_non_current', false, '2000', 510),
  ('LA', 'default', '2910', 'Intangible assets, cost', '{}'::jsonb, 'asset_non_current', false, '2900', 520),
  ('LA', 'default', '2991', 'Accumulated amortisation of intangibles', '{}'::jsonb, 'asset_non_current', false, '2900', 530),
  ('LA', 'default', '3000', 'Current liabilities', '{}'::jsonb, 'liability_current', false, null, 540),
  ('LA', 'default', '3100', 'Accounts and notes payable', '{}'::jsonb, 'liability_current', false, '3000', 550),
  ('LA', 'default', '3110', 'Accounts payable (suppliers)', '{}'::jsonb, 'liability_payable', true, '3100', 560),
  ('LA', 'default', '3120', 'Notes payable', '{}'::jsonb, 'liability_current', false, '3100', 570),
  ('LA', 'default', '3200', 'Advances received', '{}'::jsonb, 'liability_current', false, '3000', 580),
  ('LA', 'default', '3210', 'Advances received from customers', '{}'::jsonb, 'liability_current', false, '3200', 590),
  ('LA', 'default', '3300', 'Short-term loans and borrowings', '{}'::jsonb, 'liability_current', false, '3000', 600),
  ('LA', 'default', '3310', 'Short-term bank loans', '{}'::jsonb, 'liability_current', false, '3300', 610),
  ('LA', 'default', '3320', 'Other short-term borrowings', '{}'::jsonb, 'liability_current', false, '3300', 620),
  ('LA', 'default', '3330', 'Current portion of long-term debt', '{}'::jsonb, 'liability_current', false, '3300', 630),
  ('LA', 'default', '3400', 'Taxes payable', '{}'::jsonb, 'liability_current', false, '3000', 640),
  ('LA', 'default', '3410', 'Income tax payable', '{}'::jsonb, 'liability_current', false, '3400', 650),
  ('LA', 'default', '3420', 'Personal income tax payable', '{}'::jsonb, 'liability_current', false, '3400', 660),
  ('LA', 'default', '3430', 'VAT payable', '{}'::jsonb, 'liability_current', false, '3400', 670),
  ('LA', 'default', '3431', 'VAT charged on taxable sales', '{}'::jsonb, 'liability_current', false, '3430', 680),
  ('LA', 'default', '3432', 'VAT settlement with the budget (payable)', '{}'::jsonb, 'liability_current', true, '3430', 690),
  ('LA', 'default', '3433', 'VAT payable by the tax agent for a non-resident', '{}'::jsonb, 'liability_current', false, '3430', 700),
  ('LA', 'default', '3440', 'Excise tax payable', '{}'::jsonb, 'liability_current', false, '3400', 710),
  ('LA', 'default', '3450', 'Other taxes payable (sales)', '{}'::jsonb, 'liability_current', false, '3400', 720),
  ('LA', 'default', '3460', 'Other taxes payable', '{}'::jsonb, 'liability_current', false, '3400', 730),
  ('LA', 'default', '3500', 'Accrued liabilities', '{}'::jsonb, 'liability_current', false, '3000', 740),
  ('LA', 'default', '3510', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, '3500', 750),
  ('LA', 'default', '3520', 'Salaries payable', '{}'::jsonb, 'liability_current', false, '3500', 760),
  ('LA', 'default', '3530', 'Social insurance contributions payable', '{}'::jsonb, 'liability_current', false, '3500', 770),
  ('LA', 'default', '3540', 'Dividends payable', '{}'::jsonb, 'liability_current', false, '3500', 780),
  ('LA', 'default', '3550', 'Accrued interest', '{}'::jsonb, 'liability_current', false, '3500', 790),
  ('LA', 'default', '3590', 'Other accrued liabilities', '{}'::jsonb, 'liability_current', false, '3500', 800),
  ('LA', 'default', '3600', 'Other current liabilities', '{}'::jsonb, 'liability_current', false, '3000', 810),
  ('LA', 'default', '3690', 'Other current liabilities, miscellaneous', '{}'::jsonb, 'liability_current', false, '3600', 820),
  ('LA', 'default', '3699', 'Suspense account', '{}'::jsonb, 'liability_current', false, '3600', 830),
  ('LA', 'default', '3700', 'Provisions', '{}'::jsonb, 'liability_current', false, '3000', 840),
  ('LA', 'default', '3710', 'Provision for unused leave', '{}'::jsonb, 'liability_current', false, '3700', 850),
  ('LA', 'default', '3790', 'Other provisions', '{}'::jsonb, 'liability_current', false, '3700', 860),
  ('LA', 'default', '4000', 'Non-current liabilities', '{}'::jsonb, 'liability_non_current', false, null, 870),
  ('LA', 'default', '4100', 'Long-term debt', '{}'::jsonb, 'liability_non_current', false, '4000', 880),
  ('LA', 'default', '4110', 'Bonds payable', '{}'::jsonb, 'liability_non_current', false, '4100', 890),
  ('LA', 'default', '4120', 'Bank loans', '{}'::jsonb, 'liability_non_current', false, '4100', 900),
  ('LA', 'default', '4130', 'Other loans', '{}'::jsonb, 'liability_non_current', false, '4100', 910),
  ('LA', 'default', '4140', 'Notes payable, long-term', '{}'::jsonb, 'liability_non_current', false, '4100', 920),
  ('LA', 'default', '4150', 'Finance lease obligations', '{}'::jsonb, 'liability_non_current', false, '4100', 930),
  ('LA', 'default', '4160', 'Other long-term liabilities', '{}'::jsonb, 'liability_non_current', false, '4100', 940),
  ('LA', 'default', '4191', 'Unamortised bond discount (premium)', '{}'::jsonb, 'liability_non_current', false, '4100', 950),
  ('LA', 'default', '5000', 'Equity', '{}'::jsonb, 'equity', false, null, 960),
  ('LA', 'default', '5100', 'Share capital', '{}'::jsonb, 'equity', false, '5000', 970),
  ('LA', 'default', '5110', 'Ordinary shares', '{}'::jsonb, 'equity', false, '5100', 980),
  ('LA', 'default', '5120', 'Preference shares', '{}'::jsonb, 'equity', false, '5100', 990),
  ('LA', 'default', '5130', 'Other share capital (participants'' interests)', '{}'::jsonb, 'equity', false, '5100', 1000),
  ('LA', 'default', '5191', 'Treasury shares', '{}'::jsonb, 'equity', false, '5100', 1010),
  ('LA', 'default', '5200', 'Additional paid-in capital', '{}'::jsonb, 'equity', false, '5000', 1020),
  ('LA', 'default', '5210', 'Share premium', '{}'::jsonb, 'equity', false, '5200', 1030),
  ('LA', 'default', '5300', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, '5000', 1040),
  ('LA', 'default', '5400', 'Reserve capital', '{}'::jsonb, 'equity', false, '5000', 1050),
  ('LA', 'default', '5999', 'Income summary (closing account)', '{}'::jsonb, 'equity', false, '5000', 1060),
  ('LA', 'default', '6000', 'Income', '{}'::jsonb, 'income', false, null, 1070),
  ('LA', 'default', '6100', 'Revenue', '{}'::jsonb, 'income', false, '6000', 1080),
  ('LA', 'default', '6110', 'Revenue from goods, works and services', '{}'::jsonb, 'income', false, '6100', 1090),
  ('LA', 'default', '6120', 'Sales returns and discounts', '{}'::jsonb, 'income', false, '6100', 1100),
  ('LA', 'default', '6200', 'Other operating income', '{}'::jsonb, 'income_other', false, '6000', 1110),
  ('LA', 'default', '6210', 'Operating lease income', '{}'::jsonb, 'income_other', false, '6200', 1120),
  ('LA', 'default', '6290', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, '6200', 1130),
  ('LA', 'default', '7000', 'Operating expenses', '{}'::jsonb, 'expense', false, null, 1140),
  ('LA', 'default', '7100', 'Cost of products and services sold', '{}'::jsonb, 'expense_direct_cost', false, '7000', 1150),
  ('LA', 'default', '7110', 'Direct materials', '{}'::jsonb, 'expense_direct_cost', false, '7100', 1160),
  ('LA', 'default', '7130', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, '7100', 1170),
  ('LA', 'default', '7150', 'Depreciation, production', '{}'::jsonb, 'expense_direct_cost', false, '7100', 1180),
  ('LA', 'default', '7200', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, '7000', 1190),
  ('LA', 'default', '7210', 'Purchases of goods', '{}'::jsonb, 'expense_direct_cost', false, '7200', 1200),
  ('LA', 'default', '7290', 'Inventory adjustments', '{}'::jsonb, 'expense_direct_cost', false, '7200', 1210),
  ('LA', 'default', '7500', 'Selling expenses', '{}'::jsonb, 'expense', false, '7000', 1220),
  ('LA', 'default', '7510', 'Advertising and promotion', '{}'::jsonb, 'expense', false, '7500', 1230),
  ('LA', 'default', '7520', 'Transport and delivery to customers', '{}'::jsonb, 'expense', false, '7500', 1240),
  ('LA', 'default', '7530', 'Selling staff costs', '{}'::jsonb, 'expense', false, '7500', 1250),
  ('LA', 'default', '7550', 'Bad debts', '{}'::jsonb, 'expense', false, '7500', 1260),
  ('LA', 'default', '7560', 'Warranty costs', '{}'::jsonb, 'expense', false, '7500', 1270),
  ('LA', 'default', '7580', 'Depreciation, selling', '{}'::jsonb, 'expense', false, '7500', 1280),
  ('LA', 'default', '7590', 'Sales bonus costs', '{}'::jsonb, 'expense', false, '7500', 1290),
  ('LA', 'default', '7600', 'Other operating expenses', '{}'::jsonb, 'expense', false, '7000', 1300),
  ('LA', 'default', '7610', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, '7600', 1310),
  ('LA', 'default', '7690', 'Rounding differences', '{}'::jsonb, 'expense', false, '7600', 1320),
  ('LA', 'default', '8000', 'General and administrative expenses', '{}'::jsonb, 'expense', false, null, 1330),
  ('LA', 'default', '8110', 'Administrative staff costs', '{}'::jsonb, 'expense', false, '8000', 1340),
  ('LA', 'default', '8120', 'Rent', '{}'::jsonb, 'expense', false, '8000', 1350),
  ('LA', 'default', '8130', 'Utilities', '{}'::jsonb, 'expense', false, '8000', 1360),
  ('LA', 'default', '8140', 'Telecommunications', '{}'::jsonb, 'expense', false, '8000', 1370),
  ('LA', 'default', '8150', 'Outsourced services', '{}'::jsonb, 'expense', false, '8000', 1380),
  ('LA', 'default', '8210', 'Business travel', '{}'::jsonb, 'expense', false, '8000', 1390),
  ('LA', 'default', '8310', 'Taxes other than income tax', '{}'::jsonb, 'expense', false, '8000', 1400),
  ('LA', 'default', '8470', 'Depreciation of property, plant and equipment', '{}'::jsonb, 'expense', false, '8000', 1410),
  ('LA', 'default', '8480', 'Amortisation of intangibles', '{}'::jsonb, 'expense', false, '8000', 1420),
  ('LA', 'default', '8490', 'Other administrative expenses', '{}'::jsonb, 'expense', false, '8000', 1430),
  ('LA', 'default', '9100', 'Non-operating income', '{}'::jsonb, 'income_other', false, null, 1440),
  ('LA', 'default', '9190', 'Other non-operating income', '{}'::jsonb, 'income_other', false, '9100', 1450),
  ('LA', 'default', '9500', 'Non-operating expenses', '{}'::jsonb, 'expense', false, null, 1460),
  ('LA', 'default', '9590', 'Other non-operating expenses', '{}'::jsonb, 'expense', false, '9500', 1470),
  ('LA', 'default', '9600', 'Income tax expense', '{}'::jsonb, 'expense', false, null, 1480),
  ('LA', 'default', '9610', 'Current income tax', '{}'::jsonb, 'expense', false, '9600', 1490)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('LA', 'BNK', 'Bank journal', '{}'::jsonb, 'bank', 30),
  ('LA', 'CSH', 'Cash journal', '{}'::jsonb, 'cash', 40),
  ('LA', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('LA', 'OPN', 'Opening balances journal', '{}'::jsonb, 'opening', 60),
  ('LA', 'PUR', 'Purchase journal', '{}'::jsonb, 'purchase', 20),
  ('LA', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('LA', 'LA-P-10', 'VAT 10% — standard rate (purchase)', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, articles 22 to 24 (as summarised by DFDL): input tax related to goods and services used in production, business operations or taxable supplies is deductible on a proper invoice; it must be claimed within three months of the date incurred (article 23(3); PwC). Not deductible: non-business and personal expenses, utilities not used in the main business, expenses without a proper invoice, personal computers, tablets and mobile phones (article 24).', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-P-10-NR', 'VAT 10% — services from a supplier abroad, withheld by the payer (purchase)', '{}'::jsonb, 'VAT on services of a person abroad is withheld by the payer and paid to the treasury; the right to deduct arises once it is paid', 'percent', 10, 'purchase', 'foreign_services_received', date '2024-03-19', null, 'PwC, value added tax: a domestic user of services must withhold 10% VAT on the fees paid to an overseas service provider; DFDL (article 30): a VAT-registered person files by the 15th of the following month, one who is not in the VAT system within 15 days of payment. The credit after payment is the payer''s to claim; the pack posts the tax to a waiting account.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-S-10', 'VAT 10% — standard rate (sale)', '{}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, article 17 (as summarised by DFDL): 10% on supplies of goods and services within Lao PDR and on imports. The rate was 7% from January 2022 and was restored to 10% by Ordinance of the President No. 003/PDT of 19 March 2024 (Tilleke & Gibbins); PwC (reviewed February 2026) gives 10%. The Tilleke report adds that the authorities said the restored rate would be enforced later, on publication in the Official Gazette: that publication was not checked. Exports of natural resources that are not finished goods are taxed at 10%, not zero (PwC).', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-S-EXEMPT-AGRI', 'VAT exempt — unprocessed agricultural products, seeds, fertilisers and agricultural equipment (sale)', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, article 12 (as summarised by DFDL): agricultural equipment and machinery are exempt; PwC adds unprocessed agricultural products, seeds and fertilisers. The full list was not read from the Lao text; add the item a case needs with its article.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-S-EXEMPT-BANKING', 'VAT exempt — interest on deposits and loans, financial transactions of commercial banks (sale)', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, article 12 (as summarised by DFDL): deposit and lending interest and the financial transactions of commercial banks are exempt (PwC: certain bank and financial institution services).', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-S-EXEMPT-EDUCATION', 'VAT exempt — education goods and services (sale)', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2024-03-19', null, 'PwC, value added tax: educational goods and services are exempt; article 12 as summarised by DFDL lists textbooks. The exact scope (which services) was not read from the Lao text.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-S-EXEMPT-HEALTH', 'VAT exempt — medical goods and services, health insurance (sale)', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, article 12 (as summarised by DFDL): health and life insurance, animal medicines and medical tools and equipment for hospitals and health centres are exempt; PwC: certain medical goods and services. The exact scope was not read from the Lao text.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null),
  ('LA', 'LA-S-ZERO-EXPORT', 'VAT 0% — export of goods (sale)', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, article 17 (as summarised by DFDL and the Lao Trade Portal): 0% on the export of goods. PwC: exports of natural resources that are not finished goods stay at 10%; the Law has no concept of exported services, which are taxed at 10%. The customs proof the Law asks for was not read.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-articles', null, null, null, null)
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
    ('LA-P-10', 'invoice', 'base', 100, null, 'INPUT', array['INPUT']::text[], 100, 'LA-VAT', 10),
    ('LA-P-10', 'invoice', 'tax', 100, '1541', 'INPUT', array['INPUT']::text[], 100, 'LA-VAT', 20),
    ('LA-P-10', 'credit_note', 'base', 100, null, 'INPUT', array['INPUT']::text[], -100, 'LA-VAT', 10),
    ('LA-P-10', 'credit_note', 'tax', 100, '1541', 'INPUT', array['INPUT']::text[], -100, 'LA-VAT', 20),
    ('LA-P-10-NR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LA-P-10-NR', 'invoice', 'tax', 100, '1543', null, null, 100, null, 20),
    ('LA-P-10-NR', 'invoice', 'tax', -100, '3433', null, null, 100, null, 30),
    ('LA-P-10-NR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LA-P-10-NR', 'credit_note', 'tax', 100, '1543', null, null, 100, null, 20),
    ('LA-P-10-NR', 'credit_note', 'tax', -100, '3433', null, null, 100, null, 30),
    ('LA-S-10', 'invoice', 'base', 100, null, 'TAXABLE', array['TAXABLE']::text[], 100, 'LA-VAT', 10),
    ('LA-S-10', 'invoice', 'tax', 100, '3431', 'TAXABLE', array['TAXABLE']::text[], 100, 'LA-VAT', 20),
    ('LA-S-10', 'credit_note', 'base', 100, null, 'TAXABLE', array['TAXABLE']::text[], -100, 'LA-VAT', 10),
    ('LA-S-10', 'credit_note', 'tax', 100, '3431', 'TAXABLE', array['TAXABLE']::text[], -100, 'LA-VAT', 20),
    ('LA-S-EXEMPT-AGRI', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-AGRI', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-BANKING', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-BANKING', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-EDUCATION', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-EDUCATION', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-HEALTH', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'LA-VAT', 10),
    ('LA-S-EXEMPT-HEALTH', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'LA-VAT', 10),
    ('LA-S-ZERO-EXPORT', 'invoice', 'base', 100, null, 'ZERO', array['ZERO']::text[], 100, 'LA-VAT', 10),
    ('LA-S-ZERO-EXPORT', 'credit_note', 'base', 100, null, 'ZERO', array['ZERO']::text[], -100, 'LA-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'LA' and t.code = v.tax_code
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
  ('LA', 'LA-VAT', 'Value added tax return (monthly)', array['month']::declaration_period[], 'month'::declaration_period, date '2024-03-19', null, 'Law on Value Added Tax No. 48/NA of 2018, article 30(1) (as summarised by DFDL): individuals and businesses carrying on business in Lao PDR file the return by the 15th day of the following month; import VAT is paid at importation (article 30(2)). The official return form and the filing channel were not found in open sources, so the boxes are named after the operations of the Law (TAXABLE, ZERO, EXEMPT, TURNOVER, INPUT, CREDIT, PAYABLE, EXCESS), not after the lines of the form. One source (PwC) records that the monthly excise deadline moved from the 15th to the 20th; whether the VAT deadline moved too was not confirmed. See README.md.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Law on Value Added Tax No. 48/NA of 2018, article 30(1) (as summarised by DFDL): the return is filed by the 15th day of the month following the period. Not confirmed against the Lao text or a current Tax Department notice.', 'vat-law-articles', null)
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
  ('LA', 'LA-VAT', 'TAXABLE', 'base', 'Taxable sales at 10% — taxable value', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, article 17 (10%).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'TAXABLE', 'tax', 'Taxable sales at 10% — VAT charged', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, article 17 (10%).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'ZERO', 'base', 'Zero-rated sales (export of goods)', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, article 17 (0% on exports of goods).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'EXEMPT', 'base', 'Operations not subject to VAT (article 106)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, article 12 (exempt operations).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'TURNOVER', 'total', 'Total sales of the period', '{}'::jsonb, 50, null, array['TAXABLE:base', 'ZERO', 'EXEMPT']::text[], '{}'::text[], null, null, false, false, null, 'Total of the operations of the period; the Law does not name this line.', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'INPUT', 'base', 'Purchased goods, work and services — value excluding VAT', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, articles 22 to 24 (input tax).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'INPUT', 'tax', 'Purchased goods, work and services — input VAT', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, articles 22 to 24 (input tax).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'CREDIT', 'total', 'Creditable tax for the period', '{}'::jsonb, 80, null, array['INPUT:tax']::text[], '{}'::text[], null, null, false, false, null, 'Law on Value Added Tax No. 48/NA of 2018, articles 22 to 24 (input tax creditable in the period).', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'PAYABLE', 'total', 'VAT payable to the state budget', '{}'::jsonb, 90, null, array['TAXABLE:tax']::text[], array['CREDIT']::text[], null, null, true, false, null, 'Law on Value Added Tax No. 48/NA of 2018, article 30: output tax less creditable input tax is paid with the return.', 'vat-law-articles'),
  ('LA', 'LA-VAT', 'EXCESS', 'total', 'Excess of deductible VAT (refundable)', '{}'::jsonb, 100, null, array['CREDIT']::text[], array['TAXABLE:tax']::text[], null, null, true, false, null, 'Law on Value Added Tax No. 48/NA of 2018, article 28 (as summarised by DFDL): a refund is requested monthly and within three months of the tax incurred; how it works in practice is unclear.', 'vat-law-articles')
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
   source_key, result_in_progress, result_in_progress_name, result_in_progress_name_i18n)
values
  ('LA-BS', 'LA', 'default', 'Statement of financial position (balance sheet)', 'balance_sheet', 'LFRS (IFRS for SMEs)', date '2014-07-01', null, 'IFRS for SMEs, section 4 (statement of financial position) and section 5 (statement of comprehensive income), on which the Lao financial reporting standards for non-public interest entities rest (Law on Accounting, amended 2013). The lines are the items those sections list, grouped over this pack''s own chart; the official Lao forms were not read. See README.md.', 'ifrs-sme', 'combined', 'Result of the current financial year', '{}'::jsonb),
  ('LA-IS', 'LA', 'default', 'Statement of comprehensive income (profit and loss)', 'income_statement', 'LFRS (IFRS for SMEs)', date '2014-07-01', null, 'IFRS for SMEs, section 4 (statement of financial position) and section 5 (statement of comprehensive income), on which the Lao financial reporting standards for non-public interest entities rest (Law on Accounting, amended 2013). The lines are the items those sections list, grouped over this pack''s own chart; the official Lao forms were not read. See README.md.', 'ifrs-sme', null, null, '{}'::jsonb)
on conflict (code) do update set
  country         = excluded.country,
  chart_code      = excluded.chart_code,
  name            = excluded.name,
  kind            = excluded.kind,
  framework       = excluded.framework,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  result_in_progress           = excluded.result_in_progress,
  result_in_progress_name      = excluded.result_in_progress_name,
  result_in_progress_name_i18n = excluded.result_in_progress_name_i18n;

insert into statement_line_templates
  (statement_code, code, parent_code, name, name_i18n, sequence, sign, is_total,
   plus_lines, minus_lines, xbrl_element, legal_reference, source_key)
values
  ('LA-BS', 'AS-CASH', null, 'Cash', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-STINV', null, 'Short-term investments', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-REC', null, 'Accounts and notes receivable', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-OREC', null, 'Other receivables, advances and recoverable VAT', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-INV', null, 'Inventories', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-OCA', null, 'Prepaid expenses and other current assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-CA-TOTAL', null, 'Total current assets', '{}'::jsonb, 70, 1, true, array['AS-CASH', 'AS-STINV', 'AS-REC', 'AS-OREC', 'AS-INV', 'AS-OCA']::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-PPE', null, 'Property, plant and equipment, net', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-ONCA', null, 'Other non-current assets', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-INTANG', null, 'Intangible assets, net', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-NCA-TOTAL', null, 'Total non-current assets', '{}'::jsonb, 110, 1, true, array['AS-PPE', 'AS-ONCA', 'AS-INTANG']::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'AS-TOTAL', null, 'Total assets', '{}'::jsonb, 120, 1, true, array['AS-CA-TOTAL', 'AS-NCA-TOTAL']::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQ-SHARE', null, 'Share capital', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQ-APIC', null, 'Additional paid-in capital', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQ-RETAINED', null, 'Retained earnings', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQ-RESERVE', null, 'Reserve capital', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQ-SUMMARY', null, 'Income summary (closing account)', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQ-TOTAL', null, 'Total equity', '{}'::jsonb, 180, 1, true, array['EQ-SHARE', 'EQ-APIC', 'EQ-RETAINED', 'EQ-RESERVE', 'EQ-SUMMARY']::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-PAY', null, 'Accounts and notes payable', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-ADV', null, 'Advances received', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-DEBT', null, 'Short-term loans and borrowings', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-TAX', null, 'Taxes payable', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-ACCR', null, 'Accrued liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-OTHER', null, 'Other current liabilities', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-PROV', null, 'Provisions', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-CL-TOTAL', null, 'Total current liabilities', '{}'::jsonb, 260, 1, true, array['LI-PAY', 'LI-ADV', 'LI-DEBT', 'LI-TAX', 'LI-ACCR', 'LI-OTHER', 'LI-PROV']::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-LT', null, 'Non-current liabilities', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'LI-NCL-TOTAL', null, 'Total non-current liabilities', '{}'::jsonb, 280, 1, true, array['LI-LT']::text[], '{}'::text[], null, null, null),
  ('LA-BS', 'EQLI-TOTAL', null, 'Total equity and liabilities', '{}'::jsonb, 290, 1, true, array['EQ-TOTAL', 'LI-CL-TOTAL', 'LI-NCL-TOTAL']::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-REV', null, 'Revenue, net of returns and discounts', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-COGS', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['IS-REV']::text[], array['IS-COGS']::text[], null, null, null),
  ('LA-IS', 'IS-SELL', null, 'Selling expenses', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-ADMIN', null, 'General and administrative expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-OPINC', null, 'Other operating income', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-OPEXP', null, 'Other operating expenses', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-OPRESULT', null, 'Operating result', '{}'::jsonb, 80, 1, true, array['IS-GROSS', 'IS-OPINC']::text[], array['IS-SELL', 'IS-ADMIN', 'IS-OPEXP']::text[], null, null, null),
  ('LA-IS', 'IS-NONINC', null, 'Non-operating income', '{}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-NONEXP', null, 'Non-operating expenses', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-PRETAX', null, 'Profit before tax', '{}'::jsonb, 110, 1, true, array['IS-OPRESULT', 'IS-NONINC']::text[], array['IS-NONEXP']::text[], null, null, null),
  ('LA-IS', 'IS-TAX', null, 'Income tax expense', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LA-IS', 'IS-NET', null, 'Net profit', '{}'::jsonb, 130, 1, true, array['IS-PRETAX']::text[], array['IS-TAX']::text[], null, null, null)
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

delete from statement_line_rules r
 where r.statement_code in ('LA-BS', 'LA-IS')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('LA-BS', 'AS-CASH', 10),
            ('LA-BS', 'AS-STINV', 10),
            ('LA-BS', 'AS-REC', 10),
            ('LA-BS', 'AS-OREC', 10),
            ('LA-BS', 'AS-INV', 10),
            ('LA-BS', 'AS-OCA', 10),
            ('LA-BS', 'AS-PPE', 10),
            ('LA-BS', 'AS-ONCA', 10),
            ('LA-BS', 'AS-INTANG', 10),
            ('LA-BS', 'EQ-SHARE', 10),
            ('LA-BS', 'EQ-APIC', 10),
            ('LA-BS', 'EQ-RETAINED', 10),
            ('LA-BS', 'EQ-RESERVE', 10),
            ('LA-BS', 'EQ-SUMMARY', 10),
            ('LA-BS', 'LI-PAY', 10),
            ('LA-BS', 'LI-ADV', 10),
            ('LA-BS', 'LI-DEBT', 10),
            ('LA-BS', 'LI-TAX', 10),
            ('LA-BS', 'LI-ACCR', 10),
            ('LA-BS', 'LI-OTHER', 10),
            ('LA-BS', 'LI-PROV', 10),
            ('LA-BS', 'LI-LT', 10),
            ('LA-IS', 'IS-REV', 10),
            ('LA-IS', 'IS-COGS', 10),
            ('LA-IS', 'IS-SELL', 10),
            ('LA-IS', 'IS-ADMIN', 10),
            ('LA-IS', 'IS-OPINC', 10),
            ('LA-IS', 'IS-OPEXP', 10),
            ('LA-IS', 'IS-NONINC', 10),
            ('LA-IS', 'IS-NONEXP', 10),
            ('LA-IS', 'IS-TAX', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('LA-BS', 'AS-CASH', 10, 'code_range', '1100', '1299', null, 'any'),
    ('LA-BS', 'AS-STINV', 10, 'code_range', '1300', '1399', null, 'any'),
    ('LA-BS', 'AS-REC', 10, 'code_range', '1400', '1499', null, 'any'),
    ('LA-BS', 'AS-OREC', 10, 'code_range', '1500', '1599', null, 'any'),
    ('LA-BS', 'AS-INV', 10, 'code_range', '1600', '1699', null, 'any'),
    ('LA-BS', 'AS-OCA', 10, 'code_range', '1700', '1799', null, 'any'),
    ('LA-BS', 'AS-PPE', 10, 'code_range', '2100', '2199', null, 'any'),
    ('LA-BS', 'AS-ONCA', 10, 'code_range', '2200', '2899', null, 'any'),
    ('LA-BS', 'AS-INTANG', 10, 'code_range', '2900', '2999', null, 'any'),
    ('LA-BS', 'EQ-SHARE', 10, 'code_range', '5100', '5199', null, 'any'),
    ('LA-BS', 'EQ-APIC', 10, 'code_range', '5200', '5299', null, 'any'),
    ('LA-BS', 'EQ-RETAINED', 10, 'code_range', '5300', '5399', null, 'any'),
    ('LA-BS', 'EQ-RESERVE', 10, 'code_range', '5400', '5499', null, 'any'),
    ('LA-BS', 'EQ-SUMMARY', 10, 'code_range', '5900', '5999', null, 'any'),
    ('LA-BS', 'LI-PAY', 10, 'code_range', '3100', '3199', null, 'any'),
    ('LA-BS', 'LI-ADV', 10, 'code_range', '3200', '3299', null, 'any'),
    ('LA-BS', 'LI-DEBT', 10, 'code_range', '3300', '3399', null, 'any'),
    ('LA-BS', 'LI-TAX', 10, 'code_range', '3400', '3499', null, 'any'),
    ('LA-BS', 'LI-ACCR', 10, 'code_range', '3500', '3599', null, 'any'),
    ('LA-BS', 'LI-OTHER', 10, 'code_range', '3600', '3699', null, 'any'),
    ('LA-BS', 'LI-PROV', 10, 'code_range', '3700', '3799', null, 'any'),
    ('LA-BS', 'LI-LT', 10, 'code_range', '4000', '4999', null, 'any'),
    ('LA-IS', 'IS-REV', 10, 'code_range', '6100', '6199', null, 'any'),
    ('LA-IS', 'IS-COGS', 10, 'code_range', '7100', '7299', null, 'any'),
    ('LA-IS', 'IS-SELL', 10, 'code_range', '7500', '7599', null, 'any'),
    ('LA-IS', 'IS-ADMIN', 10, 'code_range', '8000', '8999', null, 'any'),
    ('LA-IS', 'IS-OPINC', 10, 'code_range', '6200', '6299', null, 'any'),
    ('LA-IS', 'IS-OPEXP', 10, 'code_range', '7600', '7699', null, 'any'),
    ('LA-IS', 'IS-NONINC', 10, 'code_range', '9100', '9199', null, 'any'),
    ('LA-IS', 'IS-NONEXP', 10, 'code_range', '9500', '9599', null, 'any'),
    ('LA-IS', 'IS-TAX', 10, 'code_range', '9600', '9699', null, 'any')
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
  ('LA', 'Lao PDR', '{}'::jsonb, array['en']::text[], 'LAK', '1410', '3110', '3699', '7690', '5300', '6110', '7210', '1210', '1110', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '6290', '7610', null, null, null, null, '3432', '1542', null, 'month'::declaration_period)
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
  number_format                 = '{CODE}-{NNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Law on Value Added Tax No. 48/NA of 2018, article 27, as summarised by DFDL: invoices are issued in accordance with the regulations on invoices. The regulation on the form and numbering of the VAT invoice was not read; the sequential numbering here is an example, not the official series.',
  numbering_source_key          = 'vat-law-articles',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = 'The time of supply under the Law on Value Added Tax was not read from the Lao text; no open English source states it. Delivery date is the pack''s working assumption and is listed among the gaps in README.md.',
  tax_point_source_key          = 'vat-law-articles',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = 'A posted entry is not erased: a return or a correction is made with a credit note and a counter entry. The Law on VAT (article 28 as summarised by DFDL) ties refunds to invoices and bookkeeping under the Law on Accounting.',
  posted_edit_policy_source_key = 'vat-law-articles',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'The Law on VAT, article 27 (as summarised by DFDL), refers to invoices under the invoice regulations. No Lao electronic invoicing exchange modelled on EN 16931 was found in open sources (PwC mentions an eInvoice duty only for overseas digital suppliers), so profile, party scheme and VAT scheme stay empty. See README.md.',
  einvoice_source_key           = 'vat-law-articles',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'iban',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'LA';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('LA', 'exempt', 'exempt', 'Exempt from value added tax', '{}'::jsonb, 10, date '1970-01-01', null, 'Law on Value Added Tax No. 48/NA of 2018, article 12 (as summarised by DFDL): the listed operations are exempt. The wording to print on an exempt invoice was not found; this text is the pack''s.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
