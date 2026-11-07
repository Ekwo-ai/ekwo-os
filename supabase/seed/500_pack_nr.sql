-- Ekwo OS — Nauru: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/nr at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build nr`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Legislation administered by the Nauru Revenue Office (Revenue Administration Act, Employment and Services Tax Act 2014, Business Tax Act 2016, Telecommunications Service Tax Act 2009, Gaming Act 2011) (Nauru Revenue Office)
--     https://naurufinance.info/nro-administered-legislation/
--   Key dates: quarterly and annual business tax returns, monthly withholding returns, tax year 1 July to 30 June (Nauru Revenue Office)
--     https://naurufinance.info/nro-key-dates/
--   Employment and Services Tax Q & A Guide 2022-2023 (Nauru Revenue Office)
--     https://naurufinance.info/wp-content/uploads/2023/08/QA-Employment-and-Services-Tax-2022-23.pdf
--   Nauru Revenue Office — forms, the FMIS portal and contacts (Nauru Revenue Office)
--     https://naurufinance.info/nauru-revenue-office/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('NR', 'Nauru', '0.1.0', date '2026-11-07', '20261011120000', 'community', null, null, '0963f803450ee6cfbb790bee921203a835d8bdf7566ef2a8e31763499d0838af', '[{"key":"nro-legislation","title":"Legislation administered by the Nauru Revenue Office (Revenue Administration Act, Employment and Services Tax Act 2014, Business Tax Act 2016, Telecommunications Service Tax Act 2009, Gaming Act 2011)","publisher":"Nauru Revenue Office","url":"https://naurufinance.info/nro-administered-legislation/","consulted_on":"2026-11-07","kind":"guidance"},{"key":"nro-key-dates","title":"Key dates: quarterly and annual business tax returns, monthly withholding returns, tax year 1 July to 30 June","publisher":"Nauru Revenue Office","url":"https://naurufinance.info/nro-key-dates/","consulted_on":"2026-11-07","kind":"guidance"},{"key":"est-guide","title":"Employment and Services Tax Q & A Guide 2022-2023","publisher":"Nauru Revenue Office","url":"https://naurufinance.info/wp-content/uploads/2023/08/QA-Employment-and-Services-Tax-2022-23.pdf","consulted_on":"2026-11-07","kind":"guidance"},{"key":"nro","title":"Nauru Revenue Office — forms, the FMIS portal and contacts","publisher":"Nauru Revenue Office","url":"https://naurufinance.info/nauru-revenue-office/","consulted_on":"2026-11-07","kind":"portal"}]'::jsonb)
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
  ('NR', 'default', 'Nauru reference chart of accounts', '{}'::jsonb, true, 'companies', array['NR-IFRS-IS', 'NR-IFRS-SFP']::text[], null, 'Nauru prescribes no chart of accounts that this pack''s research found. The Nauru Revenue Office publishes the taxes it administers (consulted 7 November 2026): business profits tax, small business tax and non-resident tax under the Business Tax Act 2016, employment and services tax withheld by the payer under the Employment and Services Tax Act 2014, and telecommunications service tax; none of the pages read numbers accounts. This chart is therefore original: four digits, blocked so that each range reaches one line item of the statement of financial position and the statement of profit or loss, following IAS 1. It carries a business profits tax provision with its quarterly instalments, a payable for employment and services tax and non-resident tax withheld, and no tax-clearing account for a turnover tax, because Nauru has no general one in force. The name of the Nauruan-language terms a Nauruan accountant would use is not supplied: see the README.', 'nro-legislation')
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
  ('NR', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('NR', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('NR', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('NR', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('NR', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('NR', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('NR', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('NR', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('NR', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('NR', 'default', '1110', 'Amounts due from related parties', '{}'::jsonb, 'asset_current', false, null, 100),
  ('NR', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 110),
  ('NR', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('NR', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('NR', 'default', '1150', 'Business profits tax paid in advance (quarterly instalments)', '{}'::jsonb, 'asset_current', false, null, 140),
  ('NR', 'default', '1160', 'Business profits tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('NR', 'default', '1170', 'Tax credits receivable — other', '{}'::jsonb, 'asset_current', false, null, 155),
  ('NR', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 160),
  ('NR', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('NR', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('NR', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 190),
  ('NR', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 200),
  ('NR', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 210),
  ('NR', 'default', '1320', 'Amounts due from related parties — non-trade', '{}'::jsonb, 'asset_current', false, null, 220),
  ('NR', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('NR', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('NR', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('NR', 'default', '1600', 'Land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('NR', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('NR', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('NR', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('NR', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('NR', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('NR', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('NR', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('NR', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('NR', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('NR', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('NR', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('NR', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('NR', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('NR', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('NR', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('NR', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('NR', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('NR', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 440),
  ('NR', 'default', '2010', 'Amounts due to related parties', '{}'::jsonb, 'liability_current', false, null, 450),
  ('NR', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 460),
  ('NR', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 470),
  ('NR', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('NR', 'default', '2050', 'Employee entitlements payable', '{}'::jsonb, 'liability_current', false, null, 490),
  ('NR', 'default', '2060', 'Provision for business profits tax', '{}'::jsonb, 'liability_current', false, null, 500),
  ('NR', 'default', '2065', 'Employment and services tax and non-resident tax withheld, payable', '{}'::jsonb, 'liability_current', false, null, 505),
  ('NR', 'default', '2070', 'Telecommunications service tax, customs duties and other government charges payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('NR', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 520),
  ('NR', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 530),
  ('NR', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 540),
  ('NR', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('NR', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('NR', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 570),
  ('NR', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('NR', 'default', '3000', 'Issued share capital', '{}'::jsonb, 'equity', false, null, 590),
  ('NR', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 600),
  ('NR', 'default', '3110', 'Legal and other reserves', '{}'::jsonb, 'equity', false, null, 610),
  ('NR', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 620),
  ('NR', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 630),
  ('NR', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 640),
  ('NR', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 650),
  ('NR', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 660),
  ('NR', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 670),
  ('NR', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 680),
  ('NR', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 690),
  ('NR', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('NR', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('NR', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('NR', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('NR', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 740),
  ('NR', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 750),
  ('NR', 'default', '6020', 'Employee entitlements expense', '{}'::jsonb, 'expense', false, null, 760),
  ('NR', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 770),
  ('NR', 'default', '6100', 'Rent', '{}'::jsonb, 'expense', false, null, 780),
  ('NR', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 790),
  ('NR', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 800),
  ('NR', 'default', '6200', 'Business registration and licence fees', '{}'::jsonb, 'expense', false, null, 810),
  ('NR', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 820),
  ('NR', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 830),
  ('NR', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 840),
  ('NR', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 850),
  ('NR', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 860),
  ('NR', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 870),
  ('NR', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 880),
  ('NR', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 890),
  ('NR', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 900),
  ('NR', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 910),
  ('NR', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 920),
  ('NR', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 930),
  ('NR', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 940),
  ('NR', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 950),
  ('NR', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 960),
  ('NR', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 970),
  ('NR', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 980),
  ('NR', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 990),
  ('NR', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1000),
  ('NR', 'default', '6470', 'Business profits tax charge', '{}'::jsonb, 'expense', false, null, 1010),
  ('NR', 'default', '6475', 'Non-resident tax borne on payments to non-residents', '{}'::jsonb, 'expense', false, null, 1015),
  ('NR', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1020),
  ('NR', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1030),
  ('NR', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1040)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('NR', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('NR', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('NR', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('NR', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('NR', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('NR', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('NR', 'NR-P-NA', 'Purchase, not subject to any general tax on turnover', '{}'::jsonb, 'Every purchase a Nauruan business books — domestic, imported, or delivered from outside Nauru to a place outside Nauru', 'percent', 0, 'purchase', 'not_subject', date '2000-01-01', null, 'The purchase side of NR-S-NA. Nauru has no value added tax, goods and services tax or general sales tax in force that this pack''s research found. The Nauru Revenue Office''s list of the legislation it administers (consulted 7 November 2026) holds the Revenue Administration Act, the Employment and Services Tax Act 2014, the Business Tax Act 2016, the Telecommunications Service Tax Act 2009 and the Gaming Act 2011; this is an absence in that list and not a statement read from a text, and the customs side was not checked. What Nauru levies instead is outside this pack: business profits tax on the taxable income of a person who conducts business in Nauru (rate by entity type, residency and turnover; 20 % for individuals, partnerships and trusts, with a tax-free threshold of 250,000 dollars for Nauruan residents), small business tax of 2.5 % of the gross revenue of a non-resident individual with annual gross revenue up to 250,000 dollars, and non-resident tax of 20 % on interest, royalties and insurance premiums derived from Nauru (Business Tax Act 2016); employment and services tax, which the payer withholds on employment income and, for services, on the fees of non-resident independent service providers at 20 % (Employment and Services Tax Act 2014; the Employment and Services Tax Q and A Guide 2022-2023, questions 1, 10 and 12) — an income tax withheld at payment, not a tax a supplier adds to its customer''s invoice; and telecommunications service tax of 10 % on the gross sales of telecommunication services by a service provider (Telecommunications Service Tax Act 2009), which is confined to one sector and is not modelled. None is a general tax an invoice line carries and credits on the other side. There is accordingly no rate for this code to state and no box for its base: the code exists so that every line still carries a tax code the engine can post, and states plainly that Nauru has no general turnover tax. If such a tax is enacted, this code must be replaced. Nothing a Nauruan business buys carries a recoverable value added tax. An import may carry customs duty, which this pack does not model and did not source.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'nro-legislation', null, null, null, null),
  ('NR', 'NR-S-NA', 'Sale, not subject to any general tax on turnover', '{}'::jsonb, 'Every sale a Nauruan business makes — domestic, exported, or delivered from outside Nauru to a place outside Nauru', 'percent', 0, 'sale', 'not_subject', date '2000-01-01', null, 'Nauru has no value added tax, goods and services tax or general sales tax in force that this pack''s research found. The Nauru Revenue Office''s list of the legislation it administers (consulted 7 November 2026) holds the Revenue Administration Act, the Employment and Services Tax Act 2014, the Business Tax Act 2016, the Telecommunications Service Tax Act 2009 and the Gaming Act 2011; this is an absence in that list and not a statement read from a text, and the customs side was not checked. What Nauru levies instead is outside this pack: business profits tax on the taxable income of a person who conducts business in Nauru (rate by entity type, residency and turnover; 20 % for individuals, partnerships and trusts, with a tax-free threshold of 250,000 dollars for Nauruan residents), small business tax of 2.5 % of the gross revenue of a non-resident individual with annual gross revenue up to 250,000 dollars, and non-resident tax of 20 % on interest, royalties and insurance premiums derived from Nauru (Business Tax Act 2016); employment and services tax, which the payer withholds on employment income and, for services, on the fees of non-resident independent service providers at 20 % (Employment and Services Tax Act 2014; the Employment and Services Tax Q and A Guide 2022-2023, questions 1, 10 and 12) — an income tax withheld at payment, not a tax a supplier adds to its customer''s invoice; and telecommunications service tax of 10 % on the gross sales of telecommunication services by a service provider (Telecommunications Service Tax Act 2009), which is confined to one sector and is not modelled. None is a general tax an invoice line carries and credits on the other side. There is accordingly no rate for this code to state and no box for its base: the code exists so that every line still carries a tax code the engine can post, and states plainly that Nauru has no general turnover tax. If such a tax is enacted, this code must be replaced.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'nro-legislation', null, null, null, null)
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
    ('NR-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NR-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('NR-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NR-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'NR' and t.code = v.tax_code
on conflict (tax_template_id, document_kind, posting_type, sequence) do update set
  factor_percent     = excluded.factor_percent,
  account_code       = excluded.account_code,
  declaration_box    = excluded.declaration_box,
  declaration_boxes  = excluded.declaration_boxes,
  box_factor_percent = excluded.box_factor_percent,
  report_code        = excluded.report_code;

insert into statement_templates
  (code, country, chart_code, name, kind, framework, valid_from, valid_to, legal_reference,
   source_key, result_in_progress, result_in_progress_name, result_in_progress_name_i18n)
values
  ('NR-IFRS-IS', 'NR', 'default', 'Statement of profit or loss', 'income_statement', 'IFRS', date '1970-01-01', null, 'Presented as a separate statement of profit or loss, with expenses classified by function in outline (cost of sales, then operating expenses) in the manner of IAS 1 paragraphs 81A and 99-103, as the Income Tax Law (Law No. 24 of 2018), articles 6 and 12, point to international accounting standards without prescribing a layout. Other comprehensive income is not modelled: no revaluation or similar account is carried, so the profit for the year is the whole result. IFRS 18, which replaces IAS 1 for annual periods beginning on or after 1 January 2027, is not modelled. The numbering is original to this pack.', 'nro-key-dates', null, null, '{}'::jsonb),
  ('NR-IFRS-SFP', 'NR', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS', date '1970-01-01', null, 'Nauru prescribes no statement layout that this pack''s research found. The Nauru Revenue Office''s key-dates page (consulted 7 November 2026) sets a tax year of 1 July to 30 June, and the Business Tax Act 2016 is the income tax in force, but this pack''s research did not open a text that fixes the accounting framework a Nauruan company must apply, the financial year its accounts cover, or the content of its annual accounts: the Corporations Act (a 1972 Act appears on the legislation database; the existence of a 2021 Act could not be confirmed) was not read. The lines follow the minimum line items of IAS 1 Presentation of Financial Statements, paragraph 54, with current and non-current assets and liabilities presented separately (paragraph 60); the numbering and the account ranges are original to this pack. Which IFRS regime, if any, applies is the first thing a local reviewer should check.', 'nro-key-dates', 'alone', null, '{}'::jsonb)
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
  ('NR-IFRS-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('NR-IFRS-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-IS', 'PBT', null, 'Profit (loss) before tax', '{}'::jsonb, 65, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('NR-IFRS-IS', 'TAX', null, 'Business profits tax expense', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 80, 1, true, array['PBT']::text[], array['TAX']::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'E-RESULT', 'E-TOT', 'Profit for the year', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('NR-IFRS-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
 where r.statement_code in ('NR-IFRS-IS', 'NR-IFRS-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('NR-IFRS-IS', 'REV', 10),
            ('NR-IFRS-IS', 'COST', 10),
            ('NR-IFRS-IS', 'OTH-INC', 10),
            ('NR-IFRS-IS', 'OPEX', 10),
            ('NR-IFRS-IS', 'OPEX', 20),
            ('NR-IFRS-IS', 'OPEX', 30),
            ('NR-IFRS-IS', 'DEPR', 10),
            ('NR-IFRS-IS', 'TAX', 10),
            ('NR-IFRS-IS', 'TAX', 20),
            ('NR-IFRS-SFP', 'A-NC-FIX', 10),
            ('NR-IFRS-SFP', 'A-NC-INT', 10),
            ('NR-IFRS-SFP', 'A-NC-OTH', 10),
            ('NR-IFRS-SFP', 'A-C-REC', 10),
            ('NR-IFRS-SFP', 'A-C-INV', 10),
            ('NR-IFRS-SFP', 'A-C-OTH', 10),
            ('NR-IFRS-SFP', 'A-C-PRE', 10),
            ('NR-IFRS-SFP', 'A-C-CASH', 10),
            ('NR-IFRS-SFP', 'E-CAP', 10),
            ('NR-IFRS-SFP', 'E-RET', 10),
            ('NR-IFRS-SFP', 'E-RESULT', 10),
            ('NR-IFRS-SFP', 'E-RESULT', 20),
            ('NR-IFRS-SFP', 'E-RESULT', 30),
            ('NR-IFRS-SFP', 'E-RESULT', 40),
            ('NR-IFRS-SFP', 'L-NC', 10),
            ('NR-IFRS-SFP', 'L-C-PAY', 10),
            ('NR-IFRS-SFP', 'L-C-TAX', 10),
            ('NR-IFRS-SFP', 'L-C-OTH', 10),
            ('NR-IFRS-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('NR-IFRS-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('NR-IFRS-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('NR-IFRS-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('NR-IFRS-IS', 'OPEX', 10, 'code_range', '6000', '6469', null, 'any'),
    ('NR-IFRS-IS', 'OPEX', 20, 'code_range', '6475', '6479', null, 'any'),
    ('NR-IFRS-IS', 'OPEX', 30, 'code_range', '6481', '6799', null, 'any'),
    ('NR-IFRS-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('NR-IFRS-IS', 'TAX', 10, 'code_range', '6470', '6474', null, 'any'),
    ('NR-IFRS-IS', 'TAX', 20, 'account_code', '6480', null, null, 'any'),
    ('NR-IFRS-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('NR-IFRS-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('NR-IFRS-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('NR-IFRS-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('NR-IFRS-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('NR-IFRS-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('NR-IFRS-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('NR-IFRS-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('NR-IFRS-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('NR-IFRS-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('NR-IFRS-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('NR-IFRS-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('NR-IFRS-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('NR-IFRS-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('NR-IFRS-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('NR-IFRS-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('NR-IFRS-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('NR-IFRS-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('NR-IFRS-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('NR', 'Nauru', '{}'::jsonb, array['en']::text[], 'AUD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Nauru has no general turnover tax in force that this pack''s research found, so no tax invoice regime conditions a tax position on an invoice carrying a sequential number (see the tax codes NR-S-NA and NR-P-NA). This pack''s research did not read the Corporations Act, the Revenue Administration Act or any text on the books a Nauruan business must keep or for how long; `numbering` is `free` and `number_format` is a convention this pack proposes. A local reviewer should confirm there is no rule.',
  numbering_source_key          = 'nro-legislation',
  payment_terms_legal_reference = 'This pack''s research found no Nauruan text setting a payment term between two businesses in the absence of an agreement, or a statutory rate of late-payment interest on a commercial debt; it did not search for one. `legal_payment_days` and `late_payment_reference` are therefore empty and a seller''s terms are a matter of contract.',
  payment_terms_source_key      = 'nro-legislation',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has no true value for Nauru: it names the day a country''s general rule makes its own turnover tax chargeable, and no such tax is in force. `invoice_date` is declared as the closest commercial convention — a convention, not a rule read from a text, and not a statement about when business profits tax or the employment and services tax withholding arises (the latter on the day the payer pays the income or fee, Employment and Services Tax Q and A Guide 2022-2023, question 1).',
  tax_point_source_key          = 'est-guide',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'This pack''s research found no Nauruan law obliging a business to issue or accept an electronic invoice, and no Peppol Authority for Nauru; the Nauru Revenue Office pages read (consulted 7 November 2026) mention none, and the official legislation database (ronlaw.gov.nr) could not be searched. `obligation` is therefore `none` and `profile`, `party_scheme` and `vat_scheme` are null; no VAT identifier exists for a scheme to carry. This is an absence of evidence and a local reviewer should confirm it.',
  einvoice_source_key           = 'nro-legislation',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'july'
 where country = 'NR';
