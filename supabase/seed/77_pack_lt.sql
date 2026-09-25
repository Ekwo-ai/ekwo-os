-- Ekwo OS — Lietuva: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/lt at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build lt`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Lietuvos Respublikos pridėtinės vertės mokesčio įstatymas Nr. IX-751, konsoliduotas tekstas su Valstybinės mokesčių inspekcijos komentaru (aktuali redakcija 2026-09-23) (Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos)
--     https://www.vmi.lt/evmi/documents/20142/390965/PVM%C4%AE+komentaras+(aktuali+redakcija+2026-07-02).pdf
--   Lietuvos Respublikos pridėtinės vertės mokesčio įstatymas Nr. IX-751, konsoliduota redakcija (Lietuvos Respublikos Seimas — e-seimas.lrs.lt)
--     https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.163423/asr
--   Valstybinės mokesčių inspekcijos prie Lietuvos Respublikos finansų ministerijos viršininko 2004 m. kovo 1 d. įsakymas Nr. VA-29 „Dėl Pridėtinės vertės mokesčio deklaracijos ir kitų su šiuo mokesčiu susijusių formų bei jų užpildymo taisyklių patvirtinimo“ (Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos)
--     https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.229389/asr
--   KM1739 „Mokestinio laikotarpio PVM deklaracijos FR0600 formos užpildymas“ (Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos)
--     https://www.vmi.lt/evmi/documents/20142/391077/KM1739+%E2%80%9EMokestinio+laikotarpio+PVM+deklaracijos+FR0600+formos+u%C5%BEpildymas%E2%80%9C.pdf
--   Valstybinės mokesčių inspekcijos prie Lietuvos Respublikos finansų ministerijos viršininko 2016 m. rugsėjo 28 d. įsakymas Nr. VA-119 „Dėl Išmaniosios mokesčių administravimo informacinės sistemos naudojimo taisyklių patvirtinimo“ (Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos)
--     https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/fa6832b0860511e6a0f68fd135e6f40c/asr
--   Lietuvos Respublikos viešųjų pirkimų įstatymas Nr. I-1491, konsoliduota redakcija, 22 straipsnio 3 dalis (Lietuvos Respublikos Seimas — e-seimas.lrs.lt)
--     https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.30614/asr
--   Lietuvos Respublikos finansinės apskaitos įstatymas Nr. IX-574, konsoliduota redakcija nuo 2025-05-01 (Lietuvos Respublikos Seimas — e-seimas.lrs.lt)
--     https://e-seimas.lrs.lt/portal/legalActEditions/lt/TAD/TAIS.154657
--   Pavyzdinis sąskaitų planas, patvirtintas Audito ir apskaitos tarnybos direktoriaus 2015 m. balandžio 13 d. įsakymu Nr. VAS-15 (Audito, apskaitos, turto vertinimo ir nemokumo valdymo tarnyba prie Lietuvos Respublikos finansų ministerijos (AVNT))
--     https://www.avnt.lt/assets/Apskaita/VAS-2020/Pavyzdinis-saskaitu-planas.pdf
--   Lietuvos Respublikos mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymas Nr. IX-1873, konsoliduota redakcija nuo 2017-07-01 (Lietuvos Respublikos Seimas — e-seimas.lrs.lt)
--     https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.224224/asr
--   Lietuvos Respublikos euro įvedimo Lietuvos Respublikoje įstatymas Nr. XII-828 (Lietuvos Respublikos Seimas — e-seimas.lrs.lt)
--     https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/c1f2e0c2cab811e3afd8f519d03d5f2d
--   SABIS — sąskaitų administravimo bendroji informacinė sistema, B2G elektroninių sąskaitų faktūrų platforma nuo 2024-09-01 (Registrų centras)
--     https://nbfc.lrv.lt/uploads/nbfc/documents/files/SABIS%20pirkimo%20Technine%20specifikacija.pdf
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
  ('LT', 'Lietuva', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '10c13d5ebd21549022adaf098f877ba47576bc1b67c873be7b0282627802463e', '[{"key":"pvmi","title":"Lietuvos Respublikos pridėtinės vertės mokesčio įstatymas Nr. IX-751, konsoliduotas tekstas su Valstybinės mokesčių inspekcijos komentaru (aktuali redakcija 2026-09-23)","publisher":"Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos","url":"https://www.vmi.lt/evmi/documents/20142/390965/PVM%C4%AE+komentaras+(aktuali+redakcija+2026-07-02).pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"pvmi-eseimas","title":"Lietuvos Respublikos pridėtinės vertės mokesčio įstatymas Nr. IX-751, konsoliduota redakcija","publisher":"Lietuvos Respublikos Seimas — e-seimas.lrs.lt","url":"https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.163423/asr","consulted_on":"2026-09-25","kind":"law"},{"key":"fr0600-taisykles","title":"Valstybinės mokesčių inspekcijos prie Lietuvos Respublikos finansų ministerijos viršininko 2004 m. kovo 1 d. įsakymas Nr. VA-29 „Dėl Pridėtinės vertės mokesčio deklaracijos ir kitų su šiuo mokesčiu susijusių formų bei jų užpildymo taisyklių patvirtinimo“","publisher":"Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos","url":"https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.229389/asr","consulted_on":"2026-09-25","kind":"regulation"},{"key":"fr0600-km1739","title":"KM1739 „Mokestinio laikotarpio PVM deklaracijos FR0600 formos užpildymas“","publisher":"Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos","url":"https://www.vmi.lt/evmi/documents/20142/391077/KM1739+%E2%80%9EMokestinio+laikotarpio+PVM+deklaracijos+FR0600+formos+u%C5%BEpildymas%E2%80%9C.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"imas","title":"Valstybinės mokesčių inspekcijos prie Lietuvos Respublikos finansų ministerijos viršininko 2016 m. rugsėjo 28 d. įsakymas Nr. VA-119 „Dėl Išmaniosios mokesčių administravimo informacinės sistemos naudojimo taisyklių patvirtinimo“","publisher":"Valstybinė mokesčių inspekcija prie Lietuvos Respublikos finansų ministerijos","url":"https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/fa6832b0860511e6a0f68fd135e6f40c/asr","consulted_on":"2026-09-25","kind":"regulation"},{"key":"vpi","title":"Lietuvos Respublikos viešųjų pirkimų įstatymas Nr. I-1491, konsoliduota redakcija, 22 straipsnio 3 dalis","publisher":"Lietuvos Respublikos Seimas — e-seimas.lrs.lt","url":"https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.30614/asr","consulted_on":"2026-09-25","kind":"law"},{"key":"fai","title":"Lietuvos Respublikos finansinės apskaitos įstatymas Nr. IX-574, konsoliduota redakcija nuo 2025-05-01","publisher":"Lietuvos Respublikos Seimas — e-seimas.lrs.lt","url":"https://e-seimas.lrs.lt/portal/legalActEditions/lt/TAD/TAIS.154657","consulted_on":"2026-09-25","kind":"law"},{"key":"avnt-planas","title":"Pavyzdinis sąskaitų planas, patvirtintas Audito ir apskaitos tarnybos direktoriaus 2015 m. balandžio 13 d. įsakymu Nr. VAS-15","publisher":"Audito, apskaitos, turto vertinimo ir nemokumo valdymo tarnyba prie Lietuvos Respublikos finansų ministerijos (AVNT)","url":"https://www.avnt.lt/assets/Apskaita/VAS-2020/Pavyzdinis-saskaitu-planas.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"velavimo-prevencija","title":"Lietuvos Respublikos mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymas Nr. IX-1873, konsoliduota redakcija nuo 2017-07-01","publisher":"Lietuvos Respublikos Seimas — e-seimas.lrs.lt","url":"https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.224224/asr","consulted_on":"2026-09-25","kind":"law"},{"key":"euro-istatymas","title":"Lietuvos Respublikos euro įvedimo Lietuvos Respublikoje įstatymas Nr. XII-828","publisher":"Lietuvos Respublikos Seimas — e-seimas.lrs.lt","url":"https://e-seimas.lrs.lt/portal/legalAct/lt/TAD/c1f2e0c2cab811e3afd8f519d03d5f2d","consulted_on":"2026-09-25","kind":"law"},{"key":"e-saskaita","title":"SABIS — sąskaitų administravimo bendroji informacinė sistema, B2G elektroninių sąskaitų faktūrų platforma nuo 2024-09-01","publisher":"Registrų centras","url":"https://nbfc.lrv.lt/uploads/nbfc/documents/files/SABIS%20pirkimo%20Technine%20specifikacija.pdf","consulted_on":"2026-09-25","kind":"portal"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformant with Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of VAT categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('LT', 'default', 'Sąskaitų planas pagal AVNT pavyzdinio plano klasių struktūrą', '{}'::jsonb, true, 'companies', array['LT-VAS-BS', 'LT-VAS-IS']::text[], null, 'Finansinės apskaitos įstatymo 2 straipsnio 3 dalis apibrėžia sąskaitų planą kaip „subjekto naudojamų sąskaitų sąrašą“, o 8 straipsnio 1 dalis palieka apskaitos registrų skaičių, sudarymo būdą ir formą pasirinkti pačiam subjektui: Lietuva, kaip ir Estija, neturi įstatymu nustatyto privalomojo įmonių sąskaitų plano (12 straipsnio 5 dalies 2 punktas numato privalomąjį planą tik viešojo sektoriaus subjektams). Audito, apskaitos, turto vertinimo ir nemokumo valdymo tarnyba (AVNT) skelbia pavyzdinį, neprivalomą sąskaitų planą (12 straipsnio 6 dalies 1 punktas), kurio klasių struktūra (1 ilgalaikis turtas, 2 trumpalaikis turtas, 3 nuosavas kapitalas, 4 mokėtinos sumos ir įsipareigojimai, 5 pajamos, 6 sąnaudos) yra plačiai naudojama lietuviškoje apskaitos praktikoje. Šis pakas seka šią klasių struktūrą, bet sąskaitų numeriai ir jų grupavimas yra originalūs ir nekopijuoja AVNT plano eilutė po eilutės — kiekviena sąskaita priskirta VAS 2 (balansas) ir VAS 3 (pelno (nuostolių) ataskaita, 1-oji schema) eilutei, kuriai ji priklauso.', 'avnt-planas')
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
  ('LT', 'default', '1010', 'Plėtros darbai', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('LT', 'default', '1015', 'Plėtros darbų amortizacija', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('LT', 'default', '1020', 'Prekių ženklai ir licencijos', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('LT', 'default', '1025', 'Prekių ženklų ir licencijų amortizacija', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('LT', 'default', '1030', 'Programinė įranga', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('LT', 'default', '1035', 'Programinės įrangos amortizacija', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('LT', 'default', '1040', 'Prestižas', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('LT', 'default', '1045', 'Prestižo amortizacija', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('LT', 'default', '1100', 'Žemė', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('LT', 'default', '1110', 'Pastatai ir statiniai', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('LT', 'default', '1115', 'Pastatų ir statinių nusidėvėjimas', '{}'::jsonb, 'asset_fixed', false, null, 110),
  ('LT', 'default', '1120', 'Mašinos ir įrenginiai', '{}'::jsonb, 'asset_fixed', false, null, 120),
  ('LT', 'default', '1125', 'Mašinų ir įrenginių nusidėvėjimas', '{}'::jsonb, 'asset_fixed', false, null, 130),
  ('LT', 'default', '1130', 'Transporto priemonės', '{}'::jsonb, 'asset_fixed', false, null, 140),
  ('LT', 'default', '1135', 'Transporto priemonių nusidėvėjimas', '{}'::jsonb, 'asset_fixed', false, null, 150),
  ('LT', 'default', '1140', 'Kita įranga, prietaisai ir įrankiai', '{}'::jsonb, 'asset_fixed', false, null, 160),
  ('LT', 'default', '1145', 'Kitos įrangos nusidėvėjimas', '{}'::jsonb, 'asset_fixed', false, null, 170),
  ('LT', 'default', '1190', 'Nebaigta statyba ir išankstiniai apmokėjimai už ilgalaikį turtą', '{}'::jsonb, 'asset_fixed', false, null, 180),
  ('LT', 'default', '1200', 'Investicinis turtas', '{}'::jsonb, 'asset_non_current', false, null, 190),
  ('LT', 'default', '1300', 'Investicijos į dukterines ir asocijuotas įmones', '{}'::jsonb, 'asset_non_current', false, null, 200),
  ('LT', 'default', '1310', 'Kitos ilgalaikės finansinės investicijos', '{}'::jsonb, 'asset_non_current', false, null, 210),
  ('LT', 'default', '1350', 'Po vienų metų gautinos sumos', '{}'::jsonb, 'asset_non_current', false, null, 220),
  ('LT', 'default', '1360', 'Atidėtojo pelno mokesčio turtas', '{}'::jsonb, 'asset_non_current', false, null, 230),
  ('LT', 'default', '2000', 'Žaliavos ir komplektavimo gaminiai', '{}'::jsonb, 'asset_current', false, null, 240),
  ('LT', 'default', '2010', 'Nebaigta gamyba', '{}'::jsonb, 'asset_current', false, null, 250),
  ('LT', 'default', '2020', 'Pagaminta produkcija', '{}'::jsonb, 'asset_current', false, null, 260),
  ('LT', 'default', '2030', 'Pirktos prekės, skirtos perparduoti', '{}'::jsonb, 'asset_current', false, null, 270),
  ('LT', 'default', '2040', 'Išankstiniai apmokėjimai už atsargas', '{}'::jsonb, 'asset_prepayments', false, null, 280),
  ('LT', 'default', '2100', 'Pirkėjų skolos', '{}'::jsonb, 'asset_receivable', true, null, 290),
  ('LT', 'default', '2110', 'Abejotinos skolos', '{}'::jsonb, 'asset_current', false, null, 300),
  ('LT', 'default', '2120', 'Kitos gautinos sumos', '{}'::jsonb, 'asset_current', false, null, 310),
  ('LT', 'default', '2130', 'Susijusių šalių skolos', '{}'::jsonb, 'asset_current', false, null, 320),
  ('LT', 'default', '2140', 'Būsimų laikotarpių sąnaudos', '{}'::jsonb, 'asset_prepayments', false, null, 330),
  ('LT', 'default', '2200', 'PVM permoka — patikslinta deklaracijos suma', '{}'::jsonb, 'asset_current', true, null, 340),
  ('LT', 'default', '2210', 'Pirkimo PVM', '{}'::jsonb, 'asset_current', false, null, 350),
  ('LT', 'default', '2220', 'Kitų mokesčių permokos', '{}'::jsonb, 'asset_current', false, null, 360),
  ('LT', 'default', '2300', 'Trumpalaikės investicijos', '{}'::jsonb, 'asset_current', false, null, 370),
  ('LT', 'default', '2400', 'Kasa', '{}'::jsonb, 'asset_cash', false, null, 380),
  ('LT', 'default', '2410', 'Banko sąskaitos', '{}'::jsonb, 'asset_cash', false, null, 390),
  ('LT', 'default', '2420', 'Pinigai kelyje', '{}'::jsonb, 'asset_cash', false, null, 400),
  ('LT', 'default', '3000', 'Įstatinis kapitalas', '{}'::jsonb, 'equity', false, null, 410),
  ('LT', 'default', '3010', 'Nepaskirstytasis (pasirašytasis neapmokėtas) kapitalas', '{}'::jsonb, 'equity', false, null, 420),
  ('LT', 'default', '3020', 'Akcijų priedai', '{}'::jsonb, 'equity', false, null, 430),
  ('LT', 'default', '3100', 'Perkainojimo rezervas', '{}'::jsonb, 'equity', false, null, 440),
  ('LT', 'default', '3200', 'Privalomasis rezervas', '{}'::jsonb, 'equity', false, null, 450),
  ('LT', 'default', '3210', 'Kiti rezervai', '{}'::jsonb, 'equity', false, null, 460),
  ('LT', 'default', '3300', 'Ankstesnių metų nepaskirstytasis pelnas (nuostoliai)', '{}'::jsonb, 'equity_retained', false, null, 470),
  ('LT', 'default', '3310', 'Ataskaitinių metų pelnas (nuostoliai)', '{}'::jsonb, 'equity_retained', false, null, 480),
  ('LT', 'default', '4000', 'Po vienų metų mokėtinos paskolos', '{}'::jsonb, 'liability_non_current', false, null, 490),
  ('LT', 'default', '4010', 'Kiti ilgalaikiai įsipareigojimai', '{}'::jsonb, 'liability_non_current', false, null, 500),
  ('LT', 'default', '4020', 'Ilgalaikiai atidėjiniai', '{}'::jsonb, 'liability_non_current', false, null, 510),
  ('LT', 'default', '4100', 'Per vienus metus mokėtinos paskolų dalys', '{}'::jsonb, 'liability_current', false, null, 520),
  ('LT', 'default', '4110', 'Trumpalaikės paskolos', '{}'::jsonb, 'liability_current', false, null, 530),
  ('LT', 'default', '4200', 'Skolos tiekėjams', '{}'::jsonb, 'liability_payable', true, null, 540),
  ('LT', 'default', '4210', 'Gauti išankstiniai apmokėjimai', '{}'::jsonb, 'liability_current', false, null, 550),
  ('LT', 'default', '4300', 'Su darbo santykiais susiję įsipareigojimai', '{}'::jsonb, 'liability_current', false, null, 560),
  ('LT', 'default', '4310', 'Su socialiniu draudimu susiję įsipareigojimai', '{}'::jsonb, 'liability_current', false, null, 570),
  ('LT', 'default', '4400', 'Pardavimo PVM', '{}'::jsonb, 'liability_current', false, null, 580),
  ('LT', 'default', '4410', 'Mokėtinas pelno mokestis', '{}'::jsonb, 'liability_current', false, null, 590),
  ('LT', 'default', '4420', 'Mokėtinas gyventojų pajamų mokestis', '{}'::jsonb, 'liability_current', false, null, 600),
  ('LT', 'default', '4430', 'PVM mokėtina suma — patikslinta deklaracijos suma', '{}'::jsonb, 'liability_current', true, null, 610),
  ('LT', 'default', '4500', 'Kitos mokėtinos sumos', '{}'::jsonb, 'liability_current', false, null, 620),
  ('LT', 'default', '4510', 'Neaiškūs gauti mokėjimai', '{}'::jsonb, 'liability_current', false, null, 630),
  ('LT', 'default', '4520', 'Trumpalaikiai atidėjiniai', '{}'::jsonb, 'liability_current', false, null, 640),
  ('LT', 'default', '4530', 'Būsimų laikotarpių pajamos ir gauti išankstiniai apmokėjimai', '{}'::jsonb, 'liability_current', false, null, 650),
  ('LT', 'default', '5000', 'Pardavimo pajamos Lietuvoje', '{}'::jsonb, 'income', false, null, 660),
  ('LT', 'default', '5010', 'Prekių tiekimas į kitas ES valstybes nares', '{}'::jsonb, 'income', false, null, 670),
  ('LT', 'default', '5020', 'Paslaugų teikimas į kitas ES valstybes nares', '{}'::jsonb, 'income', false, null, 680),
  ('LT', 'default', '5030', 'Eksportas', '{}'::jsonb, 'income', false, null, 690),
  ('LT', 'default', '5040', 'Neapmokestinamos PVM pajamos', '{}'::jsonb, 'income', false, null, 700),
  ('LT', 'default', '5100', 'Kitos veiklos pajamos', '{}'::jsonb, 'income_other', false, null, 710),
  ('LT', 'default', '5110', 'Ilgalaikio turto perleidimo pelnas', '{}'::jsonb, 'income_other', false, null, 720),
  ('LT', 'default', '5800', 'Palūkanų pajamos', '{}'::jsonb, 'income_other', false, null, 730),
  ('LT', 'default', '5810', 'Gautos baudos ir delspinigiai', '{}'::jsonb, 'income_other', false, null, 740),
  ('LT', 'default', '5820', 'Teigiama valiutos kurso pasikeitimo įtaka', '{}'::jsonb, 'income_other', false, null, 750),
  ('LT', 'default', '6000', 'Parduotų prekių savikaina', '{}'::jsonb, 'expense_direct_cost', false, null, 760),
  ('LT', 'default', '6010', 'Žaliavų ir medžiagų sąnaudos', '{}'::jsonb, 'expense_direct_cost', false, null, 770),
  ('LT', 'default', '6020', 'Paslaugų savikaina', '{}'::jsonb, 'expense_direct_cost', false, null, 780),
  ('LT', 'default', '6100', 'Patalpų nuomos ir išlaikymo sąnaudos', '{}'::jsonb, 'expense', false, null, 790),
  ('LT', 'default', '6110', 'Komunalinės paslaugos', '{}'::jsonb, 'expense', false, null, 800),
  ('LT', 'default', '6120', 'Ryšio ir informacinių technologijų paslaugos', '{}'::jsonb, 'expense', false, null, 810),
  ('LT', 'default', '6130', 'Transporto sąnaudos', '{}'::jsonb, 'expense', false, null, 820),
  ('LT', 'default', '6140', 'Komandiruočių sąnaudos', '{}'::jsonb, 'expense', false, null, 830),
  ('LT', 'default', '6150', 'Reklamos ir rinkodaros sąnaudos', '{}'::jsonb, 'expense', false, null, 840),
  ('LT', 'default', '6160', 'Biuro sąnaudos', '{}'::jsonb, 'expense', false, null, 850),
  ('LT', 'default', '6170', 'Konsultacinės, teisinės ir audito paslaugos', '{}'::jsonb, 'expense', false, null, 860),
  ('LT', 'default', '6180', 'Mokymo sąnaudos', '{}'::jsonb, 'expense', false, null, 870),
  ('LT', 'default', '6190', 'Draudimo sąnaudos', '{}'::jsonb, 'expense', false, null, 880),
  ('LT', 'default', '6200', 'Banko paslaugų sąnaudos', '{}'::jsonb, 'expense', false, null, 890),
  ('LT', 'default', '6210', 'Reprezentacinės sąnaudos', '{}'::jsonb, 'expense', false, null, 900),
  ('LT', 'default', '6220', 'Kitos veiklos sąnaudos', '{}'::jsonb, 'expense', false, null, 910),
  ('LT', 'default', '6400', 'Darbo užmokesčio sąnaudos', '{}'::jsonb, 'expense', false, null, 920),
  ('LT', 'default', '6410', 'Socialinio draudimo įmokų sąnaudos', '{}'::jsonb, 'expense', false, null, 930),
  ('LT', 'default', '6420', 'Kitos su darbo santykiais susijusios sąnaudos', '{}'::jsonb, 'expense', false, null, 940),
  ('LT', 'default', '6600', 'Ilgalaikio turto nusidėvėjimo ir amortizacijos sąnaudos', '{}'::jsonb, 'expense_depreciation', false, null, 950),
  ('LT', 'default', '6610', 'Ilgalaikio turto vertės sumažėjimas', '{}'::jsonb, 'expense_depreciation', false, null, 960),
  ('LT', 'default', '6700', 'Atsargų nurašymas ir vertės sumažėjimas', '{}'::jsonb, 'expense', false, null, 970),
  ('LT', 'default', '6800', 'Palūkanų sąnaudos', '{}'::jsonb, 'expense', false, null, 980),
  ('LT', 'default', '6810', 'Neigiama valiutos kurso pasikeitimo įtaka', '{}'::jsonb, 'expense', false, null, 990),
  ('LT', 'default', '6820', 'Kitos finansinės ir investicinės veiklos sąnaudos', '{}'::jsonb, 'expense', false, null, 1000),
  ('LT', 'default', '6830', 'Apvalinimo skirtumai', '{}'::jsonb, 'expense', false, null, 1010),
  ('LT', 'default', '6900', 'Pelno mokesčio sąnaudos', '{}'::jsonb, 'expense', false, null, 1020)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('LT', 'BEN', 'Bendrasis žurnalas', '{}'::jsonb, 'general', 50),
  ('LT', 'BNK', 'Banko žurnalas', '{}'::jsonb, 'bank', 30),
  ('LT', 'KAS', 'Kasos žurnalas', '{}'::jsonb, 'cash', 40),
  ('LT', 'PRA', 'Pradinių likučių žurnalas', '{}'::jsonb, 'opening', 60),
  ('LT', 'PRD', 'Pardavimų žurnalas', '{}'::jsonb, 'sales', 10),
  ('LT', 'PRK', 'Pirkimų žurnalas', '{}'::jsonb, 'purchase', 20)
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
  ('LT', 'LT-P-05', 'Pirkimas 5%', '{}'::jsonb, 'Vietinis įsigijimas, pilna atskaita', 'percent', 5, 'purchase', 'domestic', date '2026-01-01', null, 'PVMĮ 19 straipsnio 4 ir 5 dalys ir 58 straipsnio 1 dalis. Žr. LT-S-05 dėl datų tikslumo pastabos.', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-09', 'Pirkimas 9%', '{}'::jsonb, 'Iki 2025-12-31 galiojęs lengvatinis tarifas, pilna atskaita', 'percent', 9, 'purchase', 'domestic', date '2009-01-01', date '2025-12-31', 'PVMĮ 19 straipsnio 3 dalis, redakcija galiojusi iki 2025-12-31, ir 58 straipsnio 1 dalis. Žr. LT-S-09 dėl datų tikslumo pastabos.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-12', 'Pirkimas 12%', '{}'::jsonb, 'Vietinis įsigijimas, pilna atskaita', 'percent', 12, 'purchase', 'domestic', date '2026-01-01', null, 'PVMĮ 19 straipsnio 3 dalis (nuo 2026-01-01) ir 58 straipsnio 1 dalis.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-21', 'Pirkimas 21%', '{}'::jsonb, 'Vietinis įsigijimas, pilna atskaita', 'percent', 21, 'purchase', 'domestic', date '2009-09-01', null, 'PVMĮ 19 straipsnio 1 dalis ir 58 straipsnio 1 dalis — pirkimo PVM atskaitomas, jei prekės ar paslaugos skirtos PVM apmokestinamai veiklai.', 'S', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-ICG-21', 'Prekių įsigijimas iš ES, 21%', '{}'::jsonb, 'Pirkėjas pats apskaičiuoja PVM', 'percent', 21, 'purchase', 'intracom_acquisition_goods', date '2009-09-01', null, 'PVMĮ 8 straipsnis — prekių įsigijimas iš kitos ES valstybės narės PVM mokėtojo laikomas įvykusiu Lietuvoje; 3 straipsnio 4 dalis — pirkėjas apskaičiuoja PVM; 34 straipsnio 4 punktas ir 58 straipsnio 1 dalis — apskaičiuota PVM suma yra atskaitoma pirkimo PVM.', 'K', 'VATEX-EU-IC', 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-ND', 'Pramogoms ir reprezentacijai skirtas pirkimas be atskaitos', '{}'::jsonb, 'Prekės ir paslaugos, kurių įsigijimo išlaidos pagal pelno mokesčio teisės aktus nepriskiriamos prie reprezentacinių sąnaudų — atskaita neleidžiama', 'percent', 21, 'purchase', 'domestic', date '2009-09-01', null, 'FR0600 formos pildymo taisyklės (VA-29), 35 laukelio paaiškinimas — pirkimo ir (arba) importo PVM už pramogoms ir reprezentacijai skirtas prekes ir paslaugas, kurių įsigijimo išlaidos pagal pelno mokesčio įstatymą nepriskiriamos prie reprezentacinių sąnaudų, į atskaitomą PVM (35 laukelis) visai neįtraukiamas, nors deklaruojamas 25 laukelyje. Kadangi visas pirkimo PVM lieka neatskaitomas, šiam kodui nėra jokios eilutės, kuri didžiąją knygą paveiktų ir tuo pačiu galėtų nešti 25 laukelio bruto sumą — variklis (post_document()) praleidžia visą eilutę, kurios faktorius yra nulis, įskaitant jos case reikšmę. Todėl šis pakas 25 laukelio šiam kodui visai nedeklaruoja, o ne deklaruoja klaidingą sumą — žr. docs/international.md, skiltis „From Lithuania“. 35 ir 36 laukeliai (mokėtina suma) nepaveikiami: visa suma teisingai lieka tik sąnaudų sąskaitoje per tax_on_base.', 'S', null, 190, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'fr0600-km1739', null, null, null, null),
  ('LT', 'LT-P-PM', 'Sandoriai, kai PVM išskaito pirkėjas (96 str.)', '{}'::jsonb, 'Statybos darbai, juodųjų ir spalvotųjų metalų atliekos ir laužas — pirkėjas apskaičiuoja pardavimo PVM ir tuo pačiu atskaito pirkimo PVM', 'percent', 21, 'purchase', 'domestic_reverse_charge', date '2015-07-01', null, 'PVMĮ 96 straipsnio 3 ir 4 dalys — pirkėjas apskaičiuotą tiekėjo prekių (paslaugų) vertę ir PVM apskaito mokestinio laikotarpio, kurį gavo PVM sąskaitą faktūrą, deklaracijoje ir tuo pačiu mokestiniu laikotarpiu turi teisę atskaityti apskaičiuotą PVM. Forma FR0600 pirkėjui apmokestinamosios vertės laukelio neskiria — deklaruojama tik apskaičiuota PVM suma (33 laukelis).', 'AE', 'VATEX-EU-AE', 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-REPR', 'Reprezentacinių sąnaudų pirkimas 21%, atskaita 50%', '{}'::jsonb, 'Prekės ir paslaugos, kurių įsigijimo išlaidos priskiriamos prie reprezentacinių sąnaudų pagal pelno mokesčio teisės aktus — atskaitoma pusė pirkimo PVM', 'percent', 21, 'purchase', 'domestic', date '2009-09-01', null, 'FR0600 formos pildymo taisyklės (VA-29), 35 laukelio paaiškinimas — 50 procentų pirkimo ir (arba) importo PVM už reprezentacijai skirtas prekes ir paslaugas, kurių įsigijimo išlaidos pagal pelno mokesčio įstatymą priskiriamos prie reprezentacinių sąnaudų, neįtraukiama į atskaitomą PVM (35 laukelis), nors visa suma deklaruojama 25 laukelyje. Lietuvos Respublikos pelno mokesčio įstatymo 22 straipsnis riboja pačias reprezentacines sąnaudas iki 75 procentų jų sumos, tačiau šis pakas PVM atskaitos ribojimą modeliuoja atskirai nuo pelno mokesčio. Variklis (post_document()) praleidžia visą sąskaitos eilutę, kai jos faktorius yra nulis — todėl 25 laukelio bruto (100 %) sumos, nepriklausomos nuo į didžiąją knygą įtraukiamos sumos, šis pakas gauti negali be antros, apnulintos eilutės, kurios variklis nepalaiko. 25 ir 35 laukeliai čia todėl abu rodo tik atskaitomą pusę (50 %), o ne 25 laukelio buhalterinę bruto sumą — žr. docs/international.md, skiltis „From Lithuania“.', 'S', null, 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'fr0600-km1739', null, null, null, null),
  ('LT', 'LT-P-VABA', 'PVM neapmokestinamas pirkimas', '{}'::jsonb, 'Arve be PVM', 'percent', 0, 'purchase', 'exempt', date '2004-05-01', null, 'PVMĮ 20–32 straipsniai — tiekėjo PVM neapmokestinamas sandoris; pirkėjo gautoje sąskaitoje PVM nenurodomas.', 'E', 'VATEX-EU-132', 200, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-VS-EU-21', 'Paslaugos iš kitos ES valstybės narės PVM mokėtojo, 21%', '{}'::jsonb, 'Atvirkštinis apmokestinimas — pirkėjas apskaičiuoja PVM pagal bendrąją verslo klientui teikiamų paslaugų taisyklę', 'percent', 21, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'PVMĮ 13 straipsnio 2 dalies 1 punktas ir 95 straipsnio 2 dalis — kai paslaugos teikimo vieta yra Lietuva ir paslaugą teikia kitos ES valstybės narės PVM mokėtojas, pirkėjas privalo apskaičiuoti ir sumokėti PVM; 58 straipsnio 1 dalis — apskaičiuota suma yra atskaitoma pirkimo PVM.', 'K', 'VATEX-EU-IC', 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-P-VS-XU-21', 'Paslaugos iš ne ES valstybės asmens, 21%', '{}'::jsonb, 'Pirkėjas apskaičiuoja PVM pagal bendrąją verslo klientui teikiamų paslaugų taisyklę', 'percent', 21, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'PVMĮ 13 straipsnio 2 dalies 1 punktas ir 95 straipsnio 2 dalis — kai paslaugos teikimo vieta yra Lietuva ir paslaugą teikia Europos Sąjungai nepriklausančioje valstybėje įsisteigęs asmuo, pirkėjas privalo apskaičiuoti ir sumokėti PVM; Tarybos direktyvos 2006/112/EB 44 ir 196 straipsniai; 58 straipsnio 1 dalis — apskaičiuota suma yra atskaitoma pirkimo PVM.', null, null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-00-EXP', 'Prekių eksportas', '{}'::jsonb, 'Prekių išgabenimas iš Europos Sąjungos teritorijos, 0 proc. tarifas', 'percent', 0, 'sale', 'export', date '2004-05-01', null, 'PVMĮ 41 straipsnis — prekių eksportas apmokestinamas taikant 0 procentų PVM tarifą.', 'G', 'VATEX-EU-G', 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-00-ICG', 'Prekių tiekimas į ES', '{}'::jsonb, 'Prekių tiekimas kitos ES valstybės narės PVM mokėtojui, 0 proc. tarifas', 'percent', 0, 'sale', 'intracom_goods', date '2004-05-01', null, 'PVMĮ 49 straipsnis — prekių tiekimas kitoje valstybėje narėje įregistruotam PVM mokėtojui apmokestinamas taikant 0 procentų PVM tarifą; Tarybos direktyvos 2006/112/EB 138 straipsnis.', 'K', 'VATEX-EU-IC', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-00-ICS', 'Paslaugų teikimas ES PVM mokėtojui', '{}'::jsonb, 'Paslauga apmokestinama pirkėjo valstybėje narėje pagal bendrąją verslo klientui teikiamų paslaugų taisyklę; PVM apskaičiuoja paslaugos pirkėjas', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'PVMĮ 13 straipsnio 2 dalies 1 punktas — verslo klientui teikiamos paslaugos teikimo vieta yra kliento įsisteigimo vieta; Tarybos direktyvos 2006/112/EB 44 ir 196 straipsniai — paslaugos pirkėjas privalo apskaičiuoti PVM. Sandoris Lietuvoje PVM objektu nelaikomas, todėl apmokestinamoji vertė deklaruojama FR0600 20 laukelyje, o ne 11 ar 19 laukelyje.', 'K', 'VATEX-EU-IC', 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-05', 'Pardavimas 5%', '{}'::jsonb, 'Vaistai, medicinos pagalbos priemonės, techninės pagalbos priemonės neįgaliesiems, spausdinti ir elektroniniai laikraščiai bei žurnalai, nuo 2026-01-01 — spausdintos ir elektroninės knygos bei neperiodiniai informaciniai leidiniai', 'percent', 5, 'sale', 'domestic', date '2026-01-01', null, 'PVMĮ 19 straipsnio 4 ir 5 dalys: vaistams ir kompensuojamosioms medicinos pagalbos priemonėms bei specialiosios medicininės paskirties maisto produktams 5 proc. tarifas taikomas nuo 2004-01-01 (nekompensuojamiesiems receptiniams vaistams — nuo 2017-01-01), asmenų su negalia techninės pagalbos priemonėms ir jų remontui — nuo 2013-01-01, spausdintiems laikraščiams, žurnalams ir kitiems periodiniams leidiniams — nuo 2019-01-01 (elektroniniams — nuo 2021-01-01), o spausdintoms ir elektroninėms knygoms bei neperiodiniams informaciniams leidiniams (įskaitant vadovėlius) — nuo 2026-01-01. Šis kodas modeliuoja dabartinę (nuo 2026-01-01 galiojančią) prekių grupių visumą; ankstesniam laikotarpiui tiksliam kiekvienos grupės atskyrimui reikėtų atskirų kodų, kurių šis pakas nepateikia — žr. README.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-09', 'Pardavimas 9%', '{}'::jsonb, 'Iki 2025-12-31 galiojęs lengvatinis tarifas — šildymas, apgyvendinimas, reguliarus keleivių vežimas, meno ir kultūros renginiai, knygos ir neperiodiniai leidiniai', 'percent', 9, 'sale', 'domestic', date '2009-01-01', date '2025-12-31', 'PVMĮ 19 straipsnio 3 dalis, redakcija galiojusi iki 2025-12-31. Šis vienas kodas apima kelias skirtingas prekių ir paslaugų grupes (šilumos energija, gyvenamųjų patalpų šildymas, apgyvendinimo paslaugos, reguliarus keleivių vežimas, meno ir kultūros renginių lankymas, knygos ir neperiodiniai informaciniai leidiniai), kurios į 9 procentų tarifą buvo įtrauktos ne tuo pačiu metu — tiksli kiekvienos grupės pradinė data šio pako rengimo metu nebuvo patikrinta straipsnis po straipsnio, todėl valid_from žymi tik ankstyviausią patikimai žinomą datą, o ne kiekvienos grupės atskirą įsigaliojimą. Nuo 2026-01-01 šios grupės perskirstytos tarp 21, 12 ir 5 procentų tarifų (žr. LT-S-21, LT-S-12, LT-S-05).', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-12', 'Pardavimas 12%', '{}'::jsonb, 'Apgyvendinimo paslaugos, reguliaraus susisiekimo keleivių vežimas, meno ir kultūros įstaigų bei renginių lankymas', 'percent', 12, 'sale', 'domestic', date '2026-01-01', null, 'PVMĮ 19 straipsnio 3 dalis, redakcija galiojanti nuo 2026-01-01 (Seimo 2025 m. birželio 17 d. įstatymas Nr. XV-287): „Lengvatinis 12 procentų PVM tarifas taikomas: 1) turizmo veiklą reglamentuojančių teisės aktų nustatyta tvarka teikiamoms apgyvendinimo paslaugoms; 2) keleivių vežimo Lietuvos Respublikos susisiekimo ministerijos ar jos įgaliotos institucijos arba savivaldybių nustatytais reguliaraus susisiekimo maršrutais paslaugoms, taip pat šiame punkte nurodytų keleivių bagažo vežimo paslaugoms; 3) visų rūšių meno ir kultūros įstaigų, meno ir kultūros renginių lankymui, kai netaikomos šio Įstatymo 23 straipsnio nuostatos.“ Iki 2025-12-31 šios paslaugos buvo apmokestinamos 9 procentų tarifu (žr. LT-S-09).', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-21', 'Pardavimas 21%', '{}'::jsonb, 'Standartinis tarifas', 'percent', 21, 'sale', 'domestic', date '2009-09-01', null, 'PVMĮ 19 straipsnio 1 dalis — standartinis PVM tarifas yra 21 procentas apmokestinamosios vertės, taikomas nuo 2009-09-01 (anksčiau — 19 procentų).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-PM', 'Sandoriai, kai PVM išskaito pirkėjas (96 str.)', '{}'::jsonb, 'Statybos darbai, turto perleidimas kaip turtinis įnašas ar reorganizavimo atveju, juodųjų ir spalvotųjų metalų atliekos ir laužas — pardavimo PVM apskaičiuoja ir sumoka pirkėjas', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2015-07-01', null, 'PVMĮ 96 straipsnio 1 dalies 3 punktas — statybos darbams (PVMĮ 2 straipsnio 90 dalies prasme) taikoma atvirkštinio apmokestinimo schema nuo 2015-07-01, neterminuotai; 1 dalies 4 punktas — juodųjų ir spalvotųjų metalų atliekoms ir laužui. Pardavėjas apmokestinamąją vertę deklaruoja FR0600 12 laukelyje ir jokios pardavimo PVM sumos nedeklaruoja — ją apskaičiuoja pirkėjas (žr. LT-P-PM).', 'AE', 'VATEX-EU-AE', 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null),
  ('LT', 'LT-S-VABA', 'PVM neapmokestinamas sandoris', '{}'::jsonb, 'PVMĮ IV skyriuje išvardyti neapmokestinami sandoriai (sveikatos priežiūra, švietimas, socialinės paslaugos, draudimas, finansinės paslaugos, nekilnojamojo pagal prigimtį turto nuoma ir kt.)', 'percent', 0, 'sale', 'exempt', date '2004-05-01', null, 'PVMĮ 20–32 straipsniai — PVM neapmokestinami sandoriai. Šio pako auksinis scenarijus naudoja PVMĮ 28 straipsnį (finansinės paslaugos).', 'E', 'VATEX-EU-132', 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvmi', null, null, null, null)
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
    ('LT-P-05', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-05', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-09', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-09', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-12', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-12', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-21', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-21', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-ICG-21', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-ICG-21', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 20),
    ('LT-P-ICG-21', 'invoice', 'tax', -100, '4400', '34', array['34']::text[], 100, 'LT-FR0600', 30),
    ('LT-P-ICG-21', 'credit_note', 'base', 100, null, '21', array['21']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-ICG-21', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 20),
    ('LT-P-ICG-21', 'credit_note', 'tax', -100, '4400', '34', array['34']::text[], -100, 'LT-FR0600', 30),
    ('LT-P-ND', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('LT-P-ND', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('LT-P-PM', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-PM', 'invoice', 'tax', -100, '4400', '33', array['33']::text[], 100, 'LT-FR0600', 20),
    ('LT-P-PM', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-PM', 'credit_note', 'tax', -100, '4400', '33', array['33']::text[], -100, 'LT-FR0600', 20),
    ('LT-P-REPR', 'invoice', 'tax', 50, '2210', '25', array['25', '35']::text[], 50, 'LT-FR0600', 10),
    ('LT-P-REPR', 'invoice', 'tax_on_base', 50, null, null, null, 100, null, 20),
    ('LT-P-REPR', 'credit_note', 'tax', 50, '2210', '25', array['25', '35']::text[], -50, 'LT-FR0600', 10),
    ('LT-P-REPR', 'credit_note', 'tax_on_base', 50, null, null, null, 100, null, 20),
    ('LT-P-VS-EU-21', 'invoice', 'base', 100, null, '23', array['23', '24']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-VS-EU-21', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 20),
    ('LT-P-VS-EU-21', 'invoice', 'tax', -100, '4400', '32', array['32']::text[], 100, 'LT-FR0600', 30),
    ('LT-P-VS-EU-21', 'credit_note', 'base', 100, null, '23', array['23', '24']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-VS-EU-21', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 20),
    ('LT-P-VS-EU-21', 'credit_note', 'tax', -100, '4400', '32', array['32']::text[], -100, 'LT-FR0600', 30),
    ('LT-P-VS-XU-21', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'LT-FR0600', 10),
    ('LT-P-VS-XU-21', 'invoice', 'tax', 100, '2210', '25', array['25', '35']::text[], 100, 'LT-FR0600', 20),
    ('LT-P-VS-XU-21', 'invoice', 'tax', -100, '4400', '32', array['32']::text[], 100, 'LT-FR0600', 30),
    ('LT-P-VS-XU-21', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'LT-FR0600', 10),
    ('LT-P-VS-XU-21', 'credit_note', 'tax', 100, '2210', '25', array['25', '35']::text[], -100, 'LT-FR0600', 20),
    ('LT-P-VS-XU-21', 'credit_note', 'tax', -100, '4400', '32', array['32']::text[], -100, 'LT-FR0600', 30),
    ('LT-S-00-EXP', 'invoice', 'base', 100, null, '17', array['17']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-00-EXP', 'credit_note', 'base', 100, null, '17', array['17']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-00-ICG', 'invoice', 'base', 100, null, '18', array['18']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-00-ICG', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-00-ICS', 'invoice', 'base', 100, null, '20', array['20']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-00-ICS', 'credit_note', 'base', 100, null, '20', array['20']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-05', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-05', 'invoice', 'tax', 100, '4400', '31', array['31']::text[], 100, 'LT-FR0600', 20),
    ('LT-S-05', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-05', 'credit_note', 'tax', 100, '4400', '31', array['31']::text[], -100, 'LT-FR0600', 20),
    ('LT-S-09', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-09', 'invoice', 'tax', 100, '4400', '30', array['30']::text[], 100, 'LT-FR0600', 20),
    ('LT-S-09', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-09', 'credit_note', 'tax', 100, '4400', '30', array['30']::text[], -100, 'LT-FR0600', 20),
    ('LT-S-12', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-12', 'invoice', 'tax', 100, '4400', '29A', array['29A']::text[], 100, 'LT-FR0600', 20),
    ('LT-S-12', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-12', 'credit_note', 'tax', 100, '4400', '29A', array['29A']::text[], -100, 'LT-FR0600', 20),
    ('LT-S-21', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-21', 'invoice', 'tax', 100, '4400', '29', array['29']::text[], 100, 'LT-FR0600', 20),
    ('LT-S-21', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-21', 'credit_note', 'tax', 100, '4400', '29', array['29']::text[], -100, 'LT-FR0600', 20),
    ('LT-S-PM', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-PM', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'LT-FR0600', 10),
    ('LT-S-VABA', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'LT-FR0600', 10),
    ('LT-S-VABA', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'LT-FR0600', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'LT' and t.code = v.tax_code
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
  ('LT', 'LT-FR0600', 'PVM deklaracija (forma FR0600)', array['month', 'quarter', 'half_year']::declaration_period[], null, date '2026-01-01', null, 'Valstybinės mokesčių inspekcijos prie Lietuvos Respublikos finansų ministerijos viršininko 2004 m. kovo 1 d. įsakymas Nr. VA-29 „Dėl Pridėtinės vertės mokesčio deklaracijos ir kitų su šiuo mokesčiu susijusių formų bei jų užpildymo taisyklių patvirtinimo“ patvirtina formą FR0600 ir jos pildymo taisykles. Nuo 2026-01-01 forma papildyta 29A laukeliu lengvatiniam 12 proc. PVM tarifui, patvirtinus VMI viršininko 2025 m. gruodžio 22 d. įsakymu Nr. VA-129. Šis pakas kodus laukelių žymėms perima tiksliai tokius, kokie spausdinami formoje (pvz. „29A“); jokio ženklo transliteravimo, priešingai nei Estijos KMD formoje, nereikia.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'VMI viršininko 2004 m. kovo 1 d. įsakymu Nr. VA-29 patvirtintos PVM deklaracijos ir kitų su šiuo mokesčiu susijusių formų užpildymo taisyklės: „PVM mokėtojai, kurių mokestinis laikotarpis yra kalendorinis mėnuo, mėnesio PVM deklaraciją turi pateikti iki kito mėnesio 25 dienos, tie, kurių mokestinis laikotarpis kalendorinis ketvirtis – iki kito ketvirčio pirmo mėnesio 25 dienos, o tie, kurių mokestinis laikotarpis yra kalendorinis pusmetis, pusmečio PVM deklaraciją – iki kito pusmečio pirmo mėnesio 25 dienos.“ Ta pati 25-oji diena galioja visoms trims deklaravimo trukmėms, todėl viena taisyklė apima visą period sąrašą. Kuris mokestinis laikotarpis konkrečiam PVM mokėtojui taikomas (paprastai kalendorinis mėnuo juridiniam asmeniui, galimybė rinktis ketvirtį įmonei, kurios apyvarta praėjusiais metais neviršijo 300 000 eurų) nustato mokesčių administratorius pagal PVM mokėtojo statusą ir apyvartą, o ne vienas visiems bendras įstatymo atsakymas — todėl šis pakas period_default nedeklaruoja, panašiai kaip Liuksemburgo pakas savo PVM deklaracijai.', null, null)
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
  ('LT', 'LT-FR0600', '11', 'base', 'PVM apmokestinami sandoriai', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 11 laukelis — PVM mokėtojas nurodo apmokestinamąją vertę tų per mokestinį laikotarpį patiektų prekių ir suteiktų paslaugų, kurių tiekimo (teikimo) vieta laikoma Lietuva ir kurios apmokestinamos taikant standartinį bei lengvatinius PVM tarifus, išskyrus 12, 14, 15 ir 16 laukeliuose deklaruotinas sumas. Šis pakas laukelį naudoja tik standartinio, 12, 9 (istorinio) ir 5 procentų tarifų bazei; savų poreikių suvartojimas (14), pasigaminimas (15) ir maržos schema (16) šiame pake nemodeliuojami.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '12', 'base', 'PVM apmokestinami sandoriai, kai PVM išskaito pirkėjas (96 str. nustatytais atvejais)', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 12 laukelis — apmokestinamoji vertė tų patiektų prekių (suteiktų paslaugų), kurių pirkimo PVM pagal PVMĮ 96 straipsnio nuostatas privalo išskaityti ir sumokėti pirkėjas (statybos darbai, nekilnojamojo turto ar juodųjų ir spalvotųjų metalų atliekų ir laužo tiekimas). Pardavėjas šį laukelį pildo vietoje 11 laukelio ir prie sumos jokios pardavimo PVM sumos nedeklaruoja.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '13', 'base', 'PVM neapmokestinami sandoriai', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 13 laukelis — apmokestinamoji vertė patiektų PVM neapmokestinamų prekių ir suteiktų paslaugų, išvardytų PVMĮ 20–33 straipsniuose, bei neapmokestinamo investicinio aukso ir su juo susijusių atstovavimo paslaugų, nurodytų PVMĮ 112 straipsnio 1 ir 2 dalyse.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '14', 'base', 'Suvartojimas privatiems poreikiams', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 14 laukelis — PVM mokėtojo privatiems poreikiams sunaudotų prekių ir (ar) paslaugų apmokestinamoji vertė (PVMĮ 5 straipsnio 4 dalis). Šis pakas šio laukelio nenaudoja: golden scenarijuje savų poreikių suvartojimo sandorio nėra.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '15', 'base', 'Ilgalaikio materialiojo turto pasigaminimas', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 15 laukelis — PVMĮ 6 straipsnyje nurodytas PVM mokėtojo nuosavybės teise priklausančio pastato (statinio) esminio pagerinimo ar ilgalaikio materialiojo turto pasigaminimo apmokestinamoji vertė. Šis pakas šio laukelio nenaudoja.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '16', 'base', 'Sandorių, kuriems taikoma speciali apmokestinimo schema, marža', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 16 laukelis — kelionių organizatorių ir naudotų prekių, meno kūrinių bei kolekcinių ir antikvarinių daiktų prekybos maržos schemos apskaičiuota marža. Šis pakas maržos schemos nemodeliuoja.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '17', 'base', 'Prekių eksportas', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 17 laukelis — per mokestinį laikotarpį patiektų ir iš Europos Sąjungos teritorijos išgabentų (eksportuotų) prekių apmokestinamoji vertė (PVMĮ 41 straipsnis).', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '18', 'base', 'ES PVM mokėtojams patiektos prekės', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 18 laukelis — kitų Europos Sąjungos valstybių narių PVM mokėtojams patiektų ir iš Lietuvos išgabentų prekių apmokestinamoji vertė (PVMĮ 49 straipsnis).', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '19', 'base', 'Kiti PVM apmokestinami sandoriai (0 proc.)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 19 laukelis — kitų, nei 17 ir 18 laukeliuose nurodytų, Lietuvos teritorijoje patiektų prekių ir suteiktų paslaugų, apmokestinamų taikant 0 proc. PVM tarifą, apmokestinamoji vertė (tarptautinis vežimas, laivai, orlaiviai, diplomatinės ir konsulinės įstaigos ir kt., PVMĮ VI skyrius). Šis pakas šio laukelio nenaudoja.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '20', 'base', 'Už Lietuvos ribų įvykę sandoriai (ne PVM objektas Lietuvoje)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 20 laukelis — PVM mokėtojo už Lietuvos teritorijos ribų patiektų prekių ir suteiktų paslaugų, kurių pirkimo (importo) PVM pagal PVMĮ 58 straipsnio 1 dalies 2 punkto nuostatas gali būti atskaitomas, apmokestinamoji vertė — įskaitant paslaugas, kurių teikimo vieta pagal PVMĮ 13 straipsnio 2 dalies 1 punkto bendrąją taisyklę yra paslaugos pirkėjo — kito ES valstybės narės PVM mokėtojo — įsisteigimo vieta.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '21', 'base', 'Iš ES įsigytos prekės', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 21 laukelis — iš kitos Europos Sąjungos valstybės narės PVM mokėtojo įsigytų prekių, kurių įsigijimas laikomas įvykusiu Lietuvoje, apmokestinamoji vertė (PVMĮ 8 straipsnis).', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '22', 'base', 'Iš ES įsigytos prekės trikampei prekybai', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 22 laukelis — trikampėje prekyboje tarpininkaujančio PVM mokėtojo iš vienos ES valstybės narės PVM mokėtojo įsigytų prekių, kurios iš karto buvo patiektos kitoje ES valstybėje narėje esančiam PVM mokėtojui, apmokestinamoji vertė. Šis pakas trikampės prekybos nemodeliuoja.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '23', 'base', 'Iš užsienio valstybių įsigytos paslaugos', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 23 laukelis — iš užsienio asmenų įsigytų paslaugų, kurių teikimo vieta laikoma Lietuvos teritorija ir kurių pardavimo PVM pagal PVMĮ 95 straipsnio nuostatas privalo apskaičiuoti ir sumokėti paslaugų pirkėjas — PVM mokėtojas, apmokestinamoji vertė.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '24', 'base', 'Iš jų: įsigytos iš ES PVM mokėtojų', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 24 laukelis — 23 laukelyje deklaruotos apmokestinamosios vertės dalis, tenkanti paslaugoms, įsigytoms iš kitų ES valstybių narių PVM mokėtojų. Informacinis laukelis, jau įtrauktas į 23 laukelio sumą.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '25', 'tax', 'Įsigytų prekių ir paslaugų pirkimo PVM', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 25 laukelis — PVM mokėtojo įsigytų prekių ir paslaugų pirkimo PVM suma, nurodyta pirkimo dokumentuose, prieš taikant proporcinio PVM atskaitos procento ar konkrečių straipsnių (pvz. reprezentacinėms sąnaudoms, lengvajam automobiliui) ribojimus. Importo PVM (26, 27 laukeliai) į šį laukelį netraukiamas.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '26', 'tax', 'Sumokėta importo PVM', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 26 laukelis — nuo importuojamų prekių apmokestinamosios vertės apskaičiuota ir muitinei sumokėta (ar įskaityta) importo PVM suma, išskyrus atvejus, kai importo PVM sumokėjimo kontrolę vykdo VMI. Šis pakas importo neturi savo golden scenarijuje.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '27', 'tax', 'Importo PVM, kurio įskaitymą kontroliuoja VMI', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 27 laukelis — importo PVM suma, kurios sumokėjimą (įskaitymą) kontroliuoja VMI, o ne muitinė. Šis pakas šio laukelio nenaudoja.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '28', 'tax', 'Kalendorinių metų proporcinis PVM atskaitos procentas', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 28 laukelis — mišrią (apmokestinamąją ir neapmokestinamąją) veiklą vykdančio PVM mokėtojo kalendoriniams metams taikytinas, pagal PVMĮ 60 straipsnio 1 dalies „pajamų“ kriterijų apskaičiuotas PVM atskaitos procentas. Rankomis įvedamas dydis, ne iš apyvartos susumuojamas; šis pakas mišrios veiklos proporcijos nemodeliuoja, todėl niekas šio laukelio nepildo.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '29', 'tax', 'Standartinio tarifo pardavimo PVM', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 29 laukelis — nuo 11 (ir prireikus 14, 15, 16) laukeliuose deklaruotos, standartiniu PVM tarifu (PVMĮ 19 straipsnio 1 dalis) apmokestinamos apmokestinamosios vertės apskaičiuota pardavimo PVM suma.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '29A', 'tax', 'Lengvatinio 12 proc. tarifo pardavimo PVM', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 29A laukelis, įtrauktas nuo 2026-01-01 VMI viršininko 2025 m. gruodžio 22 d. įsakymu Nr. VA-129 — nuo 11 laukelyje deklaruotos, lengvatiniu 12 proc. PVM tarifu (PVMĮ 19 straipsnio 3 dalis, galiojanti nuo 2026-01-01: apgyvendinimo paslaugos, reguliaraus susisiekimo keleivių vežimas, meno ir kultūros įstaigų bei renginių lankymas) apmokestinamos apmokestinamosios vertės apskaičiuota pardavimo PVM suma.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '30', 'tax', '9 proc. pardavimo PVM', '{}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 30 laukelis — nuo 11 laukelyje deklaruotos, lengvatiniu 9 proc. PVM tarifu apmokestinamos apmokestinamosios vertės apskaičiuota pardavimo PVM suma. Iki 2025-12-31 galiojusi PVMĮ 19 straipsnio 3 dalies redakcija šį tarifą taikė šildymui, knygoms ir neperiodiniams leidiniams, apgyvendinimui, reguliaraus susisiekimo keleivių vežimui bei meno ir kultūros renginių lankymui; nuo 2026-01-01 šios prekių ir paslaugų grupės perkeltos į 21, 5 arba 12 proc. tarifus (žr. LT-S-12, LT-S-05 legal_reference), todėl laukelis nuo tos datos naujų sandorių nebeturėtų kaupti — jis paliktas formoje ir šiame pake ankstesnių laikotarpių sandoriams.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '31', 'tax', '5 proc. pardavimo PVM', '{}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 31 laukelis — nuo 11 laukelyje deklaruotos, lengvatiniu 5 proc. PVM tarifu (PVMĮ 19 straipsnio 4 ir 5 dalys) apmokestinamos apmokestinamosios vertės apskaičiuota pardavimo PVM suma.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '32', 'tax', 'Pardavimo PVM (95 str. nustatytais atvejais)', '{}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 32 laukelis — prekių (paslaugų) pirkėjo „atvirkštiniu“ būdu apskaičiuota pardavimo PVM suma PVMĮ 95 straipsnyje nustatytais atvejais (paslaugos iš užsienio asmenų, 23 laukelis). Jei įsigytos paslaugos skirtos apmokestinamajai veiklai, ta pati suma įtraukiama į 25 ir 35 laukelius kaip atskaitomas PVM.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '33', 'tax', 'Pardavimo PVM (96 str. nustatytais atvejais)', '{}'::jsonb, 240, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 33 laukelis — prekių (paslaugų) pirkėjo apskaičiuota pardavimo PVM suma PVMĮ 96 straipsnyje nustatytais atvejais (statybos darbai, turto perleidimas kaip turtinis įnašas ar reorganizavimo atveju, juodųjų ir spalvotųjų metalų atliekos ir laužas, 12 laukelis). Jei įsigyti darbai, prekės ar paslaugos skirti apmokestinamajai veiklai, ta pati suma įtraukiama į 25 ir 35 laukelius kaip atskaitomas PVM.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '34', 'tax', 'Iš ES įsigytų prekių pardavimo PVM', '{}'::jsonb, 250, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 34 laukelis — nuo 21 laukelyje deklaruotos apmokestinamosios vertės, taikant tokį PVM tarifą, koks būtų taikomas Lietuvoje tiekiamoms analogiškoms prekėms, pirkėjo apskaičiuota pardavimo PVM suma. Jei prekės skirtos apmokestinamajai veiklai, ta pati suma įtraukiama į 25 ir 35 laukelius kaip atskaitomas PVM.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '35', 'tax', 'Atskaitomas PVM', '{}'::jsonb, 260, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'FR0600 forma, 35 laukelis — PVM mokėtojo per mokestinį laikotarpį atskaitoma įsigytų (importuotų) prekių ir paslaugų pirkimo (importo) PVM suma: jei vykdoma vien apmokestinama veikla, visa 25, 26 ir 27 laukeliuose deklaruota suma; jei veikla mišri, jos dalis, apskaičiuota taikant 28 laukelio proporcinį procentą. PVMĮ 30 straipsnio 1 dalis, 62 straipsnio 2–3 dalys ir 30 straipsnio 3 dalis riboja ar visai atima atskaitos teisę reprezentacinėms sąnaudoms (50 proc. atskaitoma) ir tam tikroms pramogoms bei ne visai ūkinei veiklai skirtiems lengviesiems automobiliams skirtoms prekėms ir paslaugoms (neatskaitoma) — tokios sumos deklaruojamos 25 laukelyje, bet į 35 laukelį įtraukiamos tik ta dalimi, kuri lieka atskaitoma.', 'fr0600-km1739'),
  ('LT', 'LT-FR0600', '36', 'total', 'Mokėtinas į biudžetą arba grąžintinas iš biudžeto (-) PVM', '{}'::jsonb, 270, null, array['29', '29A', '30', '31', '32', '33', '34']::text[], array['35']::text[], null, null, false, false, null, 'FR0600 forma, 36 laukelis — apskaičiuojamas automatiškai kaip 29+29A+30+31+32+33+34 laukelių suma, atėmus 35 laukelį. Jei rezultatas teigiamas, tai mokėtina į biudžetą suma, mokėtina iki deklaracijos pateikimo termino pabaigos; jei neigiamas, tai iš biudžeto grąžintinas PVM skirtumas, grąžinamas PVMĮ 91 straipsnyje nustatyta tvarka. Skirtingai nei Estijos KMD forma (atskiri 12 ir 13 laukeliai), Lietuvos forma abi kryptis rašo ženklu tame pačiame laukelyje, todėl šis pakas jam netaiko floor_zero.', 'fr0600-km1739')
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
  ('LT-VAS-BS', 'LT', 'default', 'Balansas', 'balance_sheet', 'LT-GAAP', date '2016-01-01', null, 'Verslo apskaitos standartas VAS 2 „Balansas“, nustatantis balanso sudarymo tvarką ir jo formas, taikomas finansinėms ataskaitoms, sudaromoms už laikotarpius, prasidedančius 2016-01-01 ir vėliau, pagal Direktyvos 2013/34/ES perkėlimą. Šio pako rengimo metu VAS 2 pilno teksto (avnt.lt) tiesiogiai patikrinti nepavyko (serveris grąžino 403 klaidą automatizuotam užklausimui) — eilučių pavadinimai ir grupavimas šiame faile atkurti pagal bendrą Baltijos šalių apskaitos praktiką (analogiškai Estijos RPS lisa 1 schema) ir Direktyvos 2013/34/ES balanso schemų sandarą, o ne pažodžiui perrašyti iš VAS 2 priedo. Rekomenduojama, kad vietos buhalteris eilutes sutikrintų su oficialiu VAS 2 priedo tekstu.', 'avnt-planas'),
  ('LT-VAS-IS', 'LT', 'default', 'Pelno (nuostolių) ataskaita, 1-oji schema (pagal sąnaudų pobūdį)', 'income_statement', 'LT-GAAP', date '2016-01-01', null, 'Verslo apskaitos standartas VAS 3 „Pelno (nuostolių) ataskaita“ numato dvi pelno (nuostolių) ataskaitos schemas: 1-ąją, kurioje sąnaudos grupuojamos pagal pobūdį, ir 2-ąją, kurioje sąnaudos grupuojamos pagal funkciją. Šis pakas naudoja 1-ąją schemą kaip labiau paplitusią mažų ir vidutinių įmonių praktikoje, analogiškai Estijos RTJ 2 punkto 22 pastabai apie skemos 1 paprastumą. Kaip ir LT-VAS-BS atveju, VAS 3 pilno teksto tiesiogiai patikrinti nepavyko (403 klaida avnt.lt), todėl eilučių pavadinimai ir grupavimas yra šio pako autoriaus atkurti pagal bendrą praktiką, o ne pažodinė VAS 3 priedo kopija — rekomenduojama vietos buhalterio patikra.', 'avnt-planas')
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
  ('LT-VAS-BS', '1', null, 'Ilgalaikis turtas', '{}'::jsonb, 10, 1, true, array['1.1', '1.2', '1.3']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '1.1', '1', 'Nematerialusis turtas', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '1.2', '1', 'Materialusis turtas', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '1.3', '1', 'Finansinis turtas ir kitos ilgalaikės gautinos sumos', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '2', null, 'Trumpalaikis turtas', '{}'::jsonb, 50, 1, true, array['2.1', '2.2', '2.3', '2.4']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '2.1', '2', 'Atsargos', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '2.2', '2', 'Per vienus metus gautinos sumos', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '2.3', '2', 'Trumpalaikės investicijos', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '2.4', '2', 'Pinigai ir pinigų ekvivalentai', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '3', null, 'Turtas iš viso', '{}'::jsonb, 100, 1, true, array['1', '2']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '4', null, 'Nuosavas kapitalas', '{}'::jsonb, 110, 1, true, array['4.1', '4.2', '4.3', '4.4']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '4.1', '4', 'Kapitalas', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '4.2', '4', 'Perkainojimo rezervas', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '4.3', '4', 'Rezervai', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '4.4', '4', 'Nepaskirstytasis pelnas (nuostoliai)', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '5', null, 'Po vienų metų mokėtinos sumos ir ilgalaikiai įsipareigojimai', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '6', null, 'Per vienus metus mokėtinos sumos ir trumpalaikiai įsipareigojimai', '{}'::jsonb, 170, 1, true, array['6.1', '6.2', '6.3', '6.4']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '6.1', '6', 'Finansiniai įsipareigojimai', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '6.2', '6', 'Skolos tiekėjams', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '6.3', '6', 'Su darbo santykiais ir mokesčiais susiję įsipareigojimai', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '6.4', '6', 'Kitos mokėtinos sumos ir įsipareigojimai', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '7', null, 'Mokėtinos sumos ir įsipareigojimai iš viso', '{}'::jsonb, 220, 1, true, array['5', '6']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-BS', '8', null, 'Nuosavas kapitalas ir įsipareigojimai iš viso', '{}'::jsonb, 230, 1, true, array['4', '7']::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '1', null, 'Pardavimo pajamos', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '2', null, 'Kitos veiklos pajamos', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '3', null, 'Parduotų prekių, žaliavų ir paslaugų savikaina', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '4', null, 'Veiklos sąnaudos', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '5', null, 'Darbo užmokesčio ir socialinio draudimo sąnaudos', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '6', null, 'Ilgalaikio turto nusidėvėjimo ir amortizacijos sąnaudos', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '7', null, 'Kitos veiklos sąnaudos', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '8', null, 'Veiklos pelnas (nuostoliai)', '{}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('LT-VAS-IS', '9', null, 'Finansinės ir investicinės veiklos pajamos', '{}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '10', null, 'Finansinės ir investicinės veiklos sąnaudos', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '11', null, 'Pelnas (nuostoliai) prieš apmokestinimą', '{}'::jsonb, 110, 1, true, array['8', '9']::text[], array['10']::text[], null, null, null),
  ('LT-VAS-IS', '12', null, 'Pelno mokesčio sąnaudos', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LT-VAS-IS', '13', null, 'Grynasis pelnas (nuostoliai)', '{}'::jsonb, 130, 1, true, array['11']::text[], array['12']::text[], null, null, null)
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
    ('LT-VAS-BS', '1.1', 10, 'code_range', '1010', '1049', null, 'any'),
    ('LT-VAS-BS', '1.2', 10, 'code_range', '1100', '1199', null, 'any'),
    ('LT-VAS-BS', '1.3', 10, 'code_range', '1200', '1399', null, 'any'),
    ('LT-VAS-BS', '2.1', 10, 'code_range', '2000', '2049', null, 'any'),
    ('LT-VAS-BS', '2.2', 10, 'code_range', '2100', '2299', null, 'any'),
    ('LT-VAS-BS', '2.3', 10, 'code_range', '2300', '2399', null, 'any'),
    ('LT-VAS-BS', '2.4', 10, 'code_range', '2400', '2499', null, 'any'),
    ('LT-VAS-BS', '4.1', 10, 'code_range', '3000', '3099', null, 'any'),
    ('LT-VAS-BS', '4.2', 10, 'code_range', '3100', '3199', null, 'any'),
    ('LT-VAS-BS', '4.3', 10, 'code_range', '3200', '3299', null, 'any'),
    ('LT-VAS-BS', '4.4', 10, 'code_range', '3300', '3399', null, 'any'),
    ('LT-VAS-BS', '5', 10, 'code_range', '4000', '4099', null, 'any'),
    ('LT-VAS-BS', '6.1', 10, 'code_range', '4100', '4199', null, 'any'),
    ('LT-VAS-BS', '6.2', 10, 'code_range', '4200', '4299', null, 'any'),
    ('LT-VAS-BS', '6.3', 10, 'code_range', '4300', '4499', null, 'any'),
    ('LT-VAS-BS', '6.4', 10, 'code_range', '4500', '4599', null, 'any'),
    ('LT-VAS-IS', '1', 10, 'code_range', '5000', '5099', null, 'any'),
    ('LT-VAS-IS', '2', 10, 'code_range', '5100', '5199', null, 'any'),
    ('LT-VAS-IS', '3', 10, 'code_range', '6000', '6099', null, 'any'),
    ('LT-VAS-IS', '4', 10, 'code_range', '6100', '6299', null, 'any'),
    ('LT-VAS-IS', '5', 10, 'code_range', '6400', '6499', null, 'any'),
    ('LT-VAS-IS', '6', 10, 'code_range', '6600', '6699', null, 'any'),
    ('LT-VAS-IS', '7', 10, 'code_range', '6700', '6799', null, 'any'),
    ('LT-VAS-IS', '9', 10, 'code_range', '5800', '5899', null, 'any'),
    ('LT-VAS-IS', '10', 10, 'code_range', '6800', '6899', null, 'any'),
    ('LT-VAS-IS', '12', 10, 'code_range', '6900', '6999', null, 'any')
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
  ('LT', 'Lietuva', '{}'::jsonb, array['lt']::text[], 'EUR', '2100', '4200', '4510', '6830', '3300', '5000', '6000', '2410', '2400', 'PRD', 'PRK', 'BEN', 'lt', 'result_accounts', '3310', '3310', null, 'PRA', 'half_up', default, '5820', '6810', null, null, null, null, '4430', '2200', null, null)
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
  number_format                 = '{CODE}-{NNNN}',
  legal_payment_days            = 30,
  late_payment_reference        = 'Lietuvos Respublikos mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymo 2 straipsnio 5 dalis — pavėluoto mokėjimo palūkanų norma yra 8 procentiniais punktais padidinta vėliausiai pagrindinei Europos centrinio banko refinansavimo operacijai taikoma fiksuotoji palūkanų norma. Kreditorius, be palūkanų, turi teisę be atskiro įspėjimo reikalauti iš skolininko 40 eurų dydžio išieškojimo išlaidų kompensacijos.',
  numbering_legal_reference     = 'PVMĮ 80 straipsnio 1 dalies 2 punktas — PVM sąskaitos faktūros numeris turi būti sudaromas didėjančia seka ir turi būti paremtas viena ar daugiau serijų, o skirtingose PVM sąskaitose faktūrose negali būti nurodomas tas pats numeris. Įstatymas reikalauja didėjančios sekos, bet nereikalauja nei ištisinio (be spragų) numeravimo, nei kasmetinio numerio atkūrimo iš naujo, todėl numbering yra sequential, o ne gapless_per_year.',
  numbering_source_key          = 'pvmi',
  payment_terms_legal_reference = 'Mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymo 4 straipsnio 2 dalis — jei sutartyje mokėjimo terminas nenustatytas, mokėjimas turi būti atliktas per 30 kalendorinių dienų nuo sąskaitos faktūros gavimo dienos arba nuo prekių ar paslaugų gavimo dienos, jei sąskaitos gavimo diena neaiški. 4 straipsnio 1 dalis leidžia sutartyje nustatyti ilgesnį, bet ne ilgesnį kaip 60 kalendorinių dienų terminą, nebent aiškiai susitarta kitaip ir tai nėra nesąžininga kreditoriaus atžvilgiu.',
  payment_terms_source_key      = 'velavimo-prevencija',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'PVMĮ 14 straipsnio 1 ir 2 dalys — prievolė apskaičiuoti PVM atsiranda PVM sąskaitos faktūros išrašymo momentu; jei sąskaita faktūra neišrašoma, prievolė atsiranda anksčiausią iš dviejų momentų: prekių patiekimo ar paslaugos suteikimo, arba atlygio (ar jo dalies) gavimo. Uždaras šio pako naudojamas žodynas neturi reikšmės, kuri tiksliai perteiktų „sąskaita faktūra yra taisyklė, o anksčiausias iš patiekimo ar apmokėjimo — tik jos nebuvimo atveju“: invoice_date yra artimiausias žodis, nes praktikoje PVM mokėtojas beveik visada išrašo sąskaitą faktūrą (80 straipsnis reikalauja ją išrašyti), o antroji šaka lieka liekamoji. Šis socle''o žodyno spragas žymima docs/international.md skiltyje „From Lithuania“.',
  tax_point_source_key          = 'pvmi',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Viešųjų pirkimų įstatymo 22 straipsnio 3 dalis ir Finansinės apskaitos įstatymo 6 straipsnio 4 dalis — perkančiosioms organizacijoms vykdant pirkimo sutartis privaloma priimti ir apdoroti elektronines sąskaitas faktūras, atitinkančias Europos elektroninių sąskaitų faktūrų standartą (EN 16931), teikiamas per informacinę sistemą „E. sąskaita“ (nuo 2024-09-01 pakeistą SABIS platforma), o standarto neatitinkančias elektronines sąskaitas — tik per šią sistemą. Tai yra pareiga viešojo pirkimo tiekėjui, o ne bendra pareiga tarp dviejų įmonių, todėl obligation lieka none: jokio bendro B2B mandato Lietuvoje šio pako rengimo dieną (2026-09-25) nerasta nei įstatyme, nei paskelbtame teisės akto projekte. profile peppol-bis-3 aprašo formatą, kuriuo SABIS faktiškai keičiasi sąskaitomis (Peppol BIS Billing 3.0, atitinkantis EN 16931), o ne bendrą įmonių tarpusavio pareigą. party_scheme ir vat_scheme lieka tušti: šio pako rengimo metu nepatvirtinta, kad SABIS naudoja ISO 6523 keturženklį schemos identifikatorių Peppol tinkle analogišką Estijos ar Lenkijos pakams — žr. docs/international.md, skiltis „From Lithuania“.',
  einvoice_source_key           = 'vpi',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'LT';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('LT', 'reverse_charge', 'reverse_charge', 'Pardavimo PVM apskaičiuoja ir sumoka pirkėjas — PVMĮ 96 straipsnis.', '{}'::jsonb, 10, date '1970-01-01', null, 'PVMĮ 80 straipsnio 1 dalies 12 punktas — kai prekių ar paslaugų pirkėjas turi prievolę apskaičiuoti PVM, PVM sąskaitoje faktūroje turi būti nuoroda į šio įstatymo nuostatą arba Tarybos direktyvos 2006/112/EB atitinkamą straipsnį, arba kitą nuorodą, kad prekių tiekimui ar paslaugų teikimui taikoma atvirkštinio apmokestinimo schema.'),
  ('LT', 'intracom_goods', 'intra_eu_goods', 'Prekių tiekimas į kitą Europos Sąjungos valstybę narę, neapmokestinamas PVM 0 proc. tarifu — PVMĮ 49 straipsnis; Tarybos direktyvos 2006/112/EB 138 straipsnis.', '{}'::jsonb, 20, date '1970-01-01', null, 'PVMĮ 80 straipsnio 1 dalies 11 punktas — kai prekių tiekimas neapmokestinamas PVM, PVM sąskaitoje faktūroje turi būti nuoroda į šio įstatymo nuostatą arba Tarybos direktyvos 2006/112/EB atitinkamą straipsnį, kuriais remiantis toks prekių tiekimas ar paslaugų teikimas neapmokestinamas PVM.'),
  ('LT', 'intracom_services', 'intra_eu_services', 'Paslauga apmokestinama pirkėjo valstybėje narėje, PVM apskaičiuoja paslaugos pirkėjas — Tarybos direktyvos 2006/112/EB 44 ir 196 straipsniai.', '{}'::jsonb, 30, date '1970-01-01', null, 'PVMĮ 80 straipsnio 1 dalies 12 punktas kartu su 13 straipsnio 2 dalimi — kai paslaugos teikimo vieta pagal bendrąją verslo klientui teikiamų paslaugų taisyklę yra ne Lietuva, o paslaugos pirkėjas privalo apskaičiuoti PVM.'),
  ('LT', 'exempt', 'exempt', 'PVM neapmokestinama — PVMĮ IV skyrius.', '{}'::jsonb, 40, date '1970-01-01', null, 'PVMĮ 80 straipsnio 1 dalies 11 punktas — kai prekių tiekimas ar paslaugų teikimas PVM neapmokestinamas, būtina nuoroda į konkrečią šio įstatymo nuostatą.'),
  ('LT', 'late_payment', 'late_payment', 'Pavėluoto mokėjimo atveju taikomos Lietuvos Respublikos mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymo 2 straipsnio 5 dalyje nustatytos palūkanos (ECB pagrindinės refinansavimo operacijos norma + 8 procentiniai punktai) ir 40 eurų išieškojimo išlaidų kompensacija.', '{}'::jsonb, 50, date '1970-01-01', null, 'Mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymo 2 straipsnio 5 dalis — mentioninė nuoroda skirta informuoti, ji nėra sąskaitoje privaloma įstatymo tekste nurodyta formuluotė.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
