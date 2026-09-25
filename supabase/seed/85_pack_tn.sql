-- Ekwo OS — Tunisie: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/tn at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build tn`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Code de la taxe sur la valeur ajoutée, promulgué par la loi n° 88-61 du 2 juin 1988, texte consolidé (Ministère des Finances — Direction Générale des Études et de la Législation Fiscales)
--     https://www.finances.gov.tn/sites/default/files/CODE%20TVA%202017%20FR.pdf
--   Code de la TVA — texte article par article, avec le tableau « A » des exonérations, le tableau « B » (taux de 7 %) et le tableau « B bis » (taux de 13 %) annexés (JurisiteTunisie)
--     https://www.jurisitetunisie.com/tunisie/codes/tva/menu.html
--   Loi de finances pour l'année 2018, loi n° 2017-66 du 18 décembre 2017, art. 43 — relèvement des taux de la TVA de 18 %, 12 % et 6 % à 19 %, 13 % et 7 % (Imprimerie Officielle de la République Tunisienne (IORT), Journal officiel de la République tunisienne)
--     https://www.finances.gov.tn/fr/lois-de-finances
--   Loi n° 96-112 du 30 décembre 1996, relative au système comptable des entreprises (Conseil du Marché Financier (texte de la loi, publication officielle))
--     https://www.cmf.tn/sites/default/files/pdfs/reglementation/textes-reference/loi_96-112_301296_fr.pdf
--   Norme comptable générale NC 01, homologuée par le décret n° 96-2459 du 30 décembre 1996 — présentation des états financiers, organisation comptable et nomenclature des comptes (Ministère des Finances — Ordre des Experts Comptables de Tunisie (texte de la norme))
--     https://oect.org.tn/wp-content/uploads/2023/01/NC_01.pdf
--   Loi de finances pour l'année 2016 (loi n° 2015-53 du 25 décembre 2015), art. 22, assimilant la facture électronique à la facture papier et désignant Tunisie TradeNet (TTN) comme opérateur technique ; décret gouvernemental n° 2016-1066 du 15 août 2016, fixant les conditions et modalités d'émission et d'archivage de la facture électronique (Imprimerie Officielle de la République Tunisienne (IORT))
--     https://www.ttn.tn
--   Calendrier fiscal — déclaration mensuelle des impôts, délais de dépôt et de paiement (Direction Générale des Impôts (DGI))
--     https://www.impots.finances.gov.tn
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('TN', 'Tunisie', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '0b3434acabbf46f061dfc68184dc8e2263c7baf929f8a01c31d6d99d101a4489', '[{"key":"code-tva","title":"Code de la taxe sur la valeur ajoutée, promulgué par la loi n° 88-61 du 2 juin 1988, texte consolidé","publisher":"Ministère des Finances — Direction Générale des Études et de la Législation Fiscales","url":"https://www.finances.gov.tn/sites/default/files/CODE%20TVA%202017%20FR.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"jurisite-tva","title":"Code de la TVA — texte article par article, avec le tableau « A » des exonérations, le tableau « B » (taux de 7 %) et le tableau « B bis » (taux de 13 %) annexés","publisher":"JurisiteTunisie","url":"https://www.jurisitetunisie.com/tunisie/codes/tva/menu.html","consulted_on":"2026-09-25","kind":"law"},{"key":"loi-2017-66","title":"Loi de finances pour l''année 2018, loi n° 2017-66 du 18 décembre 2017, art. 43 — relèvement des taux de la TVA de 18 %, 12 % et 6 % à 19 %, 13 % et 7 %","publisher":"Imprimerie Officielle de la République Tunisienne (IORT), Journal officiel de la République tunisienne","url":"https://www.finances.gov.tn/fr/lois-de-finances","consulted_on":"2026-09-25","kind":"law"},{"key":"sce-1996","title":"Loi n° 96-112 du 30 décembre 1996, relative au système comptable des entreprises","publisher":"Conseil du Marché Financier (texte de la loi, publication officielle)","url":"https://www.cmf.tn/sites/default/files/pdfs/reglementation/textes-reference/loi_96-112_301296_fr.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"nc01","title":"Norme comptable générale NC 01, homologuée par le décret n° 96-2459 du 30 décembre 1996 — présentation des états financiers, organisation comptable et nomenclature des comptes","publisher":"Ministère des Finances — Ordre des Experts Comptables de Tunisie (texte de la norme)","url":"https://oect.org.tn/wp-content/uploads/2023/01/NC_01.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"el-fatoora","title":"Loi de finances pour l''année 2016 (loi n° 2015-53 du 25 décembre 2015), art. 22, assimilant la facture électronique à la facture papier et désignant Tunisie TradeNet (TTN) comme opérateur technique ; décret gouvernemental n° 2016-1066 du 15 août 2016, fixant les conditions et modalités d''émission et d''archivage de la facture électronique","publisher":"Imprimerie Officielle de la République Tunisienne (IORT)","url":"https://www.ttn.tn","consulted_on":"2026-09-25","kind":"regulation"},{"key":"dgi-calendrier","title":"Calendrier fiscal — déclaration mensuelle des impôts, délais de dépôt et de paiement","publisher":"Direction Générale des Impôts (DGI)","url":"https://www.impots.finances.gov.tn","consulted_on":"2026-09-25","kind":"portal"}]'::jsonb)
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
  ('TN', 'default', 'Système comptable des entreprises — nomenclature des comptes', '{}'::jsonb, true, 'companies', array['TN-SCE-BS', 'TN-SCE-IS']::text[], null, 'Loi n° 96-112 du 30 décembre 1996, relative au système comptable des entreprises, art. 7 — les normes comptables comprennent une norme générale, des normes techniques et des normes sectorielles ; décret n° 96-2459 du 30 décembre 1996 portant approbation des normes comptables, dont la norme comptable générale NC 01. Les sept classes de comptes (1 capitaux propres et passifs non courants, 2 actifs non courants, 3 stocks, 4 tiers, 5 comptes financiers, 6 charges, 7 produits) et les comptes 101 (capital social, avec ses sous-comptes 1011/1012/1013/1018), 11 (réserves), 12 (résultats reportés), 13 (résultat de l''exercice), 20/21/28 (immobilisations et leurs amortissements), 40 (fournisseurs), 41 (clients) et 436 (État, taxes sur le chiffre d''affaires) sont vérifiés contre plusieurs sources indépendantes citées ci-dessus. Au-delà de ce squelette vérifié, cette recherche n''a pas pu ouvrir une nomenclature intégrale et officielle en texte exploitable (les PDF consultés du Journal officiel et de la norme NC 01 ne se laissent pas extraire en texte) : le détail des sous-comptes est la construction propre de ce pack, dans le même esprit que packs/sa/ lorsqu''aucune nomenclature officielle exploitable n''a pu être ouverte. Un comptable tunisien devrait vérifier la numérotation fine avant tout usage réel.', 'sce-1996')
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
  ('TN', 'default', '1', 'COMPTES DE CAPITAUX PROPRES ET PASSIFS NON COURANTS', '{}'::jsonb, 'equity', false, null, 10),
  ('TN', 'default', '10', 'CAPITAL', '{}'::jsonb, 'equity', false, '1', 20),
  ('TN', 'default', '101', 'Capital social', '{}'::jsonb, 'equity', false, '10', 30),
  ('TN', 'default', '1011', 'Capital souscrit, non appelé', '{}'::jsonb, 'equity', false, '101', 40),
  ('TN', 'default', '1012', 'Capital souscrit, appelé, non versé', '{}'::jsonb, 'equity', false, '101', 50),
  ('TN', 'default', '1013', 'Capital souscrit, appelé et versé', '{}'::jsonb, 'equity', false, '101', 60),
  ('TN', 'default', '1018', 'Capital souscrit soumis à des dispositions particulières', '{}'::jsonb, 'equity', false, '101', 70),
  ('TN', 'default', '103', 'Capital personnel (entreprise individuelle)', '{}'::jsonb, 'equity', false, '10', 80),
  ('TN', 'default', '105', 'Écarts de réévaluation', '{}'::jsonb, 'equity', false, '10', 90),
  ('TN', 'default', '11', 'RÉSERVES ET PRIMES LIÉES AU CAPITAL', '{}'::jsonb, 'equity', false, '1', 100),
  ('TN', 'default', '110', 'Primes liées au capital social', '{}'::jsonb, 'equity', false, '11', 110),
  ('TN', 'default', '111', 'Réserve légale', '{}'::jsonb, 'equity', false, '11', 120),
  ('TN', 'default', '112', 'Réserves statutaires ou contractuelles', '{}'::jsonb, 'equity', false, '11', 130),
  ('TN', 'default', '113', 'Réserves réglementées', '{}'::jsonb, 'equity', false, '11', 140),
  ('TN', 'default', '118', 'Autres réserves', '{}'::jsonb, 'equity', false, '11', 150),
  ('TN', 'default', '12', 'RÉSULTATS REPORTÉS', '{}'::jsonb, 'equity_retained', false, '1', 160),
  ('TN', 'default', '120', 'Report à nouveau créditeur', '{}'::jsonb, 'equity_retained', false, '12', 170),
  ('TN', 'default', '129', 'Report à nouveau débiteur', '{}'::jsonb, 'equity_retained', false, '12', 180),
  ('TN', 'default', '13', 'RÉSULTAT DE L''EXERCICE', '{}'::jsonb, 'equity', false, '1', 190),
  ('TN', 'default', '131', 'Résultat de l''exercice, bénéfice', '{}'::jsonb, 'equity', false, '13', 200),
  ('TN', 'default', '139', 'Résultat de l''exercice, perte', '{}'::jsonb, 'equity', false, '13', 210),
  ('TN', 'default', '14', 'SUBVENTIONS D''INVESTISSEMENT', '{}'::jsonb, 'equity', false, '1', 220),
  ('TN', 'default', '140', 'Subventions d''investissement', '{}'::jsonb, 'equity', false, '14', 230),
  ('TN', 'default', '15', 'PROVISIONS POUR RISQUES ET CHARGES', '{}'::jsonb, 'liability_non_current', false, '1', 240),
  ('TN', 'default', '151', 'Provisions pour litiges', '{}'::jsonb, 'liability_non_current', false, '15', 250),
  ('TN', 'default', '158', 'Autres provisions pour risques et charges', '{}'::jsonb, 'liability_non_current', false, '15', 260),
  ('TN', 'default', '16', 'EMPRUNTS ET DETTES ASSIMILÉES', '{}'::jsonb, 'liability_non_current', false, '1', 270),
  ('TN', 'default', '161', 'Emprunts obligataires', '{}'::jsonb, 'liability_non_current', false, '16', 280),
  ('TN', 'default', '162', 'Emprunts auprès des établissements de crédit', '{}'::jsonb, 'liability_non_current', false, '16', 290),
  ('TN', 'default', '165', 'Dépôts et cautionnements reçus', '{}'::jsonb, 'liability_non_current', false, '16', 300),
  ('TN', 'default', '168', 'Autres emprunts et dettes assimilées', '{}'::jsonb, 'liability_non_current', false, '16', 310),
  ('TN', 'default', '2', 'COMPTES D''ACTIFS NON COURANTS', '{}'::jsonb, 'asset_fixed', false, null, 320),
  ('TN', 'default', '20', 'IMMOBILISATIONS INCORPORELLES', '{}'::jsonb, 'asset_non_current', false, '2', 330),
  ('TN', 'default', '201', 'Frais de développement', '{}'::jsonb, 'asset_non_current', false, '20', 340),
  ('TN', 'default', '202', 'Brevets, licences, marques et droits similaires', '{}'::jsonb, 'asset_non_current', false, '20', 350),
  ('TN', 'default', '204', 'Logiciels', '{}'::jsonb, 'asset_non_current', false, '20', 360),
  ('TN', 'default', '208', 'Autres immobilisations incorporelles', '{}'::jsonb, 'asset_non_current', false, '20', 370),
  ('TN', 'default', '21', 'IMMOBILISATIONS CORPORELLES', '{}'::jsonb, 'asset_fixed', false, '2', 380),
  ('TN', 'default', '211', 'Terrains', '{}'::jsonb, 'asset_fixed', false, '21', 390),
  ('TN', 'default', '213', 'Constructions', '{}'::jsonb, 'asset_fixed', false, '21', 400),
  ('TN', 'default', '215', 'Installations techniques, matériel et outillage industriels', '{}'::jsonb, 'asset_fixed', false, '21', 410),
  ('TN', 'default', '218', 'Autres immobilisations corporelles', '{}'::jsonb, 'asset_fixed', false, '21', 420),
  ('TN', 'default', '2181', 'Matériel de transport', '{}'::jsonb, 'asset_fixed', false, '218', 430),
  ('TN', 'default', '2182', 'Matériel et mobilier de bureau', '{}'::jsonb, 'asset_fixed', false, '218', 440),
  ('TN', 'default', '2183', 'Matériel informatique', '{}'::jsonb, 'asset_fixed', false, '218', 450),
  ('TN', 'default', '23', 'IMMOBILISATIONS EN COURS', '{}'::jsonb, 'asset_fixed', false, '2', 460),
  ('TN', 'default', '237', 'Avances et acomptes versés sur commandes d''immobilisations', '{}'::jsonb, 'asset_fixed', false, '23', 470),
  ('TN', 'default', '26', 'PARTICIPATIONS ET CRÉANCES RATTACHÉES', '{}'::jsonb, 'asset_non_current', false, '2', 480),
  ('TN', 'default', '27', 'AUTRES IMMOBILISATIONS FINANCIÈRES', '{}'::jsonb, 'asset_non_current', false, '2', 490),
  ('TN', 'default', '275', 'Dépôts et cautionnements versés', '{}'::jsonb, 'asset_non_current', false, '27', 500),
  ('TN', 'default', '28', 'AMORTISSEMENTS DES IMMOBILISATIONS', '{}'::jsonb, 'asset_fixed', false, '2', 510),
  ('TN', 'default', '281', 'Amortissements des immobilisations incorporelles', '{}'::jsonb, 'asset_fixed', false, '28', 520),
  ('TN', 'default', '282', 'Amortissements des immobilisations corporelles', '{}'::jsonb, 'asset_fixed', false, '28', 530),
  ('TN', 'default', '2821', 'Amortissements des constructions', '{}'::jsonb, 'asset_fixed', false, '282', 540),
  ('TN', 'default', '2822', 'Amortissements des installations techniques, matériel et outillage', '{}'::jsonb, 'asset_fixed', false, '282', 550),
  ('TN', 'default', '2828', 'Amortissements des autres immobilisations corporelles', '{}'::jsonb, 'asset_fixed', false, '282', 560),
  ('TN', 'default', '29', 'PROVISIONS POUR DÉPRÉCIATION DES IMMOBILISATIONS', '{}'::jsonb, 'asset_non_current', false, '2', 570),
  ('TN', 'default', '292', 'Provisions pour dépréciation des immobilisations corporelles', '{}'::jsonb, 'asset_non_current', false, '29', 580),
  ('TN', 'default', '296', 'Provisions pour dépréciation des titres de participation', '{}'::jsonb, 'asset_non_current', false, '29', 590),
  ('TN', 'default', '3', 'COMPTES DE STOCKS ET EN-COURS', '{}'::jsonb, 'asset_current', false, null, 600),
  ('TN', 'default', '31', 'MATIÈRES PREMIÈRES ET FOURNITURES', '{}'::jsonb, 'asset_current', false, '3', 610),
  ('TN', 'default', '32', 'AUTRES APPROVISIONNEMENTS', '{}'::jsonb, 'asset_current', false, '3', 620),
  ('TN', 'default', '33', 'EN-COURS DE PRODUCTION DE BIENS', '{}'::jsonb, 'asset_current', false, '3', 630),
  ('TN', 'default', '35', 'STOCKS DE PRODUITS', '{}'::jsonb, 'asset_current', false, '3', 640),
  ('TN', 'default', '37', 'STOCKS DE MARCHANDISES', '{}'::jsonb, 'asset_current', false, '3', 650),
  ('TN', 'default', '39', 'PROVISIONS POUR DÉPRÉCIATION DES STOCKS', '{}'::jsonb, 'asset_current', false, '3', 660),
  ('TN', 'default', '4', 'COMPTES DE TIERS', '{}'::jsonb, 'asset_current', false, null, 670),
  ('TN', 'default', '40', 'FOURNISSEURS ET COMPTES RATTACHÉS', '{}'::jsonb, 'liability_payable', true, '4', 680),
  ('TN', 'default', '401', 'Fournisseurs, dettes en compte', '{}'::jsonb, 'liability_payable', true, '40', 690),
  ('TN', 'default', '403', 'Fournisseurs, effets à payer', '{}'::jsonb, 'liability_payable', true, '40', 700),
  ('TN', 'default', '404', 'Fournisseurs d''immobilisations', '{}'::jsonb, 'liability_payable', true, '40', 710),
  ('TN', 'default', '408', 'Fournisseurs, factures non parvenues', '{}'::jsonb, 'liability_payable', true, '40', 720),
  ('TN', 'default', '409', 'Fournisseurs débiteurs, avances et acomptes versés', '{}'::jsonb, 'asset_current', true, '40', 730),
  ('TN', 'default', '41', 'CLIENTS ET COMPTES RATTACHÉS', '{}'::jsonb, 'asset_receivable', true, '4', 740),
  ('TN', 'default', '411', 'Clients', '{}'::jsonb, 'asset_receivable', true, '41', 750),
  ('TN', 'default', '413', 'Clients, effets à recevoir', '{}'::jsonb, 'asset_receivable', true, '41', 760),
  ('TN', 'default', '416', 'Clients douteux ou litigieux', '{}'::jsonb, 'asset_receivable', true, '41', 770),
  ('TN', 'default', '418', 'Clients, produits à recevoir', '{}'::jsonb, 'asset_receivable', true, '41', 780),
  ('TN', 'default', '419', 'Clients créditeurs, avances et acomptes reçus', '{}'::jsonb, 'liability_current', true, '41', 790),
  ('TN', 'default', '42', 'PERSONNEL', '{}'::jsonb, 'liability_current', false, '4', 800),
  ('TN', 'default', '421', 'Personnel, rémunérations dues', '{}'::jsonb, 'liability_current', false, '42', 810),
  ('TN', 'default', '425', 'Personnel, avances et acomptes', '{}'::jsonb, 'asset_current', false, '42', 820),
  ('TN', 'default', '428', 'Personnel, charges à payer', '{}'::jsonb, 'liability_current', false, '42', 830),
  ('TN', 'default', '43', 'ÉTAT ET ORGANISMES SOCIAUX', '{}'::jsonb, 'liability_current', false, '4', 840),
  ('TN', 'default', '431', 'Caisse nationale de sécurité sociale (CNSS)', '{}'::jsonb, 'liability_current', false, '43', 850),
  ('TN', 'default', '432', 'État, impôt sur les sociétés ou impôt sur le revenu', '{}'::jsonb, 'liability_current', false, '43', 860),
  ('TN', 'default', '436', 'État, taxes sur le chiffre d''affaires', '{}'::jsonb, 'liability_current', false, '43', 870),
  ('TN', 'default', '4361', 'État, TVA collectée', '{}'::jsonb, 'liability_current', false, '436', 880),
  ('TN', 'default', '4362', 'État, TVA retenue à la source à reverser (art. 19)', '{}'::jsonb, 'liability_current', false, '436', 885),
  ('TN', 'default', '4366', 'État, TVA déductible sur autres biens et services', '{}'::jsonb, 'asset_current', false, '436', 890),
  ('TN', 'default', '4367', 'État, TVA déductible sur immobilisations', '{}'::jsonb, 'asset_current', false, '436', 900),
  ('TN', 'default', '4368', 'État, TVA à payer', '{}'::jsonb, 'liability_current', true, '436', 910),
  ('TN', 'default', '4369', 'État, crédit de TVA à reporter ou à restituer', '{}'::jsonb, 'asset_current', true, '436', 920),
  ('TN', 'default', '437', 'État, autres impôts, taxes et versements assimilés', '{}'::jsonb, 'liability_current', false, '43', 930),
  ('TN', 'default', '438', 'État, charges à payer', '{}'::jsonb, 'liability_current', false, '43', 940),
  ('TN', 'default', '47', 'COMPTES D''ATTENTE ET DE RÉGULARISATION', '{}'::jsonb, 'liability_current', false, '4', 950),
  ('TN', 'default', '471', 'Compte d''attente', '{}'::jsonb, 'liability_current', false, '47', 960),
  ('TN', 'default', '486', 'Charges constatées d''avance', '{}'::jsonb, 'asset_current', false, '47', 970),
  ('TN', 'default', '487', 'Produits constatés d''avance', '{}'::jsonb, 'liability_current', false, '47', 980),
  ('TN', 'default', '5', 'COMPTES FINANCIERS', '{}'::jsonb, 'asset_cash', false, null, 990),
  ('TN', 'default', '53', 'BANQUES ET ÉTABLISSEMENTS FINANCIERS', '{}'::jsonb, 'asset_cash', false, '5', 1000),
  ('TN', 'default', '532', 'Banques', '{}'::jsonb, 'asset_cash', false, '53', 1010),
  ('TN', 'default', '534', 'Chèques postaux', '{}'::jsonb, 'asset_cash', false, '53', 1020),
  ('TN', 'default', '54', 'Caisse', '{}'::jsonb, 'asset_cash', false, '5', 1030),
  ('TN', 'default', '58', 'Virements internes', '{}'::jsonb, 'asset_cash', false, '5', 1040),
  ('TN', 'default', '59', 'Provisions pour dépréciation des comptes financiers', '{}'::jsonb, 'asset_cash', false, '5', 1050),
  ('TN', 'default', '6', 'COMPTES DE CHARGES', '{}'::jsonb, 'expense', false, null, 1060),
  ('TN', 'default', '60', 'ACHATS', '{}'::jsonb, 'expense', false, '6', 1070),
  ('TN', 'default', '601', 'Achats de marchandises', '{}'::jsonb, 'expense', false, '60', 1080),
  ('TN', 'default', '602', 'Achats de matières premières', '{}'::jsonb, 'expense', false, '60', 1090),
  ('TN', 'default', '604', 'Achats d''études et de prestations de services', '{}'::jsonb, 'expense', false, '60', 1100),
  ('TN', 'default', '606', 'Achats non stockés de matières et fournitures', '{}'::jsonb, 'expense', false, '60', 1110),
  ('TN', 'default', '609', 'Rabais, remises et ristournes obtenus sur achats', '{}'::jsonb, 'expense', false, '60', 1120),
  ('TN', 'default', '61', 'SERVICES EXTÉRIEURS', '{}'::jsonb, 'expense', false, '6', 1130),
  ('TN', 'default', '613', 'Locations', '{}'::jsonb, 'expense', false, '61', 1140),
  ('TN', 'default', '615', 'Entretien et réparations', '{}'::jsonb, 'expense', false, '61', 1150),
  ('TN', 'default', '616', 'Primes d''assurances', '{}'::jsonb, 'expense', false, '61', 1160),
  ('TN', 'default', '618', 'Documentation, missions et réceptions', '{}'::jsonb, 'expense', false, '61', 1170),
  ('TN', 'default', '62', 'AUTRES SERVICES EXTÉRIEURS', '{}'::jsonb, 'expense', false, '6', 1180),
  ('TN', 'default', '621', 'Personnel extérieur à l''entreprise', '{}'::jsonb, 'expense', false, '62', 1190),
  ('TN', 'default', '622', 'Rémunérations d''intermédiaires et honoraires', '{}'::jsonb, 'expense', false, '62', 1200),
  ('TN', 'default', '624', 'Transports', '{}'::jsonb, 'expense', false, '62', 1210),
  ('TN', 'default', '625', 'Déplacements, missions et réceptions', '{}'::jsonb, 'expense', false, '62', 1220),
  ('TN', 'default', '626', 'Frais postaux et de télécommunications', '{}'::jsonb, 'expense', false, '62', 1230),
  ('TN', 'default', '627', 'Services bancaires', '{}'::jsonb, 'expense', false, '62', 1240),
  ('TN', 'default', '63', 'IMPÔTS, TAXES ET VERSEMENTS ASSIMILÉS', '{}'::jsonb, 'expense', false, '6', 1250),
  ('TN', 'default', '635', 'Autres impôts, taxes et versements assimilés', '{}'::jsonb, 'expense', false, '63', 1260),
  ('TN', 'default', '64', 'CHARGES DE PERSONNEL', '{}'::jsonb, 'expense', false, '6', 1270),
  ('TN', 'default', '641', 'Salaires et traitements', '{}'::jsonb, 'expense', false, '64', 1280),
  ('TN', 'default', '645', 'Charges sociales (CNSS patronale)', '{}'::jsonb, 'expense', false, '64', 1290),
  ('TN', 'default', '65', 'CHARGES DIVERSES ORDINAIRES', '{}'::jsonb, 'expense', false, '6', 1300),
  ('TN', 'default', '658', 'Écarts de règlement (arrondis)', '{}'::jsonb, 'expense', false, '65', 1310),
  ('TN', 'default', '66', 'CHARGES FINANCIÈRES', '{}'::jsonb, 'expense', false, '6', 1320),
  ('TN', 'default', '661', 'Charges d''intérêts', '{}'::jsonb, 'expense', false, '66', 1330),
  ('TN', 'default', '666', 'Pertes de change', '{}'::jsonb, 'expense', false, '66', 1340),
  ('TN', 'default', '68', 'DOTATIONS AUX AMORTISSEMENTS ET AUX PROVISIONS', '{}'::jsonb, 'expense_depreciation', false, '6', 1350),
  ('TN', 'default', '681', 'Dotations aux amortissements des immobilisations', '{}'::jsonb, 'expense_depreciation', false, '68', 1360),
  ('TN', 'default', '686', 'Dotations aux provisions', '{}'::jsonb, 'expense_depreciation', false, '68', 1370),
  ('TN', 'default', '69', 'IMPÔT SUR LES BÉNÉFICES', '{}'::jsonb, 'expense', false, '6', 1380),
  ('TN', 'default', '691', 'Impôt sur les sociétés', '{}'::jsonb, 'expense', false, '69', 1390),
  ('TN', 'default', '7', 'COMPTES DE PRODUITS', '{}'::jsonb, 'income', false, null, 1400),
  ('TN', 'default', '70', 'VENTES', '{}'::jsonb, 'income', false, '7', 1410),
  ('TN', 'default', '701', 'Ventes de marchandises', '{}'::jsonb, 'income', false, '70', 1420),
  ('TN', 'default', '706', 'Ventes de prestations de services', '{}'::jsonb, 'income', false, '70', 1430),
  ('TN', 'default', '709', 'Rabais, remises et ristournes accordés', '{}'::jsonb, 'income', false, '70', 1440),
  ('TN', 'default', '75', 'PRODUITS DIVERS ORDINAIRES', '{}'::jsonb, 'income_other', false, '7', 1450),
  ('TN', 'default', '76', 'PRODUITS FINANCIERS', '{}'::jsonb, 'income_other', false, '7', 1460),
  ('TN', 'default', '766', 'Gains de change', '{}'::jsonb, 'income_other', false, '76', 1470),
  ('TN', 'default', '78', 'REPRISES SUR AMORTISSEMENTS ET PROVISIONS', '{}'::jsonb, 'income_other', false, '7', 1480)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('TN', 'AC', 'Journal des achats', '{}'::jsonb, 'purchase', 20),
  ('TN', 'AN', 'Journal des à-nouveaux', '{}'::jsonb, 'opening', 60),
  ('TN', 'BQ', 'Journal de banque', '{}'::jsonb, 'bank', 30),
  ('TN', 'CA', 'Journal de caisse', '{}'::jsonb, 'cash', 40),
  ('TN', 'OD', 'Journal des opérations diverses', '{}'::jsonb, 'general', 50),
  ('TN', 'VT', 'Journal des ventes', '{}'::jsonb, 'sales', 10)
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
  ('TN', 'TN-P-13', 'Achat au taux de 13 %, déductible', '{}'::jsonb, null, 'percent', 13, 'purchase', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 9 — droit à déduction ; art. 7 et tableau « B bis » et loi n° 2017-66 pour le taux.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'code-tva', null, null, null, null),
  ('TN', 'TN-P-19', 'Achat au taux de 19 %, déductible', '{}'::jsonb, 'Achat de biens ou de services au taux normal, engagé pour les besoins de l''exploitation.', 'percent', 19, 'purchase', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 9 — droit à déduction de la taxe ayant grevé les biens et services nécessaires à l''exploitation, sous réserve des exclusions de l''art. 10 ; art. 7 et loi n° 2017-66 pour le taux.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'code-tva', null, null, null, null),
  ('TN', 'TN-P-7', 'Achat au taux de 7 %, déductible', '{}'::jsonb, null, 'percent', 7, 'purchase', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 9 — droit à déduction ; art. 7 et tableau « B » et loi n° 2017-66 pour le taux.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'code-tva', null, null, null, null),
  ('TN', 'TN-P-ND-19', 'Achat au taux de 19 %, non déductible — voiture de tourisme', '{}'::jsonb, 'Achat, location ou entretien d''une voiture de tourisme servant au transport de personnes autre que celles objet de l''exploitation.', 'percent', 19, 'purchase', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 10, 1° — sont exclus du droit à déduction les voitures de tourisme servant au transport de personnes autres que celles objet de l''exploitation, ainsi que la location et les dépenses assurant leur fonctionnement.', null, null, 140, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'code-tva', null, null, null, null),
  ('TN', 'TN-P-NR-19', 'Prestation d''un non-résident sans établissement en Tunisie, retenue à la source au taux de 19 %', '{}'::jsonb, 'Service rendu par une personne qui n''a pas d''établissement en Tunisie — formation, étude, assistance technique, redevance, location de biens meubles ou immeubles. La taxe est retenue par le client tunisien, libératoire pour le prestataire étranger, puis récupérable par le client selon les conditions de droit commun.', 'percent', 19, 'purchase', 'foreign_services_received', date '2018-01-01', null, 'Code de la TVA, art. 19 — la réalisation d''opérations soumises à la taxe par une personne qui n''a pas d''établissement en Tunisie donne lieu à une retenue de la totalité de la taxe par la partie tunisienne cocontractante, retenue libératoire pour la personne non établie ; le prestataire peut opter pour le dépôt d''une déclaration avec déduction de la taxe qui a grevé les biens et services nécessaires à la prestation. La taxe ainsi retenue est récupérable par l''entreprise tunisienne assujettie selon les conditions de droit commun de l''art. 9. Cette recherche n''a pas pu vérifier si le reversement de la retenue se fait sur la déclaration mensuelle de TVA elle-même ou sur un imprimé séparé : la case TVANR ci-dessous est donc la transcription de ce pack et non la case numérotée d''un formulaire officiel lu par cette recherche.', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'jurisite-tva', null, null, null, null),
  ('TN', 'TN-S-13', 'Vente au taux de 13 %', '{}'::jsonb, 'Opération taxable au taux intermédiaire — tableau « B bis » annexé au Code, par exemple les prestations des architectes, ingénieurs-conseils, avocats et experts, l''hôtellerie et le matériel informatique.', 'percent', 13, 'sale', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 7 et tableau « B bis » annexé, point II — notamment les honoraires des architectes, ingénieurs-conseils, topographes, avocats, notaires, experts-comptables et experts ; loi n° 2017-66 du 18 décembre 2017, art. 43 — relèvement du taux de 12 % à 13 % à compter du 1er janvier 2018.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'loi-2017-66', null, null, null, null),
  ('TN', 'TN-S-19', 'Vente au taux de 19 %', '{}'::jsonb, 'Opération taxable au taux normal.', 'percent', 19, 'sale', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 7 — taux de 19 %, applicable aux opérations qui ne sont pas soumises à un autre taux par un tableau annexé au Code ; loi de finances pour 2018 (loi n° 2017-66 du 18 décembre 2017), art. 43 — relèvement du taux de 18 % à 19 % à compter du 1er janvier 2018.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'loi-2017-66', null, null, null, null),
  ('TN', 'TN-S-7', 'Vente au taux de 7 %', '{}'::jsonb, 'Opération taxable au taux réduit — tableau « B » annexé au Code, par exemple les produits pharmaceutiques, le savon ordinaire et les conserves de tomate et de sardine.', 'percent', 7, 'sale', 'domestic', date '2018-01-01', null, 'Code de la TVA, art. 7 et tableau « B » annexé — produits pharmaceutiques, conserves de tomate et de sardines, savon ordinaire, entre autres ; loi n° 2017-66 du 18 décembre 2017, art. 43 — relèvement du taux de 6 % à 7 % à compter du 1er janvier 2018.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'loi-2017-66', null, null, null, null),
  ('TN', 'TN-S-EXO', 'Opération exonérée — tableau « A »', '{}'::jsonb, 'Opération exonérée de la taxe sur la valeur ajoutée, par exemple les produits de première nécessité, les opérations bancaires et d''assurance ou l''enseignement.', 'percent', 0, 'sale', 'exempt', date '2018-01-01', null, 'Code de la TVA, tableau « A » annexé à l''article premier — liste des opérations exonérées, notamment les produits alimentaires de première nécessité (point 1), les opérations bancaires et les intérêts de prêts (point 39) et l''enseignement (point 9).', null, null, 50, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'jurisite-tva', null, null, null, null),
  ('TN', 'TN-S-EXP', 'Exportation', '{}'::jsonb, 'Vente de biens exportés ou de services utilisés ou exploités hors de Tunisie, taxe non applicable, opération ouvrant droit à déduction.', 'percent', 0, 'sale', 'export', date '2018-01-01', null, 'Code de la TVA, art. 9 — les recettes provenant de l''exportation de produits ou de services passibles de la taxe concourent à la formation du droit à déduction au même titre que les opérations taxées ; art. 15 — le crédit de taxe provenant de l''exportation de marchandises ou de services utilisés ou exploités hors de Tunisie est restituable. Le Code ne classe pas l''exportation dans le tableau « A » des exonérations : c''est une opération hors du champ de la taxe due à la destination, qui garde le droit à déduction — d''où `treatment: export` et non `exempt`.', null, null, 40, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'code-tva', null, null, null, null)
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
    ('TN-P-13', 'invoice', 'tax', 100, '4366', 'DED', array['DED']::text[], 100, 'TN-TVA', 10),
    ('TN-P-13', 'credit_note', 'tax', 100, '4366', 'DED', array['DED']::text[], -100, 'TN-TVA', 10),
    ('TN-P-19', 'invoice', 'tax', 100, '4366', 'DED', array['DED']::text[], 100, 'TN-TVA', 10),
    ('TN-P-19', 'credit_note', 'tax', 100, '4366', 'DED', array['DED']::text[], -100, 'TN-TVA', 10),
    ('TN-P-7', 'invoice', 'tax', 100, '4366', 'DED', array['DED']::text[], 100, 'TN-TVA', 10),
    ('TN-P-7', 'credit_note', 'tax', 100, '4366', 'DED', array['DED']::text[], -100, 'TN-TVA', 10),
    ('TN-P-ND-19', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TN-P-ND-19', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('TN-P-ND-19', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TN-P-ND-19', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('TN-P-NR-19', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TN-P-NR-19', 'invoice', 'tax', 100, '4366', 'TVANR', array['TVANR']::text[], 100, 'TN-TVA', 20),
    ('TN-P-NR-19', 'invoice', 'tax', -100, '4362', 'TVANR', array['TVANR']::text[], -100, 'TN-TVA', 30),
    ('TN-P-NR-19', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TN-P-NR-19', 'credit_note', 'tax', 100, '4366', 'TVANR', array['TVANR']::text[], -100, 'TN-TVA', 20),
    ('TN-P-NR-19', 'credit_note', 'tax', -100, '4362', 'TVANR', array['TVANR']::text[], 100, 'TN-TVA', 30),
    ('TN-S-13', 'invoice', 'base', 100, null, 'CA13', array['CA13']::text[], 100, 'TN-TVA', 10),
    ('TN-S-13', 'invoice', 'tax', 100, '4361', 'TVA13', array['TVA13']::text[], 100, 'TN-TVA', 20),
    ('TN-S-13', 'credit_note', 'base', 100, null, 'CA13', array['CA13']::text[], -100, 'TN-TVA', 10),
    ('TN-S-13', 'credit_note', 'tax', 100, '4361', 'TVA13', array['TVA13']::text[], -100, 'TN-TVA', 20),
    ('TN-S-19', 'invoice', 'base', 100, null, 'CA19', array['CA19']::text[], 100, 'TN-TVA', 10),
    ('TN-S-19', 'invoice', 'tax', 100, '4361', 'TVA19', array['TVA19']::text[], 100, 'TN-TVA', 20),
    ('TN-S-19', 'credit_note', 'base', 100, null, 'CA19', array['CA19']::text[], -100, 'TN-TVA', 10),
    ('TN-S-19', 'credit_note', 'tax', 100, '4361', 'TVA19', array['TVA19']::text[], -100, 'TN-TVA', 20),
    ('TN-S-7', 'invoice', 'base', 100, null, 'CA7', array['CA7']::text[], 100, 'TN-TVA', 10),
    ('TN-S-7', 'invoice', 'tax', 100, '4361', 'TVA7', array['TVA7']::text[], 100, 'TN-TVA', 20),
    ('TN-S-7', 'credit_note', 'base', 100, null, 'CA7', array['CA7']::text[], -100, 'TN-TVA', 10),
    ('TN-S-7', 'credit_note', 'tax', 100, '4361', 'TVA7', array['TVA7']::text[], -100, 'TN-TVA', 20),
    ('TN-S-EXO', 'invoice', 'base', 100, null, 'EXO', array['EXO']::text[], 100, 'TN-TVA', 10),
    ('TN-S-EXO', 'credit_note', 'base', 100, null, 'EXO', array['EXO']::text[], -100, 'TN-TVA', 10),
    ('TN-S-EXP', 'invoice', 'base', 100, null, 'EXP', array['EXP']::text[], 100, 'TN-TVA', 10),
    ('TN-S-EXP', 'credit_note', 'base', 100, null, 'EXP', array['EXP']::text[], -100, 'TN-TVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'TN' and t.code = v.tax_code
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
  ('TN', 'TN-TVA', 'Déclaration mensuelle — volet taxe sur la valeur ajoutée', array['month']::declaration_period[], 'month'::declaration_period, date '2018-01-01', null, 'Code de la TVA, art. 18-IV — les assujettis à la TVA, autres que ceux soumis au régime forfaitaire, sont tenus de souscrire et de déposer, au titre de chaque mois, une déclaration du modèle fourni par l''administration ; la déclaration est due même en l''absence d''opération imposable. Le modèle de l''imprimé n''a pas pu être lu en texte par cette recherche — c''est un formulaire du portail de télédéclaration de la DGI et non un texte publié en clair — et la déclaration mensuelle unique couvre aussi d''autres impôts que la TVA (retenues à la source, taxe sur les établissements à caractère industriel, commercial ou professionnel, FOPROLOS…) que ce pack ne porte pas : les cases ci-dessous sont donc la construction propre de ce pack pour la seule TVA, dans le même esprit que packs/sn/, et non la numérotation d''un formulaire officiel lu par cette recherche.', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Code de la TVA, art. 18-IV — la déclaration est déposée dans les quinze premiers jours de chaque mois pour les personnes physiques, et dans les vingt-huit premiers jours de chaque mois pour les personnes morales, pour les opérations du mois précédent.', 'code-tva', null)
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
  ('TN', 'TN-TVA', 'CA19', 'base', 'Chiffre d''affaires imposable au taux de 19 %', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 7 et art. 18-IV — montant des opérations imposables déclarées.', 'code-tva'),
  ('TN', 'TN-TVA', 'CA13', 'base', 'Chiffre d''affaires imposable au taux de 13 %', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 7, tableau « B bis » et art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'CA7', 'base', 'Chiffre d''affaires imposable au taux de 7 %', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 7, tableau « B » et art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'EXP', 'base', 'Chiffre d''affaires à l''exportation et opérations assimilées', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 9 et art. 15.', 'code-tva'),
  ('TN', 'TN-TVA', 'EXO', 'base', 'Chiffre d''affaires exonéré — tableau « A »', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, tableau « A » annexé à l''article premier.', 'jurisite-tva'),
  ('TN', 'TN-TVA', 'CAT', 'total', 'Chiffre d''affaires total', '{}'::jsonb, 60, null, array['CA19', 'CA13', 'CA7', 'EXP', 'EXO']::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'TVA19', 'tax', 'Taxe due au taux de 19 %', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 7 et art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'TVA13', 'tax', 'Taxe due au taux de 13 %', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 7 et art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'TVA7', 'tax', 'Taxe due au taux de 7 %', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 7 et art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'TVANR', 'tax', 'Taxe retenue à la source sur les prestations de non-résidents (art. 19)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 19 — retenue de la totalité de la taxe due par une personne non établie en Tunisie, opérée par la partie tunisienne cocontractante. Voir la note de TN-P-NR-19 dans taxes.json sur l''incertitude quant au formulaire de reversement.', 'jurisite-tva'),
  ('TN', 'TN-TVA', 'TVAC', 'total', 'Total de la taxe collectée et retenue', '{}'::jsonb, 110, null, array['TVA19', 'TVA13', 'TVA7', 'TVANR']::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'DED', 'tax', 'Taxe déductible sur biens, services et immobilisations', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Code de la TVA, art. 9 et art. 10 — droit à déduction et ses exclusions ; art. 18-IV.', 'code-tva'),
  ('TN', 'TN-TVA', 'NET', 'total', 'Taxe due à payer', '{}'::jsonb, 130, null, array['TVAC']::text[], array['DED']::text[], null, null, true, false, null, 'Code de la TVA, art. 18-IV — la déclaration porte le montant de la taxe due après déduction.', 'code-tva'),
  ('TN', 'TN-TVA', 'CRED', 'total', 'Crédit de taxe à reporter ou à restituer', '{}'::jsonb, 140, null, array['DED']::text[], array['TVAC']::text[], null, null, true, false, null, 'Code de la TVA, art. 15 — la fraction de taxe déductible qui ne peut être imputée est reportée sur les déclarations suivantes ou restituée sur demande, dans les conditions de l''article.', 'code-tva')
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
  ('TN-SCE-BS', 'TN', 'default', 'Bilan', 'balance_sheet', 'SCE', date '1997-01-01', null, 'Loi n° 96-112 du 30 décembre 1996 relative au système comptable des entreprises, art. 15 à 19 — les états financiers comprennent notamment un bilan ; norme comptable générale NC 01, homologuée par le décret n° 96-2459 du 30 décembre 1996, chapitre consacré à la présentation des états financiers. Cette recherche n''a pas pu extraire en texte exploitable le modèle chiffré officiel du bilan de la norme NC 01 (document PDF non extractible) : les postes ci-dessous regroupent donc les comptes de ce pack par classe et sous-classe, dans l''esprit de la norme plutôt que sur la base de son modèle imprimé ligne à ligne, et un comptable tunisien devrait comparer cette présentation à celle de la norme avant tout usage réel.', 'nc01'),
  ('TN-SCE-IS', 'TN', 'default', 'État de résultat', 'income_statement', 'SCE', date '1997-01-01', null, 'Loi n° 96-112 du 30 décembre 1996, art. 15 à 19 ; norme comptable générale NC 01. Comme pour le bilan, cette recherche n''a pas pu extraire en texte exploitable le modèle chiffré officiel de l''état de résultat par nature de la norme NC 01 : les postes ci-dessous regroupent les comptes de charges et de produits de ce pack par classe, propre à ce pack.', 'nc01')
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
  ('TN-SCE-BS', 'BS-10', null, 'Immobilisations incorporelles', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des comptes 20x (immobilisations incorporelles) et de leur amortissement 281, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-20', null, 'Immobilisations corporelles', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des comptes 21x (immobilisations corporelles), 23x (immobilisations en cours) et de leur amortissement 282, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-30', null, 'Immobilisations financières', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des comptes 26 et 27 (immobilisations financières) et de leurs provisions 292 et 296, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-40', null, 'Stocks', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement de la classe 3 (stocks et en-cours), avec leur provision pour dépréciation 39, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-50', null, 'Clients et comptes rattachés', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des comptes 411 à 418 (clients et comptes rattachés, solde débiteur), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-51', null, 'Fournisseurs débiteurs, avances et acomptes versés', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 409, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-60', null, 'Autres créances', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des avances au personnel (425), de la TVA déductible et du crédit de TVA (4366, 4367, 4369) et des charges constatées d''avance (486), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-70', null, 'Disponibilités', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des comptes 53, 54 (banques et caisse), 58 (virements internes) et 59 (provisions pour dépréciation des comptes financiers), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-ACTIF', null, 'TOTAL ACTIF', '{}'::jsonb, 90, 1, true, array['BS-10', 'BS-20', 'BS-30', 'BS-40', 'BS-50', 'BS-51', 'BS-60', 'BS-70']::text[], '{}'::text[], null, 'NC 01.', 'nc01'),
  ('TN-SCE-BS', 'BS-100', null, 'Capital', '{}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 10 (capital), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-110', null, 'Réserves et primes liées au capital', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 11 (réserves et primes), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-120', null, 'Résultats reportés', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 12 (résultats reportés), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-130', null, 'Résultat de l''exercice', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 13 (résultat de l''exercice, en instance d''affectation), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-140', null, 'Subventions d''investissement', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 14, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-150', null, 'Provisions pour risques et charges', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 15, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-160', null, 'Emprunts et dettes assimilées', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 16, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-170', null, 'Fournisseurs et comptes rattachés', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — comptes 401 à 408 (fournisseurs, solde créditeur), propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-175', null, 'Clients créditeurs, avances et acomptes reçus', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 419, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-180', null, 'Personnel', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — comptes 421 et 428, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-190', null, 'État et organismes sociaux', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — regroupement des comptes 431, 432, 4361, 4362, 4368, 437 et 438, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-195', null, 'Comptes d''attente et de régularisation', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — comptes 471 et 487, propre à ce pack.', 'nc01'),
  ('TN-SCE-BS', 'BS-PASSIF', null, 'TOTAL PASSIF', '{}'::jsonb, 220, 1, true, array['BS-100', 'BS-110', 'BS-120', 'BS-130', 'BS-140', 'BS-150', 'BS-160', 'BS-170', 'BS-175', 'BS-180', 'BS-190', 'BS-195']::text[], '{}'::text[], null, 'NC 01.', 'nc01'),
  ('TN-SCE-IS', 'IS-10', null, 'Achats', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 60, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-20', null, 'Services extérieurs', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — comptes 61 et 62, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-30', null, 'Impôts, taxes et versements assimilés', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 63, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-40', null, 'Charges de personnel', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 64, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-50', null, 'Charges diverses ordinaires', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 65, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-60', null, 'Charges financières', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 66, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-70', null, 'Dotations aux amortissements et aux provisions', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 68, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-80', null, 'Impôt sur les bénéfices', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 69, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-CHARGES', null, 'TOTAL DES CHARGES', '{}'::jsonb, 90, 1, true, array['IS-10', 'IS-20', 'IS-30', 'IS-40', 'IS-50', 'IS-60', 'IS-70', 'IS-80']::text[], '{}'::text[], null, 'NC 01.', 'nc01'),
  ('TN-SCE-IS', 'IS-90', null, 'Ventes', '{}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 70, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-100', null, 'Produits divers ordinaires', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 75, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-110', null, 'Produits financiers', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 76, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-120', null, 'Reprises sur amortissements et provisions', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'NC 01 — compte 78, propre à ce pack.', 'nc01'),
  ('TN-SCE-IS', 'IS-PRODUITS', null, 'TOTAL DES PRODUITS', '{}'::jsonb, 140, 1, true, array['IS-90', 'IS-100', 'IS-110', 'IS-120']::text[], '{}'::text[], null, 'NC 01.', 'nc01'),
  ('TN-SCE-IS', 'IS-RESULTAT', null, 'RÉSULTAT DE L''EXERCICE', '{}'::jsonb, 150, 1, true, array['IS-PRODUITS']::text[], array['IS-CHARGES']::text[], null, 'NC 01.', 'nc01')
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
    ('TN-SCE-BS', 'BS-10', 10, 'code_range', '20', '20', null, 'any'),
    ('TN-SCE-BS', 'BS-10', 20, 'code_range', '281', '281', null, 'any'),
    ('TN-SCE-BS', 'BS-20', 10, 'code_range', '21', '21', null, 'any'),
    ('TN-SCE-BS', 'BS-20', 20, 'code_range', '23', '23', null, 'any'),
    ('TN-SCE-BS', 'BS-20', 30, 'code_range', '282', '282', null, 'any'),
    ('TN-SCE-BS', 'BS-30', 10, 'code_range', '26', '27', null, 'any'),
    ('TN-SCE-BS', 'BS-30', 20, 'code_range', '292', '292', null, 'any'),
    ('TN-SCE-BS', 'BS-30', 30, 'code_range', '296', '296', null, 'any'),
    ('TN-SCE-BS', 'BS-40', 10, 'code_range', '3', '3', null, 'any'),
    ('TN-SCE-BS', 'BS-50', 10, 'code_range', '411', '418', null, 'any'),
    ('TN-SCE-BS', 'BS-51', 10, 'code_range', '409', '409', null, 'any'),
    ('TN-SCE-BS', 'BS-60', 10, 'code_range', '425', '425', null, 'any'),
    ('TN-SCE-BS', 'BS-60', 20, 'code_range', '4366', '4367', null, 'any'),
    ('TN-SCE-BS', 'BS-60', 30, 'code_range', '4369', '4369', null, 'any'),
    ('TN-SCE-BS', 'BS-60', 40, 'code_range', '486', '486', null, 'any'),
    ('TN-SCE-BS', 'BS-70', 10, 'code_range', '53', '54', null, 'any'),
    ('TN-SCE-BS', 'BS-70', 20, 'code_range', '58', '59', null, 'any'),
    ('TN-SCE-BS', 'BS-100', 10, 'code_range', '10', '10', null, 'any'),
    ('TN-SCE-BS', 'BS-110', 10, 'code_range', '11', '11', null, 'any'),
    ('TN-SCE-BS', 'BS-120', 10, 'code_range', '12', '12', null, 'any'),
    ('TN-SCE-BS', 'BS-130', 10, 'code_range', '13', '13', null, 'any'),
    ('TN-SCE-BS', 'BS-140', 10, 'code_range', '14', '14', null, 'any'),
    ('TN-SCE-BS', 'BS-150', 10, 'code_range', '15', '15', null, 'any'),
    ('TN-SCE-BS', 'BS-160', 10, 'code_range', '16', '16', null, 'any'),
    ('TN-SCE-BS', 'BS-170', 10, 'code_range', '401', '408', null, 'any'),
    ('TN-SCE-BS', 'BS-175', 10, 'code_range', '419', '419', null, 'any'),
    ('TN-SCE-BS', 'BS-180', 10, 'code_range', '421', '421', null, 'any'),
    ('TN-SCE-BS', 'BS-180', 20, 'code_range', '428', '428', null, 'any'),
    ('TN-SCE-BS', 'BS-190', 10, 'code_range', '431', '432', null, 'any'),
    ('TN-SCE-BS', 'BS-190', 20, 'code_range', '4361', '4362', null, 'any'),
    ('TN-SCE-BS', 'BS-190', 30, 'code_range', '4368', '4368', null, 'any'),
    ('TN-SCE-BS', 'BS-190', 40, 'code_range', '437', '438', null, 'any'),
    ('TN-SCE-BS', 'BS-195', 10, 'code_range', '471', '471', null, 'any'),
    ('TN-SCE-BS', 'BS-195', 20, 'code_range', '487', '487', null, 'any'),
    ('TN-SCE-IS', 'IS-10', 10, 'code_range', '60', '60', null, 'any'),
    ('TN-SCE-IS', 'IS-20', 10, 'code_range', '61', '62', null, 'any'),
    ('TN-SCE-IS', 'IS-30', 10, 'code_range', '63', '63', null, 'any'),
    ('TN-SCE-IS', 'IS-40', 10, 'code_range', '64', '64', null, 'any'),
    ('TN-SCE-IS', 'IS-50', 10, 'code_range', '65', '65', null, 'any'),
    ('TN-SCE-IS', 'IS-60', 10, 'code_range', '66', '66', null, 'any'),
    ('TN-SCE-IS', 'IS-70', 10, 'code_range', '68', '68', null, 'any'),
    ('TN-SCE-IS', 'IS-80', 10, 'code_range', '69', '69', null, 'any'),
    ('TN-SCE-IS', 'IS-90', 10, 'code_range', '70', '70', null, 'any'),
    ('TN-SCE-IS', 'IS-100', 10, 'code_range', '75', '75', null, 'any'),
    ('TN-SCE-IS', 'IS-110', 10, 'code_range', '76', '76', null, 'any'),
    ('TN-SCE-IS', 'IS-120', 10, 'code_range', '78', '78', null, 'any')
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
  ('TN', 'Tunisie', '{}'::jsonb, array['fr']::text[], 'TND', '411', '401', '471', '658', '120', '701', '601', '532', '54', 'VT', 'AC', 'OD', 'fr', 'result_accounts', '131', '139', null, 'AN', 'half_up', default, '766', '666', null, null, null, null, '4368', '4369', null, 'month'::declaration_period)
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
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Code de la TVA, art. 18 — les assujettis sont tenus de délivrer une facture pour chacune des opérations qu''ils réalisent ; cette recherche n''a pas trouvé de texte imposant explicitement une numérotation continue ou sans rupture des factures (à la différence de la facture électronique du décret n° 2016-1066, dont la structure XML impose un numéro unique et un chaînage). `numbering` est donc laissé à `sequential`, la forme la plus prudente, plutôt que `gapless_per_year` : un pack qui affirmerait l''absence de rupture sans l''avoir lu dans un texte irait au-delà de ce que cette recherche a vérifié.',
  numbering_source_key          = 'code-tva',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Code de la TVA, art. 5 — le fait générateur est, pour les ventes de biens, la livraison de la marchandise, et pour les prestations de services, la réalisation du service ou l''encaissement du prix, le premier de ces faits l''emportant. `earliest_of_delivery_or_payment` est le plus proche des cinq valeurs du vocabulaire fermé pour cette double règle, mais il la simplifie : le Code ne fait pas de l''encaissement un fait générateur pour une vente de biens, seulement pour une prestation de services, ce que le mot unique ne distingue pas. Régime particulier non repris ici : les entreprises de travaux publics et de bâtiment travaillant pour l''État, les collectivités publiques locales et les établissements publics acquittent la taxe sur les encaissements (art. 5), un régime de trésorerie qu''aucune taxe de ce pack ne porte en `cash_basis` faute d''avoir vérifié ses comptes de transition.',
  tax_point_source_key          = 'jurisite-tva',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'La facture électronique « El Fatoora » existe depuis la loi de finances pour 2016 (loi n° 2015-53 du 25 décembre 2015), art. 22, qui assimile la facture électronique à la facture papier et désigne Tunisie TradeNet (TTN) comme opérateur technique du système ; le décret gouvernemental n° 2016-1066 du 15 août 2016 en fixe les conditions et modalités d''émission et d''archivage. L''obligation, à la date de ce pack, ne couvre pas toutes les entreprises : elle porte sur les opérations avec les marchés publics (B2G) et sur les grandes entreprises rattachées à la Direction des Grandes Entreprises (DGE), sans que cette recherche ait pu ouvrir un texte daté et exhaustif fixant le périmètre exact et son calendrier d''extension — `obligation` reste donc vide plutôt que `mandatory` pour tout le pack, à vérifier auprès d''un professionnel local avant de fier une entreprise donnée sur ce point. `profile`, `mandatory_from`, `party_scheme` et `vat_scheme` restent vides pour la même raison que packs/sa/, packs/mx/ et packs/vn/ : TTN est un système de validation (« clearance »), la facture est un XML propre au standard tunisien (TEIF) transmis à TTN puis à l''administration, et aucune brique de packages/formats/ n''écrit ce XML, ne le signe, ni ne dialogue avec TTN — un document émis par Ekwo n''est donc pas une facture électronique El Fatoora. La déclaration mensuelle de TVA, elle, est obligatoirement télé-déclarée sur le portail de la DGI (Code de la TVA, art. 18-V).',
  einvoice_source_key           = 'el-fatoora',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'TN';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('TN', 'reverse_charge', 'reverse_charge', 'Taxe sur la valeur ajoutée retenue à la source par le client tunisien, en application de l''article 19 du Code de la TVA — prestataire non établi en Tunisie.', '{}'::jsonb, 10, date '1970-01-01', null, 'Code de la TVA, art. 19 — la réalisation d''opérations imposables par une personne qui n''a pas d''établissement en Tunisie donne lieu à une retenue à la source de la totalité de la taxe par la partie tunisienne, retenue libératoire pour la partie étrangère.'),
  ('TN', 'exempt', 'exempt', 'Opération exonérée de la taxe sur la valeur ajoutée — tableau « A » annexé au Code de la TVA.', '{}'::jsonb, 20, date '1970-01-01', null, 'Code de la TVA, tableau « A » annexé à l''article premier — liste des opérations exonérées.'),
  ('TN', 'export', 'export', 'Exportation — taxe sur la valeur ajoutée non applicable, opération ouvrant droit à déduction.', '{}'::jsonb, 30, date '1970-01-01', null, 'Code de la TVA, art. 9 — les recettes provenant de l''exportation de produits ou services passibles de la taxe ouvrent droit à déduction ; art. 15 — restitution du crédit de taxe provenant de l''exportation.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
