-- Ekwo OS — البحرين: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/bh at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build bh`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Legislative Decree No. (48) of 2018 Promulgating the Value Added Tax Law, Official Gazette No. 3387 of 6 October 2018 (Legislation and Legal Opinion Commission English rendering) (Legislation and Legal Opinion Commission (LLOC))
--     https://www.lloc.gov.bh/FullEn/L4818.docx
--   Law No. (33) of 2021 Amending Some Provisions of the Value Added Tax Law Promulgated by Legislative Decree No. (48) of 2018, Official Gazette No. 3572, issued 23 December 2021 — the increase of the standard rate from 5% to 10% (Legislation and Legal Opinion Commission (LLOC))
--     https://www.lloc.gov.bh/FullEn/K3321.docx
--   Resolution No. (12) of 2018 Issuing the Executive Regulations of the Value Added Tax Law (unofficial English translation) (National Bureau for Revenue — unofficial translation circulated by Grant Thornton Bahrain, no official NBR or LLOC English text of this Resolution could be opened by this pack's research)
--     https://www.grantthornton.bh/globalassets/1.-member-firms/uae/new-blocks/insights/executive-regulations-of-the-vat-law.pdf
--   Kingdom of Bahrain VAT General Guide, Version 1.13 (National Bureau for Revenue (NBR))
--     https://s3-me-south-1.amazonaws.com/nbrproduserdata-bh/media/SKcLyyq0ZSdlU2yvo1qBqgpsLECjzxfHnC9mG1dk.pdf
--   Value Added Tax — the National Bureau for Revenue's own VAT section, where a registrant files and pays (National Bureau for Revenue (NBR))
--     https://www.nbr.gov.bh/vat
--   IFRS Standards — Application Around the World, Jurisdictional Profile: Bahrain (profile last updated 16 June 2016) (IFRS Foundation)
--     https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/bahrain-ifrs-profile.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BH', 'البحرين', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, '3d8f760efc30968844302f60dad727d9df50943d7f029d00b2bcfedd11e18db7', '[{"key":"vat-law","title":"Legislative Decree No. (48) of 2018 Promulgating the Value Added Tax Law, Official Gazette No. 3387 of 6 October 2018 (Legislation and Legal Opinion Commission English rendering)","publisher":"Legislation and Legal Opinion Commission (LLOC)","url":"https://www.lloc.gov.bh/FullEn/L4818.docx","consulted_on":"2026-09-26","kind":"law"},{"key":"vat-amendment","title":"Law No. (33) of 2021 Amending Some Provisions of the Value Added Tax Law Promulgated by Legislative Decree No. (48) of 2018, Official Gazette No. 3572, issued 23 December 2021 — the increase of the standard rate from 5% to 10%","publisher":"Legislation and Legal Opinion Commission (LLOC)","url":"https://www.lloc.gov.bh/FullEn/K3321.docx","consulted_on":"2026-09-26","kind":"law"},{"key":"vat-exec-reg","title":"Resolution No. (12) of 2018 Issuing the Executive Regulations of the Value Added Tax Law (unofficial English translation)","publisher":"National Bureau for Revenue — unofficial translation circulated by Grant Thornton Bahrain, no official NBR or LLOC English text of this Resolution could be opened by this pack''s research","url":"https://www.grantthornton.bh/globalassets/1.-member-firms/uae/new-blocks/insights/executive-regulations-of-the-vat-law.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"vat-general-guide","title":"Kingdom of Bahrain VAT General Guide, Version 1.13","publisher":"National Bureau for Revenue (NBR)","url":"https://s3-me-south-1.amazonaws.com/nbrproduserdata-bh/media/SKcLyyq0ZSdlU2yvo1qBqgpsLECjzxfHnC9mG1dk.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"nbr-vat-portal","title":"Value Added Tax — the National Bureau for Revenue''s own VAT section, where a registrant files and pays","publisher":"National Bureau for Revenue (NBR)","url":"https://www.nbr.gov.bh/vat","consulted_on":"2026-09-26","kind":"portal"},{"key":"ifrs-profile","title":"IFRS Standards — Application Around the World, Jurisdictional Profile: Bahrain (profile last updated 16 June 2016)","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/bahrain-ifrs-profile.pdf","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('BH', 'default', 'الدليل المحاسبي المرجعي لمملكة البحرين', '{"en":"Bahrain reference chart of accounts"}'::jsonb, true, 'companies', array['BH-IFRSSME-IS', 'BH-IFRSSME-SFP']::text[], null, 'This pack''s research found no legally mandated chart of accounts for a Bahraini company. What the law prescribes is the reporting framework: Article 219 of the Commercial Companies Law (Legislative Decree No. 21 of 2001) conditions a clean audit opinion on financial statements ''prepared according to the international accounting standards or to the standards approved by the competent authority'', and the IFRS Foundation''s own Jurisdictional Profile records that Bahrain has adopted IFRS Accounting Standards and the IFRS for SMEs Standard, that there is no local GAAP, and that ''all SMEs are permitted to use the IFRS for SMEs Standard''. This pack''s research did not open a Ministry of Industry, Commerce and Tourism text naming a chart of accounts of its own, and none is known to exist alongside a framework requirement stated this way. The chart below is therefore this pack''s own construction, exactly as packs/ae and packs/sa build theirs on the same absence of a national numbering: four digits, blocked so that each range reaches one line item of the statement of financial position and the income statement below, carrying the accounts a Bahraini company actually keeps — VAT input and output tax apart from the net amount due to or from the National Bureau for Revenue, VAT deferred at import, and an end-of-service gratuity provision under the Labour Law for the Private Sector (Law No. 36 of 2012). A reviewer should check it against a real Bahraini company''s books before it is trusted.', 'ifrs-profile')
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
  ('BH', 'default', '1000', 'الصندوق', '{"en":"Petty cash"}'::jsonb, 'asset_cash', false, null, 10),
  ('BH', 'default', '1010', 'البنك - حساب جاري بالدينار البحريني', '{"en":"Bank current account — Bahraini dinar"}'::jsonb, 'asset_cash', false, null, 20),
  ('BH', 'default', '1015', 'البنك - حساب جاري بعملة أجنبية', '{"en":"Bank current account — foreign currency"}'::jsonb, 'asset_cash', false, null, 25),
  ('BH', 'default', '1020', 'البنك - ودائع لأجل لا تتجاوز ثلاثة أشهر', '{"en":"Bank fixed deposits of three months or less"}'::jsonb, 'asset_cash', false, null, 30),
  ('BH', 'default', '1030', 'شيكات تحت التحصيل', '{"en":"Cheques for collection"}'::jsonb, 'asset_cash', false, null, 40),
  ('BH', 'default', '1035', 'أموال في الطريق - تسويات بطاقات ووسائل الدفع الإلكترونية', '{"en":"Cash in transit — card and e-payment settlements"}'::jsonb, 'asset_cash', false, null, 45),
  ('BH', 'default', '1040', 'عهد نقدية مستديمة', '{"en":"Petty cash imprest"}'::jsonb, 'asset_cash', false, null, 50),
  ('BH', 'default', '1100', 'العملاء', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 60),
  ('BH', 'default', '1105', 'العملاء - مخصص الديون المشكوك في تحصيلها', '{"en":"Trade receivables — allowance for doubtful debts"}'::jsonb, 'asset_current', false, null, 65),
  ('BH', 'default', '1120', 'مدينون آخرون', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 70),
  ('BH', 'default', '1125', 'أرصدة مدينة لأطراف ذات علاقة', '{"en":"Amounts due from related parties"}'::jsonb, 'asset_current', false, null, 75),
  ('BH', 'default', '1130', 'عربون ودائع مدفوعة', '{"en":"Deposits paid"}'::jsonb, 'asset_current', false, null, 80),
  ('BH', 'default', '1135', 'سلف وقروض للعاملين', '{"en":"Advances and loans to employees"}'::jsonb, 'asset_current', false, null, 85),
  ('BH', 'default', '1150', 'ضريبة القيمة المضافة على المشتريات - مدخلات', '{"en":"VAT input tax"}'::jsonb, 'asset_current', false, null, 90),
  ('BH', 'default', '1155', 'رصيد مستحق من الجهاز الوطني للإيرادات - ضريبة القيمة المضافة', '{"en":"Amount receivable from the National Bureau for Revenue — VAT"}'::jsonb, 'asset_current', true, null, 95),
  ('BH', 'default', '1160', 'ضريبة القيمة المضافة المؤجلة عند الاستيراد', '{"en":"VAT deferred on import"}'::jsonb, 'asset_current', false, null, 100),
  ('BH', 'default', '1200', 'مخزون بضاعة معدة للبيع', '{"en":"Inventories — goods for resale"}'::jsonb, 'asset_current', false, null, 110),
  ('BH', 'default', '1210', 'مخزون خامات ومستلزمات إنتاج', '{"en":"Inventories — raw materials"}'::jsonb, 'asset_current', false, null, 115),
  ('BH', 'default', '1220', 'مخزون إنتاج تحت التشغيل', '{"en":"Inventories — work in progress"}'::jsonb, 'asset_current', false, null, 120),
  ('BH', 'default', '1230', 'مخزون إنتاج تام', '{"en":"Inventories — finished goods"}'::jsonb, 'asset_current', false, null, 125),
  ('BH', 'default', '1300', 'ودائع واستثمارات قصيرة الأجل', '{"en":"Short-term deposits and investments"}'::jsonb, 'asset_current', false, null, 135),
  ('BH', 'default', '1310', 'استثمارات في أوراق مالية متداولة', '{"en":"Investments in marketable securities"}'::jsonb, 'asset_current', false, null, 140),
  ('BH', 'default', '1400', 'مصروفات مدفوعة مقدمًا', '{"en":"Prepayments"}'::jsonb, 'asset_prepayments', false, null, 150),
  ('BH', 'default', '1410', 'إيرادات مستحقة غير محصلة', '{"en":"Accrued income"}'::jsonb, 'asset_prepayments', false, null, 155),
  ('BH', 'default', '1415', 'تأمين مدفوع مقدمًا', '{"en":"Prepaid insurance"}'::jsonb, 'asset_prepayments', false, null, 160),
  ('BH', 'default', '1420', 'إيجار مدفوع مقدمًا', '{"en":"Prepaid rent"}'::jsonb, 'asset_prepayments', false, null, 165),
  ('BH', 'default', '1600', 'أراضٍ ومبانٍ - التكلفة', '{"en":"Land and buildings — cost"}'::jsonb, 'asset_fixed', false, null, 180),
  ('BH', 'default', '1601', 'أراضٍ ومبانٍ - مجمع الإهلاك', '{"en":"Land and buildings — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 185),
  ('BH', 'default', '1610', 'آلات ومعدات - التكلفة', '{"en":"Machinery and equipment — cost"}'::jsonb, 'asset_fixed', false, null, 190),
  ('BH', 'default', '1611', 'آلات ومعدات - مجمع الإهلاك', '{"en":"Machinery and equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 195),
  ('BH', 'default', '1620', 'أثاث وتجهيزات مكتبية - التكلفة', '{"en":"Office furniture and fixtures — cost"}'::jsonb, 'asset_fixed', false, null, 200),
  ('BH', 'default', '1621', 'أثاث وتجهيزات مكتبية - مجمع الإهلاك', '{"en":"Office furniture and fixtures — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 205),
  ('BH', 'default', '1630', 'أجهزة حاسب آلي وبرمجيات - التكلفة', '{"en":"Computer equipment and software — cost"}'::jsonb, 'asset_fixed', false, null, 210),
  ('BH', 'default', '1631', 'أجهزة حاسب آلي وبرمجيات - مجمع الإهلاك', '{"en":"Computer equipment and software — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 215),
  ('BH', 'default', '1640', 'وسائل نقل - التكلفة', '{"en":"Motor vehicles — cost"}'::jsonb, 'asset_fixed', false, null, 220),
  ('BH', 'default', '1641', 'وسائل نقل - مجمع الإهلاك', '{"en":"Motor vehicles — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 225),
  ('BH', 'default', '1650', 'أعمال رأسمالية تحت التنفيذ', '{"en":"Capital work in progress"}'::jsonb, 'asset_fixed', false, null, 230),
  ('BH', 'default', '1700', 'استثمارات عقارية', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, null, 240),
  ('BH', 'default', '1710', 'استثمارات في شركات زميلة وتابعة', '{"en":"Investments in associates and subsidiaries"}'::jsonb, 'asset_non_current', false, null, 245),
  ('BH', 'default', '1720', 'ودائع طويلة الأجل وتأمينات مستردة', '{"en":"Long-term deposits and refundable guarantees"}'::jsonb, 'asset_non_current', false, null, 250),
  ('BH', 'default', '1740', 'شهرة المحل', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 260),
  ('BH', 'default', '1745', 'أصول غير ملموسة أخرى - التكلفة', '{"en":"Other intangible assets — cost"}'::jsonb, 'asset_non_current', false, null, 265),
  ('BH', 'default', '1746', 'أصول غير ملموسة أخرى - مجمع الإطفاء', '{"en":"Other intangible assets — accumulated amortisation"}'::jsonb, 'asset_non_current', false, null, 270),
  ('BH', 'default', '2000', 'الموردون', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 290),
  ('BH', 'default', '2010', 'دائنون آخرون ومصروفات مستحقة', '{"en":"Other payables and accrued expenses"}'::jsonb, 'liability_current', false, null, 300),
  ('BH', 'default', '2015', 'أرصدة دائنة لأطراف ذات علاقة', '{"en":"Amounts due to related parties"}'::jsonb, 'liability_current', false, null, 305),
  ('BH', 'default', '2020', 'أرصدة دائنة للشركاء والمساهمين', '{"en":"Amounts due to partners and shareholders"}'::jsonb, 'liability_current', false, null, 310),
  ('BH', 'default', '2030', 'عربون ودائع محصلة مقدمًا', '{"en":"Deposits received in advance"}'::jsonb, 'liability_current', false, null, 315),
  ('BH', 'default', '2040', 'رواتب وأجور مستحقة', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', false, null, 320),
  ('BH', 'default', '2050', 'اشتراكات الهيئة العامة للتأمين الاجتماعي مستحقة', '{"en":"Social Insurance Organisation contributions payable"}'::jsonb, 'liability_current', false, null, 325),
  ('BH', 'default', '2100', 'ضريبة القيمة المضافة على المبيعات - مخرجات', '{"en":"VAT output tax"}'::jsonb, 'liability_current', false, null, 335),
  ('BH', 'default', '2105', 'ضريبة القيمة المضافة المحتسبة ذاتيًا - آلية الاحتساب العكسي', '{"en":"VAT self-assessed — domestic reverse charge"}'::jsonb, 'liability_current', false, null, 340),
  ('BH', 'default', '2110', 'مستحق للجهاز الوطني للإيرادات - ضريبة القيمة المضافة', '{"en":"Amount payable to the National Bureau for Revenue — VAT"}'::jsonb, 'liability_current', true, null, 345),
  ('BH', 'default', '2150', 'مخصص مكافأة نهاية الخدمة - الجزء المتداول', '{"en":"End-of-service gratuity provision — current portion"}'::jsonb, 'liability_current', false, null, 355),
  ('BH', 'default', '2200', 'قروض وسحب على المكشوف قصيرة الأجل', '{"en":"Short-term loans and bank overdraft"}'::jsonb, 'liability_current', false, null, 365),
  ('BH', 'default', '2210', 'الجزء المتداول من القروض طويلة الأجل', '{"en":"Current portion of long-term loans"}'::jsonb, 'liability_current', false, null, 370),
  ('BH', 'default', '2300', 'قروض طويلة الأجل', '{"en":"Long-term loans"}'::jsonb, 'liability_non_current', false, null, 385),
  ('BH', 'default', '2350', 'مخصص مكافأة نهاية الخدمة - الجزء غير المتداول', '{"en":"End-of-service gratuity provision — non-current portion"}'::jsonb, 'liability_non_current', false, null, 395),
  ('BH', 'default', '2360', 'مخصص ضريبة الدخل على أرباح قطاع النفط والغاز', '{"en":"Income tax provision — oil and gas sector"}'::jsonb, 'liability_non_current', false, null, 400),
  ('BH', 'default', '2990', 'حساب معلق', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 410),
  ('BH', 'default', '3000', 'رأس المال المصدر', '{"en":"Issued share capital"}'::jsonb, 'equity', false, null, 420),
  ('BH', 'default', '3010', 'احتياطي قانوني', '{"en":"Statutory reserve"}'::jsonb, 'equity', false, null, 430),
  ('BH', 'default', '3020', 'احتياطيات أخرى', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 440),
  ('BH', 'default', '3025', 'احتياطي إعادة تقييم الأصول', '{"en":"Asset revaluation reserve"}'::jsonb, 'equity', false, null, 445),
  ('BH', 'default', '3030', 'فروق ترجمة عملات أجنبية', '{"en":"Foreign currency translation reserve"}'::jsonb, 'equity', false, null, 450),
  ('BH', 'default', '3200', 'أرباح مرحلة', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 460),
  ('BH', 'default', '3210', 'توزيعات أرباح', '{"en":"Dividends paid"}'::jsonb, 'equity_retained', false, null, 470),
  ('BH', 'default', '4000', 'مبيعات بضاعة محلية', '{"en":"Domestic sales of goods"}'::jsonb, 'income', false, null, 490),
  ('BH', 'default', '4010', 'إيرادات خدمات محلية', '{"en":"Domestic sales of services"}'::jsonb, 'income', false, null, 500),
  ('BH', 'default', '4020', 'مبيعات تصدير سلع', '{"en":"Export sales of goods"}'::jsonb, 'income', false, null, 510),
  ('BH', 'default', '4030', 'إيرادات خدمات مصدَّرة لغير مقيم', '{"en":"Sales of services to a non-resident customer"}'::jsonb, 'income', false, null, 520),
  ('BH', 'default', '4040', 'إيرادات إيجارية عقارية', '{"en":"Real estate rental income"}'::jsonb, 'income', false, null, 530),
  ('BH', 'default', '4700', 'أرباح فروق عملة محققة', '{"en":"Realised foreign exchange gain"}'::jsonb, 'income_other', false, null, 550),
  ('BH', 'default', '4710', 'أرباح فروق عملة غير محققة', '{"en":"Unrealised foreign exchange gain"}'::jsonb, 'income_other', false, null, 555),
  ('BH', 'default', '4750', 'أرباح بيع أصول ثابتة', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 560),
  ('BH', 'default', '4790', 'إيرادات أخرى', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 570),
  ('BH', 'default', '5000', 'تكلفة البضاعة المباعة', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 590),
  ('BH', 'default', '5010', 'مصروفات نقل وتخليص جمركي', '{"en":"Freight and customs clearance"}'::jsonb, 'expense_direct_cost', false, null, 595),
  ('BH', 'default', '5020', 'أعمال مقاولي الباطن', '{"en":"Subcontractor costs"}'::jsonb, 'expense_direct_cost', false, null, 600),
  ('BH', 'default', '5030', 'مردودات ومسموحات مشتريات', '{"en":"Purchase returns and allowances"}'::jsonb, 'expense_direct_cost', false, null, 605),
  ('BH', 'default', '6100', 'رواتب وأجور', '{"en":"Salaries and wages"}'::jsonb, 'expense', false, null, 620),
  ('BH', 'default', '6110', 'مخصص مكافأة نهاية الخدمة عن السنة', '{"en":"End-of-service gratuity charge for the year"}'::jsonb, 'expense', false, null, 625),
  ('BH', 'default', '6115', 'مساهمة صاحب العمل في التأمين الاجتماعي', '{"en":"Employer''s Social Insurance Organisation contribution"}'::jsonb, 'expense', false, null, 630),
  ('BH', 'default', '6120', 'التأمين الصحي للعاملين', '{"en":"Staff health insurance"}'::jsonb, 'expense', false, null, 635),
  ('BH', 'default', '6130', 'مصروفات تدريب وتوظيف', '{"en":"Recruitment and training"}'::jsonb, 'expense', false, null, 640),
  ('BH', 'default', '6200', 'إيجارات', '{"en":"Rent"}'::jsonb, 'expense', false, null, 650),
  ('BH', 'default', '6210', 'مرافق - كهرباء ومياه واتصالات', '{"en":"Utilities — electricity, water and telecommunications"}'::jsonb, 'expense', false, null, 655),
  ('BH', 'default', '6220', 'أدوات ومطبوعات مكتبية', '{"en":"Office supplies and printing"}'::jsonb, 'expense', false, null, 660),
  ('BH', 'default', '6230', 'نظم معلومات وبرمجيات', '{"en":"IT systems and software"}'::jsonb, 'expense', false, null, 665),
  ('BH', 'default', '6240', 'صيانة وإصلاحات', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 670),
  ('BH', 'default', '6300', 'انتقالات وسفر', '{"en":"Travel"}'::jsonb, 'expense', false, null, 680),
  ('BH', 'default', '6310', 'ضيافة وعلاقات عامة', '{"en":"Entertainment and public relations"}'::jsonb, 'expense', false, null, 685),
  ('BH', 'default', '6320', 'مصروفات تشغيل وسائل النقل', '{"en":"Motor vehicle running costs"}'::jsonb, 'expense', false, null, 690),
  ('BH', 'default', '6400', 'أتعاب مهنية واستشارية', '{"en":"Professional and consultancy fees"}'::jsonb, 'expense', false, null, 700),
  ('BH', 'default', '6410', 'مصروفات ومصاريف بنكية', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 705),
  ('BH', 'default', '6420', 'تأمين', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 710),
  ('BH', 'default', '6430', 'دعاية وإعلان', '{"en":"Marketing and advertising"}'::jsonb, 'expense', false, null, 715),
  ('BH', 'default', '6435', 'اشتراكات وعضويات', '{"en":"Subscriptions and memberships"}'::jsonb, 'expense', false, null, 720),
  ('BH', 'default', '6440', 'رسوم ورخص حكومية', '{"en":"Government fees and licences"}'::jsonb, 'expense', false, null, 725),
  ('BH', 'default', '6450', 'رسوم تجديد الإقامة وتصاريح العمل', '{"en":"Residence and work permit renewal fees"}'::jsonb, 'expense', false, null, 730),
  ('BH', 'default', '6500', 'مصروف إهلاك', '{"en":"Depreciation charge"}'::jsonb, 'expense_depreciation', false, null, 745),
  ('BH', 'default', '6510', 'مصروف إطفاء', '{"en":"Amortisation charge"}'::jsonb, 'expense_depreciation', false, null, 750),
  ('BH', 'default', '6900', 'ضريبة قيمة مضافة غير قابلة للخصم على مشتريات معفاة', '{"en":"Non-deductible VAT on exempt purchases"}'::jsonb, 'expense', false, null, 760),
  ('BH', 'default', '6950', 'خسائر فروق عملة محققة', '{"en":"Realised foreign exchange loss"}'::jsonb, 'expense', false, null, 770),
  ('BH', 'default', '6955', 'خسائر فروق عملة غير محققة', '{"en":"Unrealised foreign exchange loss"}'::jsonb, 'expense', false, null, 775),
  ('BH', 'default', '6960', 'خسائر بيع أصول ثابتة', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 780),
  ('BH', 'default', '6990', 'فروق تقريب', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 790),
  ('BH', 'default', '7100', 'فوائد وأعباء تمويلية', '{"en":"Interest and finance charges"}'::jsonb, 'expense', false, null, 805),
  ('BH', 'default', '8000', 'مصروف ضريبة الدخل على أرباح قطاع النفط والغاز', '{"en":"Income tax charge — oil and gas sector"}'::jsonb, 'expense', false, null, 820)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BH', 'BNK', 'البنك', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('BH', 'CSH', 'الصندوق', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('BH', 'GEN', 'دفتر اليومية العامة', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('BH', 'OPN', 'أرصدة افتتاحية', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('BH', 'PUR', 'دفتر يومية المشتريات', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('BH', 'SAL', 'دفتر يومية المبيعات', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('BH', 'BH-P-EXEMPT', 'شراء سلع أو خدمات معفاة', '{"en":"Purchase, exempt goods or services"}'::jsonb, 'A purchase of an exempt good or service — a financial service or a real estate rental — on which the supplier charges no VAT and the buyer has no input tax to deduct.', 'percent', 0, 'purchase', 'exempt', date '2019-01-01', null, 'VAT Law, Articles 54 and 55: a financial service and a sale or lease of real estate are exempt, so the supplier charges no Tax on them and there is none for the buyer to deduct under Article 42.', 'E', null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('BH', 'BH-P-IMPORT', 'استيراد سلع، ضريبة تحصّل عند الإفراج الجمركي', '{"en":"Import of goods, tax collected on customs release"}'::jsonb, 'Imported goods, VAT paid to Customs Affairs at the Ministry of Interior on release of the goods, then deducted as an ordinary recoverable input.', 'percent', 10, 'purchase', 'import', date '2022-01-01', null, 'Executive Regulations, Article 65(A): ''Tax due at import shall be paid to Customs Affairs at the Ministry of Interior ... in accordance with the established procedures for the payment and collection of customs duties.'' VAT Law, Article 4, third indent, makes ''every Person appointed or recognised as an Importer'' liable for it. Article 22 of the Executive Regulations lets an NBR-approved, Customs-bonded importer defer that cash payment to the periodic return instead; this pack models the ordinary case paid at the border and not that election — see the pack''s README.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-P-RC', 'شراء من مورد غير مقيم، احتساب عكسي', '{"en":"Purchase from a non-resident supplier, reverse charge"}'::jsonb, 'Goods or Services received in the Kingdom from a supplier with no place of residence in the Kingdom, self-assessed by the Bahraini taxable customer and declared on the Tax Return.', 'percent', 10, 'purchase', 'foreign_services_received', date '2022-01-01', null, 'VAT Law, Article 4, second indent: ''A taxable Customer who receives Goods or Services in the Kingdom from a Supplier who is a non-resident, in accordance with the Reverse Charge Mechanism by declaring it on the Tax Return'' is liable for the Tax. The value of the supply for this purpose is the purchase price (Executive Regulations, Article 24, Paragraph on Reverse Charge value). The Tax self-assessed nets to zero on the amount due for a fully taxable buyer: recorded on account 2105 and box e2 as the amount payable, and recovered again in box f2 to the extent it is used to make a taxable supply, the same reasoning packs/eg and packs/sa record for their own import-of-services box.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('BH', 'BH-P-STD', 'شراء، معدل قياسي 10%، ضريبة قابلة للخصم', '{"en":"Purchase, standard rate 10%, deductible"}'::jsonb, 'A domestic purchase taxed at the standard rate, whose input tax is deducted against the tax due on the buyer''s own supplies.', 'percent', 10, 'purchase', 'domestic', date '2022-01-01', null, 'VAT Law, Article 42: the Deductible Tax for a Taxable Person is ''the Input Tax paid or receivable on Goods and Services supplied to him ... for the purpose of carrying out Taxable Supplies.'' Executive Regulations, Article 57, and Article 48 of the Law on the return declaring it.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('BH', 'BH-P-ZR', 'شراء سلع أو خدمات خاضعة لنسبة الصفر', '{"en":"Purchase of zero-rated goods or services"}'::jsonb, 'A domestic purchase of goods or services taxed at the zero rate — for instance the construction services of BH-S-ZR-CONSTRUCTION, or the basic food items of BH-S-ZR-FOOD, bought rather than sold — with no input tax to deduct because none was charged.', 'percent', 0, 'purchase', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53, the same zero-rate chapter cited on the sale side: a purchase of a zero-rated Good or Service carries a value but no Tax, so box f1 is stated and box f2 stays at zero for this line.', 'Z', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('BH', 'BH-S-EXEMPT-FIN', 'بيع، خدمات مالية معفاة', '{"en":"Sale, exempt financial services"}'::jsonb, 'A financial service related to a cash transaction — a loan, a Shari''ah-compliant equivalent, currency or derivative trading held for margin, a life insurance or reinsurance contract, or the transfer of an equity or debt security — remunerated otherwise than by an explicit fee, commission or commercial discount.', 'percent', 0, 'sale', 'exempt', date '2019-01-01', null, 'VAT Law, Article 54: ''The Supply of financial Services specified in the Regulations is exempt from Tax, except where the payment for the Service is expressed as a fee, commission or commercial discount.'' Executive Regulations, Article 81(B): financial services means services related to cash transactions, including transactions the VAT General Guide, section 6.4.3, lists as interest on a loan and its Shari''ah-compliant equivalent, currency and derivative trading held for margin rather than a fee, and the provision or transfer of a life insurance or reinsurance contract; general insurance, and a brokerage, agency or asset-management service remunerated by a transaction or management fee, do not fall under the exemption and are taxed at the standard rate instead. Bahrain is outside the common system of VAT the Union directive governs, so `exemption_code` carries no VATEX code and the exempting article is stated here instead.', 'E', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-EXEMPT-REALESTATE', 'بيع أو تأجير عقار', '{"en":"Sale or lease of real estate, exempt"}'::jsonb, 'The sale, lease or licence of real estate — residential, commercial or bare land alike — other than hotel accommodation, short-term car parking, a function room or hall, serviced office space with no exclusive designated area, and utilities charged separately from the rent.', 'percent', 0, 'sale', 'exempt', date '2019-01-01', null, 'VAT Law, Article 55: ''The Supply of bare land and buildings by way of sale or rental shall be exempt from Tax.'' VAT General Guide, section 6.4.2: the exemption reaches a sale, lease or licence of real estate ''regardless of whether the real estate is residential, commercial or land'' — there is no zero-rated first supply of a new residential building in Bahrain, unlike the United Arab Emirates: a Bahraini new building''s construction services are zero-rated under BH-S-ZR-CONSTRUCTION, and the completed building''s own sale or lease is exempt under this code. Executive Regulations, Article 82(A): hotel accommodation, paid car parking for periods under one month, serviced office space where the customer has no exclusive designated space, a function room, hall or similar facility, and management, utility, telecommunications, internet or television charges billed separately from the rent are not treated as a sale or lease of real estate and stay at the standard rate. Bahrain is outside the common system of VAT the Union directive governs, so `exemption_code` carries no VATEX code and the exempting article is stated here instead.', 'E', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-EXPORT-GOODS', 'بيع، تصدير سلع', '{"en":"Sale, export of goods"}'::jsonb, 'Goods exported outside the territory of the Implementing States of the GCC Unified VAT Agreement.', 'percent', 0, 'sale', 'export', date '2019-01-01', null, 'VAT Law, Article 53, first transaction of the zero-rate chapter: ''The export of Goods outside the territory of the Implementing States.'' Bahrain is outside the common system of VAT the Union directive governs, so this pack carries no `exemption_code` and states the article here instead — see BH-S-EXEMPT-FIN below and supabase/seed/00_territories.sql.', 'G', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('BH', 'BH-S-EXPORT-SVC', 'بيع، خدمات لعميل غير مقيم خارج دول المجلس', '{"en":"Sale, services to a non-resident customer outside the GCC"}'::jsonb, 'A service supplied by a resident taxable supplier to a customer who has no place of residence in the Kingdom or in any other Implementing State and who was outside the Kingdom when the service was performed, the service and its benefit both taking place outside the Implementing States.', 'percent', 0, 'sale', 'export', date '2019-01-01', null, 'Executive Regulations, Article 73: the zero rate applies to a supply of services by a resident taxable supplier where the customer ''has no Place of Residence in the Kingdom or any Implementing State and who was outside the Kingdom'' when the service was performed, the service relates to tangible goods or real estate located outside the Implementing States, is performed outside their territory, and is enjoyed outside it — four conditions this pack''s golden scenario states are all met by its own export-of-services line.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-STD', 'بيع، معدل قياسي 10%', '{"en":"Sale, standard rate 10%"}'::jsonb, 'A domestic supply of Goods or Services that is neither zero-rated nor exempt.', 'percent', 10, 'sale', 'domestic', date '2022-01-01', null, 'Law No. 33 of 2021, Article Three, replacing Paragraph One of Article 3 of the VAT Law: ''Tax shall be imposed at a standard rate of (10%) of the value of a supply or import, unless a specific provision is made in this Law to exempt from Tax or to impose Tax at a zero rate.'' Article Five of Law No. 33 of 2021 brings this into force on 1 January 2022; before that day the same Article 3 of the VAT Law set the rate at 5% from 1 January 2019, the day the tax itself took effect. Article Four of Law No. 33 of 2021 keeps a contract concluded before the amendment at 5% until the earlier of the contract''s own term, its amendment or renewal, or one year from 1 January 2022 — a transitional rule this pack''s golden scenario, dated 2026, does not need to exercise.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-amendment', null, null, null, null),
  ('BH', 'BH-S-ZR-CONSTRUCTION', 'بيع، خدمات تشييد مبانٍ جديدة', '{"en":"Sale, construction services for new buildings, zero rate"}'::jsonb, 'Construction services relating to a new building — a residential, commercial or industrial building not yet occupied — and the goods the constructor supplies in the course of that construction, used, installed or incorporated into the building or the land.', 'percent', 0, 'sale', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53: ''The construction of new buildings'' is zero-rated. Executive Regulations, Article 76: a ''building'' is ''residential, commercial or industrial'', new meaning ''it has not been occupied yet'', and an extension of an existing building qualifies while demolition, architects'' and interior design fees, restoration works and any service supplied after completion do not; a good qualifies only where it is ''used, installed or incorporated into the building or the land'' by the person constructing it, which is why furniture not affixed to the building, landscaping, swimming pools and decorative fittings are excluded (VAT General Guide, section 6.3.9).', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-ZR-EDUCATION', 'بيع، خدمات تعليم وما يرتبط بها', '{"en":"Sale, educational services and related goods and services, zero rate"}'::jsonb, 'Educational services and related goods and services supplied by a nursery, or a pre-primary, primary, secondary or higher education institution licensed by the competent authority in the Kingdom, to a student enrolled in it.', 'percent', 0, 'sale', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53: educational services and associated goods and services supplied by nurseries and pre-school, primary, secondary and higher education institutions are zero-rated. Executive Regulations, Article 77: the zero rate applies ''only if the Supplies are made by a school or educational institution licensed by the competent authority in the Kingdom and provided to a student who is enrolled in that school or institution'' — a licence and an enrolled student are both conditions, and a service bought by somebody other than the institution itself, or supplied to somebody not enrolled, stays at the standard rate.', 'Z', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-ZR-FOOD', 'بيع، سلع غذائية أساسية', '{"en":"Sale, basic food items, zero rate"}'::jsonb, 'Food items on the list ratified by the Financial and Economic Cooperation Committee of the GCC, for human consumption, not supplied by a restaurant, coffee shop or similar establishment and not supplied by a caterer.', 'percent', 0, 'sale', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53: the zero rate applies to ''the Supply and import of food as stipulated in Clause 1 of Article 31 of the [GCC Unified VAT] Agreement.'' Executive Regulations, Article 80, the operative conditions: the zero rate reaches only goods that are not supplied by a restaurant, coffee shop or similar establishment and not supplied by caterers — a meal sold ready to eat is a supply of a restaurant service and stays at the standard rate however basic the food. VAT General Guide, section 6.3.5: ''the list of basic food items qualifying for the zero-rate [is] available on NBR website''; this pack''s research did not open that list, so it carries the rule and not the schedule, exactly as `conditions` and its own limits describe.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-ZR-HEALTHCARE', 'بيع، خدمات رعاية صحية أساسية ووقائية', '{"en":"Sale, preventive and basic healthcare services, zero rate"}'::jsonb, 'Preventive and basic healthcare services and the goods and services associated with them, being qualifying medical services provided by a qualified medical professional or institution under the laws in force in the Kingdom.', 'percent', 0, 'sale', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53: ''The Supply of preventive and basic healthcare Services and associated Goods and Services'' is zero-rated. Executive Regulations, Article 69: the service must be ''qualifying medical Services provided by qualified medical professionals or qualified medical institutions pursuant to the laws and legislation in force in the Kingdom'', and Paragraph B lists general medical health services, specialist services including surgery, and dental services among its examples. Article 71 zero-rates the supply or import of medicines and medical equipment on the same coordination with the Kingdom''s medical bodies the Law itself asks for.', 'Z', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-ZR-OILGAS', 'بيع، نفط ومشتقات نفطية وغاز', '{"en":"Sale, oil, oil derivatives and gas, zero rate"}'::jsonb, 'The import and supply of oil, gas and other hydrocarbons, processed or unprocessed, the grant of a right to explore, extract or produce them, and oil and gas exploration services.', 'percent', 0, 'sale', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53: ''Oil, oil derivatives and the gas sector'' are zero-rated. Executive Regulations, Article 79(A): the zero rate covers ''the Import and Supply of oil, gas and other hydrocarbons, whether processed or unprocessed'', the grant of a right to use, explore or exploit any part of the Kingdom to search for, extract or produce them, and the supply of oil and gas exploration services and the services related to oil and gas fields the article lists — design, drilling, rig installation, extraction, retrieval, separation, evaluation, feasibility studies and seismic surveys among them.', 'Z', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('BH', 'BH-S-ZR-TRANSPORT', 'بيع، نقل محلي للركاب والبضائع', '{"en":"Sale, local transport of passengers and goods, zero rate"}'::jsonb, 'Transport of goods or passengers by land, water or air from a place inside the Kingdom to another place inside the Kingdom, by a person who meets the regulatory and licensing requirements to supply such services.', 'percent', 0, 'sale', 'domestic', date '2019-01-01', null, 'VAT Law, Article 53: ''the local transportation sector'' is zero-rated. Executive Regulations, Article 78: the zero rate reaches transport of goods and passengers by land, water or air ''from a place inside the Kingdom to another place in the Kingdom'', and Paragraph B refuses it to transport supplied by a person who does not meet the licensing requirements of the authorised body, and to the rental of a car without a driver — a chauffeured taxi or bus service qualifies, a self-drive rental does not.', 'Z', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null)
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
    ('BH-P-IMPORT', 'invoice', 'base', 100, null, 'f1', array['f1']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-P-IMPORT', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'BH-VAT-RETURN', 20),
    ('BH-P-IMPORT', 'credit_note', 'base', 100, null, 'f1', array['f1']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-P-IMPORT', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'BH-VAT-RETURN', 20),
    ('BH-P-RC', 'invoice', 'base', 100, null, 'e1', array['e1']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-P-RC', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'BH-VAT-RETURN', 20),
    ('BH-P-RC', 'invoice', 'tax', -100, '2105', 'e2', array['e2']::text[], 100, 'BH-VAT-RETURN', 30),
    ('BH-P-RC', 'credit_note', 'base', 100, null, 'e1', array['e1']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-P-RC', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'BH-VAT-RETURN', 20),
    ('BH-P-RC', 'credit_note', 'tax', -100, '2105', 'e2', array['e2']::text[], -100, 'BH-VAT-RETURN', 30),
    ('BH-P-STD', 'invoice', 'base', 100, null, 'f1', array['f1']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-P-STD', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'BH-VAT-RETURN', 20),
    ('BH-P-STD', 'credit_note', 'base', 100, null, 'f1', array['f1']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-P-STD', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'BH-VAT-RETURN', 20),
    ('BH-P-ZR', 'invoice', 'base', 100, null, 'f1', array['f1']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-P-ZR', 'credit_note', 'base', 100, null, 'f1', array['f1']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXEMPT-FIN', 'invoice', 'base', 100, null, 'c', array['c']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXEMPT-FIN', 'credit_note', 'base', 100, null, 'c', array['c']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXEMPT-REALESTATE', 'invoice', 'base', 100, null, 'c', array['c']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXEMPT-REALESTATE', 'credit_note', 'base', 100, null, 'c', array['c']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXPORT-GOODS', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXPORT-GOODS', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXPORT-SVC', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-EXPORT-SVC', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-STD', 'invoice', 'base', 100, null, 'a1', array['a1']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-STD', 'invoice', 'tax', 100, '2100', 'a2', array['a2']::text[], 100, 'BH-VAT-RETURN', 20),
    ('BH-S-STD', 'credit_note', 'base', 100, null, 'a1', array['a1']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-STD', 'credit_note', 'tax', 100, '2100', 'a2', array['a2']::text[], -100, 'BH-VAT-RETURN', 20),
    ('BH-S-ZR-CONSTRUCTION', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-CONSTRUCTION', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-EDUCATION', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-EDUCATION', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-FOOD', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-FOOD', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-HEALTHCARE', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-HEALTHCARE', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-OILGAS', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-OILGAS', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-TRANSPORT', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'BH-VAT-RETURN', 10),
    ('BH-S-ZR-TRANSPORT', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'BH-VAT-RETURN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BH' and t.code = v.tax_code
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
  ('BH', 'BH-VAT-RETURN', 'الإقرار الضريبي — ضريبة القيمة المضافة', array['month', 'quarter']::declaration_period[], null, date '2019-01-01', null, 'VAT Law, Article 35: the Tax Period is set by the Regulations, no shorter than one month. Executive Regulations, Article 48(A): a Taxable Person whose annual Supplies declared for registration exceed BHD 3,000,000 files monthly, on the Gregorian calendar month; one whose annual Supplies do not exceed that figure files quarterly, on the calendar quarters 1 January to 31 March, 1 April to 30 June, 1 July to 30 September and 1 October to 31 December (VAT General Guide, section 12.2, repeats the same threshold and the same quarters). No cadence is proposed as the one every registrant gets: which of the two a company files on turns entirely on its own annual Supplies, the same shape packs/lu records for its own VAT return. Article 48(C) additionally lets a Taxable Person below the BHD 3,000,000 threshold ask the Bureau to move to monthly filing, and Article 48(B) lets the Bureau reassign a Taxable Person''s period for reasons it determines, on three months'' notice — elections and adjustments this pack''s `period` list does not need a third cadence to state, since both outcomes are `month`.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'VAT Law, Article 36, first paragraph: a Taxable Person submits a Tax Return for each Tax Period ''by no later than the last day of the month following the end of the Tax Period concerned.'' VAT General Guide, section 12.3.2: ''A VATable person should submit a VAT return using the NBR''s online portal and make the payment of the VAT due by the last day of the month following the end of the VAT period'' — filing and payment share the one deadline. Article 36, second paragraph: a return is due even where the Taxable Person made no purchase, import or supply in the Tax Period.', 'vat-law', null)
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
  ('BH', 'BH-VAT-RETURN', 'a1', 'base', 'قيمة المبيعات الخاضعة للمعدل القياسي 10%', '{"en":"Value of sales at the standard rate of 10%"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, Article 3, as replaced by Law No. 33 of 2021: the value of a domestic supply taxed at the standard rate of 10%. VAT Law, Article 36: the return discloses ''all Imports and Supplies he has made or received during that Tax Period'' — this pack''s research could not open a directly-fetchable, currently-in-force NBR text naming the exact on-screen boxes of the live return, so the boxes here are this pack''s own construction, built letter by letter on that requirement and on section 12.3.1 of the VAT General Guide (''the total output VAT due, and the total input VAT recoverable''). A reviewer who has filed on the NBR portal should check this first.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'a2', 'tax', 'الضريبة المستحقة على قيمة الصندوق a1', '{"en":"Tax due on box a1"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Output Tax charged on box a1, VAT Law Article 3.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'b', 'base', 'قيمة المبيعات الخاضعة لنسبة الصفر', '{"en":"Value of zero-rated sales"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, Article 53: every transaction the zero-rate chapter names — the export of goods and of services, basic food items, healthcare, education, the construction of new buildings, local transportation, and oil, oil derivatives and gas among them — carries no Tax and is stated once in this box, exactly as Chapter Thirteen of the Law states the zero rate once for all of them.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'c', 'base', 'قيمة المبيعات المعفاة', '{"en":"Value of exempt sales"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, Articles 54 and 55: the value of an exempt supply of financial services or of real estate.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'e1', 'base', 'قيمة السلع والخدمات المستلمة من مورد غير مقيم، احتساب عكسي', '{"en":"Value of goods and services received from a non-resident supplier, reverse charge"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, Article 4, second indent: the value of Goods or Services a taxable customer receives in the Kingdom from a non-resident supplier, self-assessed under the Reverse Charge Mechanism.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'e2', 'tax', 'الضريبة المحتسبة ذاتيًا على قيمة الصندوق e1', '{"en":"Tax self-assessed on box e1"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The Tax the customer self-assesses on box e1 under the Reverse Charge Mechanism, VAT Law Article 4; no clause of Article 36 names this figure separately from the value in e1, but a value reported without the Tax it carries would leave the Due Tax of box h short by exactly this amount, the same reasoning packs/ae and packs/eg record for their own self-assessment box.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'f1', 'base', 'قيمة المشتريات التي تخصم عنها الضريبة', '{"en":"Value of purchases whose tax is deducted"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, Article 42: the value of Goods and Services, whether purchased domestically, imported or received under the Reverse Charge Mechanism, whose Input Tax the Taxable Person seeks to deduct.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'f2', 'tax', 'الضريبة القابلة للخصم على قيمة الصندوق f1، متضمنة نصيب الصندوق e2 القابل للخصم', '{"en":"Deductible tax on box f1, including the recoverable share of box e2"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, Article 42: the Deductible Tax on box f1, including the recoverable share of the Tax self-assessed in box e2 to the extent it is used to make a Taxable Supply.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'h', 'total', 'إجمالي الضريبة المستحقة عن الفترة', '{"en":"Total tax due for the period"}'::jsonb, 90, null, array['a2', 'e2']::text[], '{}'::text[], null, null, false, false, null, 'The period''s total Tax due before deduction of Input Tax: the output Tax of box a2 and the Tax self-assessed in box e2.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'i', 'total', 'إجمالي الضريبة القابلة للخصم عن الفترة', '{"en":"Total deductible tax for the period"}'::jsonb, 100, null, array['f2']::text[], '{}'::text[], null, null, false, false, null, 'The period''s total Deductible Tax, box f2.', 'vat-law'),
  ('BH', 'BH-VAT-RETURN', 'j', 'total', 'صافي الضريبة المستحقة السداد أو الفائض القابل للترحيل', '{"en":"Net tax payable or surplus carried forward"}'::jsonb, 110, null, array['h']::text[], array['i']::text[], null, null, false, false, null, 'VAT Law, Article 58: the Taxable Person may ask the Bureau to carry forward excess net recoverable Tax to a subsequent Tax Period; Article 57 lets the Bureau refund Tax paid in excess instead. No floor at zero: a negative figure is the excess this pack carries forward or lets the Taxable Person reclaim.', 'vat-law')
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
  ('BH-IFRSSME-IS', 'BH', 'default', 'قائمة الدخل — طبقًا لمعيار المنشآت الصغيرة والمتوسطة الدولي للتقرير المالي', 'income_statement', 'BH-IFRSSME', date '1970-01-01', null, 'Same source and same gap as BH-IFRSSME-SFP above: built on the minimum line items of the IFRS for SMEs Accounting Standard, section 5, by nature of expense, which a small company''s ledger holds without an allocation to functions.', 'ifrs-profile'),
  ('BH-IFRSSME-SFP', 'BH', 'default', 'قائمة المركز المالي — طبقًا لمعيار المنشآت الصغيرة والمتوسطة الدولي للتقرير المالي', 'balance_sheet', 'BH-IFRSSME', date '1970-01-01', null, 'Article 219 of the Commercial Companies Law (Legislative Decree No. 21 of 2001) conditions a clean audit opinion on financial statements prepared under international accounting standards, and the IFRS Foundation''s Jurisdictional Profile records that Bahrain has adopted IFRS Accounting Standards and the IFRS for SMEs Standard with no local GAAP of its own. This pack''s research found no Bahraini text prescribing a line-by-line format for either, so the lines below are built, as packs/ae and packs/sa build theirs on the same absence, on the minimum line items the general IFRS for SMEs Accounting Standard, section 4, asks for, current and non-current apart. A reviewer familiar with the IFRS for SMEs Standard as actually applied in the Kingdom should check this first.', 'ifrs-profile')
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
  ('BH-IFRSSME-IS', '1', null, 'الإيرادات', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '2', null, 'إيرادات أخرى', '{"en":"Other income"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '3', null, 'تكلفة المبيعات', '{"en":"Cost of sales"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '4', null, 'تكلفة العاملين', '{"en":"Employee benefits expense"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '5', null, 'الإهلاك والإطفاء', '{"en":"Depreciation and amortisation"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '6', null, 'مصروفات تشغيل أخرى', '{"en":"Other operating expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '7', null, 'أعباء تمويلية', '{"en":"Finance costs"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-IS', '8', null, 'الربح قبل ضريبة الدخل', '{"en":"Profit before income tax"}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('BH-IFRSSME-IS', '9', null, 'مصروف ضريبة الدخل', '{"en":"Income tax expense"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'لا توجد ضريبة دخل عامة على الشركات في مملكة البحرين؛ هذا البند يخص فقط شركات استخراج وتكرير النفط والغاز.', null),
  ('BH-IFRSSME-IS', '10', null, 'صافي ربح السنة', '{"en":"Profit for the year"}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CA', null, 'الأصول المتداولة', '{"en":"Current assets"}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CA.1', 'CA', 'النقدية وما في حكمها', '{"en":"Cash and cash equivalents"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CA.2', 'CA', 'العملاء ومدينون آخرون', '{"en":"Trade and other receivables"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'ضريبة القيمة المضافة المدخلات، ورصيدها المؤجل عند الاستيراد، والرصيد المستحق من الجهاز الوطني للإيرادات تعرض هنا.', null),
  ('BH-IFRSSME-SFP', 'CA.3', 'CA', 'المخزون', '{"en":"Inventories"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CA.4', 'CA', 'ودائع واستثمارات قصيرة الأجل', '{"en":"Short-term deposits and investments"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CA.5', 'CA', 'مصروفات مدفوعة مقدمًا وإيرادات مستحقة', '{"en":"Prepayments and accrued income"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCA', null, 'الأصول غير المتداولة', '{"en":"Non-current assets"}'::jsonb, 70, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCA.1', 'NCA', 'الممتلكات والآلات والمعدات', '{"en":"Property, plant and equipment"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCA.2', 'NCA', 'استثمارات عقارية', '{"en":"Investment property"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCA.3', 'NCA', 'استثمارات في شركات زميلة وتابعة', '{"en":"Investments in associates and subsidiaries"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCA.4', 'NCA', 'ودائع وتأمينات طويلة الأجل', '{"en":"Long-term deposits"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCA.5', 'NCA', 'الأصول غير الملموسة والشهرة', '{"en":"Intangible assets and goodwill"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'TA', null, 'إجمالي الأصول', '{"en":"Total assets"}'::jsonb, 130, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CL', null, 'الخصوم المتداولة', '{"en":"Current liabilities"}'::jsonb, 140, 1, true, array['CL.1', 'CL.2', 'CL.3']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CL.1', 'CL', 'الموردون ودائنون آخرون', '{"en":"Trade and other payables"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'ضريبة القيمة المضافة المخرجات والمحتسبة ذاتيًا والمستحقة للجهاز الوطني للإيرادات تعرض هنا.', null),
  ('BH-IFRSSME-SFP', 'CL.2', 'CL', 'مخصصات متداولة', '{"en":"Current provisions"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'CL.3', 'CL', 'قروض قصيرة الأجل', '{"en":"Short-term loans"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCL', null, 'الخصوم غير المتداولة', '{"en":"Non-current liabilities"}'::jsonb, 180, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCL.1', 'NCL', 'قروض طويلة الأجل', '{"en":"Long-term loans"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCL.2', 'NCL', 'مخصصات غير متداولة', '{"en":"Non-current provisions"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NCL.3', 'NCL', 'مخصص ضريبة الدخل', '{"en":"Income tax provision"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'لا توجد ضريبة دخل عامة على الشركات في مملكة البحرين؛ هذا الحساب يخص فقط شركات استخراج وتكرير النفط والغاز الخاضعة لنظامها الضريبي الخاص.', null),
  ('BH-IFRSSME-SFP', 'TL', null, 'إجمالي الخصوم', '{"en":"Total liabilities"}'::jsonb, 220, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'NA', null, 'صافي الأصول', '{"en":"Net assets"}'::jsonb, 230, 1, true, array['TA']::text[], array['TL']::text[], null, 'يساوي حقوق الملكية بعد إقفال السنة، ويزيد عليها بنتيجة أعمال السنة المفتوحة قبل الإقفال.', null),
  ('BH-IFRSSME-SFP', 'EQ', null, 'حقوق الملكية', '{"en":"Equity"}'::jsonb, 240, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'EQ.1', 'EQ', 'رأس المال', '{"en":"Share capital"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'EQ.2', 'EQ', 'الاحتياطيات', '{"en":"Reserves"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BH-IFRSSME-SFP', 'EQ.3', 'EQ', 'الأرباح المرحلة', '{"en":"Retained earnings"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('BH-IFRSSME-IS', '1', 10, 'code_range', '4000', '4040', null, 'any'),
    ('BH-IFRSSME-IS', '2', 10, 'code_range', '4700', '4790', null, 'any'),
    ('BH-IFRSSME-IS', '3', 10, 'code_range', '5000', '5030', null, 'any'),
    ('BH-IFRSSME-IS', '4', 10, 'code_range', '6100', '6130', null, 'any'),
    ('BH-IFRSSME-IS', '5', 10, 'code_range', '6500', '6510', null, 'any'),
    ('BH-IFRSSME-IS', '6', 10, 'code_range', '6200', '6460', null, 'any'),
    ('BH-IFRSSME-IS', '6', 20, 'code_range', '6900', '6990', null, 'any'),
    ('BH-IFRSSME-IS', '7', 10, 'account_code', '7100', null, null, 'any'),
    ('BH-IFRSSME-IS', '9', 10, 'account_code', '8000', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('BH-IFRSSME-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('BH-IFRSSME-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('BH-IFRSSME-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('BH-IFRSSME-SFP', 'CA.4', 10, 'code_range', '1300', '1310', null, 'any'),
    ('BH-IFRSSME-SFP', 'CA.5', 10, 'code_range', '1400', '1420', null, 'any'),
    ('BH-IFRSSME-SFP', 'NCA.1', 10, 'code_range', '1600', '1650', null, 'any'),
    ('BH-IFRSSME-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'NCA.3', 10, 'account_code', '1710', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'NCA.4', 10, 'account_code', '1720', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'NCA.5', 10, 'code_range', '1740', '1746', null, 'any'),
    ('BH-IFRSSME-SFP', 'CL.1', 10, 'code_range', '2000', '2110', null, 'any'),
    ('BH-IFRSSME-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('BH-IFRSSME-SFP', 'CL.2', 10, 'account_code', '2150', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'CL.3', 10, 'code_range', '2200', '2210', null, 'any'),
    ('BH-IFRSSME-SFP', 'NCL.1', 10, 'account_code', '2300', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'NCL.2', 10, 'account_code', '2350', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'NCL.3', 10, 'account_code', '2360', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'EQ.1', 10, 'account_code', '3000', null, null, 'any'),
    ('BH-IFRSSME-SFP', 'EQ.2', 10, 'code_range', '3010', '3030', null, 'any'),
    ('BH-IFRSSME-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('BH', 'البحرين', '{"en":"Bahrain"}'::jsonb, array['ar', 'en']::text[], 'BHD', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'ar', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Executive Regulations, Article 52(A)(5): a Tax Invoice states ''a sequential invoice number.'' The article asks for a number that runs in sequence and not, in the text this pack''s research could open, that the series carry no gap, which is why the style is `sequential` and not a gapless one.',
  numbering_source_key          = 'vat-exec-reg',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'VAT Law, Article 12: ''Tax is due on the date of the Supply of the Goods or Services, the date of issue of a Tax Invoice, or the date of receipt of Consideration in full or in part, to the extent of the received amount, whichever comes first.'' That is a three-way earliest test — supply, invoice, payment — and the closed vocabulary of this field has no value for three triggers at once. `earliest_of_delivery_or_payment` is the nearest of the five and is what the rule reduces to in the ordinary case, because Article 39 of the Law already requires the Tax Invoice by the fifteenth day of the month following the month of supply; a supply invoiced ahead of delivery is the case this approximation misses, the same gap packs/sa, packs/ae and packs/eg record for their own three-way wording.',
  tax_point_source_key          = 'vat-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'At the day this pack was released, no statute obliges a Bahraini business to exchange electronic invoices with another. The VAT General Guide, section 9.2.1, records only that ''a VAT registered person may issue and retain VAT Invoices, credit and debit notes and other documents that evidence his supply in an electronic form'' without prior approval from the NBR once its own systems meet Articles 52 to 54 of the Executive Regulations — a permission to keep an invoice as a PDF, not a structured-format exchange or a clearance regime, and this pack''s research found no NBR or LLOC text past that point naming a format, a network, a party identifier or an effective date. Public reporting from mid-2026 describes a nationwide business-to-business e-invoicing platform at the tender and procurement stage since 2022, with no technical specification or legislated date published; this pack''s own research could not open a directly-fetchable primary NBR text confirming any of it, so nothing beyond the permission the General Guide itself states is carried here. docs/international.md records the gap.',
  einvoice_source_key           = 'vat-general-guide',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'BH';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('BH', 'reverse_charge', 'reverse_charge', 'Reverse charge: the Customer must account for the Tax due on this supply under Article 4 of Legislative Decree No. 48 of 2018.', '{"en":"Reverse charge: the Customer must account for the Tax due on this supply under Article 4 of Legislative Decree No. 48 of 2018."}'::jsonb, 10, date '1970-01-01', null, 'VAT Law, Article 4: a taxable customer who receives Goods or Services in the Kingdom from a non-resident supplier accounts for the Tax ''in accordance with the Reverse Charge Mechanism by declaring it on the Tax Return.'' This pack''s research found no article requiring a specific printed sentence on the non-resident supplier''s own invoice for this case, unlike Saudi Arabia''s Article 53(5)(d); the wording here is this pack''s own.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
