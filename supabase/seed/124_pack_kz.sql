-- Ekwo OS — Қазақстан: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/kz at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build kz`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Қазақстан Республикасының 2025 жылғы 18 шілдедегі № 214-VIII ҚРЗ «Салық және бюджетке төленетін басқа да міндетті төлемдер туралы» кодексі (Салық кодексі), 2026 жылғы 1 қаңтардан бастап қолданысқа енгізілген (Қазақстан Республикасы Әділет министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz))
--     https://adilet.zan.kz/rus/docs/K2500000214
--   Қазақстан Республикасының 2017 жылғы 25 желтоқсандағы № 120-VI ҚРЗ «Салық және бюджетке төленетін басқа да міндетті төлемдер туралы» кодексі (Салық кодексі), 2026 жылғы 1 қаңтарда күші жойылған — 12 % мөлшерлемесінің тарихи дереккөзі (Қазақстан Республикасы Әділет министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz))
--     https://adilet.zan.kz/rus/docs/K1700000120
--   Қазақстан Республикасы Қаржы министрінің 2025 жылғы 12 қарашадағы № 695 бұйрығы «Салық есептілігінің нысандарын, оларды жасау бойынша түсіндірмені және оларды ұсыну қағидаларын бекіту туралы» — 300.00 нысаны (ҚҚС бойынша декларация) мен оның қосымшалары, 2026 жылғы 1 қаңтардан қолданыста (Қазақстан Республикасы Қаржы министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz))
--     https://adilet.zan.kz/rus/docs/V2500037390
--   Қазақстан Республикасы Қаржы министрінің 2007 жылғы 23 мамырдағы № 185 бұйрығы «Бухгалтерлік есептің үлгі шоттар жоспарын бекіту туралы» (өзгерістерімен және толықтыруларымен) (Қазақстан Республикасы Қаржы министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz))
--     https://adilet.zan.kz/rus/docs/V070004771_
--   Қазақстан Республикасының 2007 жылғы 28 ақпандағы № 234-III ҚРЗ «Бухгалтерлік есеп пен қаржылық есептілік туралы» Заңы (Қазақстан Республикасы Әділет министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz))
--     https://adilet.zan.kz/rus/docs/Z070000234_
--   IFRS Accounting Standards (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/list-of-standards/
--   Салық төлеушінің кабинеті — салық есептілігін қабылдау, соның ішінде 300.00 нысанын электрондық түрде тапсыру (Қазақстан Республикасы Қаржы министрлігінің Мемлекеттік кірістер комитеті)
--     https://cabinet.salyk.kz/
--   Электрондық шот-фактуралардың ақпараттық жүйесі (ЭШФ АЖ) — мемлекеттік клиринг порталы (Қазақстан Республикасы Қаржы министрлігінің Мемлекеттік кірістер комитеті)
--     https://esf.gov.kz/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KZ', 'Қазақстан', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'b3e717a7be93c09f675b807cbcd0bf02ca0beeee8f11ea750a5e0a871112f337', '[{"key":"tax-code-2026","title":"Қазақстан Республикасының 2025 жылғы 18 шілдедегі № 214-VIII ҚРЗ «Салық және бюджетке төленетін басқа да міндетті төлемдер туралы» кодексі (Салық кодексі), 2026 жылғы 1 қаңтардан бастап қолданысқа енгізілген","publisher":"Қазақстан Республикасы Әділет министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz)","url":"https://adilet.zan.kz/rus/docs/K2500000214","consulted_on":"2026-09-26","kind":"law"},{"key":"tax-code-2017","title":"Қазақстан Республикасының 2017 жылғы 25 желтоқсандағы № 120-VI ҚРЗ «Салық және бюджетке төленетін басқа да міндетті төлемдер туралы» кодексі (Салық кодексі), 2026 жылғы 1 қаңтарда күші жойылған — 12 % мөлшерлемесінің тарихи дереккөзі","publisher":"Қазақстан Республикасы Әділет министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz)","url":"https://adilet.zan.kz/rus/docs/K1700000120","consulted_on":"2026-09-26","kind":"law"},{"key":"reporting-order-695","title":"Қазақстан Республикасы Қаржы министрінің 2025 жылғы 12 қарашадағы № 695 бұйрығы «Салық есептілігінің нысандарын, оларды жасау бойынша түсіндірмені және оларды ұсыну қағидаларын бекіту туралы» — 300.00 нысаны (ҚҚС бойынша декларация) мен оның қосымшалары, 2026 жылғы 1 қаңтардан қолданыста","publisher":"Қазақстан Республикасы Қаржы министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz)","url":"https://adilet.zan.kz/rus/docs/V2500037390","consulted_on":"2026-09-26","kind":"form"},{"key":"coa-order-185","title":"Қазақстан Республикасы Қаржы министрінің 2007 жылғы 23 мамырдағы № 185 бұйрығы «Бухгалтерлік есептің үлгі шоттар жоспарын бекіту туралы» (өзгерістерімен және толықтыруларымен)","publisher":"Қазақстан Республикасы Қаржы министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz)","url":"https://adilet.zan.kz/rus/docs/V070004771_","consulted_on":"2026-09-26","kind":"regulation"},{"key":"accounting-law","title":"Қазақстан Республикасының 2007 жылғы 28 ақпандағы № 234-III ҚРЗ «Бухгалтерлік есеп пен қаржылық есептілік туралы» Заңы","publisher":"Қазақстан Республикасы Әділет министрлігі — «Әділет» ақпараттық-құқықтық жүйесі (adilet.zan.kz)","url":"https://adilet.zan.kz/rus/docs/Z070000234_","consulted_on":"2026-09-26","kind":"law"},{"key":"ifrs","title":"IFRS Accounting Standards","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/list-of-standards/","consulted_on":"2026-09-26","kind":"standard"},{"key":"salyk-cabinet","title":"Салық төлеушінің кабинеті — салық есептілігін қабылдау, соның ішінде 300.00 нысанын электрондық түрде тапсыру","publisher":"Қазақстан Республикасы Қаржы министрлігінің Мемлекеттік кірістер комитеті","url":"https://cabinet.salyk.kz/","consulted_on":"2026-09-26","kind":"portal"},{"key":"esf-portal","title":"Электрондық шот-фактуралардың ақпараттық жүйесі (ЭШФ АЖ) — мемлекеттік клиринг порталы","publisher":"Қазақстан Республикасы Қаржы министрлігінің Мемлекеттік кірістер комитеті","url":"https://esf.gov.kz/","consulted_on":"2026-09-26","kind":"portal"}]'::jsonb)
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
  ('KZ', 'default', 'Бухгалтерлік есептің үлгі шоттар жоспары (№ 185 бұйрық негізінде)', '{"en":"Standard chart of accounts (based on order No. 185)","ru":"Типовой план счетов бухгалтерского учета (на основе приказа № 185)"}'::jsonb, true, 'companies', array['KZ-IFRS-BS', 'KZ-IFRS-IS']::text[], null, '«Бухгалтерлік есеп пен қаржылық есептілік туралы» Заң, 2-бап және 6-бап — коммерциялық ұйымдар қаржылық есептілікті Қазақстан Республикасының аумағында қолданылатын халықаралық қаржылық есептілік стандарттарына (ХҚЕС) немесе шағын және орта бизнес субъектілері үшін ХҚЕС-ке сәйкес жасайды. Қаржы министрінің 2007 жылғы 23 мамырдағы № 185 бұйрығымен бекітілген Бухгалтерлік есептің үлгі шоттар жоспары әрбір заңды тұлға үшін міндетті (банктер мен бюджеттік мекемелерден басқа) және шоттардың төрт таңбалы кодтарын, олардың атауларын және ХҚЕС бөлімдерге бөлінуін белгілейді, бірақ нақты қаржылық қорытынды жолдарын белгілемейді — осы дестеде IFRS терминологиясына негізделген есеп беру осы дестенің өз құрастыруы, заңмен бекітілген нысан емес; қараңыз README.md.', 'coa-order-185')
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
  ('KZ', 'default', '1000', 'Ақша қаражаты', '{"en":"Cash","ru":"Денежные средства"}'::jsonb, 'asset_cash', false, null, 10),
  ('KZ', 'default', '1010', 'Кассадағы ақша қаражаты', '{"en":"Cash on hand","ru":"Денежные средства в кассе"}'::jsonb, 'asset_cash', false, '1000', 20),
  ('KZ', 'default', '1030', 'Ағымдағы банктік шоттардағы ақша қаражаты', '{"en":"Cash at current bank accounts","ru":"Денежные средства на текущих банковских счетах"}'::jsonb, 'asset_cash', false, '1000', 30),
  ('KZ', 'default', '1040', 'Корреспонденттік шоттардағы ақша қаражаты', '{"en":"Cash at correspondent accounts","ru":"Денежные средства на корреспондентских счетах"}'::jsonb, 'asset_cash', false, '1000', 40),
  ('KZ', 'default', '1060', 'Пайдалануы шектеулі ақша қаражаты', '{"en":"Cash restricted in use","ru":"Денежные средства, ограниченные в использовании"}'::jsonb, 'asset_cash', false, '1000', 50),
  ('KZ', 'default', '1100', 'Қысқа мерзімді қаржы активтері', '{"en":"Short-term financial assets","ru":"Краткосрочные финансовые активы"}'::jsonb, 'asset_current', false, null, 60),
  ('KZ', 'default', '1110', 'Амортизацияланған құн бойынша қысқа мерзімді қаржы активтері', '{"en":"Short-term financial assets at amortised cost","ru":"Краткосрочные финансовые активы, оцениваемые по амортизированной стоимости"}'::jsonb, 'asset_current', false, '1100', 70),
  ('KZ', 'default', '1130', 'Әділ құны арқылы пайда немесе зиянға танылатын қысқа мерзімді қаржы активтері', '{"en":"Short-term financial assets at fair value through profit or loss","ru":"Краткосрочные финансовые активы, оцениваемые по справедливой стоимости через прибыль или убыток"}'::jsonb, 'asset_current', false, '1100', 80),
  ('KZ', 'default', '1150', 'Алынуға тиіс қысқа мерзімді сыйақылар', '{"en":"Short-term rewards receivable","ru":"Краткосрочные вознаграждения к получению"}'::jsonb, 'asset_current', false, '1100', 90),
  ('KZ', 'default', '1200', 'Қысқа мерзімді дебиторлық берешек', '{"en":"Short-term receivables","ru":"Краткосрочная дебиторская задолженность"}'::jsonb, 'asset_current', false, null, 100),
  ('KZ', 'default', '1210', 'Сатып алушылар мен тапсырыс берушілердің қысқа мерзімді дебиторлық берешегі', '{"en":"Short-term receivables from customers","ru":"Краткосрочная дебиторская задолженность покупателей и заказчиков"}'::jsonb, 'asset_receivable', true, '1200', 110),
  ('KZ', 'default', '1230', 'Қауымдасқан және бірлескен ұйымдардың қысқа мерзімді дебиторлық берешегі', '{"en":"Short-term receivables from associates and joint ventures","ru":"Краткосрочная дебиторская задолженность ассоциированных и совместных организаций"}'::jsonb, 'asset_current', false, '1200', 120),
  ('KZ', 'default', '1250', 'Жұмыскерлердің қысқа мерзімді дебиторлық берешегі', '{"en":"Short-term receivables from employees","ru":"Краткосрочная дебиторская задолженность работников"}'::jsonb, 'asset_current', false, '1200', 130),
  ('KZ', 'default', '1260', 'Жалдау бойынша қысқа мерзімді дебиторлық берешек', '{"en":"Short-term lease receivables","ru":"Краткосрочная дебиторская задолженность по аренде"}'::jsonb, 'asset_current', false, '1200', 140),
  ('KZ', 'default', '1270', 'Басқа қысқа мерзімді дебиторлық берешек', '{"en":"Other short-term receivables","ru":"Прочая краткосрочная дебиторская задолженность"}'::jsonb, 'asset_current', false, '1200', 150),
  ('KZ', 'default', '1280', 'Қысқа мерзімді дебиторлық берешектің құнсыздануынан болатын бағалау резерві', '{"en":"Provision for impairment of short-term receivables","ru":"Оценочный резерв под убытки от обесценения краткосрочной дебиторской задолженности"}'::jsonb, 'asset_current', false, '1200', 160),
  ('KZ', 'default', '1300', 'Қорлар', '{"en":"Inventories","ru":"Запасы"}'::jsonb, 'asset_current', false, null, 170),
  ('KZ', 'default', '1310', 'Шикізат пен материалдар', '{"en":"Raw materials and supplies","ru":"Сырье и материалы"}'::jsonb, 'asset_current', false, '1300', 180),
  ('KZ', 'default', '1320', 'Дайын өнім', '{"en":"Finished goods","ru":"Готовая продукция"}'::jsonb, 'asset_current', false, '1300', 190),
  ('KZ', 'default', '1330', 'Тауарлар', '{"en":"Goods","ru":"Товары"}'::jsonb, 'asset_current', false, '1300', 200),
  ('KZ', 'default', '1340', 'Аяқталмаған өндіріс', '{"en":"Work in progress","ru":"Незавершенное производство"}'::jsonb, 'asset_current', false, '1300', 210),
  ('KZ', 'default', '1350', 'Басқа қорлар', '{"en":"Other inventories","ru":"Прочие запасы"}'::jsonb, 'asset_current', false, '1300', 220),
  ('KZ', 'default', '1400', 'Ағымдағы салықтық активтер', '{"en":"Current tax assets","ru":"Текущие налоговые активы"}'::jsonb, 'asset_current', false, null, 230),
  ('KZ', 'default', '1410', 'Корпоративтік табыс салығы бойынша ағымдағы салықтық актив', '{"en":"Current tax asset for corporate income tax","ru":"Текущий налоговый актив по корпоративному подоходному налогу"}'::jsonb, 'asset_current', false, '1400', 240),
  ('KZ', 'default', '1420', 'Қосылған құн салығы бойынша ағымдағы салықтық актив', '{"en":"Current tax asset for VAT","ru":"Текущий налоговый актив по налогу на добавленную стоимость"}'::jsonb, 'asset_current', false, '1400', 250),
  ('KZ', 'default', '1421', 'Есептелген (өтелетін) қосылған құн салығы', '{"en":"Accrued (recoverable) VAT — posting account","ru":"Начисленный (возмещаемый) налог на добавленную стоимость"}'::jsonb, 'asset_current', false, '1420', 260),
  ('KZ', 'default', '1422', 'Бюджетпен қосылған құн салығы бойынша есеп айырысу (өтелуге тиіс)', '{"en":"Settlement with the budget for VAT (receivable)","ru":"Расчеты с бюджетом по налогу на добавленную стоимость (к возмещению)"}'::jsonb, 'asset_current', true, '1420', 270),
  ('KZ', 'default', '1430', 'Бюджетке төленетін басқа да міндетті төлемдер бойынша ағымдағы салықтық актив', '{"en":"Current tax asset for other mandatory budget payments","ru":"Текущий налоговый актив по прочим обязательным платежам в бюджет"}'::jsonb, 'asset_current', false, '1400', 280),
  ('KZ', 'default', '1700', 'Басқа қысқа мерзімді активтер', '{"en":"Other current assets","ru":"Прочие краткосрочные активы"}'::jsonb, 'asset_current', false, null, 290),
  ('KZ', 'default', '1710', 'Берілген қысқа мерзімді аванстар', '{"en":"Short-term advances paid","ru":"Краткосрочные авансы выданные"}'::jsonb, 'asset_current', false, '1700', 300),
  ('KZ', 'default', '1720', 'Болашақ кезең шығыстары', '{"en":"Prepaid expenses","ru":"Расходы будущих периодов"}'::jsonb, 'asset_prepayments', false, '1700', 310),
  ('KZ', 'default', '2000', 'Ұзақ мерзімді қаржы активтері', '{"en":"Non-current financial assets","ru":"Долгосрочные финансовые активы"}'::jsonb, 'asset_non_current', false, null, 320),
  ('KZ', 'default', '2010', 'Амортизацияланған құн бойынша ұзақ мерзімді қаржы активтері', '{"en":"Non-current financial assets at amortised cost","ru":"Долгосрочные финансовые активы по амортизированной стоимости"}'::jsonb, 'asset_non_current', false, '2000', 330),
  ('KZ', 'default', '2050', 'Алынуға тиіс ұзақ мерзімді сыйақылар', '{"en":"Long-term rewards receivable","ru":"Долгосрочные вознаграждения к получению"}'::jsonb, 'asset_non_current', false, '2000', 340),
  ('KZ', 'default', '2100', 'Ұзақ мерзімді дебиторлық берешек', '{"en":"Non-current receivables","ru":"Долгосрочная дебиторская задолженность"}'::jsonb, 'asset_non_current', false, null, 350),
  ('KZ', 'default', '2110', 'Сатып алушылар мен тапсырыс берушілердің ұзақ мерзімді дебиторлық берешегі', '{"en":"Non-current receivables from customers","ru":"Долгосрочная задолженность покупателей и заказчиков"}'::jsonb, 'asset_non_current', false, '2100', 360),
  ('KZ', 'default', '2200', 'Инвестициялар', '{"en":"Investments","ru":"Инвестиции"}'::jsonb, 'asset_non_current', false, null, 370),
  ('KZ', 'default', '2210', 'Үлестік қатысу әдісі бойынша есептелетін инвестициялар', '{"en":"Investments accounted for using the equity method","ru":"Инвестиции, учитываемые методом долевого участия"}'::jsonb, 'asset_non_current', false, '2200', 380),
  ('KZ', 'default', '2220', 'Бастапқы құны бойынша есептелетін инвестициялар', '{"en":"Investments accounted for at cost","ru":"Инвестиции, учитываемые по первоначальной стоимости"}'::jsonb, 'asset_non_current', false, '2200', 390),
  ('KZ', 'default', '2300', 'Инвестициялық мүлік', '{"en":"Investment property","ru":"Инвестиционное имущество"}'::jsonb, 'asset_non_current', false, null, 400),
  ('KZ', 'default', '2310', 'Инвестициялық мүлік', '{"en":"Investment property","ru":"Инвестиционное имущество"}'::jsonb, 'asset_non_current', false, '2300', 410),
  ('KZ', 'default', '2400', 'Негізгі құралдар', '{"en":"Property, plant and equipment","ru":"Основные средства"}'::jsonb, 'asset_fixed', false, null, 420),
  ('KZ', 'default', '2410', 'Негізгі құралдар (бастапқы құны)', '{"en":"Property, plant and equipment, at cost","ru":"Основные средства (первоначальная стоимость)"}'::jsonb, 'asset_fixed', false, '2400', 430),
  ('KZ', 'default', '2420', 'Негізгі құралдардың тозуы', '{"en":"Accumulated depreciation of property, plant and equipment","ru":"Амортизация основных средств"}'::jsonb, 'asset_fixed', false, '2400', 440),
  ('KZ', 'default', '2440', 'Активті пайдалану құқығы', '{"en":"Right-of-use asset","ru":"Право пользования активом"}'::jsonb, 'asset_fixed', false, '2400', 450),
  ('KZ', 'default', '2600', 'Барлау және бағалау активтері', '{"en":"Exploration and evaluation assets","ru":"Разведочные и оценочные активы"}'::jsonb, 'asset_non_current', false, null, 460),
  ('KZ', 'default', '2610', 'Барлау және бағалау активтері', '{"en":"Exploration and evaluation assets","ru":"Разведочные и оценочные активы"}'::jsonb, 'asset_non_current', false, '2600', 470),
  ('KZ', 'default', '2700', 'Материалдық емес активтер', '{"en":"Intangible assets","ru":"Нематериальные активы"}'::jsonb, 'asset_fixed', false, null, 480),
  ('KZ', 'default', '2710', 'Гудвилл', '{"en":"Goodwill","ru":"Гудвилл"}'::jsonb, 'asset_fixed', false, '2700', 490),
  ('KZ', 'default', '2730', 'Басқа материалдық емес активтер', '{"en":"Other intangible assets","ru":"Прочие нематериальные активы"}'::jsonb, 'asset_fixed', false, '2700', 500),
  ('KZ', 'default', '2740', 'Материалдық емес активтердің амортизациясы', '{"en":"Accumulated amortisation of intangible assets","ru":"Амортизация нематериальных активов"}'::jsonb, 'asset_fixed', false, '2700', 510),
  ('KZ', 'default', '2800', 'Кейінге қалдырылған салық активтері', '{"en":"Deferred tax assets","ru":"Отложенные налоговые активы"}'::jsonb, 'asset_non_current', false, null, 520),
  ('KZ', 'default', '2810', 'Корпоративтік табыс салығы бойынша кейінге қалдырылған салық активтері', '{"en":"Deferred tax assets for corporate income tax","ru":"Отложенные налоговые активы по корпоративному подоходному налогу"}'::jsonb, 'asset_non_current', false, '2800', 530),
  ('KZ', 'default', '2900', 'Басқа ұзақ мерзімді активтер', '{"en":"Other non-current assets","ru":"Прочие долгосрочные активы"}'::jsonb, 'asset_non_current', false, null, 540),
  ('KZ', 'default', '2910', 'Берілген ұзақ мерзімді аванстар', '{"en":"Long-term advances paid","ru":"Долгосрочные авансы выданные"}'::jsonb, 'asset_non_current', false, '2900', 550),
  ('KZ', 'default', '2930', 'Аяқталмаған құрылыс', '{"en":"Construction in progress","ru":"Незавершенное строительство"}'::jsonb, 'asset_non_current', false, '2900', 560),
  ('KZ', 'default', '3000', 'Қысқа мерзімді қаржылық міндеттемелер', '{"en":"Short-term financial liabilities","ru":"Краткосрочные финансовые обязательства"}'::jsonb, 'liability_current', false, null, 570),
  ('KZ', 'default', '3010', 'Амортизацияланған құн бойынша қысқа мерзімді қаржылық міндеттемелер', '{"en":"Short-term financial liabilities at amortised cost","ru":"Краткосрочные финансовые обязательства по амортизированной стоимости"}'::jsonb, 'liability_current', false, '3000', 580),
  ('KZ', 'default', '3050', 'Төленуге тиіс қысқа мерзімді сыйақылар', '{"en":"Short-term rewards payable","ru":"Краткосрочные вознаграждения к выплате"}'::jsonb, 'liability_current', false, '3000', 590),
  ('KZ', 'default', '3060', 'Ұзақ мерзімді қаржылық міндеттемелердің ағымдағы бөлігі', '{"en":"Current portion of non-current financial liabilities","ru":"Текущая часть долгосрочных финансовых обязательств"}'::jsonb, 'liability_current', false, '3000', 600),
  ('KZ', 'default', '3100', 'Салықтар бойынша міндеттемелер', '{"en":"Tax liabilities","ru":"Обязательства по налогам"}'::jsonb, 'liability_current', false, null, 610),
  ('KZ', 'default', '3110', 'Төленуге тиіс корпоративтік табыс салығы', '{"en":"Corporate income tax payable","ru":"Корпоративный подоходный налог, подлежащий уплате"}'::jsonb, 'liability_current', false, '3100', 620),
  ('KZ', 'default', '3130', 'Қосылған құн салығы бойынша міндеттеме', '{"en":"VAT liability","ru":"Обязательство по налогу на добавленную стоимость"}'::jsonb, 'liability_current', false, '3100', 630),
  ('KZ', 'default', '3131', 'Есептелген қосылған құн салығы', '{"en":"Accrued VAT — posting account","ru":"Начисленный налог на добавленную стоимость"}'::jsonb, 'liability_current', false, '3130', 640),
  ('KZ', 'default', '3132', 'Бюджетпен қосылған құн салығы бойынша есеп айырысу (төленуге тиіс)', '{"en":"Settlement with the budget for VAT (payable)","ru":"Расчеты с бюджетом по налогу на добавленную стоимость (к уплате)"}'::jsonb, 'liability_current', true, '3130', 650),
  ('KZ', 'default', '3150', 'Әлеуметтік салық', '{"en":"Social tax","ru":"Социальный налог"}'::jsonb, 'liability_current', false, '3100', 660),
  ('KZ', 'default', '3160', 'Жер салығы', '{"en":"Land tax","ru":"Земельный налог"}'::jsonb, 'liability_current', false, '3100', 670),
  ('KZ', 'default', '3170', 'Көлік құралдары салығы', '{"en":"Vehicle tax","ru":"Налог на транспортные средства"}'::jsonb, 'liability_current', false, '3100', 680),
  ('KZ', 'default', '3180', 'Мүлік салығы', '{"en":"Property tax","ru":"Налог на имущество"}'::jsonb, 'liability_current', false, '3100', 690),
  ('KZ', 'default', '3190', 'Басқа салықтар', '{"en":"Other taxes","ru":"Прочие налоги"}'::jsonb, 'liability_current', false, '3100', 700),
  ('KZ', 'default', '3200', 'Басқа міндетті және ерікті төлемдер бойынша міндеттемелер', '{"en":"Liabilities for other mandatory and voluntary payments","ru":"Обязательства по прочим обязательным и добровольным платежам"}'::jsonb, 'liability_current', false, null, 710),
  ('KZ', 'default', '3210', 'Әлеуметтік сақтандыру бойынша міндеттемелер', '{"en":"Social insurance liabilities","ru":"Обязательства по социальному страхованию"}'::jsonb, 'liability_current', false, '3200', 720),
  ('KZ', 'default', '3220', 'Міндетті зейнетақы жарналары бойынша міндеттемелер', '{"en":"Mandatory pension contribution liabilities","ru":"Обязательства по обязательным пенсионным взносам"}'::jsonb, 'liability_current', false, '3200', 730),
  ('KZ', 'default', '3300', 'Қысқа мерзімді кредиторлық берешек', '{"en":"Short-term payables","ru":"Краткосрочная кредиторская задолженность"}'::jsonb, 'liability_current', false, null, 740),
  ('KZ', 'default', '3310', 'Жеткізушілер мен мердігерлердің қысқа мерзімді кредиторлық берешегі', '{"en":"Short-term payables to suppliers and contractors","ru":"Краткосрочная кредиторская задолженность поставщикам и подрядчикам"}'::jsonb, 'liability_payable', true, '3300', 750),
  ('KZ', 'default', '3350', 'Еңбекақы бойынша қысқа мерзімді берешек', '{"en":"Short-term payroll payable","ru":"Краткосрочная задолженность по оплате труда"}'::jsonb, 'liability_current', false, '3300', 760),
  ('KZ', 'default', '3360', 'Жалдау бойынша қысқа мерзімді берешек', '{"en":"Short-term lease payable","ru":"Краткосрочная задолженность по аренде"}'::jsonb, 'liability_current', false, '3300', 770),
  ('KZ', 'default', '3400', 'Қысқа мерзімді бағалау міндеттемелері', '{"en":"Short-term provisions","ru":"Краткосрочные оценочные обязательства"}'::jsonb, 'liability_current', false, null, 780),
  ('KZ', 'default', '3410', 'Кепілдік міндеттемелер бойынша қысқа мерзімді бағалау міндеттемелері', '{"en":"Short-term warranty provisions","ru":"Краткосрочные гарантийные обязательства"}'::jsonb, 'liability_current', false, '3400', 790),
  ('KZ', 'default', '3500', 'Басқа қысқа мерзімді міндеттемелер', '{"en":"Other short-term liabilities","ru":"Прочие краткосрочные обязательства"}'::jsonb, 'liability_current', false, null, 800),
  ('KZ', 'default', '3510', 'Алынған қысқа мерзімді аванстар', '{"en":"Short-term advances received","ru":"Краткосрочные авансы полученные"}'::jsonb, 'liability_current', false, '3500', 810),
  ('KZ', 'default', '3520', 'Болашақ кезең кірістері', '{"en":"Deferred income","ru":"Доходы будущих периодов"}'::jsonb, 'liability_current', false, '3500', 820),
  ('KZ', 'default', '3590', 'Анықтауды қажет ететін сомалар (транзиттік шот)', '{"en":"Amounts under investigation (suspense account)","ru":"Суммы, требующие выяснения (транзитный счет)"}'::jsonb, 'liability_current', false, '3500', 830),
  ('KZ', 'default', '4000', 'Ұзақ мерзімді қаржылық міндеттемелер', '{"en":"Non-current financial liabilities","ru":"Долгосрочные финансовые обязательства"}'::jsonb, 'liability_non_current', false, null, 840),
  ('KZ', 'default', '4010', 'Ұзақ мерзімді банктік қарыздар', '{"en":"Long-term bank loans","ru":"Долгосрочные банковские займы"}'::jsonb, 'liability_non_current', false, '4000', 850),
  ('KZ', 'default', '4100', 'Ұзақ мерзімді кредиторлық берешек', '{"en":"Non-current payables","ru":"Долгосрочная кредиторская задолженность"}'::jsonb, 'liability_non_current', false, null, 860),
  ('KZ', 'default', '4110', 'Жеткізушілер мен мердігерлердің ұзақ мерзімді кредиторлық берешегі', '{"en":"Non-current payables to suppliers and contractors","ru":"Долгосрочная кредиторская задолженность поставщикам и подрядчикам"}'::jsonb, 'liability_non_current', false, '4100', 870),
  ('KZ', 'default', '4200', 'Ұзақ мерзімді бағалау міндеттемелері', '{"en":"Non-current provisions","ru":"Долгосрочные оценочные обязательства"}'::jsonb, 'liability_non_current', false, null, 880),
  ('KZ', 'default', '4210', 'Ұзақ мерзімді кепілдік міндеттемелері', '{"en":"Non-current warranty provisions","ru":"Долгосрочные гарантийные обязательства"}'::jsonb, 'liability_non_current', false, '4200', 890),
  ('KZ', 'default', '4300', 'Кейінге қалдырылған салық міндеттемелері', '{"en":"Deferred tax liabilities","ru":"Отложенные налоговые обязательства"}'::jsonb, 'liability_non_current', false, null, 900),
  ('KZ', 'default', '4310', 'Корпоративтік табыс салығы бойынша кейінге қалдырылған салық міндеттемелері', '{"en":"Deferred tax liabilities for corporate income tax","ru":"Отложенные налоговые обязательства по корпоративному подоходному налогу"}'::jsonb, 'liability_non_current', false, '4300', 910),
  ('KZ', 'default', '4400', 'Басқа ұзақ мерзімді міндеттемелер', '{"en":"Other non-current liabilities","ru":"Прочие долгосрочные обязательства"}'::jsonb, 'liability_non_current', false, null, 920),
  ('KZ', 'default', '4410', 'Алынған ұзақ мерзімді аванстар', '{"en":"Long-term advances received","ru":"Долгосрочные авансы полученные"}'::jsonb, 'liability_non_current', false, '4400', 930),
  ('KZ', 'default', '5000', 'Жарғылық капитал', '{"en":"Share capital","ru":"Уставный капитал"}'::jsonb, 'equity', false, null, 940),
  ('KZ', 'default', '5020', 'Жай акциялар / қатысушылардың жарналары', '{"en":"Ordinary shares / members'' contributions","ru":"Простые акции / вклады участников"}'::jsonb, 'equity', false, '5000', 950),
  ('KZ', 'default', '5100', 'Төленбеген капитал', '{"en":"Unpaid capital","ru":"Неоплаченный капитал"}'::jsonb, 'equity', false, null, 960),
  ('KZ', 'default', '5110', 'Төленбеген капитал', '{"en":"Unpaid capital","ru":"Неоплаченный капитал"}'::jsonb, 'equity', false, '5100', 970),
  ('KZ', 'default', '5300', 'Эмиссиялық кіріс', '{"en":"Share premium","ru":"Эмиссионный доход"}'::jsonb, 'equity', false, null, 980),
  ('KZ', 'default', '5310', 'Эмиссиялық кіріс', '{"en":"Share premium","ru":"Эмиссионный доход"}'::jsonb, 'equity', false, '5300', 990),
  ('KZ', 'default', '5500', 'Резервтер', '{"en":"Reserves","ru":"Резервы"}'::jsonb, 'equity', false, null, 1000),
  ('KZ', 'default', '5510', 'Құрылтай құжаттарында көзделген резервтік капитал', '{"en":"Statutory reserve capital","ru":"Резервный капитал, установленный учредительными документами"}'::jsonb, 'equity', false, '5500', 1010),
  ('KZ', 'default', '5520', 'Негізгі құралдарды қайта бағалау резерві', '{"en":"Property, plant and equipment revaluation reserve","ru":"Резерв на переоценку основных средств"}'::jsonb, 'equity', false, '5500', 1020),
  ('KZ', 'default', '5600', 'Бөлінбеген пайда (жабылмаған зиян)', '{"en":"Retained earnings (accumulated loss)","ru":"Нераспределенная прибыль (непокрытый убыток)"}'::jsonb, 'equity_retained', false, null, 1030),
  ('KZ', 'default', '6000', 'Өнімді сату және қызмет көрсетуден түскен кіріс', '{"en":"Revenue from sale of goods and services","ru":"Доход от реализации продукции и оказания услуг"}'::jsonb, 'income', false, null, 1040),
  ('KZ', 'default', '6010', 'Тауарларды сатудан түскен кіріс', '{"en":"Revenue from sale of goods","ru":"Доход от реализации товаров"}'::jsonb, 'income', false, '6000', 1050),
  ('KZ', 'default', '6020', 'Жұмыстар мен қызметтерді орындаудан түскен кіріс', '{"en":"Revenue from work performed and services rendered","ru":"Доход от выполнения работ и оказания услуг"}'::jsonb, 'income', false, '6000', 1060),
  ('KZ', 'default', '6030', 'Сатылған өнімнің қайтарылуы және сату жеңілдіктері', '{"en":"Sales returns and discounts","ru":"Возврат проданной продукции и скидки с продаж"}'::jsonb, 'income', false, '6000', 1070),
  ('KZ', 'default', '6100', 'Қаржыландырудан түскен кірістер', '{"en":"Finance income","ru":"Доходы от финансирования"}'::jsonb, 'income_other', false, null, 1080),
  ('KZ', 'default', '6110', 'Сыйақылар бойынша кірістер', '{"en":"Interest income","ru":"Доходы по вознаграждениям"}'::jsonb, 'income_other', false, '6100', 1090),
  ('KZ', 'default', '6120', 'Дивидендтер бойынша кірістер', '{"en":"Dividend income","ru":"Доходы по дивидендам"}'::jsonb, 'income_other', false, '6100', 1100),
  ('KZ', 'default', '6200', 'Басқа кірістер', '{"en":"Other income","ru":"Прочие доходы"}'::jsonb, 'income_other', false, null, 1110),
  ('KZ', 'default', '6210', 'Активтерді шығарудан түскен кірістер', '{"en":"Income from disposal of assets","ru":"Доходы от выбытия активов"}'::jsonb, 'income_other', false, '6200', 1120),
  ('KZ', 'default', '6250', 'Бағамдық айырма бойынша кірістер', '{"en":"Foreign exchange gains","ru":"Доходы от курсовой разницы"}'::jsonb, 'income_other', false, '6200', 1130),
  ('KZ', 'default', '6290', 'Басқа да кірістер', '{"en":"Other miscellaneous income","ru":"Прочие доходы"}'::jsonb, 'income_other', false, '6200', 1140),
  ('KZ', 'default', '7000', 'Сатылған өнім мен көрсетілген қызметтердің өзіндік құны', '{"en":"Cost of sales","ru":"Себестоимость реализованной продукции и оказанных услуг"}'::jsonb, 'expense_direct_cost', false, null, 1150),
  ('KZ', 'default', '7100', 'Өнімді сатумен байланысты шығыстар', '{"en":"Selling expenses","ru":"Расходы по реализации продукции"}'::jsonb, 'expense', false, null, 1160),
  ('KZ', 'default', '7200', 'Әкімшілік шығыстар', '{"en":"Administrative expenses","ru":"Административные расходы"}'::jsonb, 'expense', false, null, 1170),
  ('KZ', 'default', '7300', 'Қаржыландыруға арналған шығыстар', '{"en":"Finance costs","ru":"Расходы на финансирование"}'::jsonb, 'expense', false, null, 1180),
  ('KZ', 'default', '7310', 'Сыйақылар бойынша шығыстар', '{"en":"Interest expense","ru":"Расходы по вознаграждениям"}'::jsonb, 'expense', false, '7300', 1190),
  ('KZ', 'default', '7400', 'Басқа шығыстар', '{"en":"Other expenses","ru":"Прочие расходы"}'::jsonb, 'expense', false, null, 1200),
  ('KZ', 'default', '7410', 'Активтерді шығарудан болатын шығыстар', '{"en":"Loss on disposal of assets","ru":"Расходы по выбытию активов"}'::jsonb, 'expense', false, '7400', 1210),
  ('KZ', 'default', '7420', 'Қаржылық емес активтердің құнсыздануынан болатын шығыстар', '{"en":"Impairment loss on non-financial assets","ru":"Расходы от обесценения нефинансовых активов"}'::jsonb, 'expense', false, '7400', 1220),
  ('KZ', 'default', '7430', 'Бағамдық айырма бойынша шығыстар', '{"en":"Foreign exchange losses","ru":"Расходы по курсовой разнице"}'::jsonb, 'expense', false, '7400', 1230),
  ('KZ', 'default', '7440', 'Дебиторлық берешекті құнсыздандырудан болатын шығыстар', '{"en":"Impairment loss on receivables","ru":"Расходы по обесценению дебиторской задолженности"}'::jsonb, 'expense', false, '7400', 1240),
  ('KZ', 'default', '7460', 'Дөңгелектеу бойынша айырмалар', '{"en":"Rounding differences","ru":"Разницы по округлению"}'::jsonb, 'expense', false, '7400', 1250),
  ('KZ', 'default', '7490', 'Операциялық қызметтің басқа да шығыстары', '{"en":"Other operating expenses","ru":"Прочие расходы операционной деятельности"}'::jsonb, 'expense', false, '7400', 1260),
  ('KZ', 'default', '7700', 'Корпоративтік табыс салығы бойынша шығыстар', '{"en":"Corporate income tax expense","ru":"Расходы по корпоративному подоходному налогу"}'::jsonb, 'expense', false, null, 1270)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KZ', 'BNK', 'Банк журналы', '{"en":"Bank journal","ru":"Банковский журнал"}'::jsonb, 'bank', 30),
  ('KZ', 'CSH', 'Касса журналы', '{"en":"Cash journal","ru":"Кассовый журнал"}'::jsonb, 'cash', 40),
  ('KZ', 'GEN', 'Жалпы журнал', '{"en":"General journal","ru":"Общий журнал"}'::jsonb, 'general', 50),
  ('KZ', 'OPN', 'Ашылу журналы', '{"en":"Opening journal","ru":"Журнал открытия"}'::jsonb, 'opening', 60),
  ('KZ', 'PUR', 'Сатып алу журналы', '{"en":"Purchase journal","ru":"Журнал закупок"}'::jsonb, 'purchase', 20),
  ('KZ', 'SAL', 'Сату журналы', '{"en":"Sales journal","ru":"Журнал продаж"}'::jsonb, 'sales', 10)
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
  ('KZ', 'KZ-P-12', 'ҚҚС 12 % — негізгі мөлшерлеме (сатып алу, 2026 жылға дейін қолданылған, жабық код)', '{"en":"VAT 12% — standard rate (purchase, in force until 2026, closed code)","ru":"НДС 12 % — основная ставка (покупка, действовала до 2026 года, закрытый код)"}'::jsonb, null, 'percent', 12, 'purchase', 'domestic', date '2018-01-01', date '2025-12-31', 'Салық кодексі (2017 жылғы № 120-VI ҚРЗ, күші жойылған), 422-бап — қосылған құн салығының мөлшерлемесі 12 пайызды құрады. Тарихи құжаттарды есептеу үшін жабық түрде сақталады.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2017', null, null, null, null),
  ('KZ', 'KZ-P-16', 'ҚҚС 16 % — негізгі мөлшерлеме (сатып алу)', '{"en":"VAT 16% — standard rate (purchase)","ru":"НДС 16 % — основная ставка (покупка)"}'::jsonb, null, 'percent', 16, 'purchase', 'domestic', date '2026-01-01', null, 'Салық кодексі (214-VIII), 503-бап, 1-тармақ — сатып алынған тауарлар, жұмыстар, қызметтер бойынша есепке жатқызылатын қосылған құн салығы негізгі 16 пайыздық мөлшерлеме бойынша есептеледі.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-P-MED-5', 'ҚҚС 5 % — дәрілік заттар мен медициналық бұйымдар (сатып алу, 2026 жылғы уақытша мөлшерлеме)', '{"en":"VAT 5% — medicines and medical devices (purchase, transitional 2026 rate)","ru":"НДС 5 % — лекарственные средства и медицинские изделия (покупка, временная ставка 2026 года)"}'::jsonb, null, 'percent', 5, 'purchase', 'domestic', date '2026-01-01', date '2026-12-31', 'Салық кодексі (214-VIII), 503-бап, 2-тармақ, 1) тармақшасы — сатушы 5 пайыздық мөлшерлеме бойынша есептеген тіркелген дәрілік заттар мен медициналық бұйымдарды сатып алу бойынша есепке жатқызылатын салық.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-S-12', 'ҚҚС 12 % — негізгі мөлшерлеме (сату, 2026 жылға дейін қолданылған, жабық код)', '{"en":"VAT 12% — standard rate (sale, in force until 2026, closed code)","ru":"НДС 12 % — основная ставка (продажа, действовала до 2026 года, закрытый код)"}'::jsonb, null, 'percent', 12, 'sale', 'domestic', date '2018-01-01', date '2025-12-31', 'Салық кодексі (2017 жылғы 25 желтоқсандағы № 120-VI ҚРЗ, 2026 жылғы 1 қаңтарда күші жойылған), 422-бап — қосылған құн салығының мөлшерлемесі 12 пайызды құрайды. Жаңа Салық кодексінің (214-VIII) 503-бабы 2026 жылғы 1 қаңтардан бастап мөлшерлемені 16 пайызға дейін көтерді; бұл код тарихи құжаттарды дұрыс есептеу үшін жабық түрде сақталады.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2017', null, null, null, null),
  ('KZ', 'KZ-S-16', 'ҚҚС 16 % — негізгі мөлшерлеме (сату)', '{"en":"VAT 16% — standard rate (sale)","ru":"НДС 16 % — основная ставка (продажа)"}'::jsonb, null, 'percent', 16, 'sale', 'domestic', date '2026-01-01', null, 'Салық кодексі (2025 жылғы 18 шілдедегі № 214-VIII ҚРЗ), 503-бап, 1-тармақ — салық салынатын айналымға және импортқа қосылған құн салығының базалық мөлшерлемесі 16 пайызды құрайды.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-S-EXEMPT-BOOKS', 'ҚҚС-тан босатылған — отандық басылымдағы кітаптар мен кітап басып шығару қызметтері (сату)', '{"en":"VAT exempt — domestically published books and book-publishing services (sale)","ru":"Освобождено от НДС — книги отечественного издания и услуги по изданию книг (продажа)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2026-01-01', null, 'Салық кодексі (214-VIII), 474-бап, 1-тармақ, 46) тармақшасы — отандық басылымдағы кітаптарды өткізу және кітаптарды баспа түрінде шығару жөніндегі қызметтер қосылған құн салығынан босатылады.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-S-EXPORT', 'ҚҚС 0 % — тауарларды экспорттау (сату)', '{"en":"VAT 0% — export of goods (sale)","ru":"НДС 0 % — экспорт товаров (продажа)"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2026-01-01', null, 'Салық кодексі (214-VIII), 467-бап, 1-тармақ — 474-бапта көзделген оборандарды қоспағанда, тауарларды экспортқа өткізу бойынша айналым нөлдік мөлшерлеме бойынша салық салынады. Экспорт — Еуразиялық экономикалық одақтың кедендік аумағынан тауарларды Одақтың кедендік заңнамасына сәйкес әкету. 4-тармақ — растайтын құжаттар болмаған жағдайда, айналым осы Кодекстің 503-бабының 1-тармағында белгіленген мөлшерлеме бойынша салық салынатын айналымға жатқызылады.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-S-MED-10', 'ҚҚС 10 % — дәрілік заттар, медициналық бұйымдар және медициналық қызметтер (сату, 2027 жылдан бастап)', '{"en":"VAT 10% — medicines, medical devices and medical services (sale, from 2027)","ru":"НДС 10 % — лекарственные средства, медицинские изделия и медицинские услуги (продажа, с 2027 года)"}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '2027-01-01', null, 'Салық кодексі (214-VIII), 503-бап, 2-тармақ, 1) және 2) тармақшалары — 2027 жылғы 1 қаңтардан бастап дәрілік заттар, медициналық бұйымдар мен медициналық қызметтердің өткізілуіне қолданылатын төмендетілген мөлшерлеме 10 пайызға дейін көтеріледі.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-S-MED-5', 'ҚҚС 5 % — дәрілік заттар, медициналық бұйымдар және медициналық қызметтер (сату, 2026 жылғы уақытша мөлшерлеме)', '{"en":"VAT 5% — medicines, medical devices and medical services (sale, transitional 2026 rate)","ru":"НДС 5 % — лекарственные средства, медицинские изделия и медицинские услуги (продажа, временная ставка 2026 года)"}'::jsonb, null, 'percent', 5, 'sale', 'domestic', date '2026-01-01', date '2026-12-31', 'Салық кодексі (214-VIII), 503-бап, 2-тармақ, 1) және 2) тармақшалары — 2026 жылғы 1 қаңтардан бастап 2026 жылғы 31 желтоқсанды қоса алғанда, тіркелген дәрілік заттар мен медициналық бұйымдардың (кейбір алып тастаулармен) және лицензиясы бар денсаулық сақтау ұйымдары көрсететін медициналық қызметтердің өткізілуіне 5 пайыздық мөлшерлеме қолданылады.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null),
  ('KZ', 'KZ-S-PRESS-10', 'ҚҚС 10 % — отандық баспасөз басылымдары (сату)', '{"en":"VAT 10% — domestic printed periodicals (sale)","ru":"НДС 10 % — отечественные периодические печатные издания (продажа)"}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '2026-01-01', null, 'Салық кодексі (214-VIII), 503-бап, 3-тармақ — отандық мерзімді баспа басылымдарын өткізу бойынша айналымның мөлшеріне 10 пайыздық мөлшерлеме қолданылады.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-2026', null, null, null, null)
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
    ('KZ-P-12', 'invoice', 'base', 100, null, '013', array['013']::text[], 100, 'KZ-300', 10),
    ('KZ-P-12', 'invoice', 'tax', 100, '1421', '013', array['013']::text[], 100, 'KZ-300', 20),
    ('KZ-P-12', 'credit_note', 'base', 100, null, '013', array['013']::text[], -100, 'KZ-300', 10),
    ('KZ-P-12', 'credit_note', 'tax', 100, '1421', '013', array['013']::text[], -100, 'KZ-300', 20),
    ('KZ-P-16', 'invoice', 'base', 100, null, '013', array['013']::text[], 100, 'KZ-300', 10),
    ('KZ-P-16', 'invoice', 'tax', 100, '1421', '013', array['013']::text[], 100, 'KZ-300', 20),
    ('KZ-P-16', 'credit_note', 'base', 100, null, '013', array['013']::text[], -100, 'KZ-300', 10),
    ('KZ-P-16', 'credit_note', 'tax', 100, '1421', '013', array['013']::text[], -100, 'KZ-300', 20),
    ('KZ-P-MED-5', 'invoice', 'base', 100, null, '013', array['013']::text[], 100, 'KZ-300', 10),
    ('KZ-P-MED-5', 'invoice', 'tax', 100, '1421', '013', array['013']::text[], 100, 'KZ-300', 20),
    ('KZ-P-MED-5', 'credit_note', 'base', 100, null, '013', array['013']::text[], -100, 'KZ-300', 10),
    ('KZ-P-MED-5', 'credit_note', 'tax', 100, '1421', '013', array['013']::text[], -100, 'KZ-300', 20),
    ('KZ-S-12', 'invoice', 'base', 100, null, '001', array['001']::text[], 100, 'KZ-300', 10),
    ('KZ-S-12', 'invoice', 'tax', 100, '3131', '001', array['001']::text[], 100, 'KZ-300', 20),
    ('KZ-S-12', 'credit_note', 'base', 100, null, '001', array['001']::text[], -100, 'KZ-300', 10),
    ('KZ-S-12', 'credit_note', 'tax', 100, '3131', '001', array['001']::text[], -100, 'KZ-300', 20),
    ('KZ-S-16', 'invoice', 'base', 100, null, '001', array['001']::text[], 100, 'KZ-300', 10),
    ('KZ-S-16', 'invoice', 'tax', 100, '3131', '001', array['001']::text[], 100, 'KZ-300', 20),
    ('KZ-S-16', 'credit_note', 'base', 100, null, '001', array['001']::text[], -100, 'KZ-300', 10),
    ('KZ-S-16', 'credit_note', 'tax', 100, '3131', '001', array['001']::text[], -100, 'KZ-300', 20),
    ('KZ-S-EXEMPT-BOOKS', 'invoice', 'base', 100, null, '005', array['005']::text[], 100, 'KZ-300', 10),
    ('KZ-S-EXEMPT-BOOKS', 'credit_note', 'base', 100, null, '005', array['005']::text[], -100, 'KZ-300', 10),
    ('KZ-S-EXPORT', 'invoice', 'base', 100, null, '002', array['002']::text[], 100, 'KZ-300', 10),
    ('KZ-S-EXPORT', 'credit_note', 'base', 100, null, '002', array['002']::text[], -100, 'KZ-300', 10),
    ('KZ-S-MED-10', 'invoice', 'base', 100, null, '001', array['001']::text[], 100, 'KZ-300', 10),
    ('KZ-S-MED-10', 'invoice', 'tax', 100, '3131', '001', array['001']::text[], 100, 'KZ-300', 20),
    ('KZ-S-MED-10', 'credit_note', 'base', 100, null, '001', array['001']::text[], -100, 'KZ-300', 10),
    ('KZ-S-MED-10', 'credit_note', 'tax', 100, '3131', '001', array['001']::text[], -100, 'KZ-300', 20),
    ('KZ-S-MED-5', 'invoice', 'base', 100, null, '001', array['001']::text[], 100, 'KZ-300', 10),
    ('KZ-S-MED-5', 'invoice', 'tax', 100, '3131', '001', array['001']::text[], 100, 'KZ-300', 20),
    ('KZ-S-MED-5', 'credit_note', 'base', 100, null, '001', array['001']::text[], -100, 'KZ-300', 10),
    ('KZ-S-MED-5', 'credit_note', 'tax', 100, '3131', '001', array['001']::text[], -100, 'KZ-300', 20),
    ('KZ-S-PRESS-10', 'invoice', 'base', 100, null, '001', array['001']::text[], 100, 'KZ-300', 10),
    ('KZ-S-PRESS-10', 'invoice', 'tax', 100, '3131', '001', array['001']::text[], 100, 'KZ-300', 20),
    ('KZ-S-PRESS-10', 'credit_note', 'base', 100, null, '001', array['001']::text[], -100, 'KZ-300', 10),
    ('KZ-S-PRESS-10', 'credit_note', 'tax', 100, '3131', '001', array['001']::text[], -100, 'KZ-300', 20)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KZ' and t.code = v.tax_code
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
   deadline_reference, deadline_source_key, file_format,
   rounding_unit, rounding_reference, rounding_source_key)
values
  ('KZ', 'KZ-300', 'Қосылған құн салығы бойынша декларация (300.00 нысаны)', array['quarter']::declaration_period[], 'quarter'::declaration_period, date '2026-01-01', null, 'Салық кодексі (214-VIII), 504-бап — қосылған құн салығы бойынша салық кезеңі күнтізбелік тоқсан болып табылады. Қаржы министрінің 2025 жылғы 12 қарашадағы № 695 бұйрығы — 300.00 нысаны (ҚҚС бойынша декларация) және оның 300.01-300.08 қосымшалары. Бұл дестеде декларацияның негізгі нысаны ғана транскрипцияланады: салық салынатын айналым (қандай да бір оң мөлшерлемемен, 001-жол), нөлдік мөлшерлемедегі айналым (002-жол), босатылған айналым (005-жол), жалпы айналым (006-жол), ішкі сатып алулар бойынша есепке жатқызылатын салық (013-жол), есепке жатқызылатын салықтың жалпы сомасы (023-жол), есепке жатқызуға рұқсат етілген сома (025-жол) және бюджетке төленуге не өтелуге тиіс сома (030-жол). Импорт, резидент еместердің қызметтері, түзетулер мен шот-фактуралардың тізілімдері бойынша қосымшалар (300.03-300.08) транскрипцияланбаған — ешбір салық бабы оларға жетпейді; қараңыз README.md және docs/international.md, «From Kazakhstan» бөлімі.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, 15, 'Салық кодексі (214-VIII), 505-бап — декларация салық кезеңінен кейінгі екінші айдың 15-інен кешіктірмей, бірақ салық кезеңінен кейінгі айдың 15-інен ерте емес тапсырылады. Тоқсанды жабатын айдан кейінгі айдың соңғы күні (30 немесе 31) плюс 15 күн әрдайым сол екінші айдың 15-іне дәл келеді, сондықтан бұл ереже соңғы мерзімді дәл көрсетеді; ең ерте тапсыру мерзімі (алдыңғы айдың 15-і) бұл форматта көрінбейді — қараңыз README.md.', 'tax-code-2026', null, 1, '300.00 нысанын жасау бойынша түсіндірме (№ 695 бұйрық) — декларацияның барлық сомалық көрсеткіштері толық теңгемен, тиынсыз көрсетіледі.', 'reporting-order-695')
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
  rounding_unit       = excluded.rounding_unit,
  rounding_reference  = excluded.rounding_reference,
  rounding_source_key = excluded.rounding_source_key,
  file_format         = excluded.file_format;

insert into tax_report_box_templates
  (country, report_code, box, kind, name, name_i18n, sequence, print_sequence,
   plus_boxes, minus_boxes, rate, rate_of_box, floor_zero, hidden, xml_element,
   legal_reference, source_key)
values
  ('KZ', 'KZ-300', '001', 'base', 'Нөлдік мөлшерлемеден басқа мөлшерлеме бойынша салық салынатын айналым — айналымның мөлшері', '{"en":"Turnover taxed at a rate other than zero — turnover amount","ru":"Оборот, облагаемый по ставке, кроме нулевой — размер оборота"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, I бөлім, 001-жол, А бағаны.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '001', 'tax', 'Нөлдік мөлшерлемеден басқа мөлшерлеме бойынша салық салынатын айналым — салық сомасы', '{"en":"Turnover taxed at a rate other than zero — tax amount","ru":"Оборот, облагаемый по ставке, кроме нулевой — сумма налога"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, I бөлім, 001-жол, В бағаны.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '002', 'base', 'Нөлдік мөлшерлеме бойынша салық салынатын айналым', '{"en":"Turnover taxed at the zero rate","ru":"Оборот, облагаемый по нулевой ставке"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, I бөлім, 002-жол; Салық кодексі (214-VIII), 467-бап.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '005', 'base', 'Қосылған құн салығынан босатылған айналым', '{"en":"Turnover exempt from VAT","ru":"Оборот, освобожденный от налога на добавленную стоимость"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, I бөлім, 005-жол; Салық кодексі (214-VIII), 474-бап.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '006', 'total', 'Жалпы айналым', '{"en":"Total turnover","ru":"Общий оборот"}'::jsonb, 50, null, array['001:base', '002', '005']::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, I бөлім, 006-жол.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '013', 'base', 'Ішкі айналымдар бойынша сатып алынған тауарлар, жұмыстар, қызметтер — есепке жатқызу құқығын беретін айналымның мөлшері', '{"en":"Domestically acquired goods, works and services giving right to offset — turnover amount","ru":"Приобретенные товары, работы, услуги по внутренним оборотам — размер оборота, дающего право на зачет"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, II бөлім, 013-жол, А бағаны.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '013', 'tax', 'Ішкі айналымдар бойынша сатып алынған тауарлар, жұмыстар, қызметтер — есепке жатқызылатын салық сомасы', '{"en":"Domestically acquired goods, works and services giving right to offset — tax amount","ru":"Приобретенные товары, работы, услуги по внутренним оборотам — сумма налога, относимого в зачет"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, II бөлім, 013-жол, В бағаны.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '023', 'total', 'Есепке жатқызылатын салықтың жалпы сомасы', '{"en":"Total VAT offset","ru":"Общая сумма налога, относимого в зачет"}'::jsonb, 80, null, array['013:tax']::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, II бөлім, 023-жол.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '025', 'total', 'Есепке жатқызуға рұқсат етілген қосылған құн салығының сомасы', '{"en":"VAT amount allowed as a deduction","ru":"Сумма налога на добавленную стоимость, разрешенная к отнесению в зачет"}'::jsonb, 90, null, array['023']::text[], '{}'::text[], null, null, false, false, null, '300.00 нысаны, II бөлім, 025-жол.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '030I', 'total', 'Бюджетке төленуге тиіс қосылған құн салығының сомасы', '{"en":"VAT amount payable to the budget","ru":"Сумма налога на добавленную стоимость, подлежащая уплате в бюджет"}'::jsonb, 100, null, array['001:tax']::text[], array['025']::text[], null, null, true, false, null, '300.00 нысаны, III бөлім, 030-жол, I бөлігі; Салық кодексі (214-VIII), 504-бап пен 505-бап — есептелген салық пен есепке жатқызылатын салық арасындағы оң айырма бюджетке төленуге тиіс.', 'reporting-order-695'),
  ('KZ', 'KZ-300', '030II', 'total', 'Асып кету сомасы (өтелуге тиіс)', '{"en":"Excess amount (refundable)","ru":"Сумма превышения (к возврату)"}'::jsonb, 110, null, array['025']::text[], array['001:tax']::text[], null, null, true, false, null, '300.00 нысаны, III бөлім, 030-жол, II бөлігі — есепке жатқызылатын салық есептелген салықтан асып кеткен жағдайда, айырма келесі кезеңге өтеді немесе салық төлеушінің өтінішхаты бойынша қайтарылады.', 'reporting-order-695')
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
  ('KZ-IFRS-BS', 'KZ', 'default', 'Қаржылық жағдайы туралы есеп', 'balance_sheet', 'ХҚЕС', date '2013-01-01', null, '«Бухгалтерлік есеп пен қаржылық есептілік туралы» Заң, 2-бап пен 6-бап — коммерциялық ұйымдар ХҚЕС-ке немесе ШОБ субъектілері үшін ХҚЕС-ке сәйкес қаржылық есептілік жасайды; ХҚЕС (IAS) 1-стандарты қаржылық жағдайы туралы есептің құрылымын белгілейді. Бұл дестеде Қаржы министрінің № 185 бұйрығымен бекітілген Бухгалтерлік есептің үлгі шоттар жоспарының бес бөлімін (қысқа мерзімді активтер, ұзақ мерзімді активтер, қысқа мерзімді міндеттемелер, ұзақ мерзімді міндеттемелер, капитал мен резервтер) тікелей көрсететін жолдар транскрипцияланған — бұл ешбір ХҚЕС ресми кестесі емес, дестенің өз құрастыруы; қараңыз README.md.', 'coa-order-185'),
  ('KZ-IFRS-IS', 'KZ', 'default', 'Пайда мен зиян және өзге де жиынтық кіріс туралы есеп', 'income_statement', 'ХҚЕС', date '2013-01-01', null, '«Бухгалтерлік есеп пен қаржылық есептілік туралы» Заң, 2-бап пен 6-бап; ХҚЕС (IAS) 1-стандарты. Бұл дестеде Бухгалтерлік есептің үлгі шоттар жоспарының 6-бөлімі (кірістер) мен 7-бөлімі (шығыстар) тікелей көрсететін жолдар транскрипцияланған, өзге де жиынтық кіріс бөлімінсіз — ешбір осы дестенің шоты оны қажет етпейді; қараңыз README.md.', 'coa-order-185')
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
  ('KZ-IFRS-BS', 'AS-CASH', null, 'Ақша қаражаты', '{"en":"Cash","ru":"Денежные средства"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-STFA', null, 'Қысқа мерзімді қаржы активтері', '{"en":"Short-term financial assets","ru":"Краткосрочные финансовые активы"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-STREC', null, 'Қысқа мерзімді дебиторлық берешек', '{"en":"Short-term receivables","ru":"Краткосрочная дебиторская задолженность"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-INV', null, 'Қорлар', '{"en":"Inventories","ru":"Запасы"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-CTAX', null, 'Ағымдағы салықтық активтер', '{"en":"Current tax assets","ru":"Текущие налоговые активы"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-OCA', null, 'Басқа қысқа мерзімді активтер', '{"en":"Other current assets","ru":"Прочие краткосрочные активы"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-CA-TOTAL', null, 'Қысқа мерзімді активтер жиынтығы', '{"en":"Total current assets","ru":"Итого краткосрочные активы"}'::jsonb, 70, 1, true, array['AS-CASH', 'AS-STFA', 'AS-STREC', 'AS-INV', 'AS-CTAX', 'AS-OCA']::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-LTFA', null, 'Ұзақ мерзімді қаржы активтері', '{"en":"Non-current financial assets","ru":"Долгосрочные финансовые активы"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-LTREC', null, 'Ұзақ мерзімді дебиторлық берешек', '{"en":"Non-current receivables","ru":"Долгосрочная дебиторская задолженность"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-INVEST', null, 'Инвестициялар', '{"en":"Investments","ru":"Инвестиции"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-INVPROP', null, 'Инвестициялық мүлік', '{"en":"Investment property","ru":"Инвестиционное имущество"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-PPE', null, 'Негізгі құралдар', '{"en":"Property, plant and equipment","ru":"Основные средства"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-EXPLOR', null, 'Барлау және бағалау активтері', '{"en":"Exploration and evaluation assets","ru":"Разведочные и оценочные активы"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-INTANG', null, 'Материалдық емес активтер', '{"en":"Intangible assets","ru":"Нематериальные активы"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-DTA', null, 'Кейінге қалдырылған салық активтері', '{"en":"Deferred tax assets","ru":"Отложенные налоговые активы"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-ONCA', null, 'Басқа ұзақ мерзімді активтер', '{"en":"Other non-current assets","ru":"Прочие долгосрочные активы"}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-NCA-TOTAL', null, 'Ұзақ мерзімді активтер жиынтығы', '{"en":"Total non-current assets","ru":"Итого долгосрочные активы"}'::jsonb, 170, 1, true, array['AS-LTFA', 'AS-LTREC', 'AS-INVEST', 'AS-INVPROP', 'AS-PPE', 'AS-EXPLOR', 'AS-INTANG', 'AS-DTA', 'AS-ONCA']::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'AS-TOTAL', null, 'Активтер жиынтығы (баланс)', '{"en":"Total assets","ru":"Итого активы (баланс)"}'::jsonb, 180, 1, true, array['AS-CA-TOTAL', 'AS-NCA-TOTAL']::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQ-SHARE', null, 'Жарғылық капитал', '{"en":"Share capital","ru":"Уставный капитал"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQ-UNPAID', null, 'Төленбеген капитал', '{"en":"Unpaid capital","ru":"Неоплаченный капитал"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQ-PREMIUM', null, 'Эмиссиялық кіріс', '{"en":"Share premium","ru":"Эмиссионный доход"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQ-RESERVES', null, 'Резервтер', '{"en":"Reserves","ru":"Резервы"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQ-RETAINED', null, 'Бөлінбеген пайда (жабылмаған зиян)', '{"en":"Retained earnings (accumulated loss)","ru":"Нераспределенная прибыль (непокрытый убыток)"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQ-TOTAL', null, 'Капитал жиынтығы', '{"en":"Total equity","ru":"Итого капитал"}'::jsonb, 240, 1, true, array['EQ-SHARE', 'EQ-PREMIUM', 'EQ-RESERVES', 'EQ-RETAINED']::text[], array['EQ-UNPAID']::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-STFIN', null, 'Қысқа мерзімді қаржылық міндеттемелер', '{"en":"Short-term financial liabilities","ru":"Краткосрочные финансовые обязательства"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-TAX', null, 'Салықтар бойынша міндеттемелер', '{"en":"Tax liabilities","ru":"Обязательства по налогам"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-OTHERMAND', null, 'Басқа міндетті және ерікті төлемдер бойынша міндеттемелер', '{"en":"Liabilities for other mandatory and voluntary payments","ru":"Обязательства по прочим обязательным и добровольным платежам"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-STPAY', null, 'Қысқа мерзімді кредиторлық берешек', '{"en":"Short-term payables","ru":"Краткосрочная кредиторская задолженность"}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-STPROV', null, 'Қысқа мерзімді бағалау міндеттемелері', '{"en":"Short-term provisions","ru":"Краткосрочные оценочные обязательства"}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-OTHERST', null, 'Басқа қысқа мерзімді міндеттемелер', '{"en":"Other short-term liabilities","ru":"Прочие краткосрочные обязательства"}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-CL-TOTAL', null, 'Қысқа мерзімді міндеттемелер жиынтығы', '{"en":"Total current liabilities","ru":"Итого краткосрочные обязательства"}'::jsonb, 310, 1, true, array['LI-STFIN', 'LI-TAX', 'LI-OTHERMAND', 'LI-STPAY', 'LI-STPROV', 'LI-OTHERST']::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-LTFIN', null, 'Ұзақ мерзімді қаржылық міндеттемелер', '{"en":"Non-current financial liabilities","ru":"Долгосрочные финансовые обязательства"}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-LTPAY', null, 'Ұзақ мерзімді кредиторлық берешек', '{"en":"Non-current payables","ru":"Долгосрочная кредиторская задолженность"}'::jsonb, 330, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-LTPROV', null, 'Ұзақ мерзімді бағалау міндеттемелері', '{"en":"Non-current provisions","ru":"Долгосрочные оценочные обязательства"}'::jsonb, 340, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-DTL', null, 'Кейінге қалдырылған салық міндеттемелері', '{"en":"Deferred tax liabilities","ru":"Отложенные налоговые обязательства"}'::jsonb, 350, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-OTHERLT', null, 'Басқа ұзақ мерзімді міндеттемелер', '{"en":"Other non-current liabilities","ru":"Прочие долгосрочные обязательства"}'::jsonb, 360, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'LI-NCL-TOTAL', null, 'Ұзақ мерзімді міндеттемелер жиынтығы', '{"en":"Total non-current liabilities","ru":"Итого долгосрочные обязательства"}'::jsonb, 370, 1, true, array['LI-LTFIN', 'LI-LTPAY', 'LI-LTPROV', 'LI-DTL', 'LI-OTHERLT']::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-BS', 'EQLI-TOTAL', null, 'Капитал мен міндеттемелер жиынтығы (баланс)', '{"en":"Total equity and liabilities","ru":"Итого капитал и обязательства (баланс)"}'::jsonb, 380, 1, true, array['EQ-TOTAL', 'LI-CL-TOTAL', 'LI-NCL-TOTAL']::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-REV', null, 'Өнімді сату және қызмет көрсетуден түскен кіріс', '{"en":"Revenue from sale of goods and services","ru":"Доход от реализации продукции и оказания услуг"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-COGS', null, 'Сатылған өнім мен көрсетілген қызметтердің өзіндік құны', '{"en":"Cost of sales","ru":"Себестоимость реализованной продукции и оказанных услуг"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-GROSS', null, 'Жалпы пайда (зиян)', '{"en":"Gross profit (loss)","ru":"Валовая прибыль (убыток)"}'::jsonb, 30, 1, true, array['IS-REV']::text[], array['IS-COGS']::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-SELL', null, 'Өнімді сатумен байланысты шығыстар', '{"en":"Selling expenses","ru":"Расходы по реализации продукции"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-ADMIN', null, 'Әкімшілік шығыстар', '{"en":"Administrative expenses","ru":"Административные расходы"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-OPINC', null, 'Басқа кірістер', '{"en":"Other income","ru":"Прочие доходы"}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-OPEXP', null, 'Басқа шығыстар', '{"en":"Other expenses","ru":"Прочие расходы"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-OPRESULT', null, 'Операциялық қызметтен түскен қаржылық нәтиже (пайда/зиян)', '{"en":"Result from operating activities (profit/loss)","ru":"Финансовый результат от операционной деятельности (прибыль/убыток)"}'::jsonb, 80, 1, true, array['IS-GROSS', 'IS-OPINC']::text[], array['IS-SELL', 'IS-ADMIN', 'IS-OPEXP']::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-FININC', null, 'Қаржыландырудан түскен кірістер', '{"en":"Finance income","ru":"Доходы от финансирования"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-FINEXP', null, 'Қаржыландыруға арналған шығыстар', '{"en":"Finance costs","ru":"Расходы на финансирование"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-PRETAX', null, 'Салық салынғанға дейінгі қаржылық нәтиже (пайда/зиян)', '{"en":"Result before tax (profit/loss)","ru":"Финансовый результат до налогообложения (прибыль/убыток)"}'::jsonb, 110, 1, true, array['IS-OPRESULT', 'IS-FININC']::text[], array['IS-FINEXP']::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-CIT', null, 'Корпоративтік табыс салығы бойынша шығыстар', '{"en":"Corporate income tax expense","ru":"Расходы по корпоративному подоходному налогу"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('KZ-IFRS-IS', 'IS-NET', null, 'Таза қаржылық нәтиже (пайда/зиян)', '{"en":"Net result (profit/loss)","ru":"Чистый финансовый результат (прибыль/убыток)"}'::jsonb, 130, 1, true, array['IS-PRETAX']::text[], array['IS-CIT']::text[], null, null, null)
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
    ('KZ-IFRS-BS', 'AS-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('KZ-IFRS-BS', 'AS-STFA', 10, 'code_range', '1100', '1199', null, 'any'),
    ('KZ-IFRS-BS', 'AS-STREC', 10, 'code_range', '1200', '1299', null, 'any'),
    ('KZ-IFRS-BS', 'AS-INV', 10, 'code_range', '1300', '1399', null, 'any'),
    ('KZ-IFRS-BS', 'AS-CTAX', 10, 'code_range', '1400', '1499', null, 'any'),
    ('KZ-IFRS-BS', 'AS-OCA', 10, 'code_range', '1700', '1799', null, 'any'),
    ('KZ-IFRS-BS', 'AS-LTFA', 10, 'code_range', '2000', '2099', null, 'any'),
    ('KZ-IFRS-BS', 'AS-LTREC', 10, 'code_range', '2100', '2199', null, 'any'),
    ('KZ-IFRS-BS', 'AS-INVEST', 10, 'code_range', '2200', '2299', null, 'any'),
    ('KZ-IFRS-BS', 'AS-INVPROP', 10, 'code_range', '2300', '2399', null, 'any'),
    ('KZ-IFRS-BS', 'AS-PPE', 10, 'code_range', '2400', '2499', null, 'any'),
    ('KZ-IFRS-BS', 'AS-EXPLOR', 10, 'code_range', '2600', '2699', null, 'any'),
    ('KZ-IFRS-BS', 'AS-INTANG', 10, 'code_range', '2700', '2799', null, 'any'),
    ('KZ-IFRS-BS', 'AS-DTA', 10, 'code_range', '2800', '2899', null, 'any'),
    ('KZ-IFRS-BS', 'AS-ONCA', 10, 'code_range', '2900', '2999', null, 'any'),
    ('KZ-IFRS-BS', 'EQ-SHARE', 10, 'code_range', '5000', '5099', null, 'any'),
    ('KZ-IFRS-BS', 'EQ-UNPAID', 10, 'code_range', '5100', '5199', null, 'any'),
    ('KZ-IFRS-BS', 'EQ-PREMIUM', 10, 'code_range', '5300', '5399', null, 'any'),
    ('KZ-IFRS-BS', 'EQ-RESERVES', 10, 'code_range', '5500', '5599', null, 'any'),
    ('KZ-IFRS-BS', 'EQ-RETAINED', 10, 'code_range', '5600', '5699', null, 'any'),
    ('KZ-IFRS-BS', 'LI-STFIN', 10, 'code_range', '3000', '3099', null, 'any'),
    ('KZ-IFRS-BS', 'LI-TAX', 10, 'code_range', '3100', '3199', null, 'any'),
    ('KZ-IFRS-BS', 'LI-OTHERMAND', 10, 'code_range', '3200', '3299', null, 'any'),
    ('KZ-IFRS-BS', 'LI-STPAY', 10, 'code_range', '3300', '3399', null, 'any'),
    ('KZ-IFRS-BS', 'LI-STPROV', 10, 'code_range', '3400', '3499', null, 'any'),
    ('KZ-IFRS-BS', 'LI-OTHERST', 10, 'code_range', '3500', '3599', null, 'any'),
    ('KZ-IFRS-BS', 'LI-LTFIN', 10, 'code_range', '4000', '4099', null, 'any'),
    ('KZ-IFRS-BS', 'LI-LTPAY', 10, 'code_range', '4100', '4199', null, 'any'),
    ('KZ-IFRS-BS', 'LI-LTPROV', 10, 'code_range', '4200', '4299', null, 'any'),
    ('KZ-IFRS-BS', 'LI-DTL', 10, 'code_range', '4300', '4399', null, 'any'),
    ('KZ-IFRS-BS', 'LI-OTHERLT', 10, 'code_range', '4400', '4499', null, 'any'),
    ('KZ-IFRS-IS', 'IS-REV', 10, 'code_range', '6000', '6099', null, 'any'),
    ('KZ-IFRS-IS', 'IS-COGS', 10, 'code_range', '7000', '7099', null, 'any'),
    ('KZ-IFRS-IS', 'IS-SELL', 10, 'code_range', '7100', '7199', null, 'any'),
    ('KZ-IFRS-IS', 'IS-ADMIN', 10, 'code_range', '7200', '7299', null, 'any'),
    ('KZ-IFRS-IS', 'IS-OPINC', 10, 'code_range', '6200', '6299', null, 'any'),
    ('KZ-IFRS-IS', 'IS-OPEXP', 10, 'code_range', '7400', '7499', null, 'any'),
    ('KZ-IFRS-IS', 'IS-FININC', 10, 'code_range', '6100', '6199', null, 'any'),
    ('KZ-IFRS-IS', 'IS-FINEXP', 10, 'code_range', '7300', '7399', null, 'any'),
    ('KZ-IFRS-IS', 'IS-CIT', 10, 'code_range', '7700', '7799', null, 'any')
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
  ('KZ', 'Қазақстан', '{"en":"Kazakhstan","ru":"Казахстан"}'::jsonb, array['kk', 'ru', 'en']::text[], 'KZT', '1210', '3310', '3590', '7460', '5600', '6010', '7000', '1030', '1010', 'SAL', 'PUR', 'GEN', 'kk', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '6250', '7430', null, null, null, null, '3132', '1422', null, 'quarter'::declaration_period)
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
  number_format                 = '{CODE}-{NNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Салық кодексі (214-VIII), 492-бап — шот-фактура электрондық түрде электрондық шот-фактуралардың ақпараттық жүйесінде (ЭШФ АЖ) уәкілетті орган белгілеген тәртіппен және нысан бойынша жазылады; шот-фактураның нөмірі ЭШФ АЖ жүйесі бойынша беріледі, коммерциялық құжаттың (инвойстың) өз нөмірленуінен тәуелсіз. Заң коммерциялық құжаттың нөмірлену пішіміне міндетті талап қоймайды — мұндағы тізбекті нөмірлеу мысал ретінде берілген, жалғыз мүмкін пішін емес.',
  numbering_source_key          = 'tax-code-2026',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Салық кодексі (214-VIII), 380-382-баптар — сатылым бойынша айналымның мөлшерін анықтау тауарларды өткізу, жұмыстарды орындау, қызметтерді көрсету күнімен байланысты, ал шот-фактура көбіне тауар өткізілген/қызмет көрсетілген күні немесе одан кешіктірмей жазылады (492-бап). Бұл дестеде `invoice_if_issued` жуықтау ретінде алынған: жеткізу — қағида, ал шот-фактура — оны алдын ала жазуға мүмкіндік беретін ерекшелік. Алдын ала төлем алынған жағдайдағы үшінші триггерді осы socle көрсете алмайды (алдын ала төлем құжатының болмауынан) — қараңыз README.md және docs/international.md, «From Kazakhstan» бөлімі.',
  tax_point_source_key          = 'tax-code-2026',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = '«Бухгалтерлік есеп пен қаржылық есептілік туралы» Заң, 7-бап — бастапқы құжаттарға түзетулер із қалдыра отырып енгізіледі; Салық кодексі (214-VIII), 496-бап — салық салынатын айналымның мөлшерін түзету қосымша немесе түзетілген шот-фактура жазу арқылы жүзеге асырылады, бастапқы жазбаны өшірместен.',
  posted_edit_policy_source_key = 'tax-code-2026',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Салық кодексі (214-VIII), 492-бап — жалпы қағида бойынша шот-фактура электрондық түрде электрондық шот-фактуралардың ақпараттық жүйесінде (ЭШФ АЖ, esf.gov.kz) жазылады; қағаз түрінде жазу тек екі тар жағдайда рұқсат етіледі — салық төлеушінің орналасқан жері бойынша әкімшілік-аумақтық бірлік шегінде жалпыға қолжетімді телекоммуникация желісінің болмауы, немесе уәкілетті органның интернет-ресурсында ЭШФ АЖ-да техникалық ақаулар салдарынан шот-фактура жазу мүмкін еместігі туралы растама жарияланғаны. ЭШФ АЖ — мемлекеттің клирингтік жүйесі: шот-фактура сатушы мен сатып алушы арасында тікелей алмасылмайды, ол тікелей мемлекеттік бірыңғай тізілімге жазылады, содан кейін сатып алушыға өз кабинетінде автоматты түрде қолжетімді болады; бұл EN 16931 семантикалық моделіне (Peppol BIS, Factur-X, XRechnung, PINT) негізделмеген және ISO 6523 қатысушылар схемасын қолданбайды (Қазақстан Peppol қатысушылар тізімінде жоқ) — сондықтан `profile`, `party_scheme`, `vat_scheme` бос қалдырылған. Тіркелмеген ЭШФ бойынша сатып алушыда есепке жатқызу құқығы туындамайды. Бұл мемлекеттік тізілімге тіркеу, оның мерзімдері мен clearance тетігінің socle-де көрінбеу олқылығы README.md мен docs/international.md, «From Kazakhstan» бөлімінде құжатталған.',
  einvoice_source_key           = 'tax-code-2026',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'KZ';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('KZ', 'reverse_charge', 'reverse_charge', 'Резидент еместен алынған жұмыстар мен қызметтер бойынша қосылған құн салығын алушы дербес есептейді және бюджетке төлейді.', '{"en":"VAT on works and services acquired from a non-resident is self-assessed and paid by the recipient.","ru":"Налог на добавленную стоимость по работам, услугам, приобретенным у нерезидента, исчисляется и уплачивается получателем самостоятельно."}'::jsonb, 10, date '1970-01-01', null, 'Салық кодексі (214-VIII), резидент еместің жұмыстарын, көрсеткен қызметтерін сатып алу бойынша айналымды салық салынатын айналымға жатқызатын және оны алушыға есептеу мен төлеу міндетін жүктейтін бап — бұл дестеде мұндай салық коды әлі құрастырылмаған, тек ескерту ретінде беріледі; қараңыз docs/international.md, «From Kazakhstan» бөлімі.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
