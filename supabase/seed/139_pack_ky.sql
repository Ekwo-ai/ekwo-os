-- Ekwo OS — Cayman Islands: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ky at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ky`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Companies Act (2026 Revision) (Cayman Islands Government — Legislation)
--     https://legislation.gov.ky/cms/images/LEGISLATION/PRINCIPAL/1961/1961-0003/1961-0003_2026%20Revision.pdf
--   Customs Tariff Act (2026 Revision) (Cayman Islands Government — Legislation)
--     https://legislation.gov.ky/cms/images/LEGISLATION/PRINCIPAL/2012/2012-0001/2012-0001.pdf
--   Tax Information Authority — FAQs (Department for International Tax Cooperation)
--     https://www.ditc.ky/news-updates/faqs/
--   Cayman Islands: no new taxes proposed in the 2026-2027 budget (KPMG (Tax News Flash, 7 January 2026))
--     https://kpmg.com/us/en/taxnewsflash/news/2026/01/tnf-cayman-islands-no-new-taxes-proposed-in-2026-2027-budget.html
--   Cayman Islands — Corporate — Other taxes (PwC Worldwide Tax Summaries)
--     https://taxsummaries.pwc.com/cayman-islands/corporate/other-taxes
--   IFRS for SMEs Accounting Standard (IFRS Foundation (IASB))
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   DITC Portal — online application of the Tax Information Authority (Department for International Tax Cooperation)
--     https://ditcportal.secure.ky/login
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KY', 'Cayman Islands', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, '59a0bf3e2cc0b28e0e3eb1bf4ed300883cf562b39b5823d2b9ce68314cdaacfa', '[{"key":"companies-act","title":"Companies Act (2026 Revision)","publisher":"Cayman Islands Government — Legislation","url":"https://legislation.gov.ky/cms/images/LEGISLATION/PRINCIPAL/1961/1961-0003/1961-0003_2026%20Revision.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"customs-tariff-act","title":"Customs Tariff Act (2026 Revision)","publisher":"Cayman Islands Government — Legislation","url":"https://legislation.gov.ky/cms/images/LEGISLATION/PRINCIPAL/2012/2012-0001/2012-0001.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"ditc-faqs","title":"Tax Information Authority — FAQs","publisher":"Department for International Tax Cooperation","url":"https://www.ditc.ky/news-updates/faqs/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"kpmg-budget-2026-27","title":"Cayman Islands: no new taxes proposed in the 2026-2027 budget","publisher":"KPMG (Tax News Flash, 7 January 2026)","url":"https://kpmg.com/us/en/taxnewsflash/news/2026/01/tnf-cayman-islands-no-new-taxes-proposed-in-2026-2027-budget.html","consulted_on":"2026-10-10","kind":"guidance"},{"key":"pwc-tax-summaries","title":"Cayman Islands — Corporate — Other taxes","publisher":"PwC Worldwide Tax Summaries","url":"https://taxsummaries.pwc.com/cayman-islands/corporate/other-taxes","consulted_on":"2026-10-10","kind":"guidance"},{"key":"ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation (IASB)","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-10","kind":"standard"},{"key":"ditc-portal","title":"DITC Portal — online application of the Tax Information Authority","publisher":"Department for International Tax Cooperation","url":"https://ditcportal.secure.ky/login","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('KY', 'default', 'Cayman Islands reference chart of accounts', '{}'::jsonb, true, 'companies', array['KY-IFRS-SME-IS', 'KY-IFRS-SME-SFP']::text[], null, 'There is no legal chart of accounts in the Cayman Islands. Companies Act (2026 Revision), section 59(1) requires every company to keep proper books of account, material underlying documentation (contracts and invoices) included, covering all sums received and expended, all sales and purchases of goods, and assets and liabilities; section 59(2) deems the books not proper unless they give a true and fair view of the company''s affairs and explain its transactions; section 59(3) requires them to be retained for a minimum of five years from the date they are prepared. No reporting framework is imposed, so this chart is original and IFRS-inspired: four digits, blocked so that each range reaches one line of the statement of financial position and the income statement presented in the style of IFRS for SMEs (IASB). It carries no tax account of any kind: the Cayman Islands levies no sales tax, no income tax and no corporate tax (see taxes.json). See ''From Cayman Islands'' in docs/international.md.', 'companies-act')
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
  ('KY', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('KY', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('KY', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('KY', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('KY', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('KY', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('KY', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('KY', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('KY', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('KY', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('KY', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('KY', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('KY', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('KY', 'default', '1150', 'Customs duty deposits and prepayments', '{}'::jsonb, 'asset_current', false, null, 140),
  ('KY', 'default', '1160', 'Sundry receivables', '{}'::jsonb, 'asset_current', false, null, 150),
  ('KY', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 160),
  ('KY', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('KY', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('KY', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 190),
  ('KY', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 200),
  ('KY', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 210),
  ('KY', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 220),
  ('KY', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('KY', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('KY', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('KY', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('KY', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('KY', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('KY', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('KY', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('KY', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('KY', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('KY', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('KY', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('KY', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('KY', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('KY', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('KY', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('KY', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('KY', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('KY', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('KY', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('KY', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 430),
  ('KY', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 440),
  ('KY', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 450),
  ('KY', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 460),
  ('KY', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 470),
  ('KY', 'default', '2050', 'Pension contributions payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('KY', 'default', '2060', 'Government fees and levies payable', '{}'::jsonb, 'liability_current', false, null, 490),
  ('KY', 'default', '2070', 'Import duty and other government charges payable', '{}'::jsonb, 'liability_current', false, null, 500),
  ('KY', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 510),
  ('KY', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 520),
  ('KY', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 530),
  ('KY', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 540),
  ('KY', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('KY', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('KY', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 570),
  ('KY', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 580),
  ('KY', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 590),
  ('KY', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 600),
  ('KY', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 610),
  ('KY', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 620),
  ('KY', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 630),
  ('KY', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 640),
  ('KY', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 650),
  ('KY', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 660),
  ('KY', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 670),
  ('KY', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 680),
  ('KY', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 690),
  ('KY', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('KY', 'default', '5025', 'Import duty and customs charges on goods purchased', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('KY', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('KY', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 730),
  ('KY', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 740),
  ('KY', 'default', '6020', 'Pension contributions', '{}'::jsonb, 'expense', false, null, 750),
  ('KY', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 760),
  ('KY', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 770),
  ('KY', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 780),
  ('KY', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 790),
  ('KY', 'default', '6140', 'Customs duty on non-trading imports', '{}'::jsonb, 'expense', false, null, 800),
  ('KY', 'default', '6200', 'Trade licence and registry fees', '{}'::jsonb, 'expense', false, null, 810),
  ('KY', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 820),
  ('KY', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 830),
  ('KY', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 840),
  ('KY', 'default', '6240', 'Registered office and corporate services fees', '{}'::jsonb, 'expense', false, null, 850),
  ('KY', 'default', '6250', 'Work permit and immigration fees', '{}'::jsonb, 'expense', false, null, 860),
  ('KY', 'default', '6260', 'Annual regulatory and filing fees', '{}'::jsonb, 'expense', false, null, 870),
  ('KY', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 880),
  ('KY', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 890),
  ('KY', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 900),
  ('KY', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 910),
  ('KY', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 920),
  ('KY', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 930),
  ('KY', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 940),
  ('KY', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 950),
  ('KY', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 960),
  ('KY', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 970),
  ('KY', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 980),
  ('KY', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 990),
  ('KY', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1000),
  ('KY', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1010),
  ('KY', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1020),
  ('KY', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1030),
  ('KY', 'default', '6470', 'Government fees and licences', '{}'::jsonb, 'expense', false, null, 1040),
  ('KY', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1050),
  ('KY', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1060)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KY', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('KY', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('KY', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('KY', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('KY', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('KY', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('KY', 'KY-P-NA', 'Purchase, not subject to any sales tax', '{}'::jsonb, 'Every purchase a Cayman Islands business books — domestic or imported', 'percent', 0, 'purchase', 'not_subject', date '1962-01-01', null, 'The Cayman Islands has no value added tax, goods and services tax or general tax on sales: the Tax Information Authority states that ''the Cayman Islands does not have direct taxes'' (DITC FAQs), the government''s 2026-2027 budget proposed no new taxes (KPMG Tax News Flash, 7 January 2026), and PwC''s tax summary records ''no VAT'' with the State''s revenue coming from import duty, stamp duty and fees (all consulted 2026-10-10). The code exists so that every line still carries a tax code the engine can post, and states that this jurisdiction has none. On the purchase side there is nothing to recover. Goods imported pay customs duty (Customs Tariff Act (2026 Revision), section 3(1), Schedule 1) as a cost of the goods, booked by the importer to account 5025, outside the tax engine; some goods enter duty-free under Schedule 2 (section 3(2)), and a package tax applies under Schedule 3 (section 3(3)). See ''From Cayman Islands'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'ditc-faqs', null, null, null, null),
  ('KY', 'KY-S-NA', 'Sale, not subject to any sales tax', '{}'::jsonb, 'Every sale a Cayman Islands business makes — domestic or exported', 'percent', 0, 'sale', 'not_subject', date '1962-01-01', null, 'The Cayman Islands has no value added tax, goods and services tax or general tax on sales: the Tax Information Authority states that ''the Cayman Islands does not have direct taxes'' (DITC FAQs), the government''s 2026-2027 budget proposed no new taxes (KPMG Tax News Flash, 7 January 2026), and PwC''s tax summary records ''no VAT'' with the State''s revenue coming from import duty, stamp duty and fees (all consulted 2026-10-10). The code exists so that every line still carries a tax code the engine can post, and states that this jurisdiction has none. What the jurisdiction levies instead, outside this pack, is import duty at the border — charged through Customs on goods imported and enumerated in Schedule 1 of the Customs Tariff Act (2026 Revision), section 3(1), at the rates the Schedule specifies (22 % for most headings, other rates for some) — and stamp duty. Neither is a tax a sales invoice carries. `valid_from` 1962-01-01 is a convenience, not a claim about when the absence of a sales tax began. See ''From Cayman Islands'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'ditc-faqs', null, null, null, null)
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
    ('KY-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KY-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KY-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KY-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KY' and t.code = v.tax_code
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
  ('KY-IFRS-SME-IS', 'KY', 'default', 'Income statement', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Companies Act (2026 Revision), section 59 prescribes no income statement format; the Cayman Islands imposes no income, corporate or other direct tax, so this statement has no tax expense line. It presents revenue, cost of sales, other income, operating expenses and depreciation in the single-statement shape IFRS for SMEs (IASB) permits an entity with no other comprehensive income. The line numbering is original to this pack.', null),
  ('KY-IFRS-SME-SFP', 'KY', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'Companies Act (2026 Revision), section 59(1) and (2) requires every company to keep proper books of account — contracts and invoices included — and deems them not proper unless they give a true and fair view of the company''s affairs and explain its transactions; it prescribes no financial-statement format and no accounting framework. This statement follows the presentation of IFRS for SMEs (IASB): current and non-current assets and liabilities, equity, with the result for the year shown as its own unallocated line until closing. The line numbering and the ranges each line reads are original to this pack, because no legal chart exists to number against. See the README.', null)
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
  ('KY-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('KY-IFRS-SME-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Retained profits', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('KY-IFRS-SME-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
    ('KY-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('KY-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('KY-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('KY-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('KY-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('KY-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('KY-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('KY-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('KY-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('KY-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('KY-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('KY-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('KY-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('KY-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2069', null, 'any'),
    ('KY-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('KY-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('KY', 'Cayman Islands', '{}'::jsonb, array['en']::text[], 'KYD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'The Cayman Islands has no value added tax, goods and services tax or general sales tax (Tax Information Authority FAQs: ''the Cayman Islands does not have direct taxes''; PwC Worldwide Tax Summaries: ''There is no VAT imposed in the Cayman Islands''), so no tax statute conditions anything on a sequential invoice number. What the law requires is proper books of account including contracts and invoices, retained for at least five years (Companies Act (2026 Revision), section 59(1) and (3)): a duty about what is kept, not about how an issued document is numbered. `numbering` is therefore `free` and `number_format` is a convention this pack proposes.',
  numbering_source_key          = 'companies-act',
  payment_terms_legal_reference = 'No statute read for this pack sets a payment term between businesses, or interest on a late commercial debt, in the Cayman Islands; the Customs Tariff Act and the Companies Act, the two texts opened, contain none. `legal_payment_days` and `late_payment_reference` are empty: a seller''s terms are a matter of contract. This is an absence of a text found, not proof that no other law exists; a local accountant should confirm.',
  payment_terms_source_key      = 'companies-act',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in the Cayman Islands: it names the day a general turnover tax becomes chargeable, and there is none. `invoice_date` is declared as the closest general commercial convention (revenue is ordinarily invoiced at or near the point IFRS for SMEs recognises it), not as a rule read from a text. Import duty is chargeable on importation under the Customs Tariff Act (2026 Revision), section 3(1), a customs event outside this pack. See ''From Cayman Islands'' in docs/international.md.',
  tax_point_source_key          = 'ifrs-sme',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Cayman Islands statute read for this pack obliges a business to issue or accept an electronic invoice: the Companies Act (2026 Revision), section 59, requires proper books including invoices and says nothing of their form, and the Cayman Islands levies no value added tax for an e-invoice to report. No Peppol Authority for the Cayman Islands was found on the OpenPeppol list of authorities (not opened in this session; to be confirmed). `profile`, `party_scheme` and `vat_scheme` are null: there is no domestic profile and no VAT identifier to carry.',
  einvoice_source_key           = 'companies-act',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KY';
