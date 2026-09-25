-- Ekwo OS — Czechia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/cz at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build cz`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Zákon č. 235/2004 Sb., o dani z přidané hodnoty, ve znění pozdějších předpisů (konsolidované znění účinné od 1. 1. 2026) (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/2004/235
--   Zákon č. 349/2023 Sb., kterým se mění některé zákony v souvislosti s konsolidací veřejných rozpočtů — sjednocení snížené sazby DPH na 12 % a novelizace § 47 zákona č. 235/2004 Sb. od 1. 1. 2024 (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/2023/349
--   Informace GFŘ ke změnám sazeb DPH od 1. 1. 2024, č.j. 916/24/7100-30116-050822 (Generální finanční ředitelství)
--     https://financnisprava.gov.cz/assets/cs/prilohy/d-seznam-dani/Informace_GFR_ke_zmenam_sazeb_DPH_od_1_1_2024.pdf
--   Informace ke změnám v plátcovství a registračním řízení v oblasti DPH od 1. 1. 2025 (limity 2 000 000 Kč a 2 536 500 Kč podle § 6, prodloužení hranice čtvrtletního zdaňovacího období podle § 99a na 15 000 000 Kč) (Finanční správa ČR)
--     https://financnisprava.gov.cz/assets/cs/prilohy/d-seznam-dani/82973_Souhrnna-informace-k-novele-DPH-2025.pdf
--   Přiznání k dani z přidané hodnoty, tiskopis 25 5401 MFin 5401, vzor č. 25 (Finanční správa ČR)
--     https://financnisprava.gov.cz/assets/tiskopisy/5401_25.pdf
--   Moje daně — portál pro elektronické podání daňového přiznání, kontrolního hlášení a souhrnného hlášení (Finanční správa ČR)
--     https://adisspr.mfcr.cz
--   Kontrolní hlášení DPH — základní informace, struktura oddílů A a B, práh 10 000 Kč pro řádkový záznam (Finanční správa ČR)
--     https://financnisprava.gov.cz/cs/dane/dane/dan-z-pridane-hodnoty/kontrolni-hlaseni-dph/zakladni-informace
--   Kontrolní hlášení DPH — sankce podle § 101h zákona č. 235/2004 Sb. (Finanční správa ČR)
--     https://financnisprava.gov.cz/cs/dane/dane/dan-z-pridane-hodnoty/kontrolni-hlaseni-dph/sankce
--   Souhrnné hlášení — informace, formulář 25 5525 MFin 5525 (Finanční správa ČR)
--     https://financnisprava.gov.cz/cs/dane/dane/dan-z-pridane-hodnoty/informace-stanoviska-a-sdeleni/souhrnna-hlaseni
--   Zákon č. 563/1991 Sb., o účetnictví, ve znění pozdějších předpisů (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/1991/563
--   Vyhláška č. 500/2002 Sb., kterou se provádějí některá ustanovení zákona č. 563/1991 Sb., o účetnictví, pro účetní jednotky, které jsou podnikateli účtujícími v soustavě podvojného účetnictví — přílohy č. 1 (rozvaha), č. 2 (výkaz zisku a ztráty, druhové členění) a č. 4 (směrná účtová osnova) (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/2002/500
--   Zákon č. 89/2012 Sb., občanský zákoník — § 1963 (splatnost ceny mezi podnikateli) a § 1970 a násl. (úrok z prodlení) (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/2012/89
--   Nařízení vlády č. 351/2013 Sb., kterým se určuje výše úroků z prodlení — repo sazba ČNB platná pro první den příslušného kalendářního pololetí, zvýšená o 8 procentních bodů (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/2013/351
--   Jak postupovat při výpočtu úroku z prodlení — dvoutýdenní repo sazba ČNB (Česká národní banka)
--     https://www.cnb.cz/cs/casto-kladene-dotazy/Vypocet-uroku-z-prodleni/
--   Zákon č. 634/1992 Sb., o ochraně spotřebitele — § 3 odst. 1 písm. c), arrondi du montant total à la valeur nominale la plus proche de la monnaie légale en circulation lors d'un paiement en espèces (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/1992/634
--   Zaokrouhlování při platbě kartou — stanovisko Ministerstva financí ČR : seul un paiement en espèces peut être arrondi, jamais un paiement sans espèces (Ministerstvo financí ČR)
--     https://mfcr.gov.cz/cs/kontrola-a-regulace/cenova-regulace-a-kontrola/stanoviska-a-odpovedi/2017/zaokrouhlovani-pri-platbe-kartou-28591
--   Zákon č. 134/2016 Sb., o zadávání veřejných zakázek — § 221 et § 279 odst. 5 písm. a), obligation pour les principaux pouvoirs adjudicateurs d'accepter depuis le 1er avril 2019 une facture électronique conforme à la norme EN 16931 (Ministerstvo vnitra ČR — e-Sbírka)
--     https://e-sbirka.gov.cz/sb/2016/134
--   Elektronická fakturace — právní rámce (EN 16931, marchés publics) (Ministerstvo financí ČR)
--     https://mfcr.gov.cz/cs/verejny-sektor/elektronicka-fakturace/pravni-ramce
--   ISDOC — formát elektronické fakturace (Information System Document), licence a značka u Ministerstva vnitra ČR od 5. května 2021 (Ministerstvo vnitra ČR)
--     https://mv.gov.cz/isdoc/clanek/elektronicka-fakturace.aspx
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
  ('CZ', 'Czechia', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, 'c2b03814307ea5327c1d1c6de47fe6a2720ac464146392bc051ba22870dba107', '[{"key":"zakon-dph","title":"Zákon č. 235/2004 Sb., o dani z přidané hodnoty, ve znění pozdějších předpisů (konsolidované znění účinné od 1. 1. 2026)","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/2004/235","consulted_on":"2026-09-25","kind":"law"},{"key":"zakon-konsolidacni-balicek","title":"Zákon č. 349/2023 Sb., kterým se mění některé zákony v souvislosti s konsolidací veřejných rozpočtů — sjednocení snížené sazby DPH na 12 % a novelizace § 47 zákona č. 235/2004 Sb. od 1. 1. 2024","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/2023/349","consulted_on":"2026-09-25","kind":"law"},{"key":"gfr-sazby-2024","title":"Informace GFŘ ke změnám sazeb DPH od 1. 1. 2024, č.j. 916/24/7100-30116-050822","publisher":"Generální finanční ředitelství","url":"https://financnisprava.gov.cz/assets/cs/prilohy/d-seznam-dani/Informace_GFR_ke_zmenam_sazeb_DPH_od_1_1_2024.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"gfr-novela-2025","title":"Informace ke změnám v plátcovství a registračním řízení v oblasti DPH od 1. 1. 2025 (limity 2 000 000 Kč a 2 536 500 Kč podle § 6, prodloužení hranice čtvrtletního zdaňovacího období podle § 99a na 15 000 000 Kč)","publisher":"Finanční správa ČR","url":"https://financnisprava.gov.cz/assets/cs/prilohy/d-seznam-dani/82973_Souhrnna-informace-k-novele-DPH-2025.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"priznani-dph-tiskopis","title":"Přiznání k dani z přidané hodnoty, tiskopis 25 5401 MFin 5401, vzor č. 25","publisher":"Finanční správa ČR","url":"https://financnisprava.gov.cz/assets/tiskopisy/5401_25.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"moje-dane-portal","title":"Moje daně — portál pro elektronické podání daňového přiznání, kontrolního hlášení a souhrnného hlášení","publisher":"Finanční správa ČR","url":"https://adisspr.mfcr.cz","consulted_on":"2026-09-25","kind":"portal"},{"key":"kontrolni-hlaseni-info","title":"Kontrolní hlášení DPH — základní informace, struktura oddílů A a B, práh 10 000 Kč pro řádkový záznam","publisher":"Finanční správa ČR","url":"https://financnisprava.gov.cz/cs/dane/dane/dan-z-pridane-hodnoty/kontrolni-hlaseni-dph/zakladni-informace","consulted_on":"2026-09-25","kind":"guidance"},{"key":"kontrolni-hlaseni-sankce","title":"Kontrolní hlášení DPH — sankce podle § 101h zákona č. 235/2004 Sb.","publisher":"Finanční správa ČR","url":"https://financnisprava.gov.cz/cs/dane/dane/dan-z-pridane-hodnoty/kontrolni-hlaseni-dph/sankce","consulted_on":"2026-09-25","kind":"guidance"},{"key":"souhrnne-hlaseni-info","title":"Souhrnné hlášení — informace, formulář 25 5525 MFin 5525","publisher":"Finanční správa ČR","url":"https://financnisprava.gov.cz/cs/dane/dane/dan-z-pridane-hodnoty/informace-stanoviska-a-sdeleni/souhrnna-hlaseni","consulted_on":"2026-09-25","kind":"guidance"},{"key":"zakon-ucetnictvi","title":"Zákon č. 563/1991 Sb., o účetnictví, ve znění pozdějších předpisů","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/1991/563","consulted_on":"2026-09-25","kind":"law"},{"key":"vyhlaska-500-2002","title":"Vyhláška č. 500/2002 Sb., kterou se provádějí některá ustanovení zákona č. 563/1991 Sb., o účetnictví, pro účetní jednotky, které jsou podnikateli účtujícími v soustavě podvojného účetnictví — přílohy č. 1 (rozvaha), č. 2 (výkaz zisku a ztráty, druhové členění) a č. 4 (směrná účtová osnova)","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/2002/500","consulted_on":"2026-09-25","kind":"regulation"},{"key":"obcansky-zakonik","title":"Zákon č. 89/2012 Sb., občanský zákoník — § 1963 (splatnost ceny mezi podnikateli) a § 1970 a násl. (úrok z prodlení)","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/2012/89","consulted_on":"2026-09-25","kind":"law"},{"key":"nv-351-2013","title":"Nařízení vlády č. 351/2013 Sb., kterým se určuje výše úroků z prodlení — repo sazba ČNB platná pro první den příslušného kalendářního pololetí, zvýšená o 8 procentních bodů","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/2013/351","consulted_on":"2026-09-25","kind":"regulation"},{"key":"cnb-repo","title":"Jak postupovat při výpočtu úroku z prodlení — dvoutýdenní repo sazba ČNB","publisher":"Česká národní banka","url":"https://www.cnb.cz/cs/casto-kladene-dotazy/Vypocet-uroku-z-prodleni/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"zakon-ochrana-spotrebitele","title":"Zákon č. 634/1992 Sb., o ochraně spotřebitele — § 3 odst. 1 písm. c), arrondi du montant total à la valeur nominale la plus proche de la monnaie légale en circulation lors d''un paiement en espèces","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/1992/634","consulted_on":"2026-09-25","kind":"law"},{"key":"mf-zaokrouhleni-karta","title":"Zaokrouhlování při platbě kartou — stanovisko Ministerstva financí ČR : seul un paiement en espèces peut être arrondi, jamais un paiement sans espèces","publisher":"Ministerstvo financí ČR","url":"https://mfcr.gov.cz/cs/kontrola-a-regulace/cenova-regulace-a-kontrola/stanoviska-a-odpovedi/2017/zaokrouhlovani-pri-platbe-kartou-28591","consulted_on":"2026-09-25","kind":"guidance"},{"key":"zakon-zadavani-vz","title":"Zákon č. 134/2016 Sb., o zadávání veřejných zakázek — § 221 et § 279 odst. 5 písm. a), obligation pour les principaux pouvoirs adjudicateurs d''accepter depuis le 1er avril 2019 une facture électronique conforme à la norme EN 16931","publisher":"Ministerstvo vnitra ČR — e-Sbírka","url":"https://e-sbirka.gov.cz/sb/2016/134","consulted_on":"2026-09-25","kind":"law"},{"key":"mf-e-fakturace","title":"Elektronická fakturace — právní rámce (EN 16931, marchés publics)","publisher":"Ministerstvo financí ČR","url":"https://mfcr.gov.cz/cs/verejny-sektor/elektronicka-fakturace/pravni-ramce","consulted_on":"2026-09-25","kind":"guidance"},{"key":"isdoc-mvcr","title":"ISDOC — formát elektronické fakturace (Information System Document), licence a značka u Ministerstva vnitra ČR od 5. května 2021","publisher":"Ministerstvo vnitra ČR","url":"https://mv.gov.cz/isdoc/clanek/elektronicka-fakturace.aspx","consulted_on":"2026-09-25","kind":"portal"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('CZ', 'default', 'Účtový rozvrh podle směrné účtové osnovy (příloha č. 4 vyhlášky č. 500/2002 Sb.)', '{}'::jsonb, true, 'companies', array['CZ-VYHL500-ROZVAHA', 'CZ-VYHL500-VZZ-DRUHOVE']::text[], null, 'Vyhláška č. 500/2002 Sb., příloha č. 4 — la směrná účtová osnova fixe, par force de la loi, les účtové třídy (classe, un chiffre) et účtové skupiny (groupe, deux chiffres) que toute entreprise doit respecter ; elle ne va pas plus loin, à la différence du plan comptable général français normalisé jusqu''au sixième chiffre. Chaque entreprise construit ensuite son propre účtový rozvrh, ses comptes synthétiques (troisième chiffre et au-delà) et analytiques, dans le cadre de ces groupes — zákon č. 563/1991 Sb. § 4 odst. 8 renvoie ce pouvoir réglementaire à la vyhláška, qui l''exerce à ce niveau précis. Les comptes à trois chiffres et plus de ce fichier sont donc la construction de ce pack, dans la convention la plus répandue de la pratique comptable tchèque (celle enseignée et celle des logiciels du marché), et non un texte à citer un par un ; seuls le chiffre de la třída et les deux chiffres de la skupina — les deux premiers chiffres de chaque code — sont d''origine légale.', 'vyhlaska-500-2002')
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
  ('CZ', 'default', '012', 'Ocenitelná práva', '{}'::jsonb, 'asset_fixed', false, null, 600),
  ('CZ', 'default', '013', 'Software', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('CZ', 'default', '019', 'Ostatní dlouhodobý nehmotný majetek', '{}'::jsonb, 'asset_fixed', false, null, 610),
  ('CZ', 'default', '021', 'Stavby', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('CZ', 'default', '022', 'Samostatné hmotné movité věci a soubory movitých věcí', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('CZ', 'default', '042', 'Nedokončený dlouhodobý hmotný majetek', '{}'::jsonb, 'asset_fixed', false, null, 630),
  ('CZ', 'default', '052', 'Poskytnuté zálohy na dlouhodobý hmotný majetek', '{}'::jsonb, 'asset_fixed', false, null, 640),
  ('CZ', 'default', '061', 'Podíly — ovládaná nebo ovládající osoba', '{}'::jsonb, 'asset_non_current', false, null, 70),
  ('CZ', 'default', '062', 'Podíly v účetních jednotkách pod podstatným vlivem', '{}'::jsonb, 'asset_non_current', false, null, 660),
  ('CZ', 'default', '063', 'Ostatní dlouhodobé cenné papíry a podíly', '{}'::jsonb, 'asset_non_current', false, null, 670),
  ('CZ', 'default', '069', 'Jiný dlouhodobý finanční majetek', '{}'::jsonb, 'asset_non_current', false, null, 680),
  ('CZ', 'default', '073', 'Oprávky k softwaru', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('CZ', 'default', '079', 'Oprávky k ostatnímu dlouhodobému nehmotnému majetku', '{}'::jsonb, 'asset_fixed', false, null, 620),
  ('CZ', 'default', '081', 'Oprávky ke stavbám', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('CZ', 'default', '082', 'Oprávky k samostatným hmotným movitým věcem a souborům movitých věcí', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('CZ', 'default', '097', 'Opravná položka k dlouhodobému hmotnému majetku', '{}'::jsonb, 'asset_fixed', false, null, 650),
  ('CZ', 'default', '111', 'Pořízení materiálu', '{}'::jsonb, 'asset_current', false, null, 690),
  ('CZ', 'default', '112', 'Materiál na skladě', '{}'::jsonb, 'asset_current', false, null, 700),
  ('CZ', 'default', '119', 'Materiál na cestě', '{}'::jsonb, 'asset_current', false, null, 710),
  ('CZ', 'default', '121', 'Nedokončená výroba', '{}'::jsonb, 'asset_current', false, null, 720),
  ('CZ', 'default', '123', 'Výrobky', '{}'::jsonb, 'asset_current', false, null, 730),
  ('CZ', 'default', '131', 'Pořízení zboží', '{}'::jsonb, 'asset_current', false, null, 740),
  ('CZ', 'default', '132', 'Zboží na skladě a v prodejnách', '{}'::jsonb, 'asset_current', false, null, 80),
  ('CZ', 'default', '139', 'Zboží na cestě', '{}'::jsonb, 'asset_current', false, null, 750),
  ('CZ', 'default', '211', 'Pokladna', '{}'::jsonb, 'asset_cash', false, null, 150),
  ('CZ', 'default', '213', 'Ceniny', '{}'::jsonb, 'asset_cash', false, null, 760),
  ('CZ', 'default', '221', 'Bankovní účty', '{}'::jsonb, 'asset_cash', false, null, 160),
  ('CZ', 'default', '231', 'Krátkodobé bankovní úvěry', '{}'::jsonb, 'liability_current', false, null, 820),
  ('CZ', 'default', '311', 'Odběratelé', '{}'::jsonb, 'asset_receivable', true, null, 90),
  ('CZ', 'default', '312', 'Směnky k inkasu', '{}'::jsonb, 'asset_current', false, null, 770),
  ('CZ', 'default', '314', 'Poskytnuté zálohy', '{}'::jsonb, 'asset_current', false, null, 100),
  ('CZ', 'default', '315', 'Ostatní pohledávky', '{}'::jsonb, 'asset_current', false, null, 110),
  ('CZ', 'default', '321', 'Dodavatelé', '{}'::jsonb, 'liability_payable', true, null, 240),
  ('CZ', 'default', '324', 'Přijaté zálohy', '{}'::jsonb, 'liability_current', false, null, 250),
  ('CZ', 'default', '325', 'Ostatní závazky', '{}'::jsonb, 'liability_current', false, null, 260),
  ('CZ', 'default', '331', 'Zaměstnanci', '{}'::jsonb, 'liability_current', false, null, 270),
  ('CZ', 'default', '335', 'Pohledávky za zaměstnanci', '{}'::jsonb, 'asset_current', false, null, 120),
  ('CZ', 'default', '336', 'Zúčtování s institucemi sociálního zabezpečení a zdravotního pojištění', '{}'::jsonb, 'liability_current', false, null, 280),
  ('CZ', 'default', '341', 'Daň z příjmů', '{}'::jsonb, 'liability_current', false, null, 290),
  ('CZ', 'default', '3431', 'Daň z přidané hodnoty na výstupu — základní sazba', '{}'::jsonb, 'liability_current', false, null, 300),
  ('CZ', 'default', '3432', 'Daň z přidané hodnoty na výstupu — snížená sazba', '{}'::jsonb, 'liability_current', false, null, 310),
  ('CZ', 'default', '3433', 'Daň z přidané hodnoty na vstupu — nárok na odpočet', '{}'::jsonb, 'asset_current', false, null, 130),
  ('CZ', 'default', '3438', 'Zúčtování s finančním úřadem — daň z přidané hodnoty — závazek k úhradě', '{}'::jsonb, 'liability_current', true, null, 320),
  ('CZ', 'default', '3439', 'Zúčtování s finančním úřadem — daň z přidané hodnoty — nadměrný odpočet', '{}'::jsonb, 'asset_current', true, null, 140),
  ('CZ', 'default', '355', 'Ostatní pohledávky za společníky', '{}'::jsonb, 'asset_current', false, null, 780),
  ('CZ', 'default', '365', 'Ostatní závazky ke společníkům a členům družstva', '{}'::jsonb, 'liability_current', false, null, 830),
  ('CZ', 'default', '378', 'Jiné pohledávky', '{}'::jsonb, 'asset_current', false, null, 790),
  ('CZ', 'default', '379', 'Jiné závazky', '{}'::jsonb, 'liability_current', false, null, 840),
  ('CZ', 'default', '381', 'Náklady příštích období', '{}'::jsonb, 'asset_prepayments', false, null, 170),
  ('CZ', 'default', '383', 'Výdaje příštích období', '{}'::jsonb, 'liability_current', false, null, 330),
  ('CZ', 'default', '384', 'Výnosy příštích období', '{}'::jsonb, 'liability_current', false, null, 340),
  ('CZ', 'default', '385', 'Příjmy příštích období', '{}'::jsonb, 'asset_current', false, null, 180),
  ('CZ', 'default', '388', 'Dohadné účty aktivní', '{}'::jsonb, 'asset_current', false, null, 800),
  ('CZ', 'default', '389', 'Dohadné účty pasivní', '{}'::jsonb, 'liability_current', false, null, 850),
  ('CZ', 'default', '391', 'Opravná položka k pohledávkám', '{}'::jsonb, 'asset_current', false, null, 810),
  ('CZ', 'default', '411', 'Základní kapitál', '{}'::jsonb, 'equity', false, null, 190),
  ('CZ', 'default', '412', 'Ážio', '{}'::jsonb, 'equity', false, null, 860),
  ('CZ', 'default', '413', 'Ostatní kapitálové fondy', '{}'::jsonb, 'equity', false, null, 870),
  ('CZ', 'default', '419', 'Změny základního kapitálu', '{}'::jsonb, 'equity', false, null, 880),
  ('CZ', 'default', '421', 'Rezervní fond', '{}'::jsonb, 'equity', false, null, 890),
  ('CZ', 'default', '423', 'Statutární fondy', '{}'::jsonb, 'equity', false, null, 900),
  ('CZ', 'default', '426', 'Jiný výsledek hospodaření minulých let', '{}'::jsonb, 'equity_retained', false, null, 920),
  ('CZ', 'default', '427', 'Ostatní fondy', '{}'::jsonb, 'equity', false, null, 910),
  ('CZ', 'default', '428', 'Nerozdělený zisk minulých let', '{}'::jsonb, 'equity_retained', false, null, 200),
  ('CZ', 'default', '429', 'Neuhrazená ztráta minulých let', '{}'::jsonb, 'equity_retained', false, null, 210),
  ('CZ', 'default', '431', 'Výsledek hospodaření ve schvalovacím řízení', '{}'::jsonb, 'equity', false, null, 220),
  ('CZ', 'default', '451', 'Rezervy podle zvláštních právních předpisů', '{}'::jsonb, 'liability_non_current', false, null, 930),
  ('CZ', 'default', '459', 'Ostatní rezervy', '{}'::jsonb, 'liability_non_current', false, null, 940),
  ('CZ', 'default', '461', 'Bankovní úvěry', '{}'::jsonb, 'liability_non_current', false, null, 230),
  ('CZ', 'default', '479', 'Jiné dlouhodobé závazky', '{}'::jsonb, 'liability_non_current', false, null, 950),
  ('CZ', 'default', '481', 'Odložený daňový závazek a pohledávka', '{}'::jsonb, 'liability_non_current', false, null, 960),
  ('CZ', 'default', '501', 'Spotřeba materiálu', '{}'::jsonb, 'expense', false, null, 410),
  ('CZ', 'default', '502', 'Spotřeba energie', '{}'::jsonb, 'expense', false, null, 420),
  ('CZ', 'default', '504', 'Prodané zboží', '{}'::jsonb, 'expense_direct_cost', false, null, 400),
  ('CZ', 'default', '511', 'Opravy a udržování', '{}'::jsonb, 'expense', false, null, 430),
  ('CZ', 'default', '512', 'Cestovné', '{}'::jsonb, 'expense', false, null, 440),
  ('CZ', 'default', '513', 'Náklady na reprezentaci', '{}'::jsonb, 'expense', false, null, 450),
  ('CZ', 'default', '5181', 'Nájemné', '{}'::jsonb, 'expense', false, null, 460),
  ('CZ', 'default', '5182', 'Telekomunikační služby a internet', '{}'::jsonb, 'expense', false, null, 470),
  ('CZ', 'default', '5183', 'Poradenské, právní a účetní služby', '{}'::jsonb, 'expense', false, null, 480),
  ('CZ', 'default', '5184', 'Přepravné a poštovné', '{}'::jsonb, 'expense', false, null, 490),
  ('CZ', 'default', '5185', 'Ostatní služby', '{}'::jsonb, 'expense', false, null, 495),
  ('CZ', 'default', '521', 'Mzdové náklady', '{}'::jsonb, 'expense', false, null, 500),
  ('CZ', 'default', '524', 'Zákonné sociální a zdravotní pojištění', '{}'::jsonb, 'expense', false, null, 510),
  ('CZ', 'default', '538', 'Ostatní daně a poplatky', '{}'::jsonb, 'expense', false, null, 520),
  ('CZ', 'default', '543', 'Dary', '{}'::jsonb, 'expense', false, null, 970),
  ('CZ', 'default', '544', 'Smluvní pokuty a úroky z prodlení', '{}'::jsonb, 'expense', false, null, 530),
  ('CZ', 'default', '546', 'Odpis pohledávky', '{}'::jsonb, 'expense', false, null, 980),
  ('CZ', 'default', '549', 'Jiné provozní náklady', '{}'::jsonb, 'expense', false, null, 540),
  ('CZ', 'default', '551', 'Odpisy dlouhodobého nehmotného a hmotného majetku', '{}'::jsonb, 'expense_depreciation', false, null, 550),
  ('CZ', 'default', '558', 'Náklady z drobného dlouhodobého majetku', '{}'::jsonb, 'expense', false, null, 990),
  ('CZ', 'default', '562', 'Nákladové úroky', '{}'::jsonb, 'expense', false, null, 560),
  ('CZ', 'default', '563', 'Kurzové ztráty', '{}'::jsonb, 'expense', false, null, 570),
  ('CZ', 'default', '568', 'Ostatní finanční náklady', '{}'::jsonb, 'expense', false, null, 580),
  ('CZ', 'default', '591', 'Daň z příjmů splatná', '{}'::jsonb, 'expense', false, null, 590),
  ('CZ', 'default', '601', 'Tržby za vlastní výrobky', '{}'::jsonb, 'income', false, null, 1000),
  ('CZ', 'default', '602', 'Tržby z prodeje služeb', '{}'::jsonb, 'income', false, null, 350),
  ('CZ', 'default', '604', 'Tržby za zboží', '{}'::jsonb, 'income', false, null, 360),
  ('CZ', 'default', '621', 'Aktivace materiálu a zboží', '{}'::jsonb, 'income_other', false, null, 1010),
  ('CZ', 'default', '641', 'Tržby z prodeje dlouhodobého nehmotného a hmotného majetku', '{}'::jsonb, 'income_other', false, null, 1020),
  ('CZ', 'default', '642', 'Tržby z prodeje materiálu', '{}'::jsonb, 'income_other', false, null, 1030),
  ('CZ', 'default', '644', 'Smluvní pokuty a úroky z prodlení', '{}'::jsonb, 'income_other', false, null, 1040),
  ('CZ', 'default', '646', 'Výnosy z odepsaných pohledávek', '{}'::jsonb, 'income_other', false, null, 1050),
  ('CZ', 'default', '648', 'Ostatní provozní výnosy', '{}'::jsonb, 'income_other', false, null, 370),
  ('CZ', 'default', '662', 'Výnosové úroky', '{}'::jsonb, 'income_other', false, null, 380),
  ('CZ', 'default', '663', 'Kurzové zisky', '{}'::jsonb, 'income_other', false, null, 390)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('CZ', 'BANK', 'Bankovní výpisy', '{}'::jsonb, 'bank', 30),
  ('CZ', 'FP', 'Faktury přijaté', '{}'::jsonb, 'purchase', 20),
  ('CZ', 'FV', 'Faktury vydané', '{}'::jsonb, 'sales', 10),
  ('CZ', 'INT', 'Interní doklady', '{}'::jsonb, 'general', 50),
  ('CZ', 'POKL', 'Pokladna', '{}'::jsonb, 'cash', 40),
  ('CZ', 'PS', 'Počáteční stavy', '{}'::jsonb, 'opening', 60)
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
  ('CZ', 'CZ-P-12', 'Daň na vstupu 12 % — plný nárok na odpočet', '{}'::jsonb, 'Achat domestique au taux réduit, intégralement déductible', 'percent', 12, 'purchase', 'domestic', date '2024-01-01', null, 'Zákon č. 235/2004 Sb., § 72 odst. 1 písm. a) et § 47 odst. 1 písm. b).', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-P-21', 'Daň na vstupu 21 % — plný nárok na odpočet', '{}'::jsonb, 'Achat domestique au taux de base, intégralement déductible', 'percent', 21, 'purchase', 'domestic', date '2024-01-01', null, 'Zákon č. 235/2004 Sb., § 72 odst. 1 písm. a) et § 47 odst. 1 písm. a) — l''assujetti a droit à la déduction de la taxe qui lui a été facturée sur une acquisition utilisée pour ses activités économiques imposables, ici au taux de base de 21 %.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-P-PN-STAVBY', 'Stavební nebo montážní práce v režimu přenesení daňové povinnosti', '{}'::jsonb, 'Reverse charge domestique du secteur du bâtiment, base standard', 'percent', 21, 'purchase', 'domestic_reverse_charge', date '2024-01-01', null, 'Zákon č. 235/2004 Sb., § 92a et § 92e — le preneur assujetti d''une prestation de travaux de construction ou de montage (code CZ-CPA 41 à 43) reçue d''un autre assujetti établi et pour laquelle le lieu de la prestation est le territoire national est tenu de déclarer lui-même la taxe ; § 73 odst. 1 písm. b) lui ouvre, dans la même déclaration, le droit à déduction de la même somme lorsque la prestation est affectée à son activité économique imposable.', 'AE', 'VATEX-EU-AE', 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-P-VOP', 'Pořízení zboží z jiného členského státu', '{}'::jsonb, 'Acquisition intracommunautaire de biens, autoliquidée par l''acquéreur, base standard', 'percent', 21, 'purchase', 'intracom_acquisition_goods', date '2024-01-01', null, 'Zákon č. 235/2004 Sb., § 25 — l''acquisition intracommunautaire de biens est réalisée, et la taxe devient exigible, à la date d''émission du document fiscal ou, au plus tard, le quinzième jour du mois suivant celui de l''acquisition ; § 108 odst. 1 písm. b) désigne l''acquéreur comme redevable ; § 73 odst. 1 písm. b) lui ouvre, dans la même déclaration, le droit à déduction de la même somme lorsque le bien est affecté à son activité économique imposable.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-S-12', 'Daň na výstupu 12 %', '{}'::jsonb, 'Snížená sazba', 'percent', 12, 'sale', 'domestic', date '2024-01-01', null, 'Zákon č. 235/2004 Sb., § 47 odst. 1 písm. b) — snížená sazba daně činí 12 %, pro zboží a služby uvedené v přílohách č. 2 a č. 3 zákona ; ve znění zákona č. 349/2023 Sb. depuis le 1er janvier 2024, qui fusionne les deux anciens taux réduits de 10 % et 15 % en un seul.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-S-21', 'Daň na výstupu 21 %', '{}'::jsonb, 'Základní sazba', 'percent', 21, 'sale', 'domestic', date '2024-01-01', null, 'Zákon č. 235/2004 Sb., § 47 odst. 1 písm. a) — základní sazba daně činí 21 % pro zdanitelné plnění, není-li dále stanoveno jinak, ve znění zákona č. 349/2023 Sb. s účinností od 1. ledna 2024.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-S-OSV-NAJEM', 'Nájem nemovité věci osvobozený od daně', '{}'::jsonb, 'Bail immobilier exonéré sans droit à déduction', 'percent', 0, 'sale', 'exempt', date '2004-05-01', null, 'Zákon č. 235/2004 Sb., § 56a odst. 1 — le nájem (bail) d''un bien immeuble est exonéré de la taxe sans droit à déduction, sauf option du bailleur pour la taxation prévue à l''odst. 3 lorsque le preneur est lui-même assujetti ; ce pack ne modélise pas l''option. Correspond à l''article 135, paragraphe 1, point l), de la directive 2006/112/CE (location de biens immeubles).', 'E', 'VATEX-EU-135-1', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-S-SLUZBY-EU', 'Poskytnutí služby osobě registrované k dani v jiném členském státě', '{}'::jsonb, 'Prestation de services B2B intracommunautaire, règle générale de territorialité', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Zákon č. 235/2004 Sb., § 9 odst. 1 — le lieu de la prestation d''un service à un assujetti est le lieu où celui-ci a établi le siège de son activité économique, transposition de l''article 44 de la directive 2006/112/CE ; la taxe y est due par le preneur, ce qui exonère le prestataire tchèque sans le priver du droit à déduction.', 'K', 'VATEX-EU-IC', 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-S-VOP', 'Dodání zboží do jiného členského státu', '{}'::jsonb, 'Livraison intracommunautaire de biens, exonérée avec droit à déduction', 'percent', 0, 'sale', 'intracom_goods', date '2004-05-01', null, 'Zákon č. 235/2004 Sb., § 64 odst. 1 — la livraison de biens expédiés ou transportés d''un autre État membre par le vendeur, l''acquéreur ou en leur nom à destination d''une personne enregistrée à la TVA dans un autre État membre est exonérée avec droit à déduction.', 'K', 'VATEX-EU-IC', 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null),
  ('CZ', 'CZ-S-VYVOZ', 'Vývoz zboží', '{}'::jsonb, 'Export de biens hors de l''Union européenne', 'percent', 0, 'sale', 'export', date '2004-05-01', null, 'Zákon č. 235/2004 Sb., § 66 — l''exportation de biens, c''est-à-dire leur sortie du territoire douanier de l''Union européenne, est exonérée avec droit à déduction, sous réserve de la preuve de la sortie.', 'G', 'VATEX-EU-G', 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zakon-dph', null, null, null, null)
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
    ('CZ-P-12', 'invoice', 'base', 100, null, '41', array['41']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-12', 'invoice', 'tax', 100, '3433', '41', array['41']::text[], 100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-12', 'credit_note', 'base', 100, null, '41', array['41']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-12', 'credit_note', 'tax', 100, '3433', '41', array['41']::text[], -100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-21', 'invoice', 'base', 100, null, '40', array['40']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-21', 'invoice', 'tax', 100, '3433', '40', array['40']::text[], 100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-21', 'credit_note', 'base', 100, null, '40', array['40']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-21', 'credit_note', 'tax', 100, '3433', '40', array['40']::text[], -100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-PN-STAVBY', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-PN-STAVBY', 'invoice', 'tax', 100, '3431', '10', array['10']::text[], 100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-PN-STAVBY', 'invoice', 'tax', -100, '3433', null, null, 100, null, 30),
    ('CZ-P-PN-STAVBY', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-PN-STAVBY', 'credit_note', 'tax', 100, '3431', '10', array['10']::text[], -100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-PN-STAVBY', 'credit_note', 'tax', 100, '3433', null, null, 100, null, 30),
    ('CZ-P-VOP', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-VOP', 'invoice', 'tax', 100, '3431', '3', array['3']::text[], 100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-VOP', 'invoice', 'tax', -100, '3433', null, null, 100, null, 30),
    ('CZ-P-VOP', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-P-VOP', 'credit_note', 'tax', 100, '3431', '3', array['3']::text[], -100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-P-VOP', 'credit_note', 'tax', 100, '3433', null, null, 100, null, 30),
    ('CZ-S-12', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-12', 'invoice', 'tax', 100, '3432', '2', array['2']::text[], 100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-S-12', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-12', 'credit_note', 'tax', 100, '3432', '2', array['2']::text[], -100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-S-21', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-21', 'invoice', 'tax', 100, '3431', '1', array['1']::text[], 100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-S-21', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-21', 'credit_note', 'tax', 100, '3431', '1', array['1']::text[], -100, 'CZ-DPH-PRIZNANI', 20),
    ('CZ-S-OSV-NAJEM', 'invoice', 'base', 100, null, '50', array['50']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-OSV-NAJEM', 'credit_note', 'base', 100, null, '50', array['50']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-SLUZBY-EU', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-SLUZBY-EU', 'credit_note', 'base', 100, null, '21', array['21']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-VOP', 'invoice', 'base', 100, null, '20', array['20']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-VOP', 'credit_note', 'base', 100, null, '20', array['20']::text[], -100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-VYVOZ', 'invoice', 'base', 100, null, '22', array['22']::text[], 100, 'CZ-DPH-PRIZNANI', 10),
    ('CZ-S-VYVOZ', 'credit_note', 'base', 100, null, '22', array['22']::text[], -100, 'CZ-DPH-PRIZNANI', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'CZ' and t.code = v.tax_code
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
  ('CZ', 'CZ-DPH-PRIZNANI', 'Přiznání k dani z přidané hodnoty (tiskopis 25 5401 MFin 5401, vzor č. 25)', array['month', 'quarter']::declaration_period[], 'month'::declaration_period, date '2025-01-01', null, 'Zákon č. 235/2004 Sb., § 99 — zdaňovacím obdobím je kalendářní měsíc, není-li dále stanoveno jinak ; § 99a odst. 1 — un assujetti dont le chiffre d''affaires de l''année civile précédente n''a pas dépassé 15 000 000 Kč peut opter, par une déclaration à l''administration, pour un exercice trimestriel (seuil relevé de 10 000 000 Kč à 15 000 000 Kč par la novelle applicable depuis le 1er janvier 2025). La loi donne donc une réponse valable pour tous — mensuel — et une option ouverte sous condition de chiffre d''affaires, d''où period_default mensuel.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Zákon č. 235/2004 Sb., § 101 odst. 1 — le plátce dépose sa déclaration au plus tard le vingt-cinquième jour suivant la fin de la période imposable, y compris lorsqu''aucune taxe n''est due ; ce délai ne peut être prorogé.', 'zakon-dph', null)
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
  ('CZ', 'CZ-DPH-PRIZNANI', '1', 'base', 'Dodání zboží nebo poskytnutí služby s místem plnění v tuzemsku — základní sazba', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 1 (základ daně) ; zákon č. 235/2004 Sb., § 47 odst. 1 písm. a).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '1', 'tax', 'Dodání zboží nebo poskytnutí služby s místem plnění v tuzemsku — základní sazba — daň', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 1 (daň).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '2', 'base', 'Dodání zboží nebo poskytnutí služby s místem plnění v tuzemsku — snížená sazba', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 2 (základ daně) ; zákon č. 235/2004 Sb., § 47 odst. 1 písm. b).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '2', 'tax', 'Dodání zboží nebo poskytnutí služby s místem plnění v tuzemsku — snížená sazba — daň', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 2 (daň).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '3', 'base', 'Pořízení zboží z jiného členského státu — základní sazba', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 3 (základ daně) ; zákon č. 235/2004 Sb., § 25 a § 108 odst. 1 písm. b).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '3', 'tax', 'Pořízení zboží z jiného členského státu — základní sazba — daň', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 3 (daň).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '10', 'base', 'Režim přenesení daňové povinnosti — příjemce — základní sazba', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 10 (základ daně) ; zákon č. 235/2004 Sb., § 92a a § 92e.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '10', 'tax', 'Režim přenesení daňové povinnosti — příjemce — základní sazba — daň', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 10 (daň).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '20', 'base', 'Dodání zboží do jiného členského státu', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 20 ; zákon č. 235/2004 Sb., § 64.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '21', 'base', 'Poskytnutí služeb s místem plnění v jiném členském státě', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 21 ; zákon č. 235/2004 Sb., § 9 odst. 1.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '22', 'base', 'Vývoz zboží', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 22 ; zákon č. 235/2004 Sb., § 66.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '50', 'base', 'Plnění osvobozená od daně bez nároku na odpočet daně', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 50 ; zákon č. 235/2004 Sb., § 51 a násl.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '40', 'base', 'Přijatá zdanitelná plnění od plátců — základní sazba', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 40 (základ daně) ; zákon č. 235/2004 Sb., § 72 odst. 1 písm. a).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '40', 'tax', 'Přijatá zdanitelná plnění od plátců — základní sazba — daň v plné výši', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 40 (daň v plné výši).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '41', 'base', 'Přijatá zdanitelná plnění od plátců — snížená sazba', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 41 (základ daně) ; zákon č. 235/2004 Sb., § 72 odst. 1 písm. a).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '41', 'tax', 'Přijatá zdanitelná plnění od plátců — snížená sazba — daň v plné výši', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 41 (daň v plné výši).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '43', 'total', 'Zdanitelná plnění řádků 3 a 10 — základní sazba (nárok na odpočet)', '{}'::jsonb, 170, null, array['3:tax', '10:tax']::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 43 — reporte, côté déduction, la taxe autoliquidée déjà déclarée aux lignes 3 à 13 côté sortie ; ce pack ne pose que les lignes 3 et 10, la somme se limite donc à elles deux. Zákon č. 235/2004 Sb., § 73 odst. 1 písm. b).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '46', 'total', 'Odpočet daně celkem', '{}'::jsonb, 180, null, array['40:tax', '41:tax', '43']::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 46 — součet řádků 40, 41, 42, 43, 44 a 45 ; ce pack ne pose que les lignes 40, 41 et 43.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '62', 'total', 'Daň na výstupu', '{}'::jsonb, 190, null, array['1:tax', '2:tax', '3:tax', '10:tax']::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 62 — součet řádků 1 až 13, snížený o řádek 61 ; ce pack ne pose que les lignes 1, 2, 3 et 10, et ne modélise pas la ligne 61 (vrácení daně, § 84).', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '63', 'total', 'Odpočet daně', '{}'::jsonb, 200, null, array['46']::text[], '{}'::text[], null, null, false, false, null, 'Tiskopis 25 5401, řádek 63 — součet řádků 46, 52, 53 a 60 ; ce pack ne pose que la ligne 46.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '64', 'total', 'Vlastní daňová povinnost', '{}'::jsonb, 210, null, array['62']::text[], array['63']::text[], null, null, true, false, null, 'Tiskopis 25 5401, řádek 64 — rozdíl řádků 62 a 63, je-li kladný.', 'priznani-dph-tiskopis'),
  ('CZ', 'CZ-DPH-PRIZNANI', '65', 'total', 'Nadměrný odpočet', '{}'::jsonb, 220, null, array['63']::text[], array['62']::text[], null, null, true, false, null, 'Tiskopis 25 5401, řádek 65 — rozdíl řádků 63 a 62, je-li kladný.', 'priznani-dph-tiskopis')
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
  ('CZ-VYHL500-ROZVAHA', 'CZ', 'default', 'Rozvaha podle přílohy č. 1 vyhlášky č. 500/2002 Sb.', 'balance_sheet', 'CZ-VYHL500', date '2016-01-01', null, 'Vyhláška č. 500/2002 Sb., § 4 a příloha č. 1 — structure de la rozvaha en quatre blocs (B. Stálá aktiva, C. Oběžná aktiva, D.1 Časové rozlišení aktiv côté actif ; A. Vlastní kapitál, B.+C. Cizí zdroje, D.1 Časové rozlišení pasiv côté passif), dans sa forme simplifiée en vigueur depuis la novelle de 2016 (vyhláška č. 250/2015 Sb.).', 'vyhlaska-500-2002'),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'CZ', 'default', 'Výkaz zisku a ztráty v druhovém členění podle přílohy č. 2 vyhlášky č. 500/2002 Sb.', 'income_statement', 'CZ-VYHL500', date '2016-01-01', null, 'Vyhláška č. 500/2002 Sb., § 3a odst. 1 et příloha č. 2 — le druhové členění (classification par nature de charge) est l''une des deux présentations que l''annexe autorise, retenue par ce pack ; l''účelové členění (par fonction, příloha č. 3) n''est pas modélisé ici.', 'vyhlaska-500-2002')
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
  ('CZ-VYHL500-ROZVAHA', 'AKT', null, 'AKTIVA CELKEM', '{}'::jsonb, 10, 1, true, array['AKT.B', 'AKT.C', 'AKT.D']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.B', 'AKT', 'B. Stálá aktiva', '{}'::jsonb, 20, 1, true, array['AKT.B.I', 'AKT.B.II', 'AKT.B.III']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.B.I', 'AKT.B', 'B.I. Dlouhodobý nehmotný majetek', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 'AKT.B', 'B.II. Dlouhodobý hmotný majetek', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.B.III', 'AKT.B', 'B.III. Dlouhodobý finanční majetek', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.C', 'AKT', 'C. Oběžná aktiva', '{}'::jsonb, 60, 1, true, array['AKT.C.I', 'AKT.C.II', 'AKT.C.III']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 'AKT.C', 'C.I. Zásoby', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 'AKT.C', 'C.II. Pohledávky', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.C.III', 'AKT.C', 'C.III./C.IV. Peněžní prostředky', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'AKT.D', 'AKT', 'D.1. Časové rozlišení aktiv', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS', null, 'PASIVA CELKEM', '{}'::jsonb, 110, 1, true, array['PAS.A', 'PAS.BC', 'PAS.D']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.A', 'PAS', 'A. Vlastní kapitál', '{}'::jsonb, 120, 1, true, array['PAS.A.I', 'PAS.A.II', 'PAS.A.III', 'PAS.A.IV', 'PAS.A.V']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.A.I', 'PAS.A', 'A.I. Základní kapitál', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.A.II', 'PAS.A', 'A.II. Ážio a kapitálové fondy', '{}'::jsonb, 135, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.A.III', 'PAS.A', 'A.III. Fondy ze zisku', '{}'::jsonb, 138, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.A.IV', 'PAS.A', 'A.IV. Výsledek hospodaření minulých let (+/-)', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.A.V', 'PAS.A', 'A.V. Výsledek hospodaření běžného účetního období (+/-)', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.BC', 'PAS', 'B.+C. Cizí zdroje', '{}'::jsonb, 160, 1, true, array['PAS.BC.0', 'PAS.BC.I', 'PAS.BC.II']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.BC.0', 'PAS.BC', 'B. Rezervy', '{}'::jsonb, 165, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.BC.I', 'PAS.BC', 'C.I. Dlouhodobé závazky', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 'PAS.BC', 'C.II. Krátkodobé závazky', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-ROZVAHA', 'PAS.D', 'PAS', 'D.1. Časové rozlišení pasiv', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R1', null, 'I. Tržby z prodeje výrobků a služeb', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R2', null, 'II. Tržby za prodej zboží', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.C', null, 'C. Aktivace', '{}'::jsonb, 25, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A', null, 'A. Výkonová spotřeba', '{}'::jsonb, 30, 1, true, array['VZZ.A1', 'VZZ.A2', 'VZZ.A3']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A1', 'VZZ.A', 'A.1. Náklady vynaložené na prodané zboží', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A2', 'VZZ.A', 'A.2. Spotřeba materiálu a energie', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 'VZZ.A', 'A.3. Služby', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.D', null, 'D. Osobní náklady', '{}'::jsonb, 70, 1, true, array['VZZ.D1', 'VZZ.D2']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.D1', 'VZZ.D', 'D.1. Mzdové náklady', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.D2', 'VZZ.D', 'D.2. Náklady na sociální zabezpečení, zdravotní pojištění a ostatní náklady', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.E', null, 'E. Úpravy hodnot v provozní oblasti', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R3', null, 'III. Ostatní provozní výnosy', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', null, 'F. Ostatní provozní náklady', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.PROVOZNI', null, '* Provozní výsledek hospodaření', '{}'::jsonb, 130, 1, true, array['VZZ.R1', 'VZZ.R2', 'VZZ.C', 'VZZ.R3']::text[], array['VZZ.A', 'VZZ.D', 'VZZ.E', 'VZZ.F']::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R6', null, 'VI. Výnosové úroky a podobné výnosy', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R7', null, 'VII. Ostatní finanční výnosy', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.H', null, 'H. Nákladové úroky a podobné náklady', '{}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.I', null, 'I. Ostatní finanční náklady', '{}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.FINANCNI', null, '* Finanční výsledek hospodaření', '{}'::jsonb, 180, 1, true, array['VZZ.R6', 'VZZ.R7']::text[], array['VZZ.H', 'VZZ.I']::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.PRED-ZDANENIM', null, '** Výsledek hospodaření před zdaněním', '{}'::jsonb, 190, 1, true, array['VZZ.PROVOZNI', 'VZZ.FINANCNI']::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.J', null, 'J. Daň z příjmů', '{}'::jsonb, 200, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.VYSLEDEK', null, '*** Výsledek hospodaření za účetní období', '{}'::jsonb, 210, 1, true, array['VZZ.PRED-ZDANENIM']::text[], array['VZZ.J']::text[], null, null, null)
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
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.I', 10, 'account_code', '013', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.I', 20, 'account_code', '073', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.I', 30, 'account_code', '012', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.I', 40, 'account_code', '019', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.I', 50, 'account_code', '079', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 10, 'account_code', '021', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 20, 'account_code', '081', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 30, 'account_code', '022', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 40, 'account_code', '082', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 50, 'account_code', '042', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 60, 'account_code', '052', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.II', 70, 'account_code', '097', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.III', 10, 'account_code', '061', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.III', 20, 'account_code', '062', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.III', 30, 'account_code', '063', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.B.III', 40, 'account_code', '069', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 10, 'account_code', '132', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 20, 'account_code', '111', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 30, 'account_code', '112', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 40, 'account_code', '119', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 50, 'account_code', '121', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 60, 'account_code', '123', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 70, 'account_code', '131', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.I', 80, 'account_code', '139', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 10, 'account_code', '311', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 20, 'account_code', '314', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 30, 'account_code', '315', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 40, 'account_code', '335', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 50, 'account_code', '3433', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 60, 'account_code', '3439', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 70, 'account_code', '312', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 80, 'account_code', '355', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 90, 'account_code', '378', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 100, 'account_code', '388', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.II', 110, 'account_code', '391', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.III', 10, 'account_code', '211', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.III', 20, 'account_code', '221', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.C.III', 30, 'account_code', '213', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.D', 10, 'account_code', '381', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'AKT.D', 20, 'account_code', '385', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.I', 10, 'account_code', '411', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.I', 20, 'account_code', '419', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.II', 10, 'account_code', '412', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.II', 20, 'account_code', '413', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.III', 10, 'account_code', '421', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.III', 20, 'account_code', '423', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.III', 30, 'account_code', '427', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.IV', 10, 'account_code', '428', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.IV', 20, 'account_code', '429', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.IV', 30, 'account_code', '426', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.A.V', 10, 'account_code', '431', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.0', 10, 'account_code', '451', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.0', 20, 'account_code', '459', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.I', 10, 'account_code', '461', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.I', 20, 'account_code', '479', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.I', 30, 'account_code', '481', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 10, 'account_code', '321', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 20, 'account_code', '324', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 30, 'account_code', '325', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 40, 'account_code', '331', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 50, 'account_code', '336', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 60, 'account_code', '341', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 70, 'account_code', '3431', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 80, 'account_code', '3432', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 90, 'account_code', '3438', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 100, 'account_code', '231', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 110, 'account_code', '365', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 120, 'account_code', '379', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.BC.II', 130, 'account_code', '389', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.D', 10, 'account_code', '383', null, null, 'any'),
    ('CZ-VYHL500-ROZVAHA', 'PAS.D', 20, 'account_code', '384', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R1', 10, 'account_code', '602', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R1', 20, 'account_code', '601', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R2', 10, 'account_code', '604', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.C', 10, 'account_code', '621', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A1', 10, 'account_code', '504', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A2', 10, 'account_code', '501', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A2', 20, 'account_code', '502', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 10, 'account_code', '511', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 20, 'account_code', '512', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 30, 'account_code', '513', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 40, 'account_code', '5181', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 50, 'account_code', '5182', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 60, 'account_code', '5183', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 70, 'account_code', '5184', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.A3', 80, 'account_code', '5185', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.D1', 10, 'account_code', '521', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.D2', 10, 'account_code', '524', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.E', 10, 'account_code', '551', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R3', 10, 'account_code', '648', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R3', 20, 'account_code', '641', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R3', 30, 'account_code', '642', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R3', 40, 'account_code', '644', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R3', 50, 'account_code', '646', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', 10, 'account_code', '538', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', 20, 'account_code', '544', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', 30, 'account_code', '549', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', 40, 'account_code', '543', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', 50, 'account_code', '546', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.F', 60, 'account_code', '558', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R6', 10, 'account_code', '662', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.R7', 10, 'account_code', '663', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.H', 10, 'account_code', '562', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.I', 10, 'account_code', '563', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.I', 20, 'account_code', '568', null, null, 'any'),
    ('CZ-VYHL500-VZZ-DRUHOVE', 'VZZ.J', 10, 'account_code', '591', null, null, 'any')
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
  ('CZ', 'Czechia', '{}'::jsonb, array['cs']::text[], 'CZK', '311', '321', '315', '549', '428', '604', '5185', '221', '211', 'FV', 'FP', 'INT', 'cs', 'result_accounts', '431', '431', '429', 'PS', 'half_up', 1, '663', '563', null, null, null, null, '3438', '3439', null, 'month'::declaration_period)
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
  number_format                 = '{CODE}{YYYY}{NNNN}',
  legal_payment_days            = 30,
  late_payment_reference        = 'Zákon č. 89/2012 Sb., občanský zákoník, § 1963 odst. 1 — à défaut d''accord entre les parties, le prix est exigible dans les 30 jours suivant la remise de la facture (ou la livraison, ou la réception, selon l''événement le plus tardif prévu par le texte) ; § 1963 odst. 2 — un délai supérieur à 60 jours n''est licite qu''à la condition de ne pas être manifestement inéquitable envers le créancier. § 1970 et § 1971 — l''intérêt de retard est dû de plein droit dès l''exigibilité, à un taux fixé par le gouvernement (nařízení vlády č. 351/2013 Sb. : la sazba repo à deux semaines de la ČNB en vigueur le premier jour du semestre civil où le retard survient, majorée de 8 points — 3,75 % + 8 = 11,75 % au second semestre 2026) plutôt que par la loi elle-même.',
  numbering_legal_reference     = 'Zákon č. 235/2004 Sb., § 29 odst. 1 písm. e) — le daňový doklad porte un « evidenční číslo daňového dokladu », un numéro d''évidence qui l''identifie ; la loi exige l''unicité de ce numéro et non une suite sans trou ni une remise à zéro annuelle, d''où sequential et non gapless.',
  numbering_source_key          = 'zakon-dph',
  payment_terms_legal_reference = 'Zákon č. 89/2012 Sb., § 1963.',
  payment_terms_source_key      = 'obcansky-zakonik',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Zákon č. 235/2004 Sb., § 20a odst. 1 — la taxe devient exigible au jour de la réalisation de l''opération imposable (livraison du bien, prestation du service) ; odst. 2 — si un paiement est reçu avant cette réalisation, la taxe devient exigible, à hauteur du paiement reçu, au jour de sa réception, dès lors que l''opération future est connue avec une certitude suffisante à cette date. Les deux alinéas ensemble sont earliest_of_delivery_or_payment.',
  tax_point_source_key          = 'zakon-dph',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Zákon č. 563/1991 Sb., § 35 odst. 1 — une écriture erronée ne se corrige que d''une manière qui laisse le contenu initial lisible, jamais par une modification qui l''effacerait. Zákon č. 235/2004 Sb., § 42 et § 43 — un daňový doklad déjà émis se corrige par un opravný daňový doklad qui le vise, jamais par son annulation silencieuse.',
  posted_edit_policy_source_key = 'zakon-ucetnictvi',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'À la date released_at de ce pack, aucun texte n''impose l''échange d''une facture électronique structurée entre entreprises tchèques, ni en B2B ni en B2G au sens général. Ce que la loi impose est plus étroit : zákon č. 134/2016 Sb., o zadávání veřejných zakázek, § 221 et § 279 odst. 5 písm. a) — depuis le 1er avril 2019, les principaux pouvoirs adjudicateurs (dont l''État tchèque et la Česká národní banka) ne peuvent refuser une facture électronique conforme à la norme EN 16931-1:2017 dans le cadre d''un marché public ; c''est une obligation de réception pesant sur l''acheteur public, non une obligation d''émission pesant sur toute entreprise. Le format national ISDOC (XML, initié en 2008 par SPIS/ICT UNIE, dont la licence et la marque appartiennent depuis le 5 mai 2021 au Ministerstvo vnitra) est recommandé aux côtés d''EN 16931 pour ces marchés (usnesení vlády č. 347/2017), mais reste, comme EN 16931 lui-même ici, un format qu''aucune loi n''impose à une entreprise tchèque hors marché public. Voir docs/international.md, section « From Czechia », pour le paquet ViDA (adopté par le Conseil de l''Union le 11 mars 2025), dont le calendrier — 1er juillet 2030 pour les opérations intracommunautaires B2B, 1er janvier 2035 au plus tard pour l''harmonisation des systèmes domestiques — n''a encore fait l''objet d''aucun projet de loi tchèque de transposition à released_at.',
  einvoice_source_key           = 'zakon-zadavani-vz',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'CZ';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('CZ', 'reverse_charge', 'reverse_charge', 'Daň odvede zákazník', '{}'::jsonb, 10, date '1970-01-01', null, 'Zákon č. 235/2004 Sb., § 29 odst. 2 písm. c) — lorsque la personne tenue de déclarer la taxe est celle pour qui l''opération est réalisée, le daňový doklad porte la mention « daň odvede zákazník » ; le libellé est fixé par la loi elle-même.'),
  ('CZ', 'intracom_goods', 'intra_eu_goods', 'Osvobozeno od daně podle § 64 zákona č. 235/2004 Sb.', '{}'::jsonb, 20, date '1970-01-01', null, 'Zákon č. 235/2004 Sb., § 29 odst. 2 písm. a) — en cas d''exonération, le doklad renvoie à la disposition de la loi, de la directive ou toute autre mention indiquant que l''opération en est exonérée ; § 64 exonère avec droit à déduction la livraison de biens à destination d''un autre État membre à une personne y identifiée à la TVA.'),
  ('CZ', 'intracom_services', 'intra_eu_services', 'Daň odvede zákazník', '{}'::jsonb, 30, date '1970-01-01', null, 'Zákon č. 235/2004 Sb., § 29 odst. 2 písm. c) — la prestation de services à un assujetti établi dans un autre État membre, taxée là où le preneur est établi (§ 9 odst. 1, transposition de l''article 44 de la directive 2006/112/CE), porte la même mention que le reverse charge domestique : c''est le preneur qui déclare la taxe.'),
  ('CZ', 'export', 'export', 'Vývoz zboží osvobozený od daně podle § 66 zákona č. 235/2004 Sb.', '{}'::jsonb, 40, date '1970-01-01', null, 'Zákon č. 235/2004 Sb., § 29 odst. 2 písm. a) et § 66 — l''exportation de biens hors du territoire de l''Union est exonérée avec droit à déduction, sous réserve de la preuve de sortie du territoire douanier.'),
  ('CZ', 'exempt', 'exempt', 'Osvobozeno od daně bez nároku na odpočet daně podle § 56a zákona č. 235/2004 Sb.', '{}'::jsonb, 50, date '1970-01-01', null, 'Zákon č. 235/2004 Sb., § 29 odst. 2 písm. a) et § 56a — le nájem (bail) de biens immeubles à une personne autre qu''un assujetti ou pour un usage résidentiel est exonéré sans droit à déduction ; le doklad renvoie à l''article qui exonère l''opération, dont le libellé exact n''est pas imposé par la loi.'),
  ('CZ', 'late_payment', 'late_payment', 'En cas de retard de paiement entre entreprises, un intérêt de retard est dû de plein droit au taux repo à deux semaines de la ČNB en vigueur le premier jour du semestre, majoré de 8 points (§ 1970 zákona č. 89/2012 Sb. et nařízení vlády č. 351/2013 Sb.).', '{}'::jsonb, 60, date '1970-01-01', null, 'Zákon č. 89/2012 Sb., § 1970 et nařízení vlády č. 351/2013 Sb. — la mention n''est pas imposée par le texte ; elle est ici informative, à l''image des autres packs européens du dépôt qui rappellent le fondement de l''intérêt de retard.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
