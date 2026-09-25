-- Ekwo OS — Danmark: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/dk at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build dk`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Bekendtgørelse af merværdiafgiftsloven (momsloven), LBK nr 209 af 27/02/2024, som ændret (Skatteministeriet — Retsinformation)
--     https://www.retsinformation.dk/eli/lta/2024/209
--   Bekendtgørelse om merværdiafgiftsloven (momsbekendtgørelsen), BEK nr 1435 af 29/11/2023, som ændret (Skatteministeriet — Retsinformation)
--     https://www.retsinformation.dk/eli/lta/2023/1435
--   Hjælpetekster til momsangivelsen — rubrikkerne Salgsmoms, Moms af varekøb i udlandet, Moms af ydelseskøb i udlandet med omvendt betalingspligt, Købsmoms, Moms i alt, Rubrik A og Rubrik B og C (Skattestyrelsen)
--     https://www.dst.dk/Site/Dst/SingleFiles/GetArchiveFile.aspx?fi=5437448703&fo=0&ext=konjstat
--   TastSelv Erhverv — hvor momsangivelsen indberettes og betales (Skattestyrelsen)
--     https://skat.dk/tastselverhverv
--   Bekendtgørelse af årsregnskabsloven, LBK nr 402 af 23/03/2026, bilag 2 — skemaer for balancer og resultatopgørelser (Erhvervsministeriet — Retsinformation)
--     https://www.retsinformation.dk/eli/lta/2026/402
--   Lov om bogføring, LOV nr 700 af 24/05/2022 (Erhvervsministeriet — Retsinformation)
--     https://www.retsinformation.dk/eli/lta/2022/700
--   Renteloven, LBK nr 459 af 13/05/2014, som ændret (Justitsministeriet — Retsinformation)
--     https://www.retsinformation.dk/eli/lta/2014/459
--   Bekendtgørelse om elektronisk afregning med offentlige myndigheder, BEK nr 206 af 11/03/2011 (Finansministeriet — Retsinformation)
--     https://www.retsinformation.dk/eli/lta/2011/206
--   Nemhandel — fælles digital infrastruktur for e-fakturering med det offentlige (Erhvervsstyrelsen)
--     https://erhvervsstyrelsen.dk/nemhandel-faelles-digital-infrastruktur
--   Digital bogføring træder i kraft for personligt ejede virksomheder og foreninger m.fl. den 1. januar 2026 (Erhvervsstyrelsen)
--     https://erhvervsstyrelsen.dk/digital-bogfoering-traeder-i-kraft-personligt-ejede-virksomheder-og-foreninger-mfl-den-1-januar
--   Rådets direktiv 2006/112/EF af 28. november 2006 om det fælles merværdiafgiftssystem (Den Europæiske Unions Publikationskontor — EUR-Lex)
--     https://eur-lex.europa.eu/eli/dir/2006/112/oj
--   EN 16931-1 — det semantiske datamodel for den europæiske e-faktura (Europa-Kommissionen)
--     https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance
--   Peppol BIS Billing 3.0, med den danske CIUS (DICOW) (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/
--   Electronic Address Scheme (EAS) — identifikationsskemaer, herunder 0184 DK:CVR og 0088 GLN (OpenPEPPOL)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/
--   UNCL5305 — koder for momskategori (BT-118 og BT-151), delmængde for EN 16931 (OpenPEPPOL — liste offentliggjort af Europa-Kommissionen)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/
--   VATEX — koder for fritagelsesårsag (BT-121) (OpenPEPPOL — liste offentliggjort af Europa-Kommissionen)
--     https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('DK', 'Danmark', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, 'a43f7349b6d66ad9e86b9c186bca4ea31713bbf4598913a7dbdc052f13ceed80', '[{"key":"momsloven","title":"Bekendtgørelse af merværdiafgiftsloven (momsloven), LBK nr 209 af 27/02/2024, som ændret","publisher":"Skatteministeriet — Retsinformation","url":"https://www.retsinformation.dk/eli/lta/2024/209","consulted_on":"2026-09-25","kind":"law"},{"key":"momsbekendtgoerelsen","title":"Bekendtgørelse om merværdiafgiftsloven (momsbekendtgørelsen), BEK nr 1435 af 29/11/2023, som ændret","publisher":"Skatteministeriet — Retsinformation","url":"https://www.retsinformation.dk/eli/lta/2023/1435","consulted_on":"2026-09-25","kind":"regulation"},{"key":"momsangivelsen-hjaelp","title":"Hjælpetekster til momsangivelsen — rubrikkerne Salgsmoms, Moms af varekøb i udlandet, Moms af ydelseskøb i udlandet med omvendt betalingspligt, Købsmoms, Moms i alt, Rubrik A og Rubrik B og C","publisher":"Skattestyrelsen","url":"https://www.dst.dk/Site/Dst/SingleFiles/GetArchiveFile.aspx?fi=5437448703&fo=0&ext=konjstat","consulted_on":"2026-09-25","kind":"form"},{"key":"tastselv-erhverv","title":"TastSelv Erhverv — hvor momsangivelsen indberettes og betales","publisher":"Skattestyrelsen","url":"https://skat.dk/tastselverhverv","consulted_on":"2026-09-25","kind":"portal"},{"key":"arsregnskabsloven","title":"Bekendtgørelse af årsregnskabsloven, LBK nr 402 af 23/03/2026, bilag 2 — skemaer for balancer og resultatopgørelser","publisher":"Erhvervsministeriet — Retsinformation","url":"https://www.retsinformation.dk/eli/lta/2026/402","consulted_on":"2026-09-25","kind":"law"},{"key":"bogfoeringsloven","title":"Lov om bogføring, LOV nr 700 af 24/05/2022","publisher":"Erhvervsministeriet — Retsinformation","url":"https://www.retsinformation.dk/eli/lta/2022/700","consulted_on":"2026-09-25","kind":"law"},{"key":"renteloven","title":"Renteloven, LBK nr 459 af 13/05/2014, som ændret","publisher":"Justitsministeriet — Retsinformation","url":"https://www.retsinformation.dk/eli/lta/2014/459","consulted_on":"2026-09-25","kind":"law"},{"key":"elektronisk-afregning","title":"Bekendtgørelse om elektronisk afregning med offentlige myndigheder, BEK nr 206 af 11/03/2011","publisher":"Finansministeriet — Retsinformation","url":"https://www.retsinformation.dk/eli/lta/2011/206","consulted_on":"2026-09-25","kind":"regulation"},{"key":"nemhandel","title":"Nemhandel — fælles digital infrastruktur for e-fakturering med det offentlige","publisher":"Erhvervsstyrelsen","url":"https://erhvervsstyrelsen.dk/nemhandel-faelles-digital-infrastruktur","consulted_on":"2026-09-25","kind":"guidance"},{"key":"digital-bogfoering","title":"Digital bogføring træder i kraft for personligt ejede virksomheder og foreninger m.fl. den 1. januar 2026","publisher":"Erhvervsstyrelsen","url":"https://erhvervsstyrelsen.dk/digital-bogfoering-traeder-i-kraft-personligt-ejede-virksomheder-og-foreninger-mfl-den-1-januar","consulted_on":"2026-09-25","kind":"guidance"},{"key":"btw-richtlijn","title":"Rådets direktiv 2006/112/EF af 28. november 2006 om det fælles merværdiafgiftssystem","publisher":"Den Europæiske Unions Publikationskontor — EUR-Lex","url":"https://eur-lex.europa.eu/eli/dir/2006/112/oj","consulted_on":"2026-09-25","kind":"law"},{"key":"en-16931","title":"EN 16931-1 — det semantiske datamodel for den europæiske e-faktura","publisher":"Europa-Kommissionen","url":"https://ec.europa.eu/digital-building-blocks/sites/spaces/DIGITAL/pages/467108950/EN+16931+compliance","consulted_on":"2026-09-25","kind":"standard"},{"key":"peppol-bis","title":"Peppol BIS Billing 3.0, med den danske CIUS (DICOW)","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/","consulted_on":"2026-09-25","kind":"standard"},{"key":"eas","title":"Electronic Address Scheme (EAS) — identifikationsskemaer, herunder 0184 DK:CVR og 0088 GLN","publisher":"OpenPEPPOL","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/eas/","consulted_on":"2026-09-25","kind":"standard"},{"key":"uncl5305","title":"UNCL5305 — koder for momskategori (BT-118 og BT-151), delmængde for EN 16931","publisher":"OpenPEPPOL — liste offentliggjort af Europa-Kommissionen","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/UNCL5305/","consulted_on":"2026-09-25","kind":"standard"},{"key":"vatex","title":"VATEX — koder for fritagelsesårsag (BT-121)","publisher":"OpenPEPPOL — liste offentliggjort af Europa-Kommissionen","url":"https://docs.peppol.eu/poacc/billing/3.0/codelist/vatex/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('DK', 'default', 'Original kontoplan — ni klasser efter årsregnskabslovens bilag 2', '{"en":"Original chart of accounts — nine classes following annex 2 of the Danish Annual Accounts Act"}'::jsonb, true, 'companies', array['DK-ARL-BS', 'DK-ARL-IS']::text[], null, 'Danmark foreskriver ingen kontoplan: bogføringslovens § 6 pålægger kun en beskrivelse af virksomhedens bogføringsprocedurer, ikke en bestemt kontoplan eller kontonummerering. Denne kontoplan er original og bygger kontonumrene op om ni klasser, hver knyttet til én gruppe af linjer i årsregnskabslovens bilag 2, skema 1 og skema 3, så balance og resultatopgørelse kan læses direkte af kontonumrenes klasse', 'bogfoeringsloven')
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
  ('DK', 'default', '1010', 'Erhvervede koncessioner patenter licenser og lignende rettigheder', '{"en":"Concessions, patents, licences and similar rights acquired"}'::jsonb, 'asset_fixed', false, null, 10),
  ('DK', 'default', '1015', 'Software', '{"en":"Software"}'::jsonb, 'asset_fixed', false, null, 15),
  ('DK', 'default', '1020', 'Goodwill', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 20),
  ('DK', 'default', '1030', 'Færdiggjorte udviklingsprojekter', '{"en":"Completed development projects"}'::jsonb, 'asset_fixed', false, null, 30),
  ('DK', 'default', '1040', 'Udviklingsprojekter under udførelse', '{"en":"Development projects in progress"}'::jsonb, 'asset_fixed', false, null, 40),
  ('DK', 'default', '1110', 'Grunde og bygninger', '{"en":"Land and buildings"}'::jsonb, 'asset_fixed', false, null, 50),
  ('DK', 'default', '1120', 'Produktionsanlæg og maskiner', '{"en":"Plant and machinery"}'::jsonb, 'asset_fixed', false, null, 60),
  ('DK', 'default', '1125', 'Indretning af lejede lokaler', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 65),
  ('DK', 'default', '1130', 'Andre anlæg driftsmateriel og inventar', '{"en":"Other fixtures, fittings, tools and equipment"}'::jsonb, 'asset_fixed', false, null, 70),
  ('DK', 'default', '1135', 'Biler', '{"en":"Motor vehicles"}'::jsonb, 'asset_fixed', false, null, 75),
  ('DK', 'default', '1140', 'Materielle anlægsaktiver under udførelse', '{"en":"Property, plant and equipment in the course of construction"}'::jsonb, 'asset_fixed', false, null, 80),
  ('DK', 'default', '1210', 'Kapitalandele i tilknyttede virksomheder', '{"en":"Investments in group undertakings"}'::jsonb, 'asset_non_current', false, null, 90),
  ('DK', 'default', '1220', 'Andre værdipapirer og kapitalandele — anlæg', '{"en":"Other investments and securities — fixed assets"}'::jsonb, 'asset_non_current', false, null, 100),
  ('DK', 'default', '1230', 'Andre tilgodehavender — anlæg', '{"en":"Other receivables — fixed assets"}'::jsonb, 'asset_non_current', false, null, 110),
  ('DK', 'default', '1240', 'Deposita', '{"en":"Deposits"}'::jsonb, 'asset_non_current', false, null, 115),
  ('DK', 'default', '1250', 'Udskudt skatteaktiv', '{"en":"Deferred tax asset"}'::jsonb, 'asset_non_current', false, null, 118),
  ('DK', 'default', '2010', 'Råvarer og hjælpematerialer', '{"en":"Raw materials and consumables"}'::jsonb, 'asset_current', false, null, 120),
  ('DK', 'default', '2015', 'Emballage', '{"en":"Packaging materials"}'::jsonb, 'asset_current', false, null, 125),
  ('DK', 'default', '2020', 'Varer under fremstilling', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 130),
  ('DK', 'default', '2025', 'Halvfabrikata', '{"en":"Semi-finished goods"}'::jsonb, 'asset_current', false, null, 135),
  ('DK', 'default', '2030', 'Fremstillede varer og handelsvarer', '{"en":"Finished goods and goods for resale"}'::jsonb, 'asset_current', false, null, 140),
  ('DK', 'default', '2040', 'Hensættelse til ukurante varer', '{"en":"Provision for slow-moving inventory"}'::jsonb, 'asset_current', false, null, 145),
  ('DK', 'default', '2100', 'Tilgodehavender fra salg og tjenesteydelser', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 150),
  ('DK', 'default', '2101', 'Hensættelse til tab på debitorer', '{"en":"Provision for bad debts"}'::jsonb, 'asset_current', false, null, 152),
  ('DK', 'default', '2110', 'Tilgodehavender hos tilknyttede virksomheder', '{"en":"Receivables from group undertakings"}'::jsonb, 'asset_current', false, null, 160),
  ('DK', 'default', '2115', 'Tilgodehavender hos associerede virksomheder', '{"en":"Receivables from associates"}'::jsonb, 'asset_current', false, null, 165),
  ('DK', 'default', '2120', 'Andre tilgodehavender', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 170),
  ('DK', 'default', '2125', 'Tilgodehavende udbytte', '{"en":"Dividend receivable"}'::jsonb, 'asset_current', false, null, 172),
  ('DK', 'default', '2130', 'Periodeafgrænsningsposter — aktiv', '{"en":"Prepayments — assets"}'::jsonb, 'asset_prepayments', false, null, 180),
  ('DK', 'default', '2140', 'Igangværende arbejder for fremmed regning', '{"en":"Work in progress for third-party account"}'::jsonb, 'asset_current', false, null, 185),
  ('DK', 'default', '2160', 'Indgående moms — købsmoms', '{"en":"Input VAT — deductible"}'::jsonb, 'asset_current', false, null, 190),
  ('DK', 'default', '2170', 'Afgift af varekøb og ydelseskøb fra udlandet — indgående del', '{"en":"Tax on foreign purchases — deductible part"}'::jsonb, 'asset_current', false, null, 195),
  ('DK', 'default', '2180', 'Andre tilgodehavender hos det offentlige', '{"en":"Other receivables from public authorities"}'::jsonb, 'asset_current', false, null, 197),
  ('DK', 'default', '2199', 'Tilgodehavende moms — afregningskonto', '{"en":"VAT receivable — settlement account"}'::jsonb, 'asset_current', true, null, 200),
  ('DK', 'default', '2200', 'Andre værdipapirer og kapitalandele — omsætning', '{"en":"Other investments and securities — current assets"}'::jsonb, 'asset_current', false, null, 210),
  ('DK', 'default', '2210', 'Børsnoterede obligationer', '{"en":"Listed bonds"}'::jsonb, 'asset_current', false, null, 215),
  ('DK', 'default', '2310', 'Bankindestående i DKK', '{"en":"Bank balances, DKK"}'::jsonb, 'asset_cash', false, null, 220),
  ('DK', 'default', '2311', 'Bankindestående — opsparingskonto', '{"en":"Bank balances — savings account"}'::jsonb, 'asset_cash', false, null, 222),
  ('DK', 'default', '2320', 'Bankindestående i fremmed valuta', '{"en":"Bank balances, foreign currency"}'::jsonb, 'asset_cash', false, null, 230),
  ('DK', 'default', '2330', 'Kassebeholdning', '{"en":"Cash in hand"}'::jsonb, 'asset_cash', false, null, 240),
  ('DK', 'default', '2340', 'Girokonto', '{"en":"Giro account"}'::jsonb, 'asset_cash', false, null, 245),
  ('DK', 'default', '3000', 'Virksomhedskapital', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 250),
  ('DK', 'default', '3010', 'Overkurs ved emission', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 260),
  ('DK', 'default', '3020', 'Reserve for opskrivninger', '{"en":"Reserve for revaluations"}'::jsonb, 'equity', false, null, 270),
  ('DK', 'default', '3030', 'Andre reserver', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 280),
  ('DK', 'default', '3040', 'Reserve for udviklingsomkostninger', '{"en":"Reserve for development costs"}'::jsonb, 'equity', false, null, 285),
  ('DK', 'default', '3045', 'Vedtægtsmæssige reserver', '{"en":"Reserves required by the articles of association"}'::jsonb, 'equity', false, null, 288),
  ('DK', 'default', '3090', 'Overført overskud eller underskud', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 290),
  ('DK', 'default', '4010', 'Hensættelse til pension og lignende forpligtelser', '{"en":"Provision for pensions and similar obligations"}'::jsonb, 'liability_non_current', false, null, 300),
  ('DK', 'default', '4015', 'Hensættelse til garantiforpligtelser', '{"en":"Provision for warranty obligations"}'::jsonb, 'liability_non_current', false, null, 305),
  ('DK', 'default', '4020', 'Hensættelse til udskudt skat', '{"en":"Provision for deferred tax"}'::jsonb, 'liability_non_current', false, null, 310),
  ('DK', 'default', '4025', 'Hensættelse til tab på igangværende arbejder', '{"en":"Provision for losses on work in progress"}'::jsonb, 'liability_non_current', false, null, 315),
  ('DK', 'default', '4030', 'Andre hensatte forpligtelser', '{"en":"Other provisions"}'::jsonb, 'liability_non_current', false, null, 320),
  ('DK', 'default', '4110', 'Gæld til kreditinstitutter — langfristet del', '{"en":"Debt to credit institutions — non-current part"}'::jsonb, 'liability_non_current', false, null, 330),
  ('DK', 'default', '4115', 'Gæld til realkreditinstitutter — langfristet del', '{"en":"Debt to mortgage credit institutions — non-current part"}'::jsonb, 'liability_non_current', false, null, 335),
  ('DK', 'default', '4120', 'Anden langfristet gæld', '{"en":"Other non-current liabilities"}'::jsonb, 'liability_non_current', false, null, 340),
  ('DK', 'default', '4125', 'Leasingforpligtelse — langfristet del', '{"en":"Lease liability — non-current part"}'::jsonb, 'liability_non_current', false, null, 345),
  ('DK', 'default', '4130', 'Gæld til virksomhedsdeltagere og ledelse — langfristet', '{"en":"Debt to owners and management — non-current"}'::jsonb, 'liability_non_current', false, null, 350),
  ('DK', 'default', '4135', 'Konvertible gældsbreve', '{"en":"Convertible debt"}'::jsonb, 'liability_non_current', false, null, 355),
  ('DK', 'default', '5010', 'Gæld til kreditinstitutter — kortfristet del', '{"en":"Debt to credit institutions — current part"}'::jsonb, 'liability_current', false, null, 360),
  ('DK', 'default', '5015', 'Gæld til realkreditinstitutter — kortfristet del', '{"en":"Debt to mortgage credit institutions — current part"}'::jsonb, 'liability_current', false, null, 365),
  ('DK', 'default', '5020', 'Kassekredit', '{"en":"Bank overdraft"}'::jsonb, 'liability_current', false, null, 370),
  ('DK', 'default', '5025', 'Leasingforpligtelse — kortfristet del', '{"en":"Lease liability — current part"}'::jsonb, 'liability_current', false, null, 375),
  ('DK', 'default', '5100', 'Leverandører af varer og tjenesteydelser', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 380),
  ('DK', 'default', '5105', 'Leverandørgæld til tilknyttede virksomheder', '{"en":"Payables to group undertakings"}'::jsonb, 'liability_current', false, null, 385),
  ('DK', 'default', '5150', 'Modtagne forudbetalinger fra kunder', '{"en":"Prepayments received from customers"}'::jsonb, 'liability_current', false, null, 390),
  ('DK', 'default', '5155', 'Deposita fra kunder', '{"en":"Deposits received from customers"}'::jsonb, 'liability_current', false, null, 392),
  ('DK', 'default', '5160', 'Udgående moms — salgsmoms', '{"en":"Output VAT — payable"}'::jsonb, 'liability_current', false, null, 400),
  ('DK', 'default', '5170', 'Afgift af varekøb og ydelseskøb fra udlandet — udgående del', '{"en":"Tax on foreign purchases — payable part"}'::jsonb, 'liability_current', false, null, 405),
  ('DK', 'default', '5180', 'Skyldig løn', '{"en":"Wages payable"}'::jsonb, 'liability_current', false, null, 407),
  ('DK', 'default', '5190', 'Skyldige feriepenge', '{"en":"Holiday pay payable"}'::jsonb, 'liability_current', false, null, 408),
  ('DK', 'default', '5199', 'Skyldig moms — afregningskonto', '{"en":"VAT payable — settlement account"}'::jsonb, 'liability_current', true, null, 410),
  ('DK', 'default', '5200', 'Skyldigt ATP-bidrag', '{"en":"Labour-market supplementary pension (ATP) payable"}'::jsonb, 'liability_current', false, null, 415),
  ('DK', 'default', '5210', 'Skyldig A-skat og AM-bidrag', '{"en":"Payroll tax and labour-market contributions payable"}'::jsonb, 'liability_current', false, null, 420),
  ('DK', 'default', '5220', 'Anden gæld', '{"en":"Other payables"}'::jsonb, 'liability_current', false, null, 430),
  ('DK', 'default', '5225', 'Skyldige renter', '{"en":"Interest payable"}'::jsonb, 'liability_current', false, null, 432),
  ('DK', 'default', '5230', 'Periodeafgrænsningsposter — passiv', '{"en":"Accruals — liabilities"}'::jsonb, 'liability_current', false, null, 440),
  ('DK', 'default', '5235', 'Anden gæld til det offentlige', '{"en":"Other payables to public authorities"}'::jsonb, 'liability_current', false, null, 442),
  ('DK', 'default', '5240', 'Gæld til virksomhedsdeltagere og ledelse — kortfristet', '{"en":"Debt to owners and management — current"}'::jsonb, 'liability_current', false, null, 450),
  ('DK', 'default', '5250', 'Mellemregning under afklaring', '{"en":"Suspense account, pending clearing"}'::jsonb, 'liability_current', false, null, 460),
  ('DK', 'default', '6000', 'Salg af varer og ydelser — indland', '{"en":"Sale of goods and services — domestic"}'::jsonb, 'income', false, null, 470),
  ('DK', 'default', '6005', 'Salg til tilknyttede virksomheder', '{"en":"Sale to group undertakings"}'::jsonb, 'income', false, null, 472),
  ('DK', 'default', '6010', 'Salg af varer — andre EU-lande', '{"en":"Sale of goods — other EU countries"}'::jsonb, 'income', false, null, 480),
  ('DK', 'default', '6015', 'Salg af ydelser — indland', '{"en":"Sale of services — domestic"}'::jsonb, 'income', false, null, 485),
  ('DK', 'default', '6020', 'Salg af ydelser — andre EU-lande', '{"en":"Sale of services — other EU countries"}'::jsonb, 'income', false, null, 490),
  ('DK', 'default', '6030', 'Salg af varer og ydelser — uden for EU (eksport)', '{"en":"Sale of goods and services — outside the EU (export)"}'::jsonb, 'income', false, null, 500),
  ('DK', 'default', '6040', 'Udlejningsindtægter — momsfri', '{"en":"Rental income — VAT exempt"}'::jsonb, 'income', false, null, 510),
  ('DK', 'default', '6900', 'Andre driftsindtægter', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 520),
  ('DK', 'default', '6910', 'Lejeindtægter — momspligtig', '{"en":"Rental income — taxable"}'::jsonb, 'income_other', false, null, 522),
  ('DK', 'default', '6920', 'Avance ved salg af anlægsaktiver', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 524),
  ('DK', 'default', '6930', 'Offentlige tilskud', '{"en":"Public grants"}'::jsonb, 'income_other', false, null, 526),
  ('DK', 'default', '7010', 'Varekøb — indland', '{"en":"Purchase of goods — domestic"}'::jsonb, 'expense_direct_cost', false, null, 530),
  ('DK', 'default', '7015', 'Varekøb — uden for EU (import)', '{"en":"Purchase of goods — outside the EU (import)"}'::jsonb, 'expense_direct_cost', false, null, 535),
  ('DK', 'default', '7020', 'Varekøb — andre EU-lande', '{"en":"Purchase of goods — other EU countries"}'::jsonb, 'expense_direct_cost', false, null, 540),
  ('DK', 'default', '7025', 'Fragt og told', '{"en":"Freight and customs duties"}'::jsonb, 'expense_direct_cost', false, null, 545),
  ('DK', 'default', '7030', 'Fremmed arbejde', '{"en":"Subcontracted work"}'::jsonb, 'expense_direct_cost', false, null, 550),
  ('DK', 'default', '7035', 'Underleverandører', '{"en":"Subcontractors"}'::jsonb, 'expense_direct_cost', false, null, 555),
  ('DK', 'default', '7110', 'Lokaleomkostninger', '{"en":"Premises costs"}'::jsonb, 'expense', false, null, 560),
  ('DK', 'default', '7115', 'Husleje', '{"en":"Rent"}'::jsonb, 'expense', false, null, 562),
  ('DK', 'default', '7120', 'Kontorhold og it', '{"en":"Office and IT costs"}'::jsonb, 'expense', false, null, 570),
  ('DK', 'default', '7125', 'El vand og varme', '{"en":"Electricity, water and heating"}'::jsonb, 'expense', false, null, 572),
  ('DK', 'default', '7130', 'Salgs- og rejseomkostninger', '{"en":"Sales and travel costs"}'::jsonb, 'expense', false, null, 580),
  ('DK', 'default', '7135', 'Rengøring', '{"en":"Cleaning"}'::jsonb, 'expense', false, null, 582),
  ('DK', 'default', '7140', 'Autodrift', '{"en":"Vehicle running costs"}'::jsonb, 'expense', false, null, 590),
  ('DK', 'default', '7145', 'Reparation og vedligeholdelse', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 592),
  ('DK', 'default', '7150', 'Forsikringer', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 600),
  ('DK', 'default', '7155', 'Marketing og annoncer', '{"en":"Marketing and advertising"}'::jsonb, 'expense', false, null, 602),
  ('DK', 'default', '7160', 'Køb af ydelser — andre EU-lande', '{"en":"Purchase of services — other EU countries"}'::jsonb, 'expense', false, null, 610),
  ('DK', 'default', '7165', 'Telefon og internet', '{"en":"Telephone and internet"}'::jsonb, 'expense', false, null, 612),
  ('DK', 'default', '7170', 'Køb af ydelser — uden for EU', '{"en":"Purchase of services — outside the EU"}'::jsonb, 'expense', false, null, 620),
  ('DK', 'default', '7175', 'Kontingenter og abonnementer', '{"en":"Membership fees and subscriptions"}'::jsonb, 'expense', false, null, 622),
  ('DK', 'default', '7180', 'Revisor og advokat', '{"en":"Auditor and legal fees"}'::jsonb, 'expense', false, null, 630),
  ('DK', 'default', '7185', 'Småanskaffelser', '{"en":"Minor acquisitions"}'::jsonb, 'expense', false, null, 632),
  ('DK', 'default', '7195', 'Porto og gebyrer', '{"en":"Postage and bank charges"}'::jsonb, 'expense', false, null, 635),
  ('DK', 'default', '7197', 'Kursus og uddannelse', '{"en":"Courses and training"}'::jsonb, 'expense', false, null, 638),
  ('DK', 'default', '7210', 'Lønninger', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, null, 640),
  ('DK', 'default', '7215', 'Feriepenge', '{"en":"Holiday pay"}'::jsonb, 'expense', false, null, 645),
  ('DK', 'default', '7220', 'Pensioner', '{"en":"Pensions"}'::jsonb, 'expense', false, null, 650),
  ('DK', 'default', '7225', 'ATP-bidrag', '{"en":"Labour-market supplementary pension (ATP)"}'::jsonb, 'expense', false, null, 655),
  ('DK', 'default', '7230', 'Andre omkostninger til social sikring', '{"en":"Other social security costs"}'::jsonb, 'expense', false, null, 660),
  ('DK', 'default', '7235', 'Personaleforsikringer', '{"en":"Staff insurance"}'::jsonb, 'expense', false, null, 665),
  ('DK', 'default', '7310', 'Af- og nedskrivninger af materielle og immaterielle anlægsaktiver', '{"en":"Depreciation and amortisation of property, plant, equipment and intangible assets"}'::jsonb, 'expense_depreciation', false, null, 670),
  ('DK', 'default', '7315', 'Nedskrivning af anlægsaktiver', '{"en":"Impairment of fixed assets"}'::jsonb, 'expense_depreciation', false, null, 672),
  ('DK', 'default', '7900', 'Andre driftsomkostninger', '{"en":"Other operating costs"}'::jsonb, 'expense', false, null, 680),
  ('DK', 'default', '7910', 'Tab på debitorer', '{"en":"Bad debt losses"}'::jsonb, 'expense', false, null, 682),
  ('DK', 'default', '8010', 'Andre finansielle indtægter', '{"en":"Other financial income"}'::jsonb, 'income_other', false, null, 690),
  ('DK', 'default', '8015', 'Renteindtægter — bank', '{"en":"Interest income — bank"}'::jsonb, 'income_other', false, null, 692),
  ('DK', 'default', '8020', 'Valutakursgevinster', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, null, 700),
  ('DK', 'default', '8090', 'Rundingsdifferencer', '{"en":"Rounding differences"}'::jsonb, 'income_other', false, null, 710),
  ('DK', 'default', '8110', 'Øvrige finansielle omkostninger', '{"en":"Other financial costs"}'::jsonb, 'expense', false, null, 720),
  ('DK', 'default', '8115', 'Renteomkostninger — kreditinstitutter', '{"en":"Interest costs — credit institutions"}'::jsonb, 'expense', false, null, 722),
  ('DK', 'default', '8120', 'Valutakurstab', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, null, 730),
  ('DK', 'default', '8200', 'Skat af årets resultat', '{"en":"Tax on the result for the year"}'::jsonb, 'expense', false, null, 740),
  ('DK', 'default', '8210', 'Udskudt skat — årets regulering', '{"en":"Deferred tax — movement for the year"}'::jsonb, 'expense', false, null, 745),
  ('DK', 'default', '8300', 'Andre skatter', '{"en":"Other taxes"}'::jsonb, 'expense', false, null, 750),
  ('DK', 'default', '8310', 'Ejendomsskatter', '{"en":"Property taxes"}'::jsonb, 'expense', false, null, 755)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('DK', 'BNK', 'Bankbog', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('DK', 'DIV', 'Diversebog', '{"en":"Miscellaneous journal"}'::jsonb, 'general', 50),
  ('DK', 'KAS', 'Kassebog', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('DK', 'OPN', 'Åbningsbalance', '{"en":"Opening balance"}'::jsonb, 'opening', 60),
  ('DK', 'PUR', 'Købsbog', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('DK', 'SAL', 'Salgsbog', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('DK', 'DK-P-25', 'Køb — 25 % standardsats, fradragsberettiget', '{"en":"Purchase — 25% standard rate, deductible"}'::jsonb, null, 'percent', 25, 'purchase', 'domestic', date '1992-01-01', null, 'Momsloven, § 33 og § 37, stk. 1 — en registreret virksomhed kan ved opgørelsen af afgiftstilsvaret fradrage afgiften for varer og ydelser, der udelukkende anvendes til brug for virksomhedens fradragsberettigede leverancer', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-P-EU-GOODS', 'Erhvervelse af varer fra andre EU-lande — omvendt betalingspligt', '{"en":"Acquisition of goods from other EU countries — reverse charge"}'::jsonb, null, 'percent', 25, 'purchase', 'intracom_acquisition_goods', date '1993-01-01', null, 'Momsloven, § 11, stk. 1, nr. 1 — der betales afgift ved erhvervelse mod vederlag af varer fra andre EU-lande, når sælgeren er en afgiftspligtig person registreret for merværdiafgift i et andet EU-land og erhververen er en afgiftspligtig person her i landet; § 46, stk. 4 — afgiften påhviler den, der foretager en afgiftspligtig erhvervelse; § 37, stk. 1 — afgiften er samtidig fradragsberettiget hos erhververen', 'K', 'VATEX-EU-IC', 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-P-EU-SERVICES', 'Køb af ydelser fra andre EU-lande — omvendt betalingspligt', '{"en":"Purchase of services from other EU countries — reverse charge"}'::jsonb, null, 'percent', 25, 'purchase', 'intracom_acquisition_services', date '2010-01-01', null, 'Momsloven, § 16, stk. 1 og § 46, stk. 1, nr. 3 — leveringsstedet for en ydelse leveret til en dansk afgiftspligtig person af en afgiftspligtig person, der ikke er etableret her i landet, er her i landet, og køberen afregner afgiften; § 37, stk. 1 — afgiften er samtidig fradragsberettiget', 'K', 'VATEX-EU-IC', 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-P-NONEU-SERVICES', 'Køb af ydelser fra lande uden for EU — omvendt betalingspligt', '{"en":"Purchase of services from outside the EU — reverse charge"}'::jsonb, null, 'percent', 25, 'purchase', 'foreign_services_received', date '2010-01-01', null, 'Momsloven, § 16, stk. 1 og § 46, stk. 1, nr. 3 — den almindelige hovedregel om leveringssted efter modtagerens hjemsted gælder uanset hvor leverandøren er etableret, og køberen afregner afgiften af ydelseskøb i udlandet med omvendt betalingspligt; § 37, stk. 1 — afgiften er samtidig fradragsberettiget', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-S-25', 'Salg — 25 % standardsats', '{"en":"Sale — 25% standard rate"}'::jsonb, null, 'percent', 25, 'sale', 'domestic', date '1992-01-01', null, 'Momsloven, § 33 — afgiften udgør 25 pct. af afgiftsgrundlaget. Danmark har kun denne ene sats: der findes ingen nedsat sats', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-S-EU-GOODS-0', 'Salg af varer til andre EU-lande — 0 %', '{"en":"Sale of goods to other EU countries — 0%"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_goods', date '1993-01-01', null, 'Momsloven, § 34, stk. 1, nr. 1 — levering af varer, der af virksomheden eller af erhververen eller for disses regning forsendes eller transporteres til et andet EU-land, er fritaget for afgift, når erhververen er en afgiftspligtig person eller en ikkeafgiftspligtig juridisk person, der er registreret for merværdiafgift i et andet EU-land', 'K', 'VATEX-EU-IC', 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-S-EU-SERVICES-0', 'Salg af ydelser til andre EU-lande — omvendt betalingspligt', '{"en":"Sale of services to other EU countries — reverse charge"}'::jsonb, null, 'percent', 0, 'sale', 'intracom_services', date '2010-01-01', null, 'Momsloven, § 16, stk. 1 — leveringsstedet for en ydelse leveret til en afgiftspligtig person er dér, hvor denne har etableret stedet for sin økonomiske virksomhed; er dette et andet EU-land, ligger leveringsstedet uden for Danmark, og modtageren afregner ydelsesmomsen i sit eget land efter momssystemdirektivets artikel 196', 'K', 'VATEX-EU-IC', 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-S-EXEMPT-PROPERTY', 'Udlejning af fast ejendom — momsfri', '{"en":"Letting of immovable property — VAT exempt"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '1967-01-01', null, 'Momsloven, § 13, stk. 1, nr. 8 — udlejning og bortforpagtning af fast ejendom, herunder den hertil knyttede levering af gas, vand, elektricitet og varme, er fritaget for afgift. En udlejer kan i visse tilfælde lade sig frivilligt registrere for udlejningen efter § 51, hvorved leverancen i stedet afgiftsbelægges; det er ikke modelleret her', 'E', 'VATEX-EU-135-1', 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null),
  ('DK', 'DK-S-EXPORT-0', 'Udførsel til steder uden for EU — 0 %', '{"en":"Export outside the EU — 0%"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '1993-01-01', null, 'Momsloven, § 34, stk. 1, nr. 5 — levering af varer, som af virksomheden eller for dennes regning udføres til steder uden for EU, er fritaget for afgift', 'G', 'VATEX-EU-G', 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'momsloven', null, null, null, null)
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
    ('DK-P-25', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DK-P-25', 'invoice', 'tax', 100, '2160', 'koebs', array['koebs']::text[], 100, 'DK-MOMS', 20),
    ('DK-P-25', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('DK-P-25', 'credit_note', 'tax', 100, '2160', 'koebs', array['koebs']::text[], -100, 'DK-MOMS', 20),
    ('DK-P-EU-GOODS', 'invoice', 'base', 100, null, 'avarer', array['avarer']::text[], 100, 'DK-MOMS', 10),
    ('DK-P-EU-GOODS', 'invoice', 'tax', 100, '2170', 'koebs', array['koebs']::text[], 100, 'DK-MOMS', 20),
    ('DK-P-EU-GOODS', 'invoice', 'tax', -100, '5170', 'eumoms', array['eumoms']::text[], 100, 'DK-MOMS', 30),
    ('DK-P-EU-GOODS', 'credit_note', 'base', 100, null, 'avarer', array['avarer']::text[], -100, 'DK-MOMS', 10),
    ('DK-P-EU-GOODS', 'credit_note', 'tax', 100, '2170', 'koebs', array['koebs']::text[], -100, 'DK-MOMS', 20),
    ('DK-P-EU-GOODS', 'credit_note', 'tax', -100, '5170', 'eumoms', array['eumoms']::text[], -100, 'DK-MOMS', 30),
    ('DK-P-EU-SERVICES', 'invoice', 'base', 100, null, 'aydels', array['aydels']::text[], 100, 'DK-MOMS', 10),
    ('DK-P-EU-SERVICES', 'invoice', 'tax', 100, '2170', 'koebs', array['koebs']::text[], 100, 'DK-MOMS', 20),
    ('DK-P-EU-SERVICES', 'invoice', 'tax', -100, '5170', 'ydmoms', array['ydmoms']::text[], 100, 'DK-MOMS', 30),
    ('DK-P-EU-SERVICES', 'credit_note', 'base', 100, null, 'aydels', array['aydels']::text[], -100, 'DK-MOMS', 10),
    ('DK-P-EU-SERVICES', 'credit_note', 'tax', 100, '2170', 'koebs', array['koebs']::text[], -100, 'DK-MOMS', 20),
    ('DK-P-EU-SERVICES', 'credit_note', 'tax', -100, '5170', 'ydmoms', array['ydmoms']::text[], -100, 'DK-MOMS', 30),
    ('DK-P-NONEU-SERVICES', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DK-P-NONEU-SERVICES', 'invoice', 'tax', 100, '2170', 'koebs', array['koebs']::text[], 100, 'DK-MOMS', 20),
    ('DK-P-NONEU-SERVICES', 'invoice', 'tax', -100, '5170', 'ydmoms', array['ydmoms']::text[], 100, 'DK-MOMS', 30),
    ('DK-P-NONEU-SERVICES', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('DK-P-NONEU-SERVICES', 'credit_note', 'tax', 100, '2170', 'koebs', array['koebs']::text[], -100, 'DK-MOMS', 20),
    ('DK-P-NONEU-SERVICES', 'credit_note', 'tax', -100, '5170', 'ydmoms', array['ydmoms']::text[], -100, 'DK-MOMS', 30),
    ('DK-S-25', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DK-S-25', 'invoice', 'tax', 100, '5160', 'salgs', array['salgs']::text[], 100, 'DK-MOMS', 20),
    ('DK-S-25', 'credit_note', 'base', 100, null, null, null, -100, null, 10),
    ('DK-S-25', 'credit_note', 'tax', 100, '5160', 'salgs', array['salgs']::text[], -100, 'DK-MOMS', 20),
    ('DK-S-EU-GOODS-0', 'invoice', 'base', 100, null, 'bvarer', array['bvarer']::text[], 100, 'DK-MOMS', 10),
    ('DK-S-EU-GOODS-0', 'credit_note', 'base', 100, null, 'bvarer', array['bvarer']::text[], -100, 'DK-MOMS', 10),
    ('DK-S-EU-SERVICES-0', 'invoice', 'base', 100, null, 'bydels', array['bydels']::text[], 100, 'DK-MOMS', 10),
    ('DK-S-EU-SERVICES-0', 'credit_note', 'base', 100, null, 'bydels', array['bydels']::text[], -100, 'DK-MOMS', 10),
    ('DK-S-EXEMPT-PROPERTY', 'invoice', 'base', 100, null, 'c', array['c']::text[], 100, 'DK-MOMS', 10),
    ('DK-S-EXEMPT-PROPERTY', 'credit_note', 'base', 100, null, 'c', array['c']::text[], -100, 'DK-MOMS', 10),
    ('DK-S-EXPORT-0', 'invoice', 'base', 100, null, 'c', array['c']::text[], 100, 'DK-MOMS', 10),
    ('DK-S-EXPORT-0', 'credit_note', 'base', 100, null, 'c', array['c']::text[], -100, 'DK-MOMS', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'DK' and t.code = v.tax_code
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
  ('DK', 'DK-MOMS', 'Momsangivelse', array['month', 'quarter', 'half_year']::declaration_period[], null, date '1992-01-01', null, 'Momsloven, § 57 — afgiftsperioden er kalendermåneden for virksomheder, hvis samlede afgiftspligtige leverancer overstiger 50 mio. kr. årligt; kalenderkvartalet for virksomheder, hvis leverancer overstiger 5 mio. kr., men ikke 50 mio. kr. årligt; og halvåret for virksomheder, hvis leverancer ikke overstiger 5 mio. kr. årligt. Loven giver ikke én afgiftsperiode til alle virksomheder, hvorfor pakken ikke angiver period_default', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, 'Momsloven, § 57, stk. 1 — den månedlige angivelse skal foretages senest den 25. i måneden efter afgiftsperiodens udløb (med en forlængelse til 1 måned og 17 dage for juni). § 57, stk. 3 og 4 giver kvartalsvise og halvårlige afgiftsperioder en senere frist, den 1. i den tredje måned efter periodens udløb, som dette formats tre lukkede regler ikke kan udtrykke (to måneder ud, ikke én) — se docs/international.md, afsnittet »From Denmark«. Den 25. er derfor aldrig senere end loven, og typisk tidligere for en kvartals- eller halvårsangiver, efter samme løsning som packs/au/ vælger for sin egen flercadence-frist', 'momsloven', null)
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
  ('DK', 'DK-MOMS', 'salgs', 'tax', 'Salgsmoms (udgående moms)', '{"en":"Output VAT"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Hjælpetekster til momsangivelsen — Salgsmoms (Udgående moms): »Her skriver du den moms, du har opkrævet ved dit salg af varer og ydelser i momsperioden«', 'momsangivelsen-hjaelp'),
  ('DK', 'DK-MOMS', 'eumoms', 'tax', 'Moms af varekøb i udlandet', '{"en":"VAT on goods purchased abroad"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 76, stk. 1, nr. 3 og § 76, stk. 5 — kontoen for afgift af varekøb fra udlandet omfatter afgiften af EU-erhvervelser af varer, jf. momslovens § 11. Hjælpetekster til momsangivelsen: »Momsen af varekøb fra momsregistrerede virksomheder i andre EU-lande (25 % af det beløb, du indberetter i rubrik A – varer)«', 'momsbekendtgoerelsen'),
  ('DK', 'DK-MOMS', 'ydmoms', 'tax', 'Moms af ydelseskøb i udlandet med omvendt betalingspligt', '{"en":"VAT on services purchased abroad, reverse charge"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 76, stk. 1, nr. 4 og § 76, stk. 6 — kontoen for afgift af køb af ydelser fra udlandet med omvendt betalingspligt efter momslovens § 46, stk. 1, nr. 3, uden forskel på om leverandøren er etableret i et andet EU-land eller uden for EU. Hjælpetekster til momsangivelsen: »Du beregner momsen med 25 % af ydelsernes fakturaværdi«', 'momsangivelsen-hjaelp'),
  ('DK', 'DK-MOMS', 'koebs', 'tax', 'Købsmoms (indgående moms)', '{"en":"Input VAT"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsloven, § 37, stk. 1. Hjælpetekster til momsangivelsen — Købsmoms (indgående moms): »Her skriver du momsen af de fradragsberettigede køb, du har haft i momsperioden … Hvis du har indtastet moms af køb i udlandet i felterne ovenfor, kan du også trække disse momsbeløb fra sammen med momsen af dine danske køb«', 'momsangivelsen-hjaelp'),
  ('DK', 'DK-MOMS', 'ialt', 'total', 'Momstilsvar (moms i alt)', '{"en":"Net VAT (total)"}'::jsonb, 50, null, array['salgs', 'eumoms', 'ydmoms']::text[], array['koebs']::text[], null, null, false, false, null, 'Momsloven, § 56, stk. 1 — den samlede afgiftspligtiges udgående afgift med fradrag af indgående afgift efter kapitel 9 er virksomhedens afgiftstilsvar for perioden. Hjælpetekster til momsangivelsen — Moms i alt: »Feltet viser beløbet af din samlede moms på grundlag af de tal, du har indtastet i felterne ovenfor. Hvis beløbet er positivt, betyder det, at du skal betale, og er det negativt, har du penge til gode«, hvorfor boksen ikke bundes ved nul', 'momsloven'),
  ('DK', 'DK-MOMS', 'avarer', 'base', 'Rubrik A – varer: værdi af varekøb i andre EU-lande', '{"en":"Box A – goods: value of goods purchased in other EU countries"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 79, stk. 1, nr. 1 og stk. 2 — værdien uden afgift af erhvervelse af varer fra andre EU-lande, jf. momslovens § 11', 'momsbekendtgoerelsen'),
  ('DK', 'DK-MOMS', 'aydels', 'base', 'Rubrik A – ydelser: værdi af ydelseskøb i andre EU-lande', '{"en":"Box A – services: value of services purchased in other EU countries"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 79, stk. 1, nr. 2 og stk. 3 — værdien uden afgift af køb af ydelser fra andre EU-lande, når køberen er betalingspligtig for afgiften efter momslovens § 46, stk. 1, nr. 3', 'momsbekendtgoerelsen'),
  ('DK', 'DK-MOMS', 'bvarer', 'base', 'Rubrik B – varer, EU-salgsangivelse', '{"en":"Box B – goods, EC sales list"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 79, stk. 1, nr. 3 og stk. 4 — værdien uden afgift af leverancer af varer til registrerede købere i andre EU-lande, jf. momslovens § 34, stk. 1, nr. 1-4', 'momsbekendtgoerelsen'),
  ('DK', 'DK-MOMS', 'bydels', 'base', 'Rubrik B – ydelser', '{"en":"Box B – services"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 79, stk. 1, nr. 5 og stk. 6 — værdien uden afgift af leverancer af ydelser til andre EU-lande, hvor køberen er betalingspligtig for afgiften, idet leveringsstedet er bestemt efter momslovens § 16, stk. 1', 'momsbekendtgoerelsen'),
  ('DK', 'DK-MOMS', 'c', 'base', 'Rubrik C: andre varer og ydelser leveret uden afgift her i landet, i andre EU-lande og i lande uden for EU', '{"en":"Box C: other goods and services supplied without tax domestically, in other EU countries and outside the EU"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Momsbekendtgørelsen, § 79, stk. 1, nr. 6 og stk. 7 — værdien uden afgift af leverancer af andre varer og ydelser til købere her i landet, til andre EU-lande og til steder uden for EU. Rubrik C er et opsamlingsfelt for det momsfri salg, der ikke skal medtages i en af de tre B-rubrikker: momsfri udførsel efter § 34, stk. 1, nr. 5-21, og momsfri leverancer efter § 13', 'momsbekendtgoerelsen')
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
  ('DK-ARL-BS', 'DK', 'default', 'Balance i kontoform — bilag 2, skema 1', 'balance_sheet', 'DK-ARL', date '2016-01-01', null, 'Årsregnskabsloven, § 23, stk. 1, jf. bilag 2, skema 1 — balancen i kontoform, for virksomheder i regnskabsklasse B, C og D. Kontoplanets ni klasser er selv bygget om denne opstillings hovedposter, hvilket er hvorfor koderne herunder ser vilkårlige ud', 'arsregnskabsloven'),
  ('DK-ARL-IS', 'DK', 'default', 'Resultatopgørelse i beretningsform, artsopdelt — bilag 2, skema 3', 'income_statement', 'DK-ARL', date '2016-01-01', null, 'Årsregnskabsloven, § 23, stk. 1, jf. bilag 2, skema 3 — resultatopgørelsen i beretningsform, artsopdelt, for virksomheder i regnskabsklasse B, C og D', 'arsregnskabsloven')
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
  ('DK-ARL-BS', 'AKTIVER', null, 'AKTIVER I ALT', '{"en":"TOTAL ASSETS"}'::jsonb, 5, 1, true, array['A', 'B']::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'A', null, 'Anlægsaktiver', '{"en":"Fixed assets"}'::jsonb, 10, 1, true, array['A.I', 'A.II', 'A.III']::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'A.I', 'A', 'Immaterielle anlægsaktiver', '{"en":"Intangible fixed assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'A.II', 'A', 'Materielle anlægsaktiver', '{"en":"Property, plant and equipment"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'A.III', 'A', 'Finansielle anlægsaktiver', '{"en":"Financial fixed assets"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'B', null, 'Omsætningsaktiver', '{"en":"Current assets"}'::jsonb, 50, 1, true, array['B.I', 'B.II', 'B.III', 'B.IV']::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'B.I', 'B', 'Varebeholdninger', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'B.II', 'B', 'Tilgodehavender', '{"en":"Receivables"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'B.III', 'B', 'Værdipapirer og kapitalandele', '{"en":"Securities and investments"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'B.IV', 'B', 'Likvide beholdninger', '{"en":"Cash and cash equivalents"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'PASSIVER', null, 'PASSIVER I ALT', '{"en":"TOTAL EQUITY AND LIABILITIES"}'::jsonb, 95, 1, true, array['C', 'D', 'E', 'F']::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'C', null, 'Egenkapital', '{"en":"Equity"}'::jsonb, 100, 1, true, array['C.I', 'C.II', 'C.III', 'C.IV', 'C.V']::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'C.I', 'C', 'Virksomhedskapital', '{"en":"Share capital"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'C.II', 'C', 'Overkurs ved emission', '{"en":"Share premium"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'C.III', 'C', 'Reserve for opskrivninger', '{"en":"Reserve for revaluations"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'C.IV', 'C', 'Andre reserver', '{"en":"Other reserves"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'C.V', 'C', 'Overført overskud eller underskud', '{"en":"Retained earnings"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'D', null, 'Hensatte forpligtelser', '{"en":"Provisions"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'E', null, 'Langfristede gældsforpligtelser', '{"en":"Non-current liabilities"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-BS', 'F', null, 'Kortfristede gældsforpligtelser', '{"en":"Current liabilities"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '1', null, 'Nettoomsætning', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '4', null, 'Andre driftsindtægter', '{"en":"Other operating income"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '5a', null, 'Omkostninger til råvarer og hjælpematerialer', '{"en":"Cost of raw materials and consumables"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '5b', null, 'Andre eksterne omkostninger', '{"en":"Other external costs"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '6', null, 'Personaleomkostninger', '{"en":"Staff costs"}'::jsonb, 50, 1, true, array['6a', '6b', '6c']::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '6a', '6', 'Lønninger', '{"en":"Wages and salaries"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '6b', '6', 'Pensioner', '{"en":"Pensions"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '6c', '6', 'Andre omkostninger til social sikring', '{"en":"Other social security costs"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '7', null, 'Af- og nedskrivninger af materielle og immaterielle anlægsaktiver', '{"en":"Depreciation and amortisation of property, plant, equipment and intangible assets"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '9', null, 'Andre driftsomkostninger', '{"en":"Other operating costs"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '13', null, 'Andre finansielle indtægter', '{"en":"Other financial income"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '15b', null, 'Andre finansielle omkostninger', '{"en":"Other financial costs"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '16', null, 'Skat af årets resultat', '{"en":"Tax on the result for the year"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '17', null, 'Andre skatter', '{"en":"Other taxes"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DK-ARL-IS', '18', null, 'Årets resultat', '{"en":"Result for the year"}'::jsonb, 150, 1, true, array['1', '4', '13']::text[], array['5a', '5b', '6', '7', '9', '15b', '16', '17']::text[], null, null, null)
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
    ('DK-ARL-BS', 'A.I', 10, 'code_range', '1000', '1099', null, 'any'),
    ('DK-ARL-BS', 'A.II', 10, 'code_range', '1100', '1199', null, 'any'),
    ('DK-ARL-BS', 'A.III', 10, 'code_range', '1200', '1299', null, 'any'),
    ('DK-ARL-BS', 'B.I', 10, 'code_range', '2000', '2099', null, 'any'),
    ('DK-ARL-BS', 'B.II', 10, 'code_range', '2100', '2199', null, 'any'),
    ('DK-ARL-BS', 'B.III', 10, 'code_range', '2200', '2299', null, 'any'),
    ('DK-ARL-BS', 'B.IV', 10, 'code_range', '2300', '2399', null, 'any'),
    ('DK-ARL-BS', 'C.I', 10, 'account_code', '3000', null, null, 'any'),
    ('DK-ARL-BS', 'C.II', 10, 'account_code', '3010', null, null, 'any'),
    ('DK-ARL-BS', 'C.III', 10, 'account_code', '3020', null, null, 'any'),
    ('DK-ARL-BS', 'C.IV', 10, 'code_range', '3030', '3049', null, 'any'),
    ('DK-ARL-BS', 'C.V', 10, 'account_code', '3090', null, null, 'any'),
    ('DK-ARL-BS', 'D', 10, 'code_range', '4000', '4099', null, 'any'),
    ('DK-ARL-BS', 'E', 10, 'code_range', '4100', '4199', null, 'any'),
    ('DK-ARL-BS', 'F', 10, 'code_range', '5000', '5299', null, 'any'),
    ('DK-ARL-IS', '1', 10, 'code_range', '6000', '6099', null, 'any'),
    ('DK-ARL-IS', '4', 10, 'code_range', '6900', '6999', null, 'any'),
    ('DK-ARL-IS', '5a', 10, 'code_range', '7000', '7099', null, 'any'),
    ('DK-ARL-IS', '5b', 10, 'code_range', '7100', '7199', null, 'any'),
    ('DK-ARL-IS', '6a', 10, 'code_range', '7210', '7219', null, 'any'),
    ('DK-ARL-IS', '6b', 10, 'account_code', '7220', null, null, 'any'),
    ('DK-ARL-IS', '6c', 10, 'code_range', '7225', '7249', null, 'any'),
    ('DK-ARL-IS', '7', 10, 'code_range', '7300', '7399', null, 'any'),
    ('DK-ARL-IS', '9', 10, 'code_range', '7900', '7999', null, 'any'),
    ('DK-ARL-IS', '13', 10, 'code_range', '8000', '8099', null, 'any'),
    ('DK-ARL-IS', '15b', 10, 'code_range', '8100', '8199', null, 'any'),
    ('DK-ARL-IS', '16', 10, 'code_range', '8200', '8299', null, 'any'),
    ('DK-ARL-IS', '17', 10, 'code_range', '8300', '8399', null, 'any')
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
  ('DK', 'Danmark', '{"en":"Denmark"}'::jsonb, array['da', 'en']::text[], 'DKK', '2100', '5100', '5250', '8090', '3090', '6000', '7010', '2310', '2330', 'SAL', 'PUR', 'DIV', 'da', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '8020', '8120', null, null, null, null, '5199', '2199', 'Åbningsbalance', null)
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
  number_format                 = '{CODE}-{NNNNNN}',
  legal_payment_days            = 30,
  late_payment_reference        = 'Renteloven, § 3 og § 5 — er ingen betalingsdag aftalt, forfalder rentekravet 30 dage efter fakturadatoen, med en morarente på Nationalbankens udlånsrente med tillæg af 8 procentpoint',
  numbering_legal_reference     = 'Momsbekendtgørelsen, § 58, stk. 1, nr. 2 — fakturaen skal indeholde »et fortløbende nummer, der bygger på en eller flere serier, og som identificerer fakturaen«. Bekendtgørelsen kræver et fortløbende nummer og angiver ingen form; gapless er den lovtro læsning, uden at teksten kræver en årlig nulstilling',
  numbering_source_key          = 'momsbekendtgoerelsen',
  payment_terms_legal_reference = 'Renteloven, § 3, stk. 1 — er der ikke forud fastsat en betalingsdag, indtræder forpligtelsen til at betale rente, når der er forløbet 30 dage efter den dag, da fordringshaveren afsendte eller fremsatte anmodning om betaling',
  payment_terms_source_key      = 'renteloven',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Momsloven, § 23, stk. 1 — afgiftspligten indtræder på det tidspunkt, hvor leveringen af varen eller ydelsen finder sted; stk. 2 — udstedes der faktura over leverancen, anses faktureringstidspunktet som leveringstidspunkt, for så vidt faktureringen sker inden eller snarest efter leverancens afslutning. invoice_if_issued er de to stykker sammen: leveringen er hovedreglen, fakturaen fortrænger den, når den udstedes rettidigt',
  tax_point_source_key          = 'momsloven',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Momsbekendtgørelsen, § 68, stk. 1 — ved sikring af fakturaens indholdsintegritet forstås, at fakturaens indhold, jf. § 58, stk. 1, §§ 59-62, 66, stk. 1, eller § 67, stk. 1, ikke kan ændres eller slettes; bogføringslovens § 9, stk. 3 — foretages der rettelser i bilagsmaterialet, skal det oprindelige indhold og indholdet af ændringen tydeligt fremgå. En udstedt faktura rettes derfor ved et nyt dokument, aldrig ved at ændre den',
  posted_edit_policy_source_key = 'momsbekendtgoerelsen',
  einvoice_profile              = 'peppol-bis-3',
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Ingen dansk lov pålægger en virksomhed at udstede eller modtage en elektronisk faktura i samhandlen mellem virksomheder. Pligten, der findes, er rettet mod det offentlige alene: bekendtgørelse om elektronisk afregning med offentlige myndigheder (BEK nr. 206 af 11. marts 2011), udstedt i medfør af lov om offentlige betalinger m.v., pålægger offentlige myndigheder at modtage og en leverandør til det offentlige at sende fakturaen elektronisk gennem Nemhandel, i formatet OIOUBL eller — i praksis stadig hyppigere — Peppol BIS Billing 3.0 med den danske CIUS. Et forslag til en ny bekendtgørelse, der moderniserer reglerne uden at ændre denne afgrænsning, var i høring til den 3. november 2025. Da forpligtelsen kun retter sig mod det offentlige, sættes obligation til none og mandatory_from er tom. party_scheme og vat_scheme er begge 0184 (DK:CVR i EAS-listen): Danmark har intet selvstændigt momsnummer ud over CVR-nummeret — det danske momsregistreringsnummer er »DK« efterfulgt af CVR-nummerets otte cifre',
  einvoice_source_key           = 'elektronisk-afregning',
  party_scheme                  = '0184',
  vat_scheme                    = '0184',
  bank_statement_formats        = array['camt.053', 'mt940']::text[],
  payment_formats               = array['pain.001']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'DK';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('DK', 'reverse_charge', 'reverse_charge', 'Omvendt betalingspligt — køber afregner momsen.', '{"en":"Reverse charge — the customer accounts for the VAT."}'::jsonb, 10, date '1970-01-01', null, 'Momsbekendtgørelsen, § 58, stk. 1, nr. 16 — er kunden betalingspligtig for afgiften, skal fakturaen indeholde en henvisning til de relevante bestemmelser i momsloven eller til den relevante bestemmelse i momssystemdirektivet, eller enhver anden angivelse af, at leveringen er omfattet af omvendt betalingspligt'),
  ('DK', 'intracom_goods', 'intra_eu_goods', 'Momsfri leverance — momslovens § 34, stk. 1, nr. 1.', '{"en":"VAT-exempt supply — Danish VAT act, section 34(1)(1)."}'::jsonb, 20, date '1970-01-01', null, 'Momsbekendtgørelsen, § 58, stk. 1, nr. 15 — finder momslovens § 34, stk. 1, nr. 1-4, anvendelse, skal fakturaen indeholde en henvisning til denne bestemmelse eller til den relevante bestemmelse i momssystemdirektivet, eller enhver anden angivelse af, at leveringen er fritaget for afgift, samt køberens registreringsnummer, jf. § 58, stk. 1, nr. 17'),
  ('DK', 'intracom_services', 'intra_eu_services', 'Omvendt betalingspligt — køber afregner momsen i eget land.', '{"en":"Reverse charge — the customer accounts for the VAT in its own country."}'::jsonb, 30, date '1970-01-01', null, 'Momsbekendtgørelsen, § 58, stk. 1, nr. 16 — leveringsstedet for ydelsen er bestemt efter momslovens § 16, stk. 1, i køberens land, som er betalingspligtig for afgiften der'),
  ('DK', 'export', 'export', 'Momsfri udførsel — momslovens § 34, stk. 1, nr. 5.', '{"en":"VAT-exempt export — Danish VAT act, section 34(1)(5)."}'::jsonb, 40, date '1970-01-01', null, 'Momsbekendtgørelsen, § 58, stk. 1, nr. 15 — finder momslovens § 34, stk. 1, nr. 5-21, anvendelse, skal fakturaen indeholde en henvisning til denne bestemmelse eller den relevante bestemmelse i momssystemdirektivet, eller enhver anden angivelse af, at leveringen er fritaget for afgift'),
  ('DK', 'exempt', 'exempt', 'Momsfri levering efter momslovens § 13.', '{"en":"VAT-exempt supply under section 13 of the Danish VAT act."}'::jsonb, 50, date '1970-01-01', null, 'Momsbekendtgørelsen, § 58, stk. 1, nr. 15 — finder momslovens § 13 anvendelse, skal fakturaen indeholde en henvisning til denne bestemmelse eller den relevante bestemmelse i momssystemdirektivet, eller enhver anden angivelse af, at leveringen er fritaget for afgift'),
  ('DK', 'late_payment', 'late_payment', 'Ved betaling efter forfaldsdagen beregnes morarente efter rentelovens § 3 og § 5.', '{"en":"Default interest is calculated under sections 3 and 5 of the Danish Interest Act if payment is late."}'::jsonb, 60, date '1970-01-01', null, 'Renteloven, § 3 og § 5 — renten er lovbestemt og forfalder uden forudgående påkrav; angivelsen på fakturaen er kutyme og ikke et lovkrav til fakturaens indhold')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
