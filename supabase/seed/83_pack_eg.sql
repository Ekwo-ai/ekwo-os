-- Ekwo OS — مصر: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/eg at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build eg`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Value Added Tax Law No. (67) of 2016, as amended (consolidated text updated 15 January 2023) (Egyptian Tax Authority (ETA), Ministry of Finance — General Department of Translation)
--     https://www.eta.gov.eg/sites/default/files/2024-02/Law-english-no.67-2016.pdf.pdf
--   Executive Regulations of Value Added Tax Law No. (67) of 2016, Minister of Finance Decree No. 66 of 2017, as amended (consolidated text updated 15 January 2023) (Egyptian Tax Authority (ETA), Ministry of Finance — General Department of Translation)
--     https://www.eta.gov.eg/sites/default/files/2024-02/VAT-Executive-Regulations-English.pdf
--   قانون رقم 206 لسنة 2020 بإصدار قانون الإجراءات الضريبية الموحد — Law No. 206 of 2020 promulgating the Unified Tax Procedures Law, Official Gazette, issue 42 bis (C), 19 October 2020 (Egyptian Tax Authority (ETA), Ministry of Finance)
--     https://www.eta.gov.eg/sites/default/files/2024-03/law_no.206-2020.pdf
--   Egyptian Tax Authority — home page, electronic invoice system notice (Egyptian Tax Authority (ETA))
--     https://eta.gov.eg/en/home
--   دليل منظومة الفاتورة الإلكترونية — Electronic Invoice System guide (Egyptian Tax Authority (ETA))
--     https://www.eta.gov.eg/ar/content/e-invoice-services
--   دليل منظومة الإيصال الإلكتروني — Electronic Receipt System guide (Egyptian Tax Authority (ETA))
--     https://www.eta.gov.eg/ar/content/e-receipt-services
--   مساحة عمل الممول — Taxpayer workspace, where the monthly return (form 10 VAT) is filed and paid electronically (Egyptian Tax Authority (ETA))
--     https://workspace.eta.gov.eg
--   IFRS Standards — Application Around the World, Jurisdictional Profile: Egypt (profile last updated 31 January 2024) (IFRS Foundation)
--     https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/egypt-ifrs-profile.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('EG', 'مصر', '0.1.0', date '2026-09-25', '20260917170000', 'community', null, null, 'fb73e63dd48ffd3c38ad9ae7dda11815ba0965239d51a048c13c55b2dc4f0737', '[{"key":"vat-law","title":"Value Added Tax Law No. (67) of 2016, as amended (consolidated text updated 15 January 2023)","publisher":"Egyptian Tax Authority (ETA), Ministry of Finance — General Department of Translation","url":"https://www.eta.gov.eg/sites/default/files/2024-02/Law-english-no.67-2016.pdf.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"vat-exec-reg","title":"Executive Regulations of Value Added Tax Law No. (67) of 2016, Minister of Finance Decree No. 66 of 2017, as amended (consolidated text updated 15 January 2023)","publisher":"Egyptian Tax Authority (ETA), Ministry of Finance — General Department of Translation","url":"https://www.eta.gov.eg/sites/default/files/2024-02/VAT-Executive-Regulations-English.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"utpl","title":"قانون رقم 206 لسنة 2020 بإصدار قانون الإجراءات الضريبية الموحد — Law No. 206 of 2020 promulgating the Unified Tax Procedures Law, Official Gazette, issue 42 bis (C), 19 October 2020","publisher":"Egyptian Tax Authority (ETA), Ministry of Finance","url":"https://www.eta.gov.eg/sites/default/files/2024-03/law_no.206-2020.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"eta-home","title":"Egyptian Tax Authority — home page, electronic invoice system notice","publisher":"Egyptian Tax Authority (ETA)","url":"https://eta.gov.eg/en/home","consulted_on":"2026-09-25","kind":"portal"},{"key":"eta-einvoice-guide","title":"دليل منظومة الفاتورة الإلكترونية — Electronic Invoice System guide","publisher":"Egyptian Tax Authority (ETA)","url":"https://www.eta.gov.eg/ar/content/e-invoice-services","consulted_on":"2026-09-25","kind":"portal"},{"key":"eta-ereceipt-guide","title":"دليل منظومة الإيصال الإلكتروني — Electronic Receipt System guide","publisher":"Egyptian Tax Authority (ETA)","url":"https://www.eta.gov.eg/ar/content/e-receipt-services","consulted_on":"2026-09-25","kind":"portal"},{"key":"workspace","title":"مساحة عمل الممول — Taxpayer workspace, where the monthly return (form 10 VAT) is filed and paid electronically","publisher":"Egyptian Tax Authority (ETA)","url":"https://workspace.eta.gov.eg","consulted_on":"2026-09-25","kind":"portal"},{"key":"eas-ifrs-profile","title":"IFRS Standards — Application Around the World, Jurisdictional Profile: Egypt (profile last updated 31 January 2024)","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/egypt-ifrs-profile.pdf","consulted_on":"2026-09-25","kind":"guidance"}]'::jsonb)
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
  ('EG', 'default', 'الدليل المحاسبي المرجعي لمصر', '{"en":"Egypt reference chart of accounts"}'::jsonb, true, 'companies', array['EG-EAS-IS', 'EG-EAS-SFP']::text[], null, 'This pack''s research found no legally mandated chart of accounts for an ordinary Egyptian company. The historic ''Uniform Accounting System'' (النظام المحاسبي الموحد) is a public-sector numbering scheme and this research pass found no text extending it to private companies generally; what the law does prescribe is the reporting framework — the Minister of Investment issues Egyptian Accounting Standards (EAS) by ministerial decree published in the Official Gazette, EAS being based on IFRS Accounting Standards but not identical to them, with a dedicated simplified standard for small and medium-sized entities effective 1 January 2016 (IFRS Foundation, Jurisdictional Profile: Egypt, ''Relevant jurisdictional authority'' and ''Application of the IFRS for SMEs Accounting Standard''). This pack''s research could not open the Arabic text of the ministerial decree that lists the EAS chart of accounts, if any; the chart below is therefore this pack''s own construction — four digits, blocked so that each range reaches one line item of the statement of financial position and the income statement below — and not a transcription of an official numbering. A reviewer should check it against a real Egyptian company''s books before it is trusted.', 'eas-ifrs-profile')
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
  ('EG', 'default', '1000', 'الصندوق', '{"en":"Petty cash"}'::jsonb, 'asset_cash', false, null, 10),
  ('EG', 'default', '1010', 'البنك - حساب جاري بالجنيه المصري', '{"en":"Bank current account — EGP"}'::jsonb, 'asset_cash', false, null, 20),
  ('EG', 'default', '1020', 'البنك - ودائع لأجل لا تتجاوز ثلاثة أشهر', '{"en":"Bank fixed deposits of three months or less"}'::jsonb, 'asset_cash', false, null, 30),
  ('EG', 'default', '1030', 'البنك - حساب بالعملة الأجنبية', '{"en":"Bank foreign currency account"}'::jsonb, 'asset_cash', false, null, 40),
  ('EG', 'default', '1035', 'شيكات تحت التحصيل', '{"en":"Cheques for collection"}'::jsonb, 'asset_cash', false, null, 45),
  ('EG', 'default', '1040', 'أموال في الطريق - تسويات بطاقات ووسائل الدفع الإلكترونية', '{"en":"Cash in transit — card and e-payment settlements"}'::jsonb, 'asset_cash', false, null, 50),
  ('EG', 'default', '1100', 'العملاء', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 60),
  ('EG', 'default', '1110', 'العملاء - مخصص الديون المشكوك في تحصيلها', '{"en":"Trade receivables — allowance for doubtful debts"}'::jsonb, 'asset_current', false, null, 70),
  ('EG', 'default', '1120', 'مدينون آخرون', '{"en":"Other receivables"}'::jsonb, 'asset_current', true, null, 80),
  ('EG', 'default', '1130', 'أرصدة مدينة لأطراف ذات علاقة', '{"en":"Amounts due from related parties"}'::jsonb, 'asset_current', false, null, 90),
  ('EG', 'default', '1140', 'عربون ودائع مدفوعة', '{"en":"Deposits paid"}'::jsonb, 'asset_current', false, null, 100),
  ('EG', 'default', '1145', 'قروض للعاملين', '{"en":"Loans to employees"}'::jsonb, 'asset_current', false, null, 105),
  ('EG', 'default', '1150', 'ضريبة القيمة المضافة على المشتريات - مدخلات', '{"en":"VAT input tax"}'::jsonb, 'asset_current', false, null, 110),
  ('EG', 'default', '1155', 'رصيد دائن لمصلحة الضرائب - ضريبة قيمة مضافة وضريبة جدول مستحقة الاسترداد', '{"en":"VAT and Table Tax refundable by the Egyptian Tax Authority — net of a filed return"}'::jsonb, 'asset_current', true, null, 120),
  ('EG', 'default', '1160', 'سلف للعاملين', '{"en":"Advances to staff"}'::jsonb, 'asset_current', false, null, 130),
  ('EG', 'default', '1200', 'مخزون بضاعة معدة للبيع', '{"en":"Inventories — goods for resale"}'::jsonb, 'asset_current', false, null, 140),
  ('EG', 'default', '1210', 'مخزون خامات ومستلزمات إنتاج', '{"en":"Inventories — raw materials"}'::jsonb, 'asset_current', false, null, 150),
  ('EG', 'default', '1220', 'مخزون إنتاج تحت التشغيل', '{"en":"Inventories — work in progress"}'::jsonb, 'asset_current', false, null, 160),
  ('EG', 'default', '1230', 'مخزون إنتاج تام', '{"en":"Inventories — finished goods"}'::jsonb, 'asset_current', false, null, 170),
  ('EG', 'default', '1300', 'استثمارات قصيرة الأجل', '{"en":"Short-term investments"}'::jsonb, 'asset_current', false, null, 180),
  ('EG', 'default', '1350', 'ضريبة الدخل مقدمة الدفع', '{"en":"Corporate tax recoverable"}'::jsonb, 'asset_current', false, null, 190),
  ('EG', 'default', '1400', 'مصروفات مدفوعة مقدمًا', '{"en":"Prepayments"}'::jsonb, 'asset_prepayments', false, null, 200),
  ('EG', 'default', '1410', 'إيرادات مستحقة غير محصلة', '{"en":"Accrued income"}'::jsonb, 'asset_prepayments', false, null, 210),
  ('EG', 'default', '1415', 'تأمين مدفوع مقدمًا', '{"en":"Prepaid insurance"}'::jsonb, 'asset_prepayments', false, null, 215),
  ('EG', 'default', '1420', 'إيجار مدفوع مقدمًا', '{"en":"Prepaid rent"}'::jsonb, 'asset_prepayments', false, null, 220),
  ('EG', 'default', '1600', 'أراضٍ ومبانٍ - التكلفة', '{"en":"Land and buildings — cost"}'::jsonb, 'asset_fixed', false, null, 230),
  ('EG', 'default', '1601', 'أراضٍ ومبانٍ - مجمع الإهلاك', '{"en":"Land and buildings — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 240),
  ('EG', 'default', '1610', 'آلات ومعدات الإنتاج - التكلفة', '{"en":"Production machinery and equipment — cost"}'::jsonb, 'asset_fixed', false, null, 250),
  ('EG', 'default', '1611', 'آلات ومعدات الإنتاج - مجمع الإهلاك', '{"en":"Production machinery and equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 260),
  ('EG', 'default', '1620', 'أثاث وتجهيزات مكتبية - التكلفة', '{"en":"Office furniture and fixtures — cost"}'::jsonb, 'asset_fixed', false, null, 270),
  ('EG', 'default', '1621', 'أثاث وتجهيزات مكتبية - مجمع الإهلاك', '{"en":"Office furniture and fixtures — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 280),
  ('EG', 'default', '1630', 'أجهزة حاسب آلي - التكلفة', '{"en":"Computer equipment — cost"}'::jsonb, 'asset_fixed', false, null, 290),
  ('EG', 'default', '1631', 'أجهزة حاسب آلي - مجمع الإهلاك', '{"en":"Computer equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 300),
  ('EG', 'default', '1640', 'وسائل نقل - التكلفة', '{"en":"Motor vehicles — cost"}'::jsonb, 'asset_fixed', false, null, 310),
  ('EG', 'default', '1641', 'وسائل نقل - مجمع الإهلاك', '{"en":"Motor vehicles — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 320),
  ('EG', 'default', '1650', 'أعمال رأسمالية تحت التنفيذ', '{"en":"Capital work in progress"}'::jsonb, 'asset_fixed', false, null, 330),
  ('EG', 'default', '1700', 'استثمارات في شركات شقيقة وتابعة', '{"en":"Investments in associates and subsidiaries"}'::jsonb, 'asset_non_current', false, null, 340),
  ('EG', 'default', '1710', 'ودائع طويلة الأجل وتأمينات مستردة', '{"en":"Long-term deposits and refundable guarantees"}'::jsonb, 'asset_non_current', false, null, 350),
  ('EG', 'default', '1730', 'شهرة المحل', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 360),
  ('EG', 'default', '1740', 'أصول غير ملموسة - التكلفة', '{"en":"Intangible assets — cost"}'::jsonb, 'asset_non_current', false, null, 370),
  ('EG', 'default', '1741', 'أصول غير ملموسة - مجمع الإطفاء', '{"en":"Intangible assets — accumulated amortisation"}'::jsonb, 'asset_non_current', false, null, 380),
  ('EG', 'default', '2000', 'الموردون', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 390),
  ('EG', 'default', '2010', 'دائنون آخرون ومصروفات مستحقة', '{"en":"Other payables and accrued expenses"}'::jsonb, 'liability_current', false, null, 400),
  ('EG', 'default', '2020', 'أرصدة دائنة لأطراف ذات علاقة', '{"en":"Amounts due to related parties"}'::jsonb, 'liability_current', false, null, 410),
  ('EG', 'default', '2030', 'أرصدة دائنة للشركاء والمساهمين', '{"en":"Amounts due to partners and shareholders"}'::jsonb, 'liability_current', false, null, 420),
  ('EG', 'default', '2040', 'عربون ودائع محصلة', '{"en":"Deposits received"}'::jsonb, 'liability_current', false, null, 430),
  ('EG', 'default', '2050', 'أجور ومرتبات مستحقة', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', false, null, 440),
  ('EG', 'default', '2060', 'التأمينات الاجتماعية مستحقة', '{"en":"Social insurance payable"}'::jsonb, 'liability_current', false, null, 450),
  ('EG', 'default', '2100', 'ضريبة القيمة المضافة على المبيعات - مخرجات', '{"en":"VAT output tax"}'::jsonb, 'liability_current', false, null, 460),
  ('EG', 'default', '2101', 'ضريبة الجدول تحت التحصيل', '{"en":"Table Tax collected"}'::jsonb, 'liability_current', false, null, 470),
  ('EG', 'default', '2110', 'مستحق لمصلحة الضرائب - ضريبة قيمة مضافة وضريبة جدول مستحقة السداد', '{"en":"VAT and Table Tax payable to the Egyptian Tax Authority — net of a filed return"}'::jsonb, 'liability_current', true, null, 480),
  ('EG', 'default', '2130', 'ضريبة الدخل مستحقة السداد', '{"en":"Corporate tax payable"}'::jsonb, 'liability_current', false, null, 490),
  ('EG', 'default', '2150', 'مخصص مكافأة نهاية الخدمة - الجزء المتداول', '{"en":"End-of-service benefits provision — current portion"}'::jsonb, 'liability_current', false, null, 500),
  ('EG', 'default', '2200', 'قروض وسحب على المكشوف قصيرة الأجل', '{"en":"Short-term loans and bank overdraft"}'::jsonb, 'liability_current', false, null, 510),
  ('EG', 'default', '2210', 'الجزء المتداول من القروض طويلة الأجل', '{"en":"Current portion of long-term loans"}'::jsonb, 'liability_current', false, null, 520),
  ('EG', 'default', '2300', 'قروض طويلة الأجل', '{"en":"Long-term loans"}'::jsonb, 'liability_non_current', false, null, 530),
  ('EG', 'default', '2350', 'مخصص مكافأة نهاية الخدمة - الجزء غير المتداول', '{"en":"End-of-service benefits provision — non-current portion"}'::jsonb, 'liability_non_current', false, null, 540),
  ('EG', 'default', '2990', 'حساب معلق', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 550),
  ('EG', 'default', '3000', 'رأس المال المصدر', '{"en":"Issued share capital"}'::jsonb, 'equity', false, null, 560),
  ('EG', 'default', '3010', 'احتياطي قانوني', '{"en":"Statutory reserve"}'::jsonb, 'equity', false, null, 570),
  ('EG', 'default', '3020', 'احتياطيات أخرى', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 580),
  ('EG', 'default', '3025', 'احتياطي إعادة تقييم الأصول', '{"en":"Asset revaluation reserve"}'::jsonb, 'equity', false, null, 585),
  ('EG', 'default', '3030', 'فروق ترجمة عملات أجنبية', '{"en":"Foreign currency translation reserve"}'::jsonb, 'equity', false, null, 590),
  ('EG', 'default', '3200', 'أرباح مرحلة', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 600),
  ('EG', 'default', '3210', 'توزيعات أرباح', '{"en":"Dividends paid"}'::jsonb, 'equity_retained', false, null, 610),
  ('EG', 'default', '4000', 'مبيعات بضاعة', '{"en":"Sales of goods"}'::jsonb, 'income', false, null, 620),
  ('EG', 'default', '4010', 'إيرادات خدمات', '{"en":"Sales of services"}'::jsonb, 'income', false, null, 630),
  ('EG', 'default', '4020', 'مبيعات تصدير', '{"en":"Export sales"}'::jsonb, 'income', false, null, 640),
  ('EG', 'default', '4030', 'إيرادات إيجارية', '{"en":"Rental income"}'::jsonb, 'income', false, null, 650),
  ('EG', 'default', '4700', 'أرباح فروق عملة محققة', '{"en":"Realised foreign exchange gain"}'::jsonb, 'income_other', false, null, 660),
  ('EG', 'default', '4710', 'أرباح فروق عملة غير محققة', '{"en":"Unrealised foreign exchange gain"}'::jsonb, 'income_other', false, null, 670),
  ('EG', 'default', '4750', 'أرباح بيع أصول ثابتة', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 680),
  ('EG', 'default', '4790', 'إيرادات أخرى', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 690),
  ('EG', 'default', '5000', 'تكلفة البضاعة المباعة', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('EG', 'default', '5010', 'مصروفات نقل وتخليص جمركي', '{"en":"Freight and customs clearance"}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('EG', 'default', '5020', 'أعمال مقاولي الباطن', '{"en":"Subcontractor costs"}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('EG', 'default', '5030', 'مردودات ومسموحات مشتريات', '{"en":"Purchase returns and allowances"}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('EG', 'default', '6100', 'أجور ومرتبات', '{"en":"Salaries and wages"}'::jsonb, 'expense', false, null, 740),
  ('EG', 'default', '6110', 'مخصص مكافأة نهاية الخدمة عن السنة', '{"en":"End-of-service benefits charge for the year"}'::jsonb, 'expense', false, null, 750),
  ('EG', 'default', '6115', 'مساهمة الشركة في التأمينات الاجتماعية', '{"en":"Employer''s social insurance contribution"}'::jsonb, 'expense', false, null, 755),
  ('EG', 'default', '6120', 'التأمين الصحي للعاملين', '{"en":"Staff health insurance"}'::jsonb, 'expense', false, null, 760),
  ('EG', 'default', '6130', 'مصروفات تدريب وتوظيف', '{"en":"Recruitment and training"}'::jsonb, 'expense', false, null, 770),
  ('EG', 'default', '6200', 'إيجارات', '{"en":"Rent"}'::jsonb, 'expense', false, null, 780),
  ('EG', 'default', '6210', 'مرافق - كهرباء ومياه وغاز', '{"en":"Utilities — electricity, water and gas"}'::jsonb, 'expense', false, null, 790),
  ('EG', 'default', '6220', 'أدوات ومطبوعات مكتبية', '{"en":"Office supplies and printing"}'::jsonb, 'expense', false, null, 800),
  ('EG', 'default', '6230', 'نظم معلومات وبرمجيات', '{"en":"IT systems and software"}'::jsonb, 'expense', false, null, 810),
  ('EG', 'default', '6240', 'صيانة وإصلاحات', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 820),
  ('EG', 'default', '6300', 'انتقالات وسفر', '{"en":"Travel"}'::jsonb, 'expense', false, null, 830),
  ('EG', 'default', '6310', 'ضيافة وعلاقات عامة', '{"en":"Entertainment and public relations"}'::jsonb, 'expense', false, null, 840),
  ('EG', 'default', '6320', 'مصروفات تشغيل وسائل النقل', '{"en":"Motor vehicle running costs"}'::jsonb, 'expense', false, null, 850),
  ('EG', 'default', '6400', 'أتعاب مهنية واستشارية', '{"en":"Professional and consultancy fees"}'::jsonb, 'expense', false, null, 860),
  ('EG', 'default', '6410', 'مصروفات بنكية', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 870),
  ('EG', 'default', '6420', 'تأمين', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 880),
  ('EG', 'default', '6430', 'دعاية وإعلان', '{"en":"Marketing and advertising"}'::jsonb, 'expense', false, null, 890),
  ('EG', 'default', '6435', 'اشتراكات وعضويات', '{"en":"Subscriptions and memberships"}'::jsonb, 'expense', false, null, 895),
  ('EG', 'default', '6440', 'رسوم ورخص حكومية', '{"en":"Government fees and licences"}'::jsonb, 'expense', false, null, 900),
  ('EG', 'default', '6500', 'مصروف إهلاك', '{"en":"Depreciation charge"}'::jsonb, 'expense_depreciation', false, null, 910),
  ('EG', 'default', '6510', 'مصروف إطفاء', '{"en":"Amortisation charge"}'::jsonb, 'expense_depreciation', false, null, 920),
  ('EG', 'default', '6900', 'ضريبة الجدول غير القابلة للخصم', '{"en":"Non-deductible Table Tax"}'::jsonb, 'expense', false, null, 930),
  ('EG', 'default', '6950', 'خسائر فروق عملة محققة', '{"en":"Realised foreign exchange loss"}'::jsonb, 'expense', false, null, 940),
  ('EG', 'default', '6955', 'خسائر فروق عملة غير محققة', '{"en":"Unrealised foreign exchange loss"}'::jsonb, 'expense', false, null, 950),
  ('EG', 'default', '6960', 'خسائر بيع أصول ثابتة', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 960),
  ('EG', 'default', '6990', 'فروق تقريب', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 970),
  ('EG', 'default', '7100', 'فوائد وأعباء تمويلية', '{"en":"Interest and finance charges"}'::jsonb, 'expense', false, null, 980),
  ('EG', 'default', '8000', 'مصروف ضريبة الدخل عن السنة', '{"en":"Corporate tax charge for the year"}'::jsonb, 'expense', false, null, 990)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('EG', 'BNK', 'البنك', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('EG', 'CSH', 'الصندوق', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('EG', 'GEN', 'دفتر اليومية العامة', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('EG', 'OPN', 'أرصدة افتتاحية', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('EG', 'PUR', 'دفتر يومية المشتريات', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('EG', 'SAL', 'دفتر يومية المبيعات', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('EG', 'EG-P-CAPEQ', 'شراء آلات ومعدات إنتاج، معدل مخفض 5%', '{"en":"Purchase of production machinery and equipment, reduced rate 5%"}'::jsonb, 'A purchase of machinery and equipment, imported or bought locally, for use in manufacturing a commodity or providing a service.', 'percent', 5, 'purchase', 'domestic', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 3, second paragraph (5% rate); article 30, item 4: the tax previously paid on machines and equipment used in producing a taxable commodity or service is refunded upon filing the first tax return — unless the buyer''s licensed activity is itself buses or passenger cars — ''without prejudice to the registrant''s entitlement to tax refund'' (Executive Regulations, article 4(2)). Reported like an ordinary recoverable purchase, in box f1/f2.', 'S', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-P-EXEMPT', 'شراء سلع وخدمات معفاة', '{"en":"Purchase, exempt goods and services"}'::jsonb, 'A purchase of a good or a service on the list of goods and services exempted from VAT — no tax is charged and none is deductible.', 'percent', 0, 'purchase', 'exempt', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 22, third paragraph, item 3: the deduction of article 22 does not apply to ''exempted goods and services'' — there is no input tax on an exempt purchase to begin with, since the exempted supplier charges none.', 'E', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-P-IMPORT', 'استيراد سلع، ضريبة تحصّل عند الإفراج الجمركي', '{"en":"Import of goods, tax collected on customs release"}'::jsonb, 'Imported goods, taxed at the point Customs releases them, regardless of the purpose of import.', 'percent', 14, 'purchase', 'import', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 5, second paragraph: ''Imported goods shall be taxed... in the customs release stage.'' Article 31, second paragraph: ''Tax on imported goods shall be paid upon release by Customs Authority according to procedures set for payment of customs duties'' — collected at the border and not self-assessed on the return, unlike an imported service. The importer then deducts it as an ordinary recoverable input under article 22, in box f1/f2.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-P-IMPSVC', 'شراء خدمة مستوردة من الخارج، خضوع عكسي', '{"en":"Purchase of a service imported from abroad, reverse charge"}'::jsonb, 'A service rendered in Egypt by a non-resident with no permanent establishment here and no Egyptian registration, self-assessed by the Egyptian beneficiary.', 'percent', 14, 'purchase', 'foreign_services_received', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 5, third paragraph: ''Imported services shall be taxed upon rendering such services to service recipients in Egypt regardless of service rendering method.'' Executive Regulations, article 32: where a non-resident not registered in ETA sells a service in Egypt to a registered person, ''the beneficiary of such service shall calculate and pay the due tax to ETA within 30 days as of selling date'' unless the non-resident is itself registered under the streamlined supplier registration system. The beneficiary self-assesses the tax it would otherwise have been charged, and recovers it under the same conditions as any other input, factor -100 on the output posting netting the self-assessment to zero on the amount due.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('EG', 'EG-P-STD', 'شراء، معدل قياسي 14%، ضريبة قابلة للخصم', '{"en":"Purchase, standard rate 14%, deductible"}'::jsonb, 'A domestic purchase taxed at the standard rate, whose input tax the registrant deducts against the tax due on its own sales.', 'percent', 14, 'purchase', 'domestic', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 22, first paragraph: a registrant deducts, within limits and conditions the Executive Regulations set, ''the tax previously paid or charged on their returned sales and inputs... at all phases of distribution.'' Executive Regulations, article 5, item 3: inputs are declared in the tax return of the period the purchase falls in.', 'S', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-P-TABLETAX-PROF', 'شراء خدمات مهنية واستشارية، ضريبة جدول غير قابلة للخصم', '{"en":"Purchase of professional and consultancy services, non-deductible Table Tax"}'::jsonb, 'The buyer''s side of EG-S-TABLETAX-PROF: Table Tax charged on professional and consultancy services, which is not VAT and is not deductible from VAT due, so it lands on the cost of the service bought.', 'percent', 10, 'purchase', 'not_subject', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 22, third paragraph, item 1: the deduction of article 22 does not apply to ''Table Tax on goods and services, whether taxable as they are or as inputs of taxable goods and services, unless otherwise provided by a special provision herein.'' No special provision reaches professional and consultancy services, so the Table Tax the buyer is charged is a cost, not an input: `recoverable: false`, no account of its own, landing on the account of the expense line it taxes.', null, null, 120, 'other', false, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-S-CAPEQ', 'بيع آلات ومعدات إنتاج، معدل مخفض 5%', '{"en":"Sale of production machinery and equipment, reduced rate 5%"}'::jsonb, 'A sale of machinery and equipment imported or bought on the local market for use in manufacturing a commodity or providing a service — the buyer''s production line, not a bus or a passenger car.', 'percent', 5, 'sale', 'domestic', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 3, second paragraph: ''tax on machines and equipment used in manufacturing a commodity or provision of a service shall be 5% except for buses and passenger cars.'' Executive Regulations, article 4(2)-(4): the reduced rate reaches whole production lines even where supplied in parts, and spare parts of such machines are taxed at the standard rate instead (article 4(4)). Reported the same way as a standard sale, in box a1/a2: neither the law nor the Executive Regulations name a separate box for it.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('EG', 'EG-S-EXEMPT', 'بيع، سلع وخدمات معفاة', '{"en":"Sale, exempt goods and services"}'::jsonb, 'A sale of a commodity or a service on the list of goods and services exempted from VAT annexed to the Law — food staples, agricultural produce, water, healthcare, education, financial and insurance services, residential land and housing among fifty-eight items.', 'percent', 0, 'sale', 'exempt', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 1, definition of ''Exempted Goods and Services'' — ''goods and services included in the exemption lists attached hereto'' — and the List of Goods and Services Exempted from VAT annexed to the Law, items 1 to 58 (milk and infant food, bread, meat, fish, agricultural produce, water distribution, crude oil and natural gas, banking and insurance, healthcare, education, residential and agricultural land, and the rest of the list). One code covers the whole list: this pack''s golden scenario exercises item 26, notebooks, books, educational booklets, newspapers and magazines.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-S-EXPORT', 'بيع، تصدير، معدل صفر', '{"en":"Sale, export, zero rate"}'::jsonb, 'A commodity or a service exported abroad, following the Customs procedures stipulated for an export.', 'percent', 0, 'sale', 'export', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 3, last paragraph: ''goods and services exported under the terms and conditions stipulated by the Executive Regulations shall be zero-rated.'' Executive Regulations, article 5, First: the exporter follows Customs export procedures and keeps, for five years, the export certificate the Customs Authority issues or an equivalent official certificate; a service is proved exported by the service contract or an equivalent, a copy of the tax invoice detailing the service, and proof that payment reached Egypt by bank transfer through a bank supervised by the Central Bank of Egypt.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-S-FREEZONE', 'بيع لمشروعات المناطق الحرة، معدل صفر', '{"en":"Sale to a free zone project, zero rate"}'::jsonb, 'Goods or services supplied to a project of a free zone, a free city or a free market, for the authorised business operations it carries out there — other than a passenger car.', 'percent', 0, 'sale', 'domestic', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 6, second paragraph: ''goods and services supplied to such projects for carrying out related authorised business operations within the free zones, cities and markets except for passenger cars shall be zero-rated.'' Executive Regulations, article 9, Second (as replaced by Ministerial Decree No. 24 of 2023): the registrant seller keeps the invoice of the goods sold to the free zone, a letter of the General Authority for Free Zones and Investments (GAFI) or the General Authority for the Economic Zone confirming the goods or services are necessary to the licensed project, and a customs export certificate (form 13 Customs). Treated as `domestic` and not `export`: the supply does not leave Egypt''s territory, only its customs area.', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-exec-reg', null, null, null, null),
  ('EG', 'EG-S-STD', 'بيع، معدل قياسي 14%', '{"en":"Sale, standard rate 14%"}'::jsonb, 'A domestic sale of a taxable commodity or service, not on the Table, not zero-rated and not exempt.', 'percent', 14, 'sale', 'domestic', date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 3, first paragraph: the standard rate is 13% for fiscal year 2016/2017 and 14% as of the beginning of fiscal year 2017/2018, of which 1% is allocated to social justice spending programmes. Executive Regulations, article 4(1) repeats the same two rates and dates.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('EG', 'EG-S-TABLETAX-PROF', 'بيع خدمات مهنية واستشارية، ضريبة جدول فقط 10%', '{"en":"Sale of professional and consultancy services, Table Tax only 10%"}'::jsonb, 'Professional and consultancy services, item First:12 of the Table attached to the Law — a service bearing Table Tax alone, and no VAT.', 'percent', 10, 'sale', 'not_subject', date '2017-07-01', null, 'Table attached to the VAT Law, section ''First — Goods and Services subject only to Table Tax'', item 12: ''Professional and consultancy services'', tax rate 10% of value. VAT Law, article 2, first paragraph excludes a Table item from the general VAT charge ''unless otherwise enumerated in the attached table''; item 12 carries no such exception, so the service bears Table Tax and no VAT — `not_subject` for VAT purposes, and reported on this same monthly return under article 31(a) of the Unified Tax Procedures Law, which covers ''VAT, and Table Tax due or either, as applicable''. `kind: other`, because Table Tax is a distinct tax stacked on nothing here, not a VAT rate.', null, null, 60, 'other', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null)
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
    ('EG-P-CAPEQ', 'invoice', 'base', 100, null, 'f1', array['f1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-P-CAPEQ', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-P-CAPEQ', 'credit_note', 'base', 100, null, 'f1', array['f1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-P-CAPEQ', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'EG-VAT-RETURN', 20),
    ('EG-P-IMPORT', 'invoice', 'base', 100, null, 'f1', array['f1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-P-IMPORT', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-P-IMPORT', 'credit_note', 'base', 100, null, 'f1', array['f1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-P-IMPORT', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'EG-VAT-RETURN', 20),
    ('EG-P-IMPSVC', 'invoice', 'base', 100, null, 'e1', array['e1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-P-IMPSVC', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-P-IMPSVC', 'invoice', 'tax', -100, '2100', 'e2', array['e2']::text[], 100, 'EG-VAT-RETURN', 30),
    ('EG-P-IMPSVC', 'credit_note', 'base', 100, null, 'e1', array['e1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-P-IMPSVC', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'EG-VAT-RETURN', 20),
    ('EG-P-IMPSVC', 'credit_note', 'tax', -100, '2100', 'e2', array['e2']::text[], -100, 'EG-VAT-RETURN', 30),
    ('EG-P-STD', 'invoice', 'base', 100, null, 'f1', array['f1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-P-STD', 'invoice', 'tax', 100, '1150', 'f2', array['f2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-P-STD', 'credit_note', 'base', 100, null, 'f1', array['f1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-P-STD', 'credit_note', 'tax', 100, '1150', 'f2', array['f2']::text[], -100, 'EG-VAT-RETURN', 20),
    ('EG-P-TABLETAX-PROF', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('EG-P-TABLETAX-PROF', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('EG-P-TABLETAX-PROF', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('EG-P-TABLETAX-PROF', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('EG-S-CAPEQ', 'invoice', 'base', 100, null, 'a1', array['a1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-S-CAPEQ', 'invoice', 'tax', 100, '2100', 'a2', array['a2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-S-CAPEQ', 'credit_note', 'base', 100, null, 'a1', array['a1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-S-CAPEQ', 'credit_note', 'tax', 100, '2100', 'a2', array['a2']::text[], -100, 'EG-VAT-RETURN', 20),
    ('EG-S-EXEMPT', 'invoice', 'base', 100, null, 'c', array['c']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-S-EXEMPT', 'credit_note', 'base', 100, null, 'c', array['c']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-S-EXPORT', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-S-EXPORT', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-S-FREEZONE', 'invoice', 'base', 100, null, 'b', array['b']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-S-FREEZONE', 'credit_note', 'base', 100, null, 'b', array['b']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-S-STD', 'invoice', 'base', 100, null, 'a1', array['a1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-S-STD', 'invoice', 'tax', 100, '2100', 'a2', array['a2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-S-STD', 'credit_note', 'base', 100, null, 'a1', array['a1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-S-STD', 'credit_note', 'tax', 100, '2100', 'a2', array['a2']::text[], -100, 'EG-VAT-RETURN', 20),
    ('EG-S-TABLETAX-PROF', 'invoice', 'base', 100, null, 'd1', array['d1']::text[], 100, 'EG-VAT-RETURN', 10),
    ('EG-S-TABLETAX-PROF', 'invoice', 'tax', 100, '2101', 'd2', array['d2']::text[], 100, 'EG-VAT-RETURN', 20),
    ('EG-S-TABLETAX-PROF', 'credit_note', 'base', 100, null, 'd1', array['d1']::text[], -100, 'EG-VAT-RETURN', 10),
    ('EG-S-TABLETAX-PROF', 'credit_note', 'tax', 100, '2101', 'd2', array['d2']::text[], -100, 'EG-VAT-RETURN', 20)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'EG' and t.code = v.tax_code
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
  ('EG', 'EG-VAT-RETURN', 'الإقرار الضريبي الشهري — نموذج 10 ضريبة القيمة المضافة', array['month']::declaration_period[], 'month'::declaration_period, date '2017-07-01', null, 'VAT Law No. 67 of 2016, article 1, definitions of ''Month'' and ''Tax Period'': a calendar month, at the end of which registrants file a monthly return. Executive Regulations, the repealed text of article 16 (in force until Ministerial Decree No. 286 of 2021) named the form ''form No. 10 VAT''; this pack''s research could not open a directly-fetchable, currently-in-force text or screen naming the live boxes of that form, so the boxes below are built from the minimum content the two texts this pack could open actually require: what a registrant''s tax summary book has to hold (Executive Regulations, the repealed text of article 14) and what the monthly return has to declare under article 31(a) of the Unified Tax Procedures Law — ''VAT, and Table Tax due or either, as applicable.'' A reviewer who has filed on the live ETA taxpayer workspace should check this first: this pack''s box letters are its own, not a transcription of the portal''s on-screen fields.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'قانون رقم 206 لسنة 2020، المادة 31(أ): ''على كل مكلف أن يقدم للمأمورية المختصة إقرارًا شهريًا عن الضريبة على القيمة المضافة، وضريبة الجدول المستحقة أو إحداهما، بحسب الأحوال... خلال الشهر التالي لانتهاء الفترة الضريبية'' — Unified Tax Procedures Law No. 206 of 2020, article 31(a): every taxpayer files a monthly return for VAT and/or Table Tax due, on the form prepared for the purpose, during the month following the end of the tax period; a return is due even where no taxable sale or service was made in the period. Article 32 makes payment due ''on the same day'' the return is filed electronically, so the return and the payment share one deadline: the last day of the month that follows the tax period. This replaced the two-month deadline the Executive Regulations'' own article 16 stated before its repeal by Ministerial Decree No. 286 of 2021, in line with Law No. 206 of 2020.', 'utpl', null)
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
  ('EG', 'EG-VAT-RETURN', 'a1', 'base', 'قيمة المبيعات الخاضعة للمعدل القياسي أو المخفض', '{"en":"Value of supplies at the standard or reduced rate"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Value of taxable supplies at the standard rate (14%) or at the reduced rate on production machinery and equipment (5%), VAT Law article 3.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'a2', 'tax', 'الضريبة المحصلة على قيمة الصندوق a1', '{"en":"Tax charged on box a1"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Output tax charged on box a1.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'b', 'base', 'قيمة المبيعات الخاضعة لمعدل الصفر', '{"en":"Value of zero-rated supplies"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, article 3 last paragraph (export) and article 6 (free zones, free cities and free markets), zero-rated supplies.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'c', 'base', 'قيمة المبيعات المعفاة', '{"en":"Value of exempt supplies"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, article 1 definition of ''Exempted Goods and Services'' and the List of Goods and Services Exempted from VAT annexed to the Law.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'd1', 'base', 'قيمة المبيعات الخاضعة لضريبة الجدول فقط', '{"en":"Value of supplies subject only to Table Tax"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Table attached to the VAT Law, section ''First — Goods and Services subject only to Table Tax'': the value, exclusive of Table Tax, of a Table item that bears no VAT.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'd2', 'tax', 'ضريبة الجدول المستحقة على قيمة الصندوق d1', '{"en":"Table Tax due on box d1"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Table Tax due on box d1, VAT Law article 36.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'e1', 'base', 'قيمة الخدمات المستوردة الخاضعة للخضوع العكسي', '{"en":"Value of imported services subject to the reverse charge"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, article 5, third paragraph, and Executive Regulations article 32: the value of a service rendered by a non-resident, self-assessed by the Egyptian beneficiary.', 'vat-exec-reg'),
  ('EG', 'EG-VAT-RETURN', 'e2', 'tax', 'الضريبة المحتسبة ذاتيًا على قيمة الصندوق e1', '{"en":"Tax self-assessed on box e1"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The tax the beneficiary of an imported service calculates and pays under Executive Regulations article 32; not a separate clause of the law, this box is this pack''s own addition so the value in e1 is not reported without the tax it carries — the same reasoning packs/ae records for its own box g2.', 'vat-exec-reg'),
  ('EG', 'EG-VAT-RETURN', 'f1', 'base', 'قيمة المشتريات التي تخصم عنها الضريبة', '{"en":"Value of purchases whose tax is deducted"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, article 22: the value of inputs, whether local, imported or self-assessed, whose input tax the registrant seeks to deduct.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'f2', 'tax', 'الضريبة القابلة للخصم على قيمة الصندوق f1، متضمنة نصيب الصندوق e2 القابل للخصم', '{"en":"Deductible tax on box f1, including the recoverable share of box e2"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VAT Law, article 22: deductible input tax on box f1, including the recoverable share of the self-assessed tax of box e2.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'h', 'total', 'إجمالي الضريبة المستحقة عن الفترة', '{"en":"Total tax due for the period"}'::jsonb, 110, null, array['a2', 'd2', 'e2']::text[], '{}'::text[], null, null, false, false, null, 'The period''s total VAT and Table Tax due, before deduction of input tax.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'i', 'total', 'إجمالي الضريبة القابلة للخصم عن الفترة', '{"en":"Total deductible tax for the period"}'::jsonb, 120, null, array['f2']::text[], '{}'::text[], null, null, false, false, null, 'The period''s total deductible input tax.', 'vat-law'),
  ('EG', 'EG-VAT-RETURN', 'j', 'total', 'صافي الضريبة المستحقة السداد أو رصيد الاسترداد', '{"en":"Net tax payable or credit balance"}'::jsonb, 130, null, array['h']::text[], array['i']::text[], null, null, false, false, null, 'VAT Law, article 22, third paragraph, item 3: a non-deductible amount is carried forward to the following tax period until it is fully deducted; article 30, item 3, entitles the registrant to a refund of a credit balance that has lasted more than six successive tax periods. No floor at zero: a negative figure is the credit balance the law carries forward or, past six periods, lets the registrant reclaim.', 'vat-law')
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
  ('EG-EAS-IS', 'EG', 'default', 'قائمة الدخل — طبقًا لمعيار المنشآت الصغيرة والمتوسطة من معايير المحاسبة المصرية', 'income_statement', 'EG-EAS-SME', date '1970-01-01', null, 'Same source and same gap as EG-EAS-SFP above: built on the minimum line items of the IFRS for SMEs Accounting Standard, section 5, by nature of expense, which a small company''s ledger holds without an allocation to functions.', 'eas-ifrs-profile'),
  ('EG-EAS-SFP', 'EG', 'default', 'قائمة المركز المالي — طبقًا لمعيار المنشآت الصغيرة والمتوسطة من معايير المحاسبة المصرية', 'balance_sheet', 'EG-EAS-SME', date '1970-01-01', null, 'The Minister of Investment issues Egyptian Accounting Standards (EAS) by ministerial decree published in the Official Gazette; EAS, current version issued in July 2015 and amended in 2019 and 2023, is close to IFRS Accounting Standards but not identical, and includes a dedicated set of requirements for small and medium-sized entities effective 1 January 2016 (IFRS Foundation, Jurisdictional Profile: Egypt). This pack''s research could not open the Arabic decree text listing the small-and-medium-entities standard''s own line items, so the lines below are built, as packs/ae and packs/sa build theirs where no country text could be opened, on the minimum line items the general IFRS for SMEs Accounting Standard, section 4, asks for — current and non-current apart. This is the first thing a reviewer familiar with the actual EAS text should check.', 'eas-ifrs-profile')
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
  ('EG-EAS-IS', '1', null, 'الإيرادات', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '2', null, 'إيرادات أخرى', '{"en":"Other income"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '3', null, 'تكلفة المبيعات', '{"en":"Cost of sales"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '4', null, 'تكلفة العاملين', '{"en":"Employee benefits expense"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '5', null, 'الإهلاك والإطفاء', '{"en":"Depreciation and amortisation"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '6', null, 'مصروفات تشغيل أخرى', '{"en":"Other operating expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '7', null, 'أعباء تمويلية', '{"en":"Finance costs"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '8', null, 'الربح قبل ضريبة الدخل', '{"en":"Profit before corporate tax"}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('EG-EAS-IS', '9', null, 'مصروف ضريبة الدخل', '{"en":"Corporate tax expense"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-IS', '10', null, 'صافي ربح السنة', '{"en":"Profit for the year"}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('EG-EAS-SFP', 'CA', null, 'الأصول المتداولة', '{"en":"Current assets"}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CA.1', 'CA', 'النقدية وما في حكمها', '{"en":"Cash and cash equivalents"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CA.2', 'CA', 'العملاء ومدينون آخرون', '{"en":"Trade and other receivables"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'ضريبة القيمة المضافة المدخلات والرصيد المستحق من مصلحة الضرائب يعرضان هنا.', null),
  ('EG-EAS-SFP', 'CA.3', 'CA', 'المخزون', '{"en":"Inventories"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CA.4', 'CA', 'استثمارات قصيرة الأجل', '{"en":"Short-term investments"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CA.5', 'CA', 'أصول ضريبية جارية', '{"en":"Current tax assets"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CA.6', 'CA', 'مصروفات مدفوعة مقدمًا وإيرادات مستحقة', '{"en":"Prepayments and accrued income"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCA', null, 'الأصول غير المتداولة', '{"en":"Non-current assets"}'::jsonb, 80, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCA.1', 'NCA', 'الأصول الثابتة', '{"en":"Property, plant and equipment"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCA.2', 'NCA', 'استثمارات في شركات شقيقة وتابعة', '{"en":"Investments in associates and subsidiaries"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCA.3', 'NCA', 'أصول غير متداولة أخرى', '{"en":"Other non-current assets"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCA.4', 'NCA', 'الأصول غير الملموسة', '{"en":"Intangible assets"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'TA', null, 'إجمالي الأصول', '{"en":"Total assets"}'::jsonb, 130, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CL', null, 'الخصوم المتداولة', '{"en":"Current liabilities"}'::jsonb, 140, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CL.1', 'CL', 'الموردون ودائنون آخرون', '{"en":"Trade and other payables"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'ضريبة القيمة المضافة المخرجات وضريبة الجدول تحت التحصيل والمستحق لمصلحة الضرائب تعرض هنا.', null),
  ('EG-EAS-SFP', 'CL.2', 'CL', 'قروض قصيرة الأجل', '{"en":"Short-term loans"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CL.3', 'CL', 'خصوم ضريبية جارية', '{"en":"Current tax liabilities"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'CL.4', 'CL', 'مخصصات متداولة', '{"en":"Current provisions"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCL', null, 'الخصوم غير المتداولة', '{"en":"Non-current liabilities"}'::jsonb, 190, 1, true, array['NCL.1', 'NCL.2']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCL.1', 'NCL', 'قروض طويلة الأجل', '{"en":"Long-term loans"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NCL.2', 'NCL', 'مخصصات غير متداولة', '{"en":"Non-current provisions"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'TL', null, 'إجمالي الخصوم', '{"en":"Total liabilities"}'::jsonb, 220, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'NA', null, 'صافي الأصول', '{"en":"Net assets"}'::jsonb, 230, 1, true, array['TA']::text[], array['TL']::text[], null, 'يساوي حقوق الملكية بعد إقفال السنة، ويزيد عليها بنتيجة أعمال السنة المفتوحة قبل الإقفال.', null),
  ('EG-EAS-SFP', 'EQ', null, 'حقوق الملكية', '{"en":"Equity"}'::jsonb, 240, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'EQ.1', 'EQ', 'رأس المال', '{"en":"Share capital"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'EQ.2', 'EQ', 'الاحتياطيات', '{"en":"Reserves"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EG-EAS-SFP', 'EQ.3', 'EQ', 'الأرباح المرحلة', '{"en":"Retained earnings"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('EG-EAS-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('EG-EAS-IS', '2', 10, 'code_range', '4700', '4790', null, 'any'),
    ('EG-EAS-IS', '3', 10, 'code_range', '5000', '5030', null, 'any'),
    ('EG-EAS-IS', '4', 10, 'code_range', '6100', '6130', null, 'any'),
    ('EG-EAS-IS', '5', 10, 'code_range', '6500', '6510', null, 'any'),
    ('EG-EAS-IS', '6', 10, 'code_range', '6200', '6440', null, 'any'),
    ('EG-EAS-IS', '6', 20, 'code_range', '6900', '6990', null, 'any'),
    ('EG-EAS-IS', '7', 10, 'account_code', '7100', null, null, 'any'),
    ('EG-EAS-IS', '9', 10, 'account_code', '8000', null, null, 'any'),
    ('EG-EAS-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('EG-EAS-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('EG-EAS-SFP', 'CA.2', 20, 'account_code', '2990', null, null, 'debit'),
    ('EG-EAS-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('EG-EAS-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('EG-EAS-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('EG-EAS-SFP', 'CA.6', 10, 'code_range', '1400', '1420', null, 'any'),
    ('EG-EAS-SFP', 'NCA.1', 10, 'code_range', '1600', '1650', null, 'any'),
    ('EG-EAS-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('EG-EAS-SFP', 'NCA.3', 10, 'account_code', '1710', null, null, 'any'),
    ('EG-EAS-SFP', 'NCA.4', 10, 'code_range', '1730', '1741', null, 'any'),
    ('EG-EAS-SFP', 'CL.1', 10, 'code_range', '2000', '2060', null, 'any'),
    ('EG-EAS-SFP', 'CL.1', 20, 'code_range', '2100', '2110', null, 'any'),
    ('EG-EAS-SFP', 'CL.1', 30, 'account_code', '2990', null, null, 'credit'),
    ('EG-EAS-SFP', 'CL.2', 10, 'code_range', '2200', '2210', null, 'any'),
    ('EG-EAS-SFP', 'CL.3', 10, 'account_code', '2130', null, null, 'any'),
    ('EG-EAS-SFP', 'CL.4', 10, 'account_code', '2150', null, null, 'any'),
    ('EG-EAS-SFP', 'NCL.1', 10, 'account_code', '2300', null, null, 'any'),
    ('EG-EAS-SFP', 'NCL.2', 10, 'account_code', '2350', null, null, 'any'),
    ('EG-EAS-SFP', 'EQ.1', 10, 'account_code', '3000', null, null, 'any'),
    ('EG-EAS-SFP', 'EQ.2', 10, 'code_range', '3010', '3030', null, 'any'),
    ('EG-EAS-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('EG', 'مصر', '{"en":"Egypt"}'::jsonb, array['ar', 'en']::text[], 'EGP', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'ar', 'retained_earnings', null, null, null, 'OPN', default, default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'VAT Law No. 67 of 2016, article 1, definition of ''Tax Invoice'' (''Invoice prepared according to form issued by a decree of the Minister or his authorised representative''); the repealed text of Executive Regulations article 13, in force until Ministerial Decree No. 286 of 2021, required invoices to ''have numbers serialised according to issuance dates and free of any strikes or scratches'' — a running, date-ordered sequence rather than an explicit no-gap rule, which is why the style is `sequential` and not a gapless one. Since Ministerial Decree No. 188 of 2020 the electronic invoice/receipt system (ETA) additionally chains every accepted document to a UUID and an internal reference the seller assigns, which is a second identifier this field does not hold — see `einvoicing` below.',
  numbering_source_key          = 'vat-exec-reg',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'VAT Law No. 67 of 2016, article 1, definition of ''Sale'': ownership transfer or service provision, deemed to occur, whichever precedes, on (1) issuance of an invoice, (2) delivery of the goods or provision of the service, or (3) whole or partial payment. That is a three-way earliest test — invoice, delivery, payment — and the closed vocabulary of this field has no value for three triggers at once. `earliest_of_delivery_or_payment` is the nearest of the five and is what the rule reduces to whenever no invoice is issued ahead of delivery or payment; a supply invoiced before either is the case this approximation misses, exactly the gap packs/sa and packs/ae record for the same three-way wording in the Common VAT Agreement and in Federal Decree-Law No. 8 of 2017.',
  tax_point_source_key          = 'vat-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Electronic invoicing is obligatory in Egypt and this pack still leaves all four fields above empty, for the reason packs/sa/, packs/vn/ and packs/kr/ leave them empty: the ETA electronic invoice (B2B) and electronic receipt (B2C) systems are a clearance regime, not an exchange between two parties'' own access points — a document is submitted to ETA, which validates it against its own schema and returns a UUID and, for a business invoice, a digital signature reference before the document is valid — and none of it is an EN 16931 profile a brick of packages/formats writes, so `mandatory_from` would name a day with no `profile` to say what became obligatory on it. This pack''s research verified one fact at a directly-fetchable ETA page: ''As of April 1, 2023, no entity will be allowed to import, export or deal with the customs system except for entities that issue and deal with electronic tax invoices'' (eta.gov.eg, home page). The rollout itself was phased over several years by taxpayer size, starting with large taxpayers registered at the Large Taxpayers Centre from November 2020 under Ministerial Decision No. 188 of 2020, and reaching the last waves of ordinary VAT-registered businesses by 2023; this pack''s research could not open Ministerial Decision No. 188 of 2020 itself, nor the later wave-by-wave decisions, at a directly-fetchable official text, and does not invent the dates of intermediate waves from a secondary source. A second, separate obligation reaches business-to-consumer receipts (e-receipt), phased from 2022 and tightened by ETA Decision No. 281 of 2025 for taxpayers on a published list from 15 September 2025; this pack''s research could not open Decision No. 281 of 2025 either. `party_scheme` and `vat_scheme` stay null because Egypt is not on the Peppol participant identifier scheme list and issues no ISO 6523 identifier: what an Egyptian electronic invoice carries instead is the seller''s and buyer''s Tax Registration Numbers and the ETA-issued UUID, neither of which this pack''s fields hold. docs/international.md carries the rest of what the core cannot say about a clearance system.',
  einvoice_source_key           = 'eta-home',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'EG';
