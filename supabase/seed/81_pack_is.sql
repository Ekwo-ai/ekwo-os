-- Ekwo OS — Ísland: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/is at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build is`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Lög nr. 50/1988 um virðisaukaskatt, með síðari breytingum (Alþingi — Lagasafn)
--     https://www.althingi.is/lagas/nuna/1988050.html
--   Reglugerð nr. 667/1995 um framtal og skil á virðisaukaskatti (Fjármála- og efnahagsráðuneytið)
--     https://www.reglugerd.is/reglugerdir/eftir-raduneytum/fjarmala--og-efnahagsraduneyti/nr/667-1995
--   Reglugerð nr. 50/1993 um bókhald og tekjuskráningu virðisaukaskattsskyldra aðila (Fjármála- og efnahagsráðuneytið)
--     https://www.reglugerd.is/reglugerdir/eftir-raduneytum/fjarmala--og-efnahagsraduneyti/nr/50-1993
--   RSK 10.01 — Virðisaukaskattsskýrsla (eyðublað) (Skatturinn — Ríkisskattstjóri)
--     https://www.skatturinn.is/media/rsk10/rsk_1001.is.pdf
--   Leiðbeiningar um virðisaukaskatt, 19. útgáfa 2022 (Skatturinn — Ríkisskattstjóri)
--     https://www.skatturinn.is/media/baeklingar/rsk_1119.is.pdf
--   Lög nr. 3/2006 um ársreikninga, með síðari breytingum (m.a. lög nr. 73/2016 um innleiðingu tilskipunar 2013/34/ESB) (Alþingi — Lagasafn)
--     https://www.althingi.is/lagas/nuna/2006003.html
--   Reglugerð nr. 696/2019 um framsetningu og innihald ársreikninga og samstæðureikninga (Atvinnuvega- og nýsköpunarráðuneytið)
--     https://island.is/reglugerdir/nr/0696-2019
--   Lög nr. 38/2001 um vexti og verðtryggingu (Alþingi — Lagasafn)
--     https://www.althingi.is/lagas/nuna/2001038.html
--   Lög nr. 8/2015 um greiðsludrátt í verslunarviðskiptum, sem leiðir í íslenskan rétt tilskipun 2011/7/ESB samkvæmt ákvörðun sameiginlegu EES-nefndarinnar nr. 55/2012 (Alþingi — Lagasafn)
--     https://www.althingi.is/lagas/154c/2015008.html
--   Reglugerð nr. 44/2019 um rafræna reikninga vegna opinberra samninga (Fjármála- og efnahagsráðuneytið)
--     https://island.is/reglugerdir/nr/0044-2019
--   Tollalög nr. 88/2005 (Alþingi — Lagasafn)
--     https://www.althingi.is/lagas/nuna/2005088.html
--   Vefskil virðisaukaskatts — þjónustuvefur Skattsins þar sem virðisaukaskattsskýrslu er skilað (Skatturinn — Ríkisskattstjóri)
--     https://www.skatturinn.is/atvinnurekstur/virdisaukaskattur/
--   Iceland — country profile: Fjársýsla ríkisins as the Icelandic Peppol Authority (OpenPeppol)
--     https://peppol.org/learn-more/country-profiles/iceland/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('IS', 'Ísland', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '58e811d5ed6c05bb7008102ef8e005337fb9f59b19fc0b46d6fd2cce34923fac', '[{"key":"vsklog","title":"Lög nr. 50/1988 um virðisaukaskatt, með síðari breytingum","publisher":"Alþingi — Lagasafn","url":"https://www.althingi.is/lagas/nuna/1988050.html","consulted_on":"2026-09-25","kind":"law"},{"key":"reglugerd667-1995","title":"Reglugerð nr. 667/1995 um framtal og skil á virðisaukaskatti","publisher":"Fjármála- og efnahagsráðuneytið","url":"https://www.reglugerd.is/reglugerdir/eftir-raduneytum/fjarmala--og-efnahagsraduneyti/nr/667-1995","consulted_on":"2026-09-25","kind":"regulation"},{"key":"reglugerd50-1993","title":"Reglugerð nr. 50/1993 um bókhald og tekjuskráningu virðisaukaskattsskyldra aðila","publisher":"Fjármála- og efnahagsráðuneytið","url":"https://www.reglugerd.is/reglugerdir/eftir-raduneytum/fjarmala--og-efnahagsraduneyti/nr/50-1993","consulted_on":"2026-09-25","kind":"regulation"},{"key":"rsk-1001","title":"RSK 10.01 — Virðisaukaskattsskýrsla (eyðublað)","publisher":"Skatturinn — Ríkisskattstjóri","url":"https://www.skatturinn.is/media/rsk10/rsk_1001.is.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"rsk-1119","title":"Leiðbeiningar um virðisaukaskatt, 19. útgáfa 2022","publisher":"Skatturinn — Ríkisskattstjóri","url":"https://www.skatturinn.is/media/baeklingar/rsk_1119.is.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"arsreikningalog","title":"Lög nr. 3/2006 um ársreikninga, með síðari breytingum (m.a. lög nr. 73/2016 um innleiðingu tilskipunar 2013/34/ESB)","publisher":"Alþingi — Lagasafn","url":"https://www.althingi.is/lagas/nuna/2006003.html","consulted_on":"2026-09-25","kind":"law"},{"key":"reglugerd696-2019","title":"Reglugerð nr. 696/2019 um framsetningu og innihald ársreikninga og samstæðureikninga","publisher":"Atvinnuvega- og nýsköpunarráðuneytið","url":"https://island.is/reglugerdir/nr/0696-2019","consulted_on":"2026-09-25","kind":"regulation"},{"key":"vextir38-2001","title":"Lög nr. 38/2001 um vexti og verðtryggingu","publisher":"Alþingi — Lagasafn","url":"https://www.althingi.is/lagas/nuna/2001038.html","consulted_on":"2026-09-25","kind":"law"},{"key":"greidsludrattur8-2015","title":"Lög nr. 8/2015 um greiðsludrátt í verslunarviðskiptum, sem leiðir í íslenskan rétt tilskipun 2011/7/ESB samkvæmt ákvörðun sameiginlegu EES-nefndarinnar nr. 55/2012","publisher":"Alþingi — Lagasafn","url":"https://www.althingi.is/lagas/154c/2015008.html","consulted_on":"2026-09-25","kind":"law"},{"key":"reglugerd44-2019","title":"Reglugerð nr. 44/2019 um rafræna reikninga vegna opinberra samninga","publisher":"Fjármála- og efnahagsráðuneytið","url":"https://island.is/reglugerdir/nr/0044-2019","consulted_on":"2026-09-25","kind":"regulation"},{"key":"tollalog88-2005","title":"Tollalög nr. 88/2005","publisher":"Alþingi — Lagasafn","url":"https://www.althingi.is/lagas/nuna/2005088.html","consulted_on":"2026-09-25","kind":"law"},{"key":"skatturinn-vefskil","title":"Vefskil virðisaukaskatts — þjónustuvefur Skattsins þar sem virðisaukaskattsskýrslu er skilað","publisher":"Skatturinn — Ríkisskattstjóri","url":"https://www.skatturinn.is/atvinnurekstur/virdisaukaskattur/","consulted_on":"2026-09-25","kind":"portal"},{"key":"peppol-authority-is","title":"Iceland — country profile: Fjársýsla ríkisins as the Icelandic Peppol Authority","publisher":"OpenPeppol","url":"https://peppol.org/learn-more/country-profiles/iceland/","consulted_on":"2026-09-25","kind":"guidance"}]'::jsonb)
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
  ('IS', 'default', 'Kontóáætlun byggð á 3. og 5. gr. reglugerðar nr. 696/2019', '{}'::jsonb, true, 'companies', array['IS-696-BS', 'IS-696-IS']::text[], null, 'Ísland mælir ekki fyrir um lögbundna kontóáætlun. Lög nr. 3/2006 um ársreikninga, 6. gr., fela ráðherra að setja reglur um framsetningu ársreikninga; reglugerð nr. 696/2019 (sem innleiðir tilskipun 2013/34/ESB um ársreikninga, sbr. lög nr. 73/2016) mælir fyrir um lágmarksuppsetningu efnahagsreiknings (3. gr.) og rekstrarreiknings (5. gr.), en tekur enga afstöðu til kontónúmera. Kontóáætlun þessa pakka er frumsamin fyrir hann og fylgir beint uppbyggingu 3. og 5. gr. reglugerðarinnar — sjá README.md.', 'reglugerd696-2019')
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
  ('IS', 'default', '1010', 'Þróunarkostnaður', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('IS', 'default', '1020', 'Viðskiptavild', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('IS', 'default', '1030', 'Hugverkaréttindi og leyfi', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('IS', 'default', '1040', 'Fyrirframgreiðslur vegna óefnislegra eigna', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('IS', 'default', '1100', 'Lóðir og lendur', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('IS', 'default', '1110', 'Byggingar og mannvirki', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('IS', 'default', '1120', 'Vélar og tæki', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('IS', 'default', '1130', 'Áhöld og innréttingar', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('IS', 'default', '1140', 'Bifreiðar', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('IS', 'default', '1150', 'Tölvubúnaður og hugbúnaður', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('IS', 'default', '1160', 'Skrifstofubúnaður', '{}'::jsonb, 'asset_fixed', false, null, 110),
  ('IS', 'default', '1170', 'Fyrirframgreiðslur og eignir í smíðum', '{}'::jsonb, 'asset_fixed', false, null, 120),
  ('IS', 'default', '1300', 'Eignarhlutir í dótturfélögum', '{}'::jsonb, 'asset_non_current', false, null, 130),
  ('IS', 'default', '1310', 'Eignarhlutir í öðrum félögum', '{}'::jsonb, 'asset_non_current', false, null, 140),
  ('IS', 'default', '1320', 'Langtímakröfur á tengda aðila', '{}'::jsonb, 'asset_non_current', false, null, 150),
  ('IS', 'default', '1330', 'Aðrar langtímakröfur', '{}'::jsonb, 'asset_non_current', false, null, 160),
  ('IS', 'default', '1400', 'Hráefnisbirgðir', '{}'::jsonb, 'asset_current', false, null, 170),
  ('IS', 'default', '1410', 'Vörur í vinnslu', '{}'::jsonb, 'asset_current', false, null, 180),
  ('IS', 'default', '1420', 'Fullunnar vörur', '{}'::jsonb, 'asset_current', false, null, 190),
  ('IS', 'default', '1430', 'Vörubirgðir til endursölu', '{}'::jsonb, 'asset_current', false, null, 200),
  ('IS', 'default', '1440', 'Niðurfærsla vörubirgða', '{}'::jsonb, 'asset_current', false, null, 210),
  ('IS', 'default', '1500', 'Viðskiptakröfur', '{}'::jsonb, 'asset_receivable', true, null, 220),
  ('IS', 'default', '1501', 'Kröfur á tengda aðila', '{}'::jsonb, 'asset_receivable', true, null, 230),
  ('IS', 'default', '1502', 'Ógreiddar vaxtatekjur', '{}'::jsonb, 'asset_current', false, null, 240),
  ('IS', 'default', '1510', 'Aðrar skammtímakröfur', '{}'::jsonb, 'asset_current', false, null, 250),
  ('IS', 'default', '1600', 'Innskattur, 24% þrep', '{}'::jsonb, 'asset_current', false, null, 260),
  ('IS', 'default', '1601', 'Innskattur, 11% þrep', '{}'::jsonb, 'asset_current', false, null, 270),
  ('IS', 'default', '1602', 'Innskattur af innflutningi vöru', '{}'::jsonb, 'asset_current', false, null, 280),
  ('IS', 'default', '1603', 'Innskattur af aðkeyptri þjónustu erlendis frá', '{}'::jsonb, 'asset_current', false, null, 290),
  ('IS', 'default', '1690', 'Uppgjör virðisaukaskatts — inneign', '{}'::jsonb, 'asset_current', true, null, 300),
  ('IS', 'default', '1700', 'Fyrirfram greiddur kostnaður', '{}'::jsonb, 'asset_prepayments', false, null, 310),
  ('IS', 'default', '1710', 'Fyrirfram greidd tryggingariðgjöld', '{}'::jsonb, 'asset_prepayments', false, null, 320),
  ('IS', 'default', '1720', 'Fyrirfram greidd leiga', '{}'::jsonb, 'asset_prepayments', false, null, 330),
  ('IS', 'default', '1800', 'Markaðsverðbréf, hlutabréf', '{}'::jsonb, 'asset_current', false, null, 340),
  ('IS', 'default', '1810', 'Markaðsverðbréf, skuldabréf', '{}'::jsonb, 'asset_current', false, null, 350),
  ('IS', 'default', '1900', 'Sjóður', '{}'::jsonb, 'asset_cash', false, null, 360),
  ('IS', 'default', '1910', 'Bankareikningur', '{}'::jsonb, 'asset_cash', false, null, 370),
  ('IS', 'default', '1920', 'Gjaldeyrisreikningur', '{}'::jsonb, 'asset_cash', false, null, 380),
  ('IS', 'default', '2000', 'Hlutafé', '{}'::jsonb, 'equity', false, null, 390),
  ('IS', 'default', '2010', 'Yfirverðsreikningur hlutafjár', '{}'::jsonb, 'equity', false, null, 400),
  ('IS', 'default', '2020', 'Lögbundinn varasjóður', '{}'::jsonb, 'equity', false, null, 410),
  ('IS', 'default', '2030', 'Endurmatsreikningur', '{}'::jsonb, 'equity', false, null, 420),
  ('IS', 'default', '2090', 'Óráðstafað eigið fé', '{}'::jsonb, 'equity_retained', false, null, 430),
  ('IS', 'default', '2200', 'Langtímalán hjá lánastofnunum', '{}'::jsonb, 'liability_non_current', false, null, 440),
  ('IS', 'default', '2210', 'Skuldir við tengda aðila, langtíma', '{}'::jsonb, 'liability_non_current', false, null, 450),
  ('IS', 'default', '2220', 'Skuldabréfaútgáfa', '{}'::jsonb, 'liability_non_current', false, null, 460),
  ('IS', 'default', '2230', 'Skuldbinding vegna lífeyris', '{}'::jsonb, 'liability_non_current', false, null, 470),
  ('IS', 'default', '2400', 'Næsta árs afborgun langtímalána', '{}'::jsonb, 'liability_current', false, null, 480),
  ('IS', 'default', '2410', 'Viðskiptaskuldir', '{}'::jsonb, 'liability_payable', true, null, 490),
  ('IS', 'default', '2411', 'Skuldir við tengda aðila, skammtíma', '{}'::jsonb, 'liability_payable', true, null, 500),
  ('IS', 'default', '2420', 'Ógreiddir vextir', '{}'::jsonb, 'liability_current', false, null, 510),
  ('IS', 'default', '2500', 'Útskattur, 24% þrep', '{}'::jsonb, 'liability_current', false, null, 520),
  ('IS', 'default', '2501', 'Útskattur, 11% þrep', '{}'::jsonb, 'liability_current', false, null, 530),
  ('IS', 'default', '2502', 'Útskattur af aðkeyptri þjónustu erlendis frá', '{}'::jsonb, 'liability_current', false, null, 540),
  ('IS', 'default', '2590', 'Uppgjör virðisaukaskatts — til greiðslu', '{}'::jsonb, 'liability_current', true, null, 550),
  ('IS', 'default', '2600', 'Ógreidd laun', '{}'::jsonb, 'liability_current', false, null, 560),
  ('IS', 'default', '2610', 'Staðgreiðsla og lífeyrissjóðsiðgjöld', '{}'::jsonb, 'liability_current', false, null, 570),
  ('IS', 'default', '2620', 'Tryggingagjald', '{}'::jsonb, 'liability_current', false, null, 580),
  ('IS', 'default', '2630', 'Orlofsskuldbinding', '{}'::jsonb, 'liability_current', false, null, 590),
  ('IS', 'default', '2650', 'Milligreiðslureikningur', '{}'::jsonb, 'liability_current', false, null, 600),
  ('IS', 'default', '2660', 'Ógreiddur tekjuskattur', '{}'::jsonb, 'liability_current', false, null, 610),
  ('IS', 'default', '2700', 'Fyrirframinnheimtar tekjur', '{}'::jsonb, 'liability_current', false, null, 620),
  ('IS', 'default', '2710', 'Fyrirframinnheimtar leigutekjur', '{}'::jsonb, 'liability_current', false, null, 630),
  ('IS', 'default', '3000', 'Sala, 24% þrep', '{}'::jsonb, 'income', false, null, 640),
  ('IS', 'default', '3010', 'Sala, 11% þrep', '{}'::jsonb, 'income', false, null, 650),
  ('IS', 'default', '3020', 'Útflutningur vöru', '{}'::jsonb, 'income', false, null, 660),
  ('IS', 'default', '3030', 'Þjónustusala til erlendra fyrirtækja', '{}'::jsonb, 'income', false, null, 670),
  ('IS', 'default', '3040', 'Undanþegin velta — fasteignaleiga', '{}'::jsonb, 'income', false, null, 680),
  ('IS', 'default', '3050', 'Undanþegin velta — önnur', '{}'::jsonb, 'income', false, null, 690),
  ('IS', 'default', '3090', 'Afsláttur og endursendar vörur', '{}'::jsonb, 'income', false, null, 700),
  ('IS', 'default', '4000', 'Vörunotkun/kostnaðarverð seldra vara, 24% þrep', '{}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('IS', 'default', '4010', 'Vörunotkun, 11% þrep', '{}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('IS', 'default', '4020', 'Vörunotkun af innfluttri vöru', '{}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('IS', 'default', '4030', 'Flutningskostnaður vegna vara', '{}'::jsonb, 'expense_direct_cost', false, null, 740),
  ('IS', 'default', '4090', 'Afsláttur birgja', '{}'::jsonb, 'expense_direct_cost', false, null, 750),
  ('IS', 'default', '5000', 'Laun', '{}'::jsonb, 'expense', false, null, 760),
  ('IS', 'default', '5010', 'Yfirvinnulaun', '{}'::jsonb, 'expense', false, null, 770),
  ('IS', 'default', '5020', 'Verktakalaun', '{}'::jsonb, 'expense', false, null, 780),
  ('IS', 'default', '5100', 'Launatengd gjöld', '{}'::jsonb, 'expense', false, null, 790),
  ('IS', 'default', '5110', 'Lífeyrissjóðsiðgjöld launagreiðanda', '{}'::jsonb, 'expense', false, null, 800),
  ('IS', 'default', '5120', 'Tryggingagjald', '{}'::jsonb, 'expense', false, null, 810),
  ('IS', 'default', '6000', 'Húsnæðiskostnaður', '{}'::jsonb, 'expense', false, null, 820),
  ('IS', 'default', '6010', 'Hiti og rafmagn', '{}'::jsonb, 'expense', false, null, 830),
  ('IS', 'default', '6020', 'Ræsting', '{}'::jsonb, 'expense', false, null, 840),
  ('IS', 'default', '6100', 'Rekstrarvörur og skrifstofukostnaður', '{}'::jsonb, 'expense', false, null, 850),
  ('IS', 'default', '6110', 'Prentkostnaður', '{}'::jsonb, 'expense', false, null, 860),
  ('IS', 'default', '6200', 'Sími og netþjónusta', '{}'::jsonb, 'expense', false, null, 870),
  ('IS', 'default', '6210', 'Póstburðargjöld', '{}'::jsonb, 'expense', false, null, 880),
  ('IS', 'default', '6300', 'Auglýsingar og markaðsstarf', '{}'::jsonb, 'expense', false, null, 890),
  ('IS', 'default', '6310', 'Vefsíðurekstur', '{}'::jsonb, 'expense', false, null, 900),
  ('IS', 'default', '6400', 'Bókhalds- og endurskoðunarkostnaður', '{}'::jsonb, 'expense', false, null, 910),
  ('IS', 'default', '6410', 'Lögfræðiþjónusta', '{}'::jsonb, 'expense', false, null, 920),
  ('IS', 'default', '6500', 'Ferða- og risnukostnaður', '{}'::jsonb, 'expense', false, null, 930),
  ('IS', 'default', '6510', 'Námskeið og fræðsla', '{}'::jsonb, 'expense', false, null, 940),
  ('IS', 'default', '6600', 'Aðkeypt sérfræðiþjónusta erlendis frá', '{}'::jsonb, 'expense', false, null, 950),
  ('IS', 'default', '6700', 'Tryggingar', '{}'::jsonb, 'expense', false, null, 960),
  ('IS', 'default', '6710', 'Bifreiðakostnaður', '{}'::jsonb, 'expense', false, null, 970),
  ('IS', 'default', '6720', 'Viðhald véla og tækja', '{}'::jsonb, 'expense', false, null, 980),
  ('IS', 'default', '6800', 'Félagsgjöld og styrkir', '{}'::jsonb, 'expense', false, null, 990),
  ('IS', 'default', '6900', 'Annar rekstrarkostnaður', '{}'::jsonb, 'expense', false, null, 1000),
  ('IS', 'default', '7000', 'Afskriftir óefnislegra eigna', '{}'::jsonb, 'expense_depreciation', false, null, 1010),
  ('IS', 'default', '7010', 'Afskriftir bygginga og mannvirkja', '{}'::jsonb, 'expense_depreciation', false, null, 1020),
  ('IS', 'default', '7020', 'Afskriftir véla og tækja', '{}'::jsonb, 'expense_depreciation', false, null, 1030),
  ('IS', 'default', '7030', 'Afskriftir bifreiða', '{}'::jsonb, 'expense_depreciation', false, null, 1040),
  ('IS', 'default', '8000', 'Vaxtatekjur', '{}'::jsonb, 'income_other', false, null, 1050),
  ('IS', 'default', '8010', 'Arðstekjur', '{}'::jsonb, 'income_other', false, null, 1060),
  ('IS', 'default', '8100', 'Vaxtagjöld', '{}'::jsonb, 'expense', false, null, 1070),
  ('IS', 'default', '8110', 'Bankakostnaður', '{}'::jsonb, 'expense', false, null, 1080),
  ('IS', 'default', '8200', 'Gengishagnaður', '{}'::jsonb, 'income_other', false, null, 1090),
  ('IS', 'default', '8300', 'Gengistap', '{}'::jsonb, 'expense', false, null, 1100),
  ('IS', 'default', '9000', 'Reiknaður tekjuskattur', '{}'::jsonb, 'expense', false, null, 1110),
  ('IS', 'default', '9010', 'Tekjuskattur fyrri ára', '{}'::jsonb, 'expense', false, null, 1120),
  ('IS', 'default', '9900', 'Jöfnunarmismunur', '{}'::jsonb, 'expense', false, null, 1130)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('IS', 'BNK', 'Banki', '{}'::jsonb, 'bank', 30),
  ('IS', 'CSH', 'Sjóður', '{}'::jsonb, 'cash', 40),
  ('IS', 'GEN', 'Ýmsar færslur', '{}'::jsonb, 'general', 50),
  ('IS', 'OPN', 'Opnunarfærsla', '{}'::jsonb, 'opening', 60),
  ('IS', 'PUR', 'Innkaupabók', '{}'::jsonb, 'purchase', 20),
  ('IS', 'SAL', 'Sölubók', '{}'::jsonb, 'sales', 10)
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
  ('IS', 'IS-P-11', 'Innkaup, lægra skatthlutfall 11%', '{}'::jsonb, null, 'percent', 11, 'purchase', 'domestic', date '2015-01-01', null, '15. og 16. gr. laga nr. 50/1988.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-P-24', 'Innkaup, almennt skatthlutfall 24%', '{}'::jsonb, null, 'percent', 24, 'purchase', 'domestic', date '2015-01-01', null, '15. og 16. gr. laga nr. 50/1988 — virðisaukaskattur sem skattskyldum aðila er reiknaður af aðföngum sem eingöngu varða skattskylda starfsemi hans telst til innskatts og dregst frá útskatti.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-P-24-NA', 'Innkaup fyrir undanþegna starfsemi, 24% (án innskattsréttar)', '{}'::jsonb, null, 'percent', 24, 'purchase', 'exempt', date '2015-01-01', null, '16. gr. laga nr. 50/1988 — innkaup sem eingöngu varða undanþegna starfsemi samkvæmt 2. gr. veita engan rétt til innskattsfrádráttar; skatturinn sem seljandinn lagði á reikninginn leggst þá við kaupverð þeirrar vöru eða þjónustu sem keypt var.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-P-FOREIGN-24', 'Aðkeypt þjónusta erlendis frá, virðisaukaskattur til uppgjörs 24%', '{}'::jsonb, null, 'percent', 24, 'purchase', 'foreign_services_received', date '2015-01-01', null, '35. gr. laga nr. 50/1988 — skattskyldur aðili sem kaupir virðisaukaskattsskylda þjónustu frá aðila sem hvorki hefur heimilisfesti né fasta starfsstöð hér á landi skal sjálfur standa skil á virðisaukaskatti af þjónustunni. RSK 10.01 hefur engan sérstakan reit fyrir þessa fjárhæð (ólíkt t.d. svissneska eyðublaðinu, sem hefur reit fyrir bezugsteuer): hún er því færð beint í útskatt (reit D) og, að því marki sem kaupin varða eingöngu skattskylda starfsemi kaupanda og veita fullan innskattsrétt samkvæmt 15. gr., samhliða í innskatt (reit E) — sjá leiðbeiningar Skattsins, rsk_1119, bls. 9.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-P-IMPORT-24', 'Innflutningur vöru, innskattur af innflutningsskatti 24%', '{}'::jsonb, null, 'percent', 24, 'purchase', 'import', date '2015-01-01', null, 'Virðisaukaskattur af innflutningi er lagður á og innheimtur af tollyfirvöldum samkvæmt tollalögum nr. 88/2005 og 8.–10. gr. laga nr. 50/1988 um skattverð, við tollafgreiðslu og óháð virðisaukaskattsskýrslu tímabilsins (sjá leiðbeiningar Skattsins, rsk_1119, bls. 37). 4. mgr. 15. gr. sömu laga heimilar að telja þennan skatt til innskatts. RSK 10.01 hefur því engan reit fyrir grunn eða fjárhæð innflutningsskatts sjálfs — aðeins hinn frádráttarbæri innskattur birtist, í reit E.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-S-11', 'Sala, lægra skatthlutfall 11%', '{}'::jsonb, null, 'percent', 11, 'sale', 'domestic', date '2015-01-01', null, '2. mgr. 14. gr. laga nr. 50/1988 — 11% skatthlutfall gildir m.a. um útleigu hótel- og gistiherbergja, farþegaflutninga (aðra en almenningssamgöngur, sem eru undanþegnar), þjónustu ferðaskrifstofa og ferðaskipuleggjenda, afnotagjöld hljóðvarps- og sjónvarpsstöðva, sölu dagblaða, tímarita og héraðsfréttablaða, sölu bóka og hljóðbóka, sölu á heitu vatni, rafmagni og olíu til hitunar húsa, sölu matvæla og annarra vara til manneldis, aðgangseyri að vegamannvirkjum, sölu hljómplatna og annarra sambærilegra miðla með tónlist, sölu á vörum til getnaðarvarna og margnota bleyjum, aðgang að baðhúsum, gufuböðum og heilsulindum og leiðsöguþjónustu. Núverandi hlutfall gildir frá 1. janúar 2015 (áður 7%).', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-S-24', 'Sala, almennt skatthlutfall 24%', '{}'::jsonb, null, 'percent', 24, 'sale', 'domestic', date '2015-01-01', null, '1. mgr. 14. gr. laga nr. 50/1988 — virðisaukaskattur skal vera 24% og rennur hann í ríkissjóð. Núverandi hlutfall gildir frá 1. janúar 2015 (áður 25,5%).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-S-EXEMPT', 'Fasteignaleiga (undanþegin starfsemi, án innskattsréttar)', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '1990-01-01', null, '3. mgr. 2. gr. laga nr. 50/1988 — starfsemi sem talin er upp í málsgreininni er undanþegin virðisaukaskatti, þar á meðal fasteignaleiga (leiðbeiningar Skattsins, rsk_1119, bls. 7: „Fasteignaleiga... Endurgjald fyrir ýmis fasteignatengd réttindi fellur hér undir, leigusali lætur leigutaka í té slík afnot fasteignar sinnar eða hluta hennar að viðjafnist á við raunveruleg umráð eiganda.“). Ólíkt útflutningi 12. gr. veitir þessi undanþága engan rétt til innskattsfrádráttar af aðföngum sem varða hana (16. gr.). RSK 10.01 gerir enga kröfu um að undanþegin velta sé tilgreind í skýrslunni (sjá skýringu við reit C), svo grunnfjárhæðin er bókuð en ekki tilkynnt í neinum reit.', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-S-EXPORT', 'Útflutningur vöru (undanþegin, með innskattsrétti)', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '1990-01-01', null, '1. tölul. 1. mgr. 12. gr. laga nr. 50/1988 — vara sem seld er úr landi telst ekki til skattskyldrar veltu, en réttur til innskattsfrádráttar helst óskertur af sölunni (skýr undantekning frá afhendingarreglunni, ólíkt undanþeginni starfsemi 2. gr.).', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null),
  ('IS', 'IS-S-SERVICES-EXPORT', 'Þjónustusala til erlendra atvinnufyrirtækja (undanþegin, með innskattsrétti)', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '1990-01-01', null, '2. tölul. 1. mgr. 12. gr. laga nr. 50/1988 — sala þjónustu til atvinnufyrirtækja sem hafa hvorki heimilisfesti né fasta starfsstöð hér á landi telst ekki til skattskyldrar veltu, með óskertum innskattsrétti. Meðal dæma sem tíunduð eru í leiðbeiningum Skattsins (rsk_1119, bls. 24): auglýsingaþjónusta, ráðgjafarþjónusta, verkfræðiþjónusta, lögfræðiþjónusta, bókhalds- og endurskoðunarþjónusta, fjarskiptaþjónusta og rafrænt veitt þjónusta.', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vsklog', null, null, null, null)
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
    ('IS-P-11', 'invoice', 'tax', 100, '1601', 'E', array['E']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-P-11', 'credit_note', 'tax', 100, '1601', 'E', array['E']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-P-24', 'invoice', 'tax', 100, '1600', 'E', array['E']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-P-24', 'credit_note', 'tax', 100, '1600', 'E', array['E']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-P-24-NA', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('IS-P-24-NA', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('IS-P-FOREIGN-24', 'invoice', 'tax', 100, '1603', 'E', array['E']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-P-FOREIGN-24', 'invoice', 'tax', -100, '2502', 'D', array['D']::text[], 100, 'IS-VSK-10.01', 20),
    ('IS-P-FOREIGN-24', 'credit_note', 'tax', 100, '1603', 'E', array['E']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-P-FOREIGN-24', 'credit_note', 'tax', -100, '2502', 'D', array['D']::text[], -100, 'IS-VSK-10.01', 20),
    ('IS-P-IMPORT-24', 'invoice', 'tax', 100, '1602', 'E', array['E']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-P-IMPORT-24', 'credit_note', 'tax', 100, '1602', 'E', array['E']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-S-11', 'invoice', 'base', 100, null, 'B', array['B']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-S-11', 'invoice', 'tax', 100, '2501', 'D', array['D']::text[], 100, 'IS-VSK-10.01', 20),
    ('IS-S-11', 'credit_note', 'base', 100, null, 'B', array['B']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-S-11', 'credit_note', 'tax', 100, '2501', 'D', array['D']::text[], -100, 'IS-VSK-10.01', 20),
    ('IS-S-24', 'invoice', 'base', 100, null, 'A', array['A']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-S-24', 'invoice', 'tax', 100, '2500', 'D', array['D']::text[], 100, 'IS-VSK-10.01', 20),
    ('IS-S-24', 'credit_note', 'base', 100, null, 'A', array['A']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-S-24', 'credit_note', 'tax', 100, '2500', 'D', array['D']::text[], -100, 'IS-VSK-10.01', 20),
    ('IS-S-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('IS-S-EXEMPT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('IS-S-EXPORT', 'invoice', 'base', 100, null, 'C', array['C']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-S-EXPORT', 'credit_note', 'base', 100, null, 'C', array['C']::text[], -100, 'IS-VSK-10.01', 10),
    ('IS-S-SERVICES-EXPORT', 'invoice', 'base', 100, null, 'C', array['C']::text[], 100, 'IS-VSK-10.01', 10),
    ('IS-S-SERVICES-EXPORT', 'credit_note', 'base', 100, null, 'C', array['C']::text[], -100, 'IS-VSK-10.01', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'IS' and t.code = v.tax_code
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
  ('IS', 'IS-VSK-10.01', 'Virðisaukaskattsskýrsla (RSK 10.01)', array['month', 'bimonth', 'year']::declaration_period[], 'bimonth'::declaration_period, date '2015-01-01', null, '1. mgr. 24. gr. laga nr. 50/1988 og reglugerð nr. 667/1995 — almenna reglan er sú að hvert uppgjörstímabil virðisaukaskatts sé tveir mánuðir (janúar/febrúar, mars/apríl, maí/júní, júlí/ágúst, september/október, nóvember/desember), sem gildir um alla skattskylda aðila nema þeir falli undir sérstakar undantekningar. Þeir sem stunda umfangsmikinn rekstur geta fengið mánaðarlegt uppgjörstímabil (rg. 667/1995, um mánaðarskil) og þeir sem selja skattskylda vöru eða þjónustu fyrir 4.000.000 kr. eða minna á ári geta óskað eftir árlegu uppgjöri (24. gr., um ársskil). Bændur og nytjaskógræktendur hafa sérreglur með uppgjöri tvisvar á ári (1. september og 1. mars), sem þessi pakki modelar ekki — sjá README.md.', true,null, null, null, null, null, null)
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
  ('IS', 'IS-VSK-10.01', 'A', 'base', 'Skattskyld velta án VSK í 24% þrepi', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur A — skattskyld velta samkvæmt 24% skatthlutfalli 14. gr. laga nr. 50/1988.', 'rsk-1001'),
  ('IS', 'IS-VSK-10.01', 'B', 'base', 'Skattskyld velta án VSK í 11% þrepi', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur B — skattskyld velta samkvæmt 11% skatthlutfalli 14. gr. laga nr. 50/1988.', 'rsk-1001'),
  ('IS', 'IS-VSK-10.01', 'C', 'base', 'Undanþegin velta, svo sem útflutningur', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur C — hér er aðeins átt við útflutning og aðra sölu sem ber núllskatt samkvæmt 12. gr. laga nr. 50/1988. Ekki er heimilt að færa í þennan reit upplýsingar um undanþegna starfsemi samkvæmt 2. gr., skaðabætur eða aðra hreina styrki (leiðbeiningar Skattsins, rsk_1119, bls. 35).', 'rsk-1119'),
  ('IS', 'IS-VSK-10.01', 'D', 'tax', 'Útskattur', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur D — samtals útskattur á uppgjörstímabilinu.', 'rsk-1001'),
  ('IS', 'IS-VSK-10.01', 'E', 'tax', 'Innskattur', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur E — samtals innskattur á uppgjörstímabilinu.', 'rsk-1001'),
  ('IS', 'IS-VSK-10.01', 'F', 'total', 'Álagning (D − E)', '{}'::jsonb, 60, null, array['D']::text[], array['E']::text[], null, null, false, false, null, 'RSK 10.01, reitur F — mismunur útskatts og innskatts samkvæmt reitum D og E.', 'rsk-1001'),
  ('IS', 'IS-VSK-10.01', 'G', 'base', 'Álag á vangreiddan virðisaukaskatt', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur G — álag samkvæmt 28. gr. laga nr. 50/1988, sem leggst á ef greitt er eftir gjalddaga. Fjárhæðin er reiknuð af vefskilakerfi Skattsins út frá greiðsludegi, sem er utan þess sem þessi pakki heldur utan um, svo ekkert bókast í þennan reit — sjá README.md.', 'rsk-1001'),
  ('IS', 'IS-VSK-10.01', 'H', 'total', 'Samtala — til greiðslu eða inneign', '{}'::jsonb, 80, null, array['F', 'G']::text[], '{}'::text[], null, null, false, false, null, 'RSK 10.01, reitur H — sé samtalan jákvæð er hún til greiðslu, sé hún neikvæð er hún inneign (leiðbeiningar Skattsins, rsk_1119, bls. 35).', 'rsk-1119')
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
  ('IS-696-BS', 'IS', 'default', 'Efnahagsreikningur samkvæmt 3. gr. reglugerðar nr. 696/2019', 'balance_sheet', 'IS-696', date '1970-01-01', null, 'Reglugerð nr. 696/2019 um framsetningu og innihald ársreikninga og samstæðureikninga, 3. gr., sett samkvæmt heimild í 6. gr. laga nr. 3/2006 um ársreikninga, sem innleiðir tilskipun 2013/34/ESB (sbr. lög nr. 73/2016). 3. gr. skiptir efnahagsreikningnum í fastafjármuni (a. óefnislegar eignir, b. efnislegar eignir, c. fjáreignir) og veltufjármuni (a. birgðir, b. skammtímakröfur, c. verðbréf, d. handbært fé) á eignahlið, og eigið fé, langtímaskuldir og skammtímaskuldir á hinni.', 'reglugerd696-2019'),
  ('IS-696-IS', 'IS', 'default', 'Rekstrarreikningur samkvæmt 5. gr. reglugerðar nr. 696/2019 (eftir eðli kostnaðar)', 'income_statement', 'IS-696', date '1970-01-01', null, 'Reglugerð nr. 696/2019, 5. gr. — rekstrarreikningur eftir eðli kostnaðar, liðir 1 til 12: hrein velta, aðrar rekstrartekjur, kostnaðarverð seldra vara, laun og launatengd gjöld, önnur rekstrargjöld, afskriftir og virðisrýrnun, fjármunatekjur og fjármagnsgjöld, og hagnaður eða tap ársins. Þessi pakki velur þessa framsetningu; 4. gr., 2. mgr. leyfir framsetningu eftir starfsemisflokkun kostnaðar ef hún þykir gefa gleggri mynd, sem þessi pakki notar ekki.', 'reglugerd696-2019')
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
  ('IS-696-BS', 'EIGNIR', null, 'Eignir samtals', '{}'::jsonb, 10, 1, true, array['AV', 'UV']::text[], '{}'::text[], null, null, null),
  ('IS-696-BS', 'AV', 'EIGNIR', 'Fastafjármunir', '{}'::jsonb, 20, 1, true, array['AV.1', 'AV.2', 'AV.3']::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 1. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'AV.1', 'AV', 'Óefnislegar eignir', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 1. tölul., a-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'AV.2', 'AV', 'Efnislegar eignir', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 1. tölul., b-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'AV.3', 'AV', 'Fjáreignir', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 1. tölul., c-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'UV', 'EIGNIR', 'Veltufjármunir', '{}'::jsonb, 60, 1, true, array['UV.1', 'UV.2', 'UV.3', 'UV.4']::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 2. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'UV.1', 'UV', 'Birgðir', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 2. tölul., a-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'UV.2', 'UV', 'Skammtímakröfur og fyrirfram greiddur kostnaður', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 2. tölul., b-liður — meðal annars sundurliðunar á virðisaukaskattskröfum og fyrirfram greiddum kostnaði, sem þessi kontóáætlun hefur ekki sérstaka reikningaröð fyrir og raðar því hér.', 'reglugerd696-2019'),
  ('IS-696-BS', 'UV.3', 'UV', 'Verðbréf', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 2. tölul., c-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'UV.4', 'UV', 'Handbært fé', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 2. tölul., d-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'SKEF', null, 'Skuldir og eigið fé samtals', '{}'::jsonb, 110, 1, true, array['EK', 'LS', 'SS']::text[], '{}'::text[], null, null, null),
  ('IS-696-BS', 'EK', 'SKEF', 'Eigið fé', '{}'::jsonb, 120, 1, true, array['EK.1', 'EK.2', 'EK.3']::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 3. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'EK.1', 'EK', 'Hlutafé og yfirverðsreikningur hlutafjár', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 3. tölul., a-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'EK.2', 'EK', 'Lögbundnir sjóðir', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 3. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'EK.3', 'EK', 'Óráðstafað eigið fé', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 3. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'LS', 'SKEF', 'Langtímaskuldir', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 4. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'SS', 'SKEF', 'Skammtímaskuldir', '{}'::jsonb, 170, 1, true, array['SS.1', 'SS.2', 'SS.3', 'SS.4']::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 5. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'SS.1', 'SS', 'Næsta árs afborgun langtímalána', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 5. tölul., a-liður', 'reglugerd696-2019'),
  ('IS-696-BS', 'SS.2', 'SS', 'Viðskiptaskuldir', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 5. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'SS.3', 'SS', 'Virðisaukaskattur og aðrar opinberar skuldir', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 5. tölul.', 'reglugerd696-2019'),
  ('IS-696-BS', 'SS.4', 'SS', 'Fyrirframinnheimtar tekjur', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 3. gr., 5. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'NE', null, 'Hrein velta', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 1. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'KSV', null, 'Kostnaðarverð seldra vara', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 3. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'LAUN', null, 'Laun og launatengd gjöld', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 4. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'ONNUR', null, 'Önnur rekstrargjöld', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 5. tölul. — jöfnunarmismunur (9900) er tæknilegur reikningur án eigin liðar og er felldur hér inn.', 'reglugerd696-2019'),
  ('IS-696-IS', 'AFSKR', null, 'Afskriftir og virðisrýrnun', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 6. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'FE', null, 'Fjármunatekjur', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 7. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'FA', null, 'Fjármagnsgjöld', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 7. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'SKATT', null, 'Reiknaður tekjuskattur', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 10. tölul.', 'reglugerd696-2019'),
  ('IS-696-IS', 'JG', null, 'Hagnaður eða tap ársins', '{}'::jsonb, 90, 1, true, array['NE', 'FE']::text[], array['KSV', 'LAUN', 'ONNUR', 'AFSKR', 'FA', 'SKATT']::text[], null, 'Reglugerð nr. 696/2019, 5. gr., 12. tölul.', 'reglugerd696-2019')
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
    ('IS-696-BS', 'AV.1', 10, 'code_range', '1010', '1099', null, 'any'),
    ('IS-696-BS', 'AV.2', 10, 'code_range', '1100', '1299', null, 'any'),
    ('IS-696-BS', 'AV.3', 10, 'code_range', '1300', '1399', null, 'any'),
    ('IS-696-BS', 'UV.1', 10, 'code_range', '1400', '1499', null, 'any'),
    ('IS-696-BS', 'UV.2', 10, 'code_range', '1500', '1799', null, 'any'),
    ('IS-696-BS', 'UV.3', 10, 'code_range', '1800', '1899', null, 'any'),
    ('IS-696-BS', 'UV.4', 10, 'code_range', '1900', '1999', null, 'any'),
    ('IS-696-BS', 'EK.1', 10, 'code_range', '2000', '2019', null, 'any'),
    ('IS-696-BS', 'EK.2', 10, 'code_range', '2020', '2089', null, 'any'),
    ('IS-696-BS', 'EK.3', 10, 'code_range', '2090', '2099', null, 'any'),
    ('IS-696-BS', 'LS', 10, 'code_range', '2200', '2399', null, 'any'),
    ('IS-696-BS', 'SS.1', 10, 'code_range', '2400', '2409', null, 'any'),
    ('IS-696-BS', 'SS.2', 10, 'code_range', '2410', '2499', null, 'any'),
    ('IS-696-BS', 'SS.3', 10, 'code_range', '2500', '2699', null, 'any'),
    ('IS-696-BS', 'SS.4', 10, 'code_range', '2700', '2799', null, 'any'),
    ('IS-696-IS', 'NE', 10, 'code_range', '3000', '3099', null, 'any'),
    ('IS-696-IS', 'KSV', 10, 'code_range', '4000', '4099', null, 'any'),
    ('IS-696-IS', 'LAUN', 10, 'code_range', '5000', '5199', null, 'any'),
    ('IS-696-IS', 'ONNUR', 10, 'code_range', '6000', '6999', null, 'any'),
    ('IS-696-IS', 'ONNUR', 20, 'code_range', '9900', '9999', null, 'any'),
    ('IS-696-IS', 'AFSKR', 10, 'code_range', '7000', '7099', null, 'any'),
    ('IS-696-IS', 'FE', 10, 'code_range', '8000', '8099', null, 'any'),
    ('IS-696-IS', 'FE', 20, 'code_range', '8200', '8299', null, 'any'),
    ('IS-696-IS', 'FA', 10, 'code_range', '8100', '8199', null, 'any'),
    ('IS-696-IS', 'FA', 20, 'code_range', '8300', '8399', null, 'any'),
    ('IS-696-IS', 'SKATT', 10, 'code_range', '9000', '9099', null, 'any')
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
  ('IS', 'Ísland', '{}'::jsonb, array['is']::text[], 'ISK', '1500', '2410', '2650', '9900', '2090', '3000', '4000', '1910', '1900', 'SAL', 'PUR', 'GEN', 'is', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '8200', '8300', null, null, null, null, '2590', '1690', null, 'bimonth'::declaration_period)
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
  number_format                 = '{CODE}-{NNNN}',
  legal_payment_days            = 0,
  late_payment_reference        = 'Þegar greiðslufrestur er ekki umsaminn er dráttarvaxta krafist skv. 3. mgr. 5. gr. laga nr. 38/2001 um vexti og verðtryggingu: dráttarvextir reiknast frá og með þeim degi þegar liðinn er mánuður frá því að kröfuhafi sannanlega krafði skuldara um greiðslu, en ekki frá útgáfudegi reiknings sjálfkrafa. Vextirnir eru samtala grunns dráttarvaxta Seðlabanka Íslands og átta hundraðshluta álags í viðskiptum milli fyrirtækja eða fyrirtækis og opinbers aðila (3. mgr. 6. gr. sömu laga). Sé greiðslufrestur umsaminn má hann almennt ekki vera lengri en 60 almanaksdagar (1. mgr. 3. gr. laga nr. 8/2015, sem leiðir tilskipun 2011/7/ESB um sein greiðsluskil í viðskiptum inn í íslenskan rétt á grundvelli EES-samningsins).',
  numbering_legal_reference     = '1. mgr. 20. gr. laga nr. 50/1988 — sölureikninga ber að forprenta og tölusetja í samfelldri töluröð; nánar útfært í reglugerð nr. 50/1993, sem gerir hvorki kröfu um að númeraröðin hefjist að nýju ár hvert né um fjölda eyðublaða sem keypt eða notuð eru hverju sinni.',
  numbering_source_key          = 'reglugerd50-1993',
  payment_terms_legal_reference = '3. mgr. 5. gr. laga nr. 38/2001 — sé greiðslufrestur ekki umsaminn ber ekki að reikna hann sjálfkrafa út frá útgáfudegi reiknings.',
  payment_terms_source_key      = 'vextir38-2001',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Afhendingarreglan (13. gr. laga nr. 50/1988): meginreglan er sú að afhending hins selda ráði því til hvaða uppgjörstímabils salan telst. Undantekning: hafi sölureikningur verið gefinn út vegna sölunnar áður en afhending fer fram ræður útgáfudagur reikningsins. Innborganir teljast til skattskyldrar veltu við móttöku.',
  tax_point_source_key          = 'rsk-1119',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Þann 25. september 2026 skyldar engin almenn löggjöf fyrirtæki til að skiptast á rafrænum reikningum sín á milli (B2B). Reglugerð nr. 44/2019 um rafræna reikninga vegna opinberra samninga skyldar aðeins kaupendur í opinberum innkaupum (4. gr.) — ríkisaðila frá 18. apríl 2019, sveitarfélög og opinber fyrirtæki frá 18. apríl 2020 — til að taka á móti og vinna úr rafrænum reikningum sem uppfylla evrópska staðalinn EN 16931, útfærðan með tækniforskriftinni TS236:2017. Reglugerðin leggur enga skyldu á seljanda til að gefa út slíkan reikning; í reynd verður birgir opinbers aðila þó að nota Peppol-netið til að fá reikninga sína samþykkta, og Fjársýsla ríkisins er tilnefndur Peppol-yfirvald (Peppol Authority) Íslands.',
  einvoice_source_key           = 'reglugerd44-2019',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053', 'csv']::text[],
  payment_formats               = array['pain.001', 'csv']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'IS';
