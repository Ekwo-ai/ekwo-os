-- Ekwo OS — Cyprus: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/cy at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build cy`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   The Value Added Tax Laws of 2000 to 2023 (Ν. 95(Ι)/2000), consolidated text (CyLII — Cyprus Legal Information Institute (cylaw.org). Unofficial consolidation: the Department of the Law Commissioner and the Tax Department's own sites returned 403 to every automated request made while building this pack, so the base law and every amendment were read here instead, decoded from the site's native Windows-1253 encoding to avoid the mojibake a naive UTF-8 read produces. A reviewer should check a citation against the enacted text and the Official Gazette before relying on it.)
--     https://www.cylaw.org/nomoi/enop/non-ind/2000_1_95/full.html
--   Οι περί Φόρου Προστιθέμενης Αξίας (Γενικοί) Κανονισμοί του 2001 (Κ.Δ.Π. 314/2001) — the VAT (General) Regulations 2001 (Cyprus Official Gazette (Επίσημη Εφημερίδα της Κυπριακής Δημοκρατίας), Παράρτημα Τρίτο (Ι), reproduced by cylaw.org)
--     https://www.cylaw.org/KDP/data/2001_1_314.pdf
--   Το περί Φόρου Προστιθέμενης Αξίας (Τροποποίηση του Πέμπτου Παραρτήματος και Δωδέκατου Παραρτήματος) Διάταγμα του 2020 (Κ.Δ.Π. 268/2020) (Cyprus Official Gazette (Επίσημη Εφημερίδα της Κυπριακής Δημοκρατίας), Παράρτημα Τρίτο (Ι), Αρ. 5303, reproduced by cylaw.org)
--     https://www.cylaw.org/KDP/data/2020_1_268.pdf
--   The Late Payments in Commercial Transactions Law of 2012 (Ν. 123(Ι)/2012) (CyLII — Cyprus Legal Information Institute (cylaw.org), unofficial consolidation)
--     https://www.cylaw.org/nomoi/enop/non-ind/2012_1_123/full.html
--   The Companies Law, Cap. 113, English translation made July 2014 (Department of the Registrar of Companies and Intellectual Property, Ministry of Energy, Commerce and Industry)
--     https://www.companies.gov.cy/assets/modules/wgp/articles/201801/49/docs/cap_113_translation_made_july_2014.pdf
--   IFRS jurisdiction profile — Cyprus (IFRS Foundation)
--     https://www.ifrs.org/content/ifrs/home/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction.html/cyprus
--   eInvoicing in Cyprus (European Commission — Digital Building Blocks)
--     https://ec.europa.eu/digital-building-blocks/sites/display/DIGITAL/eInvoicing+in+Cyprus
--   Cyprus SME VAT rules — national annual threshold €15,600 (European Commission — Taxation and Customs Union)
--     https://sme-vat-rules.ec.europa.eu/national-vat-rules/cyprus-sme-rules_en
--   Tax For All (TFA) — the portal the VAT return and the VIES statement are filed on (Tax Department, Ministry of Finance)
--     https://taxforall.mof.gov.cy/
--   VAT Definitive Guides, Issue 2 — including an unofficial translation of VAT Return Form 4 and its completion notes (Chelco VAT Ltd. Not an official source: the Tax Department's own guide could not be retrieved for this pack (its former mof.gov.cy address now redirects to gov.cy, and the document was not found at the new one or in the Wayback Machine). Kept as the best available description of which figure the return asks for in which box, and flagged wherever it is relied on; see the pack README.)
--     https://chelcovat.com/wp-content/uploads/2021/09/VAT-Definitive-Guides-i.2-VAT-Returns-%CE%95%CE%9D.pdf
--   Council Directive 2006/112/EC of 28 November 2006 on the common system of value added tax, consolidated text (Publications Office of the European Union — EUR-Lex)
--     https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:02006L0112-20220701
--   EN 16931 compliance — the European standard on electronic invoicing under Directive 2014/55/EU (European Commission — Digital Building Blocks)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — the VAT category code list of EN 16931 (BT-118 and BT-151), as the OpenPEPPOL subset publishes it (OpenPEPPOL — the list itself is published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — the VAT exemption reason code list of EN 16931 (BT-121) (OpenPEPPOL — the list itself is published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   Peppol code list of electronic address schemes (ISO 6523 ICD) (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   The IFRS for SMEs Accounting Standard (2015 edition), section 4 — Statement of Financial Position, and section 5 — Statement of Comprehensive Income and Income Statement (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('CY', 'Cyprus', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, 'ae1b0488639ff33d488c6983911f99008a9a83f3cf180bab3acf3a03c682a11b', '[{"key":"vat-law-95-2000","title":"The Value Added Tax Laws of 2000 to 2023 (Ν. 95(Ι)/2000), consolidated text","publisher":"CyLII — Cyprus Legal Information Institute (cylaw.org). Unofficial consolidation: the Department of the Law Commissioner and the Tax Department''s own sites returned 403 to every automated request made while building this pack, so the base law and every amendment were read here instead, decoded from the site''s native Windows-1253 encoding to avoid the mojibake a naive UTF-8 read produces. A reviewer should check a citation against the enacted text and the Official Gazette before relying on it.","url":"https://www.cylaw.org/nomoi/enop/non-ind/2000_1_95/full.html","consulted_on":"2026-09-25","kind":"law"},{"key":"vat-regs-2001","title":"Οι περί Φόρου Προστιθέμενης Αξίας (Γενικοί) Κανονισμοί του 2001 (Κ.Δ.Π. 314/2001) — the VAT (General) Regulations 2001","publisher":"Cyprus Official Gazette (Επίσημη Εφημερίδα της Κυπριακής Δημοκρατίας), Παράρτημα Τρίτο (Ι), reproduced by cylaw.org","url":"https://www.cylaw.org/KDP/data/2001_1_314.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"kdp-268-2020","title":"Το περί Φόρου Προστιθέμενης Αξίας (Τροποποίηση του Πέμπτου Παραρτήματος και Δωδέκατου Παραρτήματος) Διάταγμα του 2020 (Κ.Δ.Π. 268/2020)","publisher":"Cyprus Official Gazette (Επίσημη Εφημερίδα της Κυπριακής Δημοκρατίας), Παράρτημα Τρίτο (Ι), Αρ. 5303, reproduced by cylaw.org","url":"https://www.cylaw.org/KDP/data/2020_1_268.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"late-payments-law-2012","title":"The Late Payments in Commercial Transactions Law of 2012 (Ν. 123(Ι)/2012)","publisher":"CyLII — Cyprus Legal Information Institute (cylaw.org), unofficial consolidation","url":"https://www.cylaw.org/nomoi/enop/non-ind/2012_1_123/full.html","consulted_on":"2026-09-25","kind":"law"},{"key":"companies-law-cap113","title":"The Companies Law, Cap. 113, English translation made July 2014","publisher":"Department of the Registrar of Companies and Intellectual Property, Ministry of Energy, Commerce and Industry","url":"https://www.companies.gov.cy/assets/modules/wgp/articles/201801/49/docs/cap_113_translation_made_july_2014.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"ifrs-cyprus","title":"IFRS jurisdiction profile — Cyprus","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/ifrs/home/use-around-the-world/use-of-ifrs-standards-by-jurisdiction/view-jurisdiction.html/cyprus","consulted_on":"2026-09-25","kind":"guidance"},{"key":"ec-einvoicing-cy","title":"eInvoicing in Cyprus","publisher":"European Commission — Digital Building Blocks","url":"https://ec.europa.eu/digital-building-blocks/sites/display/DIGITAL/eInvoicing+in+Cyprus","consulted_on":"2026-09-25","kind":"guidance"},{"key":"eu-sme-rules-cy","title":"Cyprus SME VAT rules — national annual threshold €15,600","publisher":"European Commission — Taxation and Customs Union","url":"https://sme-vat-rules.ec.europa.eu/national-vat-rules/cyprus-sme-rules_en","consulted_on":"2026-09-25","kind":"guidance"},{"key":"taxforall-portal","title":"Tax For All (TFA) — the portal the VAT return and the VIES statement are filed on","publisher":"Tax Department, Ministry of Finance","url":"https://taxforall.mof.gov.cy/","consulted_on":"2026-09-25","kind":"portal"},{"key":"cy-vat4-guide-chelco","title":"VAT Definitive Guides, Issue 2 — including an unofficial translation of VAT Return Form 4 and its completion notes","publisher":"Chelco VAT Ltd. Not an official source: the Tax Department''s own guide could not be retrieved for this pack (its former mof.gov.cy address now redirects to gov.cy, and the document was not found at the new one or in the Wayback Machine). Kept as the best available description of which figure the return asks for in which box, and flagged wherever it is relied on; see the pack README.","url":"https://chelcovat.com/wp-content/uploads/2021/09/VAT-Definitive-Guides-i.2-VAT-Returns-%CE%95%CE%9D.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"vat-directive-2006-112","title":"Council Directive 2006/112/EC of 28 November 2006 on the common system of value added tax, consolidated text","publisher":"Publications Office of the European Union — EUR-Lex","url":"https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:02006L0112-20220701","consulted_on":"2026-09-25","kind":"law"},{"key":"en-16931","title":"EN 16931 compliance — the European standard on electronic invoicing under Directive 2014/55/EU","publisher":"European Commission — Digital Building Blocks","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — the VAT category code list of EN 16931 (BT-118 and BT-151), as the OpenPEPPOL subset publishes it","publisher":"OpenPEPPOL — the list itself is published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — the VAT exemption reason code list of EN 16931 (BT-121)","publisher":"OpenPEPPOL — the list itself is published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"},{"key":"peppol-eas","title":"Peppol code list of electronic address schemes (ISO 6523 ICD)","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-25","kind":"standard"},{"key":"ifrs-for-smes-standard","title":"The IFRS for SMEs Accounting Standard (2015 edition), section 4 — Statement of Financial Position, and section 5 — Statement of Comprehensive Income and Income Statement","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('CY', 'default', 'Cyprus reference chart of accounts', '{}'::jsonb, true, 'companies', array['CY-IFRS-SME-BS', 'CY-IFRS-SME-IS']::text[], null, 'Cyprus prescribes no chart of accounts and no statutory balance sheet or profit and loss format. The Companies Law, Cap. 113, s. 141A (as substituted) requires every company''s accounts to give a true and fair view and to be prepared in accordance with International Financial Reporting Standards as adopted by the European Union under Regulation (EC) No 1606/2002; the Eighth Schedule to Cap. 113, which once set out a statutory balance sheet and profit and loss format transposing the Fourth Company Law Directive (78/660/EEC), was repealed in 2003 by s. 20 of Ν. 167(Ι)/2003 when that requirement was introduced, and IAS 1''s own layout is deliberately not a fixed table of captions. This chart is therefore original, follows no published format, and instead of leaving every account to fall back onto `packs/generic/`, `statements.json` gives it a statement of financial position and a statement of comprehensive income of its own, built on the minimum line items of the IFRS for SMEs Accounting Standard, sections 4 and 5 — chosen as an illustrative layout precise enough to read a Cyprus chart against, not because Cyprus law requires or permits that Standard in place of full IFRS as adopted by the European Union.', 'companies-law-cap113')
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
  ('CY', 'default', '0010', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('CY', 'default', '0020', 'Software, licences and similar intangible assets', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('CY', 'default', '0021', 'Software, licences and similar intangible assets — accumulated amortisation', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('CY', 'default', '0030', 'Intangible assets under development', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('CY', 'default', '0100', 'Investment property', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('CY', 'default', '0110', 'Land', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('CY', 'default', '0120', 'Buildings', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('CY', 'default', '0121', 'Buildings — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('CY', 'default', '0130', 'Plant and machinery', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('CY', 'default', '0131', 'Plant and machinery — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('CY', 'default', '0140', 'Furniture and fixtures', '{}'::jsonb, 'asset_fixed', false, null, 110),
  ('CY', 'default', '0141', 'Furniture and fixtures — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 120),
  ('CY', 'default', '0150', 'Computer and office equipment', '{}'::jsonb, 'asset_fixed', false, null, 130),
  ('CY', 'default', '0151', 'Computer and office equipment — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 140),
  ('CY', 'default', '0160', 'Motor vehicles', '{}'::jsonb, 'asset_fixed', false, null, 150),
  ('CY', 'default', '0161', 'Motor vehicles — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 160),
  ('CY', 'default', '0170', 'Right-of-use assets (leases)', '{}'::jsonb, 'asset_fixed', false, null, 170),
  ('CY', 'default', '0171', 'Right-of-use assets — accumulated depreciation', '{}'::jsonb, 'asset_fixed', false, null, 180),
  ('CY', 'default', '0180', 'Assets under construction and payments on account', '{}'::jsonb, 'asset_fixed', false, null, 190),
  ('CY', 'default', '0200', 'Investments in subsidiaries', '{}'::jsonb, 'asset_non_current', false, null, 200),
  ('CY', 'default', '0210', 'Investments in associates and joint ventures', '{}'::jsonb, 'asset_non_current', false, null, 220),
  ('CY', 'default', '0220', 'Other non-current investments', '{}'::jsonb, 'asset_non_current', false, null, 230),
  ('CY', 'default', '0230', 'Loans to related companies — non-current', '{}'::jsonb, 'asset_non_current', false, null, 240),
  ('CY', 'default', '0240', 'Other non-current receivables', '{}'::jsonb, 'asset_non_current', false, null, 250),
  ('CY', 'default', '0250', 'Deferred tax asset', '{}'::jsonb, 'asset_non_current', false, null, 260),
  ('CY', 'default', '1000', 'Inventory — raw materials and consumables', '{}'::jsonb, 'asset_current', false, null, 270),
  ('CY', 'default', '1010', 'Inventory — work in progress', '{}'::jsonb, 'asset_current', false, null, 280),
  ('CY', 'default', '1020', 'Inventory — finished goods and goods for resale', '{}'::jsonb, 'asset_current', false, null, 290),
  ('CY', 'default', '1030', 'Inventory — payments on account', '{}'::jsonb, 'asset_prepayments', false, null, 300),
  ('CY', 'default', '1100', 'Trade receivables', '{}'::jsonb, 'asset_receivable', true, null, 310),
  ('CY', 'default', '1105', 'Provision for expected credit losses', '{}'::jsonb, 'asset_current', false, null, 320),
  ('CY', 'default', '1110', 'Amounts owed by related companies — current', '{}'::jsonb, 'asset_current', false, null, 330),
  ('CY', 'default', '1120', 'Directors'' current account — debit', '{}'::jsonb, 'asset_current', false, null, 340),
  ('CY', 'default', '1130', 'Other receivables', '{}'::jsonb, 'asset_current', false, null, 350),
  ('CY', 'default', '1140', 'VAT on purchases — input tax', '{}'::jsonb, 'asset_current', false, null, 360),
  ('CY', 'default', '1150', 'VAT recoverable from the Tax Department', '{}'::jsonb, 'asset_current', true, null, 370),
  ('CY', 'default', '1160', 'Special Contribution for Defence recoverable', '{}'::jsonb, 'asset_current', false, null, 380),
  ('CY', 'default', '1170', 'Provisional corporate tax paid', '{}'::jsonb, 'asset_current', false, null, 390),
  ('CY', 'default', '1300', 'Prepaid expenses', '{}'::jsonb, 'asset_prepayments', false, null, 400),
  ('CY', 'default', '1310', 'Accrued income', '{}'::jsonb, 'asset_prepayments', false, null, 410),
  ('CY', 'default', '1500', 'Bank current account — euro', '{}'::jsonb, 'asset_cash', false, null, 420),
  ('CY', 'default', '1510', 'Bank deposit account', '{}'::jsonb, 'asset_cash', false, null, 430),
  ('CY', 'default', '1520', 'Bank account in a foreign currency', '{}'::jsonb, 'asset_cash', false, null, 440),
  ('CY', 'default', '1530', 'Petty cash', '{}'::jsonb, 'asset_cash', false, null, 450),
  ('CY', 'default', '1540', 'Cash in transit', '{}'::jsonb, 'asset_cash', false, null, 460),
  ('CY', 'default', '1550', 'Card acquirer settlement account', '{}'::jsonb, 'asset_cash', false, null, 470),
  ('CY', 'default', '2000', 'Bank loans — current portion', '{}'::jsonb, 'liability_current', false, null, 480),
  ('CY', 'default', '2010', 'Bank overdraft', '{}'::jsonb, 'liability_current', false, null, 490),
  ('CY', 'default', '2020', 'Credit card account', '{}'::jsonb, 'liability_credit_card', false, null, 500),
  ('CY', 'default', '2030', 'Lease liabilities — current portion', '{}'::jsonb, 'liability_current', false, null, 510),
  ('CY', 'default', '2040', 'Payments received on account', '{}'::jsonb, 'liability_current', false, null, 520),
  ('CY', 'default', '2100', 'Trade payables', '{}'::jsonb, 'liability_payable', true, null, 530),
  ('CY', 'default', '2110', 'Amounts owed to related companies — current', '{}'::jsonb, 'liability_current', false, null, 540),
  ('CY', 'default', '2200', 'VAT on sales — output tax', '{}'::jsonb, 'liability_current', false, null, 550),
  ('CY', 'default', '2210', 'VAT payable to the Tax Department', '{}'::jsonb, 'liability_current', true, null, 560),
  ('CY', 'default', '2220', 'Special Contribution for Defence payable', '{}'::jsonb, 'liability_current', false, null, 570),
  ('CY', 'default', '2230', 'Social Insurance contributions payable', '{}'::jsonb, 'liability_current', false, null, 580),
  ('CY', 'default', '2240', 'General Healthcare System (GeSY) contributions payable', '{}'::jsonb, 'liability_current', false, null, 590),
  ('CY', 'default', '2250', 'Payroll — net wages payable', '{}'::jsonb, 'liability_current', false, null, 600),
  ('CY', 'default', '2260', 'Directors'' current account — credit', '{}'::jsonb, 'liability_current', false, null, 610),
  ('CY', 'default', '2270', 'Dividends payable', '{}'::jsonb, 'liability_current', false, null, 620),
  ('CY', 'default', '2280', 'Provisional and corporate tax payable', '{}'::jsonb, 'liability_current', false, null, 630),
  ('CY', 'default', '2290', 'Deferred income — current', '{}'::jsonb, 'liability_current', false, null, 640),
  ('CY', 'default', '2300', 'Other payables and accruals', '{}'::jsonb, 'liability_current', false, null, 650),
  ('CY', 'default', '2400', 'Suspense account', '{}'::jsonb, 'liability_current', false, null, 660),
  ('CY', 'default', '3000', 'Bank loans — non-current', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('CY', 'default', '3010', 'Lease liabilities — non-current', '{}'::jsonb, 'liability_non_current', false, null, 680),
  ('CY', 'default', '3020', 'Amounts owed to related companies — non-current', '{}'::jsonb, 'liability_non_current', false, null, 690),
  ('CY', 'default', '3030', 'Deferred tax liability', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('CY', 'default', '3100', 'Provision for staff retirement benefits', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('CY', 'default', '3110', 'Other provisions', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('CY', 'default', '3300', 'Share capital', '{}'::jsonb, 'equity', false, null, 730),
  ('CY', 'default', '3310', 'Share premium', '{}'::jsonb, 'equity', false, null, 740),
  ('CY', 'default', '3320', 'Revaluation reserve', '{}'::jsonb, 'equity', false, null, 750),
  ('CY', 'default', '3330', 'Legal reserve (Companies Law, Cap. 113, s. 55)', '{}'::jsonb, 'equity', false, null, 760),
  ('CY', 'default', '3340', 'Other reserves', '{}'::jsonb, 'equity', false, null, 770),
  ('CY', 'default', '3400', 'Retained earnings brought forward', '{}'::jsonb, 'equity_retained', false, null, 780),
  ('CY', 'default', '3410', 'Dividends paid', '{}'::jsonb, 'equity_retained', false, null, 790),
  ('CY', 'default', '4000', 'Revenue — sales at the standard rate', '{}'::jsonb, 'income', false, null, 810),
  ('CY', 'default', '4010', 'Revenue — services at the standard rate', '{}'::jsonb, 'income', false, null, 820),
  ('CY', 'default', '4020', 'Revenue — sales at 9 %', '{}'::jsonb, 'income', false, null, 830),
  ('CY', 'default', '4030', 'Revenue — sales at 5 %', '{}'::jsonb, 'income', false, null, 840),
  ('CY', 'default', '4040', 'Revenue — sales at 3 %', '{}'::jsonb, 'income', false, null, 850),
  ('CY', 'default', '4050', 'Revenue — sales at the zero rate', '{}'::jsonb, 'income', false, null, 860),
  ('CY', 'default', '4060', 'Revenue — exempt activities', '{}'::jsonb, 'income', false, null, 870),
  ('CY', 'default', '4070', 'Revenue — exports of goods outside the European Union', '{}'::jsonb, 'income', false, null, 880),
  ('CY', 'default', '4080', 'Revenue — intra-Community supplies of goods', '{}'::jsonb, 'income', false, null, 890),
  ('CY', 'default', '4090', 'Revenue — services supplied to taxable persons in other Member States', '{}'::jsonb, 'income', false, null, 900),
  ('CY', 'default', '4100', 'Revenue — construction services under the domestic reverse charge', '{}'::jsonb, 'income', false, null, 910),
  ('CY', 'default', '4200', 'Sales returns and allowances', '{}'::jsonb, 'income', false, null, 920),
  ('CY', 'default', '4210', 'Discounts allowed', '{}'::jsonb, 'income', false, null, 930),
  ('CY', 'default', '4300', 'Other operating income', '{}'::jsonb, 'income_other', false, null, 940),
  ('CY', 'default', '4310', 'Rental income', '{}'::jsonb, 'income_other', false, null, 950),
  ('CY', 'default', '4320', 'Gain on disposal of fixed assets', '{}'::jsonb, 'income_other', false, null, 960),
  ('CY', 'default', '4330', 'Foreign exchange gains', '{}'::jsonb, 'income_other', false, null, 970),
  ('CY', 'default', '4340', 'Interest receivable and similar income', '{}'::jsonb, 'income_other', false, null, 980),
  ('CY', 'default', '4350', 'Dividend income', '{}'::jsonb, 'income_other', false, null, 990),
  ('CY', 'default', '5000', 'Purchases — goods for resale', '{}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('CY', 'default', '5010', 'Purchases — raw materials and consumables', '{}'::jsonb, 'expense_direct_cost', false, null, 1010),
  ('CY', 'default', '5020', 'Carriage inwards and import duty', '{}'::jsonb, 'expense_direct_cost', false, null, 1020),
  ('CY', 'default', '5030', 'Subcontractor costs', '{}'::jsonb, 'expense_direct_cost', false, null, 1030),
  ('CY', 'default', '5040', 'Direct labour', '{}'::jsonb, 'expense_direct_cost', false, null, 1040),
  ('CY', 'default', '5050', 'Purchase returns and allowances', '{}'::jsonb, 'expense_direct_cost', false, null, 1050),
  ('CY', 'default', '5060', 'Discounts received', '{}'::jsonb, 'expense_direct_cost', false, null, 1060),
  ('CY', 'default', '5070', 'Opening inventory', '{}'::jsonb, 'expense_direct_cost', false, null, 1070),
  ('CY', 'default', '5080', 'Closing inventory', '{}'::jsonb, 'expense_direct_cost', false, null, 1080),
  ('CY', 'default', '6000', 'Advertising and marketing', '{}'::jsonb, 'expense', false, null, 1090),
  ('CY', 'default', '6010', 'Sales commission', '{}'::jsonb, 'expense', false, null, 1100),
  ('CY', 'default', '6020', 'Carriage outwards', '{}'::jsonb, 'expense', false, null, 1110),
  ('CY', 'default', '6030', 'Distribution staff — wages and salaries', '{}'::jsonb, 'expense', false, null, 1120),
  ('CY', 'default', '6040', 'Distribution staff — employer''s Social Insurance and GeSY', '{}'::jsonb, 'expense', false, null, 1130),
  ('CY', 'default', '6050', 'Delivery vehicle running costs', '{}'::jsonb, 'expense', false, null, 1140),
  ('CY', 'default', '6060', 'Warehouse rent and utilities', '{}'::jsonb, 'expense', false, null, 1150),
  ('CY', 'default', '7000', 'Directors'' remuneration', '{}'::jsonb, 'expense', false, null, 1160),
  ('CY', 'default', '7010', 'Wages and salaries', '{}'::jsonb, 'expense', false, null, 1170),
  ('CY', 'default', '7020', 'Employer''s Social Insurance contributions', '{}'::jsonb, 'expense', false, null, 1180),
  ('CY', 'default', '7030', 'Employer''s General Healthcare System (GeSY) contributions', '{}'::jsonb, 'expense', false, null, 1190),
  ('CY', 'default', '7040', 'Employer''s contributions to provident and pension funds', '{}'::jsonb, 'expense', false, null, 1200),
  ('CY', 'default', '7050', 'Staff training and welfare', '{}'::jsonb, 'expense', false, null, 1210),
  ('CY', 'default', '7060', 'Rent', '{}'::jsonb, 'expense', false, null, 1220),
  ('CY', 'default', '7070', 'Rates and municipal taxes', '{}'::jsonb, 'expense', false, null, 1230),
  ('CY', 'default', '7080', 'Electricity and water', '{}'::jsonb, 'expense', false, null, 1240),
  ('CY', 'default', '7090', 'Insurance', '{}'::jsonb, 'expense', false, null, 1250),
  ('CY', 'default', '7100', 'Repairs and maintenance', '{}'::jsonb, 'expense', false, null, 1260),
  ('CY', 'default', '7110', 'Cleaning and security', '{}'::jsonb, 'expense', false, null, 1270),
  ('CY', 'default', '7120', 'Telephone, internet and postage', '{}'::jsonb, 'expense', false, null, 1280),
  ('CY', 'default', '7130', 'Printing and stationery', '{}'::jsonb, 'expense', false, null, 1290),
  ('CY', 'default', '7140', 'Software subscriptions and IT costs', '{}'::jsonb, 'expense', false, null, 1300),
  ('CY', 'default', '7150', 'Equipment hire', '{}'::jsonb, 'expense', false, null, 1310),
  ('CY', 'default', '7160', 'Motor vehicle running costs and leasing', '{}'::jsonb, 'expense', false, null, 1320),
  ('CY', 'default', '7170', 'Travel and subsistence', '{}'::jsonb, 'expense', false, null, 1330),
  ('CY', 'default', '7180', 'Entertainment', '{}'::jsonb, 'expense', false, null, 1340),
  ('CY', 'default', '7190', 'Audit fee', '{}'::jsonb, 'expense', false, null, 1350),
  ('CY', 'default', '7200', 'Accountancy and bookkeeping fees', '{}'::jsonb, 'expense', false, null, 1360),
  ('CY', 'default', '7210', 'Legal and professional fees', '{}'::jsonb, 'expense', false, null, 1370),
  ('CY', 'default', '7220', 'Registrar of Companies annual levy', '{}'::jsonb, 'expense', false, null, 1380),
  ('CY', 'default', '7230', 'Bank charges', '{}'::jsonb, 'expense', false, null, 1390),
  ('CY', 'default', '7240', 'Card processing charges', '{}'::jsonb, 'expense', false, null, 1400),
  ('CY', 'default', '7250', 'Subscriptions to professional bodies', '{}'::jsonb, 'expense', false, null, 1410),
  ('CY', 'default', '7260', 'Donations', '{}'::jsonb, 'expense', false, null, 1420),
  ('CY', 'default', '7270', 'Bad debts written off', '{}'::jsonb, 'expense', false, null, 1430),
  ('CY', 'default', '7280', 'Movement in the provision for expected credit losses', '{}'::jsonb, 'expense', false, null, 1440),
  ('CY', 'default', '7290', 'Loss on disposal of fixed assets', '{}'::jsonb, 'expense', false, null, 1450),
  ('CY', 'default', '7300', 'Foreign exchange losses', '{}'::jsonb, 'expense', false, null, 1460),
  ('CY', 'default', '7310', 'Rounding differences', '{}'::jsonb, 'expense', false, null, 1470),
  ('CY', 'default', '7320', 'Sundry expenses', '{}'::jsonb, 'expense', false, null, 1480),
  ('CY', 'default', '7400', 'Depreciation — buildings', '{}'::jsonb, 'expense_depreciation', false, null, 1490),
  ('CY', 'default', '7410', 'Depreciation — plant and machinery', '{}'::jsonb, 'expense_depreciation', false, null, 1500),
  ('CY', 'default', '7420', 'Depreciation — furniture and fixtures', '{}'::jsonb, 'expense_depreciation', false, null, 1510),
  ('CY', 'default', '7430', 'Depreciation — computer and office equipment', '{}'::jsonb, 'expense_depreciation', false, null, 1520),
  ('CY', 'default', '7440', 'Depreciation — motor vehicles', '{}'::jsonb, 'expense_depreciation', false, null, 1530),
  ('CY', 'default', '7450', 'Depreciation — right-of-use assets', '{}'::jsonb, 'expense_depreciation', false, null, 1540),
  ('CY', 'default', '7460', 'Amortisation of intangible assets', '{}'::jsonb, 'expense_depreciation', false, null, 1550),
  ('CY', 'default', '8000', 'Bank loan interest', '{}'::jsonb, 'expense', false, null, 1560),
  ('CY', 'default', '8010', 'Lease interest', '{}'::jsonb, 'expense', false, null, 1570),
  ('CY', 'default', '8020', 'Other interest payable and similar expenses', '{}'::jsonb, 'expense', false, null, 1580),
  ('CY', 'default', '8030', 'Late payment interest and compensation for recovery costs', '{}'::jsonb, 'expense', false, null, 1590),
  ('CY', 'default', '8100', 'Corporate tax charge for the year', '{}'::jsonb, 'expense', false, null, 1600),
  ('CY', 'default', '8110', 'Corporate tax — adjustment in respect of prior years', '{}'::jsonb, 'expense', false, null, 1610),
  ('CY', 'default', '8120', 'Deferred tax charge', '{}'::jsonb, 'expense', false, null, 1620),
  ('CY', 'default', '8130', 'Special Contribution for Defence charge', '{}'::jsonb, 'expense', false, null, 1630)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('CY', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('CY', 'CSH', 'Cash', '{}'::jsonb, 'cash', 40),
  ('CY', 'GEN', 'General journal', '{}'::jsonb, 'general', 50),
  ('CY', 'OPN', 'Opening balances', '{}'::jsonb, 'opening', 60),
  ('CY', 'PUR', 'Purchases journal', '{}'::jsonb, 'purchase', 20),
  ('CY', 'SAL', 'Sales journal', '{}'::jsonb, 'sales', 10)
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
  ('CY', 'CY-P-03', 'Purchase, reduced rate 3 %', '{}'::jsonb, null, 'percent', 3, 'purchase', 'domestic', date '2023-07-21', null, 'Ν. 95(Ι)/2000 as consolidated, article 18Β and the Fifteenth Schedule, on the same basis as CY-S-03. Box 4 of the return.', 'S', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-05', 'Purchase, reduced rate 5 %', '{}'::jsonb, null, 'percent', 5, 'purchase', 'domestic', date '2014-01-13', null, 'Ν. 95(Ι)/2000 as consolidated, article 18 and the Fifth Schedule, on the same basis as CY-S-05. Box 4 of the return.', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-09', 'Purchase, reduced rate 9 %', '{}'::jsonb, null, 'percent', 9, 'purchase', 'domestic', date '2014-01-13', null, 'Ν. 95(Ι)/2000 as consolidated, article 18Α and the Twelfth Schedule, on the same basis as CY-S-09. Box 4 of the return.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-19', 'Purchase, standard rate 19 %', '{}'::jsonb, null, 'percent', 19, 'purchase', 'domestic', date '2014-01-13', null, 'Ν. 95(Ι)/2000 as consolidated, article 17 for the rate; the general right of deduction of input tax charged by another taxable person by VAT invoice, subject to holding that invoice under Regulation 12(1) of Κ.Δ.Π. 314/2001. Box 4 of the return.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-EXEMPT', 'Purchase of an exempt supply', '{}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 26 and the Seventh Schedule — the supplier carries on an exempt activity and charges no tax, on the same basis as CY-S-EXEMPT.', 'E', 'VATEX-EU-132', 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-FSR-19', 'Service received from a supplier outside the European Union, 19 %', '{}'::jsonb, null, 'percent', 19, 'purchase', 'foreign_services_received', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 11 — the same self-accounting mechanism as CY-P-ICS-19, for a supplier established outside the European Union. Read directly in the consolidated text. Box 1 (output) and box 4 (input); no box carries the value, as boxes 8B and 11B are for a supplier established in another Member State only.', null, null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-ICG-19', 'Intra-Community acquisition of goods, 19 %', '{}'::jsonb, null, 'percent', 19, 'purchase', 'intracom_acquisition_goods', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 12Α — VAT is charged on the acquisition of goods from another Member State where the acquisition is a taxable acquisition made in Cyprus by a taxable person, transposing Title V, Chapter 2 of Council Directive 2006/112/EC; article 12Γ (read in the same consolidated text, adjacent to article 12Α) sets the time of the acquisition. The tax is self-accounted and, being for a taxable use, deducted in the same period. Read directly in the consolidated text. Box 2 (output) and box 4 (input) of the return; the value in box 7 and box 11A.', 'K', 'VATEX-EU-IC', 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-ICS-19', 'Service received from a taxable person in another Member State, 19 %', '{}'::jsonb, null, 'percent', 19, 'purchase', 'intracom_acquisition_services', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 11 — a taxable person in Cyprus who receives a service from a person established abroad accounts for the tax as if the recipient had made the supply, transposing the general business-to-business self-accounting mechanism behind articles 44 and 196 of Council Directive 2006/112/EC. Read directly in the consolidated text for the self-accounting mechanism; the reason code and category follow from the supplier''s establishment in another Member State rather than from a separate article naming the acquisition (see CY-S-ICS on the same point). Box 1 (output, general — not box 2, which this pack reads as confined to the acquisition of goods under article 12Α) and box 4 (input); the value in box 6 and box 7 and box 11B.', 'K', 'VATEX-EU-IC', 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-P-RCC', 'Construction services from a subcontractor, domestic reverse charge', '{}'::jsonb, null, 'percent', 19, 'purchase', 'domestic_reverse_charge', date '2005-01-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 11Β, on the same basis as CY-S-RCC: the recipient, a taxable person registered for VAT in Cyprus, self-accounts for the tax on a construction service received. Box 1 (output) and box 4 (input); the value in box 7 and not in a box of its own, no such box being carried by this form for a domestic reverse charge.', 'AE', 'VATEX-EU-AE', 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-00', 'Sale, zero rate', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 25 and the Sixth Schedule (Έκτο Παράρτημα) it refers to — goods and services taxed at zero per cent, among them (as read directly in the consolidated text) international transport and related services, seagoing vessels and aircraft used for international transport, gold supplied to the Central Bank, humanitarian donations, infant milk, nappies, sanitary protection, Braille equipment and vehicles for disabled persons, and, temporarily, fresh vegetables and fruit (K.Δ.Π. 337/2025, 1 January to 31 December 2026) and fresh or frozen meat and fish (K.Δ.Π. 168/2026, 6 April to 30 September 2026). A zero-rated supply is a taxable supply and keeps the right to deduct.', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-03', 'Sale, reduced rate 3 %', '{}'::jsonb, null, 'percent', 3, 'sale', 'domestic', date '2023-07-21', null, 'Ν. 95(Ι)/2000 as consolidated, article 18Β, and the Fifteenth Schedule (Δέκατο Πέμπτο Παράρτημα) it refers to — books, newspapers and magazines, in print and in electronic form (other than material devoted wholly or predominantly to advertising), taxed at three per cent. The Article and Schedule were read directly in the consolidated text at cylaw.org. The commencement date of 21 July 2023 is that of "The Value Added Tax (Amendment) (No. 3) Law of 2023", as reported by professional VAT commentary (KPMG Cyprus, PwC Cyprus) rather than read directly by this pack in the Official Gazette; it should be checked against the Gazette text before this pack is relied on — see the pack README.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-05', 'Sale, reduced rate 5 %', '{}'::jsonb, null, 'percent', 5, 'sale', 'domestic', date '2014-01-13', null, 'Ν. 95(Ι)/2000 as consolidated, article 18, and the Fifth Schedule (Πέμπτο Παράρτημα) it refers to — goods and services taxed at five per cent, among them foodstuffs not otherwise zero-rated, pharmaceutical products, books, newspapers and periodicals before the introduction of the three per cent rate, and (since Κ.Δ.Π. 268/2020, see CY-S-05-COVID) tourist accommodation, catering and passenger transport outside the temporary window. The Article and Schedule were read directly in the consolidated text; the commencement date of this Article''s current wording was not independently confirmed and 13 January 2014 is used on the same basis as CY-S-09 — see the pack README.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-05-COVID', 'Sale, 5 % — temporary rate for accommodation, catering and passenger transport', '{}'::jsonb, 'The temporary substitution of the 9 % rate by 5 % for tourist accommodation, restaurant/catering services and passenger transport', 'percent', 5, 'sale', 'domestic', date '2020-07-01', date '2021-01-10', 'Κ.Δ.Π. 268/2020, Το περί Φόρου Προστιθέμενης Αξίας (Τροποποίηση του Πέμπτου Παραρτήματος και Δωδέκατου Παραρτήματος) Διάταγμα του 2020, issued by the Council of Ministers under articles 18(2) and 18Α(2) of Ν. 95(Ι)/2000, Ε.Ε. Παρ. ΙΙΙ(Ι), Αρ. 5303, 23/6/2020 — hotel and tourist accommodation, restaurant and catering services, and urban, inter-urban and rural taxi and coach transport moved from the Twelfth Schedule (9 %) to the Fifth Schedule (5 %) from 1 July 2020, and paragraphs (1) to (3) of the Twelfth Schedule were deleted for the duration; the Order itself fixes its end at 10 January 2021, after which the 9 % of CY-S-09 applies again. Read directly in the primary text (Ε.Ε. Παρ. ΙΙΙ(Ι), Αρ. 5303).', 'S', null, 25, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'kdp-268-2020', null, null, null, null),
  ('CY', 'CY-S-09', 'Sale, reduced rate 9 %', '{}'::jsonb, null, 'percent', 9, 'sale', 'domestic', date '2014-01-13', null, 'Ν. 95(Ι)/2000 as consolidated, article 18Α, and the Twelfth Schedule (Δωδέκατο Παράρτημα) it refers to — goods and services taxed at nine per cent, among them most hotel and tourist accommodation, restaurant and catering services, and local passenger transport, subject to the temporary substitution recorded in CY-S-05-COVID below. The Article and Schedule were read directly in the consolidated text; the precise date this Article''s current wording commenced was not independently confirmed in the sources consulted for this pack, and 13 January 2014 — the date of the concurrent standard-rate change of article 17 — is used pending that confirmation; see the pack README.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-19', 'Sale, standard rate 19 %', '{}'::jsonb, null, 'percent', 19, 'sale', 'domestic', date '2014-01-13', null, 'The Value Added Tax Laws of 2000 to 2023 (Ν. 95(Ι)/2000, as consolidated), article 17 — the standard rate is nineteen per cent (19%) from 13 January 2014 (eighteen per cent from 14 January 2013 to 12 January 2014). Own translation of the Greek text: "Φ.Π.Α. επιβάλλεται με συντελεστή ... δεκαεννέα τοις εκατόν (19%) από 13 Ιανουαρίου 2014". Box 1 of the return, VAT Definitive Guides (Chelco VAT Ltd) §3.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-EXEMPT', 'Sale, exempt activity', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 26 — transactions and acquisitions listed in the Seventh Schedule (Έβδομο Παράρτημα) are exempt, without a right to deduct. This pack confirmed the Article and Schedule reference directly in the consolidated text but did not re-read the Seventh Schedule item by item; the usual European exemptions of health, education, insurance, financial services and residential letting are assumed to be among its contents by analogy with every other Member State''s transposition of Title IX, Chapter 2 of Council Directive 2006/112/EC, and should be checked against the Schedule itself before this pack is relied on for a specific exempt activity. The reason code is the general public-interest one of Article 132 of the Directive; a supply exempt under a different article should name that article instead.', 'E', 'VATEX-EU-132', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-EXPORT', 'Export of goods outside the European Union', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 25(6) — the export of goods to a destination outside the Member States is zero-rated where the Commissioner of Taxation is satisfied that the person exported the goods, transposing article 146 of Council Directive 2006/112/EC. Read directly in the consolidated text.', 'G', 'VATEX-EU-G', 70, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-ICG', 'Intra-Community supply of goods', '{}'::jsonb, null, 'percent', 0, 'sale', 'intracom_goods', date '2004-05-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 25(8)(α) — the Council of Ministers is empowered to zero-rate the supply of goods dispatched to a person liable for the acquisition in another Member State under the equivalent there of article 12Α, transposing article 138 of Council Directive 2006/112/EC. Read directly in the consolidated text; the implementing Order made under that power was not separately located, and the requirement to hold the customer''s VAT number and to state the supply is intra-Community rests on Regulation 12(1) of Κ.Δ.Π. 314/2001 (mandatory invoice particulars) read generally rather than a provision specific to this case.', 'K', 'VATEX-EU-IC', 80, 'vat', true, array['buyer_status', 'transport_evidence']::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null),
  ('CY', 'CY-S-ICS', 'Services supplied to a taxable person in another Member State', '{}'::jsonb, null, 'percent', 0, 'sale', 'intracom_services', date '2004-05-01', null, 'The general business-to-business place-of-supply rule of article 44 of Council Directive 2006/112/EC — a service supplied to a taxable person established in another Member State is taxed where the customer is established, and the customer accounts for the tax there under article 196. This pack was not able to confirm, in the sources consulted, the precise article of Ν. 95(Ι)/2000 that transposes article 44 for the place of supply of a business-to-business service (as distinct from article 11, confirmed as the domestic self-accounting mechanism for a service received from abroad); see the pack README.', 'K', 'VATEX-EU-IC', 90, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'vat-directive-2006-112', null, null, null, null),
  ('CY', 'CY-S-RCC', 'Construction services, domestic reverse charge', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic_reverse_charge', date '2005-01-01', null, 'Ν. 95(Ι)/2000 as consolidated, article 11Β, inserted by Ν. 88(Ι)/2005 — where a service, or a service with goods, is supplied in the course of the construction, conversion, demolition, repair or maintenance of a building or civil engineering work to a taxable person registered for VAT in Cyprus, that person accounts for the tax instead of the supplier. Read directly in the consolidated text; the commencement date of Ν. 88(Ι)/2005 was not independently re-verified in the Official Gazette and 1 January 2005 is used as the year of the amending law.', 'AE', 'VATEX-EU-AE', 100, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'vat-law-95-2000', null, null, null, null)
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
    ('CY-P-03', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-03', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-03', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-03', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-05', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-05', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-05', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-05', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-09', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-09', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-09', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-09', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-19', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-19', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-19', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-19', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-FSR-19', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-FSR-19', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-FSR-19', 'invoice', 'tax', -100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 30),
    ('CY-P-FSR-19', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-FSR-19', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-FSR-19', 'credit_note', 'tax', -100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 30),
    ('CY-P-ICG-19', 'invoice', 'base', 100, null, '7', array['7', '11A']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-ICG-19', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-ICG-19', 'invoice', 'tax', -100, '2200', '2', array['2']::text[], 100, 'CY-VAT4', 30),
    ('CY-P-ICG-19', 'credit_note', 'base', 100, null, '7', array['7', '11A']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-ICG-19', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-ICG-19', 'credit_note', 'tax', -100, '2200', '2', array['2']::text[], -100, 'CY-VAT4', 30),
    ('CY-P-ICS-19', 'invoice', 'base', 100, null, '7', array['7', '11B']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-ICS-19', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-ICS-19', 'invoice', 'tax', -100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 30),
    ('CY-P-ICS-19', 'credit_note', 'base', 100, null, '7', array['7', '11B']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-ICS-19', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-ICS-19', 'credit_note', 'tax', -100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 30),
    ('CY-P-RCC', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'CY-VAT4', 10),
    ('CY-P-RCC', 'invoice', 'tax', 100, '1140', '4', array['4']::text[], 100, 'CY-VAT4', 20),
    ('CY-P-RCC', 'invoice', 'tax', -100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 30),
    ('CY-P-RCC', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'CY-VAT4', 10),
    ('CY-P-RCC', 'credit_note', 'tax', 100, '1140', '4', array['4']::text[], -100, 'CY-VAT4', 20),
    ('CY-P-RCC', 'credit_note', 'tax', -100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 30),
    ('CY-S-00', 'invoice', 'base', 100, null, '6', array['6', '9']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-00', 'credit_note', 'base', 100, null, '6', array['6', '9']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-03', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-03', 'invoice', 'tax', 100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 20),
    ('CY-S-03', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-03', 'credit_note', 'tax', 100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 20),
    ('CY-S-05', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-05', 'invoice', 'tax', 100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 20),
    ('CY-S-05', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-05', 'credit_note', 'tax', 100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 20),
    ('CY-S-05-COVID', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-05-COVID', 'invoice', 'tax', 100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 20),
    ('CY-S-05-COVID', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-05-COVID', 'credit_note', 'tax', 100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 20),
    ('CY-S-09', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-09', 'invoice', 'tax', 100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 20),
    ('CY-S-09', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-09', 'credit_note', 'tax', 100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 20),
    ('CY-S-19', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-19', 'invoice', 'tax', 100, '2200', '1', array['1']::text[], 100, 'CY-VAT4', 20),
    ('CY-S-19', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-19', 'credit_note', 'tax', 100, '2200', '1', array['1']::text[], -100, 'CY-VAT4', 20),
    ('CY-S-EXEMPT', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-EXEMPT', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-EXPORT', 'invoice', 'base', 100, null, '6', array['6', '9']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-EXPORT', 'credit_note', 'base', 100, null, '6', array['6', '9']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-ICG', 'invoice', 'base', 100, null, '6', array['6', '8A']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-ICG', 'credit_note', 'base', 100, null, '6', array['6', '8A']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-ICS', 'invoice', 'base', 100, null, '6', array['6', '8B']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-ICS', 'credit_note', 'base', 100, null, '6', array['6', '8B']::text[], -100, 'CY-VAT4', 10),
    ('CY-S-RCC', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'CY-VAT4', 10),
    ('CY-S-RCC', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'CY-VAT4', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'CY' and t.code = v.tax_code
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
  ('CY', 'CY-VAT4', 'VAT return (Έντυπο Φ.Π.Α.4)', array['quarter']::declaration_period[], 'quarter'::declaration_period, date '2001-07-27', null, 'Οι περί Φόρου Προστιθέμενης Αξίας (Γενικοί) Κανονισμοί του 2001 (Κ.Δ.Π. 314/2001), regulation 17 — every registered person furnishes a return for each period of a quarter, or such other period of three months as the Commissioner of Taxation notifies to them, no later than the tenth day after the end of the month that follows the end of the period. Regulation 17 was read directly in the PDF of the Official Gazette notice (Ε.Ε. Παρ. ΙΙΙ(Ι), Αρ. 3518, 27/7/2001, p. 3381). This pack was not able to confirm a monthly or other cadence offered on request, as several other Member States'' forms are, so only the quarter the Regulation itself gives is declared.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, 10, 'Κ.Δ.Π. 314/2001, regulation 17 — the return and payment are due no later than the tenth day after the end of the month that follows the end of the period: a quarter ending 31 March falls due on the last day of April (30 April) plus ten days, 10 May. Read directly in the Official Gazette PDF (Ε.Ε. Παρ. ΙΙΙ(Ι), Αρ. 3518, 27/7/2001, p. 3381).', 'vat-regs-2001', null)
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
  ('CY', 'CY-VAT4', '1', 'tax', 'Output VAT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The total VAT due on domestic supplies of goods and services at every rate, and on a self-accounted supply that is not an intra-Community acquisition of goods (a reverse charge under article 11 or article 11Β of Ν. 95(Ι)/2000). Box 1 of Form 4, as described in the unofficial translation of the Tax Department''s completion notes published by Chelco VAT Ltd (VAT Definitive Guides, Issue 2) — the Department''s own guide could not be retrieved for this pack; see the README.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '2', 'tax', 'Output VAT on intra-Community acquisitions of goods', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The VAT self-accounted under article 12Α of Ν. 95(Ι)/2000 on the acquisition of goods from another Member State. Box 2 of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '3', 'total', 'Total output VAT due', '{}'::jsonb, 30, null, array['1', '2']::text[], '{}'::text[], null, null, false, false, null, 'Box 3 of Form 4 is the sum of boxes 1 and 2, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '4', 'tax', 'Input VAT', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The total VAT the person is entitled to deduct, on domestic purchases, imports, intra-Community acquisitions and services received from abroad, subject to holding a valid VAT invoice under regulation 12(1) of Κ.Δ.Π. 314/2001. Box 4 of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '5', 'total', 'VAT due for the period', '{}'::jsonb, 50, null, array['3']::text[], array['4']::text[], null, null, false, false, null, 'Box 5 of Form 4 is box 3 less box 4: an amount owed to the Tax Department where positive, a credit carried or claimed where negative. Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '6', 'base', 'Total value of sales, excluding VAT', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value, net of VAT, of every sale of the period at every rate, including a zero-rated, exempt or reverse-charged one; boxes 8A, 8B and 9 report parts of this total separately as well. Box 6 of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '7', 'base', 'Total value of purchases and expenses, excluding VAT', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value, net of VAT, of every purchase of the period at every rate, including an intra-Community acquisition or a service received from abroad; boxes 11A and 11B report parts of this total separately as well. Box 7 of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '8A', 'base', 'Value of goods dispatched to other Member States', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of an intra-Community supply of goods, article 25(8)(α) of Ν. 95(Ι)/2000, already counted in box 6. Box 8A of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '8B', 'base', 'Value of services supplied to taxable persons in other Member States', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of a business-to-business service taxed where the customer is established, article 44 of Council Directive 2006/112/EC, already counted in box 6. Box 8B of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '9', 'base', 'Value of supplies at the zero rate, other than 8A and 8B', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of a domestic zero-rated supply (article 25 of Ν. 95(Ι)/2000) or an export (article 25(6)), already counted in box 6. Box 9 of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '11A', 'base', 'Value of intra-Community acquisitions of goods', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of an acquisition taxed under article 12Α of Ν. 95(Ι)/2000, already counted in box 7. Box 11A of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes.', 'cy-vat4-guide-chelco'),
  ('CY', 'CY-VAT4', '11B', 'base', 'Value of services received from taxable persons in other Member States', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of a service self-accounted under article 11 of Ν. 95(Ι)/2000 where the supplier is established in another Member State, already counted in box 7. Box 11B of Form 4, Chelco VAT Ltd''s unofficial translation of the completion notes; this pack reads box 11B as reported within box 7 alone, the source consulted being ambiguous between box 6, box 7 and both — see the README.', 'cy-vat4-guide-chelco')
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
  ('CY-IFRS-SME-BS', 'CY', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'Companies Law, Cap. 113, s. 141A (as substituted) requires every company''s accounts to be prepared in accordance with International Financial Reporting Standards as adopted by the European Union, which prescribe no fixed table of captions — the Eighth Schedule that once did was repealed in 2003 by s. 20 of Ν. 167(Ι)/2003. The lines below are the minimum line items of section 4.2 of the IFRS for SMEs Accounting Standard (2015), used here as an illustrative layout precise enough to read this chart against, and grouped onto the codes of `accounts.csv`, which are themselves original and not a published format.', 'ifrs-for-smes-standard'),
  ('CY-IFRS-SME-IS', 'CY', 'default', 'Statement of comprehensive income (single statement)', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'IFRS for SMEs Accounting Standard (2015), section 5.3: an entity presents its total comprehensive income for a period in a single statement of comprehensive income where, as here, it has no item of other comprehensive income to show separately from profit or loss. The lines below are the minimum line items of section 5.5, grouped onto the codes of `accounts.csv`.', 'ifrs-for-smes-standard')
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
  ('CY-IFRS-SME-BS', 'NC-INT', 'NC', 'Intangible assets', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'NC-INV', 'NC', 'Investment property', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'NC-PPE', 'NC', 'Property, plant and equipment', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'NC-FIN', 'NC', 'Investments and other non-current financial assets', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'NC-DTA', 'NC', 'Deferred tax asset', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'NC', null, 'Non-current assets', '{}'::jsonb, 60, 1, true, array['NC-INT', 'NC-INV', 'NC-PPE', 'NC-FIN', 'NC-DTA']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'C-INV', 'C', 'Inventories', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'C-REC', 'C', 'Trade and other receivables', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'C-TAX', 'C', 'Current tax assets and other recoverable amounts', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'C-PRE', 'C', 'Prepayments and accrued income', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'C-CASH', 'C', 'Cash and cash equivalents', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'C', null, 'Current assets', '{}'::jsonb, 120, 1, true, array['C-INV', 'C-REC', 'C-TAX', 'C-PRE', 'C-CASH']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'A-TOT', null, 'Total assets', '{}'::jsonb, 130, 1, true, array['NC', 'C']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'E-SHARE', 'E', 'Share capital', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'E-PREM', 'E', 'Share premium', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'E-REVAL', 'E', 'Revaluation reserve', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'E-LEGAL', 'E', 'Legal reserve', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Companies Law, Cap. 113, s. 55 — the non-distributable reserve a company keeps against a reduction of capital.', 'companies-law-cap113'),
  ('CY-IFRS-SME-BS', 'E-OTH', 'E', 'Other reserves', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'E-RET', 'E', 'Retained earnings', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, '`defaults.closing_style` is `retained_earnings`: the result of a closed year is carried straight onto `3400`, and this line reads it there beside `3410`, exactly as `packs/gb/`''s own `K.V` does for the same closing style.', null),
  ('CY-IFRS-SME-BS', 'E', null, 'Total equity', '{}'::jsonb, 200, 1, true, array['E-SHARE', 'E-PREM', 'E-REVAL', 'E-LEGAL', 'E-OTH', 'E-RET']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LNC-BOR', 'LNC', 'Borrowings and lease liabilities', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LNC-DTL', 'LNC', 'Deferred tax liability', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LNC-PROV', 'LNC', 'Provisions', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LNC', null, 'Non-current liabilities', '{}'::jsonb, 240, 1, true, array['LNC-BOR', 'LNC-DTL', 'LNC-PROV']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LC-BOR', 'LC', 'Borrowings', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LC-PAY', 'LC', 'Trade and other payables', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LC-TAX', 'LC', 'Tax, social insurance and other current liabilities', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'LC', null, 'Current liabilities', '{}'::jsonb, 280, 1, true, array['LC-BOR', 'LC-PAY', 'LC-TAX']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'L-TOT', null, 'Total liabilities', '{}'::jsonb, 290, 1, true, array['LNC', 'LC']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-BS', 'EL-TOT', null, 'Total equity and liabilities', '{}'::jsonb, 300, 1, true, array['E', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'REV', null, 'Revenue', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'RET', null, 'Sales returns, allowances and discounts', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'NETREV', null, 'Net revenue', '{}'::jsonb, 30, 1, true, array['REV']::text[], array['RET']::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'COST', null, 'Cost of sales', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'GROSS', null, 'Gross profit', '{}'::jsonb, 50, 1, true, array['NETREV']::text[], array['COST']::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'OTHINC', null, 'Other operating income', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'DIST', null, 'Distribution costs', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'ADMIN', null, 'Administrative expenses', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'DEPR', null, 'Depreciation and amortisation', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'OPPROFIT', null, 'Operating profit', '{}'::jsonb, 100, 1, true, array['GROSS', 'OTHINC']::text[], array['DIST', 'ADMIN', 'DEPR']::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'FINCOST', null, 'Finance costs', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'PBT', null, 'Profit before tax', '{}'::jsonb, 120, 1, true, array['OPPROFIT']::text[], array['FINCOST']::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'TAX', null, 'Income tax expense', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CY-IFRS-SME-IS', 'PROFIT', null, 'Profit for the year', '{}'::jsonb, 140, 1, true, array['PBT']::text[], array['TAX']::text[], null, null, null)
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
    ('CY-IFRS-SME-BS', 'NC-INT', 10, 'code_range', '0010', '0030', null, 'any'),
    ('CY-IFRS-SME-BS', 'NC-INV', 10, 'account_code', '0100', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'NC-PPE', 10, 'code_range', '0110', '0180', null, 'any'),
    ('CY-IFRS-SME-BS', 'NC-FIN', 10, 'code_range', '0200', '0240', null, 'any'),
    ('CY-IFRS-SME-BS', 'NC-DTA', 10, 'account_code', '0250', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'C-INV', 10, 'code_range', '1000', '1030', null, 'any'),
    ('CY-IFRS-SME-BS', 'C-REC', 10, 'code_range', '1100', '1130', null, 'any'),
    ('CY-IFRS-SME-BS', 'C-REC', 20, 'account_code', '2400', null, null, 'debit'),
    ('CY-IFRS-SME-BS', 'C-TAX', 10, 'code_range', '1140', '1170', null, 'any'),
    ('CY-IFRS-SME-BS', 'C-PRE', 10, 'code_range', '1300', '1310', null, 'any'),
    ('CY-IFRS-SME-BS', 'C-CASH', 10, 'code_range', '1500', '1550', null, 'any'),
    ('CY-IFRS-SME-BS', 'E-SHARE', 10, 'account_code', '3300', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'E-PREM', 10, 'account_code', '3310', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'E-REVAL', 10, 'account_code', '3320', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'E-LEGAL', 10, 'account_code', '3330', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'E-OTH', 10, 'account_code', '3340', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'E-RET', 10, 'code_range', '3400', '3410', null, 'any'),
    ('CY-IFRS-SME-BS', 'LNC-BOR', 10, 'code_range', '3000', '3020', null, 'any'),
    ('CY-IFRS-SME-BS', 'LNC-DTL', 10, 'account_code', '3030', null, null, 'any'),
    ('CY-IFRS-SME-BS', 'LNC-PROV', 10, 'code_range', '3100', '3110', null, 'any'),
    ('CY-IFRS-SME-BS', 'LC-BOR', 10, 'code_range', '2000', '2030', null, 'any'),
    ('CY-IFRS-SME-BS', 'LC-PAY', 10, 'code_range', '2040', '2110', null, 'any'),
    ('CY-IFRS-SME-BS', 'LC-PAY', 20, 'account_code', '2400', null, null, 'credit'),
    ('CY-IFRS-SME-BS', 'LC-TAX', 10, 'code_range', '2200', '2300', null, 'any'),
    ('CY-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4100', null, 'any'),
    ('CY-IFRS-SME-IS', 'RET', 10, 'code_range', '4200', '4210', null, 'any'),
    ('CY-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5080', null, 'any'),
    ('CY-IFRS-SME-IS', 'OTHINC', 10, 'code_range', '4300', '4350', null, 'any'),
    ('CY-IFRS-SME-IS', 'DIST', 10, 'code_range', '6000', '6060', null, 'any'),
    ('CY-IFRS-SME-IS', 'ADMIN', 10, 'code_range', '7000', '7320', null, 'any'),
    ('CY-IFRS-SME-IS', 'DEPR', 10, 'code_range', '7400', '7460', null, 'any'),
    ('CY-IFRS-SME-IS', 'FINCOST', 10, 'code_range', '8000', '8030', null, 'any'),
    ('CY-IFRS-SME-IS', 'TAX', 10, 'code_range', '8100', '8130', null, 'any')
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
  ('CY', 'Cyprus', '{}'::jsonb, array['en']::text[], 'EUR', '1100', '2100', '2400', '7310', '3400', '4000', '5000', '1500', '1530', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4330', '7300', '4320', '7290', null, null, '2210', '1150', null, 'quarter'::declaration_period)
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
  legal_payment_days            = 30,
  late_payment_reference        = 'Ν. 123(Ι)/2012, transposing Directive 2011/7/EU — where the parties have agreed no payment date, the statutory period is 30 calendar days after the later of the receipt of the goods or services and the receipt of the invoice; statutory interest runs at the European Central Bank''s main refinancing rate plus 8 percentage points.',
  numbering_legal_reference     = 'Κ.Δ.Π. 314/2001, regulation 12(1) — a VAT invoice carries an identifying number among its mandatory particulars. The Regulation was read directly for its list of mandatory particulars; it was not found to require the absence of a gap in the sequence, so numbering is declared sequential rather than gapless.',
  numbering_source_key          = 'vat-regs-2001',
  payment_terms_legal_reference = 'Ν. 123(Ι)/2012, transposing Directive 2011/7/EU, the default payment term where the contract sets none.',
  payment_terms_source_key      = 'late-payments-law-2012',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ν. 95(Ι)/2000 as consolidated, article 9(2)–(3) — the basic time of a supply of goods is when they are transported or, if not transported, put at the recipient''s disposal, and of a service when it is performed; article 9(4) brings that time forward to the date of an earlier invoice or an advance payment, to the extent invoiced or paid; article 9(5) brings it forward again to the date of an invoice issued within fourteen days after the basic time, unless the taxable person has given the Commissioner written notice not to apply that rule (article 9(6) lets the Commissioner extend the fourteen days on request). Read directly in the consolidated text. `invoice_if_issued` is used because an invoice issued within the ordinary fourteen-day window — which covers the practical majority of supplies — displaces the basic time to the invoice date; a supply invoiced later, or after an opt-out notice, falls back to the basic time of article 9(2)–(3), which this single word does not carry, and neither does article 9(4)''s advance-payment rule, which this pack does not model as a prepayment document.',
  tax_point_source_key          = 'vat-law-95-2000',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No enactment obliges a Cyprus business to issue a structured electronic invoice to another business today. Public bodies must be able to receive and process an EN 16931 invoice under Directive 2014/55/EU, transposed for central government from April 2019 and for sub-central contracting authorities from April 2020; that is an obligation on the public buyer''s reception, not on a supplier''s issuance, and the European Commission''s own country page records that a wider B2B or B2C obligation is under discussion with no date fixed. No profile is declared for the same reason `packs/ie/` declares none where nothing is mandated: this pack was not able to confirm which profile, if any, Cyprus Peppol participants in fact exchange.',
  einvoice_source_key           = 'ec-einvoicing-cy',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'CY';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('CY', 'reverse_charge', 'reverse_charge', 'Reverse charge — VAT to be accounted for by the recipient.', '{}'::jsonb, 10, date '1970-01-01', null, 'Article 226(11a) of Council Directive 2006/112/EC requires the mention ''Reverse charge'' where the customer is liable for the tax; Ν. 95(Ι)/2000, articles 11 and 11Β are the domestic mechanisms that make the customer liable. This pack was not able to confirm a Cyprus-specific wording requirement distinct from the Directive''s own in the sources consulted.'),
  ('CY', 'intracom_goods', 'intra_eu_goods', 'Intra-Community supply of goods — zero-rated under article 25(8) of the Value Added Tax Law (article 138 of Council Directive 2006/112/EC).', '{}'::jsonb, 20, date '1970-01-01', null, 'Article 226(11) of Council Directive 2006/112/EC requires a reference to article 138; Κ.Δ.Π. 314/2001, regulation 12(1) requires the customer''s identifying particulars on every VAT invoice, read generally rather than as a provision specific to this mention.'),
  ('CY', 'intracom_services', 'intra_eu_services', 'Reverse charge — the customer is liable to account for the VAT (articles 44 and 196 of Council Directive 2006/112/EC).', '{}'::jsonb, 30, date '1970-01-01', null, 'Article 226(11a) of Council Directive 2006/112/EC.'),
  ('CY', 'export', 'export', 'Export of goods outside the European Union — zero-rated under article 25(6) of the Value Added Tax Law.', '{}'::jsonb, 40, date '1970-01-01', null, 'Κ.Δ.Π. 314/2001, regulation 12(1) — the invoice states the rate of tax, which on an export is the zero rate of article 25.'),
  ('CY', 'exempt', 'exempt', 'Exempt from VAT under article 26 and the Seventh Schedule of the Value Added Tax Law.', '{}'::jsonb, 50, date '1970-01-01', null, 'Κ.Δ.Π. 314/2001, regulation 12(1) — the invoice states the rate of tax; an exempt activity is charged at none.'),
  ('CY', 'late_payment', 'late_payment', 'Statutory interest and compensation for recovery costs apply to a payment received after the due date, under the Late Payments in Commercial Transactions Law of 2012.', '{}'::jsonb, 60, date '1970-01-01', null, 'Ν. 123(Ι)/2012, the interest and compensation it makes an implied term of every commercial transaction.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
