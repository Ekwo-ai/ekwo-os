-- Ekwo OS — កម្ពុជា: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/kh at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build kh`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Sub-Decree No. 49 ANKr.BK of 11 March 2024 on the Value Added Tax (Khmer, scanned): articles 3 (definitions), 4 to 10 (registration), 11 to 20 (input tax credit, apportionment, excess credit), 21 (tax invoice), 22 (diplomatic missions), 23 to 25 (place and time of supply), 28 (adjustment), 29 (records), 30 (tax-inclusive prices) and 32 (import) (General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia)
--     https://www.tax.gov.kh/u6rhf7ogbi6/gdtstream/1adcafd1-44a6-4875-b3e7-349a693b7c9c
--   Law on Taxation, NS/RKM/0523/004 of 16 May 2023 — the law the sub-decree implements (rate, zero rate, exemptions, taxable persons). Listed on the Department's site as a scanned Khmer document of about 11 MB that could not be read here (General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia)
--     https://www.tax.gov.kh/u6rhf7ogbi6/gdtstream/816f7e7b-e4be-4d8f-a789-e587b92dbe2e
--   Law on Accounting and Auditing, NS/RKM/4016/006 of 11 April 2016 — the duty to keep accounts and prepare financial statements (title and date read on the Department's list; the text itself was not read) (General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia)
--     https://www.tax.gov.kh/u6rhf7ogbi6/gdtstream/1cce400f-e948-4724-9712-65c3bab4fc06
--   General Department of Taxation — home page and e-Tax portal: the due dates of the monthly return (manual and online), the e-filing and e-payment services, and the library of laws, sub-decrees, prakas and instructions (General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia)
--     https://www.tax.gov.kh/en
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KH', 'កម្ពុជា', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, 'cf14069d2d4c38820a22da62a3f40255e0205bff32910e212b2c2313ae6be8cc', '[{"key":"gdt-vat-subdecree","title":"Sub-Decree No. 49 ANKr.BK of 11 March 2024 on the Value Added Tax (Khmer, scanned): articles 3 (definitions), 4 to 10 (registration), 11 to 20 (input tax credit, apportionment, excess credit), 21 (tax invoice), 22 (diplomatic missions), 23 to 25 (place and time of supply), 28 (adjustment), 29 (records), 30 (tax-inclusive prices) and 32 (import)","publisher":"General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia","url":"https://www.tax.gov.kh/u6rhf7ogbi6/gdtstream/1adcafd1-44a6-4875-b3e7-349a693b7c9c","consulted_on":"2026-10-21","kind":"regulation"},{"key":"law-taxation-2023","title":"Law on Taxation, NS/RKM/0523/004 of 16 May 2023 — the law the sub-decree implements (rate, zero rate, exemptions, taxable persons). Listed on the Department''s site as a scanned Khmer document of about 11 MB that could not be read here","publisher":"General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia","url":"https://www.tax.gov.kh/u6rhf7ogbi6/gdtstream/816f7e7b-e4be-4d8f-a789-e587b92dbe2e","consulted_on":"2026-10-21","kind":"law"},{"key":"law-accounting-2016","title":"Law on Accounting and Auditing, NS/RKM/4016/006 of 11 April 2016 — the duty to keep accounts and prepare financial statements (title and date read on the Department''s list; the text itself was not read)","publisher":"General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia","url":"https://www.tax.gov.kh/u6rhf7ogbi6/gdtstream/1cce400f-e948-4724-9712-65c3bab4fc06","consulted_on":"2026-10-21","kind":"law"},{"key":"gdt-portal","title":"General Department of Taxation — home page and e-Tax portal: the due dates of the monthly return (manual and online), the e-filing and e-payment services, and the library of laws, sub-decrees, prakas and instructions","publisher":"General Department of Taxation, Ministry of Economy and Finance, Kingdom of Cambodia","url":"https://www.tax.gov.kh/en","consulted_on":"2026-10-21","kind":"portal"}]'::jsonb)
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
  ('KH', 'default', 'ផ្លែនគណនីយោងរបស់កម្ពុជា', '{"en":"Cambodia reference chart of accounts"}'::jsonb, true, 'companies', array['KH-BS', 'KH-IS']::text[], null, 'Cambodia''s Law on Accounting and Auditing of 2016 (listed on the General Department of Taxation''s site; its text was not readable from here) obliges an enterprise to keep accounts and prepare financial statements. No chart of accounts, and no statement layout, of Cambodia could be read from an open source: the texts the Department hosts are scanned images, many in Khmer only. This chart is therefore original, four digits by class — 1 assets, 2 liabilities, 3 equity, 4 revenue, 5 cost of sales, 6 operating expenses, 7 finance items, 8 income tax — with the accounts a VAT-registered Cambodian company''s books hold: output and input value added tax, the VAT payable or refundable account a monthly return settles to, withholding tax payable, the National Social Security Fund, and the taxes the Department lists (tax on income, tax on immovable property, signboard tax, tax on means of transportation). The Khmer wording is the pack''s own. Its statements, `KH-BS` and `KH-IS`, are original too.', null)
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
  ('KH', 'default', '1000', 'សាច់ប្រាក់ក្នុងដៃ', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 10),
  ('KH', 'default', '1010', 'គណនីធនាគារ - ចរន្ត', '{"en":"Bank — current account"}'::jsonb, 'asset_cash', false, null, 20),
  ('KH', 'default', '1020', 'គណនីធនាគារ - សន្សំ', '{"en":"Bank — savings account"}'::jsonb, 'asset_cash', false, null, 30),
  ('KH', 'default', '1030', 'គណនីធនាគារ - រូបិយប័ណ្ណបរទេស (ដុល្លារអាមេរិក)', '{"en":"Bank — foreign currency account (US dollar)"}'::jsonb, 'asset_cash', false, null, 40),
  ('KH', 'default', '1040', 'គណនីធនាគារ - រូបិយប័ណ្ណបរទេស (ផ្សេងទៀត)', '{"en":"Bank — foreign currency account (other)"}'::jsonb, 'asset_cash', false, null, 50),
  ('KH', 'default', '1090', 'សាច់ប្រាក់កំពុងដឹកជញ្ជូន', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 60),
  ('KH', 'default', '1100', 'គណនីត្រូវទទួលពីអតិថិជន', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 70),
  ('KH', 'default', '1105', 'សែកត្រូវទទួល', '{"en":"Notes receivable"}'::jsonb, 'asset_receivable', true, null, 80),
  ('KH', 'default', '1110', 'គណនីត្រូវទទួលពីភាគីពាក់ព័ន្ធ', '{"en":"Receivables from related parties"}'::jsonb, 'asset_receivable', true, null, 90),
  ('KH', 'default', '1120', 'ចំណូលមិនទាន់ចេញវិក្កយបត្រ', '{"en":"Unbilled receivables"}'::jsonb, 'asset_current', false, null, 100),
  ('KH', 'default', '1121', 'ប្រាក់កក់បង់មុនសម្រាប់ទំនិញ', '{"en":"Advances paid for goods"}'::jsonb, 'asset_current', false, null, 110),
  ('KH', 'default', '1125', 'ការប្រាក់ត្រូវទទួល', '{"en":"Accrued interest receivable"}'::jsonb, 'asset_current', false, null, 120),
  ('KH', 'default', '1140', 'សំវិធានធនលើគណនីត្រូវទទួលមិនប្រាកដ', '{"en":"Allowance for doubtful accounts"}'::jsonb, 'asset_current', false, null, 130),
  ('KH', 'default', '1150', 'អាករលើតម្លៃបន្ថែមលើធាតុចូល', '{"en":"Input value added tax"}'::jsonb, 'asset_current', false, null, 140),
  ('KH', 'default', '1155', 'អាករលើតម្លៃបន្ថែមត្រូវសំណង', '{"en":"Value added tax refundable"}'::jsonb, 'asset_current', true, null, 150),
  ('KH', 'default', '1160', 'ប្រាក់បុរេប្រទានបុគ្គលិក', '{"en":"Advances to employees"}'::jsonb, 'asset_current', false, null, 160),
  ('KH', 'default', '1170', 'គណនីត្រូវទទួលផ្សេងៗ', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 170),
  ('KH', 'default', '1180', 'ប្រាក់កម្ចីរយៈពេលខ្លីជូនបុគ្គលិក', '{"en":"Short-term loans to employees"}'::jsonb, 'asset_current', false, null, 180),
  ('KH', 'default', '1200', 'សន្និធិទំនិញសម្រេច', '{"en":"Finished goods inventory"}'::jsonb, 'asset_current', false, null, 190),
  ('KH', 'default', '1210', 'សន្និធិវត្ថុធាតុដើម និងសម្ភារៈ', '{"en":"Raw materials and supplies inventory"}'::jsonb, 'asset_current', false, null, 200),
  ('KH', 'default', '1220', 'ផលិតផលកំពុងផលិត', '{"en":"Work in process"}'::jsonb, 'asset_current', false, null, 210),
  ('KH', 'default', '1230', 'សម្ភារៈវេចខ្ចប់ និងសម្ភារៈប្រើប្រាស់', '{"en":"Packaging and consumable supplies"}'::jsonb, 'asset_current', false, null, 220),
  ('KH', 'default', '1240', 'ទំនិញកំពុងដឹកជញ្ជូន', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 230),
  ('KH', 'default', '1300', 'ចំណាយបង់ជាមុន', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 240),
  ('KH', 'default', '1310', 'ប្រាក់កក់បានបង់', '{"en":"Deposits paid"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('KH', 'default', '1320', 'ធានារ៉ាប់រងបង់ជាមុន', '{"en":"Prepaid insurance"}'::jsonb, 'asset_prepayments', false, null, 260),
  ('KH', 'default', '1330', 'ថ្លៃជួលបង់ជាមុន', '{"en":"Prepaid rent"}'::jsonb, 'asset_prepayments', false, null, 270),
  ('KH', 'default', '1350', 'ប្រាក់បុរេប្រទានបុគ្គលិកសម្រាប់ដំណើរការងារ', '{"en":"Advances to employees for travel"}'::jsonb, 'asset_prepayments', false, null, 280),
  ('KH', 'default', '1600', 'ដីធ្លី', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 290),
  ('KH', 'default', '1610', 'អគារ និងសំណង់', '{"en":"Buildings and structures"}'::jsonb, 'asset_fixed', false, null, 300),
  ('KH', 'default', '1611', 'រំលស់បង្គរ - អគារ និងសំណង់', '{"en":"Accumulated depreciation — buildings and structures"}'::jsonb, 'asset_fixed', false, '1610', 310),
  ('KH', 'default', '1620', 'គ្រឿងសង្ហារឹម និងឧបករណ៍ការិយាល័យ', '{"en":"Furniture and office equipment"}'::jsonb, 'asset_fixed', false, null, 320),
  ('KH', 'default', '1621', 'រំលស់បង្គរ - គ្រឿងសង្ហារឹម និងឧបករណ៍ការិយាល័យ', '{"en":"Accumulated depreciation — furniture and office equipment"}'::jsonb, 'asset_fixed', false, '1620', 330),
  ('KH', 'default', '1630', 'យានយន្ត', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, null, 340),
  ('KH', 'default', '1631', 'រំលស់បង្គរ - យានយន្ត', '{"en":"Accumulated depreciation — vehicles"}'::jsonb, 'asset_fixed', false, '1630', 350),
  ('KH', 'default', '1640', 'ឧបករណ៍កុំព្យូទ័រ', '{"en":"Computer equipment"}'::jsonb, 'asset_fixed', false, null, 360),
  ('KH', 'default', '1641', 'រំលស់បង្គរ - ឧបករណ៍កុំព្យូទ័រ', '{"en":"Accumulated depreciation — computer equipment"}'::jsonb, 'asset_fixed', false, '1640', 370),
  ('KH', 'default', '1650', 'ការកែលម្អអចលនទ្រព្យជួល', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 380),
  ('KH', 'default', '1651', 'រំលស់បង្គរ - ការកែលម្អអចលនទ្រព្យជួល', '{"en":"Accumulated depreciation — leasehold improvements"}'::jsonb, 'asset_fixed', false, '1650', 390),
  ('KH', 'default', '1660', 'ម៉ាស៊ីន និងឧបករណ៍ផលិតកម្ម', '{"en":"Machinery and production equipment"}'::jsonb, 'asset_fixed', false, null, 400),
  ('KH', 'default', '1661', 'រំលស់បង្គរ - ម៉ាស៊ីន និងឧបករណ៍ផលិតកម្ម', '{"en":"Accumulated depreciation — machinery and production equipment"}'::jsonb, 'asset_fixed', false, '1660', 410),
  ('KH', 'default', '1670', 'ឧបករណ៍ និងសម្ភារៈ', '{"en":"Tools and equipment"}'::jsonb, 'asset_fixed', false, null, 420),
  ('KH', 'default', '1671', 'រំលស់បង្គរ - ឧបករណ៍ និងសម្ភារៈ', '{"en":"Accumulated depreciation — tools and equipment"}'::jsonb, 'asset_fixed', false, '1670', 430),
  ('KH', 'default', '1700', 'ទ្រព្យសកម្មអរូបី', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, null, 440),
  ('KH', 'default', '1710', 'ប្រាក់កក់រយៈពេលវែង', '{"en":"Long-term deposits"}'::jsonb, 'asset_non_current', false, null, 450),
  ('KH', 'default', '1720', 'កម្មវិធីកុំព្យូទ័រ និងអាជ្ញាប័ណ្ណ', '{"en":"Computer software and licences"}'::jsonb, 'asset_non_current', false, null, 460),
  ('KH', 'default', '1730', 'កេរ្តិ៍ឈ្មោះ', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 470),
  ('KH', 'default', '1740', 'ការវិនិយោគរយៈពេលវែង', '{"en":"Long-term investments"}'::jsonb, 'asset_non_current', false, null, 480),
  ('KH', 'default', '1750', 'ទ្រព្យសកម្មពន្ធពន្យារ', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 490),
  ('KH', 'default', '1760', 'ពន្ធកាត់ទុកដែលបានបង់ជាមុន រង់ចាំកាត់កង', '{"en":"Withholding tax paid in advance, awaiting credit"}'::jsonb, 'asset_non_current', false, null, 500),
  ('KH', 'default', '2000', 'គណនីត្រូវសងអ្នកផ្គត់ផ្គង់', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 510),
  ('KH', 'default', '2005', 'សែកត្រូវសង', '{"en":"Notes payable"}'::jsonb, 'liability_payable', true, null, 520),
  ('KH', 'default', '2020', 'ប្រាក់បៀវត្សរ៍ត្រូវបង់', '{"en":"Accrued payroll"}'::jsonb, 'liability_current', false, null, 530),
  ('KH', 'default', '2030', 'ប្រាក់រង្វាន់ត្រូវបង់', '{"en":"Accrued bonus"}'::jsonb, 'liability_current', false, null, 540),
  ('KH', 'default', '2040', 'ប្រាក់កក់ពីអតិថិជន', '{"en":"Advances from customers"}'::jsonb, 'liability_current', false, null, 550),
  ('KH', 'default', '2050', 'គណនីត្រូវសងផ្សេងៗ', '{"en":"Other payables"}'::jsonb, 'liability_current', false, null, 560),
  ('KH', 'default', '2060', 'ចំណូលពន្យារ', '{"en":"Deferred revenue"}'::jsonb, 'liability_current', false, null, 570),
  ('KH', 'default', '2070', 'ផ្នែកដល់កាលកំណត់នៃប្រាក់កម្ចីរយៈពេលវែង', '{"en":"Current portion of long-term loans"}'::jsonb, 'liability_current', false, null, 580),
  ('KH', 'default', '2080', 'សំវិធានធនធានាផលិតផល', '{"en":"Provision for product warranty"}'::jsonb, 'liability_current', false, null, 590),
  ('KH', 'default', '2090', 'អាករបង់ជាមុនលើការចែកភាគលាភត្រូវបង់', '{"en":"Advance tax on dividend distribution payable"}'::jsonb, 'liability_current', true, null, 600),
  ('KH', 'default', '2100', 'អាករលើតម្លៃបន្ថែមលើធាតុចេញ', '{"en":"Output value added tax"}'::jsonb, 'liability_current', false, null, 610),
  ('KH', 'default', '2110', 'អាករលើតម្លៃបន្ថែមត្រូវបង់', '{"en":"Value added tax payable"}'::jsonb, 'liability_current', true, null, 620),
  ('KH', 'default', '2130', 'ពន្ធគយត្រូវបង់', '{"en":"Import duty payable"}'::jsonb, 'liability_current', false, null, 630),
  ('KH', 'default', '2140', 'ពន្ធកាត់ទុកត្រូវបង់', '{"en":"Withholding tax payable"}'::jsonb, 'liability_current', true, null, 640),
  ('KH', 'default', '2150', 'ពន្ធលើប្រាក់ចំណូលត្រូវបង់', '{"en":"Tax on income payable"}'::jsonb, 'liability_current', false, null, 650),
  ('KH', 'default', '2160', 'ចំណែកមូលនិធិជាតិសន្តិសុខសង្គមត្រូវបង់', '{"en":"National Social Security Fund contributions payable"}'::jsonb, 'liability_current', false, null, 660),
  ('KH', 'default', '2170', 'មូលនិធិបុគ្គលិកផ្សេងៗត្រូវបង់', '{"en":"Other staff funds payable"}'::jsonb, 'liability_current', false, null, 670),
  ('KH', 'default', '2180', 'បំណុលពន្ធពន្យារ', '{"en":"Deferred tax liability"}'::jsonb, 'liability_current', false, null, 680),
  ('KH', 'default', '2195', 'ថ្លៃសវនកម្មត្រូវបង់', '{"en":"Accrued audit fee"}'::jsonb, 'liability_current', false, null, 690),
  ('KH', 'default', '2200', 'ប្រាក់កម្ចីរយៈពេលខ្លី', '{"en":"Short-term loans"}'::jsonb, 'liability_current', false, null, 700),
  ('KH', 'default', '2210', 'ចំណាយត្រូវបង់ផ្សេងៗ', '{"en":"Other accrued expenses"}'::jsonb, 'liability_current', false, null, 710),
  ('KH', 'default', '2220', 'ចំណូលសេវាពន្យារ', '{"en":"Deferred service revenue"}'::jsonb, 'liability_current', false, null, 720),
  ('KH', 'default', '2230', 'ភាគលាភត្រូវបង់', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 730),
  ('KH', 'default', '2240', 'មូលនិធិសុខុមាលភាពបុគ្គលិកត្រូវបង់', '{"en":"Employee welfare fund payable"}'::jsonb, 'liability_current', false, null, 740),
  ('KH', 'default', '2250', 'សំវិធានធនថ្ងៃឈប់សម្រាកបង្គរ', '{"en":"Provision for accumulated leave"}'::jsonb, 'liability_current', false, null, 750),
  ('KH', 'default', '2500', 'ប្រាក់កម្ចីរយៈពេលវែង', '{"en":"Long-term loans"}'::jsonb, 'liability_non_current', false, null, 800),
  ('KH', 'default', '2510', 'សញ្ញាបណ្ណត្រូវសង', '{"en":"Debentures payable"}'::jsonb, 'liability_non_current', false, null, 810),
  ('KH', 'default', '2520', 'បំណុលជួលហិរញ្ញវត្ថុ រយៈពេលវែង', '{"en":"Finance lease liability, non-current"}'::jsonb, 'liability_non_current', false, null, 820),
  ('KH', 'default', '2530', 'សំវិធានធនអត្ថប្រយោជន៍ឈប់ធ្វើការរបស់បុគ្គលិក', '{"en":"Provision for employee termination benefits"}'::jsonb, 'liability_non_current', false, null, 830),
  ('KH', 'default', '2540', 'ចំណូលពន្យារ រយៈពេលវែង', '{"en":"Deferred revenue, non-current"}'::jsonb, 'liability_non_current', false, null, 840),
  ('KH', 'default', '2900', 'ត្រូវសងនាយក', '{"en":"Due to directors"}'::jsonb, 'liability_current', false, null, 760),
  ('KH', 'default', '2910', 'ត្រូវសងក្រុមហ៊ុនសម្ព័ន្ធ', '{"en":"Due to affiliated companies"}'::jsonb, 'liability_current', false, null, 770),
  ('KH', 'default', '2920', 'ត្រូវសងម្ចាស់ភាគហ៊ុន', '{"en":"Due to shareholders"}'::jsonb, 'liability_current', false, null, 780),
  ('KH', 'default', '2990', 'គណនីព្យួរ', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 790),
  ('KH', 'default', '3000', 'ដើមទុនបានចុះបញ្ជី និងបានបង់', '{"en":"Registered and paid-up share capital"}'::jsonb, 'equity', false, null, 850),
  ('KH', 'default', '3050', 'ដើមទុនបានចុះបញ្ជីមិនទាន់បង់', '{"en":"Subscribed share capital not yet paid"}'::jsonb, 'equity', false, '3000', 860),
  ('KH', 'default', '3100', 'បុព្វលាភភាគហ៊ុន', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 870),
  ('KH', 'default', '3110', 'ទុនបម្រុងតាមច្បាប់', '{"en":"Legal reserve"}'::jsonb, 'equity', false, null, 880),
  ('KH', 'default', '3200', 'លទ្ធផលរក្សាទុក', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 890),
  ('KH', 'default', '3210', 'ភាគលាភបានបង់', '{"en":"Dividends paid"}'::jsonb, 'equity_retained', false, null, 900),
  ('KH', 'default', '4000', 'ចំណូលលក់ទំនិញក្នុងស្រុក', '{"en":"Domestic sales revenue"}'::jsonb, 'income', false, null, 910),
  ('KH', 'default', '4010', 'ចំណូលសេវាក្នុងស្រុក', '{"en":"Domestic service revenue"}'::jsonb, 'income', false, null, 920),
  ('KH', 'default', '4020', 'ចំណូលលក់ទំនិញនាំចេញ', '{"en":"Export sales revenue"}'::jsonb, 'income', false, null, 930),
  ('KH', 'default', '4030', 'ចំណូលសេវាជូនអតិថិជនបរទេស', '{"en":"Revenue from services to a foreign customer"}'::jsonb, 'income', false, null, 940),
  ('KH', 'default', '4040', 'ចំណូលសេវាផ្សេងៗ', '{"en":"Other service revenue"}'::jsonb, 'income', false, null, 950),
  ('KH', 'default', '4050', 'ចំណូលតម្លើង និងថែទាំ', '{"en":"Installation and maintenance revenue"}'::jsonb, 'income', false, null, 960),
  ('KH', 'default', '4060', 'ចំណូលលក់ទៅភាគីពាក់ព័ន្ធ', '{"en":"Sales revenue from related parties"}'::jsonb, 'income', false, null, 970),
  ('KH', 'default', '4090', 'ការបញ្ចុះតម្លៃលក់', '{"en":"Sales discounts"}'::jsonb, 'income', false, null, 980),
  ('KH', 'default', '4500', 'ចំណូលជួល', '{"en":"Rental income"}'::jsonb, 'income', false, null, 990),
  ('KH', 'default', '4510', 'ចំណូលជួលឧបករណ៍', '{"en":"Equipment rental income"}'::jsonb, 'income', false, null, 1000),
  ('KH', 'default', '4700', 'ចំណេញពីអត្រាប្តូរប្រាក់', '{"en":"Foreign exchange gain"}'::jsonb, 'income_other', false, null, 1010),
  ('KH', 'default', '4710', 'ចំណូលការប្រាក់', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 1020),
  ('KH', 'default', '4720', 'ចំណូលភាគលាភ', '{"en":"Dividend income"}'::jsonb, 'income_other', false, null, 1030),
  ('KH', 'default', '4750', 'ចំណេញពីការលក់ទ្រព្យសកម្មអចិន្ត្រៃយ៍', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 1040),
  ('KH', 'default', '4760', 'ចំណេញពីការបំប្លែងរបាយការណ៍ហិរញ្ញវត្ថុ', '{"en":"Gain on translation of financial statements"}'::jsonb, 'income_other', false, null, 1050),
  ('KH', 'default', '4770', 'ចំណូលពីសំណងធានារ៉ាប់រង', '{"en":"Insurance claim income"}'::jsonb, 'income_other', false, null, 1060),
  ('KH', 'default', '4800', 'ការត្រឡប់សំវិធានធនគណនីត្រូវទទួលមិនប្រាកដ', '{"en":"Reversal of allowance for doubtful accounts"}'::jsonb, 'income_other', false, null, 1070),
  ('KH', 'default', '4900', 'ចំណូលផ្សេងៗ', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 1080),
  ('KH', 'default', '5000', 'ថ្លៃដើមទំនិញលក់', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 1090),
  ('KH', 'default', '5010', 'ថ្លៃដឹកជញ្ជូនចូល', '{"en":"Freight in"}'::jsonb, 'expense_direct_cost', false, null, 1100),
  ('KH', 'default', '5020', 'ពលកម្មផ្ទាល់', '{"en":"Direct labour"}'::jsonb, 'expense_direct_cost', false, null, 1110),
  ('KH', 'default', '5030', 'ចំណាយទូទៅផលិតកម្ម', '{"en":"Manufacturing overhead"}'::jsonb, 'expense_direct_cost', false, null, 1120),
  ('KH', 'default', '5040', 'ពន្ធគយលើទំនិញទិញ', '{"en":"Import duty on goods purchased"}'::jsonb, 'expense_direct_cost', false, null, 1130),
  ('KH', 'default', '5050', 'ការខាតពីការបន្ថយតម្លៃសន្និធិ', '{"en":"Loss on write-down of inventory"}'::jsonb, 'expense_direct_cost', false, null, 1140),
  ('KH', 'default', '6000', 'ប្រាក់ខែ និងប្រាក់ឈ្នួល', '{"en":"Salaries and wages"}'::jsonb, 'expense', false, null, 1150),
  ('KH', 'default', '6001', 'ប្រាក់ធ្វើការថែមម៉ោង', '{"en":"Overtime pay"}'::jsonb, 'expense', false, null, 1160),
  ('KH', 'default', '6005', 'ប្រាក់រង្វាន់បុគ្គលិក', '{"en":"Employee bonus"}'::jsonb, 'expense', false, null, 1170),
  ('KH', 'default', '6010', 'ចំណែកមូលនិធិជាតិសន្តិសុខសង្គម (និយោជក)', '{"en":"National Social Security Fund contributions (employer)"}'::jsonb, 'expense', false, null, 1180),
  ('KH', 'default', '6015', 'ការបណ្តុះបណ្តាលបុគ្គលិក', '{"en":"Staff training"}'::jsonb, 'expense', false, null, 1190),
  ('KH', 'default', '6020', 'ចំណែកមូលនិធិបុគ្គលិកផ្សេងៗ (និយោជក)', '{"en":"Other staff fund contributions (employer)"}'::jsonb, 'expense', false, null, 1200),
  ('KH', 'default', '6025', 'ឯកសណ្ឋានបុគ្គលិក', '{"en":"Staff uniforms"}'::jsonb, 'expense', false, null, 1210),
  ('KH', 'default', '6030', 'ចំណាយជ្រើសរើសបុគ្គលិក', '{"en":"Recruitment expenses"}'::jsonb, 'expense', false, null, 1220),
  ('KH', 'default', '6040', 'ធានារ៉ាប់រងសុខភាពបុគ្គលិក', '{"en":"Staff health insurance"}'::jsonb, 'expense', false, null, 1230),
  ('KH', 'default', '6050', 'សុខុមាលភាពបុគ្គលិក', '{"en":"Staff welfare"}'::jsonb, 'expense', false, null, 1240),
  ('KH', 'default', '6060', 'ធានារ៉ាប់រងអាយុជីវិត និងគ្រោះថ្នាក់បុគ្គលិក', '{"en":"Staff life and accident insurance"}'::jsonb, 'expense', false, null, 1250),
  ('KH', 'default', '6100', 'ថ្លៃជួលការិយាល័យ', '{"en":"Office rent"}'::jsonb, 'expense', false, null, 1260),
  ('KH', 'default', '6110', 'ថ្លៃទឹក ភ្លើង', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 1270),
  ('KH', 'default', '6120', 'ថ្លៃទូរសព្ទ និងអ៊ីនធឺណិត', '{"en":"Telephone and internet"}'::jsonb, 'expense', false, null, 1280),
  ('KH', 'default', '6130', 'ចំណាយដឹកជញ្ជូន និងធ្វើដំណើរ', '{"en":"Transport and travel expenses"}'::jsonb, 'expense', false, null, 1290),
  ('KH', 'default', '6140', 'ចំណាយប្រេងឥន្ធនៈ និងយានយន្ត', '{"en":"Fuel and vehicle expenses"}'::jsonb, 'expense', false, null, 1300),
  ('KH', 'default', '6150', 'ថ្លៃចំណត និងថ្លៃផ្លូវ', '{"en":"Parking and toll fees"}'::jsonb, 'expense', false, null, 1310),
  ('KH', 'default', '6160', 'ថ្លៃប្រៃសណីយ៍ និងសេវាដឹកជញ្ជូនឯកសារ', '{"en":"Postage and courier"}'::jsonb, 'expense', false, null, 1320),
  ('KH', 'default', '6170', 'ក្រដាស និងទម្រង់បោះពុម្ព', '{"en":"Stationery and printed forms"}'::jsonb, 'expense', false, null, 1330),
  ('KH', 'default', '6180', 'ថ្លៃសមាជិកភាព និងសមាគម', '{"en":"Membership and association fees"}'::jsonb, 'expense', false, null, 1340),
  ('KH', 'default', '6190', 'ថ្លៃជាវកម្មវិធីក្នុងស្រុក', '{"en":"Domestic software subscription"}'::jsonb, 'expense', false, null, 1350),
  ('KH', 'default', '6200', 'ថ្លៃសេវាធនាគារ', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 1360),
  ('KH', 'default', '6210', 'ថ្លៃពិគ្រោះយោបល់ និងសេវាវិជ្ជាជីវៈក្នុងស្រុក', '{"en":"Domestic consultancy and professional fees"}'::jsonb, 'expense', false, null, 1370),
  ('KH', 'default', '6220', 'ការផ្សព្វផ្សាយ និងលើកកម្ពស់ការលក់', '{"en":"Advertising and promotion"}'::jsonb, 'expense', false, null, 1380),
  ('KH', 'default', '6230', 'ការជួសជុល និងថែទាំ', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 1390),
  ('KH', 'default', '6240', 'ចំណាយទទួលភ្ញៀវ', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 1400),
  ('KH', 'default', '6250', 'សម្ភារៈការិយាល័យ', '{"en":"Office supplies"}'::jsonb, 'expense', false, null, 1410),
  ('KH', 'default', '6260', 'ថ្លៃសេវាច្បាប់ក្នុងស្រុក', '{"en":"Domestic legal fees"}'::jsonb, 'expense', false, null, 1420),
  ('KH', 'default', '6270', 'ថ្លៃសវនកម្ម', '{"en":"Audit fees"}'::jsonb, 'expense', false, null, 1430),
  ('KH', 'default', '6280', 'ថ្លៃបកប្រែ និងបញ្ជាក់ឯកសារ', '{"en":"Translation and notarisation fees"}'::jsonb, 'expense', false, null, 1440),
  ('KH', 'default', '6290', 'ថ្លៃឯកសារនាំចូល និងនាំចេញ', '{"en":"Import and export documentation fees"}'::jsonb, 'expense', false, null, 1450),
  ('KH', 'default', '6300', 'ធានារ៉ាប់រង', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 1460),
  ('KH', 'default', '6310', 'អាករលើអចលនវត្ថុ', '{"en":"Tax on immovable property"}'::jsonb, 'expense', false, null, 1470),
  ('KH', 'default', '6320', 'អាករលើបណ្ណសញ្ញា', '{"en":"Signboard tax"}'::jsonb, 'expense', false, null, 1480),
  ('KH', 'default', '6330', 'អាករលើមធ្យោបាយដឹកជញ្ជូន', '{"en":"Tax on means of transportation"}'::jsonb, 'expense', false, null, 1490),
  ('KH', 'default', '6340', 'ការបរិច្ចាគ', '{"en":"Donations"}'::jsonb, 'expense', false, null, 1500),
  ('KH', 'default', '6350', 'កម្មវិធី និងសេវាឌីជីថលពីបរទេស', '{"en":"Foreign software and digital services"}'::jsonb, 'expense', false, null, 1510),
  ('KH', 'default', '6360', 'ថ្លៃសេវាអ្នកផ្គត់ផ្គង់តូចមិនបានចុះបញ្ជីអាករលើតម្លៃបន្ថែម', '{"en":"Fees paid to a small supplier not registered for value added tax"}'::jsonb, 'expense', false, null, 1520),
  ('KH', 'default', '6370', 'ថ្លៃផ្ទេរប្រាក់អន្តរជាតិ', '{"en":"International funds transfer fees"}'::jsonb, 'expense', false, null, 1530),
  ('KH', 'default', '6380', 'ភាពខុសគ្នានៃប្រតិបត្តិការប្តូរប្រាក់', '{"en":"Foreign exchange transaction differences"}'::jsonb, 'expense', false, null, 1540),
  ('KH', 'default', '6390', 'ថ្លៃសេវាកាតឥណទានរបស់អ្នកលក់', '{"en":"Credit card merchant fees"}'::jsonb, 'expense', false, null, 1550),
  ('KH', 'default', '6400', 'ថ្លៃប្រជុំនាយក', '{"en":"Directors'' meeting fees"}'::jsonb, 'expense', false, null, 1560),
  ('KH', 'default', '6410', 'បំណុលអាក្រក់លុបចោលដោយផ្ទាល់', '{"en":"Bad debts written off directly"}'::jsonb, 'expense', false, null, 1570),
  ('KH', 'default', '6420', 'ការខាតពីការលក់សន្និធិ', '{"en":"Loss on disposal of inventory"}'::jsonb, 'expense', false, null, 1580),
  ('KH', 'default', '6430', 'ការខាតបង់ពីគ្រោះមហន្តរាយធម្មជាតិ', '{"en":"Loss from natural disaster"}'::jsonb, 'expense', false, null, 1590),
  ('KH', 'default', '6440', 'ទណ្ឌកម្ម និងប្រាក់ពិន័យពន្ធ', '{"en":"Tax penalties and surcharges"}'::jsonb, 'expense', false, null, 1600),
  ('KH', 'default', '6450', 'ចំណាយផ្សេងៗ', '{"en":"Miscellaneous expenses"}'::jsonb, 'expense', false, null, 1610),
  ('KH', 'default', '6900', 'ចំណាយបំណុលអាក្រក់', '{"en":"Bad debt expense"}'::jsonb, 'expense', false, null, 1620),
  ('KH', 'default', '6950', 'ការខាតពីអត្រាប្តូរប្រាក់', '{"en":"Foreign exchange loss"}'::jsonb, 'expense', false, null, 1630),
  ('KH', 'default', '6960', 'ការខាតពីការលក់ទ្រព្យសកម្មអចិន្ត្រៃយ៍', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1640),
  ('KH', 'default', '6970', 'រំលស់', '{"en":"Depreciation"}'::jsonb, 'expense_depreciation', false, null, 1650),
  ('KH', 'default', '6975', 'ការធ្លាក់ថ្លៃទ្រព្យសកម្មអរូបី', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, null, 1660),
  ('KH', 'default', '6990', 'ភាពខុសគ្នាពីការបង្គត់', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1670),
  ('KH', 'default', '7000', 'ចំណាយការប្រាក់', '{"en":"Interest expense"}'::jsonb, 'expense', false, null, 1680),
  ('KH', 'default', '7010', 'ចំណាយការប្រាក់លើការជួលហិរញ្ញវត្ថុ', '{"en":"Interest expense on finance leases"}'::jsonb, 'expense', false, null, 1690),
  ('KH', 'default', '7020', 'ថ្លៃរៀបចំប្រាក់កម្ចី', '{"en":"Loan arrangement fees"}'::jsonb, 'expense', false, null, 1700),
  ('KH', 'default', '7030', 'ការខាតពីការសងប្រាក់កម្ចីមុនកាលកំណត់', '{"en":"Loss on early repayment of a loan"}'::jsonb, 'expense', false, null, 1710),
  ('KH', 'default', '8000', 'ពន្ធលើប្រាក់ចំណូល', '{"en":"Tax on income"}'::jsonb, 'expense', false, null, 1720),
  ('KH', 'default', '8010', 'ចំណាយពន្ធពន្យារ', '{"en":"Deferred tax expense"}'::jsonb, 'expense', false, null, 1730)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KH', 'BNK', 'សៀវភៅកំណត់ត្រាធនាគារ', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('KH', 'CSH', 'សៀវភៅកំណត់ត្រាសាច់ប្រាក់តូចតាច', '{"en":"Petty cash journal"}'::jsonb, 'cash', 40),
  ('KH', 'GEN', 'សៀវភៅកំណត់ត្រាទូទៅ', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('KH', 'OPN', 'កំណត់ត្រាសមតុល្យដើមគ្រា', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('KH', 'PUR', 'សៀវភៅកំណត់ត្រាការទិញ', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('KH', 'SAL', 'សៀវភៅកំណត់ត្រាការលក់', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('KH', 'KH-P-EX', 'ទិញ គ្មានអាករលើតម្លៃបន្ថែម (លើកលែង ឬអ្នកផ្គត់ផ្គង់មិនបានចុះបញ្ជី)', '{"en":"Purchase, no value added tax (exempt or unregistered supplier)"}'::jsonb, 'ការទិញដែលមិនមានអាករលើតម្លៃបន្ថែមអាចកាត់កងបាន', 'percent', 0, 'purchase', 'exempt', date '2024-03-11', null, 'A purchase carrying no value added tax: an exempt supply, or a supplier who is not registered (article 4 requires registration only of a person who has become a taxable person under article 77 of the Law on Taxation). Nothing is deducted, so no box and no account but the expense.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gdt-vat-subdecree', null, null, null, null),
  ('KH', 'KH-P-RC', 'សេវាទិញពីអ្នកមិនមែនអ្នកស្នាក់នៅ អាករគណនាដោយអ្នកទទួលសេវា', '{"en":"Service bought from a non-resident, value added tax self-assessed by the recipient"}'::jsonb, 'សេវាដែលផ្គត់ផ្គង់ដោយអ្នកមិនស្នាក់នៅ ហើយអ្នកទទួលដែលជាអ្នកជាប់អាករត្រូវគិតអាករជំនួស', 'percent', 10, 'purchase', 'foreign_services_received', date '2024-03-11', null, 'Sub-Decree 49 (2024), article 23(3), read directly: for a service supplied in Cambodia by a non-resident, the taxable person who receives it is to account for the tax in place of the supplier and pay it to the tax administration (a non-resident supplier with no establishment in Cambodia). Article 3(12) defines this ''reverse charge''. This code posts the tax on both the output and the input accounts in the same period (net nil) and does not model the period or the conditions of the credit, which were not read.', null, null, 60, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'gdt-vat-subdecree', null, null, null, null),
  ('KH', 'KH-P-STD', 'ទិញ អាករលើតម្លៃបន្ថែមអត្រា ១០% កាត់កងបាន', '{"en":"Purchase, standard rate 10 %, input tax creditable"}'::jsonb, 'ការទិញទំនិញ ឬសេវាដែលបង់អាករក្នុងស្រុក ហើយអាចកាត់កងឥណទានអាករលើធាតុចូលបាន', 'percent', 10, 'purchase', 'domestic', date '2024-03-11', null, 'Sub-Decree 49 (2024), articles 11 and 19, read directly: a registered taxpayer may deduct the input tax paid on goods and services bought to carry out taxable supplies, on presentation of the original tax invoice. This code assumes the purchase is deductible in full. Article 13 excludes accommodation, meals and entertainment, passenger vehicles of up to ten seats (unless the taxpayer sells or hires them) and petroleum products (unless the taxpayer sells them); a purchase falling there is not carried by a code of this pack (see README). Article 15 prorates the credit of a taxpayer who makes both taxable and non-taxable supplies; the pack does not.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gdt-vat-subdecree', null, null, null, null),
  ('KH', 'KH-S-EX', 'លក់ ត្រូវបានលើកលែងអាករលើតម្លៃបន្ថែម', '{"en":"Sale, exempt from value added tax"}'::jsonb, 'ការផ្គត់ផ្គង់ដែលច្បាប់លើកលែងអាករលើតម្លៃបន្ថែម', 'percent', 0, 'sale', 'exempt', date '2024-03-11', null, 'Sub-Decree 49 (2024), article 29(1), read directly, has the taxpayer keep records of exempt supplies apart from those taxed at 10 % and 0 %, which confirms that an exempt category exists. The list of exempt supplies is in the Law on Taxation, which was not read, so this code names none: the user chooses it only for a supply they know to be exempt. It carries no box: nothing read shows the return asking for the value of an exempt supply.', 'E', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'gdt-vat-subdecree', null, null, null, null),
  ('KH', 'KH-S-STD', 'លក់ អាករលើតម្លៃបន្ថែមអត្រា ១០%', '{"en":"Sale, standard rate, value added tax 10 %"}'::jsonb, 'ការផ្គត់ផ្គង់ទំនិញ ឬសេវាក្នុងព្រះរាជាណាចក្រកម្ពុជា', 'percent', 10, 'sale', 'domestic', date '2024-03-11', null, 'Sub-Decree 49 (2024) on the Value Added Tax, article 30(2), read directly: the rate for a sale to a consumer is 10 %, and the tax on a tax-inclusive price is 1/11 of it. Article 30(1)(b) takes the same rate for a sale made without an invoice. The sub-decree implements the Law on Taxation of 16 May 2023, which fixes the rate itself; that text is a scanned document in Khmer and was not read, so the rate here rests on the sub-decree alone.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'gdt-vat-subdecree', null, null, null, null),
  ('KH', 'KH-S-ZR-EXP', 'លក់នាំចេញ អត្រា ០%', '{"en":"Export sale, zero rate"}'::jsonb, 'ការនាំចេញទំនិញ ឬសេវាដែលត្រូវបង់អាករក្នុងអត្រា ០%', 'percent', 0, 'sale', 'export', date '2024-03-11', null, 'Sub-Decree 49 (2024), article 29(1)(e), read directly, names sales exported at 0 % and the records that support them: the export declaration, the invoice issued to the foreign buyer, the transport documents, the sales order or contract with the foreign buyer, and proof of payment through a bank registered in Cambodia. Which supplies qualify (goods exported, and which services) is set by the Law on Taxation, which was not read; this code is for a supply the user knows to be zero-rated, and carries `conditions` for the facts the ledger does not hold.', 'G', null, 20, 'vat', true, array['transport_evidence', 'buyer_status']::tax_condition[], null, false, false, null, 'gdt-vat-subdecree', null, null, null, null)
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
    ('KH-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KH-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KH-P-RC', 'invoice', 'base', 100, null, 'RC', array['RC']::text[], 100, 'KH-VAT', 10),
    ('KH-P-RC', 'invoice', 'tax', -100, '2100', 'OT', array['OT']::text[], 100, 'KH-VAT', 20),
    ('KH-P-RC', 'invoice', 'tax', 100, '1150', 'IT', array['IT']::text[], 100, 'KH-VAT', 30),
    ('KH-P-RC', 'credit_note', 'base', 100, null, 'RC', array['RC']::text[], -100, 'KH-VAT', 10),
    ('KH-P-RC', 'credit_note', 'tax', -100, '2100', 'OT', array['OT']::text[], -100, 'KH-VAT', 20),
    ('KH-P-RC', 'credit_note', 'tax', 100, '1150', 'IT', array['IT']::text[], -100, 'KH-VAT', 30),
    ('KH-P-STD', 'invoice', 'base', 100, null, 'PB', array['PB']::text[], 100, 'KH-VAT', 10),
    ('KH-P-STD', 'invoice', 'tax', 100, '1150', 'IT', array['IT']::text[], 100, 'KH-VAT', 20),
    ('KH-P-STD', 'credit_note', 'base', 100, null, 'PB', array['PB']::text[], -100, 'KH-VAT', 10),
    ('KH-P-STD', 'credit_note', 'tax', 100, '1150', 'IT', array['IT']::text[], -100, 'KH-VAT', 20),
    ('KH-S-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KH-S-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KH-S-STD', 'invoice', 'base', 100, null, 'SB', array['SB']::text[], 100, 'KH-VAT', 10),
    ('KH-S-STD', 'invoice', 'tax', 100, '2100', 'OT', array['OT']::text[], 100, 'KH-VAT', 20),
    ('KH-S-STD', 'credit_note', 'base', 100, null, 'SB', array['SB']::text[], -100, 'KH-VAT', 10),
    ('KH-S-STD', 'credit_note', 'tax', 100, '2100', 'OT', array['OT']::text[], -100, 'KH-VAT', 20),
    ('KH-S-ZR-EXP', 'invoice', 'base', 100, null, 'SZ', array['SZ']::text[], 100, 'KH-VAT', 10),
    ('KH-S-ZR-EXP', 'credit_note', 'base', 100, null, 'SZ', array['SZ']::text[], -100, 'KH-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KH' and t.code = v.tax_code
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
  ('KH', 'KH-VAT', 'ការប្រកាសអាករលើតម្លៃបន្ថែមប្រចាំខែ', array['month']::declaration_period[], 'month'::declaration_period, date '2024-03-11', null, 'Sub-Decree 49 (2024) on the Value Added Tax, article 29(1)(a) (a monthly VAT account), and the General Department of Taxation''s home page, read on 2026-10-21, which lists for the period September 2026 a due date of 20 October for a manual return and 25 October for an online one (''Upcoming due date of monthly-annual tax return''). The boxes below are this pack''s own short codes for the mechanics the sub-decree confirms — a base and an output tax on taxable sales, a base for zero-rated sales, a base and an input tax on purchases, and the net — and do not claim to reproduce the numbering or the Khmer wording of the form of the e-filing portal, which could not be read.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'General Department of Taxation, home page, read on 2026-10-21: for the period September 2026 it displays the due date ''20 October'' for a manual return and ''25 October'' for an online one. This pack declares the 20th, the earlier of the two; a taxpayer filing online has until the 25th by the same page. The provision of the law behind the dates was not read.', 'gdt-portal', null)
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
  ('KH', 'KH-VAT', 'SB', 'base', 'តម្លៃលក់ដែលត្រូវបង់អាករលើតម្លៃបន្ថែមអត្រា ១០% (មិនរួមអាករលើតម្លៃបន្ថែម)', '{"en":"Value of standard-rated sales (without value added tax)"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value, without value added tax, of a sale taxed at the rate of 10 %: Sub-Decree 49 (2024), article 30(2), reads the rate for a sale to a consumer as 10 %, the tax being 1/11 of the tax-inclusive price — see KH-S-STD.', 'gdt-vat-subdecree'),
  ('KH', 'KH-VAT', 'SZ', 'base', 'តម្លៃលក់ក្នុងអត្រា ០% (នាំចេញ)', '{"en":"Value of zero-rated sales (exports)"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of a sale taxed at 0 %. Sub-Decree 49 (2024), article 29(1)(e), has the taxpayer keep records of sales exported at 0 % with the export declaration and the invoice issued to the foreign buyer — see KH-S-ZR-EXP.', 'gdt-vat-subdecree'),
  ('KH', 'KH-VAT', 'OT', 'tax', 'អាករលើតម្លៃបន្ថែមលើធាតុចេញ', '{"en":"Output tax"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value added tax charged on box SB, and the tax the recipient of a service from a non-resident supplier accounts for under article 23(3) — see KH-S-STD and KH-P-RC.', 'gdt-vat-subdecree'),
  ('KH', 'KH-VAT', 'PB', 'base', 'តម្លៃទិញដែលមានសិទ្ធិកាត់កងឥណទានអាករលើធាតុចូល (មិនរួមអាករលើតម្លៃបន្ថែម)', '{"en":"Value of purchases entitled to input tax credit (without value added tax)"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value, without value added tax, of a purchase whose input tax credit this pack takes as fully deductible: article 11 grants the credit on tax paid on goods and services bought to carry out taxable supplies, article 19 asks for the original tax invoice — see KH-P-STD.', 'gdt-vat-subdecree'),
  ('KH', 'KH-VAT', 'RC', 'base', 'តម្លៃសេវាទិញពីអ្នកមិនមែនជាអ្នកស្នាក់នៅ ដែលអាករត្រូវគណនាដោយអ្នកទទួលសេវា', '{"en":"Value of services bought from a non-resident, tax self-assessed"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of a service bought from a non-resident supplier, reported apart from box PB because the tax reaches the return through the recipient''s own accounting under article 23(3) and not through a tax invoice of the supplier — see KH-P-RC.', 'gdt-vat-subdecree'),
  ('KH', 'KH-VAT', 'IT', 'tax', 'ឥណទានអាករលើធាតុចូល', '{"en":"Input tax"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The input tax of box PB and the tax self-assessed on box RC. This pack claims the self-assessed credit in the period it is assessed, a simplification named in the README.', 'gdt-vat-subdecree'),
  ('KH', 'KH-VAT', 'NET', 'total', 'អាករលើតម្លៃបន្ថែមត្រូវបង់ ឬឥណទានលើស (យកទៅបន្ត ឬសំណង)', '{"en":"Value added tax payable, or excess credit (carried forward or refundable)"}'::jsonb, 70, null, array['OT']::text[], array['IT']::text[], null, null, false, false, null, 'Output tax less input tax for the period. Article 29(1)(a) has the taxpayer keep a monthly VAT account showing total output tax, total input tax, and the tax payable or the excess credit carried forward or refunded; article 20 lets an excess credit be refunded under conditions the Minister sets. A negative figure is kept as it is: what it becomes (carry forward, refund) is not modelled beyond the figure.', 'gdt-vat-subdecree')
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
  ('KH-BS', 'KH', 'default', 'តារាងតុល្យការ', 'balance_sheet', 'KH-ORIGINAL', date '1970-01-01', null, 'Cambodia''s Law on Accounting and Auditing (NS/RKM/4016/006, 11 April 2016, listed on the General Department of Taxation''s site; its text was not readable from here) requires an enterprise to keep accounts and prepare financial statements, and no line item of a Cambodian statement could be read. This statement is original: it groups this chart''s own accounts by the code ranges accounts.csv gives them, current and non-current, revenue and cost of sales, operating expenses and depreciation, without transcribing a standard''s own line items or their numbering.', null, 'alone', null, '{}'::jsonb),
  ('KH-IS', 'KH', 'default', 'របាយការណ៍លទ្ធផល', 'income_statement', 'KH-ORIGINAL', date '1970-01-01', null, 'Cambodia''s Law on Accounting and Auditing (NS/RKM/4016/006, 11 April 2016, listed on the General Department of Taxation''s site; its text was not readable from here) requires an enterprise to keep accounts and prepare financial statements, and no line item of a Cambodian statement could be read. This statement is original: it groups this chart''s own accounts by the code ranges accounts.csv gives them, current and non-current, revenue and cost of sales, operating expenses and depreciation, without transcribing a standard''s own line items or their numbering.', null, null, null, '{}'::jsonb)
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
  ('KH-BS', 'A-C-CASH', 'A-C', 'សាច់ប្រាក់ និងសាច់ប្រាក់សមមូល', '{"en":"Cash and cash equivalents"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-C-REC', 'A-C', 'គណនីត្រូវទទួលពីអតិថិជន', '{"en":"Trade receivables"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-C-OTH', 'A-C', 'អាករលើធាតុចូល គណនីត្រូវទទួលផ្សេងៗ និងសន្និធិ', '{"en":"Input value added tax, other receivables and inventory"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-C-PREP', 'A-C', 'ចំណាយបង់ជាមុន និងប្រាក់កក់បានបង់', '{"en":"Prepaid expenses and deposits paid"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-C', null, 'ទ្រព្យសកម្មចរន្ត', '{"en":"Current assets"}'::jsonb, 50, 1, true, array['A-C-CASH', 'A-C-REC', 'A-C-OTH', 'A-C-PREP']::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-NC-FIX', 'A-NC', 'ដីធ្លី អគារ និងបរិក្ខារ (ដករំលស់បង្គរ)', '{"en":"Property, plant and equipment (net of accumulated depreciation)"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-NC-OTH', 'A-NC', 'ទ្រព្យសកម្មអរូបី និងទ្រព្យសកម្មមិនចរន្តផ្សេងៗ', '{"en":"Intangible assets and other non-current assets"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-NC', null, 'ទ្រព្យសកម្មមិនចរន្ត', '{"en":"Non-current assets"}'::jsonb, 80, 1, true, array['A-NC-FIX', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'A-TOT', null, 'ទ្រព្យសកម្មសរុប', '{"en":"Total assets"}'::jsonb, 90, 1, true, array['A-C', 'A-NC']::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'L-C-PAY', 'L-C', 'គណនីត្រូវសងអ្នកផ្គត់ផ្គង់', '{"en":"Trade payables"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'L-C-OTH', 'L-C', 'អាករលើធាតុចេញ ពន្ធត្រូវបង់ គណនីត្រូវសងផ្សេងៗ និងបំណុលចរន្តផ្សេងៗ', '{"en":"Output value added tax, tax payables, other payables and other current liabilities"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'L-C', null, 'បំណុលចរន្ត', '{"en":"Current liabilities"}'::jsonb, 120, 1, true, array['L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'L-NC', 'L-TOT', 'បំណុលមិនចរន្ត', '{"en":"Non-current liabilities"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'L-TOT', null, 'បំណុលសរុប', '{"en":"Total liabilities"}'::jsonb, 140, 1, true, array['L-C', 'L-NC']::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'E-CAP', 'E-TOT', 'ដើមទុនបានចុះបញ្ជី និងបានបង់ និងបុព្វលាភភាគហ៊ុន', '{"en":"Registered and paid-up share capital, and share premium"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'E-RET', 'E-TOT', 'លទ្ធផលរក្សាទុក', '{"en":"Retained earnings"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'E-RESULT', 'E-TOT', 'លទ្ធផលនៃគ្រា មិនទាន់បែងចែក', '{"en":"Result for the period, not yet allocated"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'E-TOT', null, 'មូលធនសរុប', '{"en":"Total equity"}'::jsonb, 180, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('KH-BS', 'EL-TOT', null, 'បំណុល និងមូលធនសរុប', '{"en":"Total liabilities and equity"}'::jsonb, 190, 1, true, array['L-TOT', 'E-TOT']::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'REV', null, 'ចំណូល', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'COST', null, 'ថ្លៃដើមលក់', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'GROSS', null, 'ប្រាក់ចំណេញដុល', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('KH-IS', 'OTH-INC', null, 'ចំណូលផ្សេងៗ', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'OPEX', null, 'ចំណាយលក់ រដ្ឋបាល និងហិរញ្ញវត្ថុ', '{"en":"Selling, administrative and finance expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'DEPR', null, 'រំលស់', '{"en":"Depreciation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'PRETAX', null, 'ប្រាក់ចំណេញមុនពន្ធលើប្រាក់ចំណូល', '{"en":"Profit before income tax"}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('KH-IS', 'TAX', null, 'ពន្ធលើប្រាក់ចំណូល', '{"en":"Corporate income tax"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KH-IS', 'PROFIT', null, 'ប្រាក់ចំណេញ (ខាតបង់) នៃគ្រា', '{"en":"Profit (loss) for the period"}'::jsonb, 90, 1, true, array['PRETAX']::text[], array['TAX']::text[], null, null, null)
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
 where r.statement_code in ('KH-BS', 'KH-IS')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('KH-BS', 'A-C-CASH', 10),
            ('KH-BS', 'A-C-REC', 10),
            ('KH-BS', 'A-C-OTH', 10),
            ('KH-BS', 'A-C-PREP', 10),
            ('KH-BS', 'A-NC-FIX', 10),
            ('KH-BS', 'A-NC-OTH', 10),
            ('KH-BS', 'L-C-PAY', 10),
            ('KH-BS', 'L-C-OTH', 10),
            ('KH-BS', 'L-C-OTH', 20),
            ('KH-BS', 'L-NC', 10),
            ('KH-BS', 'E-CAP', 10),
            ('KH-BS', 'E-RET', 10),
            ('KH-BS', 'E-RESULT', 10),
            ('KH-BS', 'E-RESULT', 20),
            ('KH-IS', 'REV', 10),
            ('KH-IS', 'COST', 10),
            ('KH-IS', 'OTH-INC', 10),
            ('KH-IS', 'OPEX', 10),
            ('KH-IS', 'OPEX', 20),
            ('KH-IS', 'DEPR', 10),
            ('KH-IS', 'TAX', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('KH-BS', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('KH-BS', 'A-C-REC', 10, 'code_range', '1100', '1119', null, 'any'),
    ('KH-BS', 'A-C-OTH', 10, 'code_range', '1120', '1299', null, 'any'),
    ('KH-BS', 'A-C-PREP', 10, 'code_range', '1300', '1399', null, 'any'),
    ('KH-BS', 'A-NC-FIX', 10, 'code_range', '1600', '1699', null, 'any'),
    ('KH-BS', 'A-NC-OTH', 10, 'code_range', '1700', '1799', null, 'any'),
    ('KH-BS', 'L-C-PAY', 10, 'code_range', '2000', '2009', null, 'any'),
    ('KH-BS', 'L-C-OTH', 10, 'code_range', '2010', '2499', null, 'any'),
    ('KH-BS', 'L-C-OTH', 20, 'code_range', '2900', '2999', null, 'any'),
    ('KH-BS', 'L-NC', 10, 'code_range', '2500', '2599', null, 'any'),
    ('KH-BS', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('KH-BS', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('KH-BS', 'E-RESULT', 10, 'code_range', '4000', '5999', null, 'any'),
    ('KH-BS', 'E-RESULT', 20, 'code_range', '6000', '8999', null, 'any'),
    ('KH-IS', 'REV', 10, 'code_range', '4000', '4599', null, 'any'),
    ('KH-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('KH-IS', 'OTH-INC', 10, 'code_range', '4700', '4999', null, 'any'),
    ('KH-IS', 'OPEX', 10, 'code_range', '6000', '6969', null, 'any'),
    ('KH-IS', 'OPEX', 20, 'code_range', '6980', '7099', null, 'any'),
    ('KH-IS', 'DEPR', 10, 'code_range', '6970', '6979', null, 'any'),
    ('KH-IS', 'TAX', 10, 'code_range', '8000', '8099', null, 'any')
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
  ('KH', 'កម្ពុជា', '{"en":"Cambodia"}'::jsonb, array['km', 'en']::text[], 'KHR', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'km', 'retained_earnings', null, null, null, 'OPN', default, default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Sub-Decree 49 (2024), article 21, read directly: a taxable person supplying goods or services issues a tax invoice to a buyer who is a registered taxable person and an ordinary invoice to one who is not; the buyer may require the invoice; the supplier keeps the original or a copy; and the form of the invoice is set by a prakas of the Minister of Economy and Finance, which was not read. The pattern is the one a business may choose, and `sequential` is the closest value; no rule of gapless numbering was read.',
  numbering_source_key          = 'gdt-vat-subdecree',
  payment_terms_legal_reference = 'No statute setting a payment term between businesses in the absence of an agreement was found; legal_payment_days and late_payment_reference are left null rather than guessed.',
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Sub-Decree 49 (2024), article 25(1)(a), read directly: a supply of goods or services takes place when the supplier is required to issue the invoice, or issues it if earlier; the invoice is due at the latest seven days after delivery of the goods or performance of the service, or after payment if payment comes first. `earliest_of_delivery_or_payment` is the closest of the format''s five values; the seven days of grace and the invoice itself as a trigger are a gap of the vocabulary, carried in docs/international.md.',
  tax_point_source_key          = 'gdt-vat-subdecree',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Sub-Decree 49 (2024) recites the Law on Electronic Commerce of 2 November 2019 (NS/RKM/1119/017) and refers to electronic transactions and to e-commerce VAT (article 3), and the General Department of Taxation runs e-filing and an e-Tax portal. This session could not read a text that obliges a taxpayer to issue an electronic invoice, nor a national profile. `obligation` is `none`, which states only that no statute obliging it was found, not that none exists — the first thing for a reviewer to check on the portal.',
  einvoice_source_key           = null,
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KH';

update country_defaults set
  tax_payee_name       = 'General Department of Taxation',
  tax_payee_source_key = 'gdt-portal'
 where country = 'KH';
