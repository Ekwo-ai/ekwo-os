-- Ekwo OS — Slovenia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/si at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build si`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Zakon o davku na dodano vrednost (ZDDV-1), Uradni list RS, št. 117/06, z zadnjo vsebinsko novelo ZDDV-1O (Uradni list RS, št. 104/24) — neuradno prečiščeno besedilo (Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije)
--     https://pisrs.si/pregledPredpisa?id=ZAKO4701
--   Zakon o gospodarskih družbah (ZGD-1), Uradni list RS, št. 65/09 — uradno prečiščeno besedilo, s poznejšimi spremembami — osmo poglavje, Poslovne knjige in letno poročilo (60. do 73. člen) (Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije)
--     https://pisrs.si/pregledPredpisa?id=ZAKO4291
--   Pravilnik o izvajanju Zakona o davku na dodano vrednost (Pravno-informacijski sistem Republike Slovenije (PISRS) — Ministrstvo za finance)
--     https://pisrs.si/Pis.web/pregledPredpisa?id=PRAV7542
--   Zakon o preprečevanju zamud pri plačilih (ZPreZP-1) — 12. člen (plačilni rok brez dogovora), 13. in 14. člen (zamudne obresti in pavšalno nadomestilo stroškov izterjave) (Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije)
--     https://pisrs.si/pregledPredpisa?id=ZAKO6412
--   Priloga X: obrazec DDV-O in Navodilo za izpolnjevanje obračuna DDV (Uradni list Republike Slovenije)
--     https://www.uradni-list.si/files/RS_-2010-104-05347-OB~P002-0000.PDF
--   Davek na dodano vrednost — Stopnje DDV, 14. izdaja, junij 2026 (Finančna uprava Republike Slovenije (FURS))
--     https://www.fu.gov.si/fileadmin/Internet/Davki_in_druge_dajatve/Podrocja/Davek_na_dodano_vrednost/Opis/Stopnje_DDV.docx
--   Value Added Tax (VAT) — areas of work (Finančna uprava Republike Slovenije (FURS))
--     https://www.fu.gov.si/en/taxes_and_other_duties/areas_of_work/value_added_tax_vat/
--   Davčni zavezanci in identifikacija za namene DDV (Finančna uprava Republike Slovenije (FURS))
--     https://www.fu.gov.si/fileadmin/Internet/Davki_in_druge_dajatve/Podrocja/Davek_na_dodano_vrednost/Opis/Davcni_zavezanci_in_identifikacija_za_namene_DDV.doc
--   Mehanizem obrnjene davčne obveznosti v določenih sektorjih (76.a člen ZDDV-1) (Finančna uprava Republike Slovenije (FURS))
--     https://www.fu.gov.si/fileadmin/Internet/Davki_in_druge_dajatve/Podrocja/Davek_na_dodano_vrednost/Opis/Mehanizem_obrnjene_davcne_obveznosti_v_dolocenih_sektorjih.doc
--   eDavki — elektronska oddaja obračuna DDV (DDV-O) in rekapitulacijskega poročila (Finančna uprava Republike Slovenije (FURS))
--     https://edavki.durs.si/EdavkiPortal/OpenPortal/CommonPages/Opdynp/PageD.aspx?category=obracun_ddv_podjetja&lng=en
--   Zakon o opravljanju plačilnih storitev za proračunske uporabnike (ZOPSPU-1), 26. člen (Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije)
--     https://pisrs.si/Pis.web/pregledPredpisa?id=ZAKO7120
--   e-invoicing of budget users — UJPeRačun, standard e-SLOG (Uprava Republike Slovenije za javna plačila (UJP))
--     https://www.gov.si/en/registries/services/e-invoicing-of-budget-users/
--   e-SLOG 2.0 — slovenski standard elektronskega računa in drugih poslovnih dokumentov (Gospodarska zbornica Slovenije (GZS) — Epos.si)
--     https://www.epos.si/eslog
--   Zakon o izmenjavi elektronskih računov in drugih elektronskih dokumentov (ZIERDED), Uradni list RS, št. 85/2025 (Uradni list Republike Slovenije)
--     https://www.uradni-list.si/glasilo-uradni-list-rs/vsebina/2025-01-3032/zakon-o-izmenjavi-elektronskih-racunov-in-drugih-elektronskih-dokumentov-zierded
--   EN 16931-1 — semantic data model of the core elements of an electronic invoice, required by Directive 2014/55/EU (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — VAT exemption reason code list (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   Electronic Address Scheme (EAS) — ISO 6523 identifier schemes, including 9949 (Slovenian VAT number) (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SI', 'Slovenia', '0.1.0', date '2026-09-25', '20260921145425', 'community', null, null, '43c52393b1394832eb678b463f53794dc933e3d8e129093701de005fa30f8a69', '[{"key":"zddv-1","title":"Zakon o davku na dodano vrednost (ZDDV-1), Uradni list RS, št. 117/06, z zadnjo vsebinsko novelo ZDDV-1O (Uradni list RS, št. 104/24) — neuradno prečiščeno besedilo","publisher":"Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije","url":"https://pisrs.si/pregledPredpisa?id=ZAKO4701","consulted_on":"2026-09-25","kind":"law"},{"key":"zgd-1","title":"Zakon o gospodarskih družbah (ZGD-1), Uradni list RS, št. 65/09 — uradno prečiščeno besedilo, s poznejšimi spremembami — osmo poglavje, Poslovne knjige in letno poročilo (60. do 73. člen)","publisher":"Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije","url":"https://pisrs.si/pregledPredpisa?id=ZAKO4291","consulted_on":"2026-09-25","kind":"law"},{"key":"pravilnik-zddv-1","title":"Pravilnik o izvajanju Zakona o davku na dodano vrednost","publisher":"Pravno-informacijski sistem Republike Slovenije (PISRS) — Ministrstvo za finance","url":"https://pisrs.si/Pis.web/pregledPredpisa?id=PRAV7542","consulted_on":"2026-09-25","kind":"regulation"},{"key":"zprezp-1","title":"Zakon o preprečevanju zamud pri plačilih (ZPreZP-1) — 12. člen (plačilni rok brez dogovora), 13. in 14. člen (zamudne obresti in pavšalno nadomestilo stroškov izterjave)","publisher":"Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije","url":"https://pisrs.si/pregledPredpisa?id=ZAKO6412","consulted_on":"2026-09-25","kind":"law"},{"key":"obrazec-ddv-o","title":"Priloga X: obrazec DDV-O in Navodilo za izpolnjevanje obračuna DDV","publisher":"Uradni list Republike Slovenije","url":"https://www.uradni-list.si/files/RS_-2010-104-05347-OB~P002-0000.PDF","consulted_on":"2026-09-25","kind":"form"},{"key":"furs-stopnje-ddv","title":"Davek na dodano vrednost — Stopnje DDV, 14. izdaja, junij 2026","publisher":"Finančna uprava Republike Slovenije (FURS)","url":"https://www.fu.gov.si/fileadmin/Internet/Davki_in_druge_dajatve/Podrocja/Davek_na_dodano_vrednost/Opis/Stopnje_DDV.docx","consulted_on":"2026-09-25","kind":"guidance"},{"key":"furs-vat-en","title":"Value Added Tax (VAT) — areas of work","publisher":"Finančna uprava Republike Slovenije (FURS)","url":"https://www.fu.gov.si/en/taxes_and_other_duties/areas_of_work/value_added_tax_vat/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"furs-davcni-zavezanci","title":"Davčni zavezanci in identifikacija za namene DDV","publisher":"Finančna uprava Republike Slovenije (FURS)","url":"https://www.fu.gov.si/fileadmin/Internet/Davki_in_druge_dajatve/Podrocja/Davek_na_dodano_vrednost/Opis/Davcni_zavezanci_in_identifikacija_za_namene_DDV.doc","consulted_on":"2026-09-25","kind":"guidance"},{"key":"furs-obrnjena-obveznost","title":"Mehanizem obrnjene davčne obveznosti v določenih sektorjih (76.a člen ZDDV-1)","publisher":"Finančna uprava Republike Slovenije (FURS)","url":"https://www.fu.gov.si/fileadmin/Internet/Davki_in_druge_dajatve/Podrocja/Davek_na_dodano_vrednost/Opis/Mehanizem_obrnjene_davcne_obveznosti_v_dolocenih_sektorjih.doc","consulted_on":"2026-09-25","kind":"guidance"},{"key":"edavki","title":"eDavki — elektronska oddaja obračuna DDV (DDV-O) in rekapitulacijskega poročila","publisher":"Finančna uprava Republike Slovenije (FURS)","url":"https://edavki.durs.si/EdavkiPortal/OpenPortal/CommonPages/Opdynp/PageD.aspx?category=obracun_ddv_podjetja&lng=en","consulted_on":"2026-09-25","kind":"portal"},{"key":"zopspu-1","title":"Zakon o opravljanju plačilnih storitev za proračunske uporabnike (ZOPSPU-1), 26. člen","publisher":"Pravno-informacijski sistem Republike Slovenije (PISRS) — Vlada Republike Slovenije","url":"https://pisrs.si/Pis.web/pregledPredpisa?id=ZAKO7120","consulted_on":"2026-09-25","kind":"law"},{"key":"ujp-eracun","title":"e-invoicing of budget users — UJPeRačun, standard e-SLOG","publisher":"Uprava Republike Slovenije za javna plačila (UJP)","url":"https://www.gov.si/en/registries/services/e-invoicing-of-budget-users/","consulted_on":"2026-09-25","kind":"portal"},{"key":"eslog","title":"e-SLOG 2.0 — slovenski standard elektronskega računa in drugih poslovnih dokumentov","publisher":"Gospodarska zbornica Slovenije (GZS) — Epos.si","url":"https://www.epos.si/eslog","consulted_on":"2026-09-25","kind":"standard"},{"key":"zierded","title":"Zakon o izmenjavi elektronskih računov in drugih elektronskih dokumentov (ZIERDED), Uradni list RS, št. 85/2025","publisher":"Uradni list Republike Slovenije","url":"https://www.uradni-list.si/glasilo-uradni-list-rs/vsebina/2025-01-3032/zakon-o-izmenjavi-elektronskih-racunov-in-drugih-elektronskih-dokumentov-zierded","consulted_on":"2026-09-25","kind":"law"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the core elements of an electronic invoice, required by Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — VAT exemption reason code list (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"},{"key":"peppol-eas","title":"Electronic Address Scheme (EAS) — ISO 6523 identifier schemes, including 9949 (Slovenian VAT number)","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('SI', 'default', 'Splošni kontni okvir po 65. in 66. členu ZGD-1', '{"en":"General chart of accounts by ZGD-1 articles 65 and 66"}'::jsonb, true, 'companies', array['SI-ZGD-BS', 'SI-ZGD-IS']::text[], null, 'ZGD-1 ne predpisuje oštevilčenega kontnega okvira: 65. in 66. člen predpisujeta le členitev bilance stanja in izkaza poslovnega izida, ne pa številk kontov. V praksi se v Sloveniji uporablja Enotni kontni okvir, ki ga je sprejel strokovni svet Slovenskega inštituta za revizijo (SIR) kot prilogo k Slovenskim računovodskim standardom (SRS) in ki je objavljen pod avtorskopravnim pridržkom SIR (izključno za osebno, nekomercialno rabo; vsaka druga oblika uporabe, vključno s kopiranjem in razmnoževanjem v komercialne namene, je prepovedana). Ta kontni okvir zato ne prevzema številk niti izrazov SIR-jevega Enotnega kontnega okvira: gre za lasten kontni okvir tega paketa, katerega prva števka razreda pomeni oddelek bilance po 65. členu (1 Dolgoročna sredstva, 2 Kratkoročna sredstva, 3 Kratkoročne aktivne časovne razmejitve, 4 Kapital, 5 Rezervacije in dolgoročne pasivne časovne razmejitve, 6 Dolgoročne obveznosti, 7 Kratkoročne obveznosti in kratkoročne pasivne časovne razmejitve) ali postavko izkaza poslovnega izida po 66. členu (8 poslovni prihodki in odhodki, postavke 1 do 8; 9 finančni prihodki in odhodki ter davki, postavke 9 do 19).', 'zgd-1')
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
  ('SI', 'default', '1000', 'Neopredmetena sredstva', '{"en":"Intangible assets"}'::jsonb, 'asset_fixed', false, null, 10),
  ('SI', 'default', '1010', 'Dolgoročne premoženjske pravice', '{"en":"Long-term property rights"}'::jsonb, 'asset_fixed', false, null, 20),
  ('SI', 'default', '1020', 'Dobro ime', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 30),
  ('SI', 'default', '1100', 'Zemljišča', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 40),
  ('SI', 'default', '1110', 'Zgradbe', '{"en":"Buildings"}'::jsonb, 'asset_fixed', false, null, 50),
  ('SI', 'default', '1200', 'Proizvajalne naprave in stroji', '{"en":"Production plant and machinery"}'::jsonb, 'asset_fixed', false, null, 60),
  ('SI', 'default', '1210', 'Druge naprave, oprema in nadomestni deli', '{"en":"Other equipment, tools and spare parts"}'::jsonb, 'asset_fixed', false, null, 70),
  ('SI', 'default', '1220', 'Drobni inventar', '{"en":"Small tools and inventory"}'::jsonb, 'asset_fixed', false, null, 80),
  ('SI', 'default', '1230', 'Osnovna sredstva v gradnji in izdelavi', '{"en":"Assets under construction"}'::jsonb, 'asset_fixed', false, null, 90),
  ('SI', 'default', '1300', 'Naložbene nepremičnine', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, null, 100),
  ('SI', 'default', '1400', 'Dolgoročne finančne naložbe', '{"en":"Long-term financial investments"}'::jsonb, 'asset_non_current', false, null, 110),
  ('SI', 'default', '1410', 'Deleži v kapitalu drugih podjetij', '{"en":"Equity investments in other companies"}'::jsonb, 'asset_non_current', false, null, 120),
  ('SI', 'default', '1420', 'Dana dolgoročna posojila', '{"en":"Long-term loans granted"}'::jsonb, 'asset_non_current', false, null, 130),
  ('SI', 'default', '1430', 'Dolgoročne naložbe v vrednostne papirje', '{"en":"Long-term investments in securities"}'::jsonb, 'asset_non_current', false, null, 140),
  ('SI', 'default', '1500', 'Dolgoročne poslovne terjatve', '{"en":"Long-term business receivables"}'::jsonb, 'asset_non_current', false, null, 150),
  ('SI', 'default', '1510', 'Dolgoročne terjatve do kupcev', '{"en":"Long-term trade receivables"}'::jsonb, 'asset_non_current', false, null, 160),
  ('SI', 'default', '1520', 'Dolgoročne terjatve do drugih', '{"en":"Other long-term receivables"}'::jsonb, 'asset_non_current', false, null, 170),
  ('SI', 'default', '1600', 'Odložene terjatve za davek', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 180),
  ('SI', 'default', '2000', 'Zaloge materiala', '{"en":"Raw material inventories"}'::jsonb, 'asset_current', false, null, 190),
  ('SI', 'default', '2010', 'Zaloge trgovskega blaga', '{"en":"Merchandise inventories"}'::jsonb, 'asset_current', false, null, 200),
  ('SI', 'default', '2020', 'Zaloge nedokončane proizvodnje', '{"en":"Work-in-progress inventories"}'::jsonb, 'asset_current', false, null, 210),
  ('SI', 'default', '2030', 'Zaloge gotovih izdelkov', '{"en":"Finished goods inventories"}'::jsonb, 'asset_current', false, null, 220),
  ('SI', 'default', '2040', 'Predujmi za zaloge', '{"en":"Advances for inventories"}'::jsonb, 'asset_current', false, null, 230),
  ('SI', 'default', '2100', 'Kratkoročne finančne naložbe', '{"en":"Short-term financial investments"}'::jsonb, 'asset_current', false, null, 240),
  ('SI', 'default', '2110', 'Kratkoročno dana posojila', '{"en":"Short-term loans granted"}'::jsonb, 'asset_current', false, null, 250),
  ('SI', 'default', '2120', 'Kratkoročne naložbe v vrednostne papirje', '{"en":"Short-term investments in securities"}'::jsonb, 'asset_current', false, null, 260),
  ('SI', 'default', '2200', 'Kratkoročne poslovne terjatve do kupcev v Sloveniji', '{"en":"Short-term trade receivables — Slovenia"}'::jsonb, 'asset_receivable', true, null, 270),
  ('SI', 'default', '2210', 'Kratkoročne poslovne terjatve do kupcev v EU', '{"en":"Short-term trade receivables — EU"}'::jsonb, 'asset_receivable', true, null, 280),
  ('SI', 'default', '2220', 'Kratkoročne poslovne terjatve do kupcev izven EU', '{"en":"Short-term trade receivables — outside the EU"}'::jsonb, 'asset_receivable', true, null, 290),
  ('SI', 'default', '2230', 'Terjatve za vstopni DDV po stopnji 22 %', '{"en":"Recoverable input VAT at 22%"}'::jsonb, 'asset_current', false, null, 300),
  ('SI', 'default', '2231', 'Terjatve za vstopni DDV po stopnji 9,5 %', '{"en":"Recoverable input VAT at 9.5%"}'::jsonb, 'asset_current', false, null, 310),
  ('SI', 'default', '2232', 'Terjatve za vstopni DDV od pridobitev blaga znotraj EU', '{"en":"Recoverable input VAT on intra-EU acquisitions of goods"}'::jsonb, 'asset_current', false, null, 320),
  ('SI', 'default', '2233', 'Terjatve za vstopni DDV od prejetih storitev iz EU', '{"en":"Recoverable input VAT on services received from the EU"}'::jsonb, 'asset_current', false, null, 330),
  ('SI', 'default', '2234', 'Terjatve za vstopni DDV od prejetih tujih storitev', '{"en":"Recoverable input VAT on foreign services received"}'::jsonb, 'asset_current', false, null, 340),
  ('SI', 'default', '2235', 'Terjatve za vstopni DDV od nabav po 76.a členu ZDDV-1', '{"en":"Recoverable input VAT on domestic reverse-charge purchases (article 76a)"}'::jsonb, 'asset_current', false, null, 350),
  ('SI', 'default', '2240', 'Terjatve do države za DDV', '{"en":"VAT receivable from the tax authority"}'::jsonb, 'asset_current', true, null, 360),
  ('SI', 'default', '2250', 'Druge kratkoročne terjatve in prehodni konto', '{"en":"Other short-term receivables and suspense account"}'::jsonb, 'asset_current', false, null, 370),
  ('SI', 'default', '2260', 'Terjatve do zaposlenih', '{"en":"Receivables from employees"}'::jsonb, 'asset_current', false, null, 380),
  ('SI', 'default', '2270', 'Terjatve do države za druge davke', '{"en":"Receivables from the state for other taxes"}'::jsonb, 'asset_current', false, null, 390),
  ('SI', 'default', '2280', 'Terjatve iz naslova preplačil', '{"en":"Receivables from overpayments"}'::jsonb, 'asset_current', false, null, 400),
  ('SI', 'default', '2500', 'Denarna sredstva na transakcijskem računu', '{"en":"Bank account"}'::jsonb, 'asset_cash', false, null, 410),
  ('SI', 'default', '2510', 'Denarna sredstva v blagajni', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 420),
  ('SI', 'default', '2520', 'Denarna sredstva na deviznem računu', '{"en":"Foreign-currency bank account"}'::jsonb, 'asset_cash', false, null, 430),
  ('SI', 'default', '2530', 'Kratkoročni denarni depoziti', '{"en":"Short-term cash deposits"}'::jsonb, 'asset_cash', false, null, 440),
  ('SI', 'default', '3000', 'Kratkoročno odloženi stroški', '{"en":"Short-term prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 450),
  ('SI', 'default', '3010', 'Nezaračunani prihodki', '{"en":"Accrued income"}'::jsonb, 'asset_prepayments', false, null, 460),
  ('SI', 'default', '3020', 'Vnaprej vračunani stroški', '{"en":"Prepaid expenses accrued in advance"}'::jsonb, 'asset_prepayments', false, null, 470),
  ('SI', 'default', '4000', 'Osnovni kapital', '{"en":"Called-up capital"}'::jsonb, 'equity', false, null, 480),
  ('SI', 'default', '4010', 'Nevpoklicani kapital', '{"en":"Uncalled capital"}'::jsonb, 'equity', false, null, 490),
  ('SI', 'default', '4100', 'Kapitalske rezerve', '{"en":"Capital reserves"}'::jsonb, 'equity', false, null, 500),
  ('SI', 'default', '4110', 'Splošni prevrednotovalni popravek kapitala', '{"en":"General revaluation adjustment of capital"}'::jsonb, 'equity', false, null, 510),
  ('SI', 'default', '4200', 'Rezerve iz dobička', '{"en":"Reserves from profit"}'::jsonb, 'equity', false, null, 520),
  ('SI', 'default', '4210', 'Zakonske rezerve', '{"en":"Legal reserves"}'::jsonb, 'equity', false, null, 530),
  ('SI', 'default', '4220', 'Statutarne rezerve', '{"en":"Statutory reserves"}'::jsonb, 'equity', false, null, 540),
  ('SI', 'default', '4230', 'Rezerve za lastne deleže', '{"en":"Reserves for own shares"}'::jsonb, 'equity', false, null, 550),
  ('SI', 'default', '4300', 'Preneseni čisti poslovni izid', '{"en":"Retained earnings carried forward"}'::jsonb, 'equity_retained', false, null, 560),
  ('SI', 'default', '4400', 'Čisti poslovni izid poslovnega leta', '{"en":"Net result of the financial year"}'::jsonb, 'equity_retained', false, null, 570),
  ('SI', 'default', '5000', 'Dolgoročne rezervacije za pokojnine in podobne obveznosti', '{"en":"Long-term provisions for pensions and similar obligations"}'::jsonb, 'liability_non_current', false, null, 580),
  ('SI', 'default', '5010', 'Dolgoročne rezervacije za garancije', '{"en":"Long-term provisions for warranties"}'::jsonb, 'liability_non_current', false, null, 590),
  ('SI', 'default', '5020', 'Druge dolgoročne rezervacije', '{"en":"Other long-term provisions"}'::jsonb, 'liability_non_current', false, null, 600),
  ('SI', 'default', '5100', 'Dolgoročne pasivne časovne razmejitve', '{"en":"Long-term deferred income"}'::jsonb, 'liability_non_current', false, null, 610),
  ('SI', 'default', '5110', 'Dolgoročno odloženi prihodki iz naslova državnih podpor', '{"en":"Long-term deferred income from government grants"}'::jsonb, 'liability_non_current', false, null, 620),
  ('SI', 'default', '6000', 'Dolgoročna posojila pri bankah', '{"en":"Long-term bank loans"}'::jsonb, 'liability_non_current', false, null, 630),
  ('SI', 'default', '6010', 'Dolgoročne obveznosti iz finančnega najema', '{"en":"Long-term finance lease liabilities"}'::jsonb, 'liability_non_current', false, null, 640),
  ('SI', 'default', '6100', 'Dolgoročne poslovne obveznosti', '{"en":"Long-term trade payables"}'::jsonb, 'liability_non_current', false, null, 650),
  ('SI', 'default', '6110', 'Dolgoročne obveznosti do dobaviteljev', '{"en":"Long-term payables to suppliers"}'::jsonb, 'liability_non_current', false, null, 660),
  ('SI', 'default', '6200', 'Odložene obveznosti za davek', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 670),
  ('SI', 'default', '7000', 'Kratkoročna posojila pri bankah', '{"en":"Short-term bank loans"}'::jsonb, 'liability_current', false, null, 680),
  ('SI', 'default', '7010', 'Kratkoročna posojila pri drugih pravnih osebah', '{"en":"Short-term loans from other legal persons"}'::jsonb, 'liability_current', false, null, 690),
  ('SI', 'default', '7100', 'Kratkoročne poslovne obveznosti do dobaviteljev v Sloveniji', '{"en":"Short-term trade payables — Slovenia"}'::jsonb, 'liability_payable', true, null, 700),
  ('SI', 'default', '7110', 'Kratkoročne poslovne obveznosti do dobaviteljev v EU', '{"en":"Short-term trade payables — EU"}'::jsonb, 'liability_payable', true, null, 710),
  ('SI', 'default', '7120', 'Kratkoročne poslovne obveznosti do dobaviteljev izven EU', '{"en":"Short-term trade payables — outside the EU"}'::jsonb, 'liability_payable', true, null, 720),
  ('SI', 'default', '7130', 'Kratkoročne obveznosti za predujme kupcev', '{"en":"Short-term advances from customers"}'::jsonb, 'liability_current', false, null, 730),
  ('SI', 'default', '7200', 'Obveznosti za DDV po stopnji 22 %', '{"en":"VAT payable at 22%"}'::jsonb, 'liability_current', false, null, 740),
  ('SI', 'default', '7210', 'Obveznosti za DDV po stopnji 9,5 %', '{"en":"VAT payable at 9.5%"}'::jsonb, 'liability_current', false, null, 750),
  ('SI', 'default', '7220', 'Obveznosti za DDV po posebni nižji stopnji 5 %', '{"en":"VAT payable at the special reduced rate of 5%"}'::jsonb, 'liability_current', false, null, 760),
  ('SI', 'default', '7230', 'Obveznosti za DDV od pridobitev blaga znotraj EU', '{"en":"VAT payable on intra-EU acquisitions of goods"}'::jsonb, 'liability_current', false, null, 770),
  ('SI', 'default', '7240', 'Obveznosti za DDV od prejetih storitev iz EU', '{"en":"VAT payable on services received from the EU"}'::jsonb, 'liability_current', false, null, 780),
  ('SI', 'default', '7250', 'Obveznosti za DDV od samoobdavčitve prejemnika (76.a člen in tuje storitve)', '{"en":"VAT payable on self-assessment as recipient (article 76a and foreign services)"}'::jsonb, 'liability_current', false, null, 790),
  ('SI', 'default', '7270', 'Obveznost do države za DDV', '{"en":"VAT payable to the tax authority"}'::jsonb, 'liability_current', true, null, 800),
  ('SI', 'default', '7300', 'Obveznosti do zaposlenih', '{"en":"Payables to employees"}'::jsonb, 'liability_current', false, null, 810),
  ('SI', 'default', '7310', 'Obveznosti za druge davke in prispevke', '{"en":"Payables for other taxes and social contributions"}'::jsonb, 'liability_current', false, null, 820),
  ('SI', 'default', '7320', 'Obveznosti do družbenikov', '{"en":"Payables to shareholders"}'::jsonb, 'liability_current', false, null, 830),
  ('SI', 'default', '7330', 'Obveznosti iz naslova dividend', '{"en":"Payables for dividends"}'::jsonb, 'liability_current', false, null, 840),
  ('SI', 'default', '7900', 'Kratkoročne pasivne časovne razmejitve', '{"en":"Short-term deferred income"}'::jsonb, 'liability_current', false, null, 850),
  ('SI', 'default', '7910', 'Vnaprej vračunani stroški in odhodki', '{"en":"Short-term accrued expenses"}'::jsonb, 'liability_current', false, null, 860),
  ('SI', 'default', '8000', 'Čisti prihodki od prodaje po splošni stopnji', '{"en":"Net sales revenue at the standard rate"}'::jsonb, 'income', false, null, 870),
  ('SI', 'default', '8010', 'Čisti prihodki od prodaje po nižji stopnji', '{"en":"Net sales revenue at the reduced rate"}'::jsonb, 'income', false, null, 880),
  ('SI', 'default', '8020', 'Čisti prihodki od prodaje po posebni nižji stopnji', '{"en":"Net sales revenue at the special reduced rate"}'::jsonb, 'income', false, null, 890),
  ('SI', 'default', '8030', 'Prihodki od izvoza', '{"en":"Export revenue"}'::jsonb, 'income', false, null, 900),
  ('SI', 'default', '8040', 'Prihodki od dobav blaga v druge države članice EU', '{"en":"Revenue from intra-EU supplies of goods"}'::jsonb, 'income', false, null, 910),
  ('SI', 'default', '8050', 'Prihodki od gradbenih storitev po 76.a členu ZDDV-1', '{"en":"Revenue from construction services under article 76a"}'::jsonb, 'income', false, null, 920),
  ('SI', 'default', '8060', 'Oproščeni prihodki brez pravice do odbitka DDV', '{"en":"Exempt revenue without right of deduction"}'::jsonb, 'income', false, null, 930),
  ('SI', 'default', '8100', 'Sprememba vrednosti zalog proizvodov in nedokončane proizvodnje', '{"en":"Change in inventories of products and work in progress"}'::jsonb, 'income_other', false, null, 940),
  ('SI', 'default', '8110', 'Usredstveni lastni proizvodi in lastne storitve', '{"en":"Capitalised own products and services"}'::jsonb, 'income_other', false, null, 950),
  ('SI', 'default', '8120', 'Drugi poslovni prihodki', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 960),
  ('SI', 'default', '8130', 'Prevrednotovalni poslovni prihodki', '{"en":"Operating revaluation income"}'::jsonb, 'income_other', false, null, 970),
  ('SI', 'default', '8200', 'Stroški materiala', '{"en":"Cost of materials"}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('SI', 'default', '8210', 'Stroški storitev', '{"en":"Cost of services"}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('SI', 'default', '8220', 'Nabavna vrednost prodanega trgovskega blaga', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('SI', 'default', '8230', 'Stroški energije', '{"en":"Cost of energy"}'::jsonb, 'expense_direct_cost', false, null, 1010),
  ('SI', 'default', '8300', 'Stroški plač', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, null, 1020),
  ('SI', 'default', '8310', 'Stroški socialnih zavarovanj', '{"en":"Social security costs"}'::jsonb, 'expense', false, null, 1030),
  ('SI', 'default', '8320', 'Drugi stroški dela', '{"en":"Other labour costs"}'::jsonb, 'expense', false, null, 1040),
  ('SI', 'default', '8330', 'Stroški prevoza zaposlenih na delo', '{"en":"Employee commuting costs"}'::jsonb, 'expense', false, null, 1050),
  ('SI', 'default', '8400', 'Amortizacija', '{"en":"Depreciation and amortisation"}'::jsonb, 'expense_depreciation', false, null, 1060),
  ('SI', 'default', '8410', 'Prevrednotovalni poslovni odhodki pri terjatvah', '{"en":"Impairment of receivables"}'::jsonb, 'expense', false, null, 1070),
  ('SI', 'default', '8420', 'Prevrednotovalni poslovni odhodki pri opredmetenih sredstvih', '{"en":"Impairment of property, plant and equipment"}'::jsonb, 'expense', false, null, 1080),
  ('SI', 'default', '8500', 'Stroški reprezentance', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 1090),
  ('SI', 'default', '8510', 'Drugi poslovni odhodki', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, null, 1100),
  ('SI', 'default', '8520', 'Stroški zavarovalnih premij', '{"en":"Insurance premiums"}'::jsonb, 'expense', false, null, 1110),
  ('SI', 'default', '8530', 'Najemnine in zakupnine', '{"en":"Rent and lease expenses"}'::jsonb, 'expense', false, null, 1120),
  ('SI', 'default', '8540', 'Stroški vzdrževanja', '{"en":"Maintenance costs"}'::jsonb, 'expense', false, null, 1130),
  ('SI', 'default', '8550', 'Stroški storitev fizičnih oseb, ki ne opravljajo dejavnosti', '{"en":"Fees paid to individuals not carrying on a registered activity"}'::jsonb, 'expense', false, null, 1140),
  ('SI', 'default', '9000', 'Finančni prihodki iz deležev', '{"en":"Financial income from shares"}'::jsonb, 'income_other', false, null, 1150),
  ('SI', 'default', '9010', 'Finančni prihodki iz danih posojil', '{"en":"Financial income from loans granted"}'::jsonb, 'income_other', false, null, 1160),
  ('SI', 'default', '9020', 'Finančni prihodki iz poslovnih terjatev', '{"en":"Financial income from trade receivables"}'::jsonb, 'income_other', false, null, 1170),
  ('SI', 'default', '9030', 'Finančni prihodki iz tečajnih razlik', '{"en":"Financial income from exchange rate differences"}'::jsonb, 'income_other', false, null, 1180),
  ('SI', 'default', '9040', 'Finančni prihodki iz obresti na denarna sredstva', '{"en":"Financial income from interest on cash"}'::jsonb, 'income_other', false, null, 1190),
  ('SI', 'default', '9100', 'Finančni odhodki iz oslabitve finančnih naložb', '{"en":"Financial expenses from impairment of financial investments"}'::jsonb, 'expense', false, null, 1200),
  ('SI', 'default', '9110', 'Finančni odhodki iz finančnih obveznosti', '{"en":"Financial expenses from financial liabilities"}'::jsonb, 'expense', false, null, 1210),
  ('SI', 'default', '9120', 'Finančni odhodki iz poslovnih obveznosti', '{"en":"Financial expenses from trade payables"}'::jsonb, 'expense', false, null, 1220),
  ('SI', 'default', '9130', 'Finančni odhodki iz tečajnih razlik', '{"en":"Financial expenses from exchange rate differences"}'::jsonb, 'expense', false, null, 1230),
  ('SI', 'default', '9140', 'Finančni odhodki iz obresti na kratkoročna posojila', '{"en":"Financial expenses from interest on short-term loans"}'::jsonb, 'expense', false, null, 1240),
  ('SI', 'default', '9200', 'Drugi prihodki', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 1250),
  ('SI', 'default', '9201', 'Prihodki od odprave dolgoročnih rezervacij', '{"en":"Income from the reversal of long-term provisions"}'::jsonb, 'income_other', false, null, 1260),
  ('SI', 'default', '9210', 'Drugi odhodki', '{"en":"Other expenses"}'::jsonb, 'expense', false, null, 1270),
  ('SI', 'default', '9211', 'Odhodki za donacije', '{"en":"Donation expenses"}'::jsonb, 'expense', false, null, 1280),
  ('SI', 'default', '9220', 'Odhodki iz naslova zaokroževanja', '{"en":"Rounding expenses"}'::jsonb, 'expense', false, null, 1290),
  ('SI', 'default', '9300', 'Davek od dobička', '{"en":"Corporate income tax"}'::jsonb, 'expense', false, null, 1300),
  ('SI', 'default', '9301', 'Davek od dobička iz preteklih let', '{"en":"Corporate income tax for prior years"}'::jsonb, 'expense', false, null, 1310),
  ('SI', 'default', '9310', 'Odloženi davki', '{"en":"Deferred taxes"}'::jsonb, 'expense', false, null, 1320)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SI', 'BAN', 'Dnevnik banke', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('SI', 'BLA', 'Dnevnik blagajne', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('SI', 'NAB', 'Dnevnik prejetih računov', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('SI', 'OB', 'Dnevnik otvoritvenih knjižb', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('SI', 'PRO', 'Dnevnik izdanih računov', '{"en":"Sales journal"}'::jsonb, 'sales', 10),
  ('SI', 'RAZ', 'Dnevnik razneh knjižb', '{"en":"Miscellaneous journal"}'::jsonb, 'general', 50)
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
  ('SI', 'SI-P-22', 'Vstopni DDV 22 %', '{"en":"Input VAT 22%"}'::jsonb, 'Vstopni DDV od nabav blaga in storitev v Sloveniji; osnova v polju 31, odbitek v polju 41.', 'percent', 22, 'purchase', 'domestic', date '2013-07-01', null, 'ZDDV-1, 63. člen, prvi odstavek, točka a) — davčni zavezanec sme odbiti DDV, ki ga je dolžan plačati ali ga je plačal pri nabavah blaga ali storitev, opravljenih s strani drugega davčnega zavezanca, če je te uporabil ali jih bo uporabil za namene svojih obdavčenih transakcij.', 'S', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-P-22-NA', 'Nabave za reprezentanco, neodbitni DDV 22 %', '{"en":"Entertainment expenses, non-deductible VAT 22%"}'::jsonb, 'DDV od izdatkov za reprezentanco (pogostitev, zabava, hrana in pijača ter nastanitev ob poslovnih ali družabnih stikih), ki ni odbiten; DDV ostane strošek in ne nastopa v nobenem polju obračuna DDV.', 'percent', 22, 'purchase', 'domestic', date '2013-07-01', null, 'ZDDV-1, 66. člen, prvi odstavek, točka b) — davčni zavezanec ne sme odbiti vstopnega DDV od izdatkov za reprezentanco; kot izdatki za reprezentanco se štejejo izdatki za pogostitev in zabavo ob poslovnih ali družabnih stikih ter izdatki za hrano, pijačo in nastanitev.', 'S', null, 100, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-P-9_5', 'Vstopni DDV 9,5 %', '{"en":"Input VAT 9.5%"}'::jsonb, 'Vstopni DDV od nabav po nižji stopnji; osnova v polju 31, odbitek v polju 42.', 'percent', 9.5, 'purchase', 'domestic', date '2020-01-01', null, 'ZDDV-1, 63. člen, prvi odstavek, točka a), v zvezi z 41. členom, drugim odstavkom, in Prilogo I.', 'S', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-P-EXT-22', 'Prejeta storitev izven EU 22 %', '{"en":"Service received from outside the EU 22%"}'::jsonb, 'Samoobdavčitev ob prejemu splošne storitve od davčnega zavezanca s sedežem v tretji državi; osnova v polju 31 (skupaj z drugimi nabavami), obračunani DDV v polju 25, odbitek v polju 41.', 'percent', 22, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'ZDDV-1, 25. člen, prvi odstavek — kraj opravljanja storitve je kraj sedeža prejemnika; 76. člen, prvi odstavek, 2. točka — plačnik DDV je prejemnik storitve, ki jo opravi davčni zavezanec s sedežem izven Slovenije, tudi kadar gre za sedež izven Unije. Navodilo za izpolnjevanje obračuna DDV, polje 25, izrecno navaja storitve po prvem odstavku 25. člena, ki jih opravi davčni zavezanec s sedežem v tretji državi.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'obrazec-ddv-o', null, null, null, null),
  ('SI', 'SI-P-ICS-22', 'Prejeta storitev iz druge države članice EU 22 %', '{"en":"Service received from another EU Member State 22%"}'::jsonb, 'Samoobdavčitev ob prejemu splošne storitve od davčnega zavezanca s sedežem v drugi državi članici; osnova v polju 32a, obračunani DDV v polju 23a, odbitek v polju 41.', 'percent', 22, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'ZDDV-1, 25. člen, prvi odstavek — kraj opravljanja storitve osebi, ki je davčni zavezanec, je kraj, kjer ima ta oseba sedež svoje dejavnosti; 76. člen, prvi odstavek, 2. točka — plačnik DDV je davčni zavezanec, prejemnik storitve iz 25. člena, ki jo opravi davčni zavezanec, ki nima sedeža v Sloveniji; 63. člen omogoča odbitek tako obračunanega DDV.', 'K', 'VATEX-EU-IC', 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-P-IGA-22', 'Pridobitev blaga znotraj EU 22 %', '{"en":"Intra-EU acquisition of goods 22%"}'::jsonb, 'Samoobdavčitev ob pridobitvi blaga iz druge države članice; osnova v polju 32, obračunani DDV v polju 23, odbitek v polju 41.', 'percent', 22, 'purchase', 'intracom_acquisition_goods', date '2013-07-01', null, 'ZDDV-1, 34. člen — pridobitev blaga znotraj Unije, opravljena v Sloveniji za plačilo, je predmet DDV; 76. člen, prvi odstavek, 3. točka — plačnik DDV je oseba, ki pridobi blago znotraj Unije; 63. člen omogoča odbitek tako obračunanega DDV, če je pridobitev opravljena za namene obdavčenih transakcij.', 'K', 'VATEX-EU-IC', 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-P-RC-GRADNJA', 'Prejeta gradbena storitev, obrnjena davčna obveznost (76.a člen)', '{"en":"Construction service received, domestic reverse charge (article 76a)"}'::jsonb, 'Samoobdavčitev prejemnika gradbene storitve po 76.a členu; osnova v polju 31a, obračunani DDV v polju 25, odbitek v polju 41.', 'percent', 22, 'purchase', 'domestic_reverse_charge', date '2010-01-01', null, 'ZDDV-1, 76.a člen, prvi odstavek, točka a) — plačnik DDV je prejemnik gradbene storitve. Navodilo za izpolnjevanje obračuna DDV, polji 31a in 25: osnova nabav po 76.a členu se všteva v polje 31a, obračunani DDV nanjo pa v polje 25 skupaj s samoobdavčitvijo storitev tretjih držav; 63. člen omogoča odbitek.', 'AE', 'VATEX-EU-AE', 140, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'obrazec-ddv-o', null, null, null, null),
  ('SI', 'SI-S-22', 'DDV 22 %', '{"en":"VAT 22%"}'::jsonb, 'Splošna stopnja DDV; polje 21 obračuna DDV, osnova v polju 11.', 'percent', 22, 'sale', 'domestic', date '2013-07-01', null, 'ZDDV-1, 41. člen, prvi odstavek — DDV se obračunava in plačuje po splošni, 22-odstotni stopnji od davčne osnove, enaki za dobavo blaga in za opravljanje storitev.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-S-5', 'DDV 5 %', '{"en":"VAT 5%"}'::jsonb, 'Posebna nižja stopnja DDV za dobave iz Priloge IV k ZDDV-1 (1. točka: tiskane in elektronske knjige, časopisi in periodične publikacije); polje 22a.', 'percent', 5, 'sale', 'domestic', date '2020-01-01', null, 'ZDDV-1, 41. člen, drugi odstavek, in Priloga IV k ZDDV-1, 1. točka — za dobavo tiskanih knjig, časopisov, periodičnih publikacij in njihovih elektronskih različic se DDV obračunava po posebni nižji, 5-odstotni stopnji. Glej FURS, Davek na dodano vrednost — Stopnje DDV (14. izdaja, junij 2026), poglavje 3.1.', 'S', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-S-9_5', 'DDV 9,5 %', '{"en":"VAT 9.5%"}'::jsonb, 'Nižja stopnja DDV za dobave iz Priloge I k ZDDV-1 (med drugim hrana, voda, zdravila, prevoz oseb, vstopnine, gostinske storitve); polje 22.', 'percent', 9.5, 'sale', 'domestic', date '2020-01-01', null, 'ZDDV-1, 41. člen, drugi odstavek, in Priloga I k ZDDV-1 — za dobave blaga in storitev, ki so navedene v Prilogi I, se DDV obračunava po nižji, 9,5-odstotni stopnji. Glej tudi FURS, Davek na dodano vrednost — Stopnje DDV (14. izdaja, junij 2026), poglavje 2, »Priloga I – 9,5 %«.', 'S', null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-S-EXE', 'Oproščen najem nepremičnine', '{"en":"Exempt letting of immovable property"}'::jsonb, 'Najem oziroma zakup nepremičnine brez pravice do odbitka DDV; polje 15.', 'percent', 0, 'sale', 'exempt', date '2004-05-01', null, 'ZDDV-1, 44. člen — plačila DDV je oproščen najem oziroma zakup nepremičnin, z izjemami, ki jih zakon določa (med drugim nastanitev, garaže, parkirni prostori ter trajno vgrajena oprema in stroji); Direktiva Sveta 2006/112/ES, člen 135(1)(l). Točna alineja 44. člena naj pred statusom reviewed preveri slovenski davčni svetovalec — glej README.', 'E', 'VATEX-EU-135-1', 70, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-S-EXP', 'Oproščena izvozna dobava blaga', '{"en":"Exempt export of goods"}'::jsonb, 'Dobava blaga, odposlano ali odpeljano izven Unije; všteto v polje 11 skupaj z obdavčenimi domačimi dobavami, kot to izrecno določa Navodilo za izpolnjevanje obračuna DDV k polju 11.', 'percent', 0, 'sale', 'export', date '2004-05-01', null, 'ZDDV-1, 52. člen, prvi odstavek, 1. točka — plačila DDV so oproščene dobave blaga, ki ga iz Slovenije odpošlje ali odpelje izven Unije prodajalec ali druga oseba za njegov račun. Navodilo za izpolnjevanje obračuna DDV, polje 11 (Priloga X k obrazcu DDV-O), izrecno uvršča »oproščene izvozne dobave blaga« med zneske, ki se vpisujejo v polje 11 skupaj z obdavčenimi dobavami na ozemlju Slovenije.', 'G', 'VATEX-EU-G', 50, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'obrazec-ddv-o', null, null, null, null),
  ('SI', 'SI-S-IGL', 'Oproščena dobava blaga v drugo državo članico EU', '{"en":"Exempt intra-EU supply of goods"}'::jsonb, 'Dobava blaga davčnemu zavezancu, identificiranemu za DDV v drugi državi članici; polje 12 in rekapitulacijsko poročilo.', 'percent', 0, 'sale', 'intracom_goods', date '2004-05-01', null, 'ZDDV-1, 46. člen, prvi odstavek, 1. točka — plačila DDV je oproščena dobava blaga, ki ga iz Slovenije v drugo državo članico odpošlje ali odpelje prodajalec, kupec ali druga oseba za njun račun, opravljena drugemu davčnemu zavezancu, identificiranemu za namene DDV v drugi državi članici, pod pogojem, da je dobava prijavljena v rekapitulacijskem poročilu iz 90. člena tega zakona.', 'K', 'VATEX-EU-IC', 40, 'vat', true, array['buyer_status', 'transport_evidence']::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null),
  ('SI', 'SI-S-RC-GRADNJA', 'Gradbena storitev, obrnjena davčna obveznost (76.a člen)', '{"en":"Construction service, domestic reverse charge (article 76a)"}'::jsonb, 'Gradbene storitve na nepremičnini, ko je plačnik DDV prejemnik; polje 11a, brez obračunanega DDV na strani izdajatelja.', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2010-01-01', null, 'ZDDV-1, 76.a člen, prvi odstavek, točka a) — plačnik DDV je vsak davčni zavezanec, identificiran za namene DDV v Sloveniji, ki mu je opravljena gradbena storitev, vključno s popravilom, čiščenjem, vzdrževanjem, rekonstrukcijo in rušenjem v zvezi z nepremičnino. Navodilo za izpolnjevanje obračuna DDV, polje 11a, in Mehanizem obrnjene davčne obveznosti v določenih sektorjih (FURS): izdajatelj računa DDV ne obračuna, na računu pa navede, da gre za obrnjeno davčno obveznost.', 'AE', 'VATEX-EU-AE', 60, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'zddv-1', null, null, null, null)
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
    ('SI-P-22', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'SI-DDV-O', 10),
    ('SI-P-22', 'invoice', 'tax', 100, '2230', '41', array['41']::text[], 100, 'SI-DDV-O', 20),
    ('SI-P-22', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'SI-DDV-O', 10),
    ('SI-P-22', 'credit_note', 'tax', 100, '2230', '41', array['41']::text[], -100, 'SI-DDV-O', 20),
    ('SI-P-22-NA', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('SI-P-22-NA', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('SI-P-9_5', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'SI-DDV-O', 10),
    ('SI-P-9_5', 'invoice', 'tax', 100, '2231', '42', array['42']::text[], 100, 'SI-DDV-O', 20),
    ('SI-P-9_5', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'SI-DDV-O', 10),
    ('SI-P-9_5', 'credit_note', 'tax', 100, '2231', '42', array['42']::text[], -100, 'SI-DDV-O', 20),
    ('SI-P-EXT-22', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'SI-DDV-O', 10),
    ('SI-P-EXT-22', 'invoice', 'tax', 100, '7250', '25', array['25']::text[], 100, 'SI-DDV-O', 20),
    ('SI-P-EXT-22', 'invoice', 'tax', 100, '2234', '41', array['41']::text[], 100, 'SI-DDV-O', 30),
    ('SI-P-EXT-22', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'SI-DDV-O', 10),
    ('SI-P-EXT-22', 'credit_note', 'tax', 100, '7250', '25', array['25']::text[], -100, 'SI-DDV-O', 20),
    ('SI-P-EXT-22', 'credit_note', 'tax', 100, '2234', '41', array['41']::text[], -100, 'SI-DDV-O', 30),
    ('SI-P-ICS-22', 'invoice', 'base', 100, null, '32a', array['32a']::text[], 100, 'SI-DDV-O', 10),
    ('SI-P-ICS-22', 'invoice', 'tax', 100, '7240', '23a', array['23a']::text[], 100, 'SI-DDV-O', 20),
    ('SI-P-ICS-22', 'invoice', 'tax', 100, '2233', '41', array['41']::text[], 100, 'SI-DDV-O', 30),
    ('SI-P-ICS-22', 'credit_note', 'base', 100, null, '32a', array['32a']::text[], -100, 'SI-DDV-O', 10),
    ('SI-P-ICS-22', 'credit_note', 'tax', 100, '7240', '23a', array['23a']::text[], -100, 'SI-DDV-O', 20),
    ('SI-P-ICS-22', 'credit_note', 'tax', 100, '2233', '41', array['41']::text[], -100, 'SI-DDV-O', 30),
    ('SI-P-IGA-22', 'invoice', 'base', 100, null, '32', array['32']::text[], 100, 'SI-DDV-O', 10),
    ('SI-P-IGA-22', 'invoice', 'tax', 100, '7230', '23', array['23']::text[], 100, 'SI-DDV-O', 20),
    ('SI-P-IGA-22', 'invoice', 'tax', 100, '2232', '41', array['41']::text[], 100, 'SI-DDV-O', 30),
    ('SI-P-IGA-22', 'credit_note', 'base', 100, null, '32', array['32']::text[], -100, 'SI-DDV-O', 10),
    ('SI-P-IGA-22', 'credit_note', 'tax', 100, '7230', '23', array['23']::text[], -100, 'SI-DDV-O', 20),
    ('SI-P-IGA-22', 'credit_note', 'tax', 100, '2232', '41', array['41']::text[], -100, 'SI-DDV-O', 30),
    ('SI-P-RC-GRADNJA', 'invoice', 'base', 100, null, '31a', array['31a']::text[], 100, 'SI-DDV-O', 10),
    ('SI-P-RC-GRADNJA', 'invoice', 'tax', 100, '7250', '25', array['25']::text[], 100, 'SI-DDV-O', 20),
    ('SI-P-RC-GRADNJA', 'invoice', 'tax', 100, '2235', '41', array['41']::text[], 100, 'SI-DDV-O', 30),
    ('SI-P-RC-GRADNJA', 'credit_note', 'base', 100, null, '31a', array['31a']::text[], -100, 'SI-DDV-O', 10),
    ('SI-P-RC-GRADNJA', 'credit_note', 'tax', 100, '7250', '25', array['25']::text[], -100, 'SI-DDV-O', 20),
    ('SI-P-RC-GRADNJA', 'credit_note', 'tax', 100, '2235', '41', array['41']::text[], -100, 'SI-DDV-O', 30),
    ('SI-S-22', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-22', 'invoice', 'tax', 100, '7200', '21', array['21']::text[], 100, 'SI-DDV-O', 20),
    ('SI-S-22', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'SI-DDV-O', 10),
    ('SI-S-22', 'credit_note', 'tax', 100, '7200', '21', array['21']::text[], -100, 'SI-DDV-O', 20),
    ('SI-S-5', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-5', 'invoice', 'tax', 100, '7220', '22a', array['22a']::text[], 100, 'SI-DDV-O', 20),
    ('SI-S-5', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'SI-DDV-O', 10),
    ('SI-S-5', 'credit_note', 'tax', 100, '7220', '22a', array['22a']::text[], -100, 'SI-DDV-O', 20),
    ('SI-S-9_5', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-9_5', 'invoice', 'tax', 100, '7210', '22', array['22']::text[], 100, 'SI-DDV-O', 20),
    ('SI-S-9_5', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'SI-DDV-O', 10),
    ('SI-S-9_5', 'credit_note', 'tax', 100, '7210', '22', array['22']::text[], -100, 'SI-DDV-O', 20),
    ('SI-S-EXE', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-EXE', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'SI-DDV-O', 10),
    ('SI-S-EXP', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-EXP', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'SI-DDV-O', 10),
    ('SI-S-IGL', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-IGL', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'SI-DDV-O', 10),
    ('SI-S-RC-GRADNJA', 'invoice', 'base', 100, null, '11a', array['11a']::text[], 100, 'SI-DDV-O', 10),
    ('SI-S-RC-GRADNJA', 'credit_note', 'base', 100, null, '11a', array['11a']::text[], -100, 'SI-DDV-O', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SI' and t.code = v.tax_code
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
  ('SI', 'SI-DDV-O', 'Obračun davka na dodano vrednost (obrazec DDV-O)', array['month', 'quarter']::declaration_period[], null, date '2020-01-01', null, 'ZDDV-1, 88. in 89. člen, ter Priloga X k Pravilniku o izvajanju ZDDV-1 (obrazec DDV-O in Navodilo za izpolnjevanje obračuna DDV). Polja so oštevilčena, kot jih navaja Priloga X, ki jo je nazadnje objavil Uradni list RS, št. 104/2010; od 10. februarja 2022 (Uradni list RS, št. 16/22) obrazec in navodilo nista več priloga Pravilnika, temveč sta objavljena samostojno na portalu eDavki, pri čemer številčenje polj ostaja isto. Polji 22a (posebna nižja stopnja 5 %) je bilo v obrazec dodano z uvedbo te stopnje 1. januarja 2020; njegovo besedilo v tem paketu izhaja iz sekundarnih virov računovodske stroke in ni bilo preverjeno na uradnem PDF-ju ali na eDavkih — glej README.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'ZDDV-1, 88. člen, prvi odstavek — davčni zavezanec mora predložiti obračun DDV davčnemu organu do zadnjega delovnega dne meseca, ki sledi poteku davčnega obdobja, na katero se obračun nanaša. Potrjeno tudi na angleški strani FURS: "A taxable person shall submit a tax return to the tax authority by the last business day of the month following the expiration of the tax period."', 'furs-vat-en', null)
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
  ('SI', 'SI-DDV-O', '11', 'base', 'Dobave blaga in storitev', '{"en":"Supplies of goods and services"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 11 — vrednost v Sloveniji obdavčljivih dobav blaga in storitev brez DDV, po vseh stopnjah, skupaj z oproščenimi izvoznimi dobavami blaga in drugimi oproščenimi dobavami s pravico do odbitka DDV (razen dobav v druge države članice EU, ki gredo v polje 12).', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '11a', 'base', 'Dobave blaga in storitev v Sloveniji, od katerih obračuna DDV prejemnik', '{"en":"Supplies of goods and services in Slovenia on which the recipient accounts for VAT"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 11a — vrednost dobav blaga in opravljenih storitev iz 76.a člena ZDDV-1, katerih plačnik DDV je prejemnik.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '12', 'base', 'Dobave blaga in storitev v druge države članice EU', '{"en":"Supplies of goods and services to other EU Member States"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 12 — vrednost oproščenih dobav blaga davčnim zavezancem, identificiranim za DDV v drugih državah članicah, o katerih se poroča v rekapitulacijskem poročilu, ter storitev, obdavčenih v drugi državi članici po členu 196 Direktive 2006/112/ES.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '15', 'base', 'Oproščene dobave brez pravice do odbitka DDV', '{"en":"Exempt supplies without right of deduction"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 15 — vrednost oproščenih dobav blaga in storitev brez pravice do odbitka DDV, na primer bolnišnična in zdravstvena oskrba, zavarovalne in finančne transakcije, najem nepremičnin.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '21', 'tax', 'Obračunani DDV po splošni stopnji', '{"en":"VAT calculated at the standard rate"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 21 — obračunani DDV od dobav, pri katerih je obveznost za DDV nastala v Sloveniji po splošni stopnji. Besedilo Priloge X iz 2010 navaja takratno splošno stopnjo 20 %; od 1. julija 2013 (ZDDV-1F) znaša splošna stopnja 22 % (41. člen ZDDV-1), oštevilčenje polja pa se ni spremenilo.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '22', 'tax', 'Obračunani DDV po nižji stopnji', '{"en":"VAT calculated at the reduced rate"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 22 — obračunani DDV od dobav, obdavčenih po nižji stopnji iz Priloge I k ZDDV-1. Besedilo Priloge X iz 2010 navaja takratno nižjo stopnjo 8,5 %; od 1. januarja 2020 (ZDDV-1L) znaša nižja stopnja 9,5 %, oštevilčenje polja pa se ni spremenilo.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '22a', 'tax', 'Obračunani DDV po posebni nižji stopnji', '{"en":"VAT calculated at the special reduced rate"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Obrazec DDV-O je bil s 1. januarjem 2020 (uvedba posebne nižje 5-odstotne stopnje po Prilogi IV k ZDDV-1, ZDDV-1L) dopolnjen s poljem 22a za obračunani DDV po tej stopnji. Obstoj in številka polja izhajata iz sekundarnih virov računovodske stroke (ne iz uradnega PDF-ja ali eDavkov, ki ju avtomatizirano branje ni moglo prikazati v celoti); pred statusom reviewed naj polje preveri, kdor ima dostop do trenutno veljavnega obrazca na eDavkih. Glej README.', 'furs-stopnje-ddv'),
  ('SI', 'SI-DDV-O', '23', 'tax', 'Obračunani DDV od pridobitev blaga iz drugih držav članic EU', '{"en":"VAT calculated on intra-EU acquisitions of goods"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 23 — obračunani DDV, ki ga davčni zavezanec obračuna od pridobitev blaga iz drugih držav članic po splošni stopnji.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '23a', 'tax', 'Obračunani DDV od prejetih storitev iz drugih držav članic EU', '{"en":"VAT calculated on services received from other EU Member States"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 23a — obračunani DDV, ki ga davčni zavezanec obračuna od prejetih storitev iz drugih držav članic po splošni stopnji.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '25', 'tax', 'Obračunani DDV na podlagi samoobdavčitve kot prejemnik blaga in storitev', '{"en":"VAT calculated on self-assessment as recipient of goods and services"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 25 — obračunani DDV, ki ga obračuna davčni zavezanec kot prejemnik dobave blaga ali storitev, ki jo opravi davčni zavezanec s sedežem v tretji državi (prvi odstavek 25. člena ZDDV-1), ali kot prejemnik dobav in danih predplačil iz 76.a člena ZDDV-1.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '31', 'base', 'Nabave blaga in storitev', '{"en":"Purchases of goods and services"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 31 — vrednost obdavčenih nabav blaga in storitev v Sloveniji ter nabav od davčnih zavezancev s sedežem v tujini (tudi izven EU), za katere je nastala obveznost za obračun in plačilo DDV v Sloveniji, razen nabav iz 76.a člena (polje 31a) in pridobitev oziroma prejetih storitev iz drugih držav članic EU (polji 32 in 32a).', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '31a', 'base', 'Nabave blaga in storitev v Sloveniji, od katerih obračuna DDV prejemnik', '{"en":"Purchases of goods and services in Slovenia on which the recipient accounts for VAT"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 31a — vrednost nabav blaga in prejetih storitev ter danih predplačil iz 76.a člena ZDDV-1, katerih plačnik DDV je prejemnik.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '32', 'base', 'Pridobitve blaga iz drugih držav članic EU', '{"en":"Acquisitions of goods from other EU Member States"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 32 — vrednost pridobitev blaga znotraj Skupnosti, ki je predmet obdavčitve v Sloveniji.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '32a', 'base', 'Prejete storitve iz drugih držav članic EU', '{"en":"Services received from other EU Member States"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 32a — vrednost prejetih storitev znotraj Skupnosti brez DDV, ki je predmet obdavčitve v Sloveniji.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '41', 'tax', 'Odbitek DDV po splošni stopnji', '{"en":"Deduction of VAT at the standard rate"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 41 — odbitek DDV od nabav blaga in storitev, pridobitev blaga in prejetih storitev iz drugih držav članic EU ter od uvoza po splošni stopnji, pri katerih ima davčni zavezanec pravico do odbitka; besedilo se po analogiji uporablja tudi za samoobdavčitev prejemnika storitev s sedežem v tretji državi in za nabave po 76.a členu, ki jih obrazec obračunava v polju 25 in odbija v istem polju 41.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '42', 'tax', 'Odbitek DDV po nižji stopnji', '{"en":"Deduction of VAT at the reduced rate"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 42 — odbitek DDV od zgoraj navedenih nabav po nižji stopnji iz Priloge I.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '51', 'total', 'Obveznost DDV', '{"en":"VAT liability"}'::jsonb, 170, null, array['21', '22', '22a', '23', '23a', '25']::text[], array['41', '42']::text[], null, null, true, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 51 — razlika med obračunanim DDV (vsota polj 21 do 26) in odbitkom DDV (vsota polj 41 do 43), kadar je obračunani DDV večji.', 'obrazec-ddv-o'),
  ('SI', 'SI-DDV-O', '52', 'total', 'Presežek DDV', '{"en":"VAT surplus"}'::jsonb, 180, null, array['41', '42']::text[], array['21', '22', '22a', '23', '23a', '25']::text[], null, null, true, false, null, 'Navodilo za izpolnjevanje obračuna DDV, polje 52 — razlika med odbitkom DDV in obračunanim DDV, kadar je odbitek DDV večji.', 'obrazec-ddv-o')
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
  ('SI-ZGD-BS', 'SI', 'default', 'Bilanca stanja po 65. členu ZGD-1', 'balance_sheet', 'SI-ZGD-1', date '2010-01-01', null, 'Zakon o gospodarskih družbah (ZGD-1), 65. člen — členitev bilance stanja. Vrstice tega paketa so postavke zakona same (A, B, C na strani sredstev; A, B, C, Č, D na strani obveznosti do virov sredstev), brez oštevilčenih kontov Enotnega kontnega okvira SIR, ki je avtorskopravno zaščiten — glej README in legal_reference kontnega načrta v pack.json.', 'zgd-1'),
  ('SI-ZGD-IS', 'SI', 'default', 'Izkaz poslovnega izida po drugem odstavku 66. člena ZGD-1 (različica I)', 'income_statement', 'SI-ZGD-1', date '2010-01-01', null, 'Zakon o gospodarskih družbah (ZGD-1), 66. člen, drugi odstavek — členitev izkaza poslovnega izida po različici I (od 1 do 19). Tretji odstavek ponuja alternativno, na stroških prodanih količin temelječo različico, ki je ta paket ne uporablja.', 'zgd-1')
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
  ('SI-ZGD-BS', 'SRE', null, 'Sredstva', '{"en":"Assets"}'::jsonb, 10, 1, true, array['A', 'B', 'C']::text[], '{}'::text[], null, 'ZGD-1, 65. člen', 'zgd-1'),
  ('SI-ZGD-BS', 'A', 'SRE', 'A. Dolgoročna sredstva', '{"en":"A. Long-term assets"}'::jsonb, 20, 1, true, array['A.I', 'A.II', 'A.III', 'A.IV', 'A.V', 'A.VI']::text[], '{}'::text[], null, 'ZGD-1, 65. člen, odstavek o sredstvih, točka A', 'zgd-1'),
  ('SI-ZGD-BS', 'A.I', 'A', 'I. Neopredmetena sredstva in dolgoročne aktivne časovne razmejitve', '{"en":"I. Intangible assets and long-term prepaid expenses"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.I', 'zgd-1'),
  ('SI-ZGD-BS', 'A.II', 'A', 'II. Opredmetena osnovna sredstva', '{"en":"II. Property, plant and equipment"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.II', 'zgd-1'),
  ('SI-ZGD-BS', 'A.III', 'A', 'III. Naložbene nepremičnine', '{"en":"III. Investment property"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.III', 'zgd-1'),
  ('SI-ZGD-BS', 'A.IV', 'A', 'IV. Dolgoročne finančne naložbe', '{"en":"IV. Long-term financial investments"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.IV', 'zgd-1'),
  ('SI-ZGD-BS', 'A.V', 'A', 'V. Dolgoročne poslovne terjatve', '{"en":"V. Long-term business receivables"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.V', 'zgd-1'),
  ('SI-ZGD-BS', 'A.VI', 'A', 'VI. Odložene terjatve za davek', '{"en":"VI. Deferred tax assets"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.VI', 'zgd-1'),
  ('SI-ZGD-BS', 'B', 'SRE', 'B. Kratkoročna sredstva', '{"en":"B. Short-term assets"}'::jsonb, 90, 1, true, array['B.II', 'B.III', 'B.IV', 'B.V']::text[], '{}'::text[], null, 'ZGD-1, 65. člen, B', 'zgd-1'),
  ('SI-ZGD-BS', 'B.II', 'B', 'II. Zaloge', '{"en":"II. Inventories"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, B.II', 'zgd-1'),
  ('SI-ZGD-BS', 'B.III', 'B', 'III. Kratkoročne finančne naložbe', '{"en":"III. Short-term financial investments"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, B.III', 'zgd-1'),
  ('SI-ZGD-BS', 'B.IV', 'B', 'IV. Kratkoročne poslovne terjatve', '{"en":"IV. Short-term business receivables"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, B.IV', 'zgd-1'),
  ('SI-ZGD-BS', 'B.V', 'B', 'V. Denarna sredstva', '{"en":"V. Cash and cash equivalents"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, B.V', 'zgd-1'),
  ('SI-ZGD-BS', 'C', 'SRE', 'C. Kratkoročne aktivne časovne razmejitve', '{"en":"C. Short-term deferred expenses and accrued income"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, C (stran sredstev)', 'zgd-1'),
  ('SI-ZGD-BS', 'OBV', null, 'Obveznosti do virov sredstev', '{"en":"Liabilities and sources of funds"}'::jsonb, 150, 1, true, array['P.A', 'P.B', 'P.C', 'P.Č', 'P.D']::text[], '{}'::text[], null, 'ZGD-1, 65. člen', 'zgd-1'),
  ('SI-ZGD-BS', 'P.A', 'OBV', 'A. Kapital', '{"en":"A. Equity"}'::jsonb, 160, 1, true, array['P.A.I', 'P.A.II', 'P.A.III', 'P.A.VI', 'P.A.VII']::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A (stran obveznosti do virov sredstev)', 'zgd-1'),
  ('SI-ZGD-BS', 'P.A.I', 'P.A', 'I. Vpoklicani kapital', '{"en":"I. Called-up capital"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.I', 'zgd-1'),
  ('SI-ZGD-BS', 'P.A.II', 'P.A', 'II. Kapitalske rezerve', '{"en":"II. Capital reserves"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.II', 'zgd-1'),
  ('SI-ZGD-BS', 'P.A.III', 'P.A', 'III. Rezerve iz dobička', '{"en":"III. Reserves from profit"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.III', 'zgd-1'),
  ('SI-ZGD-BS', 'P.A.VI', 'P.A', 'VI. Preneseni čisti poslovni izid', '{"en":"VI. Retained earnings carried forward"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.VI', 'zgd-1'),
  ('SI-ZGD-BS', 'P.A.VII', 'P.A', 'VII. Čisti poslovni izid poslovnega leta', '{"en":"VII. Net result of the financial year"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, A.VII — v tem paketu edina vrstica, ki nosi rezultat poslovnega leta, saj closing_style result_accounts loči prenesen izid (VI) od izida tekočega leta (VII) brez posebnega razdelitvenega konta.', 'zgd-1'),
  ('SI-ZGD-BS', 'P.B', 'OBV', 'B. Rezervacije in dolgoročne pasivne časovne razmejitve', '{"en":"B. Provisions and long-term deferred income"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, B (stran obveznosti do virov sredstev)', 'zgd-1'),
  ('SI-ZGD-BS', 'P.C', 'OBV', 'C. Dolgoročne obveznosti', '{"en":"C. Long-term liabilities"}'::jsonb, 230, 1, true, array['P.C.I', 'P.C.II', 'P.C.III']::text[], '{}'::text[], null, 'ZGD-1, 65. člen, C (stran obveznosti do virov sredstev)', 'zgd-1'),
  ('SI-ZGD-BS', 'P.C.I', 'P.C', 'I. Dolgoročne finančne obveznosti', '{"en":"I. Long-term financial liabilities"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, C.I', 'zgd-1'),
  ('SI-ZGD-BS', 'P.C.II', 'P.C', 'II. Dolgoročne poslovne obveznosti', '{"en":"II. Long-term trade payables"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, C.II', 'zgd-1'),
  ('SI-ZGD-BS', 'P.C.III', 'P.C', 'III. Odložene obveznosti za davek', '{"en":"III. Deferred tax liabilities"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, C.III', 'zgd-1'),
  ('SI-ZGD-BS', 'P.Č', 'OBV', 'Č. Kratkoročne obveznosti', '{"en":"Č. Short-term liabilities"}'::jsonb, 270, 1, true, array['P.Č.II', 'P.Č.III']::text[], '{}'::text[], null, 'ZGD-1, 65. člen, Č', 'zgd-1'),
  ('SI-ZGD-BS', 'P.Č.II', 'P.Č', 'II. Kratkoročne finančne obveznosti', '{"en":"II. Short-term financial liabilities"}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, Č.II', 'zgd-1'),
  ('SI-ZGD-BS', 'P.Č.III', 'P.Č', 'III. Kratkoročne poslovne obveznosti', '{"en":"III. Short-term trade payables"}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, Č.III', 'zgd-1'),
  ('SI-ZGD-BS', 'P.D', 'OBV', 'D. Kratkoročne pasivne časovne razmejitve', '{"en":"D. Short-term deferred income"}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 65. člen, D (stran obveznosti do virov sredstev)', 'zgd-1'),
  ('SI-ZGD-IS', '1', null, '1. Čisti prihodki od prodaje', '{"en":"1. Net sales revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 1. točka', 'zgd-1'),
  ('SI-ZGD-IS', '2', null, '2. Sprememba vrednosti zalog proizvodov in nedokončane proizvodnje', '{"en":"2. Change in inventories of products and work in progress"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 2. točka', 'zgd-1'),
  ('SI-ZGD-IS', '3', null, '3. Usredstveni lastni proizvodi in lastne storitve', '{"en":"3. Capitalised own products and services"}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 3. točka', 'zgd-1'),
  ('SI-ZGD-IS', '4', null, '4. Drugi poslovni prihodki', '{"en":"4. Other operating income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 4. točka', 'zgd-1'),
  ('SI-ZGD-IS', '5', null, '5. Stroški blaga, materiala in storitev', '{"en":"5. Cost of goods, materials and services"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 5. točka', 'zgd-1'),
  ('SI-ZGD-IS', '6', null, '6. Stroški dela', '{"en":"6. Labour costs"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 6. točka', 'zgd-1'),
  ('SI-ZGD-IS', '7', null, '7. Odpisi vrednosti', '{"en":"7. Value adjustments"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 7. točka', 'zgd-1'),
  ('SI-ZGD-IS', '8', null, '8. Drugi poslovni odhodki', '{"en":"8. Other operating expenses"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 8. točka', 'zgd-1'),
  ('SI-ZGD-IS', '9', null, '9. Finančni prihodki iz deležev', '{"en":"9. Financial income from shares"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 9. točka', 'zgd-1'),
  ('SI-ZGD-IS', '10', null, '10. Finančni prihodki iz danih posojil', '{"en":"10. Financial income from loans granted"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 10. točka', 'zgd-1'),
  ('SI-ZGD-IS', '11', null, '11. Finančni prihodki iz poslovnih terjatev', '{"en":"11. Financial income from business receivables"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 11. točka — vključuje tudi dobičke iz tečajnih razlik pri poslovnih terjatvah in obresti na denarna sredstva.', 'zgd-1'),
  ('SI-ZGD-IS', '12', null, '12. Finančni odhodki iz oslabitve in odpisov finančnih naložb', '{"en":"12. Financial expenses from impairment of financial investments"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 12. točka', 'zgd-1'),
  ('SI-ZGD-IS', '13', null, '13. Finančni odhodki iz finančnih obveznosti', '{"en":"13. Financial expenses from financial liabilities"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 13. točka', 'zgd-1'),
  ('SI-ZGD-IS', '14', null, '14. Finančni odhodki iz poslovnih obveznosti', '{"en":"14. Financial expenses from business obligations"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 14. točka — vključuje tudi izgube iz tečajnih razlik pri poslovnih obveznostih in obresti na kratkoročna posojila.', 'zgd-1'),
  ('SI-ZGD-IS', '15', null, '15. Drugi prihodki', '{"en":"15. Other income"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 15. točka', 'zgd-1'),
  ('SI-ZGD-IS', '16', null, '16. Drugi odhodki', '{"en":"16. Other expenses"}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 16. točka — vključuje tudi odhodke iz naslova zaokroževanja.', 'zgd-1'),
  ('SI-ZGD-IS', '17', null, '17. Davek iz dobička', '{"en":"17. Corporate income tax"}'::jsonb, 190, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 17. točka', 'zgd-1'),
  ('SI-ZGD-IS', '18', null, '18. Odloženi davki', '{"en":"18. Deferred taxes"}'::jsonb, 200, 1, false, '{}'::text[], '{}'::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 18. točka', 'zgd-1'),
  ('SI-ZGD-IS', '19', null, '19. Čisti poslovni izid obračunskega obdobja', '{"en":"19. Net result of the accounting period"}'::jsonb, 210, 1, true, array['1', '2', '3', '4', '9', '10', '11', '15']::text[], array['5', '6', '7', '8', '12', '13', '14', '16', '17', '18']::text[], null, 'ZGD-1, 66. člen, drugi odstavek, 19. točka — vsota postavk 1 do 18 po njihovem predznaku, brez natisnjenih vmesnih seštevkov, ki jih obrazec izkaza poslovnega izida ne zahteva kot ločeno vrstico.', 'zgd-1')
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
    ('SI-ZGD-BS', 'A.I', 10, 'code_range', '1000', '1099', null, 'any'),
    ('SI-ZGD-BS', 'A.II', 10, 'code_range', '1100', '1299', null, 'any'),
    ('SI-ZGD-BS', 'A.III', 10, 'code_range', '1300', '1399', null, 'any'),
    ('SI-ZGD-BS', 'A.IV', 10, 'code_range', '1400', '1499', null, 'any'),
    ('SI-ZGD-BS', 'A.V', 10, 'code_range', '1500', '1599', null, 'any'),
    ('SI-ZGD-BS', 'A.VI', 10, 'code_range', '1600', '1699', null, 'any'),
    ('SI-ZGD-BS', 'B.II', 10, 'code_range', '2000', '2099', null, 'any'),
    ('SI-ZGD-BS', 'B.III', 10, 'code_range', '2100', '2199', null, 'any'),
    ('SI-ZGD-BS', 'B.IV', 10, 'code_range', '2200', '2299', null, 'any'),
    ('SI-ZGD-BS', 'B.V', 10, 'code_range', '2500', '2599', null, 'any'),
    ('SI-ZGD-BS', 'C', 10, 'code_range', '3000', '3099', null, 'any'),
    ('SI-ZGD-BS', 'P.A.I', 10, 'code_range', '4000', '4099', null, 'any'),
    ('SI-ZGD-BS', 'P.A.II', 10, 'code_range', '4100', '4199', null, 'any'),
    ('SI-ZGD-BS', 'P.A.III', 10, 'code_range', '4200', '4299', null, 'any'),
    ('SI-ZGD-BS', 'P.A.VI', 10, 'code_range', '4300', '4399', null, 'any'),
    ('SI-ZGD-BS', 'P.A.VII', 10, 'code_range', '4400', '4499', null, 'any'),
    ('SI-ZGD-BS', 'P.B', 10, 'code_range', '5000', '5199', null, 'any'),
    ('SI-ZGD-BS', 'P.C.I', 10, 'code_range', '6000', '6099', null, 'any'),
    ('SI-ZGD-BS', 'P.C.II', 10, 'code_range', '6100', '6199', null, 'any'),
    ('SI-ZGD-BS', 'P.C.III', 10, 'code_range', '6200', '6299', null, 'any'),
    ('SI-ZGD-BS', 'P.Č.II', 10, 'code_range', '7000', '7099', null, 'any'),
    ('SI-ZGD-BS', 'P.Č.III', 10, 'code_range', '7100', '7899', null, 'any'),
    ('SI-ZGD-BS', 'P.D', 10, 'code_range', '7900', '7999', null, 'any'),
    ('SI-ZGD-IS', '1', 10, 'code_range', '8000', '8099', null, 'any'),
    ('SI-ZGD-IS', '2', 10, 'code_range', '8100', '8109', null, 'any'),
    ('SI-ZGD-IS', '3', 10, 'code_range', '8110', '8119', null, 'any'),
    ('SI-ZGD-IS', '4', 10, 'code_range', '8120', '8199', null, 'any'),
    ('SI-ZGD-IS', '5', 10, 'code_range', '8200', '8299', null, 'any'),
    ('SI-ZGD-IS', '6', 10, 'code_range', '8300', '8399', null, 'any'),
    ('SI-ZGD-IS', '7', 10, 'code_range', '8400', '8499', null, 'any'),
    ('SI-ZGD-IS', '8', 10, 'code_range', '8500', '8599', null, 'any'),
    ('SI-ZGD-IS', '9', 10, 'code_range', '9000', '9009', null, 'any'),
    ('SI-ZGD-IS', '10', 10, 'code_range', '9010', '9019', null, 'any'),
    ('SI-ZGD-IS', '11', 10, 'code_range', '9020', '9049', null, 'any'),
    ('SI-ZGD-IS', '12', 10, 'code_range', '9100', '9109', null, 'any'),
    ('SI-ZGD-IS', '13', 10, 'code_range', '9110', '9119', null, 'any'),
    ('SI-ZGD-IS', '14', 10, 'code_range', '9120', '9149', null, 'any'),
    ('SI-ZGD-IS', '15', 10, 'code_range', '9200', '9209', null, 'any'),
    ('SI-ZGD-IS', '16', 10, 'code_range', '9210', '9229', null, 'any'),
    ('SI-ZGD-IS', '17', 10, 'code_range', '9300', '9309', null, 'any'),
    ('SI-ZGD-IS', '18', 10, 'code_range', '9310', '9319', null, 'any')
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
  ('SI', 'Slovenia', '{"en":"Slovenia"}'::jsonb, array['sl', 'en']::text[], 'EUR', '2200', '7100', '2250', '9220', '4300', '8000', '8200', '2500', '2510', 'PRO', 'NAB', 'RAZ', 'sl', 'result_accounts', '4400', '4400', null, 'OB', 'half_up', default, '9030', '9130', null, null, null, null, '7270', '2240', 'Otvoritvena knjižba', null)
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
  legal_payment_days            = 30,
  late_payment_reference        = 'ZPreZP-1, 13. člen — zakonske zamudne obresti po predpisani obrestni meri zamudnih obresti; 14. člen — pavšalno nadomestilo stroškov izterjave v višini 40 EUR, ki gre upniku ne glede na to, ali je dolžnika opomnil, in neodvisno od morebitne pravice do povračila dejanskih stroškov izterjave.',
  numbering_legal_reference     = 'ZDDV-1, 82. člen, prvi odstavek, 2. točka — račun mora vsebovati zaporedno številko, ki temelji na eni ali več serijah številk in ki omogoča identifikacijo računa. Zakon zahteva torej enoličnost in ne nujno neprekinjenosti, zato je numbering sequential in ne gapless; več serij številk je dopustnih.',
  numbering_source_key          = 'zddv-1',
  payment_terms_legal_reference = 'ZPreZP-1, 12. člen — če plačilni rok med gospodarskimi subjekti ni dogovorjen, mora dolžnik svojo denarno obveznost izpolniti v 30 dneh od dneva, ko je prejel račun ali enakovreden poziv k plačilu.',
  payment_terms_source_key      = 'zprezp-1',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'ZDDV-1, 33. člen, prvi odstavek — obveznost za obračun DDV nastane, ko je blago dobavljeno ali so storitve opravljene; drugi odstavek — če je pred tem izdan račun, nastane obveznost za obračun DDV na dan izdaje računa, in sicer za znesek, ki je na računu naveden. Skupaj gre za earliest_of_delivery_or_payment v smislu, da izdaja računa pred dobavo prevzame trenutek obdavčitve; posebna ureditev po plačani realizaciji (131. do 134. člen) je pri ustreznih davkih označena posebej kot cash_basis.',
  tax_point_source_key          = 'zddv-1',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'ZDDV-1, 26. člen — popravek (zmanjšanje ali povečanje) davčne osnove po izdaji računa se opravi z dobropisom ali bremepisom, ki se sklicuje na izvirni račun, nikoli s spremembo ali izbrisom knjižene listine.',
  posted_edit_policy_source_key = 'zddv-1',
  einvoice_profile              = 'eslog-2.0',
  einvoice_mandatory_from       = date '2028-01-01',
  einvoice_obligation           = 'mandatory',
  einvoice_legal_reference      = 'Za javni sektor (proračunske uporabnike) je izmenjava e-računov obvezna od 1. januarja 2015 (26. člen Zakona o opravljanju plačilnih storitev za proračunske uporabnike, ZOPSPU-1): pošiljanje računov mimo Uprave Republike Slovenije za javna plačila (UJP) ni dovoljeno, izmenjava pa poteka v formatu e-SLOG prek bank, ponudnikov, ki imajo z UJP sklenjeno pogodbo, ali prek portala UJPeRačun. To je obveznost do proračunskih uporabnikov in ni splošna obveznost B2B, zato ni tu zapisana kot obligation. Splošna obveznost e-računov med gospodarskimi subjekti (B2B) je bila uvedena z Zakonom o izmenjavi elektronskih računov in drugih elektronskih dokumentov (ZIERDED), ki ga je državni zbor sprejel 23. oktobra 2025 in je bil objavljen v Uradnem listu RS, št. 85/2025 z dne 6. novembra 2025; zakon je začel veljati trideseti dan po objavi, uporabljati pa se v delu o ponudnikih začne 1. aprila 2027, splošna obveznost izmenjave e-računov med vsemi gospodarskimi subjekti pa 1. januarja 2028 (28. člen ZIERDED), kar je dan, ki je tu zapisan kot mandatory_from. Zakon ne uvaja sprotnega poročanja FURS (e-reporting); dopustni formati so e-SLOG (nacionalni standard, uporabljen tudi za obveznost do proračunskih uporabnikov od leta 2015), sintakse, skladne z EN 16931, ali drug mednarodno priznan standard, o katerem se stranki dogovorita. profile navaja e-SLOG 2.0 kot referenčni, dejansko uveljavljeni slovenski standard; zakon dopušča tudi alternative, ki jih to zaprto polje ne more vse hkrati imenovati. Paket packages/formats danes ne piše niti ne preverja e-SLOG sintakse — glej poglavje »From Slovenia« v docs/international.md. vat_scheme 9949 je slovenska identifikacijska številka za DDV na seznamu EAS; party_scheme ostaja prazen, ker ZIERDED ne predpisuje enotne sheme naslavljanja za B2B izmenjavo.',
  einvoice_source_key           = 'zierded',
  party_scheme                  = null,
  vat_scheme                    = '9949',
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'SI';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('SI', 'reverse_charge', 'reverse_charge', 'Obrnjena davčna obveznost — DDV obračuna prejemnik v skladu s 76.a členom ZDDV-1.', '{"en":"Reverse charge — VAT accounted for by the recipient under article 76a ZDDV-1."}'::jsonb, 10, date '1970-01-01', null, 'ZDDV-1, 82. člen, prvi odstavek, 10. točka — če je prejemnik dobave plačnik DDV, mora račun namesto zneska DDV vsebovati sklic na ustrezno določbo te direktive ali zakona oziroma navedbo, da se za dobavo blaga ali storitev uporabi obrnjena davčna obveznost.'),
  ('SI', 'intracom_goods', 'intra_eu_goods', 'Oproščena dobava blaga znotraj Unije — 46. člen ZDDV-1, člen 138 Direktive Sveta 2006/112/ES.', '{"en":"Exempt intra-Union supply of goods — article 46 ZDDV-1, article 138 of Council Directive 2006/112/EC."}'::jsonb, 20, date '1970-01-01', null, 'ZDDV-1, 82. člen, prvi odstavek, 10. točka — pri oproščeni dobavi blaga znotraj Unije mora račun vsebovati sklic na 46. člen tega zakona oziroma na člen 138 Direktive Sveta 2006/112/ES ali navedbo, da je dobava oproščena.'),
  ('SI', 'intracom_services', 'intra_eu_services', 'Obrnjena davčna obveznost — storitev je obdavčena v državi članici prejemnika v skladu s 25. členom ZDDV-1 in členom 196 Direktive Sveta 2006/112/ES.', '{"en":"Reverse charge — the service is taxed in the Member State of the recipient under article 25 ZDDV-1 and article 196 of Council Directive 2006/112/EC."}'::jsonb, 30, date '1970-01-01', null, 'ZDDV-1, 82. člen, prvi odstavek, 10. točka — kadar je plačnik DDV izključno prejemnik storitve s sedežem v drugi državi članici, račun vsebuje navedbo obrnjene davčne obveznosti.'),
  ('SI', 'export', 'export', 'Oproščena izvozna dobava blaga — 52. člen ZDDV-1.', '{"en":"Exempt export of goods — article 52 ZDDV-1."}'::jsonb, 40, date '1970-01-01', null, 'ZDDV-1, 82. člen, prvi odstavek, 10. točka — pri izvozni dobavi mora račun vsebovati sklic na 52. člen tega zakona ali navedbo, da je dobava oproščena.'),
  ('SI', 'exempt', 'exempt', 'Oproščena dobava brez pravice do odbitka DDV — 44. člen ZDDV-1.', '{"en":"Exempt supply without right of deduction — article 44 ZDDV-1."}'::jsonb, 50, date '1970-01-01', null, 'ZDDV-1, 82. člen, prvi odstavek, 10. točka — pri oproščeni dobavi mora račun vsebovati sklic na določbo tega zakona ali direktive, na podlagi katere je dobava oproščena, oziroma drugo navedbo, da je dobava oproščena.'),
  ('SI', 'small_business', 'small_business', 'Oproščeno po 94. členu ZDDV-1 — mali davčni zavezanec.', '{"en":"Exempt under article 94 ZDDV-1 — small taxable person."}'::jsonb, 60, date '1970-01-01', null, 'ZDDV-1, 94. člen — davčni zavezanec je oproščen obračunavanja DDV, če v predhodnem koledarskem letu ni presegel 60.000 EUR obdavčljivega prometa na ozemlju Slovenije in tega zneska ne preseže niti v tekočem koledarskem letu; taka oseba na računu ne sme izkazati DDV.'),
  ('SI', 'late_payment', 'late_payment', 'V primeru zamude s plačilom gredo upniku zakonske zamudne obresti ter pavšalno nadomestilo stroškov izterjave v višini 40 EUR (13. in 14. člen ZPreZP-1).', '{"en":"In the event of late payment, the creditor is entitled to statutory default interest and a flat compensation of EUR 40 for recovery costs (articles 13 and 14 ZPreZP-1)."}'::jsonb, 70, date '1970-01-01', null, 'ZPreZP-1, 13. in 14. člen — glej documents.late_payment_reference.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
