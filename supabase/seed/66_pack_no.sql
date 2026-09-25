-- Ekwo OS — Norge: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/no at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build no`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Lov om merverdiavgift (merverdiavgiftsloven) (Lovdata (konsolidert lovtekst, LOV-2009-06-19-58))
--     https://lovdata.no/lov/2009-06-19-58
--   Stortingsvedtak om merverdiavgift for 2026, vedtatt 18. desember 2025 (Lovdata / Stortinget)
--     https://lovdata.no/dokument/STV/forskrift/2025-12-18-2752
--   Forskrift til skatteforvaltningsloven (skatteforvaltningsforskriften) (Lovdata (FOR-2016-11-23-1360))
--     https://lovdata.no/dokument/SF/forskrift/2016-11-23-1360
--   Lov om bokføring (bokføringsloven) (Lovdata (LOV-2004-11-19-73))
--     https://lovdata.no/lov/2004-11-19-73
--   Forskrift om bokføring (bokføringsforskriften) (Lovdata (FOR-2004-12-01-1558))
--     https://lovdata.no/dokument/SF/forskrift/2004-12-01-1558
--   Lov om årsregnskap m.v. (regnskapsloven) (Lovdata (LOV-1998-07-17-56))
--     https://lovdata.no/lov/1998-07-17-56
--   Norsk RegnskapsStandard 8 — God regnskapsskikk for små foretak (januar 2022) (Norsk RegnskapsStiftelse)
--     https://www.regnskapsstiftelsen.no/wp-content/uploads/2021/10/2022-01-NRS-8-God-regnskapsskikk-for-sma-foretak-jan-2022.pdf
--   Lov om renter ved forsinket betaling m.m. (forsinkelsesrenteloven) (Lovdata (LOV-1976-12-17-100))
--     https://lovdata.no/lov/1976-12-17-100
--   Forsinkelsesrente og standardkompensasjon for inndrivelseskostnader fra 1. juli 2026 (Finanstilsynet)
--     https://www.finanstilsynet.no/nyhetsarkiv/nyheter/2026/forsinkelsesrente-og-standardkompensasjon-for-inndrivelseskostnader-fra-1.-juli-2026
--   Forskrift om elektronisk faktura i offentlige anskaffelser (Lovdata (FOR-2019-04-01-444))
--     https://lovdata.no/dokument/SF/forskrift/2019-04-01-444
--   Standard Tax Codes — Norwegian SAF-T Financial, kodeliste for merverdiavgiftskoder (Skatteetaten (GitHub-repositoriet Skatteetaten/saf-t))
--     https://github.com/Skatteetaten/saf-t/blob/master/Standard%20Tax%20Codes/CSV/Standard_Tax_Codes.csv
--   SAF-T Financial — dokumentasjon og terskelverdi for elektronisk tilgjengelighet (Skatteetaten)
--     https://www.skatteetaten.no/en/business-and-organisation/start-and-run/best-practices-accounting-and-cash-register-systems/saf-t-financial/
--   Mva-meldingen — informasjonsmodell (kodebasert skjema siden 2022) (Skatteetaten (GitHub-repositoriet Skatteetaten/mva-meldingen))
--     https://skatteetaten.github.io/mva-meldingen/mvameldingen/informasjonsmodell/
--   NS 4102:2023 Kontoplan for regnskap (Standard Norge)
--     https://www.standard.no/fagomrader/kontoplan-for-regnskap/
--   Mva-melding — lever mva-meldingen (via Altinn) (Skatteetaten)
--     https://www.skatteetaten.no/bedrift-og-organisasjon/avgifter/mva/mva-melding/
--   Peppol BIS Billing 3.0 — code list ICD (ISO 6523), entry 0192 (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/ICD/
--   UNCL5305 — code list for VAT category codes (BT-118, BT-151), subset published for EN 16931 (OpenPEPPOL — the list itself is published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('NO', 'Norge', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, 'c8fc4d29db00a50898a1bf7fc8f89154d81eed48e11056e27642b5665a607b79', '[{"key":"mval","title":"Lov om merverdiavgift (merverdiavgiftsloven)","publisher":"Lovdata (konsolidert lovtekst, LOV-2009-06-19-58)","url":"https://lovdata.no/lov/2009-06-19-58","consulted_on":"2026-09-25","kind":"law"},{"key":"stortingsvedtak-mva-2026","title":"Stortingsvedtak om merverdiavgift for 2026, vedtatt 18. desember 2025","publisher":"Lovdata / Stortinget","url":"https://lovdata.no/dokument/STV/forskrift/2025-12-18-2752","consulted_on":"2026-09-25","kind":"regulation"},{"key":"skatteforvforskr","title":"Forskrift til skatteforvaltningsloven (skatteforvaltningsforskriften)","publisher":"Lovdata (FOR-2016-11-23-1360)","url":"https://lovdata.no/dokument/SF/forskrift/2016-11-23-1360","consulted_on":"2026-09-25","kind":"regulation"},{"key":"bokforingsl","title":"Lov om bokføring (bokføringsloven)","publisher":"Lovdata (LOV-2004-11-19-73)","url":"https://lovdata.no/lov/2004-11-19-73","consulted_on":"2026-09-25","kind":"law"},{"key":"bokforingsforskr","title":"Forskrift om bokføring (bokføringsforskriften)","publisher":"Lovdata (FOR-2004-12-01-1558)","url":"https://lovdata.no/dokument/SF/forskrift/2004-12-01-1558","consulted_on":"2026-09-25","kind":"regulation"},{"key":"regnskapsl","title":"Lov om årsregnskap m.v. (regnskapsloven)","publisher":"Lovdata (LOV-1998-07-17-56)","url":"https://lovdata.no/lov/1998-07-17-56","consulted_on":"2026-09-25","kind":"law"},{"key":"nrs8","title":"Norsk RegnskapsStandard 8 — God regnskapsskikk for små foretak (januar 2022)","publisher":"Norsk RegnskapsStiftelse","url":"https://www.regnskapsstiftelsen.no/wp-content/uploads/2021/10/2022-01-NRS-8-God-regnskapsskikk-for-sma-foretak-jan-2022.pdf","consulted_on":"2026-09-25","kind":"guidance"},{"key":"forsinkelsesrl","title":"Lov om renter ved forsinket betaling m.m. (forsinkelsesrenteloven)","publisher":"Lovdata (LOV-1976-12-17-100)","url":"https://lovdata.no/lov/1976-12-17-100","consulted_on":"2026-09-25","kind":"law"},{"key":"forsinkelsesrente-2026","title":"Forsinkelsesrente og standardkompensasjon for inndrivelseskostnader fra 1. juli 2026","publisher":"Finanstilsynet","url":"https://www.finanstilsynet.no/nyhetsarkiv/nyheter/2026/forsinkelsesrente-og-standardkompensasjon-for-inndrivelseskostnader-fra-1.-juli-2026","consulted_on":"2026-09-25","kind":"guidance"},{"key":"ehf-forskrift","title":"Forskrift om elektronisk faktura i offentlige anskaffelser","publisher":"Lovdata (FOR-2019-04-01-444)","url":"https://lovdata.no/dokument/SF/forskrift/2019-04-01-444","consulted_on":"2026-09-25","kind":"regulation"},{"key":"saf-t-koder","title":"Standard Tax Codes — Norwegian SAF-T Financial, kodeliste for merverdiavgiftskoder","publisher":"Skatteetaten (GitHub-repositoriet Skatteetaten/saf-t)","url":"https://github.com/Skatteetaten/saf-t/blob/master/Standard%20Tax%20Codes/CSV/Standard_Tax_Codes.csv","consulted_on":"2026-09-25","kind":"standard"},{"key":"saf-t-regnskap","title":"SAF-T Financial — dokumentasjon og terskelverdi for elektronisk tilgjengelighet","publisher":"Skatteetaten","url":"https://www.skatteetaten.no/en/business-and-organisation/start-and-run/best-practices-accounting-and-cash-register-systems/saf-t-financial/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"mva-meldingen-modell","title":"Mva-meldingen — informasjonsmodell (kodebasert skjema siden 2022)","publisher":"Skatteetaten (GitHub-repositoriet Skatteetaten/mva-meldingen)","url":"https://skatteetaten.github.io/mva-meldingen/mvameldingen/informasjonsmodell/","consulted_on":"2026-09-25","kind":"standard"},{"key":"ns-4102","title":"NS 4102:2023 Kontoplan for regnskap","publisher":"Standard Norge","url":"https://www.standard.no/fagomrader/kontoplan-for-regnskap/","consulted_on":"2026-09-25","kind":"standard"},{"key":"mva-melding-portal","title":"Mva-melding — lever mva-meldingen (via Altinn)","publisher":"Skatteetaten","url":"https://www.skatteetaten.no/bedrift-og-organisasjon/avgifter/mva/mva-melding/","consulted_on":"2026-09-25","kind":"portal"},{"key":"peppol-icd","title":"Peppol BIS Billing 3.0 — code list ICD (ISO 6523), entry 0192","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/ICD/","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list for VAT category codes (BT-118, BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — the list itself is published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('NO', 'default', 'Kontoplan etter regnskapsloven § 6-1 og § 6-2', '{}'::jsonb, true, 'companies', array['NO-RSKL-BS', 'NO-RSKL-IS']::text[], null, 'Norge har ingen lovbestemt kontoplan. Regnskapsloven (LOV-1998-07-17-56) § 6-1 og § 6-2 fastsetter bare oppstillingsplanen for resultatregnskap og balanse, ikke kontonumre. Den kontoplanen bokføringspliktige i praksis bruker, er i stor grad bygget på NS 4102 Kontoplan for regnskap, en frivillig norm utgitt av Standard Norge («Loven krever ikke at denne standarden brukes», standard.no) og som denne pakken ikke gjengir: standarden selges av Standard Norge og er ikke fritt tilgjengelig for gjengivelse. Denne pakkens kontoplan er derfor egendefinert og følger direkte rekkefølgen av postene i § 6-1 og § 6-2, på samme måte som packs/ch og packs/de gjør for sine ikke-lovbestemte kontoplaner — se README.md.', 'ns-4102')
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
  ('NO', 'default', '1000', 'Utvikling', '{}'::jsonb, 'asset_fixed', false, null, 10),
  ('NO', 'default', '1010', 'Konsesjoner, patenter, lisenser, varemerker og lignende rettigheter', '{}'::jsonb, 'asset_fixed', false, null, 20),
  ('NO', 'default', '1040', 'Utsatt skattefordel', '{}'::jsonb, 'asset_fixed', false, null, 30),
  ('NO', 'default', '1050', 'Goodwill', '{}'::jsonb, 'asset_fixed', false, null, 40),
  ('NO', 'default', '1100', 'Tomter, bygninger og annen fast eiendom', '{}'::jsonb, 'asset_fixed', false, null, 50),
  ('NO', 'default', '1150', 'Maskiner og anlegg', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('NO', 'default', '1200', 'Skip, rigger, fly og lignende', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('NO', 'default', '1220', 'Driftsløsøre, inventar, verktøy, kontormaskiner og lignende', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('NO', 'default', '1300', 'Investeringer i datterselskap', '{}'::jsonb, 'asset_non_current', false, null, 90),
  ('NO', 'default', '1310', 'Investeringer i annet foretak i samme konsern', '{}'::jsonb, 'asset_non_current', false, null, 95),
  ('NO', 'default', '1320', 'Lån til foretak i samme konsern', '{}'::jsonb, 'asset_non_current', false, null, 98),
  ('NO', 'default', '1330', 'Investeringer i tilknyttet selskap', '{}'::jsonb, 'asset_non_current', false, null, 100),
  ('NO', 'default', '1340', 'Lån til tilknyttet selskap og felleskontrollert virksomhet', '{}'::jsonb, 'asset_non_current', false, null, 105),
  ('NO', 'default', '1350', 'Investeringer i aksjer og andeler', '{}'::jsonb, 'asset_non_current', false, null, 110),
  ('NO', 'default', '1360', 'Obligasjoner', '{}'::jsonb, 'asset_non_current', false, null, 120),
  ('NO', 'default', '1370', 'Andre langsiktige fordringer', '{}'::jsonb, 'asset_non_current', false, null, 130),
  ('NO', 'default', '1400', 'Varebeholdning', '{}'::jsonb, 'asset_current', false, null, 140),
  ('NO', 'default', '1500', 'Kundefordringer', '{}'::jsonb, 'asset_receivable', true, null, 150),
  ('NO', 'default', '1510', 'Opptjent, ikke fakturert driftsinntekt', '{}'::jsonb, 'asset_current', false, null, 160),
  ('NO', 'default', '1540', 'Inngående merverdiavgift, alminnelig sats (kode 1)', '{}'::jsonb, 'asset_current', false, null, 170),
  ('NO', 'default', '1541', 'Inngående merverdiavgift, redusert sats (kode 13)', '{}'::jsonb, 'asset_current', false, null, 180),
  ('NO', 'default', '1542', 'Fradragsberettiget innførselsmerverdiavgift (kode 14)', '{}'::jsonb, 'asset_current', false, null, 185),
  ('NO', 'default', '1543', 'Fradragsberettiget merverdiavgift, tjeneste kjøpt fra utlandet (kode 86)', '{}'::jsonb, 'asset_current', false, null, 187),
  ('NO', 'default', '1545', 'Til gode merverdiavgift (oppgjørskonto)', '{}'::jsonb, 'asset_current', true, null, 190),
  ('NO', 'default', '1550', 'Andre fordringer', '{}'::jsonb, 'asset_current', false, null, 200),
  ('NO', 'default', '1560', 'Krav på innbetaling av selskapskapital', '{}'::jsonb, 'asset_current', false, null, 205),
  ('NO', 'default', '1590', 'Aksjer og andeler i foretak i samme konsern', '{}'::jsonb, 'asset_current', false, null, 208),
  ('NO', 'default', '1600', 'Markedsbaserte aksjer', '{}'::jsonb, 'asset_current', false, null, 210),
  ('NO', 'default', '1630', 'Markedsbaserte obligasjoner', '{}'::jsonb, 'asset_current', false, null, 220),
  ('NO', 'default', '1650', 'Andre markedsbaserte finansielle instrumenter', '{}'::jsonb, 'asset_current', false, null, 225),
  ('NO', 'default', '1670', 'Andre finansielle instrumenter', '{}'::jsonb, 'asset_current', false, null, 228),
  ('NO', 'default', '1900', 'Kasse', '{}'::jsonb, 'asset_cash', false, null, 230),
  ('NO', 'default', '1920', 'Bankinnskudd', '{}'::jsonb, 'asset_cash', true, null, 240),
  ('NO', 'default', '2000', 'Selskapskapital', '{}'::jsonb, 'equity', false, null, 250),
  ('NO', 'default', '2010', 'Overkurs', '{}'::jsonb, 'equity', false, null, 260),
  ('NO', 'default', '2020', 'Annen innskutt egenkapital', '{}'::jsonb, 'equity', false, null, 270),
  ('NO', 'default', '2100', 'Fond', '{}'::jsonb, 'equity_retained', false, null, 280),
  ('NO', 'default', '2120', 'Annen egenkapital', '{}'::jsonb, 'equity_retained', false, null, 290),
  ('NO', 'default', '2200', 'Pensjonsforpliktelser', '{}'::jsonb, 'liability_non_current', false, null, 300),
  ('NO', 'default', '2220', 'Utsatt skatt', '{}'::jsonb, 'liability_non_current', false, null, 310),
  ('NO', 'default', '2240', 'Andre avsetninger for forpliktelser', '{}'::jsonb, 'liability_non_current', false, null, 320),
  ('NO', 'default', '2300', 'Konvertible lån (langsiktig)', '{}'::jsonb, 'liability_non_current', false, null, 325),
  ('NO', 'default', '2310', 'Obligasjonslån', '{}'::jsonb, 'liability_non_current', false, null, 328),
  ('NO', 'default', '2320', 'Gjeld til kredittinstitusjoner (langsiktig)', '{}'::jsonb, 'liability_non_current', false, null, 330),
  ('NO', 'default', '2360', 'Øvrig langsiktig gjeld', '{}'::jsonb, 'liability_non_current', false, null, 340),
  ('NO', 'default', '2400', 'Konvertible lån (kortsiktig)', '{}'::jsonb, 'liability_current', false, null, 345),
  ('NO', 'default', '2410', 'Sertifikatlån', '{}'::jsonb, 'liability_current', false, null, 348),
  ('NO', 'default', '2420', 'Gjeld til kredittinstitusjoner (kortsiktig)', '{}'::jsonb, 'liability_current', false, null, 350),
  ('NO', 'default', '2500', 'Leverandørgjeld', '{}'::jsonb, 'liability_payable', true, null, 360),
  ('NO', 'default', '2600', 'Betalbar skatt', '{}'::jsonb, 'liability_current', false, null, 370),
  ('NO', 'default', '2620', 'Utgående merverdiavgift, alminnelig sats 25 % (kode 3)', '{}'::jsonb, 'liability_current', false, null, 380),
  ('NO', 'default', '2621', 'Utgående merverdiavgift, redusert sats 15 % (kode 31)', '{}'::jsonb, 'liability_current', false, null, 390),
  ('NO', 'default', '2622', 'Utgående merverdiavgift, redusert sats 12 % (kode 33)', '{}'::jsonb, 'liability_current', false, null, 400),
  ('NO', 'default', '2630', 'Skyldig arbeidsgiveravgift', '{}'::jsonb, 'liability_current', false, null, 410),
  ('NO', 'default', '2640', 'Skyldig forskuddstrekk', '{}'::jsonb, 'liability_current', false, null, 420),
  ('NO', 'default', '2645', 'Skyldig avgift, innførsel og fjernleverbar tjeneste (snudd avregning)', '{}'::jsonb, 'liability_current', false, null, 425),
  ('NO', 'default', '2650', 'Skyldig merverdiavgift (oppgjørskonto)', '{}'::jsonb, 'liability_current', true, null, 430),
  ('NO', 'default', '2700', 'Skyldig lønn', '{}'::jsonb, 'liability_current', false, null, 440),
  ('NO', 'default', '2720', 'Skyldige feriepenger', '{}'::jsonb, 'liability_current', false, null, 450),
  ('NO', 'default', '2790', 'Uidentifiserte innbetalinger (gjennomgangskonto)', '{}'::jsonb, 'liability_current', true, null, 460),
  ('NO', 'default', '3000', 'Salgsinntekt, avgiftspliktig alminnelig sats 25 %', '{}'::jsonb, 'income', false, null, 470),
  ('NO', 'default', '3010', 'Salgsinntekt, avgiftspliktig redusert sats 15 % (næringsmidler)', '{}'::jsonb, 'income', false, null, 480),
  ('NO', 'default', '3020', 'Salgsinntekt, avgiftspliktig redusert sats 12 %', '{}'::jsonb, 'income', false, null, 490),
  ('NO', 'default', '3030', 'Salgsinntekt, fritatt (nullsats innenlands)', '{}'::jsonb, 'income', false, null, 500),
  ('NO', 'default', '3040', 'Salgsinntekt, utførsel (eksport)', '{}'::jsonb, 'income', false, null, 510),
  ('NO', 'default', '3050', 'Salgsinntekt, unntatt avgiftsplikt', '{}'::jsonb, 'income', false, null, 520),
  ('NO', 'default', '3060', 'Annen driftsinntekt', '{}'::jsonb, 'income_other', false, null, 530),
  ('NO', 'default', '3070', 'Gevinst ved salg av driftsmiddel', '{}'::jsonb, 'income_other', false, null, 535),
  ('NO', 'default', '3080', 'Offentlig tilskudd', '{}'::jsonb, 'income_other', false, null, 538),
  ('NO', 'default', '4000', 'Varekostnad, innenlands kjøp', '{}'::jsonb, 'expense_direct_cost', false, null, 540),
  ('NO', 'default', '4010', 'Varekostnad, innførsel (import)', '{}'::jsonb, 'expense_direct_cost', false, null, 550),
  ('NO', 'default', '5000', 'Lønn', '{}'::jsonb, 'expense', false, null, 560),
  ('NO', 'default', '5400', 'Arbeidsgiveravgift', '{}'::jsonb, 'expense', false, null, 570),
  ('NO', 'default', '5900', 'Annen personalkostnad', '{}'::jsonb, 'expense', false, null, 580),
  ('NO', 'default', '5920', 'Feriepenger', '{}'::jsonb, 'expense', false, null, 585),
  ('NO', 'default', '5940', 'Pensjonskostnad', '{}'::jsonb, 'expense', false, null, 588),
  ('NO', 'default', '6000', 'Avskrivning på varige driftsmidler', '{}'::jsonb, 'expense_depreciation', false, null, 590),
  ('NO', 'default', '6020', 'Avskrivning på immaterielle eiendeler', '{}'::jsonb, 'expense_depreciation', false, null, 600),
  ('NO', 'default', '6100', 'Nedskrivning på varige driftsmidler og immaterielle eiendeler', '{}'::jsonb, 'expense_depreciation', false, null, 610),
  ('NO', 'default', '7000', 'Frakt- og transportkostnad', '{}'::jsonb, 'expense', false, null, 620),
  ('NO', 'default', '7020', 'Fremmed tjeneste kjøpt fra utlandet (fjernleverbar tjeneste, snudd avregning)', '{}'::jsonb, 'expense', false, null, 630),
  ('NO', 'default', '7050', 'Forsikring', '{}'::jsonb, 'expense', false, null, 635),
  ('NO', 'default', '7060', 'Vedlikehold', '{}'::jsonb, 'expense', false, null, 638),
  ('NO', 'default', '7100', 'Kontorkostnad', '{}'::jsonb, 'expense', false, null, 640),
  ('NO', 'default', '7150', 'IT-kostnad', '{}'::jsonb, 'expense', false, null, 642),
  ('NO', 'default', '7200', 'Reisekostnad', '{}'::jsonb, 'expense', false, null, 644),
  ('NO', 'default', '7300', 'Markedsføringskostnad', '{}'::jsonb, 'expense', false, null, 646),
  ('NO', 'default', '7400', 'Revisjons- og regnskapshonorar', '{}'::jsonb, 'expense', false, null, 648),
  ('NO', 'default', '7500', 'Husleie', '{}'::jsonb, 'expense', false, null, 650),
  ('NO', 'default', '7600', 'Kontingenter og gaver', '{}'::jsonb, 'expense', false, null, 655),
  ('NO', 'default', '7700', 'Annen driftskostnad', '{}'::jsonb, 'expense', false, null, 660),
  ('NO', 'default', '7800', 'Tap på fordringer', '{}'::jsonb, 'expense', false, null, 665),
  ('NO', 'default', '7900', 'Avrundingsdifferanser', '{}'::jsonb, 'expense', false, null, 670),
  ('NO', 'default', '8000', 'Renteinntekt fra foretak i samme konsern', '{}'::jsonb, 'income_other', false, null, 680),
  ('NO', 'default', '8020', 'Annen finansinntekt', '{}'::jsonb, 'income_other', false, null, 690),
  ('NO', 'default', '8030', 'Agiogevinst', '{}'::jsonb, 'income_other', false, null, 700),
  ('NO', 'default', '8040', 'Inntekt på investering i datterselskap og tilknyttet selskap', '{}'::jsonb, 'income_other', false, null, 710),
  ('NO', 'default', '8050', 'Inntekt på andre investeringer', '{}'::jsonb, 'income_other', false, null, 720),
  ('NO', 'default', '8060', 'Verdiendring av finansielle instrumenter vurdert til virkelig verdi', '{}'::jsonb, 'income_other', false, null, 730),
  ('NO', 'default', '8100', 'Rentekostnad til foretak i samme konsern', '{}'::jsonb, 'expense', false, null, 740),
  ('NO', 'default', '8110', 'Annen finanskostnad', '{}'::jsonb, 'expense', false, null, 750),
  ('NO', 'default', '8130', 'Agiotap', '{}'::jsonb, 'expense', false, null, 760),
  ('NO', 'default', '8140', 'Nedskrivning av finansielle eiendeler', '{}'::jsonb, 'expense', false, null, 770),
  ('NO', 'default', '8300', 'Skattekostnad på ordinært resultat', '{}'::jsonb, 'expense', false, null, 780)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('NO', 'BNK', 'Bank', '{}'::jsonb, 'bank', 30),
  ('NO', 'CSH', 'Kasse', '{}'::jsonb, 'cash', 40),
  ('NO', 'GEN', 'Diverse bilag', '{}'::jsonb, 'general', 50),
  ('NO', 'OPN', 'Åpningsbalanse', '{}'::jsonb, 'opening', 60),
  ('NO', 'PUR', 'Leverandørreskontro', '{}'::jsonb, 'purchase', 20),
  ('NO', 'SAL', 'Salgsreskontro', '{}'::jsonb, 'sales', 10)
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
  ('NO', 'NO-P-12', 'Innenlands kjøp, fradragsberettiget, lav sats 12 %', '{}'::jsonb, null, 'percent', 12, 'purchase', 'domestic', date '2026-01-01', null, 'Merverdiavgiftsloven § 8-1, ved kjøp avgiftsberegnet med lav sats etter § 5-3, § 5-5, § 5-6, § 5-9, § 5-10 eller § 5-11.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null),
  ('NO', 'NO-P-25', 'Innenlands kjøp, fradragsberettiget, alminnelig sats 25 %', '{}'::jsonb, null, 'percent', 25, 'purchase', 'domestic', date '2026-01-01', null, 'Merverdiavgiftsloven § 8-1 — fradragsrett for inngående merverdiavgift på varer og tjenester til bruk i den registrerte virksomheten, ved kjøp avgiftsberegnet med alminnelig sats etter § 5-1.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null),
  ('NO', 'NO-P-FOREIGN-25', 'Fjernleverbar tjeneste kjøpt fra utlandet, alminnelig sats 25 % (snudd avregning)', '{}'::jsonb, null, 'percent', 25, 'purchase', 'foreign_services_received', date '2026-01-01', null, 'Merverdiavgiftsloven § 3-30 første ledd — kjøp av en fjernleverbar tjeneste fra en tilbyder som ikke har forretningssted eller hjemsted i merverdiavgiftsområdet, er avgiftspliktig når mottakeren er hjemmehørende i merverdiavgiftsområdet og tjenesten er avgiftspliktig ved omsetning her (snudd avregning). Fradragsretten for det samme beløpet følger av § 8-1. Samme bokføringsløsning som NO-P-IMPORT-25, av samme grunn: SAF-T-kodelisten har ingen egen utgående kode for denne selvberegnede avgiften, og den selvpålagte avgiften bokføres derfor på den alminnelige utgående koden 3.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null),
  ('NO', 'NO-P-IMPORT-25', 'Innførsel av varer, alminnelig sats 25 %', '{}'::jsonb, null, 'percent', 25, 'purchase', 'import', date '2026-01-01', null, 'Merverdiavgiftsloven § 11-1 tredje ledd — mottakeren av varen er ansvarlig for å beregne og betale merverdiavgift ved innførsel, i mva-meldingen for den terminen varen innføres, i stedet for å betale avgiften til Tolletaten ved grensepassering (ordningen fra 1. januar 2017). Fradragsretten for det samme beløpet følger av § 8-1. Denne pakken bokfører derfor to motstående linjer for samme beløp — fradraget på kode 14 og den selvberegnede avgiften på kode 3 — på samme måte som packs/gb bokfører sin «postponed VAT accounting», siden SAF-T-kodelisten ikke har noen egen utgående kode for innførsel (se README.md).', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null),
  ('NO', 'NO-S-0', 'Salg, fritatt for merverdiavgift (nullsats innenlands — bøker)', '{}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2026-01-01', null, 'Merverdiavgiftsloven § 6-4 — omsetning av bøker, herunder e-bøker, er fritatt for merverdiavgift, med fradragsrett for inngående avgift etter § 8-1 (nullsats, ikke unntak). Samme lovs kapittel 6 fritar på tilsvarende vis aviser (§ 6-1) og elbiler til og med 300 000 kroner per kjøretøy (§ 6-8, endret ved lov 22. desember 2025 nr. 121 med virkning fra 1. januar 2026, som senket beløpsgrensen fra 500 000 til 300 000 kroner).', 'Z', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null),
  ('NO', 'NO-S-12', 'Salg, lav sats 12 % (persontransport, overnatting, m.m.)', '{}'::jsonb, null, 'percent', 12, 'sale', 'domestic', date '2026-01-01', null, 'Merverdiavgiftsloven §§ 5-3 (persontransport), 5-5 (overnatting), 5-6 (kringkasting/kino), 5-9 (museer), 5-10 (fornøyelsesparker) og 5-11 (idrettsarrangement). Satsen selv er fastsatt i Stortingsvedtak om merverdiavgift for 2026, § 4: «Merverdiavgift beregnes med 12 pst. av omsetning … av tjenester».', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'stortingsvedtak-mva-2026', null, null, null, null),
  ('NO', 'NO-S-15', 'Salg, redusert sats 15 % (næringsmidler)', '{}'::jsonb, null, 'percent', 15, 'sale', 'domestic', date '2026-01-01', null, 'Merverdiavgiftsloven § 5-2 første ledd — «Det skal beregnes merverdiavgift med redusert sats ved omsetning … av næringsmidler». Satsen selv er fastsatt i Stortingsvedtak om merverdiavgift for 2026, § 3: «Merverdiavgift beregnes med 15 pst. av omsetning … av næringsmidler».', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'stortingsvedtak-mva-2026', null, null, null, null),
  ('NO', 'NO-S-25', 'Salg, alminnelig sats 25 %', '{}'::jsonb, null, 'percent', 25, 'sale', 'domestic', date '2026-01-01', null, 'Merverdiavgiftsloven §§ 5-1 og 5-2 — den alminnelige satsen gjelder all avgiftspliktig omsetning som ikke er nevnt i lovens kapittel 5 for øvrig. Satsen selv er fastsatt i Stortingsvedtak om merverdiavgift for 2026, § 2: «Merverdiavgift beregnes med 25 pst. av avgiftspliktig omsetning».', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'stortingsvedtak-mva-2026', null, null, null, null),
  ('NO', 'NO-S-EXEMPT', 'Salg av finansielle tjenester (unntatt fra loven)', '{}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2026-01-01', null, 'Merverdiavgiftsloven § 3-6 — omsetning og formidling av finansielle tjenester, herunder forsikringstjenester, långivning og annen finansiering, er unntatt fra loven, uten fradragsrett for inngående avgift. Denne omsetningen svarer til de sju bokstavene a til g i § 3-6, som ikke er transkribert enkeltvis her.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null),
  ('NO', 'NO-S-EXPORT', 'Utførsel av varer og tjenester (eksport)', '{}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2026-01-01', null, 'Merverdiavgiftsloven §§ 6-21 og 6-22 — omsetning av varer og av tjenester ut av merverdiavgiftsområdet er fritatt for merverdiavgift, med fradragsrett for inngående avgift etter § 8-1.', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mval', null, null, null, null)
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
    ('NO-P-12', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-P-12', 'invoice', 'tax', 100, '1541', '13', array['13']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-P-12', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-P-12', 'credit_note', 'tax', 100, '1541', '13', array['13']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-P-25', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-P-25', 'invoice', 'tax', 100, '1540', '1', array['1']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-P-25', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-P-25', 'credit_note', 'tax', 100, '1540', '1', array['1']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-P-FOREIGN-25', 'invoice', 'base', 100, null, '86', array['86']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-P-FOREIGN-25', 'invoice', 'tax', 100, '1543', '86', array['86']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-P-FOREIGN-25', 'invoice', 'tax', -100, '2645', '3', array['3']::text[], 100, 'NO-MVA-MELDING', 30),
    ('NO-P-FOREIGN-25', 'credit_note', 'base', 100, null, '86', array['86']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-P-FOREIGN-25', 'credit_note', 'tax', 100, '1543', '86', array['86']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-P-FOREIGN-25', 'credit_note', 'tax', -100, '2645', '3', array['3']::text[], -100, 'NO-MVA-MELDING', 30),
    ('NO-P-IMPORT-25', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-P-IMPORT-25', 'invoice', 'tax', 100, '1542', '14', array['14']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-P-IMPORT-25', 'invoice', 'tax', -100, '2645', '3', array['3']::text[], 100, 'NO-MVA-MELDING', 30),
    ('NO-P-IMPORT-25', 'credit_note', 'base', 100, null, '21', array['21']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-P-IMPORT-25', 'credit_note', 'tax', 100, '1542', '14', array['14']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-P-IMPORT-25', 'credit_note', 'tax', -100, '2645', '3', array['3']::text[], -100, 'NO-MVA-MELDING', 30),
    ('NO-S-0', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-S-0', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-S-12', 'invoice', 'base', 100, null, '33', array['33']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-S-12', 'invoice', 'tax', 100, '2622', '33', array['33']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-S-12', 'credit_note', 'base', 100, null, '33', array['33']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-S-12', 'credit_note', 'tax', 100, '2622', '33', array['33']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-S-15', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-S-15', 'invoice', 'tax', 100, '2621', '31', array['31']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-S-15', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-S-15', 'credit_note', 'tax', 100, '2621', '31', array['31']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-S-25', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-S-25', 'invoice', 'tax', 100, '2620', '3', array['3']::text[], 100, 'NO-MVA-MELDING', 20),
    ('NO-S-25', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'NO-MVA-MELDING', 10),
    ('NO-S-25', 'credit_note', 'tax', 100, '2620', '3', array['3']::text[], -100, 'NO-MVA-MELDING', 20),
    ('NO-S-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('NO-S-EXEMPT', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('NO-S-EXPORT', 'invoice', 'base', 100, null, '52', array['52']::text[], 100, 'NO-MVA-MELDING', 10),
    ('NO-S-EXPORT', 'credit_note', 'base', 100, null, '52', array['52']::text[], -100, 'NO-MVA-MELDING', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'NO' and t.code = v.tax_code
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
  ('NO', 'NO-MVA-MELDING', 'Mva-melding for merverdiavgift (kodebasert skjema, mvaKoder etter SAF-T-standarden)', array['bimonth', 'year']::declaration_period[], 'bimonth'::declaration_period, date '2022-04-01', null, 'Skatteforvaltningsforskriften (FOR-2016-11-23-1360) § 8-3 gjør skattleggingsperioden for merverdiavgift til to kalendermåneder (januar-februar, mars-april, mai-juni, juli-august, september-oktober, november-desember) som hovedregel for alle avgiftssubjekter; § 8-3-3 lar skattekontoret samtykke i årlig levering når avgiftspliktig omsetning og uttak ikke overstiger én million kroner i et kalenderår, og § 8-3-7 gir primærnæringene (jordbruk, skogbruk, fiske) en tilsvarende årlig periode uavhengig av omsetning. Siden april 2022 leveres mva-meldingen ikke lenger på faste, trykte poster (det tidligere skjemaet RF-0002), men som enkeltlinjer merket med en mvaKode fra Skatteetatens standardiserte kodeliste for SAF-T, hver med et grunnlagsbeløp og et avgiftsbeløp; boksene i denne filen er derfor kodene i den listen og ikke sidenumre på et skjema. Denne pakken transkriberer bare et utvalg av kodene — de som trengs for de avgiftsbehandlingene taxes.json dekker — og ikke hele listen; se README.md.', true,null, null, null, null, null, null)
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
  ('NO', 'NO-MVA-MELDING', '3', 'base', 'Utgående merverdiavgift, alminnelig sats — grunnlag', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 3, «Utgående merverdiavgift», alminnelig sats. Denne koden mottar også grunnlaget for salg til alminnelig sats etter merverdiavgiftsloven §§ 5-1 og 5-2, jf. Stortingsvedtak om merverdiavgift for 2026 § 2 (25 %).', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '3', 'tax', 'Utgående merverdiavgift, alminnelig sats — avgift', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 3. Denne boksen mottar også den selvpålagte utgående avgiften av innførsel av varer og av fjernleverbare tjenester kjøpt fra utlandet (kode 14/21 og 86 i denne filen), fordi kodelisten ikke har en egen utgående kode for disse to tilfellene — se README.md for begrunnelsen, som følger samme lesning som packs/gb gjør for sin boks 1.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '31', 'base', 'Utgående merverdiavgift, redusert sats (næringsmidler) — grunnlag', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 31. Grunnlag for salg av næringsmidler etter merverdiavgiftsloven § 5-2, jf. Stortingsvedtak om merverdiavgift for 2026 § 3 (15 %).', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '31', 'tax', 'Utgående merverdiavgift, redusert sats (næringsmidler) — avgift', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 31.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '33', 'base', 'Utgående merverdiavgift, lav sats — grunnlag', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 33. Grunnlag for persontransport, overnatting, kino, kringkasting, museer, fornøyelsesparker og idrettsarrangementer etter merverdiavgiftsloven §§ 5-3, 5-5, 5-6, 5-9, 5-10 og 5-11, jf. Stortingsvedtak om merverdiavgift for 2026 § 4 (12 %).', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '33', 'tax', 'Utgående merverdiavgift, lav sats — avgift', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 33.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '5', 'base', 'Innenlands omsetning fritatt for merverdiavgift (nullsats)', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 5. Grunnlag for omsetning som er fritatt med fradragsrett — bøker (§ 6-4), aviser (§ 6-1) og elbiler til og med 300 000 kroner (§ 6-8), blant andre — til forskjell fra en unntatt (avgiftsfri uten fradragsrett) omsetning, som denne kodelisten ikke har en egen kode for og som derfor ikke bokføres på noen boks i denne filen, se README.md.', 'mval'),
  ('NO', 'NO-MVA-MELDING', '52', 'base', 'Utførsel av varer og tjenester (eksport)', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 52. Merverdiavgiftsloven §§ 6-21 og 6-22 fritar utførsel av varer og tjenester ut av merverdiavgiftsområdet, med fradragsrett.', 'mval'),
  ('NO', 'NO-MVA-MELDING', '1', 'base', 'Innenlands kjøp, fradragsberettiget, alminnelig sats — grunnlag', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 1.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '1', 'tax', 'Innenlands kjøp, fradragsberettiget, alminnelig sats — fradrag', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 1. Fradragsretten følger merverdiavgiftsloven § 8-1.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '13', 'base', 'Innenlands kjøp, fradragsberettiget, lav sats — grunnlag', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 13.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '13', 'tax', 'Innenlands kjøp, fradragsberettiget, lav sats — fradrag', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 13. Fradragsretten følger merverdiavgiftsloven § 8-1.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '21', 'base', 'Kostnad ved innførsel av varer, alminnelig sats', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 21. Merverdiavgiftsloven § 11-1 tredje ledd gjør den registrerte mottakeren ansvarlig for å beregne og betale merverdiavgift ved innførsel av varer selv, i mva-meldingen, i stedet for å betale avgiften til Tolletaten ved grensepassering.', 'mval'),
  ('NO', 'NO-MVA-MELDING', '14', 'tax', 'Fradragsberettiget innførselsmerverdiavgift, alminnelig sats', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 14. Fradragsretten følger merverdiavgiftsloven § 8-1, på samme grunnlag som mvaKode 21.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', '86', 'base', 'Fjernleverbare tjenester kjøpt fra utlandet, fradragsberettiget, alminnelig sats — grunnlag', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 86. Merverdiavgiftsloven § 3-30 pålegger mottakeren å beregne og betale merverdiavgift av en fjernleverbar tjeneste kjøpt fra en tilbyder utenfor merverdiavgiftsområdet.', 'mval'),
  ('NO', 'NO-MVA-MELDING', '86', 'tax', 'Fjernleverbare tjenester kjøpt fra utlandet, fradragsberettiget, alminnelig sats — fradrag', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'SAF-T-standardens mvaKode 86. Fradragsretten følger merverdiavgiftsloven § 8-1.', 'saf-t-koder'),
  ('NO', 'NO-MVA-MELDING', 'UTSUM', 'total', 'Sum utgående merverdiavgift', '{}'::jsonb, 170, null, array['3:tax', '31:tax', '33:tax']::text[], '{}'::text[], null, null, false, true, null, 'Ikke et boksnummer i mva-meldingen: mellomsummen som denne pakken bruker for å beregne nettobeløpet, siden det kodebaserte skjemaet (se ovenfor) ikke selv navngir et felt for den.', 'mva-meldingen-modell'),
  ('NO', 'NO-MVA-MELDING', 'INNSUM', 'total', 'Sum fradragsberettiget inngående merverdiavgift', '{}'::jsonb, 180, null, array['1:tax', '13:tax', '14', '86:tax']::text[], '{}'::text[], null, null, false, true, null, 'Ikke et boksnummer i mva-meldingen, av samme grunn som UTSUM.', 'mva-meldingen-modell'),
  ('NO', 'NO-MVA-MELDING', 'BETALES', 'total', 'Merverdiavgift til betaling', '{}'::jsonb, 190, null, array['UTSUM']::text[], array['INNSUM']::text[], null, null, true, false, null, 'Ikke et boksnummer i mva-meldingen: nettobeløpet fastsettes av skattemyndigheten (fastsattMerverdiavgift) fra summen av kodene, uten et eget skjemafelt for mellomregningen.', 'mva-meldingen-modell'),
  ('NO', 'NO-MVA-MELDING', 'TILGODE', 'total', 'Merverdiavgift til gode', '{}'::jsonb, 200, null, array['INNSUM']::text[], array['UTSUM']::text[], null, null, true, false, null, 'Ikke et boksnummer i mva-meldingen, av samme grunn som BETALES.', 'mva-meldingen-modell')
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
  ('NO-RSKL-BS', 'NO', 'default', 'Balanse etter regnskapsloven § 6-2', 'balance_sheet', 'NO-RSKL', date '1970-01-01', null, 'Regnskapsloven (LOV-1998-07-17-56) § 6-2 første ledd gir oppstillingsplanen for balansen: eiendeler inndelt i A. Anleggsmidler (I. Immaterielle eiendeler, II. Varige driftsmidler, III. Finansielle anleggsmidler) og B. Omløpsmidler (I. Varer, II. Fordringer, III. Investeringer, IV. Bankinnskudd, kontanter og lignende), og egenkapital og gjeld inndelt i C. Egenkapital (I. Innskutt egenkapital, II. Opptjent egenkapital) og D. Gjeld (I. Avsetning for forpliktelser, II. Annen langsiktig gjeld, III. Kortsiktig gjeld). Denne planen er felles for alle regnskapspliktige, jf. NRS 8 God regnskapsskikk for små foretak, kapittel 3.2.1, som bekrefter at små foretak benytter samme oppstillingsplan som øvrige foretak. Linjene under er gruppert på romertallsnivå (I-IV): § 6-2 tallfester underposter innenfor hver romertallsgruppe, men NRS 8 kapittel 3, første avsnitt, tillater sammenslåing av poster når det gjør regnskapet mer oversiktlig, som er den forenklingen et lite foretaks kontoplan vanligvis bruker.', 'regnskapsl'),
  ('NO-RSKL-IS', 'NO', 'default', 'Resultatregnskap etter art, regnskapsloven § 6-1', 'income_statement', 'NO-RSKL', date '1970-01-01', null, 'Regnskapsloven § 6-1 gir oppstillingsplanen for resultatregnskapet etter art, en flat, nummerert liste fra post 1 til post 24. Postene 22 (ekstraordinære inntekter og kostnader) og 23 (skattekostnad på ekstraordinære poster) bortfaller for regnskapsår påbegynt 1. juli 2021 eller senere, jf. Norsk RegnskapsStandard 8 God regnskapsskikk for små foretak (Norsk RegnskapsStiftelse, januar 2022), kapittel 3.1.1, note 4 og 6, som gjengir lovens någjeldende ordlyd etter denne endringen; denne pakken transkriberer derfor bare postene 1-21 og 24, og det er ingen linje for 22/23.', 'nrs8')
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
  ('NO-RSKL-BS', 'EIENDELER', null, 'Sum eiendeler', '{}'::jsonb, 10, 1, true, array['ANLEGGSMIDLER', 'OMLOPSMIDLER']::text[], '{}'::text[], null, null, null),
  ('NO-RSKL-BS', 'ANLEGGSMIDLER', 'EIENDELER', 'A. Anleggsmidler', '{}'::jsonb, 20, 1, true, array['A.I', 'A.II', 'A.III']::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post A', 'regnskapsl'),
  ('NO-RSKL-BS', 'A.I', 'ANLEGGSMIDLER', 'I. Immaterielle eiendeler', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post A.I', 'regnskapsl'),
  ('NO-RSKL-BS', 'A.II', 'ANLEGGSMIDLER', 'II. Varige driftsmidler', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post A.II', 'regnskapsl'),
  ('NO-RSKL-BS', 'A.III', 'ANLEGGSMIDLER', 'III. Finansielle anleggsmidler', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post A.III', 'regnskapsl'),
  ('NO-RSKL-BS', 'OMLOPSMIDLER', 'EIENDELER', 'B. Omløpsmidler', '{}'::jsonb, 60, 1, true, array['B.I', 'B.II', 'B.III', 'B.IV']::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post B', 'regnskapsl'),
  ('NO-RSKL-BS', 'B.I', 'OMLOPSMIDLER', 'I. Varer', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post B.I', 'regnskapsl'),
  ('NO-RSKL-BS', 'B.II', 'OMLOPSMIDLER', 'II. Fordringer', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post B.II — omfatter kundefordringer, andre fordringer og inngående/til gode merverdiavgift', 'regnskapsl'),
  ('NO-RSKL-BS', 'B.III', 'OMLOPSMIDLER', 'III. Investeringer', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post B.III', 'regnskapsl'),
  ('NO-RSKL-BS', 'B.IV', 'OMLOPSMIDLER', 'IV. Bankinnskudd, kontanter og lignende', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post B.IV', 'regnskapsl'),
  ('NO-RSKL-BS', 'EK_OG_GJELD', null, 'Sum egenkapital og gjeld', '{}'::jsonb, 110, 1, true, array['EGENKAPITAL', 'GJELD']::text[], '{}'::text[], null, null, null),
  ('NO-RSKL-BS', 'EGENKAPITAL', 'EK_OG_GJELD', 'C. Egenkapital', '{}'::jsonb, 120, 1, true, array['C.I', 'C.II']::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post C', 'regnskapsl'),
  ('NO-RSKL-BS', 'C.I', 'EGENKAPITAL', 'I. Innskutt egenkapital', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post C.I', 'regnskapsl'),
  ('NO-RSKL-BS', 'C.II', 'EGENKAPITAL', 'II. Opptjent egenkapital', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post C.II — regnskapsloven kjenner ingen egen post for årets resultat på balansen; resultatet føres direkte mot annen egenkapital', 'regnskapsl'),
  ('NO-RSKL-BS', 'GJELD', 'EK_OG_GJELD', 'D. Gjeld', '{}'::jsonb, 150, 1, true, array['D.I', 'D.II', 'D.III']::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post D', 'regnskapsl'),
  ('NO-RSKL-BS', 'D.I', 'GJELD', 'I. Avsetning for forpliktelser', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post D.I', 'regnskapsl'),
  ('NO-RSKL-BS', 'D.II', 'GJELD', 'II. Annen langsiktig gjeld', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post D.II', 'regnskapsl'),
  ('NO-RSKL-BS', 'D.III', 'GJELD', 'III. Kortsiktig gjeld', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-2 første ledd, post D.III — omfatter leverandørgjeld, betalbar skatt, skyldige offentlige avgifter (herunder utgående merverdiavgift og oppgjørskonto merverdiavgift) og annen kortsiktig gjeld', 'regnskapsl'),
  ('NO-RSKL-IS', '1', null, 'Salgsinntekt', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 1', 'regnskapsl'),
  ('NO-RSKL-IS', '2', null, 'Annen driftsinntekt', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 2', 'regnskapsl'),
  ('NO-RSKL-IS', '3', null, 'Endring i beholdning av varer under tilvirkning og ferdig tilvirkede varer', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 3 — ingen konto i denne pakkens kontoplan bokfører på dette området ennå; linjen er med for å transkribere loven fullstendig', 'regnskapsl'),
  ('NO-RSKL-IS', '4', null, 'Endring i beholdning av egentilvirkede anleggsmidler', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 4 — ingen konto i denne pakkens kontoplan bokfører på dette området ennå; linjen er med for å transkribere loven fullstendig', 'regnskapsl'),
  ('NO-RSKL-IS', '5', null, 'Varekostnad', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 5', 'regnskapsl'),
  ('NO-RSKL-IS', '6', null, 'Lønnskostnad', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 6', 'regnskapsl'),
  ('NO-RSKL-IS', '7', null, 'Avskrivning på varige driftsmidler og immaterielle eiendeler', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 7', 'regnskapsl'),
  ('NO-RSKL-IS', '8', null, 'Nedskrivning på varige driftsmidler og immaterielle eiendeler', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 8', 'regnskapsl'),
  ('NO-RSKL-IS', '9', null, 'Annen driftskostnad', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 9', 'regnskapsl'),
  ('NO-RSKL-IS', '10', null, 'Driftsresultat', '{}'::jsonb, 100, 1, true, array['1', '2', '3', '4']::text[], array['5', '6', '7', '8', '9']::text[], null, 'Regnskapsloven § 6-1 nr. 10', 'regnskapsl'),
  ('NO-RSKL-IS', '11', null, 'Inntekt på investering i datterselskap og tilknyttet selskap', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 11', 'regnskapsl'),
  ('NO-RSKL-IS', '12', null, 'Inntekt på andre investeringer', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 12', 'regnskapsl'),
  ('NO-RSKL-IS', '13', null, 'Renteinntekt fra foretak i samme konsern', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 13', 'regnskapsl'),
  ('NO-RSKL-IS', '14', null, 'Annen finansinntekt', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 14', 'regnskapsl'),
  ('NO-RSKL-IS', '15', null, 'Verdiendring av finansielle instrumenter vurdert til virkelig verdi', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 15', 'regnskapsl'),
  ('NO-RSKL-IS', '16', null, 'Nedskrivning av finansielle eiendeler', '{}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 16', 'regnskapsl'),
  ('NO-RSKL-IS', '17', null, 'Rentekostnad til foretak i samme konsern', '{}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 17', 'regnskapsl'),
  ('NO-RSKL-IS', '18', null, 'Annen finanskostnad', '{}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 18', 'regnskapsl'),
  ('NO-RSKL-IS', '19', null, 'Ordinært resultat før skattekostnad', '{}'::jsonb, 190, 1, true, array['10', '11', '12', '13', '14', '15']::text[], array['16', '17', '18']::text[], null, 'Regnskapsloven § 6-1 nr. 19', 'regnskapsl'),
  ('NO-RSKL-IS', '20', null, 'Skattekostnad på ordinært resultat', '{}'::jsonb, 200, 1, false, '{}'::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 20', 'regnskapsl'),
  ('NO-RSKL-IS', '21', null, 'Ordinært resultat', '{}'::jsonb, 210, 1, true, array['19']::text[], array['20']::text[], null, 'Regnskapsloven § 6-1 nr. 21', 'regnskapsl'),
  ('NO-RSKL-IS', '24', null, 'Årsresultat', '{}'::jsonb, 220, 1, true, array['21']::text[], '{}'::text[], null, 'Regnskapsloven § 6-1 nr. 24. Uten poster 22 og 23 (bortfalt, se ovenfor) er årsresultatet identisk med det ordinære resultatet i post 21.', 'nrs8')
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
    ('NO-RSKL-BS', 'A.I', 10, 'code_range', '1000', '1099', null, 'any'),
    ('NO-RSKL-BS', 'A.II', 10, 'code_range', '1100', '1299', null, 'any'),
    ('NO-RSKL-BS', 'A.III', 10, 'code_range', '1300', '1399', null, 'any'),
    ('NO-RSKL-BS', 'B.I', 10, 'code_range', '1400', '1499', null, 'any'),
    ('NO-RSKL-BS', 'B.II', 10, 'code_range', '1500', '1599', null, 'any'),
    ('NO-RSKL-BS', 'B.III', 10, 'code_range', '1600', '1699', null, 'any'),
    ('NO-RSKL-BS', 'B.IV', 10, 'code_range', '1900', '1999', null, 'any'),
    ('NO-RSKL-BS', 'C.I', 10, 'code_range', '2000', '2099', null, 'any'),
    ('NO-RSKL-BS', 'C.II', 10, 'code_range', '2100', '2199', null, 'any'),
    ('NO-RSKL-BS', 'D.I', 10, 'code_range', '2200', '2299', null, 'any'),
    ('NO-RSKL-BS', 'D.II', 10, 'code_range', '2300', '2399', null, 'any'),
    ('NO-RSKL-BS', 'D.III', 10, 'code_range', '2400', '2799', null, 'any'),
    ('NO-RSKL-IS', '1', 10, 'code_range', '3000', '3059', null, 'any'),
    ('NO-RSKL-IS', '2', 10, 'code_range', '3060', '3089', null, 'any'),
    ('NO-RSKL-IS', '3', 10, 'code_range', '4090', '4099', null, 'any'),
    ('NO-RSKL-IS', '4', 10, 'code_range', '3090', '3099', null, 'any'),
    ('NO-RSKL-IS', '5', 10, 'code_range', '4000', '4089', null, 'any'),
    ('NO-RSKL-IS', '6', 10, 'code_range', '5000', '5999', null, 'any'),
    ('NO-RSKL-IS', '7', 10, 'code_range', '6000', '6099', null, 'any'),
    ('NO-RSKL-IS', '8', 10, 'code_range', '6100', '6199', null, 'any'),
    ('NO-RSKL-IS', '9', 10, 'code_range', '7000', '7999', null, 'any'),
    ('NO-RSKL-IS', '11', 10, 'code_range', '8040', '8049', null, 'any'),
    ('NO-RSKL-IS', '12', 10, 'code_range', '8050', '8059', null, 'any'),
    ('NO-RSKL-IS', '13', 10, 'code_range', '8000', '8019', null, 'any'),
    ('NO-RSKL-IS', '14', 10, 'code_range', '8020', '8039', null, 'any'),
    ('NO-RSKL-IS', '15', 10, 'code_range', '8060', '8069', null, 'any'),
    ('NO-RSKL-IS', '16', 10, 'code_range', '8140', '8149', null, 'any'),
    ('NO-RSKL-IS', '17', 10, 'code_range', '8100', '8109', null, 'any'),
    ('NO-RSKL-IS', '18', 10, 'code_range', '8110', '8139', null, 'any'),
    ('NO-RSKL-IS', '20', 10, 'code_range', '8300', '8399', null, 'any')
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
  ('NO', 'Norge', '{}'::jsonb, array['nb']::text[], 'NOK', '1500', '2500', '2790', '7900', '2120', '3000', '4000', '1920', '1900', 'SAL', 'PUR', 'GEN', 'nb', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '8030', '8130', null, null, null, null, '2650', '1545', null, 'bimonth'::declaration_period)
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
  legal_payment_days            = null,
  late_payment_reference        = 'Forsinkelsesrenteloven § 3 første ledd — forsinkelsesrenten fastsettes for hvert halvår og tilsvarer Norges Banks styringsrente pr. 1. januar eller 1. juli med et tillegg på minst 8 prosentpoeng; fra 1. juli 2026 er satsen 12,25 % p.a. (Finanstilsynet, som etter delegasjonsvedtak av Finansdepartementet 18. juni 2025 fastsetter satsen). Loven fastsetter selv ingen alminnelig betalingsfrist når partene ikke har avtalt en: det er ikke undersøkt i denne omgang hvilken bestemmelse (kjøpsloven § 49 eller alminnelige obligasjonsrettslige prinsipper) som i så fall gjelder, og legal_payment_days er derfor satt til null — se README.md.',
  numbering_legal_reference     = 'Bokføringsforskriften (FOR-2004-12-01-1558) § 5-1-3 første ledd — salgsdokumentet skal være forhåndsnummerert på trykte blanketter eller ved maskinelt tildelte numre med en kontrollerbar sekvens, slik at fullstendig registrering av utfakturerte salg kan etterprøves på en enkel måte.',
  numbering_source_key          = 'bokforingsforskr',
  payment_terms_legal_reference = 'Forsinkelsesrenteloven § 3 — se late_payment_reference. Ingen alminnelig lovfestet betalingsfrist er verifisert i denne omgang.',
  payment_terms_source_key      = 'forsinkelsesrl',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Bokføringsforskriften § 5-2-2 — salgsdokument skal utstedes snarest mulig og senest en måned etter levering, og bokføres deretter på det tidspunktet dokumentet er datert. Denne pakken har ikke i denne omgang funnet en egen bestemmelse i merverdiavgiftsloven som uttrykkelig sier at avgiftsplikten oppstår på et annet tidspunkt enn faktureringen for det alminnelige tilfellet (til forskjell fra § 3-30 og § 11-1, som gjelder hvem som er avgiftspliktig og ikke tidspunktet) — se README.md for hvorfor invoice_date er valgt som en forsiktig lesning og ikke en fullt verifisert artikkel.',
  tax_point_source_key          = 'bokforingsforskr',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Bokføringsloven § 4 nr. 6 og § 13 — bokførte opplysninger skal ikke slettes eller gjøres uleselige, og en korreksjon skjer ved et nytt, sporbart bilag (kreditnota); ingen bestemmelse i denne omgang gir grunnlag for et unntak som lar et bokført dokument gå tilbake til kladd.',
  posted_edit_policy_source_key = 'bokforingsl',
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Den 25. september 2026 pålegger ingen lov næringsdrivende å utveksle strukturerte elektroniske fakturaer seg imellom (B2B). Forskrift om elektronisk faktura i offentlige anskaffelser (FOR-2019-04-01-444), gitt med hjemmel i anskaffelsesloven § 16 tredje ledd og i kraft fra 2. april 2019, pålegger derimot at fakturaer til offentlige oppdragsgivere sendes som EHF-faktura eller PEPPOL BIS Billing versjon 3.0 eller nyere (§ 4) — en B2G-plikt som ikke endrer B2B-svaret. Organisasjonsnummeret fra Enhetsregisteret (ICD 0192, utstedt av Brønnøysundregistrene) identifiserer både parten og, sammen med suffikset «MVA», dens merverdiavgiftsregistrering: Norge har intet eget registreringsnummer for merverdiavgift atskilt fra organisasjonsnummeret, til forskjell fra land med to identifikatorer.',
  einvoice_source_key           = 'ehf-forskrift',
  party_scheme                  = '0192',
  vat_scheme                    = '0192',
  bank_statement_formats        = array['camt.053', 'csv']::text[],
  payment_formats               = array['csv']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'NO';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('NO', 'reverse_charge', 'reverse_charge', 'Omvendt avgiftsplikt — kjøper skal beregne og betale merverdiavgift.', '{}'::jsonb, 10, date '1970-01-01', null, 'Merverdiavgiftsloven § 3-30'),
  ('NO', 'export', 'export', 'Utførsel av varer og tjenester, fritatt for merverdiavgift.', '{}'::jsonb, 20, date '1970-01-01', null, 'Merverdiavgiftsloven §§ 6-21 og 6-22'),
  ('NO', 'exempt', 'exempt', 'Unntatt fra merverdiavgiftsloven.', '{}'::jsonb, 30, date '1970-01-01', null, 'Merverdiavgiftsloven kapittel 3, avsnitt II (unntak)')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
