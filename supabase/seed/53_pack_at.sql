-- Ekwo OS — Austria: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/at at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build at`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Umsatzsteuergesetz 1994 (UStG 1994), BGBl. Nr. 663/1994 in der geltenden Fassung (Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich)
--     https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10004873
--   Unternehmensgesetzbuch (UGB), dRGBl. S 219/1897 in der geltenden Fassung — Drittes Buch, §§ 189 bis 231 (Rechnungslegung) (Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich)
--     https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001702
--   Bundesabgabenordnung (BAO), BGBl. Nr. 194/1961 in der geltenden Fassung — § 134 (Erklärungsfristen), § 204 (Rundung) (Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich)
--     https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10003940
--   Allgemeines bürgerliches Gesetzbuch (ABGB), JGS Nr. 946/1811 — § 907a (Erfüllung einer Geldschuld) in der Fassung des Zahlungsverzugsgesetzes 2013 (Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich)
--     https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001622
--   Formular U30 — Umsatzsteuervoranmeldung 2026, und Ausfüllhilfe U30a (Bundesministerium für Finanzen (BMF))
--     https://www.usp.gv.at/formsearch/form/341
--   FinanzOnline — elektronische Abgabe der Umsatzsteuervoranmeldung, der Jahreserklärung und der Zusammenfassenden Meldung (Bundesministerium für Finanzen (BMF))
--     https://finanzonline.bmf.gv.at
--   Unternehmensserviceportal (USP) — Umsatzsteuer, Umsatzsteuervoranmeldung, Zusammenfassende Meldung, Kleinunternehmer, Rechnung, E-Rechnung an die öffentliche Verwaltung (Bundesministerium für Finanzen / Bundesministerium für Arbeit und Wirtschaft — usp.gv.at)
--     https://www.usp.gv.at/themen/steuern-finanzen/umsatzsteuer-ueberblick.html
--   e-Rechnung an den Bund — Rechtsgrundlage, Formate ebInterface und PEPPOL BIS, Leitfaden (Bundesministerium für Finanzen (BMF) — erechnung.gv.at)
--     https://www.erechnung.gv.at/go/leitfaden
--   EN 16931-1 — semantic data model of the electronic invoice, conformity under Directive 2014/55/EU (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — code list of tax categories (BT-118 and BT-151), subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — code list of VAT exemption reasons (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   Electronic Address Scheme (EAS) — ISO 6523 identifier schemes, including 9915 (Austrian VAT number) (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   Basiszinssatz nach § 1 des 1. Euro-Justiz-Begleitgesetzes, maßgeblich für § 456 UGB (Oesterreichische Nationalbank (OeNB))
--     https://www.oenb.at/Service/Zins--und-Wechselkurse/Anknuepfungszinssaetze.html
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('AT', 'Austria', '0.1.0', date '2026-09-22', '20260921145425', 'community', null, null, '763f4556eaab01639213dd304bdd076d90a0033ff98a07e76da8854be00bd440', '[{"key":"ustg","title":"Umsatzsteuergesetz 1994 (UStG 1994), BGBl. Nr. 663/1994 in der geltenden Fassung","publisher":"Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich","url":"https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10004873","consulted_on":"2026-09-22","kind":"law"},{"key":"ugb","title":"Unternehmensgesetzbuch (UGB), dRGBl. S 219/1897 in der geltenden Fassung — Drittes Buch, §§ 189 bis 231 (Rechnungslegung)","publisher":"Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich","url":"https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001702","consulted_on":"2026-09-22","kind":"law"},{"key":"bao","title":"Bundesabgabenordnung (BAO), BGBl. Nr. 194/1961 in der geltenden Fassung — § 134 (Erklärungsfristen), § 204 (Rundung)","publisher":"Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich","url":"https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10003940","consulted_on":"2026-09-22","kind":"law"},{"key":"abgb","title":"Allgemeines bürgerliches Gesetzbuch (ABGB), JGS Nr. 946/1811 — § 907a (Erfüllung einer Geldschuld) in der Fassung des Zahlungsverzugsgesetzes 2013","publisher":"Rechtsinformationssystem des Bundes (RIS) — Bundeskanzleramt Österreich","url":"https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=10001622","consulted_on":"2026-09-22","kind":"law"},{"key":"u30-2026","title":"Formular U30 — Umsatzsteuervoranmeldung 2026, und Ausfüllhilfe U30a","publisher":"Bundesministerium für Finanzen (BMF)","url":"https://www.usp.gv.at/formsearch/form/341","consulted_on":"2026-09-22","kind":"form"},{"key":"finanzonline","title":"FinanzOnline — elektronische Abgabe der Umsatzsteuervoranmeldung, der Jahreserklärung und der Zusammenfassenden Meldung","publisher":"Bundesministerium für Finanzen (BMF)","url":"https://finanzonline.bmf.gv.at","consulted_on":"2026-09-22","kind":"portal"},{"key":"usp-ust","title":"Unternehmensserviceportal (USP) — Umsatzsteuer, Umsatzsteuervoranmeldung, Zusammenfassende Meldung, Kleinunternehmer, Rechnung, E-Rechnung an die öffentliche Verwaltung","publisher":"Bundesministerium für Finanzen / Bundesministerium für Arbeit und Wirtschaft — usp.gv.at","url":"https://www.usp.gv.at/themen/steuern-finanzen/umsatzsteuer-ueberblick.html","consulted_on":"2026-09-22","kind":"guidance"},{"key":"erechnung-bund","title":"e-Rechnung an den Bund — Rechtsgrundlage, Formate ebInterface und PEPPOL BIS, Leitfaden","publisher":"Bundesministerium für Finanzen (BMF) — erechnung.gv.at","url":"https://www.erechnung.gv.at/go/leitfaden","consulted_on":"2026-09-22","kind":"guidance"},{"key":"en-16931","title":"EN 16931-1 — semantic data model of the electronic invoice, conformity under Directive 2014/55/EU","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-22","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — code list of tax categories (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-22","kind":"standard"},{"key":"vatex","title":"VATEX — code list of VAT exemption reasons (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-22","kind":"standard"},{"key":"peppol-eas","title":"Electronic Address Scheme (EAS) — ISO 6523 identifier schemes, including 9915 (Austrian VAT number)","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-22","kind":"standard"},{"key":"oenb-basiszinssatz","title":"Basiszinssatz nach § 1 des 1. Euro-Justiz-Begleitgesetzes, maßgeblich für § 456 UGB","publisher":"Oesterreichische Nationalbank (OeNB)","url":"https://www.oenb.at/Service/Zins--und-Wechselkurse/Anknuepfungszinssaetze.html","consulted_on":"2026-09-22","kind":"guidance"}]'::jsonb)
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
  ('AT', 'default', 'Referenzkontenplan nach der Gliederung der §§ 224 und 231 UGB', '{"en":"Reference chart of accounts following sections 224 and 231 UGB"}'::jsonb, true, 'companies', array['AT-UGB-224-BS', 'AT-UGB-231-GKV']::text[], null, 'UGB § 189 verpflichtet Kapitalgesellschaften und bestimmte Personengesellschaften ohne unbeschränkt haftende natürliche Person kraft Rechtsform, sonstige Unternehmer ab Überschreiten der Umsatzschwellen des § 189 Abs. 1 Z 2, zur Rechnungslegung nach dem Dritten Buch. Das Gesetz schreibt keinen Kontenplan vor. In der Praxis weit verbreitet ist der Einheitskontenrahmen (EKR), ein Fachgutachten KFS/BW6 der Kammer der Steuerberater und Wirtschaftsprüfer (KSW), das unter dem Copyright der Kammer steht und hier weder in seinen Kontonummern noch in seinen Bezeichnungen übernommen wird. Dieser Plan ist eigenständig: vierstellige Nummern, deren erste Ziffer den Abschnitt der Bilanz nach § 224 (1 Anlagevermögen, 2 Umlaufvermögen, 3 Rechnungsabgrenzung/aktive latente Steuern, 4 Eigenkapital, 5 Rückstellungen, 6 Verbindlichkeiten, 7 Rechnungsabgrenzung passiv) oder der Gewinn- und Verlustrechnung nach § 231 Abs. 2 (8 Posten 1 bis 8, 9 Posten 10 bis 20) bezeichnet.', 'ugb')
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
  ('AT', 'default', '1100', 'Entgeltlich erworbene Konzessionen und gewerbliche Schutzrechte', '{"en":"Purchased concessions and industrial property rights"}'::jsonb, 'asset_fixed', false, null, 10),
  ('AT', 'default', '1101', 'Entgeltlich erworbene Software', '{"en":"Purchased software"}'::jsonb, 'asset_fixed', false, null, 20),
  ('AT', 'default', '1110', 'Geschäfts(Firmen)wert', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 30),
  ('AT', 'default', '1120', 'Geleistete Anzahlungen auf immaterielle Vermögensgegenstände', '{"en":"Prepayments on intangible assets"}'::jsonb, 'asset_fixed', false, null, 40),
  ('AT', 'default', '1200', 'Grundstücke und Bauten', '{"en":"Land and buildings"}'::jsonb, 'asset_fixed', false, null, 50),
  ('AT', 'default', '1210', 'Technische Anlagen und Maschinen', '{"en":"Technical equipment and machinery"}'::jsonb, 'asset_fixed', false, null, 60),
  ('AT', 'default', '1220', 'Andere Anlagen sowie Betriebs- und Geschäftsausstattung', '{"en":"Other equipment, operating and office equipment"}'::jsonb, 'asset_fixed', false, null, 70),
  ('AT', 'default', '1221', 'Fahrzeuge', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, null, 80),
  ('AT', 'default', '1222', 'Büroeinrichtung', '{"en":"Office furniture"}'::jsonb, 'asset_fixed', false, null, 90),
  ('AT', 'default', '1223', 'EDV-Ausstattung', '{"en":"IT equipment"}'::jsonb, 'asset_fixed', false, null, 100),
  ('AT', 'default', '1224', 'Geringwertige Vermögensgegenstände', '{"en":"Low-value assets"}'::jsonb, 'asset_fixed', false, null, 110),
  ('AT', 'default', '1230', 'Geleistete Anzahlungen und Anlagen in Bau', '{"en":"Prepayments and assets under construction"}'::jsonb, 'asset_fixed', false, null, 120),
  ('AT', 'default', '1300', 'Anteile an verbundenen Unternehmen', '{"en":"Shares in affiliated undertakings"}'::jsonb, 'asset_non_current', false, null, 130),
  ('AT', 'default', '1310', 'Ausleihungen an verbundene Unternehmen', '{"en":"Loans to affiliated undertakings"}'::jsonb, 'asset_non_current', false, null, 140),
  ('AT', 'default', '1320', 'Beteiligungen', '{"en":"Participating interests"}'::jsonb, 'asset_non_current', false, null, 150),
  ('AT', 'default', '1330', 'Ausleihungen an Unternehmen, mit denen ein Beteiligungsverhältnis besteht', '{"en":"Loans to undertakings with which a participating interest exists"}'::jsonb, 'asset_non_current', false, null, 160),
  ('AT', 'default', '1340', 'Wertpapiere des Anlagevermögens', '{"en":"Securities held as fixed assets"}'::jsonb, 'asset_non_current', false, null, 170),
  ('AT', 'default', '1350', 'Sonstige Ausleihungen', '{"en":"Other loans"}'::jsonb, 'asset_non_current', false, null, 180),
  ('AT', 'default', '2100', 'Roh-, Hilfs- und Betriebsstoffe', '{"en":"Raw materials, consumables and supplies"}'::jsonb, 'asset_current', false, null, 190),
  ('AT', 'default', '2110', 'Unfertige Erzeugnisse', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 200),
  ('AT', 'default', '2120', 'Fertige Erzeugnisse und Waren', '{"en":"Finished goods and merchandise"}'::jsonb, 'asset_current', false, null, 210),
  ('AT', 'default', '2130', 'Geleistete Anzahlungen auf Vorräte', '{"en":"Prepayments on inventories"}'::jsonb, 'asset_current', false, null, 220),
  ('AT', 'default', '2200', 'Forderungen aus Lieferungen und Leistungen', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 230),
  ('AT', 'default', '2210', 'Forderungen gegen verbundene Unternehmen', '{"en":"Receivables from affiliated undertakings"}'::jsonb, 'asset_receivable', true, null, 240),
  ('AT', 'default', '2220', 'Forderungen gegen Unternehmen, mit denen ein Beteiligungsverhältnis besteht', '{"en":"Receivables from undertakings with which a participating interest exists"}'::jsonb, 'asset_receivable', true, null, 250),
  ('AT', 'default', '2230', 'Sonstige Forderungen und Vermögensgegenstände', '{"en":"Other receivables and assets"}'::jsonb, 'asset_current', true, null, 260),
  ('AT', 'default', '2231', 'Abziehbare Vorsteuer 20 %', '{"en":"Deductible input VAT 20 %"}'::jsonb, 'asset_current', false, null, 270),
  ('AT', 'default', '2232', 'Abziehbare Vorsteuer 13 %', '{"en":"Deductible input VAT 13 %"}'::jsonb, 'asset_current', false, null, 280),
  ('AT', 'default', '2233', 'Abziehbare Vorsteuer 10 %', '{"en":"Deductible input VAT 10 %"}'::jsonb, 'asset_current', false, null, 290),
  ('AT', 'default', '2234', 'Abziehbare Vorsteuer aus dem innergemeinschaftlichen Erwerb', '{"en":"Deductible input VAT on intra-Community acquisitions"}'::jsonb, 'asset_current', false, null, 300),
  ('AT', 'default', '2235', 'Abziehbare Vorsteuer betreffend die Steuerschuld gemäß § 19 Abs. 1', '{"en":"Deductible input VAT on the tax owed under section 19(1)"}'::jsonb, 'asset_current', false, null, 310),
  ('AT', 'default', '2236', 'Abziehbare Vorsteuer betreffend die Steuerschuld gemäß § 19 Abs. 1a', '{"en":"Deductible input VAT on the tax owed under section 19(1a)"}'::jsonb, 'asset_current', false, null, 320),
  ('AT', 'default', '2237', 'Forderungen gegen das Finanzamt aus der Umsatzsteuer', '{"en":"Receivable from the tax office for VAT"}'::jsonb, 'asset_current', true, null, 330),
  ('AT', 'default', '2238', 'Forderungen gegen Gesellschafter', '{"en":"Receivables from shareholders"}'::jsonb, 'asset_current', true, null, 340),
  ('AT', 'default', '2239', 'Durchlaufende Posten und Verrechnungskonto', '{"en":"Transitory items and clearing account"}'::jsonb, 'asset_current', true, null, 350),
  ('AT', 'default', '2300', 'Anteile an verbundenen Unternehmen (Umlaufvermögen)', '{"en":"Shares in affiliated undertakings (current assets)"}'::jsonb, 'asset_current', false, null, 360),
  ('AT', 'default', '2310', 'Sonstige Wertpapiere', '{"en":"Other securities"}'::jsonb, 'asset_current', false, null, 370),
  ('AT', 'default', '2400', 'Kassa', '{"en":"Cash in hand"}'::jsonb, 'asset_cash', false, null, 380),
  ('AT', 'default', '2410', 'Guthaben bei Kreditinstituten', '{"en":"Bank current account"}'::jsonb, 'asset_cash', false, null, 390),
  ('AT', 'default', '2411', 'Guthaben bei Kreditinstituten — zweites Konto', '{"en":"Bank current account — second account"}'::jsonb, 'asset_cash', false, null, 400),
  ('AT', 'default', '2420', 'Schecks', '{"en":"Cheques"}'::jsonb, 'asset_cash', false, null, 410),
  ('AT', 'default', '3100', 'Aktive Rechnungsabgrenzungsposten', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 420),
  ('AT', 'default', '3200', 'Aktive latente Steuern', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 430),
  ('AT', 'default', '4100', 'Eingefordertes Nennkapital', '{"en":"Called-up nominal capital"}'::jsonb, 'equity', false, null, 440),
  ('AT', 'default', '4200', 'Kapitalrücklagen', '{"en":"Capital reserves"}'::jsonb, 'equity', false, null, 450),
  ('AT', 'default', '4300', 'Gewinnrücklagen', '{"en":"Revenue reserves"}'::jsonb, 'equity', false, null, 460),
  ('AT', 'default', '4400', 'Bilanzgewinn (Bilanzverlust)', '{"en":"Retained profit (accumulated loss)"}'::jsonb, 'equity_retained', false, null, 470),
  ('AT', 'default', '5100', 'Rückstellungen für Abfertigungen', '{"en":"Provisions for severance payments"}'::jsonb, 'liability_non_current', false, null, 480),
  ('AT', 'default', '5200', 'Rückstellungen für Pensionen', '{"en":"Provisions for pensions"}'::jsonb, 'liability_non_current', false, null, 490),
  ('AT', 'default', '5300', 'Steuerrückstellungen', '{"en":"Tax provisions"}'::jsonb, 'liability_current', false, null, 500),
  ('AT', 'default', '5310', 'Sonstige Rückstellungen', '{"en":"Other provisions"}'::jsonb, 'liability_current', false, null, 510),
  ('AT', 'default', '5320', 'Passive latente Steuern', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 520),
  ('AT', 'default', '6100', 'Anleihen', '{"en":"Bonds"}'::jsonb, 'liability_non_current', false, null, 530),
  ('AT', 'default', '6200', 'Verbindlichkeiten gegenüber Kreditinstituten', '{"en":"Amounts owed to credit institutions"}'::jsonb, 'liability_current', true, null, 540),
  ('AT', 'default', '6300', 'Erhaltene Anzahlungen auf Bestellungen', '{"en":"Payments received on account of orders"}'::jsonb, 'liability_current', true, null, 550),
  ('AT', 'default', '6400', 'Verbindlichkeiten aus Lieferungen und Leistungen', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 560),
  ('AT', 'default', '6500', 'Verbindlichkeiten aus der Annahme gezogener Wechsel', '{"en":"Liabilities from bills of exchange"}'::jsonb, 'liability_current', true, null, 570),
  ('AT', 'default', '6600', 'Verbindlichkeiten gegenüber verbundenen Unternehmen', '{"en":"Amounts owed to affiliated undertakings"}'::jsonb, 'liability_payable', true, null, 580),
  ('AT', 'default', '6610', 'Verbindlichkeiten gegenüber Unternehmen, mit denen ein Beteiligungsverhältnis besteht', '{"en":"Amounts owed to undertakings with which a participating interest exists"}'::jsonb, 'liability_payable', true, null, 590),
  ('AT', 'default', '6800', 'Umsatzsteuer 20 %', '{"en":"VAT 20 %"}'::jsonb, 'liability_current', false, null, 600),
  ('AT', 'default', '6801', 'Umsatzsteuer 13 %', '{"en":"VAT 13 %"}'::jsonb, 'liability_current', false, null, 610),
  ('AT', 'default', '6802', 'Umsatzsteuer 10 %', '{"en":"VAT 10 %"}'::jsonb, 'liability_current', false, null, 620),
  ('AT', 'default', '6803', 'Umsatzsteuer aus dem innergemeinschaftlichen Erwerb', '{"en":"VAT on intra-Community acquisitions"}'::jsonb, 'liability_current', false, null, 630),
  ('AT', 'default', '6804', 'Umsatzsteuer betreffend die Steuerschuld gemäß § 19 Abs. 1', '{"en":"VAT on the tax owed under section 19(1)"}'::jsonb, 'liability_current', false, null, 640),
  ('AT', 'default', '6805', 'Umsatzsteuer betreffend die Steuerschuld gemäß § 19 Abs. 1a', '{"en":"VAT on the tax owed under section 19(1a)"}'::jsonb, 'liability_current', false, null, 650),
  ('AT', 'default', '6810', 'Umsatzsteuer-Zahllast/Überschuss gegenüber dem Finanzamt', '{"en":"VAT payable to / receivable from the tax office"}'::jsonb, 'liability_current', true, null, 660),
  ('AT', 'default', '6820', 'Verbindlichkeiten aus Lohnsteuer', '{"en":"Payroll tax payable"}'::jsonb, 'liability_current', true, null, 670),
  ('AT', 'default', '6830', 'Verbindlichkeiten im Rahmen der sozialen Sicherheit', '{"en":"Social security payable"}'::jsonb, 'liability_current', true, null, 680),
  ('AT', 'default', '6840', 'Verbindlichkeiten aus Lohn und Gehalt', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', true, null, 690),
  ('AT', 'default', '6850', 'Verbindlichkeiten gegenüber Gesellschaftern', '{"en":"Amounts owed to shareholders"}'::jsonb, 'liability_current', true, null, 700),
  ('AT', 'default', '6860', 'Kreditkartenabrechnung', '{"en":"Credit card settlement account"}'::jsonb, 'liability_credit_card', true, null, 710),
  ('AT', 'default', '6870', 'Übrige sonstige Verbindlichkeiten', '{"en":"Other liabilities"}'::jsonb, 'liability_current', true, null, 720),
  ('AT', 'default', '7100', 'Passive Rechnungsabgrenzungsposten', '{"en":"Deferred income"}'::jsonb, 'liability_current', false, null, 730),
  ('AT', 'default', '8100', 'Umsatzerlöse 20 % USt', '{"en":"Revenue at 20 % VAT"}'::jsonb, 'income', false, null, 740),
  ('AT', 'default', '8101', 'Umsatzerlöse 13 % USt', '{"en":"Revenue at 13 % VAT"}'::jsonb, 'income', false, null, 750),
  ('AT', 'default', '8102', 'Umsatzerlöse 10 % USt', '{"en":"Revenue at 10 % VAT"}'::jsonb, 'income', false, null, 760),
  ('AT', 'default', '8103', 'Steuerfreie innergemeinschaftliche Lieferungen', '{"en":"Exempt intra-Community supplies"}'::jsonb, 'income', false, null, 770),
  ('AT', 'default', '8104', 'Erlöse aus im übrigen Gemeinschaftsgebiet steuerpflichtigen sonstigen Leistungen', '{"en":"Revenue from services taxable in another Member State"}'::jsonb, 'income', false, null, 780),
  ('AT', 'default', '8105', 'Steuerfreie Ausfuhrlieferungen', '{"en":"Exempt exports"}'::jsonb, 'income', false, null, 790),
  ('AT', 'default', '8106', 'Erlöse aus Bauleistungen, für die der Leistungsempfänger die Steuer schuldet', '{"en":"Revenue from construction services on which the customer owes the tax"}'::jsonb, 'income', false, null, 800),
  ('AT', 'default', '8107', 'Steuerfreie Umsätze ohne Vorsteuerabzug', '{"en":"Exempt supplies without right of deduction"}'::jsonb, 'income', false, null, 810),
  ('AT', 'default', '8108', 'Steuerfreie Umsätze der Kleinunternehmer', '{"en":"Exempt supplies of a small business"}'::jsonb, 'income', false, null, 820),
  ('AT', 'default', '8200', 'Veränderung des Bestands an fertigen und unfertigen Erzeugnissen', '{"en":"Change in inventories of finished goods and work in progress"}'::jsonb, 'income', false, null, 830),
  ('AT', 'default', '8300', 'Andere aktivierte Eigenleistungen', '{"en":"Own work capitalised"}'::jsonb, 'income', false, null, 840),
  ('AT', 'default', '8400', 'Sonstige betriebliche Erträge', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 850),
  ('AT', 'default', '8410', 'Erträge aus dem Abgang von Anlagevermögen', '{"en":"Income from the disposal of fixed assets"}'::jsonb, 'income_other', false, null, 860),
  ('AT', 'default', '8420', 'Erträge aus der Auflösung von Rückstellungen', '{"en":"Income from the release of provisions"}'::jsonb, 'income_other', false, null, 870),
  ('AT', 'default', '8430', 'Erträge aus der Währungsumrechnung', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, null, 880),
  ('AT', 'default', '8500', 'Aufwendungen für Material und sonstige bezogene Herstellungsleistungen', '{"en":"Cost of materials and other purchased manufacturing services"}'::jsonb, 'expense_direct_cost', false, null, 890),
  ('AT', 'default', '8501', 'Aufwendungen für bezogene Waren', '{"en":"Cost of goods purchased"}'::jsonb, 'expense_direct_cost', false, null, 900),
  ('AT', 'default', '8502', 'Bauleistungen und andere Leistungen, für die der Leistungsempfänger die Steuer schuldet', '{"en":"Construction services and other services on which the recipient owes the tax"}'::jsonb, 'expense_direct_cost', false, null, 910),
  ('AT', 'default', '8600', 'Löhne', '{"en":"Wages"}'::jsonb, 'expense', false, null, 920),
  ('AT', 'default', '8610', 'Gehälter', '{"en":"Salaries"}'::jsonb, 'expense', false, null, 930),
  ('AT', 'default', '8620', 'Gesetzliche Sozialaufwendungen', '{"en":"Statutory social contributions"}'::jsonb, 'expense', false, null, 940),
  ('AT', 'default', '8630', 'Abfertigungs- und Pensionsaufwendungen', '{"en":"Severance and pension expenses"}'::jsonb, 'expense', false, null, 950),
  ('AT', 'default', '8700', 'Abschreibungen auf immaterielle Vermögensgegenstände und Sachanlagen', '{"en":"Depreciation and amortisation of intangible and tangible fixed assets"}'::jsonb, 'expense_depreciation', false, null, 960),
  ('AT', 'default', '8710', 'Sofortabschreibung geringwertiger Vermögensgegenstände', '{"en":"Immediate write-off of low-value assets"}'::jsonb, 'expense_depreciation', false, null, 970),
  ('AT', 'default', '8800', 'Miete und Pacht', '{"en":"Rent and lease payments"}'::jsonb, 'expense', false, null, 980),
  ('AT', 'default', '8801', 'Raumnebenkosten und Energie', '{"en":"Ancillary premises costs and energy"}'::jsonb, 'expense', false, null, 990),
  ('AT', 'default', '8802', 'Reparaturen und Instandhaltung', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 1000),
  ('AT', 'default', '8803', 'Versicherungen und Beiträge', '{"en":"Insurance and contributions"}'::jsonb, 'expense', false, null, 1010),
  ('AT', 'default', '8804', 'Fahrzeugkosten', '{"en":"Vehicle costs"}'::jsonb, 'expense', false, null, 1020),
  ('AT', 'default', '8805', 'Werbekosten', '{"en":"Advertising costs"}'::jsonb, 'expense', false, null, 1030),
  ('AT', 'default', '8806', 'Bewirtungskosten', '{"en":"Entertainment costs"}'::jsonb, 'expense', false, null, 1040),
  ('AT', 'default', '8807', 'Reisekosten', '{"en":"Travel costs"}'::jsonb, 'expense', false, null, 1050),
  ('AT', 'default', '8808', 'Aufwendungen aus der Währungsumrechnung', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, null, 1060),
  ('AT', 'default', '8809', 'Rechts- und Beratungskosten', '{"en":"Legal and consulting costs"}'::jsonb, 'expense', false, null, 1070),
  ('AT', 'default', '8810', 'Abschluss- und Prüfungskosten', '{"en":"Audit and accounting fees"}'::jsonb, 'expense', false, null, 1080),
  ('AT', 'default', '8811', 'Bürobedarf', '{"en":"Office supplies"}'::jsonb, 'expense', false, null, 1090),
  ('AT', 'default', '8812', 'Telekommunikation', '{"en":"Telecommunications"}'::jsonb, 'expense', false, null, 1100),
  ('AT', 'default', '8813', 'Software und IT-Dienstleistungen', '{"en":"Software and IT services"}'::jsonb, 'expense', false, null, 1110),
  ('AT', 'default', '8814', 'Nebenkosten des Geldverkehrs', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 1120),
  ('AT', 'default', '8815', 'Nicht abzugsfähige Vorsteuer', '{"en":"Non-deductible input VAT"}'::jsonb, 'expense', false, null, 1130),
  ('AT', 'default', '8816', 'Verluste aus dem Abgang von Anlagevermögen', '{"en":"Losses on the disposal of fixed assets"}'::jsonb, 'expense', false, null, 1140),
  ('AT', 'default', '8817', 'Forderungsverluste', '{"en":"Bad debt losses"}'::jsonb, 'expense', false, null, 1150),
  ('AT', 'default', '8818', 'Rundungsdifferenzen', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1160),
  ('AT', 'default', '8819', 'Übrige sonstige betriebliche Aufwendungen', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, null, 1170),
  ('AT', 'default', '9100', 'Erträge aus Beteiligungen', '{"en":"Income from participating interests"}'::jsonb, 'income_other', false, null, 1180),
  ('AT', 'default', '9110', 'Sonstige Zinsen und ähnliche Erträge', '{"en":"Other interest and similar income"}'::jsonb, 'income_other', false, null, 1190),
  ('AT', 'default', '9200', 'Zinsen und ähnliche Aufwendungen', '{"en":"Interest and similar expenses"}'::jsonb, 'expense', false, null, 1200),
  ('AT', 'default', '9300', 'Körperschaftsteuer', '{"en":"Corporate income tax"}'::jsonb, 'expense', false, null, 1210),
  ('AT', 'default', '9310', 'Sonstige Steuern', '{"en":"Other taxes"}'::jsonb, 'expense', false, null, 1220)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('AT', 'BK', 'Bank', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('AT', 'EB', 'Eröffnungsbuchungen', '{"en":"Opening entries"}'::jsonb, 'opening', 60),
  ('AT', 'EK', 'Eingangsrechnungen', '{"en":"Purchase invoices"}'::jsonb, 'purchase', 20),
  ('AT', 'KA', 'Kassa', '{"en":"Cash"}'::jsonb, 'cash', 40),
  ('AT', 'SO', 'Sonstige Buchungen', '{"en":"Miscellaneous entries"}'::jsonb, 'general', 50),
  ('AT', 'VK', 'Ausgangsrechnungen', '{"en":"Sales invoices"}'::jsonb, 'sales', 10)
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
  ('AT', 'AT-P-10', 'Vorsteuer 10 %', '{"en":"Input VAT 10 %"}'::jsonb, 'Vorsteuer aus Rechnungen anderer Unternehmer; Kennzahl 060', 'percent', 10, 'purchase', 'domestic', date '1984-01-01', null, 'UStG § 12 Abs. 1 Z 1, Satz nach § 10 Abs. 2.', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-13', 'Vorsteuer 13 %', '{"en":"Input VAT 13 %"}'::jsonb, 'Vorsteuer aus Rechnungen anderer Unternehmer; Kennzahl 060', 'percent', 13, 'purchase', 'domestic', date '2016-01-01', null, 'UStG § 12 Abs. 1 Z 1, Satz nach § 10 Abs. 3.', 'S', null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-20', 'Vorsteuer 20 %', '{"en":"Input VAT 20 %"}'::jsonb, 'Vorsteuer aus Rechnungen anderer Unternehmer; Kennzahl 060', 'percent', 20, 'purchase', 'domestic', date '1984-01-01', null, 'UStG § 12 Abs. 1 Z 1 — als Vorsteuer abziehbar ist die von anderen Unternehmern in einer Rechnung (§§ 11, 11a) an ihn gesondert ausgewiesene Steuer für Lieferungen oder sonstige Leistungen, die im Inland für sein Unternehmen ausgeführt worden sind.', 'S', null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-20-NA', 'Nicht abziehbare Vorsteuer 20 %', '{"en":"Non-deductible input VAT 20 %"}'::jsonb, 'Zum Beispiel Personenkraftwagen und Kombinationskraftwagen, sofern kein Ausnahmefall der Verordnung BGBl. Nr. 273/1996 vorliegt: die Steuer folgt dem Aufwandskonto', 'percent', 20, 'purchase', 'domestic', date '1984-01-01', null, 'UStG § 12 Abs. 2 Z 2 lit. b — nicht als für das Unternehmen ausgeführt gelten Lieferungen, sonstige Leistungen und Einfuhren im Zusammenhang mit der Anschaffung, Miete oder dem Betrieb von Personenkraftwagen, Kombinationskraftwagen und Krafträdern, soweit nicht in der Verordnung BGBl. Nr. 273/1996 als Ausnahme genannt (Fahrschulfahrzeuge, Vorführfahrzeuge, gewerbliche Personenbeförderung, Fiskal-Lkw und Kleinbusse u. a.). Die Steuer wird daher Teil der Anschaffungs- oder Aufwandskosten und erscheint in keiner Kennzahl der Voranmeldung.', 'S', null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-AUSL-20', 'Leistung eines im Drittland ansässigen Unternehmers 20 %', '{"en":"Service from a supplier established outside the Union 20 %"}'::jsonb, 'Leistungsempfänger als Steuerschuldner; Kennzahl 057 und Kennzahl 066. Anders als Deutschland unterscheidet das österreichische Formular nicht zwischen einem im übrigen Gemeinschaftsgebiet und einem im Drittland ansässigen leistenden Unternehmer.', 'percent', 20, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'UStG § 19 Abs. 1 zweiter Satz — bei sonstigen Leistungen im Sinne des § 3a Abs. 6, die von einem im Ausland (auch außerhalb der Union) ansässigen Unternehmer ausgeführt werden, schuldet der Leistungsempfänger die Steuer; § 12 Abs. 1 Z 3 lässt sie als Vorsteuer abziehen. Die Rechnung des drittländischen Lieferers fällt nicht unter EN 16931, daher keine Kategorie.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-BAU-20', 'Erhaltene Bauleistung, Steuerschuld beim Leistungsempfänger 20 %', '{"en":"Construction service received, customer liable for the tax 20 %"}'::jsonb, 'Empfänger einer Bauleistung nach § 19 Abs. 1a; Kennzahl 048 und Kennzahl 082', 'percent', 20, 'purchase', 'domestic_reverse_charge', date '2002-01-01', null, 'UStG § 19 Abs. 1a — bei Bauleistungen wird die Steuer vom Empfänger der Leistung geschuldet, wenn dieser selbst mit der Erbringung von Bauleistungen beauftragt ist; § 12 Abs. 1 Z 3 lässt sie als Vorsteuer abziehen.', 'AE', 'VATEX-EU-AE', 160, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-EUDL-20', 'Sonstige Leistung eines im übrigen Gemeinschaftsgebiet ansässigen Unternehmers 20 %', '{"en":"Service from a supplier established in another Member State 20 %"}'::jsonb, 'Leistungsempfänger als Steuerschuldner; Kennzahl 057 und Kennzahl 066. Das Formular verlangt keine gesonderte Bemessungsgrundlage für diese Zeile.', 'percent', 20, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'UStG § 19 Abs. 1 zweiter Satz — bei sonstigen Leistungen im Sinne des § 3a Abs. 6, die von einem im Ausland ansässigen Unternehmer ausgeführt werden, schuldet der Leistungsempfänger die Steuer, wenn er Unternehmer oder eine juristische Person ist; § 12 Abs. 1 Z 3 lässt die geschuldete Steuer als Vorsteuer abziehen.', 'K', 'VATEX-EU-IC', 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-P-IGE-20', 'Innergemeinschaftlicher Erwerb 20 %', '{"en":"Intra-Community acquisition of goods 20 %"}'::jsonb, 'Erwerbsteuer und Vorsteuer aus dem innergemeinschaftlichen Erwerb; Kennzahl 072 und Kennzahl 065', 'percent', 20, 'purchase', 'intracom_acquisition_goods', date '1995-01-01', null, 'UStG Art. 1 Abs. 1 Binnenmarktregelung — der innergemeinschaftliche Erwerb im Inland gegen Entgelt unterliegt der Erwerbsteuer; Art. 19 Abs. 1 zweiter Unterabsatz bestimmt den Erwerber als Steuerschuldner; Art. 12 Abs. 1 Z 1 lässt die entstandene Erwerbsteuer als Vorsteuer abziehen, sofern der Erwerb für das Unternehmen erfolgt.', 'K', 'VATEX-EU-IC', 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-10', 'Umsatzsteuer 10 %', '{"en":"Output VAT 10 %"}'::jsonb, 'Ermäßigter Steuersatz nach § 10 Abs. 2, unter anderem Lebensmittel, Bücher und Zeitungen, Wohnraumvermietung, Personenbeförderung; Kennzahl 029', 'percent', 10, 'sale', 'domestic', date '1984-01-01', null, 'UStG § 10 Abs. 2 — die Steuer ermäßigt sich auf 10 % für die dort und in Anlage 1 genannten Umsätze.', 'S', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-13', 'Umsatzsteuer 13 %', '{"en":"Output VAT 13 %"}'::jsonb, 'Ermäßigter Steuersatz nach § 10 Abs. 3, unter anderem lebende Tiere und Pflanzen, Brennholz, kulturelle Veranstaltungen, künstlerische Tätigkeiten, Beherbergung; Kennzahl 006', 'percent', 13, 'sale', 'domestic', date '2016-01-01', null, 'UStG § 10 Abs. 3 — die Steuer ermäßigt sich auf 13 % für die dort und in Anlage 2 genannten Umsätze.', 'S', null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-20', 'Umsatzsteuer 20 %', '{"en":"Output VAT 20 %"}'::jsonb, 'Normalsteuersatz; Kennzahl 022', 'percent', 20, 'sale', 'domestic', date '1984-01-01', null, 'UStG § 10 Abs. 1 — die Steuer beträgt für jeden steuerpflichtigen Umsatz 20 % der Bemessungsgrundlage.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-AUSF', 'Steuerfreie Ausfuhrlieferung', '{"en":"Exempt export of goods"}'::jsonb, 'Lieferung in das Drittlandsgebiet; Kennzahl 011', 'percent', 0, 'sale', 'export', date '1973-01-01', null, 'UStG § 6 Abs. 1 Z 1 iVm § 7 — steuerfrei sind die Ausfuhrlieferungen; die Voraussetzungen sind nach § 7 Abs. 5 buch- und belegmäßig nachzuweisen.', 'G', 'VATEX-EU-G', 60, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-BAU', 'Bauleistung, Steuerschuld beim Leistungsempfänger', '{"en":"Construction service, customer liable for the tax"}'::jsonb, 'Leistender Unternehmer bei § 19 Abs. 1a (Bauleistungen an einen selbst bauleistenden Unternehmer); Kennzahl 021', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2002-01-01', null, 'UStG § 19 Abs. 1a — bei Bauleistungen wird die Steuer vom Empfänger der Leistung geschuldet, wenn der Empfänger Unternehmer ist, der seinerseits mit der Erbringung von Bauleistungen beauftragt ist; § 11 Abs. 1a verlangt den Hinweis auf dessen Steuerschuldnerschaft.', 'AE', 'VATEX-EU-AE', 70, 'vat', true, array['buyer_status', 'supply_nature']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-EUDL', 'Sonstige Leistung im übrigen Gemeinschaftsgebiet', '{"en":"Service taxable in another Member State"}'::jsonb, 'Nicht steuerbar im Inland, Steuerschuldner ist der im übrigen Gemeinschaftsgebiet ansässige Leistungsempfänger; Kennzahl 021 und Zusammenfassende Meldung', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'UStG § 3a Abs. 6 — eine sonstige Leistung an einen Unternehmer für dessen Unternehmen wird an dem Ort ausgeführt, von dem aus der Empfänger sein Unternehmen betreibt; § 19 Abs. 1 zweiter Satz verlagert die Steuerschuld auf den im übrigen Gemeinschaftsgebiet ansässigen Leistungsempfänger; § 11 Abs. 1a verlangt den Hinweis auf dessen Steuerschuldnerschaft, Art. 21 Abs. 3 die Angabe in der Zusammenfassenden Meldung.', 'K', 'VATEX-EU-IC', 50, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-IGL', 'Steuerfreie innergemeinschaftliche Lieferung', '{"en":"Exempt intra-Community supply of goods"}'::jsonb, 'An Abnehmer mit UID-Nummer eines anderen Mitgliedstaats; Kennzahl 017 und Zusammenfassende Meldung', 'percent', 0, 'sale', 'intracom_goods', date '1995-01-01', null, 'UStG Art. 6 Abs. 1 iVm Art. 7 Abs. 1 Binnenmarktregelung (Anhang zu § 29 Abs. 8) — steuerfrei ist die innergemeinschaftliche Lieferung an einen Abnehmer, der eine ihm von einem anderen Mitgliedstaat erteilte Umsatzsteuer-Identifikationsnummer verwendet und die Lieferung in der Zusammenfassenden Meldung nach Art. 21 Abs. 3 zutreffend angegeben ist.', 'K', 'VATEX-EU-IC', 40, 'vat', true, array['buyer_status', 'transport_evidence']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null),
  ('AT', 'AT-S-VERM', 'Steuerfreie Vermietung und Verpachtung von Grundstücken', '{"en":"Exempt letting of immovable property"}'::jsonb, 'Unecht steuerbefreit, ohne Vorsteuerabzug; Kennzahl 020', 'percent', 0, 'sale', 'exempt', date '1973-01-01', null, 'UStG § 6 Abs. 1 Z 16 — steuerfrei ist die Vermietung und Verpachtung von Grundstücken, mit Ausnahmen unter anderem für die Vermietung für Wohnzwecke, kurzfristige Beherbergung und die Vermietung von Garagen; der Vorsteuerabzug ist nach § 12 Abs. 3 ausgeschlossen, sofern nicht nach § 6 Abs. 2 zur Steuerpflicht optiert wird. Richtlinie 2006/112/EG Art. 135 Abs. 1 Buchst. l, daher VATEX-EU-135-1.', 'E', 'VATEX-EU-135-1', 80, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ustg', null, null, null, null)
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
    ('AT-P-10', 'invoice', 'tax', 100, '2233', '060', array['060']::text[], 100, 'AT-UVA', 10),
    ('AT-P-10', 'credit_note', 'tax', 100, '2233', '060', array['060']::text[], -100, 'AT-UVA', 10),
    ('AT-P-13', 'invoice', 'tax', 100, '2232', '060', array['060']::text[], 100, 'AT-UVA', 10),
    ('AT-P-13', 'credit_note', 'tax', 100, '2232', '060', array['060']::text[], -100, 'AT-UVA', 10),
    ('AT-P-20', 'invoice', 'tax', 100, '2231', '060', array['060']::text[], 100, 'AT-UVA', 10),
    ('AT-P-20', 'credit_note', 'tax', 100, '2231', '060', array['060']::text[], -100, 'AT-UVA', 10),
    ('AT-P-20-NA', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('AT-P-20-NA', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('AT-P-AUSL-20', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AT-P-AUSL-20', 'invoice', 'tax', 100, '2235', '066', array['066']::text[], 100, 'AT-UVA', 20),
    ('AT-P-AUSL-20', 'invoice', 'tax', -100, '6804', '057', array['057']::text[], 100, 'AT-UVA', 30),
    ('AT-P-AUSL-20', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('AT-P-AUSL-20', 'credit_note', 'tax', 100, '2235', '066', array['066']::text[], -100, 'AT-UVA', 20),
    ('AT-P-AUSL-20', 'credit_note', 'tax', -100, '6804', '057', array['057']::text[], -100, 'AT-UVA', 30),
    ('AT-P-BAU-20', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AT-P-BAU-20', 'invoice', 'tax', 100, '2236', '082', array['082']::text[], 100, 'AT-UVA', 20),
    ('AT-P-BAU-20', 'invoice', 'tax', -100, '6805', '048', array['048']::text[], 100, 'AT-UVA', 30),
    ('AT-P-BAU-20', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('AT-P-BAU-20', 'credit_note', 'tax', 100, '2236', '082', array['082']::text[], -100, 'AT-UVA', 20),
    ('AT-P-BAU-20', 'credit_note', 'tax', -100, '6805', '048', array['048']::text[], -100, 'AT-UVA', 30),
    ('AT-P-EUDL-20', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AT-P-EUDL-20', 'invoice', 'tax', 100, '2235', '066', array['066']::text[], 100, 'AT-UVA', 20),
    ('AT-P-EUDL-20', 'invoice', 'tax', -100, '6804', '057', array['057']::text[], 100, 'AT-UVA', 30),
    ('AT-P-EUDL-20', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('AT-P-EUDL-20', 'credit_note', 'tax', 100, '2235', '066', array['066']::text[], -100, 'AT-UVA', 20),
    ('AT-P-EUDL-20', 'credit_note', 'tax', -100, '6804', '057', array['057']::text[], -100, 'AT-UVA', 30),
    ('AT-P-IGE-20', 'invoice', 'base', 100, null, '072', array['072']::text[], 100, 'AT-UVA', 10),
    ('AT-P-IGE-20', 'invoice', 'tax', 100, '2234', '065', array['065']::text[], 100, 'AT-UVA', 20),
    ('AT-P-IGE-20', 'invoice', 'tax', -100, '6803', '072', array['072']::text[], 100, 'AT-UVA', 30),
    ('AT-P-IGE-20', 'credit_note', 'base', 100, null, '072', array['072']::text[], -100, 'AT-UVA', 10),
    ('AT-P-IGE-20', 'credit_note', 'tax', 100, '2234', '065', array['065']::text[], -100, 'AT-UVA', 20),
    ('AT-P-IGE-20', 'credit_note', 'tax', -100, '6803', '072', array['072']::text[], -100, 'AT-UVA', 30),
    ('AT-S-10', 'invoice', 'base', 100, null, '029', array['029']::text[], 100, 'AT-UVA', 10),
    ('AT-S-10', 'invoice', 'tax', 100, '6802', '029', array['029']::text[], 100, 'AT-UVA', 20),
    ('AT-S-10', 'credit_note', 'base', 100, null, '029', array['029']::text[], -100, 'AT-UVA', 10),
    ('AT-S-10', 'credit_note', 'tax', 100, '6802', '029', array['029']::text[], -100, 'AT-UVA', 20),
    ('AT-S-13', 'invoice', 'base', 100, null, '006', array['006']::text[], 100, 'AT-UVA', 10),
    ('AT-S-13', 'invoice', 'tax', 100, '6801', '006', array['006']::text[], 100, 'AT-UVA', 20),
    ('AT-S-13', 'credit_note', 'base', 100, null, '006', array['006']::text[], -100, 'AT-UVA', 10),
    ('AT-S-13', 'credit_note', 'tax', 100, '6801', '006', array['006']::text[], -100, 'AT-UVA', 20),
    ('AT-S-20', 'invoice', 'base', 100, null, '022', array['022']::text[], 100, 'AT-UVA', 10),
    ('AT-S-20', 'invoice', 'tax', 100, '6800', '022', array['022']::text[], 100, 'AT-UVA', 20),
    ('AT-S-20', 'credit_note', 'base', 100, null, '022', array['022']::text[], -100, 'AT-UVA', 10),
    ('AT-S-20', 'credit_note', 'tax', 100, '6800', '022', array['022']::text[], -100, 'AT-UVA', 20),
    ('AT-S-AUSF', 'invoice', 'base', 100, null, '011', array['011']::text[], 100, 'AT-UVA', 10),
    ('AT-S-AUSF', 'credit_note', 'base', 100, null, '011', array['011']::text[], -100, 'AT-UVA', 10),
    ('AT-S-BAU', 'invoice', 'base', 100, null, '021', array['021']::text[], 100, 'AT-UVA', 10),
    ('AT-S-BAU', 'credit_note', 'base', 100, null, '021', array['021']::text[], -100, 'AT-UVA', 10),
    ('AT-S-EUDL', 'invoice', 'base', 100, null, '021', array['021']::text[], 100, 'AT-UVA', 10),
    ('AT-S-EUDL', 'credit_note', 'base', 100, null, '021', array['021']::text[], -100, 'AT-UVA', 10),
    ('AT-S-IGL', 'invoice', 'base', 100, null, '017', array['017']::text[], 100, 'AT-UVA', 10),
    ('AT-S-IGL', 'credit_note', 'base', 100, null, '017', array['017']::text[], -100, 'AT-UVA', 10),
    ('AT-S-VERM', 'invoice', 'base', 100, null, '020', array['020']::text[], 100, 'AT-UVA', 10),
    ('AT-S-VERM', 'credit_note', 'base', 100, null, '020', array['020']::text[], -100, 'AT-UVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'AT' and t.code = v.tax_code
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
  ('AT', 'AT-UVA', 'Umsatzsteuervoranmeldung (Formular U30)', array['month', 'quarter']::declaration_period[], null, date '2026-01-01', null, 'UStG § 21 Abs. 1 und 2 — der Unternehmer hat eine Voranmeldung für den Kalendermonat (Voranmeldungszeitraum) elektronisch zu übermitteln; beträgt der Vorjahresumsatz höchstens 100 000 Euro, ist der Voranmeldungszeitraum das Kalendervierteljahr, mit Option auf den Kalendermonat für ein volles Kalenderjahr. Die Kennzahlen sind jene des Formulars U30 samt Ausfüllhilfe U30a für 2026.', true,null, null, null, null, null, null)
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
  ('AT', 'AT-UVA', '000', 'base', 'Gesamtbetrag der Bemessungsgrundlage für Lieferungen, sonstige Leistungen und Eigenverbrauch (ohne gesondert angeführten Eigenverbrauch), einschließlich Anzahlungen', '{"en":"Total taxable amount for supplies and self-consumption, including prepayments"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.1, Kennzahl 000 — eine reine Summenangabe, in die keine Steuer dieses Packs eigenständig hineinschreibt; siehe docs/international.md.', 'u30-2026'),
  ('AT', 'AT-UVA', '001', 'base', 'Zuzüglich Eigenverbrauch (§ 1 Abs. 1 Z 2, § 3 Abs. 2 und § 3a Abs. 1a)', '{"en":"Plus self-consumption"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.2, Kennzahl 001 — das Pack führt keine Eigenverbrauchstatbestände, die Zeile bleibt leer.', 'u30-2026'),
  ('AT', 'AT-UVA', '022', 'base', 'Lieferungen und sonstige Leistungen zum Normalsteuersatz 20 % — Bemessungsgrundlage', '{"en":"Supplies at the standard rate of 20 % — taxable amount"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.14, Kennzahl 022; UStG § 10 Abs. 1', 'u30-2026'),
  ('AT', 'AT-UVA', '022', 'tax', 'Lieferungen und sonstige Leistungen zum Normalsteuersatz 20 % — Umsatzsteuer', '{"en":"Supplies at the standard rate of 20 % — VAT"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.14, Kennzahl 022, Spalte Umsatzsteuer', 'u30-2026'),
  ('AT', 'AT-UVA', '029', 'base', 'Lieferungen und sonstige Leistungen zum ermäßigten Steuersatz 10 % — Bemessungsgrundlage', '{"en":"Supplies at the reduced rate of 10 % — taxable amount"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.15, Kennzahl 029; UStG § 10 Abs. 2', 'u30-2026'),
  ('AT', 'AT-UVA', '029', 'tax', 'Lieferungen und sonstige Leistungen zum ermäßigten Steuersatz 10 % — Umsatzsteuer', '{"en":"Supplies at the reduced rate of 10 % — VAT"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.15, Kennzahl 029, Spalte Umsatzsteuer', 'u30-2026'),
  ('AT', 'AT-UVA', '006', 'base', 'Lieferungen und sonstige Leistungen zum ermäßigten Steuersatz 13 % — Bemessungsgrundlage', '{"en":"Supplies at the reduced rate of 13 % — taxable amount"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.16, Kennzahl 006; UStG § 10 Abs. 3', 'u30-2026'),
  ('AT', 'AT-UVA', '006', 'tax', 'Lieferungen und sonstige Leistungen zum ermäßigten Steuersatz 13 % — Umsatzsteuer', '{"en":"Supplies at the reduced rate of 13 % — VAT"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.16, Kennzahl 006, Spalte Umsatzsteuer', 'u30-2026'),
  ('AT', 'AT-UVA', '011', 'base', 'Steuerfrei mit Vorsteuerabzug — § 6 Abs. 1 Z 1 iVm § 7 (Ausfuhrlieferungen)', '{"en":"Exempt with right of deduction — exports"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.5, Kennzahl 011', 'u30-2026'),
  ('AT', 'AT-UVA', '017', 'base', 'Steuerfrei mit Vorsteuerabzug — Art. 6 Abs. 1 (innergemeinschaftliche Lieferungen ohne Fahrzeuglieferungen)', '{"en":"Exempt with right of deduction — intra-Community supplies of goods"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.8, Kennzahl 017', 'u30-2026'),
  ('AT', 'AT-UVA', '020', 'base', 'Steuerfrei ohne Vorsteuerabzug — übrige Umsätze nach § 6 Abs. 1 Z, hier Z 16 (Vermietung und Verpachtung von Grundstücken)', '{"en":"Exempt without right of deduction — other supplies under section 6(1), here Z 16 (letting of immovable property)"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.12, Kennzahl 020; UStG § 6 Abs. 1 Z 16', 'u30-2026'),
  ('AT', 'AT-UVA', '021', 'base', 'Abzüglich Umsätze, für die die Steuerschuld gemäß § 19 Abs. 1 zweiter Satz sowie § 19 Abs. 1a bis 1d auf den Leistungsempfänger übergegangen ist', '{"en":"Less supplies on which the customer owes the tax under section 19(1) second sentence and section 19(1a) to (1d)"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.3, Kennzahl 021 — trägt sowohl die Bemessungsgrundlage der sonstigen Leistungen im übrigen Gemeinschaftsgebiet (§ 19 Abs. 1 zweiter Satz) als auch jene der Bauleistungen (§ 19 Abs. 1a), die dieses Pack führt; das Formular sieht dafür keine getrennten Kennzahlen vor.', 'u30-2026'),
  ('AT', 'AT-UVA', '072', 'base', 'Innergemeinschaftliche Erwerbe zum Normalsteuersatz 20 % — Bemessungsgrundlage', '{"en":"Intra-Community acquisitions at the standard rate of 20 % — taxable amount"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.28, Kennzahl 072; UStG Art. 1', 'u30-2026'),
  ('AT', 'AT-UVA', '072', 'tax', 'Innergemeinschaftliche Erwerbe zum Normalsteuersatz 20 % — Erwerbsteuer', '{"en":"Intra-Community acquisitions at the standard rate of 20 % — acquisition tax"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.28, Kennzahl 072, Spalte Umsatzsteuer', 'u30-2026'),
  ('AT', 'AT-UVA', '070', 'total', 'Gesamtbetrag der Bemessungsgrundlagen für innergemeinschaftliche Erwerbe', '{"en":"Total taxable amount of intra-Community acquisitions"}'::jsonb, 150, null, array['072:base']::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.25, Kennzahl 070 — Summe der Bemessungsgrundlagen aller Erwerbsteuersätze, hier allein jener zu 20 %, die dieses Pack führt.', 'u30-2026'),
  ('AT', 'AT-UVA', '048', 'tax', 'Steuerschuld gemäß § 19 Abs. 1a UStG (Bauleistungen)', '{"en":"Tax owed under section 19(1a) UStG (construction services)"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.22, Kennzahl 048 — das Formular verlangt für diese Zeile keine gesonderte Bemessungsgrundlage, nur den geschuldeten Steuerbetrag.', 'u30-2026'),
  ('AT', 'AT-UVA', '057', 'tax', 'Steuerschuld gemäß § 19 Abs. 1 zweiter Satz sowie Art. 25 Abs. 5 UStG', '{"en":"Tax owed under section 19(1) second sentence and Art. 25(5) UStG"}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.21, Kennzahl 057 — Steuerschuld für sonstige Leistungen eines im Ausland (Gemeinschaftsgebiet oder Drittland) ansässigen Unternehmers; das Formular verlangt keine gesonderte Bemessungsgrundlage.', 'u30-2026'),
  ('AT', 'AT-UVA', '044', 'tax', 'Steuerschuld gemäß § 19 Abs. 1b UStG (Sicherungseigentum, Vorbehaltseigentum und Grundstücke im Zwangsversteigerungsverfahren)', '{"en":"Tax owed under section 19(1b) UStG (retention of title and sale of land in enforced auction)"}'::jsonb, 175, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.23, Kennzahl 044 — keine Steuer dieses Packs schreibt in diese Zeile; siehe README und docs/international.md.', 'u30-2026'),
  ('AT', 'AT-UVA', '087', 'tax', 'Vorsteuern betreffend die Steuerschuld gemäß § 19 Abs. 1b UStG', '{"en":"Input VAT on the tax owed under section 19(1b) UStG"}'::jsonb, 176, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 5.7, Kennzahl 087 — keine Steuer dieses Packs schreibt in diese Zeile.', 'u30-2026'),
  ('AT', 'AT-UVA', '032', 'tax', 'Steuerschuld gemäß § 19 Abs. 1d UStG (Schrott, Altmetalle, Videospielkonsolen, Laptops, Tablet-Computer, Gas- und Elektrizitätszertifikate)', '{"en":"Tax owed under section 19(1d) UStG (scrap, waste metal, game consoles, laptops, tablets, gas or electricity certificates)"}'::jsonb, 177, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 4.24, Kennzahl 032 — keine Steuer dieses Packs schreibt in diese Zeile; siehe README und docs/international.md.', 'u30-2026'),
  ('AT', 'AT-UVA', '089', 'tax', 'Vorsteuern betreffend die Steuerschuld gemäß § 19 Abs. 1d UStG', '{"en":"Input VAT on the tax owed under section 19(1d) UStG"}'::jsonb, 178, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 5.8, Kennzahl 089 — keine Steuer dieses Packs schreibt in diese Zeile.', 'u30-2026'),
  ('AT', 'AT-UVA', '060', 'tax', 'Gesamtbetrag der Vorsteuern (ohne die gesondert angeführten Beträge)', '{"en":"Total input VAT (excluding the amounts stated separately)"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 5.1, Kennzahl 060; UStG § 12 Abs. 1 Z 1', 'u30-2026'),
  ('AT', 'AT-UVA', '065', 'tax', 'Vorsteuern aus dem innergemeinschaftlichen Erwerb', '{"en":"Input VAT on intra-Community acquisitions"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 5.4, Kennzahl 065; UStG § 12 Abs. 1 Z 1', 'u30-2026'),
  ('AT', 'AT-UVA', '066', 'tax', 'Vorsteuern betreffend die Steuerschuld gemäß § 19 Abs. 1 zweiter Satz sowie Art. 25 Abs. 5', '{"en":"Input VAT on the tax owed under section 19(1) second sentence and Art. 25(5)"}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 5.5, Kennzahl 066; UStG § 12 Abs. 1 Z 3', 'u30-2026'),
  ('AT', 'AT-UVA', '082', 'tax', 'Vorsteuern betreffend die Steuerschuld gemäß § 19 Abs. 1a (Bauleistungen)', '{"en":"Input VAT on the tax owed under section 19(1a) (construction services)"}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular U30, Punkt 5.6, Kennzahl 082; UStG § 12 Abs. 1 Z 3', 'u30-2026'),
  ('AT', 'AT-UVA', '095', 'total', 'Verbleibende Umsatzsteuervorauszahlung (Zahllast) bzw. Überschuss (Gutschrift)', '{"en":"Remaining VAT payment (payable) or surplus (credit)"}'::jsonb, 220, null, array['022:tax', '029:tax', '006:tax', '072:tax', '048', '057']::text[], array['060', '065', '066', '082']::text[], null, null, false, false, null, 'Formular U30, Punkt 7, Kennzahl 095 — ein Überschuss wird mit Minuszeichen angegeben, deshalb ohne Untergrenze bei null.', 'u30-2026')
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
  ('AT-UGB-224-BS', 'AT', 'default', 'Bilanz nach § 224 UGB', 'balance_sheet', 'AT-UGB', date '2016-01-01', null, 'Unternehmensgesetzbuch § 224 Abs. 1 bis 3 in der Fassung des Rechnungslegungs-Änderungsgesetzes 2014 — Gliederung der Bilanz in Kontoform, Aktivseite Abs. 2 und Passivseite Abs. 3. Die Zeilen sind die gesetzlichen Posten mit Buchstaben und römischen Zahlen; kleine und mittelgroße Gesellschaften dürfen nach § 242 Abs. 1 iVm den Größenklassen des § 221 die mit Buchstaben und römischen Zahlen bezeichneten Posten zusammengefasst ausweisen, die hier als Summenzeilen vorhanden sind.', 'ugb'),
  ('AT-UGB-231-GKV', 'AT', 'default', 'Gewinn- und Verlustrechnung nach § 231 Abs. 2 UGB (Gesamtkostenverfahren)', 'income_statement', 'AT-UGB', date '2016-01-01', null, 'Unternehmensgesetzbuch § 231 Abs. 2 — Staffelform nach dem Gesamtkostenverfahren, Posten 1 bis 26 in der gesetzlichen Reihenfolge. Das Umsatzkostenverfahren (Abs. 3) setzt eine Kostenstellenrechnung voraus, die dieser Kontenplan nicht abbildet, und wird von diesem Pack nicht geführt. Die Posten 22 bis 26 (Rücklagenbewegung, Gewinnvortrag, Bilanzgewinn) sind nicht als eigene Zeilen dieser Rechnung geführt: dieses Pack schließt mit closing_style retained_earnings unmittelbar in das Bilanzkonto 4400, ohne ein eigenes Ergebnisverwendungskonto in der Gewinn- und Verlustrechnung.', 'ugb')
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
  ('AT-UGB-224-BS', 'AKT', null, 'Summe Aktiva', '{"en":"Total assets"}'::jsonb, 10, 1, true, array['A', 'B', 'C', 'D']::text[], '{}'::text[], null, 'UGB § 224 Abs. 2', 'ugb'),
  ('AT-UGB-224-BS', 'A', 'AKT', 'A. Anlagevermögen', '{"en":"A. Fixed assets"}'::jsonb, 20, 1, true, array['A.I', 'A.II', 'A.III']::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 A', 'ugb'),
  ('AT-UGB-224-BS', 'A.I', 'A', 'I. Immaterielle Vermögensgegenstände', '{"en":"I. Intangible assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 A.I', 'ugb'),
  ('AT-UGB-224-BS', 'A.II', 'A', 'II. Sachanlagen', '{"en":"II. Tangible assets"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 A.II', 'ugb'),
  ('AT-UGB-224-BS', 'A.III', 'A', 'III. Finanzanlagen', '{"en":"III. Financial assets"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 A.III', 'ugb'),
  ('AT-UGB-224-BS', 'B', 'AKT', 'B. Umlaufvermögen', '{"en":"B. Current assets"}'::jsonb, 60, 1, true, array['B.I', 'B.II', 'B.III', 'B.IV']::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 B', 'ugb'),
  ('AT-UGB-224-BS', 'B.I', 'B', 'I. Vorräte', '{"en":"I. Inventories"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 B.I', 'ugb'),
  ('AT-UGB-224-BS', 'B.II', 'B', 'II. Forderungen und sonstige Vermögensgegenstände', '{"en":"II. Receivables and other assets"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 B.II', 'ugb'),
  ('AT-UGB-224-BS', 'B.III', 'B', 'III. Wertpapiere und Anteile', '{"en":"III. Securities and shares"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 B.III', 'ugb'),
  ('AT-UGB-224-BS', 'B.IV', 'B', 'IV. Kassenbestand, Schecks, Guthaben bei Kreditinstituten', '{"en":"IV. Cash in hand, cheques, bank balances"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 B.IV', 'ugb'),
  ('AT-UGB-224-BS', 'C', 'AKT', 'C. Rechnungsabgrenzungsposten', '{"en":"C. Prepaid expenses"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 C', 'ugb'),
  ('AT-UGB-224-BS', 'D', 'AKT', 'D. Aktive latente Steuern', '{"en":"D. Deferred tax assets"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 2 D', 'ugb'),
  ('AT-UGB-224-BS', 'PASS', null, 'Summe Passiva', '{"en":"Total equity and liabilities"}'::jsonb, 130, 1, true, array['P.A', 'P.B', 'P.C', 'P.D']::text[], '{}'::text[], null, 'UGB § 224 Abs. 3', 'ugb'),
  ('AT-UGB-224-BS', 'P.A', 'PASS', 'A. Eigenkapital', '{"en":"A. Equity"}'::jsonb, 140, 1, true, array['P.A.I', 'P.A.II', 'P.A.III', 'P.A.IV']::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 A', 'ugb'),
  ('AT-UGB-224-BS', 'P.A.I', 'P.A', 'I. Eingefordertes Nennkapital', '{"en":"I. Called-up nominal capital"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 A.I', 'ugb'),
  ('AT-UGB-224-BS', 'P.A.II', 'P.A', 'II. Kapitalrücklagen', '{"en":"II. Capital reserves"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 A.II', 'ugb'),
  ('AT-UGB-224-BS', 'P.A.III', 'P.A', 'III. Gewinnrücklagen', '{"en":"III. Revenue reserves"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 A.III', 'ugb'),
  ('AT-UGB-224-BS', 'P.A.IV', 'P.A', 'IV. Bilanzgewinn (Bilanzverlust)', '{"en":"IV. Retained profit (accumulated loss)"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 A.IV — nimmt nach dem Jahresabschluss auch den Jahresüberschuss/Jahresfehlbetrag auf, da dieses Pack keinen eigenen Zwischenposten dafür führt (closing_style retained_earnings).', 'ugb'),
  ('AT-UGB-224-BS', 'P.B', 'PASS', 'B. Rückstellungen', '{"en":"B. Provisions"}'::jsonb, 190, 1, true, array['P.B.1', 'P.B.2', 'P.B.3', 'P.B.4']::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 B', 'ugb'),
  ('AT-UGB-224-BS', 'P.B.1', 'P.B', '1. Rückstellungen für Abfertigungen', '{"en":"1. Provisions for severance payments"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 B.1', 'ugb'),
  ('AT-UGB-224-BS', 'P.B.2', 'P.B', '2. Rückstellungen für Pensionen', '{"en":"2. Provisions for pensions"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 B.2', 'ugb'),
  ('AT-UGB-224-BS', 'P.B.3', 'P.B', '3. Steuerrückstellungen', '{"en":"3. Tax provisions"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 B.3', 'ugb'),
  ('AT-UGB-224-BS', 'P.B.4', 'P.B', '4. sonstige Rückstellungen', '{"en":"4. Other provisions"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 B.4 — führt auch die passiven latenten Steuern (5320), die UGB Rechnungslegungs-Änderungsgesetz 2014 als Rückstellung behandelt und nicht als eigenen Bilanzposten ausweist.', 'ugb'),
  ('AT-UGB-224-BS', 'P.C', 'PASS', 'C. Verbindlichkeiten', '{"en":"C. Liabilities"}'::jsonb, 240, 1, true, array['P.C.1', 'P.C.2', 'P.C.3', 'P.C.4', 'P.C.5', 'P.C.6', 'P.C.8']::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.1', 'P.C', '1. Anleihen', '{"en":"1. Bonds"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.1', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.2', 'P.C', '2. Verbindlichkeiten gegenüber Kreditinstituten', '{"en":"2. Amounts owed to credit institutions"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.2', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.3', 'P.C', '3. Erhaltene Anzahlungen auf Bestellungen', '{"en":"3. Payments received on account of orders"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.3', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.4', 'P.C', '4. Verbindlichkeiten aus Lieferungen und Leistungen', '{"en":"4. Trade payables"}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.4', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.5', 'P.C', '5. Verbindlichkeiten aus der Annahme gezogener Wechsel', '{"en":"5. Liabilities from bills of exchange"}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.5', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.6', 'P.C', '6./7. Verbindlichkeiten gegenüber verbundenen Unternehmen und Unternehmen, mit denen ein Beteiligungsverhältnis besteht', '{"en":"6./7. Amounts owed to affiliated undertakings and undertakings with which a participating interest exists"}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.6 und C.7', 'ugb'),
  ('AT-UGB-224-BS', 'P.C.8', 'P.C', '8. sonstige Verbindlichkeiten, davon aus Steuern und im Rahmen der sozialen Sicherheit', '{"en":"8. Other liabilities, of which tax and social security"}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 C.8', 'ugb'),
  ('AT-UGB-224-BS', 'P.D', 'PASS', 'D. Rechnungsabgrenzungsposten', '{"en":"D. Deferred income"}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 224 Abs. 3 D', 'ugb'),
  ('AT-UGB-231-GKV', '1', null, '1. Umsatzerlöse', '{"en":"1. Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 1', 'ugb'),
  ('AT-UGB-231-GKV', '2', null, '2. Veränderung des Bestands an fertigen und unfertigen Erzeugnissen', '{"en":"2. Change in inventories of finished goods and work in progress"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 2', 'ugb'),
  ('AT-UGB-231-GKV', '3', null, '3. andere aktivierte Eigenleistungen', '{"en":"3. Own work capitalised"}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 3', 'ugb'),
  ('AT-UGB-231-GKV', '4', null, '4. sonstige betriebliche Erträge', '{"en":"4. Other operating income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 4', 'ugb'),
  ('AT-UGB-231-GKV', '5', null, '5. Aufwendungen für Material und sonstige bezogene Herstellungsleistungen', '{"en":"5. Cost of materials and other purchased manufacturing services"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 5', 'ugb'),
  ('AT-UGB-231-GKV', '6', null, '6. Personalaufwand', '{"en":"6. Personnel expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 6', 'ugb'),
  ('AT-UGB-231-GKV', '7', null, '7. Abschreibungen', '{"en":"7. Depreciation and amortisation"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 7', 'ugb'),
  ('AT-UGB-231-GKV', '8', null, '8. sonstige betriebliche Aufwendungen', '{"en":"8. Other operating expenses"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 8', 'ugb'),
  ('AT-UGB-231-GKV', '9', null, '9. Zwischensumme aus Z 1 bis 8', '{"en":"9. Subtotal of items 1 to 8"}'::jsonb, 90, 1, true, array['1', '2', '3', '4']::text[], array['5', '6', '7', '8']::text[], null, 'UGB § 231 Abs. 2 Z 9', 'ugb'),
  ('AT-UGB-231-GKV', '10', null, '10. Erträge aus Beteiligungen', '{"en":"10. Income from participating interests"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 10', 'ugb'),
  ('AT-UGB-231-GKV', '12', null, '12. sonstige Zinsen und ähnliche Erträge', '{"en":"12. Other interest and similar income"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 12', 'ugb'),
  ('AT-UGB-231-GKV', '15', null, '15. Zinsen und ähnliche Aufwendungen', '{"en":"15. Interest and similar expenses"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 15', 'ugb'),
  ('AT-UGB-231-GKV', '16', null, '16. Zwischensumme aus Z 10 bis 15', '{"en":"16. Subtotal of items 10 to 15"}'::jsonb, 130, 1, true, array['10', '12']::text[], array['15']::text[], null, 'UGB § 231 Abs. 2 Z 16 — die Posten 11, 13 und 14 sind nicht geführt: dieses Pack bildet weder Wertpapiere des Finanzanlagevermögens noch Wertpapiere des Umlaufvermögens auf einem eigenen Ertrags- oder Aufwandskonto ab.', 'ugb'),
  ('AT-UGB-231-GKV', '17', null, '17. Ergebnis vor Steuern', '{"en":"17. Profit or loss before tax"}'::jsonb, 140, 1, true, array['9', '16']::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 17', 'ugb'),
  ('AT-UGB-231-GKV', '18', null, '18. Steuern vom Einkommen und vom Ertrag', '{"en":"18. Income tax"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 18', 'ugb'),
  ('AT-UGB-231-GKV', '19', null, '19. Ergebnis nach Steuern', '{"en":"19. Profit or loss after tax"}'::jsonb, 160, 1, true, array['17']::text[], array['18']::text[], null, 'UGB § 231 Abs. 2 Z 19', 'ugb'),
  ('AT-UGB-231-GKV', '20', null, '20. sonstige Steuern', '{"en":"20. Other taxes"}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, 'UGB § 231 Abs. 2 Z 20', 'ugb'),
  ('AT-UGB-231-GKV', '21', null, '21. Jahresüberschuss/Jahresfehlbetrag', '{"en":"21. Net income or net loss for the year"}'::jsonb, 180, 1, true, array['19']::text[], array['20']::text[], null, 'UGB § 231 Abs. 2 Z 21', 'ugb')
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
    ('AT-UGB-224-BS', 'A.I', 10, 'code_range', '1100', '1199', null, 'any'),
    ('AT-UGB-224-BS', 'A.II', 10, 'code_range', '1200', '1299', null, 'any'),
    ('AT-UGB-224-BS', 'A.III', 10, 'code_range', '1300', '1399', null, 'any'),
    ('AT-UGB-224-BS', 'B.I', 10, 'code_range', '2100', '2199', null, 'any'),
    ('AT-UGB-224-BS', 'B.II', 10, 'code_range', '2200', '2299', null, 'any'),
    ('AT-UGB-224-BS', 'B.III', 10, 'code_range', '2300', '2399', null, 'any'),
    ('AT-UGB-224-BS', 'B.IV', 10, 'code_range', '2400', '2499', null, 'any'),
    ('AT-UGB-224-BS', 'C', 10, 'code_range', '3100', '3199', null, 'any'),
    ('AT-UGB-224-BS', 'D', 10, 'code_range', '3200', '3299', null, 'any'),
    ('AT-UGB-224-BS', 'P.A.I', 10, 'code_range', '4100', '4199', null, 'any'),
    ('AT-UGB-224-BS', 'P.A.II', 10, 'code_range', '4200', '4299', null, 'any'),
    ('AT-UGB-224-BS', 'P.A.III', 10, 'code_range', '4300', '4399', null, 'any'),
    ('AT-UGB-224-BS', 'P.A.IV', 10, 'code_range', '4400', '4499', null, 'any'),
    ('AT-UGB-224-BS', 'P.B.1', 10, 'code_range', '5100', '5199', null, 'any'),
    ('AT-UGB-224-BS', 'P.B.2', 10, 'code_range', '5200', '5299', null, 'any'),
    ('AT-UGB-224-BS', 'P.B.3', 10, 'code_range', '5300', '5300', null, 'any'),
    ('AT-UGB-224-BS', 'P.B.4', 10, 'code_range', '5310', '5399', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.1', 10, 'code_range', '6100', '6199', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.2', 10, 'code_range', '6200', '6299', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.3', 10, 'code_range', '6300', '6399', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.4', 10, 'code_range', '6400', '6499', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.5', 10, 'code_range', '6500', '6599', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.6', 10, 'code_range', '6600', '6699', null, 'any'),
    ('AT-UGB-224-BS', 'P.C.8', 10, 'code_range', '6800', '6899', null, 'any'),
    ('AT-UGB-224-BS', 'P.D', 10, 'code_range', '7100', '7199', null, 'any'),
    ('AT-UGB-231-GKV', '1', 10, 'code_range', '8100', '8108', null, 'any'),
    ('AT-UGB-231-GKV', '2', 10, 'code_range', '8200', '8200', null, 'any'),
    ('AT-UGB-231-GKV', '3', 10, 'code_range', '8300', '8300', null, 'any'),
    ('AT-UGB-231-GKV', '4', 10, 'code_range', '8400', '8430', null, 'any'),
    ('AT-UGB-231-GKV', '5', 10, 'code_range', '8500', '8502', null, 'any'),
    ('AT-UGB-231-GKV', '6', 10, 'code_range', '8600', '8630', null, 'any'),
    ('AT-UGB-231-GKV', '7', 10, 'code_range', '8700', '8710', null, 'any'),
    ('AT-UGB-231-GKV', '8', 10, 'code_range', '8800', '8819', null, 'any'),
    ('AT-UGB-231-GKV', '10', 10, 'code_range', '9100', '9100', null, 'any'),
    ('AT-UGB-231-GKV', '12', 10, 'code_range', '9110', '9110', null, 'any'),
    ('AT-UGB-231-GKV', '15', 10, 'code_range', '9200', '9200', null, 'any'),
    ('AT-UGB-231-GKV', '18', 10, 'code_range', '9300', '9300', null, 'any'),
    ('AT-UGB-231-GKV', '20', 10, 'code_range', '9310', '9310', null, 'any')
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
  ('AT', 'Austria', '{"en":"Austria"}'::jsonb, array['de', 'en']::text[], 'EUR', '2200', '6400', '2239', '8818', '4400', '8100', '8500', '2410', '2400', 'VK', 'EK', 'SO', 'de', 'retained_earnings', null, null, null, 'EB', 'half_up', default, '8430', '8808', null, null, null, null, '6810', '2237', null, null)
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
  late_payment_reference        = 'UGB § 456 — Verzugszinsen zwischen Unternehmern in Höhe von 9,2 Prozentpunkten über dem von der Oesterreichischen Nationalbank festgelegten Basiszinssatz; UGB § 458 — eine Pauschale von 40 Euro, die der Gläubiger unabhängig vom Nachweis eines Schadens verlangen kann; darüber hinausgehende zweckentsprechende Betreibungskosten nach § 1333 Abs. 2 ABGB.',
  numbering_legal_reference     = 'UStG § 11 Abs. 1 Z 3 lit. h — eine fortlaufende Nummer mit einer oder mehreren Zahlenreihen, die zur Identifizierung der Rechnung vom Rechnungsaussteller einmalig vergeben wird. Das Gesetz verlangt Einmaligkeit und keine lückenlose Folge, daher sequential und nicht gapless; mehrere Nummernkreise sind zulässig.',
  numbering_source_key          = 'ustg',
  payment_terms_legal_reference = 'ABGB § 907a in der Fassung des Zahlungsverzugsgesetzes 2013 (BGBl. I Nr. 50/2013, Umsetzung der Richtlinie 2011/7/EU) regelt die Erfüllung einer Geldschuld; das Gesetz sieht mangels Vereinbarung eine Fälligkeit von 30 Tagen nach Erhalt der Rechnung oder der Leistung vor, mit einer Höchstgrenze von 60 Tagen bei ausdrücklicher Vereinbarung zwischen Unternehmern (§ 456 UGB). Dieser Punkt stützt sich auf sekundäre Quellen, die den RIS-Volltext zusammenfassen, und sollte vor einer Statusänderung auf reviewed am RIS-Volltext geprüft werden.',
  payment_terms_source_key      = 'abgb',
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'UStG § 19 Abs. 2 Z 1 lit. a — die Steuerschuld entsteht mit Ablauf des Kalendermonats, in dem die Lieferung oder sonstige Leistung ausgeführt worden ist (Sollbesteuerung, Grundsatz); wird das Entgelt oder ein Teil davon vereinnahmt, bevor die Leistung ausgeführt worden ist, entsteht die Steuerschuld insoweit bereits mit Ablauf des Voranmeldungszeitraums der Vereinnahmung. Beide Zweige zusammen sind earliest_of_delivery_or_payment. Nicht abgebildet: die Istbesteuerung nach § 17 auf Antrag oder kraft Berufs, die eigens als cash_basis auf der jeweiligen Steuer erklärt wird.',
  tax_point_source_key          = 'ustg',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'UGB § 190 Abs. 4 — eine Eintragung oder eine Aufzeichnung darf nicht in einer Weise verändert werden, dass der ursprüngliche Inhalt nicht mehr feststellbar ist. Eine gebuchte Rechnung wird daher nur durch eine Stornorechnung oder Gutschrift berichtigt, die auf sie verweist.',
  posted_edit_policy_source_key = 'ugb',
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Für den Bund besteht die elektronische Rechnungslegung seit 1. Jänner 2014 verpflichtend (§ 5 IKT-Konsolidierungsgesetz, IKTKonG), in den Formaten ebInterface (nationales XML-Format) oder PEPPOL BIS, eingebracht über das Unternehmensserviceportal (USP) oder erechnung.gv.at; diese Pflicht bindet nur Lieferanten des Bundes und wird hier nicht als Landespflicht abgebildet. Eine allgemeine Pflicht zur elektronischen Rechnung zwischen Unternehmern besteht zum released_at dieses Packs nicht: die Reform ViDA (VAT in the Digital Age) der Europäischen Union sieht grenzüberschreitende digitale Meldepflichten erst ab Juli 2030 vor, ohne dass eine österreichische Umsetzung bereits veröffentlicht wäre. profile nennt das auf dem USP unterstützte PEPPOL-BIS-Billing-3.0-Profil, das dem semantischen Modell der EN 16931 entspricht; das nationale ebInterface-Format ist gleichwertig zulässig, aber nicht Teil dieses geschlossenen Vokabulars. vat_scheme 9915 ist die österreichische UID in der EAS-Liste. party_scheme bleibt leer: zwischen Unternehmen gibt es kein vorgeschriebenes Netz und keine einheitliche Adresskennung.',
  einvoice_source_key           = 'erechnung-bund',
  party_scheme                  = null,
  vat_scheme                    = '9915',
  bank_statement_formats        = array['camt.053']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'AT';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('AT', 'reverse_charge', 'reverse_charge', 'Steuerschuldnerschaft des Leistungsempfängers', '{"en":"Reverse charge — the recipient of the supply is liable for the tax"}'::jsonb, 10, date '1970-01-01', null, 'UStG § 11 Abs. 1a — bei einer Leistung, für die der Empfänger die Steuer nach § 19 Abs. 1 zweiter Satz oder Abs. 1a bis 1e schuldet, hat der leistende Unternehmer auf die Steuerschuldnerschaft des Leistungsempfängers hinzuweisen; einen vorgeschriebenen Wortlaut kennt das Gesetz nicht.'),
  ('AT', 'intracom_goods', 'intra_eu_goods', 'Steuerfreie innergemeinschaftliche Lieferung', '{"en":"Exempt intra-Community supply of goods"}'::jsonb, 20, date '1970-01-01', null, 'UStG Art. 6 Abs. 1 iVm Art. 7 Abs. 1 Binnenmarktregelung — steuerfrei ist die innergemeinschaftliche Lieferung an einen Abnehmer, der eine ihm von einem anderen Mitgliedstaat erteilte Umsatzsteuer-Identifikationsnummer verwendet.'),
  ('AT', 'intracom_services', 'intra_eu_services', 'Steuerschuldnerschaft des Leistungsempfängers', '{"en":"Reverse charge — the recipient of the supply is liable for the tax"}'::jsonb, 30, date '1970-01-01', null, 'UStG § 11 Abs. 1a iVm § 3a Abs. 6 — eine sonstige Leistung an einen Unternehmer für dessen Unternehmen wird an dessen Sitz ausgeführt; der Leistungsempfänger schuldet die Steuer nach § 19 Abs. 1 zweiter Satz, und die Rechnung weist auf seine Steuerschuldnerschaft hin.'),
  ('AT', 'export', 'export', 'Steuerfreie Ausfuhrlieferung', '{"en":"Exempt export of goods"}'::jsonb, 40, date '1970-01-01', null, 'UStG § 6 Abs. 1 Z 1 iVm § 7 — steuerfrei sind Ausfuhrlieferungen; ein Hinweis auf die Steuerbefreiung ist nach § 11 Abs. 1 Z 3 lit. g erforderlich.'),
  ('AT', 'exempt', 'exempt', 'Steuerfreier Umsatz', '{"en":"Exempt supply"}'::jsonb, 50, date '1970-01-01', null, 'UStG § 11 Abs. 1 Z 3 lit. g — im Fall einer Steuerbefreiung ein Hinweis darauf, dass für die Lieferung oder sonstige Leistung eine Steuerbefreiung gilt. Das Gesetz schreibt für diesen Hinweis keinen Wortlaut vor.'),
  ('AT', 'small_business', 'small_business', 'Steuerfrei nach § 6 Abs. 1 Z 27 UStG (Kleinunternehmerregelung)', '{"en":"Exempt under the small-business scheme, section 6(1) Z 27 UStG"}'::jsonb, 60, date '1970-01-01', null, 'UStG § 6 Abs. 1 Z 27 — steuerfrei sind die Umsätze eines Kleinunternehmers, dessen Umsätze im Veranlagungszeitraum die Kleinunternehmergrenze von 55 000 Euro im vorangegangenen Kalenderjahr nicht und im laufenden Jahr noch nicht übersteigen, mit einer Toleranz von 10 % bis zum Ende des Kalenderjahres. Seit 1. Jänner 2025 (Abgabenänderungsgesetz 2024) steht die Befreiung unter denselben Voraussetzungen auch Unternehmern anderer Mitgliedstaaten offen, deren unionsweiter Jahresumsatz 100 000 Euro nicht übersteigt (Art. 6a).'),
  ('AT', 'late_payment', 'late_payment', 'Bei Zahlungsverzug gebühren Verzugszinsen in Höhe von 9,2 Prozentpunkten über dem Basiszinssatz sowie eine Pauschale von 40 Euro (§§ 456 und 458 UGB).', '{"en":"On late payment, default interest of 9.2 percentage points above the base rate and a flat fee of 40 euros are due (sections 456 and 458 UGB)."}'::jsonb, 70, date '1970-01-01', null, 'UGB § 456 und § 458 — siehe documents.late_payment_reference.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
