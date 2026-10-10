-- Ekwo OS — Bermuda: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/bm at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build bm`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Companies Act 1981 (consolidated) (Bermuda Monetary Authority (consolidated text of the Government of Bermuda))
--     https://www.bma.bm/viewPDF/documents/2023-11-14-10-39-37-Companies-Act-1981.pdf
--   Bermuda — Corporate — Other taxes (Worldwide Tax Summaries) (PwC)
--     https://taxsummaries.pwc.com/bermuda/corporate/other-taxes
--   Bermuda Corporate Income Tax (EY)
--     https://www.ey.com/en_us/bbc/bermuda-corporate-income-tax
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   e-Tax — Office of the Tax Commissioner (Government of Bermuda, Office of the Tax Commissioner)
--     https://www.etax.gov.bm
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BM', 'Bermuda', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, '99d2139a715ff9649ace82ee546effd6f5eaedf1c3b5bfcbb626e52586892101', '[{"key":"companies-act-1981","title":"Companies Act 1981 (consolidated)","publisher":"Bermuda Monetary Authority (consolidated text of the Government of Bermuda)","url":"https://www.bma.bm/viewPDF/documents/2023-11-14-10-39-37-Companies-Act-1981.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"pwc-bm-taxes","title":"Bermuda — Corporate — Other taxes (Worldwide Tax Summaries)","publisher":"PwC","url":"https://taxsummaries.pwc.com/bermuda/corporate/other-taxes","consulted_on":"2026-10-10","kind":"guidance"},{"key":"ey-bm-cit","title":"Bermuda Corporate Income Tax","publisher":"EY","url":"https://www.ey.com/en_us/bbc/bermuda-corporate-income-tax","consulted_on":"2026-10-10","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-10","kind":"standard"},{"key":"bm-etax","title":"e-Tax — Office of the Tax Commissioner","publisher":"Government of Bermuda, Office of the Tax Commissioner","url":"https://www.etax.gov.bm","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('BM', 'default', 'Bermuda reference chart of accounts', '{}'::jsonb, true, 'companies', array['BM-IFRS-SME-IS', 'BM-IFRS-SME-SFP']::text[], null, 'There is no legal chart of accounts in Bermuda. Companies Act 1981, section 83 requires every company to keep proper records of account of all sums received and expended, of all sales and purchases of goods and of its assets and liabilities, for five years from the date they were prepared, and section 84 requires the directors to lay financial statements before the general meeting, the notes of which name the generally accepted accounting principles used, whether those of Bermuda or of another jurisdiction (section 84(1A)). Neither section prescribes a chart. This chart is original: four digits, blocked so that each range reaches one line of a balance sheet and income statement presented in the manner of IFRS for SMEs, which is a choice of this pack — a company that reports under full IFRS or US GAAP uses the same chart with different notes. It carries no tax-clearing account because there is no sales tax to clear; accounts for the levies Bermuda does charge (payroll tax, customs duty, land tax, corporate income tax) are ordinary payable and expense accounts. See ''From Bermuda'' in docs/international.md.', 'companies-act-1981')
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
  ('BM', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('BM', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('BM', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('BM', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('BM', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('BM', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('BM', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('BM', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('BM', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('BM', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('BM', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('BM', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('BM', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('BM', 'default', '1150', 'Customs duty deposits paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('BM', 'default', '1160', 'Corporate income tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('BM', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 160),
  ('BM', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('BM', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('BM', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 190),
  ('BM', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 200),
  ('BM', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 210),
  ('BM', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 220),
  ('BM', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('BM', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('BM', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('BM', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('BM', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('BM', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('BM', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('BM', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('BM', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('BM', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('BM', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('BM', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('BM', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('BM', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('BM', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('BM', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('BM', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('BM', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('BM', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('BM', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('BM', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('BM', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 440),
  ('BM', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 450),
  ('BM', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 460),
  ('BM', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 470),
  ('BM', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('BM', 'default', '2050', 'Social insurance and health insurance contributions payable', '{}'::jsonb, 'liability_current', false, null, 490),
  ('BM', 'default', '2060', 'Corporate income tax payable', '{}'::jsonb, 'liability_current', false, null, 500),
  ('BM', 'default', '2070', 'Payroll tax payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('BM', 'default', '2071', 'Customs duty payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('BM', 'default', '2072', 'Land tax payable', '{}'::jsonb, 'liability_current', false, null, 530),
  ('BM', 'default', '2073', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 540),
  ('BM', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 550),
  ('BM', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 560),
  ('BM', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 570),
  ('BM', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('BM', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 590),
  ('BM', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 600),
  ('BM', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 610),
  ('BM', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 620),
  ('BM', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 630),
  ('BM', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 640),
  ('BM', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 650),
  ('BM', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 660),
  ('BM', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 670),
  ('BM', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 680),
  ('BM', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 690),
  ('BM', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 700),
  ('BM', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 710),
  ('BM', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 720),
  ('BM', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('BM', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 740),
  ('BM', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 750),
  ('BM', 'default', '5025', 'Customs duty on imports', '{}'::jsonb, 'expense_direct_cost', false, null, 760),
  ('BM', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 770),
  ('BM', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 780),
  ('BM', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 790),
  ('BM', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 800),
  ('BM', 'default', '6025', 'Payroll tax — employer portion', '{}'::jsonb, 'expense', false, null, 810),
  ('BM', 'default', '6026', 'Social insurance and health insurance — employer portion', '{}'::jsonb, 'expense', false, null, 820),
  ('BM', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 830),
  ('BM', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 840),
  ('BM', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 850),
  ('BM', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 860),
  ('BM', 'default', '6130', 'Land tax', '{}'::jsonb, 'expense', false, null, 870),
  ('BM', 'default', '6200', 'Government fees, licences and company registry fees', '{}'::jsonb, 'expense', false, null, 880),
  ('BM', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 890),
  ('BM', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 900),
  ('BM', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 910),
  ('BM', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 920),
  ('BM', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 930),
  ('BM', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 940),
  ('BM', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 950),
  ('BM', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 960),
  ('BM', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 970),
  ('BM', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 980),
  ('BM', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 990),
  ('BM', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1000),
  ('BM', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 1010),
  ('BM', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 1020),
  ('BM', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 1030),
  ('BM', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1040),
  ('BM', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1050),
  ('BM', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1060),
  ('BM', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1070),
  ('BM', 'default', '6470', 'Corporate income tax charge', '{}'::jsonb, 'expense', false, null, 1080),
  ('BM', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1090),
  ('BM', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1100),
  ('BM', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1110)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BM', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('BM', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('BM', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('BM', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('BM', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('BM', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('BM', 'BM-P-NA', 'Purchase, not subject to any tax on turnover', '{}'::jsonb, 'Every purchase a Bermuda business books — domestic, imported, or delivered from outside Bermuda to a place outside Bermuda', 'percent', 0, 'purchase', 'not_subject', date '2000-01-01', null, 'The purchase side of BM-S-NA: no VAT, GST or general sales tax is charged on what a Bermuda business buys, whether the seller is local or abroad (PwC, Worldwide Tax Summaries, Bermuda, last reviewed 19 February 2026: there is no VAT or sales tax in Bermuda). An import does carry a tax at the border, customs duty under the Customs Tariff Act 1970, most commonly at 25 % and between 0 % and 33.5 % by tariff line. It is payable once by the importer on the goods'' value, is not recoverable and is not a tax any invoice line can carry a code for, so this pack does not model it as a tax code: a business books it to inventory or cost of sales (account 5025 Customs duty on imports), and the duty paid appears on the customs entry, not on the supplier''s invoice. See ''From Bermuda'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'pwc-bm-taxes', null, null, null, null),
  ('BM', 'BM-S-NA', 'Sale, not subject to any tax on turnover', '{}'::jsonb, 'Every sale a Bermuda business makes — domestic, exported, or delivered from outside Bermuda to a place outside Bermuda', 'percent', 0, 'sale', 'not_subject', date '2000-01-01', null, 'Bermuda levies no value added tax, goods and services tax or general sales tax: PwC''s Worldwide Tax Summaries for Bermuda (last reviewed 19 February 2026) states that there is no VAT or sales tax in Bermuda, and no enabling legislation exists. The 2026-27 budget material read for this pack (the Government''s pre-budget report and the press coverage of the 2026 Customs Tariff and Payroll Tax amendments) proposes none either; a check of this on 10 October 2026 found no such tax in force or enacted. What a Bermuda business pays on trading instead lies outside this pack and outside any invoice line: payroll tax, charged quarterly on remuneration and split between employer and employee under the Payroll Tax Act 1995; customs duty on imported goods under the Customs Tariff Act 1970 (most commonly 25 %, ranging from 0 % to 33.5 %), paid at the border by the importer; and, for the Bermuda entities of multinational groups with consolidated revenue of EUR 750 million or more, the 15 % corporate income tax of the Corporate Income Tax Act 2023, from fiscal years beginning on or after 1 January 2025. The code exists so that every sale line still carries a tax code the engine can post, and states that this jurisdiction has none. See ''From Bermuda'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'pwc-bm-taxes', null, null, null, null)
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
    ('BM-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BM-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('BM-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BM-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BM' and t.code = v.tax_code
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
  ('BM-IFRS-SME-IS', 'BM', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Companies Act 1981, section 84(1)(a)(i) requires a statement of the results of operations for the period; section 84(1A) leaves the accounting principles to the company, Bermudian or foreign, provided the notes name them. This income statement is a single-step-with-gross-profit layout in the spirit of IFRS for SMEs (International Accounting Standards Board), section 5, which allows the profit or loss to be presented alone where an entity has no other comprehensive income; a company with items of other comprehensive income adds the second statement. The layout is a choice of this pack and not a Bermuda requirement. The numbering is this pack''s own.', null),
  ('BM-IFRS-SME-SFP', 'BM', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'Companies Act 1981, section 84(1)(a)(iii) requires the directors to lay before the general meeting a balance sheet at the end of the period, and section 84(1A) requires the notes to describe the generally accepted accounting principles used, which may be those of Bermuda or of another jurisdiction, and to identify them where they are not Bermuda''s. The Act prescribes no layout. This statement follows the presentation of IFRS for SMEs (International Accounting Standards Board), section 4: current and non-current assets and liabilities, with equity shown beside them; that is a choice of this pack, not a text that Bermuda imposes, and a company that reports under full IFRS or US GAAP presents the same balance sheet with different notes. The numbering and the ranges each line reads are original to this pack: Bermuda has no legal chart of accounts to number against. Retained earnings and cash flows are separate statements under section 84(1)(a)(ii) and (iiiA), which this pack does not model.', null)
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
  ('BM-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('BM-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('BM-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
    ('BM-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('BM-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('BM-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('BM-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('BM-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('BM-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('BM-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('BM-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('BM-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('BM-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('BM-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('BM-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('BM-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('BM-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('BM-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('BM-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('BM-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('BM', 'Bermuda', '{}'::jsonb, array['en']::text[], 'BMD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Bermuda levies no value added tax, goods and services tax or general sales tax (PwC, Worldwide Tax Summaries, Bermuda, last reviewed 19 February 2026), so no tax statute conditions anything on an invoice carrying a sequential number. What a company must do is keep proper records of account of all sums received and expended and of all sales and purchases of goods, for five years from the date they were prepared (Companies Act 1981, section 83(1) and (5)) — a duty about what is kept, not about how an issued document is numbered. `numbering` is therefore `free`; `number_format` is a convention this pack proposes.',
  numbering_source_key          = 'companies-act-1981',
  payment_terms_legal_reference = 'This pack found no Bermuda statute that sets a payment term between two businesses in the absence of agreement, or a rate of interest on a commercial debt paid late; the search was not exhaustive and the primary legislation site was not read for it. `legal_payment_days` and `late_payment_reference` are empty, and a seller''s terms are a matter of contract stated on the document.',
  payment_terms_source_key      = 'companies-act-1981',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in Bermuda: it names the day a country''s general rule makes its own turnover tax chargeable, and Bermuda charges none (PwC, Worldwide Tax Summaries, Bermuda). `invoice_date` is declared as the closest general commercial convention — revenue is ordinarily recognised on satisfying the performance obligation under IFRS for SMEs — and not as a rule read from a Bermuda text; see ''From Bermuda'' in docs/international.md.',
  tax_point_source_key          = 'iasb-ifrs-sme',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Bermuda statute read for this pack obliges a business to issue or accept an electronic invoice, and no Bermuda Peppol Authority turned up in a search of the OpenPeppol network on 10 October 2026 (peppol.org''s own list of authorities was not opened). `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile to name and no VAT identifier for a scheme to carry, since Bermuda levies no value added tax (PwC, Worldwide Tax Summaries, Bermuda, last reviewed 19 February 2026).',
  einvoice_source_key           = 'pwc-bm-taxes',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'BM';
