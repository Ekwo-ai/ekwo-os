-- Ekwo OS — Israel: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/il at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build il`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   חוק מס ערך מוסף, התשל"ו-1975 (Value Added Tax Law, 5736-1975), consolidated text (Nevo Legal Database — a private publisher. The Knesset's own official National Legislation Database (מאגר החקיקה הלאומי, main.knesset.gov.il) lists the law and every amendment to it but did not serve a fetchable consolidated text to this research pass; Nevo is the text every Israeli professional source this pack read in turn cites, and is used here for that reason and named as what it is.)
--     https://www.nevo.co.il/law_html/Law01/271_001.htm
--   תקנות מס ערך מוסף, התשל"ו-1976 (Value Added Tax Regulations, 5736-1976), consolidated text (Nevo Legal Database — a private publisher; see the note on the "vat-law" entry above, which applies here too.)
--     https://www.nevo.co.il/law_html/law01/271_005.htm
--   חוק אזור סחר חפשי באילת (פטורים והנחות ממסים), התשמ"ה-1985 (Free Trade Area (Eilat) Law (Exemptions and Tax Reductions), 5745-1985), consolidated text (Nevo Legal Database — a private publisher; see the note on the "vat-law" entry above.)
--     https://www.nevo.co.il/law_html/law01/009_001.htm
--   צו מס ערך מוסף (שיעור המס על עסקה ועל יבוא טובין), התשס"ה-2005, כפי שתוקן (Value Added Tax Order (Rate of Tax on a Transaction and on Import of Goods), 5765-2005, as amended) — the order made under section 2 of the Law that has carried every rate since 2005, including the reduction to 17% from 1 October 2015 (Amendment 5775-2015, Reshumot 10 September 2015) and the increase to 18% from 1 January 2025 (Amendment 5784-2024, Reshumot 28 February 2024) (Nevo Legal Database — a private publisher; see the note on the "vat-law" entry above. The two amending orders were each published in Reshumot (the Official Gazette), which this research pass could not open at a stable, directly-fetchable URL for either one specifically; the Tax Authority's own announcements of both changes are the "vat-rate-change-2025" and "vat-filing-guidance" entries below.)
--     https://www.nevo.co.il/law_html/law01/999_481.htm
--   העלאת שיעור המע"מ בשנת 2025 (Raising the VAT rate in 2025) — government decision page, and הוראת פרשנות מס' 1/2024 (Interpretive Directive 1/2024) on the transactions each rate applies to (Prime Minister's Office / Israel Tax Authority (gov.il))
--     https://www.gov.il/he/pages/dec1270-2024
--   קביעת מועדי הדיווח והתשלום — דוחות תקופתיים מע"מ, מקדמות מס הכנסה וניכויים, שנת המס 2025 (Setting the reporting and payment dates — periodic VAT reports, income tax advances and withholdings, tax year 2025) (Israel Tax Authority (gov.il))
--     https://www.gov.il/he/pages/pa271024-1
--   דיווח ותשלום של דוחות מע"מ (Reporting and paying VAT returns) (Israel Tax Authority (gov.il))
--     https://www.gov.il/he/service/reporting-or-payment-of-vat-reports
--   בקשה למספר הקצאה לחשבונית מס (Requesting an allocation number for a tax invoice) (Israel Tax Authority (gov.il))
--     https://www.gov.il/he/service/request-assignment-number-for-tax-invoice
--   החל מה-1 ביוני 2026: חובת מספר הקצאה בניכוי מס תשומות תחול מ-5,000 ₪ (From 1 June 2026: the allocation-number requirement for an input-tax deduction applies from NIS 5,000) — the declining threshold of the "Israel Invoices" model, enacted by the Economic Efficiency Law (Legislative Amendments to Achieve the Budget Targets for the 2023 and 2024 Budget Years), 5783-2023 (Israel Tax Authority (gov.il))
--     https://www.gov.il/he/pages/pa240525-1
--   תקנות ניירות ערך (דוחות כספיים שנתיים), התש"ע-2010 (Securities Regulations (Annual Financial Statements), 5770-2010) (Nevo Legal Database — a private publisher; see the note on the "vat-law" entry above. The Israel Securities Authority (isa.gov.il) is the regulator these regulations belong to.)
--     https://www.nevo.co.il/law_html/law01/500_271.htm
--   תקן חשבונאות מספר 29 — אימוץ תקני דיווח כספי בין-לאומיים (IFRS) (Accounting Standard No. 29 — Adoption of International Financial Reporting Standards), the Israel Accounting Standards Board decision requiring a reporting corporation to prepare its financial statements under IFRS for periods beginning 1 January 2008 (המוסד הישראלי לתקינה בחשבונאות — the Israel Accounting Standards Board)
--     https://www.iasb.org.il/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('IL', 'Israel', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, '7c073b1591402a09c21c2fe609160317cd1e3432a97be3233b64223c5924b159', '[{"key":"vat-law","title":"חוק מס ערך מוסף, התשל\"ו-1975 (Value Added Tax Law, 5736-1975), consolidated text","publisher":"Nevo Legal Database — a private publisher. The Knesset''s own official National Legislation Database (מאגר החקיקה הלאומי, main.knesset.gov.il) lists the law and every amendment to it but did not serve a fetchable consolidated text to this research pass; Nevo is the text every Israeli professional source this pack read in turn cites, and is used here for that reason and named as what it is.","url":"https://www.nevo.co.il/law_html/Law01/271_001.htm","consulted_on":"2026-09-25","kind":"law"},{"key":"vat-regulations","title":"תקנות מס ערך מוסף, התשל\"ו-1976 (Value Added Tax Regulations, 5736-1976), consolidated text","publisher":"Nevo Legal Database — a private publisher; see the note on the \"vat-law\" entry above, which applies here too.","url":"https://www.nevo.co.il/law_html/law01/271_005.htm","consulted_on":"2026-09-25","kind":"regulation"},{"key":"eilat-law","title":"חוק אזור סחר חפשי באילת (פטורים והנחות ממסים), התשמ\"ה-1985 (Free Trade Area (Eilat) Law (Exemptions and Tax Reductions), 5745-1985), consolidated text","publisher":"Nevo Legal Database — a private publisher; see the note on the \"vat-law\" entry above.","url":"https://www.nevo.co.il/law_html/law01/009_001.htm","consulted_on":"2026-09-25","kind":"law"},{"key":"vat-rate-order","title":"צו מס ערך מוסף (שיעור המס על עסקה ועל יבוא טובין), התשס\"ה-2005, כפי שתוקן (Value Added Tax Order (Rate of Tax on a Transaction and on Import of Goods), 5765-2005, as amended) — the order made under section 2 of the Law that has carried every rate since 2005, including the reduction to 17% from 1 October 2015 (Amendment 5775-2015, Reshumot 10 September 2015) and the increase to 18% from 1 January 2025 (Amendment 5784-2024, Reshumot 28 February 2024)","publisher":"Nevo Legal Database — a private publisher; see the note on the \"vat-law\" entry above. The two amending orders were each published in Reshumot (the Official Gazette), which this research pass could not open at a stable, directly-fetchable URL for either one specifically; the Tax Authority''s own announcements of both changes are the \"vat-rate-change-2025\" and \"vat-filing-guidance\" entries below.","url":"https://www.nevo.co.il/law_html/law01/999_481.htm","consulted_on":"2026-09-25","kind":"regulation"},{"key":"vat-rate-change-2025","title":"העלאת שיעור המע\"מ בשנת 2025 (Raising the VAT rate in 2025) — government decision page, and הוראת פרשנות מס'' 1/2024 (Interpretive Directive 1/2024) on the transactions each rate applies to","publisher":"Prime Minister''s Office / Israel Tax Authority (gov.il)","url":"https://www.gov.il/he/pages/dec1270-2024","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vat-filing-guidance","title":"קביעת מועדי הדיווח והתשלום — דוחות תקופתיים מע\"מ, מקדמות מס הכנסה וניכויים, שנת המס 2025 (Setting the reporting and payment dates — periodic VAT reports, income tax advances and withholdings, tax year 2025)","publisher":"Israel Tax Authority (gov.il)","url":"https://www.gov.il/he/pages/pa271024-1","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vat-filing-portal","title":"דיווח ותשלום של דוחות מע\"מ (Reporting and paying VAT returns)","publisher":"Israel Tax Authority (gov.il)","url":"https://www.gov.il/he/service/reporting-or-payment-of-vat-reports","consulted_on":"2026-09-25","kind":"portal"},{"key":"invoice-allocation-number","title":"בקשה למספר הקצאה לחשבונית מס (Requesting an allocation number for a tax invoice)","publisher":"Israel Tax Authority (gov.il)","url":"https://www.gov.il/he/service/request-assignment-number-for-tax-invoice","consulted_on":"2026-09-25","kind":"portal"},{"key":"invoice-allocation-threshold","title":"החל מה-1 ביוני 2026: חובת מספר הקצאה בניכוי מס תשומות תחול מ-5,000 ₪ (From 1 June 2026: the allocation-number requirement for an input-tax deduction applies from NIS 5,000) — the declining threshold of the \"Israel Invoices\" model, enacted by the Economic Efficiency Law (Legislative Amendments to Achieve the Budget Targets for the 2023 and 2024 Budget Years), 5783-2023","publisher":"Israel Tax Authority (gov.il)","url":"https://www.gov.il/he/pages/pa240525-1","consulted_on":"2026-09-25","kind":"guidance"},{"key":"securities-regs-annual-reports","title":"תקנות ניירות ערך (דוחות כספיים שנתיים), התש\"ע-2010 (Securities Regulations (Annual Financial Statements), 5770-2010)","publisher":"Nevo Legal Database — a private publisher; see the note on the \"vat-law\" entry above. The Israel Securities Authority (isa.gov.il) is the regulator these regulations belong to.","url":"https://www.nevo.co.il/law_html/law01/500_271.htm","consulted_on":"2026-09-25","kind":"regulation"},{"key":"accounting-standard-29","title":"תקן חשבונאות מספר 29 — אימוץ תקני דיווח כספי בין-לאומיים (IFRS) (Accounting Standard No. 29 — Adoption of International Financial Reporting Standards), the Israel Accounting Standards Board decision requiring a reporting corporation to prepare its financial statements under IFRS for periods beginning 1 January 2008","publisher":"המוסד הישראלי לתקינה בחשבונאות — the Israel Accounting Standards Board","url":"https://www.iasb.org.il/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('IL', 'default', 'לוח חשבונות ייחוס לישראל', '{"en":"Israel reference chart of accounts"}'::jsonb, true, 'companies', array['IL-IAS1-IS', 'IL-IAS1-SFP']::text[], null, 'There is no statutory chart of accounts in Israel. The Companies Law, 5759-1999 requires a company to keep books and prepare financial statements, and Accounting Standard 29 of the Israel Accounting Standards Board requires a ''reporting corporation'' — a public company, and a private company that has issued bonds to the public — to prepare them under IFRS from periods beginning 1 January 2008; a private company outside that definition is bound by no statute to a specific chart or a specific framework, and in practice keeps books under Israeli GAAP or under IFRS by choice. This pack''s research found no official, numbered reference chart of accounts to transcribe, the same finding packs/ae/ and packs/sg/ and packs/hk/ each record for their own country. The chart below is therefore original: four digits, blocked by class, built to reach one line of the IAS 1 statement of financial position and statement of profit or loss this pack carries (see statements.json), with the accounts an Israeli VAT-registered business actually keeps — VAT input and output tax, the net amount payable to or receivable from the Tax Authority, and the split default roles a periodic return needs. A reviewer should check this chart against a real set of Israeli books before trusting it as more than a working scaffold.', 'accounting-standard-29')
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
  ('IL', 'default', '1000', 'קופה', '{"en":"Petty cash"}'::jsonb, 'asset_cash', false, null, 10),
  ('IL', 'default', '1010', 'בנק — חשבון שקלי', '{"en":"Bank — NIS current account"}'::jsonb, 'asset_cash', false, null, 20),
  ('IL', 'default', '1015', 'בנק — חשבון מט״ח', '{"en":"Bank — foreign currency account"}'::jsonb, 'asset_cash', false, null, 30),
  ('IL', 'default', '1020', 'פיקדונות לזמן קצר', '{"en":"Short-term deposits"}'::jsonb, 'asset_cash', false, null, 40),
  ('IL', 'default', '1100', 'לקוחות', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 50),
  ('IL', 'default', '1105', 'לקוחות — צ''קים לגביה', '{"en":"Trade receivables — checks for collection"}'::jsonb, 'asset_current', false, null, 55),
  ('IL', 'default', '1110', 'לקוחות — הפרשה לחובות מסופקים', '{"en":"Trade receivables — allowance for doubtful debts"}'::jsonb, 'asset_current', false, null, 60),
  ('IL', 'default', '1120', 'חייבים אחרים', '{"en":"Other receivables"}'::jsonb, 'asset_current', true, null, 70),
  ('IL', 'default', '1130', 'הוצאות מראש', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 80),
  ('IL', 'default', '1140', 'מקדמות לספקים', '{"en":"Advances to suppliers"}'::jsonb, 'asset_current', false, null, 90),
  ('IL', 'default', '1145', 'ניכוי מס במקור לקבל', '{"en":"Withholding tax receivable"}'::jsonb, 'asset_current', false, null, 95),
  ('IL', 'default', '1150', 'מע״מ תשומות', '{"en":"VAT input tax"}'::jsonb, 'asset_current', false, null, 100),
  ('IL', 'default', '1155', 'מע״מ לקבל מרשות המסים — נטו לאחר הגשת דוח', '{"en":"VAT receivable from the Tax Authority — net, after a filed return"}'::jsonb, 'asset_current', true, null, 110),
  ('IL', 'default', '1160', 'מקדמות מס הכנסה', '{"en":"Income tax advances"}'::jsonb, 'asset_current', false, null, 120),
  ('IL', 'default', '1165', 'מקדמות לעובדים', '{"en":"Employee advances"}'::jsonb, 'asset_current', false, null, 125),
  ('IL', 'default', '1170', 'פיקדונות ביטחון ששולמו', '{"en":"Security deposits paid"}'::jsonb, 'asset_current', false, null, 128),
  ('IL', 'default', '1200', 'מלאי — סחורה למכירה', '{"en":"Inventories — goods for resale"}'::jsonb, 'asset_current', false, null, 130),
  ('IL', 'default', '1210', 'מלאי — חומרי גלם', '{"en":"Inventories — raw materials"}'::jsonb, 'asset_current', false, null, 140),
  ('IL', 'default', '1220', 'מלאי — עבודה בתהליך', '{"en":"Inventories — work in progress"}'::jsonb, 'asset_current', false, null, 150),
  ('IL', 'default', '1230', 'מלאי — תוצרת גמורה', '{"en":"Inventories — finished goods"}'::jsonb, 'asset_current', false, null, 160),
  ('IL', 'default', '1240', 'מלאי בדרך', '{"en":"Inventories — goods in transit"}'::jsonb, 'asset_current', false, null, 165),
  ('IL', 'default', '1300', 'השקעות לזמן קצר', '{"en":"Short-term investments"}'::jsonb, 'asset_current', false, null, 170),
  ('IL', 'default', '1310', 'ניירות ערך סחירים', '{"en":"Marketable securities"}'::jsonb, 'asset_current', false, null, 175),
  ('IL', 'default', '1600', 'קרקעות ומבנים — עלות', '{"en":"Land and buildings — cost"}'::jsonb, 'asset_fixed', false, null, 180),
  ('IL', 'default', '1601', 'קרקעות ומבנים — פחת נצבר', '{"en":"Land and buildings — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 190),
  ('IL', 'default', '1610', 'השבחות במושכר — עלות', '{"en":"Leasehold improvements — cost"}'::jsonb, 'asset_fixed', false, null, 200),
  ('IL', 'default', '1611', 'השבחות במושכר — פחת נצבר', '{"en":"Leasehold improvements — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 210),
  ('IL', 'default', '1620', 'מכונות וציוד — עלות', '{"en":"Machinery and equipment — cost"}'::jsonb, 'asset_fixed', false, null, 220),
  ('IL', 'default', '1621', 'מכונות וציוד — פחת נצבר', '{"en":"Machinery and equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 230),
  ('IL', 'default', '1630', 'ריהוט וציוד משרדי — עלות', '{"en":"Office furniture and equipment — cost"}'::jsonb, 'asset_fixed', false, null, 240),
  ('IL', 'default', '1631', 'ריהוט וציוד משרדי — פחת נצבר', '{"en":"Office furniture and equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 250),
  ('IL', 'default', '1640', 'כלי רכב — עלות', '{"en":"Motor vehicles — cost"}'::jsonb, 'asset_fixed', false, null, 260),
  ('IL', 'default', '1641', 'כלי רכב — פחת נצבר', '{"en":"Motor vehicles — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 270),
  ('IL', 'default', '1650', 'מחשבים וציוד היקפי — עלות', '{"en":"Computers and peripheral equipment — cost"}'::jsonb, 'asset_fixed', false, null, 275),
  ('IL', 'default', '1651', 'מחשבים וציוד היקפי — פחת נצבר', '{"en":"Computers and peripheral equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 278),
  ('IL', 'default', '1660', 'נדל״ן להשקעה — עלות', '{"en":"Investment property — cost"}'::jsonb, 'asset_fixed', false, null, 280),
  ('IL', 'default', '1661', 'נדל״ן להשקעה — פחת נצבר', '{"en":"Investment property — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 282),
  ('IL', 'default', '1700', 'השקעות בחברות מוחזקות', '{"en":"Investments in related companies"}'::jsonb, 'asset_non_current', false, null, 290),
  ('IL', 'default', '1710', 'פיקדונות והלוואות לזמן ארוך', '{"en":"Long-term deposits and loans receivable"}'::jsonb, 'asset_non_current', false, null, 300),
  ('IL', 'default', '1720', 'פיקדון ביטחון לחכירה', '{"en":"Lease security deposit"}'::jsonb, 'asset_non_current', false, null, 305),
  ('IL', 'default', '1750', 'נכסים בלתי מוחשיים — עלות', '{"en":"Intangible assets — cost"}'::jsonb, 'asset_non_current', false, null, 310),
  ('IL', 'default', '1751', 'נכסים בלתי מוחשיים — הפחתה נצברת', '{"en":"Intangible assets — accumulated amortisation"}'::jsonb, 'asset_non_current', false, null, 320),
  ('IL', 'default', '1760', 'מוניטין', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 325),
  ('IL', 'default', '2000', 'ספקים', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 330),
  ('IL', 'default', '2005', 'ספקים — צ''קים לתשלום', '{"en":"Trade payables — checks issued"}'::jsonb, 'liability_current', false, null, 335),
  ('IL', 'default', '2010', 'זכאים שונים והוצאות לשלם', '{"en":"Other payables and accrued expenses"}'::jsonb, 'liability_current', false, null, 340),
  ('IL', 'default', '2020', 'הכנסות מראש', '{"en":"Deferred revenue"}'::jsonb, 'liability_current', false, null, 350),
  ('IL', 'default', '2030', 'מקדמות מלקוחות', '{"en":"Advances from customers"}'::jsonb, 'liability_current', false, null, 360),
  ('IL', 'default', '2040', 'מס הכנסה לשלם — חברה', '{"en":"Corporate income tax payable"}'::jsonb, 'liability_current', false, null, 365),
  ('IL', 'default', '2045', 'דיבידנד לתשלום', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 368),
  ('IL', 'default', '2050', 'שכר עבודה לשלם', '{"en":"Wages payable"}'::jsonb, 'liability_current', false, null, 370),
  ('IL', 'default', '2060', 'מוסדות — ניכויים לביטוח לאומי ולמס הכנסה', '{"en":"National Insurance and income tax withholdings payable"}'::jsonb, 'liability_current', false, null, 380),
  ('IL', 'default', '2065', 'ביטוח לאומי מעביד לשלם', '{"en":"Employer''s National Insurance payable"}'::jsonb, 'liability_current', false, null, 385),
  ('IL', 'default', '2070', 'קרן פנסיה וקרן השתלמות לשלם', '{"en":"Pension and further-education fund payable"}'::jsonb, 'liability_current', false, null, 388),
  ('IL', 'default', '2100', 'מע״מ עסקאות', '{"en":"VAT output tax"}'::jsonb, 'liability_current', false, null, 390),
  ('IL', 'default', '2110', 'מע״מ לשלם לרשות המסים — נטו לאחר הגשת דוח', '{"en":"VAT payable to the Tax Authority — net, after a filed return"}'::jsonb, 'liability_current', true, null, 400),
  ('IL', 'default', '2150', 'הפרשה לפיצויי פרישה — חלק שוטף', '{"en":"Severance pay provision — current portion"}'::jsonb, 'liability_current', false, null, 410),
  ('IL', 'default', '2160', 'הפרשה לחופשה ולדמי הבראה', '{"en":"Provision for vacation and recreation pay"}'::jsonb, 'liability_current', false, null, 415),
  ('IL', 'default', '2200', 'אשראי בנקאי לזמן קצר ומשיכת יתר', '{"en":"Short-term bank credit and overdraft"}'::jsonb, 'liability_current', false, null, 420),
  ('IL', 'default', '2210', 'חלות שוטפות של הלוואות לזמן ארוך', '{"en":"Current portion of long-term loans"}'::jsonb, 'liability_current', false, null, 430),
  ('IL', 'default', '2220', 'התחייבות בגין חכירה — חלק שוטף', '{"en":"Lease liability — current portion"}'::jsonb, 'liability_current', false, null, 435),
  ('IL', 'default', '2300', 'הלוואות לזמן ארוך', '{"en":"Long-term loans"}'::jsonb, 'liability_non_current', false, null, 440),
  ('IL', 'default', '2310', 'התחייבות בגין חכירה — לא שוטף', '{"en":"Lease liability — non-current portion"}'::jsonb, 'liability_non_current', false, null, 445),
  ('IL', 'default', '2350', 'הפרשה לפיצויי פרישה — חלק לא שוטף', '{"en":"Severance pay provision — non-current portion"}'::jsonb, 'liability_non_current', false, null, 450),
  ('IL', 'default', '2360', 'מסים נדחים — התחייבות', '{"en":"Deferred tax liability"}'::jsonb, 'liability_non_current', false, null, 455),
  ('IL', 'default', '2990', 'חשבון מעבר', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 460),
  ('IL', 'default', '3000', 'הון מניות', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 470),
  ('IL', 'default', '3010', 'פרמיה על מניות', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 480),
  ('IL', 'default', '3020', 'קרנות הון', '{"en":"Capital reserves"}'::jsonb, 'equity', false, null, 490),
  ('IL', 'default', '3030', 'קרן הון מתרגום דוחות כספיים', '{"en":"Translation reserve"}'::jsonb, 'equity', false, null, 495),
  ('IL', 'default', '3200', 'עודפים', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 500),
  ('IL', 'default', '3210', 'דיבידנד שהוכרז', '{"en":"Dividends declared"}'::jsonb, 'equity_retained', false, null, 510),
  ('IL', 'default', '4000', 'הכנסות ממכירת טובין בישראל', '{"en":"Sales of goods in Israel"}'::jsonb, 'income', false, null, 520),
  ('IL', 'default', '4010', 'הכנסות ממתן שירותים בישראל', '{"en":"Sales of services in Israel"}'::jsonb, 'income', false, null, 530),
  ('IL', 'default', '4020', 'הכנסות ממכירות ליצוא', '{"en":"Export sales"}'::jsonb, 'income', false, null, 540),
  ('IL', 'default', '4030', 'הכנסות משכירות', '{"en":"Rental income"}'::jsonb, 'income', false, null, 550),
  ('IL', 'default', '4040', 'הכנסות מדמי ניהול', '{"en":"Management fee income"}'::jsonb, 'income', false, null, 555),
  ('IL', 'default', '4700', 'רווחי שער חליפין — ממומשים', '{"en":"Realised foreign exchange gain"}'::jsonb, 'income_other', false, null, 560),
  ('IL', 'default', '4710', 'רווחי שער חליפין — טרם מומשו', '{"en":"Unrealised foreign exchange gain"}'::jsonb, 'income_other', false, null, 570),
  ('IL', 'default', '4720', 'רווח ממימוש רכוש קבוע', '{"en":"Gain on disposal of property, plant and equipment"}'::jsonb, 'income_other', false, null, 575),
  ('IL', 'default', '4730', 'הכנסות ריבית', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 578),
  ('IL', 'default', '4790', 'הכנסות אחרות', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 580),
  ('IL', 'default', '5000', 'עלות המכר — סחורה', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 590),
  ('IL', 'default', '5010', 'הובלה ושחרור מכס', '{"en":"Freight and customs clearance"}'::jsonb, 'expense_direct_cost', false, null, 600),
  ('IL', 'default', '5020', 'עבודות קבלני משנה', '{"en":"Subcontractor work"}'::jsonb, 'expense_direct_cost', false, null, 610),
  ('IL', 'default', '5030', 'החזרות וזיכויים מספקים', '{"en":"Purchase returns and allowances"}'::jsonb, 'expense_direct_cost', false, null, 620),
  ('IL', 'default', '5040', 'עלות שכר עובדי ייצור', '{"en":"Direct production labour cost"}'::jsonb, 'expense_direct_cost', false, null, 625),
  ('IL', 'default', '6100', 'שכר עבודה ונלוות', '{"en":"Salaries and related costs"}'::jsonb, 'expense', false, null, 630),
  ('IL', 'default', '6110', 'הפרשה לפיצויי פרישה — הוצאות השנה', '{"en":"Severance pay charge for the year"}'::jsonb, 'expense', false, null, 640),
  ('IL', 'default', '6120', 'ביטוח בריאות ורפואי לעובדים', '{"en":"Employee health insurance"}'::jsonb, 'expense', false, null, 650),
  ('IL', 'default', '6130', 'הכשרה וגיוס עובדים', '{"en":"Recruitment and training"}'::jsonb, 'expense', false, null, 660),
  ('IL', 'default', '6140', 'הפרשות לביטוח לאומי מעביד', '{"en":"Employer''s National Insurance contributions"}'::jsonb, 'expense', false, null, 665),
  ('IL', 'default', '6150', 'הפרשות לקרן פנסיה ולקרן השתלמות', '{"en":"Pension and further-education fund contributions"}'::jsonb, 'expense', false, null, 668),
  ('IL', 'default', '6160', 'דמי הבראה וחופשה', '{"en":"Recreation and vacation pay"}'::jsonb, 'expense', false, null, 669),
  ('IL', 'default', '6200', 'שכירות והחזקת משרד', '{"en":"Rent and office occupancy"}'::jsonb, 'expense', false, null, 670),
  ('IL', 'default', '6210', 'חשמל ומים', '{"en":"Electricity and water"}'::jsonb, 'expense', false, null, 680),
  ('IL', 'default', '6220', 'ציוד וחומרים משרדיים', '{"en":"Office supplies and materials"}'::jsonb, 'expense', false, null, 690),
  ('IL', 'default', '6230', 'תקשוב ותוכנה', '{"en":"IT and software"}'::jsonb, 'expense', false, null, 700),
  ('IL', 'default', '6240', 'תיקונים ואחזקה', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 710),
  ('IL', 'default', '6250', 'אבטחה ושמירה', '{"en":"Security services"}'::jsonb, 'expense', false, null, 715),
  ('IL', 'default', '6300', 'נסיעות', '{"en":"Travel"}'::jsonb, 'expense', false, null, 720),
  ('IL', 'default', '6310', 'אירוח — מע״מ אינו ניתן לניכוי', '{"en":"Entertainment — VAT not recoverable"}'::jsonb, 'expense', false, null, 730),
  ('IL', 'default', '6320', 'הוצאות החזקת רכב', '{"en":"Motor vehicle running costs"}'::jsonb, 'expense', false, null, 740),
  ('IL', 'default', '6400', 'שכר טרחה מקצועי', '{"en":"Professional fees"}'::jsonb, 'expense', false, null, 750),
  ('IL', 'default', '6410', 'עמלות והוצאות בנק', '{"en":"Bank fees and charges"}'::jsonb, 'expense', false, null, 760),
  ('IL', 'default', '6420', 'ביטוח', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 770),
  ('IL', 'default', '6430', 'שיווק ופרסום', '{"en":"Marketing and advertising"}'::jsonb, 'expense', false, null, 780),
  ('IL', 'default', '6440', 'אגרות ותשלומים לרשויות', '{"en":"Licence fees and government charges"}'::jsonb, 'expense', false, null, 790),
  ('IL', 'default', '6450', 'הוצאות משפטיות', '{"en":"Legal fees"}'::jsonb, 'expense', false, null, 795),
  ('IL', 'default', '6460', 'ביקורת חשבונות', '{"en":"Audit fees"}'::jsonb, 'expense', false, null, 798),
  ('IL', 'default', '6470', 'דמי חבר וארגון', '{"en":"Membership dues"}'::jsonb, 'expense', false, null, 799),
  ('IL', 'default', '6480', 'אירוח ומתנות ללקוחות', '{"en":"Client entertainment and gifts"}'::jsonb, 'expense', false, null, 800),
  ('IL', 'default', '6490', 'הוצאות שונות', '{"en":"Miscellaneous expenses"}'::jsonb, 'expense', false, null, 805),
  ('IL', 'default', '6500', 'פחת', '{"en":"Depreciation"}'::jsonb, 'expense_depreciation', false, null, 810),
  ('IL', 'default', '6510', 'הפחתת נכסים בלתי מוחשיים', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, null, 820),
  ('IL', 'default', '6520', 'ירידת ערך מוניטין', '{"en":"Goodwill impairment"}'::jsonb, 'expense_depreciation', false, null, 825),
  ('IL', 'default', '6950', 'הפסדי שער חליפין — ממומשים', '{"en":"Realised foreign exchange loss"}'::jsonb, 'expense', false, null, 830),
  ('IL', 'default', '6955', 'הפסדי שער חליפין — טרם מומשו', '{"en":"Unrealised foreign exchange loss"}'::jsonb, 'expense', false, null, 840),
  ('IL', 'default', '6990', 'הפרשי עיגול', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 850),
  ('IL', 'default', '7050', 'עמלות מימון והפרשי הצמדה', '{"en":"Financing commissions and linkage differentials"}'::jsonb, 'expense', false, null, 855),
  ('IL', 'default', '7100', 'הוצאות מימון', '{"en":"Finance costs"}'::jsonb, 'expense', false, null, 860),
  ('IL', 'default', '8000', 'הוצאות מס חברות לשנה', '{"en":"Income tax expense for the year"}'::jsonb, 'expense', false, null, 870),
  ('IL', 'default', '8010', 'מסים נדחים', '{"en":"Deferred tax"}'::jsonb, 'expense', false, null, 875)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('IL', 'BNK', 'בנק', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('IL', 'CSH', 'קופה', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('IL', 'GEN', 'יומן כללי', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('IL', 'OPN', 'יתרות פתיחה', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('IL', 'PUR', 'יומן רכש', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('IL', 'SAL', 'יומן מכירות', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('IL', 'IL-P-BL-VEH', 'רכישת רכב פרטי, מס תשומות חסום', '{"en":"Purchase of a private vehicle, input tax blocked"}'::jsonb, 'רכישה, ייבוא או שכירות של רכב פרטי, חדש או משומש, שמס התשומות בגינו אינו ניתן לניכוי אף אם הרכב משמש לצורכי העסק בלבד.', 'percent', 18, 'purchase', 'domestic', date '2025-01-01', null, 'תקנות מס ערך מוסף, התשל״ו-1976, תקנה 14(א) — the input tax on the purchase or the import of a ''private vehicle'' (as defined in regulation 1) is not deductible, new or used, even where the vehicle serves the business exclusively. This pack''s research read the rule from professional secondary sources rather than from a directly-fetchable copy of regulation 14 itself; the tax lands on the account of the line it taxes rather than on 1150, and on no box of the return.', null, null, 100, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-regulations', null, null, null, null),
  ('IL', 'IL-P-CAP', 'רכישת רכוש קבוע, ניתן לניכוי', '{"en":"Purchase of a fixed asset, recoverable"}'::jsonb, 'רכישה או ייבוא של רכוש קבוע לשימוש בעסק, ששולם בגינם מס תשומות הניתן לניכוי.', 'percent', 18, 'purchase', 'domestic', date '2025-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א), applied to the purchase of a fixed asset; the periodic report keeps a fixed-asset purchase apart from an ordinary purchase — see box 7 of tax_report.json.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('IL', 'IL-P-EX', 'רכישה, פטורה ממס', '{"en":"Purchase, exempt"}'::jsonb, 'רכישה של עסקה פטורה ממס, כגון השכרת דירה למגורים, שלא נגבה בגינה מס תשומות.', 'percent', 0, 'purchase', 'exempt', date '1976-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 31 — an exempt supply carries no tax for the buyer to deduct, and is reported on no box of the return.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('IL', 'IL-P-IMP', 'ייבוא טובין לפי רשימון יבוא, ניתן לניכוי', '{"en":"Import of goods per an import declaration, recoverable"}'::jsonb, 'ייבוא טובין, שהמס בגינו שולם למכס כנגד רשימון יבוא וניתן לניכוי כמס תשומות.', 'percent', 18, 'purchase', 'import', date '2025-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, פרק ו׳ (סעיפים 19 עד 20) charges VAT on the import of goods, collected by Customs against the import declaration (רשימון יבוא) rather than self-assessed on the periodic report; סעיף 38(א) then lets the importer deduct the tax once paid. This pack models the import document against the customs or forwarding agent who actually collects the amount from the importer and remits it — an Israeli import ordinarily reaches a business as a single invoice from that agent covering the customs value, the duty and the VAT — rather than inventing a deferred self-assessment Israeli law does not give an ordinary importer.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('IL', 'IL-P-RC-SVC', 'ייבוא שירות מתושב חוץ, חשבונית עצמית', '{"en":"Imported service from a foreign resident, self-invoice"}'::jsonb, 'שירות או נכס בלתי מוחשי המיובאים מספק שאין לו עסקים בישראל, שהעוסק המקבל מוציא בגינם חשבונית עצמית ומשדר לעצמו את המס המגיע.', 'percent', 18, 'purchase', 'foreign_services_received', date '2025-01-01', null, 'תקנות מס ערך מוסף, התשל״ו-1976, תקנה 6ג ו-6ד — a dealer who imports a service or an intangible asset from a person with no place of business in Israel issues a self-invoice in their own name, reports it with the periodic report filed under regulation 23, and pays the tax due with that report; the same tax, to the extent the import is used for a taxable activity, is deducted in the same report under section 38(א) of the Law. This pack''s research read the mechanism from professional secondary sources rather than from a directly-fetchable copy of the two regulations; a reviewer should check their exact wording.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-regulations', null, null, null, null),
  ('IL', 'IL-P-SR', 'רכישה, שיעור מלא 18% (מ-1.1.2025), ניתן לניכוי', '{"en":"Purchase, standard rate 18% (from 1 Jan 2025), recoverable"}'::jsonb, 'רכישה שוטפת של טובין או שירותים, שאינה רכישת רכוש קבוע, ששולם בגינה מס תשומות הניתן לניכוי במלואו.', 'percent', 18, 'purchase', 'domestic', date '2025-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א) — ''מס תשומות שנתחייב בו עוסק... ניתן לניכוי ובלבד שהן לשימוש בעסקה החייבת במס''.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('IL', 'IL-S-EX-RESI', 'מכירה, פטורה — השכרת דירת מגורים', '{"en":"Sale, exempt — residential lease"}'::jsonb, 'השכרת דירה המשמשת למגורים בלבד, לתקופה שאינה עולה על 25 שנים, שלא לשם אירוח בבית מלון.', 'percent', 0, 'sale', 'exempt', date '1976-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 31(1) — the letting of an asset for residence, for a period not exceeding 25 years, other than a letting for hotel-style accommodation, is exempt.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('IL', 'IL-S-SR', 'מכירה, שיעור מלא 18% (מ-1.1.2025)', '{"en":"Sale, standard rate 18% (from 1 Jan 2025)"}'::jsonb, 'מכירה חייבת במס בשיעור המלא — כל עסקה בישראל שאינה חייבת בשיעור אפס ואינה פטורה.', 'percent', 18, 'sale', 'domestic', date '2025-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 2 — ''על עסקה בישראל... יוטל מס ערך מוסף בשיעור אחד ממחיר העסקה'', the rate being set by the Minister of Finance by order after consulting the Knesset Finance Committee. צו מס ערך מוסף (שיעור המס על עסקה ועל יבוא טובין)(תיקון), התשפ״ד-2024, published in Reshumot on 28 February 2024, raised the rate from 17% to 18% for a transaction whose tax point falls from 1 January 2025; the Tax Authority''s Interpretive Directive 1/2024 sets the tax-point rules that decide which rate a transaction spanning the change falls under.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-rate-order', null, null, null, null),
  ('IL', 'IL-S-ZR-EILAT', 'מכירה, פטורה — שירות באזור אילת בידי תושב אזור אילת', '{"en":"Sale, exempt — service in the Eilat area by an Eilat-area resident"}'::jsonb, 'מתן שירות באזור אילת, על ידי עוסק שהוא תושב אזור אילת, לצריכה או לשימוש באזור אילת.', 'percent', 0, 'sale', 'exempt', date '1985-01-01', null, 'חוק אזור סחר חפשי באילת (פטורים והנחות ממסים), התשמ״ה-1985, סעיף 5(ה) — ''מתן שירותים באזור אילת בידי תושב אזור אילת יהא פטור ממס ערך מוסף''. The exemption turns on two facts this pack cannot read from a document alone — that the supplier is a resident of the Eilat free-trade area, and that the service is supplied there — so this tax carries `conditions: ["supply_nature"]` and is not wired to a territory rule of its own. A separate, narrower exemption of the same Law covers goods brought into Eilat for sale there (section 5(א), with import VAT paid and then refunded under regulation 19 of the Law''s own Regulations); this pack does not carry that second mechanism — see the README.', null, null, 50, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'eilat-law', null, null, null, null),
  ('IL', 'IL-S-ZR-EXP', 'מכירה, שיעור אפס — יצוא טובין', '{"en":"Sale, zero-rated — export of goods"}'::jsonb, 'מכירת טובין המיוצאים מישראל, שהוגשה לגביהם הצהרת יצוא או מסמך אחר וניתנה התרה.', 'percent', 0, 'sale', 'export', date '1976-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 30(א)(1) — the sale of goods is zero-rated where an export declaration or another document naming the goods as exported has been filed and cleared, so the exporter can show the goods actually left Israel.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('IL', 'IL-S-ZR-SVC', 'מכירה, שיעור אפס — שירות לתושב חוץ', '{"en":"Sale, zero-rated — service to a foreign resident"}'::jsonb, 'מתן שירות לתושב חוץ, למעט שירות שנרשם בתקנות כשירות שאינו מזכה בשיעור אפס — בפרט שירות הניתן, נוסף על תושב החוץ, גם לתושב ישראל בישראל.', 'percent', 0, 'sale', 'export', date '1976-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 30(א)(5) — a service supplied to a foreign resident is zero-rated, subject to the exceptions the VAT Regulations state; regulation 12 of תקנות מס ערך מוסף, התשל״ו-1976 (per multiple professional secondary sources this pack''s research could not itself verify against the regulation''s own text) withholds the zero rate where the service, though billed to a foreign resident, is also actually supplied to a person in Israel. This pack does not model that exception — a reviewer should apply it by hand where it is relevant.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null)
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
    ('IL-P-BL-VEH', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('IL-P-BL-VEH', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('IL-P-BL-VEH', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('IL-P-BL-VEH', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('IL-P-CAP', 'invoice', 'base', 100, null, '7', array['7']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-CAP', 'invoice', 'tax', 100, '1150', '8', array['8']::text[], 100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-CAP', 'credit_note', 'base', 100, null, '7', array['7']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-CAP', 'credit_note', 'tax', 100, '1150', '8', array['8']::text[], -100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-IMP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-IMP', 'invoice', 'tax', 100, '1150', '12', array['12']::text[], 100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-IMP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-IMP', 'credit_note', 'tax', 100, '1150', '12', array['12']::text[], -100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-RC-SVC', 'invoice', 'base', 100, null, '9', array['9']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-RC-SVC', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-RC-SVC', 'invoice', 'tax', -100, '2100', '10', array['10']::text[], 100, 'IL-VAT-PERIODIC', 30),
    ('IL-P-RC-SVC', 'credit_note', 'base', 100, null, '9', array['9']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-RC-SVC', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-RC-SVC', 'credit_note', 'tax', -100, '2100', '10', array['10']::text[], -100, 'IL-VAT-PERIODIC', 30),
    ('IL-P-SR', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-SR', 'invoice', 'tax', 100, '1150', '6', array['6']::text[], 100, 'IL-VAT-PERIODIC', 20),
    ('IL-P-SR', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-P-SR', 'credit_note', 'tax', 100, '1150', '6', array['6']::text[], -100, 'IL-VAT-PERIODIC', 20),
    ('IL-S-EX-RESI', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-EX-RESI', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-SR', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-SR', 'invoice', 'tax', 100, '2100', '2', array['2']::text[], 100, 'IL-VAT-PERIODIC', 20),
    ('IL-S-SR', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-SR', 'credit_note', 'tax', 100, '2100', '2', array['2']::text[], -100, 'IL-VAT-PERIODIC', 20),
    ('IL-S-ZR-EILAT', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-ZR-EILAT', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-ZR-EXP', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-ZR-EXP', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-ZR-SVC', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'IL-VAT-PERIODIC', 10),
    ('IL-S-ZR-SVC', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'IL-VAT-PERIODIC', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'IL' and t.code = v.tax_code
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
  ('IL', 'IL-VAT-PERIODIC', 'דוח תקופתי למע״מ (Periodic VAT report)', array['month', 'bimonth']::declaration_period[], null, date '1976-01-01', null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 67(א2)(1) — the ordinary reporting period of a registered dealer is two months, unless the dealer''s turnover in the preceding tax year exceeded an amount the section itself sets and the Tax Authority updates every 1 January by the rise in the consumer price index (NIS 1,725,000 for the 2025 tax year, per the Tax Authority''s own published table), in which case the period is one month. Section 67(א2)(2) also lets a dealer whose turnover is under the ceiling elect the monthly period. Because the ceiling is a fact about each dealer''s own turnover and not an answer the law gives every dealer alike, this pack proposes no `period_default` — the same reading packs/lu/ gives its own turnover-conditioned cadence.', true,'day_of_month_after_period'::filing_deadline_rule, 23, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 67(ב) sets the baseline: a report is due within fifteen days of the end of the report period, and section 71 sets the same day for payment. תקנות מס ערך מוסף, התשל״ו-1976, תקנה 23(ג) extends that date for a dealer who files online — the ordinary case since online filing became the norm — to the 23rd of the month after the period; the Tax Authority''s own yearly notice of reporting and payment dates (see "vat-filing-guidance" in certification.sources) states the 23rd for every 2025 period. This pack''s research could not open a directly-fetchable copy of regulation 23(ג) itself to quote its own words, and names that gap rather than inventing them; a reviewer should check the regulation''s text before this citation is relied on for a dealer who still files on paper, who remains on the fifteen-day rule of section 67(ב).', 'vat-filing-guidance', null)
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
  ('IL', 'IL-VAT-PERIODIC', '1', 'base', 'שווי עסקאות חייבות במס בשיעור מלא (Value of taxable domestic transactions, standard rate)', '{"en":"Value of taxable domestic transactions, standard rate"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א) conditions the deduction and the reporting of tax on a periodic report; the value reported here excludes the tax itself, which box 2 carries. This pack''s research could not open a directly-fetchable copy of the periodic report''s own administrative field list (the live misim.gov.il screen, or regulation 23 of the VAT Regulations, which most likely prescribes it) — see the note on the "vat-regulations" source. The box numbering below is this pack''s own, built on what every independent professional description of the report agrees it holds, and not the Tax Authority''s own field numbers.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '2', 'tax', 'מע״מ על עסקאות (Output tax on box 1)', '{"en":"Output tax on box 1"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 2 וסעיף 9 — the tax charged on box 1 at the rate in force.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '3', 'base', 'שווי עסקאות בשיעור אפס (Value of zero-rated transactions — export and Eilat)', '{"en":"Value of zero-rated transactions — export and Eilat"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 30 (export of goods and of services to a foreign resident) and חוק אזור סחר חפשי באילת (פטורים והנחות ממסים), התשמ״ה-1985, סעיף 5 (a service supplied in the Eilat area by an Eilat-area resident).', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '4', 'base', 'שווי עסקאות פטורות ממס (Value of exempt transactions)', '{"en":"Value of exempt transactions"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 31.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '5', 'base', 'שווי תשומות שוטפות (Value of ordinary inputs — goods and services, not fixed assets)', '{"en":"Value of ordinary inputs — goods and services, not fixed assets"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א) — the value of a purchase whose input tax the dealer seeks to deduct, other than the purchase of a fixed asset, which box 7 carries apart: multiple independent professional descriptions of the periodic report agree it keeps the two apart, which this research reads as reflecting the different capital-goods disclosures the Income Tax Ordinance and VAT statistics ask of a fixed asset; this pack''s research could not open a primary text naming the distinction itself.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '6', 'tax', 'מע״מ תשומות שוטפות, לרבות מס שהעוסק שידר לעצמו (Input tax on box 5, including the recoverable share of a self-invoiced import of services)', '{"en":"Input tax on box 5, including the recoverable share of a self-invoiced import of services"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א), and — for a self-invoice — תקנות מס ערך מוסף, התשל״ו-1976, תקנה 6ג ו-6ד.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '7', 'base', 'שווי תשומות בגין רכוש קבוע (Value of inputs — fixed assets)', '{"en":"Value of inputs — fixed assets"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א), applied to the purchase or the import of a fixed asset of the business.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '8', 'tax', 'מע״מ תשומות בגין רכוש קבוע (Input tax on box 7)', '{"en":"Input tax on box 7"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א).', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '9', 'base', 'שווי יבוא שירותים ונכסים בלתי מוחשיים לפי חשבונית עצמית (Value of imported services and intangible assets, self-invoiced)', '{"en":"Value of imported services and intangible assets, self-invoiced"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'תקנות מס ערך מוסף, התשל״ו-1976, תקנה 6ג ו-6ד — a dealer who imports a service or an intangible asset from a person with no place of business in Israel self-assesses the tax by issuing a self-invoice (חשבונית עצמית) and reporting it with the periodic report filed under regulation 23; the same source note as box 1 applies to the exact wording.', 'vat-regulations'),
  ('IL', 'IL-VAT-PERIODIC', '10', 'tax', 'מע״מ שהעוסק שידר לעצמו על יבוא שירותים (Tax self-assessed on box 9)', '{"en":"Tax self-assessed on box 9"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'תקנות מס ערך מוסף, התשל״ו-1976, תקנה 6ג ו-6ד. The recoverable share of this same amount, where the imported service is used for a taxable activity, is deducted through box 6 and not counted here a second time.', 'vat-regulations'),
  ('IL', 'IL-VAT-PERIODIC', '11', 'base', 'שווי טובין מיובאים לפי רשימוני יבוא (Value of imported goods, per import declarations)', '{"en":"Value of imported goods, per import declarations"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, פרק ו׳ (סעיפים 19 עד 20) sets the charge on the import of goods, assessed and collected by Customs against the import declaration (רשימון יבוא) rather than reported by the dealer on this return; the value is reported here for the same reason box 1''s is — as the base the tax of box 12 was charged on. This pack''s research corroborates a distinct import-of-goods category in the periodic report from the table of contents of the Tax Authority''s own guide to the detailed electronic report file (PCN874), which lists ''פקודות רשומוני יבוא'' as a posting category apart from an ordinary domestic purchase.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '12', 'tax', 'מע״מ ששולם למכס על יבוא טובין, ניתן לניכוי (Tax paid to Customs on box 11, recoverable)', '{"en":"Tax paid to Customs on box 11, recoverable"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38(א), once the tax has been paid to Customs against the import declaration.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '13', 'total', 'סך מס עסקאות לתשלום (Total output tax due)', '{"en":"Total output tax due"}'::jsonb, 130, null, array['2', '10']::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '14', 'total', 'סך מס תשומות הניתן לניכוי (Total input tax recoverable)', '{"en":"Total input tax recoverable"}'::jsonb, 140, null, array['6', '8', '12']::text[], '{}'::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38.', 'vat-law'),
  ('IL', 'IL-VAT-PERIODIC', '15', 'total', 'יתרת מס לתשלום או לקבלה (Net tax payable or refundable for the period)', '{"en":"Net tax payable or refundable for the period"}'::jsonb, 150, null, array['13']::text[], array['14']::text[], null, null, false, false, null, 'חוק מס ערך מוסף, התשל״ו-1975, סעיף 38 וסעיף 39 — a negative figure is an excess of input tax, which section 39 lets the dealer carry to the next period or, past six periods, claim as a refund under section 40; this pack applies no floor at zero.', 'vat-law')
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
  ('IL-IAS1-IS', 'IL', 'default', 'דוח רווח והפסד (Statement of profit or loss — IAS 1)', 'income_statement', 'IL-IAS1', date '1970-01-01', null, 'See the legal_reference of IL-IAS1-SFP: the same reading applies here. Expenses are classified by nature, which is what a small business''s ledger holds without allocating a cost to a function — IAS 1, paragraph 99 lets either classification stand and paragraph 102 illustrates the by-nature form.', 'accounting-standard-29'),
  ('IL-IAS1-SFP', 'IL', 'default', 'דוח על המצב הכספי (Statement of financial position — IAS 1)', 'balance_sheet', 'IL-IAS1', date '1970-01-01', null, 'תקן חשבונאות מספר 29 of the Israel Accounting Standards Board requires a ''reporting corporation'' — a public company and a private company that has issued bonds to the public — to prepare its financial statements under IFRS for periods beginning 1 January 2008, and תקנות ניירות ערך (דוחות כספיים שנתיים), התש״ע-2010 sets out what such a corporation''s annual report must contain without itself fixing a numbered chart of lines. No statute this pack''s research found binds every other Israeli company — the overwhelming majority of them, private and outside that definition — to this or to any other fixed statement format; those companies keep books under Israeli GAAP or under IFRS by choice, with no numbered scheme of their own either. The lines below are therefore built, exactly as packs/ae/ and packs/sg/ and packs/hk/ each build theirs where no country-specific statutory format exists, on the minimum line items IAS 1 itself requires (paragraph 54), current and non-current apart. This is the first thing a reviewer should check.', 'accounting-standard-29')
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
  ('IL-IAS1-IS', 'REV', null, 'הכנסות (Revenue)', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 82(a).', null),
  ('IL-IAS1-IS', 'OINC', null, 'הכנסות אחרות (Other income)', '{"en":"Other income"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 85.', null),
  ('IL-IAS1-IS', 'COS', null, 'עלות המכר (Cost of sales)', '{"en":"Cost of sales"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 99 and 103 (by-nature classification: raw materials and consumables used).', null),
  ('IL-IAS1-IS', 'EMP', null, 'הוצאות שכר (Employee benefits expense)', '{"en":"Employee benefits expense"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 102(d).', null),
  ('IL-IAS1-IS', 'DEP', null, 'פחת והפחתות (Depreciation and amortisation)', '{"en":"Depreciation and amortisation"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 102(b), and paragraph 104 (the entity discloses depreciation and amortisation among its by-nature expenses).', null),
  ('IL-IAS1-IS', 'OPEX', null, 'הוצאות תפעוליות אחרות (Other operating expenses)', '{"en":"Other operating expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 99.', null),
  ('IL-IAS1-IS', 'FIN', null, 'הוצאות מימון, נטו (Finance costs, net)', '{"en":"Finance costs, net"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 82(b). Realised and unrealised exchange differences and rounding differences are grouped with interest expense here rather than split into a line of their own.', null),
  ('IL-IAS1-IS', 'TAX', null, 'הוצאות מסים על ההכנסה (Income tax expense)', '{"en":"Income tax expense"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 82(d).', null),
  ('IL-IAS1-IS', 'PROFIT', null, 'רווח (הפסד) לתקופה (Profit (loss) for the period)', '{"en":"Profit (loss) for the period"}'::jsonb, 90, 1, true, array['REV', 'OINC']::text[], array['COS', 'EMP', 'DEP', 'OPEX', 'FIN', 'TAX']::text[], null, 'IAS 1, paragraph 81A(a).', null),
  ('IL-IAS1-SFP', 'CA', null, 'רכוש שוטף (Current assets)', '{"en":"Current assets"}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4']::text[], '{}'::text[], null, 'IAS 1, paragraphs 60 and 66 — an entity presents current and non-current assets as separate classifications.', null),
  ('IL-IAS1-SFP', 'CA.1', 'CA', 'מזומנים ושווי מזומנים (Cash and cash equivalents)', '{"en":"Cash and cash equivalents"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(i).', null),
  ('IL-IAS1-SFP', 'CA.2', 'CA', 'לקוחות וחייבים אחרים (Trade and other receivables)', '{"en":"Trade and other receivables"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(h). VAT input tax and the net amount receivable from the Tax Authority are presented here rather than as current tax, which paragraph 54(n) keeps for income tax.', null),
  ('IL-IAS1-SFP', 'CA.3', 'CA', 'מלאי (Inventories)', '{"en":"Inventories"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(g).', null),
  ('IL-IAS1-SFP', 'CA.4', 'CA', 'השקעות לזמן קצר (Short-term investments)', '{"en":"Short-term investments"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(d).', null),
  ('IL-IAS1-SFP', 'NCA', null, 'רכוש קבוע ולא שוטף (Non-current assets)', '{"en":"Non-current assets"}'::jsonb, 60, 1, true, array['NCA.1', 'NCA.2', 'NCA.3']::text[], '{}'::text[], null, 'IAS 1, paragraphs 60 and 66.', null),
  ('IL-IAS1-SFP', 'NCA.1', 'NCA', 'רכוש קבוע, נטו (Property, plant and equipment, net)', '{"en":"Property, plant and equipment, net"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(a). Cost and accumulated depreciation sit in the same range, so a class nets to its carrying amount.', null),
  ('IL-IAS1-SFP', 'NCA.2', 'NCA', 'השקעות וחייבים לזמן ארוך (Investments and long-term receivables)', '{"en":"Investments and long-term receivables"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(e).', null),
  ('IL-IAS1-SFP', 'NCA.3', 'NCA', 'נכסים בלתי מוחשיים, נטו (Intangible assets, net)', '{"en":"Intangible assets, net"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(c).', null),
  ('IL-IAS1-SFP', 'TA', null, 'סך כל הרכוש (Total assets)', '{"en":"Total assets"}'::jsonb, 100, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('IL-IAS1-SFP', 'CL', null, 'התחייבויות שוטפות (Current liabilities)', '{"en":"Current liabilities"}'::jsonb, 110, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, 'IAS 1, paragraphs 60 and 69.', null),
  ('IL-IAS1-SFP', 'CL.1', 'CL', 'ספקים (Trade payables)', '{"en":"Trade payables"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(k).', null),
  ('IL-IAS1-SFP', 'CL.2', 'CL', 'זכאים אחרים וחשבון מעבר (Other payables and the suspense account)', '{"en":"Other payables and the suspense account"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 55.', null),
  ('IL-IAS1-SFP', 'CL.3', 'CL', 'מע״מ לשלם (VAT payable)', '{"en":"VAT payable"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(n).', null),
  ('IL-IAS1-SFP', 'CL.4', 'CL', 'הפרשות שוטפות (Current provisions)', '{"en":"Current provisions"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(l).', null),
  ('IL-IAS1-SFP', 'CL.5', 'CL', 'אשראי לזמן קצר (Short-term borrowings)', '{"en":"Short-term borrowings"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(m).', null),
  ('IL-IAS1-SFP', 'NCL', null, 'התחייבויות לא שוטפות (Non-current liabilities)', '{"en":"Non-current liabilities"}'::jsonb, 170, 1, true, array['NCL.1', 'NCL.2']::text[], '{}'::text[], null, 'IAS 1, paragraphs 60 and 69.', null),
  ('IL-IAS1-SFP', 'NCL.1', 'NCL', 'הלוואות לזמן ארוך (Long-term borrowings)', '{"en":"Long-term borrowings"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(m).', null),
  ('IL-IAS1-SFP', 'NCL.2', 'NCL', 'הפרשות לא שוטפות (Non-current provisions)', '{"en":"Non-current provisions"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(l).', null),
  ('IL-IAS1-SFP', 'TL', null, 'סך כל ההתחייבויות (Total liabilities)', '{"en":"Total liabilities"}'::jsonb, 200, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('IL-IAS1-SFP', 'EQ.1', null, 'הון מניות ופרמיה (Share capital and premium)', '{"en":"Share capital and premium"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(r) and 79.', null),
  ('IL-IAS1-SFP', 'EQ.2', null, 'עודפים (Retained earnings)', '{"en":"Retained earnings"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'IAS 1, paragraph 54(r).', null),
  ('IL-IAS1-SFP', 'TE', null, 'סך כל ההון (Total equity)', '{"en":"Total equity"}'::jsonb, 230, 1, true, array['EQ.1', 'EQ.2']::text[], '{}'::text[], null, null, null)
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
    ('IL-IAS1-IS', 'REV', 10, 'code_range', '4000', '4040', null, 'any'),
    ('IL-IAS1-IS', 'OINC', 10, 'code_range', '4700', '4790', null, 'any'),
    ('IL-IAS1-IS', 'COS', 10, 'code_range', '5000', '5040', null, 'any'),
    ('IL-IAS1-IS', 'EMP', 10, 'code_range', '6100', '6160', null, 'any'),
    ('IL-IAS1-IS', 'DEP', 10, 'code_range', '6500', '6520', null, 'any'),
    ('IL-IAS1-IS', 'OPEX', 10, 'code_range', '6200', '6490', null, 'any'),
    ('IL-IAS1-IS', 'FIN', 10, 'code_range', '6950', '7100', null, 'any'),
    ('IL-IAS1-IS', 'TAX', 10, 'code_range', '8000', '8010', null, 'any'),
    ('IL-IAS1-SFP', 'CA.1', 10, 'code_range', '1000', '1020', null, 'any'),
    ('IL-IAS1-SFP', 'CA.2', 10, 'code_range', '1100', '1170', null, 'any'),
    ('IL-IAS1-SFP', 'CA.3', 10, 'code_range', '1200', '1240', null, 'any'),
    ('IL-IAS1-SFP', 'CA.4', 10, 'code_range', '1300', '1310', null, 'any'),
    ('IL-IAS1-SFP', 'NCA.1', 10, 'code_range', '1600', '1661', null, 'any'),
    ('IL-IAS1-SFP', 'NCA.2', 10, 'code_range', '1700', '1720', null, 'any'),
    ('IL-IAS1-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('IL-IAS1-SFP', 'CL.1', 10, 'code_range', '2000', '2005', null, 'any'),
    ('IL-IAS1-SFP', 'CL.2', 10, 'code_range', '2010', '2070', null, 'any'),
    ('IL-IAS1-SFP', 'CL.2', 20, 'account_code', '2990', null, null, 'any'),
    ('IL-IAS1-SFP', 'CL.3', 10, 'code_range', '2100', '2110', null, 'any'),
    ('IL-IAS1-SFP', 'CL.4', 10, 'code_range', '2150', '2160', null, 'any'),
    ('IL-IAS1-SFP', 'CL.5', 10, 'code_range', '2200', '2220', null, 'any'),
    ('IL-IAS1-SFP', 'NCL.1', 10, 'code_range', '2300', '2310', null, 'any'),
    ('IL-IAS1-SFP', 'NCL.2', 10, 'code_range', '2350', '2360', null, 'any'),
    ('IL-IAS1-SFP', 'EQ.1', 10, 'code_range', '3000', '3030', null, 'any'),
    ('IL-IAS1-SFP', 'EQ.2', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('IL', 'Israel', '{"en":"Israel"}'::jsonb, array['he', 'en']::text[], 'ILS', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'he', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', null, null, null, null, '2110', '1155', null, null)
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
  numbering_gapless             = true,
  number_format                 = '{CODE}-{NNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'תקנות מס ערך מוסף, התשל"ו-1976, תקנה 9ב — a tax invoice issued by computer must carry a running, sequential number with no gap and no repetition, assigned by the software itself (''מספרי החשבוניות ינופקו ברצף רץ ללא הפסק וללא חזרה על אותו מספר''), for as long as the dealer keeps books by computer under the Records-Keeping Rules. This pack''s research read that requirement from secondary professional sources rather than from a directly-fetchable copy of regulation 9ב itself; nevo.co.il''s regulations text (see "vat-regulations") should be checked for the exact wording before this citation is relied on.',
  numbering_source_key          = 'vat-regulations',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'חוק מס ערך מוסף, התשל"ו-1975, סעיף 24 (מכר טובין) וסעיף 28 (מתן שירות) קובעים כי מועד החיוב במס הוא מועד מסירת הטובין או מועד גמר מתן השירות, ואילו סעיף 29 גובר עליהם ומקדים את מועד החיוב למועד הוצאת החשבונית, ככל שזו קדמה למסירה או לגמר השירות — the delivery of the goods or the completion of the service is the principle, and the invoice date displaces it wherever the invoice was issued first, which is the ordinary case for a business that invoices before or on delivery. A registered dealer whose annual turnover does not exceed the cash-basis ceiling of section 21 may instead be taxed on collection; that derogation is carried on the tax itself as cash_basis and not on this country-wide rule.',
  tax_point_source_key          = 'vat-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No statute this pack''s research found obliges an Israeli business to exchange a structured electronic invoice — a Peppol-style document a buyer''s software can read — with another business. What the Economic Efficiency Law (Legislative Amendments to Achieve the Budget Targets for the 2023 and 2024 Budget Years), 5783-2023 requires instead, from 1 January 2024, is a real-time control of a different shape: a seller who wants a buyer to be able to deduct the input tax of a tax invoice above a declining threshold must first request an ''allocation number'' (מספר הקצאה) from the Tax Authority''s own system for that specific invoice, and print it on the document — the threshold itself falling from NIS 25,000 in May 2024 to NIS 20,000 from 1 January 2025, NIS 10,000 from 1 January 2026 and NIS 5,000 from 1 June 2026. The invoice a buyer receives is not itself required to be a structured document of any named format; the control is an authorisation number requested and returned over the Tax Authority''s own API before or when the invoice is issued, closer to a real-time clearance model than to a Peppol exchange. This pack format has a field for the profile of a structured invoice exchanged between two parties and none for a clearance control of this shape, so `profile` and `mandatory_from` stay empty rather than naming something this is not; the allocation-number regime itself is documented in this pack''s README and in docs/international.md under "Israel", and is not patched into the schema.',
  einvoice_source_key           = 'invoice-allocation-threshold',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'IL';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('IL', 'reverse_charge', 'reverse_charge', 'חשבונית עצמית — המס על עסקה זו מדווח ומשולם על ידי מקבל השירות, בהתאם לתקנה 6ג/6ד לתקנות מס ערך מוסף, התשל"ו-1976.', '{"en":"Self-invoice — the tax on this transaction is reported and paid by the recipient of the service, under regulation 6ג/6ד of the Value Added Tax Regulations, 5736-1976."}'::jsonb, 10, date '1970-01-01', null, 'תקנות מס ערך מוסף, התשל"ו-1976, תקנה 6ג ותקנה 6ד — an Israeli dealer who imports a service or an intangible asset from a person with no place of business in Israel issues a self-invoice (חשבונית עצמית) in their own name and reports the tax with the periodic report filed under regulation 23. This pack''s research read the mechanism from professional secondary sources rather than from a directly-fetchable copy of the two regulations; see the note on the "vat-regulations" entry.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
