-- Ekwo OS — Latvija: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/lv at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build lv`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Pievienotās vērtības nodokļa likums (Latvijas Vēstnesis — likumi.lv)
--     https://likumi.lv/ta/id/253451-pievienotas-vertibas-nodokla-likums
--   Ministru kabineta 2013. gada 15. janvāra noteikumi Nr. 40 "Noteikumi par pievienotās vērtības nodokļa deklarācijām" (Ministru kabinets — likumi.lv)
--     https://likumi.lv/ta/id/254279-noteikumi-par-pievienotas-vertibas-nodokla-deklaracijam
--   Metodiskais materiāls par pievienotās vērtības nodokļa deklarācijas un tās pielikumu aizpildīšanu (aktualizēts 29.05.2026) (Valsts ieņēmumu dienests)
--     https://www.vid.gov.lv/lv/media/2299/download
--   Elektroniskā deklarēšanas sistēma (EDS) — kur PVN deklarācija tiek iesniegta (Valsts ieņēmumu dienests)
--     https://eds.vid.gov.lv/
--   Pievienotās vērtības nodokļa likmes (Valsts ieņēmumu dienests)
--     https://www.vid.gov.lv/lv/pievienotas-vertibas-nodokla-likmes
--   Civillikums. Ceturtā daļa. Saistību tiesības (Latvijas Vēstnesis — likumi.lv)
--     https://likumi.lv/ta/id/90220-civillikums-ceturta-dala-saistibu-tiesibas
--   Grāmatvedības likums (Latvijas Vēstnesis — likumi.lv)
--     https://likumi.lv/ta/id/324249-gramatvedibas-likums
--   Gada pārskatu un konsolidēto gada pārskatu likums (Latvijas Vēstnesis — likumi.lv)
--     https://likumi.lv/ta/id/277779-gada-parskatu-un-konsolideto-gada-parskatu-likums
--   EN 16931-1 — Electronic invoicing. Part 1: Semantic data model of the core elements of an electronic invoice (European Commission)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   UNCL5305 — VAT category code list (BT-118 and BT-151), OpenPEPPOL subset published for EN 16931 (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — VAT exemption reason code list (BT-121) (OpenPEPPOL — list published by the European Commission)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--   ISO 6523 International Code Designator (ICD) list — Peppol BIS Billing 3.0 code list (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/ICD/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('LV', 'Latvija', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '5e3ff5ca96b6cb286111002e573484e5d2dae2ac55583e90ac1c198c2cf9900e', '[{"key":"pvn-likums","title":"Pievienotās vērtības nodokļa likums","publisher":"Latvijas Vēstnesis — likumi.lv","url":"https://likumi.lv/ta/id/253451-pievienotas-vertibas-nodokla-likums","consulted_on":"2026-09-25","kind":"law"},{"key":"pvn-deklaracijas-noteikumi","title":"Ministru kabineta 2013. gada 15. janvāra noteikumi Nr. 40 \"Noteikumi par pievienotās vērtības nodokļa deklarācijām\"","publisher":"Ministru kabinets — likumi.lv","url":"https://likumi.lv/ta/id/254279-noteikumi-par-pievienotas-vertibas-nodokla-deklaracijam","consulted_on":"2026-09-25","kind":"regulation"},{"key":"pvn-metodika","title":"Metodiskais materiāls par pievienotās vērtības nodokļa deklarācijas un tās pielikumu aizpildīšanu (aktualizēts 29.05.2026)","publisher":"Valsts ieņēmumu dienests","url":"https://www.vid.gov.lv/lv/media/2299/download","consulted_on":"2026-09-25","kind":"form"},{"key":"eds-portal","title":"Elektroniskā deklarēšanas sistēma (EDS) — kur PVN deklarācija tiek iesniegta","publisher":"Valsts ieņēmumu dienests","url":"https://eds.vid.gov.lv/","consulted_on":"2026-09-25","kind":"portal"},{"key":"vid-pvn-likmes","title":"Pievienotās vērtības nodokļa likmes","publisher":"Valsts ieņēmumu dienests","url":"https://www.vid.gov.lv/lv/pievienotas-vertibas-nodokla-likmes","consulted_on":"2026-09-25","kind":"guidance"},{"key":"civillikums","title":"Civillikums. Ceturtā daļa. Saistību tiesības","publisher":"Latvijas Vēstnesis — likumi.lv","url":"https://likumi.lv/ta/id/90220-civillikums-ceturta-dala-saistibu-tiesibas","consulted_on":"2026-09-25","kind":"law"},{"key":"gramatvedibas-likums","title":"Grāmatvedības likums","publisher":"Latvijas Vēstnesis — likumi.lv","url":"https://likumi.lv/ta/id/324249-gramatvedibas-likums","consulted_on":"2026-09-25","kind":"law"},{"key":"gada-parskatu-likums","title":"Gada pārskatu un konsolidēto gada pārskatu likums","publisher":"Latvijas Vēstnesis — likumi.lv","url":"https://likumi.lv/ta/id/277779-gada-parskatu-un-konsolideto-gada-parskatu-likums","consulted_on":"2026-09-25","kind":"law"},{"key":"en-16931","title":"EN 16931-1 — Electronic invoicing. Part 1: Semantic data model of the core elements of an electronic invoice","publisher":"European Commission","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — VAT category code list (BT-118 and BT-151), OpenPEPPOL subset published for EN 16931","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — VAT exemption reason code list (BT-121)","publisher":"OpenPEPPOL — list published by the European Commission","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"},{"key":"peppol-icd","title":"ISO 6523 International Code Designator (ICD) list — Peppol BIS Billing 3.0 code list","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/ICD/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('LV', 'default', 'Kontu plāns pēc Gada pārskatu un konsolidēto gada pārskatu likuma 1. un 2. pielikuma shēmas', '{}'::jsonb, true, 'companies', array['LV-GPL-BS', 'LV-GPL-IS']::text[], null, 'Grāmatvedības likuma 11. panta pirmā daļa — Latvijā nav ar likumu noteikts obligāts kontu plāns; attaisnojuma dokumentu un grāmatvedības reģistru kārtošanas apraksts, tostarp kontu plāns, ir katra uzņēmuma paša izstrādāts iekšējais dokuments. Šis kontu plāns ir oriģināls un strukturēts tā, lai katrs konts pēc pirmā cipara nepārprotami atbilstu Gada pārskatu un konsolidēto gada pārskatu likuma 1. pielikuma (bilances shēma) vai 2. pielikuma (peļņas vai zaudējumu aprēķina shēma pēc izdevumu veidiem) postenim.', 'gramatvedibas-likums')
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
  ('LV', 'default', '1010', 'Attīstības izmaksas', '{}'::jsonb, 'asset_non_current', false, null, 10),
  ('LV', 'default', '1020', 'Koncesijas patenti licences un preču zīmes', '{}'::jsonb, 'asset_non_current', false, null, 20),
  ('LV', 'default', '1030', 'Citi nemateriālie ieguldījumi', '{}'::jsonb, 'asset_non_current', false, null, 30),
  ('LV', 'default', '1040', 'Nemateriālā vērtība', '{}'::jsonb, 'asset_non_current', false, null, 40),
  ('LV', 'default', '1090', 'Avansa maksājumi par nemateriālajiem ieguldījumiem', '{}'::jsonb, 'asset_non_current', false, null, 50),
  ('LV', 'default', '1110', 'Zemesgabali ēkas un inženierbūves', '{}'::jsonb, 'asset_fixed', false, null, 60),
  ('LV', 'default', '1115', 'Ieguldījuma īpašumi', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('LV', 'default', '1120', 'Darba vai produktīvie dzīvnieki un ilggadīgie stādījumi', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('LV', 'default', '1125', 'Bioloģiskie aktīvi (ilgtermiņa)', '{}'::jsonb, 'asset_fixed', false, null, 90),
  ('LV', 'default', '1130', 'Ilgtermiņa ieguldījumi nomātajos pamatlīdzekļos', '{}'::jsonb, 'asset_fixed', false, null, 100),
  ('LV', 'default', '1140', 'Tehnoloģiskās iekārtas un ierīces', '{}'::jsonb, 'asset_fixed', false, null, 110),
  ('LV', 'default', '1150', 'Pārējie pamatlīdzekļi un inventārs', '{}'::jsonb, 'asset_fixed', false, null, 120),
  ('LV', 'default', '1160', 'Pamatlīdzekļu izveidošana un nepabeigto celtniecības objektu izmaksas', '{}'::jsonb, 'asset_fixed', false, null, 130),
  ('LV', 'default', '1190', 'Avansa maksājumi par pamatlīdzekļiem', '{}'::jsonb, 'asset_fixed', false, null, 140),
  ('LV', 'default', '1210', 'Līdzdalība radniecīgo sabiedrību kapitālā', '{}'::jsonb, 'asset_non_current', false, null, 150),
  ('LV', 'default', '1220', 'Aizdevumi radniecīgajām sabiedrībām', '{}'::jsonb, 'asset_non_current', false, null, 160),
  ('LV', 'default', '1230', 'Līdzdalība asociēto sabiedrību kapitālā', '{}'::jsonb, 'asset_non_current', false, null, 170),
  ('LV', 'default', '1240', 'Aizdevumi asociētajām sabiedrībām', '{}'::jsonb, 'asset_non_current', false, null, 180),
  ('LV', 'default', '1250', 'Pārējie vērtspapīri un ieguldījumi', '{}'::jsonb, 'asset_non_current', false, null, 190),
  ('LV', 'default', '1260', 'Pārējie aizdevumi un citi ilgtermiņa debitori', '{}'::jsonb, 'asset_non_current', false, null, 200),
  ('LV', 'default', '1270', 'Aizdevumi akcionāriem vai dalībniekiem un vadībai', '{}'::jsonb, 'asset_non_current', false, null, 210),
  ('LV', 'default', '1290', 'Atliktā nodokļa aktīvi', '{}'::jsonb, 'asset_non_current', false, null, 220),
  ('LV', 'default', '2010', 'Izejvielas pamatmateriāli un palīgmateriāli', '{}'::jsonb, 'asset_current', false, null, 230),
  ('LV', 'default', '2020', 'Nepabeigtie ražojumi un pasūtījumi', '{}'::jsonb, 'asset_current', false, null, 240),
  ('LV', 'default', '2030', 'Gatavie ražojumi un preces pārdošanai', '{}'::jsonb, 'asset_current', false, null, 250),
  ('LV', 'default', '2040', 'Dzīvnieki un viengadīgie stādījumi', '{}'::jsonb, 'asset_current', false, null, 260),
  ('LV', 'default', '2050', 'Bioloģiskie aktīvi (apgrozāmie)', '{}'::jsonb, 'asset_current', false, null, 270),
  ('LV', 'default', '2090', 'Avansa maksājumi par krājumiem', '{}'::jsonb, 'asset_current', false, null, 280),
  ('LV', 'default', '2110', 'Pircēju un pasūtītāju parādi', '{}'::jsonb, 'asset_receivable', true, null, 290),
  ('LV', 'default', '2115', 'Radniecīgo sabiedrību parādi', '{}'::jsonb, 'asset_current', false, null, 300),
  ('LV', 'default', '2120', 'Asociēto sabiedrību parādi', '{}'::jsonb, 'asset_current', false, null, 310),
  ('LV', 'default', '2125', 'Citi debitori', '{}'::jsonb, 'asset_current', false, null, 320),
  ('LV', 'default', '2130', 'Neiemaksātās daļas sabiedrības kapitālā', '{}'::jsonb, 'asset_current', false, null, 330),
  ('LV', 'default', '2135', 'Īstermiņa aizdevumi akcionāriem vai dalībniekiem un vadībai', '{}'::jsonb, 'asset_current', false, null, 340),
  ('LV', 'default', '2140', 'Nākamo periodu izmaksas', '{}'::jsonb, 'asset_prepayments', false, null, 350),
  ('LV', 'default', '2145', 'Uzkrātie ieņēmumi', '{}'::jsonb, 'asset_current', false, null, 360),
  ('LV', 'default', '2150', 'Iepirkumu PVN (priekšnodoklis)', '{}'::jsonb, 'asset_current', false, null, 370),
  ('LV', 'default', '2155', 'Atskaitāmais priekšnodoklis par precēm no Eiropas Savienības teritorijas', '{}'::jsonb, 'asset_current', false, null, 380),
  ('LV', 'default', '2160', 'PVN pārmaksa — iesniegtās deklarācijas atlikums', '{}'::jsonb, 'asset_current', true, null, 390),
  ('LV', 'default', '2210', 'Līdzdalība radniecīgo sabiedrību kapitālā (īstermiņa)', '{}'::jsonb, 'asset_current', false, null, 400),
  ('LV', 'default', '2220', 'Pašu akcijas vai daļas', '{}'::jsonb, 'asset_current', false, null, 410),
  ('LV', 'default', '2230', 'Pārējie vērtspapīri un līdzdalība kapitālos', '{}'::jsonb, 'asset_current', false, null, 420),
  ('LV', 'default', '2240', 'Atvasināti finanšu instrumenti', '{}'::jsonb, 'asset_current', false, null, 430),
  ('LV', 'default', '2310', 'Kase', '{}'::jsonb, 'asset_cash', false, null, 440),
  ('LV', 'default', '2320', 'Norēķinu konti kredītiestādēs', '{}'::jsonb, 'asset_cash', false, null, 450),
  ('LV', 'default', '3010', 'Akciju vai daļu kapitāls (pamatkapitāls)', '{}'::jsonb, 'equity', false, null, 460),
  ('LV', 'default', '3020', 'Akciju (daļu) emisijas uzcenojums', '{}'::jsonb, 'equity', false, null, 470),
  ('LV', 'default', '3030', 'Ilgtermiņa ieguldījumu pārvērtēšanas rezerve', '{}'::jsonb, 'equity', false, null, 480),
  ('LV', 'default', '3040', 'Finanšu instrumentu patiesās vērtības rezerve', '{}'::jsonb, 'equity', false, null, 490),
  ('LV', 'default', '3050', 'Likumā noteiktās rezerves', '{}'::jsonb, 'equity', false, null, 500),
  ('LV', 'default', '3055', 'Rezerves pašu akcijām vai daļām', '{}'::jsonb, 'equity', false, null, 510),
  ('LV', 'default', '3060', 'Sabiedrības statūtos noteiktās rezerves', '{}'::jsonb, 'equity', false, null, 520),
  ('LV', 'default', '3065', 'Rezerves kas novirzītas attīstībai', '{}'::jsonb, 'equity', false, null, 530),
  ('LV', 'default', '3070', 'Ārvalstu valūtu pārrēķināšanas rezerve', '{}'::jsonb, 'equity', false, null, 540),
  ('LV', 'default', '3075', 'Pārējās rezerves', '{}'::jsonb, 'equity', false, null, 550),
  ('LV', 'default', '3080', 'Iepriekšējo gadu nesadalītā peļņa vai nesegtie zaudējumi', '{}'::jsonb, 'equity_retained', false, null, 560),
  ('LV', 'default', '3090', 'Pārskata gada peļņa vai zaudējumi', '{}'::jsonb, 'equity_retained', false, null, 570),
  ('LV', 'default', '4010', 'Uzkrājumi pensijām un tamlīdzīgām saistībām', '{}'::jsonb, 'liability_non_current', false, null, 580),
  ('LV', 'default', '4020', 'Uzkrājumi paredzamajiem nodokļiem', '{}'::jsonb, 'liability_non_current', false, null, 590),
  ('LV', 'default', '4090', 'Citi uzkrājumi', '{}'::jsonb, 'liability_non_current', false, null, 600),
  ('LV', 'default', '4110', 'Aizņēmumi pret obligācijām (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 610),
  ('LV', 'default', '4120', 'Akcijās pārvēršamie aizņēmumi (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 620),
  ('LV', 'default', '4130', 'Aizņēmumi no kredītiestādēm (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 630),
  ('LV', 'default', '4140', 'Citi aizņēmumi (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 640),
  ('LV', 'default', '4150', 'No pircējiem saņemtie avansi (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 650),
  ('LV', 'default', '4160', 'Parādi piegādātājiem un darbuzņēmējiem (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 660),
  ('LV', 'default', '4165', 'Maksājamie vekseļi (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 670),
  ('LV', 'default', '4170', 'Parādi radniecīgajām sabiedrībām (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 680),
  ('LV', 'default', '4175', 'Parādi asociētajām sabiedrībām (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 690),
  ('LV', 'default', '4180', 'Nodokļi un valsts sociālās apdrošināšanas obligātās iemaksas (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 700),
  ('LV', 'default', '4185', 'Atliktā nodokļa saistības', '{}'::jsonb, 'liability_non_current', false, null, 710),
  ('LV', 'default', '4190', 'Pārējie kreditori (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 720),
  ('LV', 'default', '4195', 'Nākamo periodu ieņēmumi (ilgtermiņa)', '{}'::jsonb, 'liability_non_current', false, null, 730),
  ('LV', 'default', '5010', 'Aizņēmumi pret obligācijām (īstermiņa)', '{}'::jsonb, 'liability_current', false, null, 740),
  ('LV', 'default', '5015', 'Akcijās pārvēršamie aizņēmumi (īstermiņa)', '{}'::jsonb, 'liability_current', false, null, 750),
  ('LV', 'default', '5020', 'Aizņēmumi no kredītiestādēm (īstermiņa)', '{}'::jsonb, 'liability_current', false, null, 760),
  ('LV', 'default', '5025', 'Citi aizņēmumi (īstermiņa)', '{}'::jsonb, 'liability_current', false, null, 770),
  ('LV', 'default', '5030', 'No pircējiem saņemtie avansi', '{}'::jsonb, 'liability_current', false, null, 780),
  ('LV', 'default', '5035', 'Parādi piegādātājiem un darbuzņēmējiem', '{}'::jsonb, 'liability_payable', true, null, 790),
  ('LV', 'default', '5040', 'Maksājamie vekseļi', '{}'::jsonb, 'liability_current', false, null, 800),
  ('LV', 'default', '5045', 'Parādi radniecīgajām sabiedrībām', '{}'::jsonb, 'liability_current', false, null, 810),
  ('LV', 'default', '5050', 'Parādi asociētajām sabiedrībām', '{}'::jsonb, 'liability_current', false, null, 820),
  ('LV', 'default', '5055', 'Nodokļi un valsts sociālās apdrošināšanas obligātās iemaksas', '{}'::jsonb, 'liability_current', false, null, 830),
  ('LV', 'default', '5060', 'Pārējie kreditori', '{}'::jsonb, 'liability_current', false, null, 840),
  ('LV', 'default', '5065', 'Nākamo periodu ieņēmumi', '{}'::jsonb, 'liability_current', false, null, 850),
  ('LV', 'default', '5070', 'Neizmaksātās dividendes', '{}'::jsonb, 'liability_current', false, null, 860),
  ('LV', 'default', '5080', 'Pārdošanas PVN (izejošais nodoklis)', '{}'::jsonb, 'liability_current', false, null, 870),
  ('LV', 'default', '5085', 'PVN par Eiropas Savienības teritorijā iegādātām precēm (pašaprēķins)', '{}'::jsonb, 'liability_current', false, null, 880),
  ('LV', 'default', '5090', 'PVN maksājamā summa — iesniegtās deklarācijas atlikums', '{}'::jsonb, 'liability_current', true, null, 890),
  ('LV', 'default', '5095', 'Starpkontu norēķini', '{}'::jsonb, 'liability_current', false, null, 900),
  ('LV', 'default', '6010', 'Ieņēmumi no pārdošanas — pamatdarbība', '{}'::jsonb, 'income', false, null, 910),
  ('LV', 'default', '6015', 'Ieņēmumi no sniegtajiem būvniecības pakalpojumiem', '{}'::jsonb, 'income', false, null, 920),
  ('LV', 'default', '6018', 'Ieņēmumi no citiem pamatdarbības veidiem', '{}'::jsonb, 'income', false, null, 930),
  ('LV', 'default', '6110', 'Gatavās produkcijas un nepabeigto ražojumu krājumu izmaiņas', '{}'::jsonb, 'income_other', false, null, 940),
  ('LV', 'default', '6120', 'Lauksaimnieciskās produkcijas krājumu izmaiņas', '{}'::jsonb, 'income_other', false, null, 950),
  ('LV', 'default', '6130', 'Peļņa vai zaudējumi no bioloģiskajiem aktīviem', '{}'::jsonb, 'income_other', false, null, 960),
  ('LV', 'default', '6140', 'Uz pašu ilgtermiņa ieguldījumiem attiecinātās (kapitalizētās) izmaksas', '{}'::jsonb, 'income_other', false, null, 970),
  ('LV', 'default', '6210', 'Pārējie saimnieciskās darbības ieņēmumi', '{}'::jsonb, 'income_other', false, null, 980),
  ('LV', 'default', '7010', 'Izejvielu un palīgmateriālu izmaksas', '{}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('LV', 'default', '7020', 'Pārējās ārējās izmaksas', '{}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('LV', 'default', '7110', 'Atlīdzība par darbu', '{}'::jsonb, 'expense', false, null, 1010),
  ('LV', 'default', '7120', 'Pensijas no sabiedrības līdzekļiem', '{}'::jsonb, 'expense', false, null, 1020),
  ('LV', 'default', '7130', 'Valsts sociālās apdrošināšanas obligātās iemaksas', '{}'::jsonb, 'expense', false, null, 1030),
  ('LV', 'default', '7140', 'Pārējās sociālās nodrošināšanas izmaksas', '{}'::jsonb, 'expense', false, null, 1040),
  ('LV', 'default', '7210', 'Pamatlīdzekļu un nemateriālo ieguldījumu vērtības samazinājuma korekcijas', '{}'::jsonb, 'expense_depreciation', false, null, 1050),
  ('LV', 'default', '7220', 'Apgrozāmo līdzekļu vērtības samazinājuma korekcijas', '{}'::jsonb, 'expense', false, null, 1060),
  ('LV', 'default', '7310', 'Pārējās saimnieciskās darbības izmaksas', '{}'::jsonb, 'expense', false, null, 1070),
  ('LV', 'default', '7390', 'Noapaļošanas starpības', '{}'::jsonb, 'expense', false, null, 1080),
  ('LV', 'default', '8010', 'Ieņēmumi no līdzdalības radniecīgo sabiedrību kapitālā', '{}'::jsonb, 'income_other', false, null, 1090),
  ('LV', 'default', '8020', 'Ieņēmumi no līdzdalības asociēto sabiedrību kapitālā', '{}'::jsonb, 'income_other', false, null, 1100),
  ('LV', 'default', '8030', 'Ieņēmumi no līdzdalības citu sabiedrību kapitālā', '{}'::jsonb, 'income_other', false, null, 1110),
  ('LV', 'default', '8040', 'Ieņēmumi no pārējiem vērtspapīriem un aizdevumiem', '{}'::jsonb, 'income_other', false, null, 1120),
  ('LV', 'default', '8050', 'Procentu ieņēmumi no radniecīgajām sabiedrībām', '{}'::jsonb, 'income_other', false, null, 1130),
  ('LV', 'default', '8060', 'Pārējie procentu ieņēmumi un tamlīdzīgi ieņēmumi', '{}'::jsonb, 'income_other', false, null, 1140),
  ('LV', 'default', '8070', 'Ārvalstu valūtas kursa peļņa', '{}'::jsonb, 'income_other', false, null, 1150),
  ('LV', 'default', '8110', 'Ilgtermiņa un īstermiņa finanšu ieguldījumu vērtības samazinājuma korekcijas', '{}'::jsonb, 'expense', false, null, 1160),
  ('LV', 'default', '8120', 'Procentu maksājumi radniecīgajām sabiedrībām', '{}'::jsonb, 'expense', false, null, 1170),
  ('LV', 'default', '8130', 'Procentu maksājumi un tamlīdzīgas izmaksas citām personām', '{}'::jsonb, 'expense', false, null, 1180),
  ('LV', 'default', '8140', 'Ārvalstu valūtas kursa zaudējumi', '{}'::jsonb, 'expense', false, null, 1190),
  ('LV', 'default', '8210', 'Uzņēmumu ienākuma nodoklis par pārskata gadu', '{}'::jsonb, 'expense', false, null, 1200)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('LV', 'BNK', 'Bankas žurnāls', '{}'::jsonb, 'bank', 30),
  ('LV', 'CIT', 'Citi darījumi', '{}'::jsonb, 'general', 50),
  ('LV', 'IEP', 'Iepirkumu žurnāls', '{}'::jsonb, 'purchase', 20),
  ('LV', 'KSE', 'Kases žurnāls', '{}'::jsonb, 'cash', 40),
  ('LV', 'PIL', 'Pārdošanas žurnāls', '{}'::jsonb, 'sales', 10),
  ('LV', 'SAK', 'Sākuma atlikumu žurnāls', '{}'::jsonb, 'opening', 60)
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
  ('LV', 'LV-P-12', 'Iepirkums 12%', '{}'::jsonb, 'Samazinātā likme, atskaitāms priekšnodoklis', 'percent', 12, 'purchase', 'domestic', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 41. panta pirmās daļas 2. punkta "a" apakšpunkts un 92. pants — atskaitāmais priekšnodoklis par iekšzemē reģistrēta nodokļa maksātāja izrakstītajā nodokļa rēķinā norādīto samazinātās likmes nodokļa summu', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-P-21', 'Iepirkums 21%', '{}'::jsonb, 'Standartlikme, atskaitāms priekšnodoklis par iekšzemē saņemtajām precēm un pakalpojumiem', 'percent', 21, 'purchase', 'domestic', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 41. panta pirmās daļas 1. punkts un 92. pants — atskaitāmais priekšnodoklis par iekšzemē reģistrēta nodokļa maksātāja izrakstītajā nodokļa rēķinā norādīto nodokļa summu', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-P-IC-GOODS-21', 'Preču iegāde Eiropas Savienības teritorijā 21%', '{}'::jsonb, 'Pašaprēķins — 50., 55. un 64. rinda', 'percent', 21, 'purchase', 'intracom_acquisition_goods', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 5. panta pirmās daļas 3. punkts — preču iegāde Eiropas Savienības teritorijā par atlīdzību ir ar nodokli apliekams darījums; nodokli aprēķina un valsts budžetā maksā preču saņēmējs (93. pants), kuram saskaņā ar 92. pantu ir tiesības to pašu taksācijas periodā atskaitīt kā priekšnodokli', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-S-12', 'Pārdošana 12%', '{}'::jsonb, 'Samazinātā likme — izmitināšanas pakalpojumi tūristu mītnēs', 'percent', 12, 'sale', 'domestic', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 41. panta pirmās daļas 2. punkta "a" apakšpunkts un 42. panta desmitā daļa — nodokļa samazinātā likme 12 procentu apmērā izmitināšanas pakalpojumiem tūristu mītnēs', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-S-21', 'Pārdošana 21%', '{}'::jsonb, 'Standartlikme', 'percent', 21, 'sale', 'domestic', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 41. panta pirmās daļas 1. punkts — nodokļa standartlikme 21 procenta apmērā', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-S-5', 'Pārdošana 5%', '{}'::jsonb, 'Samazinātā likme — grāmatu piegāde', 'percent', 5, 'sale', 'domestic', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 41. panta pirmās daļas 2. punkta "b" apakšpunkts un 42. panta piektā daļa — nodokļa samazinātā likme piecu procentu apmērā grāmatu, tostarp mācību literatūras, piegādei iespieddarba vai elektroniska izdevuma formā, ja tās izdotas valsts valodā vai citu dalībvalstu valsts valodās', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-S-EXEMPT-RE', 'Lietota nekustamā īpašuma pārdošana', '{}'::jsonb, 'Ar nodokli neapliekams darījums', 'percent', 0, 'sale', 'exempt', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 52. panta pirmās daļas 24. punkts — ar nodokli neapliek nekustamā īpašuma pārdošanu, izņemot nelietota nekustamā īpašuma pārdošanu un apbūves zemes pārdošanu (Padomes direktīvas 2006/112/EK 135. panta pirmās daļas "j" punkts)', 'E', 'VATEX-EU-135-1', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-S-EXPORT', 'Preču eksports', '{}'::jsonb, 'Nodokļa 0 procentu likme', 'percent', 0, 'sale', 'export', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 43. panta pirmā daļa — nodokļa 0 procentu likmi piemēro preču eksportam', 'G', 'VATEX-EU-G', 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null),
  ('LV', 'LV-S-IC-GOODS', 'Preču piegāde Eiropas Savienības teritorijā', '{}'::jsonb, 'Nodokļa 0 procentu likme', 'percent', 0, 'sale', 'intracom_goods', date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 43. panta ceturtā daļa — nodokļa 0 procentu likmi piemēro preču piegādei Eiropas Savienības teritorijā, ja preču saņēmējs darījuma brīdī ir uzrādījis derīgu citas dalībvalsts nodokļa maksātāja reģistrācijas numuru un preces ir nosūtītas uz galamērķi citā dalībvalstī', 'K', 'VATEX-EU-IC', 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pvn-likums', null, null, null, null)
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
    ('LV-P-12', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LV-P-12', 'invoice', 'tax', 100, '2150', '62', array['62']::text[], 100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-P-12', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('LV-P-12', 'credit_note', 'tax', 100, '2150', '62', array['62']::text[], -100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-P-21', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('LV-P-21', 'invoice', 'tax', 100, '2150', '62', array['62']::text[], 100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-P-21', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('LV-P-21', 'credit_note', 'tax', 100, '2150', '62', array['62']::text[], -100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-P-IC-GOODS-21', 'invoice', 'base', 100, null, '50', array['50']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-P-IC-GOODS-21', 'invoice', 'tax', 100, '2155', '64', array['64']::text[], 100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-P-IC-GOODS-21', 'invoice', 'tax', -100, '5085', '55', array['55']::text[], 100, 'LV-PVN-DEKLARACIJA', 30),
    ('LV-P-IC-GOODS-21', 'credit_note', 'base', 100, null, '50', array['50']::text[], -100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-P-IC-GOODS-21', 'credit_note', 'tax', 100, '2155', '64', array['64']::text[], -100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-P-IC-GOODS-21', 'credit_note', 'tax', -100, '5085', '55', array['55']::text[], -100, 'LV-PVN-DEKLARACIJA', 30),
    ('LV-S-12', 'invoice', 'base', 100, null, '42', array['42']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-12', 'invoice', 'tax', 100, '5080', '53', array['53']::text[], 100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-S-12', 'credit_note', 'base', 100, null, '42', array['42']::text[], -100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-12', 'credit_note', 'tax', 100, '5080', '53', array['53']::text[], -100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-S-21', 'invoice', 'base', 100, null, '41', array['41']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-21', 'invoice', 'tax', 100, '5080', '52', array['52']::text[], 100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-S-21', 'credit_note', 'base', 100, null, '41', array['41']::text[], -100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-21', 'credit_note', 'tax', 100, '5080', '52', array['52']::text[], -100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-S-5', 'invoice', 'base', 100, null, '42a', array['42a']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-5', 'invoice', 'tax', 100, '5080', '53a', array['53a']::text[], 100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-S-5', 'credit_note', 'base', 100, null, '42a', array['42a']::text[], -100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-5', 'credit_note', 'tax', 100, '5080', '53a', array['53a']::text[], -100, 'LV-PVN-DEKLARACIJA', 20),
    ('LV-S-EXEMPT-RE', 'invoice', 'base', 100, null, '49', array['49']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-EXEMPT-RE', 'credit_note', 'base', 100, null, '49', array['49']::text[], -100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-EXPORT', 'invoice', 'base', 100, null, '48a', array['48a']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-EXPORT', 'credit_note', 'base', 100, null, '48a', array['48a']::text[], -100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-IC-GOODS', 'invoice', 'base', 100, null, '45', array['45']::text[], 100, 'LV-PVN-DEKLARACIJA', 10),
    ('LV-S-IC-GOODS', 'credit_note', 'base', 100, null, '45', array['45']::text[], -100, 'LV-PVN-DEKLARACIJA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'LV' and t.code = v.tax_code
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
  ('LV', 'LV-PVN-DEKLARACIJA', 'Pievienotās vērtības nodokļa deklarācija par taksācijas periodu', array['month', 'quarter']::declaration_period[], null, date '2013-01-01', null, 'Pievienotās vērtības nodokļa likuma 115. pants — taksācijas periods ir viens kalendāra mēnesis, ja reģistrētā nodokļa maksātāja ar nodokli apliekamo darījumu vērtība pārsniedz 50 000 euro vai tas veic noteiktus pārrobežu darījumus, citādi viens ceturksnis (panta pirmā, otrā un trešā daļa). Šī paka nemodelē, kurš no diviem nosacījumiem konkrētam uzņēmumam iestājas, tāpēc period_default nav deklarēts. Deklarācijas un tās pielikumu veidlapu paraugus un aizpildīšanas kārtību nosaka Ministru kabineta 2013. gada 15. janvāra noteikumi Nr. 40.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Pievienotās vērtības nodokļa likuma 118. panta pirmā daļa — reģistrēts nodokļa maksātājs deklarāciju un tās pielikumus iesniedz Valsts ieņēmumu dienestam 20 dienu laikā pēc taksācijas perioda beigām', 'pvn-likums', null)
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
  ('LV', 'LV-PVN-DEKLARACIJA', '40', 'total', 'Taksācijas perioda kopējā darījumu vērtība bez nodokļa', '{}'::jsonb, 10, null, array['41', '42', '42a', '43', '49']::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 40. rindas skaidrojums — taksācijas perioda kopējo darījumu vērtību bez nodokļa veido 41., 41.1, 42., 42.1, 43., 48.2 un 49. rindas kopsumma. Šī paka nemodelē 41.1 un 48.2 rindu (īpašā režīma darījumi un ārpus iekšzemes sniegtie pakalpojumi), tāpēc 40. rindas formula šeit summē tikai 41., 42., 42.1, 43. un 49. rindu.', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '41', 'base', 'Ar nodokļa standartlikmi apliekamo darījumu vērtība', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 41. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 41. panta pirmās daļas 1. punkts', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '42', 'base', 'Ar samazināto nodokļa likmi 12 procentu apmērā apliekamo darījumu vērtība', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 42. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 42. pants', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '42a', 'base', 'Ar samazināto nodokļa likmi 5 procentu apmērā apliekamo preču piegādes vērtība', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 42a rindas skaidrojums; Pievienotās vērtības nodokļa likuma 42. panta piektā daļa', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '43', 'total', 'Ar nodokļa 0 procentu likmi apliekamo darījumu vērtība', '{}'::jsonb, 50, null, array['45', '48a']::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 43. rindas skaidrojums — rindā ietver arī 44., 45.1, 46., 47. un 48. rindā norādīto vērtību. Šī paka modelē tikai preču piegādi Eiropas Savienības teritorijā (45. rinda) un preču eksportu (48a rinda); pārējie 0 procentu likmes gadījumi (brīvostas, jauni transportlīdzekļi, ķēdes darījumi, ārpus iekšzemes sniegti pakalpojumi) šajā pakā nav modelēti — sk. docs/international.md.', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '45', 'base', 'Uz citu dalībvalsti piegādāto preču vērtība', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 45. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 43. panta ceturtā daļa', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '48a', 'base', 'Eksportēto preču vērtība', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 48a rindas skaidrojums; Pievienotās vērtības nodokļa likuma 43. panta pirmā daļa', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '49', 'base', 'Ar nodokli neapliekamo darījumu vērtība', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 49. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 52. pants', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '50', 'base', 'Ar nodokļa standartlikmi apliekamā vērtība par preču iegādi Eiropas Savienības teritorijā', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 50. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 5. panta pirmās daļas 3. punkts un 19. panta pirmā daļa', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '52', 'tax', 'Pēc standartlikmes aprēķinātā nodokļa summa', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 52. rindas skaidrojums — 41. rinda x standartlikme : 100', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '53', 'tax', 'Pēc samazinātās nodokļa likmes 12 procentu apmērā aprēķinātā nodokļa summa', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 53. rindas skaidrojums — 42. rinda x samazinātā nodokļa likme 12 procentu apmērā : 100', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '53a', 'tax', 'Pēc samazinātās nodokļa likmes 5 procentu apmērā aprēķinātā nodokļa summa', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 53a rindas skaidrojums — 42a rinda x samazinātā nodokļa likme 5 procentu apmērā : 100', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '55', 'tax', 'Pēc standartlikmes aprēķinātā nodokļa summa par preču iegādi Eiropas Savienības teritorijā', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 55. rindas skaidrojums — 50. rinda x standartlikme : 100', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '60', 'total', 'Priekšnodoklis', '{}'::jsonb, 140, null, array['62', '64']::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 60. rindas skaidrojums — 60. rindu veido 61., 62., 63., 64. un 65. rindas kopsumma. Šī paka modelē tikai 62. un 64. rindu (iekšzemē un Eiropas Savienības teritorijā saņemto preču un pakalpojumu priekšnodoklis); importa, pakalpojumu pašaprēķina un lauksaimniecības kompensācijas priekšnodoklis (61., 63., 65. rinda) šajā pakā nav modelēts — sk. docs/international.md.', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '62', 'tax', 'Priekšnodoklis par iekšzemē saņemtajām precēm un pakalpojumiem', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 62. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 92. pants', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '64', 'tax', 'Priekšnodoklis par precēm, kas iegādātas Eiropas Savienības teritorijā', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla 64. rindas skaidrojums; Pievienotās vērtības nodokļa likuma 92. un 93. pants', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', 'P', 'total', 'Priekšnodoklis, ko aprēķina', '{}'::jsonb, 170, null, array['60']::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla (P) rindas skaidrojums — 60. rinda – 66. rinda + 67. rinda. Šī paka nemodelē 66. un 67. rindu (neatskaitāmā priekšnodokļa proporciju un zaudēto parādu korekcijas), tāpēc (P) šeit ir vienāds ar 60. rindu — sk. docs/international.md.', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', 'S', 'total', 'Nodokļa summa, ko aprēķina', '{}'::jsonb, 180, null, array['52', '53', '53a', '55']::text[], '{}'::text[], null, null, false, false, null, 'Metodiskā materiāla (S) rindas skaidrojums — 52. + 53. + 53.1 + 54. + 55. + 56. + 56.1 + 57. rinda. Šī paka nemodelē 54., 56., 56.1 un 57. rindu (pakalpojumu pašaprēķins, samazināto likmju iegādes Eiropas Savienības teritorijā un iepriekšējo periodu korekcijas) — sk. docs/international.md.', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '70', 'total', 'Pārmaksātā nodokļa summa', '{}'::jsonb, 190, null, array['P']::text[], array['S']::text[], null, null, true, false, null, 'Metodiskā materiāla 70. rindas skaidrojums — (P) rinda – (S) rinda, ja priekšnodoklis ir lielāks', 'pvn-metodika'),
  ('LV', 'LV-PVN-DEKLARACIJA', '80', 'total', 'Valsts budžetā maksājamā nodokļa summa', '{}'::jsonb, 200, null, array['S']::text[], array['P']::text[], null, null, true, false, null, 'Metodiskā materiāla 80. rindas skaidrojums — (S) rinda – (P) rinda, ja aprēķinātā nodokļa summa ir lielāka', 'pvn-metodika')
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
  ('LV-GPL-BS', 'LV', 'default', 'Bilance', 'balance_sheet', 'LV-GPL', date '1970-01-01', null, 'Gada pārskatu un konsolidēto gada pārskatu likuma 10. panta pirmā daļa un 1. pielikums (bilances shēma). Šī paka apkopo 1. pielikuma posteņus to virsraksta (I—IV) līmenī, kā to atļauj likuma 56.—58. panta tiesības mazām un mikrosabiedrībām apvienot maznozīmīgus posteņus vienā rindā.', 'gada-parskatu-likums'),
  ('LV-GPL-IS', 'LV', 'default', 'Peļņas vai zaudējumu aprēķins (vertikālā forma, klasificēts pēc izdevumu veidiem)', 'income_statement', 'LV-GPL', date '1970-01-01', null, 'Gada pārskatu un konsolidēto gada pārskatu likuma 10. panta otrā daļa un 2. pielikums. Rindu kodi atbilst 2. pielikuma posteņu numuriem; šī paka apvieno vairākus 2. pielikuma posteņus vienā rindā (2.+3., 9.+10.+11., 12.+13.), jo tie visi kartējas uz vienu kontu grupu šajā kontu plānā.', 'gada-parskatu-likums')
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
  ('LV-GPL-BS', 'AKTIVS', null, 'AKTĪVS', '{}'::jsonb, 10, 1, true, array['ILGTERM', 'APGROZ']::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'ILGTERM', null, 'Ilgtermiņa ieguldījumi', '{}'::jsonb, 20, 1, true, array['NEMAT', 'PAMATL', 'FIN_ILGT']::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'NEMAT', null, 'I. Nemateriālie ieguldījumi', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'PAMATL', null, 'II. Pamatlīdzekļi, ieguldījuma īpašumi un bioloģiskie aktīvi', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'FIN_ILGT', null, 'III. Ilgtermiņa finanšu ieguldījumi', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'APGROZ', null, 'Apgrozāmie līdzekļi', '{}'::jsonb, 60, 1, true, array['KRAJ', 'DEBIT', 'FIN_ISTERM', 'NAUDA']::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'KRAJ', null, 'I. Krājumi', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'DEBIT', null, 'II. Debitori', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'FIN_ISTERM', null, 'III. Īstermiņa finanšu ieguldījumi', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'NAUDA', null, 'IV. Nauda', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'PASIVS', null, 'PASĪVS', '{}'::jsonb, 110, 1, true, array['KAPITALS', 'UZKRAJ', 'KRED_ILGT', 'KRED_ISTERM']::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'KAPITALS', null, 'Pašu kapitāls', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'UZKRAJ', null, 'Uzkrājumi', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'KRED_ILGT', null, 'Ilgtermiņa kreditori', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-BS', 'KRED_ISTERM', null, 'Īstermiņa kreditori', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '1', null, '1. Neto apgrozījums', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '2', null, '2.—3. Krājumu izmaiņas un kapitalizētās izmaksas', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '4', null, '4. Pārējie saimnieciskās darbības ieņēmumi', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '5', null, '5. Materiālu izmaksas', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '6', null, '6. Personāla izmaksas', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '7', null, '7. Vērtības samazinājuma korekcijas', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '8', null, '8. Pārējās saimnieciskās darbības izmaksas', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '9', null, '9.—11. Ieņēmumi no līdzdalības, vērtspapīriem un procentiem', '{}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '12', null, '12.—13. Finanšu izmaksas', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '14', null, '14. Peļņa vai zaudējumi pirms uzņēmumu ienākuma nodokļa', '{}'::jsonb, 100, 1, true, array['1', '2', '4', '9']::text[], array['5', '6', '7', '8', '12']::text[], null, null, null),
  ('LV-GPL-IS', '15', null, '15. Uzņēmumu ienākuma nodoklis par pārskata gadu', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('LV-GPL-IS', '16', null, '16. Pārskata gada peļņa vai zaudējumi', '{}'::jsonb, 120, 1, true, array['14']::text[], array['15']::text[], null, null, null)
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
    ('LV-GPL-BS', 'NEMAT', 10, 'code_range', '1010', '1099', null, 'any'),
    ('LV-GPL-BS', 'PAMATL', 10, 'code_range', '1100', '1199', null, 'any'),
    ('LV-GPL-BS', 'FIN_ILGT', 10, 'code_range', '1200', '1299', null, 'any'),
    ('LV-GPL-BS', 'KRAJ', 10, 'code_range', '2010', '2099', null, 'any'),
    ('LV-GPL-BS', 'DEBIT', 10, 'code_range', '2100', '2199', null, 'any'),
    ('LV-GPL-BS', 'FIN_ISTERM', 10, 'code_range', '2200', '2299', null, 'any'),
    ('LV-GPL-BS', 'NAUDA', 10, 'code_range', '2300', '2399', null, 'any'),
    ('LV-GPL-BS', 'KAPITALS', 10, 'code_range', '3010', '3099', null, 'any'),
    ('LV-GPL-BS', 'UZKRAJ', 10, 'code_range', '4010', '4099', null, 'any'),
    ('LV-GPL-BS', 'KRED_ILGT', 10, 'code_range', '4110', '4199', null, 'any'),
    ('LV-GPL-BS', 'KRED_ISTERM', 10, 'code_range', '5010', '5099', null, 'any'),
    ('LV-GPL-IS', '1', 10, 'code_range', '6010', '6019', null, 'any'),
    ('LV-GPL-IS', '2', 10, 'code_range', '6100', '6199', null, 'any'),
    ('LV-GPL-IS', '4', 10, 'code_range', '6200', '6299', null, 'any'),
    ('LV-GPL-IS', '5', 10, 'code_range', '7000', '7099', null, 'any'),
    ('LV-GPL-IS', '6', 10, 'code_range', '7100', '7199', null, 'any'),
    ('LV-GPL-IS', '7', 10, 'code_range', '7200', '7299', null, 'any'),
    ('LV-GPL-IS', '8', 10, 'code_range', '7300', '7399', null, 'any'),
    ('LV-GPL-IS', '9', 10, 'code_range', '8000', '8099', null, 'any'),
    ('LV-GPL-IS', '12', 10, 'code_range', '8100', '8199', null, 'any'),
    ('LV-GPL-IS', '15', 10, 'code_range', '8200', '8299', null, 'any')
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
  ('LV', 'Latvija', '{}'::jsonb, array['lv']::text[], 'EUR', '2110', '5035', '5095', '7390', '3080', '6010', '7010', '2320', '2310', 'PIL', 'IEP', 'CIT', 'lv', 'result_accounts', '3090', '3090', null, 'SAK', 'half_up', default, '8070', '8140', null, null, null, null, '5090', '2160', null, null)
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
  late_payment_reference        = 'Civillikuma 1765.panta trešā daļa — likumisko procentu apmērs par tāda naudas parāda samaksas nokavējumu, kas kā atlīdzība nolīgta līgumā par preces piegādi, pirkumu vai pakalpojuma sniegšanu, ir astoņi procentpunkti virs procentu pamatlikmes (Eiropas Centrālās bankas pēdējā galveno refinansēšanas operāciju likme) gadā.',
  numbering_legal_reference     = 'Pievienotās vērtības nodokļa likuma 125. panta pirmās daļas 2. punkts — nodokļa rēķinā jānorāda tā kārtas numurs, kas unikāli identificē rēķinu; Grāmatvedības likuma 11. panta piektās daļas 3. punkts prasa attaisnojuma dokumenta numuru vispārīgi. Nedz viens, nedz otrs pants neprasa nepārtrauktu (gapless) numerāciju, tāpēc numbering ir sequential.',
  numbering_source_key          = 'pvn-likums',
  payment_terms_legal_reference = 'Civillikuma 1668.2 pants — ja līgumā par preces piegādi, pirkumu vai pakalpojuma sniegšanu nav noteikts atlīdzības samaksas termiņš, parādnieka nokavējums iestājas pats no sevis, ja parādnieks nav veicis samaksu trīsdesmit dienu laikā pēc rēķina vai preces/pakalpojuma saņemšanas dienas.',
  payment_terms_source_key      = 'civillikums',
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = 'Pievienotās vērtības nodokļa likuma 31. panta pirmā daļa (preču piegāde) un 32. panta pirmā daļa (pakalpojuma sniegšana) — darījuma brīdis ir brīdis, kad faktiski notiek preču piegāde vai pakalpojuma sniegšana saņēmējam. Likums nesatur vispārīgu atkāpi uz rēķina izrakstīšanas datumu; avansa maksājumu īpašais režīms šajā pakā nav modelēts (sk. docs/international.md).',
  tax_point_source_key          = 'pvn-likums',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = date '2028-01-01',
  einvoice_obligation           = 'mandatory',
  einvoice_legal_reference      = 'Grāmatvedības likuma 11. panta četrpadsmitā daļa — attaisnojuma dokumentu, kuru uzņēmums izsniedz citam Latvijas Republikā reģistrētam uzņēmumam samaksāšanai, noformē kā strukturētu elektronisko rēķinu atbilstoši standartam LVS EN 16931-1:2017. Pārejas noteikumu 8. punkts (05.06.2025. likuma redakcijā) atliek šo pienākumu darījumiem starp uzņēmumiem, kas nav budžeta iestādes, līdz 2028. gada 1. janvārim (sākotnēji plānotā 2026. gada 1. janvāra vietā). Attiecībā uz rēķiniem budžeta iestādēm pienākums jau piemērojams kopš 2025. gada 1. janvāra, ar pārejas periodu līdz 2026. gada 1. janvārim līgumiem, kas noslēgti līdz 2024. gada 31. decembrim (pārejas noteikumu 9. punkts); strukturēto rēķinu datu nodošana Valsts ieņēmumu dienestam sākas 2026. gada 1. janvārī budžeta iestāžu darījumiem un 2028. gada 1. janvārī pārējiem uzņēmumiem (pārejas noteikumu 10. punkts). Likums neparedz vienotu tīklu; rēķinu var nosūtīt caur e-adresi vai jebkuru Peppol pieejas punktu. Šis pakas modelis izmanto peppol-bis-3 profilu, jo tas ir standarts LVS EN 16931-1:2017 atbilstošs sintakses profils, ko faktiski izmanto e-adreses un komerciālo Peppol operatoru starpā (sk. docs/international.md par to, ka likums pats neuzspiež konkrētu sintaksi).',
  einvoice_source_key           = 'gramatvedibas-likums',
  party_scheme                  = '0218',
  vat_scheme                    = '0219',
  bank_statement_formats        = array['camt.053', 'camt.052']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'LV';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('LV', 'export', 'export', 'Piemērota nodokļa 0 procentu likme — preču eksports (Pievienotās vērtības nodokļa likuma 43. panta pirmā daļa).', '{}'::jsonb, 10, date '1970-01-01', null, 'Pievienotās vērtības nodokļa likuma 125. panta pirmās daļas 15. punkts — ja piemērota 0 procentu likme vai atbrīvojums no nodokļa, rēķinā jānorāda atsauce uz likuma pantu vai Direktīvas 2006/112/EK pantu, saskaņā ar kuru tā piemērota.'),
  ('LV', 'intracom_goods', 'intra_eu_goods', 'Piemērota nodokļa 0 procentu likme — preču piegāde Eiropas Savienības teritorijā (Pievienotās vērtības nodokļa likuma 43. panta ceturtā daļa; Padomes direktīvas 2006/112/EK 138. pants).', '{}'::jsonb, 20, date '1970-01-01', null, 'Pievienotās vērtības nodokļa likuma 125. panta pirmās daļas 15. punkts'),
  ('LV', 'exempt', 'exempt', 'Ar nodokli neapliekams darījums (Pievienotās vērtības nodokļa likuma 52. pants).', '{}'::jsonb, 30, date '1970-01-01', null, 'Pievienotās vērtības nodokļa likuma 125. panta pirmās daļas 15. punkts'),
  ('LV', 'reverse_charge', 'reverse_charge', 'Nodokļa apgrieztā maksāšana.', '{}'::jsonb, 40, date '1970-01-01', null, 'Pievienotās vērtības nodokļa likuma 125. panta pirmās daļas 16. punkts — ja par nodokļa samaksu ir atbildīgs preču vai pakalpojumu saņēmējs, rēķinā jānorāda "nodokļa apgrieztā maksāšana".'),
  ('LV', 'small_business', 'small_business', 'Nodoklis netiek piemērots — piegādātājs nav reģistrēts Valsts ieņēmumu dienesta pievienotās vērtības nodokļa maksātāju reģistrā (Pievienotās vērtības nodokļa likuma 59. pants).', '{}'::jsonb, 50, date '1970-01-01', null, 'Pievienotās vērtības nodokļa likuma 59. panta pirmā daļa — iekšzemes nodokļa maksātājs ir tiesīgs nereģistrēties, kamēr tā ar nodokli apliekamo darījumu vērtība kalendāra gadā nepārsniedz 50 000 euro reģistrācijas slieksni.'),
  ('LV', 'late_payment', 'late_payment', 'Maksājuma kavējuma gadījumā kreditoram ir tiesības uz likumiskajiem procentiem astoņu procentpunktu apmērā virs procentu pamatlikmes gadā (Civillikuma 1765. panta trešā daļa), neskarot tiesības uz zaudējumu atlīdzību.', '{}'::jsonb, 60, date '1970-01-01', null, 'Civillikuma 1668.2 un 1765. pants')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
