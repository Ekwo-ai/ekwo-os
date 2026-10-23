-- Ekwo OS — Туркменистан: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/tm at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build tm`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Налоговый кодекс Туркменистана (новая редакция, с изменениями по состоянию на закон от 30 ноября 2024 г. и закон от 30 сентября 2025 г.) — статьи 95–113 (налог на добавленную стоимость), статья 30 (налоговая декларация) (Меджлис Туркменистана)
--     https://mejlis.gov.tm/single-code/10?lang=ru
--   Национальный стандарт финансовой отчётности для предприятий малого и среднего предпринимательства — утверждён приказом Министра финансов Туркменистана № 57-Ö от 1 апреля 2013 г. (зарегистрирован Министерством адалат № 686 от 16 апреля 2013 г.), с изменениями приказа № 117-Ö от 16 сентября 2015 г.; неофициальный перевод (Министерство финансов и экономики Туркменистана)
--     https://fineconomic.gov.tm/storage/app/uploads/public/5f4/f66/886/5f4f668867a33773552472.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--   Государственная налоговая служба при Министерстве финансов и экономики Туркменистана — электронный налог, личный кабинет юридических лиц и предпринимателей (Министерство финансов и экономики Туркменистана — Налоговое управление)
--     https://tax.gov.tm/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('TM', 'Туркменистан', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, '6ca8ae75222887e4e1927192c68da6ad05fc8c7a8b0693a4976f6d01a5e654e7', '[{"key":"tax-code","title":"Налоговый кодекс Туркменистана (новая редакция, с изменениями по состоянию на закон от 30 ноября 2024 г. и закон от 30 сентября 2025 г.) — статьи 95–113 (налог на добавленную стоимость), статья 30 (налоговая декларация)","publisher":"Меджлис Туркменистана","url":"https://mejlis.gov.tm/single-code/10?lang=ru","consulted_on":"2026-10-21","kind":"law"},{"key":"nsfo-sme","title":"Национальный стандарт финансовой отчётности для предприятий малого и среднего предпринимательства — утверждён приказом Министра финансов Туркменистана № 57-Ö от 1 апреля 2013 г. (зарегистрирован Министерством адалат № 686 от 16 апреля 2013 г.), с изменениями приказа № 117-Ö от 16 сентября 2015 г.; неофициальный перевод","publisher":"Министерство финансов и экономики Туркменистана","url":"https://fineconomic.gov.tm/storage/app/uploads/public/5f4/f66/886/5f4f668867a33773552472.pdf","consulted_on":"2026-10-21","kind":"standard"},{"key":"ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-21","kind":"standard"},{"key":"stss-portal","title":"Государственная налоговая служба при Министерстве финансов и экономики Туркменистана — электронный налог, личный кабинет юридических лиц и предпринимателей","publisher":"Министерство финансов и экономики Туркменистана — Налоговое управление","url":"https://tax.gov.tm/","consulted_on":"2026-10-21","kind":"portal"}]'::jsonb)
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
  ('TM', 'default', 'План счетов бухгалтерского учёта — коммерческие организации (собственная группировка пакета по классам НСФО МСП)', '{"en":"Chart of accounts of commercial organisations (the pack''s own grouping by the classes of the National Financial Reporting Standard for SMEs)"}'::jsonb, true, 'companies', array['TM-BS', 'TM-IS']::text[], null, 'Типовой план счетов Туркменистана не найден в открытых источниках: ни его текст, ни приказ, которым он утверждён, не удалось прочитать. Классы (1 оборотные активы, 2 внеоборотные активы, 3 краткосрочные обязательства, 4 долгосрочные обязательства, 5 собственный капитал, 6 доходы, 7–9 расходы) и все коды — группировка самого пакета по перечню статей Национального стандарта финансовой отчётности для МСП (раздел 2, пункт 58), а не переписанный официальный план. Бухгалтер, знающий действующий план, должен сверить его перед использованием. См. README.md.', 'nsfo-sme')
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
  ('TM', 'default', '1000', 'Оборотные активы', '{"en":"Current assets"}'::jsonb, 'asset_current', false, null, 10),
  ('TM', 'default', '1100', 'Касса', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, '1000', 20),
  ('TM', 'default', '1110', 'Денежные средства в кассе в национальной валюте', '{"en":"Cash in national currency"}'::jsonb, 'asset_cash', false, '1100', 30),
  ('TM', 'default', '1120', 'Денежные средства в кассе в иностранной валюте', '{"en":"Cash in foreign currency"}'::jsonb, 'asset_cash', false, '1100', 40),
  ('TM', 'default', '1200', 'Денежные средства в банках', '{"en":"Cash at bank"}'::jsonb, 'asset_cash', false, '1000', 50),
  ('TM', 'default', '1210', 'Расчётные счета в национальной валюте', '{"en":"Current accounts in national currency"}'::jsonb, 'asset_cash', false, '1200', 60),
  ('TM', 'default', '1220', 'Счета в иностранной валюте', '{"en":"Accounts in foreign currency"}'::jsonb, 'asset_cash', false, '1200', 70),
  ('TM', 'default', '1230', 'Денежные средства с ограничением использования', '{"en":"Cash restricted in use"}'::jsonb, 'asset_cash', false, '1200', 80),
  ('TM', 'default', '1300', 'Краткосрочные инвестиции', '{"en":"Short-term investments"}'::jsonb, 'asset_current', false, '1000', 90),
  ('TM', 'default', '1310', 'Краткосрочные ценные бумаги', '{"en":"Short-term securities"}'::jsonb, 'asset_current', false, '1300', 100),
  ('TM', 'default', '1320', 'Краткосрочные депозиты', '{"en":"Short-term deposits"}'::jsonb, 'asset_current', false, '1300', 110),
  ('TM', 'default', '1400', 'Дебиторская задолженность и векселя к получению', '{"en":"Accounts and notes receivable"}'::jsonb, 'asset_current', false, '1000', 120),
  ('TM', 'default', '1410', 'Дебиторская задолженность покупателей и заказчиков', '{"en":"Accounts receivable (customers)"}'::jsonb, 'asset_receivable', true, '1400', 130),
  ('TM', 'default', '1420', 'Задолженность связанных сторон', '{"en":"Receivables from related parties"}'::jsonb, 'asset_current', false, '1400', 140),
  ('TM', 'default', '1491', 'Резерв по сомнительным долгам', '{"en":"Allowance for doubtful debts"}'::jsonb, 'asset_current', false, '1400', 150),
  ('TM', 'default', '1500', 'Прочая краткосрочная дебиторская задолженность', '{"en":"Other short-term receivables"}'::jsonb, 'asset_current', false, '1000', 160),
  ('TM', 'default', '1510', 'Векселя к получению', '{"en":"Notes receivable"}'::jsonb, 'asset_current', false, '1500', 170),
  ('TM', 'default', '1520', 'Выданные авансы', '{"en":"Advances paid"}'::jsonb, 'asset_prepayments', false, '1500', 180),
  ('TM', 'default', '1530', 'Задолженность подотчётных лиц', '{"en":"Amounts held by accountable persons"}'::jsonb, 'asset_current', false, '1500', 190),
  ('TM', 'default', '1540', 'НДС к возмещению', '{"en":"VAT recoverable"}'::jsonb, 'asset_current', false, '1500', 200),
  ('TM', 'default', '1541', 'НДС по приобретённым товарам, работам и услугам', '{"en":"Input VAT on purchased goods, work and services"}'::jsonb, 'asset_current', false, '1540', 210),
  ('TM', 'default', '1542', 'Расчёты с бюджетом по НДС (к возмещению)', '{"en":"VAT settlement with the budget (refundable)"}'::jsonb, 'asset_current', true, '1540', 220),
  ('TM', 'default', '1543', 'НДС по услугам нерезидентов (после уплаты)', '{"en":"Input VAT on services from non-residents (after payment)"}'::jsonb, 'asset_current', false, '1540', 230),
  ('TM', 'default', '1550', 'Начисленные проценты к получению', '{"en":"Interest receivable"}'::jsonb, 'asset_current', false, '1500', 240),
  ('TM', 'default', '1560', 'Дивиденды к получению', '{"en":"Dividends receivable"}'::jsonb, 'asset_current', false, '1500', 250),
  ('TM', 'default', '1570', 'Переплата по прочим налогам', '{"en":"Overpaid other taxes"}'::jsonb, 'asset_current', false, '1500', 260),
  ('TM', 'default', '1590', 'Прочая краткосрочная дебиторская задолженность, разное', '{"en":"Other short-term receivables, miscellaneous"}'::jsonb, 'asset_current', false, '1500', 270),
  ('TM', 'default', '1600', 'Запасы', '{"en":"Inventories"}'::jsonb, 'asset_current', false, '1000', 280),
  ('TM', 'default', '1610', 'Товары для перепродажи', '{"en":"Goods for resale"}'::jsonb, 'asset_current', false, '1600', 290),
  ('TM', 'default', '1620', 'Сырьё и материалы', '{"en":"Raw materials"}'::jsonb, 'asset_current', false, '1600', 300),
  ('TM', 'default', '1625', 'Вспомогательные материалы', '{"en":"Auxiliary materials"}'::jsonb, 'asset_current', false, '1600', 310),
  ('TM', 'default', '1630', 'Незавершённое производство', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, '1600', 320),
  ('TM', 'default', '1635', 'Общепроизводственные расходы', '{"en":"Production overheads"}'::jsonb, 'asset_current', false, '1600', 330),
  ('TM', 'default', '1640', 'Готовая продукция', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, '1600', 340),
  ('TM', 'default', '1700', 'Расходы будущих периодов и прочие оборотные активы', '{"en":"Prepaid expenses and other current assets"}'::jsonb, 'asset_current', false, '1000', 350),
  ('TM', 'default', '1710', 'Расходы будущих периодов', '{"en":"Prepaid expenses"}'::jsonb, 'asset_current', false, '1700', 360),
  ('TM', 'default', '1750', 'Малоценные и быстроизнашивающиеся предметы', '{"en":"Low-value and short-life items"}'::jsonb, 'asset_current', false, '1700', 370),
  ('TM', 'default', '1790', 'Прочие оборотные активы', '{"en":"Other current assets"}'::jsonb, 'asset_current', false, '1700', 380),
  ('TM', 'default', '2000', 'Внеоборотные активы', '{"en":"Non-current assets"}'::jsonb, 'asset_non_current', false, null, 390),
  ('TM', 'default', '2100', 'Основные средства', '{"en":"Property, plant and equipment"}'::jsonb, 'asset_fixed', false, '2000', 400),
  ('TM', 'default', '2110', 'Земельные участки', '{"en":"Land"}'::jsonb, 'asset_fixed', false, '2100', 410),
  ('TM', 'default', '2120', 'Здания и сооружения', '{"en":"Buildings and structures"}'::jsonb, 'asset_fixed', false, '2100', 420),
  ('TM', 'default', '2130', 'Машины и оборудование', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, '2100', 430),
  ('TM', 'default', '2140', 'Транспортные средства', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, '2100', 440),
  ('TM', 'default', '2150', 'Мебель и офисное оборудование', '{"en":"Furniture and office equipment"}'::jsonb, 'asset_fixed', false, '2100', 450),
  ('TM', 'default', '2160', 'Прочие основные средства', '{"en":"Other property, plant and equipment"}'::jsonb, 'asset_fixed', false, '2100', 460),
  ('TM', 'default', '2193', 'Накопленная амортизация, производство', '{"en":"Accumulated depreciation, production"}'::jsonb, 'asset_fixed', false, '2100', 470),
  ('TM', 'default', '2199', 'Накопленная амортизация, прочее', '{"en":"Accumulated depreciation, other"}'::jsonb, 'asset_fixed', false, '2100', 480),
  ('TM', 'default', '2700', 'Долгосрочная дебиторская задолженность', '{"en":"Long-term receivables"}'::jsonb, 'asset_non_current', false, '2000', 490),
  ('TM', 'default', '2800', 'Долгосрочные инвестиции', '{"en":"Long-term investments"}'::jsonb, 'asset_non_current', false, '2000', 500),
  ('TM', 'default', '2900', 'Нематериальные активы', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, '2000', 510),
  ('TM', 'default', '2910', 'Нематериальные активы по первоначальной стоимости', '{"en":"Intangible assets, cost"}'::jsonb, 'asset_non_current', false, '2900', 520),
  ('TM', 'default', '2991', 'Накопленная амортизация нематериальных активов', '{"en":"Accumulated amortisation of intangibles"}'::jsonb, 'asset_non_current', false, '2900', 530),
  ('TM', 'default', '3000', 'Краткосрочные обязательства', '{"en":"Current liabilities"}'::jsonb, 'liability_current', false, null, 540),
  ('TM', 'default', '3100', 'Кредиторская задолженность и векселя к уплате', '{"en":"Accounts and notes payable"}'::jsonb, 'liability_current', false, '3000', 550),
  ('TM', 'default', '3110', 'Кредиторская задолженность поставщикам и подрядчикам', '{"en":"Accounts payable (suppliers)"}'::jsonb, 'liability_payable', true, '3100', 560),
  ('TM', 'default', '3120', 'Векселя к уплате', '{"en":"Notes payable"}'::jsonb, 'liability_current', false, '3100', 570),
  ('TM', 'default', '3200', 'Полученные авансы', '{"en":"Advances received"}'::jsonb, 'liability_current', false, '3000', 580),
  ('TM', 'default', '3210', 'Авансы, полученные от покупателей', '{"en":"Advances received from customers"}'::jsonb, 'liability_current', false, '3200', 590),
  ('TM', 'default', '3300', 'Краткосрочные кредиты и займы', '{"en":"Short-term loans and borrowings"}'::jsonb, 'liability_current', false, '3000', 600),
  ('TM', 'default', '3310', 'Краткосрочные банковские кредиты', '{"en":"Short-term bank loans"}'::jsonb, 'liability_current', false, '3300', 610),
  ('TM', 'default', '3320', 'Прочие краткосрочные займы', '{"en":"Other short-term borrowings"}'::jsonb, 'liability_current', false, '3300', 620),
  ('TM', 'default', '3330', 'Текущая часть долгосрочных обязательств', '{"en":"Current portion of long-term debt"}'::jsonb, 'liability_current', false, '3300', 630),
  ('TM', 'default', '3400', 'Налоги к уплате', '{"en":"Taxes payable"}'::jsonb, 'liability_current', false, '3000', 640),
  ('TM', 'default', '3410', 'Налог на прибыль (доход) к уплате', '{"en":"Income tax payable"}'::jsonb, 'liability_current', false, '3400', 650),
  ('TM', 'default', '3420', 'Подоходный налог с физических лиц к уплате', '{"en":"Personal income tax payable"}'::jsonb, 'liability_current', false, '3400', 660),
  ('TM', 'default', '3430', 'НДС к уплате', '{"en":"VAT payable"}'::jsonb, 'liability_current', false, '3400', 670),
  ('TM', 'default', '3431', 'НДС, начисленный по облагаемым продажам', '{"en":"VAT charged on taxable sales"}'::jsonb, 'liability_current', false, '3430', 680),
  ('TM', 'default', '3432', 'Расчёты с бюджетом по НДС (к уплате)', '{"en":"VAT settlement with the budget (payable)"}'::jsonb, 'liability_current', true, '3430', 690),
  ('TM', 'default', '3433', 'НДС к уплате налоговым агентом за нерезидента', '{"en":"VAT payable by the tax agent for a non-resident"}'::jsonb, 'liability_current', false, '3430', 700),
  ('TM', 'default', '3440', 'Акцизы к уплате', '{"en":"Excise tax payable"}'::jsonb, 'liability_current', false, '3400', 710),
  ('TM', 'default', '3450', 'Прочие налоги к уплате (продажи)', '{"en":"Other taxes payable (sales)"}'::jsonb, 'liability_current', false, '3400', 720),
  ('TM', 'default', '3460', 'Прочие налоги к уплате', '{"en":"Other taxes payable"}'::jsonb, 'liability_current', false, '3400', 730),
  ('TM', 'default', '3500', 'Начисленные обязательства', '{"en":"Accrued liabilities"}'::jsonb, 'liability_current', false, '3000', 740),
  ('TM', 'default', '3510', 'Начисленные расходы', '{"en":"Accrued expenses"}'::jsonb, 'liability_current', false, '3500', 750),
  ('TM', 'default', '3520', 'Задолженность по заработной плате', '{"en":"Salaries payable"}'::jsonb, 'liability_current', false, '3500', 760),
  ('TM', 'default', '3530', 'Взносы на социальное страхование к уплате', '{"en":"Social insurance contributions payable"}'::jsonb, 'liability_current', false, '3500', 770),
  ('TM', 'default', '3540', 'Дивиденды к выплате', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, '3500', 780),
  ('TM', 'default', '3550', 'Начисленные проценты к уплате', '{"en":"Accrued interest"}'::jsonb, 'liability_current', false, '3500', 790),
  ('TM', 'default', '3590', 'Прочие начисленные обязательства', '{"en":"Other accrued liabilities"}'::jsonb, 'liability_current', false, '3500', 800),
  ('TM', 'default', '3600', 'Прочие краткосрочные обязательства', '{"en":"Other current liabilities"}'::jsonb, 'liability_current', false, '3000', 810),
  ('TM', 'default', '3690', 'Прочие краткосрочные обязательства, разное', '{"en":"Other current liabilities, miscellaneous"}'::jsonb, 'liability_current', false, '3600', 820),
  ('TM', 'default', '3699', 'Счёт расчётов до выяснения', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, '3600', 830),
  ('TM', 'default', '3700', 'Резервы', '{"en":"Provisions"}'::jsonb, 'liability_current', false, '3000', 840),
  ('TM', 'default', '3710', 'Резерв отпусков', '{"en":"Provision for unused leave"}'::jsonb, 'liability_current', false, '3700', 850),
  ('TM', 'default', '3790', 'Прочие резервы', '{"en":"Other provisions"}'::jsonb, 'liability_current', false, '3700', 860),
  ('TM', 'default', '4000', 'Долгосрочные обязательства', '{"en":"Non-current liabilities"}'::jsonb, 'liability_non_current', false, null, 870),
  ('TM', 'default', '4100', 'Долгосрочная задолженность', '{"en":"Long-term debt"}'::jsonb, 'liability_non_current', false, '4000', 880),
  ('TM', 'default', '4110', 'Облигации к уплате', '{"en":"Bonds payable"}'::jsonb, 'liability_non_current', false, '4100', 890),
  ('TM', 'default', '4120', 'Банковские кредиты', '{"en":"Bank loans"}'::jsonb, 'liability_non_current', false, '4100', 900),
  ('TM', 'default', '4130', 'Прочие займы', '{"en":"Other loans"}'::jsonb, 'liability_non_current', false, '4100', 910),
  ('TM', 'default', '4140', 'Долгосрочные векселя к уплате', '{"en":"Notes payable, long-term"}'::jsonb, 'liability_non_current', false, '4100', 920),
  ('TM', 'default', '4150', 'Обязательства по финансовой аренде', '{"en":"Finance lease obligations"}'::jsonb, 'liability_non_current', false, '4100', 930),
  ('TM', 'default', '4160', 'Прочие долгосрочные обязательства', '{"en":"Other long-term liabilities"}'::jsonb, 'liability_non_current', false, '4100', 940),
  ('TM', 'default', '4191', 'Неамортизированная скидка (премия) по облигациям', '{"en":"Unamortised bond discount (premium)"}'::jsonb, 'liability_non_current', false, '4100', 950),
  ('TM', 'default', '5000', 'Собственный капитал', '{"en":"Equity"}'::jsonb, 'equity', false, null, 960),
  ('TM', 'default', '5100', 'Уставный капитал', '{"en":"Share capital"}'::jsonb, 'equity', false, '5000', 970),
  ('TM', 'default', '5110', 'Обыкновенные акции', '{"en":"Ordinary shares"}'::jsonb, 'equity', false, '5100', 980),
  ('TM', 'default', '5120', 'Привилегированные акции', '{"en":"Preference shares"}'::jsonb, 'equity', false, '5100', 990),
  ('TM', 'default', '5130', 'Прочий уставный капитал (доли участников)', '{"en":"Other share capital (participants'' interests)"}'::jsonb, 'equity', false, '5100', 1000),
  ('TM', 'default', '5191', 'Выкупленные собственные акции', '{"en":"Treasury shares"}'::jsonb, 'equity', false, '5100', 1010),
  ('TM', 'default', '5200', 'Дополнительный оплаченный капитал', '{"en":"Additional paid-in capital"}'::jsonb, 'equity', false, '5000', 1020),
  ('TM', 'default', '5210', 'Эмиссионный доход', '{"en":"Share premium"}'::jsonb, 'equity', false, '5200', 1030),
  ('TM', 'default', '5300', 'Нераспределённая прибыль', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, '5000', 1040),
  ('TM', 'default', '5400', 'Резервный капитал', '{"en":"Reserve capital"}'::jsonb, 'equity', false, '5000', 1050),
  ('TM', 'default', '5999', 'Итоговый счёт прибылей и убытков (закрытие)', '{"en":"Income summary (closing account)"}'::jsonb, 'equity', false, '5000', 1060),
  ('TM', 'default', '6000', 'Доходы', '{"en":"Income"}'::jsonb, 'income', false, null, 1070),
  ('TM', 'default', '6100', 'Выручка', '{"en":"Revenue"}'::jsonb, 'income', false, '6000', 1080),
  ('TM', 'default', '6110', 'Выручка от продажи товаров, работ и услуг', '{"en":"Revenue from goods, works and services"}'::jsonb, 'income', false, '6100', 1090),
  ('TM', 'default', '6120', 'Возвраты и скидки покупателям', '{"en":"Sales returns and discounts"}'::jsonb, 'income', false, '6100', 1100),
  ('TM', 'default', '6200', 'Прочие операционные доходы', '{"en":"Other operating income"}'::jsonb, 'income_other', false, '6000', 1110),
  ('TM', 'default', '6210', 'Доходы от операционной аренды', '{"en":"Operating lease income"}'::jsonb, 'income_other', false, '6200', 1120),
  ('TM', 'default', '6290', 'Доходы от курсовых разниц', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, '6200', 1130),
  ('TM', 'default', '7000', 'Операционные расходы', '{"en":"Operating expenses"}'::jsonb, 'expense', false, null, 1140),
  ('TM', 'default', '7100', 'Себестоимость проданной продукции и услуг', '{"en":"Cost of products and services sold"}'::jsonb, 'expense_direct_cost', false, '7000', 1150),
  ('TM', 'default', '7110', 'Прямые материалы', '{"en":"Direct materials"}'::jsonb, 'expense_direct_cost', false, '7100', 1160),
  ('TM', 'default', '7130', 'Прямые затраты на оплату труда', '{"en":"Direct labour"}'::jsonb, 'expense_direct_cost', false, '7100', 1170),
  ('TM', 'default', '7150', 'Амортизация, производство', '{"en":"Depreciation, production"}'::jsonb, 'expense_direct_cost', false, '7100', 1180),
  ('TM', 'default', '7200', 'Себестоимость проданных товаров', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, '7000', 1190),
  ('TM', 'default', '7210', 'Закупка товаров', '{"en":"Purchases of goods"}'::jsonb, 'expense_direct_cost', false, '7200', 1200),
  ('TM', 'default', '7290', 'Корректировки запасов', '{"en":"Inventory adjustments"}'::jsonb, 'expense_direct_cost', false, '7200', 1210),
  ('TM', 'default', '7500', 'Расходы на продажу', '{"en":"Selling expenses"}'::jsonb, 'expense', false, '7000', 1220),
  ('TM', 'default', '7510', 'Реклама и продвижение', '{"en":"Advertising and promotion"}'::jsonb, 'expense', false, '7500', 1230),
  ('TM', 'default', '7520', 'Транспорт и доставка покупателям', '{"en":"Transport and delivery to customers"}'::jsonb, 'expense', false, '7500', 1240),
  ('TM', 'default', '7530', 'Расходы на оплату труда персонала по продажам', '{"en":"Selling staff costs"}'::jsonb, 'expense', false, '7500', 1250),
  ('TM', 'default', '7550', 'Безнадёжные долги', '{"en":"Bad debts"}'::jsonb, 'expense', false, '7500', 1260),
  ('TM', 'default', '7560', 'Расходы по гарантийным обязательствам', '{"en":"Warranty costs"}'::jsonb, 'expense', false, '7500', 1270),
  ('TM', 'default', '7580', 'Амортизация, продажи', '{"en":"Depreciation, selling"}'::jsonb, 'expense', false, '7500', 1280),
  ('TM', 'default', '7590', 'Расходы на бонусы по продажам', '{"en":"Sales bonus costs"}'::jsonb, 'expense', false, '7500', 1290),
  ('TM', 'default', '7600', 'Прочие операционные расходы', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, '7000', 1300),
  ('TM', 'default', '7610', 'Расходы от курсовых разниц', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, '7600', 1310),
  ('TM', 'default', '7690', 'Разницы от округления', '{"en":"Rounding differences"}'::jsonb, 'expense', false, '7600', 1320),
  ('TM', 'default', '8000', 'Общие и административные расходы', '{"en":"General and administrative expenses"}'::jsonb, 'expense', false, null, 1330),
  ('TM', 'default', '8110', 'Расходы на оплату труда административного персонала', '{"en":"Administrative staff costs"}'::jsonb, 'expense', false, '8000', 1340),
  ('TM', 'default', '8120', 'Аренда', '{"en":"Rent"}'::jsonb, 'expense', false, '8000', 1350),
  ('TM', 'default', '8130', 'Коммунальные услуги', '{"en":"Utilities"}'::jsonb, 'expense', false, '8000', 1360),
  ('TM', 'default', '8140', 'Услуги связи', '{"en":"Telecommunications"}'::jsonb, 'expense', false, '8000', 1370),
  ('TM', 'default', '8150', 'Услуги сторонних организаций', '{"en":"Outsourced services"}'::jsonb, 'expense', false, '8000', 1380),
  ('TM', 'default', '8210', 'Командировочные расходы', '{"en":"Business travel"}'::jsonb, 'expense', false, '8000', 1390),
  ('TM', 'default', '8310', 'Налоги, кроме налога на прибыль', '{"en":"Taxes other than income tax"}'::jsonb, 'expense', false, '8000', 1400),
  ('TM', 'default', '8470', 'Амортизация основных средств', '{"en":"Depreciation of property, plant and equipment"}'::jsonb, 'expense', false, '8000', 1410),
  ('TM', 'default', '8480', 'Амортизация нематериальных активов', '{"en":"Amortisation of intangibles"}'::jsonb, 'expense', false, '8000', 1420),
  ('TM', 'default', '8490', 'Прочие административные расходы', '{"en":"Other administrative expenses"}'::jsonb, 'expense', false, '8000', 1430),
  ('TM', 'default', '9100', 'Внереализационные доходы', '{"en":"Non-operating income"}'::jsonb, 'income_other', false, null, 1440),
  ('TM', 'default', '9190', 'Прочие внереализационные доходы', '{"en":"Other non-operating income"}'::jsonb, 'income_other', false, '9100', 1450),
  ('TM', 'default', '9500', 'Внереализационные расходы', '{"en":"Non-operating expenses"}'::jsonb, 'expense', false, null, 1460),
  ('TM', 'default', '9590', 'Прочие внереализационные расходы', '{"en":"Other non-operating expenses"}'::jsonb, 'expense', false, '9500', 1470),
  ('TM', 'default', '9600', 'Расходы по налогу на прибыль', '{"en":"Income tax expense"}'::jsonb, 'expense', false, null, 1480),
  ('TM', 'default', '9610', 'Текущий налог на прибыль', '{"en":"Current income tax"}'::jsonb, 'expense', false, '9600', 1490)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('TM', 'BNK', 'Банковский журнал', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('TM', 'CSH', 'Кассовый журнал', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('TM', 'GEN', 'Общий журнал', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('TM', 'OPN', 'Журнал начальных остатков', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('TM', 'PUR', 'Журнал покупок', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('TM', 'SAL', 'Журнал продаж', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('TM', 'TM-P-15', 'НДС 15 % — общая ставка (покупка)', '{"en":"VAT 15% — standard rate (purchase)"}'::jsonb, null, 'percent', 15, 'purchase', 'domestic', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 110, части 1 и 2 — суммой засчитываемого налога являются суммы налога, уплаченные налогоплательщиком поставщикам товаров (работ, услуг) в налоговом периоде; основанием для зачёта служат налоговая счёт-фактура и документы, подтверждающие оплату. Пакет относит налог в зачёт по счёту-фактуре; условие оплаты поставщику остаётся на усмотрение бухгалтера (README.md).', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-P-15-NR', 'НДС 15 % — услуги иностранного лица, удерживаемый налоговым агентом (покупка)', '{"en":"VAT 15% — services of a foreign person, withheld by the tax agent (purchase)"}'::jsonb, 'НДС с услуг иностранного лица исчисляется и удерживается налоговым агентом, уплачивается в бюджет, а право на зачёт возникает после уплаты', 'percent', 15, 'purchase', 'foreign_services_received', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 108, часть 2 — если иностранное юридическое лицо или иностранный индивидуальный предприниматель совершает на территории Туркменистана налогооблагаемые операции и не состоит на налоговом учёте, налог исчисляется и удерживается налоговым агентом, оплачивающим стоимость приобретаемых товаров (работ, услуг); налоговым агентом признаются резидент — юридическое лицо и индивидуальный предприниматель, состоящий на налоговом учёте. Статья 111, часть 4 — уплата удержанного налога в бюджет. Начисленный налог проводится по счёту 3433, право на зачёт ожидает на счёте 1543 и переносится на 1541 ручной проводкой после уплаты (статья 110, часть 1 — зачёту подлежит налог, уплаченный поставщикам). Декларацию по НДС такие иностранные лица не представляют (статья 111, часть 2); налоговый агент представляет отчёт о выплатах нерезидентам — он вне этого пакета (README.md).', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-S-15', 'НДС 15 % — общая ставка (продажа)', '{"en":"VAT 15% — standard rate (sale)"}'::jsonb, null, 'percent', 15, 'sale', 'domestic', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 103 — ставка налога на добавленную стоимость устанавливается в размере 15 процентов в отношении налогооблагаемых операций, кроме операций, указанных в статье 105 (нулевая ставка). Налог предъявляется покупателю отдельной строкой (статья 107, часть 3).', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-S-EXEMPT-EDUCATION', 'НДС не уплачивается — услуги в системе образования (продажа)', '{"en":"VAT-exempt — education services (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 106, часть 1 — налог на добавленную стоимость не уплачивается при оказании услуг в системе образования. Счёт-фактура выписывается без выделения налога (статья 107, часть 5).', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-S-EXEMPT-INSURANCE', 'НДС не уплачивается — услуги по страхованию и перестрахованию (продажа)', '{"en":"VAT-exempt — insurance and reinsurance services (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 106, часть 1 — налог на добавленную стоимость не уплачивается при оказании услуг по страхованию и перестрахованию страховыми организациями. Счёт-фактура выписывается без выделения налога (статья 107, часть 5).', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-S-EXEMPT-MEDICINES', 'НДС не уплачивается — лекарственные средства и изделия медицинского назначения (продажа)', '{"en":"VAT-exempt — medicines and medical products (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 106, часть 1 — налог на добавленную стоимость не уплачивается при реализации лекарственных средств, медикаментов, средств дезинфекции, изделий медицинского назначения, медицинской техники, протезно-ортопедических изделий и специальных транспортных средств для инвалидов. Счёт-фактура выписывается без выделения налога с надписью «Без налога на добавленную стоимость» (статья 107, часть 5).', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-S-ZERO-EXPORT', 'НДС 0 % — экспорт товаров (продажа)', '{"en":"VAT 0% — export of goods (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 105, абзац первый — нулевая ставка применяется при реализации на экспорт товаров как собственного производства, так и приобретённых, за исключением природного (попутного) газа, нефти и продуктов их переработки; экспортом считается вывоз за пределы Туркменистана при наличии подтверждения пересечения таможенной границы.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('TM', 'TM-S-ZERO-TRANSPORT', 'НДС 0 % — международные перевозки (продажа)', '{"en":"VAT 0% — international transport (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 105 — нулевая ставка применяется к услугам по осуществлению международных перевозок пассажиров и грузов; перевозки, когда пункт отправления и назначения находятся на территории Туркменистана, международными не являются.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null)
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
    ('TM-P-15', 'invoice', 'base', 100, null, 'INPUT', array['INPUT']::text[], 100, 'TM-VAT', 10),
    ('TM-P-15', 'invoice', 'tax', 100, '1541', 'INPUT', array['INPUT']::text[], 100, 'TM-VAT', 20),
    ('TM-P-15', 'credit_note', 'base', 100, null, 'INPUT', array['INPUT']::text[], -100, 'TM-VAT', 10),
    ('TM-P-15', 'credit_note', 'tax', 100, '1541', 'INPUT', array['INPUT']::text[], -100, 'TM-VAT', 20),
    ('TM-P-15-NR', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TM-P-15-NR', 'invoice', 'tax', 100, '1543', null, null, 100, null, 20),
    ('TM-P-15-NR', 'invoice', 'tax', -100, '3433', null, null, 100, null, 30),
    ('TM-P-15-NR', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TM-P-15-NR', 'credit_note', 'tax', 100, '1543', null, null, 100, null, 20),
    ('TM-P-15-NR', 'credit_note', 'tax', -100, '3433', null, null, 100, null, 30),
    ('TM-S-15', 'invoice', 'base', 100, null, 'TAXABLE', array['TAXABLE']::text[], 100, 'TM-VAT', 10),
    ('TM-S-15', 'invoice', 'tax', 100, '3431', 'TAXABLE', array['TAXABLE']::text[], 100, 'TM-VAT', 20),
    ('TM-S-15', 'credit_note', 'base', 100, null, 'TAXABLE', array['TAXABLE']::text[], -100, 'TM-VAT', 10),
    ('TM-S-15', 'credit_note', 'tax', 100, '3431', 'TAXABLE', array['TAXABLE']::text[], -100, 'TM-VAT', 20),
    ('TM-S-EXEMPT-EDUCATION', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'TM-VAT', 10),
    ('TM-S-EXEMPT-EDUCATION', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'TM-VAT', 10),
    ('TM-S-EXEMPT-INSURANCE', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'TM-VAT', 10),
    ('TM-S-EXEMPT-INSURANCE', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'TM-VAT', 10),
    ('TM-S-EXEMPT-MEDICINES', 'invoice', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], 100, 'TM-VAT', 10),
    ('TM-S-EXEMPT-MEDICINES', 'credit_note', 'base', 100, null, 'EXEMPT', array['EXEMPT']::text[], -100, 'TM-VAT', 10),
    ('TM-S-ZERO-EXPORT', 'invoice', 'base', 100, null, 'ZERO', array['ZERO']::text[], 100, 'TM-VAT', 10),
    ('TM-S-ZERO-EXPORT', 'credit_note', 'base', 100, null, 'ZERO', array['ZERO']::text[], -100, 'TM-VAT', 10),
    ('TM-S-ZERO-TRANSPORT', 'invoice', 'base', 100, null, 'ZERO', array['ZERO']::text[], 100, 'TM-VAT', 10),
    ('TM-S-ZERO-TRANSPORT', 'credit_note', 'base', 100, null, 'ZERO', array['ZERO']::text[], -100, 'TM-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'TM' and t.code = v.tax_code
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
  ('TM', 'TM-VAT', 'Декларация по налогу на добавленную стоимость', array['month']::declaration_period[], 'month'::declaration_period, date '2004-11-01', null, 'Налоговый кодекс Туркменистана, статья 104, часть 1 — налоговый и отчётный периоды по НДС для юридических лиц равны календарному месяцу; статья 111, часть 1 — декларация представляется не позднее 20 числа месяца, следующего за отчётным периодом. Форма декларации утверждается Министерством финансов и экономики (статья 30, часть 1) и не найдена в открытых источниках: ячейки названы по статьям Кодекса (TAXABLE, ZERO, EXEMPT, TURNOVER, INPUT, CREDIT, PAYABLE, EXCESS). См. README.md.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Налоговый кодекс Туркменистана, статья 111, часть 1 — декларация по НДС представляется за истёкший отчётный период не позднее 20 числа месяца, следующего за отчётным периодом; часть 3 — налог уплачивается не позднее 25 числа. Часть 6 позволяет Министерству финансов и экономики установить для отдельных категорий иные сроки, но не более чем на тридцать дней позже: пакет несёт общий срок.', 'tax-code', null)
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
  ('TM', 'TM-VAT', 'TAXABLE', 'base', 'Облагаемые продажи по ставке 15 % — налоговая база', '{"en":"Taxable sales at 15% — taxable value"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статьи 100 и 103.', 'tax-code'),
  ('TM', 'TM-VAT', 'TAXABLE', 'tax', 'Облагаемые продажи по ставке 15 % — начисленный НДС', '{"en":"Taxable sales at 15% — VAT charged"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статьи 100 и 103.', 'tax-code'),
  ('TM', 'TM-VAT', 'ZERO', 'base', 'Операции по нулевой ставке (экспорт, международные перевозки)', '{"en":"Zero-rated sales (export, international transport)"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статья 105.', 'tax-code'),
  ('TM', 'TM-VAT', 'EXEMPT', 'base', 'Операции, освобождённые от НДС (статья 106)', '{"en":"Operations not subject to VAT (article 106)"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статья 106.', 'tax-code'),
  ('TM', 'TM-VAT', 'TURNOVER', 'total', 'Общий оборот за период', '{"en":"Total sales of the period"}'::jsonb, 50, null, array['TAXABLE:base', 'ZERO', 'EXEMPT']::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статьи 100 и 108.', 'tax-code'),
  ('TM', 'TM-VAT', 'INPUT', 'base', 'Приобретённые товары, работы и услуги — стоимость без НДС', '{"en":"Purchased goods, work and services — value excluding VAT"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статья 110.', 'tax-code'),
  ('TM', 'TM-VAT', 'INPUT', 'tax', 'Приобретённые товары, работы и услуги — НДС к зачёту', '{"en":"Purchased goods, work and services — input VAT"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статья 110.', 'tax-code'),
  ('TM', 'TM-VAT', 'CREDIT', 'total', 'Сумма налога, засчитываемая за период', '{"en":"Creditable tax for the period"}'::jsonb, 80, null, array['INPUT:tax']::text[], '{}'::text[], null, null, false, false, null, 'Налоговый кодекс Туркменистана, статья 110.', 'tax-code'),
  ('TM', 'TM-VAT', 'PAYABLE', 'total', 'НДС к уплате в Государственный бюджет', '{"en":"VAT payable to the state budget"}'::jsonb, 90, null, array['TAXABLE:tax']::text[], array['CREDIT']::text[], null, null, true, false, null, 'Налоговый кодекс Туркменистана, статья 108, часть 4.', 'tax-code'),
  ('TM', 'TM-VAT', 'EXCESS', 'total', 'Превышение засчитываемого налога (к возврату или зачёту)', '{"en":"Excess of deductible VAT (refundable)"}'::jsonb, 100, null, array['CREDIT']::text[], array['TAXABLE:tax']::text[], null, null, true, false, null, 'Налоговый кодекс Туркменистана, статья 108, часть 6 — превышение подлежит возврату либо зачёту.', 'tax-code')
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
  ('TM-BS', 'TM', 'default', 'Отчёт о финансовом положении (баланс)', 'balance_sheet', 'НСФО МСП', date '2013-04-01', null, 'Национальный стандарт финансовой отчётности для предприятий малого и среднего предпринимательства (приказ Министра финансов Туркменистана № 57-Ö от 1 апреля 2013 г., с изменениями приказа № 117-Ö от 16 сентября 2015 г.), раздел 2, пункт 58 — перечень статей, которые должны быть представлены в отчёте о финансовом положении. Стандарт называет статьи, а не их порядок и не номера счетов: строки собраны самим пакетом по классам его плана счетов, это не форма, утверждённая Министерством финансов и экономики. См. README.md.', 'nsfo-sme', 'combined', 'Результат текущего финансового года', '{"en":"Result of the current financial year"}'::jsonb),
  ('TM-IS', 'TM', 'default', 'Отчёт о совокупной прибыли (о прибылях и убытках)', 'income_statement', 'НСФО МСП', date '2013-04-01', null, 'Национальный стандарт финансовой отчётности для предприятий малого и среднего предпринимательства (приказ Министра финансов Туркменистана № 57-Ö от 1 апреля 2013 г.), раздел 2, пункты 64 и далее — отчёт о совокупной прибыли. Строки собраны самим пакетом по классам плана счетов, это не утверждённая форма. См. README.md.', 'nsfo-sme', null, null, '{}'::jsonb)
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
  ('TM-BS', 'AS-CASH', null, 'Денежные средства', '{"en":"Cash"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-STINV', null, 'Краткосрочные инвестиции', '{"en":"Short-term investments"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-REC', null, 'Дебиторская задолженность и векселя к получению', '{"en":"Accounts and notes receivable"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-OREC', null, 'Прочая дебиторская задолженность, авансы и НДС к возмещению', '{"en":"Other receivables, advances and recoverable VAT"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-INV', null, 'Запасы', '{"en":"Inventories"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-OCA', null, 'Расходы будущих периодов и прочие оборотные активы', '{"en":"Prepaid expenses and other current assets"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-CA-TOTAL', null, 'Итого оборотные активы', '{"en":"Total current assets"}'::jsonb, 70, 1, true, array['AS-CASH', 'AS-STINV', 'AS-REC', 'AS-OREC', 'AS-INV', 'AS-OCA']::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-PPE', null, 'Основные средства (за вычетом накопленной амортизации)', '{"en":"Property, plant and equipment, net"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-ONCA', null, 'Прочие внеоборотные активы', '{"en":"Other non-current assets"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-INTANG', null, 'Нематериальные активы (за вычетом амортизации)', '{"en":"Intangible assets, net"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-NCA-TOTAL', null, 'Итого внеоборотные активы', '{"en":"Total non-current assets"}'::jsonb, 110, 1, true, array['AS-PPE', 'AS-ONCA', 'AS-INTANG']::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'AS-TOTAL', null, 'Итого активы', '{"en":"Total assets"}'::jsonb, 120, 1, true, array['AS-CA-TOTAL', 'AS-NCA-TOTAL']::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQ-SHARE', null, 'Уставный капитал', '{"en":"Share capital"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQ-APIC', null, 'Дополнительный оплаченный капитал', '{"en":"Additional paid-in capital"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQ-RETAINED', null, 'Нераспределённая прибыль', '{"en":"Retained earnings"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQ-RESERVE', null, 'Резервный капитал', '{"en":"Reserve capital"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQ-SUMMARY', null, 'Итоговый счёт прибылей и убытков (закрытие)', '{"en":"Income summary (closing account)"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQ-TOTAL', null, 'Итого собственный капитал', '{"en":"Total equity"}'::jsonb, 180, 1, true, array['EQ-SHARE', 'EQ-APIC', 'EQ-RETAINED', 'EQ-RESERVE', 'EQ-SUMMARY']::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-PAY', null, 'Кредиторская задолженность и векселя к уплате', '{"en":"Accounts and notes payable"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-ADV', null, 'Полученные авансы', '{"en":"Advances received"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-DEBT', null, 'Краткосрочные кредиты и займы', '{"en":"Short-term loans and borrowings"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-TAX', null, 'Налоги к уплате', '{"en":"Taxes payable"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-ACCR', null, 'Начисленные обязательства', '{"en":"Accrued liabilities"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-OTHER', null, 'Прочие краткосрочные обязательства', '{"en":"Other current liabilities"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-PROV', null, 'Резервы', '{"en":"Provisions"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-CL-TOTAL', null, 'Итого краткосрочные обязательства', '{"en":"Total current liabilities"}'::jsonb, 260, 1, true, array['LI-PAY', 'LI-ADV', 'LI-DEBT', 'LI-TAX', 'LI-ACCR', 'LI-OTHER', 'LI-PROV']::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-LT', null, 'Долгосрочные обязательства', '{"en":"Non-current liabilities"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'LI-NCL-TOTAL', null, 'Итого долгосрочные обязательства', '{"en":"Total non-current liabilities"}'::jsonb, 280, 1, true, array['LI-LT']::text[], '{}'::text[], null, null, null),
  ('TM-BS', 'EQLI-TOTAL', null, 'Итого собственный капитал и обязательства', '{"en":"Total equity and liabilities"}'::jsonb, 290, 1, true, array['EQ-TOTAL', 'LI-CL-TOTAL', 'LI-NCL-TOTAL']::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-REV', null, 'Выручка за вычетом возвратов и скидок', '{"en":"Revenue, net of returns and discounts"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-COGS', null, 'Себестоимость продаж', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-GROSS', null, 'Валовая прибыль', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['IS-REV']::text[], array['IS-COGS']::text[], null, null, null),
  ('TM-IS', 'IS-SELL', null, 'Расходы на продажу', '{"en":"Selling expenses"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-ADMIN', null, 'Общие и административные расходы', '{"en":"General and administrative expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-OPINC', null, 'Прочие операционные доходы', '{"en":"Other operating income"}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-OPEXP', null, 'Прочие операционные расходы', '{"en":"Other operating expenses"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-OPRESULT', null, 'Операционный результат', '{"en":"Operating result"}'::jsonb, 80, 1, true, array['IS-GROSS', 'IS-OPINC']::text[], array['IS-SELL', 'IS-ADMIN', 'IS-OPEXP']::text[], null, null, null),
  ('TM-IS', 'IS-NONINC', null, 'Внереализационные доходы', '{"en":"Non-operating income"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-NONEXP', null, 'Внереализационные расходы', '{"en":"Non-operating expenses"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-PRETAX', null, 'Прибыль до налогообложения', '{"en":"Profit before tax"}'::jsonb, 110, 1, true, array['IS-OPRESULT', 'IS-NONINC']::text[], array['IS-NONEXP']::text[], null, null, null),
  ('TM-IS', 'IS-TAX', null, 'Расходы по налогу на прибыль', '{"en":"Income tax expense"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TM-IS', 'IS-NET', null, 'Чистая прибыль', '{"en":"Net profit"}'::jsonb, 130, 1, true, array['IS-PRETAX']::text[], array['IS-TAX']::text[], null, null, null)
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
 where r.statement_code in ('TM-BS', 'TM-IS')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('TM-BS', 'AS-CASH', 10),
            ('TM-BS', 'AS-STINV', 10),
            ('TM-BS', 'AS-REC', 10),
            ('TM-BS', 'AS-OREC', 10),
            ('TM-BS', 'AS-INV', 10),
            ('TM-BS', 'AS-OCA', 10),
            ('TM-BS', 'AS-PPE', 10),
            ('TM-BS', 'AS-ONCA', 10),
            ('TM-BS', 'AS-INTANG', 10),
            ('TM-BS', 'EQ-SHARE', 10),
            ('TM-BS', 'EQ-APIC', 10),
            ('TM-BS', 'EQ-RETAINED', 10),
            ('TM-BS', 'EQ-RESERVE', 10),
            ('TM-BS', 'EQ-SUMMARY', 10),
            ('TM-BS', 'LI-PAY', 10),
            ('TM-BS', 'LI-ADV', 10),
            ('TM-BS', 'LI-DEBT', 10),
            ('TM-BS', 'LI-TAX', 10),
            ('TM-BS', 'LI-ACCR', 10),
            ('TM-BS', 'LI-OTHER', 10),
            ('TM-BS', 'LI-PROV', 10),
            ('TM-BS', 'LI-LT', 10),
            ('TM-IS', 'IS-REV', 10),
            ('TM-IS', 'IS-COGS', 10),
            ('TM-IS', 'IS-SELL', 10),
            ('TM-IS', 'IS-ADMIN', 10),
            ('TM-IS', 'IS-OPINC', 10),
            ('TM-IS', 'IS-OPEXP', 10),
            ('TM-IS', 'IS-NONINC', 10),
            ('TM-IS', 'IS-NONEXP', 10),
            ('TM-IS', 'IS-TAX', 10)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('TM-BS', 'AS-CASH', 10, 'code_range', '1100', '1299', null, 'any'),
    ('TM-BS', 'AS-STINV', 10, 'code_range', '1300', '1399', null, 'any'),
    ('TM-BS', 'AS-REC', 10, 'code_range', '1400', '1499', null, 'any'),
    ('TM-BS', 'AS-OREC', 10, 'code_range', '1500', '1599', null, 'any'),
    ('TM-BS', 'AS-INV', 10, 'code_range', '1600', '1699', null, 'any'),
    ('TM-BS', 'AS-OCA', 10, 'code_range', '1700', '1799', null, 'any'),
    ('TM-BS', 'AS-PPE', 10, 'code_range', '2100', '2199', null, 'any'),
    ('TM-BS', 'AS-ONCA', 10, 'code_range', '2200', '2899', null, 'any'),
    ('TM-BS', 'AS-INTANG', 10, 'code_range', '2900', '2999', null, 'any'),
    ('TM-BS', 'EQ-SHARE', 10, 'code_range', '5100', '5199', null, 'any'),
    ('TM-BS', 'EQ-APIC', 10, 'code_range', '5200', '5299', null, 'any'),
    ('TM-BS', 'EQ-RETAINED', 10, 'code_range', '5300', '5399', null, 'any'),
    ('TM-BS', 'EQ-RESERVE', 10, 'code_range', '5400', '5499', null, 'any'),
    ('TM-BS', 'EQ-SUMMARY', 10, 'code_range', '5900', '5999', null, 'any'),
    ('TM-BS', 'LI-PAY', 10, 'code_range', '3100', '3199', null, 'any'),
    ('TM-BS', 'LI-ADV', 10, 'code_range', '3200', '3299', null, 'any'),
    ('TM-BS', 'LI-DEBT', 10, 'code_range', '3300', '3399', null, 'any'),
    ('TM-BS', 'LI-TAX', 10, 'code_range', '3400', '3499', null, 'any'),
    ('TM-BS', 'LI-ACCR', 10, 'code_range', '3500', '3599', null, 'any'),
    ('TM-BS', 'LI-OTHER', 10, 'code_range', '3600', '3699', null, 'any'),
    ('TM-BS', 'LI-PROV', 10, 'code_range', '3700', '3799', null, 'any'),
    ('TM-BS', 'LI-LT', 10, 'code_range', '4000', '4999', null, 'any'),
    ('TM-IS', 'IS-REV', 10, 'code_range', '6100', '6199', null, 'any'),
    ('TM-IS', 'IS-COGS', 10, 'code_range', '7100', '7299', null, 'any'),
    ('TM-IS', 'IS-SELL', 10, 'code_range', '7500', '7599', null, 'any'),
    ('TM-IS', 'IS-ADMIN', 10, 'code_range', '8000', '8999', null, 'any'),
    ('TM-IS', 'IS-OPINC', 10, 'code_range', '6200', '6299', null, 'any'),
    ('TM-IS', 'IS-OPEXP', 10, 'code_range', '7600', '7699', null, 'any'),
    ('TM-IS', 'IS-NONINC', 10, 'code_range', '9100', '9199', null, 'any'),
    ('TM-IS', 'IS-NONEXP', 10, 'code_range', '9500', '9599', null, 'any'),
    ('TM-IS', 'IS-TAX', 10, 'code_range', '9600', '9699', null, 'any')
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
  ('TM', 'Туркменистан', '{"en":"Turkmenistan"}'::jsonb, array['ru', 'en']::text[], 'TMT', '1410', '3110', '3699', '7690', '5300', '6110', '7210', '1210', '1110', 'SAL', 'PUR', 'GEN', 'ru', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '6290', '7610', null, null, null, null, '3432', '1542', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Налоговый кодекс Туркменистана, статья 107, часть 4 — налогоплательщик обязан выписать получателю налоговую счёт-фактуру установленного образца в двух экземплярах не позднее пяти дней с даты отгрузки; форму устанавливает Министерство финансов и экономики. Кодекс не требует определённой формы нумерации коммерческого документа — последовательная нумерация приведена как пример.',
  numbering_source_key          = 'tax-code',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = 'Налоговый кодекс Туркменистана, статья 109, часть 1 — налогооблагаемая операция считается совершённой в том отчётном (налоговом) периоде, когда товары отгружены (переданы), работы выполнены и сданы, услуги завершены. Особые правила для долгосрочных контрактов (более трёх месяцев) и авансов формат не выражает — см. README.md.',
  tax_point_source_key          = 'tax-code',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = 'Налоговый кодекс Туркменистана, статья 102 — налоговая база подлежит корректировке в случаях, установленных статьёй 35. Проведённая запись не стирается: возврат или исправление оформляются кредит-нотой и встречной записью.',
  posted_edit_policy_source_key = 'tax-code',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Налоговый кодекс Туркменистана, статья 107, часть 4 — налоговая счёт-фактура выписывается в двух экземплярах установленной формы; статья 30, часть 2 допускает представление налоговой декларации в виде электронного документа по согласованию с налоговым органом. Обязательной обмена электронными счетами-фактурами по модели EN 16931 в найденных источниках нет, поэтому профиль, схема участников и схема НДС оставлены пустыми; электронная отчётность идёт через личный кабинет налоговой службы (README.md).',
  einvoice_source_key           = 'tax-code',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'iban',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'TM';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('TM', 'exempt', 'exempt', 'Без налога на добавленную стоимость', '{"en":"Without value added tax"}'::jsonb, 10, date '1970-01-01', null, 'Налоговый кодекс Туркменистана, статья 107, часть 5 — при совершении налогооблагаемой операции, освобождаемой от налога на добавленную стоимость, налоговая счёт-фактура выписывается без выделения суммы налога, и в ней делается соответствующая надпись или ставится штамп «Без налога на добавленную стоимость».')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;

update country_defaults set
  tax_payee_name       = 'Государственная налоговая служба при Министерстве финансов и экономики Туркменистана',
  tax_payee_source_key = 'stss-portal'
 where country = 'TM';
