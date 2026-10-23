-- Ekwo OS — Suriname: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sr at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build sr`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143), thans geldende tekst — artikelen 2 tot en met 5, 10 tot en met 17, 21, 27 en 30 (btw.sr, geconsolideerde tekst van de wet (Staatsblad van de Republiek Suriname))
--     https://btw.sr/wet-belasting-over-de-toegevoegde-waarde/
--   Wet van 30 december 2022 tot nadere wijziging van de Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 148) — de bijlagen 1 tot en met 4 en de tarieven van 0, 5 en 25 procent, in werking per 1 januari 2023 (Belastingdienst Suriname (Staatsblad van de Republiek Suriname))
--     https://belastingdienst.sr/wp-content/uploads/2023/01/S.B.-2022-no.-148-WET-van-30-december-2022-houdende-nadere-wijziging-van-de-Wet-Belasting-over-de-Toegevoegde-Waarde-2022.pdf
--   Wet Belasting over de Toegevoegde Waarde 2022 — de wet in de wetgeving van De Nationale Assemblée (De Nationale Assemblée van de Republiek Suriname)
--     https://www.dna.sr/wetgeving/surinaamse-wetten/wetten-na-2005/wet-belasting-over-de-toegevoegde-waarde-2022/
--   Beschikking model aangifte BTW (S.B. 2023 no. 31) — het model van de maandelijkse aangifte, de rubrieken 1a tot en met 4j en de toelichting bij het invullen (Ministerie van Financiën en Planning, Staatsblad van de Republiek Suriname)
--     https://www.sris.sr/wp-content/uploads/2023/03/Beschikking-model-aangifte-BTW-S.B.-2023-no.-31.pdf
--   BTW-aangifte — hoe de maandelijkse aangifte online wordt ingediend: hele bedragen, naar beneden afgerond, een nulaangifte, tijdig vóór de 16de dag van de volgende maand, correctie tot en met de 15de (Belastingdienst Suriname)
--     https://belastingdienst.sr/btw-aangifte/
--   Brochure met een beschrijving van de BTW-wetgeving op hoofdlijnen (versie van 28 april 2025) — registratie, drempel van SRD 1.000.000, facturen, kassaregistratie, bewaarplicht (Belastingdienst Suriname)
--     https://belastingdienst.sr/wp-content/uploads/2025/06/Brochure-met-een-beschrijving-van-de-BTW-wetgeving-op-hoofdlijnen-2025.pdf
--   Online Portaal van de Belastingdienst — waar de BTW-aangifte wordt ingediend (Belastingdienst Suriname)
--     https://portaal.belastingdienst.sr/OPO
--   IFRS Foundation — jurisdiction profile Suriname (16 juni 2016): geen wettelijk voorgeschreven stelsel van verslaggevingsstandaarden (IFRS Foundation)
--     https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/suriname-ifrs-profile.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation / International Accounting Standards Board)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SR', 'Suriname', '0.2.0', date '2026-10-23', '20261023124650', 'community', null, null, 'd0752ea79d29a1d3ef1d4fadc18e77c719fa84428daf9fbb7af0666a975b494d', '[{"key":"sr-wet-btw","title":"Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143), thans geldende tekst — artikelen 2 tot en met 5, 10 tot en met 17, 21, 27 en 30","publisher":"btw.sr, geconsolideerde tekst van de wet (Staatsblad van de Republiek Suriname)","url":"https://btw.sr/wet-belasting-over-de-toegevoegde-waarde/","consulted_on":"2026-10-20","kind":"law"},{"key":"sr-sb-2022-148","title":"Wet van 30 december 2022 tot nadere wijziging van de Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 148) — de bijlagen 1 tot en met 4 en de tarieven van 0, 5 en 25 procent, in werking per 1 januari 2023","publisher":"Belastingdienst Suriname (Staatsblad van de Republiek Suriname)","url":"https://belastingdienst.sr/wp-content/uploads/2023/01/S.B.-2022-no.-148-WET-van-30-december-2022-houdende-nadere-wijziging-van-de-Wet-Belasting-over-de-Toegevoegde-Waarde-2022.pdf","consulted_on":"2026-10-20","kind":"law"},{"key":"sr-dna-wet","title":"Wet Belasting over de Toegevoegde Waarde 2022 — de wet in de wetgeving van De Nationale Assemblée","publisher":"De Nationale Assemblée van de Republiek Suriname","url":"https://www.dna.sr/wetgeving/surinaamse-wetten/wetten-na-2005/wet-belasting-over-de-toegevoegde-waarde-2022/","consulted_on":"2026-10-20","kind":"law"},{"key":"sr-model-aangifte","title":"Beschikking model aangifte BTW (S.B. 2023 no. 31) — het model van de maandelijkse aangifte, de rubrieken 1a tot en met 4j en de toelichting bij het invullen","publisher":"Ministerie van Financiën en Planning, Staatsblad van de Republiek Suriname","url":"https://www.sris.sr/wp-content/uploads/2023/03/Beschikking-model-aangifte-BTW-S.B.-2023-no.-31.pdf","consulted_on":"2026-10-20","kind":"form"},{"key":"sr-btw-aangifte","title":"BTW-aangifte — hoe de maandelijkse aangifte online wordt ingediend: hele bedragen, naar beneden afgerond, een nulaangifte, tijdig vóór de 16de dag van de volgende maand, correctie tot en met de 15de","publisher":"Belastingdienst Suriname","url":"https://belastingdienst.sr/btw-aangifte/","consulted_on":"2026-10-20","kind":"guidance"},{"key":"sr-btw-brochure","title":"Brochure met een beschrijving van de BTW-wetgeving op hoofdlijnen (versie van 28 april 2025) — registratie, drempel van SRD 1.000.000, facturen, kassaregistratie, bewaarplicht","publisher":"Belastingdienst Suriname","url":"https://belastingdienst.sr/wp-content/uploads/2025/06/Brochure-met-een-beschrijving-van-de-BTW-wetgeving-op-hoofdlijnen-2025.pdf","consulted_on":"2026-10-20","kind":"guidance"},{"key":"sr-portaal","title":"Online Portaal van de Belastingdienst — waar de BTW-aangifte wordt ingediend","publisher":"Belastingdienst Suriname","url":"https://portaal.belastingdienst.sr/OPO","consulted_on":"2026-10-20","kind":"portal"},{"key":"sr-ifrs-profile","title":"IFRS Foundation — jurisdiction profile Suriname (16 juni 2016): geen wettelijk voorgeschreven stelsel van verslaggevingsstandaarden","publisher":"IFRS Foundation","url":"https://www.ifrs.org/content/dam/ifrs/publications/jurisdictions/pdf-profiles/suriname-ifrs-profile.pdf","consulted_on":"2026-10-20","kind":"guidance"},{"key":"iasb-ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation / International Accounting Standards Board","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes/","consulted_on":"2026-10-20","kind":"standard"}]'::jsonb)
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
  ('SR', 'default', 'Surinaams referentierekeningschema', '{"en":"Surinamese reference chart of accounts"}'::jsonb, true, 'companies', array['SR-IFRS-SME-IS', 'SR-IFRS-SME-SFP']::text[], null, 'Dit pakket vond geen wettelijk rekeningschema voor Suriname en las geen bepaling van het Wetboek van Koophandel of van de inkomstenbelasting: er wordt er geen aangehaald. Wat de Wet BTW vraagt van de ondernemer is een administratie in de Nederlandse taal die zijn leveringen, facturen, ontvangsten en uitgaven, invoer en aftrek van belasting overzichtelijk laat zien (artikel 26 en 30), bewaard gedurende tien jaar (artikel 30). Het schema is eigen aan dit pakket: vier cijfers, in blokken zodat elk bereik één regel van de balans of van de winst-en-verliesrekening bereikt. De afrekening van de aangifte (2100, terug te ontvangen 1172) staat los van de rekeningen waarop de belasting boekt (2101 tot en met 2103 verschuldigd, 1170, 1171 en 1173 voorbelasting). Zie README.md', 'sr-wet-btw')
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
  ('SR', 'default', '1000', 'Kas', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 10),
  ('SR', 'default', '1010', 'Bank — rekening-courant', '{"en":"Bank current account"}'::jsonb, 'asset_cash', false, null, 20),
  ('SR', 'default', '1020', 'Bank — spaarrekening', '{"en":"Bank savings account"}'::jsonb, 'asset_cash', false, null, 30),
  ('SR', 'default', '1030', 'Bankrekening in vreemde valuta', '{"en":"Foreign currency bank account"}'::jsonb, 'asset_cash', false, null, 40),
  ('SR', 'default', '1040', 'Afwikkelrekening betalingsplatform en kaarten', '{"en":"Payment gateway and card clearing account"}'::jsonb, 'asset_cash', false, null, 50),
  ('SR', 'default', '1050', 'Termijndeposito''s tot drie maanden', '{"en":"Fixed deposits of three months or less"}'::jsonb, 'asset_cash', false, null, 60),
  ('SR', 'default', '1060', 'Geld onderweg', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 70),
  ('SR', 'default', '1100', 'Debiteuren', '{"en":"Trade debtors"}'::jsonb, 'asset_receivable', true, null, 80),
  ('SR', 'default', '1105', 'Voorziening voor verwachte kredietverliezen', '{"en":"Allowance for expected credit losses"}'::jsonb, 'asset_current', false, null, 90),
  ('SR', 'default', '1110', 'Vorderingen op groepsmaatschappijen', '{"en":"Amounts due from related companies"}'::jsonb, 'asset_current', false, null, 100),
  ('SR', 'default', '1120', 'Overige vorderingen', '{"en":"Other debtors"}'::jsonb, 'asset_current', false, null, 110),
  ('SR', 'default', '1130', 'Nog te ontvangen opbrengsten', '{"en":"Accrued income"}'::jsonb, 'asset_current', false, null, 120),
  ('SR', 'default', '1140', 'Voorschotten en leningen aan personeel', '{"en":"Staff advances and loans to employees"}'::jsonb, 'asset_current', false, null, 130),
  ('SR', 'default', '1150', 'Betaalde deposito''s invoerrechten', '{"en":"Customs duty deposits paid"}'::jsonb, 'asset_current', false, null, 140),
  ('SR', 'default', '1160', 'Te vorderen inkomstenbelasting', '{"en":"Income tax recoverable"}'::jsonb, 'asset_current', false, null, 150),
  ('SR', 'default', '1170', 'BTW voorbelasting — binnenlandse inkopen', '{"en":"VAT recoverable — local purchases"}'::jsonb, 'asset_current', false, null, 160),
  ('SR', 'default', '1171', 'BTW voorbelasting — betaald bij invoer', '{"en":"VAT recoverable — paid on imports"}'::jsonb, 'asset_current', false, null, 170),
  ('SR', 'default', '1172', 'BTW terug te ontvangen — afrekening van de aangifte', '{"en":"VAT refundable — settlement of the return"}'::jsonb, 'asset_current', true, null, 180),
  ('SR', 'default', '1173', 'BTW voorbelasting — verlegd (diensten uit het buitenland)', '{"en":"VAT recoverable — reverse-charged services from abroad"}'::jsonb, 'asset_current', false, null, 190),
  ('SR', 'default', '1200', 'Voorraad grond- en hulpstoffen', '{"en":"Inventory — raw materials and consumables"}'::jsonb, 'asset_current', false, null, 200),
  ('SR', 'default', '1210', 'Voorraad onderhanden werk', '{"en":"Inventory — work in progress"}'::jsonb, 'asset_current', false, null, 210),
  ('SR', 'default', '1220', 'Voorraad gereed product en handelsgoederen', '{"en":"Inventory — finished goods and goods for resale"}'::jsonb, 'asset_current', false, null, 220),
  ('SR', 'default', '1230', 'Goederen onderweg', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 230),
  ('SR', 'default', '1300', 'Termijndeposito''s langer dan drie maanden', '{"en":"Fixed deposits of more than three months"}'::jsonb, 'asset_current', false, null, 240),
  ('SR', 'default', '1310', 'Beleggingen voor handelsdoeleinden', '{"en":"Investments held for trading"}'::jsonb, 'asset_current', false, null, 250),
  ('SR', 'default', '1320', 'Vorderingen op groepsmaatschappijen — niet-handel', '{"en":"Amounts due from related companies — non-trade"}'::jsonb, 'asset_current', false, null, 260),
  ('SR', 'default', '1400', 'Vooruitbetaalde kosten', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 270),
  ('SR', 'default', '1410', 'Betaalde waarborgsommen huur en nutsvoorzieningen', '{"en":"Rental and utility deposits paid"}'::jsonb, 'asset_prepayments', false, null, 280),
  ('SR', 'default', '1420', 'Vooruitbetalingen aan leveranciers', '{"en":"Deposits paid to suppliers"}'::jsonb, 'asset_prepayments', false, null, 290),
  ('SR', 'default', '1600', 'Gebouwen en terreinen', '{"en":"Land and buildings"}'::jsonb, 'asset_fixed', false, null, 300),
  ('SR', 'default', '1610', 'Verbouwingen', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 310),
  ('SR', 'default', '1620', 'Meubilair en inrichting', '{"en":"Furniture and fixtures"}'::jsonb, 'asset_fixed', false, null, 320),
  ('SR', 'default', '1630', 'Kantoorapparatuur', '{"en":"Office equipment"}'::jsonb, 'asset_fixed', false, null, 330),
  ('SR', 'default', '1640', 'Computerapparatuur en software', '{"en":"Computer equipment and software"}'::jsonb, 'asset_fixed', false, null, 340),
  ('SR', 'default', '1650', 'Vervoermiddelen', '{"en":"Motor vehicles"}'::jsonb, 'asset_fixed', false, null, 350),
  ('SR', 'default', '1660', 'Machines en installaties', '{"en":"Plant and machinery"}'::jsonb, 'asset_fixed', false, null, 360),
  ('SR', 'default', '1670', 'Gebruiksrechten (leases)', '{"en":"Right-of-use assets"}'::jsonb, 'asset_fixed', false, null, 370),
  ('SR', 'default', '1690', 'Cumulatieve afschrijvingen — materiële vaste activa', '{"en":"Accumulated depreciation — property, plant and equipment"}'::jsonb, 'asset_fixed', false, null, 380),
  ('SR', 'default', '1695', 'Cumulatieve afschrijvingen — gebruiksrechten', '{"en":"Accumulated depreciation — right-of-use assets"}'::jsonb, 'asset_fixed', false, null, 390),
  ('SR', 'default', '1800', 'Goodwill', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 400),
  ('SR', 'default', '1810', 'Overige immateriële vaste activa', '{"en":"Other intangible assets"}'::jsonb, 'asset_non_current', false, null, 410),
  ('SR', 'default', '1820', 'Cumulatieve afschrijvingen — immateriële vaste activa', '{"en":"Accumulated amortisation — intangible assets"}'::jsonb, 'asset_non_current', false, null, 420),
  ('SR', 'default', '1900', 'Deelnemingen in dochtermaatschappijen', '{"en":"Investments in subsidiaries"}'::jsonb, 'asset_non_current', false, null, 430),
  ('SR', 'default', '1910', 'Deelnemingen in geassocieerde maatschappijen', '{"en":"Investments in associates"}'::jsonb, 'asset_non_current', false, null, 440),
  ('SR', 'default', '1920', 'Overige langlopende beleggingen', '{"en":"Other long-term investments"}'::jsonb, 'asset_non_current', false, null, 450),
  ('SR', 'default', '1930', 'Waarborgsommen — langlopend', '{"en":"Deposits — non-current"}'::jsonb, 'asset_non_current', false, null, 460),
  ('SR', 'default', '1990', 'Latente belastingvorderingen', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 470),
  ('SR', 'default', '2000', 'Crediteuren', '{"en":"Trade creditors"}'::jsonb, 'liability_payable', true, null, 480),
  ('SR', 'default', '2010', 'Schulden aan groepsmaatschappijen', '{"en":"Amounts due to related companies"}'::jsonb, 'liability_current', false, null, 490),
  ('SR', 'default', '2020', 'Overlopende passiva', '{"en":"Accruals"}'::jsonb, 'liability_current', false, null, 500),
  ('SR', 'default', '2030', 'Ontvangen vooruitbetalingen van klanten', '{"en":"Customer deposits and advances received"}'::jsonb, 'liability_current', false, null, 510),
  ('SR', 'default', '2040', 'Te betalen lonen en salarissen', '{"en":"Salaries and wages payable"}'::jsonb, 'liability_current', false, null, 520),
  ('SR', 'default', '2050', 'Te betalen pensioen- en sociale premies', '{"en":"Pension and social contributions payable"}'::jsonb, 'liability_current', false, null, 530),
  ('SR', 'default', '2060', 'Te betalen inkomstenbelasting', '{"en":"Income tax payable"}'::jsonb, 'liability_current', false, null, 540),
  ('SR', 'default', '2070', 'Te betalen loonbelasting en inhoudingen', '{"en":"Wage tax and payroll deductions payable"}'::jsonb, 'liability_current', false, null, 550),
  ('SR', 'default', '2071', 'Te betalen invoerrechten', '{"en":"Customs duty payable"}'::jsonb, 'liability_current', false, null, 560),
  ('SR', 'default', '2072', 'Te betalen overige belastingen', '{"en":"Other taxes payable"}'::jsonb, 'liability_current', false, null, 570),
  ('SR', 'default', '2073', 'Te betalen overige overheidsheffingen', '{"en":"Other government charges payable"}'::jsonb, 'liability_current', false, null, 580),
  ('SR', 'default', '2080', 'Leaseverplichtingen — kortlopend deel', '{"en":"Lease liabilities — current portion"}'::jsonb, 'liability_current', false, null, 590),
  ('SR', 'default', '2090', 'Wachtrekening', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 600),
  ('SR', 'default', '2100', 'BTW af te dragen — afrekening van de aangifte', '{"en":"VAT payable — settlement of the return"}'::jsonb, 'liability_current', true, null, 610),
  ('SR', 'default', '2101', 'BTW verschuldigd — algemeen tarief (10 %)', '{"en":"VAT due — standard rate (10 %)"}'::jsonb, 'liability_current', false, null, 620),
  ('SR', 'default', '2102', 'BTW verschuldigd — overige tarieven (5 % en 25 %)', '{"en":"VAT due — other rates (5 % and 25 %)"}'::jsonb, 'liability_current', false, null, 630),
  ('SR', 'default', '2103', 'BTW verschuldigd — verlegd (diensten uit het buitenland)', '{"en":"VAT due — reverse-charged services from abroad"}'::jsonb, 'liability_current', false, null, 640),
  ('SR', 'default', '2200', 'Creditcard van de onderneming', '{"en":"Corporate credit card payable"}'::jsonb, 'liability_credit_card', false, null, 650),
  ('SR', 'default', '2300', 'Bankleningen — langlopend', '{"en":"Bank borrowings — non-current"}'::jsonb, 'liability_non_current', false, null, 660),
  ('SR', 'default', '2310', 'Leaseverplichtingen — langlopend', '{"en":"Lease liabilities — non-current"}'::jsonb, 'liability_non_current', false, null, 670),
  ('SR', 'default', '2320', 'Schulden aan aandeelhouders — langlopend', '{"en":"Amounts due to shareholders — non-current"}'::jsonb, 'liability_non_current', false, null, 680),
  ('SR', 'default', '2390', 'Latente belastingverplichtingen', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 690),
  ('SR', 'default', '3000', 'Geplaatst en gestort kapitaal', '{"en":"Issued and paid-up share capital"}'::jsonb, 'equity', false, null, 700),
  ('SR', 'default', '3100', 'Agio', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 710),
  ('SR', 'default', '3110', 'Overige reserves', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 720),
  ('SR', 'default', '3200', 'Overgedragen winst', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 730),
  ('SR', 'default', '4000', 'Verkoop van goederen', '{"en":"Sale of goods"}'::jsonb, 'income', false, null, 740),
  ('SR', 'default', '4010', 'Verrichte diensten', '{"en":"Rendering of services"}'::jsonb, 'income', false, null, 750),
  ('SR', 'default', '4700', 'Gerealiseerde koerswinsten', '{"en":"Realised exchange gains"}'::jsonb, 'income_other', false, null, 760),
  ('SR', 'default', '4710', 'Niet-gerealiseerde koerswinsten', '{"en":"Unrealised exchange gains"}'::jsonb, 'income_other', false, null, 770),
  ('SR', 'default', '4720', 'Rentebaten', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 780),
  ('SR', 'default', '4730', 'Overige opbrengsten', '{"en":"Sundry income"}'::jsonb, 'income_other', false, null, 790),
  ('SR', 'default', '4750', 'Winst bij afstoting van vaste activa', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 800),
  ('SR', 'default', '5000', 'Kostprijs van de omzet', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 810),
  ('SR', 'default', '5010', 'Inkopen', '{"en":"Purchases"}'::jsonb, 'expense_direct_cost', false, null, 820),
  ('SR', 'default', '5020', 'Vrachtkosten inkopen', '{"en":"Freight inwards"}'::jsonb, 'expense_direct_cost', false, null, 830),
  ('SR', 'default', '5025', 'Invoerrechten', '{"en":"Customs duty on imports"}'::jsonb, 'expense_direct_cost', false, null, 840),
  ('SR', 'default', '5030', 'Directe arbeid', '{"en":"Direct labour"}'::jsonb, 'expense_direct_cost', false, null, 850),
  ('SR', 'default', '6000', 'Bezoldiging van bestuurders', '{"en":"Directors'' remuneration"}'::jsonb, 'expense', false, null, 860),
  ('SR', 'default', '6010', 'Lonen en salarissen', '{"en":"Staff salaries and wages"}'::jsonb, 'expense', false, null, 870),
  ('SR', 'default', '6020', 'Pensioenpremies', '{"en":"Pension contributions"}'::jsonb, 'expense', false, null, 880),
  ('SR', 'default', '6025', 'Sociale lasten werkgever', '{"en":"Employer payroll contributions"}'::jsonb, 'expense', false, null, 890),
  ('SR', 'default', '6030', 'Overige personeelskosten', '{"en":"Staff welfare and benefits"}'::jsonb, 'expense', false, null, 900),
  ('SR', 'default', '6100', 'Huisvestingskosten', '{"en":"Rent and premises"}'::jsonb, 'expense', false, null, 910),
  ('SR', 'default', '6110', 'Beheer- en gebouwkosten', '{"en":"Management fees and building outgoings"}'::jsonb, 'expense', false, null, 920),
  ('SR', 'default', '6120', 'Water, elektriciteit en gas', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 930),
  ('SR', 'default', '6130', 'Overige belastingen en heffingen', '{"en":"Other taxes and levies"}'::jsonb, 'expense', false, null, 940),
  ('SR', 'default', '6200', 'Vergunningen, rechten en registratiekosten', '{"en":"Government fees, licences and registry fees"}'::jsonb, 'expense', false, null, 950),
  ('SR', 'default', '6210', 'Accountantskosten — controle', '{"en":"Auditor''s remuneration"}'::jsonb, 'expense', false, null, 960),
  ('SR', 'default', '6220', 'Kosten boekhouding en administratie', '{"en":"Accounting and bookkeeping fees"}'::jsonb, 'expense', false, null, 970),
  ('SR', 'default', '6230', 'Juridische en overige advieskosten', '{"en":"Legal and professional fees"}'::jsonb, 'expense', false, null, 980),
  ('SR', 'default', '6300', 'Onderhoud en reparaties', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 990),
  ('SR', 'default', '6310', 'Verzekeringen', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 1000),
  ('SR', 'default', '6320', 'Autokosten', '{"en":"Motor vehicle expenses"}'::jsonb, 'expense', false, null, 1010),
  ('SR', 'default', '6330', 'Reis- en verblijfkosten', '{"en":"Travelling expenses"}'::jsonb, 'expense', false, null, 1020),
  ('SR', 'default', '6340', 'Representatiekosten', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 1030),
  ('SR', 'default', '6350', 'Reclame en promotie', '{"en":"Advertising and promotion"}'::jsonb, 'expense', false, null, 1040),
  ('SR', 'default', '6360', 'Drukwerk, kantoorbehoeften en porti', '{"en":"Printing, stationery and postage"}'::jsonb, 'expense', false, null, 1050),
  ('SR', 'default', '6370', 'Telecommunicatie', '{"en":"Telecommunications"}'::jsonb, 'expense', false, null, 1060),
  ('SR', 'default', '6380', 'Bankkosten', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 1070),
  ('SR', 'default', '6390', 'Overige kantoorkosten', '{"en":"Sundry office expenses"}'::jsonb, 'expense', false, null, 1080),
  ('SR', 'default', '6400', 'Dotatie voorziening kredietverliezen', '{"en":"Allowance for expected credit losses charged"}'::jsonb, 'expense', false, null, 1090),
  ('SR', 'default', '6410', 'Rentelasten bankleningen', '{"en":"Interest expense on bank borrowings"}'::jsonb, 'expense', false, null, 1100),
  ('SR', 'default', '6420', 'Rentelasten leaseverplichtingen', '{"en":"Interest expense on lease liabilities"}'::jsonb, 'expense', false, null, 1110),
  ('SR', 'default', '6450', 'Gerealiseerde koersverliezen', '{"en":"Realised exchange losses"}'::jsonb, 'expense', false, null, 1120),
  ('SR', 'default', '6455', 'Niet-gerealiseerde koersverliezen', '{"en":"Unrealised exchange losses"}'::jsonb, 'expense', false, null, 1130),
  ('SR', 'default', '6460', 'Verlies bij afstoting van vaste activa', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1140),
  ('SR', 'default', '6470', 'Last inkomstenbelasting', '{"en":"Income tax charge"}'::jsonb, 'expense', false, null, 1150),
  ('SR', 'default', '6480', 'Last latente belasting', '{"en":"Deferred tax charge"}'::jsonb, 'expense', false, null, 1160),
  ('SR', 'default', '6490', 'Afrondingsverschillen', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1170),
  ('SR', 'default', '6800', 'Afschrijvingen', '{"en":"Depreciation and amortisation"}'::jsonb, 'expense_depreciation', false, null, 1180)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SR', 'BNK', 'Bank', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('SR', 'CSH', 'Kas', '{"en":"Petty cash"}'::jsonb, 'cash', 40),
  ('SR', 'GEN', 'Memoriaal', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('SR', 'OPN', 'Openingsbalans', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('SR', 'PUR', 'Inkoopboek', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('SR', 'SAL', 'Verkoopboek', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('SR', 'SR-P-05', 'Inkoop 5 % — aftrekbaar', '{"en":"Purchase 5 % — deductible"}'::jsonb, 'Een binnenlandse inkoop tegen het verlaagde tarief (brandstof), voor belaste handelingen', 'percent', 5, 'purchase', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 3, artikel 14 en artikel 4, lid 3 — aftrek van de belasting tegen 5 procent in rubriek 4b', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-10', 'Inkoop 10 % — aftrekbaar', '{"en":"Purchase 10 % — deductible"}'::jsonb, 'Een binnenlandse inkoop tegen het algemene tarief, voor belaste handelingen', 'percent', 10, 'purchase', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 3 en artikel 14 — de aan de ondernemer in rekening gebrachte belasting wordt afgetrokken voor zover de goederen en diensten dienen voor belaste handelingen, op vertoon van een correcte factuur. De belasting in rubriek 4b; de aangifte kent geen rubriek voor de inkoop zelf', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-10-ND', 'Inkoop 10 % — niet aftrekbaar', '{"en":"Purchase 10 % — not deductible"}'::jsonb, 'Spijzen, dranken en tabak, relatiegeschenken, loon in natura, personenauto''s: de belasting is kosten', 'percent', 10, 'purchase', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 14 — geen aftrek van de belasting die in rekening is gebracht ter zake van het verstrekken van spijzen, dranken en tabaksproducten, van relatiegeschenken en andere giften, van loon in natura en gelegenheid tot ontspanning, en van motorvoertuigen bestemd voor personenvervoer (met de uitzonderingen van de tekst). De belasting valt op de kosten van de regel; geen rubriek', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-25', 'Inkoop 25 % — aftrekbaar', '{"en":"Purchase 25 % — deductible"}'::jsonb, 'Een binnenlandse inkoop tegen het verhoogde tarief, voor belaste handelingen', 'percent', 25, 'purchase', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 3, artikel 14 en artikel 4, lid 4 — aftrek van de belasting tegen 25 procent in rubriek 4b, behalve voor motorvoertuigen voor personenvervoer, die artikel 14 van aftrek uitsluit (gebruik SR-P-25-ND)', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-25-ND', 'Inkoop 25 % — niet aftrekbaar', '{"en":"Purchase 25 % — not deductible"}'::jsonb, 'Een personenauto of andere niet aftrekbare inkoop tegen het verhoogde tarief: de belasting is kosten', 'percent', 25, 'purchase', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 14 — geen aftrek voor motorvoertuigen bestemd voor personenvervoer en de goederen en diensten die daarmee verband houden (uitgezonderd autodealers, autoleasebedrijven en voertuigen boven 3.500 kg). De belasting valt op de kosten van de regel; geen rubriek', null, null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-EX', 'Inkoop zonder BTW', '{"en":"Purchase without VAT"}'::jsonb, 'Een inkoop van een vrijgestelde levering of dienst, of van een leverancier die geen BTW in rekening brengt: geen voorbelasting', 'percent', 0, 'purchase', 'exempt', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 5 — op een vrijgestelde handeling of een handeling van een ondernemer onder de drempel van artikel 21 wordt geen belasting in rekening gebracht, dus is er niets af te trekken. Geen rubriek', null, null, 180, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-IMP-05', 'Invoer van goederen 5 %', '{"en":"Import of goods 5 %"}'::jsonb, 'BTW betaald bij de Douane op ingevoerde goederen, 5 procent', 'percent', 5, 'purchase', 'import', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 2, onderdeel c (heffing bij invoer), artikel 3 en artikel 14 — de bij invoer betaalde belasting is aftrekbaar voor zover de goederen dienen voor belaste handelingen; rubriek 4d van de aangifte. Een invoerder met een vergunning voor verlegging bij invoer (artikel 11, lid 3, rubrieken 3a tot en met 3c) gebruikt dit pakket niet voor die belasting', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-IMP-10', 'Invoer van goederen 10 %', '{"en":"Import of goods 10 %"}'::jsonb, 'BTW betaald bij de Douane op ingevoerde goederen, 10 procent', 'percent', 10, 'purchase', 'import', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 2, onderdeel c (heffing bij invoer), artikel 3 en artikel 14 — de bij invoer betaalde belasting is aftrekbaar voor zover de goederen dienen voor belaste handelingen; rubriek 4d van de aangifte. Een invoerder met een vergunning voor verlegging bij invoer (artikel 11, lid 3, rubrieken 3a tot en met 3c) gebruikt dit pakket niet voor die belasting', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-IMP-25', 'Invoer van goederen 25 %', '{"en":"Import of goods 25 %"}'::jsonb, 'BTW betaald bij de Douane op ingevoerde goederen, 25 procent', 'percent', 25, 'purchase', 'import', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 2, onderdeel c (heffing bij invoer), artikel 3 en artikel 14 — de bij invoer betaalde belasting is aftrekbaar voor zover de goederen dienen voor belaste handelingen; rubriek 4d van de aangifte. Een invoerder met een vergunning voor verlegging bij invoer (artikel 11, lid 3, rubrieken 3a tot en met 3c) gebruikt dit pakket niet voor die belasting', null, null, 160, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-P-RC-10', 'Diensten van een ondernemer buiten Suriname 10 % — verlegd', '{"en":"Services from a supplier outside Suriname 10 % — reverse-charged"}'::jsonb, 'De afnemer geeft de belasting aan en trekt haar af, zodat de boeking nul is', 'percent', 10, 'purchase', 'foreign_services_received', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 11, lid 2 — is de ondernemer niet in Suriname gevestigd en is de afnemer een ondernemer in Suriname, dan wordt de belasting geheven van de afnemer, die haar volgens het regime van verlegging in zijn aangifte voldoet (rubriek 3d, 10 procent) en in aftrek brengt voor zover hij belaste handelingen verricht (rubriek 4c, artikel 14)', null, null, 170, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-S-00', 'Verkoop 0 % — bijlage 1', '{"en":"Sale 0 % — Annex 1"}'::jsonb, 'Een binnenlandse levering of dienst van bijlage 1 (water, elektriciteit, vervoer, geneesmiddelen, onderwijs, basisvoedsel en meer), belast tegen 0 procent', 'percent', 0, 'sale', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 2, onderdeel a, en bijlage 1 (S.B. 2022 no. 148, artikel I onder A en L) — het nultarief. Een goed of dienst tegen 0 procent is belast: de voorbelasting van wat haar voortbrengt blijft aftrekbaar. Omzet in rubriek 1b, waarbij de aangifte een specificatie vraagt die bij de aangifte wordt ingediend', 'Z', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-sb-2022-148', null, null, null, null),
  ('SR', 'SR-S-05', 'Verkoop 5 % — verlaagd tarief', '{"en":"Sale 5 % — reduced rate"}'::jsonb, 'Motorbrandstoffen en dieselolie, verzekering voor internationale ziektekosten', 'percent', 5, 'sale', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 3, en bijlage 4 (S.B. 2022 no. 148, artikel I onder C en O) — 5 procent op de levering en invoer van motorgasoline en daarmee gelijkgestelde motorbrandstoffen, dieselolie, en op de verzekering voor internationale ziektekosten. Omzet en belasting in rubriek 1c', 'S', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-sb-2022-148', null, null, null, null),
  ('SR', 'SR-S-10', 'Verkoop 10 % — algemeen tarief', '{"en":"Sale 10 % — standard rate"}'::jsonb, 'Een belaste levering of dienst in Suriname door een BTW-ondernemer, tegen het algemene tarief', 'percent', 10, 'sale', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 1 — «Het tarief van de belasting bedraagt 10 (tien) procent», in werking per 1 januari 2023 (artikel II, lid 2, van S.B. 2022 no. 148). Omzet in rubriek 1a van de aangifte, de belasting in rubriek 1a', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-S-10-INC', 'Kleinhandelsverkoop 10 % — prijs inclusief BTW', '{"en":"Retail sale 10 % — price includes the tax"}'::jsonb, 'Een levering tegen het algemene tarief waarvan de prijs de BTW al bevat', 'percent', 10, 'sale', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 1 (10 procent) en artikel 10 — aan anderen dan ondernemers mogen goederen en diensten niet worden aangeboden tegen prijzen waarin de belasting niet is begrepen (de overtreding is strafbaar gesteld in artikel 58). De BTW wordt uit de prijs gehaald: 110,00 bevat 100,00 en 10,00. Zelfde rubrieken als SR-S-10', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-S-25', 'Verkoop 25 % — verhoogd tarief', '{"en":"Sale 25 % — higher rate"}'::jsonb, 'Personenauto''s boven 2.500 cm³ of met een cif-waarde van US$ 40.000 of meer, motorfietsen boven 125 cm³', 'percent', 25, 'sale', 'domestic', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 4, en bijlage 3 (S.B. 2022 no. 148, artikel I onder D en N) — 25 procent op de levering en invoer van automobielen en andere motorvoertuigen voor personenvervoer met een cilinderinhoud van meer dan 2.500 cm³ of een cif-waarde van US$ 40.000 of meer, en van motorfietsen boven 125 cm³. Omzet en belasting in rubriek 1d. Het pakket beslist niet welke goederen onder bijlage 3 vallen', 'S', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-sb-2022-148', null, null, null, null),
  ('SR', 'SR-S-EX', 'Vrijgestelde verkoop — bijlage 2', '{"en":"Exempt sale — Annex 2"}'::jsonb, 'Een levering of dienst van bijlage 2: onroerende goederen, medische beroepen, toegang tot vermakelijkheden, kansspelen, non-profitorganisaties', 'percent', 0, 'sale', 'exempt', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 5, lid 1, en bijlage 2 (S.B. 2022 no. 148, artikel I onder M) — vrijgesteld van belasting. Een vrijgestelde handeling geeft geen recht op aftrek van de voorbelasting en komt in geen rubriek van de aangifte; op de factuur wordt de vrijstelling vermeld (brochure Belastingdienst)', 'E', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-sb-2022-148', null, null, null, null),
  ('SR', 'SR-S-EXP-D', 'Diensten aan afnemers buiten Suriname 0 %', '{"en":"Services to customers outside Suriname 0 %"}'::jsonb, 'Internationaal goederenvervoer, diensten ter zake van uitgaande goederen, outsourcing voor een niet in Suriname gevestigde afnemer', 'percent', 0, 'sale', 'export', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 2, onderdelen c, d en e — nultarief voor internationaal goederenvervoer per luchtvaartuig of zeeschip, voor diensten in Suriname ter zake van uitgaande goederen en voor outsourcingswerkzaamheden ten behoeve van een niet in Suriname woonachtige of gevestigde afnemer. Omzet in rubriek 2b (''diensten aan buitenlandse afnemers''). Een dienst waarvan de plaats volgens artikel 9 buiten Suriname ligt, valt niet onder dit pakket te bewijzen: de gebruiker kiest met zijn accountant', 'G', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-wet-btw', null, null, null, null),
  ('SR', 'SR-S-EXP-G', 'Uitvoer van goederen 0 %', '{"en":"Export of goods 0 %"}'::jsonb, 'Levering van goederen die worden uitgevoerd', 'percent', 0, 'sale', 'export', date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 4, lid 2, onderdeel b (S.B. 2022 no. 148, artikel I onder B) — nultarief voor de levering van goederen die worden uitgevoerd; alleen de ondernemer die uitvoert past het toe, de leveringen eerder in de keten zijn gewoon belast (memorie van toelichting). Omzet in rubriek 2a. De factuur is ook bij uitvoer verplicht (brochure Belastingdienst)', 'G', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sr-sb-2022-148', null, null, null, null)
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
    ('SR-P-05', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-05', 'invoice', 'tax', 100, '1170', '4b', array['4b']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-05', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-05', 'credit_note', 'tax', 100, '1170', '4b', array['4b']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-10', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-10', 'invoice', 'tax', 100, '1170', '4b', array['4b']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-10', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-10', 'credit_note', 'tax', 100, '1170', '4b', array['4b']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-10-ND', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-10-ND', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SR-P-10-ND', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-10-ND', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SR-P-25', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-25', 'invoice', 'tax', 100, '1170', '4b', array['4b']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-25', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-25', 'credit_note', 'tax', 100, '1170', '4b', array['4b']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-25-ND', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-25-ND', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SR-P-25-ND', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-25-ND', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('SR-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-05', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-05', 'invoice', 'tax', 100, '1171', '4d', array['4d']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-IMP-05', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-05', 'credit_note', 'tax', 100, '1171', '4d', array['4d']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-IMP-10', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-10', 'invoice', 'tax', 100, '1171', '4d', array['4d']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-IMP-10', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-10', 'credit_note', 'tax', 100, '1171', '4d', array['4d']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-IMP-25', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-25', 'invoice', 'tax', 100, '1171', '4d', array['4d']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-IMP-25', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-P-IMP-25', 'credit_note', 'tax', 100, '1171', '4d', array['4d']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-RC-10', 'invoice', 'base', 100, null, '3d', array['3d']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-P-RC-10', 'invoice', 'tax', 100, '1173', '4c', array['4c']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-RC-10', 'invoice', 'tax', -100, '2103', '3d', array['3d']::text[], 100, 'SR-BTW-AANGIFTE', 30),
    ('SR-P-RC-10', 'credit_note', 'base', 100, null, '3d', array['3d']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-P-RC-10', 'credit_note', 'tax', 100, '1173', '4c', array['4c']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-P-RC-10', 'credit_note', 'tax', -100, '2103', '3d', array['3d']::text[], -100, 'SR-BTW-AANGIFTE', 30),
    ('SR-S-00', 'invoice', 'base', 100, null, '1b', array['1b']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-00', 'credit_note', 'base', 100, null, '1b', array['1b']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-05', 'invoice', 'base', 100, null, '1c', array['1c']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-05', 'invoice', 'tax', 100, '2102', '1c', array['1c']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-05', 'credit_note', 'base', 100, null, '1c', array['1c']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-05', 'credit_note', 'tax', 100, '2102', '1c', array['1c']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-10', 'invoice', 'base', 100, null, '1a', array['1a']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-10', 'invoice', 'tax', 100, '2101', '1a', array['1a']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-10', 'credit_note', 'base', 100, null, '1a', array['1a']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-10', 'credit_note', 'tax', 100, '2101', '1a', array['1a']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-10-INC', 'invoice', 'base', 100, null, '1a', array['1a']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-10-INC', 'invoice', 'tax', 100, '2101', '1a', array['1a']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-10-INC', 'credit_note', 'base', 100, null, '1a', array['1a']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-10-INC', 'credit_note', 'tax', 100, '2101', '1a', array['1a']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-25', 'invoice', 'base', 100, null, '1d', array['1d']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-25', 'invoice', 'tax', 100, '2102', '1d', array['1d']::text[], 100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-25', 'credit_note', 'base', 100, null, '1d', array['1d']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-25', 'credit_note', 'tax', 100, '2102', '1d', array['1d']::text[], -100, 'SR-BTW-AANGIFTE', 20),
    ('SR-S-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('SR-S-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('SR-S-EXP-D', 'invoice', 'base', 100, null, '2b', array['2b']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-EXP-D', 'credit_note', 'base', 100, null, '2b', array['2b']::text[], -100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-EXP-G', 'invoice', 'base', 100, null, '2a', array['2a']::text[], 100, 'SR-BTW-AANGIFTE', 10),
    ('SR-S-EXP-G', 'credit_note', 'base', 100, null, '2a', array['2a']::text[], -100, 'SR-BTW-AANGIFTE', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SR' and t.code = v.tax_code
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
   deadline_reference, deadline_source_key, file_format,
   rounding_unit, rounding_reference, rounding_source_key)
values
  ('SR', 'SR-BTW-AANGIFTE', 'BTW-aangifte (maandelijkse aangifte)', array['month']::declaration_period[], 'month'::declaration_period, date '2023-01-01', null, 'Wet Belasting over de Toegevoegde Waarde 2022 (S.B. 2022 no. 121, verbeterblad S.B. 2022 no. 143, gewijzigd bij S.B. 2022 no. 148), artikel 1 en artikel 13 — het tijdvak van aangifte is de kalendermaand, tenzij de Minister bij beschikking een ander tijdvak vaststelt (de brochure van de Belastingdienst: BTW-plichtige ondernemers doen maandelijks aangifte, ook als er niets aan te geven is). Het model is dat van S.B. 2023 no. 31: rubrieken 1a tot en met 4j. De drempel van SRD 1.000.000 aan belaste omzet per kalenderjaar (artikel 21) bepaalt of de ondernemer zich moet registreren; het pakket controleert hem niet', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Artikel 13, leden 2 en 4, van de wet — de aangifte wordt gedaan en de belasting wordt betaald vóór de zestiende dag van de maand volgend op het tijdvak; de Belastingdienst noemt tijdig ''voor de 16de dag van de maand daaropvolgend''. De regel geeft dus de 15de als laatste dag. Een 15de op een zaterdag, zondag of feestdag verschuift volgens geen gelezen tekst en wordt niet verschoven. Op de 15de eindigt ook het corrigeren via het online portaal', 'sr-btw-aangifte', null, 1, 'Het online aangifteformulier accepteert alleen hele bedragen, zonder komma of punt: centen worden niet ingevoerd en de bedragen worden naar beneden afgerond (Belastingdienst, BTW-aangifte). Het pakket rondt op de eenheid; de richting naar beneden kan het niet uitdrukken, zie README.md', 'sr-btw-aangifte')
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
  rounding_unit       = excluded.rounding_unit,
  rounding_reference  = excluded.rounding_reference,
  rounding_source_key = excluded.rounding_source_key,
  file_format         = excluded.file_format;

insert into tax_report_box_templates
  (country, report_code, box, kind, name, name_i18n, sequence, print_sequence,
   plus_boxes, minus_boxes, rate, rate_of_box, floor_zero, hidden, xml_element,
   legal_reference, source_key)
values
  ('SR', 'SR-BTW-AANGIFTE', '1a', 'base', 'Leveringen en diensten belast met 10 % — omzet', '{"en":"Supplies taxed at 10 % — turnover"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1a — het algemene tarief van 10 procent; de omzet per tarief wordt gespecificeerd, niet opgeteld', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1a', 'tax', 'Leveringen en diensten belast met 10 % — belasting', '{"en":"Supplies taxed at 10 % — tax"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1a', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1b', 'base', 'Leveringen en diensten belast met 0 % — omzet', '{"en":"Supplies taxed at 0 % — turnover"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1b — het nultarief van bijlage 1; bij deze rubriek hoort een specificatie die bij de aangifte wordt ingediend', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1c', 'base', 'Leveringen en diensten belast met 5 % — omzet', '{"en":"Supplies taxed at 5 % — turnover"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1c — het verlaagde tarief van 5 procent', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1c', 'tax', 'Leveringen en diensten belast met 5 % — belasting', '{"en":"Supplies taxed at 5 % — tax"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1c', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1d', 'base', 'Leveringen van goederen belast met 25 % — omzet', '{"en":"Supplies of goods taxed at 25 % — turnover"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1d — het verhoogde tarief van 25 procent', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1d', 'tax', 'Leveringen van goederen belast met 25 % — belasting', '{"en":"Supplies of goods taxed at 25 % — tax"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1d', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1e', 'base', 'Privégebruik en onttrekkingen — omzet', '{"en":"Private use and withdrawals — turnover"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1e — goederen uit de onderneming gehaald of voor andere doeleinden gebruikt; geen btw-code van dit pakket boekt hierop', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '1e', 'tax', 'Privégebruik en onttrekkingen — belasting', '{"en":"Private use and withdrawals — tax"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 1e', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '2a', 'base', 'Uitvoer van goederen (0 %) — omzet', '{"en":"Export of goods (0 %) — turnover"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 2a — goederen uitgevoerd naar andere landen, ook onder het stelsel van douane-entrepot; het nultarief, dus geen bedrag belasting', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '2b', 'base', 'Diensten aan buitenlandse afnemers — omzet', '{"en":"Services to customers abroad — turnover"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 2b', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3a', 'base', 'Invoer met verlegging, 10 % — omzet', '{"en":"Imports under the reverse-charge permit, 10 % — turnover"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3a — alleen met een vergunning als bedoeld in artikel 11, lid 3; geen btw-code van dit pakket boekt hierop', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3a', 'tax', 'Invoer met verlegging, 10 % — belasting', '{"en":"Imports under the reverse-charge permit, 10 % — tax"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3a', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3b', 'base', 'Invoer met verlegging, 5 % — omzet', '{"en":"Imports under the reverse-charge permit, 5 % — turnover"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3b — zelfde vergunning, het verlaagde tarief; geen btw-code van dit pakket boekt hierop', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3b', 'tax', 'Invoer met verlegging, 5 % — belasting', '{"en":"Imports under the reverse-charge permit, 5 % — tax"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3b', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3c', 'base', 'Invoer met verlegging, 25 % — omzet', '{"en":"Imports under the reverse-charge permit, 25 % — turnover"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3c — zelfde vergunning, het verhoogde tarief; geen btw-code van dit pakket boekt hierop', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3c', 'tax', 'Invoer met verlegging, 25 % — belasting', '{"en":"Imports under the reverse-charge permit, 25 % — tax"}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3c', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3d', 'base', 'Diensten afgenomen van een ondernemer buiten Suriname — omzet', '{"en":"Services received from a supplier abroad — turnover"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3d — de ondernemer uit het buitenland heeft de BTW naar de afnemer verlegd (of had dat moeten doen); 10 procent', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '3d', 'tax', 'Diensten afgenomen van een ondernemer buiten Suriname — belasting', '{"en":"Services received from a supplier abroad — tax"}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 3d', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4a', 'total', 'Totaal verschuldigde belasting', '{"en":"Total tax due"}'::jsonb, 200, null, array['1a:tax', '1c:tax', '1d:tax', '1e:tax', '3a:tax', '3b:tax', '3c:tax', '3d:tax']::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4a — de belasting van de rubrieken 1a tot en met 3d bij elkaar opgeteld', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4b', 'tax', 'Voorbelasting binnenlandse inkopen', '{"en":"Input tax on local purchases"}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4b — de Surinaamse BTW die andere ondernemers in rekening hebben gebracht, aftrekbaar voor zover de goederen en diensten dienen voor belaste handelingen (artikel 14)', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4c', 'tax', 'Voorbelasting verlegd (rubrieken 3a tot en met 3d)', '{"en":"Input tax on reverse-charged supplies (boxes 3a to 3d)"}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4c — de verschuldigde belasting door verlegging bij invoer en door de diensten van buitenlandse ondernemers, aftrekbaar onder dezelfde voorwaarde', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4d', 'tax', 'Voorbelasting betaald bij invoer', '{"en":"Input tax paid on imports"}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4d — de BTW betaald bij de Douane wegens de invoer van goederen; niet te vermelden bij 4d wat verlegd is (rubrieken 3a tot en met 3c, dat staat in 4c)', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4e', 'tax', 'Omzetbelasting op voorraad per 31 december 2022', '{"en":"Turnover tax on stock held on 31 December 2022"}'::jsonb, 240, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4e — alleen met toekenning van het verzoek op grond van artikel 68 en voor goederen die in 2023 met BTW zijn doorverkocht; geen btw-code van dit pakket boekt hierop', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4f', 'total', 'Totaal in aftrek te brengen belasting', '{"en":"Total tax to be deducted"}'::jsonb, 250, null, array['4b:tax', '4c:tax', '4d:tax', '4e:tax']::text[], '{}'::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4f — de belasting van de rubrieken 4b tot en met 4e bij elkaar opgeteld', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4g', 'total', 'Subtotaal', '{"en":"Subtotal"}'::jsonb, 260, null, array['4a']::text[], array['4f']::text[], null, null, false, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4g — de belasting van rubriek 4f afgetrokken van die van rubriek 4a; een negatief bedrag is een teruggaaf', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4j', 'total', 'Te betalen belasting', '{"en":"Tax to be paid"}'::jsonb, 270, null, array['4g']::text[], '{}'::text[], null, null, true, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4j — het vakje ''te betalen belasting'' wanneer 4g positief is. De rubrieken 4h (correctie van de in een vorige periode te veel of te weinig afgetrokken belasting) en 4i (correctie van de te veel of te weinig betaalde belasting) zijn niet gemodelleerd', 'sr-model-aangifte'),
  ('SR', 'SR-BTW-AANGIFTE', '4jTerug', 'total', 'Terug te ontvangen belasting', '{"en":"Tax to be received back"}'::jsonb, 280, null, array['4f']::text[], array['4a']::text[], null, null, true, false, null, 'Beschikking model aangifte BTW (S.B. 2023 no. 31), bijlage, rubriek 4j — het vakje ''terug te ontvangen belasting'' wanneer 4g negatief is; de terugbetaling volgt binnen een maand na het ontstaan van het recht (artikel 17), een termijn die tot twee maanden kan worden opgeschort', 'sr-model-aangifte')
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
   source_key, result_in_progress, result_in_progress_name, result_in_progress_name_i18n)
values
  ('SR-IFRS-SME-IS', 'SR', 'default', 'Winst-en-verliesrekening', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'In Suriname is geen stelsel van verslaggevingsstandaarden wettelijk voorgeschreven (IFRS Foundation, jurisdiction profile, 2016), en de Wet BTW (artikel 30) vraagt alleen dat de administratie in de Nederlandse taal duidelijk en overzichtelijk wordt gevoerd. Deze opstelling volgt de presentatie van IFRS for SMEs (IASB), sectie 4 en 5: dat is een keuze van dit pakket en geen tekst die het land oplegt. De nummering van de regels en de bereiken die elke regel leest zijn eigen aan dit pakket. Het kasstroomoverzicht en het mutatieoverzicht van het eigen vermogen zijn aparte overzichten die dit pakket niet modelleert. De last inkomstenbelasting (6470) valt in de bedrijfskosten; de inkomstenbelasting is niet gemodelleerd', 'iasb-ifrs-sme', null, null, '{}'::jsonb),
  ('SR-IFRS-SME-SFP', 'SR', 'default', 'Balans', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'In Suriname is geen stelsel van verslaggevingsstandaarden wettelijk voorgeschreven (IFRS Foundation, jurisdiction profile, 2016), en de Wet BTW (artikel 30) vraagt alleen dat de administratie in de Nederlandse taal duidelijk en overzichtelijk wordt gevoerd. Deze opstelling volgt de presentatie van IFRS for SMEs (IASB), sectie 4 en 5: dat is een keuze van dit pakket en geen tekst die het land oplegt. De nummering van de regels en de bereiken die elke regel leest zijn eigen aan dit pakket. Het kasstroomoverzicht en het mutatieoverzicht van het eigen vermogen zijn aparte overzichten die dit pakket niet modelleert.', 'sr-ifrs-profile', 'alone', null, '{}'::jsonb)
on conflict (code) do update set
  country         = excluded.country,
  chart_code      = excluded.chart_code,
  name            = excluded.name,
  kind            = excluded.kind,
  framework       = excluded.framework,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  result_in_progress           = excluded.result_in_progress,
  result_in_progress_name      = excluded.result_in_progress_name,
  result_in_progress_name_i18n = excluded.result_in_progress_name_i18n;

insert into statement_line_templates
  (statement_code, code, parent_code, name, name_i18n, sequence, sign, is_total,
   plus_lines, minus_lines, xbrl_element, legal_reference, source_key)
values
  ('SR-IFRS-SME-IS', 'REV', null, 'Netto-omzet', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-IS', 'COST', null, 'Kostprijs van de omzet', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-IS', 'GROSS', null, 'Brutowinst', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('SR-IFRS-SME-IS', 'OTH-INC', null, 'Overige opbrengsten', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-IS', 'OPEX', null, 'Bedrijfskosten', '{"en":"Administrative and other operating expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-IS', 'DEPR', null, 'Afschrijvingen', '{"en":"Depreciation and amortisation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-IS', 'PROFIT', null, 'Winst (verlies) van het boekjaar', '{"en":"Profit (loss) for the year"}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-NC-FIX', 'A-NC', 'Materiële vaste activa', '{"en":"Property, plant and equipment"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-NC-INT', 'A-NC', 'Goodwill en overige immateriële vaste activa', '{"en":"Goodwill and other intangible assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-NC-OTH', 'A-NC', 'Overige vaste activa', '{"en":"Other non-current assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-NC', null, 'Vaste activa', '{"en":"Non-current assets"}'::jsonb, 40, 1, true, array['A-NC-FIX', 'A-NC-INT', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-C-REC', 'A-C', 'Handels- en overige vorderingen', '{"en":"Trade and other receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-C-INV', 'A-C', 'Voorraden', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-C-OTH', 'A-C', 'Overige vlottende activa', '{"en":"Other current assets"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-C-PRE', 'A-C', 'Vooruitbetaalde kosten en betaalde waarborgsommen', '{"en":"Prepayments and deposits paid"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-C-CASH', 'A-C', 'Liquide middelen', '{"en":"Cash and cash equivalents"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-C', null, 'Vlottende activa', '{"en":"Current assets"}'::jsonb, 100, 1, true, array['A-C-REC', 'A-C-INV', 'A-C-OTH', 'A-C-PRE', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'A-TOT', null, 'Totaal activa', '{"en":"Total assets"}'::jsonb, 110, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'E-CAP', 'E-TOT', 'Aandelenkapitaal en reserves', '{"en":"Share capital and reserves"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'E-RET', 'E-TOT', 'Overgedragen winst', '{"en":"Retained earnings"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'E-RESULT', 'E-TOT', 'Winst of verlies van het boekjaar, nog niet verwerkt', '{"en":"Profit or loss for the year, not yet allocated"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'E-TOT', null, 'Totaal eigen vermogen', '{"en":"Total equity"}'::jsonb, 150, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'L-NC', 'L-TOT', 'Langlopende schulden', '{"en":"Non-current liabilities"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'L-C-PAY', 'L-C', 'Handels- en overige schulden', '{"en":"Trade and other payables"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'L-C-TAX', 'L-C', 'Kortlopende belastingschulden, inclusief verschuldigde BTW', '{"en":"Current tax liabilities, including VAT due"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'L-C-OTH', 'L-C', 'Overige kortlopende schulden', '{"en":"Other current liabilities"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'L-C', null, 'Kortlopende schulden', '{"en":"Current liabilities"}'::jsonb, 200, 1, true, array['L-C-PAY', 'L-C-TAX', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'L-TOT', null, 'Totaal schulden', '{"en":"Total liabilities"}'::jsonb, 210, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('SR-IFRS-SME-SFP', 'EL-TOT', null, 'Totaal eigen vermogen en schulden', '{"en":"Total equity and liabilities"}'::jsonb, 220, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null)
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

delete from statement_line_rules r
 where r.statement_code in ('SR-IFRS-SME-IS', 'SR-IFRS-SME-SFP')
   and (r.statement_code, r.line_code, r.sequence) not in (
     values ('SR-IFRS-SME-IS', 'REV', 10),
            ('SR-IFRS-SME-IS', 'COST', 10),
            ('SR-IFRS-SME-IS', 'OTH-INC', 10),
            ('SR-IFRS-SME-IS', 'OPEX', 10),
            ('SR-IFRS-SME-IS', 'DEPR', 10),
            ('SR-IFRS-SME-SFP', 'A-NC-FIX', 10),
            ('SR-IFRS-SME-SFP', 'A-NC-INT', 10),
            ('SR-IFRS-SME-SFP', 'A-NC-OTH', 10),
            ('SR-IFRS-SME-SFP', 'A-C-REC', 10),
            ('SR-IFRS-SME-SFP', 'A-C-INV', 10),
            ('SR-IFRS-SME-SFP', 'A-C-OTH', 10),
            ('SR-IFRS-SME-SFP', 'A-C-PRE', 10),
            ('SR-IFRS-SME-SFP', 'A-C-CASH', 10),
            ('SR-IFRS-SME-SFP', 'E-CAP', 10),
            ('SR-IFRS-SME-SFP', 'E-RET', 10),
            ('SR-IFRS-SME-SFP', 'E-RESULT', 10),
            ('SR-IFRS-SME-SFP', 'E-RESULT', 20),
            ('SR-IFRS-SME-SFP', 'E-RESULT', 30),
            ('SR-IFRS-SME-SFP', 'E-RESULT', 40),
            ('SR-IFRS-SME-SFP', 'L-NC', 10),
            ('SR-IFRS-SME-SFP', 'L-C-PAY', 10),
            ('SR-IFRS-SME-SFP', 'L-C-TAX', 10),
            ('SR-IFRS-SME-SFP', 'L-C-TAX', 20),
            ('SR-IFRS-SME-SFP', 'L-C-OTH', 10),
            ('SR-IFRS-SME-SFP', 'L-C-OTH', 20)
   );

insert into statement_line_rules
  (statement_code, line_code, sequence, rule_kind, code_from, code_to,
   account_type, balance_side)
select v.statement_code, v.line_code, v.sequence, v.rule_kind, v.code_from,
       v.code_to, v.account_type::account_type, v.balance_side
  from (values
    ('SR-IFRS-SME-IS', 'REV', 10, 'code_range', '4000', '4699', null, 'any'),
    ('SR-IFRS-SME-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('SR-IFRS-SME-IS', 'OTH-INC', 10, 'code_range', '4700', '4799', null, 'any'),
    ('SR-IFRS-SME-IS', 'OPEX', 10, 'code_range', '6000', '6799', null, 'any'),
    ('SR-IFRS-SME-IS', 'DEPR', 10, 'code_range', '6800', '6899', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-NC-FIX', 10, 'code_range', '1600', '1799', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-NC-INT', 10, 'code_range', '1800', '1899', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-NC-OTH', 10, 'code_range', '1900', '1999', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-C-REC', 10, 'code_range', '1100', '1199', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-C-INV', 10, 'code_range', '1200', '1299', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-C-OTH', 10, 'code_range', '1300', '1399', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-C-PRE', 10, 'code_range', '1400', '1499', null, 'any'),
    ('SR-IFRS-SME-SFP', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('SR-IFRS-SME-SFP', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('SR-IFRS-SME-SFP', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('SR-IFRS-SME-SFP', 'E-RESULT', 10, 'code_range', '4000', '4699', null, 'any'),
    ('SR-IFRS-SME-SFP', 'E-RESULT', 20, 'code_range', '4700', '4799', null, 'any'),
    ('SR-IFRS-SME-SFP', 'E-RESULT', 30, 'code_range', '5000', '5099', null, 'any'),
    ('SR-IFRS-SME-SFP', 'E-RESULT', 40, 'code_range', '6000', '6899', null, 'any'),
    ('SR-IFRS-SME-SFP', 'L-NC', 10, 'code_range', '2300', '2399', null, 'any'),
    ('SR-IFRS-SME-SFP', 'L-C-PAY', 10, 'code_range', '2000', '2059', null, 'any'),
    ('SR-IFRS-SME-SFP', 'L-C-TAX', 10, 'code_range', '2060', '2069', null, 'any'),
    ('SR-IFRS-SME-SFP', 'L-C-TAX', 20, 'code_range', '2100', '2199', null, 'any'),
    ('SR-IFRS-SME-SFP', 'L-C-OTH', 10, 'code_range', '2070', '2099', null, 'any'),
    ('SR-IFRS-SME-SFP', 'L-C-OTH', 20, 'code_range', '2200', '2299', null, 'any')
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
  ('SR', 'Suriname', '{"en":"Suriname"}'::jsonb, array['nl', 'en']::text[], 'SRD', '1100', '2000', '2090', '6490', '3200', '4000', '5010', '1010', '1000', 'SAL', 'PUR', 'GEN', 'nl', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4700', '6450', '4750', '6460', null, null, '2100', '1172', null, 'month'::declaration_period)
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
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Wet BTW, artikel 27, lid 1 — de ondernemer reikt gedagtekende en doorlopend genummerde facturen uit aan afnemers die ondernemers zijn, en maakt van elke factuur een dubbel (lid 5). ''Doorlopend genummerd'' is gelezen als een reeks zonder gat, zonder een jaarlijkse herstart; het formaat van het nummer is een voorstel van dit pakket',
  numbering_source_key          = 'sr-wet-btw',
  payment_terms_legal_reference = 'Geen gelezen Surinaamse tekst bepaalt een betalingstermijn tussen twee ondernemers of een rente op een te laat betaalde handelsschuld: de rente bij een te late betaling van de belasting (artikel 13, lid 5) en de boeten zijn lasten van de belastingplichtige jegens de Belastingdienst. `legal_payment_days` en `late_payment_reference` zijn leeg',
  payment_terms_source_key      = 'sr-wet-btw',
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Wet BTW, artikel 12 — de belasting wordt verschuldigd op het tijdstip van uitreiking van de factuur wanneer een factuur moet worden uitgereikt (en uiterlijk op het tijdstip waarop dat had moeten gebeuren: binnen vijftien dagen na afloop van de maand van de levering, artikel 27, lid 3), in andere gevallen op het tijdstip van de levering of dienst, en in elk geval op het tijdstip waarop de vergoeding geheel of gedeeltelijk wordt ontvangen. `invoice_if_issued` is de dichtstbijzijnde waarde, de ontvangst van een vooruitbetaling als eerder tijdstip niet inbegrepen',
  tax_point_source_key          = 'sr-wet-btw',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Geen gelezen Surinaamse tekst verplicht een ondernemer tot het uitreiken of aanvaarden van een elektronische factuur: de Wet BTW vraagt een gedagtekende, doorlopend genummerde factuur met het bedrag van de verschuldigde belasting (artikel 27) en de brochure van de Belastingdienst noemt kassaregistratie voor de verkoop aan anderen dan ondernemers, zonder platform of formaat. Geen Peppol-autoriteit voor Suriname werd gezocht',
  einvoice_source_key           = 'sr-btw-brochure',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'SR';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('SR', 'exempt', 'exempt', 'Vrijgesteld van BTW (bijlage 2 van de Wet Belasting over de Toegevoegde Waarde 2022).', '{"en":"Exempt from VAT (Annex 2 of the Value Added Tax Act 2022)."}'::jsonb, 10, date '1970-01-01', null, 'Brochure van de Belastingdienst over de BTW-wetgeving, hoofdstuk Uitreiken van facturen: een factuur vermeldt, in geval van een vrijstelling van BTW, de vermelding daarvan. De zin zelf is van dit pakket; de Wet BTW (artikel 27) vraagt van de factuur het bedrag van de verschuldigde belasting')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;

update country_defaults set
  tax_payee_name       = 'Belastingdienst Suriname',
  tax_payee_source_key = 'sr-portaal'
 where country = 'SR';
