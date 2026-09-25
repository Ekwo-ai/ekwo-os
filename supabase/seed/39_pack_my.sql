-- Ekwo OS — Malaysia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/my at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build my`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Sales Tax Act 2018 (Act 806) — section 8 charges the tax on a taxable person manufacturing taxable goods in Malaysia, section 9 on the importation of taxable goods, section 13 the registration threshold, section 15 the rate of tax, and section 41 the exemption of goods on which it is proved to the satisfaction of the Director General that the goods have been exported (Attorney General's Chambers of Malaysia — Federal Legislation Portal)
--     https://lom.agc.gov.my/ilims/upload/portal/akta/LOM/EN/Act%20806%20-%20Reprint%20Online%20(1-10-2020).pdf
--   Service Tax Act 2018 (Act 807) — section 7 charges the tax on any taxable person who provides taxable services in Malaysia, section 13 the registration threshold, section 26 the rate of tax, and section 26A the remittance of tax by a person in Malaysia who imports a taxable service (Attorney General's Chambers of Malaysia — Federal Legislation Portal)
--     https://lom.agc.gov.my/ilims/upload/portal/akta/outputaktap/2590513_BI/Act%20807%20(Online%202024).pdf
--   Guide on Sales Tax Rates for Various Goods, and the General Guide on Sales Tax — the First Schedule of the Sales Tax (Rates of Tax) Order 2018 taxes a specified list of goods at 5 %, the Second Schedule and the residual rule tax everything else taxable at 10 %, and a specific rate applies to petroleum (Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia) — MySST)
--     https://mysst.customs.gov.my/assets/document/General%20Guides/V4.0%20Guide%20On%20Sales%20Tax%20Rates%20%20for%20Various%20Goods_07.09.pdf
--   Targeted Revision of Sales Tax Rate and Expansion of Service Tax Scope, effective 1 July 2025 — the Sales Tax (Rates of Tax) (Amendment) Order 2025 narrows the 0 % rate to essential goods and taxes selected non-essential and discretionary goods at 5 % or 10 %; the Service Tax scope is expanded to leasing and rental, construction, financial services, private healthcare and education, each with its own rate and registration threshold, with targeted exemptions (Ministry of Finance Malaysia (Kementerian Kewangan Malaysia))
--     https://www.mof.gov.my/portal/en/news/press-release/targeted-revision-of-sales-tax-rate-and-expansion-of-service-tax-scope-effective-1-july-2025
--   Guidelines: SST-02 Return — the taxable period, the fields of Part B2 of the form (11a and 11b the value of taxable goods at 5 % and 10 %, 11c and 11d the value of taxable services, 13 and 13d credit-note and bad-debt adjustments, 18a to 18e and 19 to 21 the exempted values), and the filing and payment deadline (Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia) — MySST)
--     https://mysst.customs.gov.my/assets/document/Specific%20Guides/Appendix%20II_Return%20SST02%20Guidelines.pdf
--   MySST — registration, the SST-02 and SST-02A returns, and payment (Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia))
--     https://mysst.customs.gov.my/
--   Companies Act 2016 (Act 777) — section 245 requires a company's financial statements to comply with approved accounting standards, and section 248 the accounting period (Companies Commission of Malaysia (Suruhanjaya Syarikat Malaysia))
--     https://www.ssm.com.my/Pages/Legal_Framework/Document/Act%20777%20Reprint.pdf
--   MASB Approved Accounting Standards — the Malaysian Financial Reporting Standards (MFRS), which converge with IFRS, and the Malaysian Private Entities Reporting Standard (MPERS), which converges with the IFRS for SMEs Accounting Standard (Malaysian Accounting Standards Board (MASB))
--     https://www.masb.org.my/pages.php?id=20
--   Income Tax Act 1967 (Act 53), section 82C — the duty to issue an electronic invoice for a transaction in respect of goods sold or services performed, phased in by the Minister's order; the Income Tax (Issuance of Electronic Invoice) Rules 2024 [P.U. (A) 265/2024], in force 1 October 2024, prescribe the particulars and the manner of issuance (Attorney General's Chambers of Malaysia, and Inland Revenue Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM))
--     https://www.hasil.gov.my/en/e-invoice/
--   e-Invoice Guideline — the phased mandatory implementation timeline by annual turnover or revenue (1 August 2024 above RM100 million, 1 January 2025 above RM25 million, 1 July 2025 above RM5 million, 1 January 2026 above RM1 million), the exemption threshold since raised in stages, and the MyInvois validation flow: a taxpayer submits the invoice to LHDNM for validation, which returns a Unique Identifier Number (UIN) and a QR code before the document is shared with the buyer (Inland Revenue Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM))
--     https://www.hasil.gov.my/media/fzagbaj2/irbm-e-invoice-guideline.pdf
--   e-Invoice General Guideline, version 4.8 (30 August 2026), section 1.6.1(e) — a taxpayer with an annual turnover or revenue below RM3,000,000, subject to a related-party carve-out, is exempted from issuing an e-Invoice, including a self-billed e-Invoice, at the date this pack was released (Inland Revenue Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM))
--     https://www.hasil.gov.my/wp-content/uploads/IRBM-e-Invoice-Guideline.pdf
--   Peppol International (PINT) model for Billing, Malaysia — PINT MY, the Peppol-network data format aligned with LHDNM's MyInvois particulars, for a taxpayer that chooses to transmit through a Peppol access point rather than the MyInvois Portal or API directly (OpenPeppol, with the Malaysia Digital Economy Corporation (MDEC) as the Malaysia Peppol Authority)
--     https://docs.peppol.eu/poac/my/pint-my-sb/bis/
--   Peppol Code Lists — participant identifier schemes: 0230, the Malaysia National ID Registration Number (SSM registration number) scheme (OpenPeppol)
--     https://docs.peppol.eu/edelivery/codelists/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('MY', 'Malaysia', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, 'b34dd04d7fa0abd37809c53026299ac351c807713f8af7e5859b5c55c29b3e95', '[{"key":"sales-tax-act","title":"Sales Tax Act 2018 (Act 806) — section 8 charges the tax on a taxable person manufacturing taxable goods in Malaysia, section 9 on the importation of taxable goods, section 13 the registration threshold, section 15 the rate of tax, and section 41 the exemption of goods on which it is proved to the satisfaction of the Director General that the goods have been exported","publisher":"Attorney General''s Chambers of Malaysia — Federal Legislation Portal","url":"https://lom.agc.gov.my/ilims/upload/portal/akta/LOM/EN/Act%20806%20-%20Reprint%20Online%20(1-10-2020).pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"service-tax-act","title":"Service Tax Act 2018 (Act 807) — section 7 charges the tax on any taxable person who provides taxable services in Malaysia, section 13 the registration threshold, section 26 the rate of tax, and section 26A the remittance of tax by a person in Malaysia who imports a taxable service","publisher":"Attorney General''s Chambers of Malaysia — Federal Legislation Portal","url":"https://lom.agc.gov.my/ilims/upload/portal/akta/outputaktap/2590513_BI/Act%20807%20(Online%202024).pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"sst-rates-guide","title":"Guide on Sales Tax Rates for Various Goods, and the General Guide on Sales Tax — the First Schedule of the Sales Tax (Rates of Tax) Order 2018 taxes a specified list of goods at 5 %, the Second Schedule and the residual rule tax everything else taxable at 10 %, and a specific rate applies to petroleum","publisher":"Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia) — MySST","url":"https://mysst.customs.gov.my/assets/document/General%20Guides/V4.0%20Guide%20On%20Sales%20Tax%20Rates%20%20for%20Various%20Goods_07.09.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"mof-sst-2025","title":"Targeted Revision of Sales Tax Rate and Expansion of Service Tax Scope, effective 1 July 2025 — the Sales Tax (Rates of Tax) (Amendment) Order 2025 narrows the 0 % rate to essential goods and taxes selected non-essential and discretionary goods at 5 % or 10 %; the Service Tax scope is expanded to leasing and rental, construction, financial services, private healthcare and education, each with its own rate and registration threshold, with targeted exemptions","publisher":"Ministry of Finance Malaysia (Kementerian Kewangan Malaysia)","url":"https://www.mof.gov.my/portal/en/news/press-release/targeted-revision-of-sales-tax-rate-and-expansion-of-service-tax-scope-effective-1-july-2025","consulted_on":"2026-09-25","kind":"guidance"},{"key":"sst02-return-guide","title":"Guidelines: SST-02 Return — the taxable period, the fields of Part B2 of the form (11a and 11b the value of taxable goods at 5 % and 10 %, 11c and 11d the value of taxable services, 13 and 13d credit-note and bad-debt adjustments, 18a to 18e and 19 to 21 the exempted values), and the filing and payment deadline","publisher":"Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia) — MySST","url":"https://mysst.customs.gov.my/assets/document/Specific%20Guides/Appendix%20II_Return%20SST02%20Guidelines.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"mysst-portal","title":"MySST — registration, the SST-02 and SST-02A returns, and payment","publisher":"Royal Malaysian Customs Department (Jabatan Kastam Diraja Malaysia)","url":"https://mysst.customs.gov.my/","consulted_on":"2026-09-25","kind":"portal"},{"key":"companies-act-my","title":"Companies Act 2016 (Act 777) — section 245 requires a company''s financial statements to comply with approved accounting standards, and section 248 the accounting period","publisher":"Companies Commission of Malaysia (Suruhanjaya Syarikat Malaysia)","url":"https://www.ssm.com.my/Pages/Legal_Framework/Document/Act%20777%20Reprint.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"masb-standards","title":"MASB Approved Accounting Standards — the Malaysian Financial Reporting Standards (MFRS), which converge with IFRS, and the Malaysian Private Entities Reporting Standard (MPERS), which converges with the IFRS for SMEs Accounting Standard","publisher":"Malaysian Accounting Standards Board (MASB)","url":"https://www.masb.org.my/pages.php?id=20","consulted_on":"2026-09-25","kind":"guidance"},{"key":"ita-1967-82c","title":"Income Tax Act 1967 (Act 53), section 82C — the duty to issue an electronic invoice for a transaction in respect of goods sold or services performed, phased in by the Minister''s order; the Income Tax (Issuance of Electronic Invoice) Rules 2024 [P.U. (A) 265/2024], in force 1 October 2024, prescribe the particulars and the manner of issuance","publisher":"Attorney General''s Chambers of Malaysia, and Inland Revenue Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM)","url":"https://www.hasil.gov.my/en/e-invoice/","consulted_on":"2026-09-25","kind":"law"},{"key":"einvoice-guideline","title":"e-Invoice Guideline — the phased mandatory implementation timeline by annual turnover or revenue (1 August 2024 above RM100 million, 1 January 2025 above RM25 million, 1 July 2025 above RM5 million, 1 January 2026 above RM1 million), the exemption threshold since raised in stages, and the MyInvois validation flow: a taxpayer submits the invoice to LHDNM for validation, which returns a Unique Identifier Number (UIN) and a QR code before the document is shared with the buyer","publisher":"Inland Revenue Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM)","url":"https://www.hasil.gov.my/media/fzagbaj2/irbm-e-invoice-guideline.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"einvoice-exemption","title":"e-Invoice General Guideline, version 4.8 (30 August 2026), section 1.6.1(e) — a taxpayer with an annual turnover or revenue below RM3,000,000, subject to a related-party carve-out, is exempted from issuing an e-Invoice, including a self-billed e-Invoice, at the date this pack was released","publisher":"Inland Revenue Board of Malaysia (Lembaga Hasil Dalam Negeri Malaysia, LHDNM)","url":"https://www.hasil.gov.my/wp-content/uploads/IRBM-e-Invoice-Guideline.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"pint-my","title":"Peppol International (PINT) model for Billing, Malaysia — PINT MY, the Peppol-network data format aligned with LHDNM''s MyInvois particulars, for a taxpayer that chooses to transmit through a Peppol access point rather than the MyInvois Portal or API directly","publisher":"OpenPeppol, with the Malaysia Digital Economy Corporation (MDEC) as the Malaysia Peppol Authority","url":"https://docs.peppol.eu/poac/my/pint-my-sb/bis/","consulted_on":"2026-09-25","kind":"standard"},{"key":"peppol-scheme","title":"Peppol Code Lists — participant identifier schemes: 0230, the Malaysia National ID Registration Number (SSM registration number) scheme","publisher":"OpenPeppol","url":"https://docs.peppol.eu/edelivery/codelists/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('MY', 'default', 'Malaysia reference chart of accounts', '{}'::jsonb, true, 'companies', array['MY-BS', 'MY-IS']::text[], null, 'Malaysia prescribes no chart of accounts. Companies Act 2016, section 245 requires a company to keep accounting and other records that sufficiently explain its transactions and enable true and fair financial statements to comply with the approved accounting standards to be prepared; the standards themselves — the Malaysian Financial Reporting Standards (MFRS) and the Malaysian Private Entities Reporting Standard (MPERS) — are issued by the Malaysian Accounting Standards Board and prescribe the content of a set of financial statements, never a ledger. This chart is original: four digits by class in the numbering the sibling Asian packs (Singapore, Thailand) use — 1 assets, 2 liabilities, 3 equity, 4 revenue, 5 cost of sales, 6 operating expenses, 7 finance items, 8 income tax — with the accounts a Malaysian company''s books actually hold: Sales Tax and Service Tax payable, kept apart from each other and from the settlement account a filed SST-02 return clears to, EPF, SOCSO and EIS contributions and the HRD Corp levy. Its statements, `MY-BS` and `MY-IS` in `statements.json`, are original: lines grouped by the code ranges this chart''s own numbering gives its accounts, current and non-current apart, without transcribing MFRS''s or MPERS''s own line items or their paragraph numbering — neither of which this session could read as a primary, openly served text (see the pack''s README, "Sources").', 'companies-act-my')
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
  ('MY', 'default', '1000', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('MY', 'default', '1010', 'Current account — MYR', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('MY', 'default', '1020', 'Fixed deposits placed for three months or less', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('MY', 'default', '1030', 'Foreign currency account', '{}'::jsonb, 'asset_cash', false, null, 40),
  ('MY', 'default', '1040', 'Cash in transit — card and DuitNow settlements', '{}'::jsonb, 'asset_cash', false, null, 50),
  ('MY', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('MY', 'default', '1110', 'Trade receivables — allowance for impairment', '{}'::jsonb, 'asset_current', false, null, 70),
  ('MY', 'default', '1120', 'Other receivables', '{}'::jsonb, 'asset_current', true, null, 80),
  ('MY', 'default', '1130', 'Amounts due from related companies', '{}'::jsonb, 'asset_current', false, null, 90),
  ('MY', 'default', '1140', 'Deposits paid', '{}'::jsonb, 'asset_current', false, null, 100),
  ('MY', 'default', '1155', 'Sales Tax and Service Tax refundable by RMCD — net of a filed return', '{}'::jsonb, 'asset_current', true, null, 110),
  ('MY', 'default', '1160', 'Advances to staff', '{}'::jsonb, 'asset_current', false, null, 120),
  ('MY', 'default', '1200', 'Inventories — goods for resale', '{}'::jsonb, 'asset_current', false, null, 130),
  ('MY', 'default', '1210', 'Inventories — raw materials', '{}'::jsonb, 'asset_current', false, null, 140),
  ('MY', 'default', '1220', 'Inventories — work in progress', '{}'::jsonb, 'asset_current', false, null, 150),
  ('MY', 'default', '1230', 'Inventories — finished goods', '{}'::jsonb, 'asset_current', false, null, 160),
  ('MY', 'default', '1300', 'Short-term investments', '{}'::jsonb, 'asset_current', false, null, 170),
  ('MY', 'default', '1350', 'Income tax recoverable', '{}'::jsonb, 'asset_current', false, null, 180),
  ('MY', 'default', '1400', 'Prepayments', '{}'::jsonb, 'asset_prepayments', false, null, 190),
  ('MY', 'default', '1410', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 200),
  ('MY', 'default', '1600', 'Leasehold property — cost', '{}'::jsonb, 'asset_fixed', false, null, 210),
  ('MY', 'default', '1601', 'Leasehold property — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('MY', 'default', '1610', 'Renovation — cost', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('MY', 'default', '1611', 'Renovation — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('MY', 'default', '1620', 'Plant and machinery — cost', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('MY', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('MY', 'default', '1630', 'Office equipment — cost', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('MY', 'default', '1631', 'Office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('MY', 'default', '1640', 'Computers — cost', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('MY', 'default', '1641', 'Computers — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('MY', 'default', '1650', 'Furniture and fittings — cost', '{}'::jsonb, 'asset_fixed', false, null, 310),
  ('MY', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('MY', 'default', '1660', 'Motor vehicles — cost', '{}'::jsonb, 'asset_fixed', false, null, 330),
  ('MY', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('MY', 'default', '1670', 'Right-of-use assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 350),
  ('MY', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 360),
  ('MY', 'default', '1700', 'Investment property', '{}'::jsonb, 'asset_non_current', false, null, 370),
  ('MY', 'default', '1750', 'Intangible assets — cost', '{}'::jsonb, 'asset_fixed', false, null, 380),
  ('MY', 'default', '1751', 'Intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 390),
  ('MY', 'default', '1760', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 400),
  ('MY', 'default', '1800', 'Investments in associates', '{}'::jsonb, 'asset_non_current', false, null, 410),
  ('MY', 'default', '1810', 'Investments in joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 420),
  ('MY', 'default', '1830', 'Long-term financial assets', '{}'::jsonb, 'asset_non_current', false, null, 430),
  ('MY', 'default', '1840', 'Long-term deposits', '{}'::jsonb, 'asset_non_current', false, null, 440),
  ('MY', 'default', '1900', 'Deferred tax assets', '{}'::jsonb, 'asset_non_current', false, null, 450),
  ('MY', 'default', '2000', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 460),
  ('MY', 'default', '2010', 'Accrued expenses', '{}'::jsonb, 'liability_current', false, null, 470),
  ('MY', 'default', '2020', 'Other payables', '{}'::jsonb, 'liability_current', true, null, 480),
  ('MY', 'default', '2030', 'Amounts due to related companies', '{}'::jsonb, 'liability_current', false, null, 490),
  ('MY', 'default', '2040', 'Deposits received from customers', '{}'::jsonb, 'liability_current', false, null, 500),
  ('MY', 'default', '2100', 'Sales Tax payable — output', '{}'::jsonb, 'liability_current', false, null, 510),
  ('MY', 'default', '2101', 'Service Tax payable — output', '{}'::jsonb, 'liability_current', false, null, 520),
  ('MY', 'default', '2102', 'Service Tax payable — self-assessed on imported services', '{}'::jsonb, 'liability_current', false, null, 530),
  ('MY', 'default', '2110', 'Sales Tax and Service Tax payable to RMCD — net of a filed return', '{}'::jsonb, 'liability_current', true, null, 550),
  ('MY', 'default', '2150', 'EPF contributions payable', '{}'::jsonb, 'liability_current', true, null, 560),
  ('MY', 'default', '2160', 'SOCSO and EIS contributions payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('MY', 'default', '2170', 'HRD Corp levy payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('MY', 'default', '2180', 'Salaries payable', '{}'::jsonb, 'liability_current', true, null, 590),
  ('MY', 'default', '2190', 'Directors'' fees payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('MY', 'default', '2200', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 610),
  ('MY', 'default', '2210', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 620),
  ('MY', 'default', '2220', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 630),
  ('MY', 'default', '2230', 'Hire purchase — current portion', '{}'::jsonb, 'liability_current', false, null, 640),
  ('MY', 'default', '2240', 'Corporate credit card', '{}'::jsonb, 'liability_credit_card', false, null, 650),
  ('MY', 'default', '2250', 'Amounts due to directors', '{}'::jsonb, 'liability_current', false, null, 660),
  ('MY', 'default', '2300', 'Income tax payable', '{}'::jsonb, 'liability_current', false, null, 670),
  ('MY', 'default', '2350', 'Provision for unutilised leave', '{}'::jsonb, 'liability_current', false, null, 680),
  ('MY', 'default', '2360', 'Other provisions — current', '{}'::jsonb, 'liability_current', false, null, 690),
  ('MY', 'default', '2400', 'Bank loans — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('MY', 'default', '2410', 'Lease liabilities — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('MY', 'default', '2420', 'Hire purchase — non-current portion', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('MY', 'default', '2430', 'Loans from shareholders and directors — non-current', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('MY', 'default', '2500', 'Deferred tax liabilities', '{}'::jsonb, 'liability_non_current', false, null, 740),
  ('MY', 'default', '2550', 'Provision for reinstatement costs', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('MY', 'default', '2990', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 760),
  ('MY', 'default', '3000', 'Share capital', '{}'::jsonb, 'equity', false, null, 770),
  ('MY', 'default', '3010', 'Treasury shares', '{}'::jsonb, 'equity', false, null, 780),
  ('MY', 'default', '3100', 'Other reserves', '{}'::jsonb, 'equity', false, null, 790),
  ('MY', 'default', '3110', 'Foreign currency translation reserve', '{}'::jsonb, 'equity', false, null, 800),
  ('MY', 'default', '3200', 'Retained earnings', '{}'::jsonb, 'equity_retained', false, null, 810),
  ('MY', 'default', '3210', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 820),
  ('MY', 'default', '4000', 'Sales of goods', '{}'::jsonb, 'income', false, null, 830),
  ('MY', 'default', '4010', 'Services rendered', '{}'::jsonb, 'income', false, null, 840),
  ('MY', 'default', '4020', 'Export sales of goods', '{}'::jsonb, 'income', false, null, 850),
  ('MY', 'default', '4030', 'International services', '{}'::jsonb, 'income', false, null, 860),
  ('MY', 'default', '4500', 'Interest income', '{}'::jsonb, 'income_other', false, null, 870),
  ('MY', 'default', '4510', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 880),
  ('MY', 'default', '4520', 'Rental income', '{}'::jsonb, 'income_other', false, null, 890),
  ('MY', 'default', '4530', 'Government grants', '{}'::jsonb, 'income_other', false, null, 900),
  ('MY', 'default', '4700', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 910),
  ('MY', 'default', '4750', 'Gain on disposal of property plant and equipment', '{}'::jsonb, 'income_other', false, null, 920),
  ('MY', 'default', '4790', 'Other income', '{}'::jsonb, 'income_other', false, null, 930),
  ('MY', 'default', '5000', 'Purchases of goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('MY', 'default', '5010', 'Freight inwards and import duties', '{}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('MY', 'default', '5020', 'Subcontract costs', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('MY', 'default', '5100', 'Changes in inventories', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('MY', 'default', '6000', 'Salaries and wages', '{}'::jsonb, 'expense', false, null, 980),
  ('MY', 'default', '6010', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 990),
  ('MY', 'default', '6020', 'Directors'' fees', '{}'::jsonb, 'expense', false, null, 1000),
  ('MY', 'default', '6030', 'EPF contributions — employer', '{}'::jsonb, 'expense', false, null, 1010),
  ('MY', 'default', '6031', 'SOCSO and EIS contributions — employer', '{}'::jsonb, 'expense', false, null, 1020),
  ('MY', 'default', '6040', 'HRD Corp levy', '{}'::jsonb, 'expense', false, null, 1030),
  ('MY', 'default', '6050', 'Foreign worker levy', '{}'::jsonb, 'expense', false, null, 1040),
  ('MY', 'default', '6060', 'Staff welfare', '{}'::jsonb, 'expense', false, null, 1050),
  ('MY', 'default', '6070', 'Staff medical expenses and insurance', '{}'::jsonb, 'expense', false, null, 1060),
  ('MY', 'default', '6080', 'Staff training', '{}'::jsonb, 'expense', false, null, 1070),
  ('MY', 'default', '6200', 'Depreciation of property plant and equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('MY', 'default', '6210', 'Depreciation of right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1090),
  ('MY', 'default', '6220', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1100),
  ('MY', 'default', '6300', 'Rent — short-term leases', '{}'::jsonb, 'expense', false, null, 1110),
  ('MY', 'default', '6310', 'Utilities', '{}'::jsonb, 'expense', false, null, 1120),
  ('MY', 'default', '6320', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1130),
  ('MY', 'default', '6330', 'Cleaning', '{}'::jsonb, 'expense', false, null, 1140),
  ('MY', 'default', '6340', 'Telephone and internet', '{}'::jsonb, 'expense', false, null, 1150),
  ('MY', 'default', '6350', 'Software subscriptions', '{}'::jsonb, 'expense', false, null, 1160),
  ('MY', 'default', '6360', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1170),
  ('MY', 'default', '6370', 'Overseas travelling', '{}'::jsonb, 'expense', false, null, 1180),
  ('MY', 'default', '6380', 'Motor vehicle expenses', '{}'::jsonb, 'expense', false, null, 1190),
  ('MY', 'default', '6390', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1200),
  ('MY', 'default', '6400', 'Club subscriptions', '{}'::jsonb, 'expense', false, null, 1210),
  ('MY', 'default', '6410', 'Insurance and takaful', '{}'::jsonb, 'expense', false, null, 1220),
  ('MY', 'default', '6420', 'Professional fees', '{}'::jsonb, 'expense', false, null, 1230),
  ('MY', 'default', '6430', 'Audit fees', '{}'::jsonb, 'expense', false, null, 1240),
  ('MY', 'default', '6440', 'Company secretarial fees', '{}'::jsonb, 'expense', false, null, 1250),
  ('MY', 'default', '6450', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1260),
  ('MY', 'default', '6460', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1270),
  ('MY', 'default', '6470', 'Postage and courier', '{}'::jsonb, 'expense', false, null, 1280),
  ('MY', 'default', '6480', 'Licences permits and SSM fees', '{}'::jsonb, 'expense', false, null, 1290),
  ('MY', 'default', '6490', 'Royalties', '{}'::jsonb, 'expense', false, null, 1300),
  ('MY', 'default', '6500', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1310),
  ('MY', 'default', '6510', 'Impairment loss on trade receivables', '{}'::jsonb, 'expense', false, null, 1320),
  ('MY', 'default', '6900', 'Donations', '{}'::jsonb, 'expense', false, null, 1330),
  ('MY', 'default', '6950', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1340),
  ('MY', 'default', '6960', 'Loss on disposal of property plant and equipment', '{}'::jsonb, 'expense', false, null, 1350),
  ('MY', 'default', '6990', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1360),
  ('MY', 'default', '7000', 'Interest on bank loans', '{}'::jsonb, 'expense', false, null, 1370),
  ('MY', 'default', '7010', 'Interest on lease liabilities', '{}'::jsonb, 'expense', false, null, 1380),
  ('MY', 'default', '7020', 'Hire purchase interest', '{}'::jsonb, 'expense', false, null, 1390),
  ('MY', 'default', '7030', 'Interest on loans from related parties and others', '{}'::jsonb, 'expense', false, null, 1400),
  ('MY', 'default', '8000', 'Current income tax expense', '{}'::jsonb, 'expense', false, null, 1410),
  ('MY', 'default', '8010', 'Deferred tax expense', '{}'::jsonb, 'expense', false, null, 1420),
  ('MY', 'default', '8020', 'Under or over provision of income tax in prior years', '{}'::jsonb, 'expense', false, null, 1430)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('MY', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('MY', 'CSH', 'Petty cash', '{}'::jsonb, 'cash', 40),
  ('MY', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('MY', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('MY', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('MY', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('MY', 'MY-P-EXEMPT', 'Purchase not subject to Sales Tax or Service Tax', '{}'::jsonb, 'The ordinary untaxed purchase: a service outside the First Schedule of the Service Tax Regulations 2018, or a good that is not a taxable good', 'percent', 0, 'purchase', 'not_subject', date '2018-09-01', null, 'Sales Tax Act 2018, section 2 and Service Tax Act 2018, section 2 — neither tax reaches a good that is not a taxable good or a service the First Schedule of the Service Tax Regulations 2018 does not describe: professional rent, most financial services before 1 July 2025, and a great many ordinary running costs of a Malaysian business. This code reaches no box of SST-02, which has no input side at all.', null, null, 150, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sales-tax-act', null, null, null, null),
  ('MY', 'MY-P-IMPORT', 'Importation of taxable goods, Sales Tax at 10 %', '{}'::jsonb, 'Charged by the Royal Malaysian Customs Department at the point of import, on the customs declaration, and not through SST-02', 'percent', 10, 'purchase', 'import', date '2018-09-01', null, 'Sales Tax Act 2018, section 9 charges the tax on the importation of taxable goods into Malaysia, collected by the Royal Malaysian Customs Department as if it were a customs duty, at the same rates as a domestic sale. It is assessed on the customs declaration at the point of import and is never a line of SST-02, which is a registered person''s own periodic return of what they sold; `recoverable` is false for the same reason as every other Sales Tax code of this pack.', null, null, 100, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sales-tax-act', null, null, null, null),
  ('MY', 'MY-P-RAWMAT-EXEMPT', 'Purchase or importation of raw material exempted from Sales Tax (Schedule C)', '{}'::jsonb, 'A registered manufacturer, approved by the Director General, buys or imports a raw material, component or packaging material used solely to manufacture taxable goods, free of Sales Tax', 'percent', 0, 'purchase', 'exempt', date '2018-09-01', null, 'Sales Tax (Persons Exempted From Payment of Tax) Order 2018, Schedule C — a manufacturer of taxable goods approved by the Director General may purchase or import a raw material, component or packaging material used solely in manufacturing taxable goods without paying Sales Tax, against a CJ(P) exemption certificate. Whether the buyer holds that approval is a fact `conditions` records and the ledger does not: `buyer_status`, a quality of the buyer the Order names. This is the relief a Sales Tax registered manufacturer uses instead of an input tax credit, which the Act has none of.', null, null, 110, 'vat', false, array['buyer_status']::tax_condition[], null, false, false, null, 'sst-rates-guide', null, null, null, null),
  ('MY', 'MY-P-RED', 'Purchase of goods bearing Sales Tax at 5 %', '{}'::jsonb, 'The buyer''s side: the tax is a cost and never a claim on RMCD', 'percent', 5, 'purchase', 'domestic', date '2018-09-01', null, 'Sales Tax Act 2018, section 8 imposes the tax on the registered manufacturer, who adds it to the price. The Act contains no mechanism for the buyer to credit it against a tax of their own — the whole difference between a sales tax and a value added tax — so `recoverable` is false and the tax is booked by a `tax_on_base` posting at the full amount, landing it on the accounts of the lines it taxes: a machine bought for 10,000.00 ringgit is capitalised at 10,500.00. Neither the base nor the tax reaches a box of SST-02, which reports a registered person''s own sales and not what they paid on a purchase.', null, null, 80, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sales-tax-act', null, null, null, null),
  ('MY', 'MY-P-STD', 'Purchase of goods bearing Sales Tax at 10 %', '{}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2018-09-01', null, 'As MY-P-RED, at the standard rate.', null, null, 90, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sales-tax-act', null, null, null, null),
  ('MY', 'MY-P-SVT-FB', 'Purchase of a taxable service bearing Service Tax at 6 %', '{}'::jsonb, null, 'percent', 6, 'purchase', 'domestic', date '2018-09-01', null, 'Service Tax Act 2018, section 7 imposes the tax on the taxable person providing the service, who adds it to the price; there is no credit for a registered buyer, so `recoverable` is false and the tax lands on the account of the line it taxes by a `tax_on_base` posting, as MY-P-RED does for Sales Tax. Neither figure reaches a box of SST-02.', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'service-tax-act', null, null, null, null),
  ('MY', 'MY-P-SVT-IMPORT', 'Imported taxable service, self-assessed Service Tax at 8 %', '{}'::jsonb, 'A service provided by a person outside Malaysia and used in Malaysia: the recipient accounts for the tax themselves, on form SST-02A, which this pack does not carry', 'percent', 8, 'purchase', 'self_assessed', date '2019-01-01', null, 'Service Tax Act 2018, section 26A — a person in Malaysia, whether or not registered for Service Tax, who acquires an imported taxable service, is treated as providing that service themselves and accounts for the tax on it, due at the time of payment or receipt of invoice, whichever earlier. This session could not independently verify 1 January 2019 as the commencement date of section 26A against the Gazette order that brought it into force, only against secondary accounts; a reviewer should check it. The declaration is form SST-02A, quite apart from SST-02, which this pack does not carry (`docs/packs.md` records that a pack carries one form); the postings here book the cost and the liability and reach no box. `buyer_status` records that the duty turns on the recipient being in Malaysia, which `conditions` states and the core does not evaluate. Nothing is recovered at the other end: there is no exempt supply behind this, no supplier who was relieved of anything, and the `tax_on_base` posting puts the whole of the tax on the account of the line it taxes, exactly as a domestic purchase does.', null, null, 140, 'vat', false, array['buyer_status']::tax_condition[], null, false, false, null, 'service-tax-act', null, null, null, null),
  ('MY', 'MY-P-SVT-STD', 'Purchase of a taxable service bearing Service Tax at 8 %', '{}'::jsonb, null, 'percent', 8, 'purchase', 'domestic', date '2024-03-01', null, 'As MY-P-SVT-FB, at the general rate the Ministry of Finance raised to 8 % effective 1 March 2024.', null, null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'mof-sst-2025', null, null, null, null),
  ('MY', 'MY-S-EXEMPT', 'Sale of goods that are not taxable goods (Schedule B)', '{}'::jsonb, 'Basic foodstuffs and other goods a scheduled manufacturer produces, outside the definition of taxable goods entirely', 'percent', 0, 'sale', 'not_subject', date '2018-09-01', null, 'Sales Tax Act 2018, section 2 defines "taxable goods" as goods of a class or kind not for the time being exempted from tax by order of the Minister under section 34; the Sales Tax (Goods Exempted From Sales Tax) Order 2018, Schedule B, names the goods a scheduled manufacturer produces that carry no Sales Tax at all, basic foodstuffs among them (rice, sugar, salt and the like, by RMCD''s own guide — the Order''s own First Schedule numbering could not be read from a machine-readable copy this session). What makes a good fall inside Schedule B is a fact about the good, which the ledger does not hold on its own, hence `conditions`. The line is outside the scope of the tax rather than a taxable supply relieved of it, which is why the treatment is `not_subject` and not `exempt`.', 'O', null, 60, 'vat', false, array['supply_nature']::tax_condition[], null, false, false, null, 'sst-rates-guide', null, null, null, null),
  ('MY', 'MY-S-RED', 'Sale of taxable goods, Sales Tax at 5 %', '{}'::jsonb, 'Goods the First Schedule of the Sales Tax (Rates of Tax) Order 2018 taxes at the reduced rate', 'percent', 5, 'sale', 'domestic', date '2018-09-01', null, 'Sales Tax Act 2018, section 8 charges the tax on a registered manufacturer who sells, disposes of otherwise than by sale, or first uses, taxable goods manufactured in Malaysia; section 15 sets the rate at that specified by order. The Sales Tax (Rates of Tax) Order 2018, First Schedule, lists the goods taxed at 5 % — building materials, timber, certain foodstuffs and other goods this session could not enumerate against a machine-readable copy of the Order itself (see the pack''s README). There is no mechanism anywhere in the Act for a registered buyer to deduct this tax against a tax of their own: `recoverable` is false on every Sales Tax and Service Tax code of this pack, the whole difference between Malaysia''s Sales Tax and Service Tax and a value added tax.', 'S', null, 10, 'sales_tax', false, '{}'::tax_condition[], null, false, false, null, 'sst-rates-guide', null, null, null, null),
  ('MY', 'MY-S-STD', 'Sale of taxable goods, Sales Tax at 10 %', '{}'::jsonb, 'The residual rate: a taxable good the First Schedule does not name at 5 % and that is not taxed at a specific rate', 'percent', 10, 'sale', 'domestic', date '2018-09-01', null, 'Sales Tax Act 2018, sections 8 and 15, as for MY-S-RED. The Sales Tax (Rates of Tax) Order 2018, Second Schedule and its residual rule, tax at 10 % every taxable good the First Schedule does not name at 5 % and that carries no specific rate of its own (petroleum products among the latter, and not carried by this pack). This is the ordinary rate of Sales Tax.', 'S', null, 20, 'sales_tax', false, '{}'::tax_condition[], null, false, false, null, 'sst-rates-guide', null, null, null, null),
  ('MY', 'MY-S-ZERO', 'Export of taxable goods', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2018-09-01', null, 'Sales Tax Act 2018, section 41 — where it is proved to the satisfaction of the Director General that taxable goods manufactured in Malaysia have been exported, the tax is not charged, or, if it was paid, is drawn back. What proves the export — the shipping and customs documents — is a fact of the movement of the goods that the ledger does not hold, which is why this code carries `conditions` rather than a rule the core evaluates.', 'G', null, 50, 'vat', false, array['transport_evidence']::tax_condition[], null, false, false, null, 'sales-tax-act', null, null, null, null),
  ('MY', 'MY-SVT-EXEMPT', 'Service that is not a taxable service', '{}'::jsonb, 'A service outside the First Schedule of the Service Tax Regulations 2018, or supplied by a person below the group''s own registration threshold', 'percent', 0, 'sale', 'not_subject', date '2018-09-01', null, 'Service Tax Act 2018, section 2 defines "taxable service" as a service of a description in the First Schedule of the Service Tax Regulations 2018, provided by a taxable person; a service the Schedule does not describe is outside the tax entirely, and so is one a person below that group''s own registration threshold provides — the general RM500,000, or RM1,000,000 or RM1,500,000 for the groups the Ministry of Finance''s 2025 expansion names, each in the past twelve months.', 'O', null, 70, 'vat', false, array['supply_nature']::tax_condition[], null, false, false, null, 'service-tax-act', null, null, null, null),
  ('MY', 'MY-SVT-FB', 'Taxable service, Service Tax at 6 %', '{}'::jsonb, 'Food and beverage service, telecommunication, parking and logistics — the groups the Ministry of Finance kept at 6 % when the general rate rose', 'percent', 6, 'sale', 'domestic', date '2018-09-01', null, 'Service Tax Act 2018, section 7 charges the tax on a taxable person who provides a taxable service in Malaysia; section 26 sets the rate at that specified by order. Food and beverage service (First Schedule, Group B), telecommunication (Group I), parking and logistics kept the original 6 % rate when the Ministry of Finance raised the general Service Tax rate to 8 % effective 1 March 2024 and again expanded the scope of taxable services effective 1 July 2025.', 'S', null, 30, 'sales_tax', false, '{}'::tax_condition[], null, false, false, null, 'mof-sst-2025', null, null, null, null),
  ('MY', 'MY-SVT-STD', 'Taxable service, Service Tax at 8 %', '{}'::jsonb, 'The general rate since 1 March 2024: professional, consultancy, management, IT, employment and most other taxable services, and — since 1 July 2025 — leasing and rental and financial services', 'percent', 8, 'sale', 'domestic', date '2024-03-01', null, 'Service Tax Act 2018, sections 7 and 26, as for MY-SVT-FB. The Ministry of Finance''s press release of 1 July 2025 ("Targeted Revision of Sales Tax Rate and Expansion of Service Tax Scope") records the general rate rising from 6 % to 8 % on 1 March 2024 and the scope of taxable services expanding on 1 July 2025 to leasing and rental, construction, financial services, private healthcare and education, each with its own rate and registration threshold this pack does not separately carry — a single representative 8 % code stands for the general rate, and the README names the gap.', 'S', null, 40, 'sales_tax', false, '{}'::tax_condition[], null, false, false, null, 'mof-sst-2025', null, null, null, null)
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
    ('MY-P-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-EXEMPT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-IMPORT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-IMPORT', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-IMPORT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-IMPORT', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-RAWMAT-EXEMPT', 'invoice', 'base', 100, null, '19', array['19']::text[], 100, 'MY-SST-02', 10),
    ('MY-P-RAWMAT-EXEMPT', 'credit_note', 'base', 100, null, '19', array['19']::text[], -100, 'MY-SST-02', 10),
    ('MY-P-RED', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-RED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-RED', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-RED', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-STD', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-STD', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-STD', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-STD', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-SVT-FB', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-SVT-FB', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-SVT-FB', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-SVT-FB', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-SVT-IMPORT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-SVT-IMPORT', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-SVT-IMPORT', 'invoice', 'tax', -100, '2102', null, null, 100, null, 30),
    ('MY-P-SVT-IMPORT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-SVT-IMPORT', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-SVT-IMPORT', 'credit_note', 'tax', -100, '2102', null, null, 100, null, 30),
    ('MY-P-SVT-STD', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-SVT-STD', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-P-SVT-STD', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('MY-P-SVT-STD', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('MY-S-EXEMPT', 'invoice', 'base', 100, null, '18b2', array['18b2']::text[], 100, 'MY-SST-02', 10),
    ('MY-S-EXEMPT', 'credit_note', 'base', 100, null, '18b2', array['18b2']::text[], -100, 'MY-SST-02', 10),
    ('MY-S-RED', 'invoice', 'base', 100, null, '11a', array['11a']::text[], 100, 'MY-SST-02', 10),
    ('MY-S-RED', 'invoice', 'tax', 100, '2100', null, null, 100, null, 20),
    ('MY-S-RED', 'credit_note', 'base', 100, null, '11a', array['11a']::text[], -100, 'MY-SST-02', 10),
    ('MY-S-RED', 'credit_note', 'tax', 100, '2100', null, null, 100, null, 20),
    ('MY-S-STD', 'invoice', 'base', 100, null, '11b', array['11b']::text[], 100, 'MY-SST-02', 10),
    ('MY-S-STD', 'invoice', 'tax', 100, '2100', null, null, 100, null, 20),
    ('MY-S-STD', 'credit_note', 'base', 100, null, '11b', array['11b']::text[], -100, 'MY-SST-02', 10),
    ('MY-S-STD', 'credit_note', 'tax', 100, '2100', null, null, 100, null, 20),
    ('MY-S-ZERO', 'invoice', 'base', 100, null, '18a', array['18a']::text[], 100, 'MY-SST-02', 10),
    ('MY-S-ZERO', 'credit_note', 'base', 100, null, '18a', array['18a']::text[], -100, 'MY-SST-02', 10),
    ('MY-SVT-EXEMPT', 'invoice', 'base', 100, null, '18d', array['18d']::text[], 100, 'MY-SST-02', 10),
    ('MY-SVT-EXEMPT', 'credit_note', 'base', 100, null, '18d', array['18d']::text[], -100, 'MY-SST-02', 10),
    ('MY-SVT-FB', 'invoice', 'base', 100, null, '11c', array['11c']::text[], 100, 'MY-SST-02', 10),
    ('MY-SVT-FB', 'invoice', 'tax', 100, '2101', null, null, 100, null, 20),
    ('MY-SVT-FB', 'credit_note', 'base', 100, null, '11c', array['11c']::text[], -100, 'MY-SST-02', 10),
    ('MY-SVT-FB', 'credit_note', 'tax', 100, '2101', null, null, 100, null, 20),
    ('MY-SVT-STD', 'invoice', 'base', 100, null, '11d', array['11d']::text[], 100, 'MY-SST-02', 10),
    ('MY-SVT-STD', 'invoice', 'tax', 100, '2101', null, null, 100, null, 20),
    ('MY-SVT-STD', 'credit_note', 'base', 100, null, '11d', array['11d']::text[], -100, 'MY-SST-02', 10),
    ('MY-SVT-STD', 'credit_note', 'tax', 100, '2101', null, null, 100, null, 20)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'MY' and t.code = v.tax_code
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
  ('MY', 'MY-SST-02', 'SST-02 — Return of Sales Tax and Service Tax', array['bimonth']::declaration_period[], 'bimonth'::declaration_period, date '2018-09-01', null, 'Sales Tax Act 2018, section 26 and Service Tax Act 2018, section 26 each fix the taxable period at two months, a registered person furnishing one return to the Director General for both taxes on the one form, SST-02. This pack carries the parts and the item numbers RMCD''s own guidelines describe — Part B2, items 11(a) to 11(d), 18(a), 18(b)(ii), 18(d) and 19 — for the value of taxable goods and services by rate, the values relieved as an export, as a manufacturer of nontaxable goods, as a nontaxable service, and as a registered manufacturer''s raw material exempted under Schedule C. The item numbers that compute the amount of tax due on each rate band, and the totals that sum them to the figure payable, could not be read from a machine-readable copy of the RMCD guideline this session (see the pack''s README, "Sources"); this pack states them as the ordinary arithmetic of an ad valorem tax — the rate of the value already declared — and a reviewer with the live SST-02 form open should check the item numbers before relying on them.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Sales Tax Act 2018 and Service Tax Act 2018, each section 26 with the Regulations made under it — a registered person furnishes the return and pays the tax due not later than the last day of the month following the taxable period. For a taxable period of January and February, the return and the payment are due by 31 March.', null, null)
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
  ('MY', 'MY-SST-02', '11a', 'base', 'Value of taxable goods sold, disposed of or first used, at 5 %', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 11(a) — the value of taxable goods taxed at the reduced rate the Sales Tax (Rates of Tax) Order 2018, First Schedule, sets for a specified list of goods.', 'sst02-return-guide'),
  ('MY', 'MY-SST-02', '12a', 'total', 'Sales Tax at 5 % on item 11(a)', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], 5, '11a', false, false, null, 'Sales Tax Act 2018, section 15 — the tax is charged at the rate specified in the Sales Tax (Rates of Tax) Order 2018. The item number the form itself gives this figure could not be confirmed this session; the arithmetic is not in doubt.', 'sst-rates-guide'),
  ('MY', 'MY-SST-02', '11b', 'base', 'Value of taxable goods sold, disposed of or first used, at 10 %', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 11(b) — the value of taxable goods taxed at the standard rate, the residual rule of the Sales Tax (Rates of Tax) Order 2018 for a taxable good the First Schedule does not name at 5 % and that is not taxed at a specific rate.', 'sst02-return-guide'),
  ('MY', 'MY-SST-02', '12b', 'total', 'Sales Tax at 10 % on item 11(b)', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], 10, '11b', false, false, null, 'As item 12(a), at the standard rate.', 'sst-rates-guide'),
  ('MY', 'MY-SST-02', '11c', 'base', 'Value of taxable services at 6 %', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 11(c) — the value of a taxable service the Service Tax (Rate of Tax) Order keeps at 6 % rather than raising to the general rate: food and beverage service, telecommunication, parking and logistics, per the Ministry of Finance''s announcement of the rate increase and scope expansion effective 1 March 2024 and 1 July 2025.', 'mof-sst-2025'),
  ('MY', 'MY-SST-02', '12c', 'total', 'Service Tax at 6 % on item 11(c)', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], 6, '11c', false, false, null, 'Service Tax Act 2018, section 26 — the tax is charged at the rate specified in the Service Tax (Rate of Tax) Order.', 'sst-rates-guide'),
  ('MY', 'MY-SST-02', '11d', 'base', 'Value of taxable services at 8 %', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2 — the value of a taxable service at the general rate the Ministry of Finance raised from 6 % to 8 % effective 1 March 2024, and extended on 1 July 2025 to leasing and rental, financial services and other newly taxable groups: professional, consultancy, management, IT, employment, credit card and most other services regulation 2018''s First Schedule lists. This pack''s placement of the general 8 % band on item 11(d) is its own reading and not a confirmed reading of the current form: the secondary source this session could read for the form''s item numbers predates the 2024 rate restructuring and shows only a single-group example. A reviewer with the live SST-02 form open should check this item number before relying on it.', 'mof-sst-2025'),
  ('MY', 'MY-SST-02', '12d', 'total', 'Service Tax at 8 % on item 11(d)', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], 8, '11d', false, false, null, 'As item 12(c), at the general rate.', 'sst-rates-guide'),
  ('MY', 'MY-SST-02', '12', 'total', 'Total Sales Tax and Service Tax due for the period', '{}'::jsonb, 90, null, array['12a', '12b', '12c', '12d']::text[], '{}'::text[], null, null, false, false, null, 'The sum of the tax due at every rate this pack carries. RMCD''s own form carries further items this pack does not model — bad debt relief, a deduction for tax already accounted for on a credit note, penalties and a carried-forward credit — which is why this total is this pack''s own and not necessarily the form''s own printed line; see the pack''s README.', 'sst02-return-guide'),
  ('MY', 'MY-SST-02', '18a', 'base', 'Exempted export, Special Area and Designated Area', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 18(a). Sales Tax Act 2018, section 41 — where it is proved to the satisfaction of the Director General that taxable goods have been exported, the tax is remitted or, if paid, refunded; goods moved into a Special Area (Labuan, Langkawi, Tioman and a free zone) or a Designated Area receive the same relief under the Act''s own territorial rules for those areas.', 'sales-tax-act'),
  ('MY', 'MY-SST-02', '18b2', 'base', 'Schedule B — manufacturer of specific nontaxable goods', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 18(b)(ii). Sales Tax Act 2018, section 2 defines "taxable goods" as goods other than goods exempted from tax by order of the Minister under section 34, and the Sales Tax (Goods Exempted From Sales Tax) Order 2018, Schedule B, names the goods a scheduled manufacturer produces that carry no Sales Tax at all — basic foodstuffs (rice, sugar, salt, flour and the like) among them. The value is reported here because the goods are outside the definition of taxable goods, and not because a taxable supply was relieved.', 'sst-rates-guide'),
  ('MY', 'MY-SST-02', '18d', 'base', 'Nontaxable services', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 18(d) — the value of a service a registered person provides that is not itself a taxable service under the First Schedule of the Service Tax Regulations 2018: outside the schedule''s own groups, or supplied by a person below the threshold that group carries.', 'sst02-return-guide'),
  ('MY', 'MY-SST-02', '19', 'base', 'Purchase or importation of raw materials exempted from Sales Tax', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SST-02, Part B2, item 19. Sales Tax (Persons Exempted From Payment of Tax) Order 2018, Schedule C — a registered manufacturer approved by the Director General purchases or imports a raw material, component or packaging material used solely in manufacturing taxable goods free of Sales Tax, against a CJ(P) exemption certificate; this item records what the exemption relieved.', 'sst-rates-guide')
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
  ('MY-BS', 'MY', 'default', 'Statement of financial position', 'balance_sheet', 'MY-ORIGINAL', date '1970-01-01', null, 'Malaysia prescribes no line items of its own that this session could read as a primary, openly served text: Companies Act 2016, section 245 requires a company''s financial statements to comply with the approved accounting standards MASB issues — MFRS, converging with IFRS, or MPERS, converging with the IFRS for SMEs Accounting Standard — and this session could not open either standard''s own paragraphs (they are served to registered users; see the pack''s README, "Sources"). This statement is original: it groups this chart''s own accounts by the code ranges accounts.csv gives them — current and non-current, receivables and payables split from other balances — the same classification MFRS 101 and Section 4 of MPERS use, without transcribing either standard''s own line items or their paragraph numbering.', null),
  ('MY-IS', 'MY', 'default', 'Statement of profit or loss', 'income_statement', 'MY-ORIGINAL', date '1970-01-01', null, 'As MY-BS: original, grouped by the code ranges accounts.csv gives this chart''s revenue, cost and expense accounts, by nature.', null)
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
  ('MY-BS', 'CA-CASH', 'CA', 'Cash and cash equivalents', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-REC', 'CA', 'Trade and other receivables', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-TAX', 'CA', 'Sales Tax and Service Tax refundable by RMCD', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-STAFF', 'CA', 'Advances to staff', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-INV', 'CA', 'Inventories', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-STI', 'CA', 'Short-term investments', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-ITAX', 'CA', 'Income tax recoverable', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA-PREP', 'CA', 'Prepayments and accrued income', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CA', null, 'Current assets', '{}'::jsonb, 90, 1, true, array['CA-CASH', 'CA-REC', 'CA-TAX', 'CA-STAFF', 'CA-INV', 'CA-STI', 'CA-ITAX', 'CA-PREP']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA-PPE', 'NCA', 'Property, plant and equipment', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA-INVPROP', 'NCA', 'Investment property', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA-INTANG', 'NCA', 'Intangible assets and goodwill', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA-ASSOC', 'NCA', 'Investments in associates and joint ventures', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA-FIN', 'NCA', 'Long-term financial assets and deposits', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA-DTA', 'NCA', 'Deferred tax assets', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCA', null, 'Non-current assets', '{}'::jsonb, 160, 1, true, array['NCA-PPE', 'NCA-INVPROP', 'NCA-INTANG', 'NCA-ASSOC', 'NCA-FIN', 'NCA-DTA']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'TA', null, 'Total assets', '{}'::jsonb, 170, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-PAY', 'CL', 'Trade payables', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-OTH', 'CL', 'Other payables and accruals', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-TAXP', 'CL', 'Sales Tax and Service Tax payable — output', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-TAXSETTLE', 'CL', 'Sales Tax and Service Tax payable to RMCD — net of a filed return', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-STAT', 'CL', 'Statutory and payroll liabilities', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-FIN', 'CL', 'Borrowings and other current financial liabilities', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-ITAX', 'CL', 'Income tax payable', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL-PROV', 'CL', 'Provisions — current', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'CL', null, 'Current liabilities', '{}'::jsonb, 260, 1, true, array['CL-PAY', 'CL-OTH', 'CL-TAXP', 'CL-TAXSETTLE', 'CL-STAT', 'CL-FIN', 'CL-ITAX', 'CL-PROV']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCL-FIN', 'NCL', 'Borrowings — non-current portion', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCL-DTAX', 'NCL', 'Deferred tax liabilities', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCL-PROV', 'NCL', 'Provisions — non-current', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'NCL', null, 'Non-current liabilities', '{}'::jsonb, 300, 1, true, array['NCL-FIN', 'NCL-DTAX', 'NCL-PROV']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'TL', null, 'Total liabilities', '{}'::jsonb, 310, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'EQ-CAP', 'EQ', 'Share capital', '{}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'EQ-RES', 'EQ', 'Other reserves', '{}'::jsonb, 330, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'EQ-RET', 'EQ', 'Retained earnings', '{}'::jsonb, 340, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'EQ', null, 'Total equity', '{}'::jsonb, 350, 1, true, array['EQ-CAP', 'EQ-RES', 'EQ-RET']::text[], '{}'::text[], null, null, null),
  ('MY-BS', 'TLE', null, 'Total liabilities and equity', '{}'::jsonb, 360, 1, true, array['TL', 'EQ']::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'COGS', null, 'Cost of sales', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['COGS']::text[], null, null, null),
  ('MY-IS', 'OTH-INC', null, 'Other income', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'OPEX', null, 'Administrative and other operating expenses', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'FIN', null, 'Finance costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'PRETAX', null, 'Profit before tax', '{}'::jsonb, 80, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR', 'FIN']::text[], null, null, null),
  ('MY-IS', 'TAX', null, 'Income tax expense', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MY-IS', 'PROFIT', null, 'Profit for the year', '{}'::jsonb, 100, 1, true, array['PRETAX']::text[], array['TAX']::text[], null, null, null)
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
    ('MY-BS', 'CA-CASH', 10, 'code_range', '1000', '1040', null, 'any'),
    ('MY-BS', 'CA-REC', 10, 'code_range', '1100', '1140', null, 'any'),
    ('MY-BS', 'CA-REC', 20, 'account_code', '2990', null, null, 'debit'),
    ('MY-BS', 'CA-TAX', 10, 'account_code', '1155', null, null, 'any'),
    ('MY-BS', 'CA-STAFF', 10, 'account_code', '1160', null, null, 'any'),
    ('MY-BS', 'CA-INV', 10, 'code_range', '1200', '1230', null, 'any'),
    ('MY-BS', 'CA-STI', 10, 'account_code', '1300', null, null, 'any'),
    ('MY-BS', 'CA-ITAX', 10, 'account_code', '1350', null, null, 'any'),
    ('MY-BS', 'CA-PREP', 10, 'code_range', '1400', '1410', null, 'any'),
    ('MY-BS', 'NCA-PPE', 10, 'code_range', '1600', '1671', null, 'any'),
    ('MY-BS', 'NCA-INVPROP', 10, 'account_code', '1700', null, null, 'any'),
    ('MY-BS', 'NCA-INTANG', 10, 'code_range', '1750', '1760', null, 'any'),
    ('MY-BS', 'NCA-ASSOC', 10, 'code_range', '1800', '1810', null, 'any'),
    ('MY-BS', 'NCA-FIN', 10, 'code_range', '1830', '1840', null, 'any'),
    ('MY-BS', 'NCA-DTA', 10, 'account_code', '1900', null, null, 'any'),
    ('MY-BS', 'CL-PAY', 10, 'account_code', '2000', null, null, 'any'),
    ('MY-BS', 'CL-PAY', 20, 'account_code', '2990', null, null, 'credit'),
    ('MY-BS', 'CL-OTH', 10, 'code_range', '2010', '2040', null, 'any'),
    ('MY-BS', 'CL-TAXP', 10, 'code_range', '2100', '2102', null, 'any'),
    ('MY-BS', 'CL-TAXSETTLE', 10, 'account_code', '2110', null, null, 'any'),
    ('MY-BS', 'CL-STAT', 10, 'code_range', '2150', '2190', null, 'any'),
    ('MY-BS', 'CL-FIN', 10, 'code_range', '2200', '2250', null, 'any'),
    ('MY-BS', 'CL-ITAX', 10, 'account_code', '2300', null, null, 'any'),
    ('MY-BS', 'CL-PROV', 10, 'code_range', '2350', '2360', null, 'any'),
    ('MY-BS', 'NCL-FIN', 10, 'code_range', '2400', '2430', null, 'any'),
    ('MY-BS', 'NCL-DTAX', 10, 'account_code', '2500', null, null, 'any'),
    ('MY-BS', 'NCL-PROV', 10, 'account_code', '2550', null, null, 'any'),
    ('MY-BS', 'EQ-CAP', 10, 'code_range', '3000', '3010', null, 'any'),
    ('MY-BS', 'EQ-RES', 10, 'code_range', '3100', '3110', null, 'any'),
    ('MY-BS', 'EQ-RET', 10, 'code_range', '3200', '3210', null, 'any'),
    ('MY-IS', 'REV', 10, 'code_range', '4000', '4030', null, 'any'),
    ('MY-IS', 'COGS', 10, 'code_range', '5000', '5100', null, 'any'),
    ('MY-IS', 'OTH-INC', 10, 'code_range', '4500', '4790', null, 'any'),
    ('MY-IS', 'OPEX', 10, 'code_range', '6000', '6080', null, 'any'),
    ('MY-IS', 'OPEX', 20, 'code_range', '6300', '6990', null, 'any'),
    ('MY-IS', 'DEPR', 10, 'code_range', '6200', '6220', null, 'any'),
    ('MY-IS', 'FIN', 10, 'code_range', '7000', '7030', null, 'any'),
    ('MY-IS', 'TAX', 10, 'code_range', '8000', '8020', null, 'any')
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
  ('MY', 'Malaysia', '{}'::jsonb, array['ms']::text[], 'MYR', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'ms', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'bimonth'::declaration_period)
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
  numbering_legal_reference     = 'Sales Tax Regulations 2018 and Service Tax Regulations 2018 prescribe the particulars an invoice must state, a serial number among them; neither regulation''s own numbered provision could be read as a primary text this session (RMCD''s guides describe the particulars in prose rather than quoting the regulation), so `sequential` records that an identifying number is required and not, in so many words, that the series may carry no gap. The pattern in number_format is one a business may choose.',
  numbering_source_key          = 'sst-rates-guide',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Sales Tax Act 2018, section 8 charges the tax on a taxable person who sells, disposes of otherwise than by sale, or first uses, taxable goods manufactured by them in Malaysia — a rule closer to the delivery or removal of the goods than to the invoice. Service Tax Act 2018, section 7 read with the general guide on Service Tax: the tax is generally due when payment is received for the taxable service, or, failing payment within twelve months of the invoice, on the day after that period — closer to payment than to delivery. `documents.tax_point` is one value for the whole country and neither rule alone states it; `earliest_of_delivery_or_payment` is the closest of the five values to both halves, and is exact for neither. The approximation is recorded in docs/international.md.',
  tax_point_source_key          = 'sales-tax-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'pint-my',
  einvoice_mandatory_from       = date '2024-08-01',
  einvoice_obligation           = 'mandatory',
  einvoice_legal_reference      = 'Income Tax Act 1967, section 82C imposes a duty to issue an electronic invoice for a transaction in respect of goods sold or services performed, phased in by the Minister; the Income Tax (Issuance of Electronic Invoice) Rules 2024 [P.U. (A) 265/2024] set the particulars, in force 1 October 2024. LHDNM phased the duty by annual turnover or revenue: 1 August 2024 above RM100 million, 1 January 2025 above RM25 million, 1 July 2025 above RM5 million and 1 January 2026 above RM1 million: `mandatory_from` states the first of these, the day the duty first bound any taxpayer. The exemption threshold below which a taxpayer need not comply has since been raised in stages — to RM1,000,000 in December 2025 and to RM3,000,000 by the e-Invoice General Guideline, version 4.8 of 30 August 2026 — which this pack''s `released_at` falls after, so a large share of Malaysian companies are, at that date, not yet bound by a duty the statute still imposes on the rest; docs/international.md records that the format has no field for a turnover-dependent exemption threshold that moves by administrative guideline rather than by a dated rule. The profile is PINT MY, built on UBL 2.1 in the same shape as the MyInvois JSON/XML particulars; a taxpayer submitting through a Peppol access point rather than the MyInvois Portal or API directly still submits to LHDNM''s MyInvois system for validation, which is a **pre-issuance clearance**: the invoice is not legally the taxpayer''s until LHDNM returns a Unique Identifier Number and a QR code, ordinarily before it reaches the buyer. Ekwo has no document status for a step that happens between posting and delivery and waits on an external answer; docs/international.md records that gap under "From Malaysia", and this pack does not attempt to model the UIN, the QR code or the 72-hour rejection window. The party scheme, 0230, is the SSM registration number, the identifier PINT MY and the MyInvois particulars both use; `vat_scheme` is empty, as it is for every pack of a country that levies no value added tax: Malaysia''s Tax Identification Number (Nombor Pengenalan Cukai, TIN) is a LHDNM identifier with no ISO 6523 scheme of its own found this session.',
  einvoice_source_key           = 'ita-1967-82c',
  party_scheme                  = '0230',
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'MY';
