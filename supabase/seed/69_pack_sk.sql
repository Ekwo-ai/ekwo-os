-- Ekwo OS — Slovensko: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sk at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build sk`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Zákon č. 222/2004 Z. z. o dani z pridanej hodnoty, úplné znenie k 1.1.2025 (v znení zákona č. 278/2024 Z. z. a zákona č. 102/2024 Z. z.) (Finančné riaditeľstvo SR)
--     https://www.financnasprava.sk/_img/pfsedit/Dokumenty_PFS/Zverejnovanie_dok/Sprievodca/Sprievodca_danami/2025/2025.01.28_zakon_DPH.pdf
--   Zákon č. 278/2024 Z. z., ktorým sa mení a dopĺňa zákon č. 222/2004 Z. z. o dani z pridanej hodnoty — nové sadzby dane 23 %, 19 % a 5 % od 1.1.2025 (konsolidačný balíček) (Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex))
--     https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2024/278/
--   Zákon č. 102/2024 Z. z., ktorým sa mení a dopĺňa zákon č. 222/2004 Z. z. o dani z pridanej hodnoty — nový spôsob registrácie, prahy obratu a § 84a (samozdanenie pri dovoze tovaru) od 1.1.2025 (Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex))
--     https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2024/102/
--   Poučenie na vyplnenie daňového priznania k dani z pridanej hodnoty (tlačivo MF/007833/2025-731, „DPHv25“), platné od 1.7.2025 (Finančné riaditeľstvo SR)
--     https://www.podnikajte.sk/assets/prilohy-v-clankoch/2025-05-29-vzor-danove-priznanie/2025-05-29-danove-priznanie-dph-poucenie.pdf
--   9/DPH/2025/IM — Najčastejšie otázky a odpovede k eFaktúre (Finančné riaditeľstvo SR)
--     https://www.financnasprava.sk/_img/pfsedit/Dokumenty_PFS/Podnikatelia/Dan_z_pridanej_hodnoty/efaktura/2026/2026.09.11_FAQ_eFaktura.pdf
--   Opatrenie Ministerstva financií Slovenskej republiky zo 16. decembra 2002 č. 23054/2002-92, ktorým sa ustanovujú podrobnosti o postupoch účtovania a rámcovej účtovej osnove pre podnikateľov účtujúcich v sústave podvojného účtovníctva, úplné znenie (Ministerstvo financií Slovenskej republiky)
--     https://www.mfsr.sk/files/sk/dane-cla-uctovnictvo/uctovnictvo-audit/uctovnictvo/legislativa-sr/opatrenia-oblasti-uctovnictva/uctovnictvo-podnikatelov/podvojne-uctovnictvo/postupy-uctovania/Uplne_znenie_23054_2002_92_PU1.pdf
--   Zákon č. 431/2002 Z. z. o účtovníctve, v znení neskorších predpisov (naposledy zákon č. 105/2024 Z. z.) (Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex))
--     https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2002/431/
--   Súvaha Úč POD 1-01 (súčasť tlačiva UZPODv14, opatrenie MF SR č. MF/18009/2014-74) (Finančné riaditeľstvo SR)
--     https://pfseform.financnasprava.sk/Formulare/VzoryTlacivEdit/UVPOD104-11-print-edit-save.pdf
--   Výkaz ziskov a strát Úč POD 2-01 (súčasť tlačiva UZPODv14 — Účtovná závierka podnikateľov v podvojnom účtovníctve, opatrenie MF SR č. MF/18009/2014-74, platné pre účtovné obdobia od 31.12.2014) (Finančné riaditeľstvo SR)
--     https://pfseform.financnasprava.sk/Formulare/VzoryTlaciv/UZPODv14.pdf
--   Zákon č. 513/1991 Zb. Obchodný zákonník, § 340a, § 369 a § 369c, v znení zákona č. 9/2013 Z. z. (transpozícia smernice 2011/7/EÚ) (Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex))
--     https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/1991/513/
--   Nariadenie vlády Slovenskej republiky č. 21/2013 Z. z. z 23. januára 2013, ktorým sa vykonávajú niektoré ustanovenia Obchodného zákonníka — § 1 (sadzba úrokov z omeškania) a § 2 (paušálna náhrada 40 eur) (Vláda Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex))
--     https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2013/21/
--   Elektronické služby Finančnej správy SR — podávanie daňového priznania k DPH a kontrolného výkazu (Finančné riaditeľstvo SR)
--     https://www.financnasprava.sk/sk/elektronicke-sluzby
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
  ('SK', 'Slovensko', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, '82a8c551cc85f3c3940d48ef789defd159373765ff3582930c82c47e6faa7308', '[{"key":"zakon-dph","title":"Zákon č. 222/2004 Z. z. o dani z pridanej hodnoty, úplné znenie k 1.1.2025 (v znení zákona č. 278/2024 Z. z. a zákona č. 102/2024 Z. z.)","publisher":"Finančné riaditeľstvo SR","url":"https://www.financnasprava.sk/_img/pfsedit/Dokumenty_PFS/Zverejnovanie_dok/Sprievodca/Sprievodca_danami/2025/2025.01.28_zakon_DPH.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"novela-278-2024","title":"Zákon č. 278/2024 Z. z., ktorým sa mení a dopĺňa zákon č. 222/2004 Z. z. o dani z pridanej hodnoty — nové sadzby dane 23 %, 19 % a 5 % od 1.1.2025 (konsolidačný balíček)","publisher":"Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex)","url":"https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2024/278/","consulted_on":"2026-09-25","kind":"law"},{"key":"novela-102-2024","title":"Zákon č. 102/2024 Z. z., ktorým sa mení a dopĺňa zákon č. 222/2004 Z. z. o dani z pridanej hodnoty — nový spôsob registrácie, prahy obratu a § 84a (samozdanenie pri dovoze tovaru) od 1.1.2025","publisher":"Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex)","url":"https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2024/102/","consulted_on":"2026-09-25","kind":"law"},{"key":"tlacivo-dph","title":"Poučenie na vyplnenie daňového priznania k dani z pridanej hodnoty (tlačivo MF/007833/2025-731, „DPHv25“), platné od 1.7.2025","publisher":"Finančné riaditeľstvo SR","url":"https://www.podnikajte.sk/assets/prilohy-v-clankoch/2025-05-29-vzor-danove-priznanie/2025-05-29-danove-priznanie-dph-poucenie.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"efaktura-faq","title":"9/DPH/2025/IM — Najčastejšie otázky a odpovede k eFaktúre","publisher":"Finančné riaditeľstvo SR","url":"https://www.financnasprava.sk/_img/pfsedit/Dokumenty_PFS/Podnikatelia/Dan_z_pridanej_hodnoty/efaktura/2026/2026.09.11_FAQ_eFaktura.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"opatrenie-uctova-osnova","title":"Opatrenie Ministerstva financií Slovenskej republiky zo 16. decembra 2002 č. 23054/2002-92, ktorým sa ustanovujú podrobnosti o postupoch účtovania a rámcovej účtovej osnove pre podnikateľov účtujúcich v sústave podvojného účtovníctva, úplné znenie","publisher":"Ministerstvo financií Slovenskej republiky","url":"https://www.mfsr.sk/files/sk/dane-cla-uctovnictvo/uctovnictvo-audit/uctovnictvo/legislativa-sr/opatrenia-oblasti-uctovnictva/uctovnictvo-podnikatelov/podvojne-uctovnictvo/postupy-uctovania/Uplne_znenie_23054_2002_92_PU1.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"zakon-uctovnictvo","title":"Zákon č. 431/2002 Z. z. o účtovníctve, v znení neskorších predpisov (naposledy zákon č. 105/2024 Z. z.)","publisher":"Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex)","url":"https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2002/431/","consulted_on":"2026-09-25","kind":"law"},{"key":"tlacivo-suvaha","title":"Súvaha Úč POD 1-01 (súčasť tlačiva UZPODv14, opatrenie MF SR č. MF/18009/2014-74)","publisher":"Finančné riaditeľstvo SR","url":"https://pfseform.financnasprava.sk/Formulare/VzoryTlacivEdit/UVPOD104-11-print-edit-save.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"tlacivo-vzas","title":"Výkaz ziskov a strát Úč POD 2-01 (súčasť tlačiva UZPODv14 — Účtovná závierka podnikateľov v podvojnom účtovníctve, opatrenie MF SR č. MF/18009/2014-74, platné pre účtovné obdobia od 31.12.2014)","publisher":"Finančné riaditeľstvo SR","url":"https://pfseform.financnasprava.sk/Formulare/VzoryTlaciv/UZPODv14.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"obchodny-zakonnik","title":"Zákon č. 513/1991 Zb. Obchodný zákonník, § 340a, § 369 a § 369c, v znení zákona č. 9/2013 Z. z. (transpozícia smernice 2011/7/EÚ)","publisher":"Kancelária Národnej rady Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex)","url":"https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/1991/513/","consulted_on":"2026-09-25","kind":"law"},{"key":"nariadenie-21-2013","title":"Nariadenie vlády Slovenskej republiky č. 21/2013 Z. z. z 23. januára 2013, ktorým sa vykonávajú niektoré ustanovenia Obchodného zákonníka — § 1 (sadzba úrokov z omeškania) a § 2 (paušálna náhrada 40 eur)","publisher":"Vláda Slovenskej republiky — Elektronická zbierka zákonov (Slov-Lex)","url":"https://www.slov-lex.sk/ezbierky/pravne-predpisy/SK/ZZ/2013/21/","consulted_on":"2026-09-25","kind":"regulation"},{"key":"portal-financnasprava","title":"Elektronické služby Finančnej správy SR — podávanie daňového priznania k DPH a kontrolného výkazu","publisher":"Finančné riaditeľstvo SR","url":"https://www.financnasprava.sk/sk/elektronicke-sluzby","consulted_on":"2026-09-25","kind":"portal"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('SK', 'default', 'Rámcová účtová osnova pre podnikateľov', '{}'::jsonb, true, 'companies', array['SK-UCT-SUVAHA', 'SK-UCT-VZAS']::text[], null, 'Opatrenie MF SR č. 23054/2002-92 v znení neskorších predpisov, § 1 ods. 3 a Príloha č. 1 — ustanovuje rámcovú účtovú osnovu ako záväzný zoznam syntetických účtov (číslo aj slovné označenie), z ktorej si účtovná jednotka podľa § 3 opatrenia zostavuje vlastný účtový rozvrh s analytickými účtami. Na rozdiel od poľského alebo rakúskeho balíka tohto repozitára ide o skutočne záväzné trojmiestne syntetické čísla (napr. 311 Odberatelia, 343 Daň z pridanej hodnoty, 411 Základné imanie), nie o číslovanie vytvorené pre tento balík. Tento pack preberá reálne slovenské syntetické účty tried 0 až 6 v rozsahu, ktorý pokrýva bežnú agendu malej alebo strednej spoločnosti; triedy 7 (uzávierkové a podsúvahové účty) a 8/9 (vnútropodnikové účtovníctvo, § 6 ods. 1 opatrenia — obsah je u každej účtovnej jednotky voľný) nie sú prevzaté, pretože jadro tohto formátu nečíta uzávierkové účty priamo a analytika vnútropodnikového účtovníctva nemá záväznú štruktúru, ktorú by bolo možné prepísať.', 'opatrenie-uctova-osnova')
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
  ('SK', 'default', '012', 'Aktivované náklady na vývoj', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('SK', 'default', '013', 'Softvér', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('SK', 'default', '014', 'Oceniteľné práva', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('SK', 'default', '015', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('SK', 'default', '019', 'Ostatný dlhodobý nehmotný majetok', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('SK', 'default', '021', 'Stavby', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('SK', 'default', '022', 'Samostatné hnuteľné veci a súbory hnuteľných vecí', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('SK', 'default', '023', 'Pestovateľské celky trvalých porastov', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('SK', 'default', '025', 'Základné stádo a ťažné zvieratá', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('SK', 'default', '026', 'Iný dlhodobý hmotný majetok', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('SK', 'default', '031', 'Pozemky', '{}'::jsonb, 'asset_fixed', false, null, 110),
  ('SK', 'default', '032', 'Umelecké diela a zbierky', '{}'::jsonb, 'asset_fixed', false, null, 120),
  ('SK', 'default', '041', 'Obstaranie dlhodobého nehmotného majetku', '{}'::jsonb, 'asset_fixed', false, null, 130),
  ('SK', 'default', '042', 'Obstaranie dlhodobého hmotného majetku', '{}'::jsonb, 'asset_fixed', false, null, 140),
  ('SK', 'default', '052', 'Poskytnuté preddavky na dlhodobý hmotný majetok', '{}'::jsonb, 'asset_fixed', false, null, 150),
  ('SK', 'default', '061', 'Podielové cenné papiere a podiely v dcérskej účtovnej jednotke', '{}'::jsonb, 'asset_non_current', false, null, 160),
  ('SK', 'default', '062', 'Podielové cenné papiere a podiely v spoločnosti s podstatným vplyvom', '{}'::jsonb, 'asset_non_current', false, null, 170),
  ('SK', 'default', '065', 'Dlhopisy a ostatné dlhodobé cenné papiere', '{}'::jsonb, 'asset_non_current', false, null, 180),
  ('SK', 'default', '066', 'Pôžičky prepojeným účtovným jednotkám', '{}'::jsonb, 'asset_non_current', false, null, 190),
  ('SK', 'default', '067', 'Ostatné pôžičky', '{}'::jsonb, 'asset_non_current', false, null, 200),
  ('SK', 'default', '069', 'Ostatné realizovateľné cenné papiere a podiely', '{}'::jsonb, 'asset_non_current', false, null, 210),
  ('SK', 'default', '071', 'Oprávky k aktivovaným nákladom na vývoj', '{}'::jsonb, 'asset_fixed', false, null, 220),
  ('SK', 'default', '072', 'Oprávky ku goodwillu', '{}'::jsonb, 'asset_fixed', false, null, 230),
  ('SK', 'default', '073', 'Oprávky k softvéru', '{}'::jsonb, 'asset_fixed', false, null, 240),
  ('SK', 'default', '079', 'Oprávky k ostatnému dlhodobému nehmotnému majetku', '{}'::jsonb, 'asset_fixed', false, null, 250),
  ('SK', 'default', '081', 'Oprávky k stavbám', '{}'::jsonb, 'asset_fixed', false, null, 260),
  ('SK', 'default', '082', 'Oprávky k samostatným hnuteľným veciam a súborom hnuteľných vecí', '{}'::jsonb, 'asset_fixed', false, null, 270),
  ('SK', 'default', '083', 'Oprávky k pestovateľským celkom trvalých porastov', '{}'::jsonb, 'asset_fixed', false, null, 280),
  ('SK', 'default', '085', 'Oprávky k základnému stádu a ťažným zvieratám', '{}'::jsonb, 'asset_fixed', false, null, 290),
  ('SK', 'default', '089', 'Oprávky k inému dlhodobému hmotnému majetku', '{}'::jsonb, 'asset_fixed', false, null, 300),
  ('SK', 'default', '112', 'Materiál na sklade', '{}'::jsonb, 'asset_current', false, null, 310),
  ('SK', 'default', '121', 'Nedokončená výroba', '{}'::jsonb, 'asset_current', false, null, 320),
  ('SK', 'default', '122', 'Polotovary vlastnej výroby', '{}'::jsonb, 'asset_current', false, null, 330),
  ('SK', 'default', '123', 'Výrobky', '{}'::jsonb, 'asset_current', false, null, 340),
  ('SK', 'default', '124', 'Zvieratá', '{}'::jsonb, 'asset_current', false, null, 350),
  ('SK', 'default', '132', 'Tovar na sklade a v predajniach', '{}'::jsonb, 'asset_current', false, null, 360),
  ('SK', 'default', '133', 'Tovar na ceste', '{}'::jsonb, 'asset_current', false, null, 370),
  ('SK', 'default', '211', 'Pokladnica', '{}'::jsonb, 'asset_cash', false, null, 380),
  ('SK', 'default', '213', 'Ceniny', '{}'::jsonb, 'asset_cash', false, null, 390),
  ('SK', 'default', '221', 'Bankové účty', '{}'::jsonb, 'asset_cash', false, null, 400),
  ('SK', 'default', '251', 'Majetkové cenné papiere na obchodovanie', '{}'::jsonb, 'asset_current', false, null, 410),
  ('SK', 'default', '252', 'Vlastné akcie a vlastné obchodné podiely', '{}'::jsonb, 'asset_current', false, null, 420),
  ('SK', 'default', '253', 'Dlhové cenné papiere na obchodovanie', '{}'::jsonb, 'asset_current', false, null, 430),
  ('SK', 'default', '255', 'Vlastné dlhopisy', '{}'::jsonb, 'asset_current', false, null, 440),
  ('SK', 'default', '256', 'Dlhové cenné papiere so splatnosťou do jedného roka držané do splatnosti', '{}'::jsonb, 'asset_current', false, null, 450),
  ('SK', 'default', '261', 'Peniaze na ceste', '{}'::jsonb, 'asset_cash', false, null, 460),
  ('SK', 'default', '311', 'Odberatelia', '{}'::jsonb, 'asset_receivable', true, null, 470),
  ('SK', 'default', '313', 'Pohľadávky za eskontované cenné papiere', '{}'::jsonb, 'asset_current', false, null, 480),
  ('SK', 'default', '314', 'Poskytnuté prevádzkové preddavky', '{}'::jsonb, 'asset_current', false, null, 490),
  ('SK', 'default', '315', 'Ostatné pohľadávky', '{}'::jsonb, 'asset_current', true, null, 500),
  ('SK', 'default', '317', 'Iné pohľadávky z hlavnej činnosti', '{}'::jsonb, 'asset_current', false, null, 510),
  ('SK', 'default', '318', 'Pohľadávky voči účastníkom združenia', '{}'::jsonb, 'asset_current', false, null, 520),
  ('SK', 'default', '321', 'Dodávatelia', '{}'::jsonb, 'liability_payable', true, null, 530),
  ('SK', 'default', '324', 'Prijaté preddavky', '{}'::jsonb, 'liability_current', true, null, 540),
  ('SK', 'default', '325', 'Ostatné záväzky', '{}'::jsonb, 'liability_current', false, null, 550),
  ('SK', 'default', '331', 'Zamestnanci', '{}'::jsonb, 'liability_current', true, null, 560),
  ('SK', 'default', '333', 'Ostatné záväzky voči zamestnancom', '{}'::jsonb, 'liability_current', false, null, 570),
  ('SK', 'default', '336', 'Zúčtovanie s inštitúciami sociálneho a zdravotného poistenia', '{}'::jsonb, 'liability_current', false, null, 580),
  ('SK', 'default', '341', 'Daň z príjmov', '{}'::jsonb, 'liability_current', false, null, 590),
  ('SK', 'default', '342', 'Ostatné priame dane', '{}'::jsonb, 'liability_current', false, null, 600),
  ('SK', 'default', '343', 'Daň z pridanej hodnoty', '{}'::jsonb, 'liability_current', true, null, 610),
  ('SK', 'default', '3431', 'DPH na výstupe', '{}'::jsonb, 'liability_current', false, '343', 611),
  ('SK', 'default', '3432', 'DPH na vstupe', '{}'::jsonb, 'asset_current', false, '343', 612),
  ('SK', 'default', '345', 'Ostatné dane a poplatky', '{}'::jsonb, 'liability_current', false, null, 620),
  ('SK', 'default', '346', 'Dotácie zo štátneho rozpočtu', '{}'::jsonb, 'liability_current', false, null, 630),
  ('SK', 'default', '347', 'Ostatné dotácie', '{}'::jsonb, 'liability_current', false, null, 640),
  ('SK', 'default', '349', 'Daňové pohľadávky a záväzky', '{}'::jsonb, 'liability_current', false, null, 650),
  ('SK', 'default', '379', 'Iné záväzky', '{}'::jsonb, 'liability_current', true, null, 660),
  ('SK', 'default', '381', 'Náklady budúcich období', '{}'::jsonb, 'asset_prepayments', false, null, 670),
  ('SK', 'default', '384', 'Výnosy budúcich období', '{}'::jsonb, 'liability_current', false, null, 680),
  ('SK', 'default', '411', 'Základné imanie', '{}'::jsonb, 'equity', false, null, 690),
  ('SK', 'default', '413', 'Ostatné kapitálové fondy', '{}'::jsonb, 'equity', false, null, 700),
  ('SK', 'default', '421', 'Zákonný rezervný fond', '{}'::jsonb, 'equity', false, null, 710),
  ('SK', 'default', '428', 'Nerozdelený zisk minulých rokov', '{}'::jsonb, 'equity_retained', false, null, 720),
  ('SK', 'default', '429', 'Neuhradená strata minulých rokov', '{}'::jsonb, 'equity_retained', false, null, 730),
  ('SK', 'default', '431', 'Výsledok hospodárenia v schvaľovacom konaní', '{}'::jsonb, 'equity_retained', false, null, 740),
  ('SK', 'default', '451', 'Rezervy zákonné', '{}'::jsonb, 'liability_non_current', false, null, 750),
  ('SK', 'default', '459', 'Ostatné rezervy', '{}'::jsonb, 'liability_current', false, null, 760),
  ('SK', 'default', '461', 'Bankové úvery dlhodobé', '{}'::jsonb, 'liability_non_current', true, null, 770),
  ('SK', 'default', '479', 'Ostatné dlhodobé záväzky', '{}'::jsonb, 'liability_non_current', true, null, 780),
  ('SK', 'default', '481', 'Odložený daňový záväzok', '{}'::jsonb, 'liability_non_current', false, null, 790),
  ('SK', 'default', '501', 'Spotreba materiálu', '{}'::jsonb, 'expense', false, null, 800),
  ('SK', 'default', '502', 'Spotreba energie', '{}'::jsonb, 'expense', false, null, 810),
  ('SK', 'default', '504', 'Predaný tovar', '{}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('SK', 'default', '511', 'Opravy a udržiavanie', '{}'::jsonb, 'expense', false, null, 830),
  ('SK', 'default', '512', 'Cestovné', '{}'::jsonb, 'expense', false, null, 840),
  ('SK', 'default', '513', 'Náklady na reprezentáciu', '{}'::jsonb, 'expense', false, null, 850),
  ('SK', 'default', '518', 'Ostatné služby', '{}'::jsonb, 'expense', false, null, 860),
  ('SK', 'default', '521', 'Mzdové náklady', '{}'::jsonb, 'expense', false, null, 870),
  ('SK', 'default', '524', 'Zákonné sociálne poistenie', '{}'::jsonb, 'expense', false, null, 880),
  ('SK', 'default', '527', 'Zákonné sociálne náklady', '{}'::jsonb, 'expense', false, null, 890),
  ('SK', 'default', '531', 'Daň z motorových vozidiel', '{}'::jsonb, 'expense', false, null, 900),
  ('SK', 'default', '532', 'Daň z nehnuteľností', '{}'::jsonb, 'expense', false, null, 910),
  ('SK', 'default', '538', 'Ostatné dane a poplatky', '{}'::jsonb, 'expense', false, null, 920),
  ('SK', 'default', '541', 'Zostatková cena predaného dlhodobého majetku', '{}'::jsonb, 'expense', false, null, 930),
  ('SK', 'default', '544', 'Zmluvné pokuty, penále a úroky z omeškania', '{}'::jsonb, 'expense', false, null, 940),
  ('SK', 'default', '546', 'Tvorba opravnej položky k pohľadávkam', '{}'::jsonb, 'expense', false, null, 950),
  ('SK', 'default', '548', 'Ostatné náklady na hospodársku činnosť', '{}'::jsonb, 'expense', false, null, 960),
  ('SK', 'default', '551', 'Odpisy dlhodobého nehmotného a hmotného majetku', '{}'::jsonb, 'expense_depreciation', false, null, 970),
  ('SK', 'default', '562', 'Úroky', '{}'::jsonb, 'expense', false, null, 980),
  ('SK', 'default', '563', 'Kurzové straty', '{}'::jsonb, 'expense', false, null, 990),
  ('SK', 'default', '568', 'Ostatné finančné náklady', '{}'::jsonb, 'expense', false, null, 1000),
  ('SK', 'default', '591', 'Daň z príjmov z bežnej činnosti — splatná', '{}'::jsonb, 'expense', false, null, 1010),
  ('SK', 'default', '601', 'Tržby za vlastné výrobky', '{}'::jsonb, 'income', false, null, 1020),
  ('SK', 'default', '602', 'Tržby z predaja služieb', '{}'::jsonb, 'income', false, null, 1030),
  ('SK', 'default', '604', 'Tržby za tovar', '{}'::jsonb, 'income', false, null, 1040),
  ('SK', 'default', '644', 'Zmluvné pokuty, penále a úroky z omeškania', '{}'::jsonb, 'income_other', false, null, 1050),
  ('SK', 'default', '648', 'Ostatné výnosy z hospodárskej činnosti', '{}'::jsonb, 'income_other', false, null, 1060),
  ('SK', 'default', '662', 'Úroky', '{}'::jsonb, 'income_other', false, null, 1070),
  ('SK', 'default', '663', 'Kurzové zisky', '{}'::jsonb, 'income_other', false, null, 1080),
  ('SK', 'default', '668', 'Ostatné finančné výnosy', '{}'::jsonb, 'income_other', false, null, 1090)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SK', 'BANK', 'Bankové výpisy', '{}'::jsonb, 'bank', 30),
  ('SK', 'FP', 'Faktúry prijaté', '{}'::jsonb, 'purchase', 20),
  ('SK', 'FV', 'Faktúry vydané', '{}'::jsonb, 'sales', 10),
  ('SK', 'IUD', 'Interné účtovné doklady', '{}'::jsonb, 'general', 50),
  ('SK', 'POK', 'Pokladničné doklady', '{}'::jsonb, 'cash', 40),
  ('SK', 'PZS', 'Začiatočný stav', '{}'::jsonb, 'opening', 60)
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
  ('SK', 'SK-P-19', 'DPH 19 % — odpočítateľná daň, tuzemský nákup', '{}'::jsonb, 'Riadok 18 (odpočítateľná daň pri zníženej sadzbe § 27 ods. 2).', 'percent', 19, 'purchase', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 49 ods. 1 a ods. 2 písm. a), vo výške sadzby podľa § 27 ods. 2.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-23', 'DPH 23 % — odpočítateľná daň, tuzemský nákup', '{}'::jsonb, 'Nákup tovaru alebo služby od tuzemského platiteľa, základná sadzba, plný nárok na odpočet. Riadok 19 (odpočítateľná daň pri základnej sadzbe).', 'percent', 23, 'purchase', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 49 ods. 1 a ods. 2 písm. a) — platiteľ môže odpočítať daň, ktorú voči nemu uplatnil iný platiteľ za tovar alebo službu dodanú v tuzemsku, ak ju použije na svoje zdaniteľné dodania.', 'S', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-5', 'DPH 5 % — odpočítateľná daň, tuzemský nákup', '{}'::jsonb, 'Riadok 18a (odpočítateľná daň pri zníženej sadzbe § 27 ods. 3).', 'percent', 5, 'purchase', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 49 ods. 1 a ods. 2 písm. a), vo výške sadzby podľa § 27 ods. 3.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-DOVOZ-23', 'Dovoz tovaru z tretieho štátu 23 % — daň zaplatená colnému orgánu', '{}'::jsonb, 'Bežný prípad dovozu (platiteľ nemá štatút schváleného hospodárskeho subjektu, samozdanenie podľa § 84a sa neuplatňuje): daň vyrubí a vyberie colný úrad, platiteľ si ju odpočíta po zaplatení. Riadok 23 (odpočítateľná daň zaplatená pri dovoze, základná sadzba).', 'percent', 23, 'purchase', 'import', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 21 — daňová povinnosť pri dovoze tovaru vzniká prepustením tovaru do voľného obehu; § 69 ods. 8 — daň platí osoba, ktorá je dlžníkom podľa colných predpisov; § 49 ods. 2 písm. d) — daň zaplatená colnému orgánu v tuzemsku pri dovoze je odpočítateľná. Samozdanenie podľa § 84a (vyžadujúce štatút schváleného hospodárskeho subjektu, riadky 11c–12e) nie je modelované — pozri README.', null, null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-IC-23', 'Nadobudnutie tovaru z iného členského štátu 23 %', '{}'::jsonb, 'Riadok 07 (základ), riadok 08 (daň z nadobudnutia), riadok 19 (odpočítanie tej istej dane v tej istej lehote).', 'percent', 23, 'purchase', 'intracom_acquisition_goods', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 11 ods. 1 a 2 — nadobudnutie tovaru v tuzemsku z iného členského štátu; § 69 ods. 6 — daň platí osoba, ktorá tovar nadobudne podľa § 11 a § 11a; § 49 ods. 2 písm. c) — táto daň je súčasne odpočítateľná.', 'K', 'VATEX-EU-IC', 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-OSLOBODENE', 'Nákup oslobodenej dodávky', '{}'::jsonb, 'Nákup od dodávateľa, ktorého dodávka je oslobodená bez nároku na odpočet (napríklad poistenie): žiadna daň na faktúre, nič na odpočítanie, žiadny riadok priznania.', 'percent', 0, 'purchase', 'exempt', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 49 ods. 1 — bez dane uplatnenej dodávateľom (tu oslobodenej podľa § 37, poisťovacia činnosť) nie je čo odpočítať ani kam priznať.', null, null, 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-POHOSTENIE', 'Nedeliteľná daň — pohostenie a zábava', '{}'::jsonb, 'Nákup tovaru alebo služby na účely pohostenia a zábavy (napríklad obchodná večera s klientom): daň nie je odpočítateľná vôbec, zostáva súčasťou obstarávacej ceny a nevstupuje do žiadneho riadku priznania.', 'percent', 23, 'purchase', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 49 ods. 7 písm. a) — platiteľ nemôže odpočítať daň pri kúpe tovarov a služieb na účely pohostenia a zábavy. Ide o úplné vylúčenie, nie o pomerné krátenie ako pri osobných automobiloch v iných členských štátoch — takéto osobitné krátenie sa v zákone nenašlo, pozri README.', 'S', null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-RC-STAVBY-23', 'Prijaté stavebné práce — prenesenie daňovej povinnosti 23 %', '{}'::jsonb, 'Riadok 09b (základ), riadok 10b (daň, ktorú platí príjemca), riadok 19 (odpočítanie tej istej dane).', 'percent', 23, 'purchase', 'domestic_reverse_charge', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 69 ods. 12 písm. j) — príjemca stavebných prác zaradených do sekcie F je povinný platiť daň; § 49 ods. 2 písm. b) — táto daň je súčasne odpočítateľná, ak sú splnené záznamy podľa § 70.', 'AE', 'VATEX-EU-AE', 150, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-SLUZBA-EU-23', 'Služba od osoby z iného členského štátu 23 %', '{}'::jsonb, 'Všeobecné pravidlo B2B (§ 15 ods. 1): miesto dodania je v tuzemsku, príjemca si daň sám vyrubí a odpočíta. Riadok 09b (základ), riadok 10b (daň), riadok 19 (odpočítanie).', 'percent', 23, 'purchase', 'intracom_acquisition_services', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 69 ods. 3 — zdaniteľná osoba je povinná platiť daň pri službe dodanej zahraničnou osobou z iného členského štátu, ak je miesto dodania služby podľa § 15 ods. 1 v tuzemsku; § 49 ods. 2 písm. b) — daň je súčasne odpočítateľná.', 'K', 'VATEX-EU-IC', 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-P-SLUZBA-MIMO-EU-23', 'Služba od osoby z tretieho štátu 23 %', '{}'::jsonb, 'Rovnaké všeobecné pravidlo B2B, dodávateľ mimo Únie: zákon nerozlišuje dodávateľa z iného členského štátu od dodávateľa z tretieho štátu, obe idú do rovnakých riadkov 09b/10b/19.', 'percent', 23, 'purchase', 'foreign_services_received', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 69 ods. 3 — zdaniteľná osoba je povinná platiť daň aj pri službe dodanej zahraničnou osobou z tretieho štátu, ak je miesto dodania podľa § 15 ods. 1 v tuzemsku. Faktúra dodávateľa z tretieho štátu nepodlieha smernici 2006/112/ES, preto bez kategórie.', null, null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-19', 'DPH 19 % — znížená sadzba, tuzemsko', '{}'::jsonb, 'Znížená sadzba podľa § 27 ods. 2 a prílohy č. 7 bod 1 / č. 7a bod 1 — okrem iného základné potraviny nezahrnuté do 5 % pásma, elektrina, reštauračné a stravovacie služby (bez alkoholu nad 0,5 %). Riadok 01 (základ), riadok 02 (daň).', 'percent', 19, 'sale', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 27 ods. 2 — znížená sadzba dane 19 % sa uplatňuje na tovary uvedené v prílohe č. 7 bode 1 a na služby uvedené v prílohe č. 7a bode 1, s účinnosťou od 1.1.2025.', 'S', null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-23', 'DPH 23 % — základná sadzba, tuzemsko', '{}'::jsonb, 'Základná sadzba na dodanie tovaru a služby v tuzemsku. Riadok 03 (základ), riadok 04 (daň).', 'percent', 23, 'sale', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 27 ods. 1 — základná sadzba dane na tovary a služby je 23 % zo základu dane, s účinnosťou od 1.1.2025 (zákon č. 278/2024 Z. z.).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-5', 'DPH 5 % — druhá znížená sadzba, tuzemsko', '{}'::jsonb, 'Znížená sadzba podľa § 27 ods. 3 a prílohy č. 7 body 2 a 3 / č. 7a bod 2 — okrem iného čerstvé potraviny, lieky, knihy, ubytovacie služby. Riadok 01a (základ), riadok 02a (daň).', 'percent', 5, 'sale', 'domestic', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 27 ods. 3 — znížená sadzba dane 5 % sa uplatňuje na tovary uvedené v prílohe č. 7 bodoch 2 a 3 a na služby uvedené v prílohe č. 7a bode 2, s účinnosťou od 1.1.2025.', 'S', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-EXEMPT-NAJOM', 'Nájom nebytových priestorov — oslobodený bez nároku na odpočet', '{}'::jsonb, 'Príklad oslobodenej dodávky bez nároku na odpočet: nájom nebytových (komerčných) priestorov. Riadok 13 (súčet oslobodených dodaní podľa § 28 až § 43, § 46, § 47).', 'percent', 0, 'sale', 'exempt', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 38 ods. 3 — oslobodený od dane je nájom nehnuteľnosti alebo jej časti, okrem nájmu v ubytovacích zariadeniach, nájmu priestorov a miest na parkovanie vozidiel, nájmu bezpečnostných schránok a nájmu trvalo inštalovaných zariadení a strojov; § 38 ods. 5 pripúšťa voľbu zdanenia, ktorá tu nie je uplatnená.', 'E', 'VATEX-EU-135-1', 60, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-EXPORT', 'Vývoz tovaru do tretieho štátu — oslobodený', '{}'::jsonb, 'Riadok 13 (súčet oslobodených dodaní) a riadok 15 (z toho vývoz podľa § 46, § 47, § 48 ods. 8).', 'percent', 0, 'sale', 'export', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 47 ods. 1 — oslobodené od dane je dodanie tovaru, ktorý je odoslaný alebo prepravený predávajúcim alebo na jeho účet do miesta určenia na území tretieho štátu; § 47 ods. 3 vyžaduje colný doklad potvrdzujúci výstup tovaru z územia Únie.', 'G', 'VATEX-EU-G', 50, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-IC', 'Dodanie tovaru do iného členského štátu — oslobodené', '{}'::jsonb, 'Intrakomunitárna dodávka tovaru odberateľovi identifikovanému pre DPH v inom členskom štáte. Riadok 13 (súčet oslobodených dodaní) a riadok 14 (z toho dodanie podľa § 43).', 'percent', 0, 'sale', 'intracom_goods', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 43 ods. 1 — oslobodené od dane je dodanie tovaru odoslaného alebo prepraveného z tuzemska do iného členského štátu nadobúdateľovi, ktorý je zdaniteľnou osobou konajúcou v tomto postavení v inom členskom štáte a ktorý dodávateľovi oznámil svoje identifikačné číslo pre daň; § 43 ods. 10 (od 1.1.2025) odopiera oslobodenie, ak dodávateľ sám nie je platiteľom dane.', 'K', 'VATEX-EU-IC', 40, 'vat', true, array['buyer_status', 'transport_evidence']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('SK', 'SK-S-RC-STAVBY', 'Stavebné práce — prenesenie daňovej povinnosti na príjemcu', '{}'::jsonb, 'Tuzemské dodanie stavebných prác inému platiteľovi identifikovanému pre DPH: dodávateľ neúčtuje daň a faktúra nesie slovnú informáciu „prenesenie daňovej povinnosti“. Táto strana dodávateľa nemá vlastný riadok v daňovom priznaní — údaje o faktúre sa uvádzajú v kontrolnom výkaze (§ 78a), ktorý tento balík nemodeluje ako samostatnú tlačivovú štruktúru; pozri README.', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2025-01-01', null, 'Zákon č. 222/2004 Z. z., § 69 ods. 12 písm. j) — pri dodaní stavebných prác vrátane dodania stavby alebo jej časti, ktoré patria do sekcie F štatistickej klasifikácie produktov, je povinný platiť daň platiteľ, ktorému je táto stavebná práca dodaná; § 69 ods. 16 podmieňuje prenos daňovej povinnosti tým, že faktúra nesie slovnú informáciu „prenesenie daňovej povinnosti“ a obe strany majú pridelené identifikačné číslo pre daň podľa § 4, § 4b alebo § 5.', 'AE', 'VATEX-EU-AE', 70, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null)
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
    ('SK-P-19', 'invoice', 'tax', 100, '3432', '18', array['18']::text[], 100, 'SK-DPH', 10),
    ('SK-P-19', 'credit_note', 'tax', 100, '3432', '18', array['18']::text[], -100, 'SK-DPH', 10),
    ('SK-P-23', 'invoice', 'tax', 100, '3432', '19', array['19']::text[], 100, 'SK-DPH', 10),
    ('SK-P-23', 'credit_note', 'tax', 100, '3432', '19', array['19']::text[], -100, 'SK-DPH', 10),
    ('SK-P-5', 'invoice', 'tax', 100, '3432', '18a', array['18a']::text[], 100, 'SK-DPH', 10),
    ('SK-P-5', 'credit_note', 'tax', 100, '3432', '18a', array['18a']::text[], -100, 'SK-DPH', 10),
    ('SK-P-DOVOZ-23', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SK-P-DOVOZ-23', 'invoice', 'tax', 100, '3432', '23', array['23']::text[], 100, 'SK-DPH', 20),
    ('SK-P-DOVOZ-23', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('SK-P-DOVOZ-23', 'credit_note', 'tax', 100, '3432', '23', array['23']::text[], -100, 'SK-DPH', 20),
    ('SK-P-IC-23', 'invoice', 'base', 100, null, '07', array['07']::text[], 100, 'SK-DPH', 10),
    ('SK-P-IC-23', 'invoice', 'tax', 100, '3432', '19', array['19']::text[], 100, 'SK-DPH', 20),
    ('SK-P-IC-23', 'invoice', 'tax', -100, '3431', '08', array['08']::text[], 100, 'SK-DPH', 30),
    ('SK-P-IC-23', 'credit_note', 'base', 100, null, '07', array['07']::text[], -100, 'SK-DPH', 10),
    ('SK-P-IC-23', 'credit_note', 'tax', 100, '3432', '19', array['19']::text[], -100, 'SK-DPH', 20),
    ('SK-P-IC-23', 'credit_note', 'tax', -100, '3431', '08', array['08']::text[], -100, 'SK-DPH', 30),
    ('SK-P-OSLOBODENE', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SK-P-OSLOBODENE', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('SK-P-POHOSTENIE', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('SK-P-POHOSTENIE', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('SK-P-RC-STAVBY-23', 'invoice', 'base', 100, null, '09b', array['09b']::text[], 100, 'SK-DPH', 10),
    ('SK-P-RC-STAVBY-23', 'invoice', 'tax', 100, '3432', '19', array['19']::text[], 100, 'SK-DPH', 20),
    ('SK-P-RC-STAVBY-23', 'invoice', 'tax', -100, '3431', '10b', array['10b']::text[], 100, 'SK-DPH', 30),
    ('SK-P-RC-STAVBY-23', 'credit_note', 'base', 100, null, '09b', array['09b']::text[], -100, 'SK-DPH', 10),
    ('SK-P-RC-STAVBY-23', 'credit_note', 'tax', 100, '3432', '19', array['19']::text[], -100, 'SK-DPH', 20),
    ('SK-P-RC-STAVBY-23', 'credit_note', 'tax', -100, '3431', '10b', array['10b']::text[], -100, 'SK-DPH', 30),
    ('SK-P-SLUZBA-EU-23', 'invoice', 'base', 100, null, '09b', array['09b']::text[], 100, 'SK-DPH', 10),
    ('SK-P-SLUZBA-EU-23', 'invoice', 'tax', 100, '3432', '19', array['19']::text[], 100, 'SK-DPH', 20),
    ('SK-P-SLUZBA-EU-23', 'invoice', 'tax', -100, '3431', '10b', array['10b']::text[], 100, 'SK-DPH', 30),
    ('SK-P-SLUZBA-EU-23', 'credit_note', 'base', 100, null, '09b', array['09b']::text[], -100, 'SK-DPH', 10),
    ('SK-P-SLUZBA-EU-23', 'credit_note', 'tax', 100, '3432', '19', array['19']::text[], -100, 'SK-DPH', 20),
    ('SK-P-SLUZBA-EU-23', 'credit_note', 'tax', -100, '3431', '10b', array['10b']::text[], -100, 'SK-DPH', 30),
    ('SK-P-SLUZBA-MIMO-EU-23', 'invoice', 'base', 100, null, '09b', array['09b']::text[], 100, 'SK-DPH', 10),
    ('SK-P-SLUZBA-MIMO-EU-23', 'invoice', 'tax', 100, '3432', '19', array['19']::text[], 100, 'SK-DPH', 20),
    ('SK-P-SLUZBA-MIMO-EU-23', 'invoice', 'tax', -100, '3431', '10b', array['10b']::text[], 100, 'SK-DPH', 30),
    ('SK-P-SLUZBA-MIMO-EU-23', 'credit_note', 'base', 100, null, '09b', array['09b']::text[], -100, 'SK-DPH', 10),
    ('SK-P-SLUZBA-MIMO-EU-23', 'credit_note', 'tax', 100, '3432', '19', array['19']::text[], -100, 'SK-DPH', 20),
    ('SK-P-SLUZBA-MIMO-EU-23', 'credit_note', 'tax', -100, '3431', '10b', array['10b']::text[], -100, 'SK-DPH', 30),
    ('SK-S-19', 'invoice', 'base', 100, null, '01', array['01']::text[], 100, 'SK-DPH', 10),
    ('SK-S-19', 'invoice', 'tax', 100, '3431', '02', array['02']::text[], 100, 'SK-DPH', 20),
    ('SK-S-19', 'credit_note', 'base', 100, null, '01', array['01']::text[], -100, 'SK-DPH', 10),
    ('SK-S-19', 'credit_note', 'tax', 100, '3431', '02', array['02']::text[], -100, 'SK-DPH', 20),
    ('SK-S-23', 'invoice', 'base', 100, null, '03', array['03']::text[], 100, 'SK-DPH', 10),
    ('SK-S-23', 'invoice', 'tax', 100, '3431', '04', array['04']::text[], 100, 'SK-DPH', 20),
    ('SK-S-23', 'credit_note', 'base', 100, null, '03', array['03']::text[], -100, 'SK-DPH', 10),
    ('SK-S-23', 'credit_note', 'tax', 100, '3431', '04', array['04']::text[], -100, 'SK-DPH', 20),
    ('SK-S-5', 'invoice', 'base', 100, null, '01a', array['01a']::text[], 100, 'SK-DPH', 10),
    ('SK-S-5', 'invoice', 'tax', 100, '3431', '02a', array['02a']::text[], 100, 'SK-DPH', 20),
    ('SK-S-5', 'credit_note', 'base', 100, null, '01a', array['01a']::text[], -100, 'SK-DPH', 10),
    ('SK-S-5', 'credit_note', 'tax', 100, '3431', '02a', array['02a']::text[], -100, 'SK-DPH', 20),
    ('SK-S-EXEMPT-NAJOM', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'SK-DPH', 10),
    ('SK-S-EXEMPT-NAJOM', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'SK-DPH', 10),
    ('SK-S-EXPORT', 'invoice', 'base', 100, null, '13', array['13', '15']::text[], 100, 'SK-DPH', 10),
    ('SK-S-EXPORT', 'credit_note', 'base', 100, null, '13', array['13', '15']::text[], -100, 'SK-DPH', 10),
    ('SK-S-IC', 'invoice', 'base', 100, null, '13', array['13', '14']::text[], 100, 'SK-DPH', 10),
    ('SK-S-IC', 'credit_note', 'base', 100, null, '13', array['13', '14']::text[], -100, 'SK-DPH', 10),
    ('SK-S-RC-STAVBY', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SK-S-RC-STAVBY', 'credit_note', 'base', 100, null, null, null, -100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SK' and t.code = v.tax_code
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
  ('SK', 'SK-DPH', 'Daňové priznanie k dani z pridanej hodnoty (tlačivo DPHv25, MF/007833/2025-731)', array['month', 'quarter']::declaration_period[], 'month'::declaration_period, date '2025-07-01', null, 'Zákon č. 222/2004 Z. z., § 78 ods. 2 — platiteľ podáva daňové priznanie za každé zdaňovacie obdobie. Riadky citované nižšie sú riadky poučenia na vyplnenie tlačiva DPHv25, platného od 1.7.2025; toto je pracovná podmnožina formulára — chýbajúce riadky (trojstranný obchod, samozdanenie dovozu podľa § 84a, opravy základu dane, uplatnenie odpočtu pri registrácii, vrátenie dane cestujúcim, prenos nadmerného odpočtu) sú vysvetlené v README a v docs/international.md, sekcia „From Slovakia“.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Zákon č. 222/2004 Z. z., § 78 ods. 1 a 2 — daň je splatná a daňové priznanie sa podáva do 25 dní po skončení zdaňovacieho obdobia.', 'zakon-dph', null)
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
  ('SK', 'SK-DPH', '01', 'base', 'Základ dane pri sadzbe 19 % podľa § 27 ods. 2', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 01 — základ dane za zdaniteľné obchody v tuzemsku v zníženej sadzbe podľa § 27 ods. 2.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '02', 'tax', 'Daň pri sadzbe 19 % podľa § 27 ods. 2', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 02.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '01a', 'base', 'Základ dane pri sadzbe 5 % podľa § 27 ods. 3', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 01a — základ dane za zdaniteľné obchody v tuzemsku v zníženej sadzbe podľa § 27 ods. 3.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '02a', 'tax', 'Daň pri sadzbe 5 % podľa § 27 ods. 3', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 02a.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '03', 'base', 'Základ dane pri základnej sadzbe 23 %', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 03.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '04', 'tax', 'Daň pri základnej sadzbe 23 %', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 04.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '07', 'base', 'Základ dane pri nadobudnutí tovaru z iného členského štátu, základná sadzba', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 07.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '08', 'tax', 'Daň pri nadobudnutí tovaru z iného členského štátu, základná sadzba', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 08.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '09b', 'base', 'Základ dane — tovary a služby, pri ktorých daň platí príjemca plnenia, základná sadzba', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 09b — zahŕňa tuzemský prenos daňovej povinnosti podľa § 69 ods. 12 aj samozdanenie služby dodanej zahraničnou osobou podľa § 69 ods. 2 a 3, spoločne v jednom riadku.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '10b', 'tax', 'Daň — tovary a služby, pri ktorých daň platí príjemca plnenia, základná sadzba', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 10b.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '13', 'base', 'Základ dane za všetky dodané tovary a služby oslobodené od dane podľa § 28 až § 43, § 46, § 47', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 13. Súčtová informačná položka, do ktorej píše každá oslobodená dodávka tohto balíka — vrátane tej, ktorá nemá vlastný pamätný riadok 14 alebo 15 (napríklad nájom podľa § 38).', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '14', 'base', 'Z toho dodanie tovaru do iného členského štátu podľa § 43 ods. 1 a 4', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 14 — pamätná podpoložka riadku 13, slúži aj súhrnnému výkazu.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '15', 'base', 'Z toho vývoz tovaru podľa § 46, § 47, § 48 ods. 8', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 15 — pamätná podpoložka riadku 13.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '17', 'total', 'Daň celkom', '{}'::jsonb, 140, null, array['02', '02a', '04', '08', '10b']::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 17 — súčet riadkov 02, 02a, 04, 06, 06a, 08, 10, 10a, 10b, 12, 12a, 12b, 12c, 12d, 12e a 16. Tento balík deklaruje len podmnožinu riadkov (trojstranný obchod, samozdanenie dovozu, osobitné schémy nie sú modelované), preto súčet obsahuje len riadky, ktoré tento balík skutočne používa.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '18', 'tax', 'Odpočítateľná daň podľa § 49 až § 52 a § 54 až § 54d, znížená sadzba 19 %', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 18.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '18a', 'tax', 'Odpočítateľná daň podľa § 49 až § 52 a § 54 až § 54d, znížená sadzba 5 %', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 18a.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '19', 'tax', 'Odpočítateľná daň podľa § 49 až § 52 a § 54 až § 54d, základná sadzba 23 %', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 19 — všeobecný riadok odpočtu pri základnej sadzbe, do ktorého tento balík priznáva odpočet tuzemského nákupu, tuzemského prenosu daňovej povinnosti aj nadobudnutia z iného členského štátu.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '22', 'tax', 'Daň zaplatená colnému orgánu pri dovoze tovaru, znížená sadzba 19 %', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 22.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '22a', 'tax', 'Daň zaplatená colnému orgánu pri dovoze tovaru, znížená sadzba 5 %', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 22a.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '23', 'tax', 'Daň zaplatená colnému orgánu pri dovoze tovaru, základná sadzba 23 %', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Poučenie k DPHv25, riadok 23.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '32', 'total', 'Vlastná daňová povinnosť', '{}'::jsonb, 210, null, array['17']::text[], array['18', '18a', '19', '22', '22a', '23']::text[], null, null, true, false, null, 'Poučenie k DPHv25, riadok 32 — kladný výsledok (riadok 17 mínus riadky odpočtu). Vzorec tu obsahuje len riadky, ktoré tento balík deklaruje; oficiálny riadok 32 odpočítava aj riadky 24 až 31 (opravy základu dane, opravy odpočtu, odpočet pri registrácii, vrátenie dane cestujúcim), ktoré tento balík nemodeluje — pozri README.', 'tlacivo-dph'),
  ('SK', 'SK-DPH', '33', 'total', 'Nadmerný odpočet', '{}'::jsonb, 220, null, array['18', '18a', '19', '22', '22a', '23']::text[], array['17']::text[], null, null, true, false, null, 'Poučenie k DPHv25, riadok 33 — záporný výsledok, vykázaný ako kladné číslo na opačnej strane páru s riadkom 32. Rovnaké obmedzenie vzorca ako pri riadku 32.', 'tlacivo-dph')
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
  ('SK-UCT-SUVAHA', 'SK', 'default', 'Súvaha Úč POD 1-01', 'balance_sheet', 'SK-UCT', date '2015-01-01', null, 'Opatrenie MF SR č. MF/18009/2014-74 (ktorým sa mení opatrenie č. 4455/2003-92), Príloha č. 1 — vzor Súvahy Úč POD 1-01, spoločný pre malé aj veľké účtovné jednotky (voľba sa vyznačí na prvej strane tlačiva UZPODv14). Riadkovanie nižšie preberá len súčtové riadky formulára; podrobnejšie rozpisové riadky (napríklad jednotlivé zložky dlhodobého hmotného majetku) nie sú prevzaté, pretože sa nepodarilo overiť ich presné číslovanie čítaním úradného textu — pozri README.', 'tlacivo-suvaha'),
  ('SK-UCT-VZAS', 'SK', 'default', 'Výkaz ziskov a strát Úč POD 2-01', 'income_statement', 'SK-UCT', date '2015-01-01', null, 'Opatrenie MF SR č. MF/18009/2014-74, Príloha č. 1 — vzor Výkazu ziskov a strát Úč POD 2-01, v platnosti pre účtovné obdobia končiace 31.12.2014 a neskôr; oproti staršiemu vzoru (do roku 2014) neobsahuje samostatnú časť mimoriadnych výnosov a nákladov, ktorá bola zrušená pri transpozícii smernice 2013/34/EÚ. Riadky 28 (Pridaná hodnota) je vytlačená ako pamätný riadok za riadkom 27 a nevstupuje do výpočtového reťazca. Podrobné rozpisové riadky finančnej časti (napríklad výnosy z cenných papierov, riadky 30 až 38) nie sú prevzaté, pretože tento balík nemá pre ne účet v pláne — pozri README.', 'tlacivo-vzas')
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
  ('SK-UCT-SUVAHA', 'r001', null, 'SPOLU MAJETOK', '{}'::jsonb, 10, 1, true, array['r002', 'r030', 'r061']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r002', 'r001', 'A. Neobežný majetok', '{}'::jsonb, 20, 1, true, array['r003', 'r011', 'r021']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r003', 'r002', 'A.I. Dlhodobý nehmotný majetok', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r011', 'r002', 'A.II. Dlhodobý hmotný majetok', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r021', 'r002', 'A.III. Dlhodobý finančný majetok', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r030', 'r001', 'B. Obežný majetok', '{}'::jsonb, 60, 1, true, array['r031', 'r038', 'r046', 'r055']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r031', 'r030', 'B.I. Zásoby', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r038', 'r030', 'B.II. Dlhodobé pohľadávky', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r046', 'r030', 'B.III. Krátkodobé pohľadávky', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r055', 'r030', 'B.IV. Finančné účty', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r061', 'r001', 'C. Časové rozlíšenie (aktíva)', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r066', null, 'SPOLU VLASTNÉ IMANIE A ZÁVÄZKY', '{}'::jsonb, 120, 1, true, array['r067', 'r089', 'r122']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r067', 'r066', 'A. Vlastné imanie', '{}'::jsonb, 130, 1, true, array['r068', 'r073', 'r080', 'r087', 'r088']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r068', 'r067', 'A.I. Základné imanie', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r073', 'r067', 'A.II. Kapitálové fondy', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r080', 'r067', 'A.III. Fondy zo zisku', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r087', 'r067', 'Výsledok hospodárenia minulých rokov', '{}'::jsonb, 170, 1, true, array['r084', 'r085']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r084', 'r087', 'A.IV. Nerozdelený zisk minulých rokov', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r085', 'r087', 'A.V. Neuhradená strata minulých rokov', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r088', 'r067', 'Výsledok hospodárenia za účtovné obdobie po zdanení', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Nesie výsledok bežného účtovného obdobia na účte 431 (Výsledok hospodárenia v schvaľovacom konaní), keďže tento balík uzatvára rok priamo na tento účet (closing_style: result_accounts) a nemá samostatný súvahový účet na rozdelený, ešte neschválený výsledok.', 'opatrenie-uctova-osnova'),
  ('SK-UCT-SUVAHA', 'r089', 'r066', 'B. Záväzky', '{}'::jsonb, 210, 1, true, array['r090', 'r095', 'r107', 'r119']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r090', 'r089', 'B.I. Rezervy', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r095', 'r089', 'B.II. Dlhodobé záväzky', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r107', 'r089', 'B.III. Krátkodobé záväzky', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r119', 'r089', 'B.V. Bankové úvery dlhodobé', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-SUVAHA', 'r122', 'r066', 'C. Časové rozlíšenie (pasíva)', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r02', null, 'Výnosy z hospodárskej činnosti spolu', '{}'::jsonb, 10, 1, true, array['r03', 'r04', 'r05', 'r06', 'r07', 'r08', 'r09']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r03', 'r02', 'Tržby z predaja tovaru', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r04', 'r02', 'Tržby z predaja vlastných výrobkov', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r05', 'r02', 'Tržby z predaja služieb', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r06', 'r02', 'Zmeny stavu vnútroorganizačných zásob', '{}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r07', 'r02', 'Aktivácia', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r08', 'r02', 'Tržby z predaja dlhodobého nehmotného majetku, dlhodobého hmotného majetku a materiálu', '{}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r09', 'r02', 'Ostatné výnosy z hospodárskej činnosti', '{}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r10', null, 'Náklady na hospodársku činnosť spolu', '{}'::jsonb, 90, 1, true, array['r11', 'r12', 'r13', 'r14', 'r15', 'r20', 'r21', 'r24', 'r25', 'r26']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r11', 'r10', 'Náklady vynaložené na obstaranie predaného tovaru', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r12', 'r10', 'Spotreba materiálu, energie a ostatných neskladovateľných dodávok', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r13', 'r10', 'Opravné položky k zásobám', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r14', 'r10', 'Služby', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r15', 'r10', 'Osobné náklady', '{}'::jsonb, 140, 1, true, array['r16', 'r17', 'r18', 'r19']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r16', 'r15', 'Mzdové náklady', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r17', 'r15', 'Odmeny členom orgánov spoločnosti a družstva', '{}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r18', 'r15', 'Náklady na sociálne poistenie', '{}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r19', 'r15', 'Sociálne náklady', '{}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r20', 'r10', 'Dane a poplatky', '{}'::jsonb, 190, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r21', 'r10', 'Odpisy a opravné položky k dlhodobému nehmotnému majetku a dlhodobému hmotnému majetku', '{}'::jsonb, 200, 1, true, array['r22', 'r23']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r22', 'r21', 'Odpisy dlhodobého nehmotného majetku a dlhodobého hmotného majetku', '{}'::jsonb, 210, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r23', 'r21', 'Opravné položky k dlhodobému nehmotnému majetku a dlhodobému hmotnému majetku', '{}'::jsonb, 220, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r24', 'r10', 'Zostatková cena predaného dlhodobého majetku a predaného materiálu', '{}'::jsonb, 230, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r25', 'r10', 'Opravné položky k pohľadávkam', '{}'::jsonb, 240, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r26', 'r10', 'Ostatné náklady na hospodársku činnosť', '{}'::jsonb, 250, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r27', null, 'Výsledok hospodárenia z hospodárskej činnosti', '{}'::jsonb, 260, 1, true, array['r02']::text[], array['r10']::text[], null, null, null),
  ('SK-UCT-VZAS', 'r28', null, 'Pridaná hodnota', '{}'::jsonb, 270, 1, true, array['r03', 'r04', 'r05', 'r06', 'r07']::text[], array['r11', 'r12', 'r13', 'r14']::text[], null, 'Tlačivo vytlačí tento riadok za riadkom 27 ako informatívny (označený hviezdičkou), mimo hlavného výpočtového reťazca výsledku hospodárenia.', 'tlacivo-vzas'),
  ('SK-UCT-VZAS', 'r29', null, 'Výnosy z finančnej činnosti spolu', '{}'::jsonb, 280, 1, true, array['r39', 'r42', 'r43', 'r44']::text[], '{}'::text[], null, 'Oficiálny riadok 29 sčítava aj riadky 30, 31 a 35 (tržby z predaja cenných papierov, výnosy z dlhodobého a krátkodobého finančného majetku), ktoré tento balík nedeklaruje, lebo preň nemá samostatný účet.', 'tlacivo-vzas'),
  ('SK-UCT-VZAS', 'r39', 'r29', 'Výnosové úroky', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r42', 'r29', 'Kurzové zisky', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r43', 'r29', 'Výnosy z precenenia cenných papierov a výnosy z derivátových operácií', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r44', 'r29', 'Ostatné výnosy z finančnej činnosti', '{}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r45', null, 'Náklady na finančnú činnosť spolu', '{}'::jsonb, 330, 1, true, array['r49', 'r52', 'r54']::text[], '{}'::text[], null, 'Oficiálny riadok 45 sčítava aj riadky 46, 47, 48 a 53 (predané cenné papiere, náklady na precenenie a derivátové operácie), ktoré tento balík nedeklaruje.', 'tlacivo-vzas'),
  ('SK-UCT-VZAS', 'r49', 'r45', 'Nákladové úroky', '{}'::jsonb, 340, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r52', 'r45', 'Kurzové straty', '{}'::jsonb, 350, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r54', 'r45', 'Ostatné náklady na finančnú činnosť', '{}'::jsonb, 360, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r55', null, 'Výsledok hospodárenia z finančnej činnosti', '{}'::jsonb, 370, 1, true, array['r29']::text[], array['r45']::text[], null, null, null),
  ('SK-UCT-VZAS', 'r56', null, 'Výsledok hospodárenia za účtovné obdobie pred zdanením', '{}'::jsonb, 380, 1, true, array['r27', 'r55']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r57', null, 'Daň z príjmov', '{}'::jsonb, 390, 1, true, array['r58', 'r59']::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r58', 'r57', 'Daň z príjmov splatná', '{}'::jsonb, 400, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r59', 'r57', 'Daň z príjmov odložená', '{}'::jsonb, 410, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r60', null, 'Prevod podielov na výsledku hospodárenia spoločníkom', '{}'::jsonb, 420, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SK-UCT-VZAS', 'r61', null, 'Výsledok hospodárenia za účtovné obdobie po zdanení', '{}'::jsonb, 430, 1, true, array['r56']::text[], array['r57', 'r60']::text[], null, null, null)
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
    ('SK-UCT-SUVAHA', 'r003', 10, 'code_range', '012', '019', null, 'any'),
    ('SK-UCT-SUVAHA', 'r003', 20, 'code_range', '041', '041', null, 'any'),
    ('SK-UCT-SUVAHA', 'r003', 30, 'code_range', '071', '079', null, 'any'),
    ('SK-UCT-SUVAHA', 'r011', 10, 'code_range', '021', '035', null, 'any'),
    ('SK-UCT-SUVAHA', 'r011', 20, 'code_range', '042', '042', null, 'any'),
    ('SK-UCT-SUVAHA', 'r011', 30, 'code_range', '052', '052', null, 'any'),
    ('SK-UCT-SUVAHA', 'r011', 40, 'code_range', '081', '089', null, 'any'),
    ('SK-UCT-SUVAHA', 'r021', 10, 'code_range', '061', '069', null, 'any'),
    ('SK-UCT-SUVAHA', 'r031', 10, 'code_range', '112', '133', null, 'any'),
    ('SK-UCT-SUVAHA', 'r046', 10, 'code_range', '311', '319', null, 'any'),
    ('SK-UCT-SUVAHA', 'r055', 10, 'code_range', '211', '261', null, 'any'),
    ('SK-UCT-SUVAHA', 'r061', 10, 'code_range', '381', '381', null, 'any'),
    ('SK-UCT-SUVAHA', 'r068', 10, 'code_range', '411', '411', null, 'any'),
    ('SK-UCT-SUVAHA', 'r073', 10, 'code_range', '413', '413', null, 'any'),
    ('SK-UCT-SUVAHA', 'r080', 10, 'code_range', '421', '421', null, 'any'),
    ('SK-UCT-SUVAHA', 'r084', 10, 'code_range', '428', '428', null, 'any'),
    ('SK-UCT-SUVAHA', 'r085', 10, 'code_range', '429', '429', null, 'any'),
    ('SK-UCT-SUVAHA', 'r088', 10, 'code_range', '431', '431', null, 'any'),
    ('SK-UCT-SUVAHA', 'r090', 10, 'code_range', '451', '459', null, 'any'),
    ('SK-UCT-SUVAHA', 'r095', 10, 'code_range', '479', '481', null, 'any'),
    ('SK-UCT-SUVAHA', 'r107', 10, 'code_range', '321', '349', null, 'any'),
    ('SK-UCT-SUVAHA', 'r107', 20, 'code_range', '379', '379', null, 'any'),
    ('SK-UCT-SUVAHA', 'r119', 10, 'code_range', '461', '461', null, 'any'),
    ('SK-UCT-SUVAHA', 'r122', 10, 'code_range', '384', '384', null, 'any'),
    ('SK-UCT-VZAS', 'r03', 10, 'code_range', '604', '604', null, 'any'),
    ('SK-UCT-VZAS', 'r04', 10, 'code_range', '601', '601', null, 'any'),
    ('SK-UCT-VZAS', 'r05', 10, 'code_range', '602', '602', null, 'any'),
    ('SK-UCT-VZAS', 'r09', 10, 'code_range', '644', '648', null, 'any'),
    ('SK-UCT-VZAS', 'r11', 10, 'code_range', '504', '504', null, 'any'),
    ('SK-UCT-VZAS', 'r12', 10, 'code_range', '501', '502', null, 'any'),
    ('SK-UCT-VZAS', 'r14', 10, 'code_range', '511', '518', null, 'any'),
    ('SK-UCT-VZAS', 'r16', 10, 'code_range', '521', '521', null, 'any'),
    ('SK-UCT-VZAS', 'r18', 10, 'code_range', '524', '524', null, 'any'),
    ('SK-UCT-VZAS', 'r19', 10, 'code_range', '527', '527', null, 'any'),
    ('SK-UCT-VZAS', 'r20', 10, 'code_range', '531', '538', null, 'any'),
    ('SK-UCT-VZAS', 'r22', 10, 'code_range', '551', '551', null, 'any'),
    ('SK-UCT-VZAS', 'r24', 10, 'code_range', '541', '541', null, 'any'),
    ('SK-UCT-VZAS', 'r26', 10, 'code_range', '544', '548', null, 'any'),
    ('SK-UCT-VZAS', 'r39', 10, 'code_range', '662', '662', null, 'any'),
    ('SK-UCT-VZAS', 'r42', 10, 'code_range', '663', '663', null, 'any'),
    ('SK-UCT-VZAS', 'r44', 10, 'code_range', '668', '668', null, 'any'),
    ('SK-UCT-VZAS', 'r49', 10, 'code_range', '562', '562', null, 'any'),
    ('SK-UCT-VZAS', 'r52', 10, 'code_range', '563', '563', null, 'any'),
    ('SK-UCT-VZAS', 'r54', 10, 'code_range', '568', '568', null, 'any'),
    ('SK-UCT-VZAS', 'r58', 10, 'code_range', '591', '591', null, 'any')
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
  ('SK', 'Slovensko', '{}'::jsonb, array['sk']::text[], 'EUR', '311', '321', '379', '548', '428', '604', '501', '221', '211', 'FV', 'FP', 'IUD', 'sk', 'result_accounts', '431', '431', '429', 'PZS', 'half_up', default, '663', '563', null, null, null, null, '343', null, null, 'month'::declaration_period)
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
  number_format                 = '{CODE}/{YYYY}/{NNNN}',
  legal_payment_days            = null,
  late_payment_reference        = 'Obchodný zákonník (zákon č. 513/1991 Zb.), § 369 a § 369c, v znení zákona č. 9/2013 Z. z. — pri omeškaní s peňažným záväzkom medzi podnikateľmi patrí veriteľovi bez upomienky úrok z omeškania vo výške základnej úrokovej sadzby Európskej centrálnej banky platnej k prvému dňu omeškania zvýšenej o deväť percentuálnych bodov (nariadenie vlády SR č. 21/2013 Z. z., § 1 ods. 1), a paušálna náhrada nákladov spojených s uplatnením pohľadávky vo výške 40 eur jednorazovo bez ohľadu na dĺžku omeškania (nariadenie vlády SR č. 21/2013 Z. z., § 2).',
  numbering_legal_reference     = 'Zákon č. 222/2004 Z. z. o dani z pridanej hodnoty, § 74 ods. 1 písm. c) — faktúra musí obsahovať poradové číslo faktúry. Zákon vyžaduje jednoznačnú identifikáciu, nie neprerušenú číselnú radu ani ročný reset, preto sequential a nie gapless_per_year.',
  numbering_source_key          = 'zakon-dph',
  payment_terms_legal_reference = 'Obchodný zákonník, § 340a ods. 1 — medzi podnikateľmi dohodnutá lehota splatnosti nesmie presiahnuť 60 dní odo dňa doručenia faktúry alebo odo dňa plnenia, ak je neskorší, okrem výnimiek dojednaných výslovne a nie hrubo nespravodlivých voči veriteľovi. Toto je strop na dohodnutú lehotu, nie subsidiárna lehota v prípade, že sa strany na ničom nedohodnú; presné číslo dní platné bez dohody sa v texte dostupnom pri príprave tohto balíka nepodarilo overiť doslovne, preto legal_payment_days zostáva prázdne namiesto toho, aby stropovú hodnotu vydávalo za subsidiárnu — pozri README, časť na doplnenie účtovníkom.',
  payment_terms_source_key      = 'obchodny-zakonnik',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Zákon č. 222/2004 Z. z., § 19 ods. 1 a 2 — daňová povinnosť vzniká dňom dodania tovaru alebo dňom dodania služby; § 19 ods. 4 — ak je platba prijatá pred dodaním, daňová povinnosť z prijatej platby vzniká dňom prijatia platby. Obe vetvy spolu zodpovedajú earliest_of_delivery_or_payment.',
  tax_point_source_key          = 'zakon-dph',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Zákon č. 222/2004 Z. z., § 71 ods. 2 — za faktúru sa považuje aj každý doklad alebo oznámenie, ktoré mení pôvodnú faktúru a osobitne a jednoznačne sa na ňu vzťahuje; opravu základu dane a opravný doklad upravuje § 25 a § 25a. Vyhotovená faktúra sa teda opravuje odkazujúcim dokladom (dobropisom), nie tichou úpravou pôvodného záznamu.',
  posted_edit_policy_source_key = 'zakon-dph',
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = date '2027-01-01',
  einvoice_obligation           = 'mandatory',
  einvoice_legal_reference      = 'Novelizovaný zákon č. 222/2004 Z. z. (nové § 76a a § 85o), podľa informačného dokumentu Finančného riaditeľstva SR 9/DPH/2025/IM — od 1. januára 2027 sú platitelia DPH povinní vyhotoviť a prijímať faktúry z tuzemských dodaní tovarov a služieb v ustanovenom elektronickom formáte (B2B a B2G, nie B2C), a každá osoba, ktorej má byť takáto faktúra vystavená, ju musí vedieť prijať. Od 1. januára 2026 do 31. decembra 2026 beží dobrovoľné prechodné obdobie. Kontrolný výkaz a súhrnný výkaz sa e-faktúrou nerušia — ich zrušenie sa plánuje až od 1. júla 2030, súbežne s cezhraničnou digitálnou report­ovacou povinnosťou európskej iniciatívy ViDA (VAT in the Digital Age). Formát je štruktúrovaný XML podľa európskej normy EN 16931 (syntax UBL alebo CII), prenášaný cez sieť Peppol, ktorej autoritou pre Slovensko je Finančné riaditeľstvo SR. Presné číslo novelizujúceho zákona a jeho paragrafové znenie sa nepodarilo overiť priamym čítaním na slov-lex.gov.sk pri príprave tohto balíka (kandidát: zákon č. 385/2025 Z. z., neoverené) — pozri README. party_scheme a vat_scheme zostávajú prázdne: konkrétna schéma ISO 6523 pre slovenských účastníkov siete Peppol nebola overená zo žiadneho zdroja použitého pri príprave tohto balíka.',
  einvoice_source_key           = 'efaktura-faq',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'SK';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('SK', 'reverse_charge', 'reverse_charge', 'Prenesenie daňovej povinnosti', '{}'::jsonb, 10, date '1970-01-01', null, 'Zákon č. 222/2004 Z. z., § 74 ods. 1 písm. k) — ak je osobou povinnou platiť daň príjemca tovaru alebo služby, faktúra obsahuje slovnú informáciu „prenesenie daňovej povinnosti“; zákon nepripúšťa inú formuláciu.'),
  ('SK', 'intra_eu_goods', 'intra_eu_goods', 'Dodanie je oslobodené od dane podľa § 43 zákona č. 222/2004 Z. z.', '{}'::jsonb, 20, date '1970-01-01', null, 'Zákon č. 222/2004 Z. z., § 74 ods. 1 písm. h) — pri oslobodení od dane faktúra uvádza odkaz na ustanovenie tohto zákona alebo smernice 2006/112/ES, alebo slovnú informáciu „dodanie je oslobodené od dane“; § 43 je oslobodenie s nárokom na odpočet pri dodaní tovaru do iného členského štátu.'),
  ('SK', 'export', 'export', 'Dodanie je oslobodené od dane podľa § 47 zákona č. 222/2004 Z. z.', '{}'::jsonb, 30, date '1970-01-01', null, 'Zákon č. 222/2004 Z. z., § 74 ods. 1 písm. h) a § 47 — oslobodenie od dane pri vývoze tovaru do tretieho štátu, s nárokom na odpočet.'),
  ('SK', 'exempt', 'exempt', 'Dodanie je oslobodené od dane', '{}'::jsonb, 40, date '1970-01-01', null, 'Zákon č. 222/2004 Z. z., § 74 ods. 1 písm. h) — všeobecná slovná informácia, keď sa dodávateľ neodvoláva na konkrétny paragraf; každá jednotlivá oslobodená daň tohto balíka cituje svoj vlastný článok v legal_reference.'),
  ('SK', 'late_payment', 'late_payment', 'Pri omeškaní s platbou patrí veriteľovi úrok z omeškania vo výške základnej úrokovej sadzby ECB zvýšenej o deväť percentuálnych bodov a paušálna náhrada nákladov 40 eur (§ 369 a § 369c Obchodného zákonníka, § 1 a § 2 nariadenia vlády SR č. 21/2013 Z. z.).', '{}'::jsonb, 50, date '1970-01-01', null, 'Pozri documents.late_payment_reference.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
