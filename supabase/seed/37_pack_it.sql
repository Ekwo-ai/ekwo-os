-- Ekwo OS — Italia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/it at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build it`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633 — Istituzione e disciplina dell'imposta sul valore aggiunto — testo vigente (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.del.presidente.della.repubblica:1972-10-26;633
--   Decreto-legge 30 agosto 1993, n. 331, convertito con modificazioni dalla legge 29 ottobre 1993, n. 427 — disciplina IVA delle operazioni intracomunitarie, titolo II, capo II — testo vigente (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legge:1993-08-30;331
--   Decreto del Presidente della Repubblica 29 settembre 1973, n. 600 — Disposizioni comuni in materia di accertamento delle imposte sui redditi — testo vigente (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.del.presidente.della.repubblica:1973-09-29;600
--   Regio Decreto 16 marzo 1942, n. 262 — Codice civile, libro V, titolo V, capo V, sezione IX (artt. 2423-2435-bis, bilancio d'esercizio) — testo vigente (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:regio.decreto:1942-03-16;262
--   Decreto legislativo 9 ottobre 2002, n. 231 — Attuazione della direttiva 2000/35/CE relativa alla lotta contro i ritardi di pagamento nelle transazioni commerciali — testo vigente (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2002-10-09;231
--   Legge 27 dicembre 2017, n. 205, art. 1, commi 909-910 — legge di bilancio 2018: obbligo generalizzato di fatturazione elettronica tramite il Sistema di Interscambio dal 1° gennaio 2019 (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:2017-12-27;205
--   Modello IVA 2026, periodo d'imposta 2025 — istruzioni per la compilazione (Agenzia delle Entrate)
--     https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_istr.pdf/2a42fb92-1b76-229a-d0f5-06069d79b514
--   Modello IVA 2026, periodo d'imposta 2025 — modello (Agenzia delle Entrate)
--     https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_mod.pdf/016d3be2-98cb-2ed8-2d66-32408b08b749
--   Decreto del Presidente della Repubblica 22 luglio 1998, n. 322, art. 8, comma 1 — termine di presentazione della dichiarazione annuale IVA, tra il 1° febbraio e il 30 aprile — testo vigente (Normattiva — Presidenza del Consiglio dei Ministri)
--     https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.del.presidente.della.repubblica:1998-07-22;322
--   Provvedimento del Direttore dell'Agenzia delle entrate — regole tecniche per l'emissione e la ricezione delle fatture elettroniche tramite il Sistema di Interscambio, e allegato A, specifiche tecniche versione 1.9.1 (Agenzia delle Entrate)
--     https://www.agenziaentrate.gov.it/portale/aree-tematiche/fatturazione-elettronica
--   Entrata in vigore dei nuovi codici 0210 (Codice Fiscale) e 0211 (Partita IVA) sulla rete Peppol (AGID — Peppol Italia)
--     https://peppol.agid.gov.it/it/news/entrata-in-vigore-nuovi-codici/
--   EN 16931-1 — semantic data model of the core elements of an electronic invoice, required by Directive 2014/55/EU (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — VAT exemption reason code list (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   Dichiarazioni fiscali — invio telematico tramite i servizi Entratel e Fisconline (Agenzia delle Entrate)
--     https://www.agenziaentrate.gov.it/portale/web/guest/dichiarazioni
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('IT', 'Italia', '0.1.0', date '2026-09-22', '20260921145425', 'community', null, null, 'e9db4e3dab701c110c61c04982a178b8e69e348b0b71281701e740207230771c', '[{"key":"dpr-633-1972","title":"Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633 — Istituzione e disciplina dell''imposta sul valore aggiunto — testo vigente","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.del.presidente.della.repubblica:1972-10-26;633","consulted_on":"2026-09-22","kind":"law"},{"key":"dl-331-1993","title":"Decreto-legge 30 agosto 1993, n. 331, convertito con modificazioni dalla legge 29 ottobre 1993, n. 427 — disciplina IVA delle operazioni intracomunitarie, titolo II, capo II — testo vigente","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legge:1993-08-30;331","consulted_on":"2026-09-22","kind":"law"},{"key":"dpr-600-1973","title":"Decreto del Presidente della Repubblica 29 settembre 1973, n. 600 — Disposizioni comuni in materia di accertamento delle imposte sui redditi — testo vigente","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.del.presidente.della.repubblica:1973-09-29;600","consulted_on":"2026-09-22","kind":"law"},{"key":"codice-civile","title":"Regio Decreto 16 marzo 1942, n. 262 — Codice civile, libro V, titolo V, capo V, sezione IX (artt. 2423-2435-bis, bilancio d''esercizio) — testo vigente","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:regio.decreto:1942-03-16;262","consulted_on":"2026-09-22","kind":"law"},{"key":"dlgs-231-2002","title":"Decreto legislativo 9 ottobre 2002, n. 231 — Attuazione della direttiva 2000/35/CE relativa alla lotta contro i ritardi di pagamento nelle transazioni commerciali — testo vigente","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2002-10-09;231","consulted_on":"2026-09-22","kind":"law"},{"key":"legge-205-2017","title":"Legge 27 dicembre 2017, n. 205, art. 1, commi 909-910 — legge di bilancio 2018: obbligo generalizzato di fatturazione elettronica tramite il Sistema di Interscambio dal 1° gennaio 2019","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:2017-12-27;205","consulted_on":"2026-09-22","kind":"law"},{"key":"modello-iva-2026-istr","title":"Modello IVA 2026, periodo d''imposta 2025 — istruzioni per la compilazione","publisher":"Agenzia delle Entrate","url":"https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_istr.pdf/2a42fb92-1b76-229a-d0f5-06069d79b514","consulted_on":"2026-09-22","kind":"form"},{"key":"modello-iva-2026-mod","title":"Modello IVA 2026, periodo d''imposta 2025 — modello","publisher":"Agenzia delle Entrate","url":"https://www.agenziaentrate.gov.it/portale/documents/20143/9602686/IVA_ANNUALE_2026_mod.pdf/016d3be2-98cb-2ed8-2d66-32408b08b749","consulted_on":"2026-09-22","kind":"form"},{"key":"dpr-322-1998","title":"Decreto del Presidente della Repubblica 22 luglio 1998, n. 322, art. 8, comma 1 — termine di presentazione della dichiarazione annuale IVA, tra il 1° febbraio e il 30 aprile — testo vigente","publisher":"Normattiva — Presidenza del Consiglio dei Ministri","url":"https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.del.presidente.della.repubblica:1998-07-22;322","consulted_on":"2026-09-22","kind":"law"},{"key":"provvedimento-fatturapa","title":"Provvedimento del Direttore dell''Agenzia delle entrate — regole tecniche per l''emissione e la ricezione delle fatture elettroniche tramite il Sistema di Interscambio, e allegato A, specifiche tecniche versione 1.9.1","publisher":"Agenzia delle Entrate","url":"https://www.agenziaentrate.gov.it/portale/aree-tematiche/fatturazione-elettronica","consulted_on":"2026-09-22","kind":"regulation"},{"key":"peppol-it-codici","title":"Entrata in vigore dei nuovi codici 0210 (Codice Fiscale) e 0211 (Partita IVA) sulla rete Peppol","publisher":"AGID — Peppol Italia","url":"https://peppol.agid.gov.it/it/news/entrata-in-vigore-nuovi-codici/","consulted_on":"2026-09-22","kind":"guidance"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the core elements of an electronic invoice, required by Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-22","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — VAT category code list (BT-118 and BT-151), the subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-22","kind":"standard"},{"key":"vatex","title":"VATEX — VAT exemption reason code list (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-22","kind":"standard"},{"key":"sede-dichiarazioni","title":"Dichiarazioni fiscali — invio telematico tramite i servizi Entratel e Fisconline","publisher":"Agenzia delle Entrate","url":"https://www.agenziaentrate.gov.it/portale/web/guest/dichiarazioni","consulted_on":"2026-09-22","kind":"portal"}]'::jsonb)
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
  ('IT', 'default', 'Piano dei conti civilistico — schema di stato patrimoniale e conto economico', '{"en":"Chart of accounts — statutory balance sheet and income statement format"}'::jsonb, true, 'companies', array['IT-CC-BS', 'IT-CC-IS']::text[], null, 'Il codice civile impone lo schema dello stato patrimoniale (art. 2424) e del conto economico (art. 2425), non una codifica dei conti: l''Italia non ha, a differenza della Spagna, del Belgio o della Francia, un piano dei conti ufficiale numerato. La numerazione di questo file è quindi una convenzione di questo pacchetto, scelta per rispecchiare le macroclassi e le voci degli articoli 2424 e 2425, e non un testo da citare. Va rivista da un dottore commercialista prima di un uso in produzione — si veda il README', 'codice-civile')
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
  ('IT', 'default', '0010', 'Costi di impianto e di ampliamento', '{"en":"Start-up and expansion costs"}'::jsonb, 'asset_fixed', false, null, 10),
  ('IT', 'default', '0015', 'Costi di sviluppo', '{"en":"Development costs"}'::jsonb, 'asset_fixed', false, null, 20),
  ('IT', 'default', '0020', 'Diritti di brevetto industriale', '{"en":"Industrial patent rights"}'::jsonb, 'asset_fixed', false, null, 30),
  ('IT', 'default', '0025', 'Diritti di utilizzazione di opere dell''ingegno', '{"en":"Rights to intellectual works"}'::jsonb, 'asset_fixed', false, null, 40),
  ('IT', 'default', '0030', 'Concessioni, licenze, marchi e diritti simili', '{"en":"Concessions, licences, trademarks and similar rights"}'::jsonb, 'asset_fixed', false, null, 50),
  ('IT', 'default', '0035', 'Licenze d''uso di software', '{"en":"Software licences"}'::jsonb, 'asset_fixed', false, null, 60),
  ('IT', 'default', '0040', 'Avviamento', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 70),
  ('IT', 'default', '0045', 'Migliorie su beni di terzi', '{"en":"Improvements to leasehold property"}'::jsonb, 'asset_fixed', false, null, 80),
  ('IT', 'default', '0050', 'Immobilizzazioni immateriali in corso e acconti', '{"en":"Intangible assets under construction and advances"}'::jsonb, 'asset_fixed', false, null, 90),
  ('IT', 'default', '0090', 'Fondo ammortamento immobilizzazioni immateriali', '{"en":"Accumulated amortisation of intangible assets"}'::jsonb, 'asset_fixed', false, null, 100),
  ('IT', 'default', '0100', 'Terreni', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 110),
  ('IT', 'default', '0105', 'Fabbricati industriali', '{"en":"Industrial buildings"}'::jsonb, 'asset_fixed', false, null, 120),
  ('IT', 'default', '0110', 'Fabbricati civili', '{"en":"Non-industrial buildings"}'::jsonb, 'asset_fixed', false, null, 130),
  ('IT', 'default', '0115', 'Impianti generici', '{"en":"General plant"}'::jsonb, 'asset_fixed', false, null, 140),
  ('IT', 'default', '0120', 'Impianti specifici', '{"en":"Specific plant"}'::jsonb, 'asset_fixed', false, null, 150),
  ('IT', 'default', '0125', 'Macchinario', '{"en":"Machinery"}'::jsonb, 'asset_fixed', false, null, 160),
  ('IT', 'default', '0130', 'Attrezzatura industriale e commerciale', '{"en":"Industrial and commercial equipment"}'::jsonb, 'asset_fixed', false, null, 170),
  ('IT', 'default', '0135', 'Mobili e arredi', '{"en":"Furniture and fittings"}'::jsonb, 'asset_fixed', false, null, 180),
  ('IT', 'default', '0140', 'Macchine d''ufficio elettroniche', '{"en":"Electronic office equipment"}'::jsonb, 'asset_fixed', false, null, 190),
  ('IT', 'default', '0145', 'Automezzi', '{"en":"Commercial vehicles"}'::jsonb, 'asset_fixed', false, null, 200),
  ('IT', 'default', '0150', 'Autovetture', '{"en":"Motor cars"}'::jsonb, 'asset_fixed', false, null, 210),
  ('IT', 'default', '0155', 'Immobilizzazioni materiali in corso e acconti', '{"en":"Tangible assets under construction and advances"}'::jsonb, 'asset_fixed', false, null, 220),
  ('IT', 'default', '0190', 'Fondo ammortamento immobilizzazioni materiali', '{"en":"Accumulated depreciation of tangible assets"}'::jsonb, 'asset_fixed', false, null, 230),
  ('IT', 'default', '0200', 'Partecipazioni in imprese controllate', '{"en":"Investments in subsidiaries"}'::jsonb, 'asset_non_current', false, null, 240),
  ('IT', 'default', '0205', 'Partecipazioni in imprese collegate', '{"en":"Investments in associates"}'::jsonb, 'asset_non_current', false, null, 250),
  ('IT', 'default', '0210', 'Partecipazioni in altre imprese', '{"en":"Investments in other undertakings"}'::jsonb, 'asset_non_current', false, null, 260),
  ('IT', 'default', '0220', 'Crediti finanziari verso imprese controllate', '{"en":"Financial receivables from subsidiaries"}'::jsonb, 'asset_non_current', false, null, 270),
  ('IT', 'default', '0225', 'Crediti finanziari verso imprese collegate', '{"en":"Financial receivables from associates"}'::jsonb, 'asset_non_current', false, null, 280),
  ('IT', 'default', '0230', 'Altri crediti finanziari immobilizzati', '{"en":"Other non-current financial receivables"}'::jsonb, 'asset_non_current', false, null, 290),
  ('IT', 'default', '1000', 'Materie prime', '{"en":"Raw materials"}'::jsonb, 'asset_current', false, null, 300),
  ('IT', 'default', '1005', 'Semilavorati', '{"en":"Semi-finished products"}'::jsonb, 'asset_current', false, null, 310),
  ('IT', 'default', '1010', 'Prodotti in corso di lavorazione', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 320),
  ('IT', 'default', '1015', 'Prodotti finiti', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 330),
  ('IT', 'default', '1020', 'Merci', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, null, 340),
  ('IT', 'default', '1025', 'Acconti a fornitori per rimanenze', '{"en":"Advances to suppliers for inventories"}'::jsonb, 'asset_current', false, null, 350),
  ('IT', 'default', '1100', 'Crediti verso clienti Italia', '{"en":"Trade receivables — Italy"}'::jsonb, 'asset_receivable', true, null, 360),
  ('IT', 'default', '1101', 'Crediti verso clienti UE', '{"en":"Trade receivables — EU"}'::jsonb, 'asset_receivable', true, null, 370),
  ('IT', 'default', '1102', 'Crediti verso clienti extra-UE', '{"en":"Trade receivables — outside the EU"}'::jsonb, 'asset_receivable', true, null, 380),
  ('IT', 'default', '1103', 'Clienti c/fatture da emettere', '{"en":"Accrued receivables for invoices to be issued"}'::jsonb, 'asset_receivable', true, null, 390),
  ('IT', 'default', '1104', 'Clienti insoluti', '{"en":"Doubtful trade receivables"}'::jsonb, 'asset_receivable', true, null, 400),
  ('IT', 'default', '1105', 'Fondo svalutazione crediti verso clienti', '{"en":"Allowance for doubtful trade receivables"}'::jsonb, 'asset_current', false, null, 410),
  ('IT', 'default', '1110', 'Erario c/IVA a credito', '{"en":"VAT receivable from the tax authority"}'::jsonb, 'asset_current', true, null, 420),
  ('IT', 'default', '1115', 'Erario c/acconti imposte dirette', '{"en":"Advance payments of direct taxes"}'::jsonb, 'asset_current', false, null, 430),
  ('IT', 'default', '1120', 'Crediti verso INPS', '{"en":"Receivables from the National Social Security Institute (INPS)"}'::jsonb, 'asset_current', false, null, 440),
  ('IT', 'default', '1125', 'Anticipi a fornitori', '{"en":"Advances to suppliers"}'::jsonb, 'asset_current', false, null, 450),
  ('IT', 'default', '1130', 'Cauzioni attive', '{"en":"Guarantee deposits paid"}'::jsonb, 'asset_current', false, null, 460),
  ('IT', 'default', '1135', 'Crediti diversi', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 470),
  ('IT', 'default', '1300', 'Banca c/c 1', '{"en":"Bank current account 1"}'::jsonb, 'asset_cash', false, null, 480),
  ('IT', 'default', '1305', 'Banca c/c 2', '{"en":"Bank current account 2"}'::jsonb, 'asset_cash', false, null, 490),
  ('IT', 'default', '1310', 'Cassa contanti', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 500),
  ('IT', 'default', '1315', 'Assegni', '{"en":"Cheques"}'::jsonb, 'asset_cash', false, null, 510),
  ('IT', 'default', '1400', 'Ratei attivi', '{"en":"Accrued income"}'::jsonb, 'asset_prepayments', false, null, 520),
  ('IT', 'default', '1410', 'Risconti attivi', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 530),
  ('IT', 'default', '2000', 'Debiti verso banche c/c passivi', '{"en":"Bank overdrafts"}'::jsonb, 'liability_current', false, null, 540),
  ('IT', 'default', '2010', 'Mutui passivi', '{"en":"Bank loans"}'::jsonb, 'liability_current', false, null, 550),
  ('IT', 'default', '2100', 'Debiti verso fornitori Italia', '{"en":"Trade payables — Italy"}'::jsonb, 'liability_payable', true, null, 560),
  ('IT', 'default', '2105', 'Debiti verso fornitori UE', '{"en":"Trade payables — EU"}'::jsonb, 'liability_payable', true, null, 570),
  ('IT', 'default', '2110', 'Debiti verso fornitori extra-UE', '{"en":"Trade payables — outside the EU"}'::jsonb, 'liability_payable', true, null, 580),
  ('IT', 'default', '2115', 'Fornitori c/fatture da ricevere', '{"en":"Accrued payables for invoices to be received"}'::jsonb, 'liability_payable', true, null, 590),
  ('IT', 'default', '2200', 'Erario c/IVA a debito', '{"en":"VAT payable to the tax authority"}'::jsonb, 'liability_current', true, null, 600),
  ('IT', 'default', '2210', 'Erario c/ritenute da versare', '{"en":"Withholding tax payable to the tax authority"}'::jsonb, 'liability_current', false, null, 610),
  ('IT', 'default', '2220', 'Erario c/IRES da versare', '{"en":"Corporate income tax (IRES) payable"}'::jsonb, 'liability_current', false, null, 620),
  ('IT', 'default', '2230', 'Erario c/IRAP da versare', '{"en":"Regional production tax (IRAP) payable"}'::jsonb, 'liability_current', false, null, 630),
  ('IT', 'default', '2300', 'Debiti verso INPS', '{"en":"Payables to the National Social Security Institute (INPS)"}'::jsonb, 'liability_current', false, null, 640),
  ('IT', 'default', '2305', 'Debiti verso INAIL', '{"en":"Payables to the National Institute for Insurance against Accidents at Work (INAIL)"}'::jsonb, 'liability_current', false, null, 650),
  ('IT', 'default', '2310', 'Debiti verso dipendenti per retribuzioni', '{"en":"Payables to employees for wages"}'::jsonb, 'liability_current', false, null, 660),
  ('IT', 'default', '2315', 'Debiti verso dipendenti per ferie e permessi maturati', '{"en":"Payables to employees for accrued leave"}'::jsonb, 'liability_current', false, null, 670),
  ('IT', 'default', '2320', 'Fondo trattamento di fine rapporto', '{"en":"Employee severance provision (TFR)"}'::jsonb, 'liability_current', false, null, 680),
  ('IT', 'default', '2340', 'Cauzioni passive', '{"en":"Guarantee deposits received"}'::jsonb, 'liability_current', false, null, 690),
  ('IT', 'default', '2350', 'Debiti diversi', '{"en":"Other payables"}'::jsonb, 'liability_current', false, null, 700),
  ('IT', 'default', '2400', 'Ratei passivi', '{"en":"Accrued expenses"}'::jsonb, 'liability_current', false, null, 710),
  ('IT', 'default', '2410', 'Risconti passivi', '{"en":"Deferred income"}'::jsonb, 'liability_current', false, null, 720),
  ('IT', 'default', '2900', 'Partite in sospeso', '{"en":"Suspense items"}'::jsonb, 'liability_current', true, null, 730),
  ('IT', 'default', '3000', 'Capitale sociale', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 740),
  ('IT', 'default', '3010', 'Riserva legale', '{"en":"Legal reserve"}'::jsonb, 'equity', false, null, 750),
  ('IT', 'default', '3020', 'Riserva straordinaria', '{"en":"Extraordinary reserve"}'::jsonb, 'equity', false, null, 760),
  ('IT', 'default', '3025', 'Riserva statutaria', '{"en":"Statutory reserve"}'::jsonb, 'equity', false, null, 770),
  ('IT', 'default', '3030', 'Riserva da sovrapprezzo azioni', '{"en":"Share premium reserve"}'::jsonb, 'equity', false, null, 780),
  ('IT', 'default', '3100', 'Utili portati a nuovo', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 790),
  ('IT', 'default', '3105', 'Perdite portate a nuovo', '{"en":"Accumulated losses carried forward"}'::jsonb, 'equity_retained', false, null, 800),
  ('IT', 'default', '3200', 'Utile (perdita) dell''esercizio', '{"en":"Profit (loss) for the year"}'::jsonb, 'equity', false, null, 810),
  ('IT', 'default', '4000', 'Ricavi delle vendite di prodotti', '{"en":"Revenue from sales of products"}'::jsonb, 'income', false, null, 820),
  ('IT', 'default', '4005', 'Ricavi delle vendite di merci', '{"en":"Revenue from sales of merchandise"}'::jsonb, 'income', false, null, 830),
  ('IT', 'default', '4010', 'Ricavi delle prestazioni di servizi', '{"en":"Revenue from services"}'::jsonb, 'income', false, null, 840),
  ('IT', 'default', '4020', 'Resi su vendite', '{"en":"Sales returns"}'::jsonb, 'income', false, null, 850),
  ('IT', 'default', '4025', 'Abbuoni e sconti su vendite', '{"en":"Sales allowances and discounts"}'::jsonb, 'income', false, null, 860),
  ('IT', 'default', '4300', 'Ricavi e proventi diversi', '{"en":"Miscellaneous revenue and income"}'::jsonb, 'income_other', false, null, 870),
  ('IT', 'default', '4305', 'Plusvalenze da alienazione di beni strumentali', '{"en":"Gains on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 880),
  ('IT', 'default', '4310', 'Sopravvenienze attive', '{"en":"Non-recurring income"}'::jsonb, 'income_other', false, null, 890),
  ('IT', 'default', '4320', 'Proventi da partecipazioni', '{"en":"Income from investments"}'::jsonb, 'income_other', false, null, 900),
  ('IT', 'default', '4330', 'Interessi attivi bancari', '{"en":"Bank interest income"}'::jsonb, 'income_other', false, null, 910),
  ('IT', 'default', '4335', 'Interessi attivi diversi', '{"en":"Other interest income"}'::jsonb, 'income_other', false, null, 920),
  ('IT', 'default', '4340', 'Utili su cambi', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, null, 930),
  ('IT', 'default', '5000', 'Acquisti di materie prime', '{"en":"Purchases of raw materials"}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('IT', 'default', '5005', 'Acquisti di merci', '{"en":"Purchases of merchandise"}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('IT', 'default', '5010', 'Acquisti di materiali di consumo', '{"en":"Purchases of consumables"}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('IT', 'default', '5015', 'Trasporti su acquisti', '{"en":"Freight on purchases"}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('IT', 'default', '5100', 'Spese telefoniche', '{"en":"Telephone expenses"}'::jsonb, 'expense', false, null, 980),
  ('IT', 'default', '5105', 'Spese per energia elettrica', '{"en":"Electricity expenses"}'::jsonb, 'expense', false, null, 990),
  ('IT', 'default', '5110', 'Spese postali', '{"en":"Postal expenses"}'::jsonb, 'expense', false, null, 1000),
  ('IT', 'default', '5115', 'Spese di pulizia', '{"en":"Cleaning expenses"}'::jsonb, 'expense', false, null, 1010),
  ('IT', 'default', '5120', 'Consulenze legali e notarili', '{"en":"Legal and notarial fees"}'::jsonb, 'expense', false, null, 1020),
  ('IT', 'default', '5125', 'Consulenze fiscali e contabili', '{"en":"Tax and accounting fees"}'::jsonb, 'expense', false, null, 1030),
  ('IT', 'default', '5130', 'Compensi agli amministratori', '{"en":"Directors'' fees"}'::jsonb, 'expense', false, null, 1040),
  ('IT', 'default', '5135', 'Provvigioni passive', '{"en":"Commissions paid"}'::jsonb, 'expense', false, null, 1050),
  ('IT', 'default', '5140', 'Spese di manutenzione e riparazione', '{"en":"Maintenance and repair expenses"}'::jsonb, 'expense', false, null, 1060),
  ('IT', 'default', '5145', 'Assicurazioni', '{"en":"Insurance premiums"}'::jsonb, 'expense', false, null, 1070),
  ('IT', 'default', '5200', 'Canoni di leasing', '{"en":"Lease payments"}'::jsonb, 'expense', false, null, 1080),
  ('IT', 'default', '5205', 'Affitti passivi', '{"en":"Rent expense"}'::jsonb, 'expense', false, null, 1090),
  ('IT', 'default', '5250', 'Salari e stipendi', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, null, 1100),
  ('IT', 'default', '5255', 'Oneri sociali INPS', '{"en":"Social security contributions (INPS)"}'::jsonb, 'expense', false, null, 1110),
  ('IT', 'default', '5260', 'Oneri sociali INAIL', '{"en":"Accident insurance contributions (INAIL)"}'::jsonb, 'expense', false, null, 1120),
  ('IT', 'default', '5265', 'Accantonamento trattamento di fine rapporto', '{"en":"Severance provision (TFR) accrual"}'::jsonb, 'expense', false, null, 1130),
  ('IT', 'default', '5270', 'Altri costi per il personale', '{"en":"Other personnel costs"}'::jsonb, 'expense', false, null, 1140),
  ('IT', 'default', '5300', 'Ammortamento delle immobilizzazioni immateriali', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, null, 1150),
  ('IT', 'default', '5305', 'Ammortamento delle immobilizzazioni materiali', '{"en":"Depreciation of tangible assets"}'::jsonb, 'expense_depreciation', false, null, 1160),
  ('IT', 'default', '5310', 'Svalutazione crediti verso clienti', '{"en":"Write-down of trade receivables"}'::jsonb, 'expense', false, null, 1170),
  ('IT', 'default', '5400', 'Minusvalenze da alienazione di beni strumentali', '{"en":"Losses on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1180),
  ('IT', 'default', '5405', 'Sopravvenienze passive', '{"en":"Non-recurring expenses"}'::jsonb, 'expense', false, null, 1190),
  ('IT', 'default', '5410', 'Oneri diversi di gestione', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, null, 1200),
  ('IT', 'default', '5460', 'Arrotondamenti passivi', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1210),
  ('IT', 'default', '8000', 'Interessi passivi bancari', '{"en":"Bank interest expense"}'::jsonb, 'expense', false, null, 1220),
  ('IT', 'default', '8005', 'Interessi passivi diversi', '{"en":"Other interest expense"}'::jsonb, 'expense', false, null, 1230),
  ('IT', 'default', '8010', 'Perdite su cambi', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, null, 1240),
  ('IT', 'default', '8200', 'IRES corrente', '{"en":"Corporate income tax (IRES) — current"}'::jsonb, 'expense', false, null, 1250),
  ('IT', 'default', '8205', 'IRAP corrente', '{"en":"Regional production tax (IRAP) — current"}'::jsonb, 'expense', false, null, 1260)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('IT', 'ACQ', 'Giornale acquisti', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('IT', 'APE', 'Scrittura di apertura', '{"en":"Opening entry"}'::jsonb, 'opening', 60),
  ('IT', 'BAN', 'Giornale di banca', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('IT', 'CAS', 'Giornale di cassa', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('IT', 'VAR', 'Operazioni diverse', '{"en":"Miscellaneous operations"}'::jsonb, 'general', 50),
  ('IT', 'VEN', 'Giornale vendite', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('IT', 'IT-P-10', 'Acquisti — aliquota ridotta 10%', '{"en":"Purchases — reduced rate 10%"}'::jsonb, null, 'percent', 10, 'purchase', 'domestic', date '1997-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 3, e art. 19', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-P-22', 'Acquisti — aliquota ordinaria 22%', '{"en":"Purchases — standard rate 22%"}'::jsonb, null, 'percent', 22, 'purchase', 'domestic', date '2013-10-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 1, e art. 19 — detrazione dell''imposta assolta sugli acquisti inerenti all''attività', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-P-EXT-22', 'Acquisti di servizi da soggetto non stabilito nell''Unione — integrazione al 22%', '{"en":"Services from a supplier not established in the Union — self-assessed at 22%"}'::jsonb, null, 'percent', 22, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 2 — il committente italiano assolve l''imposta mediante autofattura o integrazione per le prestazioni di servizi generiche rese da un soggetto non stabilito nell''Unione europea (art. 7-ter)', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-P-ICG-22', 'Acquisti intracomunitari di beni — integrazione al 22%', '{"en":"Intra-Community acquisitions of goods — self-assessed at 22%"}'::jsonb, null, 'percent', 22, 'purchase', 'intracom_acquisition_goods', date '1993-01-01', null, 'Decreto-legge 30 agosto 1993, n. 331, art. 38 — l''acquisto intracomunitario di beni è soggetto a imposta; art. 46, comma 1, e art. 47, comma 1 — l''acquirente integra la fattura del cedente con l''IVA italiana e la annota sia nel registro delle fatture emesse (rigo VJ9, imposta dovuta) sia, ai fini della detrazione, nel registro degli acquisti (rigo VF13, tra gli acquisti imponibili al 22%, imposta detraibile). Una sola posting di base, riportata nei due righi, come per l''acquisizione intracomunitaria estone di docs/packs.md', 'K', 'VATEX-EU-IC', 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dl-331-1993', null, null, null, null),
  ('IT', 'IT-P-ICS-22', 'Acquisti di servizi generici da soggetto passivo UE — integrazione al 22%', '{"en":"Generic services from an EU taxable person — self-assessed at 22%"}'::jsonb, null, 'percent', 22, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 2 — il committente italiano assolve l''imposta mediante il meccanismo dell''inversione contabile per le prestazioni di servizi generiche rese da un soggetto passivo stabilito in un altro Stato membro (art. 7-ter). Il modello IVA non riserva un rigo distinto ai servizi UE rispetto ai servizi extra-UE: entrambi confluiscono nel rigo VJ3, ed è la categoria dell''imposta — non il modello — a distinguerli sulla fattura', 'K', 'VATEX-EU-IC', 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-P-RA-20', 'Ritenuta d''acconto 20% — compensi per lavoro autonomo', '{"en":"Withholding tax 20% — self-employment fees"}'::jsonb, null, 'percent', 20, 'purchase', 'not_subject', date '1973-01-01', null, 'Decreto del Presidente della Repubblica 29 settembre 1973, n. 600, art. 25, comma 1 — i soggetti indicati nel primo comma dell''art. 23 (sostituti d''imposta) che corrispondono compensi per prestazioni di lavoro autonomo devono operare all''atto del pagamento una ritenuta del 20% a titolo di acconto dell''IRPEF dovuta dal percipiente, con obbligo di rivalsa. Non è un''imposta sul valore aggiunto: nessuna casella della dichiarazione IVA la riguarda, e la somma resta dovuta all''erario su un conto di attesa fino al versamento', null, null, 160, 'withholding', true, array['buyer_status']::tax_condition[], null, false, false, null, 'dpr-600-1973', null, null, null, null),
  ('IT', 'IT-S-10', 'Vendite — aliquota ridotta 10%', '{"en":"Sales — reduced rate 10%"}'::jsonb, null, 'percent', 10, 'sale', 'domestic', date '1997-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 3 — beni e servizi elencati nella parte III della tabella A allegata', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-22', 'Vendite — aliquota ordinaria 22%', '{"en":"Sales — standard rate 22%"}'::jsonb, null, 'percent', 22, 'sale', 'domestic', date '2013-10-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 1 — aliquota ordinaria, elevata al 22% dal 1° ottobre 2013 (decreto-legge 26 giugno 2012, n. 63, art. 1, comma 480, lettera f), come da ultimo modificato dal decreto-legge 30 agosto 2013, n. 102)', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-4', 'Vendite — aliquota minima 4%', '{"en":"Sales — minimum rate 4%"}'::jsonb, null, 'percent', 4, 'sale', 'domestic', date '1989-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 2 — beni e servizi elencati nella parte II della tabella A allegata, tra cui i generi alimentari di prima necessità, l''abitazione principale «prima casa» e le pubblicazioni', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-5', 'Vendite — aliquota ridotta 5%', '{"en":"Sales — reduced rate 5%"}'::jsonb, null, 'percent', 5, 'sale', 'domestic', date '2016-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 2-bis — beni e servizi elencati nella parte II-bis della tabella A allegata, introdotta dalla legge 28 dicembre 2015, n. 208, art. 1, comma 960', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-EXE', 'Operazioni esenti — prestazioni sanitarie', '{"en":"Exempt supplies — healthcare services"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '1973-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 10, comma 1, n. 18 — prestazioni sanitarie di diagnosi, cura e riabilitazione rese alla persona nell''esercizio delle professioni e arti sanitarie soggette a vigilanza. Il codice VATEX-EU-D è uno dei quattro codici che la lista VATEX associa alla categoria E ed è qui un segnaposto: la scelta tra -D, -F, -I e -J per questo motivo esatto è da confermare da un dottore commercialista, si veda il README', 'E', 'VATEX-EU-D', 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-EXP', 'Cessioni all''esportazione — non imponibile', '{"en":"Exports — not taxable"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '1973-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 8, comma 1, lettera a) — cessioni eseguite mediante trasporto o spedizione dei beni fuori dal territorio dell''Unione europea, a cura o a nome del cedente', 'G', 'VATEX-EU-G', 50, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-ICG', 'Cessioni intracomunitarie di beni — non imponibile', '{"en":"Intra-Community supplies of goods — not taxable"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_goods', date '1993-01-01', null, 'Decreto-legge 30 agosto 1993, n. 331, art. 41, comma 1, lettera a) — cessioni a titolo oneroso di beni trasportati o spediti nel territorio di un altro Stato membro dal cedente o dal cessionario, nei confronti di un soggetto passivo o di un ente non soggetto passivo', 'K', 'VATEX-EU-IC', 60, 'vat', true, array['transport_evidence', 'buyer_status']::tax_condition[], null, false, false, null, 'dl-331-1993', null, null, null, null),
  ('IT', 'IT-S-ICS', 'Prestazioni di servizi generiche rese a soggetto passivo UE — non soggetta', '{"en":"Generic services to an EU taxable person — not subject"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 7-ter, comma 1, lettera a) — le prestazioni di servizi generiche si considerano effettuate nel territorio dello Stato del committente; una prestazione resa a un soggetto passivo stabilito in un altro Stato membro non è quindi soggetta a imposta in Italia (artt. 44 e 196 della direttiva 2006/112/CE)', 'K', 'VATEX-EU-IC', 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-RC-EDIL', 'Subappalto nel settore edile — inversione contabile', '{"en":"Construction subcontracting — domestic reverse charge"}'::jsonb, null, 'percent', 0, 'sale', 'domestic_reverse_charge', date '2007-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 6, lettera a) — prestazioni di servizi, compresa la manodopera, rese nel settore edile da soggetti subappaltatori nei confronti delle imprese che svolgono l''attività di costruzione o ristrutturazione di immobili, o nei confronti dell''appaltatore principale o di un altro subappaltatore', 'AE', 'VATEX-EU-AE', 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null),
  ('IT', 'IT-S-RC-PULIZIE', 'Servizi di pulizia, demolizione, installazione e completamento su edifici — inversione contabile', '{"en":"Cleaning, demolition, installation and completion services on buildings — domestic reverse charge"}'::jsonb, null, 'percent', 0, 'sale', 'domestic_reverse_charge', date '2015-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 6, lettera a-ter) — prestazioni di servizi di pulizia, di demolizione, di installazione di impianti e di completamento relative a edifici, introdotta dalla legge 28 dicembre 2015, n. 208, art. 1, comma 44', 'AE', 'VATEX-EU-AE', 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'dpr-633-1972', null, null, null, null)
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
    ('IT-P-10', 'invoice', 'base', 100, null, 'VF11', array['VF11']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-P-10', 'invoice', 'tax', 100, '1110', 'VF11', array['VF11']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-P-10', 'credit_note', 'base', 100, null, 'VF11', array['VF11']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-P-10', 'credit_note', 'tax', 100, '1110', 'VF11', array['VF11']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-P-22', 'invoice', 'base', 100, null, 'VF13', array['VF13']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-P-22', 'invoice', 'tax', 100, '1110', 'VF13', array['VF13']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-P-22', 'credit_note', 'base', 100, null, 'VF13', array['VF13']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-P-22', 'credit_note', 'tax', 100, '1110', 'VF13', array['VF13']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-P-EXT-22', 'invoice', 'base', 100, null, 'VJ3', array['VJ3', 'VF13']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-P-EXT-22', 'invoice', 'tax', 100, '1110', 'VF13', array['VF13']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-P-EXT-22', 'invoice', 'tax', -100, '2200', 'VJ3', array['VJ3']::text[], 100, 'IT-DICH-IVA', 30),
    ('IT-P-EXT-22', 'credit_note', 'base', 100, null, 'VJ3', array['VJ3', 'VF13']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-P-EXT-22', 'credit_note', 'tax', 100, '1110', 'VF13', array['VF13']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-P-EXT-22', 'credit_note', 'tax', -100, '2200', 'VJ3', array['VJ3']::text[], -100, 'IT-DICH-IVA', 30),
    ('IT-P-ICG-22', 'invoice', 'base', 100, null, 'VJ9', array['VJ9', 'VF13']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-P-ICG-22', 'invoice', 'tax', 100, '1110', 'VF13', array['VF13']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-P-ICG-22', 'invoice', 'tax', -100, '2200', 'VJ9', array['VJ9']::text[], 100, 'IT-DICH-IVA', 30),
    ('IT-P-ICG-22', 'credit_note', 'base', 100, null, 'VJ9', array['VJ9', 'VF13']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-P-ICG-22', 'credit_note', 'tax', 100, '1110', 'VF13', array['VF13']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-P-ICG-22', 'credit_note', 'tax', -100, '2200', 'VJ9', array['VJ9']::text[], -100, 'IT-DICH-IVA', 30),
    ('IT-P-ICS-22', 'invoice', 'base', 100, null, 'VJ3', array['VJ3', 'VF13']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-P-ICS-22', 'invoice', 'tax', 100, '1110', 'VF13', array['VF13']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-P-ICS-22', 'invoice', 'tax', -100, '2200', 'VJ3', array['VJ3']::text[], 100, 'IT-DICH-IVA', 30),
    ('IT-P-ICS-22', 'credit_note', 'base', 100, null, 'VJ3', array['VJ3', 'VF13']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-P-ICS-22', 'credit_note', 'tax', 100, '1110', 'VF13', array['VF13']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-P-ICS-22', 'credit_note', 'tax', -100, '2200', 'VJ3', array['VJ3']::text[], -100, 'IT-DICH-IVA', 30),
    ('IT-P-RA-20', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('IT-P-RA-20', 'invoice', 'tax', -100, '2210', null, null, 100, null, 20),
    ('IT-P-RA-20', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('IT-P-RA-20', 'credit_note', 'tax', -100, '2210', null, null, 100, null, 20),
    ('IT-S-10', 'invoice', 'base', 100, null, 'VE22', array['VE22']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-10', 'invoice', 'tax', 100, '2200', 'VE22', array['VE22']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-S-10', 'credit_note', 'base', 100, null, 'VE22', array['VE22']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-10', 'credit_note', 'tax', 100, '2200', 'VE22', array['VE22']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-S-22', 'invoice', 'base', 100, null, 'VE23', array['VE23']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-22', 'invoice', 'tax', 100, '2200', 'VE23', array['VE23']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-S-22', 'credit_note', 'base', 100, null, 'VE23', array['VE23']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-22', 'credit_note', 'tax', 100, '2200', 'VE23', array['VE23']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-S-4', 'invoice', 'base', 100, null, 'VE20', array['VE20']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-4', 'invoice', 'tax', 100, '2200', 'VE20', array['VE20']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-S-4', 'credit_note', 'base', 100, null, 'VE20', array['VE20']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-4', 'credit_note', 'tax', 100, '2200', 'VE20', array['VE20']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-S-5', 'invoice', 'base', 100, null, 'VE21', array['VE21']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-5', 'invoice', 'tax', 100, '2200', 'VE21', array['VE21']::text[], 100, 'IT-DICH-IVA', 20),
    ('IT-S-5', 'credit_note', 'base', 100, null, 'VE21', array['VE21']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-5', 'credit_note', 'tax', 100, '2200', 'VE21', array['VE21']::text[], -100, 'IT-DICH-IVA', 20),
    ('IT-S-EXE', 'invoice', 'base', 100, null, 'VE33', array['VE33']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-EXE', 'credit_note', 'base', 100, null, 'VE33', array['VE33']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-EXP', 'invoice', 'base', 100, null, 'VE30C2', array['VE30C2']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-EXP', 'credit_note', 'base', 100, null, 'VE30C2', array['VE30C2']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-ICG', 'invoice', 'base', 100, null, 'VE30C3', array['VE30C3']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-ICG', 'credit_note', 'base', 100, null, 'VE30C3', array['VE30C3']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-ICS', 'invoice', 'base', 100, null, 'VE34', array['VE34']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-ICS', 'credit_note', 'base', 100, null, 'VE34', array['VE34']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-RC-EDIL', 'invoice', 'base', 100, null, 'VE35C4', array['VE35C4']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-RC-EDIL', 'credit_note', 'base', 100, null, 'VE35C4', array['VE35C4']::text[], -100, 'IT-DICH-IVA', 10),
    ('IT-S-RC-PULIZIE', 'invoice', 'base', 100, null, 'VE35C8', array['VE35C8']::text[], 100, 'IT-DICH-IVA', 10),
    ('IT-S-RC-PULIZIE', 'credit_note', 'base', 100, null, 'VE35C8', array['VE35C8']::text[], -100, 'IT-DICH-IVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'IT' and t.code = v.tax_code
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
  ('IT', 'IT-DICH-IVA', 'Dichiarazione IVA annuale — Quadri VE, VF, VJ, VL, VX', array['year']::declaration_period[], 'year'::declaration_period, date '2016-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 8 — ogni soggetto passivo presenta annualmente la dichiarazione relativa all''imposta dovuta per l''anno solare precedente. I numeri di rigo e la loro disposizione sono verificati sul Modello IVA 2026 (periodo d''imposta 2025); la ripartizione per aliquota dei righi VE20-VE23 e VF1-VF13 è quella prestampata su tale modello. I campi di un rigo che il modello dispone in colonne separate (ad esempio VE30, campo 2 « Esportazioni » e campo 3 « Cessioni intracomunitarie ») sono trascritti come identificatori di casella distinti — VE30C2, VE30C3 — perché il formato del pacchetto non ammette i due punti nell''identificatore di una casella, riservati alla qualification base/tax/total di un riferimento. `deadline` non è dichiarato: il termine di presentazione corre dal 1° febbraio al 30 aprile dell''anno successivo (decreto del Presidente della Repubblica 22 luglio 1998, n. 322, art. 8, comma 1), cioè l''ultimo giorno del *secondo* mese successivo alla fine del periodo, mentre il vocabolario chiuso di `deadline.rule` conosce solo il giorno o l''ultimo giorno del *primo* mese successivo: nessuna delle tre regole esprime questo termine senza rischiare, in un anno bisestile, una data calcolata dopo il 30 aprile. Si veda la sezione « From Italy » di docs/international.md', true,null, null, null, null, null, null)
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
  ('IT', 'IT-DICH-IVA', 'VE20', 'base', 'Operazioni imponibili — aliquota 4% — imponibile', '{"en":"Taxable operations — 4% rate — taxable amount"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE20 — aliquota prestampata 4%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 2', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE20', 'tax', 'Operazioni imponibili — aliquota 4% — imposta', '{"en":"Taxable operations — 4% rate — tax"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE20 — aliquota prestampata 4%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 2', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE21', 'base', 'Operazioni imponibili — aliquota 5% — imponibile', '{"en":"Taxable operations — 5% rate — taxable amount"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE21 — aliquota prestampata 5%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 2-bis', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE21', 'tax', 'Operazioni imponibili — aliquota 5% — imposta', '{"en":"Taxable operations — 5% rate — tax"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE21 — aliquota prestampata 5%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 2-bis', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE22', 'base', 'Operazioni imponibili — aliquota 10% — imponibile', '{"en":"Taxable operations — 10% rate — taxable amount"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE22 — aliquota prestampata 10%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 3', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE22', 'tax', 'Operazioni imponibili — aliquota 10% — imposta', '{"en":"Taxable operations — 10% rate — tax"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE22 — aliquota prestampata 10%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 3', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE23', 'base', 'Operazioni imponibili — aliquota 22% — imponibile', '{"en":"Taxable operations — 22% rate — taxable amount"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE23 — aliquota prestampata 22%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 1', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE23', 'tax', 'Operazioni imponibili — aliquota 22% — imposta', '{"en":"Taxable operations — 22% rate — tax"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 2, rigo VE23 — aliquota prestampata 22%. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 16, comma 1', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE24', 'total', 'Totale imposta — sezioni 1 e 2', '{"en":"Total tax — sections 1 and 2"}'::jsonb, 90, null, array['VE20:tax', 'VE21:tax', 'VE22:tax', 'VE23:tax']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 3, rigo VE24, colonna imposta — somma dei righi da VE1 a VE11 (regime agricolo, non trattato da questo pacchetto) e da VE20 a VE23. Solo la colonna imposta è transcritta: nessuna riga a valle di questo pacchetto legge la colonna imponibile del rigo VE24', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE26', 'total', 'Totale imposta sulle operazioni imponibili', '{"en":"Total tax on taxable operations"}'::jsonb, 100, null, array['VE24']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 3, rigo VE26 = VE24 ± VE25. Il rigo VE25 (variazioni e arrotondamenti d''imposta) non è scritto da nessuna imposta di questo pacchetto e non compare qui', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE30C2', 'base', 'Operazioni non imponibili — esportazioni', '{"en":"Non-taxable operations — exports"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 4, rigo VE30, campo 2. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 8, comma 1, lettera a)', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE30C3', 'base', 'Operazioni non imponibili — cessioni intracomunitarie', '{"en":"Non-taxable operations — intra-Community supplies"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 4, rigo VE30, campo 3. Decreto-legge 30 agosto 1993, n. 331, art. 41, comma 1, lettera a)', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE33', 'base', 'Operazioni esenti', '{"en":"Exempt operations"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 4, rigo VE33. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 10', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE34', 'base', 'Operazioni non soggette all''imposta per carenza del requisito di territorialità', '{"en":"Operations not subject to tax for lack of territoriality"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 4, rigo VE34. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, artt. da 7 a 7-septies', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE35C4', 'base', 'Operazioni con applicazione del reverse charge — subappalto nel settore edile', '{"en":"Reverse charge operations — construction subcontracting"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 4, rigo VE35, campo 4. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 6, lettera a)', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VE35C8', 'base', 'Operazioni con applicazione del reverse charge — prestazioni comparto edile e settori connessi', '{"en":"Reverse charge operations — building services"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VE, sezione 4, rigo VE35, campo 8. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 6, lettera a-ter)', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF11', 'base', 'Acquisti e importazioni imponibili — aliquota 10% — imponibile', '{"en":"Taxable purchases and imports — 10% rate — taxable amount"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 1, rigo VF11 — aliquota prestampata 10%', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF11', 'tax', 'Acquisti e importazioni imponibili — aliquota 10% — imposta', '{"en":"Taxable purchases and imports — 10% rate — tax"}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 1, rigo VF11 — aliquota prestampata 10%', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF13', 'base', 'Acquisti e importazioni imponibili — aliquota 22% — imponibile', '{"en":"Taxable purchases and imports — 22% rate — taxable amount"}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 1, rigo VF13 — aliquota prestampata 22%. Vi confluiscono gli acquisti interni, gli acquisti intracomunitari e i servizi esteri integrati al 22%', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF13', 'tax', 'Acquisti e importazioni imponibili — aliquota 22% — imposta', '{"en":"Taxable purchases and imports — 22% rate — tax"}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 1, rigo VF13 — aliquota prestampata 22%. Vi confluiscono gli acquisti interni, gli acquisti intracomunitari e i servizi esteri integrati al 22%', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF25', 'total', 'Totale acquisti e importazioni — imposta', '{"en":"Total tax — purchases and imports"}'::jsonb, 230, null, array['VF11:tax', 'VF13:tax']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 2, rigo VF25, colonna imposta — somma dei righi da VF1 a VF13. Solo la colonna imposta è transcritta', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF27', 'total', 'Totale imposta sugli acquisti e importazioni imponibili', '{"en":"Total tax on taxable purchases and imports"}'::jsonb, 240, null, array['VF25']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 2, rigo VF27 = VF25 colonna 2 + VF26. Il rigo VF26 (variazioni e arrotondamenti) non è scritto da nessuna imposta di questo pacchetto', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VF71', 'total', 'IVA ammessa in detrazione', '{"en":"VAT allowed as a deduction"}'::jsonb, 250, null, array['VF27']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VF, sezione 3, rigo VF71. Questo pacchetto non tratta il pro rata (sezione 3-A) né il regime speciale agricolo (sezione 3-B): per un''impresa senza operazioni esenti significative, l''imposta ammessa in detrazione coincide con il rigo VF27', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VJ3', 'base', 'Acquisti di beni e servizi da soggetti non residenti — imponibile', '{"en":"Purchases of goods and services from non-residents — taxable amount"}'::jsonb, 270, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VJ, rigo VJ3. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 2', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VJ3', 'tax', 'Acquisti di beni e servizi da soggetti non residenti — imposta', '{"en":"Purchases of goods and services from non-residents — tax"}'::jsonb, 280, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VJ, rigo VJ3. Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 17, comma 2', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VJ9', 'base', 'Acquisti intracomunitari di beni — imponibile', '{"en":"Intra-Community acquisitions of goods — taxable amount"}'::jsonb, 290, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VJ, rigo VJ9. Decreto-legge 30 agosto 1993, n. 331, art. 38', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VJ9', 'tax', 'Acquisti intracomunitari di beni — imposta', '{"en":"Intra-Community acquisitions of goods — tax"}'::jsonb, 300, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VJ, rigo VJ9. Decreto-legge 30 agosto 1993, n. 331, art. 38', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VJ19', 'total', 'Totale imposta — quadro VJ', '{"en":"Total tax — special operations"}'::jsonb, 310, null, array['VJ3:tax', 'VJ9:tax']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VJ, rigo VJ19 — somma dei righi da VJ1 a VJ18', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL1', 'total', 'IVA a debito', '{"en":"VAT payable"}'::jsonb, 320, null, array['VE26', 'VJ19']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VL, sezione 1, rigo VL1 — somma dei righi VE26 e VJ19', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL2', 'total', 'IVA detraibile', '{"en":"VAT deductible"}'::jsonb, 330, null, array['VF71']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VL, sezione 1, rigo VL2 — importo di cui al rigo VF71', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL3', 'total', 'Imposta dovuta', '{"en":"Tax due"}'::jsonb, 340, null, array['VL1']::text[], array['VL2']::text[], null, null, true, false, null, 'Modello IVA 2026, quadro VL, sezione 1, rigo VL3 = VL1 − VL2, quando positivo', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL4', 'total', 'Imposta a credito', '{"en":"Tax credit"}'::jsonb, 350, null, array['VL2']::text[], array['VL1']::text[], null, null, true, false, null, 'Modello IVA 2026, quadro VL, sezione 1, rigo VL4 = VL2 − VL1, quando positivo', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL32', 'total', 'IVA a debito — sezione 3', '{"en":"Total VAT payable"}'::jsonb, 360, null, array['VL3']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VL, sezione 3, rigo VL32. Questo pacchetto non tratta i righi VL5 a VL31 (eccedenze di anni precedenti, gruppo IVA, rimborsi infrannuali)', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL33', 'total', 'IVA a credito — sezione 3', '{"en":"Total VAT credit"}'::jsonb, 370, null, array['VL4']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VL, sezione 3, rigo VL33', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL38', 'total', 'Totale IVA dovuta', '{"en":"Total VAT due"}'::jsonb, 380, null, array['VL32']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VL, sezione 3, rigo VL38 = VL32 − VL34 − VL35 + VL36. I righi VL34 a VL36 (crediti d''imposta di categorie particolari) non sono trattati da questo pacchetto', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VL39', 'total', 'Totale IVA a credito', '{"en":"Total VAT credit"}'::jsonb, 390, null, array['VL33']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VL, sezione 3, rigo VL39 = VL33 − VL37. Il rigo VL37 (credito ceduto) non è trattato da questo pacchetto', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VX1', 'total', 'IVA da versare', '{"en":"VAT to be paid"}'::jsonb, 400, null, array['VL38']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VX, rigo VX1 — importo di cui al rigo VL38', 'modello-iva-2026-mod'),
  ('IT', 'IT-DICH-IVA', 'VX2', 'total', 'IVA a credito', '{"en":"VAT credit"}'::jsonb, 410, null, array['VL39']::text[], '{}'::text[], null, null, false, false, null, 'Modello IVA 2026, quadro VX, rigo VX2 — eccedenza annuale d''imposta detraibile di cui al rigo VL39', 'modello-iva-2026-mod')
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
  ('IT-CC-BS', 'IT', 'default', 'Stato patrimoniale', 'balance_sheet', 'IT-CC', date '1970-01-01', null, 'Codice civile, art. 2424 — contenuto dello stato patrimoniale. Le lettere e i numeri romani riportati sono le macroclassi e le classi dell''articolo; le voci che nessun conto di questo pacchetto raggiunge (A — crediti verso soci, B — fondi per rischi e oneri, C — trattamento di fine rapporto lavoro subordinato come voce separata dai debiti, III — attività finanziarie che non costituiscono immobilizzazioni) non figurano qui, per la regola per cui una riga senza conto non serve a nulla', 'codice-civile'),
  ('IT-CC-IS', 'IT', 'default', 'Conto economico', 'income_statement', 'IT-CC', date '1970-01-01', null, 'Codice civile, art. 2425 — contenuto del conto economico, forma scalare per natura. Le voci A.2, A.3, A.4, B.11, B.12, B.13 e C.17-bis, che nessun conto di questo pacchetto raggiunge, non figurano qui', 'codice-civile')
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
  ('IT-CC-BS', 'B.I', null, 'Immobilizzazioni immateriali', '{"en":"Intangible fixed assets"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'B.II', null, 'Immobilizzazioni materiali', '{"en":"Tangible fixed assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'B.III', null, 'Immobilizzazioni finanziarie', '{"en":"Financial fixed assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'B', null, 'Totale immobilizzazioni', '{"en":"Total fixed assets"}'::jsonb, 40, 1, true, array['B.I', 'B.II', 'B.III']::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'C.I', null, 'Rimanenze', '{"en":"Inventories"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'C.II', null, 'Crediti', '{"en":"Receivables"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'C.IV', null, 'Disponibilità liquide', '{"en":"Cash and cash equivalents"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'C', null, 'Totale attivo circolante', '{"en":"Total current assets"}'::jsonb, 80, 1, true, array['C.I', 'C.II', 'C.IV']::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D-ATT', null, 'Ratei e risconti attivi', '{"en":"Accrued income and prepaid expenses"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'TOT-ATT', null, 'Totale attivo', '{"en":"Total assets"}'::jsonb, 100, 1, true, array['B', 'C', 'D-ATT']::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'A.I', null, 'Capitale', '{"en":"Share capital"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'A.IV-VI', null, 'Riserva legale e altre riserve', '{"en":"Legal reserve and other reserves"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'A.VIII', null, 'Utili (perdite) portati a nuovo', '{"en":"Retained earnings (accumulated losses)"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'A.IX', null, 'Utile (perdita) dell''esercizio', '{"en":"Profit (loss) for the year"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'A', null, 'Totale patrimonio netto', '{"en":"Total equity"}'::jsonb, 150, 1, true, array['A.I', 'A.IV-VI', 'A.VIII', 'A.IX']::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D.banche', null, 'Debiti verso banche', '{"en":"Payables to banks"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D.fornitori', null, 'Debiti verso fornitori', '{"en":"Trade payables"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D.tributari', null, 'Debiti tributari', '{"en":"Tax payables"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D.previdenza', null, 'Debiti verso istituti di previdenza e di sicurezza sociale', '{"en":"Payables to social security institutions"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D.personale', null, 'Debiti verso il personale e fondo TFR', '{"en":"Payables to employees and severance provision"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D.altri', null, 'Altri debiti', '{"en":"Other payables"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'D', null, 'Totale debiti', '{"en":"Total payables"}'::jsonb, 220, 1, true, array['D.banche', 'D.fornitori', 'D.tributari', 'D.previdenza', 'D.personale', 'D.altri']::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'E-PASS', null, 'Ratei e risconti passivi', '{"en":"Accrued expenses and deferred income"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-BS', 'TOT-PASS', null, 'Totale patrimonio netto e passivo', '{"en":"Total equity and liabilities"}'::jsonb, 240, 1, true, array['A', 'D', 'E-PASS']::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'A.1', null, 'Ricavi delle vendite e delle prestazioni', '{"en":"Revenue from sales and services"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'A.5', null, 'Altri ricavi e proventi', '{"en":"Other revenue and income"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'A', null, 'Totale valore della produzione', '{"en":"Total value of production"}'::jsonb, 30, 1, true, array['A.1', 'A.5']::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.6', null, 'Costi per materie prime, sussidiarie, di consumo e di merci', '{"en":"Costs for raw materials, consumables and goods"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.7', null, 'Costi per servizi', '{"en":"Costs for services"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.8', null, 'Costi per godimento di beni di terzi', '{"en":"Costs for the use of third-party assets"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.9.a', 'B.9', 'Salari e stipendi', '{"en":"Wages and salaries"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.9.b', 'B.9', 'Oneri sociali', '{"en":"Social security contributions"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.9.c', 'B.9', 'Trattamento di fine rapporto e altri costi', '{"en":"Severance provision and other personnel costs"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.9', null, 'Costi per il personale', '{"en":"Personnel costs"}'::jsonb, 100, 1, true, array['B.9.a', 'B.9.b', 'B.9.c']::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.10.a', 'B.10', 'Ammortamento delle immobilizzazioni immateriali', '{"en":"Amortisation of intangible assets"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.10.b', 'B.10', 'Ammortamento delle immobilizzazioni materiali', '{"en":"Depreciation of tangible assets"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.10.c', 'B.10', 'Svalutazione dei crediti compresi nell''attivo circolante', '{"en":"Write-down of receivables in current assets"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.10', null, 'Ammortamenti e svalutazioni', '{"en":"Amortisation, depreciation and write-downs"}'::jsonb, 140, 1, true, array['B.10.a', 'B.10.b', 'B.10.c']::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B.14', null, 'Oneri diversi di gestione', '{"en":"Other operating expenses"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'B', null, 'Totale costi della produzione', '{"en":"Total costs of production"}'::jsonb, 160, 1, true, array['B.6', 'B.7', 'B.8', 'B.9', 'B.10', 'B.14']::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'DIFF', null, 'Differenza tra valore e costi della produzione', '{"en":"Difference between value and costs of production"}'::jsonb, 170, 1, true, array['A']::text[], array['B']::text[], null, null, null),
  ('IT-CC-IS', 'C.16', null, 'Altri proventi finanziari', '{"en":"Other financial income"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'C.17', null, 'Interessi e altri oneri finanziari', '{"en":"Interest and other financial expenses"}'::jsonb, 190, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', 'C', null, 'Totale proventi e oneri finanziari', '{"en":"Total financial income and expenses"}'::jsonb, 200, 1, true, array['C.16']::text[], array['C.17']::text[], null, null, null),
  ('IT-CC-IS', 'RISULTATO-ANTE', null, 'Risultato prima delle imposte', '{"en":"Result before taxes"}'::jsonb, 210, 1, true, array['DIFF', 'C']::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', '20', null, 'Imposte sul reddito dell''esercizio', '{"en":"Income tax expense for the year"}'::jsonb, 220, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('IT-CC-IS', '21', null, 'Utile (perdita) dell''esercizio', '{"en":"Profit (loss) for the year"}'::jsonb, 230, 1, true, array['RISULTATO-ANTE']::text[], array['20']::text[], null, null, null)
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
    ('IT-CC-BS', 'B.I', 10, 'code_range', '0010', '0099', null, 'any'),
    ('IT-CC-BS', 'B.II', 10, 'code_range', '0100', '0199', null, 'any'),
    ('IT-CC-BS', 'B.III', 10, 'code_range', '0200', '0299', null, 'any'),
    ('IT-CC-BS', 'C.I', 10, 'code_range', '1000', '1099', null, 'any'),
    ('IT-CC-BS', 'C.II', 10, 'code_range', '1100', '1199', null, 'any'),
    ('IT-CC-BS', 'C.IV', 10, 'code_range', '1300', '1399', null, 'any'),
    ('IT-CC-BS', 'D-ATT', 10, 'code_range', '1400', '1499', null, 'any'),
    ('IT-CC-BS', 'A.I', 10, 'account_code', '3000', null, null, 'any'),
    ('IT-CC-BS', 'A.IV-VI', 10, 'code_range', '3010', '3039', null, 'any'),
    ('IT-CC-BS', 'A.VIII', 10, 'code_range', '3100', '3109', null, 'any'),
    ('IT-CC-BS', 'A.IX', 10, 'account_code', '3200', null, null, 'any'),
    ('IT-CC-BS', 'D.banche', 10, 'code_range', '2000', '2099', null, 'any'),
    ('IT-CC-BS', 'D.fornitori', 10, 'code_range', '2100', '2199', null, 'any'),
    ('IT-CC-BS', 'D.tributari', 10, 'code_range', '2200', '2239', null, 'any'),
    ('IT-CC-BS', 'D.previdenza', 10, 'code_range', '2300', '2309', null, 'any'),
    ('IT-CC-BS', 'D.personale', 10, 'code_range', '2310', '2329', null, 'any'),
    ('IT-CC-BS', 'D.altri', 10, 'code_range', '2340', '2359', null, 'any'),
    ('IT-CC-BS', 'D.altri', 20, 'account_code', '2900', null, null, 'any'),
    ('IT-CC-BS', 'E-PASS', 10, 'code_range', '2400', '2499', null, 'any'),
    ('IT-CC-IS', 'A.1', 10, 'code_range', '4000', '4099', null, 'any'),
    ('IT-CC-IS', 'A.5', 10, 'code_range', '4300', '4329', null, 'any'),
    ('IT-CC-IS', 'B.6', 10, 'code_range', '5000', '5019', null, 'any'),
    ('IT-CC-IS', 'B.7', 10, 'code_range', '5100', '5149', null, 'any'),
    ('IT-CC-IS', 'B.8', 10, 'code_range', '5200', '5249', null, 'any'),
    ('IT-CC-IS', 'B.9.a', 10, 'account_code', '5250', null, null, 'any'),
    ('IT-CC-IS', 'B.9.b', 10, 'code_range', '5255', '5264', null, 'any'),
    ('IT-CC-IS', 'B.9.c', 10, 'code_range', '5265', '5299', null, 'any'),
    ('IT-CC-IS', 'B.10.a', 10, 'account_code', '5300', null, null, 'any'),
    ('IT-CC-IS', 'B.10.b', 10, 'account_code', '5305', null, null, 'any'),
    ('IT-CC-IS', 'B.10.c', 10, 'account_code', '5310', null, null, 'any'),
    ('IT-CC-IS', 'B.14', 10, 'code_range', '5400', '5469', null, 'any'),
    ('IT-CC-IS', 'C.16', 10, 'code_range', '4330', '4349', null, 'any'),
    ('IT-CC-IS', 'C.17', 10, 'code_range', '8000', '8019', null, 'any'),
    ('IT-CC-IS', '20', 10, 'code_range', '8200', '8219', null, 'any')
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
  ('IT', 'Italia', '{"en":"Italy"}'::jsonb, array['it', 'en']::text[], 'EUR', '1100', '2100', '2900', '5460', '3100', '4000', '5000', '1300', '1310', 'VEN', 'ACQ', 'VAR', 'it', 'result_accounts', '3200', '3200', null, 'APE', 'half_up', default, '4340', '8010', null, null, null, null, '2200', '1110', 'Scrittura di apertura', 'year'::declaration_period)
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
  late_payment_reference        = 'Decreto legislativo 9 ottobre 2002, n. 231, art. 5, comma 2 — interesse di mora: il tasso di riferimento della Banca centrale europea per le operazioni di rifinanziamento più recenti, maggiorato di otto punti percentuali; art. 6, comma 2 — indennizzo forfettario di 40 euro per i costi di recupero, dovuto senza bisogno di costituzione in mora',
  numbering_legal_reference     = 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 21, comma 2, lettera b) — numero progressivo che identifichi la fattura in modo univoco. Dal 1° gennaio 2013 (legge 24 dicembre 2012, n. 228, art. 1, comma 325, lettera d) la norma non impone più l''azzeramento del numero a ogni anno: basta la progressività e l''univocità. Una serie per anno, con l''anno nel numero, resta la convenzione più diffusa ed è quella proposta da questo pacchetto',
  numbering_source_key          = 'dpr-633-1972',
  payment_terms_legal_reference = 'Decreto legislativo 9 ottobre 2002, n. 231, art. 4, comma 2 — in mancanza di pattuizione, trenta giorni dal ricevimento della fattura o di richiesta di pagamento equivalente; art. 7, comma 1 — un termine superiore a sessanta giorni concordato tra imprese deve essere provato per iscritto e non deve essere gravemente iniquo per il creditore',
  payment_terms_source_key      = 'dlgs-231-2002',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 6, comma 1 — le cessioni di beni si considerano effettuate al momento della consegna o spedizione; comma 3 — le prestazioni di servizi al momento del pagamento del corrispettivo; comma 4 — se anteriormente al verificarsi di questi eventi è emessa fattura, l''operazione si considera effettuata, limitatamente all''importo fatturato, alla data della fattura. La regola generale è dunque la consegna o il pagamento, con la fattura emessa in anticipo che anticipa il momento impositivo',
  tax_point_source_key          = 'dpr-633-1972',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Codice civile, art. 2219 — le scritture contabili devono essere tenute senza abrasioni e ogni cancellazione deve risultare da apposita annotazione; Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 26 — una fattura registrata si rettifica con una nota di variazione, mai con una cancellazione. Una fattura contabilizzata si annulla con una nota di credito che la richiama, mai tornando a bozza',
  posted_edit_policy_source_key = 'codice-civile',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Legge 27 dicembre 2017, n. 205, art. 1, commi 909-910, che modifica il decreto legislativo 5 agosto 2015, n. 127, art. 1 — dal 1° gennaio 2019 la fattura tra soggetti stabiliti in Italia deve essere emessa esclusivamente in formato elettronico tramite il Sistema di Interscambio (SdI), gestito dall''Agenzia delle entrate, nel formato FatturaPA (provvedimento del Direttore dell''Agenzia delle entrate, allegato A). Non si tratta di uno scambio d''un profilo EN 16931 tra le parti: lo SdI convalida e recapita la fattura, la respinge in caso di scarto, e ne conserva copia — una funzione di clearance dello Stato, non di trasporto. Nessun mattone di packages/formats scrive o convalida oggi una fattura conforme allo SdI: dichiarare un profile affermerebbe il contrario. profile e mandatory_from restano dunque vuoti, come per il Messico e la Spagna (si veda la sezione « From Italy » di docs/international.md), pur essendo l''obbligo italiano pienamente in vigore dal 2019 — a differenza della Spagna, dove l''obbligo B2B non è ancora entrato in vigore. Lo schema 0211 (AGID, rete Peppol italiana) identifica la partita IVA; il Codice Destinatario a sette caratteri con cui un operatore è raggiunto sullo SdI non è un identificatore ISO 6523 e non ha una casella qui',
  einvoice_source_key           = 'legge-205-2017',
  party_scheme                  = null,
  vat_scheme                    = '0211',
  bank_statement_formats        = array['camt.053', 'mt940']::text[],
  payment_formats               = array['pain.001', 'pain.008']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'IT';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('IT', 'reverse_charge', 'reverse_charge', 'Inversione contabile — operazione soggetta al regime del reverse charge, ai sensi dell''art. 17 del D.P.R. 26 ottobre 1972, n. 633.', '{"en":"Reverse charge — domestic self-assessment of the tax, art. 17 of Presidential Decree No. 633 of 26 October 1972."}'::jsonb, 10, date '1970-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 21, comma 6, lettera a) — la fattura relativa alle operazioni di cui all''art. 17, sesto comma, è emessa senza addebito d''imposta, con l''annotazione «inversione contabile»'),
  ('IT', 'intracom_goods', 'intra_eu_goods', 'Operazione non imponibile — cessione intracomunitaria, art. 41 del D.L. 30 agosto 1993, n. 331; art. 138 della direttiva 2006/112/CE.', '{"en":"Not taxable — intra-Community supply, art. 41 of Decree-Law No. 331 of 1993; art. 138 of Directive 2006/112/EC."}'::jsonb, 20, date '1970-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 21, comma 6, lettera b) — la fattura relativa alle cessioni intracomunitarie di cui all''art. 41 del D.L. n. 331 del 1993 reca l''annotazione «operazione non imponibile», con l''indicazione della norma'),
  ('IT', 'intracom_services', 'intra_eu_services', 'Operazione non soggetta — prestazione di servizi generica resa a soggetto passivo stabilito in altro Stato membro, artt. 7-ter e 21, comma 6-bis, lettera a) del D.P.R. n. 633 del 1972; artt. 44 e 196 della direttiva 2006/112/CE.', '{"en":"Not subject to tax — generic service supplied to a taxable person established in another Member State, arts. 7-ter and 21(6-bis)(a) of Presidential Decree No. 633 of 1972; arts. 44 and 196 of Directive 2006/112/EC."}'::jsonb, 30, date '1970-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 21, comma 6-bis, lettera a) — fattura con l''annotazione «inversione contabile» per le prestazioni di servizi generiche rese a soggetti passivi stabiliti in un altro Stato membro'),
  ('IT', 'export', 'export', 'Operazione non imponibile — cessione all''esportazione, art. 8, comma 1, del D.P.R. 26 ottobre 1972, n. 633.', '{"en":"Not taxable — export supply, art. 8(1) of Presidential Decree No. 633 of 26 October 1972."}'::jsonb, 40, date '1970-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 21, comma 6, lettera b) — annotazione «operazione non imponibile» con l''indicazione della norma, per le cessioni all''esportazione dell''art. 8'),
  ('IT', 'exempt', 'exempt', 'Operazione esente, art. 10 del D.P.R. 26 ottobre 1972, n. 633.', '{"en":"Exempt operation, art. 10 of Presidential Decree No. 633 of 26 October 1972."}'::jsonb, 50, date '1970-01-01', null, 'Decreto del Presidente della Repubblica 26 ottobre 1972, n. 633, art. 21, comma 6, lettera b) — annotazione «operazione esente» con l''indicazione della norma')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
