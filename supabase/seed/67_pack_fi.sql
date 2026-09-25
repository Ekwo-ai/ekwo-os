-- Ekwo OS — Finland: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/fi at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build fi`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Arvonlisäverolaki 1501/1993 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/1993/19931501
--   Kirjanpitolaki 1336/1997 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/1997/19971336
--   Kirjanpitoasetus 1339/1997 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/1997/19971339
--   Laki kaupallisten sopimusten maksuehdoista 30/2013 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/2013/20130030
--   Korkolaki 633/1982 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/1982/19820633
--   Laki saatavien perinnästä 513/1999 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/1999/19990513
--   Laki hankintayksiköiden ja elinkeinonharjoittajien sähköisestä laskutuksesta 241/2019 (Oikeusministeriö — Finlex)
--     https://www.finlex.fi/fi/laki/ajantasa/2019/20190241
--   VAT rates (Verohallinto)
--     https://www.vero.fi/en/businesses-and-corporations/taxes-and-charges/vat/rates-of-vat/
--   When to file and pay VAT (Verohallinto)
--     https://www.vero.fi/en/businesses-and-corporations/taxes-and-charges/vat/when-to-file-and-pay/
--   Return for self-assessed taxes, VAT (VSRALVKV) — Description of the data file (Verohallinto)
--     https://www.vero.fi/contentassets/ef5905e0f5b74bcba89aa9ba9c34015d/finnish-tax-administration_description-of-the-data-file_vsralvkv_290824.pdf
--   Laskutusvaatimukset arvonlisäverotuksessa (Verohallinto)
--     https://www.vero.fi/syventavat-vero-ohjeet/ohje-hakusivu/48090/laskutusvaatimukset_arvonlisaverotukses/
--   OmaVero — palvelu, jossa arvonlisäveroilmoitus annetaan (Verohallinto)
--     https://www.vero.fi/omavero/
--   Peppol BIS Billing 3.0 — Electronic Address Scheme code list (FI:OVT2, 0216) (OpenPeppol AISBL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   EN 16931-1 — European e-invoicing semantic data model and Directive 2014/55/EU conformity (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — Duty or tax or fee category code list (BT-118 and BT-151), subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — VAT exemption reason code list (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('FI', 'Finland', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '9161402038ff71af01a28851fd5feef4747ebfc7f683c6074b40750c03517ad7', '[{"key":"avl","title":"Arvonlisäverolaki 1501/1993","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/1993/19931501","consulted_on":"2026-09-25","kind":"law"},{"key":"kpl","title":"Kirjanpitolaki 1336/1997","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/1997/19971336","consulted_on":"2026-09-25","kind":"law"},{"key":"kpa","title":"Kirjanpitoasetus 1339/1997","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/1997/19971339","consulted_on":"2026-09-25","kind":"regulation"},{"key":"maksuehtolaki","title":"Laki kaupallisten sopimusten maksuehdoista 30/2013","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/2013/20130030","consulted_on":"2026-09-25","kind":"law"},{"key":"korkolaki","title":"Korkolaki 633/1982","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/1982/19820633","consulted_on":"2026-09-25","kind":"law"},{"key":"perintalaki","title":"Laki saatavien perinnästä 513/1999","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/1999/19990513","consulted_on":"2026-09-25","kind":"law"},{"key":"sahkoinen-laskutus","title":"Laki hankintayksiköiden ja elinkeinonharjoittajien sähköisestä laskutuksesta 241/2019","publisher":"Oikeusministeriö — Finlex","url":"https://www.finlex.fi/fi/laki/ajantasa/2019/20190241","consulted_on":"2026-09-25","kind":"law"},{"key":"vero-alv-rates","title":"VAT rates","publisher":"Verohallinto","url":"https://www.vero.fi/en/businesses-and-corporations/taxes-and-charges/vat/rates-of-vat/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vero-filing","title":"When to file and pay VAT","publisher":"Verohallinto","url":"https://www.vero.fi/en/businesses-and-corporations/taxes-and-charges/vat/when-to-file-and-pay/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"vero-vsralvkv","title":"Return for self-assessed taxes, VAT (VSRALVKV) — Description of the data file","publisher":"Verohallinto","url":"https://www.vero.fi/contentassets/ef5905e0f5b74bcba89aa9ba9c34015d/finnish-tax-administration_description-of-the-data-file_vsralvkv_290824.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"vero-laskutus","title":"Laskutusvaatimukset arvonlisäverotuksessa","publisher":"Verohallinto","url":"https://www.vero.fi/syventavat-vero-ohjeet/ohje-hakusivu/48090/laskutusvaatimukset_arvonlisaverotukses/","consulted_on":"2026-09-25","kind":"guidance"},{"key":"omavero","title":"OmaVero — palvelu, jossa arvonlisäveroilmoitus annetaan","publisher":"Verohallinto","url":"https://www.vero.fi/omavero/","consulted_on":"2026-09-25","kind":"portal"},{"key":"peppol-eas","title":"Peppol BIS Billing 3.0 — Electronic Address Scheme code list (FI:OVT2, 0216)","publisher":"OpenPeppol AISBL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-25","kind":"standard"},{"key":"en-16931","title":"EN 16931-1 — European e-invoicing semantic data model and Directive 2014/55/EU conformity","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — Duty or tax or fee category code list (BT-118 and BT-151), subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — VAT exemption reason code list (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('FI', 'default', 'Suomalaisen pien- ja keskisuuren kirjanpitovelvollisen tilikartta', '{"en":"Finnish chart of accounts for small and medium-sized entities"}'::jsonb, true, 'companies', array['FI-KPA-BS', 'FI-KPA-IS']::text[], null, 'Kirjanpitolaki 1336/1997, 2 luku 2 § — kirjanpitovelvollisella tulee olla kultakin tilikaudelta selkeä ja riittävästi eritelty tililuettelo, joka selittää tilien sisällön; Suomessa ei ole lailla säädettyä yhtenäistä tilikarttaa, vaan jokainen kirjanpitovelvollinen laatii omansa. Tämä tilikartta on pakin oma, laadittu noudattamaan yleisesti käytettyä nelinumeroista luokittelua (1 vastaavaa, 2 vastattavaa, 3 liikevaihto, 4 aineet ja palvelut, 5 henkilöstökulut, 6 poistot, 7 muut kulut, 8 rahoituserät, 9 tilinpäätössiirrot ja verot), joka seuraa kirjanpitoasetuksen tuloslaskelma- ja tasekaavojen omaa järjestystä ja jota useimmat suomalaiset kirjanpito-ohjelmat ja -oppikirjat käyttävät oletuksena.', 'kpl')
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
  ('FI', 'default', '1000', 'Kehittämismenot', '{"en":"Development costs"}'::jsonb, 'asset_fixed', false, null, 10),
  ('FI', 'default', '1010', 'Aineettomat oikeudet', '{"en":"Intangible rights"}'::jsonb, 'asset_fixed', false, null, 20),
  ('FI', 'default', '1020', 'Liikearvo', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 30),
  ('FI', 'default', '1030', 'Muut pitkävaikutteiset menot', '{"en":"Other capitalised long-term expenditure"}'::jsonb, 'asset_fixed', false, null, 40),
  ('FI', 'default', '1040', 'Ennakkomaksut (aineettomat hyödykkeet)', '{"en":"Advances paid (intangible assets)"}'::jsonb, 'asset_fixed', false, null, 50),
  ('FI', 'default', '1050', 'Aineettomien hyödykkeiden kertyneet poistot', '{"en":"Accumulated amortisation of intangible assets"}'::jsonb, 'asset_fixed', false, null, 60),
  ('FI', 'default', '1100', 'Maa- ja vesialueet', '{"en":"Land and water areas"}'::jsonb, 'asset_fixed', false, null, 70),
  ('FI', 'default', '1110', 'Rakennukset ja rakennelmat', '{"en":"Buildings and structures"}'::jsonb, 'asset_fixed', false, null, 80),
  ('FI', 'default', '1115', 'Rakennusten kertyneet poistot', '{"en":"Accumulated depreciation of buildings"}'::jsonb, 'asset_fixed', false, null, 90),
  ('FI', 'default', '1120', 'Koneet ja kalusto', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 100),
  ('FI', 'default', '1125', 'Koneiden ja kaluston kertyneet poistot', '{"en":"Accumulated depreciation of machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 110),
  ('FI', 'default', '1130', 'Muut aineelliset hyödykkeet', '{"en":"Other tangible assets"}'::jsonb, 'asset_fixed', false, null, 120),
  ('FI', 'default', '1135', 'Muiden aineellisten hyödykkeiden kertyneet poistot', '{"en":"Accumulated depreciation of other tangible assets"}'::jsonb, 'asset_fixed', false, null, 130),
  ('FI', 'default', '1140', 'Ennakkomaksut ja keskeneräiset hankinnat', '{"en":"Advances paid and construction in progress"}'::jsonb, 'asset_fixed', false, null, 140),
  ('FI', 'default', '1200', 'Osuudet saman konsernin yrityksissä', '{"en":"Shares in group undertakings"}'::jsonb, 'asset_non_current', false, null, 150),
  ('FI', 'default', '1210', 'Saamiset saman konsernin yrityksiltä', '{"en":"Receivables from group undertakings"}'::jsonb, 'asset_non_current', false, null, 160),
  ('FI', 'default', '1220', 'Osuudet omistusyhteysyrityksissä', '{"en":"Shares in participating interests"}'::jsonb, 'asset_non_current', false, null, 170),
  ('FI', 'default', '1230', 'Saamiset omistusyhteysyrityksiltä', '{"en":"Receivables from participating interests"}'::jsonb, 'asset_non_current', false, null, 180),
  ('FI', 'default', '1240', 'Muut osakkeet ja osuudet', '{"en":"Other shares and holdings"}'::jsonb, 'asset_non_current', false, null, 190),
  ('FI', 'default', '1250', 'Muut saamiset (pitkäaikaiset)', '{"en":"Other receivables (non-current)"}'::jsonb, 'asset_non_current', false, null, 200),
  ('FI', 'default', '1300', 'Aineet ja tarvikkeet', '{"en":"Raw materials and consumables"}'::jsonb, 'asset_current', false, null, 210),
  ('FI', 'default', '1310', 'Keskeneräiset tuotteet', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 220),
  ('FI', 'default', '1320', 'Valmiit tuotteet/tavarat', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 230),
  ('FI', 'default', '1330', 'Muu vaihto-omaisuus', '{"en":"Other inventories"}'::jsonb, 'asset_current', false, null, 240),
  ('FI', 'default', '1340', 'Ennakkomaksut (vaihto-omaisuus)', '{"en":"Advances paid (inventories)"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('FI', 'default', '1500', 'Myyntisaamiset', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 260),
  ('FI', 'default', '1510', 'Saamiset saman konsernin yrityksiltä (lyhytaikaiset)', '{"en":"Receivables from group undertakings (current)"}'::jsonb, 'asset_current', false, null, 270),
  ('FI', 'default', '1520', 'Saamiset omistusyhteysyrityksiltä (lyhytaikaiset)', '{"en":"Receivables from participating interests (current)"}'::jsonb, 'asset_current', false, null, 280),
  ('FI', 'default', '1530', 'Lainasaamiset', '{"en":"Loan receivables"}'::jsonb, 'asset_current', false, null, 290),
  ('FI', 'default', '1540', 'Muut saamiset', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 300),
  ('FI', 'default', '1550', 'Maksamattomat osakkeet tai osuudet', '{"en":"Unpaid share capital called"}'::jsonb, 'asset_current', false, null, 310),
  ('FI', 'default', '1560', 'Siirtosaamiset', '{"en":"Accrued income and deferred expenses"}'::jsonb, 'asset_prepayments', false, null, 320),
  ('FI', 'default', '1590', 'Arvonlisäverosaaminen — annetun ilmoituksen saldo', '{"en":"VAT refund claim — balance of a filed return"}'::jsonb, 'asset_current', true, null, 330),
  ('FI', 'default', '1600', 'Rahoitusarvopaperit', '{"en":"Current investments"}'::jsonb, 'asset_current', false, null, 340),
  ('FI', 'default', '1700', 'Kassa', '{"en":"Cash in hand"}'::jsonb, 'asset_cash', false, null, 350),
  ('FI', 'default', '1710', 'Pankkitili', '{"en":"Bank account"}'::jsonb, 'asset_cash', false, null, 360),
  ('FI', 'default', '1720', 'Pankkitili valuuttamääräinen', '{"en":"Bank account in foreign currency"}'::jsonb, 'asset_cash', false, null, 370),
  ('FI', 'default', '2000', 'Osake- tai osuuspääoma', '{"en":"Share or cooperative capital"}'::jsonb, 'equity', false, null, 380),
  ('FI', 'default', '2010', 'Ylikurssirahasto', '{"en":"Share premium account"}'::jsonb, 'equity', false, null, 390),
  ('FI', 'default', '2020', 'Arvonkorotusrahasto', '{"en":"Revaluation reserve"}'::jsonb, 'equity', false, null, 400),
  ('FI', 'default', '2030', 'Muut rahastot', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 410),
  ('FI', 'default', '2040', 'Edellisten tilikausien voitto (tappio)', '{"en":"Retained earnings (accumulated deficit)"}'::jsonb, 'equity_retained', false, null, 420),
  ('FI', 'default', '2050', 'Tilikauden voitto (tappio)', '{"en":"Profit (loss) for the financial year"}'::jsonb, 'equity_retained', false, null, 430),
  ('FI', 'default', '2100', 'Poistoero', '{"en":"Depreciation difference"}'::jsonb, 'liability_non_current', false, null, 440),
  ('FI', 'default', '2110', 'Vapaaehtoiset varaukset', '{"en":"Voluntary provisions"}'::jsonb, 'liability_non_current', false, null, 450),
  ('FI', 'default', '2150', 'Pakolliset varaukset', '{"en":"Compulsory provisions"}'::jsonb, 'liability_non_current', false, null, 460),
  ('FI', 'default', '2200', 'Joukkovelkakirjalainat', '{"en":"Bonds"}'::jsonb, 'liability_non_current', false, null, 470),
  ('FI', 'default', '2210', 'Lainat rahoituslaitoksilta (pitkäaikaiset)', '{"en":"Loans from credit institutions (non-current)"}'::jsonb, 'liability_non_current', false, null, 480),
  ('FI', 'default', '2220', 'Eläkelainat', '{"en":"Pension loans"}'::jsonb, 'liability_non_current', false, null, 490),
  ('FI', 'default', '2230', 'Saadut ennakot (pitkäaikaiset)', '{"en":"Advances received (non-current)"}'::jsonb, 'liability_non_current', false, null, 500),
  ('FI', 'default', '2240', 'Ostovelat (pitkäaikaiset)', '{"en":"Trade payables (non-current)"}'::jsonb, 'liability_non_current', false, null, 510),
  ('FI', 'default', '2250', 'Velat saman konsernin yrityksille (pitkäaikaiset)', '{"en":"Payables to group undertakings (non-current)"}'::jsonb, 'liability_non_current', false, null, 520),
  ('FI', 'default', '2260', 'Muut pitkäaikaiset velat', '{"en":"Other non-current payables"}'::jsonb, 'liability_non_current', false, null, 530),
  ('FI', 'default', '2300', 'Lainat rahoituslaitoksilta (lyhytaikaiset)', '{"en":"Loans from credit institutions (current)"}'::jsonb, 'liability_current', false, null, 540),
  ('FI', 'default', '2310', 'Saadut ennakot (lyhytaikaiset)', '{"en":"Advances received (current)"}'::jsonb, 'liability_current', false, null, 550),
  ('FI', 'default', '2320', 'Ostovelat', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 560),
  ('FI', 'default', '2330', 'Velat saman konsernin yrityksille (lyhytaikaiset)', '{"en":"Payables to group undertakings (current)"}'::jsonb, 'liability_current', false, null, 570),
  ('FI', 'default', '2340', 'Palkkavelka', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', false, null, 580),
  ('FI', 'default', '2345', 'Ennakonpidätysvelka', '{"en":"Withheld tax payable"}'::jsonb, 'liability_current', false, null, 590),
  ('FI', 'default', '2350', 'Sosiaaliturvamaksuvelka', '{"en":"Social security contributions payable"}'::jsonb, 'liability_current', false, null, 600),
  ('FI', 'default', '2360', 'Muut lyhytaikaiset velat', '{"en":"Other current payables"}'::jsonb, 'liability_current', false, null, 610),
  ('FI', 'default', '2365', 'Selvittämättömät maksut', '{"en":"Unidentified payments"}'::jsonb, 'liability_current', false, null, 620),
  ('FI', 'default', '2370', 'Siirtovelat', '{"en":"Accrued liabilities and deferred income"}'::jsonb, 'liability_current', false, null, 630),
  ('FI', 'default', '2450', 'Myynnin arvonlisäverovelka', '{"en":"Output VAT"}'::jsonb, 'liability_current', false, null, 640),
  ('FI', 'default', '2455', 'Ostojen arvonlisäverosaaminen', '{"en":"Input VAT"}'::jsonb, 'asset_current', false, null, 650),
  ('FI', 'default', '2460', 'Arvonlisäverovelka — annetun ilmoituksen saldo', '{"en":"VAT payable — balance of a filed return"}'::jsonb, 'liability_current', true, null, 660),
  ('FI', 'default', '3000', 'Myynti kotimaahan', '{"en":"Domestic sales"}'::jsonb, 'income', false, null, 670),
  ('FI', 'default', '3010', 'Myynti Euroopan unionin alueelle', '{"en":"Sales to the European Union"}'::jsonb, 'income', false, null, 680),
  ('FI', 'default', '3020', 'Vienti Euroopan unionin ulkopuolelle', '{"en":"Export outside the European Union"}'::jsonb, 'income', false, null, 690),
  ('FI', 'default', '3030', 'Verottomaan toimintaan liittyvä myynti', '{"en":"Sales relating to exempt activity"}'::jsonb, 'income', false, null, 700),
  ('FI', 'default', '3100', 'Valmiiden ja keskeneräisten tuotteiden varastojen muutos', '{"en":"Change in inventories of finished and unfinished goods"}'::jsonb, 'income_other', false, null, 710),
  ('FI', 'default', '3110', 'Valmistus omaan käyttöön', '{"en":"Production for own use"}'::jsonb, 'income_other', false, null, 720),
  ('FI', 'default', '3200', 'Liiketoiminnan muut tuotot', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 730),
  ('FI', 'default', '3210', 'Käyttöomaisuuden myyntivoitot', '{"en":"Gains on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 740),
  ('FI', 'default', '4000', 'Ostot tilikauden aikana', '{"en":"Purchases during the financial year"}'::jsonb, 'expense_direct_cost', false, null, 750),
  ('FI', 'default', '4010', 'Varastojen muutos', '{"en":"Change in inventories"}'::jsonb, 'expense_direct_cost', false, null, 760),
  ('FI', 'default', '4100', 'Ulkopuoliset palvelut', '{"en":"External services"}'::jsonb, 'expense_direct_cost', false, null, 770),
  ('FI', 'default', '5000', 'Palkat ja palkkiot', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, null, 780),
  ('FI', 'default', '5010', 'Eläkekulut', '{"en":"Pension costs"}'::jsonb, 'expense', false, null, 790),
  ('FI', 'default', '5020', 'Muut henkilösivukulut', '{"en":"Other indirect employee costs"}'::jsonb, 'expense', false, null, 800),
  ('FI', 'default', '6000', 'Suunnitelman mukaiset poistot', '{"en":"Depreciation according to plan"}'::jsonb, 'expense_depreciation', false, null, 810),
  ('FI', 'default', '6010', 'Arvonalentumiset pysyvien vastaavien hyödykkeistä', '{"en":"Impairment of non-current assets"}'::jsonb, 'expense_depreciation', false, null, 820),
  ('FI', 'default', '7000', 'Vuokrat', '{"en":"Rent"}'::jsonb, 'expense', false, null, 830),
  ('FI', 'default', '7010', 'Sähkö ja muu energia', '{"en":"Electricity and other energy"}'::jsonb, 'expense', false, null, 840),
  ('FI', 'default', '7020', 'Tietoliikenne- ja tietotekniikkakulut', '{"en":"Telecommunications and IT costs"}'::jsonb, 'expense', false, null, 850),
  ('FI', 'default', '7030', 'Matkustuskulut', '{"en":"Travel costs"}'::jsonb, 'expense', false, null, 860),
  ('FI', 'default', '7040', 'Markkinointikulut', '{"en":"Marketing costs"}'::jsonb, 'expense', false, null, 870),
  ('FI', 'default', '7050', 'Toimistokulut', '{"en":"Office costs"}'::jsonb, 'expense', false, null, 880),
  ('FI', 'default', '7060', 'Asiantuntijapalvelut', '{"en":"Professional services"}'::jsonb, 'expense', false, null, 890),
  ('FI', 'default', '7070', 'Koulutuskulut', '{"en":"Training costs"}'::jsonb, 'expense', false, null, 900),
  ('FI', 'default', '7080', 'Vakuutukset', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 910),
  ('FI', 'default', '7090', 'Pankkikulut', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 920),
  ('FI', 'default', '7100', 'Edustuskulut', '{"en":"Entertainment costs"}'::jsonb, 'expense', false, null, 930),
  ('FI', 'default', '7110', 'Ajoneuvokulut', '{"en":"Vehicle costs"}'::jsonb, 'expense', false, null, 940),
  ('FI', 'default', '7200', 'Muut liiketoiminnan kulut', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, null, 950),
  ('FI', 'default', '7900', 'Käyttöomaisuuden myyntitappiot', '{"en":"Losses on disposal of fixed assets"}'::jsonb, 'expense', false, null, 960),
  ('FI', 'default', '7910', 'Pyöristyserot', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 970),
  ('FI', 'default', '8000', 'Korkotuotot', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 980),
  ('FI', 'default', '8010', 'Muut rahoitustuotot', '{"en":"Other financial income"}'::jsonb, 'income_other', false, null, 990),
  ('FI', 'default', '8020', 'Kurssivoitot', '{"en":"Exchange gains"}'::jsonb, 'income_other', false, null, 1000),
  ('FI', 'default', '8100', 'Korkokulut', '{"en":"Interest expenses"}'::jsonb, 'expense', false, null, 1010),
  ('FI', 'default', '8110', 'Muut rahoituskulut', '{"en":"Other financial expenses"}'::jsonb, 'expense', false, null, 1020),
  ('FI', 'default', '8120', 'Kurssitappiot', '{"en":"Exchange losses"}'::jsonb, 'expense', false, null, 1030),
  ('FI', 'default', '9000', 'Tilinpäätössiirrot', '{"en":"Appropriations"}'::jsonb, 'expense', false, null, 1040),
  ('FI', 'default', '9100', 'Tuloverot', '{"en":"Income taxes"}'::jsonb, 'expense', false, null, 1050),
  ('FI', 'default', '9110', 'Muut välittömät verot', '{"en":"Other direct taxes"}'::jsonb, 'expense', false, null, 1060)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('FI', 'ALK', 'Alkusaldot', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('FI', 'KAS', 'Kassapäiväkirja', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('FI', 'MUU', 'Muistiotositteet', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('FI', 'MYY', 'Myyntipäiväkirja', '{"en":"Sales journal"}'::jsonb, 'sales', 10),
  ('FI', 'OST', 'Ostopäiväkirja', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('FI', 'PNK', 'Pankkipäiväkirja', '{"en":"Bank journal"}'::jsonb, 'bank', 30)
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
  ('FI', 'FI-P-10', 'Osto 10 %', '{"en":"Purchase 10%"}'::jsonb, 'Sanoma- ja aikakauslehden hankinta, täysi vähennysoikeus', 'percent', 10, 'purchase', 'domestic', date '2025-01-01', null, 'Arvonlisäverolaki 85 a §, sellaisena kuin se on laissa 691/2024, yhdessä 102 §:n kanssa.', 'S', null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-135', 'Osto 13,5 %', '{"en":"Purchase 13.5%"}'::jsonb, 'Kotimainen hankinta, täysi vähennysoikeus', 'percent', 13.5, 'purchase', 'domestic', date '2026-01-01', null, 'Arvonlisäverolaki 85 §, sellaisena kuin se on laissa 1358/2025, yhdessä 102 §:n kanssa.', 'S', null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-14', 'Osto 14 %', '{"en":"Purchase 14%"}'::jsonb, 'Kotimainen hankinta 1.1.2025–31.12.2025, täysi vähennysoikeus', 'percent', 14, 'purchase', 'domestic', date '2025-01-01', date '2025-12-31', 'Arvonlisäverolaki 85 §, sellaisena kuin se oli laissa 691/2024, yhdessä 102 §:n kanssa.', 'S', null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-24', 'Osto 24 %', '{"en":"Purchase 24%"}'::jsonb, 'Kotimainen hankinta 1.1.2013–31.8.2024, täysi vähennysoikeus', 'percent', 24, 'purchase', 'domestic', date '2013-01-01', date '2024-08-31', 'Arvonlisäverolaki 84 §, sellaisena kuin se oli laissa 706/2012, yhdessä 102 §:n kanssa.', 'S', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-255', 'Osto 25,5 %', '{"en":"Purchase 25.5%"}'::jsonb, 'Kotimainen hankinta, täysi vähennysoikeus', 'percent', 25.5, 'purchase', 'domestic', date '2024-09-01', null, 'Arvonlisäverolaki 84 § yhdessä 102 §:n kanssa — verovelvollinen saa vähentää verollista liiketoimintaa varten hankkimastaan tavarasta tai palvelusta suoritettavan veron.', 'S', null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-AUTO-ND', 'Henkilöauton hankinta 25,5 %, ei vähennysoikeutta', '{"en":"Acquisition of a passenger car 25.5%, no right of deduction"}'::jsonb, 'Henkilöauto, joka ei ole yksinomaan vähennykseen oikeuttavassa käytössä (jälleenmyynti, vuokraus, henkilökuljetus, ajo-opetus)', 'percent', 25.5, 'purchase', 'domestic', date '2024-09-01', null, 'Arvonlisäverolaki 114 § 1 momentti 5 kohta — vähennystä ei saa tehdä, kun hankinta koskee henkilöautoa ja siihen tai sen käyttöön liittyviä tavaroita ja palveluja, ellei auto ole yksinomaan vähennykseen oikeuttavassa käytössä (Verohallinnon ohje: jälleenmyynti, vuokraustoiminta, henkilökuljetus tai ajo-opetus).', 'S', null, 200, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-EDUSTUS', 'Edustuskulun hankinta 25,5 %, ei vähennysoikeutta', '{"en":"Acquisition of entertainment costs 25.5%, no right of deduction"}'::jsonb, 'Edustustarkoitukseen käytettävä tavara tai palvelu', 'percent', 25.5, 'purchase', 'domestic', date '2024-09-01', null, 'Arvonlisäverolaki 114 § 1 momentti 3 kohta — vähennystä ei saa tehdä, kun hankinta koskee edustustarkoitukseen käytettäviä tavaroita ja palveluja.', 'S', null, 210, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-EU-G', 'Tavaran yhteisöhankinta 25,5 %', '{"en":"Intra-Community acquisition of goods 25.5%"}'::jsonb, 'Ostaja tilittää veron itse; vähennysoikeus samassa ilmoituksessa', 'percent', 25.5, 'purchase', 'intracom_acquisition_goods', date '2024-09-01', null, 'Arvonlisäverolaki 1 § 1 momentti 3 kohta ja 26 a § — veroa suoritetaan tavaran yhteisöhankinnasta; 2 a § — velvollinen suorittamaan veron yhteisöhankinnasta on ostaja; 102 § — vero on samalla ilmoituksella vähennyskelpoinen, jos hankinta tehdään verollista liiketoimintaa varten.', 'K', 'VATEX-EU-IC', 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-EU-S', 'Palvelun osto toisesta jäsenvaltiosta, käännetty verovelvollisuus 25,5 %', '{"en":"Services received from another Member State, reverse charge 25.5%"}'::jsonb, 'Yleisen säännön mukainen palvelun osto; ostaja tilittää veron itse ja vähentää sen samassa ilmoituksessa', 'percent', 25.5, 'purchase', 'intracom_acquisition_services', date '2024-09-01', null, 'Arvonlisäverolaki 9 § yhdessä 65 §:n kanssa — palvelu on myyty Suomessa, kun se on luovutettu täällä olevaan kiinteään toimipaikkaan tai, jollei toimipaikkaa ole, ostajan kotipaikkaan; jos myyjä on ulkomaalainen, jolla ei ole Suomessa kiinteää toimipaikkaa, verovelvollinen on ostaja. 102 § — sama ilmoitus vähentää veron.', 'K', 'VATEX-EU-IC', 180, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-RAKENNUS', 'Rakentamispalvelun osto, käännetty verovelvollisuus 25,5 %', '{"en":"Purchase of construction services, reverse charge 25.5%"}'::jsonb, 'Ostaja tilittää veron itse ja vähentää sen samassa ilmoituksessa', 'percent', 25.5, 'purchase', 'domestic_reverse_charge', date '2024-09-01', null, 'Arvonlisäverolaki 8 c § 1 momentti — rakentamispalvelun ostajana toimiva elinkeinonharjoittaja on verovelvollinen, jos hän muutoin kuin satunnaisesti myy rakentamispalveluja; 102 § — sama ilmoitus vähentää veron, jos hankinta tehdään verollista liiketoimintaa varten. Säännös lisättiin lailla 686/2010, voimaan 1.4.2011.', 'AE', 'VATEX-EU-AE', 190, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-P-VAPAA', 'Veroton hankinta', '{"en":"Exempt acquisition"}'::jsonb, 'Lasku ilman arvonlisäveroa', 'percent', 0, 'purchase', 'exempt', date '1994-06-01', null, 'Arvonlisäverolaki 27, 34, 39, 41 tai 44 § — myyjän veroton myynti; ostajan laskulla ei ole arvonlisäveroa. Myyjän valitsema peruste (132 vai 135 artikla) ei ole ostajan kirjanpidosta pääteltävissä, joten sitä ei kirjata tähän ostoveroon.', null, null, 220, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-0-EXP', 'Vienti Euroopan unionin ulkopuolelle', '{"en":"Export outside the European Union"}'::jsonb, 'Tavaran myynti kuljetettuna Euroopan unionin ulkopuolelle', 'percent', 0, 'sale', 'export', date '1994-06-01', null, 'Arvonlisäverolaki 70 § 1 momentti 1 kohta — veroa ei suoriteta tavaran myynnistä, kun myyjä tai joku muu hänen puolestaan kuljettaa tavaran Euroopan unionin ulkopuolelle. Pykälä on ollut arvonlisäverolaissa sen alkuperäisestä, 1.6.1994 voimaan tulleesta sanamuodosta lähtien.', 'G', 'VATEX-EU-G', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-0-ICG', 'Tavaran yhteisömyynti', '{"en":"Intra-Community supply of goods"}'::jsonb, 'Tavaran myynti kuljetettuna Suomesta toiseen jäsenvaltioon arvonlisäverovelvolliselle ostajalle', 'percent', 0, 'sale', 'intracom_goods', date '1995-01-01', null, 'Arvonlisäverolaki 72 a § — veroa ei suoriteta 72 b §:ssä tarkoitetusta tavaran yhteisömyynnistä; 72 b § — yhteisömyynnillä tarkoitetaan irtaimen esineen myyntiä, jos myyjä, ostaja tai joku muu heidän puolestaan kuljettaa esineen ostajalle Suomesta toiseen jäsenvaltioon. Neuvoston direktiivin 2006/112/EY 138 artikla. Suomi on ollut Euroopan unionin jäsen 1.1.1995 alkaen.', 'K', 'VATEX-EU-IC', 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-0-ICS', 'Palvelun myynti toiseen jäsenvaltioon, käännetty verovelvollisuus', '{"en":"Supply of services to another Member State, reverse charge"}'::jsonb, 'Yleisen säännön mukainen palvelun myynti toisessa jäsenvaltiossa olevalle elinkeinonharjoittajalle, joka tilittää veron itse', 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Arvonlisäverolaki 65 § — palvelu on myyty Suomen ulkopuolella, jos se luovutetaan ostajan kiinteään toimipaikkaan toisessa valtiossa tai, jollei palvelua luovuteta kiinteään toimipaikkaan, ostajan kotipaikkaan; 68 a § vastaavasti ulkomaille sijoittautuneelle ostajalle. Neuvoston direktiivin 2006/112/EY 44 ja 196 artikla, sellaisina kuin ne ovat direktiivissä 2008/8/EY, sovellettu 1.1.2010 alkaen.', 'K', 'VATEX-EU-IC', 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-10', 'Myynti 10 %', '{"en":"Sale 10%"}'::jsonb, 'Sanoma- ja aikakauslehdet fyysisellä alustalla tai sähköisesti luovutettuna', 'percent', 10, 'sale', 'domestic', date '2025-01-01', null, 'Arvonlisäverolaki 85 a §, sellaisena kuin se on laissa 691/2024 (voimaan 1.1.2025) ja laissa 921/2024 (voimaan 1.1.2026, Yleisradion maksu poistettu tästä pykälästä) — 10 prosentin verokanta fyysisellä alustalla olevien tai sähköisesti luovutettavien sanoma- ja aikakauslehtien myynnistä, lukuun ottamatta pääasiallisesti mainoksia tai yksityistä käyttöä varten tarkoitettua ääni- tai kuvatallennetta sisältäviä julkaisuja. Verokanta itsessään ei ole tälle myynnille uusi 1.1.2025: pykälän 85 a soveltamisala vain supistui tähän yhteen ryhmään, kun muut ryhmät siirtyivät 85 §:ään.', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-135', 'Myynti 13,5 %', '{"en":"Sale 13.5%"}'::jsonb, 'Elintarvikkeet, ravintola- ja ateriapalvelut, rehu, henkilökuljetus, majoitustilan käyttöoikeus, lääkkeet, kirjat, liikunta- ja kulttuuripalvelut, taide-esineet, tekijänoikeuskorvaukset sekä Yleisradio Oy:n televisio- ja radiorahastoon suoritettava maksu', 'percent', 13.5, 'sale', 'domestic', date '2026-01-01', null, 'Arvonlisäverolaki 85 §, sellaisena kuin se on laissa 1358/2025 (voimaan 1.1.2026, verokanta 14 prosentista 13,5 prosenttiin) ja laissa 921/2024 (voimaan 1.1.2026, Yleisradio Oy:n tv- ja radiorahaston maksu siirretty 85 a §:stä 85 §:ään). Soveltamisalaa laajennettiin 1.1.2025 alkaen laissa 691/2024, joka siirsi henkilökuljetuksen, majoituksen, lääkkeet, kirjat, liikunta- ja kulttuuripalvelut, taide-esineet ja tekijänoikeuskorvaukset aiemmasta 10 prosentin verokannasta tähän verokantaan.', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-14', 'Myynti 14 %', '{"en":"Sale 14%"}'::jsonb, 'Sama soveltamisala kuin FI-S-135:llä, verokanta 1.1.2025–31.12.2025', 'percent', 14, 'sale', 'domestic', date '2025-01-01', date '2025-12-31', 'Arvonlisäverolaki 85 §, sellaisena kuin se oli laissa 691/2024, voimaan 1.1.2025 — verokanta 14 prosenttia. Korvattu 1.1.2026 laissa 1358/2025 verokannalla 13,5 prosenttia.', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-24', 'Myynti 24 %', '{"en":"Sale 24%"}'::jsonb, 'Yleinen verokanta 1.1.2013–31.8.2024', 'percent', 24, 'sale', 'domestic', date '2013-01-01', date '2024-08-31', 'Arvonlisäverolaki 84 §, sellaisena kuin se oli laissa 706/2012, voimaan 1.1.2013 — yleinen verokanta 24 prosenttia. Kumottu 1.9.2024 laissa 462/2024.', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-255', 'Myynti 25,5 %', '{"en":"Sale 25.5%"}'::jsonb, 'Yleinen verokanta', 'percent', 25.5, 'sale', 'domestic', date '2024-09-01', null, 'Arvonlisäverolaki 84 § — suoritettava vero on 25,5 prosenttia veron perusteesta, ellei 85 tai 85 a §:ssä toisin säädetä. Laki 462/2024, voimaan 1.9.2024. Verokannan soveltaminen määräytyy sen mukaan, milloin tavara on toimitettu tai palvelu suoritettu (15 §), ei laskun päivämäärän mukaan.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-RAKENNUS', 'Rakentamispalvelun myynti, käännetty verovelvollisuus', '{"en":"Sale of construction services, reverse charge"}'::jsonb, 'Ostaja on verovelvollinen arvonlisäverolain 8 c §:n mukaisesti', 'percent', 0, 'sale', 'domestic_reverse_charge', date '2011-04-01', null, 'Arvonlisäverolaki 8 c § 1 momentti — rakentamispalvelun sekä työvoiman vuokrauksen rakentamispalvelua varten myynnistä verovelvollinen on ostaja, jos ostaja on elinkeinonharjoittaja, joka muutoin kuin satunnaisesti myy rakentamispalveluja tai 31 §:n 1 momentin 1 kohdassa tai 33 §:ssä tarkoitettuja kiinteistön luovutuksia. Säännös lisättiin lailla 686/2010, voimaan 1.4.2011.', 'AE', 'VATEX-EU-AE', 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-VAPAA-132', 'Terveyden- ja sairaanhoito sekä koulutus, veroton', '{"en":"Health care and education, exempt"}'::jsonb, 'Veroton toiminta yleisen edun vuoksi', 'percent', 0, 'sale', 'exempt', date '1994-06-01', null, 'Arvonlisäverolaki 34 § — veroa ei suoriteta terveyden- ja sairaanhoitopalvelun myynnistä; 39 § — veroa ei suoriteta koulutuspalvelun myynnistä. Neuvoston direktiivin 2006/112/EY 132 artikla 1 kohta b ja i alakohta.', 'E', 'VATEX-EU-132', 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null),
  ('FI', 'FI-S-VAPAA-135', 'Rahoitus- ja vakuutuspalvelut sekä kiinteistön luovutus, veroton', '{"en":"Financial and insurance services and transfer of real estate, exempt"}'::jsonb, 'Muu direktiivin 135 artiklan mukainen vapautus', 'percent', 0, 'sale', 'exempt', date '1994-06-01', null, 'Arvonlisäverolaki 27 § — veroa ei suoriteta kiinteistön myynnistä eikä maanvuokraoikeuden, huoneenvuokraoikeuden, rasiteoikeuden tai muun niihin verrattavan kiinteistöön kohdistuvan oikeuden luovuttamisesta; 41 § — veroa ei suoriteta rahoituspalvelun myynnistä; 44 § — veroa ei suoriteta vakuutuspalvelun myynnistä ja välityksestä. Neuvoston direktiivin 2006/112/EY 135 artikla 1 kohta a, b–g ja l alakohta.', 'E', 'VATEX-EU-135', 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'avl', null, null, null, null)
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
    ('FI-P-10', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-10', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-135', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-135', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-14', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-14', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-24', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-24', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-255', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-255', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-AUTO-ND', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('FI-P-AUTO-ND', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('FI-P-EDUSTUS', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('FI-P-EDUSTUS', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 10),
    ('FI-P-EU-G', 'invoice', 'base', 100, null, '313', array['313']::text[], 100, 'FI-ALV', 10),
    ('FI-P-EU-G', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-EU-G', 'invoice', 'tax', -100, '2450', '305', array['305']::text[], 100, 'FI-ALV', 20),
    ('FI-P-EU-G', 'credit_note', 'base', 100, null, '313', array['313']::text[], -100, 'FI-ALV', 10),
    ('FI-P-EU-G', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-EU-G', 'credit_note', 'tax', -100, '2450', '305', array['305']::text[], -100, 'FI-ALV', 20),
    ('FI-P-EU-S', 'invoice', 'base', 100, null, '314', array['314']::text[], 100, 'FI-ALV', 10),
    ('FI-P-EU-S', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-EU-S', 'invoice', 'tax', -100, '2450', '306', array['306']::text[], 100, 'FI-ALV', 20),
    ('FI-P-EU-S', 'credit_note', 'base', 100, null, '314', array['314']::text[], -100, 'FI-ALV', 10),
    ('FI-P-EU-S', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-EU-S', 'credit_note', 'tax', -100, '2450', '306', array['306']::text[], -100, 'FI-ALV', 20),
    ('FI-P-RAKENNUS', 'invoice', 'base', 100, null, '320', array['320']::text[], 100, 'FI-ALV', 10),
    ('FI-P-RAKENNUS', 'invoice', 'tax', 100, '2455', '307', array['307']::text[], 100, 'FI-ALV', 10),
    ('FI-P-RAKENNUS', 'invoice', 'tax', -100, '2450', '318', array['318']::text[], 100, 'FI-ALV', 20),
    ('FI-P-RAKENNUS', 'credit_note', 'base', 100, null, '320', array['320']::text[], -100, 'FI-ALV', 10),
    ('FI-P-RAKENNUS', 'credit_note', 'tax', 100, '2455', '307', array['307']::text[], -100, 'FI-ALV', 10),
    ('FI-P-RAKENNUS', 'credit_note', 'tax', -100, '2450', '318', array['318']::text[], -100, 'FI-ALV', 20),
    ('FI-S-0-EXP', 'invoice', 'base', 100, null, '309', array['309']::text[], 100, 'FI-ALV', 10),
    ('FI-S-0-EXP', 'credit_note', 'base', 100, null, '309', array['309']::text[], -100, 'FI-ALV', 10),
    ('FI-S-0-ICG', 'invoice', 'base', 100, null, '311', array['311']::text[], 100, 'FI-ALV', 10),
    ('FI-S-0-ICG', 'credit_note', 'base', 100, null, '311', array['311']::text[], -100, 'FI-ALV', 10),
    ('FI-S-0-ICS', 'invoice', 'base', 100, null, '312', array['312']::text[], 100, 'FI-ALV', 10),
    ('FI-S-0-ICS', 'credit_note', 'base', 100, null, '312', array['312']::text[], -100, 'FI-ALV', 10),
    ('FI-S-10', 'invoice', 'tax', 100, '2450', '303', array['303']::text[], 100, 'FI-ALV', 10),
    ('FI-S-10', 'credit_note', 'tax', 100, '2450', '303', array['303']::text[], -100, 'FI-ALV', 10),
    ('FI-S-135', 'invoice', 'tax', 100, '2450', '302', array['302']::text[], 100, 'FI-ALV', 10),
    ('FI-S-135', 'credit_note', 'tax', 100, '2450', '302', array['302']::text[], -100, 'FI-ALV', 10),
    ('FI-S-14', 'invoice', 'tax', 100, '2450', '302', array['302']::text[], 100, 'FI-ALV', 10),
    ('FI-S-14', 'credit_note', 'tax', 100, '2450', '302', array['302']::text[], -100, 'FI-ALV', 10),
    ('FI-S-24', 'invoice', 'tax', 100, '2450', '301', array['301']::text[], 100, 'FI-ALV', 10),
    ('FI-S-24', 'credit_note', 'tax', 100, '2450', '301', array['301']::text[], -100, 'FI-ALV', 10),
    ('FI-S-255', 'invoice', 'tax', 100, '2450', '301', array['301']::text[], 100, 'FI-ALV', 10),
    ('FI-S-255', 'credit_note', 'tax', 100, '2450', '301', array['301']::text[], -100, 'FI-ALV', 10),
    ('FI-S-RAKENNUS', 'invoice', 'base', 100, null, '319', array['319']::text[], 100, 'FI-ALV', 10),
    ('FI-S-RAKENNUS', 'credit_note', 'base', 100, null, '319', array['319']::text[], -100, 'FI-ALV', 10),
    ('FI-S-VAPAA-132', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('FI-S-VAPAA-132', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('FI-S-VAPAA-135', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('FI-S-VAPAA-135', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'FI' and t.code = v.tax_code
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
  ('FI', 'FI-ALV', 'Arvonlisäveroilmoitus (oma-aloitteisten verojen veroilmoitus, VSRALVKV)', array['month', 'quarter', 'year']::declaration_period[], 'month'::declaration_period, date '2017-01-01', null, 'Laki oma-aloitteisten verojen verotusmenettelystä 768/2016, 11 § — verokausi on kalenterikuukausi, jollei 12 §:ssä toisin säädetä; 12 § 1 momentti — verovelvollinen, jonka kalenterivuoden liikevaihto on enintään 100 000 euroa, voi hakemuksesta siirtyä neljänneskalenterivuoden verokauteen; 2 momentti — liikevaihdoltaan enintään 30 000 euron verovelvollinen voi hakemuksesta siirtyä kalenterivuoden verokauteen. Lomakkeen kohdat noudattavat Verohallinnon julkaisemaa tietuekuvausta VSRALVKV.', true,null, null, null, null, null, null)
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
  ('FI', 'FI-ALV', '301', 'tax', 'Vero kotimaan myynnistä, yleinen verokanta', '{"en":"Tax on domestic sales, standard rate"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 301 "Tax on domestic sales at 24% of 25.5%" — arvonlisäverolain 84 §:n mukainen yleisen verokannan (25,5 % 1.9.2024 alkaen) mukainen vero kotimaan myynnistä. Lomake ei erittele myynnin arvoa verokannoittain, vaan ainoastaan verokannan mukaisen veron.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '302', 'tax', 'Vero kotimaan myynnistä, alempi korotettu verokanta', '{"en":"Tax on domestic sales, upper reduced rate"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 302 "Tax on domestic sales at 14% or 13,5%" — arvonlisäverolain 85 §:n mukainen verokanta (13,5 % 1.1.2026 alkaen, 14 % 1.1.2025–31.12.2025) mukainen vero kotimaan myynnistä.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '303', 'tax', 'Vero kotimaan myynnistä, alennettu verokanta', '{"en":"Tax on domestic sales, lower reduced rate"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 303 "Tax on domestic sales at 10%" — arvonlisäverolain 85 a §:n mukainen 10 prosentin verokanta.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '304', 'tax', 'Vero tavaroiden maahantuonnista Euroopan unionin ulkopuolelta', '{"en":"VAT on import of goods from outside the EU"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 304 "VAT on import of goods from outside the EU". Tämä pakki ei mallinna maahantuontia (ks. README): kohta on kuvattu lomakkeen täydellisyyden vuoksi, mutta mikään vero ei kirjoita siihen.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '305', 'tax', 'Vero tavaraostoista muista EU-maista', '{"en":"Tax on goods purchased from other EU countries"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 305 "Tax on goods purchased from other EU countries" — ostajan itse suorittama vero yhteisöhankinnasta.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '306', 'tax', 'Vero palveluostoista muista EU-maista', '{"en":"Tax on services purchased from other EU countries"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 306 "Tax on services purchased from other EU countries" — ostajan itse suorittama vero yleisen säännön mukaisesta palvelun myynnistä.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '307', 'tax', 'Verokauden vähennettävä vero', '{"en":"Tax deductible for the tax period"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 307 "Tax deductible for the tax period" — arvonlisäverolain 10 luvun mukaan vähennyskelpoinen ostojen vero, jo rajoitusten (114 §) jälkeisenä määränä.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '309', 'base', 'Nollaverokannan alainen myynti', '{"en":"Sales taxable at zero VAT rate"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 309 "Sales taxable at zero VAT rate" — arvonlisäverolain 70 §:n mukainen vienti Euroopan unionin ulkopuolelle ja muu 0-verokannan myynti, joka ei sisälly kohtiin 311 tai 312.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '310', 'base', 'Tavaroiden maahantuonti Euroopan unionin ulkopuolelta', '{"en":"Imports of goods from outside the EU"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 310 "Imports of goods from outside the EU". Tämä pakki ei mallinna maahantuontia (ks. README): kohta on kuvattu lomakkeen täydellisyyden vuoksi, mutta mikään vero ei kirjoita siihen.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '311', 'base', 'Tavaroiden myynti muihin EU-maihin', '{"en":"Sales of goods to other EU countries"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 311 "Sales of goods to other EU countries" — arvonlisäverolain 72 a ja 72 b §:n mukainen yhteisömyynti.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '312', 'base', 'Palveluiden myynti muihin EU-maihin', '{"en":"Sales of services to other EU countries"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 312 "Sales of services to other EU countries" — yleisen säännön mukainen palvelun myynti toisessa jäsenvaltiossa olevalle elinkeinonharjoittajalle, jonka ostaja tilittää veron.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '313', 'base', 'Tavaraostot muista EU-maista', '{"en":"Purchases of goods from other EU countries"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 313 "Purchases of goods from other EU countries" — yhteisöhankinnan arvo.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '314', 'base', 'Palveluostot muista EU-maista', '{"en":"Purchases of services from other EU countries"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 314 "Purchases of services from other EU countries" — yleisen säännön mukaisen ostetun palvelun arvo.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '318', 'tax', 'Vero rakentamispalvelun tai metalliromun ostosta (käännetty verovelvollisuus)', '{"en":"Tax on purchases of construction services/scrap metal (reverse charge)"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 318 "Tax on purchases of construction services/scrap metal (reverse charge)" — arvonlisäverolain 8 c ja 8 d §:n mukainen ostajan itse suorittama vero.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '319', 'base', 'Rakentamispalvelun tai metalliromun myynti (käännetty verovelvollisuus)', '{"en":"Sales of construction services/scrap metal"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 319 "Sales of construction services/scrap metal" — myyjän 8 c tai 8 d §:n perusteella verottomana laskuttama myynti.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '320', 'base', 'Rakentamispalvelun tai metalliromun ostot (käännetty verovelvollisuus)', '{"en":"Purchases of construction services/scrap metal"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 320 "Purchases of construction services/scrap metal" — ostajan 8 c tai 8 d §:n perusteella itse verottaman oston arvo.', 'vero-vsralvkv'),
  ('FI', 'FI-ALV', '308', 'total', 'Maksettava vero / palautukseen oikeuttava vero (-)', '{"en":"Tax payable / negative tax that qualifies for refund"}'::jsonb, 400, null, array['301', '302', '303', '304', '305', '306', '318']::text[], array['307']::text[], null, null, false, false, null, 'VSRALVKV-tietuekuvaus, kohta 308: 301+302+303+304+305+306+318-307. Voi olla negatiivinen, jolloin kyse on palautukseen oikeuttavasta verosta; arvonlisäverolaki 149 §, laki oma-aloitteisten verojen verotusmenettelystä 768/2016.', 'vero-vsralvkv')
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
  ('FI-KPA-BS', 'FI', 'default', 'Tase', 'balance_sheet', 'FI-KPA', date '1998-01-01', null, 'Kirjanpitoasetus 1339/1997, 1 luku 6 § — taseen kaava. Tässä pakissa kaava on esitetty tiivistettynä: kirjanpitoasetuksen omat alaerät (esim. oman pääoman rahastot, vieraan pääoman erät) on yhdistetty yhdeksi riviksi silloin, kun tilikartassa ei ole erillistä tiliä kullekin alaerälle. Rivi 2.2 (Saamiset ja siirtosaamiset) yhdistää kirjanpitoasetuksen pitkä- ja lyhytaikaiset saamiset, koska tilikartta ei erittele niitä.', 'kpa'),
  ('FI-KPA-IS', 'FI', 'default', 'Tuloslaskelma, kululajikohtainen kaava', 'income_statement', 'FI-KPA', date '1998-01-01', null, 'Kirjanpitoasetus 1339/1997, 1 luku 1 § — kululajikohtainen tuloslaskelmakaava. 2 § sallii vaihtoehtoisesti toimintokohtaisen kaavan, jota tämä pakki ei kanna: 1 §:n kaava on yleisimmin käytetty, erityisesti pienemmillä kirjanpitovelvollisilla.', 'kpa')
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
  ('FI-KPA-BS', '1', null, 'A Pysyvät vastaavat', '{"en":"A Non-current assets"}'::jsonb, 10, 1, true, array['1.1', '1.2', '1.3']::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '1.1', '1', 'A I Aineettomat hyödykkeet', '{"en":"A I Intangible assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '1.2', '1', 'A II Aineelliset hyödykkeet', '{"en":"A II Tangible assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '1.3', '1', 'A III Sijoitukset', '{"en":"A III Investments"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '2', null, 'B Vaihtuvat vastaavat', '{"en":"B Current assets"}'::jsonb, 50, 1, true, array['2.1', '2.2', '2.3', '2.4']::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '2.1', '2', 'B I Vaihto-omaisuus', '{"en":"B I Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '2.2', '2', 'B II–III Saamiset ja siirtosaamiset', '{"en":"B II-III Receivables and accrued income"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '2.3', '2', 'B IV Rahoitusarvopaperit', '{"en":"B IV Current investments"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '2.4', '2', 'B V Rahat ja pankkisaamiset', '{"en":"B V Cash and bank"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '3', null, 'VASTAAVAA YHTEENSÄ', '{"en":"TOTAL ASSETS"}'::jsonb, 100, 1, true, array['1', '2']::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4', null, 'A Oma pääoma', '{"en":"A Equity"}'::jsonb, 110, 1, true, array['4.1', '4.2', '4.3', '4.4', '4.5', '4.6']::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4.1', '4', 'A I Osake- tai osuuspääoma', '{"en":"A I Share or cooperative capital"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4.2', '4', 'A II Ylikurssirahasto', '{"en":"A II Share premium account"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4.3', '4', 'A III Arvonkorotusrahasto', '{"en":"A III Revaluation reserve"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4.4', '4', 'A V Muut rahastot', '{"en":"A V Other reserves"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4.5', '4', 'A VI Edellisten tilikausien voitto (tappio)', '{"en":"A VI Retained earnings (accumulated deficit)"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '4.6', '4', 'A VII Tilikauden voitto (tappio)', '{"en":"A VII Profit (loss) for the financial year"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '5', null, 'B Tilinpäätössiirtojen kertymä', '{"en":"B Accumulated appropriations"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '6', null, 'C Pakolliset varaukset', '{"en":"C Compulsory provisions"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '7', null, 'D Vieras pääoma, pitkäaikainen', '{"en":"D Non-current liabilities"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '8', null, 'D Vieras pääoma, lyhytaikainen', '{"en":"D Current liabilities"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-BS', '9', null, 'VASTATTAVAA YHTEENSÄ', '{"en":"TOTAL EQUITY AND LIABILITIES"}'::jsonb, 220, 1, true, array['4', '5', '6', '7', '8']::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '1', null, 'LIIKEVAIHTO', '{"en":"TURNOVER"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '2', null, 'Valmiiden ja keskeneräisten tuotteiden varastojen muutos', '{"en":"Change in inventories of finished and unfinished goods"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '3', null, 'Valmistus omaan käyttöön', '{"en":"Production for own use"}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '4', null, 'Liiketoiminnan muut tuotot', '{"en":"Other operating income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '5', null, 'Materiaalit ja palvelut', '{"en":"Materials and services"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '6', null, 'Henkilöstökulut', '{"en":"Personnel expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '7', null, 'Poistot ja arvonalentumiset', '{"en":"Depreciation and impairment"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '8', null, 'Liiketoiminnan muut kulut', '{"en":"Other operating expenses"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '9', null, 'LIIKEVOITTO (-TAPPIO)', '{"en":"OPERATING PROFIT (LOSS)"}'::jsonb, 90, 1, true, array['1', '2', '3', '4']::text[], array['5', '6', '7', '8']::text[], null, null, null),
  ('FI-KPA-IS', '10.1', null, 'Rahoitustuotot', '{"en":"Financial income"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '10.2', null, 'Rahoituskulut', '{"en":"Financial expenses"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '11', null, 'VOITTO (TAPPIO) ENNEN TILINPÄÄTÖSSIIRTOJA JA VEROJA', '{"en":"PROFIT (LOSS) BEFORE APPROPRIATIONS AND TAXES"}'::jsonb, 120, 1, true, array['9', '10.1']::text[], array['10.2']::text[], null, null, null),
  ('FI-KPA-IS', '12', null, 'Tilinpäätössiirrot', '{"en":"Appropriations"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '13', null, 'Tuloverot', '{"en":"Income taxes"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '14', null, 'Muut välittömät verot', '{"en":"Other direct taxes"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('FI-KPA-IS', '15', null, 'TILIKAUDEN VOITTO (TAPPIO)', '{"en":"PROFIT (LOSS) FOR THE FINANCIAL YEAR"}'::jsonb, 160, 1, true, array['11']::text[], array['12', '13', '14']::text[], null, null, null)
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
    ('FI-KPA-BS', '1.1', 10, 'code_range', '1000', '1099', null, 'any'),
    ('FI-KPA-BS', '1.2', 10, 'code_range', '1100', '1199', null, 'any'),
    ('FI-KPA-BS', '1.3', 10, 'code_range', '1200', '1299', null, 'any'),
    ('FI-KPA-BS', '2.1', 10, 'code_range', '1300', '1399', null, 'any'),
    ('FI-KPA-BS', '2.2', 10, 'code_range', '1500', '1599', null, 'any'),
    ('FI-KPA-BS', '2.2', 20, 'account_code', '2450', null, null, 'debit'),
    ('FI-KPA-BS', '2.2', 30, 'account_code', '2455', null, null, 'debit'),
    ('FI-KPA-BS', '2.3', 10, 'code_range', '1600', '1699', null, 'any'),
    ('FI-KPA-BS', '2.4', 10, 'code_range', '1700', '1799', null, 'any'),
    ('FI-KPA-BS', '4.1', 10, 'account_code', '2000', null, null, 'any'),
    ('FI-KPA-BS', '4.2', 10, 'account_code', '2010', null, null, 'any'),
    ('FI-KPA-BS', '4.3', 10, 'account_code', '2020', null, null, 'any'),
    ('FI-KPA-BS', '4.4', 10, 'account_code', '2030', null, null, 'any'),
    ('FI-KPA-BS', '4.5', 10, 'account_code', '2040', null, null, 'any'),
    ('FI-KPA-BS', '4.6', 10, 'account_code', '2050', null, null, 'any'),
    ('FI-KPA-BS', '5', 10, 'code_range', '2100', '2149', null, 'any'),
    ('FI-KPA-BS', '6', 10, 'code_range', '2150', '2199', null, 'any'),
    ('FI-KPA-BS', '7', 10, 'code_range', '2200', '2299', null, 'any'),
    ('FI-KPA-BS', '8', 10, 'code_range', '2300', '2399', null, 'any'),
    ('FI-KPA-BS', '8', 20, 'account_code', '2450', null, null, 'credit'),
    ('FI-KPA-BS', '8', 30, 'account_code', '2455', null, null, 'credit'),
    ('FI-KPA-BS', '8', 40, 'account_code', '2460', null, null, 'any'),
    ('FI-KPA-IS', '1', 10, 'code_range', '3000', '3099', null, 'any'),
    ('FI-KPA-IS', '2', 10, 'code_range', '3100', '3109', null, 'any'),
    ('FI-KPA-IS', '3', 10, 'code_range', '3110', '3119', null, 'any'),
    ('FI-KPA-IS', '4', 10, 'code_range', '3200', '3299', null, 'any'),
    ('FI-KPA-IS', '5', 10, 'code_range', '4000', '4199', null, 'any'),
    ('FI-KPA-IS', '6', 10, 'code_range', '5000', '5099', null, 'any'),
    ('FI-KPA-IS', '7', 10, 'code_range', '6000', '6099', null, 'any'),
    ('FI-KPA-IS', '8', 10, 'code_range', '7000', '7999', null, 'any'),
    ('FI-KPA-IS', '10.1', 10, 'code_range', '8000', '8099', null, 'any'),
    ('FI-KPA-IS', '10.2', 10, 'code_range', '8100', '8199', null, 'any'),
    ('FI-KPA-IS', '12', 10, 'code_range', '9000', '9099', null, 'any'),
    ('FI-KPA-IS', '13', 10, 'code_range', '9100', '9109', null, 'any'),
    ('FI-KPA-IS', '14', 10, 'code_range', '9110', '9119', null, 'any')
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
  ('FI', 'Finland', '{"en":"Finland"}'::jsonb, array['fi', 'en']::text[], 'EUR', '1500', '2320', '2365', '7910', '2040', '3000', '4000', '1710', '1700', 'MYY', 'OST', 'MUU', 'fi', 'result_accounts', '2050', '2050', null, 'ALK', 'half_up', default, '8020', '8120', null, null, null, null, '2460', '1590', null, 'month'::declaration_period)
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
  late_payment_reference        = 'Korkolaki 633/1982, 6 § — jos eräpäivää ei ole sovittu, viivästyskorkoa on maksettava 30 päivän kuluttua siitä, kun velkoja lähetti laskun; 4 § — viivästyskorko on viitekoron (12 §) lisäksi seitsemän prosenttiyksikköä, ja 4 a § — kaupallisissa sopimuksissa (elinkeinonharjoittajien ja hankintayksiköiden välillä) kahdeksan prosenttiyksikköä; laki kaupallisten sopimusten maksuehdoista 30/2013, 5 § — elinkeinonharjoittajien välillä maksuaika saa ylittää 30 päivää vain, jos siitä on nimenomaisesti sovittu, enintään 60 päivää; laki saatavien perinnästä 513/1999, 10 § — velkojalla on oikeus 40 euron vakiokorvaukseen perintäkuluista heti, kun viivästyskorkoon on oikeus.',
  numbering_legal_reference     = 'Arvonlisäverolaki 209 e § 1 momentti — laskussa on mainittava muun ohella laskun järjestysnumero, joka perustuu yhteen tai useampaan sarjaan ja jolla lasku voidaan yksilöidä. Laki vaatii juoksevan ja yksilöivän numeron, ei tiettyä muotoa eikä katkeamattomuutta, joten numbering on tässä sequential eikä gapless.',
  numbering_source_key          = 'avl',
  payment_terms_legal_reference = 'Korkolaki 633/1982, 6 § yhdessä 4 §:n kanssa; laki kaupallisten sopimusten maksuehdoista 30/2013, 5 § rajoittaa sovitun maksuajan enintään 60 päivään elinkeinonharjoittajien välillä.',
  payment_terms_source_key      = 'maksuehtolaki',
  tax_point_rule                = null,
  tax_point_legal_reference     = null,
  tax_point_source_key          = null,
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'on_request',
  einvoice_legal_reference      = 'Laki hankintayksiköiden ja elinkeinonharjoittajien sähköisestä laskutuksesta 241/2019, 3 § — hankintayksikön on otettava vastaan ja käsiteltävä sähköinen lasku, joka perustuu lain 1397/2016, 1398/2016 tai 1531/2011 mukaiseen hankintaan; voimaan keskushallinnon hankintayksiköille ja yhteishankintayksiköille 1.4.2019, muille hankintayksiköille 1.4.2020 (5 §). 4 § — hankintayksiköllä ja elinkeinonharjoittajalla on oikeus saada pyynnöstä lasku toiselta hankintayksiköltä tai elinkeinonharjoittajalta sähköisenä laskuna, sovellettavissa 1.4.2020 alkaen (5 §): tämä on suomalainen kansallinen laajennus direktiivin 2014/55/EU vähimmäisvaatimukseen (joka koskee vain julkisia hankintayksiköitä ostajana), ei yleinen velvollisuus jokaiselle yritykselle. Laki ei nimeä yksittäistä syntaksia, vaan viittaa eurooppalaiseen standardiin EN 16931 ja komission julkaisemiin syntakseihin: käytännössä Peppol BIS Billing 3.0, Finvoice 3.0 (Finanssiala ry) ja TEAPPSXML 3.0 täyttävät kaikki tämän vaatimuksen rinnakkain, eikä mikään niistä ole ilmoitettu vanhentuneeksi. party_scheme 0216 (OVT-koodi) on Peppolin nykyinen suomalainen osoiteskeema; erillistä ICD-koodia suomalaiselle arvonlisäverotunnisteelle ei Peppolin skeemaluettelossa ole (vat_scheme jää tyhjäksi).',
  einvoice_source_key           = 'sahkoinen-laskutus',
  party_scheme                  = '0216',
  vat_scheme                    = null,
  bank_statement_formats        = array['camt.053', 'camt.052']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'FI';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('FI', 'reverse_charge', 'reverse_charge', 'Käännetty verovelvollisuus', '{"en":"Reverse charge"}'::jsonb, 10, date '1970-01-01', null, 'Arvonlisäverolaki 209 e § 1 momentti 12 kohta — jos verovelvollinen on 2 a, 8 a–8 d tai 9 §:n taikka toisen jäsenvaltion vastaavan säännöksen perusteella ostaja, laskuun on merkittävä "käännetty verovelvollisuus". Verohallinnon ohje suosittaa täsmentämään perusteen, esimerkiksi rakennusalalla "AVL 8 c §".'),
  ('FI', 'late_payment', 'late_payment', 'Maksun viivästyessä myyjällä on oikeus korkolain 4 tai 4 a §:n mukaiseen viivästyskorkoon sekä lain saatavien perinnästä 10 §:n mukaiseen 40 euron vakiokorvaukseen perintäkuluista.', '{"en":"Where payment is late, the seller is entitled to statutory interest under sections 4 or 4a of the Interest Act and to a standard compensation of 40 euros for recovery costs under section 10 of the Debt Collection Act."}'::jsonb, 20, date '1970-01-01', null, 'Korkolaki 633/1982, 4 § ja 4 a §; laki saatavien perinnästä 513/1999, 10 §')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
