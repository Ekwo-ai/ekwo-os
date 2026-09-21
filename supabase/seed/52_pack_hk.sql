-- Ekwo OS — Hong Kong: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/hk at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build hk`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Companies Ordinance (Cap. 622) (Department of Justice — Hong Kong e-Legislation)
--     https://www.elegislation.gov.hk/hk/cap622
--   Inland Revenue Ordinance (Cap. 112) (Department of Justice — Hong Kong e-Legislation)
--     https://www.elegislation.gov.hk/hk/cap112
--   Business Registration Ordinance (Cap. 310) (Department of Justice — Hong Kong e-Legislation)
--     https://www.elegislation.gov.hk/hk/cap310
--   Profits Tax (Inland Revenue Department)
--     https://www.ird.gov.hk/eng/tax/bus_pft.htm
--   Two-tiered Profits Tax Rates Regime (Inland Revenue Department)
--     https://www.ird.gov.hk/eng/faq/index.htm
--   Keeping Business Records (Inland Revenue Department)
--     https://www.ird.gov.hk/eng/tax/bus_rke.htm
--   Business Registration (Inland Revenue Department)
--     https://www.ird.gov.hk/eng/tax/bre.htm
--   Annual Returns of Local Private Companies (Companies Registry)
--     https://www.cr.gov.hk/en/compliance/annual-return/private-company.htm
--   SME-FRF & SME-FRS — Members' Handbook, Volume II (Hong Kong Institute of Certified Public Accountants)
--     https://www.hkicpa.org.hk/en/Standards-setting/Standards/Members-Handbook-and-Due-Process/Due-Process/Financial-reporting
--   Electronic Services — eTAX Business Tax Portal (Inland Revenue Department)
--     https://www.ird.gov.hk/eng/ese/index.htm
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('HK', 'Hong Kong', '0.1.0', date '2026-09-21', '20260917170000', 'community', null, null, '9020952ee867483f8e5f7ff32acd2ffcc93133a9d5dd8e587682f54faf03e768', '[{"key":"co-cap622","title":"Companies Ordinance (Cap. 622)","publisher":"Department of Justice — Hong Kong e-Legislation","url":"https://www.elegislation.gov.hk/hk/cap622","consulted_on":"2026-09-21","kind":"law"},{"key":"iro-cap112","title":"Inland Revenue Ordinance (Cap. 112)","publisher":"Department of Justice — Hong Kong e-Legislation","url":"https://www.elegislation.gov.hk/hk/cap112","consulted_on":"2026-09-21","kind":"law"},{"key":"bro-cap310","title":"Business Registration Ordinance (Cap. 310)","publisher":"Department of Justice — Hong Kong e-Legislation","url":"https://www.elegislation.gov.hk/hk/cap310","consulted_on":"2026-09-21","kind":"law"},{"key":"ird-profits-tax","title":"Profits Tax","publisher":"Inland Revenue Department","url":"https://www.ird.gov.hk/eng/tax/bus_pft.htm","consulted_on":"2026-09-21","kind":"guidance"},{"key":"ird-two-tiered","title":"Two-tiered Profits Tax Rates Regime","publisher":"Inland Revenue Department","url":"https://www.ird.gov.hk/eng/faq/index.htm","consulted_on":"2026-09-21","kind":"guidance"},{"key":"ird-record-keeping","title":"Keeping Business Records","publisher":"Inland Revenue Department","url":"https://www.ird.gov.hk/eng/tax/bus_rke.htm","consulted_on":"2026-09-21","kind":"guidance"},{"key":"ird-business-registration","title":"Business Registration","publisher":"Inland Revenue Department","url":"https://www.ird.gov.hk/eng/tax/bre.htm","consulted_on":"2026-09-21","kind":"guidance"},{"key":"cr-annual-return","title":"Annual Returns of Local Private Companies","publisher":"Companies Registry","url":"https://www.cr.gov.hk/en/compliance/annual-return/private-company.htm","consulted_on":"2026-09-21","kind":"guidance"},{"key":"hkicpa-sme-frf","title":"SME-FRF & SME-FRS — Members'' Handbook, Volume II","publisher":"Hong Kong Institute of Certified Public Accountants","url":"https://www.hkicpa.org.hk/en/Standards-setting/Standards/Members-Handbook-and-Due-Process/Due-Process/Financial-reporting","consulted_on":"2026-09-21","kind":"standard"},{"key":"ird-etax","title":"Electronic Services — eTAX Business Tax Portal","publisher":"Inland Revenue Department","url":"https://www.ird.gov.hk/eng/ese/index.htm","consulted_on":"2026-09-21","kind":"portal"}]'::jsonb)
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
  ('HK', 'default', 'Hong Kong reference chart of accounts', '{}'::jsonb, true, 'companies', array['HK-SME-FRS-IS', 'HK-SME-FRS-SFP']::text[], null, 'There is no legal chart of accounts in Hong Kong. Companies Ordinance (Cap. 622), Part 9 (Accounts and Audit) requires every company to keep proper accounting records sufficient to give a true and fair view of its state of affairs and to explain its transactions, and requires its directors to prepare financial statements that give a true and fair view for each financial year, prescribing no chart to get there. This chart is original: four digits, blocked so that each range reaches one line item of the statement of financial position and the income statement a company reporting under the SME-FRF & SME-FRS (Hong Kong Institute of Certified Public Accountants) presents — the simplified framework a private company that is not a specified body, stays under its size test and has the unanimous written agreement of its shareholders may report under, in place of full Hong Kong Financial Reporting Standards. Neither framework prescribes a chart of accounts, only the two statements; a company outside the SME-FRF reports the same transactions under full HKFRS and this chart ties into the same statement of financial position and statement of profit or loss either way. It carries no tax-clearing account of any kind, because there is no tax to clear — see ''From Hong Kong'' in docs/international.md.', 'co-cap622')
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
  ('HK', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('HK', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('HK', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('HK', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('HK', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('HK', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('HK', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('HK', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('HK', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('HK', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('HK', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('HK', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('HK', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('HK', 'default', '1150', 'Provisional profits tax paid', '{}'::jsonb, 'asset_current', false, null, 140),
  ('HK', 'default', '1160', 'Profits tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('HK', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 160),
  ('HK', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('HK', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('HK', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 190),
  ('HK', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 200),
  ('HK', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 210),
  ('HK', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 220),
  ('HK', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('HK', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('HK', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('HK', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('HK', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('HK', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('HK', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('HK', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('HK', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('HK', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('HK', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('HK', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('HK', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('HK', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('HK', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('HK', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('HK', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('HK', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('HK', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('HK', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('HK', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('HK', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 440),
  ('HK', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 450),
  ('HK', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 460),
  ('HK', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 470),
  ('HK', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('HK', 'default', '2050', 'Mandatory Provident Fund contributions payable', '{}'::jsonb, 'liability_current', false, null, 490),
  ('HK', 'default', '2060', 'Provision for Hong Kong profits tax', '{}'::jsonb, 'liability_current', false, null, 500),
  ('HK', 'default', '2070', 'Other tax and government charges payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('HK', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 520),
  ('HK', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 530),
  ('HK', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 540),
  ('HK', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('HK', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('HK', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 570),
  ('HK', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('HK', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 590),
  ('HK', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 600),
  ('HK', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 610),
  ('HK', 'default', '3200', 'Retained profits', '{}'::jsonb, 'equity_retained', false, null, 620),
  ('HK', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 630),
  ('HK', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 640),
  ('HK', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 650),
  ('HK', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 660),
  ('HK', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 670),
  ('HK', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 680),
  ('HK', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 690),
  ('HK', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('HK', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('HK', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('HK', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('HK', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 740),
  ('HK', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 750),
  ('HK', 'default', '6020', 'Mandatory Provident Fund contributions', '{}'::jsonb, 'expense', false, null, 760),
  ('HK', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 770),
  ('HK', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 780),
  ('HK', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 790),
  ('HK', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 800),
  ('HK', 'default', '6200', 'Business registration and licence fees', '{}'::jsonb, 'expense', false, null, 810),
  ('HK', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 820),
  ('HK', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 830),
  ('HK', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 840),
  ('HK', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 850),
  ('HK', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 860),
  ('HK', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 870),
  ('HK', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 880),
  ('HK', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 890),
  ('HK', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 900),
  ('HK', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 910),
  ('HK', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 920),
  ('HK', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 930),
  ('HK', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 940),
  ('HK', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 950),
  ('HK', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 960),
  ('HK', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 970),
  ('HK', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 980),
  ('HK', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 990),
  ('HK', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1000),
  ('HK', 'default', '6470', 'Hong Kong profits tax charge', '{}'::jsonb, 'expense', false, null, 1010),
  ('HK', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1020),
  ('HK', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1030),
  ('HK', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1040)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('HK', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('HK', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('HK', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('HK', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('HK', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('HK', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('HK', 'HK-P-NA', 'Purchase, not subject to any tax on turnover', '{}'::jsonb, 'Every purchase a Hong Kong business books — domestic, imported, or delivered from outside Hong Kong to a place outside Hong Kong', 'percent', 0, 'purchase', 'not_subject', date '1997-07-01', null, 'The purchase side of HK-S-NA: nothing a Hong Kong business buys carries a value added tax, a goods and services tax or a general sales tax to recover, because none is charged on the sale that supplies it, whether the seller is in Hong Kong or abroad. Hong Kong is a free port — the Basic Law, article 114, commits the Region to remaining one, levying no customs tariff — so an import carries no tax at the border either, other than the excise duty the Dutiable Commodities Ordinance (Cap. 109) charges on four commodities (liquor, tobacco, hydrocarbon oil and methyl alcohol), which this pack does not model: it is a duty on those specific goods and not a general tax any invoice line can carry a code for. See ''From Hong Kong'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'iro-cap112', null, null, null, null),
  ('HK', 'HK-S-NA', 'Sale, not subject to any tax on turnover', '{}'::jsonb, 'Every sale a Hong Kong business makes — domestic, exported, or delivered from outside Hong Kong to a place outside Hong Kong', 'percent', 0, 'sale', 'not_subject', date '1997-07-01', null, 'Hong Kong has never imposed a value added tax, a goods and services tax or a general tax on the sale of goods or the supply of services. A proposal for a broad-based goods and services tax was put to a five-month public consultation in 2006 and withdrawn in the face of public opposition; no such tax has been proposed again since. What a Hong Kong business pays on its trading is profits tax, charged under the Inland Revenue Ordinance (Cap. 112), section 14, on the assessable profits of a trade, profession or business carried on in Hong Kong and arising in or derived from Hong Kong — a tax on the year''s net profit, computed once for the whole business at the year end, and not a tax any single invoice carries, collects on the seller''s behalf, or is credited against on the buyer''s. There is accordingly no rate for this code to state and no box for its base to be reported in: the code exists so that every sale line still carries a tax code the engine can post, the way a ledger for a country with a real turnover tax does, and states plainly that this jurisdiction has none. 1 July 1997 is the day the Basic Law took effect and the Inland Revenue Ordinance continued in force under it (Basic Law, article 8); Hong Kong''s territorial, no-turnover-tax system dates from long before that, and is unrelated to it — the date is a convenience the pack needed for `valid_from` and not a claim about when the absence of a turnover tax began. See ''From Hong Kong'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'iro-cap112', null, null, null, null)
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
    ('HK-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('HK-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('HK-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('HK-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'HK' and t.code = v.tax_code
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
  ('HK-SME-FRS-IS', 'HK', 'default', 'Income statement', 'income_statement', 'SME-FRS', date '1970-01-01', null, 'SME-FRS requires an income statement and not a statement of comprehensive income: an entity that qualifies to report under the SME-FRF & SME-FRS (Hong Kong Institute of Certified Public Accountants) carries no item of other comprehensive income under the standard''s own measurement rules — no revaluation of property, plant and equipment, no fair-value movement on an available-for-sale investment — so nothing would ever appear below the profit for the year, and the standard does not ask for the second statement. The numbering below is this pack''s own.', null),
  ('HK-SME-FRS-SFP', 'HK', 'default', 'Statement of financial position', 'balance_sheet', 'SME-FRS', date '1970-01-01', null, 'Companies Ordinance (Cap. 622), Part 9 requires the directors of every company to prepare, for each financial year, financial statements that give a true and fair view of the state of affairs of the company, and prescribes no format to reach it. SME-FRS, the standard a company reporting under the SME-FRF & SME-FRS (Hong Kong Institute of Certified Public Accountants) applies in place of full Hong Kong Financial Reporting Standards, presents financial position by current and non-current assets and liabilities and offers no revaluation model for property, plant and equipment — every item is carried at cost less accumulated depreciation and impairment, which is why this chart carries no revaluation reserve line. The numbering below and the ranges each line reads are original to this pack: there is no legal chart of accounts to number against, so the blocks are this pack''s own, the same way the British and Australian packs number theirs.', null)
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
  ('HK-SME-FRS-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('HK-SME-FRS-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'E-RET', 'E-TOT', 'Retained profits', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'L-C-TAX', 'L-C', 'Current tax liabilities', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('HK-SME-FRS-SFP', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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
    ('HK-SME-FRS-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('HK-SME-FRS-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('HK-SME-FRS-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('HK-SME-FRS-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('HK-SME-FRS-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('HK-SME-FRS-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('HK-SME-FRS-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('HK-SME-FRS-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('HK-SME-FRS-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('HK-SME-FRS-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('HK-SME-FRS-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('HK-SME-FRS-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('HK-SME-FRS-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('HK-SME-FRS-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('HK-SME-FRS-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('HK-SME-FRS-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('HK-SME-FRS-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('HK', 'Hong Kong', '{}'::jsonb, array['en']::text[], 'HKD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Hong Kong has never levied a value added tax, a goods and services tax or a general tax on the sale of goods or services (Inland Revenue Department; a proposal for a goods and services tax was put to public consultation in 2006 and withdrawn), so no statute conditions the deductibility of a tax, or anything else, on an invoice carrying a sequential number. What every person carrying on a trade, profession or business has to do is keep sufficient records, in English or Chinese, to enable assessable profits to be readily ascertained (Inland Revenue Ordinance (Cap. 112), section 51C(1)), for a period of not less than seven years (section 51C(2)), or face a fine of up to $100,000 (section 51C(5)) — a duty about what is kept and not about how a document already issued is shaped. `numbering` is therefore `free`, not a gap this pack leaves for somebody else to fill: `number_format` is a convention it proposes, the same one a business free to choose its own numbering would reach for.',
  numbering_source_key          = 'iro-cap112',
  payment_terms_legal_reference = 'No Hong Kong statute sets a payment term between two businesses in the absence of an agreement, or a rate of interest on a commercial debt paid late: the Late Payment of Commercial Debts (Interest) Act 1998 is a United Kingdom statute and was never extended to Hong Kong, and no local equivalent has replaced it. `legal_payment_days` and `late_payment_reference` are therefore empty, and a seller''s own terms are a matter of contract, stated on the document and not derived from a rule this pack could cite.',
  payment_terms_source_key      = 'co-cap622',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in Hong Kong: it names the day a country''s general rule makes its own turnover tax chargeable, and Hong Kong charges none. `invoice_date` is declared as the closest general commercial convention — revenue is ordinarily invoiced at or shortly after the point HKFRS 15 / SME-FRF & SME-FRS recognise it, on satisfying the performance obligation — and not as a rule read from a text; see ''From Hong Kong'' in docs/international.md, which sets this out as a gap in what the field can honestly say of a territory with no transaction tax at all.',
  tax_point_source_key          = 'hkicpa-sme-frf',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Hong Kong statute obliges a business to issue or to accept an electronic invoice, and no Peppol Authority is listed for Hong Kong (OpenPeppol, list of Peppol Authorities, consulted 2026-09-21): unlike Singapore''s InvoiceNow or Australia and New Zealand''s PINT A-NZ, Hong Kong has not joined the network. `profile`, `party_scheme` and `vat_scheme` are therefore null and not merely unresearched: there is no domestic profile to name and no VAT identifier for a scheme to carry, since Hong Kong levies no value added tax and a party is addressed, where it is addressed at all, by its Business Registration Number under the Business Registration Ordinance (Cap. 310) — a number this pack''s chart carries as an invoice mention and not as an e-invoicing party scheme, which is a different claim from the one a Peppol pack makes.',
  einvoice_source_key           = 'bro-cap310',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'april'
 where country = 'HK';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('HK', 'business-registration-number', 'always', 'Business Registration Number: {business_registration_number}', '{}'::jsonb, 10, date '1970-01-01', null, 'Business Registration Ordinance (Cap. 310) requires a person carrying on a business in Hong Kong to apply for business registration within one month of commencement and to display the business registration certificate at the place of business; the ordinance does not itself require the number on an invoice. The mention is usual commercial practice, not a numbering or invoicing rule of the kind `documents.mentions` records for a VAT country, and this pack states it as such rather than dressing a custom as a statute — see ''From Hong Kong'' in docs/international.md.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
