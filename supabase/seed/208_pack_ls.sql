-- Ekwo OS — Lesotho: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ls at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build ls`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Act, 2001 (Act No. 9 of 2001), as published by Revenue Services Lesotho — sections 1, 6, 7, 9, 10, 11, 12, 17, 19, 20, 23, 24 and 27, 37 and Schedule II. This is the 2001 text; the amending Act No. 6 of 2003 listed beside it was not read (Revenue Services Lesotho (the Act is also published on LesLII))
--     https://www.rsl.org.ls/sites/default/files/2026-09/VAT%20ACT%20-%202001.pdf
--   Value Added Tax (Amendment) Regulations, 2020 (Legal Notice No. 18 of 2020, Government Gazette Vol. 65 No. 17, 20 March 2020) — reg. 6(1)(b) electricity 9 % and (d) telecommunications 15 % from 1 April 2020 (Revenue Services Lesotho / Government Printer)
--     https://www.rsl.org.ls/sites/default/files/2026-09/VAT%20REGULATIONS%20NO.18%20OF%202020.pdf
--   Value Added Tax (Amendment) Regulations, 2021 (Legal Notice No. 30 of 2021, Government Gazette Vol. 66 No. 25, 12 March 2021) — reg. 6(1)(b) electricity raised to 10 % from 1 April 2021 (Revenue Services Lesotho / Government Printer)
--     https://www.rsl.org.ls/sites/default/files/2026-09/VALUE%20ADDED%20TAX%20%28AMENDMENT%29%20REGULATIONS%20LN.30%20OF%202021_0.pdf
--   Tax Rates — VAT: 0 % exports and basic commodities, 10 % electricity, 15 % telecommunications, 15 % other goods and services (Revenue Services Lesotho)
--     https://www.rsl.org.ls/tax-rates
--   Value Added Tax (VAT) — registration: threshold of M850,000 per annum, and a return filed every month (Revenue Services Lesotho)
--     https://www.rsl.org.ls/node/106
--   Frequently asked questions — registration threshold of M850,000 per annum; eTax and e-Payments services (Revenue Services Lesotho)
--     https://www.rsl.org.ls/faqs
--   RSL eTax — the online filing portal for returns (Revenue Services Lesotho)
--     https://efiling.rsl.org.ls/rsl-client/login
--   Value Added Tax (E-Invoicing) Regulations, 2026 (Legal Notice No. 25 of 2026) — in operation on 1 April 2026; invoices issued from an accredited Electronic Billing System and registered on the Invoice Data Management System (Revenue Services Lesotho / Government Printer)
--     https://www.rsl.org.ls/sites/default/files/2026-09/VAT%20-%20E-Invoicing%20Regulations%20No.25%20of%202026%20%283%29.pdf
--   Companies Act, 2011 (Act No. 18 of 2011), s. 95 — accounts follow the financial reporting framework prescribed by the Lesotho Institute of Accountants, as summarised in the IFRS Foundation's jurisdiction profile for Lesotho (IFRS Foundation)
--     https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/lesotho/
--   IFRS for SMEs Accounting Standard — Section 4, Statement of Financial Position, and Section 5, Statement of Comprehensive Income and Income Statement (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   UNCL5305 — duty or tax or fee category code (OpenPEPPOL — the list itself is published by UN/CEFACT)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('LS', 'Lesotho', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, 'a3303a527eb88cd23af186bc9d17d253b58fac118751e7aa9715ec7153d50677', '[{"key":"vat-act","title":"Value Added Tax Act, 2001 (Act No. 9 of 2001), as published by Revenue Services Lesotho — sections 1, 6, 7, 9, 10, 11, 12, 17, 19, 20, 23, 24 and 27, 37 and Schedule II. This is the 2001 text; the amending Act No. 6 of 2003 listed beside it was not read","publisher":"Revenue Services Lesotho (the Act is also published on LesLII)","url":"https://www.rsl.org.ls/sites/default/files/2026-09/VAT%20ACT%20-%202001.pdf","consulted_on":"2026-10-19","kind":"law"},{"key":"vat-regs-2020","title":"Value Added Tax (Amendment) Regulations, 2020 (Legal Notice No. 18 of 2020, Government Gazette Vol. 65 No. 17, 20 March 2020) — reg. 6(1)(b) electricity 9 % and (d) telecommunications 15 % from 1 April 2020","publisher":"Revenue Services Lesotho / Government Printer","url":"https://www.rsl.org.ls/sites/default/files/2026-09/VAT%20REGULATIONS%20NO.18%20OF%202020.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"vat-regs-2021","title":"Value Added Tax (Amendment) Regulations, 2021 (Legal Notice No. 30 of 2021, Government Gazette Vol. 66 No. 25, 12 March 2021) — reg. 6(1)(b) electricity raised to 10 % from 1 April 2021","publisher":"Revenue Services Lesotho / Government Printer","url":"https://www.rsl.org.ls/sites/default/files/2026-09/VALUE%20ADDED%20TAX%20%28AMENDMENT%29%20REGULATIONS%20LN.30%20OF%202021_0.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"rsl-tax-rates","title":"Tax Rates — VAT: 0 % exports and basic commodities, 10 % electricity, 15 % telecommunications, 15 % other goods and services","publisher":"Revenue Services Lesotho","url":"https://www.rsl.org.ls/tax-rates","consulted_on":"2026-10-19","kind":"guidance"},{"key":"vat-registration","title":"Value Added Tax (VAT) — registration: threshold of M850,000 per annum, and a return filed every month","publisher":"Revenue Services Lesotho","url":"https://www.rsl.org.ls/node/106","consulted_on":"2026-10-19","kind":"guidance"},{"key":"rsl-faqs","title":"Frequently asked questions — registration threshold of M850,000 per annum; eTax and e-Payments services","publisher":"Revenue Services Lesotho","url":"https://www.rsl.org.ls/faqs","consulted_on":"2026-10-19","kind":"guidance"},{"key":"etax","title":"RSL eTax — the online filing portal for returns","publisher":"Revenue Services Lesotho","url":"https://efiling.rsl.org.ls/rsl-client/login","consulted_on":"2026-10-19","kind":"portal"},{"key":"einvoicing-regs","title":"Value Added Tax (E-Invoicing) Regulations, 2026 (Legal Notice No. 25 of 2026) — in operation on 1 April 2026; invoices issued from an accredited Electronic Billing System and registered on the Invoice Data Management System","publisher":"Revenue Services Lesotho / Government Printer","url":"https://www.rsl.org.ls/sites/default/files/2026-09/VAT%20-%20E-Invoicing%20Regulations%20No.25%20of%202026%20%283%29.pdf","consulted_on":"2026-10-19","kind":"regulation"},{"key":"companies-act","title":"Companies Act, 2011 (Act No. 18 of 2011), s. 95 — accounts follow the financial reporting framework prescribed by the Lesotho Institute of Accountants, as summarised in the IFRS Foundation''s jurisdiction profile for Lesotho","publisher":"IFRS Foundation","url":"https://www.ifrs.org/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction/lesotho/","consulted_on":"2026-10-19","kind":"guidance"},{"key":"ifrs-for-smes","title":"IFRS for SMEs Accounting Standard — Section 4, Statement of Financial Position, and Section 5, Statement of Comprehensive Income and Income Statement","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-19","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — duty or tax or fee category code","publisher":"OpenPEPPOL — the list itself is published by UN/CEFACT","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-10-19","kind":"standard"}]'::jsonb)
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
  ('LS', 'default', 'Lesotho reference chart of accounts', '{}'::jsonb, true, 'companies', array['LS-IFRSSME-PL', 'LS-IFRSSME-SFP']::text[], null, 'There is no chart of accounts prescribed by Lesotho law that this pack could read. Companies Act, 2011 (Act No. 18 of 2011), s. 95 requires a company''s accounts to follow the financial reporting framework the Lesotho Institute of Accountants prescribes; the Institute has adopted the IFRS Standards and the IFRS for SMEs Accounting Standard, and a company other than a financial institution may use either (IFRS Foundation jurisdiction profile for Lesotho). This chart is original — four digits, blocked so that each range reaches one line item of Section 4.2 (statement of financial position) and Section 5.5 (statement of comprehensive income) of the IFRS for SMEs Accounting Standard; a company that files nothing keeps the same books and uses the same statements as management accounts. A financial institution applies full IFRS and needs more than this chart.', 'companies-act')
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
  ('LS', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('LS', 'default', '1010', 'Business current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('LS', 'default', '1020', 'Business savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('LS', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('LS', 'default', '1040', 'Card and payment gateway clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('LS', 'default', '1050', 'Call and fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('LS', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('LS', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('LS', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('LS', 'default', '1110', 'Amounts receivable from related parties', '{}'::jsonb, 'asset_current', false, null, 100),
  ('LS', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('LS', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('LS', 'default', '1140', 'Employee and director loans and advances', '{}'::jsonb, 'asset_current', false, null, 130),
  ('LS', 'default', '1150', 'VAT input — VAT paid on purchases and imports', '{}'::jsonb, 'asset_current', false, null, 140),
  ('LS', 'default', '1152', 'VAT input on purchases accounted for on the payments basis — awaiting payment', '{}'::jsonb, 'asset_current', false, null, 150),
  ('LS', 'default', '1155', 'VAT refund due from RSL — net of a submitted VAT return', '{}'::jsonb, 'asset_current', true, null, 160),
  ('LS', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 170),
  ('LS', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 180),
  ('LS', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 190),
  ('LS', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 200),
  ('LS', 'default', '1300', 'Call and fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 210),
  ('LS', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 220),
  ('LS', 'default', '1320', 'Loans to related parties — current', '{}'::jsonb, 'asset_current', false, null, 230),
  ('LS', 'default', '1350', 'Income tax refundable', '{}'::jsonb, 'asset_current', false, null, 240),
  ('LS', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('LS', 'default', '1410', 'Deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 260),
  ('LS', 'default', '1420', 'Payments on account to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 270),
  ('LS', 'default', '1600', 'Land', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('LS', 'default', '1610', 'Buildings', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('LS', 'default', '1611', 'Buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('LS', 'default', '1620', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('LS', 'default', '1621', 'Leasehold improvements — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('LS', 'default', '1630', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('LS', 'default', '1631', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('LS', 'default', '1640', 'Furniture and fittings', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('LS', 'default', '1641', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('LS', 'default', '1650', 'Computer equipment', '{}'::jsonb, 'asset_fixed', false, null, 370),
  ('LS', 'default', '1651', 'Computer equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('LS', 'default', '1660', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('LS', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('LS', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 410),
  ('LS', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 420),
  ('LS', 'default', '1680', 'Capital work in progress', '{}'::jsonb, 'asset_fixed', false, null, 430),
  ('LS', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('LS', 'default', '1750', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 450),
  ('LS', 'default', '1751', 'Goodwill — accumulated impairment', '{}'::jsonb, 'asset_fixed', false, null, 460),
  ('LS', 'default', '1760', 'Software and development costs', '{}'::jsonb, 'asset_fixed', false, null, 470),
  ('LS', 'default', '1761', 'Software and development costs — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 480),
  ('LS', 'default', '1770', 'Patents, trade marks and licences', '{}'::jsonb, 'asset_fixed', false, null, 490),
  ('LS', 'default', '1771', 'Patents, trade marks and licences — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 500),
  ('LS', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 510),
  ('LS', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 520),
  ('LS', 'default', '1820', 'Shares in unlisted entities', '{}'::jsonb, 'asset_non_current', false, null, 530),
  ('LS', 'default', '1830', 'Loans to related parties — non-current', '{}'::jsonb, 'asset_non_current', false, null, 540),
  ('LS', 'default', '1840', 'Security deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 550),
  ('LS', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 560),
  ('LS', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 570),
  ('LS', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 580),
  ('LS', 'default', '2020', 'Amounts payable to related parties', '{}'::jsonb, 'liability_current', false, null, 590),
  ('LS', 'default', '2030', 'Other creditors', '{}'::jsonb, 'liability_current', false, null, 600),
  ('LS', 'default', '2040', 'Customer deposits and contract liabilities', '{}'::jsonb, 'liability_current', false, null, 610),
  ('LS', 'default', '2050', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('LS', 'default', '2060', 'Statutory employee contributions payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('LS', 'default', '2070', 'Payroll levies payable', '{}'::jsonb, 'liability_current', false, null, 640),
  ('LS', 'default', '2080', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 650),
  ('LS', 'default', '2090', 'Withholding taxes payable to RSL', '{}'::jsonb, 'liability_current', false, null, 660),
  ('LS', 'default', '2100', 'VAT output — VAT charged on sales', '{}'::jsonb, 'liability_current', false, null, 670),
  ('LS', 'default', '2105', 'VAT output on sales accounted for on the payments basis — awaiting payment', '{}'::jsonb, 'liability_current', false, null, 680),
  ('LS', 'default', '2110', 'VAT payable to RSL — net of a submitted VAT return', '{}'::jsonb, 'liability_current', true, null, 690),
  ('LS', 'default', '2120', 'Pay-as-you-earn (PAYE) payable', '{}'::jsonb, 'liability_current', false, null, 700),
  ('LS', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 710),
  ('LS', 'default', '2210', 'Business credit card', '{}'::jsonb, 'liability_credit_card', false, null, 720),
  ('LS', 'default', '2220', 'Bank loans — current', '{}'::jsonb, 'liability_current', false, null, 730),
  ('LS', 'default', '2230', 'Lease liabilities — current', '{}'::jsonb, 'liability_current', false, null, 740),
  ('LS', 'default', '2240', 'Instalment sale and hire purchase liabilities — current', '{}'::jsonb, 'liability_current', false, null, 750),
  ('LS', 'default', '2300', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 760),
  ('LS', 'default', '2310', 'Income tax instalments payable', '{}'::jsonb, 'liability_current', false, null, 770),
  ('LS', 'default', '2350', 'Provision for leave pay', '{}'::jsonb, 'liability_current', false, null, 780),
  ('LS', 'default', '2370', 'Provision for warranties and other provisions — current', '{}'::jsonb, 'liability_current', false, null, 790),
  ('LS', 'default', '2400', 'Bank loans — non-current', '{}'::jsonb, 'liability_non_current', false, null, 800),
  ('LS', 'default', '2410', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 810),
  ('LS', 'default', '2420', 'Instalment sale and hire purchase liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 820),
  ('LS', 'default', '2430', 'Loans from shareholders and related parties — non-current', '{}'::jsonb, 'liability_non_current', false, null, 830),
  ('LS', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 840),
  ('LS', 'default', '2550', 'Provision for leave pay — non-current', '{}'::jsonb, 'liability_non_current', false, null, 850),
  ('LS', 'default', '2560', 'Provision for restoration and rehabilitation', '{}'::jsonb, 'liability_non_current', false, null, 860),
  ('LS', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 870),
  ('LS', 'default', '3000', 'Issued share capital — ordinary shares', '{}'::jsonb, 'equity', false, null, 880),
  ('LS', 'default', '3010', 'Issued share capital — preference shares', '{}'::jsonb, 'equity', false, null, 890),
  ('LS', 'default', '3020', 'Members'' contributions', '{}'::jsonb, 'equity', false, null, 900),
  ('LS', 'default', '3100', 'Revaluation reserve', '{}'::jsonb, 'equity', false, null, 910),
  ('LS', 'default', '3110', 'Other reserves', '{}'::jsonb, 'equity', false, null, 920),
  ('LS', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 930),
  ('LS', 'default', '3210', 'Dividends declared', '{}'::jsonb, 'equity_retained', false, null, 940),
  ('LS', 'default', '4000', 'Sales — goods', '{}'::jsonb, 'income', false, null, 950),
  ('LS', 'default', '4010', 'Sales — services', '{}'::jsonb, 'income', false, null, 960),
  ('LS', 'default', '4020', 'Sales — zero-rated goods and services', '{}'::jsonb, 'income', false, null, 970),
  ('LS', 'default', '4030', 'Sales — exports', '{}'::jsonb, 'income', false, null, 980),
  ('LS', 'default', '4040', 'Residential rental income', '{}'::jsonb, 'income', false, null, 990),
  ('LS', 'default', '4050', 'Retail takings', '{}'::jsonb, 'income', false, null, 1000),
  ('LS', 'default', '4080', 'Sales returns and allowances', '{}'::jsonb, 'income', false, null, 1010),
  ('LS', 'default', '4090', 'Settlement discount granted', '{}'::jsonb, 'income', false, null, 1020),
  ('LS', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 1030),
  ('LS', 'default', '4510', 'Commercial rental income', '{}'::jsonb, 'income_other', false, null, 1040),
  ('LS', 'default', '4520', 'Government grants and incentives', '{}'::jsonb, 'income_other', false, null, 1050),
  ('LS', 'default', '4530', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 1060),
  ('LS', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 1070),
  ('LS', 'default', '4750', 'Gain on disposal of non-current assets', '{}'::jsonb, 'income_other', false, null, 1080),
  ('LS', 'default', '5000', 'Purchases — goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1090),
  ('LS', 'default', '5010', 'Purchases — raw materials and consumables', '{}'::jsonb, 'expense_direct_cost', false, null, 1100),
  ('LS', 'default', '5020', 'Freight and carriage inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 1110),
  ('LS', 'default', '5030', 'Customs duty and import charges', '{}'::jsonb, 'expense_direct_cost', false, null, 1120),
  ('LS', 'default', '5040', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 1130),
  ('LS', 'default', '5100', 'Subcontractors', '{}'::jsonb, 'expense_direct_cost', false, null, 1140),
  ('LS', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 1150),
  ('LS', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1160),
  ('LS', 'default', '6020', 'Pension and provident fund contributions', '{}'::jsonb, 'expense', false, null, 1170),
  ('LS', 'default', '6030', 'Employer statutory contributions', '{}'::jsonb, 'expense', false, null, 1180),
  ('LS', 'default', '6040', 'Employer payroll levies', '{}'::jsonb, 'expense', false, null, 1190),
  ('LS', 'default', '6050', 'Employee injury and insurance contributions', '{}'::jsonb, 'expense', false, null, 1200),
  ('LS', 'default', '6060', 'Leave pay expense', '{}'::jsonb, 'expense', false, null, 1210),
  ('LS', 'default', '6070', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1220),
  ('LS', 'default', '6200', 'Depreciation — buildings and leasehold improvements', '{}'::jsonb, 'expense_depreciation', false, null, 1230),
  ('LS', 'default', '6210', 'Depreciation — plant, machinery and motor vehicles', '{}'::jsonb, 'expense_depreciation', false, null, 1240),
  ('LS', 'default', '6220', 'Depreciation — right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1250),
  ('LS', 'default', '6230', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1260),
  ('LS', 'default', '6300', 'Rent and operating lease charges', '{}'::jsonb, 'expense', false, null, 1270),
  ('LS', 'default', '6310', 'Electricity, water and refuse removal', '{}'::jsonb, 'expense', false, null, 1280),
  ('LS', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1290),
  ('LS', 'default', '6330', 'Insurance', '{}'::jsonb, 'expense', false, null, 1300),
  ('LS', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1310),
  ('LS', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1320),
  ('LS', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1330),
  ('LS', 'default', '6370', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1340),
  ('LS', 'default', '6380', 'Travel and accommodation', '{}'::jsonb, 'expense', false, null, 1350),
  ('LS', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1360),
  ('LS', 'default', '6400', 'Accounting and audit fees', '{}'::jsonb, 'expense', false, null, 1370),
  ('LS', 'default', '6410', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 1380),
  ('LS', 'default', '6420', 'Consulting fees', '{}'::jsonb, 'expense', false, null, 1390),
  ('LS', 'default', '6430', 'Bank charges and merchant fees', '{}'::jsonb, 'expense', false, null, 1400),
  ('LS', 'default', '6440', 'Printing, postage and stationery', '{}'::jsonb, 'expense', false, null, 1410),
  ('LS', 'default', '6450', 'Subscriptions and memberships', '{}'::jsonb, 'expense', false, null, 1420),
  ('LS', 'default', '6460', 'Bad debts and expected credit losses', '{}'::jsonb, 'expense', false, null, 1430),
  ('LS', 'default', '6470', 'Donations', '{}'::jsonb, 'expense', false, null, 1440),
  ('LS', 'default', '6480', 'Rates and municipal charges', '{}'::jsonb, 'expense', false, null, 1450),
  ('LS', 'default', '6490', 'Sundry expenses', '{}'::jsonb, 'expense', false, null, 1460),
  ('LS', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1470),
  ('LS', 'default', '6960', 'Loss on disposal of non-current assets', '{}'::jsonb, 'expense', false, null, 1480),
  ('LS', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1490),
  ('LS', 'default', '7000', 'Interest on bank loans and overdraft', '{}'::jsonb, 'expense', false, null, 1500),
  ('LS', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1510),
  ('LS', 'default', '7020', 'Instalment sale and hire purchase interest', '{}'::jsonb, 'expense', false, null, 1520),
  ('LS', 'default', '7030', 'Interest on late payment of tax', '{}'::jsonb, 'expense', false, null, 1530),
  ('LS', 'default', '8000', 'Income tax expense — current', '{}'::jsonb, 'expense', false, null, 1540),
  ('LS', 'default', '8010', 'Income tax expense — deferred', '{}'::jsonb, 'expense', false, null, 1550),
  ('LS', 'default', '8020', 'Income tax — under or over provision of prior years', '{}'::jsonb, 'expense', false, null, 1560)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('LS', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('LS', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('LS', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('LS', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('LS', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('LS', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('LS', 'LS-P-EXEMPT', 'Purchase, exempt', '{}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2021-04-01', null, 'The supplier made an exempt supply under Value Added Tax Act, 2001, s. 6(2) — bank charges and interest are financial services — and charged no VAT.', 'E', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-P-IMPORT-GOODS', 'Importation of goods, VAT 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'import', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 7(1)(b) — the tax on a taxable import is paid by the importer; s. 11(1)(a) and (2) — an import of goods occurs on the date of clearance under the Customs and Excise Act, 1982; s. 23(1)(a) and s. 24(4)(b) — the credit is allowed on a bill of entry or other customs document. Imported goods carry the 15 % rate.', null, null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-P-NOT-SUBJECT', 'Purchase from a person who is not a vendor', '{}'::jsonb, null, 'percent', 0, 'purchase', 'not_subject', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 17 — only a registered vendor charges VAT; a supplier below the registration threshold charges none, and there is nothing to deduct.', 'O', null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-P-RC-IMPORT-SERVICES', 'Imported services, reverse charged, not claimed', '{}'::jsonb, null, 'percent', 15, 'purchase', 'foreign_services_received', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 11(1)(b) — an import of services is a supply by a person carrying on an enterprise outside Lesotho for use or consumption in Lesotho; s. 7(1)(b) — the importer pays the tax. The pack books the tax on the service as a cost and as a liability in box 8, and claims no credit; a vendor that is entitled to the credit under s. 23 adjusts it with its accountant.', null, null, 180, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-P-VAT', 'Purchase, standard rate 15 %', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 20(1) — the tax payable for a period is output tax (A) less input tax (B) allowed as a credit; s. 23(1)(a) — the credit is allowed for input tax on a taxable supply to the vendor for use in manufacturing, in construction services or for resale in substantially the same state, and s. 24(4) requires a value added tax invoice in the period of the claim. The conditions of s. 23 are the vendor''s to check: this code credits the tax and `LS-P-VAT-NC` does not.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-P-VAT-ELEC', 'Purchase of electricity, rate 10 %', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2021-04-01', null, 'Value Added Tax Regulations, 2003, reg. 6(1)(b) as amended by Legal Notice No. 30 of 2021 — 10 % on electricity from 1 April 2021; the credit follows Value Added Tax Act, 2001, s. 20(1) and s. 23 as for LS-P-VAT.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-regs-2021', null, null, null, null),
  ('LS', 'LS-P-VAT-NC', 'Purchase, standard rate 15 %, input tax not creditable', '{}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 23(1)(a) — a credit is allowed only for the supplies the paragraph lists, and s. 6(2) read with s. 20(1) leaves none for what went into an exempt supply. Where the vendor cannot claim the VAT on a purchase, the tax is part of its cost and no box of the return carries it.', 'S', null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-P-ZERO', 'Purchase, zero-rated', '{}'::jsonb, null, 'percent', 0, 'purchase', 'domestic', date '2021-04-01', null, 'The supplier charged VAT at 0 % under Value Added Tax Act, 2001, s. 19; there is no input tax to claim and the return has no box for the value of a purchase that carries no VAT.', 'Z', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-S-EXEMPT', 'Exempt supply', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 6(2) — exempt supplies: public postal, transportation, medical or dental, financial, insurance and education services (defined in s. 6(1)); unimproved land; the letting of immovable property to a manufacturer that uses it principally for manufacturing; water; and any supply the Minister prescribes in regulations. An exempt supply carries no output tax, and the input tax on what went into it is not creditable. No exemption reason code is carried: the VATEX list names provisions of the European Union''s common system that do not bind a Lesotho supplier. Residential rent is not in the list of s. 6(2) as published in 2001 and is therefore not offered here as exempt.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-S-EXPORT', 'Export of goods or services, zero-rated', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 19(2) — the rate of value added tax imposed on an export of goods or services from Lesotho by a vendor is zero; s. 12(2) — a taxable supply includes an export; s. 10(7) — services supplied from a place of business in Lesotho that would be treated as supplied abroad are considered exported for the purposes of s. 19(2).', 'G', null, 40, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-S-NOT-SUBJECT', 'Supply outside the scope of VAT', '{}'::jsonb, null, 'percent', 0, 'sale', 'not_subject', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 12(1) and (3) — VAT is levied only on a supply made in Lesotho by a vendor in the course or furtherance of an enterprise; a private sale, or a supply made outside Lesotho (s. 10), is not a taxable supply and appears in no box of the return.', 'O', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('LS', 'LS-S-VAT', 'Sale, standard rate 15 %', '{}'::jsonb, 'A taxable supply made by a vendor in the course or furtherance of an enterprise, in Lesotho', 'percent', 15, 'sale', 'domestic', date '2021-04-01', null, 'Value Added Tax Act, 2001 (Act No. 9 of 2001), s. 12(1) — a taxable supply is a supply of goods or services, other than an exempt supply, made in Lesotho by a vendor for consideration in the course or furtherance of an enterprise; s. 19(3) — the rates are prescribed by regulation, at most four including a zero rate. The Revenue Services Lesotho page of tax rates lists 15 % for other goods and services, that is every supply the regulations do not carry at another rate. The pack dates every code from 1 April 2021, the day the last rate change in the regulations it read took effect (electricity at 10 %); earlier dates are left to a later version, since no official text of the earlier standard rate was read.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rsl-tax-rates', null, null, null, null),
  ('LS', 'LS-S-VAT-ELEC', 'Sale of electricity, rate 10 %', '{}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '2021-04-01', null, 'Value Added Tax Regulations, 2003 (Legal Notice No. 95 of 2003), reg. 6(1)(b), as amended: the rate on electricity was raised from 8 % to 9 % from 1 April 2020 by the Value Added Tax (Amendment) Regulations, 2020 (Legal Notice No. 18 of 2020), and from 9 % to 10 % from 1 April 2021 by the Value Added Tax (Amendment) Regulations, 2021 (Legal Notice No. 30 of 2021). The RSL page of tax rates still lists 10 % for electricity. The 9 % and 8 % periods are closed and not carried, since no document of this pack falls in them.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-regs-2021', null, null, null, null),
  ('LS', 'LS-S-ZERO', 'Sale, zero-rated, domestic', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 6(4) and the regulations made under s. 19(3) — the rate of zero applies to the supplies the regulations list; the RSL page of tax rates names exports and basic commodities at 0 %. The list of basic commodities is in the regulations, which RSL amended in 2026 to add zero-rated imported products (fresh produce, cooking oil); the list is not copied into this pack, so the user picks this code only for a supply the regulations name. A zero-rated supply is a taxable supply at a nil charge, not an exempt one (s. 6(4)): the input tax on what went into it stays creditable.', 'Z', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'rsl-tax-rates', null, null, null, null)
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
    ('LS-P-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-EXEMPT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-IMPORT-GOODS', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-IMPORT-GOODS', 'invoice', 'tax', 100, '1150', '11', array['11']::text[], 100, 'LS-VAT', 20),
    ('LS-P-IMPORT-GOODS', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-IMPORT-GOODS', 'credit_note', 'tax', 100, '1150', '11', array['11']::text[], -100, 'LS-VAT', 20),
    ('LS-P-NOT-SUBJECT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-NOT-SUBJECT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-RC-IMPORT-SERVICES', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-RC-IMPORT-SERVICES', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('LS-P-RC-IMPORT-SERVICES', 'invoice', 'tax', -100, '2100', '8', array['8']::text[], 100, 'LS-VAT', 30),
    ('LS-P-RC-IMPORT-SERVICES', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-RC-IMPORT-SERVICES', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('LS-P-RC-IMPORT-SERVICES', 'credit_note', 'tax', -100, '2100', '8', array['8']::text[], -100, 'LS-VAT', 30),
    ('LS-P-VAT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-VAT', 'invoice', 'tax', 100, '1150', '10', array['10']::text[], 100, 'LS-VAT', 20),
    ('LS-P-VAT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-VAT', 'credit_note', 'tax', 100, '1150', '10', array['10']::text[], -100, 'LS-VAT', 20),
    ('LS-P-VAT-ELEC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-VAT-ELEC', 'invoice', 'tax', 100, '1150', '10', array['10']::text[], 100, 'LS-VAT', 20),
    ('LS-P-VAT-ELEC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-VAT-ELEC', 'credit_note', 'tax', 100, '1150', '10', array['10']::text[], -100, 'LS-VAT', 20),
    ('LS-P-VAT-NC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-VAT-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('LS-P-VAT-NC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-VAT-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('LS-P-ZERO', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-P-ZERO', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-S-EXEMPT', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'LS-VAT', 10),
    ('LS-S-EXEMPT', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'LS-VAT', 10),
    ('LS-S-EXPORT', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'LS-VAT', 10),
    ('LS-S-EXPORT', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'LS-VAT', 10),
    ('LS-S-NOT-SUBJECT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LS-S-NOT-SUBJECT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('LS-S-VAT', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'LS-VAT', 10),
    ('LS-S-VAT', 'invoice', 'tax', 100, '2100', '6', array['6']::text[], 100, 'LS-VAT', 20),
    ('LS-S-VAT', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'LS-VAT', 10),
    ('LS-S-VAT', 'credit_note', 'tax', 100, '2100', '6', array['6']::text[], -100, 'LS-VAT', 20),
    ('LS-S-VAT-ELEC', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'LS-VAT', 10),
    ('LS-S-VAT-ELEC', 'invoice', 'tax', 100, '2100', '7', array['7']::text[], 100, 'LS-VAT', 20),
    ('LS-S-VAT-ELEC', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'LS-VAT', 10),
    ('LS-S-VAT-ELEC', 'credit_note', 'tax', 100, '2100', '7', array['7']::text[], -100, 'LS-VAT', 20),
    ('LS-S-ZERO', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'LS-VAT', 10),
    ('LS-S-ZERO', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'LS-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'LS' and t.code = v.tax_code
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
  ('LS', 'LS-VAT', 'Value Added Tax return', array['month']::declaration_period[], null, date '2021-04-01', null, 'Value Added Tax Act, 2001, s. 1 — the tax period is one month ending on the last day of each month of the calendar year; s. 27(1) — a vendor files a return for each tax period with the Commissioner General; s. 27(2) — the return is in the form the Commissioner prescribes. The boxes below follow the structure of s. 20(1) (output tax A less input tax B); the numbering is this pack''s own, because the form RSL prescribes was not published in a text this pack could read — the README says so.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Value Added Tax Act, 2001, s. 27(1) — within twenty days after the end of the period; s. 37(1)(a) — the tax is due and payable on the date the return is to be filed. s. 27(4) lets the Commissioner extend the filing, but not the payment (s. 27(5)).', 'vat-act', null)
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
  ('LS', 'LS-VAT', '1', 'base', 'Supplies at the standard rate of 15 %, VAT-exclusive', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1), item A — the tax payable on the taxable supplies made in the period; the base is the taxable value of the supplies at the rate of 15 % (s. 12, s. 14).', 'vat-act'),
  ('LS', 'LS-VAT', '2', 'base', 'Supplies of electricity at 10 %, VAT-exclusive', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Regulations, 2003, reg. 6(1)(b), as amended by Legal Notice No. 30 of 2021 — the taxable value of supplies of electricity.', 'vat-regs-2021'),
  ('LS', 'LS-VAT', '3', 'base', 'Zero-rated supplies, other than exports', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 19(3) — supplies at the zero rate the regulations prescribe, such as basic commodities.', 'vat-act'),
  ('LS', 'LS-VAT', '4', 'base', 'Exports, zero-rated', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 19(2) — exports of goods or services by a vendor at the rate of zero.', 'vat-act'),
  ('LS', 'LS-VAT', '5', 'base', 'Exempt supplies', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 6(2) — exempt supplies carry no tax and no input credit.', 'vat-act'),
  ('LS', 'LS-VAT', '6', 'tax', 'Output tax at 15 %', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1), item A — the value added tax payable on the taxable supplies of box 1.', 'vat-act'),
  ('LS', 'LS-VAT', '7', 'tax', 'Output tax on electricity at 10 %', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1), item A — the tax payable on the supplies of box 2.', 'vat-act'),
  ('LS', 'LS-VAT', '8', 'tax', 'Tax on imported services, self-assessed', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 7(1)(b) and s. 11(1)(b) — the tax on an import of services is paid by the importer.', 'vat-act'),
  ('LS', 'LS-VAT', '9', 'total', 'Total output tax', '{}'::jsonb, 90, null, array['6', '7', '8']::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1) — item A, the sum of boxes 6, 7 and 8.', 'vat-act'),
  ('LS', 'LS-VAT', '10', 'tax', 'Input tax on local purchases', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1), item B, and s. 23(1)(a) — input tax allowed as a credit on taxable supplies to the vendor.', 'vat-act'),
  ('LS', 'LS-VAT', '11', 'tax', 'Input tax on imported goods', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 23(1)(a) and s. 24(4)(b) — input tax on a taxable import, evidenced by a bill of entry or other customs document.', 'vat-act'),
  ('LS', 'LS-VAT', '12', 'total', 'Total input tax', '{}'::jsonb, 120, null, array['10', '11']::text[], '{}'::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1) — item B, the sum of boxes 10 and 11.', 'vat-act'),
  ('LS', 'LS-VAT', '13', 'total', 'Value added tax payable or (refundable)', '{}'::jsonb, 130, null, array['9']::text[], array['12']::text[], null, null, false, false, null, 'Value Added Tax Act, 2001, s. 20(1) — the tax payable for a period is A − B; a negative figure is an excess credit. This pack writes the signed subtraction.', 'vat-act')
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
  ('LS-IFRSSME-PL', 'LS', 'default', 'Statement of comprehensive income — IFRS for SMEs Accounting Standard, Section 5, expenses by nature', 'income_statement', 'LS-IFRS-FOR-SMES', date '1970-01-01', null, 'IFRS for SMEs, paragraph 5.5 lists the line items a statement of comprehensive income presents as a minimum, and paragraph 5.11 requires an analysis of expenses using a classification based on either their nature or their function, whichever provides information that is reliable and more relevant; this statement analyses them by nature, which a small company''s ledger holds without any allocation. The share of the profit or loss of associates and joint ventures (5.5(c)), discontinued operations (5.5(e)) and other comprehensive income (5.5(g)) are not lines here, because the chart carries no account for them: a company with none of those is permitted a single profit-or-loss line under paragraph 5.5(f).', 'ifrs-for-smes', null, null, '{}'::jsonb),
  ('LS-IFRSSME-SFP', 'LS', 'default', 'Statement of financial position — IFRS for SMEs Accounting Standard, Section 4', 'balance_sheet', 'LS-IFRS-FOR-SMES', date '1970-01-01', null, 'Companies Act, 2011 (Act No. 18 of 2011), s. 95 — a company''s accounts follow the financial reporting framework prescribed by the Lesotho Institute of Accountants, which has adopted the IFRS Standards and the IFRS for SMEs Accounting Standard; a company other than a financial institution may choose either (IFRS Foundation jurisdiction profile for Lesotho). IFRS for SMEs, paragraph 4.2, lists the line items a statement of financial position presents as a minimum, and paragraph 4.2A leaves their order and format to the entity, so the lines below are those items in the order Lesotho practice prints them, classified current and non-current under paragraphs 4.4 to 4.8. Biological assets (4.2(h)-(i)) and non-controlling interests (4.2(q)) are not lines here, because the chart carries no account for them.', 'ifrs-for-smes', 'combined', 'Result of the current financial year', '{}'::jsonb)
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
  ('LS-IFRSSME-PL', '1', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(a).', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '2', null, 'Other income', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.9 — an entity presents additional line items when relevant to an understanding of its financial performance: interest, rent, grants, foreign exchange gains and gains on disposal, which are not revenue from the entity''s ordinary activities.', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '3', null, 'Raw materials, consumables and goods for resale used', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — expenses analysed by their nature: purchases of materials and goods, freight inwards, import charges, the change in inventories and subcontractors.', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '4', null, 'Employee benefits expense', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — employee benefits costs, statutory employer contributions and levies among them.', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '5', null, 'Depreciation and amortisation expense', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — depreciation.', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '6', null, 'Other expenses', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.11(b) — the other expenses by nature, foreign exchange losses and losses on disposal among them.', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '7', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(b).', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '8', null, 'Profit before income tax', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('LS-IFRSSME-PL', '9', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 5.5(d) — tax expense, excluding any tax the company only withholds and remits for somebody else, which is never a charge against its own profit.', 'ifrs-for-smes'),
  ('LS-IFRSSME-PL', '10', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, 'IFRS for SMEs, paragraph 5.5(f) — profit or loss. The pack carries no item of other comprehensive income, so paragraph 5.5(f)''s permission applies and this is also total comprehensive income.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA', null, 'Current assets', '{}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4 to 4.8 — current and non-current assets are presented as separate classifications, an asset being current when it is expected to be realised in the entity''s normal operating cycle, held for trading, expected to be realised within twelve months, or is cash or a cash equivalent not restricted for at least twelve months.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA.1', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(a).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA.2', 'CA', 'Trade and other receivables', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(b). VAT input and the VAT refund due from RSL are receivables from the Commissioner and not current tax, which paragraph 4.2(n) keeps for income tax; the suspense account reports here while it is in debit.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA.3', 'CA', 'Inventories', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(d).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA.4', 'CA', 'Financial assets', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(c), the part realised within twelve months.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA.5', 'CA', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(n) — assets for current tax, which in Lesotho is income tax.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CA.6', 'CA', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.3 — an entity presents additional line items when relevant to an understanding of its financial position: prepayments and deposits paid, which are neither receivables nor financial assets.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA', null, 'Non-current assets', '{}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4 and 4.5 — every asset that is not current is non-current.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.1', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(e). Right-of-use assets are presented within this line, beside the assets of the same nature; each cost account carries its accumulated depreciation on the next code so that one range reaches the carrying amount.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.2', 'NCA', 'Investment property', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(f).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.3', 'NCA', 'Intangible assets', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(g).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.4', 'NCA', 'Investments in associates', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(j).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.5', 'NCA', 'Investments in joint ventures', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(k).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.6', 'NCA', 'Financial assets', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(c), the part not realised within twelve months.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCA.7', 'NCA', 'Deferred tax assets', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(o) — deferred tax assets and liabilities are always classified as non-current.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'TA', null, 'Total assets', '{}'::jsonb, 160, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('LS-IFRSSME-SFP', 'CL', null, 'Current liabilities', '{}'::jsonb, 170, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraphs 4.4, 4.6 and 4.7 — current and non-current liabilities are presented as separate classifications.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CL.1', 'CL', 'Trade and other payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(l). VAT output, the VAT payable to RSL, withholding taxes and pay-as-you-earn (PAYE) are owed to RSL and are not current income tax, so they report here and not under paragraph 4.2(n); the suspense account reports here while it is in credit.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CL.2', 'CL', 'Financial liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(m), the part due within twelve months, the credit card among them.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CL.3', 'CL', 'Current tax liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(n) — liabilities for current tax: income tax and provisional tax.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'CL.4', 'CL', 'Provisions', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(p), the part expected to be settled within twelve months, leave pay among it.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 220, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.7 — every liability that is not current is non-current.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCL.1', 'NCL', 'Financial liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(m), the part not due within twelve months.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCL.2', 'NCL', 'Deferred tax liabilities', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(o).', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'NCL.3', 'NCL', 'Provisions', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(p), the part not expected to be settled within twelve months.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'TL', null, 'Total liabilities', '{}'::jsonb, 260, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('LS-IFRSSME-SFP', 'NA', null, 'Net assets', '{}'::jsonb, 270, 1, true, array['TA']::text[], array['TL']::text[], null, 'Not a line paragraph 4.2 lists: the subtotal a Lesotho statement of financial position prints above equity, which paragraph 4.3 allows. It equals total equity once the year is closed, and exceeds it by the profit of the year until then.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'EQ', null, 'Equity', '{}'::jsonb, 280, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.2(r) — equity attributable to the owners of the parent; paragraph 4.12(f) asks for its classes, which are the three lines below.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'EQ.1', 'EQ', 'Issued capital', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(f) — classes of equity, such as paid-in capital; members'' contributions report on the same line.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'EQ.2', 'EQ', 'Reserves', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(f) — reserves.', 'ifrs-for-smes'),
  ('LS-IFRSSME-SFP', 'EQ.3', 'EQ', 'Retained earnings', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'IFRS for SMEs, paragraph 4.12(f) — retained earnings, after the dividends declared that are booked beside them.', 'ifrs-for-smes')
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
 where r.statement_code in ('LS-IFRSSME-PL', 'LS-IFRSSME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('LS-IFRSSME-PL', '1', 10),
            ('LS-IFRSSME-PL', '2', 10),
            ('LS-IFRSSME-PL', '3', 10),
            ('LS-IFRSSME-PL', '4', 10),
            ('LS-IFRSSME-PL', '5', 10),
            ('LS-IFRSSME-PL', '6', 10),
            ('LS-IFRSSME-PL', '7', 10),
            ('LS-IFRSSME-PL', '9', 10),
            ('LS-IFRSSME-SFP', 'CA.1', 10),
            ('LS-IFRSSME-SFP', 'CA.2', 10),
            ('LS-IFRSSME-SFP', 'CA.2', 20),
            ('LS-IFRSSME-SFP', 'CA.3', 10),
            ('LS-IFRSSME-SFP', 'CA.4', 10),
            ('LS-IFRSSME-SFP', 'CA.5', 10),
            ('LS-IFRSSME-SFP', 'CA.6', 10),
            ('LS-IFRSSME-SFP', 'NCA.1', 10),
            ('LS-IFRSSME-SFP', 'NCA.2', 10),
            ('LS-IFRSSME-SFP', 'NCA.3', 10),
            ('LS-IFRSSME-SFP', 'NCA.4', 10),
            ('LS-IFRSSME-SFP', 'NCA.5', 10),
            ('LS-IFRSSME-SFP', 'NCA.6', 10),
            ('LS-IFRSSME-SFP', 'NCA.7', 10),
            ('LS-IFRSSME-SFP', 'CL.1', 10),
            ('LS-IFRSSME-SFP', 'CL.1', 20),
            ('LS-IFRSSME-SFP', 'CL.2', 10),
            ('LS-IFRSSME-SFP', 'CL.3', 10),
            ('LS-IFRSSME-SFP', 'CL.4', 10),
            ('LS-IFRSSME-SFP', 'NCL.1', 10),
            ('LS-IFRSSME-SFP', 'NCL.2', 10),
            ('LS-IFRSSME-SFP', 'NCL.3', 10),
            ('LS-IFRSSME-SFP', 'EQ.1', 10),
            ('LS-IFRSSME-SFP', 'EQ.2', 10),
            ('LS-IFRSSME-SFP', 'EQ.3', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('LS-IFRSSME-PL', '1', 10, 'code_range', '4000', '4090', null, 'any'),
    ('LS-IFRSSME-PL', '2', 10, 'code_range', '4500', '4750', null, 'any'),
    ('LS-IFRSSME-PL', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('LS-IFRSSME-PL', '4', 10, 'code_range', '6000', '6070', null, 'any'),
    ('LS-IFRSSME-PL', '5', 10, 'code_range', '6200', '6230', null, 'any'),
    ('LS-IFRSSME-PL', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('LS-IFRSSME-PL', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('LS-IFRSSME-PL', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('LS-IFRSSME-SFP', 'CA.1', 10, 'code_range', '1000', '1060', null, 'any'),
    ('LS-IFRSSME-SFP', 'CA.2', 10, 'code_range', '1100', '1155', null, 'any'),
    ('LS-IFRSSME-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('LS-IFRSSME-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('LS-IFRSSME-SFP', 'CA.4', 10, 'code_range', '1300', '1320', null, 'any'),
    ('LS-IFRSSME-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('LS-IFRSSME-SFP', 'CA.6', 10, 'code_range', '1400', '1420', null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.1', 10, 'code_range', '1600', '1680', null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.3', 10, 'code_range', '1750', '1771', null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.6', 10, 'code_range', '1820', '1840', null, 'any'),
    ('LS-IFRSSME-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('LS-IFRSSME-SFP', 'CL.1', 10, 'code_range', '2000', '2120', null, 'any'),
    ('LS-IFRSSME-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('LS-IFRSSME-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('LS-IFRSSME-SFP', 'CL.3', 10, 'code_range', '2300', '2310', null, 'any'),
    ('LS-IFRSSME-SFP', 'CL.4', 10, 'code_range', '2350', '2370', null, 'any'),
    ('LS-IFRSSME-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('LS-IFRSSME-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('LS-IFRSSME-SFP', 'NCL.3', 10, 'code_range', '2550', '2560', null, 'any'),
    ('LS-IFRSSME-SFP', 'EQ.1', 10, 'code_range', '3000', '3020', null, 'any'),
    ('LS-IFRSSME-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('LS-IFRSSME-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('LS', 'Lesotho', '{}'::jsonb, array['en']::text[], 'LSL', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', default, default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Value Added Tax Act, 2001, s. 24 and Schedule III — a vendor making a taxable supply to another vendor provides a value added tax invoice with the particulars of Schedule III; the Act does not, in the text this pack read, require the numbering to be unbroken or to restart each year, so numbering is `sequential`. The pattern in number_format is a business''s own choice.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = 'No statute of general application that this pack read fixes a payment term between businesses in Lesotho in the absence of an agreement, nor a statutory rate of interest on a late commercial invoice, so legal_payment_days and late_payment_reference are left empty.',
  payment_terms_source_key      = 'vat-act',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Value Added Tax Act, 2001, s. 9(2)(d) — in the ordinary case a supply occurs on the earliest of the date the goods are delivered or made available (or the services completed), the date the invoice is issued, and the date payment, including part payment, is made. `invoice_date` is right when the invoice comes first, which is the ordinary case between vendors; it is a derogation from the earliest-of rule, wrong for goods delivered or paid for before any invoice. s. 9(2)(a) to (c) fix other dates for an auction, an own use and a gift.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Lesotho has no Peppol authority and no published structured-invoice profile that Ekwo''s vocabulary can name, so `profile`, `party_scheme` and `vat_scheme` are null and `obligation` is `none`. What Lesotho has instead is a clearance-style system: the Value Added Tax (E-Invoicing) Regulations, 2026 (Legal Notice No. 25 of 2026), made under s. 88 of the Value Added Tax Act, 2001, came into operation on 1 April 2026, and provide for an invoice issued from an accredited Electronic Billing System, carrying a QR code and registered on RSL''s Invoice Data Management System (the Lekuka portal). Real-time registration with the tax authority and accreditation of billing software are outside what a pack can model; the date from which each vendor must connect, and the penalties, were not read in the regulations and are left to the README.',
  einvoice_source_key           = 'einvoicing-regs',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'LS';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('LS', 'export', 'export', 'Export of goods or services — zero-rated under section 19(2) of the Value Added Tax Act, 2001.', '{}'::jsonb, 10, date '1970-01-01', null, 'Value Added Tax Act, 2001, s. 19(2) — the rate on an export by a vendor is zero; Schedule III lists the particulars of a value added tax invoice. Lesotho is outside the VATEX list of the European Union''s common system and carries no exemption reason code of its own.'),
  ('LS', 'exempt', 'exempt', 'Exempt supply under section 6 of the Value Added Tax Act, 2001 — no VAT is charged and no input tax on what went into it may be credited.', '{}'::jsonb, 20, date '1970-01-01', null, 'Value Added Tax Act, 2001, s. 6(2) — the exempt supplies: public postal, transportation, medical or dental, financial, insurance and education services, unimproved land, certain lettings to manufacturers, water, and the supplies the Minister prescribes.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;

update country_defaults set
  tax_payee_name       = 'Revenue Services Lesotho',
  tax_payee_source_key = 'etax'
 where country = 'LS';
