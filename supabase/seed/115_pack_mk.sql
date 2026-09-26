-- Ekwo OS — Северна Македонија: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/mk at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build mk`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Закон за данокот на додадена вредност — редакциски пречистен текст (основен текст „Службен весник на РМ“ бр. 44/99, со сите последователни измени и дополнувања, до Законот објавен во „Службен весник на РСМ“ бр. 3/25) (Собрание на Република Северна Македонија — Законодавно-правна комисија (редакциски пречистен текст), објавен преку mojkonsultant.mk)
--     https://mojkonsultant.mk/wp-content/uploads/2023/02/%D0%97%D0%B0%D0%BA%D0%BE%D0%BD-%D0%B7%D0%B0-%D0%B4%D0%B0%D0%BD%D0%BE%D0%BA%D0%BE%D1%82-%D0%BD%D0%B0-%D0%B4%D0%BE%D0%B4%D0%B0%D0%B4%D0%B5%D0%BD%D0%B0-%D0%B2%D1%80%D0%B5%D0%B4%D0%BD%D0%BE%D1%81%D1%82-04.02.2025.pdf
--   Даночна пријава ДДВ-04 и Упатство за пополнување (образец објавен во „Службен весник на РСМ“ бр. 79/22, важи од 30.03.2022) (Управа за јавни приходи (УЈП))
--     https://www.ujp.gov.mk/files/attachment/0000/0967/sl.79_DDV-04_30.03.2022.pdf
--   Правилник за сметковниот план и содржината на одделните сметки во сметковниот план (донесен врз основа на член 472 став (9) од Законот за трговските друштва, „Службен весник на Република Македонија“, со подоцнежни измени) (Министерство за финансии на Република Северна Македонија / Управа за јавни приходи)
--     https://www.ujp.gov.mk/files/attachment/0000/0720/Pravilnik_za_smetkovostveniot_plan_i_sodrzinata_na_oddelnite_smetki_vo_smetkovostveniot_plan__174-2011.od_16.12.2011.pdf
--   Закон за финансиска дисциплина („Службен весник на РМ“ бр. 187/2013, 201/2014 и 215 од 07.12.2015) (Управа за јавни приходи (УЈП) — текст на закон)
--     https://www.ujp.gov.mk/files/attachment/0000/0766/Zakon_za_finansiska_disciplina_215_07.12.2015.pdf
--   е-Даноци — системот на УЈП за поднесување на даночни пријави, вклучувајќи ја ДДВ-пријавата (Управа за јавни приходи (УЈП))
--     https://etax.ujp.gov.mk
--   Соопштение на УЈП: „Презентација на новиот систем за електронско фактурирање (е-фактура) пред членките на Стопанската комора на Македонија“ — тестирање преку АПИ врска започнува на 1.1.2026 (Управа за јавни приходи (УЈП))
--     https://ujp.gov.mk/uploads/File/2025/e-Faktura/08-9024-1_%D0%9F%D1%80%D0%B5%D0%B7%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D1%98%D0%B0%20%D0%BD%D0%B0%20%D0%BD%D0%BE%D0%B2%D0%B8%D0%BE%D1%82%20%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%20%D0%B7%D0%B0%20%D0%B5%D0%BB%D0%B5%D0%BA%D1%82%D1%80%D0%BE%D0%BD%D1%81%D0%BA%D0%BE%20%D1%84%D0%B0%D0%BA%D1%82%D1%83%D1%80%D0%B8%D1%80%D0%B0%D1%9A%D0%B5%20(%D0%B5-%D1%84%D0%B0%D0%BA%D1%82%D1%83%D1%80%D0%B0)%20%D0%BF%D1%80%D0%B5%D0%B4%20%D1%87%D0%BB%D0%B5%D0%BD%D0%BA%D0%B8%D1%82%D0%B5%20%D0%BD%D0%B0%20%D0%A1%D1%82%D0%BE%D0%BF%D0%B0%D0%BD%D1%81%D0%BA%D0%B0%D1%82%D0%B0%20%D0%BA%D0%BE%D0%BC%D0%BE%D1%80%D0%B0%20%D0%BD%D0%B0%20%D0%9C%D0%B0%D0%BA%D0%B5%D0%B4%D0%BE%D0%BD%D0%B8%D1%98%D0%B0_10.12.2025.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('MK', 'Северна Македонија', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, '768b8fe47ec13c2508d5b733cf62aba1ed724187d6581857a589777257213bd7', '[{"key":"zddv","title":"Закон за данокот на додадена вредност — редакциски пречистен текст (основен текст „Службен весник на РМ“ бр. 44/99, со сите последователни измени и дополнувања, до Законот објавен во „Службен весник на РСМ“ бр. 3/25)","publisher":"Собрание на Република Северна Македонија — Законодавно-правна комисија (редакциски пречистен текст), објавен преку mojkonsultant.mk","url":"https://mojkonsultant.mk/wp-content/uploads/2023/02/%D0%97%D0%B0%D0%BA%D0%BE%D0%BD-%D0%B7%D0%B0-%D0%B4%D0%B0%D0%BD%D0%BE%D0%BA%D0%BE%D1%82-%D0%BD%D0%B0-%D0%B4%D0%BE%D0%B4%D0%B0%D0%B4%D0%B5%D0%BD%D0%B0-%D0%B2%D1%80%D0%B5%D0%B4%D0%BD%D0%BE%D1%81%D1%82-04.02.2025.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ddv-04","title":"Даночна пријава ДДВ-04 и Упатство за пополнување (образец објавен во „Службен весник на РСМ“ бр. 79/22, важи од 30.03.2022)","publisher":"Управа за јавни приходи (УЈП)","url":"https://www.ujp.gov.mk/files/attachment/0000/0967/sl.79_DDV-04_30.03.2022.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"konten-plan","title":"Правилник за сметковниот план и содржината на одделните сметки во сметковниот план (донесен врз основа на член 472 став (9) од Законот за трговските друштва, „Службен весник на Република Македонија“, со подоцнежни измени)","publisher":"Министерство за финансии на Република Северна Македонија / Управа за јавни приходи","url":"https://www.ujp.gov.mk/files/attachment/0000/0720/Pravilnik_za_smetkovostveniot_plan_i_sodrzinata_na_oddelnite_smetki_vo_smetkovostveniot_plan__174-2011.od_16.12.2011.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"finansiska-disciplina","title":"Закон за финансиска дисциплина („Службен весник на РМ“ бр. 187/2013, 201/2014 и 215 од 07.12.2015)","publisher":"Управа за јавни приходи (УЈП) — текст на закон","url":"https://www.ujp.gov.mk/files/attachment/0000/0766/Zakon_za_finansiska_disciplina_215_07.12.2015.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"etax-portal","title":"е-Даноци — системот на УЈП за поднесување на даночни пријави, вклучувајќи ја ДДВ-пријавата","publisher":"Управа за јавни приходи (УЈП)","url":"https://etax.ujp.gov.mk","consulted_on":"2026-09-26","kind":"portal"},{"key":"e-faktura-najava","title":"Соопштение на УЈП: „Презентација на новиот систем за електронско фактурирање (е-фактура) пред членките на Стопанската комора на Македонија“ — тестирање преку АПИ врска започнува на 1.1.2026","publisher":"Управа за јавни приходи (УЈП)","url":"https://ujp.gov.mk/uploads/File/2025/e-Faktura/08-9024-1_%D0%9F%D1%80%D0%B5%D0%B7%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D1%98%D0%B0%20%D0%BD%D0%B0%20%D0%BD%D0%BE%D0%B2%D0%B8%D0%BE%D1%82%20%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%20%D0%B7%D0%B0%20%D0%B5%D0%BB%D0%B5%D0%BA%D1%82%D1%80%D0%BE%D0%BD%D1%81%D0%BA%D0%BE%20%D1%84%D0%B0%D0%BA%D1%82%D1%83%D1%80%D0%B8%D1%80%D0%B0%D1%9A%D0%B5%20(%D0%B5-%D1%84%D0%B0%D0%BA%D1%82%D1%83%D1%80%D0%B0)%20%D0%BF%D1%80%D0%B5%D0%B4%20%D1%87%D0%BB%D0%B5%D0%BD%D0%BA%D0%B8%D1%82%D0%B5%20%D0%BD%D0%B0%20%D0%A1%D1%82%D0%BE%D0%BF%D0%B0%D0%BD%D1%81%D0%BA%D0%B0%D1%82%D0%B0%20%D0%BA%D0%BE%D0%BC%D0%BE%D1%80%D0%B0%20%D0%BD%D0%B0%20%D0%9C%D0%B0%D0%BA%D0%B5%D0%B4%D0%BE%D0%BD%D0%B8%D1%98%D0%B0_10.12.2025.pdf","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('MK', 'default', 'Сметковен план за трговски друштва (Правилник за сметковниот план)', '{"en":"Chart of accounts for trading companies (Regulation on the Chart of Accounts)"}'::jsonb, true, 'companies', array['MK-BS', 'MK-IS']::text[], null, 'Правилник за сметковниот план и содржината на одделните сметки во сметковниот план, донесен врз основа на член 472 став (9) од Законот за трговските друштва — задолжителен за секој субјект кој води сметководство според Законот за трговските друштва. Членот 2 од Правилникот дозволува пропишаните трицифрени (синтетички) сметки да се расчленат на аналитички сметки; на таа основа овој пакет додава четирицифрени подсметки под 130 и 230 (разграничување на пресметан/влезен ДДВ од побарувањето/обврската по даночната пријава — научено од пакетот за Словачка) и под 259 и 469 (сметка на чекање и заокружување, кои Правилникот не ги предвидува одделно). Овој пакет транскрибира избор од синтетичките сметки на официјалниот план кои ги достигнуваат неговите документи; не секоја официјална подсметка е присутна — видете README.md.', 'konten-plan')
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
  ('MK', 'default', '00', 'Нематеријални средства', '{"en":"Intangible assets"}'::jsonb, 'asset_fixed', false, null, 10),
  ('MK', 'default', '001', 'Гудвил', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, '00', 20),
  ('MK', 'default', '002', 'Концесии, патенти, лиценци, трговски и услужни марки', '{"en":"Concessions, patents, licences, trademarks and service marks"}'::jsonb, 'asset_fixed', false, '00', 30),
  ('MK', 'default', '003', 'Софтвер и останати права', '{"en":"Software and other rights"}'::jsonb, 'asset_fixed', false, '00', 40),
  ('MK', 'default', '01', 'Материјални средства', '{"en":"Property, plant and equipment"}'::jsonb, 'asset_fixed', false, null, 50),
  ('MK', 'default', '010', 'Земјишта', '{"en":"Land"}'::jsonb, 'asset_fixed', false, '01', 60),
  ('MK', 'default', '011', 'Градежни објекти', '{"en":"Buildings and structures"}'::jsonb, 'asset_fixed', false, '01', 70),
  ('MK', 'default', '012', 'Постројки и опрема', '{"en":"Plant and equipment"}'::jsonb, 'asset_fixed', false, '01', 80),
  ('MK', 'default', '013', 'Алат, погонски и канцелариски инвентар, мебел и транспортни средства', '{"en":"Tools, office and computer equipment, furniture and vehicles"}'::jsonb, 'asset_fixed', false, '01', 90),
  ('MK', 'default', '016', 'Материјални средства во подготовка', '{"en":"Property, plant and equipment under construction"}'::jsonb, 'asset_fixed', false, '01', 100),
  ('MK', 'default', '02', 'Вложувања во недвижности', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, null, 110),
  ('MK', 'default', '03', 'Долгорочни финансиски средства', '{"en":"Long-term financial assets"}'::jsonb, 'asset_non_current', false, null, 120),
  ('MK', 'default', '030', 'Вложувања во подружници', '{"en":"Investments in subsidiaries"}'::jsonb, 'asset_non_current', false, '03', 130),
  ('MK', 'default', '033', 'Дадени заеми и кредити во земјата и во странство', '{"en":"Loans and credits granted in the country and abroad"}'::jsonb, 'asset_non_current', false, '03', 140),
  ('MK', 'default', '04', 'Долгорочни побарувања', '{"en":"Long-term receivables"}'::jsonb, 'asset_non_current', false, null, 150),
  ('MK', 'default', '05', 'Одложени даночни средства', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 160),
  ('MK', 'default', '10', 'Парични средства и парични еквиваленти', '{"en":"Cash and cash equivalents"}'::jsonb, 'asset_cash', false, null, 170),
  ('MK', 'default', '100', 'Парични средства на трансакциски сметки во денари', '{"en":"Cash at transaction accounts in denars"}'::jsonb, 'asset_cash', false, '10', 180),
  ('MK', 'default', '102', 'Парични средства во благајна', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, '10', 190),
  ('MK', 'default', '103', 'Девизни сметки', '{"en":"Foreign currency accounts"}'::jsonb, 'asset_cash', false, '10', 200),
  ('MK', 'default', '11', 'Побарувања од поврзани друштва', '{"en":"Receivables from related companies"}'::jsonb, 'asset_current', false, null, 210),
  ('MK', 'default', '12', 'Побарувања од купувачи', '{"en":"Receivables from customers"}'::jsonb, 'asset_receivable', true, null, 220),
  ('MK', 'default', '120', 'Побарувања од купувачи во земјата', '{"en":"Receivables from domestic customers"}'::jsonb, 'asset_receivable', true, '12', 230),
  ('MK', 'default', '121', 'Побарувања од купувачи во странство', '{"en":"Receivables from foreign customers"}'::jsonb, 'asset_receivable', true, '12', 240),
  ('MK', 'default', '122', 'Побарувања за дадени аванси, депозити и каунции', '{"en":"Receivables for advances, deposits and guarantees given"}'::jsonb, 'asset_current', false, '12', 250),
  ('MK', 'default', '13', 'Побарувања од државни органи и институции', '{"en":"Receivables from state authorities and institutions"}'::jsonb, 'asset_current', false, null, 260),
  ('MK', 'default', '130', 'Данок на додадена вредност', '{"en":"Value added tax"}'::jsonb, 'asset_current', false, '13', 270),
  ('MK', 'default', '1300', 'ДДВ — за одбивка (влезен данок)', '{"en":"VAT deductible (input tax)"}'::jsonb, 'asset_current', false, '130', 280),
  ('MK', 'default', '1301', 'ДДВ — побарување по даночна пријава', '{"en":"VAT receivable under the tax return"}'::jsonb, 'asset_current', true, '130', 290),
  ('MK', 'default', '134', 'Побарувања за повеќе платен персонален данок на доход', '{"en":"Receivables for personal income tax overpaid"}'::jsonb, 'asset_current', false, '13', 300),
  ('MK', 'default', '14', 'Побарувања од вработените', '{"en":"Receivables from employees"}'::jsonb, 'asset_current', false, null, 310),
  ('MK', 'default', '140', 'Побарувања од вработените за повеќе исплатена плата и надоместоци', '{"en":"Receivables from employees for salary overpaid"}'::jsonb, 'asset_current', false, '14', 320),
  ('MK', 'default', '15', 'Останати побарувања', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 330),
  ('MK', 'default', '158', 'Останати побарувања', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, '15', 340),
  ('MK', 'default', '16', 'Краткорочни финансиски средства', '{"en":"Short-term financial assets"}'::jsonb, 'asset_current', false, null, 350),
  ('MK', 'default', '19', 'Платени трошоци за идни периоди и пресметани приходи', '{"en":"Prepaid expenses and accrued income"}'::jsonb, 'asset_prepayments', false, null, 360),
  ('MK', 'default', '190', 'Однапред платени трошоци', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, '19', 370),
  ('MK', 'default', '21', 'Краткорочни обврски спрема поврзани друштва', '{"en":"Short-term liabilities to related companies"}'::jsonb, 'liability_current', false, null, 380),
  ('MK', 'default', '22', 'Краткорочни обврски спрема добавувачи', '{"en":"Short-term liabilities to suppliers"}'::jsonb, 'liability_payable', true, null, 390),
  ('MK', 'default', '220', 'Обврски спрема добавувачи во земјата', '{"en":"Liabilities to domestic suppliers"}'::jsonb, 'liability_payable', true, '22', 400),
  ('MK', 'default', '221', 'Обврски спрема добавувачи од странство', '{"en":"Liabilities to foreign suppliers"}'::jsonb, 'liability_payable', true, '22', 410),
  ('MK', 'default', '222', 'Обврски за примени аванси, депозити и каунции', '{"en":"Liabilities for advances, deposits and guarantees received"}'::jsonb, 'liability_current', false, '22', 420),
  ('MK', 'default', '23', 'Краткорочни обврски за даноци, придонеси и други давачки', '{"en":"Short-term liabilities for taxes, contributions and other charges"}'::jsonb, 'liability_current', false, null, 430),
  ('MK', 'default', '230', 'Обврски за данокот на додадена вредност', '{"en":"Value added tax liability"}'::jsonb, 'liability_current', false, '23', 440),
  ('MK', 'default', '2300', 'ДДВ — пресметан (излезен данок)', '{"en":"VAT charged (output tax)"}'::jsonb, 'liability_current', false, '230', 450),
  ('MK', 'default', '2301', 'ДДВ — обврска по даночна пријава', '{"en":"VAT payable under the tax return"}'::jsonb, 'liability_current', true, '230', 460),
  ('MK', 'default', '234', 'Обврски за даноци и придонеси на плата и надоместоци на плата', '{"en":"Liabilities for payroll taxes and contributions"}'::jsonb, 'liability_current', false, '23', 470),
  ('MK', 'default', '235', 'Обврски за персонален данок на доход', '{"en":"Liabilities for personal income tax"}'::jsonb, 'liability_current', false, '23', 480),
  ('MK', 'default', '24', 'Обврски спрема вработените', '{"en":"Liabilities to employees"}'::jsonb, 'liability_current', false, null, 490),
  ('MK', 'default', '240', 'Обврски за плата и надоместоци на плата', '{"en":"Liabilities for salaries and salary allowances"}'::jsonb, 'liability_current', false, '24', 500),
  ('MK', 'default', '25', 'Останати краткорочни обврски и краткорочни резервирања', '{"en":"Other short-term liabilities and short-term provisions"}'::jsonb, 'liability_current', false, null, 510),
  ('MK', 'default', '253', 'Обврски врз основа на наем', '{"en":"Liabilities from leases"}'::jsonb, 'liability_current', false, '25', 520),
  ('MK', 'default', '259', 'Останати краткорочни обврски', '{"en":"Other short-term liabilities"}'::jsonb, 'liability_current', false, '25', 530),
  ('MK', 'default', '2590', 'Сметка на чекање (суспензивна сметка)', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, '259', 540),
  ('MK', 'default', '26', 'Краткорочни финансиски обврски', '{"en":"Short-term financial liabilities"}'::jsonb, 'liability_current', false, null, 550),
  ('MK', 'default', '262', 'Краткорочни кредити и заеми во земјата', '{"en":"Short-term domestic loans and credits"}'::jsonb, 'liability_current', false, '26', 560),
  ('MK', 'default', '27', 'Долгорочни резервирања', '{"en":"Long-term provisions"}'::jsonb, 'liability_non_current', false, null, 570),
  ('MK', 'default', '28', 'Долгорочни обврски', '{"en":"Long-term liabilities"}'::jsonb, 'liability_non_current', false, null, 580),
  ('MK', 'default', '286', 'Долгорочни обврски врз основа на заеми и кредити во земјата и во странство', '{"en":"Long-term liabilities from domestic and foreign loans and credits"}'::jsonb, 'liability_non_current', false, '28', 590),
  ('MK', 'default', '289', 'Одложени даночни обврски', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, '28', 600),
  ('MK', 'default', '29', 'Одложени плаќања на трошоци и приходи на идни периоди', '{"en":"Deferred income and accrued expenses"}'::jsonb, 'liability_current', false, null, 610),
  ('MK', 'default', '293', 'Пресметани приходи за идни периоди', '{"en":"Deferred income"}'::jsonb, 'liability_current', false, '29', 620),
  ('MK', 'default', '30', 'Пресметка на набавката на залихи', '{"en":"Purchases of inventory in transit"}'::jsonb, 'asset_current', false, null, 630),
  ('MK', 'default', '31', 'Залиха на суровини и материјали', '{"en":"Raw materials and supplies"}'::jsonb, 'asset_current', false, null, 640),
  ('MK', 'default', '310', 'Суровини и материјали на залиха', '{"en":"Raw materials and supplies in stock"}'::jsonb, 'asset_current', false, '31', 650),
  ('MK', 'default', '32', 'Залиха на резервни делови', '{"en":"Spare parts inventory"}'::jsonb, 'asset_current', false, null, 660),
  ('MK', 'default', '35', 'Залиха на ситен инвентар, амбалажа и автогуми', '{"en":"Low-value inventory, packaging and tyres"}'::jsonb, 'asset_current', false, null, 670),
  ('MK', 'default', '350', 'Ситен инвентар на залиха', '{"en":"Low-value inventory in stock"}'::jsonb, 'asset_current', false, '35', 680),
  ('MK', 'default', '352', 'Залиха на амбалажа', '{"en":"Packaging in stock"}'::jsonb, 'asset_current', false, '35', 690),
  ('MK', 'default', '40', 'Трошоци за суровини, материјали, енергија, резервни делови и ситен инвентар', '{"en":"Cost of raw materials, supplies, energy, spare parts and low-value inventory"}'::jsonb, 'expense_direct_cost', false, null, 700),
  ('MK', 'default', '400', 'Трошоци за суровини и материјали (за производство)', '{"en":"Cost of raw materials and supplies (production)"}'::jsonb, 'expense_direct_cost', false, '40', 710),
  ('MK', 'default', '402', 'Трошоци за енергија (за производство)', '{"en":"Cost of energy (production)"}'::jsonb, 'expense_direct_cost', false, '40', 720),
  ('MK', 'default', '41', 'Трошоци за услуги', '{"en":"Cost of services"}'::jsonb, 'expense', false, null, 730),
  ('MK', 'default', '410', 'Транспортни услуги', '{"en":"Transport services"}'::jsonb, 'expense', false, '41', 740),
  ('MK', 'default', '411', 'Поштенски услуги, телефонски услуги и интернет', '{"en":"Postal, telephone and internet services"}'::jsonb, 'expense', false, '41', 750),
  ('MK', 'default', '413', 'Услуги за одржување и заштита', '{"en":"Maintenance and protection services"}'::jsonb, 'expense', false, '41', 760),
  ('MK', 'default', '414', 'Наем — лизинг', '{"en":"Rent — leasing"}'::jsonb, 'expense', false, '41', 770),
  ('MK', 'default', '417', 'Трошоци за реклама, пропаганда, промоција и саеми', '{"en":"Advertising, promotion and trade fair costs"}'::jsonb, 'expense', false, '41', 780),
  ('MK', 'default', '419', 'Останати услуги', '{"en":"Other services"}'::jsonb, 'expense', false, '41', 790),
  ('MK', 'default', '42', 'Плата, надоместоци на плата и останати трошоци за вработените', '{"en":"Salaries, salary allowances and other employee costs"}'::jsonb, 'expense', false, null, 800),
  ('MK', 'default', '420', 'Плата и надоместоци на плата — бруто (за производство)', '{"en":"Gross salaries and allowances (production)"}'::jsonb, 'expense', false, '42', 810),
  ('MK', 'default', '421', 'Плата и надоместоци на плата — бруто (за администрација, управа и продажба)', '{"en":"Gross salaries and allowances (administration, management and sales)"}'::jsonb, 'expense', false, '42', 820),
  ('MK', 'default', '43', 'Трошоци за амортизација и резервирања', '{"en":"Depreciation and provisions"}'::jsonb, 'expense_depreciation', false, null, 830),
  ('MK', 'default', '430', 'Трошоци за амортизација (за производство)', '{"en":"Depreciation costs (production)"}'::jsonb, 'expense_depreciation', false, '43', 840),
  ('MK', 'default', '432', 'Трошоци за амортизација (за администрација, управа и продажба)', '{"en":"Depreciation costs (administration, management and sales)"}'::jsonb, 'expense_depreciation', false, '43', 850),
  ('MK', 'default', '44', 'Останати трошоци од работењето', '{"en":"Other operating costs"}'::jsonb, 'expense', false, null, 860),
  ('MK', 'default', '440', 'Дневници за службени патувања, ноќевања и патни трошоци', '{"en":"Business travel, accommodation and travel costs"}'::jsonb, 'expense', false, '44', 870),
  ('MK', 'default', '444', 'Трошоци за репрезентација', '{"en":"Entertainment costs"}'::jsonb, 'expense', false, '44', 880),
  ('MK', 'default', '445', 'Трошоци за осигурување', '{"en":"Insurance costs"}'::jsonb, 'expense', false, '44', 890),
  ('MK', 'default', '446', 'Банкарски услуги и трошоци за платен промет', '{"en":"Bank charges and payment costs"}'::jsonb, 'expense', false, '44', 900),
  ('MK', 'default', '447', 'Даноци кои не зависат од резултатот, членарини и други давачки', '{"en":"Non-result-dependent taxes, membership fees and other charges"}'::jsonb, 'expense', false, '44', 910),
  ('MK', 'default', '45', 'Вредносно усогласување (обезвреднување) на нетековни и тековни средства', '{"en":"Impairment of non-current and current assets"}'::jsonb, 'expense', false, null, 920),
  ('MK', 'default', '455', 'Вредносно усогласување (обезвреднување) на краткорочни побарувања', '{"en":"Impairment of short-term receivables"}'::jsonb, 'expense', false, '45', 930),
  ('MK', 'default', '46', 'Останати расходи', '{"en":"Other expenses"}'::jsonb, 'expense', false, null, 940),
  ('MK', 'default', '464', 'Кусоци, кало, растур, расипување и кршење', '{"en":"Shortages, spillage, spoilage and breakage"}'::jsonb, 'expense', false, '46', 950),
  ('MK', 'default', '469', 'Останати расходи од работењето', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, '46', 960),
  ('MK', 'default', '4690', 'Заокружување (разлики од заокружување)', '{"en":"Rounding"}'::jsonb, 'expense', false, '469', 970),
  ('MK', 'default', '47', 'Финансиски расходи', '{"en":"Financial expenses"}'::jsonb, 'expense', false, null, 980),
  ('MK', 'default', '470', 'Расходи врз основа на камати од работењето со поврзани друштва', '{"en":"Interest expense from related companies"}'::jsonb, 'expense', false, '47', 990),
  ('MK', 'default', '474', 'Расходи врз основа на камати од работењето со неповрзани друштва', '{"en":"Interest expense from unrelated companies"}'::jsonb, 'expense', false, '47', 1000),
  ('MK', 'default', '475', 'Расходи врз основа на негативни курсни разлики од работењето со неповрзани друштва', '{"en":"Negative exchange-rate differences from unrelated companies"}'::jsonb, 'expense', false, '47', 1010),
  ('MK', 'default', '60', 'Производство', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 1020),
  ('MK', 'default', '600', 'Производство (изградба) во тек', '{"en":"Work (construction) in progress"}'::jsonb, 'asset_current', false, '60', 1030),
  ('MK', 'default', '63', 'Готови производи', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 1040),
  ('MK', 'default', '630', 'Производи на залиха', '{"en":"Finished goods in stock"}'::jsonb, 'asset_current', false, '63', 1050),
  ('MK', 'default', '66', 'Стоки', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, null, 1060),
  ('MK', 'default', '660', 'Стоки на залиха', '{"en":"Merchandise in stock"}'::jsonb, 'asset_current', false, '66', 1070),
  ('MK', 'default', '70', 'Расходи врз основа на продадени добра и услуги', '{"en":"Cost of goods and services sold"}'::jsonb, 'expense_direct_cost', false, null, 1080),
  ('MK', 'default', '700', 'Расходи врз основа на продадени добра (производи) и услуги', '{"en":"Cost of goods (products) and services sold"}'::jsonb, 'expense_direct_cost', false, '70', 1090),
  ('MK', 'default', '701', 'Набавна вредност на продадени добра (стоки)', '{"en":"Purchase cost of merchandise sold"}'::jsonb, 'expense_direct_cost', false, '70', 1100),
  ('MK', 'default', '74', 'Приходи од продажба на неповрзани друштва', '{"en":"Revenue from sales to unrelated companies"}'::jsonb, 'income', false, null, 1110),
  ('MK', 'default', '740', 'Приходи од продажба на добра (производи) и услуги во земјата', '{"en":"Revenue from domestic sales of goods (products) and services"}'::jsonb, 'income', false, '74', 1120),
  ('MK', 'default', '741', 'Приходи од продажба на добра (стоки) во земјата', '{"en":"Revenue from domestic sales of merchandise"}'::jsonb, 'income', false, '74', 1130),
  ('MK', 'default', '742', 'Приходи од продажба на добра (производи, стоки) и услуги во странство', '{"en":"Revenue from foreign sales of goods (products, merchandise) and services"}'::jsonb, 'income', false, '74', 1140),
  ('MK', 'default', '747', 'Приходи од наемнини', '{"en":"Rental income"}'::jsonb, 'income', false, '74', 1150),
  ('MK', 'default', '75', 'Приходи од вредносно усогласување на нетековни и тековни средства', '{"en":"Income from value adjustment of non-current and current assets"}'::jsonb, 'income_other', false, null, 1160),
  ('MK', 'default', '755', 'Приходи од вредносно усогласување на краткорочни побарувања', '{"en":"Income from value adjustment of short-term receivables"}'::jsonb, 'income_other', false, '75', 1170),
  ('MK', 'default', '76', 'Останати приходи', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 1180),
  ('MK', 'default', '764', 'Вишоци', '{"en":"Surpluses"}'::jsonb, 'income_other', false, '76', 1190),
  ('MK', 'default', '769', 'Останати приходи од работењето', '{"en":"Other operating income"}'::jsonb, 'income_other', false, '76', 1200),
  ('MK', 'default', '77', 'Финансиски приходи', '{"en":"Financial income"}'::jsonb, 'income_other', false, null, 1210),
  ('MK', 'default', '770', 'Приходи врз основа на камати од работењето со поврзани друштва', '{"en":"Interest income from related companies"}'::jsonb, 'income_other', false, '77', 1220),
  ('MK', 'default', '774', 'Приходи врз основа на камати од работењето со неповрзани друштва', '{"en":"Interest income from unrelated companies"}'::jsonb, 'income_other', false, '77', 1230),
  ('MK', 'default', '775', 'Приходи врз основа на позитивни курсни разлики од работењето со неповрзани друштва', '{"en":"Positive exchange-rate differences from unrelated companies"}'::jsonb, 'income_other', false, '77', 1240),
  ('MK', 'default', '90', 'Основна главнина — запишан капитал', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 1250),
  ('MK', 'default', '900', 'Основна главнина — запишан и уплатен капитал', '{"en":"Share capital — subscribed and paid in"}'::jsonb, 'equity', false, '90', 1260),
  ('MK', 'default', '94', 'Резерви', '{"en":"Reserves"}'::jsonb, 'equity', false, null, 1270),
  ('MK', 'default', '940', 'Законски резерви', '{"en":"Legal reserves"}'::jsonb, 'equity', false, '94', 1280),
  ('MK', 'default', '941', 'Статутарни резерви', '{"en":"Statutory reserves"}'::jsonb, 'equity', false, '94', 1290),
  ('MK', 'default', '95', 'Задржана (акумулирана) добивка и добивка за тековна година', '{"en":"Retained earnings and profit for the current year"}'::jsonb, 'equity_retained', false, null, 1300),
  ('MK', 'default', '950', 'Задржана (акумулирана) добивка од претходни години', '{"en":"Retained earnings from previous years"}'::jsonb, 'equity_retained', false, '95', 1310),
  ('MK', 'default', '951', 'Добивка од тековната година', '{"en":"Profit for the current year"}'::jsonb, 'equity', false, '95', 1320),
  ('MK', 'default', '96', 'Пренесена загуба и загуба за тековна година', '{"en":"Losses carried forward and loss for the current year"}'::jsonb, 'equity_retained', false, null, 1330),
  ('MK', 'default', '960', 'Пренесена загуба од претходни години', '{"en":"Losses carried forward from previous years"}'::jsonb, 'equity_retained', false, '96', 1340),
  ('MK', 'default', '961', 'Загуба за тековната година', '{"en":"Loss for the current year"}'::jsonb, 'equity', false, '96', 1350)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('MK', 'BNK', 'Банкарски дневник', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('MK', 'CSH', 'Благајнички дневник', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('MK', 'GEN', 'Општ дневник', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('MK', 'OPN', 'Дневник на отворање', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('MK', 'PUR', 'Дневник на набавка', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('MK', 'SAL', 'Дневник на продажба', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('MK', 'MK-P-10', 'ДДВ 10% — повластена стапка, услуги на исхрана и сместување (набавка)', '{"en":"VAT 10% — reduced rate, catering and accommodation services (purchase)"}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '2023-09-01', null, 'Закон за данокот на додадена вредност, член 30-а став (1) и член 33 — претходниот данок платен по повластената стапка на 10% на услуги на сместување или на исхрана и пијалаци (освен репрезентација, исклучена со член 35 точка 3) користени за целите на стопанската дејност се одбива согласно условите од член 34.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-P-18', 'ДДВ 18% — општа даночна стапка (набавка)', '{"en":"VAT 18% — standard rate (purchase)"}'::jsonb, null, 'percent', 18, 'purchase', 'domestic', date '2000-04-01', null, 'Закон за данокот на додадена вредност, член 29 и член 33 — претходниот данок платен по општата стапка на 18% за набавени добра и услуги користени за целите на стопанската дејност на даночниот обврзник се одбива согласно условите од член 34.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-P-5', 'ДДВ 5% — повластена стапка (набавка)', '{"en":"VAT 5% — reduced rate (purchase)"}'::jsonb, null, 'percent', 5, 'purchase', 'domestic', date '2000-04-01', null, 'Закон за данокот на додадена вредност, член 30 став (1) точка 10 и член 33 — повластената стапка од 5% опфаќа и машини за автоматска обработка на податоци (компјутери) и софтвер за нив; претходниот данок платен по оваа стапка за набавки користени за целите на стопанската дејност се одбива согласно условите од член 34.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-S-10', 'ДДВ 10% — повластена стапка, услуги на исхрана и сместување (продажба)', '{"en":"VAT 10% — reduced rate, catering and accommodation services (sale)"}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '2023-09-01', null, 'Закон за данокот на додадена вредност, член 30-а став (1) — повластената даночна стапка од 10% се применува на услуги на предавање на храна и на пијалаци за консумација на лице место и кетеринг услуги, со исклучок на алкохолни пијалаци.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-S-18', 'ДДВ 18% — општа даночна стапка (продажба)', '{"en":"VAT 18% — standard rate (sale)"}'::jsonb, null, 'percent', 18, 'sale', 'domestic', date '2000-04-01', null, 'Закон за данокот на додадена вредност, член 29 — општата даночна стапка од 18% се применува врз целокупниот промет и увоз, освен врз прометот и увозот кој се оданочува со повластената даночна стапка.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-S-5', 'ДДВ 5% — повластена стапка, основни производи за човечка исхрана (продажба)', '{"en":"VAT 5% — reduced rate, basic food products (sale)"}'::jsonb, null, 'percent', 5, 'sale', 'domestic', date '2000-04-01', null, 'Закон за данокот на додадена вредност, член 30 став (1) точка 1 — повластената даночна стапка од 5% се применува врз прометот и увозот на основни производи за човечка исхрана.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-S-EXEMPT-EDU', 'Ослободено без право на одбивка — образовни услуги (продажба)', '{"en":"Exempt without right to deduct — educational services (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2000-04-01', null, 'Закон за данокот на додадена вредност, член 23 точка 17 буква а) — се ослободуваат од данок образовните услуги, и тоа образование и воспитување на деца и младинци, вклучувајќи и услуги на училишно и универзитетско образование.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null),
  ('MK', 'MK-S-EXPORT', 'Извоз на добра — ослободено со право на одбивка (продажба)', '{"en":"Export of goods — exempt with right to deduct (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2000-04-01', null, 'Закон за данокот на додадена вредност, член 24 став (1) точка 1 — се ослободуваат од данок испораки на добра кои се превезуваат или испраќаат во странство од страна на даночниот обврзник, примателот на доброто или трето лице по нивен налог, ако примателот на доброто е со седиште во странство; член 26 — прометот се смета за извршен извоз кога доброто ја премине царинската линија на Републиката и стигне во странство. Северна Македонија е кандидат, а не членка на Европската Унија — согласно член 5(2) од Директивата 2006/112/ЕЗ, заедничкиот систем на ДДВ не се протега на нејзината територија (нов ред во supabase/seed/00_territories.sql); `vat_category` и `exemption_code` затоа остануваат празни на секој оданочив ред, а статијата на ослободувањето е запишана во `legal_reference`.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv', null, null, null, null)
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
    ('MK-P-10', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'MK-DDV-04', 10),
    ('MK-P-10', 'invoice', 'tax', 100, '1300', '22', array['22']::text[], 100, 'MK-DDV-04', 20),
    ('MK-P-18', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'MK-DDV-04', 10),
    ('MK-P-18', 'invoice', 'tax', 100, '1300', '22', array['22']::text[], 100, 'MK-DDV-04', 20),
    ('MK-P-5', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'MK-DDV-04', 10),
    ('MK-P-5', 'invoice', 'tax', 100, '1300', '22', array['22']::text[], 100, 'MK-DDV-04', 20),
    ('MK-S-10', 'invoice', 'base', 100, null, '03', array['03']::text[], 100, 'MK-DDV-04', 10),
    ('MK-S-10', 'invoice', 'tax', 100, '2300', '04', array['04']::text[], 100, 'MK-DDV-04', 20),
    ('MK-S-10', 'credit_note', 'base', 100, null, '03', array['03']::text[], -100, 'MK-DDV-04', 10),
    ('MK-S-10', 'credit_note', 'tax', 100, '2300', '04', array['04']::text[], -100, 'MK-DDV-04', 20),
    ('MK-S-18', 'invoice', 'base', 100, null, '01', array['01']::text[], 100, 'MK-DDV-04', 10),
    ('MK-S-18', 'invoice', 'tax', 100, '2300', '02', array['02']::text[], 100, 'MK-DDV-04', 20),
    ('MK-S-18', 'credit_note', 'base', 100, null, '01', array['01']::text[], -100, 'MK-DDV-04', 10),
    ('MK-S-18', 'credit_note', 'tax', 100, '2300', '02', array['02']::text[], -100, 'MK-DDV-04', 20),
    ('MK-S-5', 'invoice', 'base', 100, null, '05', array['05']::text[], 100, 'MK-DDV-04', 10),
    ('MK-S-5', 'invoice', 'tax', 100, '2300', '06', array['06']::text[], 100, 'MK-DDV-04', 20),
    ('MK-S-5', 'credit_note', 'base', 100, null, '05', array['05']::text[], -100, 'MK-DDV-04', 10),
    ('MK-S-5', 'credit_note', 'tax', 100, '2300', '06', array['06']::text[], -100, 'MK-DDV-04', 20),
    ('MK-S-EXEMPT-EDU', 'invoice', 'base', 100, null, '09', array['09']::text[], 100, 'MK-DDV-04', 10),
    ('MK-S-EXEMPT-EDU', 'credit_note', 'base', 100, null, '09', array['09']::text[], -100, 'MK-DDV-04', 10),
    ('MK-S-EXPORT', 'invoice', 'base', 100, null, '07', array['07']::text[], 100, 'MK-DDV-04', 10),
    ('MK-S-EXPORT', 'credit_note', 'base', 100, null, '07', array['07']::text[], -100, 'MK-DDV-04', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'MK' and t.code = v.tax_code
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
  ('MK', 'MK-DDV-04', 'Даночна пријава на данокот на додадена вредност (ДДВ-04)', array['month', 'quarter']::declaration_period[], null, date '2022-03-30', null, 'Закон за данокот на додадена вредност, член 39 — даночниот период е календарски месец, или календарско тримесечје кога вкупниот промет во изминатата календарска година не надминал износ од 25 милиони денари. Образецот ДДВ-04 (Службен весник на РСМ бр. 79/22) го носи истиот образец без разлика на периодот; овој пакет не предлага `period_default`, бидејќи периодот зависи од прометот на компанијата и не е еден одговор даден на секого. Транскрибирани се само редовите што ги достигнуваат сопствените даноци на овој пакет: прометот по општата и повластените стапки (редови 01-06), извозот (ред 07), ослободениот промет без право на одбивка (ред 09), збирот на ДДВ (ред 20), влезниот промет со право на одбивка (редови 21-22), збирот на претходни даноци (ред 29) и конечниот износ (ред 31). Редовите за пренесен данок (11-19), увоз (27-28), останати даноци и исправки (поле 30) и распределбата на побарувањето не се пресликани — видете README.md и docs/international.md, делот „From North Macedonia“.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Закон за данокот на додадена вредност, член 41 став (1) — даночниот обврзник е должен за секој даночен период да поднесе даночна пријава во рок од 25 дена по истекот на даночниот период. Уплатата на пресметаниот данок доспева пет дена подоцна (член 43 став (2)), рок кој ова поле не го моделира одделно бидејќи `tax_report.json.deadline` носи само еден датум — видете README.md.', 'zddv', null, 1, 'УЈП, Упатство за пополнување на образецот ДДВ-04 — „Износите се искажуваат во денари, без пари“.', 'ddv-04')
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
  ('MK', 'MK-DDV-04', '01', 'base', 'Оданочив промет по општа даночна стапка — даночна основа', '{"en":"Taxable supply at the standard rate — base"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 01.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '02', 'tax', 'Оданочив промет по општа даночна стапка — износ на ДДВ', '{"en":"Taxable supply at the standard rate — VAT"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 02.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '03', 'base', 'Оданочив промет по повластена даночна стапка од 10% — даночна основа', '{"en":"Taxable supply at the reduced rate of 10% — base"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 03.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '04', 'tax', 'Оданочив промет по повластена даночна стапка од 10% — износ на ДДВ', '{"en":"Taxable supply at the reduced rate of 10% — VAT"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 04.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '05', 'base', 'Оданочив промет по повластена стапка од 5% — даночна основа', '{"en":"Taxable supply at the reduced rate of 5% — base"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 05.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '06', 'tax', 'Оданочив промет по повластена стапка од 5% — износ на ДДВ', '{"en":"Taxable supply at the reduced rate of 5% — VAT"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 06.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '07', 'base', 'Извоз', '{"en":"Export"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 07; Закон за данокот на додадена вредност, член 24 став (1) точка 1 и член 26.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '09', 'base', 'Промет ослободен од данок без право на одбивка на претходен данок', '{"en":"Supply exempt without right to deduct input tax"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 09; Закон за данокот на додадена вредност, член 23.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '20', 'total', 'Вкупен ДДВ', '{"en":"Total VAT"}'::jsonb, 90, null, array['02', '04', '06']::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 20 — формулата на образецот собира и полињата 13, 15, 17 и 19 (пренесен данок), кои овој пакет не ги достигнува.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '21', 'base', 'Влезен промет со право на одбивка на претходниот данок', '{"en":"Input supply with right to deduct input tax"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 21.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '22', 'tax', 'Претходен данок за одбивка', '{"en":"Input tax for deduction"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 22.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '29', 'total', 'Претходни даноци за одбивање', '{"en":"Input taxes for deduction (total)"}'::jsonb, 120, null, array['22']::text[], '{}'::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 29 — формулата на образецот собира и полињата 24, 26 и 28 (пренесен данок и увоз), кои овој пакет не ги достигнува.', 'ddv-04'),
  ('MK', 'MK-DDV-04', '31', 'total', 'Севкупен износ на долгуван или побаруван ДДВ', '{"en":"Net amount owed or receivable"}'::jsonb, 130, null, array['20']::text[], array['29']::text[], null, null, false, false, null, 'Образец ДДВ-04, поле 31 — резултат од полињата 20, 29 и 30; полето 30 не е достигнато во овој пакет. Позитивен износ е долг кон буџетот, а негативен износ е побарување кое се пренесува како аконтација за следниот период или се бара негово враќање.', 'ddv-04')
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
  ('MK-BS', 'MK', 'default', 'Биланс на состојба', 'balance_sheet', 'МСФИ за мали и средни субјекти', date '2012-01-01', null, 'Закон за трговските друштва, член 466 и член 472 — трговските друштва го водат сметководството и ги составуваат годишните сметки согласно Меѓународните стандарди за финансиско известување (МСФИ), односно Меѓународниот стандард за финансиско известување за мали и средни субјекти. Ниту еден пропис прегледан за овој пакет не носи пропишана билансна шема со редни броеви на позиции за трговски друштва (за разлика од НП(С)БО-формата во некои соседни земји); овој пакет затоа состава сопствена сажета шема, групирана по синтетичките класи на официјалниот сметковен план (Правилник за сметковниот план), а не транскрипција на официјален образец со броеви на редови. Видете README.md.', 'konten-plan'),
  ('MK-IS', 'MK', 'default', 'Биланс на успех', 'income_statement', 'МСФИ за мали и средни субјекти', date '2012-01-01', null, 'Закон за трговските друштва, член 466 и член 472 — годишните сметки, вклучувајќи го билансот на успех, се составуваат согласно МСФИ, односно МСФИ за мали и средни субјекти. Оваа шема е сажета и групирана по синтетичките класи на официјалниот сметковен план, а не транскрипција на пропишан образец со броеви на редови (видете забелешката кај MK-BS и README.md).', 'konten-plan')
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
  ('MK-BS', '100', null, 'Нематеријални средства', '{"en":"Intangible assets"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '110', null, 'Материјални средства', '{"en":"Property, plant and equipment"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '120', null, 'Вложувања во недвижности', '{"en":"Investment property"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '130', null, 'Долгорочни финансиски средства', '{"en":"Long-term financial assets"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '140', null, 'Долгорочни побарувања', '{"en":"Long-term receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '150', null, 'Одложени даночни средства', '{"en":"Deferred tax assets"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '160', null, 'Вкупно нетековни средства', '{"en":"Total non-current assets"}'::jsonb, 70, 1, true, array['100', '110', '120', '130', '140', '150']::text[], '{}'::text[], null, null, null),
  ('MK-BS', '170', null, 'Парични средства и парични еквиваленти', '{"en":"Cash and cash equivalents"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '180', null, 'Побарувања од поврзани друштва', '{"en":"Receivables from related companies"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '190', null, 'Побарувања од купувачи', '{"en":"Receivables from customers"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '200', null, 'Побарувања од државни органи и институции', '{"en":"Receivables from state authorities and institutions"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '210', null, 'Побарувања од вработените', '{"en":"Receivables from employees"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '220', null, 'Останати побарувања', '{"en":"Other receivables"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '230', null, 'Краткорочни финансиски средства', '{"en":"Short-term financial assets"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '240', null, 'Платени трошоци за идни периоди и пресметани приходи', '{"en":"Prepaid expenses and accrued income"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '250', null, 'Залихи', '{"en":"Inventory"}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '260', null, 'Вкупно тековни средства', '{"en":"Total current assets"}'::jsonb, 170, 1, true, array['170', '180', '190', '200', '210', '220', '230', '240', '250']::text[], '{}'::text[], null, null, null),
  ('MK-BS', '270', null, 'ВКУПНО СРЕДСТВА', '{"en":"TOTAL ASSETS"}'::jsonb, 180, 1, true, array['160', '260']::text[], '{}'::text[], null, null, null),
  ('MK-BS', '280', null, 'Основна главнина', '{"en":"Share capital"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '290', null, 'Резерви', '{"en":"Reserves"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '300', null, 'Задржана добивка и добивка/загуба за тековната година', '{"en":"Retained earnings and profit/loss for the current year"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '310', null, 'Вкупно капитал и резерви', '{"en":"Total equity"}'::jsonb, 220, 1, true, array['280', '290', '300']::text[], '{}'::text[], null, null, null),
  ('MK-BS', '320', null, 'Долгорочни резервирања', '{"en":"Long-term provisions"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '330', null, 'Долгорочни обврски', '{"en":"Long-term liabilities"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '340', null, 'Вкупно долгорочни обврски', '{"en":"Total non-current liabilities"}'::jsonb, 250, 1, true, array['320', '330']::text[], '{}'::text[], null, null, null),
  ('MK-BS', '350', null, 'Краткорочни обврски спрема поврзани друштва', '{"en":"Short-term liabilities to related companies"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '360', null, 'Краткорочни обврски спрема добавувачи', '{"en":"Short-term liabilities to suppliers"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '370', null, 'Краткорочни обврски за даноци, придонеси и други давачки', '{"en":"Short-term liabilities for taxes, contributions and other charges"}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '380', null, 'Обврски спрема вработените', '{"en":"Liabilities to employees"}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '390', null, 'Останати краткорочни обврски и краткорочни резервирања', '{"en":"Other short-term liabilities and short-term provisions"}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '400', null, 'Краткорочни финансиски обврски', '{"en":"Short-term financial liabilities"}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '410', null, 'Одложени плаќања на трошоци и приходи на идни периоди', '{"en":"Deferred income and accrued expenses"}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-BS', '420', null, 'Вкупно краткорочни обврски', '{"en":"Total current liabilities"}'::jsonb, 330, 1, true, array['350', '360', '370', '380', '390', '400', '410']::text[], '{}'::text[], null, null, null),
  ('MK-BS', '430', null, 'ВКУПНО КАПИТАЛ И ОБВРСКИ', '{"en":"TOTAL EQUITY AND LIABILITIES"}'::jsonb, 340, 1, true, array['310', '340', '420']::text[], '{}'::text[], null, null, null),
  ('MK-IS', '500', null, 'Приходи од продажба', '{"en":"Revenue from sales"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '510', null, 'Набавна вредност на продадени добра и услуги', '{"en":"Cost of goods and services sold"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '520', null, 'Бруто добивка', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['500']::text[], array['510']::text[], null, null, null),
  ('MK-IS', '530', null, 'Трошоци за суровини, материјали и енергија', '{"en":"Cost of raw materials, supplies and energy"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '540', null, 'Трошоци за услуги', '{"en":"Cost of services"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '550', null, 'Трошоци за вработените', '{"en":"Employee costs"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '560', null, 'Трошоци за амортизација', '{"en":"Depreciation"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '570', null, 'Останати трошоци од работењето', '{"en":"Other operating costs"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '580', null, 'Вредносно усогласување (обезвреднување)', '{"en":"Impairment"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '590', null, 'Останати расходи', '{"en":"Other expenses"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '600', null, 'Останати приходи од работењето', '{"en":"Other operating income"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '610', null, 'Добивка/загуба од работењето', '{"en":"Operating profit/loss"}'::jsonb, 120, 1, true, array['520', '600']::text[], array['530', '540', '550', '560', '570', '580', '590']::text[], null, null, null),
  ('MK-IS', '620', null, 'Финансиски приходи', '{"en":"Financial income"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '630', null, 'Финансиски расходи', '{"en":"Financial expenses"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('MK-IS', '640', null, 'Нето добивка/загуба за периодот', '{"en":"Net profit/loss for the period"}'::jsonb, 150, 1, true, array['610', '620']::text[], array['630']::text[], null, null, null)
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
    ('MK-BS', '100', 10, 'code_range', '00', '00', null, 'any'),
    ('MK-BS', '110', 10, 'code_range', '01', '01', null, 'any'),
    ('MK-BS', '120', 10, 'code_range', '02', '02', null, 'any'),
    ('MK-BS', '130', 10, 'code_range', '03', '03', null, 'any'),
    ('MK-BS', '140', 10, 'code_range', '04', '04', null, 'any'),
    ('MK-BS', '150', 10, 'code_range', '05', '05', null, 'any'),
    ('MK-BS', '170', 10, 'code_range', '10', '10', null, 'any'),
    ('MK-BS', '180', 10, 'code_range', '11', '11', null, 'any'),
    ('MK-BS', '190', 10, 'code_range', '12', '12', null, 'any'),
    ('MK-BS', '200', 10, 'code_range', '13', '13', null, 'any'),
    ('MK-BS', '210', 10, 'code_range', '14', '14', null, 'any'),
    ('MK-BS', '220', 10, 'code_range', '15', '15', null, 'any'),
    ('MK-BS', '230', 10, 'code_range', '16', '16', null, 'any'),
    ('MK-BS', '240', 10, 'code_range', '19', '19', null, 'any'),
    ('MK-BS', '250', 10, 'code_range', '30', '35', null, 'any'),
    ('MK-BS', '250', 20, 'code_range', '60', '66', null, 'any'),
    ('MK-BS', '280', 10, 'code_range', '90', '90', null, 'any'),
    ('MK-BS', '290', 10, 'code_range', '94', '94', null, 'any'),
    ('MK-BS', '300', 10, 'code_range', '95', '96', null, 'any'),
    ('MK-BS', '320', 10, 'code_range', '27', '27', null, 'any'),
    ('MK-BS', '330', 10, 'code_range', '28', '28', null, 'any'),
    ('MK-BS', '350', 10, 'code_range', '21', '21', null, 'any'),
    ('MK-BS', '360', 10, 'code_range', '22', '22', null, 'any'),
    ('MK-BS', '370', 10, 'code_range', '23', '23', null, 'any'),
    ('MK-BS', '380', 10, 'code_range', '24', '24', null, 'any'),
    ('MK-BS', '390', 10, 'code_range', '25', '25', null, 'any'),
    ('MK-BS', '400', 10, 'code_range', '26', '26', null, 'any'),
    ('MK-BS', '410', 10, 'code_range', '29', '29', null, 'any'),
    ('MK-IS', '500', 10, 'code_range', '74', '74', null, 'any'),
    ('MK-IS', '510', 10, 'code_range', '70', '70', null, 'any'),
    ('MK-IS', '530', 10, 'code_range', '40', '40', null, 'any'),
    ('MK-IS', '540', 10, 'code_range', '41', '41', null, 'any'),
    ('MK-IS', '550', 10, 'code_range', '42', '42', null, 'any'),
    ('MK-IS', '560', 10, 'code_range', '43', '43', null, 'any'),
    ('MK-IS', '570', 10, 'code_range', '44', '44', null, 'any'),
    ('MK-IS', '580', 10, 'code_range', '45', '45', null, 'any'),
    ('MK-IS', '590', 10, 'code_range', '46', '46', null, 'any'),
    ('MK-IS', '600', 10, 'code_range', '75', '76', null, 'any'),
    ('MK-IS', '620', 10, 'code_range', '77', '77', null, 'any'),
    ('MK-IS', '630', 10, 'code_range', '47', '47', null, 'any')
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
  ('MK', 'Северна Македонија', '{"en":"North Macedonia"}'::jsonb, array['mk', 'en']::text[], 'MKD', '120', '220', '2590', '4690', '950', '740', '419', '100', '102', 'SAL', 'PUR', 'GEN', 'mk', 'result_accounts', '951', '961', null, 'OPN', 'half_up', default, '775', '475', null, null, null, null, '2301', '1301', null, null)
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
  legal_payment_days            = 30,
  late_payment_reference        = 'Доверителот има право на надоместок за доцнење од 3.000 денари, без претходно потсетување, ако паричната обврска не е исполнета во роковите утврдени со Законот за финансиска дисциплина, покрај казнената камата утврдена со Законот за облигационите односи (член 8 од Законот за финансиска дисциплина).',
  numbering_legal_reference     = 'Закон за данокот на додадена вредност, член 53 став (10) точка 1 — фактурата содржи место, датум на издавање и број. Ниту оваа одредба ниту Законот за трговските друштва не пропишуваат единствена задолжителна форма на бројот на комерцијален документ; форматот тука е пример за последователна нумерација, а не единствено можна форма.',
  numbering_source_key          = 'zddv',
  payment_terms_legal_reference = 'Закон за финансиска дисциплина, член 7 став (1) — кога рокот за плаќање не е утврден во деловната трансакција меѓу економски оператори од приватниот сектор, должникот е должен да ја исполни паричната обврска во рок од 30 дена; член 5 став (1) забранува договарање рок подолг од 60 дена меѓу приватни субјекти.',
  payment_terms_source_key      = 'finansiska-disciplina',
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = 'Закон за данокот на додадена вредност, член 31 став (1) — даночниот долг настанува во моментот кога е извршен прометот на доброто (при превоз — моментот на започнување на превозот или испраќањето; при монтирање или инсталирање — моментот на завршување) или во моментот кога услугата е целосно извршена. Ставот (2) на истиот член додава дека кога плаќањето е примено пред прометот, даночниот долг за примениот износ настанува во моментот на плаќањето — механизам на аванс кој овој формат не го моделира одделно бидејќи Ekwo нема документ за авансно плаќање (видете docs/international.md, делот „From North Macedonia“).',
  tax_point_source_key          = 'zddv',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Закон за данокот на додадена вредност, член 22 — корекција на даночната основа поради враќање на доброто, поништување на договорот или менување на цените по извршениот промет се врши во текот на даночниот период во кој настанала промената, а не со бришење на првобитниот запис; член 55 став (3) упатува на истиот механизам за исправка на погрешно искажан данок.',
  posted_edit_policy_source_key = 'zddv',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Законот за данокот на додадена вредност уредува само електронска фактура издадена со согласност на примателот (член 53-б), а не пропишува задолжителна општа е-фактура помеѓу деловни субјекти. УЈП соопшти дека нов систем за е-фактура влегува во фаза на тестирање преку АПИ врска од 1 јануари 2026 година, со спецификации за интеграција што сè уште се објавуваат; на датумот на издавање на овој пакет не е потврден пропис од Службен весник со кој задолжителноста и датумот се утврдени со закон — извештаите на консултантски страници за задолжителност од 1 октомври 2026 не се потврдени со официјален текст. `obligation` затоа е „none“, наместо „mandatory“ со непроверен датум; видете README.md и docs/international.md, делот „From North Macedonia“.',
  einvoice_source_key           = 'e-faktura-najava',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'MK';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('MK', 'export', 'export', 'Извоз — ослободено од данок на додадена вредност согласно член 24 став (1) точка 1 и член 26 од Законот за данокот на додадена вредност.', '{"en":"Export — exempt from value added tax under article 24(1)(1) and article 26 of the Law on Value Added Tax."}'::jsonb, 10, date '1970-01-01', null, 'Закон за данокот на додадена вредност, член 24 став (1) точка 1 и член 26'),
  ('MK', 'exempt', 'exempt', 'Ослободено од данок на додадена вредност без право на одбивка на претходниот данок, согласно член 23 од Законот за данокот на додадена вредност.', '{"en":"Exempt from value added tax without right to deduct input tax, under article 23 of the Law on Value Added Tax."}'::jsonb, 20, date '1970-01-01', null, 'Закон за данокот на додадена вредност, член 23'),
  ('MK', 'late_payment', 'late_payment', 'Во случај на задоцнето плаќање, доверителот има право на законска казнена камата и на надоместок за доцнење од 3.000 денари, согласно Законот за финансиска дисциплина.', '{"en":"In the event of late payment, the creditor is entitled to statutory default interest and to a compensation of 3,000 denars, under the Law on Financial Discipline."}'::jsonb, 30, date '1970-01-01', null, 'Закон за финансиска дисциплина, член 7 и член 8')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
