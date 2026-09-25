-- Ekwo OS — България: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/bg at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build bg`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Закон за данък върху добавената стойност, обн. ДВ бр.63 от 4 август 2006 г., ред. до изм. и доп. ДВ бр.115 от 30 декември 2025 г. (Държавна агенция за метрологичен и технически надзор — препубликуван консолидиран текст (Правно-информационна система „Сиела“))
--     https://www.damtn.government.bg/wp-content/uploads/zakoni/zakon-za-danak-varhu-dobavenata-stoinost.pdf
--   Данък върху добавената стойност — ставки, регистрация и срокове (Национална агенция за приходите (НАП))
--     https://nra.bg/wps/portal/nra/taxes/dds-v-balgariya
--   Справка-декларация по ЗДДС — услуга и срок на подаване (Национална агенция за приходите (НАП))
--     https://nra.bg/wps/portal/nra/uslugi/spravka.deklaraciq/
--   Справка-декларация за ДДС (Приложение № 13 към чл. 116, ал. 1 от ППЗДДС) — структура на клетките по раздели А—Д. Бланка (вариант, предхождащ повишението на намалената ставка от 7 % на 9 % от 01.07.2022 г. — номерацията и структурата на клетките са запазени, ставката е коригирана в този пакет спрямо действащия чл. 66а ЗДДС) (Правно-информационна система „Сиела“ — бланка, препубликувана от счетоводен софтуер (tera-bg.com); официалният файл на НАП (nra.bg, документ на Приложение № 13) не можа да бъде прочетен технически при тази консултация)
--     https://www.tera-bg.com/files/Exported%20dds2.pdf
--   Национален счетоводен стандарт 1 — Представяне на финансови отчети (Приложения № 1, 2 и 3 — примерни схеми на баланса и на отчета за приходите и разходите) (Портал за счетоводна и данъчна информация kik-info.com, възпроизвеждащ Национален счетоводен стандарт 1, приет с ПМС № 251/2015 г. в приложение на Закона за счетоводството — текстът на самия стандарт на официален правителствен адрес (minfin.bg, registryagency.bg) не можа да бъде прочетен технически при тази консултация)
--     https://kik-info.com/normativna-baza/nss/0X2135501601/
--   Закон за счетоводството, в сила от 01.01.2016 г. — чл. 16, ал. 1: индивидуален сметкоплан, одобрен от ръководителя на предприятието; няма национален задължителен сметкоплан за предприятия извън публичния сектор (Министерство на финансите / Агенция по вписванията)
--     https://www.registryagency.bg/media/filer_public/2026/01/08/zakon_za_schetovodstvoto.pdf
--   Постановление № 347 от 29 декември 2025 г. на Министерския съвет за изменение на Постановление № 426 от 2014 г. — лихва за забавено плащане: основен лихвен процент на ЕЦБ по операциите по рефинансиране + 8 процентни пункта, считано от 01.01.2026 г., след въвеждането на еврото (Народно събрание — Държавен вестник (портал dv.parliament.bg))
--     https://dv.parliament.bg/DVWeb/showMaterialDV.jsp?idMat=240356
--   Bulgaria joins the euro area — press release, 1 January 2026 (European Central Bank)
--     https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.pr260101~c830245e42.en.html
--   EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — code list of VAT exemption reasons (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BG', 'България', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, 'ac5c7869bb1e3df8381df1169b583bc510ff2e3d0f3046402a27e1c9cf7ce912', '[{"key":"zdds","title":"Закон за данък върху добавената стойност, обн. ДВ бр.63 от 4 август 2006 г., ред. до изм. и доп. ДВ бр.115 от 30 декември 2025 г.","publisher":"Държавна агенция за метрологичен и технически надзор — препубликуван консолидиран текст (Правно-информационна система „Сиела“)","url":"https://www.damtn.government.bg/wp-content/uploads/zakoni/zakon-za-danak-varhu-dobavenata-stoinost.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"nra-dds","title":"Данък върху добавената стойност — ставки, регистрация и срокове","publisher":"Национална агенция за приходите (НАП)","url":"https://nra.bg/wps/portal/nra/taxes/dds-v-balgariya","consulted_on":"2026-09-25","kind":"guidance"},{"key":"nra-spravka-deklaracia","title":"Справка-декларация по ЗДДС — услуга и срок на подаване","publisher":"Национална агенция за приходите (НАП)","url":"https://nra.bg/wps/portal/nra/uslugi/spravka.deklaraciq/","consulted_on":"2026-09-25","kind":"portal"},{"key":"ppzdds-prilojenie-13","title":"Справка-декларация за ДДС (Приложение № 13 към чл. 116, ал. 1 от ППЗДДС) — структура на клетките по раздели А—Д. Бланка (вариант, предхождащ повишението на намалената ставка от 7 % на 9 % от 01.07.2022 г. — номерацията и структурата на клетките са запазени, ставката е коригирана в този пакет спрямо действащия чл. 66а ЗДДС)","publisher":"Правно-информационна система „Сиела“ — бланка, препубликувана от счетоводен софтуер (tera-bg.com); официалният файл на НАП (nra.bg, документ на Приложение № 13) не можа да бъде прочетен технически при тази консултация","url":"https://www.tera-bg.com/files/Exported%20dds2.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"ss1","title":"Национален счетоводен стандарт 1 — Представяне на финансови отчети (Приложения № 1, 2 и 3 — примерни схеми на баланса и на отчета за приходите и разходите)","publisher":"Портал за счетоводна и данъчна информация kik-info.com, възпроизвеждащ Национален счетоводен стандарт 1, приет с ПМС № 251/2015 г. в приложение на Закона за счетоводството — текстът на самия стандарт на официален правителствен адрес (minfin.bg, registryagency.bg) не можа да бъде прочетен технически при тази консултация","url":"https://kik-info.com/normativna-baza/nss/0X2135501601/","consulted_on":"2026-09-25","kind":"standard"},{"key":"zakon-schetovodstvo","title":"Закон за счетоводството, в сила от 01.01.2016 г. — чл. 16, ал. 1: индивидуален сметкоплан, одобрен от ръководителя на предприятието; няма национален задължителен сметкоплан за предприятия извън публичния сектор","publisher":"Министерство на финансите / Агенция по вписванията","url":"https://www.registryagency.bg/media/filer_public/2026/01/08/zakon_za_schetovodstvoto.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"pms-347-2025","title":"Постановление № 347 от 29 декември 2025 г. на Министерския съвет за изменение на Постановление № 426 от 2014 г. — лихва за забавено плащане: основен лихвен процент на ЕЦБ по операциите по рефинансиране + 8 процентни пункта, считано от 01.01.2026 г., след въвеждането на еврото","publisher":"Народно събрание — Държавен вестник (портал dv.parliament.bg)","url":"https://dv.parliament.bg/DVWeb/showMaterialDV.jsp?idMat=240356","consulted_on":"2026-09-25","kind":"regulation"},{"key":"ecb-bg-euro","title":"Bulgaria joins the euro area — press release, 1 January 2026","publisher":"European Central Bank","url":"https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.pr260101~c830245e42.en.html","consulted_on":"2026-09-25","kind":"guidance"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('BG', 'default', 'Сметкоплан, изграден по структурата на баланса и отчета за приходите и разходите на СС 1', '{}'::jsonb, true, 'companies', array['BG-SS1-BALANS', 'BG-SS1-OPR']::text[], null, 'Закон за счетоводството, чл. 16, ал. 1 — индивидуалният сметкоплан се одобрява от ръководителя на всяко предприятие; България няма национален задължителен сметкоплан от влизането в сила на действащия закон (01.01.2016 г.). Историческият „Национален сметкоплан“ от 1998 г. остава широко използван в практиката като необвързващ модел, но не е норма — този пакет не го възпроизвежда. Вместо това сметкопланът е изграден за целите на този пакет: първата цифра насочва направо към раздела на баланса или на отчета за приходите и разходите по примерните схеми на СС 1 (Приложения № 1 и № 2): 1 Нетекущи активи (Раздел Б, актив), 2 Текущи активи (Раздел В, актив, вкл. Раздел Г — разходи за бъдещи периоди), 3 Записан, невнесен капитал (Раздел А, актив), 4 Собствен капитал (Раздел А, пасив), 5 Провизии и сходни задължения (Раздел Б, пасив), 6 Задължения, вкл. финансирания и приходи за бъдещи периоди (Раздел В и Г, пасив), 8 Разходи (Приложение № 2, Раздел А), 9 Приходи (Приложение № 2, Раздел Б). Всяка сметка носи по построение позицията на баланса или отчета, към която се отнася.', 'ss1')
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
  ('BG', 'default', '1000', 'I. Нематериални активи', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('BG', 'default', '1010', 'Продукти от развойна дейност', '{}'::jsonb, 'asset_fixed', false, '1000', 20),
  ('BG', 'default', '1020', 'Концесии, патенти, лицензии, търговски марки и програмни продукти', '{}'::jsonb, 'asset_fixed', false, '1000', 30),
  ('BG', 'default', '1030', 'Търговска репутация', '{}'::jsonb, 'asset_fixed', false, '1000', 40),
  ('BG', 'default', '1040', 'Аванси за нематериални активи', '{}'::jsonb, 'asset_fixed', false, '1000', 50),
  ('BG', 'default', '1100', 'II. Дълготрайни материални активи', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('BG', 'default', '1110', 'Земи и сгради', '{}'::jsonb, 'asset_fixed', false, '1100', 70),
  ('BG', 'default', '1120', 'Машини, производствено оборудване и апаратура', '{}'::jsonb, 'asset_fixed', false, '1100', 80),
  ('BG', 'default', '1130', 'Съоръжения и други', '{}'::jsonb, 'asset_fixed', false, '1100', 90),
  ('BG', 'default', '1140', 'Аванси за дълготрайни материални активи', '{}'::jsonb, 'asset_fixed', false, '1100', 100),
  ('BG', 'default', '1200', 'III. Дългосрочни финансови активи', '{}'::jsonb, 'asset_non_current', false, null, 110),
  ('BG', 'default', '1210', 'Акции и дялове в предприятия от група', '{}'::jsonb, 'asset_non_current', false, '1200', 120),
  ('BG', 'default', '1220', 'Предоставени заеми на предприятия от група', '{}'::jsonb, 'asset_non_current', false, '1200', 130),
  ('BG', 'default', '1230', 'Акции и дялове в асоциирани и смесени предприятия', '{}'::jsonb, 'asset_non_current', false, '1200', 140),
  ('BG', 'default', '1240', 'Предоставени заеми, свързани с асоциирани и смесени предприятия', '{}'::jsonb, 'asset_non_current', false, '1200', 150),
  ('BG', 'default', '1250', 'Дългосрочни инвестиции', '{}'::jsonb, 'asset_non_current', false, '1200', 160),
  ('BG', 'default', '1260', 'Други дългосрочни заеми', '{}'::jsonb, 'asset_non_current', false, '1200', 170),
  ('BG', 'default', '1270', 'Изкупени собствени акции (дългосрочни)', '{}'::jsonb, 'asset_non_current', false, '1200', 180),
  ('BG', 'default', '1300', 'IV. Отсрочени данъци (актив)', '{}'::jsonb, 'asset_non_current', false, null, 190),
  ('BG', 'default', '2000', 'I. Материални запаси', '{}'::jsonb, 'asset_current', false, null, 200),
  ('BG', 'default', '2010', 'Суровини и материали', '{}'::jsonb, 'asset_current', false, '2000', 210),
  ('BG', 'default', '2020', 'Незавършено производство', '{}'::jsonb, 'asset_current', false, '2000', 220),
  ('BG', 'default', '2030', 'Продукция и стоки', '{}'::jsonb, 'asset_current', false, '2000', 230),
  ('BG', 'default', '2040', 'Аванси за материални запаси', '{}'::jsonb, 'asset_prepayments', false, '2000', 240),
  ('BG', 'default', '2100', 'II. Вземания', '{}'::jsonb, 'asset_current', false, null, 250),
  ('BG', 'default', '2210', 'Вземания от клиенти и доставчици', '{}'::jsonb, 'asset_receivable', true, '2100', 260),
  ('BG', 'default', '2220', 'Вземания от предприятия от група', '{}'::jsonb, 'asset_current', false, '2100', 270),
  ('BG', 'default', '2225', 'Вземания, свързани с асоциирани и смесени предприятия', '{}'::jsonb, 'asset_current', false, '2100', 280),
  ('BG', 'default', '2230', 'Други вземания', '{}'::jsonb, 'asset_current', false, '2100', 290),
  ('BG', 'default', '2241', 'ДДС за приспадане (входящ данък за периода)', '{}'::jsonb, 'asset_current', false, '2100', 300),
  ('BG', 'default', '2242', 'Разчети с бюджета за ДДС — надвзет данък за възстановяване', '{}'::jsonb, 'asset_current', true, '2100', 310),
  ('BG', 'default', '2290', 'Разчети по сметки за изясняване', '{}'::jsonb, 'asset_current', false, '2100', 320),
  ('BG', 'default', '2300', 'III. Инвестиции', '{}'::jsonb, 'asset_current', false, null, 330),
  ('BG', 'default', '2310', 'Краткосрочни инвестиции', '{}'::jsonb, 'asset_current', false, '2300', 340),
  ('BG', 'default', '2320', 'Изкупени собствени акции (краткосрочни)', '{}'::jsonb, 'asset_current', false, '2300', 350),
  ('BG', 'default', '2400', 'IV. Парични средства', '{}'::jsonb, 'asset_cash', false, null, 360),
  ('BG', 'default', '2410', 'Каса', '{}'::jsonb, 'asset_cash', false, '2400', 370),
  ('BG', 'default', '2420', 'Разплащателна сметка', '{}'::jsonb, 'asset_cash', false, '2400', 380),
  ('BG', 'default', '2500', 'Раздел Г. Разходи за бъдещи периоди', '{}'::jsonb, 'asset_prepayments', false, null, 390),
  ('BG', 'default', '3100', 'Раздел А. Записан, невнесен капитал', '{}'::jsonb, 'asset_current', false, null, 400),
  ('BG', 'default', '4100', 'I. Записан капитал', '{}'::jsonb, 'equity', false, null, 410),
  ('BG', 'default', '4200', 'II. Премии от емисии', '{}'::jsonb, 'equity', false, null, 420),
  ('BG', 'default', '4300', 'III. Резерв от последващи оценки', '{}'::jsonb, 'equity', false, null, 430),
  ('BG', 'default', '4400', 'IV. Резерви', '{}'::jsonb, 'equity', false, null, 440),
  ('BG', 'default', '4410', 'Законови резерви', '{}'::jsonb, 'equity', false, '4400', 450),
  ('BG', 'default', '4420', 'Резерв, свързан с изкупени собствени акции', '{}'::jsonb, 'equity', false, '4400', 460),
  ('BG', 'default', '4430', 'Резерв съгласно учредителен акт', '{}'::jsonb, 'equity', false, '4400', 470),
  ('BG', 'default', '4440', 'Други резерви', '{}'::jsonb, 'equity', false, '4400', 480),
  ('BG', 'default', '4500', 'V. Натрупана печалба от минали години', '{}'::jsonb, 'equity_retained', false, null, 490),
  ('BG', 'default', '4610', 'VI. Текуща печалба', '{}'::jsonb, 'equity', false, null, 500),
  ('BG', 'default', '4620', 'VI. Текуща загуба', '{}'::jsonb, 'equity', false, null, 510),
  ('BG', 'default', '5100', 'Провизии за пенсии и други подобни задължения', '{}'::jsonb, 'liability_non_current', false, null, 520),
  ('BG', 'default', '5200', 'Провизии за данъци, вкл. отсрочени данъци', '{}'::jsonb, 'liability_non_current', false, null, 530),
  ('BG', 'default', '5300', 'Други провизии и сходни задължения', '{}'::jsonb, 'liability_non_current', false, null, 540),
  ('BG', 'default', '6100', 'Облигационни заеми', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('BG', 'default', '6200', 'Задължения към финансови предприятия', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('BG', 'default', '6300', 'Получени аванси', '{}'::jsonb, 'liability_current', false, null, 570),
  ('BG', 'default', '6400', 'Задължения към доставчици', '{}'::jsonb, 'liability_payable', true, null, 580),
  ('BG', 'default', '6500', 'Задължения по полици', '{}'::jsonb, 'liability_current', false, null, 590),
  ('BG', 'default', '6600', 'Задължения към предприятия от група', '{}'::jsonb, 'liability_current', false, null, 600),
  ('BG', 'default', '6650', 'Задължения, свързани с асоциирани и смесени предприятия', '{}'::jsonb, 'liability_current', false, null, 610),
  ('BG', 'default', '6700', 'Данъчни и осигурителни задължения — други', '{}'::jsonb, 'liability_current', false, null, 620),
  ('BG', 'default', '6810', 'Задължения към персонала', '{}'::jsonb, 'liability_current', false, '6700', 630),
  ('BG', 'default', '6820', 'Осигурителни задължения', '{}'::jsonb, 'liability_current', false, '6700', 640),
  ('BG', 'default', '6831', 'ДДС начислен (изходящ данък за периода)', '{}'::jsonb, 'liability_current', false, '6700', 650),
  ('BG', 'default', '6832', 'Разчети с бюджета за ДДС — дължим данък', '{}'::jsonb, 'liability_current', true, '6700', 660),
  ('BG', 'default', '6900', 'Раздел Г. Финансирания и приходи за бъдещи периоди', '{}'::jsonb, 'liability_current', false, null, 670),
  ('BG', 'default', '8100', 'Намаление на запасите от продукция и незавършено производство', '{}'::jsonb, 'expense', false, null, 680),
  ('BG', 'default', '8200', 'Разходи за суровини, материали и услуги', '{}'::jsonb, 'expense', false, null, 690),
  ('BG', 'default', '8210', 'Разходи за материали', '{}'::jsonb, 'expense', false, '8200', 700),
  ('BG', 'default', '8220', 'Разходи за външни услуги', '{}'::jsonb, 'expense', false, '8200', 710),
  ('BG', 'default', '8221', 'Наеми и лизинг', '{}'::jsonb, 'expense', false, '8220', 720),
  ('BG', 'default', '8222', 'Ремонт и поддръжка', '{}'::jsonb, 'expense', false, '8220', 730),
  ('BG', 'default', '8223', 'Транспортни услуги', '{}'::jsonb, 'expense', false, '8220', 740),
  ('BG', 'default', '8224', 'Телекомуникации и интернет', '{}'::jsonb, 'expense', false, '8220', 750),
  ('BG', 'default', '8225', 'Правни, консултантски и счетоводни услуги', '{}'::jsonb, 'expense', false, '8220', 760),
  ('BG', 'default', '8226', 'Реклама и представителни разходи', '{}'::jsonb, 'expense', false, '8220', 770),
  ('BG', 'default', '8227', 'Командировки', '{}'::jsonb, 'expense', false, '8220', 780),
  ('BG', 'default', '8300', 'Разходи за персонала', '{}'::jsonb, 'expense', false, null, 790),
  ('BG', 'default', '8310', 'Разходи за заплати', '{}'::jsonb, 'expense', false, '8300', 800),
  ('BG', 'default', '8320', 'Разходи за осигуровки', '{}'::jsonb, 'expense', false, '8300', 810),
  ('BG', 'default', '8400', 'Разходи за амортизация и обезценка', '{}'::jsonb, 'expense_depreciation', false, null, 820),
  ('BG', 'default', '8500', 'Други разходи', '{}'::jsonb, 'expense', false, null, 830),
  ('BG', 'default', '8510', 'Други разходи — общо', '{}'::jsonb, 'expense', false, '8500', 840),
  ('BG', 'default', '8590', 'Разходи от закръгляване', '{}'::jsonb, 'expense', false, '8500', 850),
  ('BG', 'default', '8600', 'Разходи от обезценка на финансови активи', '{}'::jsonb, 'expense', false, null, 860),
  ('BG', 'default', '8700', 'Разходи за лихви и други финансови разходи', '{}'::jsonb, 'expense', false, null, 870),
  ('BG', 'default', '8710', 'Разходи за лихви', '{}'::jsonb, 'expense', false, '8700', 880),
  ('BG', 'default', '8720', 'Отрицателни разлики от валутни операции', '{}'::jsonb, 'expense', false, '8700', 890),
  ('BG', 'default', '9100', 'Нетни приходи от продажби', '{}'::jsonb, 'income', false, null, 900),
  ('BG', 'default', '9110', 'Приходи от продажба на стоки и услуги', '{}'::jsonb, 'income', false, '9100', 910),
  ('BG', 'default', '9200', 'Увеличение на запасите от продукция и незавършено производство', '{}'::jsonb, 'income', false, null, 920),
  ('BG', 'default', '9300', 'Приходи от придобиване на активи по стопански начин', '{}'::jsonb, 'income_other', false, null, 930),
  ('BG', 'default', '9400', 'Други приходи', '{}'::jsonb, 'income_other', false, null, 940),
  ('BG', 'default', '9410', 'Приходи от отписани задължения', '{}'::jsonb, 'income_other', false, '9400', 950),
  ('BG', 'default', '9420', 'Приходи от неустойки и обезщетения', '{}'::jsonb, 'income_other', false, '9400', 960),
  ('BG', 'default', '9500', 'Приходи от участия в дъщерни, асоциирани и смесени предприятия', '{}'::jsonb, 'income_other', false, null, 970),
  ('BG', 'default', '9600', 'Приходи от други инвестиции и заеми, признати като нетекущи активи', '{}'::jsonb, 'income_other', false, null, 980),
  ('BG', 'default', '9700', 'Други лихви и финансови приходи', '{}'::jsonb, 'income_other', false, null, 990),
  ('BG', 'default', '9710', 'Приходи от лихви', '{}'::jsonb, 'income_other', false, '9700', 1000),
  ('BG', 'default', '9720', 'Положителни разлики от валутни операции', '{}'::jsonb, 'income_other', false, '9700', 1010)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BG', 'BANK', 'Банка', '{}'::jsonb, 'bank', 30),
  ('BG', 'CASH', 'Каса', '{}'::jsonb, 'cash', 40),
  ('BG', 'MISC', 'Други операции', '{}'::jsonb, 'general', 50),
  ('BG', 'OPEN', 'Начално салдо', '{}'::jsonb, 'opening', 60),
  ('BG', 'PURCH', 'Покупки', '{}'::jsonb, 'purchase', 20),
  ('BG', 'SALES', 'Продажби', '{}'::jsonb, 'sales', 10)
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
  ('BG', 'BG-P-20', 'ДДС покупки 20% — пълен данъчен кредит', '{}'::jsonb, 'Вътрешна доставка на стоки или услуги, стандартна ставка, с право на пълен данъчен кредит. Клетки 31 (данъчна основа) и 41 (ДДС с право на пълен данъчен кредит).', 'percent', 20, 'purchase', 'domestic', date '2022-07-01', null, 'Закон за данък върху добавената стойност, чл. 68 и чл. 69, ал. 1 — регистрираното лице приспада данъчен кредит за получени от него стоки или услуги по облагаема доставка, използвани за целите на извършваните от него облагаеми доставки; ставката е тази на чл. 66, ал. 1.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-P-9', 'ДДС покупки 9% — пълен данъчен кредит', '{}'::jsonb, 'Вътрешна доставка на услуга по настаняване, намалена ставка, с право на пълен данъчен кредит. Клетки 31 и 41.', 'percent', 9, 'purchase', 'domestic', date '2023-01-01', null, 'Закон за данък върху добавената стойност, чл. 68 и чл. 69, ал. 1 във връзка с чл. 66а, ал. 1, т. 1 — приспадане на данъчен кредит за получена доставка, за която доставчикът е начислил данък по намалената ставка от 9 на сто.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-P-EXEMPT', 'Покупка без право на данъчен кредит — освободена доставка', '{}'::jsonb, 'Пример за покупка на освободена доставка (застрахователна премия): без данък, без право на приспадане. Клетка 30.', 'percent', 0, 'purchase', 'exempt', date '2021-01-01', null, 'Закон за данък върху добавената стойност, чл. 47 във връзка с чл. 68, ал. 1 — застрахователните услуги са освободена доставка; поради липса на начислен от доставчика данък не възниква право на приспадане за получателя.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-P-USLUGI-ES-20', 'Получена услуга по общото правило от данъчно задължено лице от друга държава членка 20%', '{}'::jsonb, 'Услуга, получена от доставчик — данъчно задължено лице от друга държава членка, обратно начислена от получателя по общото правило. Данъчна основа в клетки 12 и 31, дължим данък в клетка 22, приспаднат данък в клетка 41.', 'percent', 20, 'purchase', 'intracom_acquisition_services', date '2022-07-01', null, 'Закон за данък върху добавената стойност, чл. 82, ал. 2, т. 3 — когато доставчикът е данъчно задължено лице, което не е established на територията на страната, и услугата е с място на изпълнение на територията на страната по чл. 21, ал. 2, данъкът е изискуем от получателя — данъчно задължено лице по чл. 3, ал. 1, 5 и 6; чл. 68, ал. 1, т. 3 и чл. 69, ал. 1, т. 3 — така начисленият данък е и данъчен кредит на същото лице в същия данъчен период.', 'K', 'VATEX-EU-IC', 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-P-VOP-20', 'Вътреобщностно придобиване на стоки 20%', '{}'::jsonb, 'Вътреобщностно придобиване на стоки (ВОП), самоначислено и напълно приспадано в същата декларация. Данъчна основа в клетки 12 и 31, дължим данък в клетка 22, приспаднат данък в клетка 41.', 'percent', 20, 'purchase', 'intracom_acquisition_goods', date '2022-07-01', null, 'Закон за данък върху добавената стойност, чл. 84 — данъкът при вътреобщностно придобиване е изискуем от лицето, което извършва придобиването, и се начислява от него с протокол; чл. 68, ал. 1, т. 2 и чл. 69, ал. 1, т. 3 — така начисленият данък е и данъчен кредит на същото лице в същия данъчен период.', 'K', 'VATEX-EU-IC', 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-S-20', 'ДДС продажби 20%', '{}'::jsonb, 'Стандартна ставка, продажба на територията на страната. Клетки 11 (данъчна основа) и 21 (начислен ДДС).', 'percent', 20, 'sale', 'domestic', date '2022-07-01', null, 'Закон за данък върху добавената стойност, чл. 66, ал. 1 (изм. — ДВ, бр. 52 от 2022 г., в сила от 01.07.2022 г.) — стандартната ставка на данъка е 20 на сто за облагаемите доставки с място на изпълнение на територията на страната, освен изрично посочените като облагаеми с намалена или нулева ставка.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-S-9', 'ДДС продажби 9%', '{}'::jsonb, 'Намалена ставка — пример: настаняване в хотели и подобни заведения. Клетки 13 (данъчна основа) и 24 (начислен ДДС).', 'percent', 9, 'sale', 'domestic', date '2023-01-01', null, 'Закон за данък върху добавената стойност, чл. 66а, ал. 1, т. 1 (нов — ДВ, бр. 52 от 2022 г., в сила от 01.07.2022 г., изм. — ДВ, бр. 102 от 2022 г., в сила от 01.01.2023 г.) — ставката на данъка е 9 на сто за доставка на услуга по настаняване, предоставяно в хотели и подобни заведения, включително предоставянето на ваканционно настаняване и отдаване под наем на места за площадки за къмпинг или каравани. Другите две доставки на 9 %, книги (т. 2) и бебешки стоки по приложение № 4 (т. 3), не се моделират тук.', 'S', null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-S-EXEMPT-NAEM', 'Отдаване под наем на сграда за жилище на физическо лице — освободена доставка', '{}'::jsonb, 'Пример за освободена вътрешна доставка: отдаване под наем на сграда или част от нея за жилище на физическо лице, което не е търговец. Клетка 19.', 'percent', 0, 'sale', 'exempt', date '2007-01-01', null, 'Закон за данък върху добавената стойност, чл. 45, ал. 4 — освободена доставка е и отдаването под наем на сграда или част от нея за жилище на физическо лице, което не е търговец.', 'E', 'VATEX-EU-135', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-S-EXPORT', 'Износ на стоки 0%', '{}'::jsonb, 'Износ на стоки извън Европейския съюз. Клетка 14.', 'percent', 0, 'sale', 'export', date '2007-01-01', null, 'Закон за данък върху добавената стойност, чл. 28 (глава трета — облагаеми доставки с нулева ставка) — облагаема доставка с нулева ставка е износът на стоки извън територията на Европейския съюз, удостоверен по реда, определен с правилника за прилагане на закона (чл. 66б препраща към глава трета за прилагането на нулевата ставка).', 'G', 'VATEX-EU-G', 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-S-USLUGI-ES', 'Услуга по общото правило към данъчно задължено лице от друга държава членка', '{}'::jsonb, 'Услуга с място на изпълнение в друга държава членка по общото правило (получателят е данъчно задължено лице, установено там), обратно начислена от получателя. Клетка 17.', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Закон за данък върху добавената стойност, чл. 21, ал. 2 — мястото на изпълнение при доставка на услуга, когато получателят е данъчно задължено лице, е мястото, където получателят е установил независимата си икономическа дейност; данъкът е изискуем от получателя. Доставката няма място на изпълнение на територията на страната и се декларира в клетка 17.', 'K', 'VATEX-EU-IC', 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null),
  ('BG', 'BG-S-VOD', 'Вътреобщностна доставка на стоки 0%', '{}'::jsonb, 'Вътреобщностна доставка на стоки (ВОД). Клетка 15.', 'percent', 0, 'sale', 'intracom_goods', date '2007-01-01', null, 'Закон за данък върху добавената стойност, чл. 53, ал. 1 — облагаема доставка с нулева ставка е доставката на стоки, които се изпращат или транспортират от място на територията на страната до друга държава членка, когато получателят е данъчно задължено лице или данъчно незадължено юридическо лице, регистрирано за целите на ДДС в друга държава членка (чл. 66б препраща към глава трета и към чл. 53 за прилагането на нулевата ставка).', 'K', 'VATEX-EU-IC', 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zdds', null, null, null, null)
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
    ('BG-P-20', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-P-20', 'invoice', 'tax', 100, '2241', '41', array['41']::text[], 100, 'BG-VAT-SD', 20),
    ('BG-P-20', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-P-20', 'credit_note', 'tax', 100, '2241', '41', array['41']::text[], -100, 'BG-VAT-SD', 20),
    ('BG-P-9', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-P-9', 'invoice', 'tax', 100, '2241', '41', array['41']::text[], 100, 'BG-VAT-SD', 20),
    ('BG-P-9', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-P-9', 'credit_note', 'tax', 100, '2241', '41', array['41']::text[], -100, 'BG-VAT-SD', 20),
    ('BG-P-EXEMPT', 'invoice', 'base', 100, null, '30', array['30']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-P-EXEMPT', 'credit_note', 'base', 100, null, '30', array['30']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-P-USLUGI-ES-20', 'invoice', 'base', 100, null, '12', array['12', '31']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-P-USLUGI-ES-20', 'invoice', 'tax', 100, '6831', '22', array['22']::text[], 100, 'BG-VAT-SD', 20),
    ('BG-P-USLUGI-ES-20', 'invoice', 'tax', 100, '2241', '41', array['41']::text[], 100, 'BG-VAT-SD', 30),
    ('BG-P-USLUGI-ES-20', 'credit_note', 'base', 100, null, '12', array['12', '31']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-P-USLUGI-ES-20', 'credit_note', 'tax', 100, '6831', '22', array['22']::text[], -100, 'BG-VAT-SD', 20),
    ('BG-P-USLUGI-ES-20', 'credit_note', 'tax', 100, '2241', '41', array['41']::text[], -100, 'BG-VAT-SD', 30),
    ('BG-P-VOP-20', 'invoice', 'base', 100, null, '12', array['12', '31']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-P-VOP-20', 'invoice', 'tax', 100, '6831', '22', array['22']::text[], 100, 'BG-VAT-SD', 20),
    ('BG-P-VOP-20', 'invoice', 'tax', 100, '2241', '41', array['41']::text[], 100, 'BG-VAT-SD', 30),
    ('BG-P-VOP-20', 'credit_note', 'base', 100, null, '12', array['12', '31']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-P-VOP-20', 'credit_note', 'tax', 100, '6831', '22', array['22']::text[], -100, 'BG-VAT-SD', 20),
    ('BG-P-VOP-20', 'credit_note', 'tax', 100, '2241', '41', array['41']::text[], -100, 'BG-VAT-SD', 30),
    ('BG-S-20', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-S-20', 'invoice', 'tax', 100, '6831', '21', array['21']::text[], 100, 'BG-VAT-SD', 20),
    ('BG-S-20', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-S-20', 'credit_note', 'tax', 100, '6831', '21', array['21']::text[], -100, 'BG-VAT-SD', 20),
    ('BG-S-9', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-S-9', 'invoice', 'tax', 100, '6831', '24', array['24']::text[], 100, 'BG-VAT-SD', 20),
    ('BG-S-9', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-S-9', 'credit_note', 'tax', 100, '6831', '24', array['24']::text[], -100, 'BG-VAT-SD', 20),
    ('BG-S-EXEMPT-NAEM', 'invoice', 'base', 100, null, '19', array['19']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-S-EXEMPT-NAEM', 'credit_note', 'base', 100, null, '19', array['19']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-S-EXPORT', 'invoice', 'base', 100, null, '14', array['14']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-S-EXPORT', 'credit_note', 'base', 100, null, '14', array['14']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-S-USLUGI-ES', 'invoice', 'base', 100, null, '17', array['17']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-S-USLUGI-ES', 'credit_note', 'base', 100, null, '17', array['17']::text[], -100, 'BG-VAT-SD', 10),
    ('BG-S-VOD', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'BG-VAT-SD', 10),
    ('BG-S-VOD', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'BG-VAT-SD', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BG' and t.code = v.tax_code
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
  ('BG', 'BG-VAT-SD', 'Справка-декларация за данък върху добавената стойност', array['month']::declaration_period[], 'month'::declaration_period, date '2026-01-01', null, 'Закон за данък върху добавената стойност, чл. 87, ал. 1 — данъчният период е едномесечен и съвпада с календарния месец, освен в случаите, предвидени в глава осемнадесета. Приложение № 13 към чл. 116, ал. 1 от Правилника за прилагане на закона урежда формата и клетките на справка-декларацията.', true,'day_of_month_after_period'::filing_deadline_rule, 14, null, 'Закон за данък върху добавената стойност, чл. 125, ал. 5 — декларациите по ал. 1 и 2 и отчетните регистри по ал. 3 се подават до 14-о число включително на месеца, следващ данъчния период, за който се отнасят.', 'zdds', null)
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
  ('BG', 'BG-VAT-SD', '01', 'total', 'Общ размер на данъчните основи за облагане с ДДС', '{}'::jsonb, 10, null, array['11', '12', '13', '14', '15', '16']::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС — клетка 01, сума от кл. 11 до кл. 16.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '11', 'base', 'Данъчна основа на облагаемите доставки със ставка 20%, вкл. доставките при условията на дистанционни продажби с място на изпълнение на територията на страната', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 11.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '12', 'base', 'Данъчна основа на ВОП и данъчна основа на получени доставки по чл. 82, ал. 2 – 5 ЗДДС', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 12.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '13', 'base', 'Данъчна основа на облагаемите доставки със ставка 9%', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 13 — ставката, отпечатана върху бланката (7%), е коригирана в този пакет на действащата ставка от 9% по чл. 66а ЗДДС, в сила от 01.07.2022 г.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '14', 'base', 'Данъчна основа на доставки по глава трета от ЗДДС, облагаеми със ставка 0%', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 14.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '15', 'base', 'Данъчна основа на ВОД на стоки', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 15.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '16', 'base', 'Данъчна основа на доставки по чл. 140, чл. 146 и чл. 173, ал. 1 и 4 ЗДДС', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 16. Не се моделира в този пакет.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '17', 'base', 'Данъчна основа на доставки на услуги по чл. 21, ал. 3 и чл. 22 – чл. 24 с място на изпълнение на територията на друга държава членка', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 17.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '18', 'base', 'Данъчна основа на доставки по чл. 69, ал. 2 ЗДДС, вкл. доставките при условията на дистанционни продажби с място на изпълнение на територията на друга държава членка', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 18. Не се моделира в този пакет.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '19', 'base', 'Данъчна основа на освободените доставки и освободените ВОП', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 19.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '20', 'total', 'Всичко начислен ДДС', '{}'::jsonb, 110, null, array['21', '22', '23', '24']::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС — клетка 20, сума от кл. 21 до кл. 24.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '21', 'tax', 'Начислен ДДС (20%)', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 21.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '22', 'tax', 'Начислен ДДС за ВОП и за получени доставки по чл. 82, ал. 2 – 5 ЗДДС', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 22.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '23', 'tax', 'Начислен данък (20%) в други случаи, предвидени в ЗДДС', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 23. Не се моделира в този пакет.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '24', 'tax', 'Начислен ДДС (9%)', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 24 — ставката, отпечатана върху бланката (7%), е коригирана в този пакет на действащата ставка от 9%, вж. клетка 13.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '30', 'base', 'Данъчна основа и данък на получените доставки, ВОП, получените доставки по чл. 82, ал. 2 – 5 ЗДДС и вноса без право на данъчен кредит или без данък', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 30.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '31', 'base', 'Данъчна основа на получените доставки, ВОП, получените доставки по чл. 82, ал. 2 – 5 ЗДДС, вноса и на получените доставки по чл. 69, ал. 2 ЗДДС — с право на пълен данъчен кредит', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 31.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '32', 'base', 'Същата данъчна основа — с право на частичен данъчен кредит', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 32. Не се моделира в този пакет — виж README на пакета.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '33', 'tax', 'Коефициент по чл. 73, ал. 5 ЗДДС', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 33. Не се моделира в този пакет.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '40', 'total', 'Общо данъчен кредит', '{}'::jsonb, 200, null, array['41', '42', '43']::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС — клетка 40, изчислена по формулата „кл. 41 + кл. 42 х кл. 33 + кл. 43". Не може да бъде възпроизведена точно (виж README на пакета): умножението на клетка 42 по коефициента на клетка 33 не се поддържа от формàта на декларациите, който събира и изважда клетки, но не ги умножава едни по други; тази клетка е точна само доколкото клетки 32, 33 и 42 остават нулеви, т.е. извън режима на частичен данъчен кредит.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '41', 'tax', 'ДДС с право на пълен данъчен кредит', '{}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 41.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '42', 'tax', 'ДДС с право на частичен данъчен кредит', '{}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 42. Не се моделира в този пакет.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '43', 'tax', 'Годишна корекция по чл. 73, ал. 8 (+/-) и по чл. 147, ал. 3 ЗДДС', '{}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 43. Не се моделира в този пакет.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '50', 'total', 'ДДС за внасяне (кл. 20 – кл. 40) >= 0', '{}'::jsonb, 240, null, array['20']::text[], array['40']::text[], null, null, true, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 50.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '60', 'total', 'ДДС за възстановяване (кл. 20 – кл. 40) < 0', '{}'::jsonb, 250, null, array['40']::text[], array['20']::text[], null, null, true, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 60.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '70', 'tax', 'Данък за внасяне от кл. 50, приспаднат по реда на чл. 92, ал. 1 ЗДДС', '{}'::jsonb, 260, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 70. Не се моделира — административен избор, не факт от счетоводните книги.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '71', 'tax', 'Данък за внасяне от кл. 50, внесен ефективно', '{}'::jsonb, 270, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 71. Не се моделира.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '80', 'tax', 'ДДС за възстановяване съгласно чл. 92, ал. 1 ЗДДС, в 45-дневен срок от подаването на декларацията', '{}'::jsonb, 280, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 80. Не се моделира.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '81', 'tax', 'ДДС за възстановяване съгласно чл. 92, ал. 3 ЗДДС, в 30-дневен срок от подаването на декларацията', '{}'::jsonb, 290, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 81. Не се моделира.', 'ppzdds-prilojenie-13'),
  ('BG', 'BG-VAT-SD', '82', 'tax', 'ДДС за възстановяване съгласно чл. 92, ал. 4 ЗДДС, в 30-дневен срок от подаването на декларацията', '{}'::jsonb, 300, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Приложение № 13 към чл. 116, ал. 1 ППЗДДС, клетка 82. Не се моделира.', 'ppzdds-prilojenie-13')
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
  ('BG-SS1-BALANS', 'BG', 'default', 'Счетоводен баланс по примерната схема на Приложение № 1 към СС 1', 'balance_sheet', 'BG-SS1', date '2026-01-01', null, 'Национален счетоводен стандарт 1 — Представяне на финансови отчети, § 10.1 и § 14, Приложение № 1 — примерна схема на счетоводния баланс за предприятия, прилагащи националните счетоводни стандарти.', 'ss1'),
  ('BG-SS1-OPR', 'BG', 'default', 'Отчет за приходите и разходите по видове (природа), примерна схема на Приложение № 2 към СС 1', 'income_statement', 'BG-SS1', date '2026-01-01', null, 'Национален счетоводен стандарт 1 — Представяне на финансови отчети, § 19, Приложение № 2 — примерна схема на отчета за приходите и разходите по икономически елементи (по природа).', 'ss1')
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
  ('BG-SS1-BALANS', 'AKTIV', null, 'АКТИВ — общо', '{}'::jsonb, 10, 1, true, array['AKTIV.A', 'AKTIV.B', 'AKTIV.V', 'AKTIV.G']::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.A', 'AKTIV', 'Раздел А. Записан, невнесен капитал', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.B', 'AKTIV', 'Раздел Б. Нетекущи активи', '{}'::jsonb, 30, 1, true, array['AKTIV.B.I', 'AKTIV.B.II', 'AKTIV.B.III', 'AKTIV.B.IV']::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.B.I', 'AKTIV.B', 'I. Нематериални активи', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.B.II', 'AKTIV.B', 'II. Дълготрайни материални активи', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.B.III', 'AKTIV.B', 'III. Дългосрочни финансови активи', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.B.IV', 'AKTIV.B', 'IV. Отсрочени данъци', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.V', 'AKTIV', 'Раздел В. Текущи активи', '{}'::jsonb, 80, 1, true, array['AKTIV.V.I', 'AKTIV.V.II', 'AKTIV.V.III', 'AKTIV.V.IV']::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.V.I', 'AKTIV.V', 'I. Материални запаси', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.V.II', 'AKTIV.V', 'II. Вземания', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.V.III', 'AKTIV.V', 'III. Инвестиции', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.V.IV', 'AKTIV.V', 'IV. Парични средства', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'AKTIV.G', 'AKTIV', 'Раздел Г. Разходи за бъдещи периоди', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV', null, 'ПАСИВ — общо', '{}'::jsonb, 140, 1, true, array['PASIV.A', 'PASIV.B', 'PASIV.V', 'PASIV.G']::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A', 'PASIV', 'Раздел А. Собствен капитал', '{}'::jsonb, 150, 1, true, array['PASIV.A.I', 'PASIV.A.II', 'PASIV.A.III', 'PASIV.A.IV', 'PASIV.A.V', 'PASIV.A.VI']::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A.I', 'PASIV.A', 'I. Записан капитал', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A.II', 'PASIV.A', 'II. Премии от емисии', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A.III', 'PASIV.A', 'III. Резерв от последващи оценки', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A.IV', 'PASIV.A', 'IV. Резерви', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A.V', 'PASIV.A', 'V. Натрупана печалба от минали години', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.A.VI', 'PASIV.A', 'VI. Текуща печалба (загуба)', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.B', 'PASIV', 'Раздел Б. Провизии и сходни задължения', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.V', 'PASIV', 'Раздел В. Задължения', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-BALANS', 'PASIV.G', 'PASIV', 'Раздел Г. Финансирания и приходи за бъдещи периоди', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-OPR', 'OPR.A', null, 'Раздел А. Разходи', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-OPR', 'OPR.B', null, 'Раздел Б. Приходи', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('BG-SS1-OPR', 'OPR.V', null, 'Печалба (загуба) за периода', '{}'::jsonb, 30, 1, true, array['OPR.B']::text[], array['OPR.A']::text[], null, null, null)
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
    ('BG-SS1-BALANS', 'AKTIV.A', 10, 'code_range', '3100', '3199', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.B.I', 10, 'code_range', '1000', '1099', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.B.II', 10, 'code_range', '1100', '1199', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.B.III', 10, 'code_range', '1200', '1299', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.B.IV', 10, 'code_range', '1300', '1399', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.V.I', 10, 'code_range', '2000', '2099', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.V.II', 10, 'code_range', '2100', '2299', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.V.III', 10, 'code_range', '2300', '2399', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.V.IV', 10, 'code_range', '2400', '2499', null, 'any'),
    ('BG-SS1-BALANS', 'AKTIV.G', 10, 'code_range', '2500', '2599', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.A.I', 10, 'code_range', '4100', '4199', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.A.II', 10, 'code_range', '4200', '4299', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.A.III', 10, 'code_range', '4300', '4399', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.A.IV', 10, 'code_range', '4400', '4499', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.A.V', 10, 'code_range', '4500', '4599', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.A.VI', 10, 'code_range', '4600', '4699', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.B', 10, 'code_range', '5100', '5399', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.V', 10, 'code_range', '6100', '6899', null, 'any'),
    ('BG-SS1-BALANS', 'PASIV.G', 10, 'code_range', '6900', '6999', null, 'any'),
    ('BG-SS1-OPR', 'OPR.A', 10, 'code_range', '8100', '8799', null, 'any'),
    ('BG-SS1-OPR', 'OPR.B', 10, 'code_range', '9100', '9799', null, 'any')
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
  ('BG', 'България', '{}'::jsonb, array['bg']::text[], 'EUR', '2210', '6400', '2290', '8590', '4500', '9110', '8210', '2420', '2410', 'SALES', 'PURCH', 'MISC', 'bg', 'result_accounts', '4610', '4620', null, 'OPEN', 'half_up', default, '9720', '8720', null, null, null, null, '6832', '2242', null, 'month'::declaration_period)
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
  number_format                 = '{CODE}{NNNNNNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = 'Постановление № 347 от 29 декември 2025 г. на Министерския съвет — лихвата за забавено парично задължение, при липса на уговорен лихвен процент, е основният лихвен процент на Европейската централна банка по операциите по рефинансиране, в сила към 1 януари, съответно към 1 юли на текущата година, плюс 8 процентни пункта; за първото полугодие на 2026 г. това е първата стойност, изчислена след въвеждането на еврото и премахването на предишния основен лихвен процент на БНБ.',
  numbering_legal_reference     = 'Закон за данък върху добавената стойност, чл. 114, ал. 1, т. 2 — фактурата съдържа задължително пореден номер, съставен само от арабски цифри, базиран на една или повече серии в зависимост от отчетните нужди на данъчно задълженото лице, който идентифицира фактурата уникално. Правилникът за прилагане на закона доразвива изискването до десетразряден номер, нарастващ без дублиране и пропуски — тази допълнителна подробност не е проверена в текста на самия правилник при тази консултация и се основава на съгласувани вторични източници (виж README на пакета); затова е избрано gapless, а не gapless_per_year, тъй като нито законът, нито вторичните източници споменават годишно нулиране на номерацията. Le jeton {CODE} du gabarit de ce pack transcrit exactement le mot « серии » (séries) que la loi autorise elle-même : chaque journal (ventes, achats, banque…) forme sa propre série, la partie numérique restant entièrement composée de chiffres arabes comme l''exige la norme.',
  numbering_source_key          = 'zdds',
  payment_terms_legal_reference = 'Няма намерен в тази консултация общ законов срок за плащане, приложим при липса на договорка между търговци (за разлика от лихвата за забава, уредена от Постановление № 347/2025 и цитирана по-горе) — полето остава празно вместо да представя друг факт като падежен срок по подразбиране.',
  payment_terms_source_key      = 'pms-347-2025',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Закон за данък върху добавената стойност, чл. 25, ал. 2 и 6 — данъчното събитие настъпва по общото правило на датата на доставката, но когато данъчният документ (фактурата) е издаден преди тази дата, данъкът става изискуем на датата на издаване на фактурата, доколкото издаването предхожда данъчното събитие. Този пакет не пресъздава изрично тук всяко изключение на закона (напр. авансово плащане, доставки с периодично изпълнение), а следва общото правило и производното му от фактурата.',
  tax_point_source_key          = 'zdds',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Закон за данък върху добавената стойност, чл. 116, ал. 1 — поправки и добавки във фактурите и известията към тях не се разрешават; погрешно съставени или поправени документи се анулират и се издават нови (кредитно или дебитно известие по чл. 115).',
  posted_edit_policy_source_key = 'zdds',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Към 25.09.2026 г. не е открито в нито един официален източник на НАП или на Министерството на финансите общо задължение за структурирана електронна фактура между регистрирани по ЗДДС лица; фактурирането по общия ред остава на хартиен носител или в свободен електронен формат със съгласие на получателя (чл. 114, ал. 9 ЗДДС). Отделно съществува задължение за е-репортинг чрез SAF-T (стандартен одиторски файл), въведено на етапи от 01.04.2026 г. за най-големите данъчно задължени лица по реда на § 17 от допълнителните разпоредби на ДОПК, различно от електронна фактура — виж README на пакета и раздел „From Bulgaria“ на docs/international.md. На 23.09.2026 г. Министерството на финансите публикува за обществено обсъждане проект за изменение на ЗДДС, предвиждащ задължителна структурирана електронна фактура между български предприятия от 01.01.2028 г., с проверка на всяка фактура от система на НАП преди издаването ѝ да се счита за завършено — този проект не е приет закон към датата на този пакет и не се моделира.',
  einvoice_source_key           = 'zdds',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['mt940', 'camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'BG';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('BG', 'reverse_charge', 'reverse_charge', 'обратно начисляване', '{}'::jsonb, 10, date '1970-01-01', null, 'Закон за данък върху добавената стойност, чл. 114, ал. 1, т. 12, буква „и“ във връзка с ал. 4 — когато данъкът е изискуем от получателя, във фактурата не се посочват размерът на данъка и данъчната ставка, а се вписва основанието за това: „обратно начисляване“.'),
  ('BG', 'intra_eu_goods', 'intra_eu_goods', 'обратно начисляване', '{}'::jsonb, 20, date '1970-01-01', null, 'Закон за данък върху добавената стойност, чл. 114, ал. 1, т. 12 — фактурата за вътреобщностна доставка посочва основанието за неначисляване на данък.'),
  ('BG', 'intra_eu_services', 'intra_eu_services', 'обратно начисляване', '{}'::jsonb, 30, date '1970-01-01', null, 'Закон за данък върху добавената стойност, чл. 114, ал. 4 — за услуга с място на изпълнение в друга държава членка, за която данъкът е изискуем от получателя по общото правило (чл. 21, ал. 2), фактурата не посочва данък, а основанието „обратно начисляване“.'),
  ('BG', 'export', 'export', 'нулева ставка на основание чл. 28 ЗДДС', '{}'::jsonb, 40, date '1970-01-01', null, 'Закон за данък върху добавената стойност, чл. 114, ал. 1, т. 12 — когато ставката е нулева, фактурата посочва основанието за прилагането ѝ.'),
  ('BG', 'exempt', 'exempt', 'освободена доставка', '{}'::jsonb, 50, date '1970-01-01', null, 'Закон за данък върху добавената стойност, чл. 114, ал. 1, т. 12 — фактурата за освободена доставка посочва основанието за освобождаването (члена от глава четвърта, на който се основава).'),
  ('BG', 'late_payment', 'late_payment', 'При забава на плащане между търговци се дължи лихва в размер на основния лихвен процент на Европейската централна банка по операциите по рефинансиране плюс 8 процентни пункта (Постановление № 347 от 29 декември 2025 г. на Министерския съвет).', '{}'::jsonb, 60, date '1970-01-01', null, 'Постановление № 347 от 29 декември 2025 г. на Министерския съвет, изменящо Постановление № 426 от 2014 г. — мнението е информативно, по образеца на другите европейски пакети на това хранилище, които напомнят основанието на лихвата за забава.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
