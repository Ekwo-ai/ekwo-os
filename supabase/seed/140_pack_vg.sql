-- Ekwo OS — British Virgin Islands: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/vg at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build vg`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Inland Revenue Department (Government of the Virgin Islands)
--     https://gov.vg/inland-revenue-department
--   Laws of the Virgin Islands (statute index: BVI Business Companies Act 2004, Payroll Taxes Act 2004, Income Tax Act) (Government of the Virgin Islands)
--     https://laws.gov.vg
--   BVI Business Companies Requirements for New Annual Returns (Maples Group)
--     https://maples.com/en/knowledge-centre/2023/9/bvi-business-companies-requirements-for-new-annual-returns
--   BVI Business Companies — Financial reporting rules (Mourant)
--     https://www.mourant.com/guides/bvi-business-companies-financial-reporting-rules/
--   Preparing and filing an annual return in the BVI (Vistra)
--     https://www.vistra.com/insights/preparing-and-filing-annual-return-bvi-what-companies-need-know
--   British Virgin Islands Highlights 2025 (Deloitte)
--     https://www.deloitte.com/content/dam/assets-shared/docs/services/tax/2025/dttl-tax-britishvirginislandshighlights-2025.pdf
--   British Virgin Islands Requires Electronic Filing Using New Tax System from December 2023 (Orbitax)
--     https://orbitax.com/news/archive.php/British-Virgin-Islands-Require-54174
--   Tax administration system — online tax registration (eregisterfortax.gov.vg) (Inland Revenue Department, Government of the Virgin Islands)
--     https://www.eregisterfortax.gov.vg
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('VG', 'British Virgin Islands', '0.1.0', date '2026-10-10', '20260929141500', 'community', null, null, 'd935682d8b78d925488d9a6beba18b43249f996b9612294368a867707e1744c1', '[{"key":"ird-vg","title":"Inland Revenue Department","publisher":"Government of the Virgin Islands","url":"https://gov.vg/inland-revenue-department","consulted_on":"2026-10-10","kind":"guidance"},{"key":"vg-laws","title":"Laws of the Virgin Islands (statute index: BVI Business Companies Act 2004, Payroll Taxes Act 2004, Income Tax Act)","publisher":"Government of the Virgin Islands","url":"https://laws.gov.vg","consulted_on":"2026-10-10","kind":"law"},{"key":"maples-fr","title":"BVI Business Companies Requirements for New Annual Returns","publisher":"Maples Group","url":"https://maples.com/en/knowledge-centre/2023/9/bvi-business-companies-requirements-for-new-annual-returns","consulted_on":"2026-10-10","kind":"guidance"},{"key":"mourant-fr","title":"BVI Business Companies — Financial reporting rules","publisher":"Mourant","url":"https://www.mourant.com/guides/bvi-business-companies-financial-reporting-rules/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"vistra-fr","title":"Preparing and filing an annual return in the BVI","publisher":"Vistra","url":"https://www.vistra.com/insights/preparing-and-filing-annual-return-bvi-what-companies-need-know","consulted_on":"2026-10-10","kind":"guidance"},{"key":"deloitte-vg-2025","title":"British Virgin Islands Highlights 2025","publisher":"Deloitte","url":"https://www.deloitte.com/content/dam/assets-shared/docs/services/tax/2025/dttl-tax-britishvirginislandshighlights-2025.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"orbitax-vg-etax","title":"British Virgin Islands Requires Electronic Filing Using New Tax System from December 2023","publisher":"Orbitax","url":"https://orbitax.com/news/archive.php/British-Virgin-Islands-Require-54174","consulted_on":"2026-10-10","kind":"guidance"},{"key":"ird-eregister","title":"Tax administration system — online tax registration (eregisterfortax.gov.vg)","publisher":"Inland Revenue Department, Government of the Virgin Islands","url":"https://www.eregisterfortax.gov.vg","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('VG', 'default', 'British Virgin Islands reference chart of accounts', '{}'::jsonb, true, 'companies', array['VG-FR-BS', 'VG-FR-IS']::text[], null, 'The British Virgin Islands prescribe no chart of accounts. BVI Business Companies Act 2004, section 98 requires a company to keep records that explain its transactions and enable its financial position to be determined, and section 98A with the BVI Business Companies (Financial Return) Order 2023 requires a company that is not exempt to give its registered agent an annual financial return — a balance sheet and an income statement — within nine months of its financial year end, with no audit and no mandated accounting framework (Maples, Mourant, Vistra; the statutory text itself was not opened). This chart is original: four digits, blocked so that each range reaches one line of an IFRS for SMEs balance sheet and income statement, the form the financial return can be filled in from. Its only government-levy accounts are those for payroll tax and social contributions, which are payroll liabilities and not a tax on sales; see ''From British Virgin Islands'' in docs/international.md.', 'maples-fr')
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
  ('VG', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('VG', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('VG', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('VG', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('VG', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('VG', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('VG', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('VG', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('VG', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('VG', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('VG', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('VG', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('VG', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('VG', 'default', '1150', 'Government fees and payroll tax paid in advance', '{}'::jsonb, 'asset_current', false, null, 140),
  ('VG', 'default', '1160', 'Payroll tax overpaid and recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('VG', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 160),
  ('VG', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('VG', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('VG', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 190),
  ('VG', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 200),
  ('VG', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 210),
  ('VG', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 220),
  ('VG', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('VG', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('VG', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('VG', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('VG', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('VG', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('VG', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('VG', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('VG', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('VG', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('VG', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('VG', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('VG', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('VG', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('VG', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('VG', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('VG', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('VG', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('VG', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('VG', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('VG', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('VG', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 440),
  ('VG', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 450),
  ('VG', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 460),
  ('VG', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 470),
  ('VG', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('VG', 'default', '2050', 'Social security and National Health Insurance contributions payable', '{}'::jsonb, 'liability_current', false, null, 490),
  ('VG', 'default', '2060', 'Payroll tax payable — employees'' share withheld', '{}'::jsonb, 'liability_current', false, null, 500),
  ('VG', 'default', '2061', 'Payroll tax payable — employer''s share', '{}'::jsonb, 'liability_current', false, null, 510),
  ('VG', 'default', '2070', 'Other government charges payable', '{}'::jsonb, 'liability_current', false, null, 520),
  ('VG', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 530),
  ('VG', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 540),
  ('VG', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 550),
  ('VG', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('VG', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 570),
  ('VG', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('VG', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 590),
  ('VG', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 600),
  ('VG', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 610),
  ('VG', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 620),
  ('VG', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 630),
  ('VG', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 640),
  ('VG', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 650),
  ('VG', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 660),
  ('VG', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 670),
  ('VG', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 680),
  ('VG', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 690),
  ('VG', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 700),
  ('VG', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('VG', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('VG', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('VG', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 740),
  ('VG', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 750),
  ('VG', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 760),
  ('VG', 'default', '6020', 'Social security and National Health Insurance contributions (employer)', '{}'::jsonb, 'expense', false, null, 770),
  ('VG', 'default', '6025', 'Payroll tax (employer''s share)', '{}'::jsonb, 'expense', false, null, 780),
  ('VG', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 790),
  ('VG', 'default', '6100', 'Rent and property charges', '{}'::jsonb, 'expense', false, null, 800),
  ('VG', 'default', '6105', 'Land and house tax', '{}'::jsonb, 'expense', false, null, 810),
  ('VG', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 820),
  ('VG', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 830),
  ('VG', 'default', '6200', 'Registered agent, annual registration and licence fees', '{}'::jsonb, 'expense', false, null, 840),
  ('VG', 'default', '6210', 'Audit and assurance fees', '{}'::jsonb, 'expense', false, null, 850),
  ('VG', 'default', '6220', 'Accounting and company administration fees', '{}'::jsonb, 'expense', false, null, 860),
  ('VG', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 870),
  ('VG', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 880),
  ('VG', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 890),
  ('VG', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 900),
  ('VG', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 910),
  ('VG', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 920),
  ('VG', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 930),
  ('VG', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 940),
  ('VG', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 950),
  ('VG', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 960),
  ('VG', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 970),
  ('VG', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 980),
  ('VG', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 990),
  ('VG', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 1000),
  ('VG', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 1010),
  ('VG', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 1020),
  ('VG', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1030),
  ('VG', 'default', '6470', 'Income tax expense (foreign and other taxes on income)', '{}'::jsonb, 'expense', false, null, 1040),
  ('VG', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1050),
  ('VG', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1060),
  ('VG', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1070)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('VG', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('VG', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('VG', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('VG', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('VG', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('VG', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('VG', 'VG-P-NA', 'Purchase, not subject to any tax on turnover', '{}'::jsonb, 'Every purchase a Virgin Islands business books — domestic, imported, or delivered from outside the territory to a place outside it', 'percent', 0, 'purchase', 'not_subject', date '2005-01-01', null, 'The purchase side of VG-S-NA: nothing a Virgin Islands business buys carries a value added tax or general sales tax to recover, because none is levied on the sale that supplies it (Inland Revenue Department, gov.vg; Deloitte, British Virgin Islands Highlights 2025). Imported goods are subject to customs import duty at ad valorem rates (practitioner summaries; the tariff was not opened), a duty on goods crossing the border and not a tax an invoice line can carry a recoverable code for, which this pack does not model. See ''From British Virgin Islands'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'ird-vg', null, null, null, null),
  ('VG', 'VG-S-NA', 'Sale, not subject to any tax on turnover', '{}'::jsonb, 'Every sale a Virgin Islands business makes — domestic, exported, or delivered from outside the territory to a place outside it', 'percent', 0, 'sale', 'not_subject', date '2005-01-01', null, 'The Virgin Islands levy no value added tax, goods and services tax or general sales tax: the Inland Revenue Department (gov.vg, consulted 2026-10-10) lists the taxes it administers — payroll tax, stamp duty, self-drive motor vehicle tax, hotel accommodation tax, land and house tax, liquor licence, cheque duty and service charges — and no tax on sales, and Deloitte''s British Virgin Islands Highlights 2025 states that the territory does not levy VAT or sales tax. Income tax is legislated but set at a zero rate (practitioner summaries; the statute was not opened), and a BVI business company is generally exempt from income taxation (Deloitte). What the territory takes instead lies outside this pack: payroll tax under the Payroll Taxes Act 2004 (employer 2% or 6% by employer class, employee 8% withheld by the employer, on remuneration above USD 10,000 a year, monthly return P6 due within 21 days of month end — rates and deadline from Deloitte and registered-agent summaries; the P6 form itself could not be opened), stamp duty, hotel accommodation tax and import duties. None is a tax an invoice line carries. There is accordingly no rate for this code to state and no box for its base: it exists so that every sale line carries a tax code the engine can post. `valid_from` 2005-01-01 is a convenience (the year income tax was set at zero and payroll tax introduced), not a claim about when the absence began. See ''From British Virgin Islands'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'ird-vg', null, null, null, null)
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
    ('VG-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('VG-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('VG-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('VG-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'VG' and t.code = v.tax_code
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
  ('VG-FR-BS', 'VG', 'default', 'Balance sheet (statement of financial position)', 'balance_sheet', 'IFRS for SMEs', date '1970-01-01', null, 'BVI Business Companies Act 2004, section 98A, with the BVI Business Companies (Financial Return) Order 2023 (in force 1 January 2023), requires a company that is not exempt to produce a financial return — an unaudited balance sheet and income statement — and to give it to its registered agent within nine months of the end of its financial year; the return is not filed with the Registrar or made public. Neither the Act nor the Order imposes an accounting framework. This statement is laid out in the IFRS for SMEs form (current and non-current assets and liabilities, equity), which a company can fill in the financial return from; the line numbering and the ranges each line reads are this pack''s own, and the Order''s own schedule of lines was not opened in this session — see ''From British Virgin Islands'' in docs/international.md.', null),
  ('VG-FR-IS', 'VG', 'default', 'Income statement', 'income_statement', 'IFRS for SMEs', date '1970-01-01', null, 'The financial return required by BVI Business Companies Act 2004, section 98A and the BVI Business Companies (Financial Return) Order 2023 comprises an income statement beside the balance sheet: revenue, cost of sales, gross profit, operating expenses, other income and expense, income tax expense and net income, as registered-agent and law-firm summaries of the Order''s form describe it. No framework is imposed; this statement follows the IFRS for SMEs income statement, with a single result line and no other comprehensive income. The numbering is this pack''s own, and the Order''s schedule itself was not opened in this session.', null)
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
  ('VG-FR-BS', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-C', null, 'Current assets', '{}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'A-TOT', null, 'Total assets', '{}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'E-TOT', null, 'Total equity', '{}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'L-C-TAX', 'L-C', 'Payroll tax and other government charges payable', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'L-C', null, 'Current liabilities', '{}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('VG-FR-BS', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('VG-FR-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'OPEX', null, 'Operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'OTH-EXP', null, 'Finance costs and other expenses', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'PRE-TAX', null, 'Profit (loss) before income tax', '{}'::jsonb, 80, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR', 'OTH-EXP']::text[], null, null, null),
  ('VG-FR-IS', 'TAX', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('VG-FR-IS', 'PROFIT', null, 'Net income (loss) for the year', '{}'::jsonb, 100, 1, true, array['PRE-TAX']::text[], array['TAX']::text[], null, null, null)
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
    ('VG-FR-BS', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('VG-FR-BS', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('VG-FR-BS', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('VG-FR-BS', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('VG-FR-BS', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('VG-FR-BS', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('VG-FR-BS', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('VG-FR-BS', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('VG-FR-BS', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('VG-FR-BS', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('VG-FR-BS', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('VG-FR-BS', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('VG-FR-BS', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('VG-FR-BS', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('VG-FR-BS', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('VG-FR-BS', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('VG-FR-BS', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('VG-FR-BS', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('VG-FR-BS', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any'),
    ('VG-FR-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('VG-FR-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('VG-FR-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('VG-FR-IS', 'OPEX', 10, 'code_range', '6000', '6399', null, 'any'),
    ('VG-FR-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('VG-FR-IS', 'OTH-EXP', 10, 'code_range', '6400', '6469', null, 'any'),
    ('VG-FR-IS', 'OTH-EXP', 20, 'code_range', '6480', '6799', null, 'any'),
    ('VG-FR-IS', 'TAX', 10, 'code_range', '6470', '6479', null, 'any')
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
  ('VG', 'British Virgin Islands', '{}'::jsonb, array['en']::text[], 'USD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'The Virgin Islands levy no value added tax, goods and services tax or general sales tax (Inland Revenue Department, gov.vg, which lists payroll tax, stamp duty, hotel accommodation tax and land and house tax among the taxes it administers and no tax on sales; Deloitte, British Virgin Islands Highlights 2025: ''The BVI does not levy VAT or sales tax''), so no tax statute conditions anything on an invoice carrying a sequential number. The record-keeping duty of the BVI Business Companies Act 2004, section 98 concerns what a company keeps, not how an issued invoice is numbered. `numbering` is therefore `free` and `number_format` is a convention this pack proposes, not a rule it read.',
  numbering_source_key          = 'ird-vg',
  payment_terms_legal_reference = 'This pack found no Virgin Islands statute that sets a payment term between two businesses or a rate of interest on a late commercial debt; the search covered the Inland Revenue Department''s pages and the practitioner summaries listed in the register, not a clause-by-clause read of the statute book (laws.gov.vg), so this is an absence of finding and not a proven absence of law. `legal_payment_days` and `late_payment_reference` are empty and a seller''s terms are a matter of contract.',
  payment_terms_source_key      = 'vg-laws',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in the Virgin Islands: it names the day a country''s general rule makes its own turnover tax chargeable, and the territory charges none. `invoice_date` is declared as the closest general commercial convention (revenue is ordinarily invoiced at or shortly after the point IFRS for SMEs section 23 recognises it), not as a rule read from a text; see ''From British Virgin Islands'' in docs/international.md.',
  tax_point_source_key          = 'ird-vg',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Virgin Islands statute found by this pack obliges a business to issue or accept an electronic invoice, and no Peppol Authority for the territory appeared in the OpenPeppol authority lists as retrieved on 2026-10-10 (partial snippets; a few BVI-registered participants do appear in the Peppol Directory, which does not imply a local authority or mandate). `profile`, `party_scheme` and `vat_scheme` are therefore null: there is no domestic profile to name and no VAT identifier to carry, since no value added tax is levied. Taxpayers do file payroll tax, self-drive motor vehicle tax and hotel accommodation tax returns electronically through the Inland Revenue Department''s tax system since 1 December 2023 (Orbitax), but those are periodic returns, not invoices.',
  einvoice_source_key           = 'orbitax-vg-etax',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'VG';
