-- Ekwo OS — Polska: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/pl at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build pl`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Obwieszczenie Marszałka Sejmu Rzeczypospolitej Polskiej z dnia 21 maja 2025 r. w sprawie ogłoszenia jednolitego tekstu ustawy o podatku od towarów i usług (Dz. U. z 2025 r. poz. 775) (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20250000775
--   Ustawa z dnia 24 czerwca 2025 r. o zmianie ustawy o podatku od towarów i usług (Dz. U. z 2025 r. poz. 896) — podnosi próg zwolnienia podmiotowego art. 113 ust. 1 do 240 000 zł od 1 stycznia 2026 r. (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20250000896
--   Ustawa z dnia 16 czerwca 2023 r. o zmianie ustawy o podatku od towarów i usług oraz niektórych innych ustaw (Dz. U. z 2023 r. poz. 1598) — wprowadza obowiązkowe fakturowanie w Krajowym Systemie e-Faktur (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://eli.gov.pl/eli/DU/2023/1598
--   Ustawa z dnia 5 sierpnia 2025 r. o zmianie ustawy o podatku od towarów i usług oraz ustawy o zmianie ustawy o podatku od towarów i usług oraz niektórych innych ustaw (Dz. U. z 2025 r. poz. 1203) — harmonogram obowiązku KSeF według progu obrotu (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20250001203
--   Rozporządzenie Ministra Finansów, Inwestycji i Rozwoju z dnia 15 października 2019 r. w sprawie szczegółowego zakresu danych zawartych w deklaracjach podatkowych i w ewidencji w zakresie podatku od towarów i usług (Dz. U. z 2019 r. poz. 1988, z późn. zm., ost. zm. Dz. U. z 2025 r. poz. 1800) (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20190001988
--   JPK_VAT z deklaracją [JPK_V7M(3), JPK_V7K(3)] — broszura informacyjna dot. struktury, Warszawa, styczeń 2026 r. (Ministerstwo Finansów)
--     https://www.podatki.gov.pl/media/wgbkrejs/broszura-jpk_vat-z-deklaracj%C4%85-od-1-lutego-2026-r.pdf
--   Obwieszczenie Marszałka Sejmu Rzeczypospolitej Polskiej z dnia 30 marca 2026 r. w sprawie ogłoszenia jednolitego tekstu ustawy o rachunkowości (Dz. U. z 2026 r. poz. 522), w tym załącznik nr 1 — zakres informacji wykazywanych w sprawozdaniu finansowym (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20260000522
--   Obwieszczenie Marszałka Sejmu Rzeczypospolitej Polskiej w sprawie ogłoszenia jednolitego tekstu ustawy o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych (Dz. U. z 2023 r. poz. 1790) (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20230001790
--   Obwieszczenie Ministra Finansów i Gospodarki z dnia 22 czerwca 2026 r. w sprawie wysokości odsetek ustawowych za opóźnienie w transakcjach handlowych (M.P. z 2026 r. poz. 642) — 13,75 % (11,75 % wobec podmiotu leczniczego) na okres od 1 lipca do 31 grudnia 2026 r. (Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP))
--     https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WMP20260000642
--   Krajowy System e-Faktur (KSeF) — informacje ogólne, podstawy prawne oraz kluczowe terminy (Ministerstwo Finansów / Krajowa Administracja Skarbowa)
--     https://ksef.podatki.gov.pl/informacje-ogolne-ksef-20/podstawy-prawne-oraz-kluczowe-terminy/
--   Struktura logiczna faktury ustrukturyzowanej FA(3), w mocy od 1 lutego 2026 r. (wzór opublikowany w CRWDE 25 czerwca 2025 r., http://crd.gov.pl/wzor/2025/06/25/13775/) (Ministerstwo Finansów / Krajowa Administracja Skarbowa)
--     https://ksef.podatki.gov.pl/informacje-ogolne-ksef-20/struktura-logiczna-fa-3/
--   Mechanizm podzielonej płatności (MPP) — poradnik (Ministerstwo Finansów)
--     https://www.podatki.gov.pl/podatki-firmowe/vat/poradniki-i-informatory/mechanizm-podzielonej-platnosci-mpp
--   Portal podatki.gov.pl — usługi elektroniczne do złożenia JPK_VAT z deklaracją (Ministerstwo Finansów)
--     https://www.podatki.gov.pl/jednolity-plik-kontrolny/jpk-vat-z-deklaracja
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
  ('PL', 'Polska', '0.1.0', date '2026-09-22', '20260921145425', 'community', null, null, 'b161d022050d5e62273344e501721521ab17400b3f89e286b739beade9f73bb2', '[{"key":"ustawa-vat","title":"Obwieszczenie Marszałka Sejmu Rzeczypospolitej Polskiej z dnia 21 maja 2025 r. w sprawie ogłoszenia jednolitego tekstu ustawy o podatku od towarów i usług (Dz. U. z 2025 r. poz. 775)","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20250000775","consulted_on":"2026-09-22","kind":"law"},{"key":"ustawa-vat-zwolnienie-2026","title":"Ustawa z dnia 24 czerwca 2025 r. o zmianie ustawy o podatku od towarów i usług (Dz. U. z 2025 r. poz. 896) — podnosi próg zwolnienia podmiotowego art. 113 ust. 1 do 240 000 zł od 1 stycznia 2026 r.","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20250000896","consulted_on":"2026-09-22","kind":"law"},{"key":"ustawa-ksef-2023","title":"Ustawa z dnia 16 czerwca 2023 r. o zmianie ustawy o podatku od towarów i usług oraz niektórych innych ustaw (Dz. U. z 2023 r. poz. 1598) — wprowadza obowiązkowe fakturowanie w Krajowym Systemie e-Faktur","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://eli.gov.pl/eli/DU/2023/1598","consulted_on":"2026-09-22","kind":"law"},{"key":"ustawa-ksef-2025","title":"Ustawa z dnia 5 sierpnia 2025 r. o zmianie ustawy o podatku od towarów i usług oraz ustawy o zmianie ustawy o podatku od towarów i usług oraz niektórych innych ustaw (Dz. U. z 2025 r. poz. 1203) — harmonogram obowiązku KSeF według progu obrotu","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20250001203","consulted_on":"2026-09-22","kind":"law"},{"key":"rozporzadzenie-jpk","title":"Rozporządzenie Ministra Finansów, Inwestycji i Rozwoju z dnia 15 października 2019 r. w sprawie szczegółowego zakresu danych zawartych w deklaracjach podatkowych i w ewidencji w zakresie podatku od towarów i usług (Dz. U. z 2019 r. poz. 1988, z późn. zm., ost. zm. Dz. U. z 2025 r. poz. 1800)","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20190001988","consulted_on":"2026-09-22","kind":"regulation"},{"key":"broszura-jpk","title":"JPK_VAT z deklaracją [JPK_V7M(3), JPK_V7K(3)] — broszura informacyjna dot. struktury, Warszawa, styczeń 2026 r.","publisher":"Ministerstwo Finansów","url":"https://www.podatki.gov.pl/media/wgbkrejs/broszura-jpk_vat-z-deklaracj%C4%85-od-1-lutego-2026-r.pdf","consulted_on":"2026-09-22","kind":"form"},{"key":"ustawa-rachunkowosc","title":"Obwieszczenie Marszałka Sejmu Rzeczypospolitej Polskiej z dnia 30 marca 2026 r. w sprawie ogłoszenia jednolitego tekstu ustawy o rachunkowości (Dz. U. z 2026 r. poz. 522), w tym załącznik nr 1 — zakres informacji wykazywanych w sprawozdaniu finansowym","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20260000522","consulted_on":"2026-09-22","kind":"law"},{"key":"ustawa-oplaty","title":"Obwieszczenie Marszałka Sejmu Rzeczypospolitej Polskiej w sprawie ogłoszenia jednolitego tekstu ustawy o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych (Dz. U. z 2023 r. poz. 1790)","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20230001790","consulted_on":"2026-09-22","kind":"law"},{"key":"mp-odsetki-2026-2","title":"Obwieszczenie Ministra Finansów i Gospodarki z dnia 22 czerwca 2026 r. w sprawie wysokości odsetek ustawowych za opóźnienie w transakcjach handlowych (M.P. z 2026 r. poz. 642) — 13,75 % (11,75 % wobec podmiotu leczniczego) na okres od 1 lipca do 31 grudnia 2026 r.","publisher":"Kancelaria Sejmu — Internetowy System Aktów Prawnych (ISAP)","url":"https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WMP20260000642","consulted_on":"2026-09-22","kind":"guidance"},{"key":"ksef-portal","title":"Krajowy System e-Faktur (KSeF) — informacje ogólne, podstawy prawne oraz kluczowe terminy","publisher":"Ministerstwo Finansów / Krajowa Administracja Skarbowa","url":"https://ksef.podatki.gov.pl/informacje-ogolne-ksef-20/podstawy-prawne-oraz-kluczowe-terminy/","consulted_on":"2026-09-22","kind":"portal"},{"key":"ksef-fa3","title":"Struktura logiczna faktury ustrukturyzowanej FA(3), w mocy od 1 lutego 2026 r. (wzór opublikowany w CRWDE 25 czerwca 2025 r., http://crd.gov.pl/wzor/2025/06/25/13775/)","publisher":"Ministerstwo Finansów / Krajowa Administracja Skarbowa","url":"https://ksef.podatki.gov.pl/informacje-ogolne-ksef-20/struktura-logiczna-fa-3/","consulted_on":"2026-09-22","kind":"standard"},{"key":"mpp-portal","title":"Mechanizm podzielonej płatności (MPP) — poradnik","publisher":"Ministerstwo Finansów","url":"https://www.podatki.gov.pl/podatki-firmowe/vat/poradniki-i-informatory/mechanizm-podzielonej-platnosci-mpp","consulted_on":"2026-09-22","kind":"guidance"},{"key":"e-deklaracje-portal","title":"Portal podatki.gov.pl — usługi elektroniczne do złożenia JPK_VAT z deklaracją","publisher":"Ministerstwo Finansów","url":"https://www.podatki.gov.pl/jednolity-plik-kontrolny/jpk-vat-z-deklaracja","consulted_on":"2026-09-22","kind":"portal"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-22","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-22","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-22","kind":"standard"}]'::jsonb)
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
  ('PL', 'default', 'Plan kont odpowiadający załącznikowi nr 1 do ustawy o rachunkowości', '{}'::jsonb, true, 'companies', array['PL-UOR-BILANS', 'PL-UOR-RZIS-POROWNAWCZY']::text[], null, 'Ustawa o rachunkowości art. 10 ust. 1 pkt 3 lit. a nakazuje à chaque jednostce de tenir sa propre documentation décrivant son zakładowy plan kont — la loi n''impose pas de plan de comptes national (contrairement, par exemple, au plan comptable français). Le plan-type à neuf groupes (zespoły 0 à 9) enseigné dans la pratique comptable polonaise est un usage professionnel et non une obligation légale ; ce pack ne le reprend pas et propose à la place un plan à quatre chiffres dont le premier chiffre renvoie directement à la lettre de la section du bilan (art. 45 et załącznik nr 1) : 1 Aktywa trwałe (A), 2 Aktywa obrotowe (B), 3 Należne wpłaty i udziały własne (C, D), 4 Kapitał własny (A pasywów), 5 Rezerwy na zobowiązania (B.I pasywów), 6 Zobowiązania długoterminowe (B.II), 7 Zobowiązania krótkoterminowe et rozliczenia międzyokresowe bierne (B.III, B.IV), 8 et 9 postes du rachunek zysków i strat en wariant porównawczy (załącznik nr 1). Chaque compte porte donc, par construction, le poste légal auquel il se rattache.', 'ustawa-rachunkowosc')
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
  ('PL', 'default', '1000', 'A. Aktywa trwałe', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('PL', 'default', '1100', 'I. Wartości niematerialne i prawne', '{}'::jsonb, 'asset_fixed', false, '1000', 20),
  ('PL', 'default', '1110', 'Koszty zakończonych prac rozwojowych', '{}'::jsonb, 'asset_fixed', false, '1100', 30),
  ('PL', 'default', '1120', 'Wartość firmy', '{}'::jsonb, 'asset_fixed', false, '1100', 40),
  ('PL', 'default', '1130', 'Inne wartości niematerialne i prawne', '{}'::jsonb, 'asset_fixed', false, '1100', 50),
  ('PL', 'default', '1140', 'Zaliczki na wartości niematerialne i prawne', '{}'::jsonb, 'asset_fixed', false, '1100', 60),
  ('PL', 'default', '1200', 'II. Rzeczowe aktywa trwałe', '{}'::jsonb, 'asset_fixed', false, '1000', 70),
  ('PL', 'default', '1210', '1. Środki trwałe', '{}'::jsonb, 'asset_fixed', false, '1200', 80),
  ('PL', 'default', '1211', 'a) Grunty (w tym prawo użytkowania wieczystego gruntu)', '{}'::jsonb, 'asset_fixed', false, '1210', 90),
  ('PL', 'default', '1212', 'b) Budynki lokale prawa do lokali i obiekty inżynierii lądowej i wodnej', '{}'::jsonb, 'asset_fixed', false, '1210', 100),
  ('PL', 'default', '1213', 'c) Urządzenia techniczne i maszyny', '{}'::jsonb, 'asset_fixed', false, '1210', 110),
  ('PL', 'default', '1214', 'd) Środki transportu', '{}'::jsonb, 'asset_fixed', false, '1210', 120),
  ('PL', 'default', '1215', 'e) Inne środki trwałe', '{}'::jsonb, 'asset_fixed', false, '1210', 130),
  ('PL', 'default', '1220', '2. Środki trwałe w budowie', '{}'::jsonb, 'asset_fixed', false, '1200', 140),
  ('PL', 'default', '1230', '3. Zaliczki na środki trwałe w budowie', '{}'::jsonb, 'asset_fixed', false, '1200', 150),
  ('PL', 'default', '1300', 'III. Należności długoterminowe', '{}'::jsonb, 'asset_non_current', false, '1000', 160),
  ('PL', 'default', '1310', 'Należności długoterminowe od pozostałych jednostek', '{}'::jsonb, 'asset_non_current', false, '1300', 170),
  ('PL', 'default', '1400', 'IV. Inwestycje długoterminowe', '{}'::jsonb, 'asset_non_current', false, '1000', 180),
  ('PL', 'default', '1410', 'Długoterminowe aktywa finansowe', '{}'::jsonb, 'asset_non_current', false, '1400', 190),
  ('PL', 'default', '1420', 'Inne inwestycje długoterminowe', '{}'::jsonb, 'asset_non_current', false, '1400', 200),
  ('PL', 'default', '1500', 'V. Długoterminowe rozliczenia międzyokresowe', '{}'::jsonb, 'asset_non_current', false, '1000', 210),
  ('PL', 'default', '1510', '1. Aktywa z tytułu odroczonego podatku dochodowego', '{}'::jsonb, 'asset_non_current', false, '1500', 220),
  ('PL', 'default', '1520', '2. Inne rozliczenia międzyokresowe długoterminowe', '{}'::jsonb, 'asset_non_current', false, '1500', 230),
  ('PL', 'default', '2000', 'B. Aktywa obrotowe', '{}'::jsonb, 'asset_current', false, null, 240),
  ('PL', 'default', '2100', 'I. Zapasy', '{}'::jsonb, 'asset_current', false, '2000', 250),
  ('PL', 'default', '2110', '1. Materiały', '{}'::jsonb, 'asset_current', false, '2100', 260),
  ('PL', 'default', '2120', '2. Półprodukty i produkty w toku', '{}'::jsonb, 'asset_current', false, '2100', 270),
  ('PL', 'default', '2130', '3. Produkty gotowe', '{}'::jsonb, 'asset_current', false, '2100', 280),
  ('PL', 'default', '2140', '4. Towary', '{}'::jsonb, 'asset_current', false, '2100', 290),
  ('PL', 'default', '2150', '5. Zaliczki na dostawy i usługi', '{}'::jsonb, 'asset_prepayments', false, '2100', 300),
  ('PL', 'default', '2200', 'II. Należności krótkoterminowe', '{}'::jsonb, 'asset_current', false, '2000', 310),
  ('PL', 'default', '2210', '1. Należności od jednostek powiązanych', '{}'::jsonb, 'asset_current', false, '2200', 312),
  ('PL', 'default', '2220', '2. Należności od pozostałych jednostek w których jednostka posiada zaangażowanie w kapitale', '{}'::jsonb, 'asset_current', false, '2200', 314),
  ('PL', 'default', '2230', 'a) Należności z tytułu dostaw i usług', '{}'::jsonb, 'asset_receivable', true, '2200', 320),
  ('PL', 'default', '2240', 'b) Należności z tytułu podatków dotacji ceł ubezpieczeń społecznych i zdrowotnych oraz innych świadczeń', '{}'::jsonb, 'asset_current', false, '2200', 330),
  ('PL', 'default', '2241', 'VAT naliczony podlegający odliczeniu', '{}'::jsonb, 'asset_current', true, '2240', 340),
  ('PL', 'default', '2242', 'Rozrachunki z urzędem skarbowym z tytułu VAT — nadwyżka do zwrotu', '{}'::jsonb, 'asset_current', true, '2240', 350),
  ('PL', 'default', '2250', 'c) Pozostałe należności krótkoterminowe', '{}'::jsonb, 'asset_current', false, '2200', 360),
  ('PL', 'default', '2260', 'd) Należności dochodzone na drodze sądowej', '{}'::jsonb, 'asset_current', false, '2200', 370),
  ('PL', 'default', '2270', 'Rozrachunki nierozliczone (konto przejściowe)', '{}'::jsonb, 'asset_current', false, '2200', 380),
  ('PL', 'default', '2300', 'III. Inwestycje krótkoterminowe', '{}'::jsonb, 'asset_current', false, '2000', 390),
  ('PL', 'default', '2310', 'Kasa', '{}'::jsonb, 'asset_cash', false, '2300', 400),
  ('PL', 'default', '2320', 'Rachunki bankowe', '{}'::jsonb, 'asset_cash', true, '2300', 410),
  ('PL', 'default', '2321', 'Rachunek VAT (mechanizm podzielonej płatności)', '{}'::jsonb, 'asset_cash', true, '2300', 420),
  ('PL', 'default', '2340', 'Krótkoterminowe aktywa finansowe pozostałe', '{}'::jsonb, 'asset_current', false, '2300', 430),
  ('PL', 'default', '2400', 'IV. Krótkoterminowe rozliczenia międzyokresowe', '{}'::jsonb, 'asset_prepayments', false, '2000', 440),
  ('PL', 'default', '3100', 'C. Należne wpłaty na kapitał (fundusz) podstawowy', '{}'::jsonb, 'asset_current', false, null, 450),
  ('PL', 'default', '3200', 'D. Udziały (akcje) własne', '{}'::jsonb, 'asset_current', false, null, 460),
  ('PL', 'default', '4100', 'I. Kapitał (fundusz) podstawowy', '{}'::jsonb, 'equity', false, null, 470),
  ('PL', 'default', '4200', 'II. Kapitał (fundusz) zapasowy', '{}'::jsonb, 'equity', false, null, 480),
  ('PL', 'default', '4300', 'III. Kapitał (fundusz) z aktualizacji wyceny', '{}'::jsonb, 'equity', false, null, 490),
  ('PL', 'default', '4400', 'IV. Pozostałe kapitały (fundusze) rezerwowe', '{}'::jsonb, 'equity', false, null, 500),
  ('PL', 'default', '4500', 'V. Zysk (strata) z lat ubiegłych', '{}'::jsonb, 'equity_retained', false, null, 510),
  ('PL', 'default', '4610', 'VI. Zysk netto roku obrotowego', '{}'::jsonb, 'equity', false, null, 520),
  ('PL', 'default', '4620', 'VI. Strata netto roku obrotowego (wielkość ujemna)', '{}'::jsonb, 'equity', false, null, 530),
  ('PL', 'default', '4700', 'VII. Odpisy z zysku netto w ciągu roku obrotowego (wielkość ujemna)', '{}'::jsonb, 'equity', false, null, 540),
  ('PL', 'default', '5100', '1. Rezerwa z tytułu odroczonego podatku dochodowego', '{}'::jsonb, 'liability_non_current', false, null, 550),
  ('PL', 'default', '5200', '2. Rezerwa na świadczenia emerytalne i podobne', '{}'::jsonb, 'liability_non_current', false, null, 560),
  ('PL', 'default', '5300', '3. Pozostałe rezerwy na zobowiązania', '{}'::jsonb, 'liability_non_current', false, null, 570),
  ('PL', 'default', '6100', 'a) Kredyty i pożyczki długoterminowe', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('PL', 'default', '6200', 'b) Zobowiązania z tytułu emisji dłużnych papierów wartościowych długoterminowe', '{}'::jsonb, 'liability_non_current', false, null, 590),
  ('PL', 'default', '6300', 'c) Inne zobowiązania finansowe długoterminowe', '{}'::jsonb, 'liability_non_current', false, null, 600),
  ('PL', 'default', '6400', 'd) Inne zobowiązania długoterminowe', '{}'::jsonb, 'liability_non_current', false, null, 610),
  ('PL', 'default', '7100', 'a) Kredyty i pożyczki krótkoterminowe', '{}'::jsonb, 'liability_current', false, null, 620),
  ('PL', 'default', '7200', 'b) Zobowiązania z tytułu emisji dłużnych papierów wartościowych krótkoterminowe', '{}'::jsonb, 'liability_current', false, null, 630),
  ('PL', 'default', '7300', 'c) Inne zobowiązania finansowe krótkoterminowe', '{}'::jsonb, 'liability_current', false, null, 640),
  ('PL', 'default', '7400', 'd) Zobowiązania z tytułu dostaw i usług', '{}'::jsonb, 'liability_payable', true, null, 650),
  ('PL', 'default', '7500', 'e) Zaliczki otrzymane na dostawy i usługi', '{}'::jsonb, 'liability_current', false, null, 660),
  ('PL', 'default', '7600', 'f) Zobowiązania wekslowe', '{}'::jsonb, 'liability_current', false, null, 670),
  ('PL', 'default', '7700', 'g) Zobowiązania z tytułu podatków ceł ubezpieczeń społecznych i zdrowotnych oraz innych świadczeń', '{}'::jsonb, 'liability_current', false, null, 680),
  ('PL', 'default', '7710', 'VAT należny', '{}'::jsonb, 'liability_current', false, '7700', 690),
  ('PL', 'default', '7720', 'Rozrachunki z urzędem skarbowym z tytułu VAT — zobowiązanie', '{}'::jsonb, 'liability_current', true, '7700', 700),
  ('PL', 'default', '7730', 'Pozostałe zobowiązania publicznoprawne', '{}'::jsonb, 'liability_current', false, '7700', 710),
  ('PL', 'default', '7800', 'h) Zobowiązania z tytułu wynagrodzeń', '{}'::jsonb, 'liability_current', false, null, 720),
  ('PL', 'default', '7900', 'i) Inne zobowiązania krótkoterminowe', '{}'::jsonb, 'liability_current', false, null, 730),
  ('PL', 'default', '7950', '4. Fundusze specjalne', '{}'::jsonb, 'liability_current', false, null, 740),
  ('PL', 'default', '7960', '1. Rozliczenia międzyokresowe bierne krótkoterminowe', '{}'::jsonb, 'liability_current', false, null, 750),
  ('PL', 'default', '7970', '2. Ujemna wartość firmy', '{}'::jsonb, 'liability_non_current', false, null, 760),
  ('PL', 'default', '8100', 'I. Przychody netto ze sprzedaży produktów', '{}'::jsonb, 'income', false, null, 770),
  ('PL', 'default', '8110', 'II. Zmiana stanu produktów', '{}'::jsonb, 'income', false, null, 780),
  ('PL', 'default', '8120', 'III. Koszt wytworzenia produktów na własne potrzeby jednostki', '{}'::jsonb, 'income', false, null, 790),
  ('PL', 'default', '8130', 'IV. Przychody netto ze sprzedaży towarów i materiałów', '{}'::jsonb, 'income', false, null, 800),
  ('PL', 'default', '8210', 'I. Amortyzacja', '{}'::jsonb, 'expense_depreciation', false, null, 810),
  ('PL', 'default', '8220', 'II. Zużycie materiałów i energii — materiały biurowe', '{}'::jsonb, 'expense', false, null, 820),
  ('PL', 'default', '8221', 'II. Zużycie materiałów i energii — energia elektryczna i cieplna', '{}'::jsonb, 'expense', false, null, 822),
  ('PL', 'default', '8222', 'II. Zużycie materiałów i energii — paliwo i woda', '{}'::jsonb, 'expense', false, null, 824),
  ('PL', 'default', '8230', 'III. Usługi obce — pozostałe', '{}'::jsonb, 'expense', false, null, 830),
  ('PL', 'default', '8231', 'III. Usługi obce — telekomunikacyjne i internet', '{}'::jsonb, 'expense', false, null, 831),
  ('PL', 'default', '8232', 'III. Usługi obce — najem i dzierżawa', '{}'::jsonb, 'expense', false, null, 832),
  ('PL', 'default', '8233', 'III. Usługi obce — doradcze prawne i księgowe', '{}'::jsonb, 'expense', false, null, 833),
  ('PL', 'default', '8234', 'III. Usługi obce — transportowe', '{}'::jsonb, 'expense', false, null, 834),
  ('PL', 'default', '8235', 'III. Usługi obce — remontowe i konserwacyjne', '{}'::jsonb, 'expense', false, null, 835),
  ('PL', 'default', '8240', 'IV. Podatki i opłaty', '{}'::jsonb, 'expense', false, null, 840),
  ('PL', 'default', '8250', 'V. Wynagrodzenia', '{}'::jsonb, 'expense', false, null, 850),
  ('PL', 'default', '8260', 'VI. Ubezpieczenia społeczne i inne świadczenia', '{}'::jsonb, 'expense', false, null, 860),
  ('PL', 'default', '8270', 'VII. Pozostałe koszty rodzajowe — pozostałe', '{}'::jsonb, 'expense', false, null, 870),
  ('PL', 'default', '8271', 'VII. Pozostałe koszty rodzajowe — ubezpieczenia majątkowe', '{}'::jsonb, 'expense', false, null, 871),
  ('PL', 'default', '8272', 'VII. Pozostałe koszty rodzajowe — reprezentacja i reklama', '{}'::jsonb, 'expense', false, null, 872),
  ('PL', 'default', '8273', 'VII. Pozostałe koszty rodzajowe — podróże służbowe', '{}'::jsonb, 'expense', false, null, 873),
  ('PL', 'default', '8280', 'VIII. Wartość sprzedanych towarów i materiałów', '{}'::jsonb, 'expense_direct_cost', false, null, 880),
  ('PL', 'default', '8310', 'D. Pozostałe przychody operacyjne', '{}'::jsonb, 'income_other', false, null, 890),
  ('PL', 'default', '8320', 'E. Pozostałe koszty operacyjne (w tym zaokrąglenia)', '{}'::jsonb, 'expense', false, null, 900),
  ('PL', 'default', '8410', 'Przychody finansowe — pozostałe', '{}'::jsonb, 'income_other', false, null, 910),
  ('PL', 'default', '8411', 'Przychody finansowe — dodatnie różnice kursowe', '{}'::jsonb, 'income_other', false, null, 920),
  ('PL', 'default', '8420', 'Koszty finansowe — pozostałe', '{}'::jsonb, 'expense', false, null, 930),
  ('PL', 'default', '8421', 'Koszty finansowe — ujemne różnice kursowe', '{}'::jsonb, 'expense', false, null, 940),
  ('PL', 'default', '8500', 'J. Podatek dochodowy', '{}'::jsonb, 'expense', false, null, 950),
  ('PL', 'default', '8510', 'K. Pozostałe obowiązkowe zmniejszenia zysku (zwiększenia straty)', '{}'::jsonb, 'expense', false, null, 960)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PL', 'BANK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('PL', 'BO', 'Bilans otwarcia', '{}'::jsonb, 'opening', 60),
  ('PL', 'KASA', 'Kasa', '{}'::jsonb, 'cash', 40),
  ('PL', 'OG', 'Operacje pozostałe', '{}'::jsonb, 'general', 50),
  ('PL', 'SP', 'Sprzedaż', '{}'::jsonb, 'sales', 10),
  ('PL', 'ZA', 'Zakupy', '{}'::jsonb, 'purchase', 20)
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
  ('PL', 'PL-P-23', 'VAT zakup 23% — towary i usługi pozostałe', '{}'::jsonb, 'Achat domestique au taux standard, hors immobilisations. Pole P_42 (net) et P_43 (VAT).', 'percent', 23, 'purchase', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 86 ust. 1 — droit à déduction de la taxe facturée par un fournisseur national, dans la mesure où les biens ou services acquis servent des opérations taxées ; le taux facturé par le fournisseur est celui de l''art. 41 ust. 1 en liaison avec l''art. 146ef ust. 1 pkt 1 (voir PL-S-23).', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-23-POJAZD', 'VAT zakup 23% — pojazd samochodowy, odliczenie 50%', '{}'::jsonb, 'Frais liés à un véhicule à usage mixte : seule la moitié de la taxe est déductible. Pole P_42 (valeur nette entière) et P_43 (VAT — seulement la moitié déductible).', 'percent', 23, 'purchase', 'domestic', date '2014-04-01', null, 'Ustawa o VAT art. 86a ust. 1 — pour les dépenses liées aux véhicules à moteur utilisés à la fois pour l''activité de l''assujetti et à d''autres fins, le montant de la taxe déductible est de 50 % du montant facturé, sauf tenue d''un registre du kilométrage démontrant un usage exclusivement professionnel (art. 86a ust. 3-4).', null, null, 140, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-23-ST', 'VAT zakup 23% — środki trwałe', '{}'::jsonb, 'Achat domestique d''une immobilisation au taux standard. Pole P_40 (net) et P_41 (VAT).', 'percent', 23, 'purchase', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 86 ust. 1 ; le formulaire distingue en P_40/P_41 la valeur nette et la taxe des acquisitions classées par l''acquéreur parmi ses środki trwałe, séparément des autres achats (P_42/P_43).', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-5', 'VAT zakup 5% — towary i usługi pozostałe', '{}'::jsonb, 'Achat domestique au taux réduit de 5 %. Pole P_42 (net) et P_43 (VAT).', 'percent', 5, 'purchase', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 86 ust. 1 en liaison avec l''art. 41 ust. 2a (voir PL-S-5).', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-8', 'VAT zakup 8% — towary i usługi pozostałe', '{}'::jsonb, 'Achat domestique au taux réduit de 8 %. Pole P_42 (net) et P_43 (VAT).', 'percent', 8, 'purchase', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 86 ust. 1 en liaison avec l''art. 41 ust. 2 et l''art. 146ef ust. 1 pkt 2 (voir PL-S-8).', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-IMPORT-23', 'Import towarów rozliczany zgodnie z art. 33a 23%', '{}'::jsonb, 'Import de biens hors Union sous la procédure simplifiée de l''art. 33a : la taxe due sur la déclaration douanière est déclarée et déduite sur la déclaration de TVA elle-même. Base en P_25 et P_42, taxe due en P_26, taxe déduite en P_43.', 'percent', 23, 'purchase', 'import', date '2011-01-01', null, 'Ustawa o VAT art. 33a — sur autorisation, l''assujetti déclare la taxe due sur l''importation directement dans la déclaration de TVA plutôt que de la verser au bureau des douanes ; art. 86 ust. 2 pkt 2 — la même taxe ouvre droit à déduction. Le régime de droit commun (taxe versée à la douane sur la base du document douanier) n''est pas modélisé ici : voir docs/international.md, section « From Poland ».', null, null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-RC-17-1-5', 'Dostawa towarów, dla której podatnikiem jest nabywca (art. 17 ust. 1 pkt 5) 23%', '{}'::jsonb, 'Achat de biens livrés en Pologne par un fournisseur qui n''y a ni siège ni établissement stable : l''acquéreur liquide lui-même la taxe. Base en P_31 et P_42, taxe due en P_32, taxe déduite en P_43.', 'percent', 23, 'purchase', 'domestic_reverse_charge', date '2013-04-01', null, 'Ustawa o VAT art. 17 ust. 1 pkt 5 — l''acquéreur, assujetti établi en Pologne, est redevable de la taxe lorsque le fournisseur n''a en Pologne ni siège ni établissement stable participant à la livraison (et n''est pas identifié selon l''art. 96 ust. 4) ; art. 86 ust. 2 pkt 4 lit. b — déduction dans la même déclaration.', 'AE', 'VATEX-EU-AE', 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-USLUGI-SPOZA-UE-23', 'Import usług od podatnika spoza UE 23%', '{}'::jsonb, 'Service reçu d''un prestataire établi hors de l''Union, non identifié à la TVA d''un autre État membre. Base en P_27 et P_42, taxe due en P_28, taxe déduite en P_43.', 'percent', 23, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'Ustawa o VAT art. 17 ust. 1 pkt 4 et art. 28b — le preneur liquide lui-même la taxe ; ce code couvre les prestataires que l''art. 29 (déclaration P_29/P_30) n''atteint pas, c''est-à-dire non identifiés à la taxe sur la valeur ajoutée d''un autre État membre.', null, null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-USLUGI-UE-23', 'Import usług od podatnika z UE (art. 28b) 23%', '{}'::jsonb, 'Service reçu d''un assujetti établi dans un autre État membre, sous la règle générale B2B. Base en P_29 et P_42, taxe due en P_30, taxe déduite en P_43.', 'percent', 23, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'Ustawa o VAT art. 17 ust. 1 pkt 4 et art. 28b — le preneur, assujetti établi en Pologne, liquide lui-même la taxe sur une prestation dont le lieu est fixé au siège de l''acquéreur ; art. 86 ust. 2 pkt 4 lit. a — déduction dans la même déclaration.', 'K', 'VATEX-EU-IC', 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-WNT-23', 'Wewnątrzwspólnotowe nabycie towarów 23%', '{}'::jsonb, 'Acquisition intracommunautaire de biens, autoliquidée intégralement déductible. Base en P_23 et P_42, taxe due en P_24, taxe déduite en P_43.', 'percent', 23, 'purchase', 'intracom_acquisition_goods', date '2011-01-01', null, 'Ustawa o VAT art. 17 ust. 1 pkt 3 et art. 20 — l''acquéreur liquide lui-même la taxe sur l''acquisition intracommunautaire, au taux de l''art. 41 ust. 1 en liaison avec l''art. 146ef ; art. 86 ust. 2 pkt 4 lit. c — la même taxe ouvre droit à déduction dans la même déclaration, sans passer par un compte fournisseur.', 'K', 'VATEX-EU-IC', 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-P-ZW', 'Zakup zwolniony lub niepodlegający VAT', '{}'::jsonb, 'Achat d''un bien ou service exonéré ou hors champ (par exemple une prime d''assurance) : aucune taxe à déduire, aucune case de la déclaration.', 'percent', 0, 'purchase', 'exempt', date '2004-05-01', null, 'Ustawa o VAT art. 86 ust. 1 — faute de taxe facturée par le fournisseur (l''assurance étant elle-même exonérée par l''art. 43 ust. 1 pkt 37), il n''y a rien à déduire ni à déclarer côté acquéreur.', null, null, 200, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-23', 'VAT sprzedaż 23%', '{}'::jsonb, 'Stawka podstawowa, sprzedaż krajowa. Pola P_19 (podstawa) i P_20 (podatek).', 'percent', 23, 'sale', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 41 ust. 1 fixe le taux nominal à 22 %, mais l''art. 146ef ust. 1 pkt 1 le porte à 23 % tant que les dépenses de défense excèdent 3 % du PIB (période ouverte depuis le 1er janvier 2024, prorogée chaque année par obwieszczenie du ministre au Monitor Polski, art. 146ef ust. 2) : ce code transcrit le taux effectivement appliqué depuis le 1er janvier 2011, et non le taux nominal de l''art. 41.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-5', 'VAT sprzedaż 5%', '{}'::jsonb, 'Stawka obniżona (załącznik nr 10 — m.in. podstawowe artykuły spożywcze, książki). Pola P_15 (podstawa) i P_16 (podatek).', 'percent', 5, 'sale', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 41 ust. 2a — pour les biens et services de l''annexe 10 ; ce taux n''est pas surchargé par l''art. 146ef, à la différence des deux précédents.', 'S', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-8', 'VAT sprzedaż 8%', '{}'::jsonb, 'Stawka obniżona (załącznik nr 3). Pola P_17 (podstawa) i P_18 (podatek).', 'percent', 8, 'sale', 'domestic', date '2011-01-01', null, 'Ustawa o VAT art. 41 ust. 2 fixe le taux nominal à 7 % pour les biens et services de l''annexe 3 ; l''art. 146ef ust. 1 pkt 2 le porte à 8 % pour la même période que le taux standard (voir PL-S-23).', 'S', null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-EXPORT', 'Eksport towarów 0%', '{}'::jsonb, 'Export de biens hors Union européenne. Pole P_22.', 'percent', 0, 'sale', 'export', date '2004-05-01', null, 'Ustawa o VAT art. 41 ust. 4-5 — taux zéro sous réserve de la confirmation en douane de la sortie du territoire de l''Union avant l''expiration du délai de déclaration (ust. 6-9b organisent le report d''un mois et la correction ultérieure si le document arrive plus tard).', 'G', 'VATEX-EU-G', 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-USLUGI-UE', 'Świadczenie usług na rzecz podatnika z innego państwa UE (art. 28b)', '{}'::jsonb, 'Service à un assujetti établi dans un autre État membre, taxé chez l''acquéreur (règle générale B2B). Pole P_11, mémorisé aussi en P_12 pour le récapitulatif VAT-UE.', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Ustawa o VAT art. 28b — lieu de la prestation au siège de l''acquéreur assujetti ; art. 100 ust. 1 pkt 4 — obligation de la déclarer dans la déclaration récapitulative VAT-UE, d''où le report en P_12 en plus de P_11.', 'K', 'VATEX-EU-IC', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-WDT', 'Wewnątrzwspólnotowa dostawa towarów 0%', '{}'::jsonb, 'Livraison intracommunautaire de biens. Pole P_21.', 'percent', 0, 'sale', 'intracom_goods', date '2004-05-01', null, 'Ustawa o VAT art. 41 ust. 3 en liaison avec l''art. 42 (conditions de fond et de preuve du taux zéro : acquéreur identifié à la TVA dans un autre État membre, biens transportés hors de Pologne, documents de transport, récapitulatif VAT-UE).', 'K', 'VATEX-EU-IC', 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null),
  ('PL', 'PL-S-ZW-NAJEM', 'Najem nieruchomości mieszkalnej na cele mieszkaniowe — zwolniony', '{}'::jsonb, 'Exemple de vente exonérée (location d''un bien immobilier résidentiel à usage d''habitation). Pole P_10.', 'percent', 0, 'sale', 'exempt', date '2004-05-01', null, 'Ustawa o VAT art. 43 ust. 1 pkt 36 — exonération de la location d''un bien immobilier de caractère résidentiel, réalisée pour son propre compte, exclusivement à des fins d''habitation.', 'E', 'VATEX-EU-135', 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustawa-vat', null, null, null, null)
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
    ('PL-P-23', 'invoice', 'base', 100, null, '42', array['42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-23', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-23', 'credit_note', 'base', 100, null, '42', array['42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-23', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-23-POJAZD', 'invoice', 'base', 100, null, '42', array['42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-23-POJAZD', 'invoice', 'tax', 50, '2241', '43', array['43']::text[], 50, 'PL-JPK-V7', 20),
    ('PL-P-23-POJAZD', 'invoice', 'tax_on_base', 50, null, '42', array['42']::text[], 50, 'PL-JPK-V7', 30),
    ('PL-P-23-POJAZD', 'credit_note', 'base', 100, null, '42', array['42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-23-POJAZD', 'credit_note', 'tax', 50, '2241', '43', array['43']::text[], -50, 'PL-JPK-V7', 20),
    ('PL-P-23-POJAZD', 'credit_note', 'tax_on_base', 50, null, '42', array['42']::text[], -50, 'PL-JPK-V7', 30),
    ('PL-P-23-ST', 'invoice', 'base', 100, null, '40', array['40']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-23-ST', 'invoice', 'tax', 100, '2241', '41', array['41']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-23-ST', 'credit_note', 'base', 100, null, '40', array['40']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-23-ST', 'credit_note', 'tax', 100, '2241', '41', array['41']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-5', 'invoice', 'base', 100, null, '42', array['42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-5', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-5', 'credit_note', 'base', 100, null, '42', array['42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-5', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-8', 'invoice', 'base', 100, null, '42', array['42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-8', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-8', 'credit_note', 'base', 100, null, '42', array['42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-8', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-IMPORT-23', 'invoice', 'base', 100, null, '25', array['25', '42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-IMPORT-23', 'invoice', 'tax', 100, '7710', '26', array['26']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-IMPORT-23', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 30),
    ('PL-P-IMPORT-23', 'credit_note', 'base', 100, null, '25', array['25', '42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-IMPORT-23', 'credit_note', 'tax', 100, '7710', '26', array['26']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-IMPORT-23', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 30),
    ('PL-P-RC-17-1-5', 'invoice', 'base', 100, null, '31', array['31', '42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-RC-17-1-5', 'invoice', 'tax', 100, '7710', '32', array['32']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-RC-17-1-5', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 30),
    ('PL-P-RC-17-1-5', 'credit_note', 'base', 100, null, '31', array['31', '42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-RC-17-1-5', 'credit_note', 'tax', 100, '7710', '32', array['32']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-RC-17-1-5', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 30),
    ('PL-P-USLUGI-SPOZA-UE-23', 'invoice', 'base', 100, null, '27', array['27', '42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-USLUGI-SPOZA-UE-23', 'invoice', 'tax', 100, '7710', '28', array['28']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-USLUGI-SPOZA-UE-23', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 30),
    ('PL-P-USLUGI-SPOZA-UE-23', 'credit_note', 'base', 100, null, '27', array['27', '42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-USLUGI-SPOZA-UE-23', 'credit_note', 'tax', 100, '7710', '28', array['28']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-USLUGI-SPOZA-UE-23', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 30),
    ('PL-P-USLUGI-UE-23', 'invoice', 'base', 100, null, '29', array['29', '42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-USLUGI-UE-23', 'invoice', 'tax', 100, '7710', '30', array['30']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-USLUGI-UE-23', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 30),
    ('PL-P-USLUGI-UE-23', 'credit_note', 'base', 100, null, '29', array['29', '42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-USLUGI-UE-23', 'credit_note', 'tax', 100, '7710', '30', array['30']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-USLUGI-UE-23', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 30),
    ('PL-P-WNT-23', 'invoice', 'base', 100, null, '23', array['23', '42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-WNT-23', 'invoice', 'tax', 100, '7710', '24', array['24']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-P-WNT-23', 'invoice', 'tax', 100, '2241', '43', array['43']::text[], 100, 'PL-JPK-V7', 30),
    ('PL-P-WNT-23', 'credit_note', 'base', 100, null, '23', array['23', '42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-P-WNT-23', 'credit_note', 'tax', 100, '7710', '24', array['24']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-P-WNT-23', 'credit_note', 'tax', 100, '2241', '43', array['43']::text[], -100, 'PL-JPK-V7', 30),
    ('PL-P-ZW', 'invoice', 'base', 100, null, '42', array['42']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-P-ZW', 'credit_note', 'base', 100, null, '42', array['42']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-23', 'invoice', 'base', 100, null, '19', array['19']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-23', 'invoice', 'tax', 100, '7710', '20', array['20']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-S-23', 'credit_note', 'base', 100, null, '19', array['19']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-23', 'credit_note', 'tax', 100, '7710', '20', array['20']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-S-5', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-5', 'invoice', 'tax', 100, '7710', '16', array['16']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-S-5', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-5', 'credit_note', 'tax', 100, '7710', '16', array['16']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-S-8', 'invoice', 'base', 100, null, '17', array['17']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-8', 'invoice', 'tax', 100, '7710', '18', array['18']::text[], 100, 'PL-JPK-V7', 20),
    ('PL-S-8', 'credit_note', 'base', 100, null, '17', array['17']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-8', 'credit_note', 'tax', 100, '7710', '18', array['18']::text[], -100, 'PL-JPK-V7', 20),
    ('PL-S-EXPORT', 'invoice', 'base', 100, null, '22', array['22']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-EXPORT', 'credit_note', 'base', 100, null, '22', array['22']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-USLUGI-UE', 'invoice', 'base', 100, null, '11', array['11', '12']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-USLUGI-UE', 'credit_note', 'base', 100, null, '11', array['11', '12']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-WDT', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-WDT', 'credit_note', 'base', 100, null, '21', array['21']::text[], -100, 'PL-JPK-V7', 10),
    ('PL-S-ZW-NAJEM', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'PL-JPK-V7', 10),
    ('PL-S-ZW-NAJEM', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'PL-JPK-V7', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PL' and t.code = v.tax_code
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
  ('PL', 'PL-JPK-V7', 'JPK_VAT z deklaracją — część deklaracyjna (wzór JPK_V7M(3) / JPK_V7K(3))', array['month', 'quarter']::declaration_period[], 'month'::declaration_period, date '2026-02-01', null, 'Rozporządzenie Ministra Finansów, Inwestycji i Rozwoju z dnia 15 października 2019 r. w sprawie szczegółowego zakresu danych zawartych w deklaracjach podatkowych i w ewidencji w zakresie podatku od towarów i usług (Dz. U. z 2019 r. poz. 1988, z późn. zm.), wydane na podstawie art. 99 ust. 13b oraz art. 109 ust. 14 ustawy o VAT. Le fichier unique JPK_VAT z deklaracją combine, en une seule transmission XML, le registre (Ewidencja) et la déclaration (Deklaracja) ; ce pack ne transcrit que la partie Deklaracja — Pozycje szczegółowe, pole par pole — dont les cases sont numérotées P_xx, à la suite du modèle imprimé de la déclaration VAT-7 qu''elle a remplacé le 1er octobre 2020. La version (3), en vigueur pour les périodes à compter de février 2026, ajoute notamment les cases P_360 et P_660 et le champ texte libre P_ORDZU qui remplace l''ancienne annexe ORD-ZU ; une déclaration d''une version antérieure est un formulaire différent, avec son propre valid_from.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Ustawa o VAT art. 99 ust. 1 — la déclaration mensuelle est déposée au plus tard le 25 du mois suivant chaque mois ; art. 99 ust. 2 — le petit contribuable ayant opté pour la méthode de caisse dépose au 25 du mois suivant le trimestre ; art. 103 ust. 1-2 — le paiement est dû à la même date que le dépôt.', 'ustawa-vat', null)
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
  ('PL', 'PL-JPK-V7', '10', 'base', 'Dostawa towarów oraz świadczenie usług na terytorium kraju, zwolnione od podatku', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_10 — wykazana w K_10 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '11', 'base', 'Dostawa towarów oraz świadczenie usług poza terytorium kraju', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_11 — wykazana w K_11 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '12', 'base', 'Świadczenie usług, o których mowa w art. 100 ust. 1 pkt 4 ustawy (usługi wykazywane w informacji podsumowującej VAT-UE)', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_12 — wykazana w K_12 ewidencji ; sous-ensemble mémoire de P_11, non repris dans le total P_37.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '13', 'base', 'Dostawa towarów oraz świadczenie usług na terytorium kraju, opodatkowane stawką 0%', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_13 — wykazana w K_13 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '14', 'base', 'W tym dostawa towarów, o której mowa w art. 129 ustawy (zwrot podatku podróżnym)', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_14 — sous-ensemble mémoire de P_13, wykazana w K_14 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '15', 'base', 'Dostawa towarów oraz świadczenie usług na terytorium kraju, opodatkowane stawką 5%, oraz korekta zgodnie z art. 89a ust. 1 i 4 ustawy', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_15 — wykazana w K_15 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '16', 'tax', 'Podatek należny od dostaw i usług, o których mowa w polu P_15', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16, pole P_16 — wykazana w K_16 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '17', 'base', 'Dostawa towarów oraz świadczenie usług na terytorium kraju, opodatkowane stawką 7% albo 8%, oraz korekta zgodnie z art. 89a ust. 1 i 4 ustawy', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 16-17, pole P_17 — wykazana w K_17 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '18', 'tax', 'Podatek należny od dostaw i usług, o których mowa w polu P_17', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_18 — wykazana w K_18 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '19', 'base', 'Dostawa towarów oraz świadczenie usług na terytorium kraju, opodatkowane stawką 22% albo 23%, oraz korekta zgodnie z art. 89a ust. 1 i 4 ustawy', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_19 — wykazana w K_19 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '20', 'tax', 'Podatek należny od dostaw i usług, o których mowa w polu P_19', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_20 — wykazana w K_20 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '21', 'base', 'Wewnątrzwspólnotowa dostawa towarów', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_21 — wykazana w K_21 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '22', 'base', 'Eksport towarów', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_22 — wykazana w K_22 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '23', 'base', 'Wewnątrzwspólnotowe nabycie towarów', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_23 — wykazana w K_23 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '24', 'tax', 'Podatek należny od wewnątrzwspólnotowego nabycia towarów', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17, pole P_24 — wykazana w K_24 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '25', 'base', 'Import towarów rozliczany zgodnie z art. 33a ustawy', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17-18, pole P_25 — wykazana w K_25 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '26', 'tax', 'Podatek należny od importu towarów rozliczanego zgodnie z art. 33a ustawy', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_26 — wykazana w K_26 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '27', 'base', 'Import usług, z wyłączeniem usług nabywanych od podatników podatku od wartości dodanej, do których stosuje się art. 28b ustawy', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_27 — wykazana w K_27 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '28', 'tax', 'Podatek należny od importu usług, o którym mowa w polu P_27', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_28 — wykazana w K_28 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '29', 'base', 'Import usług nabywanych od podatników podatku od wartości dodanej, do których stosuje się art. 28b ustawy', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_29 — wykazana w K_29 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '30', 'tax', 'Podatek należny od importu usług, o którym mowa w polu P_29', '{}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_30 — wykazana w K_30 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '31', 'base', 'Dostawa towarów, dla której podatnikiem jest nabywca zgodnie z art. 17 ust. 1 pkt 5 ustawy', '{}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_31 — wykazana w K_31 ewidencji ; du 1er avril 2023 au 31 décembre 2026, y figure aussi la fourniture de gaz, d''électricité et de quotas d''émission de l''art. 145e ust. 1.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '32', 'tax', 'Podatek należny od dostawy towarów, o której mowa w polu P_31', '{}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_32 — wykazana w K_32 ewidencji ; le champ n''accepte que « 0.00 » lorsqu''aucun podatek należny n''apparaît en P_31.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '33', 'tax', 'Podatek należny od towarów objętych spisem z natury, o którym mowa w art. 14 ust. 5 ustawy', '{}'::jsonb, 240, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_33 — wykazana w K_33 ewidencji. Non modélisé : voir docs/international.md, section « From Poland ».', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '34', 'tax', 'Zwrot odliczonej lub zwróconej kwoty wydanej na zakup kas rejestrujących, o którym mowa w art. 111 ust. 6 ustawy', '{}'::jsonb, 250, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18, pole P_34 — wykazana w K_34 ewidencji. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '35', 'tax', 'Podatek należny od wewnątrzwspólnotowego nabycia środków transportu, podlegający wpłacie w terminie, o którym mowa w art. 103 ust. 3 i 4 ustawy', '{}'::jsonb, 260, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 18-19, pole P_35 — sous-ensemble mémoire de P_24, wykazana w K_35 ewidencji. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '36', 'tax', 'Podatek należny od wewnątrzwspólnotowego nabycia towarów, o których mowa w art. 103 ust. 5aa ustawy, podlegający wpłacie w terminach, o których mowa w art. 103 ust. 5a i 5ac ustawy', '{}'::jsonb, 270, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 19, pole P_36 — wykazana w K_36 ewidencji. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '360', 'tax', 'Podatek od niezwróconej kaucji pobranej za produkty w opakowaniach na napoje objęte systemem kaucyjnym, podlegający wpłacie przez podmiot reprezentujący, o którym mowa w art. 17b ustawy', '{}'::jsonb, 280, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 19, pole P_360 — nowość wzoru (3). Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '37', 'total', 'Łączna wysokość podstawy opodatkowania', '{}'::jsonb, 290, null, array['10', '11', '13', '15', '17', '19', '21', '22', '23', '25', '27', '29', '31']::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 19, pole P_37 — suma kwot z pól P_10, P_11, P_13, P_15, P_17, P_19, P_21, P_22, P_23, P_25, P_27, P_29, P_31.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '38', 'total', 'Łączna wysokość podatku należnego', '{}'::jsonb, 300, null, array['16', '18', '20', '24', '26', '28', '30', '32', '33', '34']::text[], array['35', '36', '360']::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 19, pole P_38 (pole obowiązkowe, w przypadku braku wartość „0”) — suma kwot z pól P_16, P_18, P_20, P_24, P_26, P_28, P_30, P_32, P_33, P_34 pomniejszona o kwoty z pól P_35, P_36 i P_360.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '39', 'tax', 'Wysokość nadwyżki podatku naliczonego nad należnym z poprzedniej deklaracji', '{}'::jsonb, 310, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 17 [sic, Tabela 19], pole P_39 — kwota z pola P_62 poprzedniej deklaracji lub kwota wynikająca z decyzji. Non modélisé : le socle ne reporte pas un solde d''une déclaration à l''autre, voir docs/international.md, section « From Poland ».', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '40', 'base', 'Wartość netto nabycia towarów i usług zaliczanych u podatnika do środków trwałych', '{}'::jsonb, 320, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 19, pole P_40 — wykazana w K_40 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '41', 'tax', 'Podatek naliczony z tytułu nabycia towarów i usług zaliczanych u podatnika do środków trwałych', '{}'::jsonb, 330, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 19, pole P_41 — wykazana w K_41 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '42', 'base', 'Wartość netto nabycia pozostałych towarów i usług', '{}'::jsonb, 340, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_42 — wykazana w K_42 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '43', 'tax', 'Podatek naliczony z tytułu nabycia pozostałych towarów i usług', '{}'::jsonb, 350, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_43 — wykazana w K_43 ewidencji.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '44', 'tax', 'Podatek naliczony z tytułu korekty podatku naliczonego od nabycia środków trwałych', '{}'::jsonb, 360, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_44 — wykazana w K_44 ewidencji. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '45', 'tax', 'Podatek naliczony z tytułu korekty podatku naliczonego od nabycia pozostałych towarów i usług', '{}'::jsonb, 370, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_45 — wykazana w K_45 ewidencji. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '46', 'tax', 'Korekta podatku naliczonego, o której mowa w art. 89b ust. 1 ustawy (wyłącznie wartości ujemne lub „0”)', '{}'::jsonb, 380, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_46 — wykazana w K_46 ewidencji. Non modélisé : voir docs/international.md, section « From Poland ».', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '47', 'tax', 'Korekta podatku naliczonego, o której mowa w art. 89b ust. 4 ustawy', '{}'::jsonb, 390, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_47 — wykazana w K_47 ewidencji. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '48', 'total', 'Łączna wysokość podatku naliczonego do odliczenia', '{}'::jsonb, 400, null, array['39', '41', '43', '44', '45', '46', '47']::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 20, pole P_48 — suma kwot z pól P_39, P_41, P_43, P_44, P_45, P_46 i P_47.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '49', 'tax', 'Kwota wydana na zakup kas rejestrujących, do odliczenia w danym okresie rozliczeniowym, pomniejszająca wysokość podatku należnego', '{}'::jsonb, 410, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 21, pole P_49. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '50', 'tax', 'Wysokość podatku objęta zaniechaniem poboru', '{}'::jsonb, 420, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 21, pole P_50. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '51', 'total', 'Wysokość podatku podlegająca wpłacie do urzędu skarbowego', '{}'::jsonb, 430, null, array['38']::text[], array['48']::text[], null, null, true, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 21, pole P_51 (pole obowiązkowe, w przypadku braku wartość „0”) — l''excédent de la taxe due sur la taxe déductible, plafonné à zéro (l''excédent inverse est P_53).', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '52', 'tax', 'Kwota wydana na zakup kas rejestrujących, do odliczenia w danym okresie rozliczeniowym, przysługująca do zwrotu lub do przeniesienia na następny okres rozliczeniowy', '{}'::jsonb, 440, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 21, pole P_52. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '53', 'total', 'Wysokość nadwyżki podatku naliczonego nad należnym', '{}'::jsonb, 450, null, array['48']::text[], array['38']::text[], null, null, true, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 21-22, pole P_53 — l''excédent de la taxe déductible sur la taxe due, plafonné à zéro.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '54', 'tax', 'Wysokość nadwyżki podatku naliczonego nad należnym do zwrotu na rachunek wskazany przez podatnika', '{}'::jsonb, 460, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 22, pole P_54 — part de l''excédent P_53 dont le contribuable demande le remboursement, un choix qui lui appartient. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '540', 'tax', 'Zwrot na rachunek rozliczeniowy podatnika w terminie 15 dni (art. 87 ust. 6d ustawy)', '{}'::jsonb, 470, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 22, pole P_540 — valeur « 1 » si ce délai est demandé. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '55', 'tax', 'Zwrot na rachunek VAT podatnika w terminie 25 dni', '{}'::jsonb, 480, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 22-23, pole P_55 — valeur « 1 » si ce choix est fait. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '56', 'tax', 'Zwrot na rachunek rozliczeniowy podatnika w terminie 25 dni (art. 87 ust. 6 ustawy)', '{}'::jsonb, 490, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 23, pole P_56 — valeur « 1 » si ce choix est fait. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '560', 'tax', 'Zwrot na rachunek rozliczeniowy podatnika w terminie 40 dni', '{}'::jsonb, 500, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 23, pole P_560 — valeur « 1 » si ce choix est fait. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '58', 'tax', 'Zwrot na rachunek rozliczeniowy podatnika w terminie 180 dni', '{}'::jsonb, 510, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 24, pole P_58 — valeur « 1 » si ce choix est fait. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '59', 'tax', 'Zaliczenie zwrotu podatku na poczet przyszłych zobowiązań podatkowych', '{}'::jsonb, 520, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 24, pole P_59 — valeur « 1 » si ce choix est fait (art. 76 § 1 et art. 76b § 1 Ordynacja podatkowa). Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '60', 'tax', 'Wysokość zwrotu do zaliczenia na poczet przyszłych zobowiązań podatkowych', '{}'::jsonb, 530, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 24, pole P_60. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '61', 'tax', 'Rodzaj przyszłego zobowiązania podatkowego', '{}'::jsonb, 540, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 24, pole P_61 — champ descriptif. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '62', 'tax', 'Wysokość nadwyżki podatku naliczonego nad należnym do przeniesienia na następny okres rozliczeniowy', '{}'::jsonb, 550, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 24, pole P_62 — part de l''excédent P_53 reportée sur la période suivante, complément du choix opéré en P_54/P_60. Non modélisé : ce report est le pendant du gap documenté sur P_39.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '63', 'tax', 'Podatnik wykonywał w okresie rozliczeniowym czynności, o których mowa w art. 119 ustawy (procedura marży — biura podróży)', '{}'::jsonb, 560, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 25, pole P_63 — valeur « 1 » le cas échéant. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '64', 'tax', 'Podatnik wykonywał w okresie rozliczeniowym czynności, o których mowa w art. 120 ust. 4 lub 5 ustawy (procedura marży — towary używane)', '{}'::jsonb, 570, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 25, pole P_64. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '65', 'tax', 'Podatnik wykonywał w okresie rozliczeniowym czynności, o których mowa w art. 122 ustawy (złoto inwestycyjne)', '{}'::jsonb, 580, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 25-26, pole P_65. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '66', 'tax', 'Podatnik wykonywał w okresie rozliczeniowym czynności, o których mowa w art. 136 ustawy (transakcja trójstronna uproszczona — drugi w kolejności podatnik)', '{}'::jsonb, 590, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 26, pole P_66. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '660', 'tax', 'Podatnik ułatwiał w okresie rozliczeniowym dokonanie czynności, o których mowa w art. 109b ust. 4 ustawy', '{}'::jsonb, 600, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 26, pole P_660 — nowość wzoru (3). Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '67', 'tax', 'Podatnik korzysta z obniżenia zobowiązania podatkowego, o którym mowa w art. 108d ustawy', '{}'::jsonb, 610, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 26, pole P_67 — rabais pour paiement anticipé depuis le rachunek VAT. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '68', 'tax', 'Korekta podstawy opodatkowania, o której mowa w art. 89a ust. 1 ustawy (wyłącznie wartości ujemne lub „0”)', '{}'::jsonb, 620, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 26, pole P_68 — reprise dans K_15, K_17 et K_19. Non modélisé : voir docs/international.md, section « From Poland ».', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', '69', 'tax', 'Korekta podatku należnego, o której mowa w art. 89a ust. 1 ustawy (wyłącznie wartości ujemne lub „0”)', '{}'::jsonb, 630, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 27, pole P_69 — reprise dans K_16, K_18 et K_20. Non modélisé.', 'broszura-jpk'),
  ('PL', 'PL-JPK-V7', 'ORDZU', 'tax', 'Uzasadnienie przyczyn złożenia korekty', '{}'::jsonb, 640, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Broszura JPK_VAT z deklaracją, Tabela 27, pole P_ORDZU — champ texte libre, remplace l''ancienne annexe ORD-ZU ; représenté ici comme une case du formulaire sans valeur monétaire, jamais posté.', 'broszura-jpk')
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
  ('PL-UOR-BILANS', 'PL', 'default', 'Bilans według załącznika nr 1 do ustawy o rachunkowości', 'balance_sheet', 'PL-UOR', date '2026-01-01', null, 'Ustawa o rachunkowości art. 45 ust. 2 pkt 1 et załącznik nr 1 — modèle du bilan pour les entités autres que les banques, les entreprises d''assurance et de réassurance.', 'ustawa-rachunkowosc'),
  ('PL-UOR-RZIS-POROWNAWCZY', 'PL', 'default', 'Rachunek zysków i strat — wariant porównawczy, według załącznika nr 1 do ustawy o rachunkowości', 'income_statement', 'PL-UOR', date '2026-01-01', null, 'Ustawa o rachunkowości art. 45 ust. 2 pkt 2 et załącznik nr 1 — le wariant porównawczy (par nature de charge) est retenu par ce pack, sur les deux que l''annexe autorise ; le choix appartient à l''entité (le wariant kalkulacyjny, par fonction, n''est pas modélisé ici).', 'ustawa-rachunkowosc')
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
  ('PL-UOR-BILANS', 'AKT', null, 'AKTYWA RAZEM', '{}'::jsonb, 10, 1, true, array['AKT.A', 'AKT.B', 'AKT.C', 'AKT.D']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.A', 'AKT', 'A. Aktywa trwałe', '{}'::jsonb, 20, 1, true, array['AKT.A.I', 'AKT.A.II', 'AKT.A.III', 'AKT.A.IV', 'AKT.A.V']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.A.I', 'AKT.A', 'I. Wartości niematerialne i prawne', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.A.II', 'AKT.A', 'II. Rzeczowe aktywa trwałe', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.A.III', 'AKT.A', 'III. Należności długoterminowe', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.A.IV', 'AKT.A', 'IV. Inwestycje długoterminowe', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.A.V', 'AKT.A', 'V. Długoterminowe rozliczenia międzyokresowe', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.B', 'AKT', 'B. Aktywa obrotowe', '{}'::jsonb, 80, 1, true, array['AKT.B.I', 'AKT.B.II', 'AKT.B.III', 'AKT.B.IV']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.B.I', 'AKT.B', 'I. Zapasy', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.B.II', 'AKT.B', 'II. Należności krótkoterminowe', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.B.III', 'AKT.B', 'III. Inwestycje krótkoterminowe', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.B.IV', 'AKT.B', 'IV. Krótkoterminowe rozliczenia międzyokresowe', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.C', 'AKT', 'C. Należne wpłaty na kapitał (fundusz) podstawowy', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'AKT.D', 'AKT', 'D. Udziały (akcje) własne', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS', null, 'PASYWA RAZEM', '{}'::jsonb, 150, 1, true, array['PAS.A', 'PAS.B']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A', 'PAS', 'A. Kapitał (fundusz) własny', '{}'::jsonb, 160, 1, true, array['PAS.A.I', 'PAS.A.II', 'PAS.A.III', 'PAS.A.IV', 'PAS.A.V', 'PAS.A.VI', 'PAS.A.VII']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.I', 'PAS.A', 'I. Kapitał (fundusz) podstawowy', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.II', 'PAS.A', 'II. Kapitał (fundusz) zapasowy', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.III', 'PAS.A', 'III. Kapitał (fundusz) z aktualizacji wyceny', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.IV', 'PAS.A', 'IV. Pozostałe kapitały (fundusze) rezerwowe', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.V', 'PAS.A', 'V. Zysk (strata) z lat ubiegłych', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.VI', 'PAS.A', 'VI. Zysk (strata) netto', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.A.VII', 'PAS.A', 'VII. Odpisy z zysku netto w ciągu roku obrotowego (wielkość ujemna)', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.B', 'PAS', 'B. Zobowiązania i rezerwy na zobowiązania', '{}'::jsonb, 240, 1, true, array['PAS.B.I', 'PAS.B.II', 'PAS.B.III', 'PAS.B.IV']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.B.I', 'PAS.B', 'I. Rezerwy na zobowiązania', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.B.II', 'PAS.B', 'II. Zobowiązania długoterminowe', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.B.III', 'PAS.B', 'III. Zobowiązania krótkoterminowe', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-BILANS', 'PAS.B.IV', 'PAS.B', 'IV. Rozliczenia międzyokresowe', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A', null, 'A. Przychody netto ze sprzedaży i zrównane z nimi', '{}'::jsonb, 10, 1, true, array['RZIS.A.I', 'RZIS.A.II', 'RZIS.A.III', 'RZIS.A.IV']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.I', 'RZIS.A', 'I. Przychody netto ze sprzedaży produktów', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.II', 'RZIS.A', 'II. Zmiana stanu produktów', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.III', 'RZIS.A', 'III. Koszt wytworzenia produktów na własne potrzeby jednostki', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.IV', 'RZIS.A', 'IV. Przychody netto ze sprzedaży towarów i materiałów', '{}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B', null, 'B. Koszty działalności operacyjnej', '{}'::jsonb, 60, 1, true, array['RZIS.B.I', 'RZIS.B.II', 'RZIS.B.III', 'RZIS.B.IV', 'RZIS.B.V', 'RZIS.B.VI', 'RZIS.B.VII', 'RZIS.B.VIII']::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.I', 'RZIS.B', 'I. Amortyzacja', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.II', 'RZIS.B', 'II. Zużycie materiałów i energii', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.III', 'RZIS.B', 'III. Usługi obce', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.IV', 'RZIS.B', 'IV. Podatki i opłaty', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.V', 'RZIS.B', 'V. Wynagrodzenia', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.VI', 'RZIS.B', 'VI. Ubezpieczenia społeczne i inne świadczenia', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.VII', 'RZIS.B', 'VII. Pozostałe koszty rodzajowe', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.VIII', 'RZIS.B', 'VIII. Wartość sprzedanych towarów i materiałów', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.C', null, 'C. Zysk (strata) ze sprzedaży (A-B)', '{}'::jsonb, 150, 1, true, array['RZIS.A']::text[], array['RZIS.B']::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.D', null, 'D. Pozostałe przychody operacyjne', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.E', null, 'E. Pozostałe koszty operacyjne', '{}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.F', null, 'F. Zysk (strata) z działalności operacyjnej (C+D-E)', '{}'::jsonb, 180, 1, true, array['RZIS.C', 'RZIS.D']::text[], array['RZIS.E']::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.G', null, 'G. Przychody finansowe', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.H', null, 'H. Koszty finansowe', '{}'::jsonb, 200, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.I', null, 'I. Zysk (strata) brutto (F+G-H)', '{}'::jsonb, 210, 1, true, array['RZIS.F', 'RZIS.G']::text[], array['RZIS.H']::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.J', null, 'J. Podatek dochodowy', '{}'::jsonb, 220, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.K', null, 'K. Pozostałe obowiązkowe zmniejszenia zysku (zwiększenia straty)', '{}'::jsonb, 230, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.L', null, 'L. Zysk (strata) netto (I-J-K)', '{}'::jsonb, 240, 1, true, array['RZIS.I']::text[], array['RZIS.J', 'RZIS.K']::text[], null, null, null)
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
    ('PL-UOR-BILANS', 'AKT.A.I', 10, 'code_range', '1110', '1140', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.A.II', 10, 'code_range', '1211', '1230', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.A.III', 10, 'code_range', '1310', '1310', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.A.IV', 10, 'code_range', '1410', '1420', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.A.V', 10, 'code_range', '1510', '1520', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.B.I', 10, 'code_range', '2110', '2150', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.B.II', 10, 'code_range', '2210', '2270', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.B.III', 10, 'code_range', '2310', '2340', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.B.IV', 10, 'code_range', '2400', '2400', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.C', 10, 'code_range', '3100', '3100', null, 'any'),
    ('PL-UOR-BILANS', 'AKT.D', 10, 'code_range', '3200', '3200', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.I', 10, 'code_range', '4100', '4100', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.II', 10, 'code_range', '4200', '4200', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.III', 10, 'code_range', '4300', '4300', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.IV', 10, 'code_range', '4400', '4400', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.V', 10, 'code_range', '4500', '4500', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.VI', 10, 'code_range', '4610', '4620', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.A.VII', 10, 'code_range', '4700', '4700', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.B.I', 10, 'code_range', '5100', '5300', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.B.II', 10, 'code_range', '6100', '6400', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.B.III', 10, 'code_range', '7100', '7950', null, 'any'),
    ('PL-UOR-BILANS', 'PAS.B.IV', 10, 'code_range', '7960', '7970', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.I', 10, 'code_range', '8100', '8100', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.II', 10, 'code_range', '8110', '8110', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.III', 10, 'code_range', '8120', '8120', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.A.IV', 10, 'code_range', '8130', '8130', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.I', 10, 'code_range', '8210', '8210', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.II', 10, 'code_range', '8220', '8222', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.III', 10, 'code_range', '8230', '8235', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.IV', 10, 'code_range', '8240', '8240', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.V', 10, 'code_range', '8250', '8250', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.VI', 10, 'code_range', '8260', '8260', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.VII', 10, 'code_range', '8270', '8273', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.B.VIII', 10, 'code_range', '8280', '8280', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.D', 10, 'code_range', '8310', '8310', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.E', 10, 'code_range', '8320', '8320', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.G', 10, 'code_range', '8410', '8411', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.H', 10, 'code_range', '8420', '8421', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.J', 10, 'code_range', '8500', '8500', null, 'any'),
    ('PL-UOR-RZIS-POROWNAWCZY', 'RZIS.K', 10, 'code_range', '8510', '8510', null, 'any')
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
  ('PL', 'Polska', '{}'::jsonb, array['pl']::text[], 'PLN', '2230', '7400', '2270', '8320', '4500', '8100', '8230', '2320', '2310', 'SP', 'ZA', 'OG', 'pl', 'result_accounts', '4610', '4620', null, 'BO', 'half_up', default, '8411', '8421', null, null, null, null, '7720', '2242', null, 'month'::declaration_period)
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
  number_format                 = '{CODE}/{NNNN}/{YYYY}',
  legal_payment_days            = null,
  late_payment_reference        = 'Ustawa z dnia 8 marca 2013 r. o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych, art. 7 ust. 1-2 — entre entreprises, intérêt dû sans mise en demeure dès l''échéance impayée ; le terme contractuel ne peut dépasser 60 jours à compter de la remise de la facture (60 jours impératifs, art. 7 ust. 2a, lorsque le débiteur est une grande entreprise et le créancier une micro, petite ou moyenne entreprise). Art. 4 pkt 3 lit. b — taux : taux de référence NBP + 10 points (+ 8 points si le débiteur est un podmiot leczniczy), publié tous les six mois au Monitor Polski (art. 11c) ; pour le second semestre 2026, 13,75 % (11,75 % pour un podmiot leczniczy), M.P. 2026 poz. 642. Art. 10 — indemnité forfaitaire de recouvrement due sans mise en demeure : 40 EUR si la créance ne dépasse pas 5 000 zł, 70 EUR entre 5 000 et 50 000 zł, 100 EUR à partir de 50 000 zł, convertis au cours moyen EUR de la NBP du dernier jour ouvré du mois précédant l''exigibilité.',
  numbering_legal_reference     = 'Ustawa o VAT art. 106e ust. 1 pkt 2 — la facture porte « kolejny numer nadany w ramach jednej lub więcej serii, który w sposób jednoznaczny identyfikuje fakturę » : un numéro séquentiel, éventuellement réparti sur plusieurs séries, dont la loi exige seulement qu''il identifie la facture de façon univoque — ni continuité sans trou ni remise à zéro annuelle n''est imposée, d''où sequential et non gapless_per_year.',
  numbering_source_key          = 'ustawa-vat',
  payment_terms_legal_reference = 'Ustawa o przeciwdziałaniu nadmiernym opóźnieniom, art. 7 ust. 2 et 2a — ce n''est pas un délai supplétif en l''absence d''accord (le code civil, art. 455 k.c., rend une créance pécuniaire sans terme exigible « niezwłocznie » sur demande, ce qui n''est pas un nombre de jours à coder) mais un plafond impératif de 60 jours sur le délai que les parties peuvent convenir entre elles ; legal_payment_days reste donc vide plutôt que de présenter ce plafond comme le délai que la loi fixerait à défaut d''accord.',
  payment_terms_source_key      = 'ustawa-oplaty',
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = 'Ustawa o VAT art. 19a ust. 1 — « Obowiązek podatkowy powstaje z chwilą dokonania dostawy towarów lub wykonania usługi ». Non modélisées ici, les dérogations à l''émission de la facture de l''art. 19a ust. 5 pkt 3-4 (construction, presse imprimée, énergie, loyers, télécommunications) et à l''encaissement de l''ust. 5 pkt 1-2 (commission, services financiers et d''assurance exonérés, subventions) : elles touchent des activités précises plutôt que d''être une dérogation générale ouverte à toute facture, à la différence de la Belgique ou du Luxembourg.',
  tax_point_source_key          = 'ustawa-vat',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ustawa o rachunkowości art. 25 ust. 1 — une erreur constatée dans une écriture ne se corrige que par annulation lisible du texte initial ou par une pièce de correction portant des écritures positives ou négatives, jamais par une modification qui rendrait le contenu initial illisible. Ustawa o VAT art. 106j — une facture émise se corrige par une faktura korygująca qui la vise, jamais par une annulation.',
  posted_edit_policy_source_key = 'ustawa-rachunkowosc',
  einvoice_profile              = 'ksef-fa3',
  einvoice_mandatory_from       = date '2026-02-01',
  einvoice_obligation           = 'mandatory',
  einvoice_legal_reference      = 'Ustawa z dnia 16 czerwca 2023 r. (Dz. U. 2023 poz. 1598), modifiée en dernier lieu par la loi du 5 août 2025 (Dz. U. 2025 poz. 1203) — la faktura ustrukturyzowana devient obligatoire par palier de chiffre d''affaires : 1er février 2026 pour les entreprises dont les ventes TTC ont dépassé 200 millions de zł en 2024, 1er avril 2026 pour toutes les autres, 1er janvier 2027 pour les plus petites factures (jusqu''à 450 zł l''unité et 10 000 zł cumulés par mois). mandatory_from porte la date qui lie tout le monde à la fois : depuis le 1er février 2026, recevoir une facture par le KSeF est obligatoire pour tout assujetti, que sa propre obligation d''émettre ait déjà commencé ou non. Le profil ksef-fa3 n''est PAS l''un des profils fondés sur le modèle sémantique EN 16931 que ce champ nomme d''ordinaire (peppol-bis-3, factur-x-en16931, xrechnung, un PINT) : FA(3) est un schéma XML national propre, publié au CRWDE (http://crd.gov.pl/wzor/2025/06/25/13775/) et non une des variantes interopérables du modèle européen. party_scheme et vat_scheme restent vides : le KSeF identifie les parties par leur NIP directement, sans registre ISO 6523 à quatre chiffres comparable à celui du réseau Peppol. Voir docs/international.md, section « From Poland », pour la lacune du socle que cela ouvre : le KSeF est une clearance en temps réel — une faktura ustrukturyzowana est réputée émise à son envoi au système (art. 106na ust. 1) et reçue seulement à l''attribution, PAR le système, d''un numéro KSeF (art. 106na ust. 3) — que le socle, conçu pour un échange décentralisé entre pairs au format EN 16931, ne modélise pas.',
  einvoice_source_key           = 'ustawa-ksef-2023',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['mt940', 'camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'PL';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('PL', 'reverse_charge', 'reverse_charge', 'odwrotne obciążenie', '{}'::jsonb, 10, date '1970-01-01', null, 'Ustawa o VAT art. 106e ust. 1 pkt 18 — lorsque l''acquéreur du bien ou du service est tenu de liquider la taxe, la facture porte la mention « odwrotne obciążenie ».'),
  ('PL', 'intra_eu_services', 'intra_eu_services', 'odwrotne obciążenie', '{}'::jsonb, 20, date '1970-01-01', null, 'Ustawa o VAT art. 106e ust. 1 pkt 18 — la même mention s''applique lorsque l''acquéreur, établi dans un autre État membre, est celui qui liquide la taxe sur une prestation de services relevant de la règle générale B2B (art. 28b).'),
  ('PL', 'exempt', 'exempt', 'zwolnione z VAT', '{}'::jsonb, 30, date '1970-01-01', null, 'Ustawa o VAT art. 106e ust. 1 pkt 19 — pour une opération exonérée, la facture indique la disposition de la loi ou de son texte d''application, ou l''article de la directive 2006/112/CE, qui fonde l''exonération ; le libellé exact n''est pas imposé, seule la référence l''est.'),
  ('PL', 'small_business', 'small_business', 'zwolnienie podmiotowe — art. 113 ustawy o VAT', '{}'::jsonb, 40, date '1970-01-01', null, 'Ustawa o VAT art. 106e ust. 1 pkt 19 et art. 113 ust. 1 — l''entité bénéficiant de la franchise en base cite de même la disposition qui l''exonère. Aucune colonne du socle ne porte ce statut d''ensemble de l''entreprise ; la ligne existe pour un moteur de rendu qui le connaîtrait par ailleurs.'),
  ('PL', 'late_payment', 'late_payment', 'En cas de retard de paiement entre entreprises, des intérêts au taux de référence NBP majoré de 10 points (8 points si le débiteur est un podmiot leczniczy) sont dus de plein droit, ainsi qu''une indemnité forfaitaire de recouvrement de 40, 70 ou 100 EUR selon le montant de la créance (art. 7 et 10 de la loi du 8 mars 2013).', '{}'::jsonb, 50, date '1970-01-01', null, 'Ustawa o przeciwdziałaniu nadmiernym opóźnieniom w transakcjach handlowych, art. 7 ust. 1 et art. 10 — la mention n''est pas imposée par le texte ; elle est ici informative, à l''image des autres packs européens du dépôt qui rappellent le fondement de l''intérêt de retard.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
