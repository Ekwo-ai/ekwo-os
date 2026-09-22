-- Ekwo OS — Schweiz: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ch at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ch`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Bundesgesetz über die Mehrwertsteuer (Mehrwertsteuergesetz, MWSTG) vom 12. Juni 2009 (SR 641.20), Stand am 31. März 2025 (Bundeskanzlei — Fedlex)
--     https://www.fedlex.admin.ch/eli/cc/2009/615/de
--   Bundesgesetz betreffend die Ergänzung des Schweizerischen Zivilgesetzbuches (Fünfter Teil: Obligationenrecht, OR) vom 30. März 1911 (SR 220) — insbesondere Art. 75 und 104 (Erfüllungszeit, Verzugszins) und Art. 957–963b (kaufmännische Buchführung und Rechnungslegung) (Bundeskanzlei — Fedlex)
--     https://www.fedlex.admin.ch/eli/cc/27/317_321_377/de
--   Verordnung der ESTV über die Höhe der Steuersätze für Saldosteuersätze nach Branche und Tätigkeit vom 5. September 2024 (SR 641.202.62), Stand am 1. Januar 2025 (Eidgenössische Steuerverwaltung (ESTV))
--     https://www.fedlex.admin.ch/eli/cc/2024/500/de
--   Formular Nr. 4470 — Abrechnung Mehrwertsteuer, effektive Methode, gültig ab 1. Januar 2024 (Muster) (Eidgenössische Steuerverwaltung (ESTV))
--     https://www.estv2.admin.ch/mwst/formulare/mwst-form-abr-muster-2024-4470-eff-fr.pdf
--   MWST-Sätze in der Schweiz (Eidgenössische Steuerverwaltung (ESTV))
--     https://www.estv.admin.ch/de/mwst-steuersaetze-schweiz
--   Saldosteuersätze und Pauschalsteuersätze (Eidgenössische Steuerverwaltung (ESTV))
--     https://www.estv.admin.ch/de/mwst-saldosteuersaetze-pauschalsteuersaetze
--   Steuerpflicht Bezugsteuer bei der Mehrwertsteuer (Eidgenössische Steuerverwaltung (ESTV))
--     https://www.estv.admin.ch/de/steuerpflicht-bezugsteuer-mwst
--   eCH-0217 Spezifikation e-MWST — Format für die elektronische Übermittlung der MWST-Abrechnung an das ESTV-Portal SuisseTax (Verein eCH)
--     https://www.ech.ch/de/ech/ech-0217/1.0
--   Verbindlichkeit der eCH-Standards — genehmigte eCH-Standards haben Empfehlungscharakter (Verein eCH)
--     https://www.ech.ch/de/ech-standards/verbindlichkeit
--   Décompter la TVA en ligne — le portail AFC (Décompte TVA pro) par lequel l'abrechnung est déposée (Eidgenössische Steuerverwaltung (ESTV))
--     https://www.estv.admin.ch/fr/decompter-la-tva-en-ligne
--   QR-bill — the Swiss standard for payment slips with QR code, replacing the red and orange payment slips since 1 October 2022 (SIX Group)
--     https://www.six-group.com/en/products-services/banking-services/payment-standardization/standards/qr-bill.html
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('CH', 'Schweiz', '0.1.0', date '2026-09-22', '20260921145425', 'community', null, null, '903c384c6df0dd76f7ac807d35c93db5baa10437fa42e4541823a5fed4915ede', '[{"key":"mwstg","title":"Bundesgesetz über die Mehrwertsteuer (Mehrwertsteuergesetz, MWSTG) vom 12. Juni 2009 (SR 641.20), Stand am 31. März 2025","publisher":"Bundeskanzlei — Fedlex","url":"https://www.fedlex.admin.ch/eli/cc/2009/615/de","consulted_on":"2026-09-22","kind":"law"},{"key":"or","title":"Bundesgesetz betreffend die Ergänzung des Schweizerischen Zivilgesetzbuches (Fünfter Teil: Obligationenrecht, OR) vom 30. März 1911 (SR 220) — insbesondere Art. 75 und 104 (Erfüllungszeit, Verzugszins) und Art. 957–963b (kaufmännische Buchführung und Rechnungslegung)","publisher":"Bundeskanzlei — Fedlex","url":"https://www.fedlex.admin.ch/eli/cc/27/317_321_377/de","consulted_on":"2026-09-22","kind":"law"},{"key":"tdfn-verordnung","title":"Verordnung der ESTV über die Höhe der Steuersätze für Saldosteuersätze nach Branche und Tätigkeit vom 5. September 2024 (SR 641.202.62), Stand am 1. Januar 2025","publisher":"Eidgenössische Steuerverwaltung (ESTV)","url":"https://www.fedlex.admin.ch/eli/cc/2024/500/de","consulted_on":"2026-09-22","kind":"regulation"},{"key":"mwst-4470","title":"Formular Nr. 4470 — Abrechnung Mehrwertsteuer, effektive Methode, gültig ab 1. Januar 2024 (Muster)","publisher":"Eidgenössische Steuerverwaltung (ESTV)","url":"https://www.estv2.admin.ch/mwst/formulare/mwst-form-abr-muster-2024-4470-eff-fr.pdf","consulted_on":"2026-09-22","kind":"form"},{"key":"estv-mwst-saetze","title":"MWST-Sätze in der Schweiz","publisher":"Eidgenössische Steuerverwaltung (ESTV)","url":"https://www.estv.admin.ch/de/mwst-steuersaetze-schweiz","consulted_on":"2026-09-22","kind":"guidance"},{"key":"estv-saldosteuersatz","title":"Saldosteuersätze und Pauschalsteuersätze","publisher":"Eidgenössische Steuerverwaltung (ESTV)","url":"https://www.estv.admin.ch/de/mwst-saldosteuersaetze-pauschalsteuersaetze","consulted_on":"2026-09-22","kind":"guidance"},{"key":"estv-bezugsteuer","title":"Steuerpflicht Bezugsteuer bei der Mehrwertsteuer","publisher":"Eidgenössische Steuerverwaltung (ESTV)","url":"https://www.estv.admin.ch/de/steuerpflicht-bezugsteuer-mwst","consulted_on":"2026-09-22","kind":"guidance"},{"key":"ech-0217","title":"eCH-0217 Spezifikation e-MWST — Format für die elektronische Übermittlung der MWST-Abrechnung an das ESTV-Portal SuisseTax","publisher":"Verein eCH","url":"https://www.ech.ch/de/ech/ech-0217/1.0","consulted_on":"2026-09-22","kind":"standard"},{"key":"ech-verbindlichkeit","title":"Verbindlichkeit der eCH-Standards — genehmigte eCH-Standards haben Empfehlungscharakter","publisher":"Verein eCH","url":"https://www.ech.ch/de/ech-standards/verbindlichkeit","consulted_on":"2026-09-22","kind":"guidance"},{"key":"estv-decompte-online","title":"Décompter la TVA en ligne — le portail AFC (Décompte TVA pro) par lequel l''abrechnung est déposée","publisher":"Eidgenössische Steuerverwaltung (ESTV)","url":"https://www.estv.admin.ch/fr/decompter-la-tva-en-ligne","consulted_on":"2026-09-22","kind":"portal"},{"key":"six-qr-rechnung","title":"QR-bill — the Swiss standard for payment slips with QR code, replacing the red and orange payment slips since 1 October 2022","publisher":"SIX Group","url":"https://www.six-group.com/en/products-services/banking-services/payment-standardization/standards/qr-bill.html","consulted_on":"2026-09-22","kind":"standard"}]'::jsonb)
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
  ('CH', 'default', 'Kontenrahmen nach Art. 959/959b OR', '{"fr":"Plan comptable établi selon les art. 959/959b CO"}'::jsonb, true, 'companies', array['CH-OR-959-BS', 'CH-OR-959B-IS']::text[], null, 'Das schweizerische Recht schreibt keinen gesetzlichen Kontenplan vor. Art. 957a OR verlangt eine den Verhältnissen des Unternehmens angemessene, vollständige, wahrheitsgetreue und systematische Erfassung der Geschäftsvorfälle, Art. 959/959a/959b OR geben die Mindestgliederung von Bilanz und Erfolgsrechnung vor. Der in der Praxis verbreitete « Schweizer Kontenrahmen KMU » (herausgegeben von veb.ch) hat keinen gesetzlichen Status; dieser Kontenrahmen kopiert ihn nicht, sondern folgt unmittelbar der Gliederung von Art. 959 Abs. 5/6 und Art. 959b Abs. 2 OR — siehe README.md.', 'or')
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
  ('CH', 'default', '1000', 'Kasse', '{"fr":"Caisse"}'::jsonb, 'asset_cash', false, null, 10),
  ('CH', 'default', '1010', 'Kasse Fremdwährung', '{"fr":"Caisse devises étrangères"}'::jsonb, 'asset_cash', false, null, 20),
  ('CH', 'default', '1020', 'Post-/Bankkonto CHF', '{"fr":"Compte postal/bancaire CHF"}'::jsonb, 'asset_cash', false, null, 30),
  ('CH', 'default', '1021', 'Post-/Bankkonto Fremdwährung', '{"fr":"Compte postal/bancaire devises étrangères"}'::jsonb, 'asset_cash', false, null, 40),
  ('CH', 'default', '1023', 'PostFinance-Konto', '{"fr":"Compte PostFinance"}'::jsonb, 'asset_cash', false, null, 50),
  ('CH', 'default', '1030', 'Festgeldanlagen', '{"fr":"Placements à terme"}'::jsonb, 'asset_current', true, null, 60),
  ('CH', 'default', '1050', 'Wertschriften Obligationen', '{"fr":"Titres — obligations"}'::jsonb, 'asset_current', true, null, 70),
  ('CH', 'default', '1055', 'Wertschriften Aktien', '{"fr":"Titres — actions"}'::jsonb, 'asset_current', true, null, 80),
  ('CH', 'default', '1100', 'Forderungen aus Lieferungen und Leistungen', '{"fr":"Créances résultant de livraisons et de prestations"}'::jsonb, 'asset_receivable', true, null, 90),
  ('CH', 'default', '1101', 'Forderungen gegenüber nahestehenden Personen', '{"fr":"Créances envers des personnes proches"}'::jsonb, 'asset_receivable', true, null, 100),
  ('CH', 'default', '1109', 'Delkredere (Wertberichtigung auf Forderungen)', '{"fr":"Ducroire (correction de valeur sur créances)"}'::jsonb, 'asset_receivable', true, null, 110),
  ('CH', 'default', '1110', 'Kreditkartenforderungen', '{"fr":"Créances sur cartes de crédit"}'::jsonb, 'asset_receivable', true, null, 120),
  ('CH', 'default', '1140', 'Vorschüsse an Mitarbeitende', '{"fr":"Avances au personnel"}'::jsonb, 'asset_current', false, null, 130),
  ('CH', 'default', '1150', 'Verrechnungssteuerguthaben', '{"fr":"Impôt anticipé à récupérer"}'::jsonb, 'asset_current', false, null, 140),
  ('CH', 'default', '1170', 'Vorsteuer Material- und Dienstleistungsaufwand', '{"fr":"TVA préalable sur charges de matériel et de services"}'::jsonb, 'asset_current', false, null, 150),
  ('CH', 'default', '1171', 'Vorsteuer Investitionen und übriger Betriebsaufwand', '{"fr":"TVA préalable sur investissements et autres charges d''exploitation"}'::jsonb, 'asset_current', false, null, 160),
  ('CH', 'default', '1176', 'Verrechnungskonto Eidgenössische Steuerverwaltung (Vorsteuerüberschuss)', '{"fr":"Compte de compensation avec l''Administration fédérale des contributions (excédent de TVA préalable)"}'::jsonb, 'asset_current', true, null, 170),
  ('CH', 'default', '1180', 'Kautionen und Depots (kurzfristig)', '{"fr":"Cautions et dépôts à court terme"}'::jsonb, 'asset_current', false, null, 180),
  ('CH', 'default', '1185', 'Übrige kurzfristige Forderungen', '{"fr":"Autres créances à court terme"}'::jsonb, 'asset_current', false, null, 190),
  ('CH', 'default', '1200', 'Handelswaren', '{"fr":"Marchandises"}'::jsonb, 'asset_current', false, null, 200),
  ('CH', 'default', '1210', 'Rohmaterial', '{"fr":"Matières premières"}'::jsonb, 'asset_current', false, null, 210),
  ('CH', 'default', '1220', 'Unfertige Erzeugnisse', '{"fr":"Produits en cours de fabrication"}'::jsonb, 'asset_current', false, null, 220),
  ('CH', 'default', '1230', 'Fertige Erzeugnisse', '{"fr":"Produits finis"}'::jsonb, 'asset_current', false, null, 230),
  ('CH', 'default', '1260', 'Wertberichtigung Warenlager', '{"fr":"Correction de valeur sur stocks"}'::jsonb, 'asset_current', false, null, 240),
  ('CH', 'default', '1300', 'Aktive Rechnungsabgrenzung', '{"fr":"Actifs de régularisation"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('CH', 'default', '1301', 'Vorausbezahlte Miete', '{"fr":"Loyers payés d''avance"}'::jsonb, 'asset_prepayments', false, null, 260),
  ('CH', 'default', '1302', 'Vorausbezahlte Versicherungen', '{"fr":"Primes d''assurance payées d''avance"}'::jsonb, 'asset_prepayments', false, null, 270),
  ('CH', 'default', '1500', 'Mobiliar und Einrichtungen', '{"fr":"Mobilier et installations"}'::jsonb, 'asset_fixed', false, null, 280),
  ('CH', 'default', '1501', 'Werkzeuge', '{"fr":"Outillage"}'::jsonb, 'asset_fixed', false, null, 290),
  ('CH', 'default', '1502', 'Ladeneinrichtung', '{"fr":"Agencement de magasin"}'::jsonb, 'asset_fixed', false, null, 300),
  ('CH', 'default', '1510', 'Maschinen und Apparate', '{"fr":"Machines et appareils"}'::jsonb, 'asset_fixed', false, null, 310),
  ('CH', 'default', '1520', 'Fahrzeuge (Personenwagen)', '{"fr":"Véhicules (voitures de tourisme)"}'::jsonb, 'asset_fixed', false, null, 320),
  ('CH', 'default', '1521', 'Fahrzeuge (Lieferwagen)', '{"fr":"Véhicules (véhicules utilitaires)"}'::jsonb, 'asset_fixed', false, null, 330),
  ('CH', 'default', '1530', 'Informatik Hardware', '{"fr":"Matériel informatique"}'::jsonb, 'asset_fixed', false, null, 340),
  ('CH', 'default', '1531', 'Softwarelizenzen', '{"fr":"Licences de logiciels"}'::jsonb, 'asset_fixed', false, null, 350),
  ('CH', 'default', '1540', 'Mietereinbauten', '{"fr":"Installations dans des locaux loués"}'::jsonb, 'asset_fixed', false, null, 360),
  ('CH', 'default', '1600', 'Liegenschaften — Gebäude', '{"fr":"Immeubles — bâtiments"}'::jsonb, 'asset_fixed', false, null, 370),
  ('CH', 'default', '1601', 'Liegenschaften — Land', '{"fr":"Immeubles — terrains"}'::jsonb, 'asset_fixed', false, null, 380),
  ('CH', 'default', '1700', 'Darlehen an Dritte', '{"fr":"Prêts à des tiers"}'::jsonb, 'asset_non_current', false, null, 390),
  ('CH', 'default', '1710', 'Wertschriften (langfristig)', '{"fr":"Titres (long terme)"}'::jsonb, 'asset_non_current', false, null, 400),
  ('CH', 'default', '1720', 'Beteiligungen', '{"fr":"Participations"}'::jsonb, 'asset_non_current', false, null, 410),
  ('CH', 'default', '2000', 'Verbindlichkeiten aus Lieferungen und Leistungen', '{"fr":"Dettes résultant de livraisons et de prestations"}'::jsonb, 'liability_payable', true, null, 420),
  ('CH', 'default', '2001', 'Verbindlichkeiten gegenüber nahestehenden Personen', '{"fr":"Dettes envers des personnes proches"}'::jsonb, 'liability_payable', true, null, 430),
  ('CH', 'default', '2020', 'Kreditkartenverbindlichkeiten', '{"fr":"Dettes sur cartes de crédit"}'::jsonb, 'liability_payable', true, null, 440),
  ('CH', 'default', '2030', 'Kurzfristige Bankverbindlichkeiten (Kontokorrent)', '{"fr":"Dettes bancaires à court terme (compte courant)"}'::jsonb, 'liability_current', false, null, 450),
  ('CH', 'default', '2050', 'Kurzfristige Darlehen Dritter', '{"fr":"Emprunts à court terme de tiers"}'::jsonb, 'liability_current', false, null, 460),
  ('CH', 'default', '2100', 'MWST geschuldet (Umsatzsteuer auf Leistungen)', '{"fr":"TVA due (impôt sur le chiffre d''affaires)"}'::jsonb, 'liability_current', false, null, 470),
  ('CH', 'default', '2110', 'Bezugsteuer geschuldet', '{"fr":"Impôt sur les acquisitions dû"}'::jsonb, 'liability_current', false, null, 480),
  ('CH', 'default', '2120', 'Quellensteuer geschuldet', '{"fr":"Impôt à la source dû"}'::jsonb, 'liability_current', false, null, 490),
  ('CH', 'default', '2130', 'AHV/IV/EO/ALV geschuldet', '{"fr":"AVS/AI/APG/AC dues"}'::jsonb, 'liability_current', false, null, 500),
  ('CH', 'default', '2140', 'Verrechnungskonto Eidgenössische Steuerverwaltung (MWST geschuldet)', '{"fr":"Compte de compensation avec l''Administration fédérale des contributions (TVA due)"}'::jsonb, 'liability_current', true, null, 510),
  ('CH', 'default', '2150', 'Geschuldete Löhne', '{"fr":"Salaires dus"}'::jsonb, 'liability_current', false, null, 520),
  ('CH', 'default', '2160', 'Ferien- und Überzeitguthaben Personal', '{"fr":"Vacances et heures supplémentaires dues au personnel"}'::jsonb, 'liability_current', false, null, 530),
  ('CH', 'default', '2200', 'Sonstige kurzfristige Verbindlichkeiten', '{"fr":"Autres dettes à court terme"}'::jsonb, 'liability_current', false, null, 540),
  ('CH', 'default', '2210', 'Geschuldete Dividenden', '{"fr":"Dividendes dus"}'::jsonb, 'liability_current', false, null, 550),
  ('CH', 'default', '2260', 'Passive Rechnungsabgrenzung', '{"fr":"Passifs de régularisation"}'::jsonb, 'liability_current', false, null, 560),
  ('CH', 'default', '2261', 'Abgegrenzte Zinsen', '{"fr":"Intérêts courus"}'::jsonb, 'liability_current', false, null, 570),
  ('CH', 'default', '2270', 'Kurzfristige Rückstellungen', '{"fr":"Provisions à court terme"}'::jsonb, 'liability_current', false, null, 580),
  ('CH', 'default', '2280', 'Garantierückstellungen', '{"fr":"Provisions pour garanties"}'::jsonb, 'liability_current', false, null, 590),
  ('CH', 'default', '2300', 'Durchlaufende Posten (Verrechnungskonto)', '{"fr":"Comptes de passage (compte de compensation)"}'::jsonb, 'liability_current', false, null, 600),
  ('CH', 'default', '2400', 'Langfristige Bankverbindlichkeiten und Darlehen', '{"fr":"Dettes bancaires et emprunts à long terme"}'::jsonb, 'liability_non_current', false, null, 610),
  ('CH', 'default', '2410', 'Hypothek Geschäftsliegenschaft', '{"fr":"Hypothèque sur l''immeuble d''exploitation"}'::jsonb, 'liability_non_current', false, null, 620),
  ('CH', 'default', '2420', 'Darlehen von Anteilseignern', '{"fr":"Prêts d''actionnaires"}'::jsonb, 'liability_non_current', false, null, 630),
  ('CH', 'default', '2450', 'Langfristige Rückstellungen', '{"fr":"Provisions à long terme"}'::jsonb, 'liability_non_current', false, null, 640),
  ('CH', 'default', '2460', 'Rückstellung latente Steuern', '{"fr":"Provision pour impôts latents"}'::jsonb, 'liability_non_current', false, null, 650),
  ('CH', 'default', '2800', 'Aktien- oder Stammkapital', '{"fr":"Capital-actions ou capital social"}'::jsonb, 'equity', false, null, 660),
  ('CH', 'default', '2801', 'Partizipationskapital', '{"fr":"Capital de participation"}'::jsonb, 'equity', false, null, 670),
  ('CH', 'default', '2850', 'Gesetzliche Kapitalreserve', '{"fr":"Réserve légale issue du capital"}'::jsonb, 'equity', false, null, 680),
  ('CH', 'default', '2860', 'Gesetzliche Gewinnreserve', '{"fr":"Réserve légale issue du bénéfice"}'::jsonb, 'equity', false, null, 690),
  ('CH', 'default', '2870', 'Freiwillige Gewinnreserven', '{"fr":"Réserves facultatives issues du bénéfice"}'::jsonb, 'equity', false, null, 700),
  ('CH', 'default', '2890', 'Eigene Kapitalanteile (Minusposten)', '{"fr":"Actions propres (poste négatif)"}'::jsonb, 'equity', false, null, 710),
  ('CH', 'default', '2900', 'Bilanzgewinn / Bilanzverlust', '{"fr":"Bénéfice ou perte au bilan"}'::jsonb, 'equity_retained', false, null, 720),
  ('CH', 'default', '2979', 'Gewinnvortrag', '{"fr":"Bénéfice reporté"}'::jsonb, 'equity_retained', false, null, 730),
  ('CH', 'default', '2989', 'Verlustvortrag', '{"fr":"Perte reportée"}'::jsonb, 'equity_retained', false, null, 740),
  ('CH', 'default', '3000', 'Erlöse aus Lieferungen — Normalsatz', '{"fr":"Produits des ventes — taux normal"}'::jsonb, 'income', false, null, 750),
  ('CH', 'default', '3001', 'Erlöse aus Lieferungen — reduzierter Satz', '{"fr":"Produits des ventes — taux réduit"}'::jsonb, 'income', false, null, 760),
  ('CH', 'default', '3002', 'Erlöse aus Beherbergungsleistungen — Sondersatz', '{"fr":"Produits des prestations d''hébergement — taux spécial"}'::jsonb, 'income', false, null, 770),
  ('CH', 'default', '3010', 'Erlöse aus Dienstleistungen — Normalsatz', '{"fr":"Produits des prestations de services — taux normal"}'::jsonb, 'income', false, null, 780),
  ('CH', 'default', '3020', 'Erlöse Detailhandel — Normalsatz', '{"fr":"Produits du commerce de détail — taux normal"}'::jsonb, 'income', false, null, 790),
  ('CH', 'default', '3040', 'Erlöse aus Ausfuhrlieferungen (steuerbefreit mit Vorsteuerabzug)', '{"fr":"Produits des livraisons à l''exportation (exonérées avec droit à déduction)"}'::jsonb, 'income', false, null, 800),
  ('CH', 'default', '3041', 'Erlöse aus Dienstleistungsexport', '{"fr":"Produits de l''exportation de prestations de services"}'::jsonb, 'income', false, null, 810),
  ('CH', 'default', '3050', 'Erlöse aus von der Steuer ausgenommenen Leistungen — Vermietung', '{"fr":"Produits de prestations exclues du champ de l''impôt — location"}'::jsonb, 'income', false, null, 820),
  ('CH', 'default', '3051', 'Erlöse aus von der Steuer ausgenommenen Leistungen — Bildung', '{"fr":"Produits de prestations exclues du champ de l''impôt — formation"}'::jsonb, 'income', false, null, 830),
  ('CH', 'default', '3052', 'Erlöse aus von der Steuer ausgenommenen Leistungen — Versicherung', '{"fr":"Produits de prestations exclues du champ de l''impôt — assurance"}'::jsonb, 'income', false, null, 840),
  ('CH', 'default', '3080', 'Erlöse aus Anzahlungen', '{"fr":"Produits d''acomptes"}'::jsonb, 'income', false, null, 850),
  ('CH', 'default', '3090', 'Erlösminderungen (Rabatte, Skonti, Verluste)', '{"fr":"Diminutions de produits (rabais, escomptes, pertes)"}'::jsonb, 'income', false, null, 860),
  ('CH', 'default', '4000', 'Materialaufwand und Wareneinkauf — Normalsatz', '{"fr":"Charges de matériel et de marchandises — taux normal"}'::jsonb, 'expense_direct_cost', false, null, 870),
  ('CH', 'default', '4001', 'Materialaufwand und Wareneinkauf — reduzierter Satz', '{"fr":"Charges de matériel et de marchandises — taux réduit"}'::jsonb, 'expense_direct_cost', false, null, 880),
  ('CH', 'default', '4010', 'Fremdleistungen Dritter (Inland)', '{"fr":"Prestations de tiers (Suisse)"}'::jsonb, 'expense_direct_cost', false, null, 890),
  ('CH', 'default', '4020', 'Materialaufwand aus Einfuhr', '{"fr":"Charges de matériel à l''importation"}'::jsonb, 'expense_direct_cost', false, null, 900),
  ('CH', 'default', '4040', 'Fremdleistungen aus dem Ausland (Bezugsteuer)', '{"fr":"Prestations de tiers depuis l''étranger (impôt sur les acquisitions)"}'::jsonb, 'expense_direct_cost', false, null, 910),
  ('CH', 'default', '4050', 'Bestandesänderungen Handelswaren', '{"fr":"Variation des stocks de marchandises"}'::jsonb, 'expense_direct_cost', false, null, 920),
  ('CH', 'default', '4060', 'Verpackungsmaterial', '{"fr":"Matériel d''emballage"}'::jsonb, 'expense_direct_cost', false, null, 930),
  ('CH', 'default', '4090', 'Aufwandminderungen (erhaltene Rabatte)', '{"fr":"Diminutions de charges (rabais obtenus)"}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('CH', 'default', '5000', 'Löhne Verwaltung', '{"fr":"Salaires — administration"}'::jsonb, 'expense', false, null, 950),
  ('CH', 'default', '5010', 'Löhne Verkauf', '{"fr":"Salaires — vente"}'::jsonb, 'expense', false, null, 960),
  ('CH', 'default', '5020', 'Löhne Produktion', '{"fr":"Salaires — production"}'::jsonb, 'expense', false, null, 970),
  ('CH', 'default', '5700', 'AHV/IV/EO/ALV-Beiträge', '{"fr":"Charges AVS/AI/APG/AC"}'::jsonb, 'expense', false, null, 980),
  ('CH', 'default', '5710', 'Familienzulagen', '{"fr":"Allocations familiales"}'::jsonb, 'expense', false, null, 990),
  ('CH', 'default', '5720', 'Krankentaggeldversicherung', '{"fr":"Assurance indemnités journalières maladie"}'::jsonb, 'expense', false, null, 1000),
  ('CH', 'default', '5730', 'Unfallversicherung (UVG)', '{"fr":"Assurance-accidents (LAA)"}'::jsonb, 'expense', false, null, 1010),
  ('CH', 'default', '5740', 'Berufliche Vorsorge (BVG)', '{"fr":"Prévoyance professionnelle (LPP)"}'::jsonb, 'expense', false, null, 1020),
  ('CH', 'default', '5800', 'Übriger Personalaufwand', '{"fr":"Autres charges de personnel"}'::jsonb, 'expense', false, null, 1030),
  ('CH', 'default', '5810', 'Aus- und Weiterbildung', '{"fr":"Formation et formation continue"}'::jsonb, 'expense', false, null, 1040),
  ('CH', 'default', '5820', 'Spesenentschädigungen Personal', '{"fr":"Indemnités de frais du personnel"}'::jsonb, 'expense', false, null, 1050),
  ('CH', 'default', '6000', 'Raumaufwand (Miete)', '{"fr":"Charges de locaux (loyer)"}'::jsonb, 'expense', false, null, 1060),
  ('CH', 'default', '6030', 'Nebenkosten Miete', '{"fr":"Frais accessoires du loyer"}'::jsonb, 'expense', false, null, 1070),
  ('CH', 'default', '6040', 'Reinigung', '{"fr":"Nettoyage"}'::jsonb, 'expense', false, null, 1080),
  ('CH', 'default', '6100', 'Unterhalt, Reparaturen, Ersatz (Mobilien)', '{"fr":"Entretien, réparations, remplacement (mobilier)"}'::jsonb, 'expense', false, null, 1090),
  ('CH', 'default', '6105', 'Unterhalt Informatik', '{"fr":"Entretien informatique"}'::jsonb, 'expense', false, null, 1100),
  ('CH', 'default', '6200', 'Fahrzeug- und Transportaufwand', '{"fr":"Frais de véhicules et de transport"}'::jsonb, 'expense', false, null, 1110),
  ('CH', 'default', '6210', 'Fahrzeugversicherungen und -steuern', '{"fr":"Assurances et taxes des véhicules"}'::jsonb, 'expense', false, null, 1120),
  ('CH', 'default', '6260', 'Versicherungsaufwand (Sachversicherungen)', '{"fr":"Assurances choses"}'::jsonb, 'expense', false, null, 1130),
  ('CH', 'default', '6300', 'Energie- und Entsorgungsaufwand', '{"fr":"Énergie et élimination des déchets"}'::jsonb, 'expense', false, null, 1140),
  ('CH', 'default', '6400', 'Büromaterial und Drucksachen', '{"fr":"Fournitures de bureau et imprimés"}'::jsonb, 'expense', false, null, 1150),
  ('CH', 'default', '6410', 'Telefon, Internet und Kommunikation', '{"fr":"Téléphone, Internet et communication"}'::jsonb, 'expense', false, null, 1160),
  ('CH', 'default', '6420', 'Bewilligungen und Gebühren', '{"fr":"Autorisations et taxes"}'::jsonb, 'expense', false, null, 1170),
  ('CH', 'default', '6440', 'Buchführungs- und Beratungsaufwand', '{"fr":"Frais de comptabilité et de conseil"}'::jsonb, 'expense', false, null, 1180),
  ('CH', 'default', '6460', 'Werbeaufwand', '{"fr":"Frais de publicité"}'::jsonb, 'expense', false, null, 1190),
  ('CH', 'default', '6470', 'Marketing und Repräsentation', '{"fr":"Marketing et représentation"}'::jsonb, 'expense', false, null, 1200),
  ('CH', 'default', '6480', 'Reisespesen', '{"fr":"Frais de déplacement"}'::jsonb, 'expense', false, null, 1210),
  ('CH', 'default', '6500', 'Verwaltungsaufwand und übriger Betriebsaufwand', '{"fr":"Frais d''administration et autres charges d''exploitation"}'::jsonb, 'expense', false, null, 1220),
  ('CH', 'default', '6570', 'Aufwand für Warenimport (Einfuhrsteuer)', '{"fr":"Charges d''importation de marchandises (impôt sur les importations)"}'::jsonb, 'expense', false, null, 1230),
  ('CH', 'default', '6600', 'Abschreibungen Mobiliar und Einrichtungen', '{"fr":"Amortissements sur mobilier et installations"}'::jsonb, 'expense_depreciation', false, null, 1240),
  ('CH', 'default', '6601', 'Abschreibungen Maschinen und Apparate', '{"fr":"Amortissements sur machines et appareils"}'::jsonb, 'expense_depreciation', false, null, 1250),
  ('CH', 'default', '6602', 'Abschreibungen Fahrzeuge', '{"fr":"Amortissements sur véhicules"}'::jsonb, 'expense_depreciation', false, null, 1260),
  ('CH', 'default', '6603', 'Abschreibungen Informatik', '{"fr":"Amortissements sur informatique"}'::jsonb, 'expense_depreciation', false, null, 1270),
  ('CH', 'default', '6604', 'Abschreibungen Liegenschaften', '{"fr":"Amortissements sur immeubles"}'::jsonb, 'expense_depreciation', false, null, 1280),
  ('CH', 'default', '6610', 'Wertberichtigungen Finanzanlagen', '{"fr":"Corrections de valeur sur immobilisations financières"}'::jsonb, 'expense_depreciation', false, null, 1290),
  ('CH', 'default', '6900', 'Zinsaufwand Kontokorrent', '{"fr":"Charges d''intérêts (compte courant)"}'::jsonb, 'expense', false, null, 1300),
  ('CH', 'default', '6901', 'Zinsaufwand Darlehen', '{"fr":"Charges d''intérêts (emprunts)"}'::jsonb, 'expense', false, null, 1310),
  ('CH', 'default', '6910', 'Bankspesen', '{"fr":"Frais bancaires"}'::jsonb, 'expense', false, null, 1320),
  ('CH', 'default', '6920', 'Kursverluste Fremdwährung', '{"fr":"Pertes de change"}'::jsonb, 'expense', false, null, 1330),
  ('CH', 'default', '6930', 'Wertberichtigung Wertschriften', '{"fr":"Correction de valeur sur titres"}'::jsonb, 'expense', false, null, 1340),
  ('CH', 'default', '6950', 'Zinsertrag', '{"fr":"Produits d''intérêts"}'::jsonb, 'income_other', false, null, 1350),
  ('CH', 'default', '6951', 'Wertschriftenertrag', '{"fr":"Produits sur titres"}'::jsonb, 'income_other', false, null, 1360),
  ('CH', 'default', '6960', 'Kursgewinne Fremdwährung', '{"fr":"Gains de change"}'::jsonb, 'income_other', false, null, 1370),
  ('CH', 'default', '7500', 'Mietertrag aus nicht betriebsnotwendigen Liegenschaften', '{"fr":"Produits de la location d''immeubles non nécessaires à l''exploitation"}'::jsonb, 'income_other', false, null, 1380),
  ('CH', 'default', '7510', 'Ertrag aus Beteiligungen', '{"fr":"Produits de participations"}'::jsonb, 'income_other', false, null, 1390),
  ('CH', 'default', '7900', 'Aufwand nicht betriebsnotwendige Liegenschaften', '{"fr":"Charges d''immeubles non nécessaires à l''exploitation"}'::jsonb, 'expense', false, null, 1400),
  ('CH', 'default', '8500', 'Gewinn aus Anlagenverkauf', '{"fr":"Gain sur cession d''immobilisations"}'::jsonb, 'income_other', false, null, 1410),
  ('CH', 'default', '8510', 'Auflösung stiller Reserven', '{"fr":"Dissolution de réserves latentes"}'::jsonb, 'income_other', false, null, 1420),
  ('CH', 'default', '8900', 'Verlust aus Anlagenverkauf', '{"fr":"Perte sur cession d''immobilisations"}'::jsonb, 'expense', false, null, 1430),
  ('CH', 'default', '8910', 'Bildung stiller Reserven', '{"fr":"Constitution de réserves latentes"}'::jsonb, 'expense', false, null, 1440),
  ('CH', 'default', '8950', 'Rundungsdifferenzen', '{"fr":"Différences d''arrondi"}'::jsonb, 'expense', false, null, 1450),
  ('CH', 'default', '8990', 'Kantons- und Gemeindesteuern', '{"fr":"Impôts cantonaux et communaux"}'::jsonb, 'expense', false, null, 1460),
  ('CH', 'default', '8991', 'Direkte Bundessteuer', '{"fr":"Impôt fédéral direct"}'::jsonb, 'expense', false, null, 1470),
  ('CH', 'default', '8992', 'Kapitalsteuer', '{"fr":"Impôt sur le capital"}'::jsonb, 'expense', false, null, 1480)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('CH', 'BNK', 'Bank', '{"fr":"Banque"}'::jsonb, 'bank', 30),
  ('CH', 'CSH', 'Kasse', '{"fr":"Caisse"}'::jsonb, 'cash', 40),
  ('CH', 'GEN', 'Diverse Buchungen', '{"fr":"Opérations diverses"}'::jsonb, 'general', 50),
  ('CH', 'OPN', 'Eröffnungsbilanz', '{"fr":"Bilan d''ouverture"}'::jsonb, 'opening', 60),
  ('CH', 'PUR', 'Einkaufsjournal', '{"fr":"Journal des achats"}'::jsonb, 'purchase', 20),
  ('CH', 'SAL', 'Verkaufsjournal', '{"fr":"Journal des ventes"}'::jsonb, 'sales', 10)
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
  ('CH', 'CH-P-26', 'Einkauf Material-/Dienstleistungsaufwand, reduzierter Satz 2,6 %', '{"fr":"Achat de matériel et prestations de services, taux réduit 2,6 %"}'::jsonb, null, 'percent', 2.6, 'purchase', 'domestic', date '2024-01-01', null, 'MWSTG Art. 28 Abs. 1 Bst. a, Ziffer 400 des Formulars Nr. 4470, zum reduzierten Satz von Art. 25 Abs. 2 MWSTG.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwst-4470', null, null, null, null),
  ('CH', 'CH-P-81', 'Einkauf Material-/Dienstleistungsaufwand, Normalsatz 8,1 %', '{"fr":"Achat de matériel et prestations de services, taux normal 8,1 %"}'::jsonb, null, 'percent', 8.1, 'purchase', 'domestic', date '2024-01-01', null, 'MWSTG Art. 28 Abs. 1 Bst. a — Anspruch auf Vorsteuerabzug für die im Rahmen der unternehmerischen Tätigkeit von anderen Steuerpflichtigen in Rechnung gestellte Inlandsteuer. Das Formular Nr. 4470 weist diese Vorsteuer unter Ziffer 400 aus (Vorsteuer auf Material- und Dienstleistungsaufwand), getrennt von den Investitionen (Ziffer 405, siehe CH-P-81-INV). Das Formular verlangt für den Bezug keinen eigenen Bemessungsgrundlage-Betrag, weshalb dieser Code keine base-Buchung trägt.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwst-4470', null, null, null, null),
  ('CH', 'CH-P-81-INV', 'Einkauf Investitionen und übriger Betriebsaufwand, Normalsatz 8,1 %', '{"fr":"Achat d''investissements et autres charges d''exploitation, taux normal 8,1 %"}'::jsonb, null, 'percent', 8.1, 'purchase', 'domestic', date '2024-01-01', null, 'MWSTG Art. 28 Abs. 1 Bst. a, ausgewiesen unter Ziffer 405 des Formulars Nr. 4470 (Vorsteuer auf Investitionen und übrigem Betriebsaufwand) — dieselbe gesetzliche Grundlage wie CH-P-81, aber die andere Zeile des Formulars, weil dieses zwischen laufendem Aufwand und Investitionen/übrigem Betriebsaufwand unterscheidet.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwst-4470', null, null, null, null),
  ('CH', 'CH-P-81-NA', 'Einkauf für eine von der Steuer ausgenommene Tätigkeit, Normalsatz 8,1 % (nicht abziehbar)', '{"fr":"Achat pour une activité exclue, taux normal 8,1 % (non déductible)"}'::jsonb, null, 'percent', 8.1, 'purchase', 'exempt', date '2024-01-01', null, 'MWSTG Art. 29 Abs. 1 — Leistungen, die für eine nach Art. 21 von der Steuer ausgenommene Tätigkeit verwendet werden, berechtigen nicht zum Vorsteuerabzug, sofern nicht nach Art. 22 optiert wurde. Die vom Lieferanten in Rechnung gestellte Steuer ist damit Teil der Anschaffungskosten und wird auf dem Konto der belasteten Zeile gebucht, ohne dass das Formular dafür eine eigene Ziffer vorsieht.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-P-BEZUGSTEUER-81', 'Bezug einer Dienstleistung aus dem Ausland, Bezugsteuer 8,1 %', '{"fr":"Acquisition d''une prestation de services de l''étranger, impôt sur les acquisitions 8,1 %"}'::jsonb, null, 'percent', 8.1, 'purchase', 'foreign_services_received', date '2024-01-01', null, 'MWSTG Art. 45 Abs. 1 Bst. a und Art. 45 Abs. 2 — der Bezugsteuer unterliegen Dienstleistungen mit Ort im Inland (Art. 8 Abs. 1), die von einem Unternehmen mit Sitz im Ausland erbracht werden, das nicht im Register der steuerpflichtigen Personen eingetragen ist, sofern die bezugsteuerpflichtige Person nach Art. 10 steuerpflichtig ist oder solche Bezüge CHF 10''000 pro Kalenderjahr übersteigen. Art. 46 MWSTG verweist für Satz und Berechnung auf Art. 24/25. Das Formular Nr. 4470 weist die Bezugsteuer unter Ziffer 383 (Impôt sur les acquisitions) im Total der geschuldeten Steuer (Ziffer 399) aus; der volle Vorsteuerabzug erfolgt gleichzeitig unter Ziffer 400/405, sofern die Leistung für eine zum Vorsteuerabzug berechtigende Tätigkeit verwendet wird.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-P-IMPORT-81', 'Einfuhr von Gegenständen, Einfuhrsteuer 8,1 %', '{"fr":"Importation de biens, impôt sur les importations 8,1 %"}'::jsonb, null, 'percent', 8.1, 'purchase', 'import', date '2024-01-01', null, 'MWSTG Art. 50 und Art. 52 Abs. 1 Bst. a — der Einfuhrsteuer unterliegt die Einfuhr von Gegenständen; die Zollgesetzgebung ist anwendbar, soweit das MWSTG nichts anderes vorsieht. Die Einfuhrsteuer wird von der Eidgenössischen Zollverwaltung (Bundesamt für Zoll und Grenzsicherheit, BAZG) bei der Einfuhr erhoben, nicht über die periodische MWST-Abrechnung geschuldet; das Formular Nr. 4470 weist nur den anschliessenden Vorsteuerabzug unter Ziffer 400/405 aus (Art. 28 Abs. 1 Bst. c MWSTG). Dieser Code bildet daher nur den Vorsteuerabzug ab, keine Schuld gegenüber der ESTV.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwst-4470', null, null, null, null),
  ('CH', 'CH-S-26', 'Verkauf, reduzierter Satz 2,6 %', '{"fr":"Vente, taux réduit 2,6 %"}'::jsonb, null, 'percent', 2.6, 'sale', 'domestic', date '2024-01-01', null, 'MWSTG Art. 25 Abs. 2 — der reduzierte Satz von 2,6 % gilt für eine abschliessende Liste von Leistungen: Wasser in Leitungen, Lebensmittel (ohne alkoholische Getränke) im Sinne des Lebensmittelgesetzes, Vieh/Geflügel/Fisch, Getreide, Saatgut, Futtermittel, Dünger, Arzneimittel, Zeitungen/Zeitschriften/Bücher ohne Reklamecharakter, Erzeugnisse zur Monatshygiene, u.a. Seit 1. Januar 2024 gemäss der gleichen Verordnung wie CH-S-81.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-S-38-HEB', 'Beherbergungsleistung, Sondersatz 3,8 %', '{"fr":"Prestation d''hébergement, taux spécial 3,8 %"}'::jsonb, null, 'percent', 3.8, 'sale', 'domestic', date '2024-01-01', null, 'MWSTG Art. 25 Abs. 4 — der Steuersatz für Beherbergungsleistungen (Unterkunft mit Frühstück, auch wenn dieses separat in Rechnung gestellt wird) beträgt 3,8 % (Sondersatz), gültig bis längstens 31. Dezember 2027, sofern die Frist nach Art. 196 Ziff. 14 Abs. 1 der Bundesverfassung nicht verlängert wird. Dieser Pack setzt kein valid_to, weil das Gesetz selbst diese Frist als bedingte Obergrenze und nicht als feststehendes Enddatum formuliert; siehe README.md.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-S-81', 'Verkauf, Normalsatz 8,1 %', '{"fr":"Vente, taux normal 8,1 %"}'::jsonb, null, 'percent', 8.1, 'sale', 'domestic', date '2024-01-01', null, 'MWSTG Art. 25 Abs. 1 — der Steuersatz beträgt 8,1 % (Normalsatz); die Abs. 2 und 4 bleiben vorbehalten. Der Satz gilt gemäss Ziff. I der Verordnung vom 9. Dezember 2022 über die Erhöhung der Mehrwertsteuersätze zur Zusatzfinanzierung der AHV (AS 2022 863) seit dem 1. Januar 2024, nach der Volksabstimmung vom 25. September 2022 über den Bundesbeschluss vom 17. Dezember 2021.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-S-EXCLU', 'Von der Steuer ausgenommene Leistung (ohne Option)', '{"fr":"Prestation exclue du champ de l''impôt (sans option)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2010-01-01', null, 'MWSTG Art. 21 — eine von der Steuer ausgenommene Leistung ist nicht steuerbar, sofern nicht nach Art. 22 für ihre Versteuerung optiert wurde; anders als bei Art. 23 besteht dafür kein Anspruch auf Vorsteuerabzug. Beispiele in Art. 21 Abs. 2: humanmedizinische Heilbehandlungen (Ziff. 2/3), Bildung (Ziff. 11), Versicherungsgeschäfte (Ziff. 18), Vermietung von Grundstücken (Ziff. 21). Dieser Pack verzichtet auf einen Befreiungscode (exemption_code): die Schweiz liegt ausserhalb des gemeinsamen Mehrwertsteuersystems der EU, dessen Codeliste VATEX Art. 21 nicht kennt.', 'E', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-S-EXPORT', 'Ausfuhrlieferung (von der Steuer befreit)', '{"fr":"Livraison exonérée à l''exportation"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2010-01-01', null, 'MWSTG Art. 23 Abs. 1 und Abs. 2 Ziff. 1 — die Lieferung von Gegenständen, die direkt ins Ausland befördert oder versendet werden, ist von der Steuer befreit, mit Anspruch auf Vorsteuerabzug (echte Befreiung, im Gegensatz zu Art. 21).', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null),
  ('CH', 'CH-S-FOREIGN', 'Dienstleistung mit Erbringungsort im Ausland', '{"fr":"Prestation de services fournie à l''étranger"}'::jsonb, null, 'percent', 0, 'sale', 'not_subject', date '2010-01-01', null, 'MWSTG Art. 1 Abs. 2 Bst. a und Art. 8 Abs. 1 — der Inlandsteuer unterliegen nur im Inland gegen Entgelt erbrachte Leistungen. Eine Dienstleistung, deren Ort nach Art. 8 im Ausland liegt (Empfängerortsprinzip), fällt nicht in den Geltungsbereich der schweizerischen Mehrwertsteuer und wird auf dem Formular gleichwohl unter Ziffer 221 ausgewiesen.', 'O', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'mwstg', null, null, null, null)
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
    ('CH-P-26', 'invoice', 'tax', 100, '1170', '400', array['400']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-P-26', 'credit_note', 'tax', 100, '1170', '400', array['400']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-P-81', 'invoice', 'tax', 100, '1170', '400', array['400']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-P-81', 'credit_note', 'tax', 100, '1170', '400', array['400']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-P-81-INV', 'invoice', 'tax', 100, '1171', '405', array['405']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-P-81-INV', 'credit_note', 'tax', 100, '1171', '405', array['405']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-P-81-NA', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('CH-P-81-NA', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('CH-P-BEZUGSTEUER-81', 'invoice', 'tax', 100, '1170', '400', array['400']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-P-BEZUGSTEUER-81', 'invoice', 'tax', -100, '2110', '383', array['383']::text[], 100, 'CH-MWST-ABR', 20),
    ('CH-P-BEZUGSTEUER-81', 'credit_note', 'tax', 100, '1170', '400', array['400']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-P-BEZUGSTEUER-81', 'credit_note', 'tax', -100, '2110', '383', array['383']::text[], -100, 'CH-MWST-ABR', 20),
    ('CH-P-IMPORT-81', 'invoice', 'tax', 100, '1171', '405', array['405']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-P-IMPORT-81', 'credit_note', 'tax', 100, '1171', '405', array['405']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-S-26', 'invoice', 'base', 100, null, '200', array['200', '313']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-S-26', 'invoice', 'tax', 100, '2100', '313', array['313']::text[], 100, 'CH-MWST-ABR', 20),
    ('CH-S-26', 'credit_note', 'base', 100, null, '200', array['200', '313']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-S-26', 'credit_note', 'tax', 100, '2100', '313', array['313']::text[], -100, 'CH-MWST-ABR', 20),
    ('CH-S-38-HEB', 'invoice', 'base', 100, null, '200', array['200', '343']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-S-38-HEB', 'invoice', 'tax', 100, '2100', '343', array['343']::text[], 100, 'CH-MWST-ABR', 20),
    ('CH-S-38-HEB', 'credit_note', 'base', 100, null, '200', array['200', '343']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-S-38-HEB', 'credit_note', 'tax', 100, '2100', '343', array['343']::text[], -100, 'CH-MWST-ABR', 20),
    ('CH-S-81', 'invoice', 'base', 100, null, '200', array['200', '303']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-S-81', 'invoice', 'tax', 100, '2100', '303', array['303']::text[], 100, 'CH-MWST-ABR', 20),
    ('CH-S-81', 'credit_note', 'base', 100, null, '200', array['200', '303']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-S-81', 'credit_note', 'tax', 100, '2100', '303', array['303']::text[], -100, 'CH-MWST-ABR', 20),
    ('CH-S-EXCLU', 'invoice', 'base', 100, null, '200', array['200', '230']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-S-EXCLU', 'credit_note', 'base', 100, null, '200', array['200', '230']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-S-EXPORT', 'invoice', 'base', 100, null, '200', array['200', '220']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-S-EXPORT', 'credit_note', 'base', 100, null, '200', array['200', '220']::text[], -100, 'CH-MWST-ABR', 10),
    ('CH-S-FOREIGN', 'invoice', 'base', 100, null, '200', array['200', '221']::text[], 100, 'CH-MWST-ABR', 10),
    ('CH-S-FOREIGN', 'credit_note', 'base', 100, null, '200', array['200', '221']::text[], -100, 'CH-MWST-ABR', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'CH' and t.code = v.tax_code
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
  ('CH', 'CH-MWST-ABR', 'MWST-Abrechnung, effektive Methode (Formular Nr. 4470)', array['month', 'quarter', 'half_year', 'year']::declaration_period[], null, date '2024-01-01', null, 'Art. 35 Abs. 1 MWSTG — die Abrechnung erfolgt vierteljährlich, bei Anwendung der Methode der Saldosteuersätze (Art. 37 Abs. 1 und 2) halbjährlich. Art. 35 Abs. 1bis lässt auf Gesuch hin eine monatliche Abrechnung zu, wer regelmässig Vorsteuerüberschüsse ausweist (Bst. a), oder eine jährliche, wer einen massgebenden Jahresumsatz von höchstens CHF 5''005''000 aus steuerbaren Leistungen erzielt (Bst. b, siehe Art. 35a). Keine dieser vier Kaderungen ist die gesetzliche Regel für jede steuerpflichtige Person: welche davon gilt, hängt von der gewählten Abrechnungsmethode und vom Umsatz ab, weshalb dieser Pack keinen period_default setzt.', true,null, null, null, null, null, null)
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
  ('CH', 'CH-MWST-ABR', '200', 'base', 'Total der vereinbarten oder vereinnahmten Entgelte (Weltumsatz)', '{"fr":"Total des contre-prestations convenues ou reçues (chiffre d''affaires mondial)"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 200 — Total des contre-prestations convenues ou reçues, y c. prestations imposées par option, transferts par procédure de déclaration, prestations à l''étranger (chiffre d''affaires mondial).', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '205', 'base', 'Entgelte aus optierten, von der Steuer ausgenommenen Leistungen', '{"fr":"Contre-prestations provenant de prestations exclues pour lesquelles il a été opté"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 205 — Art. 22 MWSTG (Option für die Versteuerung einer nach Art. 21 ausgenommenen Leistung). Dieser Pack bildet die Option nicht ab; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '220', 'base', 'Von der Steuer befreite Leistungen (Ausfuhr, Art. 23)', '{"fr":"Prestations exonérées (exportations, art. 23)"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 220 — MWSTG Art. 23.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '221', 'base', 'Leistungen mit Ort im Ausland', '{"fr":"Prestations fournies à l''étranger"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 221 — MWSTG Art. 8.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '225', 'base', 'Übertragungen im Meldeverfahren', '{"fr":"Transferts avec la procédure de déclaration"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 225 — MWSTG Art. 38. Dieser Pack bildet das Meldeverfahren nicht ab; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '230', 'base', 'Von der Steuer ausgenommene Leistungen im Inland, nicht optiert', '{"fr":"Prestations exclues du champ de l''impôt, non optées"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 230 — MWSTG Art. 21.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '235', 'base', 'Entgeltsminderungen (Rabatte, Skonti usw.)', '{"fr":"Diminutions de la contre-prestation (rabais, escomptes)"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 235. Dieser Pack bildet Rabatte/Skonti als eigene Ziffer nicht ab; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '280', 'base', 'Diverses (Landwert, Einkaufspreis bei Margenbesteuerung)', '{"fr":"Divers (valeur du terrain, imposition de la marge)"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 280 — MWSTG Art. 24 Abs. 6 Bst. c und Art. 24a (Margenbesteuerung). Dieser Pack bildet die Margenbesteuerung nicht ab; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '289', 'total', 'Total der Abzüge (Ziffern 220 bis 280)', '{"fr":"Total des déductions"}'::jsonb, 90, null, array['220', '221', '225', '230', '235', '280']::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 289.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '299', 'total', 'Total steuerbarer Umsatz (Ziffer 200 abzüglich Ziffer 289)', '{"fr":"Total du chiffre d''affaires imposable"}'::jsonb, 100, null, array['200']::text[], array['289']::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 299.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '302', 'tax', 'Steuer zum Normalsatz, bis 31.12.2023 (7,7 %)', '{"fr":"Impôt au taux normal, jusqu''au 31.12.2023 (7,7 %)"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Spalte «jusqu''au 31.12.2023». Von diesem Pack nicht bebucht: er bildet nur die seit 1. Januar 2024 geltende Rechtslage ab; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '303', 'base', 'Umsatz zum Normalsatz, ab 01.01.2024 (Bemessungsgrundlage)', '{"fr":"Chiffre d''affaires au taux normal, dès le 01.01.2024"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 303, Spalte «Prestations CHF» — MWSTG Art. 25 Abs. 1.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '303', 'tax', 'Steuer zum Normalsatz, ab 01.01.2024 (8,1 %)', '{"fr":"Impôt au taux normal, dès le 01.01.2024 (8,1 %)"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 303, Spalte «Impôt CHF/ct.» — MWSTG Art. 25 Abs. 1.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '312', 'tax', 'Steuer zum reduzierten Satz, bis 31.12.2023 (2,5 %)', '{"fr":"Impôt au taux réduit, jusqu''au 31.12.2023 (2,5 %)"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Spalte «jusqu''au 31.12.2023». Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '313', 'base', 'Umsatz zum reduzierten Satz, ab 01.01.2024 (Bemessungsgrundlage)', '{"fr":"Chiffre d''affaires au taux réduit, dès le 01.01.2024"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 313, Spalte «Prestations CHF» — MWSTG Art. 25 Abs. 2.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '313', 'tax', 'Steuer zum reduzierten Satz, ab 01.01.2024 (2,6 %)', '{"fr":"Impôt au taux réduit, dès le 01.01.2024 (2,6 %)"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 313, Spalte «Impôt CHF/ct.» — MWSTG Art. 25 Abs. 2.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '342', 'tax', 'Steuer zum Sondersatz Beherbergung, bis 31.12.2023 (3,7 %)', '{"fr":"Impôt au taux spécial hébergement, jusqu''au 31.12.2023 (3,7 %)"}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Spalte «jusqu''au 31.12.2023». Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '343', 'base', 'Umsatz zum Sondersatz Beherbergung, ab 01.01.2024 (Bemessungsgrundlage)', '{"fr":"Chiffre d''affaires au taux spécial hébergement, dès le 01.01.2024"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 343, Spalte «Prestations CHF» — MWSTG Art. 25 Abs. 4.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '343', 'tax', 'Steuer zum Sondersatz Beherbergung, ab 01.01.2024 (3,8 %)', '{"fr":"Impôt au taux spécial hébergement, dès le 01.01.2024 (3,8 %)"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 343, Spalte «Impôt CHF/ct.» — MWSTG Art. 25 Abs. 4.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '382', 'tax', 'Bezugsteuer, bis 31.12.2023', '{"fr":"Impôt sur les acquisitions, jusqu''au 31.12.2023"}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Spalte «jusqu''au 31.12.2023». Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '383', 'tax', 'Bezugsteuer, ab 01.01.2024', '{"fr":"Impôt sur les acquisitions, dès le 01.01.2024"}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 383 — MWSTG Art. 45–49.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '399', 'total', 'Total geschuldete Steuer (Ziffern 302 bis 383)', '{"fr":"Total de l''impôt dû"}'::jsonb, 220, null, array['302', '303:tax', '312', '313:tax', '342', '343:tax', '382', '383']::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 399.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '400', 'tax', 'Vorsteuer auf Material- und Dienstleistungsaufwand', '{"fr":"Impôt préalable grevant les coûts en matériel et en prestations de services"}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 400 — MWSTG Art. 28.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '405', 'tax', 'Vorsteuer auf Investitionen und übrigem Betriebsaufwand', '{"fr":"Impôt préalable grevant les investissements et autres charges d''exploitation"}'::jsonb, 240, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 405 — MWSTG Art. 28.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '410', 'tax', 'Einlageentsteuerung (nachträglicher Vorsteuerabzug)', '{"fr":"Dégrèvement ultérieur de l''impôt préalable"}'::jsonb, 250, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 410 — MWSTG Art. 32. Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '415', 'tax', 'Vorsteuerkorrekturen: gemischte Verwendung (Art. 30), Eigenverbrauch (Art. 31)', '{"fr":"Corrections de l''impôt préalable (double affectation, prestation à soi-même)"}'::jsonb, 260, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 415 — MWSTG Art. 30 und Art. 31. Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '420', 'tax', 'Vorsteuerkürzungen (Subventionen, Tourismusabgaben)', '{"fr":"Réductions de la déduction de l''impôt préalable"}'::jsonb, 270, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 420 — MWSTG Art. 33 Abs. 2. Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '479', 'total', 'Total der Vorsteuer (Ziffern 400 bis 420)', '{"fr":"Total de l''impôt préalable"}'::jsonb, 280, null, array['400', '405', '410']::text[], array['415', '420']::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 479.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '500', 'total', 'Zu bezahlender Betrag', '{"fr":"Montant à payer"}'::jsonb, 290, null, array['399']::text[], array['479']::text[], null, null, true, false, null, 'Formular Nr. 4470, Ziffer 500.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '510', 'total', 'Guthaben der steuerpflichtigen Person', '{"fr":"Solde en faveur de l''assujetti"}'::jsonb, 300, null, array['479']::text[], array['399']::text[], null, null, true, false, null, 'Formular Nr. 4470, Ziffer 510.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '900', 'base', 'Subventionen, Tourismusabgaben, Entsorgungs-/Wasserbeiträge', '{"fr":"Subventions, taxes touristiques, contributions à l''élimination des déchets et à l''approvisionnement en eau"}'::jsonb, 310, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 900 — MWSTG Art. 18 Abs. 2 Bst. a–c. Von diesem Pack nicht bebucht: keine dieser Positionen ist eine Gegenleistung und keine löst eine Buchung im Sinne dieses Formats aus; siehe README.md.', 'mwst-4470'),
  ('CH', 'CH-MWST-ABR', '910', 'base', 'Spenden, Dividenden, Schadenersatz usw.', '{"fr":"Dons, dividendes, dédommagements"}'::jsonb, 320, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formular Nr. 4470, Ziffer 910 — MWSTG Art. 18 Abs. 2 Bst. d–l. Von diesem Pack nicht bebucht; siehe README.md.', 'mwst-4470')
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
  ('CH-OR-959-BS', 'CH', 'default', 'Bilanz nach Art. 959 OR', 'balance_sheet', 'CH-OR', date '1970-01-01', null, 'Obligationenrecht (OR), Art. 959 Abs. 1 — die Bilanz stellt die Vermögens- und Finanzierungslage des Unternehmens am Bilanzstichtag dar. Abs. 5 gibt die Mindestgliederung des Umlauf- und des Anlagevermögens, Abs. 6 die des kurz- und des langfristigen Fremdkapitals sowie des Eigenkapitals. Jede Position unten ist eine Ziffer dieser beiden Absätze; wo mehrere Ziffern zu einer Zeile zusammengefasst sind, weil dieser Kontenrahmen keine eigene Kontenreihe für sie führt, sagt die Zeile es selbst.', 'or'),
  ('CH-OR-959B-IS', 'CH', 'default', 'Erfolgsrechnung nach Art. 959b Abs. 2 OR (Gliederung nach Aufwandsarten)', 'income_statement', 'CH-OR', date '1970-01-01', null, 'Obligationenrecht (OR), Art. 959b Abs. 1 — die Erfolgsrechnung stellt die Ertragslage des Unternehmens dar. Abs. 2 gibt die Mindestgliederung nach der Art des Aufwands (dieser Pack wählt diese Variante; Abs. 3 lässt eine Gliederung nach Funktionen zu, mit Angabepflicht von Personalaufwand und Abschreibungen im Anhang, die dieser Pack nicht abbildet).', 'or')
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
  ('CH-OR-959-BS', 'AKT', null, 'Total Aktiven', '{"fr":"Total de l''actif"}'::jsonb, 10, 1, true, array['UV', 'AV']::text[], '{}'::text[], null, null, null),
  ('CH-OR-959-BS', 'UV', 'AKT', 'Umlaufvermögen', '{"fr":"Actif circulant"}'::jsonb, 20, 1, true, array['UV.1', 'UV.2', 'UV.3', 'UV.4', 'UV.5']::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 1', 'or'),
  ('CH-OR-959-BS', 'UV.1', 'UV', 'Flüssige Mittel und kurzfristig gehaltene Aktiven mit Börsenkurs', '{"fr":"Liquidités et actifs cotés en bourse détenus à court terme"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 1 Bst. a', 'or'),
  ('CH-OR-959-BS', 'UV.2', 'UV', 'Forderungen aus Lieferungen und Leistungen', '{"fr":"Créances résultant de livraisons et de prestations"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 1 Bst. b', 'or'),
  ('CH-OR-959-BS', 'UV.3', 'UV', 'Sonstige kurzfristige Forderungen', '{"fr":"Autres créances à court terme"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 1 Bst. c', 'or'),
  ('CH-OR-959-BS', 'UV.4', 'UV', 'Vorräte und nicht fakturierte Dienstleistungen', '{"fr":"Stocks et prestations de services non facturées"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 1 Bst. d', 'or'),
  ('CH-OR-959-BS', 'UV.5', 'UV', 'Aktive Rechnungsabgrenzungen', '{"fr":"Actifs de régularisation"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 1 Bst. e', 'or'),
  ('CH-OR-959-BS', 'AV', 'AKT', 'Anlagevermögen', '{"fr":"Actif immobilisé"}'::jsonb, 80, 1, true, array['AV.1', 'AV.2']::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 2', 'or'),
  ('CH-OR-959-BS', 'AV.1', 'AV', 'Sachanlagen', '{"fr":"Immobilisations corporelles"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 2 Bst. c', 'or'),
  ('CH-OR-959-BS', 'AV.2', 'AV', 'Finanzanlagen und Beteiligungen', '{"fr":"Immobilisations financières et participations"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 5 Ziff. 2 Bst. a und b', 'or'),
  ('CH-OR-959-BS', 'PAS', null, 'Total Passiven', '{"fr":"Total du passif"}'::jsonb, 110, 1, true, array['FK1', 'FK2', 'EK']::text[], '{}'::text[], null, null, null),
  ('CH-OR-959-BS', 'FK1', 'PAS', 'Kurzfristiges Fremdkapital', '{"fr":"Capitaux étrangers à court terme"}'::jsonb, 120, 1, true, array['FK1.1', 'FK1.2']::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 1', 'or'),
  ('CH-OR-959-BS', 'FK1.1', 'FK1', 'Verbindlichkeiten aus Lieferungen und Leistungen', '{"fr":"Dettes résultant de livraisons et de prestations"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 1 Bst. a', 'or'),
  ('CH-OR-959-BS', 'FK1.2', 'FK1', 'Übrige kurzfristige Verbindlichkeiten, Rückstellungen und passive Rechnungsabgrenzungen', '{"fr":"Autres dettes à court terme, provisions et passifs de régularisation"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 1 Bst. b bis d — dieser Kontenrahmen führt für diese drei Ziffern eine gemeinsame Kontenreihe, so dass sie hier eine Zeile bilden.', 'or'),
  ('CH-OR-959-BS', 'FK2', 'PAS', 'Langfristiges Fremdkapital', '{"fr":"Capitaux étrangers à long terme"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 2', 'or'),
  ('CH-OR-959-BS', 'EK', 'PAS', 'Eigenkapital', '{"fr":"Capitaux propres"}'::jsonb, 160, 1, true, array['EK.1', 'EK.2']::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 3', 'or'),
  ('CH-OR-959-BS', 'EK.1', 'EK', 'Kapital und Reserven', '{"fr":"Capital et réserves"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 3 Bst. a bis d', 'or'),
  ('CH-OR-959-BS', 'EK.2', 'EK', 'Bilanzgewinn oder Bilanzverlust', '{"fr":"Bénéfice ou perte au bilan"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959 Abs. 6 Ziff. 3 Bst. d', 'or'),
  ('CH-OR-959B-IS', 'NE', null, 'Nettoerlöse aus Lieferungen und Leistungen', '{"fr":"Produits nets des ventes et des prestations de services"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 1', 'or'),
  ('CH-OR-959B-IS', 'MAT', null, 'Materialaufwand', '{"fr":"Charges de matériel"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 3', 'or'),
  ('CH-OR-959B-IS', 'PERS', null, 'Personalaufwand', '{"fr":"Charges de personnel"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 4', 'or'),
  ('CH-OR-959B-IS', 'SBA', null, 'Sonstiger betrieblicher Aufwand', '{"fr":"Autres charges d''exploitation"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 5 — Rundungsdifferenzen (8950/8969) sind ein technisches Konto ohne eigene Ziffer und werden hier eingereiht.', 'or'),
  ('CH-OR-959B-IS', 'ABS', null, 'Abschreibungen und Wertberichtigungen auf Positionen des Anlagevermögens', '{"fr":"Amortissements et corrections de valeur sur l''actif immobilisé"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 6', 'or'),
  ('CH-OR-959B-IS', 'FA', null, 'Finanzaufwand', '{"fr":"Charges financières"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 7', 'or'),
  ('CH-OR-959B-IS', 'FE', null, 'Finanzertrag', '{"fr":"Produits financiers"}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 7', 'or'),
  ('CH-OR-959B-IS', 'BFA', null, 'Betriebsfremder Aufwand', '{"fr":"Charges hors exploitation"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 8', 'or'),
  ('CH-OR-959B-IS', 'BFE', null, 'Betriebsfremder Ertrag', '{"fr":"Produits hors exploitation"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 8', 'or'),
  ('CH-OR-959B-IS', 'AOA', null, 'Ausserordentlicher, einmaliger oder periodenfremder Aufwand', '{"fr":"Charges extraordinaires, uniques ou hors période"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 9', 'or'),
  ('CH-OR-959B-IS', 'AOE', null, 'Ausserordentlicher, einmaliger oder periodenfremder Ertrag', '{"fr":"Produits extraordinaires, uniques ou hors période"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 9', 'or'),
  ('CH-OR-959B-IS', 'STE', null, 'Direkte Steuern', '{"fr":"Impôts directs"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'OR Art. 959b Abs. 2 Ziff. 10', 'or'),
  ('CH-OR-959B-IS', 'JG', null, 'Jahresgewinn oder Jahresverlust', '{"fr":"Bénéfice ou perte de l''exercice"}'::jsonb, 130, 1, true, array['NE', 'FE', 'BFE', 'AOE']::text[], array['MAT', 'PERS', 'SBA', 'ABS', 'FA', 'BFA', 'AOA', 'STE']::text[], null, 'OR Art. 959b Abs. 2 Ziff. 11', 'or')
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
    ('CH-OR-959-BS', 'UV.1', 10, 'code_range', '1000', '1099', null, 'any'),
    ('CH-OR-959-BS', 'UV.2', 10, 'code_range', '1100', '1119', null, 'any'),
    ('CH-OR-959-BS', 'UV.3', 10, 'code_range', '1140', '1189', null, 'any'),
    ('CH-OR-959-BS', 'UV.4', 10, 'code_range', '1200', '1299', null, 'any'),
    ('CH-OR-959-BS', 'UV.5', 10, 'code_range', '1300', '1399', null, 'any'),
    ('CH-OR-959-BS', 'AV.1', 10, 'code_range', '1500', '1699', null, 'any'),
    ('CH-OR-959-BS', 'AV.2', 10, 'code_range', '1700', '1799', null, 'any'),
    ('CH-OR-959-BS', 'FK1.1', 10, 'code_range', '2000', '2029', null, 'any'),
    ('CH-OR-959-BS', 'FK1.2', 10, 'code_range', '2030', '2399', null, 'any'),
    ('CH-OR-959-BS', 'FK2', 10, 'code_range', '2400', '2799', null, 'any'),
    ('CH-OR-959-BS', 'EK.1', 10, 'code_range', '2800', '2899', null, 'any'),
    ('CH-OR-959-BS', 'EK.2', 10, 'code_range', '2900', '2999', null, 'any'),
    ('CH-OR-959B-IS', 'NE', 10, 'code_range', '3000', '3099', null, 'any'),
    ('CH-OR-959B-IS', 'MAT', 10, 'code_range', '4000', '4099', null, 'any'),
    ('CH-OR-959B-IS', 'PERS', 10, 'code_range', '5000', '5999', null, 'any'),
    ('CH-OR-959B-IS', 'SBA', 10, 'code_range', '6000', '6570', null, 'any'),
    ('CH-OR-959B-IS', 'SBA', 20, 'code_range', '8950', '8969', null, 'any'),
    ('CH-OR-959B-IS', 'ABS', 10, 'code_range', '6600', '6699', null, 'any'),
    ('CH-OR-959B-IS', 'FA', 10, 'code_range', '6900', '6949', null, 'any'),
    ('CH-OR-959B-IS', 'FE', 10, 'code_range', '6950', '6999', null, 'any'),
    ('CH-OR-959B-IS', 'BFA', 10, 'code_range', '7900', '7999', null, 'any'),
    ('CH-OR-959B-IS', 'BFE', 10, 'code_range', '7500', '7899', null, 'any'),
    ('CH-OR-959B-IS', 'AOA', 10, 'code_range', '8900', '8949', null, 'any'),
    ('CH-OR-959B-IS', 'AOE', 10, 'code_range', '8500', '8899', null, 'any'),
    ('CH-OR-959B-IS', 'STE', 10, 'code_range', '8990', '8999', null, 'any')
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
  ('CH', 'Schweiz', '{"fr":"Suisse"}'::jsonb, array['de', 'fr']::text[], 'CHF', '1100', '2000', '2300', '8950', '2900', '3000', '4000', '1020', '1000', 'SAL', 'PUR', 'GEN', 'de', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '6960', '6920', null, null, null, null, '2140', '1176', null, null)
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
  legal_payment_days            = 0,
  late_payment_reference        = 'Art. 75 OR: Fehlt eine Vereinbarung über die Erfüllungszeit, so kann die Forderung sofort eingefordert werden — die Schweiz kennt keine gesetzliche Zahlungsfrist von 30 Tagen wie sie ausserhalb der EU nicht gilt. Art. 102 Abs. 1 OR setzt Verzug erst mit einer Mahnung des Gläubigers oder mit einem vereinbarten Verfalltag; Art. 104 Abs. 1 OR setzt den Verzugszins auf 5 % pro Jahr fest, sofern kein höherer vertraglicher Zins vereinbart wurde. Anders als die EU-Richtlinie 2011/7/EU (die für die Schweiz nicht gilt) kennt das OR keinen automatischen Verzugszins ohne Mahnung und keine gesetzliche Pauschale für Beitreibungskosten.',
  numbering_legal_reference     = 'Art. 26 Abs. 2 MWSTG zählt die Pflichtangaben der Rechnung abschliessend auf (Bst. a–f: Name/Adresse und UID des Leistungserbringers, Name/Adresse des Empfängers, Datum oder Zeitraum der Leistung, Art/Gegenstand/Umfang der Leistung, Entgelt, Steuersatz und Steuerbetrag) und verlangt keine fortlaufende Rechnungsnummer. Art. 957a OR verlangt eine nachvollziehbare Buchführung anhand von Belegen, schreibt aber ebenfalls kein Nummerierungsschema vor. Dieser Pack schlägt daher ein Format vor, ohne eine gesetzliche Lückenlosigkeit zu behaupten, die keine Norm verlangt.',
  numbering_source_key          = 'mwstg',
  payment_terms_legal_reference = 'Art. 75 OR — mangels Vereinbarung ist die Forderung sofort fällig und einforderbar.',
  payment_terms_source_key      = 'or',
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = 'Art. 39 Abs. 1 MWSTG — die Regel ist die Abrechnung nach vereinbarten Entgelten; Art. 40 Abs. 1 Bst. a MWSTG — die Steuerforderung entsteht bei dieser Methode im Zeitpunkt der Rechnungsstellung. Art. 39 Abs. 2 MWSTG lässt auf Gesuch hin die Abrechnung nach vereinnahmten Entgelten (Ist-Methode, Zahlungszeitpunkt) zu; dieser unternehmensweite Methodenwechsel wird von diesem Pack nicht abgebildet — siehe README.md.',
  tax_point_source_key          = 'mwstg',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Am 22. September 2026 verpflichtet kein Bundesgesetz Unternehmen zum Austausch strukturierter elektronischer Rechnungen untereinander (B2B). Der Bund verlangt seit 2016 von seinen eigenen Lieferanten bei Aufträgen über CHF 5''000 eine elektronische Rechnung (B2G), was keine B2B-Pflicht begründet. Die von eCH veröffentlichten Standards — eCH-0069 (Inhaltsstandard swissDIGIN für elektronische Rechnungen) und eCH-0217 (Format für die elektronische Übermittlung der MWST-Abrechnung an das ESTV-Portal SuisseTax, keine Rechnungsnorm) — haben nach den eigenen Nutzungsbestimmungen von eCH ausdrücklich nur Empfehlungscharakter.',
  einvoice_source_key           = 'ech-verbindlichkeit',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053', 'mt940', 'csv']::text[],
  payment_formats               = array['pain.001', 'csv']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'CH';
