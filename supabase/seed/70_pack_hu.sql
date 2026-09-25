-- Ekwo OS — Magyarország: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/hu at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build hu`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   2007. évi CXXVII. törvény az általános forgalmi adóról (Nemzeti Jogszabálytár / net.jogtar.hu (a Wolters Kluwer Hatályos Jogszabályok Gyűjteménye, az Igazságügyi Minisztérium közreműködésével gondozott hatályos szövegtár))
--     https://net.jogtar.hu/jogszabaly?docid=a0700127.tv
--   2000. évi C. törvény a számvitelről (Nemzeti Jogszabálytár / net.jogtar.hu)
--     https://net.jogtar.hu/jogszabaly?docid=a0000100.tv
--   2017. évi CL. törvény az adózás rendjéről, 2. melléklet I./B./3. pont — az áfabevallás gyakorisága (Nemzeti Jogszabálytár / net.jogtar.hu)
--     https://net.jogtar.hu/jogszabaly?docid=a1700150.tv
--   2013. évi V. törvény a Polgári Törvénykönyvről, Hatodik könyv, 6:130. § — pénztartozás teljesítésének ideje (Nemzeti Jogszabálytár / net.jogtar.hu)
--     https://net.jogtar.hu/jogszabaly?docid=a1300005.tv
--   2008. évi III. törvény az 1 és 2 forintos címletű érmék bevonása következtében szükséges kerekítés szabályairól (Nemzeti Jogszabálytár / net.jogtar.hu)
--     https://net.jogtar.hu/jogszabaly?docid=a0800003.tv
--   2665 számú áfabevallás és kitöltési útmutatója, a 2026. évi bevallási időszakokra (Nemzeti Adó- és Vámhivatal (NAV))
--     https://nav.gov.hu/pfile/file?path=%2Fnyomtatvanyok%2Fletoltesek%2Fnyomtatvanykitolto_programok%2Fnyomtatvanykitolto_programok_nav%2F2665%2F2665-kitoltesi-utmutato
--   Áfakulcsok és a tevékenység közérdekű vagy egyéb sajátos jellegére tekintettel adómentes tevékenységek köre (Nemzeti Adó- és Vámhivatal (NAV))
--     https://nav.gov.hu/pfile/file?path=%2Fugyfeliranytu%2Fadokulcsok_jarulekmertekek%2Fafakulcs_adomen%2FAfa_kulcsok_es_a_tevekenyseg_kozerdeku_vagy_egyeb_sajatos_jellegere_tekintettel_adomentes_tevekenysegek_kore
--   Emelkedik az alanyi adómentesség értékhatára (Nemzeti Adó- és Vámhivatal (NAV))
--     https://nav.gov.hu/ado/afa/Emelkedik_az_alanyi_adomentesseg_ertekhatara
--   A számlakibocsátók adatszolgáltatási kötelezettsége (Online Számla, valós idejű adatszolgáltatás) (Nemzeti Adó- és Vámhivatal (NAV))
--     https://nav.gov.hu/ado/afa/A_szamlakibocsatok_sz20201231
--   Online Számla — a NAV valós idejű számla-adatszolgáltatási rendszere (Nemzeti Adó- és Vámhivatal (NAV))
--     https://onlineszamla.nav.gov.hu/
--   Electronic Address Scheme (EAS) — ISO 6523 identifier schemes, including 9910 (Hungary VAT number) (OpenPeppol)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
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
  ('HU', 'Magyarország', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, 'f4368971431c86de93a246e41cd4c4c93a2c5df2cc3a860386c90d1213f75f8c', '[{"key":"afa-torveny","title":"2007. évi CXXVII. törvény az általános forgalmi adóról","publisher":"Nemzeti Jogszabálytár / net.jogtar.hu (a Wolters Kluwer Hatályos Jogszabályok Gyűjteménye, az Igazságügyi Minisztérium közreműködésével gondozott hatályos szövegtár)","url":"https://net.jogtar.hu/jogszabaly?docid=a0700127.tv","consulted_on":"2026-09-25","kind":"law"},{"key":"szamviteli-torveny","title":"2000. évi C. törvény a számvitelről","publisher":"Nemzeti Jogszabálytár / net.jogtar.hu","url":"https://net.jogtar.hu/jogszabaly?docid=a0000100.tv","consulted_on":"2026-09-25","kind":"law"},{"key":"art-torveny","title":"2017. évi CL. törvény az adózás rendjéről, 2. melléklet I./B./3. pont — az áfabevallás gyakorisága","publisher":"Nemzeti Jogszabálytár / net.jogtar.hu","url":"https://net.jogtar.hu/jogszabaly?docid=a1700150.tv","consulted_on":"2026-09-25","kind":"law"},{"key":"ptk","title":"2013. évi V. törvény a Polgári Törvénykönyvről, Hatodik könyv, 6:130. § — pénztartozás teljesítésének ideje","publisher":"Nemzeti Jogszabálytár / net.jogtar.hu","url":"https://net.jogtar.hu/jogszabaly?docid=a1300005.tv","consulted_on":"2026-09-25","kind":"law"},{"key":"kerekitesi-torveny","title":"2008. évi III. törvény az 1 és 2 forintos címletű érmék bevonása következtében szükséges kerekítés szabályairól","publisher":"Nemzeti Jogszabálytár / net.jogtar.hu","url":"https://net.jogtar.hu/jogszabaly?docid=a0800003.tv","consulted_on":"2026-09-25","kind":"law"},{"key":"nyomtatvany-2665","title":"2665 számú áfabevallás és kitöltési útmutatója, a 2026. évi bevallási időszakokra","publisher":"Nemzeti Adó- és Vámhivatal (NAV)","url":"https://nav.gov.hu/pfile/file?path=%2Fnyomtatvanyok%2Fletoltesek%2Fnyomtatvanykitolto_programok%2Fnyomtatvanykitolto_programok_nav%2F2665%2F2665-kitoltesi-utmutato","consulted_on":"2026-09-25","kind":"form"},{"key":"nav-afakulcsok","title":"Áfakulcsok és a tevékenység közérdekű vagy egyéb sajátos jellegére tekintettel adómentes tevékenységek köre","publisher":"Nemzeti Adó- és Vámhivatal (NAV)","url":"https://nav.gov.hu/pfile/file?path=%2Fugyfeliranytu%2Fadokulcsok_jarulekmertekek%2Fafakulcs_adomen%2FAfa_kulcsok_es_a_tevekenyseg_kozerdeku_vagy_egyeb_sajatos_jellegere_tekintettel_adomentes_tevekenysegek_kore","consulted_on":"2026-09-25","kind":"guidance"},{"key":"nav-alanyi-mentesseg","title":"Emelkedik az alanyi adómentesség értékhatára","publisher":"Nemzeti Adó- és Vámhivatal (NAV)","url":"https://nav.gov.hu/ado/afa/Emelkedik_az_alanyi_adomentesseg_ertekhatara","consulted_on":"2026-09-25","kind":"guidance"},{"key":"nav-online-szamla","title":"A számlakibocsátók adatszolgáltatási kötelezettsége (Online Számla, valós idejű adatszolgáltatás)","publisher":"Nemzeti Adó- és Vámhivatal (NAV)","url":"https://nav.gov.hu/ado/afa/A_szamlakibocsatok_sz20201231","consulted_on":"2026-09-25","kind":"guidance"},{"key":"onlineszamla-portal","title":"Online Számla — a NAV valós idejű számla-adatszolgáltatási rendszere","publisher":"Nemzeti Adó- és Vámhivatal (NAV)","url":"https://onlineszamla.nav.gov.hu/","consulted_on":"2026-09-25","kind":"portal"},{"key":"peppol-eas","title":"Electronic Address Scheme (EAS) — ISO 6523 identifier schemes, including 9910 (Hungary VAT number)","publisher":"OpenPeppol","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-25","kind":"standard"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('HU', 'default', 'A mérleg és az eredménykimutatás „A” változatának tagolására épülő számlatükör', '{}'::jsonb, true, 'companies', array['HU-SZT-EREDMENY-A', 'HU-SZT-MERLEG-A']::text[], null, 'A számvitelről szóló 2000. évi C. törvény 14. §-a minden gazdálkodót saját számviteli politika és — ahhoz igazodó — saját számlarend írásbeli kialakítására kötelez; a törvény nem ír elő egységes, számokkal rögzített nemzeti számlatükröt (ellentétben például a francia PCG-vel vagy a belga PCMN-nel). Ez a számlatükör ezért e pack saját, a törvény 22. §-a szerinti, az 1. számú melléklet „A” változatában rögzített mérlegtagolásra és a 71. §, 2. számú melléklet szerinti, összköltség eljárással készített eredménykimutatás „A” változatára épülő javaslata: a kód első számjegye közvetlenül a mérleg vagy az eredménykimutatás azon fő tételére utal, amelyhez a számla tartozik (1 A) Befektetett eszközök, 2 B) Forgóeszközök, 3 C) Aktív időbeli elhatárolások, 4 D) Saját tőke, 5 E) Céltartalékok, 6 F) Kötelezettségek, 7 G) Passzív időbeli elhatárolások, 8–9 az eredménykimutatás 2. számú melléklet szerinti sorai).', 'szamviteli-torveny')
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
  ('HU', 'default', '1100', 'Vagyoni értékű jogok', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('HU', 'default', '1110', 'Szellemi termékek (szoftver)', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('HU', 'default', '1120', 'Kísérleti fejlesztés aktivált értéke', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('HU', 'default', '1130', 'Üzleti vagy cégérték', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('HU', 'default', '1140', 'Immateriális javakra adott előlegek', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('HU', 'default', '1200', 'Ingatlanok és a kapcsolódó vagyoni értékű jogok', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('HU', 'default', '1210', 'Műszaki berendezések, gépek, járművek', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('HU', 'default', '1220', 'Egyéb berendezések, felszerelések', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('HU', 'default', '1230', 'Beruházások, felújítások', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('HU', 'default', '1240', 'Beruházásokra adott előlegek', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('HU', 'default', '1300', 'Tartós részesedés kapcsolt vállalkozásban', '{}'::jsonb, 'asset_non_current', false, null, 110),
  ('HU', 'default', '1310', 'Tartósan adott kölcsön kapcsolt vállalkozásnak', '{}'::jsonb, 'asset_non_current', false, null, 120),
  ('HU', 'default', '1320', 'Egyéb hosszú lejáratú befektetett pénzügyi eszköz', '{}'::jsonb, 'asset_non_current', false, null, 130),
  ('HU', 'default', '2100', 'Anyagok', '{}'::jsonb, 'asset_current', false, null, 140),
  ('HU', 'default', '2110', 'Befejezetlen termelés és félkész termékek', '{}'::jsonb, 'asset_current', false, null, 150),
  ('HU', 'default', '2120', 'Késztermékek', '{}'::jsonb, 'asset_current', false, null, 160),
  ('HU', 'default', '2130', 'Áruk', '{}'::jsonb, 'asset_current', false, null, 170),
  ('HU', 'default', '2140', 'Készletekre adott előlegek', '{}'::jsonb, 'asset_current', false, null, 180),
  ('HU', 'default', '2200', 'Vevőkövetelések', '{}'::jsonb, 'asset_receivable', true, null, 190),
  ('HU', 'default', '2210', 'Kapcsolt vállalkozással szembeni követelés', '{}'::jsonb, 'asset_current', false, null, 200),
  ('HU', 'default', '2215', 'Munkavállalókkal szembeni követelés', '{}'::jsonb, 'asset_current', false, null, 220),
  ('HU', 'default', '2216', 'Tagokkal (tulajdonosokkal) szembeni követelés', '{}'::jsonb, 'asset_current', false, null, 230),
  ('HU', 'default', '2220', 'Egyéb követelés', '{}'::jsonb, 'asset_current', false, null, 240),
  ('HU', 'default', '2221', 'Levonható előzetesen felszámított áfa 27%', '{}'::jsonb, 'asset_current', false, null, 250),
  ('HU', 'default', '2222', 'Levonható előzetesen felszámított áfa 18%', '{}'::jsonb, 'asset_current', false, null, 260),
  ('HU', 'default', '2223', 'Levonható előzetesen felszámított áfa 5%', '{}'::jsonb, 'asset_current', false, null, 270),
  ('HU', 'default', '2224', 'Levonható előzetesen felszámított áfa — önadózás (közösségi beszerzés, fordított adózás, külföldi szolgáltatás)', '{}'::jsonb, 'asset_current', false, null, 280),
  ('HU', 'default', '2230', 'Költségvetéssel szembeni követelés — általános forgalmi adó', '{}'::jsonb, 'asset_current', true, null, 290),
  ('HU', 'default', '2235', 'Költségvetéssel szembeni egyéb követelés', '{}'::jsonb, 'asset_current', false, null, 300),
  ('HU', 'default', '2240', 'Elszámolási (átvezetési) számla', '{}'::jsonb, 'asset_current', true, null, 310),
  ('HU', 'default', '2300', 'Egyéb részesedés', '{}'::jsonb, 'asset_current', false, null, 320),
  ('HU', 'default', '2310', 'Saját részvények, üzletrészek', '{}'::jsonb, 'asset_current', false, null, 330),
  ('HU', 'default', '2320', 'Egyéb értékpapír', '{}'::jsonb, 'asset_current', false, null, 340),
  ('HU', 'default', '2400', 'Pénztár', '{}'::jsonb, 'asset_cash', false, null, 350),
  ('HU', 'default', '2410', 'Bankbetétek — elszámolási számla', '{}'::jsonb, 'asset_cash', false, null, 360),
  ('HU', 'default', '2420', 'Bankbetétek — elkülönített számla', '{}'::jsonb, 'asset_cash', false, null, 370),
  ('HU', 'default', '3100', 'Aktív időbeli elhatárolás — bevételek', '{}'::jsonb, 'asset_prepayments', false, null, 380),
  ('HU', 'default', '3110', 'Aktív időbeli elhatárolás — költségek, ráfordítások', '{}'::jsonb, 'asset_prepayments', false, null, 390),
  ('HU', 'default', '3120', 'Halasztott ráfordítások', '{}'::jsonb, 'asset_prepayments', false, null, 400),
  ('HU', 'default', '4100', 'Jegyzett tőke', '{}'::jsonb, 'equity', false, null, 410),
  ('HU', 'default', '4200', 'Jegyzett, de még be nem fizetett tőke', '{}'::jsonb, 'equity', false, null, 420),
  ('HU', 'default', '4300', 'Tőketartalék', '{}'::jsonb, 'equity', false, null, 430),
  ('HU', 'default', '4400', 'Eredménytartalék', '{}'::jsonb, 'equity_retained', false, null, 440),
  ('HU', 'default', '4500', 'Lekötött tartalék', '{}'::jsonb, 'equity', false, null, 450),
  ('HU', 'default', '4600', 'Értékelési tartalék', '{}'::jsonb, 'equity', false, null, 460),
  ('HU', 'default', '4710', 'Adózott eredmény — nyereség', '{}'::jsonb, 'equity', false, null, 470),
  ('HU', 'default', '4720', 'Adózott eredmény — veszteség', '{}'::jsonb, 'equity', false, null, 480),
  ('HU', 'default', '5100', 'Céltartalék várható kötelezettségekre', '{}'::jsonb, 'liability_non_current', false, null, 490),
  ('HU', 'default', '5110', 'Céltartalék jövőbeni költségekre', '{}'::jsonb, 'liability_non_current', false, null, 500),
  ('HU', 'default', '5120', 'Egyéb céltartalék', '{}'::jsonb, 'liability_non_current', false, null, 510),
  ('HU', 'default', '6100', 'Hátrasorolt kötelezettség kapcsolt vállalkozással szemben', '{}'::jsonb, 'liability_non_current', false, null, 520),
  ('HU', 'default', '6110', 'Hátrasorolt kötelezettség egyéb részesedési viszonyban lévő vállalkozással szemben', '{}'::jsonb, 'liability_non_current', false, null, 530),
  ('HU', 'default', '6200', 'Hosszú lejáratú hitel', '{}'::jsonb, 'liability_non_current', false, null, 540),
  ('HU', 'default', '6210', 'Hosszú lejáratú kölcsön', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('HU', 'default', '6220', 'Egyéb hosszú lejáratú kötelezettség', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('HU', 'default', '6300', 'Szállítói kötelezettség', '{}'::jsonb, 'liability_payable', true, null, 570),
  ('HU', 'default', '6310', 'Kapcsolt vállalkozással szembeni kötelezettség', '{}'::jsonb, 'liability_payable', true, null, 580),
  ('HU', 'default', '6315', 'Tagokkal (tulajdonosokkal) szembeni kötelezettség', '{}'::jsonb, 'liability_current', false, null, 590),
  ('HU', 'default', '6320', 'Váltótartozás', '{}'::jsonb, 'liability_current', false, null, 600),
  ('HU', 'default', '6321', 'Fizetendő áfa 27%', '{}'::jsonb, 'liability_current', false, null, 610),
  ('HU', 'default', '6322', 'Fizetendő áfa 18%', '{}'::jsonb, 'liability_current', false, null, 620),
  ('HU', 'default', '6323', 'Fizetendő áfa 5%', '{}'::jsonb, 'liability_current', false, null, 630),
  ('HU', 'default', '6324', 'Fizetendő áfa — önadózás (közösségi beszerzés, fordított adózás)', '{}'::jsonb, 'liability_current', false, null, 640),
  ('HU', 'default', '6330', 'Költségvetéssel szembeni kötelezettség — általános forgalmi adó', '{}'::jsonb, 'liability_current', true, null, 650),
  ('HU', 'default', '6335', 'Költségvetéssel szembeni egyéb kötelezettség', '{}'::jsonb, 'liability_current', false, null, 660),
  ('HU', 'default', '6340', 'Munkavállalókkal szembeni kötelezettség (bér)', '{}'::jsonb, 'liability_current', false, null, 670),
  ('HU', 'default', '6350', 'Társadalombiztosítással szembeni kötelezettség', '{}'::jsonb, 'liability_current', false, null, 680),
  ('HU', 'default', '6360', 'Rövid lejáratú hitel', '{}'::jsonb, 'liability_current', false, null, 690),
  ('HU', 'default', '6370', 'Egyéb rövid lejáratú kötelezettség', '{}'::jsonb, 'liability_current', false, null, 700),
  ('HU', 'default', '7100', 'Passzív időbeli elhatárolás — bevételek', '{}'::jsonb, 'liability_current', false, null, 710),
  ('HU', 'default', '7110', 'Passzív időbeli elhatárolás — költségek, ráfordítások', '{}'::jsonb, 'liability_current', false, null, 720),
  ('HU', 'default', '7120', 'Halasztott bevételek', '{}'::jsonb, 'liability_current', false, null, 730),
  ('HU', 'default', '8100', 'Belföldi értékesítés nettó árbevétele — termék', '{}'::jsonb, 'income', false, null, 740),
  ('HU', 'default', '8101', 'Belföldi értékesítés nettó árbevétele — szolgáltatás', '{}'::jsonb, 'income', false, null, 750),
  ('HU', 'default', '8110', 'Exportértékesítés nettó árbevétele', '{}'::jsonb, 'income', false, null, 760),
  ('HU', 'default', '8120', 'Közösségen belüli értékesítés nettó árbevétele', '{}'::jsonb, 'income', false, null, 770),
  ('HU', 'default', '8200', 'Saját termelésű készletek állományváltozása', '{}'::jsonb, 'income_other', false, null, 780),
  ('HU', 'default', '8300', 'Saját előállítású eszközök aktivált értéke', '{}'::jsonb, 'income_other', false, null, 790),
  ('HU', 'default', '8400', 'Egyéb bevételek — kapott támogatás', '{}'::jsonb, 'income_other', false, null, 800),
  ('HU', 'default', '8401', 'Egyéb bevételek — kapott kötbér, kártérítés', '{}'::jsonb, 'income_other', false, null, 810),
  ('HU', 'default', '8402', 'Egyéb bevételek — értékesített tárgyi eszköz bevétele', '{}'::jsonb, 'income_other', false, null, 820),
  ('HU', 'default', '8403', 'Egyéb bevételek — céltartalék felhasználása', '{}'::jsonb, 'income_other', false, null, 830),
  ('HU', 'default', '8500', 'Anyagköltség — alapanyag', '{}'::jsonb, 'expense', false, null, 840),
  ('HU', 'default', '8501', 'Anyagköltség — irodaszer', '{}'::jsonb, 'expense', false, null, 850),
  ('HU', 'default', '8502', 'Anyagköltség — energia (villany, gáz)', '{}'::jsonb, 'expense', false, null, 860),
  ('HU', 'default', '8510', 'Igénybe vett szolgáltatások — bérleti díj', '{}'::jsonb, 'expense', false, null, 870),
  ('HU', 'default', '8511', 'Igénybe vett szolgáltatások — szakértői, tanácsadói díj', '{}'::jsonb, 'expense', false, null, 880),
  ('HU', 'default', '8512', 'Igénybe vett szolgáltatások — telekommunikáció, internet', '{}'::jsonb, 'expense', false, null, 890),
  ('HU', 'default', '8513', 'Igénybe vett szolgáltatások — szállítási, fuvarozási', '{}'::jsonb, 'expense', false, null, 900),
  ('HU', 'default', '8514', 'Igénybe vett szolgáltatások — karbantartás, javítás', '{}'::jsonb, 'expense', false, null, 910),
  ('HU', 'default', '8515', 'Igénybe vett szolgáltatások — oktatás, továbbképzés', '{}'::jsonb, 'expense', false, null, 920),
  ('HU', 'default', '8520', 'Egyéb szolgáltatások értéke — hatósági díjak, illetékek', '{}'::jsonb, 'expense', false, null, 930),
  ('HU', 'default', '8521', 'Egyéb szolgáltatások értéke — biztosítás', '{}'::jsonb, 'expense', false, null, 940),
  ('HU', 'default', '8522', 'Egyéb szolgáltatások értéke — bankköltség', '{}'::jsonb, 'expense', false, null, 950),
  ('HU', 'default', '8530', 'Eladott áruk beszerzési értéke', '{}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('HU', 'default', '8540', 'Eladott (közvetített) szolgáltatások értéke', '{}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('HU', 'default', '8600', 'Bérköltség', '{}'::jsonb, 'expense', false, null, 980),
  ('HU', 'default', '8610', 'Személyi jellegű egyéb kifizetések', '{}'::jsonb, 'expense', false, null, 990),
  ('HU', 'default', '8620', 'Bérjárulékok — szociális hozzájárulási adó', '{}'::jsonb, 'expense', false, null, 1000),
  ('HU', 'default', '8621', 'Bérjárulékok — egyéb', '{}'::jsonb, 'expense', false, null, 1010),
  ('HU', 'default', '8700', 'Értékcsökkenési leírás', '{}'::jsonb, 'expense_depreciation', false, null, 1020),
  ('HU', 'default', '8800', 'Egyéb ráfordítások — adók, illetékek', '{}'::jsonb, 'expense', false, null, 1030),
  ('HU', 'default', '8801', 'Egyéb ráfordítások — adott kötbér, kártérítés', '{}'::jsonb, 'expense', false, null, 1040),
  ('HU', 'default', '8810', 'Le nem vonható áfa — személygépkocsi', '{}'::jsonb, 'expense', false, null, 1050),
  ('HU', 'default', '8820', 'Kerekítési különbözet', '{}'::jsonb, 'expense', false, null, 1060),
  ('HU', 'default', '9100', 'Kapott osztalék és részesedés', '{}'::jsonb, 'income_other', false, null, 1070),
  ('HU', 'default', '9110', 'Egyéb kapott kamatok és kamatjellegű bevételek', '{}'::jsonb, 'income_other', false, null, 1080),
  ('HU', 'default', '9120', 'Árfolyamnyereség', '{}'::jsonb, 'income_other', false, null, 1090),
  ('HU', 'default', '9200', 'Fizetendő kamatok és kamatjellegű ráfordítások', '{}'::jsonb, 'expense', false, null, 1100),
  ('HU', 'default', '9210', 'Árfolyamveszteség', '{}'::jsonb, 'expense', false, null, 1110),
  ('HU', 'default', '9300', 'Adófizetési kötelezettség (társasági adó)', '{}'::jsonb, 'expense', false, null, 1120)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('HU', 'BE', 'Bejövő számlák', '{}'::jsonb, 'purchase', 20),
  ('HU', 'BK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('HU', 'KI', 'Kimenő számlák', '{}'::jsonb, 'sales', 10),
  ('HU', 'NY', 'Nyitás', '{}'::jsonb, 'opening', 60),
  ('HU', 'PT', 'Pénztár', '{}'::jsonb, 'cash', 40),
  ('HU', 'VE', 'Vegyes tételek', '{}'::jsonb, 'general', 50)
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
  ('HU', 'HU-P-18', 'Levonható előzetesen felszámított adó 18%', '{}'::jsonb, 'Más adóalany által rá áthárított adó', 'percent', 18, 'purchase', 'domestic', date '2018-01-01', null, 'Áfa tv. 120. §, a 82. § (3) szerinti tétel után.', 'S', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-P-27', 'Levonható előzetesen felszámított adó 27%', '{}'::jsonb, 'Más adóalany által rá áthárított adó', 'percent', 27, 'purchase', 'domestic', date '2012-01-01', null, 'Áfa tv. 120. § — az adóalanyt, ha adóköteles termékértékesítést, szolgáltatásnyújtást végez, megilleti az az adó levonásának joga, amelyet termék beszerzéséhez, szolgáltatás igénybevételéhez kapcsolódóan egy másik adóalany rá áthárított.', 'S', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-P-27-NA', 'Le nem vonható előzetesen felszámított adó 27% — személygépkocsi', '{}'::jsonb, 'Személygépkocsi (vámtarifaszám 8703) beszerzését terhelő adó, amelyre a levonási jog nem érvényesíthető', 'percent', 27, 'purchase', 'domestic', date '2012-01-01', null, 'Áfa tv. 124. § (1) d) — nem vonható le a személygépkocsi beszerzését terhelő előzetesen felszámított adó; a 125. § szerinti kivételek (például továbbértékesítési vagy taxi célú beszerzés) e tételre nem alkalmazandók. E pontot csak másodlagos, egybehangzó szakmai forrásokból lehetett megerősíteni, nem a törvény szövegének közvetlen olvasásából — lásd README.', 'S', null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-P-5', 'Levonható előzetesen felszámított adó 5%', '{}'::jsonb, 'Más adóalany által rá áthárított adó', 'percent', 5, 'purchase', 'domestic', date '2009-01-01', null, 'Áfa tv. 120. §, a 82. § (2) szerinti tétel után.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-P-EUDL-27', 'Másik tagállamban letelepedett adóalanytól igénybe vett szolgáltatás — önadózás 27%', '{}'::jsonb, 'A teljesítési hely általános szabálya (37. § (1)) alá tartozó szolgáltatás, másik tagállamban letelepedett szolgáltatótól', 'percent', 27, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'Áfa tv. 37. § (1) a teljesítés helyéről; 138–140. § arról, hogy a belföldön le nem telepedett szolgáltató helyett a belföldi igénybevevő fizeti az adót — a 139. és 140. § pontos elhatárolása nem volt közvetlenül ellenőrizhető a törvény szövegéből, lásd README. Áfa tv. 120. § a levonási jogról.', 'K', 'VATEX-EU-IC', 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-P-FOREIGN-27', 'Harmadik országban letelepedett adóalanytól igénybe vett szolgáltatás — önadózás 27%', '{}'::jsonb, 'A teljesítési hely általános szabálya (37. § (1)) alá tartozó szolgáltatás, harmadik országban letelepedett szolgáltatótól', 'percent', 27, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'Áfa tv. 37. § (1) a teljesítés helyéről; 138–140. § arról, hogy a belföldön le nem telepedett szolgáltató helyett a belföldi igénybevevő fizeti az adót. A harmadik országbeli szolgáltató számlájára az EN 16931 nem alkalmazandó, ezért kategória nem szerepel rajta.', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-P-RC-27', 'Fordított adózás — építési-szerelési munka, önadózás 27%', '{}'::jsonb, 'Belföldi fordított adózás alá eső, igénybe vett építési-szerelési munka', 'percent', 27, 'purchase', 'domestic_reverse_charge', date '2008-01-01', null, 'Áfa tv. 142. § (1) b) — az adót a szolgáltatás igénybevevője fizeti; a felek belföldön nyilvántartásba vett adóalanyok (142. § (3)), a kapott számla áthárított adót nem tartalmaz (142. § (7)). Áfa tv. 120. § a levonási jogról.', 'AE', 'VATEX-EU-AE', 150, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-18', 'Áfa 18%', '{}'::jsonb, 'Kedvezményes adómérték — egyebek mellett egyes tejtermékek (a nyers tej kivételével), pékáruk, valamint a kereskedelmi szálláshely-szolgáltatás és az étkeztetés', 'percent', 18, 'sale', 'domestic', date '2018-01-01', null, 'Áfa tv. 82. § (3), a 3/A. számú melléklet szerinti termékekre és szolgáltatásokra.', 'S', null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-27', 'Áfa 27%', '{}'::jsonb, 'Általános (normál) adómérték', 'percent', 27, 'sale', 'domestic', date '2012-01-01', null, 'Áfa tv. 82. § (1) — az adó mértéke az adóalap 27 százaléka, ha e törvény másként nem rendelkezik.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-5', 'Áfa 5%', '{}'::jsonb, 'Kedvezményes adómérték — egyebek mellett a nyers tej, egyes alapvető élelmiszerek, gyógyszerek, könyvek és a távhőszolgáltatás', 'percent', 5, 'sale', 'domestic', date '2009-01-01', null, 'Áfa tv. 82. § (2), a 3. számú melléklet szerinti termékekre és szolgáltatásokra.', 'S', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-EUDL', 'Másik tagállami adóalany részére nyújtott szolgáltatás — fordított adózás', '{}'::jsonb, 'A teljesítési hely általános szabálya (37. § (1)) alá tartozó szolgáltatás, ha az igénybevevő másik tagállamban letelepedett adóalany', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Áfa tv. 37. § (1) — az adóalanynak nyújtott szolgáltatás teljesítési helye ott van, ahol az igénybevevő adóalany gazdasági céllal letelepedett; a másik tagállamban letelepedett igénybevevő ott adófizetésre kötelezett, a magyar számlán a fordított adózásra való utalás kötelező.', 'K', 'VATEX-EU-IC', 60, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-EXEMPT', 'Ingatlan bérbeadása — adómentes, adólevonási jog nélkül', '{}'::jsonb, 'Kereskedelmi ingatlan bérbeadása, adókötelessé tétel választása nélkül', 'percent', 0, 'sale', 'exempt', date '2008-01-01', null, 'Áfa tv. 86. § (1) — mentes az adó alól a tevékenység egyéb sajátos jellegére tekintettel egyebek mellett az ingatlan (ingatlanrész) bérbeadása, feltéve hogy az adóalany nem élt a 88. § szerinti adókötelessé tétel választásával; a pontos betűjelzés nem volt közvetlenül ellenőrizhető a törvény szövegéből — lásd README.', 'E', 'VATEX-EU-135-1', 70, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-EXPORT', 'Adómentes termékexport', '{}'::jsonb, 'Termék Közösség területén kívülre történő értékesítése', 'percent', 0, 'sale', 'export', date '2008-01-01', null, 'Áfa tv. 98. § (1) — mentes az adó alól a termék Közösség területén kívülre történő értékesítése, feltéve hogy a termék az értékesítés következtében elhagyja a Közösség területét, és ezt a kiléptető hatóság igazolja.', 'G', 'VATEX-EU-G', 40, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-IGL', 'Adómentes Közösségen belüli termékértékesítés', '{}'::jsonb, 'Termékértékesítés másik tagállamban közösségi adószámmal rendelkező adóalany részére', 'percent', 0, 'sale', 'intracom_goods', date '2004-05-01', null, 'Áfa tv. 89. § (1) — mentes az adó alól a termék Közösségen belüli értékesítése egy olyan, más tagállamban közösségi adószámmal rendelkező adóalany részére, aki a termékbeszerzés után saját tagállamában adófizetésre kötelezett.', 'K', 'VATEX-EU-IC', 50, 'vat', true, array['buyer_status', 'transport_evidence']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null),
  ('HU', 'HU-S-RC', 'Fordított adózás — építési-szerelési munka', '{}'::jsonb, 'Építési hatósági engedélyhez vagy tudomásulvételi eljáráshoz kötött, ingatlanra vonatkozó építési-szerelési munka', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2008-01-01', null, 'Áfa tv. 142. § (1) b) — a termék értékesítése, szolgáltatás nyújtása után az adót a termék beszerzője, szolgáltatás igénybevevője fizeti, ha az ingatlan létrehozatalára, bővítésére, átalakítására vagy egyéb megváltoztatására — az ingatlan bontását is ideértve — irányuló, építési hatósági engedélyköteles vagy építési hatósági tudomásulvételi eljáráshoz kötött munka. Az így kiállított számla nem tartalmazhat áthárított adót (142. § (7)).', 'AE', 'VATEX-EU-AE', 80, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'afa-torveny', null, null, null, null)
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
    ('HU-P-18', 'invoice', 'tax', 100, '2222', '64', array['64']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-P-18', 'credit_note', 'tax', 100, '2222', '64', array['64']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-P-27', 'invoice', 'tax', 100, '2221', '64', array['64']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-P-27', 'credit_note', 'tax', 100, '2221', '64', array['64']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-P-27-NA', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('HU-P-27-NA', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('HU-P-5', 'invoice', 'tax', 100, '2223', '64', array['64']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-P-5', 'credit_note', 'tax', 100, '2223', '64', array['64']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-P-EUDL-27', 'invoice', 'base', 100, null, '18B', array['18B']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-P-EUDL-27', 'invoice', 'tax', -100, '6324', '18B', array['18B']::text[], 100, 'HU-AFA-2665', 20),
    ('HU-P-EUDL-27', 'invoice', 'tax', 100, '2224', '64', array['64']::text[], 100, 'HU-AFA-2665', 30),
    ('HU-P-EUDL-27', 'credit_note', 'base', 100, null, '18B', array['18B']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-P-EUDL-27', 'credit_note', 'tax', -100, '6324', '18B', array['18B']::text[], -100, 'HU-AFA-2665', 20),
    ('HU-P-EUDL-27', 'credit_note', 'tax', 100, '2224', '64', array['64']::text[], -100, 'HU-AFA-2665', 30),
    ('HU-P-FOREIGN-27', 'invoice', 'base', 100, null, '27', array['27']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-P-FOREIGN-27', 'invoice', 'tax', -100, '6324', '27', array['27']::text[], 100, 'HU-AFA-2665', 20),
    ('HU-P-FOREIGN-27', 'invoice', 'tax', 100, '2224', '64', array['64']::text[], 100, 'HU-AFA-2665', 30),
    ('HU-P-FOREIGN-27', 'credit_note', 'base', 100, null, '27', array['27']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-P-FOREIGN-27', 'credit_note', 'tax', -100, '6324', '27', array['27']::text[], -100, 'HU-AFA-2665', 20),
    ('HU-P-FOREIGN-27', 'credit_note', 'tax', 100, '2224', '64', array['64']::text[], -100, 'HU-AFA-2665', 30),
    ('HU-P-RC-27', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('HU-P-RC-27', 'invoice', 'tax', -100, '6324', '29', array['29']::text[], 100, 'HU-AFA-2665', 20),
    ('HU-P-RC-27', 'invoice', 'tax', 100, '2224', '64', array['64']::text[], 100, 'HU-AFA-2665', 30),
    ('HU-P-RC-27', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('HU-P-RC-27', 'credit_note', 'tax', -100, '6324', '29', array['29']::text[], -100, 'HU-AFA-2665', 20),
    ('HU-P-RC-27', 'credit_note', 'tax', 100, '2224', '64', array['64']::text[], -100, 'HU-AFA-2665', 30),
    ('HU-S-18', 'invoice', 'base', 100, null, '06', array['06']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-18', 'invoice', 'tax', 100, '6322', '06', array['06']::text[], 100, 'HU-AFA-2665', 20),
    ('HU-S-18', 'credit_note', 'base', 100, null, '06', array['06']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-18', 'credit_note', 'tax', 100, '6322', '06', array['06']::text[], -100, 'HU-AFA-2665', 20),
    ('HU-S-27', 'invoice', 'base', 100, null, '07', array['07']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-27', 'invoice', 'tax', 100, '6321', '07', array['07']::text[], 100, 'HU-AFA-2665', 20),
    ('HU-S-27', 'credit_note', 'base', 100, null, '07', array['07']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-27', 'credit_note', 'tax', 100, '6321', '07', array['07']::text[], -100, 'HU-AFA-2665', 20),
    ('HU-S-5', 'invoice', 'base', 100, null, '05', array['05']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-5', 'invoice', 'tax', 100, '6323', '05', array['05']::text[], 100, 'HU-AFA-2665', 20),
    ('HU-S-5', 'credit_note', 'base', 100, null, '05', array['05']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-5', 'credit_note', 'tax', 100, '6323', '05', array['05']::text[], -100, 'HU-AFA-2665', 20),
    ('HU-S-EUDL', 'invoice', 'base', 100, null, '92', array['92']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-EUDL', 'credit_note', 'base', 100, null, '92', array['92']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-EXEMPT', 'invoice', 'base', 100, null, '08', array['08']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-EXEMPT', 'credit_note', 'base', 100, null, '08', array['08']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-EXPORT', 'invoice', 'base', 100, null, '01', array['01']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-EXPORT', 'credit_note', 'base', 100, null, '01', array['01']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-IGL', 'invoice', 'base', 100, null, '02', array['02']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-IGL', 'credit_note', 'base', 100, null, '02', array['02']::text[], -100, 'HU-AFA-2665', 10),
    ('HU-S-RC', 'invoice', 'base', 100, null, '04', array['04']::text[], 100, 'HU-AFA-2665', 10),
    ('HU-S-RC', 'credit_note', 'base', 100, null, '04', array['04']::text[], -100, 'HU-AFA-2665', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'HU' and t.code = v.tax_code
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
  ('HU', 'HU-AFA-2665', 'Általános forgalmi adó bevallása (2665 számú nyomtatvány, 2026. évi bevallási időszakok)', array['month', 'quarter', 'year']::declaration_period[], null, date '2026-01-01', null, 'Az adózás rendjéről szóló 2017. évi CL. törvény 2. melléklet I./B./3. pontja szerint az áfabevallás gyakoriságát a tárgyévet megelőző második év adatai döntik el: havi, ha az elszámolandó adó egyenlege a +1 000 000 forintot elérte; negyedéves, ha ezt nem éri el, de a +/- 250 000 forintos és az 50 000 000 forintos éves küszöböket túllépte; éves, ha az elszámolandó adó egyenlege a +/- 250 000 forintot nem haladja meg és a nettó árbevétel az 50 000 000 forintot nem éri el, feltéve hogy az adóalanynak nincs közösségi adószáma. A sorok — 01-től 36-ig, a 64. és a 85. sor — a 2665 számú nyomtatvány és kitöltési útmutatója szerintiek.', true,null, null, null, null, null, null)
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
  ('HU', 'HU-AFA-2665', '01', 'base', 'Termék Közösség területén kívülre történő értékesítése (export)', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 01. sor; Áfa tv. 98. § (1).', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '02', 'base', 'Termék Közösségen belüli adómentes értékesítése', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 02. sor; Áfa tv. 89. § (1).', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '04', 'base', 'Fordított adózás alá eső, belföldön teljesített termékértékesítés, szolgáltatásnyújtás — az értékesítő oldala', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 04. sor; Áfa tv. 142. §. A számlán ilyenkor áthárított adó nincs, a sor csak az adóalapot hordozza.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '05', 'base', 'Belföldi értékesítés 5%-os adómérték alá tartozó adóalapja', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 05. sor; Áfa tv. 82. § (2).', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '05', 'tax', 'Belföldi értékesítés 5%-os adómérték alá tartozó fizetendő adója', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 05. sor, adó oszlop.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '06', 'base', 'Belföldi értékesítés 18%-os adómérték alá tartozó adóalapja', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 06. sor; Áfa tv. 82. § (3).', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '06', 'tax', 'Belföldi értékesítés 18%-os adómérték alá tartozó fizetendő adója', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 06. sor, adó oszlop.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '07', 'base', 'Belföldi értékesítés 27%-os adómérték alá tartozó adóalapja', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 07. sor; Áfa tv. 82. § (1) — a törvény szövegében nem szerepel önálló Kulcs-jelölés, a bevallás nyomtatványa rendeli a legmagasabb sorszámot a legmagasabb, 27%-os adómértékhez a kitöltési útmutató 05.–07. sorainak sorrendje szerint.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '07', 'tax', 'Belföldi értékesítés 27%-os adómérték alá tartozó fizetendő adója', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 07. sor, adó oszlop.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '08', 'base', 'A tevékenység közérdekű vagy egyéb sajátos jellegére tekintettel, valamint egyéb okból adómentes termékértékesítés, szolgáltatásnyújtás ellenértéke', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 08. sor; Áfa tv. 85. §, 86. § és 87. §.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '18B', 'base', 'Közösségen belülről igénybe vett, a teljesítési hely általános szabálya alá tartozó szolgáltatás adóalapja — az igénybevevő oldala', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap kiegészítő 18B mező; Áfa tv. 37. § (1) a teljesítés helyéről, 138–140. § arról, hogy a belföldön le nem telepedett szolgáltatót nyújtó helyett a belföldi igénybevevő fizeti az adót — a 139. és 140. § pontos elhatárolása nem volt közvetlenül ellenőrizhető a törvény szövegéből, lásd README.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '18B', 'tax', 'Közösségen belülről igénybe vett szolgáltatás után önadózással fizetendő adó', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap kiegészítő 18B mező, adó oszlop.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '27', 'base', 'Harmadik országban letelepedett adóalanytól igénybe vett szolgáltatás adóalapja — az igénybevevő oldala', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 27. sor; Áfa tv. 37. § (1) a teljesítés helyéről, 138–140. § arról, hogy a belföldön le nem telepedett szolgáltatót nyújtó helyett a belföldi igénybevevő fizeti az adót.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '27', 'tax', 'Harmadik országban letelepedett adóalanytól igénybe vett szolgáltatás után önadózással fizetendő adó', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 27. sor, adó oszlop.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '29', 'tax', 'Fordított adózás alá eső, belföldön teljesített termékértékesítés, szolgáltatásnyújtás után az igénybevevő által önadózással fizetendő adó', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 29. sor; Áfa tv. 142. §. A nyomtatvány e sorhoz nem rendel önálló adóalap-oszlopot, csak a fizetendő adó összegét — az adóalapot a 04. sor hordozza az értékesítő bevallásában.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '92', 'base', 'Másik tagállamban letelepedett adóalany részére nyújtott, a teljesítési hely általános szabálya alá tartozó szolgáltatás ellenértéke — az értékesítő oldala', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-02 lap, 92. sor; Áfa tv. 37. § (1).', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '36ALAP', 'total', '36. sor — Fizetendő adó összesen, adóalap oszlop', '{}'::jsonb, 170, null, array['01', '02', '04', '05:base', '06:base', '07:base', '08', '27:base']::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 36. sor: „Ebben a sorban kell összesíteni adóalap és adó bontásban a 01-35. és 110. sorokban található részösszegeket.” A nyomtatvány egyetlen sorszáma (36) alatt két oszlopot (adóalap, adó) nyomtat; e pack — az olasz IT-DICH-IVA pack VE30C2/VE30C3 mintáját követve, kettőspont helyett betűjelzéssel — a két oszlopot 36ALAP és 36ADO azonosítóval különbözteti meg, mivel egy total csak egy képletet hordozhat. E pack a 110. sort (belföldi, 0%-os adómértékű ügyletek, Áfa tv. 82. § (4)) nem modellezi — lásd README.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '36ADO', 'total', '36. sor — Fizetendő adó összesen, adó oszlop', '{}'::jsonb, 180, null, array['05:tax', '06:tax', '07:tax', '27:tax', '29']::text[], '{}'::text[], null, null, false, false, null, '2665A-01-01 lap, 36. sor, adó oszlop — ugyanazon összesítő sor a 01-35. sorok adó oszlopára; lásd 36ALAP a sorszám-felbontásról.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '64', 'tax', 'Levonható előzetesen felszámított adó összesen', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '2665A-01-02 lap, 64. sor; Áfa tv. 120–121. §. A nyomtatvány a levonható adót több sorra (64., 65., 66., 68. sor) bontja, amelyek együtt adják a 109. sor összegét; e pack, mivel a 64–68. sorok pontos elhatárolását a rendelkezésre álló forrásokból nem lehetett megerősíteni, az összes levonható adót — a belföldi beszerzések és az önadózás alá eső ügyletek levonható részét egyaránt — ezen az egy soron összesíti. Lásd README.', 'nyomtatvany-2665'),
  ('HU', 'HU-AFA-2665', '85', 'total', 'A bevallási időszakban elszámolandó adó — pozitív előjellel fizetendő, negatív előjellel visszaigényelhető', '{}'::jsonb, 200, null, array['36ADO', '18B:tax']::text[], array['64']::text[], null, null, false, false, null, '2665A-01-02 lap, 85. sor („visszaigényelhető előzetesen felszámított adó”). A rendelkezésre álló forrásokból nem volt közvetlenül megerősíthető, hogy a nyomtatvány a fizetendő és a visszaigényelhető összeget egyetlen előjeles soron (mint az osztrák U30 095. Kennzahl-ja) vagy két külön sorban mutatja-e be; e pack — amíg ez nincs megerősítve — az osztrák mintát követve egyetlen előjeles összesítő sort ír, floor_zero nélkül. Egy felülvizsgálónak ezt a kitöltési útmutató teljes szövegén kell ellenőriznie a reviewed státusz előtt — lásd README.', 'nyomtatvany-2665')
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
  ('HU-SZT-EREDMENY-A', 'HU', 'default', 'Eredménykimutatás — összköltség eljárással, „A” változat', 'income_statement', 'HU-SZT', date '2016-01-01', null, 'Szvt. 71. § (2) — az eredmény megállapításának összköltség, illetve forgalmi költség eljárása szerinti tagolását a 2. és 3. számú melléklet tartalmazza; e pack az összköltség eljárás szerinti, 2. számú melléklet szerinti „A” változatot követi.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'HU', 'default', 'Mérleg — „A” változat', 'balance_sheet', 'HU-SZT', date '2016-01-01', null, 'A számvitelről szóló 2000. évi C. törvény 22. § — a mérleg tagolását az 1. számú melléklet tartalmazza, „A”, illetve „B” változatban; e pack az „A” változatot követi. A törvény betűkkel (A–G) és — az eszközoldalon — római számokkal jelöli a fő- és altételeket; e pack ugyanezeket a jelöléseket használja sorkódként.', 'szamviteli-torveny')
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
  ('HU-SZT-EREDMENY-A', '01', null, '01. Belföldi értékesítés nettó árbevétele', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 01. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '02', null, '02. Exportértékesítés nettó árbevétele', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 02. sor — e pack e soron mutatja be a Közösségen kívülre (8110), illetve a Közösségen belülre (8120) történő értékesítés árbevételét egyaránt, mivel a törvény szövege ezekhez külön sort nem rendel.', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'I', null, 'I. Értékesítés nettó árbevétele', '{}'::jsonb, 30, 1, true, array['01', '02']::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, I. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '03', null, '03. Saját termelésű készletek állományváltozása', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 03. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '04', null, '04. Saját előállítású eszközök aktivált értéke', '{}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 04. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'II', null, 'II. Aktivált saját teljesítmények értéke', '{}'::jsonb, 60, 1, true, array['03', '04']::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, II. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'III', null, 'III. Egyéb bevételek', '{}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, III. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '05', null, '05. Anyagköltség', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 05. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '06', null, '06. Igénybe vett szolgáltatások értéke', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 06. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '07', null, '07. Egyéb szolgáltatások értéke', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 07. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '08', null, '08. Eladott áruk beszerzési értéke', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 08. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '09', null, '09. Eladott (közvetített) szolgáltatások értéke', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 09. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'IV', null, 'IV. Anyagjellegű ráfordítások', '{}'::jsonb, 130, 1, true, array['05', '06', '07', '08', '09']::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, IV. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '10', null, '10. Bérköltség', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 10. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '11', null, '11. Személyi jellegű egyéb kifizetések', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 11. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', '12', null, '12. Bérjárulékok', '{}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, 12. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'V', null, 'V. Személyi jellegű ráfordítások', '{}'::jsonb, 170, 1, true, array['10', '11', '12']::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, V. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'VI', null, 'VI. Értékcsökkenési leírás', '{}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, VI. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'VII', null, 'VII. Egyéb ráfordítások', '{}'::jsonb, 190, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, VII. sor — e sor a le nem vonható áfát (8810) és a kerekítési különbözetet (8820) is hordozza.', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'A_EREDM', null, 'A) ÜZEMI (ÜZLETI) TEVÉKENYSÉG EREDMÉNYE', '{}'::jsonb, 200, 1, true, array['I', 'II', 'III']::text[], array['IV', 'V', 'VI', 'VII']::text[], null, 'Szvt. 2. számú melléklet, A) sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'VIII', null, 'VIII. Kapott (járó) osztalék és részesedés', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, VIII. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'IX', null, 'IX. Pénzügyi műveletek egyéb bevételei', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, IX. sor — e sor a kapott kamatokat (9110) és az árfolyamnyereséget (9120) is hordozza.', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'X', null, 'X. Fizetendő kamatok és kamatjellegű ráfordítások', '{}'::jsonb, 230, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, X. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'XII', null, 'XII. Pénzügyi műveletek egyéb ráfordításai', '{}'::jsonb, 240, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, XII. sor — e sor az árfolyamveszteséget (9210) hordozza.', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'B_EREDM', null, 'B) PÉNZÜGYI MŰVELETEK EREDMÉNYE', '{}'::jsonb, 250, 1, true, array['VIII', 'IX']::text[], array['X', 'XII']::text[], null, 'Szvt. 2. számú melléklet, B) sor — a XI. (részesedések, értékpapírok értékvesztése) sort e pack számlatükre nem hordozza, ezért itt nem szerepel.', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'C_EREDM', null, 'C) ADÓZÁS ELŐTTI EREDMÉNY', '{}'::jsonb, 260, 1, true, array['A_EREDM', 'B_EREDM']::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, C) sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'XIII', null, 'XIII. Adófizetési kötelezettség', '{}'::jsonb, 270, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 2. számú melléklet, XIII. sor', 'szamviteli-torveny'),
  ('HU-SZT-EREDMENY-A', 'D_EREDM', null, 'D) ADÓZOTT EREDMÉNY', '{}'::jsonb, 280, 1, true, array['C_EREDM']::text[], array['XIII']::text[], null, 'Szvt. 2. számú melléklet, D) sor', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'AKT', null, 'ESZKÖZÖK (AKTÍVÁK) ÖSSZESEN', '{}'::jsonb, 10, 1, true, array['A', 'B', 'C']::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet, eszközoldal', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'A', 'AKT', 'A) Befektetett eszközök', '{}'::jsonb, 20, 1, true, array['A.I', 'A.II', 'A.III']::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet A)', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'A.I', 'A', 'I. Immateriális javak', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet A) I.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'A.II', 'A', 'II. Tárgyi eszközök', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet A) II.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'A.III', 'A', 'III. Befektetett pénzügyi eszközök', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet A) III.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'B', 'AKT', 'B) Forgóeszközök', '{}'::jsonb, 60, 1, true, array['B.I', 'B.II', 'B.III', 'B.IV']::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet B)', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'B.I', 'B', 'I. Készletek', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet B) I.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'B.II', 'B', 'II. Követelések', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet B) II. — e sor a vevőkövetelések (2200) mellett a költségvetéssel szembeni, áfából eredő követelést (2230) és az elszámolási számlát (2240) is hordozza, mivel e pack számlatükre nem nyit ezekre külön római alcímet.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'B.III', 'B', 'III. Értékpapírok', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet B) III.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'B.IV', 'B', 'IV. Pénzeszközök', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet B) IV.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'C', 'AKT', 'C) Aktív időbeli elhatárolások', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet C)', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'PASS', null, 'FORRÁSOK (PASSZÍVÁK) ÖSSZESEN', '{}'::jsonb, 120, 1, true, array['D', 'E', 'F', 'G']::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet, forrásoldal', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D', 'PASS', 'D) Saját tőke', '{}'::jsonb, 130, 1, true, array['D.I', 'D.II', 'D.III', 'D.IV', 'D.V', 'D.VI', 'D.VII']::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D)', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.I', 'D', 'I. Jegyzett tőke', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) I.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.II', 'D', 'II. Jegyzett, de még be nem fizetett tőke (-)', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) II.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.III', 'D', 'III. Tőketartalék', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) III.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.IV', 'D', 'IV. Eredménytartalék', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) IV.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.V', 'D', 'V. Lekötött tartalék', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) V.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.VI', 'D', 'VI. Értékelési tartalék', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) VI.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'D.VII', 'D', 'VII. Adózott eredmény', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet D) VII. — a 2013/34/EU irányelv átültetése óta (2016-tól) a mérleg saját tőkéje közvetlenül az adózott eredményt mutatja, önálló mérleg szerinti eredmény tétel nélkül; az osztalékról szóló döntés a döntés évében rendezi az elhatárolást, nem az eredmény évében.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'E', 'PASS', 'E) Céltartalékok', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet E)', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'F', 'PASS', 'F) Kötelezettségek', '{}'::jsonb, 220, 1, true, array['F.I', 'F.II', 'F.III']::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet F)', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'F.I', 'F', 'I. Hátrasorolt kötelezettségek', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet F) I.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'F.II', 'F', 'II. Hosszú lejáratú kötelezettségek', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet F) II.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'F.III', 'F', 'III. Rövid lejáratú kötelezettségek', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet F) III. — e sor a szállítói kötelezettségek (6300) mellett a költségvetéssel szembeni, áfából eredő kötelezettséget (6330) is hordozza.', 'szamviteli-torveny'),
  ('HU-SZT-MERLEG-A', 'G', 'PASS', 'G) Passzív időbeli elhatárolások', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Szvt. 1. számú melléklet G)', 'szamviteli-torveny')
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
    ('HU-SZT-EREDMENY-A', '01', 10, 'code_range', '8100', '8109', null, 'any'),
    ('HU-SZT-EREDMENY-A', '02', 10, 'code_range', '8110', '8129', null, 'any'),
    ('HU-SZT-EREDMENY-A', '03', 10, 'code_range', '8200', '8209', null, 'any'),
    ('HU-SZT-EREDMENY-A', '04', 10, 'code_range', '8300', '8309', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'III', 10, 'code_range', '8400', '8409', null, 'any'),
    ('HU-SZT-EREDMENY-A', '05', 10, 'code_range', '8500', '8509', null, 'any'),
    ('HU-SZT-EREDMENY-A', '06', 10, 'code_range', '8510', '8519', null, 'any'),
    ('HU-SZT-EREDMENY-A', '07', 10, 'code_range', '8520', '8529', null, 'any'),
    ('HU-SZT-EREDMENY-A', '08', 10, 'code_range', '8530', '8539', null, 'any'),
    ('HU-SZT-EREDMENY-A', '09', 10, 'code_range', '8540', '8549', null, 'any'),
    ('HU-SZT-EREDMENY-A', '10', 10, 'code_range', '8600', '8609', null, 'any'),
    ('HU-SZT-EREDMENY-A', '11', 10, 'code_range', '8610', '8619', null, 'any'),
    ('HU-SZT-EREDMENY-A', '12', 10, 'code_range', '8620', '8629', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'VI', 10, 'code_range', '8700', '8709', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'VII', 10, 'code_range', '8800', '8829', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'VIII', 10, 'code_range', '9100', '9109', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'IX', 10, 'code_range', '9110', '9129', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'X', 10, 'code_range', '9200', '9209', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'XII', 10, 'code_range', '9210', '9219', null, 'any'),
    ('HU-SZT-EREDMENY-A', 'XIII', 10, 'code_range', '9300', '9309', null, 'any'),
    ('HU-SZT-MERLEG-A', 'A.I', 10, 'code_range', '1100', '1199', null, 'any'),
    ('HU-SZT-MERLEG-A', 'A.II', 10, 'code_range', '1200', '1299', null, 'any'),
    ('HU-SZT-MERLEG-A', 'A.III', 10, 'code_range', '1300', '1399', null, 'any'),
    ('HU-SZT-MERLEG-A', 'B.I', 10, 'code_range', '2100', '2199', null, 'any'),
    ('HU-SZT-MERLEG-A', 'B.II', 10, 'code_range', '2200', '2299', null, 'any'),
    ('HU-SZT-MERLEG-A', 'B.III', 10, 'code_range', '2300', '2399', null, 'any'),
    ('HU-SZT-MERLEG-A', 'B.IV', 10, 'code_range', '2400', '2499', null, 'any'),
    ('HU-SZT-MERLEG-A', 'C', 10, 'code_range', '3100', '3199', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.I', 10, 'code_range', '4100', '4199', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.II', 10, 'code_range', '4200', '4299', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.III', 10, 'code_range', '4300', '4399', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.IV', 10, 'code_range', '4400', '4499', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.V', 10, 'code_range', '4500', '4599', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.VI', 10, 'code_range', '4600', '4699', null, 'any'),
    ('HU-SZT-MERLEG-A', 'D.VII', 10, 'code_range', '4700', '4799', null, 'any'),
    ('HU-SZT-MERLEG-A', 'E', 10, 'code_range', '5100', '5199', null, 'any'),
    ('HU-SZT-MERLEG-A', 'F.I', 10, 'code_range', '6100', '6199', null, 'any'),
    ('HU-SZT-MERLEG-A', 'F.II', 10, 'code_range', '6200', '6299', null, 'any'),
    ('HU-SZT-MERLEG-A', 'F.III', 10, 'code_range', '6300', '6399', null, 'any'),
    ('HU-SZT-MERLEG-A', 'G', 10, 'code_range', '7100', '7199', null, 'any')
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
  ('HU', 'Magyarország', '{}'::jsonb, array['hu']::text[], 'HUF', '2200', '6300', '2240', '8820', '4400', '8100', '8510', '2410', '2400', 'KI', 'BE', 'VE', 'hu', 'result_accounts', '4710', '4720', null, 'NY', 'half_up', 5, '9120', '9210', null, null, null, null, '6330', '2230', null, null)
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
  number_format                 = '{CODE}/{YYYY}/{NNNN}',
  legal_payment_days            = 30,
  late_payment_reference        = 'A Polgári Törvénykönyvről szóló 2013. évi V. törvény (Ptk.) 6:130. §-a szerint, megállapodás hiányában, a pénztartozást a jogosult fizetési felszólításának, illetve számlájának kézhezvételétől számított harminc napon belül kell teljesíteni; vállalkozások közötti szerződésben hatvan napnál hosszabb határidő csak akkor köthető ki, ha az a szerződés tárgyára tekintettel kifejezetten nem méltánytalan a jogosultra nézve. A 2011/7/EU irányelv átültetése. E pack nem tudta a 6:130. §-t közvetlenül, a törvény teljes szövegéből ellenőrizni — a net.jogtar.hu kinyerése a Hatodik Könyv előtt megszakadt minden kísérletnél —, a fenti szöveg egybehangzó másodlagos jogi szakirodalmi forrásokból (ügyvédi irodák, szakcikkek) származik; egy felülvizsgálónak a törvény teljes szövegén kell ezt ellenőriznie a reviewed státusz előtt.',
  numbering_legal_reference     = 'Áfa tv. 169. § (1) b) — a számla kötelező adattartalma egyebek mellett a számla sorszáma, amely a számlát kétséget kizáróan azonosítja; a törvény szövege szerint a sorszámnak egyedinek, folytonosnak és kihagyásmentesnek kell lennie, ami — Ausztriával ellentétben, ahol a törvény csak az egyediséget írja elő — a gapless_per_year-t indokolja. Számlázó programmal kibocsátott számla esetén a folytonos, ismétlődés- és kihagyásmentes sorszámozást magának a programnak kell automatikusan biztosítania.',
  numbering_source_key          = 'afa-torveny',
  payment_terms_legal_reference = 'Ptk. 6:130. § — lásd documents.late_payment_reference; e pontot csak másodlagos forrásokból lehetett megerősíteni, lásd a fenti megjegyzést.',
  payment_terms_source_key      = 'ptk',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Áfa tv. 55. § (1) — az adófizetési kötelezettséget az a tény keletkezteti, amellyel az adóztatandó ügylet tényállásszerűen megvalósul (teljesítés); ez a főszabály. Áfa tv. 59. § — ha a teljesítést megelőzően fizetnek az ellenértékből (előleg), a fizetendő adó a fizetendő összeg jóváírásakor, kézhezvételekor keletkezik. A két ág együtt earliest_of_delivery_or_payment. Nem modellezve: a folyamatos teljesítésű ügyletekre vonatkozó 58. § szerinti különös szabály.',
  tax_point_source_key          = 'afa-torveny',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Számv. tv. 165. § (3) és 166. § — a könyvviteli nyilvántartásokba csak szabályszerűen kiállított bizonylat alapján szabad adatot bejegyezni, és a nyilvántartásba bejegyzett adatot bizonylat nélkül megváltoztatni nem lehet; egy könyvelt számlát ezért csak arra hivatkozó helyesbítő számlával (jóváírással) lehet érvényteleníteni, nem törléssel.',
  posted_edit_policy_source_key = 'szamviteli-torveny',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'E pack released_at napján egyetlen jogszabály sem kötelezi a vállalkozásokat arra, hogy egymás között az EN 16931 szemantikai adatmodelljére épülő strukturált elektronikus számlát (Peppol, Factur-X, XRechnung, egy PINT) váltsanak — a papír- vagy PDF-számla önmagában továbbra is érvényes. Ami kötelező, egy harmadik, e mezők egyikével sem leírható alak: az Áfa tv. 10. számú melléklete és a 158/A. §, valamint a 169–172. és 176. § szerinti adattartalom alapján minden, az Áfa tv. hatálya alá tartozó számláról — 2021. január 4-től a vevő adóalanyiságától és honosságától függetlenül — valós idejű adatszolgáltatást kell teljesíteni a NAV Online Számla rendszere felé: számlázó programmal kiállított számla esetén azonnal, XML-ben, emberi beavatkozás nélkül; kézi számla esetén a kibocsátás napját követő naptári napon (ha az áthárított adó eléri az 500 000 forintot) vagy négy naptári napon belül (egyéb esetben). Ez nem az EN 16931 modelljére épülő partnerek közötti csere (profile ezt írná le) és nem is a felek közötti számlaváltást helyettesítő állami clearance (mint Lengyelország KSeF-je vagy Olaszország SdI-je, ahol a számla csak a rendszeren áthaladva minősül kibocsátottnak/kézbesítettnek): a számla a felek között a megszokott módon jön létre és érvényes, a NAV csak annak adatait kapja meg, utólag, valós időben, ellenőrzési célból. A magnak nincs mezője erre a harmadik alakra — lásd docs/international.md, „From Hungary” szakasz. vat_scheme 9910 a magyar áfaalany-azonosító az EAS listán; party_scheme üresen marad, mert a cégjegyzékszámhoz nem található ISO 6523-kód, és vállalkozások között nincs kötelező hálózat vagy egységes címzési séma.',
  einvoice_source_key           = 'nav-online-szamla',
  party_scheme                  = null,
  vat_scheme                    = '9910',
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'HU';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('HU', 'reverse_charge', 'reverse_charge', 'Fordított adózás', '{}'::jsonb, 10, date '1970-01-01', null, 'Áfa tv. 142. § (7) — a fordított adózás alá eső ügyletről kibocsátott számla nem tartalmazhat áthárított adót, és a számlán fel kell tüntetni a fordított adózásra való utalást.'),
  ('HU', 'intra_eu_goods', 'intra_eu_goods', 'Adómentes Közösségen belüli termékértékesítés', '{}'::jsonb, 20, date '1970-01-01', null, 'Áfa tv. 89. § (1) — mentes az adó alól a termék Közösségen belüli értékesítése egy olyan, más tagállamban közösségi adószámmal rendelkező adóalany részére, aki a termékbeszerzés után saját tagállamában adófizetésre kötelezett.'),
  ('HU', 'intra_eu_services', 'intra_eu_services', 'Fordított adózás — a szolgáltatás igénybevevője a teljesítési hely szerinti tagállamban adófizetésre kötelezett', '{}'::jsonb, 30, date '1970-01-01', null, 'Áfa tv. 37. § (1) — az adóalanynak nyújtott szolgáltatás teljesítési helye az a hely, ahol a szolgáltatást igénybevevő adóalany gazdasági céllal letelepedett; a törvény adófizetésre kötelezettről szóló fejezete (138–140. §) az igénybevevőt teszi adófizetésre kötelezetté, ha a szolgáltatást nyújtó nem telepedett le belföldön — a 139. és 140. § pontos elhatárolása e pack készítése során nem volt közvetlenül ellenőrizhető a törvény szövegéből, lásd README.'),
  ('HU', 'export', 'export', 'Adómentes termékexport a Közösségen kívülre', '{}'::jsonb, 40, date '1970-01-01', null, 'Áfa tv. 98. § (1) — mentes az adó alól a termék Közösség területén kívülre történő értékesítése, feltéve hogy a termék az értékesítés következtében elhagyja a Közösség területét.'),
  ('HU', 'exempt', 'exempt', 'Adómentes ügylet', '{}'::jsonb, 50, date '1970-01-01', null, 'Áfa tv. 169. § h) — adómentesség esetén jogszabályi hivatkozás vagy bármely, arra utaló megjelölés feltüntetése, hogy a termékértékesítés vagy szolgáltatásnyújtás mentes az adó alól.'),
  ('HU', 'small_business', 'small_business', 'Alanyi adómentes — Áfa tv. 187–188. §', '{}'::jsonb, 60, date '1970-01-01', null, 'Áfa tv. 188. § (2) — alanyi adómentesség választható, ha az adóalany gazdasági céllal belföldön telepedett le, és sem a tárgy naptári évet megelőző évben, sem a tárgy naptári évben ésszerűen várhatóan nem haladja meg a 20 000 000 forintot; e küszöbérték a 377. § (1)-gyel módosítva 2026-tól. A törvény a mentesség tényét feltüntetteti a számlán (169. § h) is), a szövegre a szakmai gyakorlat szerinti megjelölést e pack sora adja meg. Egy egységes alkalmazási feltétel az egész vállalkozásra vonatkozik, amit egyetlen tétel adata nem hordoz — lásd a magban erről szóló megjegyzést.'),
  ('HU', 'late_payment', 'late_payment', 'Késedelmes fizetés esetén a Ptk. 6:130. §-a szerinti törvényes késedelmi kamat jár.', '{}'::jsonb, 70, date '1970-01-01', null, 'Ptk. 6:155. § — lásd documents.late_payment_reference a kamat mértékéről és a Ptk. 6:130. §-ról.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
