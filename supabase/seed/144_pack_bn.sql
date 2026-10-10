-- Ekwo OS — Brunei Darussalam: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/bn at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build bn`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Income Tax Act (Chapter 35), 2021 Edition (B.L.R.O. 1/2024) (Attorney General's Chambers, Brunei Darussalam — copy published by the Ministry of Finance and Economy)
--     https://www.mof.gov.bn/wp-content/uploads/2025/10/TR_Relevant-Acts_Income-Tax-Act-Chapter-35.pdf
--   Income Tax Public Ruling PR No. 01/2021 — Keeping of Books of Accounts, second edition (Revenue Division, Ministry of Finance and Economy)
--     https://www.mof.gov.bn/wp-content/uploads/2025/10/Public-Ruling-PR5.pdf
--   Types of taxes — Income Tax (Revenue Division, Ministry of Finance and Economy)
--     https://www.mof.gov.bn/div_revenue_typesoftaxes_incometax/
--   Frequently asked questions — Corporate Tax (Revenue Division, Ministry of Finance and Economy)
--     https://www.mof.gov.bn/div_revenue_faq_corporatetax/
--   Types of taxes — Stamp Duty (Revenue Division, Ministry of Finance and Economy)
--     https://www.mof.gov.bn/div_revenue_typesoftaxes_stampduty/
--   Press release: Amendments to the Customs Import and Excise Duties effective 1st April 2017 (Ministry of Finance)
--     https://business.mofe.gov.bn/wp-content/uploads/2025/11/Press-Release-on-Amendments-to-Customs-Import-and-Excise-Duties.pdf
--   Brunei Darussalam Accounting Standards — Non Public Interest Entities (BDAS NON-PIE) (Brunei Darussalam Accounting Standards Council)
--     https://bdasc.mof.gov.bn/wp-content/uploads/2025/08/BDAS-for-Non-PIEs.pdf
--   Notice No. 1/2014 — Accounting Standards (adoption of IFRS by public accountable entities from 1 January 2014) (Brunei Darussalam Accounting Standards Council)
--     https://bdasc.mof.gov.bn/wp-content/uploads/2025/08/1-January-2014-IFRS-Notice.pdf
--   FAQs on BDAS (Brunei Darussalam Accounting Standards Council)
--     https://bdasc.mof.gov.bn/faqs-on-bdas/
--   Peppol Authorities (OpenPeppol)
--     https://peppol.org/about/peppol-authorities/
--   One Common Portal (Ministry of Finance and Economy)
--     https://ocp.mofe.gov.bn/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BN', 'Brunei Darussalam', '0.1.0', date '2026-10-10', '20260917170000', 'community', null, null, '3b527b121e9063edf7090ee9307c4b681d650b7518762aea37d1a358bcdfe704', '[{"key":"itax-cap35","title":"Income Tax Act (Chapter 35), 2021 Edition (B.L.R.O. 1/2024)","publisher":"Attorney General''s Chambers, Brunei Darussalam — copy published by the Ministry of Finance and Economy","url":"https://www.mof.gov.bn/wp-content/uploads/2025/10/TR_Relevant-Acts_Income-Tax-Act-Chapter-35.pdf","consulted_on":"2026-10-10","kind":"law"},{"key":"pr5","title":"Income Tax Public Ruling PR No. 01/2021 — Keeping of Books of Accounts, second edition","publisher":"Revenue Division, Ministry of Finance and Economy","url":"https://www.mof.gov.bn/wp-content/uploads/2025/10/Public-Ruling-PR5.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"mof-income-tax","title":"Types of taxes — Income Tax","publisher":"Revenue Division, Ministry of Finance and Economy","url":"https://www.mof.gov.bn/div_revenue_typesoftaxes_incometax/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"mof-corporate-faq","title":"Frequently asked questions — Corporate Tax","publisher":"Revenue Division, Ministry of Finance and Economy","url":"https://www.mof.gov.bn/div_revenue_faq_corporatetax/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"mof-stamp-duty","title":"Types of taxes — Stamp Duty","publisher":"Revenue Division, Ministry of Finance and Economy","url":"https://www.mof.gov.bn/div_revenue_typesoftaxes_stampduty/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"mof-customs-press","title":"Press release: Amendments to the Customs Import and Excise Duties effective 1st April 2017","publisher":"Ministry of Finance","url":"https://business.mofe.gov.bn/wp-content/uploads/2025/11/Press-Release-on-Amendments-to-Customs-Import-and-Excise-Duties.pdf","consulted_on":"2026-10-10","kind":"guidance"},{"key":"bdas-non-pie","title":"Brunei Darussalam Accounting Standards — Non Public Interest Entities (BDAS NON-PIE)","publisher":"Brunei Darussalam Accounting Standards Council","url":"https://bdasc.mof.gov.bn/wp-content/uploads/2025/08/BDAS-for-Non-PIEs.pdf","consulted_on":"2026-10-10","kind":"standard"},{"key":"bdasc-ifrs-notice","title":"Notice No. 1/2014 — Accounting Standards (adoption of IFRS by public accountable entities from 1 January 2014)","publisher":"Brunei Darussalam Accounting Standards Council","url":"https://bdasc.mof.gov.bn/wp-content/uploads/2025/08/1-January-2014-IFRS-Notice.pdf","consulted_on":"2026-10-10","kind":"regulation"},{"key":"bdasc-faq","title":"FAQs on BDAS","publisher":"Brunei Darussalam Accounting Standards Council","url":"https://bdasc.mof.gov.bn/faqs-on-bdas/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"peppol-authorities","title":"Peppol Authorities","publisher":"OpenPeppol","url":"https://peppol.org/about/peppol-authorities/","consulted_on":"2026-10-10","kind":"guidance"},{"key":"ocp","title":"One Common Portal","publisher":"Ministry of Finance and Economy","url":"https://ocp.mofe.gov.bn/","consulted_on":"2026-10-10","kind":"portal"}]'::jsonb)
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
  ('BN', 'default', 'Brunei Darussalam reference chart of accounts', '{}'::jsonb, true, 'companies', array['BN-BDAS-BS', 'BN-BDAS-IS']::text[], null, 'There is no legal chart of accounts in Brunei Darussalam. The Income Tax Act (Chapter 35), section 56A(1)(a), requires every person carrying on a trade, business, profession or vocation to keep sufficient records, for 7 years from the year of assessment to which the income relates, to enable income and allowable deductions to be readily ascertained, and section 56A(6) defines those records as books of account recording receipts, payments, income and expenditure together with the invoices, vouchers and receipts that verify them; the Revenue Division''s Public Ruling PR No. 01/2021 adds that they must be sufficient to prepare a true and fair profit and loss account and balance sheet and may be kept in manual or electronic form. Neither text prescribes a chart. This chart is original: four digits, blocked so that each range reaches one line item of the balance sheet and the income statement a company reporting under the Brunei Darussalam Accounting Standards for non-public interest entities (BDAS NON-PIE, in force since 1 January 2018) presents. A company with public accountability reports under full IFRS (since 1 January 2014) and one without may choose IFRS; the same transactions tie into this balance sheet and income statement either way. It carries no tax-clearing account of any kind, because no tax on sales is collected or paid — see ''From Brunei Darussalam'' in docs/international.md.', 'bdas-non-pie')
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
  ('BN', 'default', '1000', 'Cash on hand', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('BN', 'default', '1010', 'Bank current account', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('BN', 'default', '1020', 'Bank savings account', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('BN', 'default', '1030', 'Foreign currency bank account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('BN', 'default', '1040', 'Payment gateway and card clearing account', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('BN', 'default', '1050', 'Fixed deposits of three months or less', '{}'::jsonb, 'asset_cash', false, null, 60),
  ('BN', 'default', '1060', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 70),
  ('BN', 'default', '1100', 'Trade debtors', '{}'::jsonb, 'asset_receivable', true, null, 80),
  ('BN', 'default', '1105', 'Allowance for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 90),
  ('BN', 'default', '1110', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 100),
  ('BN', 'default', '1120', 'Other debtors', '{}'::jsonb, 'asset_current', false, null, 110),
  ('BN', 'default', '1130', 'Accrued income', '{}'::jsonb, 'asset_current', false, null, 120),
  ('BN', 'default', '1140', 'Staff advances and loans to employees', '{}'::jsonb, 'asset_current', false, null, 130),
  ('BN', 'default', '1150', 'Income tax paid on account', '{}'::jsonb, 'asset_current', false, null, 140),
  ('BN', 'default', '1160', 'Income tax recoverable', '{}'::jsonb, 'asset_current', false, null, 150),
  ('BN', 'default', '1200', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 160),
  ('BN', 'default', '1210', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 170),
  ('BN', 'default', '1220', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 180),
  ('BN', 'default', '1230', 'Goods in transit', '{}'::jsonb, 'asset_current', false, null, 190),
  ('BN', 'default', '1300', 'Fixed deposits of more than three months', '{}'::jsonb, 'asset_current', false, null, 200),
  ('BN', 'default', '1310', 'Listed investments held for trading', '{}'::jsonb, 'asset_current', false, null, 210),
  ('BN', 'default', '1320', 'Amounts due from related companies — non-trade', '{}'::jsonb, 'asset_current', false, null, 220),
  ('BN', 'default', '1400', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('BN', 'default', '1410', 'Rental and utility deposits paid', '{}'::jsonb, 'asset_prepayments', false, null, 240),
  ('BN', 'default', '1420', 'Deposits paid to suppliers', '{}'::jsonb, 'asset_prepayments', false, null, 250),
  ('BN', 'default', '1600', 'Leasehold land and buildings', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('BN', 'default', '1610', 'Leasehold improvements', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('BN', 'default', '1620', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('BN', 'default', '1630', 'Office equipment', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('BN', 'default', '1640', 'Computer equipment and software', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('BN', 'default', '1650', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('BN', 'default', '1660', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('BN', 'default', '1670', 'Right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('BN', 'default', '1690', 'Accumulated depreciation — property plant and equipment', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('BN', 'default', '1695', 'Accumulated depreciation — right-of-use assets', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('BN', 'default', '1800', 'Goodwill', '{}'::jsonb, 'asset_non_current', false, null, 360),
  ('BN', 'default', '1810', 'Other intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('BN', 'default', '1820', 'Accumulated amortisation — intangible assets', '{}'::jsonb, 'asset_non_current', false, null, 380),
  ('BN', 'default', '1900', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 390),
  ('BN', 'default', '1910', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 400),
  ('BN', 'default', '1920', 'Other long-term investments', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('BN', 'default', '1930', 'Rental and utility deposits — non-current', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('BN', 'default', '1990', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('BN', 'default', '2000', 'Trade creditors', '{}'::jsonb, 'liability_payable', true, null, 440),
  ('BN', 'default', '2010', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 450),
  ('BN', 'default', '2020', 'Accruals', '{}'::jsonb, 'liability_current', false, null, 460),
  ('BN', 'default', '2030', 'Customer deposits and advances received', '{}'::jsonb, 'liability_current', false, null, 470),
  ('BN', 'default', '2040', 'Salaries and wages payable', '{}'::jsonb, 'liability_current', false, null, 480),
  ('BN', 'default', '2050', 'Employee retirement fund contributions payable (TAP and SCP)', '{}'::jsonb, 'liability_current', false, null, 490),
  ('BN', 'default', '2060', 'Provision for income tax', '{}'::jsonb, 'liability_current', false, null, 500),
  ('BN', 'default', '2065', 'Withholding tax payable on payments to non-residents', '{}'::jsonb, 'liability_current', false, null, 505),
  ('BN', 'default', '2070', 'Other taxes and government charges payable', '{}'::jsonb, 'liability_current', false, null, 510),
  ('BN', 'default', '2080', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 520),
  ('BN', 'default', '2090', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 530),
  ('BN', 'default', '2200', 'Corporate credit card payable', '{}'::jsonb, 'liability_credit_card', false, null, 540),
  ('BN', 'default', '2300', 'Bank borrowings — non-current', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('BN', 'default', '2310', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('BN', 'default', '2320', 'Amounts due to shareholders — non-current', '{}'::jsonb, 'liability_non_current', false, null, 570),
  ('BN', 'default', '2390', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('BN', 'default', '3000', 'Issued and paid-up share capital', '{}'::jsonb, 'equity', false, null, 590),
  ('BN', 'default', '3100', 'Share premium', '{}'::jsonb, 'equity', false, null, 600),
  ('BN', 'default', '3110', 'Capital reserve', '{}'::jsonb, 'equity', false, null, 610),
  ('BN', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 620),
  ('BN', 'default', '4000', 'Sale of goods', '{}'::jsonb, 'income', false, null, 630),
  ('BN', 'default', '4010', 'Rendering of services', '{}'::jsonb, 'income', false, null, 640),
  ('BN', 'default', '4700', 'Realised exchange gains', '{}'::jsonb, 'income_other', false, null, 650),
  ('BN', 'default', '4710', 'Unrealised exchange gains', '{}'::jsonb, 'income_other', false, null, 660),
  ('BN', 'default', '4720', 'Interest income', '{}'::jsonb, 'income_other', false, null, 670),
  ('BN', 'default', '4730', 'Sundry income', '{}'::jsonb, 'income_other', false, null, 680),
  ('BN', 'default', '4750', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 690),
  ('BN', 'default', '5000', 'Cost of goods sold', '{}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('BN', 'default', '5010', 'Purchases', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('BN', 'default', '5020', 'Freight inwards', '{}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('BN', 'default', '5030', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('BN', 'default', '6000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 740),
  ('BN', 'default', '6010', 'Staff salaries and wages', '{}'::jsonb, 'expense', false, null, 750),
  ('BN', 'default', '6020', 'Employee retirement fund contributions (TAP and SCP)', '{}'::jsonb, 'expense', false, null, 760),
  ('BN', 'default', '6030', 'Staff welfare and benefits', '{}'::jsonb, 'expense', false, null, 770),
  ('BN', 'default', '6100', 'Rent and rates', '{}'::jsonb, 'expense', false, null, 780),
  ('BN', 'default', '6110', 'Management fees and building outgoings', '{}'::jsonb, 'expense', false, null, 790),
  ('BN', 'default', '6120', 'Utilities', '{}'::jsonb, 'expense', false, null, 800),
  ('BN', 'default', '6200', 'Business licence and registration fees', '{}'::jsonb, 'expense', false, null, 810),
  ('BN', 'default', '6205', 'Stamp duty', '{}'::jsonb, 'expense', false, null, 815),
  ('BN', 'default', '6210', 'Auditor''s remuneration', '{}'::jsonb, 'expense', false, null, 820),
  ('BN', 'default', '6220', 'Accounting and company secretarial fees', '{}'::jsonb, 'expense', false, null, 830),
  ('BN', 'default', '6230', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 840),
  ('BN', 'default', '6300', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 850),
  ('BN', 'default', '6310', 'Insurance', '{}'::jsonb, 'expense', false, null, 860),
  ('BN', 'default', '6320', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 870),
  ('BN', 'default', '6330', 'Travelling expenses', '{}'::jsonb, 'expense', false, null, 880),
  ('BN', 'default', '6340', 'Entertainment expenses', '{}'::jsonb, 'expense', false, null, 890),
  ('BN', 'default', '6350', 'Advertising and promotion', '{}'::jsonb, 'expense', false, null, 900),
  ('BN', 'default', '6360', 'Printing, stationery and postage', '{}'::jsonb, 'expense', false, null, 910),
  ('BN', 'default', '6370', 'Telecommunications', '{}'::jsonb, 'expense', false, null, 920),
  ('BN', 'default', '6380', 'Bank charges', '{}'::jsonb, 'expense', false, null, 930),
  ('BN', 'default', '6390', 'Sundry office expenses', '{}'::jsonb, 'expense', false, null, 940),
  ('BN', 'default', '6400', 'Allowance for expected credit losses charged', '{}'::jsonb, 'expense', false, null, 950),
  ('BN', 'default', '6410', 'Interest expense on bank borrowings', '{}'::jsonb, 'expense', false, null, 960),
  ('BN', 'default', '6420', 'Interest expense on lease liabilities', '{}'::jsonb, 'expense', false, null, 970),
  ('BN', 'default', '6450', 'Realised exchange losses', '{}'::jsonb, 'expense', false, null, 980),
  ('BN', 'default', '6455', 'Unrealised exchange losses', '{}'::jsonb, 'expense', false, null, 990),
  ('BN', 'default', '6460', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1000),
  ('BN', 'default', '6470', 'Income tax charge', '{}'::jsonb, 'expense', false, null, 1010),
  ('BN', 'default', '6480', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1020),
  ('BN', 'default', '6490', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1030),
  ('BN', 'default', '6800', 'Depreciation and amortisation', '{}'::jsonb, 'expense_depreciation', false, null, 1040)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BN', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('BN', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('BN', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('BN', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('BN', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('BN', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('BN', 'BN-P-NA', 'Purchase, not subject to any tax on turnover', '{}'::jsonb, 'Every purchase a Brunei Darussalam business books — domestic, imported, or delivered from outside Brunei Darussalam to a place outside it', 'percent', 0, 'purchase', 'not_subject', date '2000-01-01', null, 'The purchase side of BN-S-NA: nothing a Brunei Darussalam business buys carries a value added tax, a goods and services tax or a general sales tax to recover, because none is charged on the sale that supplies it, whether the seller is in Brunei Darussalam or abroad. Imported goods can carry customs import duty and excise duty under the Customs Import Duties Order and the Excise Duties Order (amended with effect from 1 April 2017, Ministry of Finance press release), which are duties on specified goods levied at the border and not a general tax any invoice line can carry a code for: this pack does not model them, and an importer books the duty in the cost of the goods or the expense account it chooses. See ''From Brunei Darussalam'' in docs/international.md.', 'O', null, 20, 'other', true, '{}'::tax_condition[], null, false, false, null, 'itax-cap35', null, null, null, null),
  ('BN', 'BN-S-NA', 'Sale, not subject to any tax on turnover', '{}'::jsonb, 'Every sale a Brunei Darussalam business makes — domestic, exported, or delivered from outside Brunei Darussalam to a place outside it', 'percent', 0, 'sale', 'not_subject', date '2000-01-01', null, 'Brunei Darussalam has no value added tax, goods and services tax or general tax on the sale of goods or the supply of services. The Revenue Division of the Ministry of Finance and Economy lists the taxes it administers as income tax (Income Tax Act, Chapter 35, and Income Tax (Petroleum) Act, Chapter 119), withholding tax and stamp duty (Stamp Act, Chapter 34), and its FAQ on corporate tax names only the tax on companies'' chargeable income; a text search of the Income Tax Act for goods and services tax, sales tax and value added tax finds none. Checked on 2026-10-10; secondary summaries found in the same research agree and no announced project to introduce one was found, though no official statement ruling one out was found either. What the jurisdiction charges instead, all outside this pack: income tax on companies incorporated or registered under the Companies Act (Chapter 39) at 18.5 per cent of chargeable income from the year of assessment 2015 (Income Tax Act, section 35(1)(f), with a threshold under section 35(4) taxing only 25 per cent of the first $100,000 and 50 per cent of the next $150,000), while sole proprietorships and partnerships registered as business names are not taxed (Revenue Division, corporate tax FAQ); petroleum income tax at 55 per cent on oil and gas exploration and production profits (Revenue Division, income tax page); withholding tax on payments to non-residents (section 35(2) and (2A): 2.5 per cent, and 10 per cent on royalties and the other payments section 9(5) lists, and 10 per cent on non-resident directors'' remuneration under section 35(2B)); stamp duty on instruments (Stamp Act, Chapter 34); and customs and excise duties on goods, restructured with effect from 1 April 2017 (Ministry of Finance press release). Section 8A of the Income Tax Act imposes a tax of one per cent on the gross proceeds of approved exports; it is a tax on the income of an exporter the authorities have approved, assessed under the Act, and not a charge any invoice line carries, so it is not modelled. The code exists so that every sale line still carries a tax code the engine can post, and states plainly that this jurisdiction has none. `valid_from` is a convenience the pack needed, not a claim about when the absence began. See ''From Brunei Darussalam'' in docs/international.md.', 'O', null, 10, 'other', true, '{}'::tax_condition[], null, false, false, null, 'itax-cap35', null, null, null, null)
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
    ('BN-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BN-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('BN-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BN-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BN' and t.code = v.tax_code
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
  ('BN-BDAS-BS', 'BN', 'default', 'Balance sheet', 'balance_sheet', 'BDAS', date '1970-01-01', null, 'Brunei Darussalam Accounting Standards for Non-Public Interest Entities (BDAS NON-PIE), BDAS 1 (Presentation of Financial Statements), paragraphs 1.1 and 1.16 to 1.21: a complete set of financial statements comprises a balance sheet, an income statement, accounting policies and explanatory notes, and a cash flow statement; the balance sheet presents current and non-current assets and current and non-current liabilities as separate classifications, and its face includes, where applicable, property, plant and equipment, intangible assets, financial assets, inventories, trade and other receivables, tax assets, cash and cash equivalents, trade and other payables, tax liabilities, provisions, non-current liabilities, issued capital and reserves (paragraph 1.19). BDAS NON-PIE has applied since 1 January 2018 to entities without public accountability (Brunei Darussalam Accounting Standards Council, Frequently Asked Questions on BDAS); an entity with public accountability reports under full IFRS since 1 January 2014 (Notice No. 1/2014) and a non-public interest entity may choose IFRS. The numbering below and the ranges each line reads are original to this pack: neither the Income Tax Act nor BDAS prescribes a chart of accounts, so the blocks are this pack''s own. This pack does not carry the cash flow statement BDAS 18 also requires; see the README.', null),
  ('BN-BDAS-IS', 'BN', 'default', 'Income statement', 'income_statement', 'BDAS', date '1970-01-01', null, 'BDAS NON-PIE, BDAS 1, paragraphs 1.22 to 1.28: the face of the income statement includes, where applicable, revenue, finance costs, tax expense and profit or loss for the period, with further line items and subtotals where needed, and an analysis of expenses by nature or by function. BDAS NON-PIE presents an income statement and not a statement of comprehensive income (paragraph 1.1(b)). This pack classifies expenses by nature, which paragraph 1.26 permits, and shows finance costs and tax expense on their own lines. The numbering below is this pack''s own.', null)
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
  ('BN-BDAS-BS', 'A-NC-FIX', 'A-NC', 'Property, plant and equipment', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-NC-INT', 'A-NC', 'Goodwill and other intangible assets', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-NC-OTH', 'A-NC', 'Other non-current assets', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-NC', null, 'Non-current assets', '{}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C-REC', 'A-C', 'Trade and other receivables', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C-TAX', 'A-C', 'Current tax assets', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C-INV', 'A-C', 'Inventories', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C-OTH', 'A-C', 'Other current assets', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C-PRE', 'A-C', 'Prepayments and deposits paid', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C-CASH', 'A-C', 'Cash and cash equivalents', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-C', null, 'Current assets', '{}'::jsonb, 110, 1, true, array['A-C-REC', 'A-C-TAX', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'A-TOT', null, 'Total assets', '{}'::jsonb, 120, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'E-CAP', 'E-TOT', 'Share capital and reserves', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'E-RET', 'E-TOT', 'Retained earnings', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'E-RESULT', 'E-TOT', 'Profit or loss for the year, not yet allocated', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'E-TOT', null, 'Total equity', '{}'::jsonb, 160, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'L-NC', 'L-TOT', 'Non-current liabilities', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'L-C-PAY', 'L-C', 'Trade and other payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'L-C-TAX', 'L-C', 'Current tax liabilities', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'L-C-OTH', 'L-C', 'Other current liabilities', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'L-C', null, 'Current liabilities', '{}'::jsonb, 210, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 220, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-BS', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 230, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('BN-BDAS-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'FIN', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'TAX', null, 'Tax expense', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BN-BDAS-IS', 'PROFIT', null, 'Profit (loss) for the year', '{}'::jsonb, 90, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR', 'FIN', 'TAX']::text[], null, null, null)
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
    ('BN-BDAS-BS', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('BN-BDAS-BS', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('BN-BDAS-BS', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('BN-BDAS-BS', 'A-C-REC', 10, 'code_range', '1100', '1149', null, 'any'),
    ('BN-BDAS-BS', 'A-C-REC', 20, 'code_range', '1170', '1199', null, 'any'),
    ('BN-BDAS-BS', 'A-C-TAX', 10, 'code_range', '1150', '1169', null, 'any'),
    ('BN-BDAS-BS', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('BN-BDAS-BS', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('BN-BDAS-BS', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('BN-BDAS-BS', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('BN-BDAS-BS', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('BN-BDAS-BS', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('BN-BDAS-BS', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('BN-BDAS-BS', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('BN-BDAS-BS', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('BN-BDAS-BS', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('BN-BDAS-BS', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('BN-BDAS-BS', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('BN-BDAS-BS', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('BN-BDAS-BS', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('BN-BDAS-BS', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any'),
    ('BN-BDAS-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('BN-BDAS-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('BN-BDAS-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('BN-BDAS-IS', 'OPEX', 10, 'code_range', '6000', '6409', null, 'any'),
    ('BN-BDAS-IS', 'OPEX', 20, 'code_range', '6430', '6469', null, 'any'),
    ('BN-BDAS-IS', 'OPEX', 30, 'code_range', '6490', '6799', null, 'any'),
    ('BN-BDAS-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('BN-BDAS-IS', 'FIN', 10, 'code_range', '6410', '6429', null, 'any'),
    ('BN-BDAS-IS', 'TAX', 10, 'code_range', '6470', '6489', null, 'any')
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
  ('BN', 'Brunei Darussalam', '{}'::jsonb, array['en']::text[], 'BND', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, null, null, null, null)
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
  numbering_legal_reference     = 'Income Tax Act (Chapter 35), section 56A(1)(b): every person carrying on a trade, business, profession or vocation shall issue a printed receipt serially numbered for every sum received in respect of goods sold or services performed in the course of the business, and shall retain a duplicate of every such receipt; failing to comply without reasonable excuse is an offence (section 56A(5)). Where a machine records sales, a receipt may be dispensed with if the Collector is satisfied that it records all sales automatically and transfers each day''s total to a record of sales (section 56A(2)); the Collector may prescribe the form of the receipts (section 56A(3)) and may waive the duty (section 56A(4)). The Revenue Division''s Public Ruling PR No. 01/2021 reads the duty as covering sales invoices, delivery orders and official receipts alike, each carrying an identifying number that is ''serially printed numbered'', and requires the duplicate to be kept to reconcile with the income transaction. No text consulted says that the series must be free of gaps, so `numbering` is `sequential` and not `gapless`; `number_format` is a convention this pack proposes. The text says ''printed'': whether a number generated by software satisfies it is something the ruling does not address beyond accepting electronic records generally, and a Brunei accountant should confirm it. This is a real numbering rule, unlike the free numbering of a country with no such duty.',
  numbering_source_key          = 'itax-cap35',
  payment_terms_legal_reference = 'None of the texts consulted sets a payment term between two businesses in the absence of an agreement, or a rate of interest on a commercial debt paid late; the Companies Act (Chapter 39) and the Civil Law Act were not opened in this research. `legal_payment_days` and `late_payment_reference` are therefore empty, and a seller''s own terms are a matter of contract, stated on the document and not derived from a rule this pack could cite.',
  payment_terms_source_key      = 'itax-cap35',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'This field has nothing to describe in Brunei Darussalam: it names the day a country''s general rule makes its own turnover tax chargeable, and Brunei Darussalam charges none. `invoice_date` is declared as the closest general commercial convention — revenue is recognised on the terms of BDAS 11 (Revenue) when the risks and rewards of ownership pass or the service is rendered, which an invoice ordinarily records — and not as a rule read from a text; see ''From Brunei Darussalam'' in docs/international.md.',
  tax_point_source_key          = 'bdas-non-pie',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No text consulted obliges a business in Brunei Darussalam to issue or to accept an electronic invoice, and no Peppol Authority is listed for Brunei Darussalam (OpenPeppol, Peppol Authorities, consulted 2026-10-10; the list names Australia, Belgium, Denmark, England, Finland, France, Germany, Greece, Iceland, Ireland, Italy, Japan, Luxembourg, Malaysia, New Zealand, Nigeria, Norway, Oman, Poland, Portugal, Singapore, Slovakia, Sweden, Taiwan, the Netherlands and the United Arab Emirates). `profile`, `party_scheme` and `vat_scheme` are therefore null: there is no domestic profile to name and no VAT identifier for a scheme to carry, since Brunei Darussalam levies no value added tax. The duty that does exist is the one on printed, serially numbered receipts (Income Tax Act, Chapter 35, section 56A(1)(b)); the Revenue Division''s Public Ruling PR No. 01/2021 accepts records kept electronically, but this research found no statement on e-invoicing as such, and absence from the sources consulted is not proof that none exists.',
  einvoice_source_key           = 'peppol-authorities',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'BN';
