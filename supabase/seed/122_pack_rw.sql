-- Ekwo OS — Rwanda: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/rw at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build rw`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Law N° 049/2023 of 05/09/2023 establishing value added tax, repealing Law N° 37/2012 of 09/11/2012 (Official Gazette of the Republic of Rwanda, n° Special of 14/09/2023)
--     https://www.rra.gov.rw/fileadmin/user_upload/LAW_ESTABLISHING_VALUE_ADDED_TAX.pdf
--   Law N° 020/2023 of 31/03/2023 on tax procedures, articles on the electronic invoicing system and its administrative fine (Official Gazette of the Republic of Rwanda, n° Special ter of 31/03/2023)
--     https://www.rra.gov.rw/fileadmin/user_upload/NEW_TAX_PROCEDURES_LAW_2023.pdf
--   Law N° 007/2021 of 05/02/2021 governing companies, articles 121 to 133 (accounting records, annual accounts, audit) (Official Gazette of the Republic of Rwanda, n° 04 ter of 08/02/2021)
--     https://www.minicom.gov.rw/fileadmin/user_upload/Minicom/Publications/Laws/Companies/10.8.2.1.Companies-Law-No-007-of-2021.pdf
--   RRA Tax Handbook, 2nd edition, 2025 — Value Added Tax (VAT) chapter (Rwanda Revenue Authority)
--     https://www.rra.gov.rw/fileadmin/Folder_for_2025/RRA_Tax_Handbook_2025_Final.pdf
--   Monthly VAT Declaration Form, form RRA-VAT-DF1 (Rwanda Revenue Authority, published on the Rwanda Development Board business procedures portal)
--     https://businessprocedures.rdb.rw/media/RRA-VAT-DF1-E08.pdf
--   e-Tax — where the VAT declaration is filed and paid (Rwanda Revenue Authority)
--     https://etax.rra.gov.rw/
--   The Electronic Billing Machine and the Electronic Invoicing System (Rwanda Revenue Authority)
--     https://www.rra.gov.rw/en/about-ebm
--   Rwanda — Member Country, on ICPAR's adoption of the IFRS Accounting Standards and the IFRS for SMEs Accounting Standard under Law N° 11/2008 of 06/05/2008 establishing the Institute of Certified Public Accountants of Rwanda (International Federation of Accountants (IFAC))
--     https://www.ifac.org/about-ifac/membership/profile/rwanda
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('RW', 'Rwanda', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, '26423bb20017cd6387f3a652d0e84eb41e34e7bc08d043ac7a7ea90cf9a4e367', '[{"key":"vat-law","title":"Law N° 049/2023 of 05/09/2023 establishing value added tax, repealing Law N° 37/2012 of 09/11/2012","publisher":"Official Gazette of the Republic of Rwanda, n° Special of 14/09/2023","url":"https://www.rra.gov.rw/fileadmin/user_upload/LAW_ESTABLISHING_VALUE_ADDED_TAX.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"tax-procedures-law","title":"Law N° 020/2023 of 31/03/2023 on tax procedures, articles on the electronic invoicing system and its administrative fine","publisher":"Official Gazette of the Republic of Rwanda, n° Special ter of 31/03/2023","url":"https://www.rra.gov.rw/fileadmin/user_upload/NEW_TAX_PROCEDURES_LAW_2023.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"companies-law","title":"Law N° 007/2021 of 05/02/2021 governing companies, articles 121 to 133 (accounting records, annual accounts, audit)","publisher":"Official Gazette of the Republic of Rwanda, n° 04 ter of 08/02/2021","url":"https://www.minicom.gov.rw/fileadmin/user_upload/Minicom/Publications/Laws/Companies/10.8.2.1.Companies-Law-No-007-of-2021.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"rra-tax-handbook","title":"RRA Tax Handbook, 2nd edition, 2025 — Value Added Tax (VAT) chapter","publisher":"Rwanda Revenue Authority","url":"https://www.rra.gov.rw/fileadmin/Folder_for_2025/RRA_Tax_Handbook_2025_Final.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"vat-df1-form","title":"Monthly VAT Declaration Form, form RRA-VAT-DF1","publisher":"Rwanda Revenue Authority, published on the Rwanda Development Board business procedures portal","url":"https://businessprocedures.rdb.rw/media/RRA-VAT-DF1-E08.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"etax","title":"e-Tax — where the VAT declaration is filed and paid","publisher":"Rwanda Revenue Authority","url":"https://etax.rra.gov.rw/","consulted_on":"2026-09-26","kind":"portal"},{"key":"ebm-portal","title":"The Electronic Billing Machine and the Electronic Invoicing System","publisher":"Rwanda Revenue Authority","url":"https://www.rra.gov.rw/en/about-ebm","consulted_on":"2026-09-26","kind":"portal"},{"key":"ifac-rwanda","title":"Rwanda — Member Country, on ICPAR''s adoption of the IFRS Accounting Standards and the IFRS for SMEs Accounting Standard under Law N° 11/2008 of 06/05/2008 establishing the Institute of Certified Public Accountants of Rwanda","publisher":"International Federation of Accountants (IFAC)","url":"https://www.ifac.org/about-ifac/membership/profile/rwanda","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('RW', 'default', 'Rwanda reference chart of accounts', '{"fr":"Plan comptable de référence du Rwanda"}'::jsonb, true, 'companies', array['RW-ICPAR-IS', 'RW-ICPAR-SFP']::text[], null, 'There is no legal chart of accounts in Rwanda. Law N° 007/2021 of 05/02/2021 governing companies, article 121 requires every company to keep accounting records; article 122 requires annual accounts comprising a balance sheet, a profit and loss account, cash flow statements, equity and a statement of changes; article 123 requires the balance sheet of a company to comply with international standards, with explanatory notes on significant policies, trends, risks and uncertainties. The Institute of Certified Public Accountants of Rwanda (ICPAR), the standard-setting body Law N° 11/2008 of 06/05/2008 establishes, has adopted the IFRS Accounting Standards for an entity with public accountability and the IFRS for SMEs Accounting Standard for other entities. This chart is original: four digits, blocked so that each range reaches one line of the IFRS for SMEs statements below, carrying the accounts a Rwandan company actually keeps — VAT input and output tax, import VAT owed to the Rwanda Revenue Authority (RRA) at the border, Rwanda Social Security Board (RSSB) and medical insurance contributions, Pay As You Earn (PAYE), withholding tax and amounts due to directors.', 'companies-law')
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
  ('RW', 'default', '1000', 'Petty cash', '{"fr":"Caisse"}'::jsonb, 'asset_cash', false, null, 10),
  ('RW', 'default', '1010', 'Current account — RWF', '{"fr":"Compte courant — RWF"}'::jsonb, 'asset_cash', false, null, 20),
  ('RW', 'default', '1020', 'Fixed deposits placed for three months or less', '{"fr":"Dépôts à terme de trois mois ou moins"}'::jsonb, 'asset_cash', false, null, 30),
  ('RW', 'default', '1030', 'Foreign currency account', '{"fr":"Compte en devises étrangères"}'::jsonb, 'asset_cash', false, null, 40),
  ('RW', 'default', '1040', 'Cash in transit — mobile money and card settlements', '{"fr":"Fonds en transit — règlements mobile money et carte"}'::jsonb, 'asset_cash', false, null, 50),
  ('RW', 'default', '1100', 'Trade receivables', '{"fr":"Créances clients"}'::jsonb, 'asset_receivable', true, null, 60),
  ('RW', 'default', '1110', 'Trade receivables — allowance for impairment', '{"fr":"Créances clients — provision pour dépréciation"}'::jsonb, 'asset_current', false, null, 70),
  ('RW', 'default', '1120', 'Other receivables', '{"fr":"Autres créances"}'::jsonb, 'asset_current', false, null, 80),
  ('RW', 'default', '1130', 'Amounts due from related companies', '{"fr":"Sommes dues par des sociétés liées"}'::jsonb, 'asset_current', false, null, 90),
  ('RW', 'default', '1140', 'Deposits paid', '{"fr":"Cautionnements versés"}'::jsonb, 'asset_current', false, null, 100),
  ('RW', 'default', '1150', 'VAT input tax', '{"fr":"TVA déductible"}'::jsonb, 'asset_current', false, null, 110),
  ('RW', 'default', '1155', 'VAT refundable by RRA — net of a filed return', '{"fr":"TVA à restituer par la RRA — solde d''une déclaration déposée"}'::jsonb, 'asset_current', true, null, 120),
  ('RW', 'default', '1160', 'Advances to staff', '{"fr":"Avances au personnel"}'::jsonb, 'asset_current', false, null, 130),
  ('RW', 'default', '1200', 'Inventories — goods for resale', '{"fr":"Stocks — marchandises destinées à la revente"}'::jsonb, 'asset_current', false, null, 140),
  ('RW', 'default', '1210', 'Inventories — raw materials', '{"fr":"Stocks — matières premières"}'::jsonb, 'asset_current', false, null, 150),
  ('RW', 'default', '1220', 'Inventories — work in progress', '{"fr":"Stocks — en-cours de production"}'::jsonb, 'asset_current', false, null, 160),
  ('RW', 'default', '1230', 'Inventories — finished goods', '{"fr":"Stocks — produits finis"}'::jsonb, 'asset_current', false, null, 170),
  ('RW', 'default', '1300', 'Short-term investments', '{"fr":"Placements à court terme"}'::jsonb, 'asset_current', false, null, 180),
  ('RW', 'default', '1350', 'Current tax recoverable', '{"fr":"Impôt courant à recouvrer"}'::jsonb, 'asset_current', false, null, 190),
  ('RW', 'default', '1400', 'Prepayments', '{"fr":"Charges constatées d''avance"}'::jsonb, 'asset_prepayments', false, null, 200),
  ('RW', 'default', '1410', 'Accrued income', '{"fr":"Produits à recevoir"}'::jsonb, 'asset_prepayments', false, null, 210),
  ('RW', 'default', '1600', 'Land and buildings — cost', '{"fr":"Terrains et bâtiments — coût"}'::jsonb, 'asset_fixed', false, null, 220),
  ('RW', 'default', '1601', 'Land and buildings — accumulated depreciation', '{"fr":"Terrains et bâtiments — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 230),
  ('RW', 'default', '1610', 'Leasehold improvements — cost', '{"fr":"Aménagements de locaux loués — coût"}'::jsonb, 'asset_fixed', false, null, 240),
  ('RW', 'default', '1611', 'Leasehold improvements — accumulated depreciation', '{"fr":"Aménagements de locaux loués — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 250),
  ('RW', 'default', '1620', 'Plant and machinery — cost', '{"fr":"Installations et machines — coût"}'::jsonb, 'asset_fixed', false, null, 260),
  ('RW', 'default', '1621', 'Plant and machinery — accumulated depreciation', '{"fr":"Installations et machines — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 270),
  ('RW', 'default', '1630', 'Office equipment — cost', '{"fr":"Matériel de bureau — coût"}'::jsonb, 'asset_fixed', false, null, 280),
  ('RW', 'default', '1631', 'Office equipment — accumulated depreciation', '{"fr":"Matériel de bureau — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 290),
  ('RW', 'default', '1640', 'Computers — cost', '{"fr":"Matériel informatique — coût"}'::jsonb, 'asset_fixed', false, null, 300),
  ('RW', 'default', '1641', 'Computers — accumulated depreciation', '{"fr":"Matériel informatique — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 310),
  ('RW', 'default', '1650', 'Furniture and fittings — cost', '{"fr":"Mobilier et agencements — coût"}'::jsonb, 'asset_fixed', false, null, 320),
  ('RW', 'default', '1651', 'Furniture and fittings — accumulated depreciation', '{"fr":"Mobilier et agencements — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 330),
  ('RW', 'default', '1660', 'Motor vehicles — cost', '{"fr":"Véhicules automobiles — coût"}'::jsonb, 'asset_fixed', false, null, 340),
  ('RW', 'default', '1661', 'Motor vehicles — accumulated depreciation', '{"fr":"Véhicules automobiles — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 350),
  ('RW', 'default', '1670', 'Right-of-use assets — cost', '{"fr":"Droits d''utilisation — coût"}'::jsonb, 'asset_fixed', false, null, 360),
  ('RW', 'default', '1671', 'Right-of-use assets — accumulated depreciation', '{"fr":"Droits d''utilisation — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 370),
  ('RW', 'default', '1700', 'Investment property', '{"fr":"Immeubles de placement"}'::jsonb, 'asset_non_current', false, null, 380),
  ('RW', 'default', '1750', 'Intangible assets — cost', '{"fr":"Immobilisations incorporelles — coût"}'::jsonb, 'asset_fixed', false, null, 390),
  ('RW', 'default', '1751', 'Intangible assets — accumulated amortisation', '{"fr":"Immobilisations incorporelles — amortissements cumulés"}'::jsonb, 'asset_fixed', false, null, 400),
  ('RW', 'default', '1760', 'Goodwill', '{"fr":"Écart d''acquisition"}'::jsonb, 'asset_fixed', false, null, 410),
  ('RW', 'default', '1800', 'Investments in associates', '{"fr":"Participations dans des entreprises associées"}'::jsonb, 'asset_non_current', false, null, 420),
  ('RW', 'default', '1810', 'Investments in joint ventures', '{"fr":"Participations dans des coentreprises"}'::jsonb, 'asset_non_current', false, null, 430),
  ('RW', 'default', '1830', 'Long-term financial assets', '{"fr":"Immobilisations financières"}'::jsonb, 'asset_non_current', false, null, 440),
  ('RW', 'default', '1840', 'Long-term deposits', '{"fr":"Dépôts et cautionnements à long terme"}'::jsonb, 'asset_non_current', false, null, 450),
  ('RW', 'default', '1900', 'Deferred tax assets', '{"fr":"Actifs d''impôt différé"}'::jsonb, 'asset_non_current', false, null, 460),
  ('RW', 'default', '2000', 'Trade payables', '{"fr":"Dettes fournisseurs"}'::jsonb, 'liability_payable', true, null, 470),
  ('RW', 'default', '2010', 'Accrued expenses', '{"fr":"Charges à payer"}'::jsonb, 'liability_current', false, null, 480),
  ('RW', 'default', '2020', 'Other payables', '{"fr":"Autres dettes"}'::jsonb, 'liability_current', false, null, 490),
  ('RW', 'default', '2030', 'Amounts due to related companies', '{"fr":"Sommes dues à des sociétés liées"}'::jsonb, 'liability_current', false, null, 500),
  ('RW', 'default', '2040', 'Deposits received from customers', '{"fr":"Cautionnements reçus des clients"}'::jsonb, 'liability_current', false, null, 510),
  ('RW', 'default', '2100', 'VAT output tax', '{"fr":"TVA collectée"}'::jsonb, 'liability_current', false, null, 520),
  ('RW', 'default', '2110', 'VAT payable to RRA — net of a filed return', '{"fr":"TVA à payer à la RRA — solde d''une déclaration déposée"}'::jsonb, 'liability_current', true, null, 530),
  ('RW', 'default', '2125', 'Import VAT payable to RRA at the border', '{"fr":"TVA à l''importation due à la RRA à la frontière"}'::jsonb, 'liability_current', false, null, 540),
  ('RW', 'default', '2130', 'VAT withheld by public institutions — pending offset', '{"fr":"TVA retenue par les institutions publiques — en attente d''imputation"}'::jsonb, 'liability_current', false, null, 550),
  ('RW', 'default', '2140', 'Withholding tax payable to RRA', '{"fr":"Retenue à la source à payer à la RRA"}'::jsonb, 'liability_current', false, null, 560),
  ('RW', 'default', '2150', 'RSSB contributions payable — pension and maternity leave', '{"fr":"Cotisations RSSB à payer — pension et congé de maternité"}'::jsonb, 'liability_current', false, null, 570),
  ('RW', 'default', '2155', 'Medical insurance contributions payable', '{"fr":"Cotisations d''assurance maladie à payer"}'::jsonb, 'liability_current', false, null, 580),
  ('RW', 'default', '2160', 'PAYE payable', '{"fr":"Impôt sur les salaires (PAYE) à payer"}'::jsonb, 'liability_current', false, null, 590),
  ('RW', 'default', '2180', 'Salaries payable', '{"fr":"Salaires à payer"}'::jsonb, 'liability_current', false, null, 600),
  ('RW', 'default', '2190', 'Directors'' fees payable', '{"fr":"Jetons de présence à payer"}'::jsonb, 'liability_current', false, null, 610),
  ('RW', 'default', '2200', 'Bank overdraft', '{"fr":"Découvert bancaire"}'::jsonb, 'liability_current', false, null, 620),
  ('RW', 'default', '2210', 'Bank loans — current portion', '{"fr":"Emprunts bancaires — part à moins d''un an"}'::jsonb, 'liability_current', false, null, 630),
  ('RW', 'default', '2220', 'Lease liabilities — current portion', '{"fr":"Dettes de location — part à moins d''un an"}'::jsonb, 'liability_current', false, null, 640),
  ('RW', 'default', '2230', 'Hire purchase — current portion', '{"fr":"Location-vente — part à moins d''un an"}'::jsonb, 'liability_current', false, null, 650),
  ('RW', 'default', '2240', 'Corporate credit card', '{"fr":"Carte de crédit d''entreprise"}'::jsonb, 'liability_credit_card', false, null, 660),
  ('RW', 'default', '2250', 'Amounts due to directors and shareholders', '{"fr":"Sommes dues aux administrateurs et actionnaires"}'::jsonb, 'liability_current', false, null, 670),
  ('RW', 'default', '2300', 'Current income tax payable', '{"fr":"Impôt sur les bénéfices à payer"}'::jsonb, 'liability_current', false, null, 680),
  ('RW', 'default', '2350', 'Provision for unutilised leave', '{"fr":"Provision pour congés non pris"}'::jsonb, 'liability_current', false, null, 690),
  ('RW', 'default', '2360', 'Other provisions — current', '{"fr":"Autres provisions — courantes"}'::jsonb, 'liability_current', false, null, 700),
  ('RW', 'default', '2400', 'Bank loans — non-current portion', '{"fr":"Emprunts bancaires — part à plus d''un an"}'::jsonb, 'liability_non_current', false, null, 710),
  ('RW', 'default', '2410', 'Lease liabilities — non-current portion', '{"fr":"Dettes de location — part à plus d''un an"}'::jsonb, 'liability_non_current', false, null, 720),
  ('RW', 'default', '2420', 'Hire purchase — non-current portion', '{"fr":"Location-vente — part à plus d''un an"}'::jsonb, 'liability_non_current', false, null, 730),
  ('RW', 'default', '2430', 'Loans from shareholders and directors — non-current', '{"fr":"Emprunts des actionnaires et administrateurs — part à plus d''un an"}'::jsonb, 'liability_non_current', false, null, 740),
  ('RW', 'default', '2500', 'Deferred tax liabilities', '{"fr":"Passifs d''impôt différé"}'::jsonb, 'liability_non_current', false, null, 750),
  ('RW', 'default', '2550', 'Provision for reinstatement costs', '{"fr":"Provision pour coûts de remise en état"}'::jsonb, 'liability_non_current', false, null, 760),
  ('RW', 'default', '2990', 'Suspense account', '{"fr":"Compte d''attente"}'::jsonb, 'liability_current', false, null, 770),
  ('RW', 'default', '3000', 'Share capital', '{"fr":"Capital social"}'::jsonb, 'equity', false, null, 780),
  ('RW', 'default', '3010', 'Treasury shares', '{"fr":"Actions propres"}'::jsonb, 'equity', false, null, 790),
  ('RW', 'default', '3100', 'Other reserves', '{"fr":"Autres réserves"}'::jsonb, 'equity', false, null, 800),
  ('RW', 'default', '3110', 'Foreign currency translation reserve', '{"fr":"Écart de conversion"}'::jsonb, 'equity', false, null, 810),
  ('RW', 'default', '3200', 'Retained earnings', '{"fr":"Report à nouveau"}'::jsonb, 'equity_retained', false, null, 820),
  ('RW', 'default', '3210', 'Dividends paid', '{"fr":"Dividendes versés"}'::jsonb, 'equity_retained', false, null, 830),
  ('RW', 'default', '4000', 'Sales of goods', '{"fr":"Ventes de marchandises"}'::jsonb, 'income', false, null, 840),
  ('RW', 'default', '4010', 'Services rendered', '{"fr":"Prestations de services"}'::jsonb, 'income', false, null, 850),
  ('RW', 'default', '4020', 'Export sales of goods', '{"fr":"Ventes de marchandises à l''exportation"}'::jsonb, 'income', false, null, 860),
  ('RW', 'default', '4030', 'Export of services', '{"fr":"Prestations de services à l''exportation"}'::jsonb, 'income', false, null, 870),
  ('RW', 'default', '4500', 'Interest income', '{"fr":"Produits d''intérêts"}'::jsonb, 'income_other', false, null, 880),
  ('RW', 'default', '4510', 'Dividend income', '{"fr":"Produits de dividendes"}'::jsonb, 'income_other', false, null, 890),
  ('RW', 'default', '4520', 'Rental income', '{"fr":"Produits locatifs"}'::jsonb, 'income_other', false, null, 900),
  ('RW', 'default', '4530', 'Government grants', '{"fr":"Subventions publiques"}'::jsonb, 'income_other', false, null, 910),
  ('RW', 'default', '4700', 'Foreign exchange gains', '{"fr":"Gains de change"}'::jsonb, 'income_other', false, null, 920),
  ('RW', 'default', '4750', 'Gain on disposal of property plant and equipment', '{"fr":"Plus-value de cession d''immobilisations corporelles"}'::jsonb, 'income_other', false, null, 930),
  ('RW', 'default', '4790', 'Other income', '{"fr":"Autres produits"}'::jsonb, 'income_other', false, null, 940),
  ('RW', 'default', '5000', 'Purchases of goods for resale', '{"fr":"Achats de marchandises"}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('RW', 'default', '5010', 'Freight inwards and import duties', '{"fr":"Frets à l''entrée et droits de douane"}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('RW', 'default', '5020', 'Subcontract costs', '{"fr":"Sous-traitance"}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('RW', 'default', '5100', 'Changes in inventories', '{"fr":"Variation des stocks"}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('RW', 'default', '6000', 'Salaries and wages', '{"fr":"Salaires et traitements"}'::jsonb, 'expense', false, null, 990),
  ('RW', 'default', '6010', 'Directors'' remuneration', '{"fr":"Rémunération des administrateurs"}'::jsonb, 'expense', false, null, 1000),
  ('RW', 'default', '6020', 'Directors'' fees', '{"fr":"Jetons de présence"}'::jsonb, 'expense', false, null, 1010),
  ('RW', 'default', '6030', 'RSSB contributions — employer', '{"fr":"Cotisations RSSB — part patronale"}'::jsonb, 'expense', false, null, 1020),
  ('RW', 'default', '6035', 'Medical insurance contributions — employer', '{"fr":"Cotisations d''assurance maladie — part patronale"}'::jsonb, 'expense', false, null, 1030),
  ('RW', 'default', '6060', 'Staff welfare', '{"fr":"Œuvres sociales du personnel"}'::jsonb, 'expense', false, null, 1040),
  ('RW', 'default', '6070', 'Staff medical expenses and insurance', '{"fr":"Frais médicaux et assurance du personnel"}'::jsonb, 'expense', false, null, 1050),
  ('RW', 'default', '6080', 'Staff training', '{"fr":"Formation du personnel"}'::jsonb, 'expense', false, null, 1060),
  ('RW', 'default', '6200', 'Depreciation of property plant and equipment', '{"fr":"Dotations aux amortissements des immobilisations corporelles"}'::jsonb, 'expense_depreciation', false, null, 1070),
  ('RW', 'default', '6210', 'Depreciation of right-of-use assets', '{"fr":"Dotations aux amortissements des droits d''utilisation"}'::jsonb, 'expense_depreciation', false, null, 1080),
  ('RW', 'default', '6220', 'Amortisation of intangible assets', '{"fr":"Dotations aux amortissements des immobilisations incorporelles"}'::jsonb, 'expense_depreciation', false, null, 1090),
  ('RW', 'default', '6300', 'Rent — short-term leases', '{"fr":"Loyers — locations à court terme"}'::jsonb, 'expense', false, null, 1100),
  ('RW', 'default', '6310', 'Utilities', '{"fr":"Eau, électricité et énergie"}'::jsonb, 'expense', false, null, 1110),
  ('RW', 'default', '6320', 'Repairs and maintenance', '{"fr":"Réparations et entretien"}'::jsonb, 'expense', false, null, 1120),
  ('RW', 'default', '6330', 'Cleaning and security services', '{"fr":"Nettoyage et gardiennage"}'::jsonb, 'expense', false, null, 1130),
  ('RW', 'default', '6340', 'Telephone and internet', '{"fr":"Téléphone et internet"}'::jsonb, 'expense', false, null, 1140),
  ('RW', 'default', '6350', 'Software subscriptions', '{"fr":"Abonnements logiciels"}'::jsonb, 'expense', false, null, 1150),
  ('RW', 'default', '6360', 'Advertising and marketing', '{"fr":"Publicité et marketing"}'::jsonb, 'expense', false, null, 1160),
  ('RW', 'default', '6370', 'Travelling', '{"fr":"Frais de déplacement"}'::jsonb, 'expense', false, null, 1170),
  ('RW', 'default', '6380', 'Motor vehicle expenses', '{"fr":"Frais de véhicules"}'::jsonb, 'expense', false, null, 1180),
  ('RW', 'default', '6390', 'Entertainment', '{"fr":"Frais de réception"}'::jsonb, 'expense', false, null, 1190),
  ('RW', 'default', '6400', 'Subscriptions and memberships', '{"fr":"Cotisations et adhésions"}'::jsonb, 'expense', false, null, 1200),
  ('RW', 'default', '6410', 'Insurance', '{"fr":"Assurances"}'::jsonb, 'expense', false, null, 1210),
  ('RW', 'default', '6420', 'Professional fees', '{"fr":"Honoraires"}'::jsonb, 'expense', false, null, 1220),
  ('RW', 'default', '6430', 'Audit fees', '{"fr":"Honoraires d''audit"}'::jsonb, 'expense', false, null, 1230),
  ('RW', 'default', '6440', 'Company registration and secretarial fees', '{"fr":"Frais de greffe et de secrétariat juridique"}'::jsonb, 'expense', false, null, 1240),
  ('RW', 'default', '6450', 'Bank charges', '{"fr":"Frais bancaires"}'::jsonb, 'expense', false, null, 1250),
  ('RW', 'default', '6460', 'Printing and stationery', '{"fr":"Imprimés et fournitures de bureau"}'::jsonb, 'expense', false, null, 1260),
  ('RW', 'default', '6470', 'Postage and courier', '{"fr":"Affranchissement et courrier"}'::jsonb, 'expense', false, null, 1270),
  ('RW', 'default', '6480', 'Licences permits and district government fees', '{"fr":"Licences, permis et taxes de district"}'::jsonb, 'expense', false, null, 1280),
  ('RW', 'default', '6490', 'Royalties', '{"fr":"Redevances"}'::jsonb, 'expense', false, null, 1290),
  ('RW', 'default', '6500', 'Bad debts written off', '{"fr":"Créances irrécouvrables"}'::jsonb, 'expense', false, null, 1300),
  ('RW', 'default', '6510', 'Impairment loss on trade receivables', '{"fr":"Dépréciation des créances clients"}'::jsonb, 'expense', false, null, 1310),
  ('RW', 'default', '6900', 'Donations', '{"fr":"Dons"}'::jsonb, 'expense', false, null, 1320),
  ('RW', 'default', '6950', 'Foreign exchange losses', '{"fr":"Pertes de change"}'::jsonb, 'expense', false, null, 1330),
  ('RW', 'default', '6960', 'Loss on disposal of property plant and equipment', '{"fr":"Moins-value de cession d''immobilisations corporelles"}'::jsonb, 'expense', false, null, 1340),
  ('RW', 'default', '6990', 'Rounding differences', '{"fr":"Écarts d''arrondi"}'::jsonb, 'expense', false, null, 1350),
  ('RW', 'default', '7000', 'Interest on bank loans', '{"fr":"Intérêts sur emprunts bancaires"}'::jsonb, 'expense', false, null, 1360),
  ('RW', 'default', '7010', 'Interest on lease liabilities', '{"fr":"Intérêts sur dettes de location"}'::jsonb, 'expense', false, null, 1370),
  ('RW', 'default', '7020', 'Hire purchase interest', '{"fr":"Intérêts de location-vente"}'::jsonb, 'expense', false, null, 1380),
  ('RW', 'default', '7030', 'Interest on loans from related parties and others', '{"fr":"Intérêts sur emprunts des parties liées et autres"}'::jsonb, 'expense', false, null, 1390),
  ('RW', 'default', '8000', 'Current income tax expense', '{"fr":"Charge d''impôt exigible"}'::jsonb, 'expense', false, null, 1400),
  ('RW', 'default', '8010', 'Deferred tax expense', '{"fr":"Charge d''impôt différé"}'::jsonb, 'expense', false, null, 1410),
  ('RW', 'default', '8020', 'Under or over provision of income tax in prior years', '{"fr":"Ajustement de l''impôt des exercices antérieurs"}'::jsonb, 'expense', false, null, 1420)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('RW', 'BNK', 'Bank', '{"fr":"Banque"}'::jsonb, 'bank', 30),
  ('RW', 'CSH', 'Petty cash', '{"fr":"Caisse"}'::jsonb, 'cash', 40),
  ('RW', 'GEN', 'General journal', '{"fr":"Journal général"}'::jsonb, 'general', 50),
  ('RW', 'OPN', 'Opening balances', '{"fr":"À-nouveaux"}'::jsonb, 'opening', 60),
  ('RW', 'PUR', 'Purchases journal', '{"fr":"Journal des achats"}'::jsonb, 'purchase', 20),
  ('RW', 'SAL', 'Sales journal', '{"fr":"Journal des ventes"}'::jsonb, 'sales', 10)
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
  ('RW', 'RW-P-18', 'Purchase, standard rate 18 %, deductible', '{"fr":"Achat, taux normal 18 %, déductible"}'::jsonb, 'A local purchase at the general rate, used to make taxable supplies', 'percent', 18, 'purchase', 'domestic', date '2023-09-14', null, 'Value Added Tax Law, article 17(1) — a taxpayer who supplies taxable goods or services during a tax period is entitled to a credit of the input tax paid in respect of taxable acquisitions during the period for the purposes of selling taxable goods or delivering taxable services; article 4(b) — the rate. Monthly VAT Declaration Form, line 55 (VAT Paid on Local Purchase) and line 60 (VAT Paid on Input).', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-P-18-BL', 'Purchase, standard rate 18 %, input tax disallowed (passenger vehicle)', '{"fr":"Achat, taux normal 18 %, taxe en amont refusée (véhicule de transport de personnes)"}'::jsonb, 'A passenger vehicle, its spare parts and its repair and maintenance services, bought other than by a taxpayer who deals, rents or teaches driving with such vehicles', 'percent', 18, 'purchase', 'domestic', date '2023-09-14', null, 'Value Added Tax Law, article 20(a) — no input tax is allowed on a passenger vehicle, its spare parts and its repair and maintenance services, unless the taxpayer conducts a business of sale or rent of passenger vehicles, or has a driving school. The disallowed tax is not a claim on the Monthly VAT Declaration Form, so it lands on the account of the line and reaches no box.', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-P-IMP', 'Import of goods, VAT paid at the border', '{"fr":"Importation de biens, TVA payée à la frontière"}'::jsonb, 'VAT due at the customs point on the importation of taxable goods, claimed as input tax once paid', 'percent', 18, 'purchase', 'import', date '2023-09-14', null, 'Value Added Tax Law, article 3(1)(b) — tax is charged on taxable imported goods and services; article 15 — goods are considered imported on the date they enter Rwandan territory under customs law; article 16 — the basic value for taxation of imported goods; article 29(2) — the value added tax payable by an importer is due when the imported goods enter the customs point. Article 17(1) — the tax so paid is then deductible as input tax. Monthly VAT Declaration Form, line 50 (VAT Paid on Imports) and line 60 (VAT Paid on Input). The tax is owed to the Rwanda Revenue Authority at the border and not to the supplier, so it waits on 2125 until the import declaration is settled.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-P-RC-FOREIGN', 'Imported service, self-charged and claimed', '{"fr":"Service importé, autoliquidé et déduit"}'::jsonb, 'A service acquired from a person residing outside Rwanda, not available on the local market, self-assessed and fully deductible', 'percent', 18, 'purchase', 'foreign_services_received', date '2023-09-14', null, 'Value Added Tax Law, article 14(1) — a taxpayer who acquires a service from a person outside Rwanda is considered to have received a taxable service and an output tax from that person; article 14(2) — the output tax is payable on the date of declaration for the period the service was delivered, and the receipt justifying payment to the foreign supplier is considered the value added tax invoice; article 14(3) — the recipient may deduct that input tax only if the service is not available on the local market. Monthly VAT Declaration Form, line 40 (VAT Reverse Charge) and line 65 (VAT Reverse Charge deductible).', null, null, 140, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-P-RC-FOREIGN-BL', 'Imported service, self-charged, input tax disallowed (available locally)', '{"fr":"Service importé, autoliquidé, taxe en amont refusée (disponible localement)"}'::jsonb, 'A service acquired from a person residing outside Rwanda, available from an identical or similar provider on the local market, so the self-assessed tax cannot be offset as input tax', 'percent', 18, 'purchase', 'foreign_services_received', date '2023-09-14', null, 'Value Added Tax Law, article 14(1) and (2) — the taxpayer self-charges and pays the output tax on the service received. Article 14(3) and (4) — this VAT may be offset as input tax only if the service received is not available on the local market; a service is not considered available in Rwanda if there is no one who can deliver an identical or similar service. Where the service is available locally, the tax is not offset, and the disallowed amount is not a claim on the Monthly VAT Declaration Form, so it lands on the account of the line. Monthly VAT Declaration Form, line 40 (VAT Reverse Charge).', null, null, 150, 'vat', false, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-S-18', 'Sale, standard rate 18 %', '{"fr":"Vente, taux normal 18 %"}'::jsonb, 'The general rate on a taxable supply made in Rwanda', 'percent', 18, 'sale', 'domestic', date '2023-09-14', null, 'Value Added Tax Law, article 3(1)(a) — value added tax is charged on taxable goods and services supplied in Rwanda; article 4(b) — at eighteen per cent for other goods and services supplied in Rwanda or imported. Monthly VAT Declaration Form, line 5 (total value of supplies) and line 35 (VAT on taxable sales, 18 % of line 30).', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-S-EX-AGRI', 'Sale, exempt (unprocessed agricultural and livestock products)', '{"fr":"Vente, exonérée (produits agricoles et d''élevage non transformés)"}'::jsonb, 'Agricultural and livestock products in their unprocessed state', 'percent', 0, 'sale', 'exempt', date '2023-09-14', null, 'Value Added Tax Law, article 8(1)(k) — all agricultural and livestock products, except processed ones, are exempt from value added tax; processed maize, rice and milk remain exempt, except powdered milk and milk-derived products. Monthly VAT Declaration Form, line 5 and line 10 (Exempted Sales).', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-S-ZR-EXP', 'Sale, zero-rated (export of goods)', '{"fr":"Vente, taux zéro (exportation de biens)"}'::jsonb, 'Goods exported from Rwanda and their auxiliary services', 'percent', 0, 'sale', 'export', date '2023-09-14', null, 'Value Added Tax Law, article 7(1)(a) — exported goods and their auxiliary services, including those that are already exempted, are zero-rated. Monthly VAT Declaration Form, line 5 (total value of supplies) and line 20 (Exports).', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-S-ZR-EXP-SVC', 'Sale, zero-rated (export of services)', '{"fr":"Vente, taux zéro (exportation de services)"}'::jsonb, 'A service exported outside Rwanda', 'percent', 0, 'sale', 'export', date '2023-09-14', null, 'Value Added Tax Law, article 7(1)(b) — exported services are zero-rated; article 2, 15° defines an exported service as one provided for use or consumption outside Rwanda, whether supplied in Rwanda or both inside and outside Rwanda, but which has no impact on the recipient''s interest in Rwanda. Monthly VAT Declaration Form, line 5 and line 20 (Exports).', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null),
  ('RW', 'RW-S-ZR-MIN', 'Sale, zero-rated (minerals sold on the domestic market)', '{"fr":"Vente, taux zéro (minerais vendus sur le marché intérieur)"}'::jsonb, 'A domestic sale of minerals, which stays zero-rated without the goods leaving Rwanda', 'percent', 0, 'sale', 'domestic', date '2023-09-14', null, 'Value Added Tax Law, article 7(1)(c) — minerals sold on the domestic market are zero-rated. Monthly VAT Declaration Form, line 5 and line 15 (Zero Rated Sales).', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law', null, null, null, null)
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
    ('RW-P-18', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-18', 'invoice', 'tax', 100, '1150', '55', array['55']::text[], 100, 'RW-VAT', 20),
    ('RW-P-18', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-18', 'credit_note', 'tax', 100, '1150', '55', array['55']::text[], -100, 'RW-VAT', 20),
    ('RW-P-18-BL', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-18-BL', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('RW-P-18-BL', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-18-BL', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('RW-P-IMP', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-IMP', 'invoice', 'tax', 100, '1150', '50', array['50']::text[], 100, 'RW-VAT', 20),
    ('RW-P-IMP', 'invoice', 'tax', -100, '2125', null, null, 100, null, 30),
    ('RW-P-IMP', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-IMP', 'credit_note', 'tax', 100, '1150', '50', array['50']::text[], -100, 'RW-VAT', 20),
    ('RW-P-IMP', 'credit_note', 'tax', -100, '2125', null, null, 100, null, 30),
    ('RW-P-RC-FOREIGN', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-RC-FOREIGN', 'invoice', 'tax', 100, '1150', '65', array['65']::text[], 100, 'RW-VAT', 20),
    ('RW-P-RC-FOREIGN', 'invoice', 'tax', -100, '2100', '40', array['40']::text[], 100, 'RW-VAT', 30),
    ('RW-P-RC-FOREIGN', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-RC-FOREIGN', 'credit_note', 'tax', 100, '1150', '65', array['65']::text[], -100, 'RW-VAT', 20),
    ('RW-P-RC-FOREIGN', 'credit_note', 'tax', -100, '2100', '40', array['40']::text[], -100, 'RW-VAT', 30),
    ('RW-P-RC-FOREIGN-BL', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-RC-FOREIGN-BL', 'invoice', 'tax', -100, '2100', '40', array['40']::text[], 100, 'RW-VAT', 20),
    ('RW-P-RC-FOREIGN-BL', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 30),
    ('RW-P-RC-FOREIGN-BL', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('RW-P-RC-FOREIGN-BL', 'credit_note', 'tax', -100, '2100', '40', array['40']::text[], -100, 'RW-VAT', 20),
    ('RW-P-RC-FOREIGN-BL', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 30),
    ('RW-S-18', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'RW-VAT', 10),
    ('RW-S-18', 'invoice', 'tax', 100, '2100', null, null, 100, null, 20),
    ('RW-S-18', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'RW-VAT', 10),
    ('RW-S-18', 'credit_note', 'tax', 100, '2100', null, null, -100, null, 20),
    ('RW-S-EX-AGRI', 'invoice', 'base', 100, null, '5', array['5', '10']::text[], 100, 'RW-VAT', 10),
    ('RW-S-EX-AGRI', 'credit_note', 'base', 100, null, '5', array['5', '10']::text[], -100, 'RW-VAT', 10),
    ('RW-S-ZR-EXP', 'invoice', 'base', 100, null, '5', array['5', '20']::text[], 100, 'RW-VAT', 10),
    ('RW-S-ZR-EXP', 'credit_note', 'base', 100, null, '5', array['5', '20']::text[], -100, 'RW-VAT', 10),
    ('RW-S-ZR-EXP-SVC', 'invoice', 'base', 100, null, '5', array['5', '20']::text[], 100, 'RW-VAT', 10),
    ('RW-S-ZR-EXP-SVC', 'credit_note', 'base', 100, null, '5', array['5', '20']::text[], -100, 'RW-VAT', 10),
    ('RW-S-ZR-MIN', 'invoice', 'base', 100, null, '5', array['5', '15']::text[], 100, 'RW-VAT', 10),
    ('RW-S-ZR-MIN', 'credit_note', 'base', 100, null, '5', array['5', '15']::text[], -100, 'RW-VAT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'RW' and t.code = v.tax_code
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
  ('RW', 'RW-VAT', 'Monthly VAT Declaration Form (RRA-VAT-DF1)', array['month', 'quarter']::declaration_period[], null, date '2023-09-14', null, 'Value Added Tax Law, article 28(1) — value added tax is declared after the end of a month or after a quarter of three months; article 28(2) — a taxpayer whose annual turnover is equal to or less than FRW 200,000,000 declares quarterly; article 28(3) — a taxpayer whose annual turnover is more than FRW 200,000,000 declares monthly; article 28(4) — a taxpayer under the threshold may opt for a monthly declaration. The cadence follows a fact about the company (its turnover) rather than a rule the law gives everybody, so no `period_default` is declared. The form lays sales out in section 5 (lines 5 to 20) and the calculation of tax due in lines 25 to 95; this pack carries lines 5 to 70. Lines 75 (credit carried forward from a previous period), 76 and 80 (invoices to and VAT withheld by public institutions, a mechanism a third party to the sale executes) and 90/95 (the administrative split of line 70 between a refund claim and an amount due) are period-to-period settlement or a third party''s own declaration rather than a figure this document posts; both gaps are recorded in docs/international.md.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Value Added Tax Law, article 28(2) and (3) — a taxpayer declares within fifteen days after the end of the quarter or the month; article 29(1) — the value added tax declared is paid within fifteen days following each month or quarter of declaration.', 'vat-law', null)
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
  ('RW', 'RW-VAT', '5', 'base', 'Total Value of Supplies During the Month (VAT Exclusive)', '{"fr":"Valeur totale des livraisons durant le mois (hors TVA)"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 5 — the value excluding VAT of every supply made during the period, taxable and non-taxable alike.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '10', 'base', 'Exempted Sales', '{"fr":"Ventes exonérées"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 10 — sales exempt under article 8 of the Value Added Tax Law.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '15', 'base', 'Zero Rated Sales', '{"fr":"Ventes imposées au taux zéro"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 15 — domestic sales zero-rated under article 7 of the Value Added Tax Law, other than exports.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '20', 'base', 'Exports', '{"fr":"Exportations"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 20 — exported goods and services, zero-rated under article 7(1)(a) and (b) of the Value Added Tax Law.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '25', 'total', 'Total Not Taxable', '{"fr":"Total non imposable"}'::jsonb, 50, null, array['10', '15', '20']::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 25 — Total Not Taxable (Line 10+15+20).', 'vat-df1-form'),
  ('RW', 'RW-VAT', '30', 'total', 'Taxable Sales Subject to VAT', '{"fr":"Ventes imposables soumises à la TVA"}'::jsonb, 60, null, array['5']::text[], array['25']::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 30 — Taxable Sales Subject to VAT (Line 5 - Line 25).', 'vat-df1-form'),
  ('RW', 'RW-VAT', '35', 'total', 'VAT on Taxable Sales', '{"fr":"TVA sur les ventes imposables"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], 18, '30', false, false, null, 'Monthly VAT Declaration Form, line 35 — VAT on Taxable Sales (18 % of Line 30).', 'vat-df1-form'),
  ('RW', 'RW-VAT', '40', 'tax', 'VAT Reverse Charge', '{"fr":"TVA autoliquidée"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 40 — the output tax self-charged under article 14 of the Value Added Tax Law on a service acquired from a person residing outside Rwanda.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '45', 'total', 'VAT Payable', '{"fr":"TVA à payer"}'::jsonb, 90, null, array['35', '40']::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 45 — VAT Payable (Line 35+Line 40).', 'vat-df1-form'),
  ('RW', 'RW-VAT', '50', 'tax', 'VAT Paid on Imports', '{"fr":"TVA payée à l''importation"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 50 — value added tax paid at the customs point on imported goods, deductible under article 17(1) of the Value Added Tax Law.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '55', 'tax', 'VAT Paid on Local Purchase', '{"fr":"TVA payée sur les achats locaux"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 55 — value added tax paid on a local purchase, deductible under article 17(1) of the Value Added Tax Law.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '60', 'total', 'VAT Paid on Input', '{"fr":"TVA payée en amont"}'::jsonb, 120, null, array['50', '55']::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 60 — VAT Paid on Input (Line 50+Line 55).', 'vat-df1-form'),
  ('RW', 'RW-VAT', '65', 'tax', 'VAT Reverse Charge deductible', '{"fr":"TVA autoliquidée déductible"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 65 — the input tax of line 40 the taxpayer may deduct under article 14(3) of the Value Added Tax Law, where the service received is not available on the local market.', 'vat-df1-form'),
  ('RW', 'RW-VAT', '70', 'total', 'VAT Payable/Credit Refundable', '{"fr":"TVA à payer / crédit remboursable"}'::jsonb, 140, null, array['45']::text[], array['60', '65']::text[], null, null, false, false, null, 'Monthly VAT Declaration Form, line 70 — VAT Payable/Credit Refundable [(Line 45-(Line 60+Line 65))]. A positive figure is payable to the Rwanda Revenue Authority within fifteen days of the end of the period (article 29(1)); a negative figure is a credit, which article 26 refunds within thirty days of the declaration or carries forward, which the form''s lines 75, 90 and 95 track and this pack does not carry.', 'vat-df1-form')
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
  ('RW-ICPAR-IS', 'RW', 'default', 'Profit and loss account', 'income_statement', 'IFRS-SME', date '2021-02-08', null, 'Law N° 007/2021 of 05/02/2021 governing companies, article 122 — the individual accounts include a profit and loss account for the accounting period. ICPAR''s IFRS for SMEs illustrative statement aggregates expenses by nature, which these lines follow.', 'companies-law'),
  ('RW-ICPAR-SFP', 'RW', 'default', 'Statement of financial position', 'balance_sheet', 'IFRS-SME', date '2021-02-08', null, 'Law N° 007/2021 of 05/02/2021 governing companies, article 122 — the individual accounts of a company show its activities during the accounting period, including a balance sheet, a profit and loss account, cash flow statements, equity and a statement of changes; article 123 — the balance sheet of a company complies with international standards. The Institute of Certified Public Accountants of Rwanda has adopted the IFRS for SMEs Accounting Standard for an entity with no public accountability; the lines below follow that standard''s illustrative statement of financial position, section 4.', 'companies-law')
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
  ('RW-ICPAR-IS', '1', null, 'Revenue', '{"fr":"Produits des activités ordinaires"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '2', null, 'Other income', '{"fr":"Autres produits"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '3', null, 'Purchases and changes in inventories', '{"fr":"Achats et variation des stocks"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '4', null, 'Employee benefits expense', '{"fr":"Charges de personnel"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '5', null, 'Depreciation and amortisation', '{"fr":"Dotations aux amortissements"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '6', null, 'Other operating expenses', '{"fr":"Autres charges opérationnelles"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '7', null, 'Finance costs', '{"fr":"Charges financières"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '8', null, 'Profit before tax', '{"fr":"Résultat avant impôt"}'::jsonb, 80, 1, true, array['1', '2']::text[], array['3', '4', '5', '6', '7']::text[], null, null, null),
  ('RW-ICPAR-IS', '9', null, 'Income tax expense', '{"fr":"Charge d''impôt sur les bénéfices"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-IS', '10', null, 'Profit for the year', '{"fr":"Résultat de l''exercice"}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA', null, 'Current assets', '{"fr":"Actifs courants"}'::jsonb, 10, 1, true, array['CA.1', 'CA.2', 'CA.3', 'CA.4', 'CA.5', 'CA.6']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA.1', null, 'Cash and cash equivalents', '{"fr":"Trésorerie et équivalents de trésorerie"}'::jsonb, 11, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA.2', null, 'Trade and other receivables', '{"fr":"Créances clients et autres créances"}'::jsonb, 12, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA.3', null, 'Inventories', '{"fr":"Stocks"}'::jsonb, 13, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA.4', null, 'Financial assets', '{"fr":"Actifs financiers"}'::jsonb, 14, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA.5', null, 'Current tax recoverable', '{"fr":"Impôt courant à recouvrer"}'::jsonb, 15, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CA.6', null, 'Prepayments and accrued income', '{"fr":"Charges constatées d''avance et produits à recevoir"}'::jsonb, 16, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA', null, 'Non-current assets', '{"fr":"Actifs non courants"}'::jsonb, 20, 1, true, array['NCA.1', 'NCA.2', 'NCA.3', 'NCA.4', 'NCA.5', 'NCA.6', 'NCA.7']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.1', null, 'Property, plant and equipment', '{"fr":"Immobilisations corporelles"}'::jsonb, 21, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.2', null, 'Investment property', '{"fr":"Immeubles de placement"}'::jsonb, 22, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.3', null, 'Intangible assets', '{"fr":"Immobilisations incorporelles"}'::jsonb, 23, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.4', null, 'Investments in associates', '{"fr":"Participations dans des entreprises associées"}'::jsonb, 24, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.5', null, 'Investments in joint ventures', '{"fr":"Participations dans des coentreprises"}'::jsonb, 25, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.6', null, 'Financial assets', '{"fr":"Actifs financiers"}'::jsonb, 26, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCA.7', null, 'Deferred tax assets', '{"fr":"Actifs d''impôt différé"}'::jsonb, 27, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'TA', null, 'Total assets', '{"fr":"Total des actifs"}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CL', null, 'Current liabilities', '{"fr":"Passifs courants"}'::jsonb, 40, 1, true, array['CL.1', 'CL.2', 'CL.3', 'CL.4', 'CL.5']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CL.1', null, 'Trade and other payables', '{"fr":"Dettes fournisseurs et autres dettes"}'::jsonb, 41, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CL.2', null, 'Borrowings and other financial liabilities', '{"fr":"Emprunts et autres passifs financiers"}'::jsonb, 42, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CL.3', null, 'Amounts due to directors and shareholders', '{"fr":"Sommes dues aux administrateurs et actionnaires"}'::jsonb, 43, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CL.4', null, 'Current income tax payable', '{"fr":"Impôt sur les bénéfices à payer"}'::jsonb, 44, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'CL.5', null, 'Provisions', '{"fr":"Provisions"}'::jsonb, 45, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCL', null, 'Non-current liabilities', '{"fr":"Passifs non courants"}'::jsonb, 50, 1, true, array['NCL.1', 'NCL.2', 'NCL.3']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCL.1', null, 'Borrowings and other financial liabilities', '{"fr":"Emprunts et autres passifs financiers"}'::jsonb, 51, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCL.2', null, 'Deferred tax liabilities', '{"fr":"Passifs d''impôt différé"}'::jsonb, 52, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NCL.3', null, 'Provisions', '{"fr":"Provisions"}'::jsonb, 53, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'TL', null, 'Total liabilities', '{"fr":"Total des passifs"}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'NA', null, 'Net assets', '{"fr":"Actif net"}'::jsonb, 70, 1, true, array['TA']::text[], array['TL']::text[], null, null, null),
  ('RW-ICPAR-SFP', 'EQ', null, 'Equity', '{"fr":"Capitaux propres"}'::jsonb, 80, 1, true, array['EQ.1', 'EQ.2', 'EQ.3']::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'EQ.1', null, 'Share capital', '{"fr":"Capital social"}'::jsonb, 81, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'EQ.2', null, 'Other reserves', '{"fr":"Autres réserves"}'::jsonb, 82, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('RW-ICPAR-SFP', 'EQ.3', null, 'Retained earnings', '{"fr":"Report à nouveau"}'::jsonb, 83, -1, false, '{}'::text[], '{}'::text[], null, null, null)
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
    ('RW-ICPAR-IS', '1', 10, 'code_range', '4000', '4030', null, 'any'),
    ('RW-ICPAR-IS', '2', 10, 'code_range', '4500', '4790', null, 'any'),
    ('RW-ICPAR-IS', '3', 10, 'code_range', '5000', '5100', null, 'any'),
    ('RW-ICPAR-IS', '4', 10, 'code_range', '6000', '6080', null, 'any'),
    ('RW-ICPAR-IS', '5', 10, 'code_range', '6200', '6220', null, 'any'),
    ('RW-ICPAR-IS', '6', 10, 'code_range', '6300', '6990', null, 'any'),
    ('RW-ICPAR-IS', '7', 10, 'code_range', '7000', '7030', null, 'any'),
    ('RW-ICPAR-IS', '9', 10, 'code_range', '8000', '8020', null, 'any'),
    ('RW-ICPAR-SFP', 'CA.1', 10, 'code_range', '1000', '1040', null, 'any'),
    ('RW-ICPAR-SFP', 'CA.2', 10, 'code_range', '1100', '1160', null, 'any'),
    ('RW-ICPAR-SFP', 'CA.3', 10, 'code_range', '1200', '1230', null, 'any'),
    ('RW-ICPAR-SFP', 'CA.4', 10, 'account_code', '1300', null, null, 'any'),
    ('RW-ICPAR-SFP', 'CA.5', 10, 'account_code', '1350', null, null, 'any'),
    ('RW-ICPAR-SFP', 'CA.6', 10, 'code_range', '1400', '1410', null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.1', 10, 'code_range', '1600', '1671', null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.2', 10, 'account_code', '1700', null, null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.3', 10, 'code_range', '1750', '1760', null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.4', 10, 'account_code', '1800', null, null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.5', 10, 'account_code', '1810', null, null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.6', 10, 'code_range', '1830', '1840', null, 'any'),
    ('RW-ICPAR-SFP', 'NCA.7', 10, 'account_code', '1900', null, null, 'any'),
    ('RW-ICPAR-SFP', 'CL.1', 10, 'code_range', '2000', '2190', null, 'any'),
    ('RW-ICPAR-SFP', 'CL.1', 20, 'account_code', '2990', null, null, 'credit'),
    ('RW-ICPAR-SFP', 'CL.2', 10, 'code_range', '2200', '2240', null, 'any'),
    ('RW-ICPAR-SFP', 'CL.3', 10, 'account_code', '2250', null, null, 'any'),
    ('RW-ICPAR-SFP', 'CL.4', 10, 'account_code', '2300', null, null, 'any'),
    ('RW-ICPAR-SFP', 'CL.5', 10, 'code_range', '2350', '2360', null, 'any'),
    ('RW-ICPAR-SFP', 'NCL.1', 10, 'code_range', '2400', '2430', null, 'any'),
    ('RW-ICPAR-SFP', 'NCL.2', 10, 'account_code', '2500', null, null, 'any'),
    ('RW-ICPAR-SFP', 'NCL.3', 10, 'account_code', '2550', null, null, 'any'),
    ('RW-ICPAR-SFP', 'EQ.1', 10, 'code_range', '3000', '3010', null, 'any'),
    ('RW-ICPAR-SFP', 'EQ.2', 10, 'code_range', '3100', '3110', null, 'any'),
    ('RW-ICPAR-SFP', 'EQ.3', 10, 'code_range', '3200', '3210', null, 'any')
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
  ('RW', 'Rwanda', '{"fr":"Rwanda"}'::jsonb, array['en', 'fr']::text[], 'RWF', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'en', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, null)
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
  numbering_legal_reference     = 'Law N° 020/2023 of 31/03/2023 on tax procedures requires every person carrying out a taxable activity to issue an electronic tax invoice through the electronic invoicing system (EIS/EBM), which the Tax Administration certifies and numbers; the requirement identifies each invoice rather than forbidding a hole in the series, which is why `numbering` is `sequential` and not gapless.',
  numbering_source_key          = 'tax-procedures-law',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Value Added Tax Law, article 12(1) — the value added tax point for the supply of goods and services is the earliest among: (a) the date the invoice is issued; (b) the date payment (including partial payment) is made, except an advance payment for construction services; (c) the date goods are removed from the supplier''s premises or given to the recipient; (d) the date a service is delivered; (e) the date a taxpayer applies for deregistration. This is a five-way earliest-of test and Ekwo''s closed vocabulary only expresses a two-way one; `earliest_of_delivery_or_payment` is the nearest value, and the gap — an invoice issued ahead of both delivery and payment, or a deregistration application, which would fix the tax point in Rwanda but not in Ekwo''s own reading of this word — is recorded in docs/international.md.',
  tax_point_source_key          = 'vat-law',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No Rwandan statute obliges a business to exchange a structured electronic invoice with another business, or to accept one, in the sense Ekwo''s vocabulary gives the word — there is no Rwandan Peppol authority, no published profile and no ISO 6523 scheme a party is addressed by, so `profile`, `party_scheme` and `vat_scheme` are all null and `obligation` is `none`. What Rwanda has instead is the Electronic Invoicing System (EIS), a clearance system built on the Electronic Billing Machine (EBM): Law N° 020/2023 of 31/03/2023 on tax procedures requires every person carrying out a taxable activity, whether registered for VAT or not, to request and use an EIS/EBM device — an ETR, e-invoicing software (OSCU/VSCU), a mobile application or another certified channel — to issue every tax invoice, which is validated and reported to the Rwanda Revenue Authority in real time; a person who fails to comply is liable to an administrative fine. This is a real-time clearance of an invoice already addressed to a Rwandan buyer and not a peer-to-peer exchange of a structured document between two businesses in the sense `einvoicing.profile` describes; the gap is recorded in docs/international.md and in this pack''s README, and the socle is not patched to fit it.',
  einvoice_source_key           = 'tax-procedures-law',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'RW';
