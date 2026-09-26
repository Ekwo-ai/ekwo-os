-- Ekwo OS — Kosova: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/xk at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build xk`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ligji Nr. 05/L-037 për Tatimin mbi Vlerën e Shtuar (Gazeta Zyrtare e Republikës së Kosovës, Nr. 23, 17 gusht 2015) (Kuvendi i Republikës së Kosovës — Administrata Tatimore e Kosovës)
--     https://www.atk-ks.org/wp-content/uploads/2017/07/LIGJI_NR._05_L-037__PER_TATIMIN_MBI_VLEREN_E_SHTUAR_SHTOJCA.pdf
--   Udhëzimi Administrativ MF-Nr. 03/2015 për zbatimin e Ligjit Nr. 05/L-037 për Tatimin mbi Vlerën e Shtuar (Ministria e Financave e Republikës së Kosovës)
--     https://gzk.rks-gov.net/ActDocumentDetail.aspx?ActID=11079
--   Formulari i deklarimit dhe pagesës së TVSH-së (TV-E-3), me shënimet e ATK-së për plotësimin e tij (Administrata Tatimore e Kosovës)
--     https://www.atk-ks.org/wp-content/uploads/2017/10/TV1.pdf
--   EDI — Sistemi Elektronik i Deklarimit i Administratës Tatimore të Kosovës (Administrata Tatimore e Kosovës)
--     https://edi.atk-ks.org/
--   Ligji Nr. 06/L-032 për Kontabilitet, Raportim Financiar dhe Auditim (Gazeta Zyrtare e Republikës së Kosovës, Nr. 3, 19 prill 2018) (Kuvendi i Republikës së Kosovës — Këshilli Kosovar për Raportim Financiar (KKRF))
--     https://cps.rks-gov.net/wp-content/uploads/2020/09/LAW_NO._06_L-032___ON_ACCOUNTING_FINANCIAL_REPORTING_AND_AUDITING-2.pdf
--   IFRS for SMEs Accounting Standard (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes-accounting-standard/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('XK', 'Kosova', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'addb94b57e4582a05139d6d0288692987ed8c9d6b630de566fe71bc4465fd6bf', '[{"key":"ligji-tvsh","title":"Ligji Nr. 05/L-037 për Tatimin mbi Vlerën e Shtuar (Gazeta Zyrtare e Republikës së Kosovës, Nr. 23, 17 gusht 2015)","publisher":"Kuvendi i Republikës së Kosovës — Administrata Tatimore e Kosovës","url":"https://www.atk-ks.org/wp-content/uploads/2017/07/LIGJI_NR._05_L-037__PER_TATIMIN_MBI_VLEREN_E_SHTUAR_SHTOJCA.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"udhezimi-tvsh","title":"Udhëzimi Administrativ MF-Nr. 03/2015 për zbatimin e Ligjit Nr. 05/L-037 për Tatimin mbi Vlerën e Shtuar","publisher":"Ministria e Financave e Republikës së Kosovës","url":"https://gzk.rks-gov.net/ActDocumentDetail.aspx?ActID=11079","consulted_on":"2026-09-26","kind":"regulation"},{"key":"tv-form","title":"Formulari i deklarimit dhe pagesës së TVSH-së (TV-E-3), me shënimet e ATK-së për plotësimin e tij","publisher":"Administrata Tatimore e Kosovës","url":"https://www.atk-ks.org/wp-content/uploads/2017/10/TV1.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"edi-portal","title":"EDI — Sistemi Elektronik i Deklarimit i Administratës Tatimore të Kosovës","publisher":"Administrata Tatimore e Kosovës","url":"https://edi.atk-ks.org/","consulted_on":"2026-09-26","kind":"portal"},{"key":"ligji-kontabiliteti","title":"Ligji Nr. 06/L-032 për Kontabilitet, Raportim Financiar dhe Auditim (Gazeta Zyrtare e Republikës së Kosovës, Nr. 3, 19 prill 2018)","publisher":"Kuvendi i Republikës së Kosovës — Këshilli Kosovar për Raportim Financiar (KKRF)","url":"https://cps.rks-gov.net/wp-content/uploads/2020/09/LAW_NO._06_L-032___ON_ACCOUNTING_FINANCIAL_REPORTING_AND_AUDITING-2.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes-accounting-standard/","consulted_on":"2026-09-26","kind":"standard"}]'::jsonb)
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
  ('XK', 'default', 'Plan kontabël i frymëzuar nga IFRS (jo i legjislatuar)', '{"en":"IFRS-inspired chart of accounts (not legislated)"}'::jsonb, true, 'companies', array['XK-IFRS-BS', 'XK-IFRS-IS']::text[], null, 'Ligji Nr. 06/L-032 për Kontabilitet, Raportim Financiar dhe Auditim, neni 7 (organizatat e mëdha — IFRS të plota) dhe neni 8 (organizatat e vogla dhe të mesme — IFRS for SMEs) — ligji përcakton standardet e raportimit sipas madhësisë së subjektit dhe fuqinë e Këshillit Kosovar për Raportim Financiar (KKRF) për t''i miratuar ato, por nuk përcakton një plan kontabël të detyrueshëm me kode zyrtare. Ky paket ofron një plan kontabël të organizuar sipas terminologjisë ndërkombëtare të IFRS, me emërtime në shqip dhe anglisht, dhe jo një plan të miratuar me ligj — shih README.md.', 'ligji-kontabiliteti')
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
  ('XK', 'default', '0100', 'Emri i mirë (goodwill)', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 10),
  ('XK', 'default', '0101', 'Emri i mirë — amortizimi i akumuluar', '{"en":"Goodwill — accumulated amortisation"}'::jsonb, 'asset_fixed', false, null, 20),
  ('XK', 'default', '0110', 'Software dhe aktive të tjera jomateriale', '{"en":"Software and other intangible assets"}'::jsonb, 'asset_fixed', false, null, 30),
  ('XK', 'default', '0111', 'Software — amortizimi i akumuluar', '{"en":"Software — accumulated amortisation"}'::jsonb, 'asset_fixed', false, null, 40),
  ('XK', 'default', '0120', 'Shpenzime të kapitalizuara kërkimi dhe zhvillimi', '{"en":"Capitalised research and development costs"}'::jsonb, 'asset_fixed', false, null, 50),
  ('XK', 'default', '0121', 'Shpenzime kërkimi dhe zhvillimi — amortizimi i akumuluar', '{"en":"Research and development costs — accumulated amortisation"}'::jsonb, 'asset_fixed', false, null, 60),
  ('XK', 'default', '0200', 'Toka', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 70),
  ('XK', 'default', '0210', 'Ndërtesa', '{"en":"Buildings"}'::jsonb, 'asset_fixed', false, null, 80),
  ('XK', 'default', '0211', 'Ndërtesa — zhvlerësimi i akumuluar', '{"en":"Buildings — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 90),
  ('XK', 'default', '0220', 'Makineri dhe pajisje', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 100),
  ('XK', 'default', '0221', 'Makineri dhe pajisje — zhvlerësimi i akumuluar', '{"en":"Machinery and equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 110),
  ('XK', 'default', '0230', 'Mjete transporti', '{"en":"Motor vehicles"}'::jsonb, 'asset_fixed', false, null, 120),
  ('XK', 'default', '0231', 'Mjete transporti — zhvlerësimi i akumuluar', '{"en":"Motor vehicles — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 130),
  ('XK', 'default', '0240', 'Mobilje dhe inventar zyre', '{"en":"Furniture and office equipment"}'::jsonb, 'asset_fixed', false, null, 140),
  ('XK', 'default', '0241', 'Mobilje dhe inventar zyre — zhvlerësimi i akumuluar', '{"en":"Furniture and office equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 150),
  ('XK', 'default', '0250', 'Pajisje kompjuterike', '{"en":"Computer equipment"}'::jsonb, 'asset_fixed', false, null, 160),
  ('XK', 'default', '0251', 'Pajisje kompjuterike — zhvlerësimi i akumuluar', '{"en":"Computer equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 170),
  ('XK', 'default', '0260', 'Ndërtim në vazhdim dhe investime kapitale në proces', '{"en":"Construction in progress and capital work in progress"}'::jsonb, 'asset_fixed', false, null, 180),
  ('XK', 'default', '0270', 'Përmirësime në pronën e marrë me qira', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 190),
  ('XK', 'default', '0271', 'Përmirësime në pronën e marrë me qira — zhvlerësimi i akumuluar', '{"en":"Leasehold improvements — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 200),
  ('XK', 'default', '0280', 'Aktivi i së drejtës së përdorimit (qiraja)', '{"en":"Right-of-use asset (lease)"}'::jsonb, 'asset_fixed', false, null, 210),
  ('XK', 'default', '0281', 'Aktivi i së drejtës së përdorimit — zhvlerësimi i akumuluar', '{"en":"Right-of-use asset — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 220),
  ('XK', 'default', '0300', 'Investime financiare afatgjata', '{"en":"Long-term financial investments"}'::jsonb, 'asset_non_current', false, null, 230),
  ('XK', 'default', '0310', 'Pjesëmarrje në shoqëri të varura dhe të asociuara', '{"en":"Investments in subsidiaries and associates"}'::jsonb, 'asset_non_current', false, null, 240),
  ('XK', 'default', '0320', 'Kredi afatgjata dhënë palëve të treta', '{"en":"Long-term loans granted to third parties"}'::jsonb, 'asset_non_current', false, null, 250),
  ('XK', 'default', '0330', 'Aktivi i shtyrë tatimor', '{"en":"Deferred tax asset"}'::jsonb, 'asset_non_current', false, null, 260),
  ('XK', 'default', '0340', 'Të arkëtueshme afatgjata', '{"en":"Long-term receivables"}'::jsonb, 'asset_non_current', false, null, 270),
  ('XK', 'default', '0350', 'Prona e investimit', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, null, 280),
  ('XK', 'default', '1000', 'Lëndë e parë dhe materiale', '{"en":"Raw materials and supplies"}'::jsonb, 'asset_current', false, null, 290),
  ('XK', 'default', '1010', 'Prodhim në proces', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 300),
  ('XK', 'default', '1020', 'Produkte të gatshme', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 310),
  ('XK', 'default', '1030', 'Stoqe mallrash', '{"en":"Merchandise inventory"}'::jsonb, 'asset_current', false, null, 320),
  ('XK', 'default', '1040', 'Mallra në rrugë (të patranzituara)', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 330),
  ('XK', 'default', '1050', 'Sende me vlerë të vogël dhe konsumim të shpejtë', '{"en":"Low-value and fast-consumption items"}'::jsonb, 'asset_current', false, null, 340),
  ('XK', 'default', '1100', 'Të arkëtueshme nga blerësit', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 350),
  ('XK', 'default', '1110', 'Provizioni për borxhe të dyshimta', '{"en":"Allowance for doubtful debts"}'::jsonb, 'asset_receivable', true, null, 360),
  ('XK', 'default', '1120', 'Të arkëtueshme të tjera', '{"en":"Other receivables"}'::jsonb, 'asset_receivable', true, null, 370),
  ('XK', 'default', '1130', 'Të arkëtueshme nga palët e lidhura', '{"en":"Receivables from related parties"}'::jsonb, 'asset_receivable', true, null, 380),
  ('XK', 'default', '1200', 'Paradhënie dhëna furnitorëve', '{"en":"Advances paid to suppliers"}'::jsonb, 'asset_prepayments', false, null, 390),
  ('XK', 'default', '1210', 'Shpenzime të parapaguara', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 400),
  ('XK', 'default', '1220', 'Primi i sigurimit i parapaguar', '{"en":"Prepaid insurance premium"}'::jsonb, 'asset_prepayments', false, null, 410),
  ('XK', 'default', '1300', 'Arka (para në dorë)', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 420),
  ('XK', 'default', '1310', 'Llogari bankare në euro', '{"en":"Bank accounts in euro"}'::jsonb, 'asset_cash', false, null, 430),
  ('XK', 'default', '1320', 'Llogari bankare në valutë të huaj', '{"en":"Bank accounts in foreign currency"}'::jsonb, 'asset_cash', false, null, 440),
  ('XK', 'default', '1330', 'Mjete monetare në tranzit (inkasim)', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 450),
  ('XK', 'default', '1450', 'TVSH e zbritshme — blerje vendase me normën standarde 18%', '{"en":"Deductible VAT — domestic purchases at the standard 18% rate"}'::jsonb, 'asset_current', false, null, 460),
  ('XK', 'default', '1452', 'TVSH e zbritshme — blerje vendase me normën e reduktuar 8%', '{"en":"Deductible VAT — domestic purchases at the reduced 8% rate"}'::jsonb, 'asset_current', false, null, 470),
  ('XK', 'default', '1454', 'TVSH e zbritshme — importe', '{"en":"Deductible VAT — imports"}'::jsonb, 'asset_current', false, null, 480),
  ('XK', 'default', '1456', 'TVSH e zbritshme — vetëngarkim mbi shërbimet nga jorezidentë', '{"en":"Deductible VAT — reverse charge on services received from non-established suppliers"}'::jsonb, 'asset_current', false, null, 490),
  ('XK', 'default', '1458', 'Llogaria e shlyerjes së TVSH-së — tepricë e arkëtueshme', '{"en":"VAT settlement account — receivable balance"}'::jsonb, 'asset_current', true, null, 500),
  ('XK', 'default', '1460', 'Llogaria me buxhetin — tatime të tjera', '{"en":"Account with the tax administration — other taxes"}'::jsonb, 'asset_current', false, null, 510),
  ('XK', 'default', '1470', 'Paradhënie dhe të arkëtueshme nga punonjësit', '{"en":"Advances and receivables from employees"}'::jsonb, 'asset_current', false, null, 520),
  ('XK', 'default', '1480', 'Investime financiare afatshkurtra', '{"en":"Short-term financial investments"}'::jsonb, 'asset_current', false, null, 530),
  ('XK', 'default', '1490', 'Aktive të tjera afatshkurtra', '{"en":"Other current assets"}'::jsonb, 'asset_current', false, null, 540),
  ('XK', 'default', '2000', 'Detyrime ndaj furnitorëve', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 550),
  ('XK', 'default', '2010', 'Detyrime ndaj palëve të lidhura', '{"en":"Payables to related parties"}'::jsonb, 'liability_payable', true, null, 560),
  ('XK', 'default', '2020', 'Paradhënie të pranuara nga blerësit', '{"en":"Advances received from customers"}'::jsonb, 'liability_payable', true, null, 570),
  ('XK', 'default', '2100', 'TVSH e ngarkuar — furnizime vendase me normën standarde 18%', '{"en":"VAT charged — domestic supplies at the standard 18% rate"}'::jsonb, 'liability_current', false, null, 580),
  ('XK', 'default', '2102', 'TVSH e ngarkuar — furnizime vendase me normën e reduktuar 8%', '{"en":"VAT charged — domestic supplies at the reduced 8% rate"}'::jsonb, 'liability_current', false, null, 590),
  ('XK', 'default', '2104', 'TVSH e vetëngarkuar — shërbime të pranuara nga jorezidentë', '{"en":"Self-charged VAT — services received from non-established suppliers"}'::jsonb, 'liability_current', false, null, 600),
  ('XK', 'default', '2108', 'Llogaria e shlyerjes së TVSH-së — detyrim për pagesë', '{"en":"VAT settlement account — payable balance"}'::jsonb, 'liability_current', true, null, 610),
  ('XK', 'default', '2120', 'Detyrimi i tatimit në fitim', '{"en":"Corporate income tax liability"}'::jsonb, 'liability_current', false, null, 620),
  ('XK', 'default', '2130', 'Detyrime ndaj punonjësve për paga', '{"en":"Payroll payable"}'::jsonb, 'liability_current', false, null, 630),
  ('XK', 'default', '2140', 'Detyrime për tatimin në të ardhurat personale dhe kontribute', '{"en":"Personal income tax and social contributions payable"}'::jsonb, 'liability_current', false, null, 640),
  ('XK', 'default', '2150', 'Shpenzime të përllogaritura afatshkurtra', '{"en":"Short-term accrued expenses"}'::jsonb, 'liability_current', false, null, 650),
  ('XK', 'default', '2160', 'Kredi dhe huamarrje afatshkurtra', '{"en":"Short-term loans and borrowings"}'::jsonb, 'liability_current', false, null, 660),
  ('XK', 'default', '2170', 'Detyrimi afatshkurtër i qirasë', '{"en":"Short-term lease liability"}'::jsonb, 'liability_current', false, null, 670),
  ('XK', 'default', '2180', 'Detyrimi për dividendë', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 680),
  ('XK', 'default', '2190', 'Provizione afatshkurtra', '{"en":"Short-term provisions"}'::jsonb, 'liability_current', false, null, 690),
  ('XK', 'default', '2200', 'Detyrime të tjera afatshkurtra', '{"en":"Other current liabilities"}'::jsonb, 'liability_current', false, null, 700),
  ('XK', 'default', '2250', 'Detyrimi për kartelën e kreditit', '{"en":"Credit card liability"}'::jsonb, 'liability_credit_card', false, null, 710),
  ('XK', 'default', '2300', 'Llogaria e pritjes (shumat e paidentifikuara)', '{"en":"Suspense account (unidentified receipts and payments)"}'::jsonb, 'liability_current', false, null, 720),
  ('XK', 'default', '2400', 'Kredi dhe huamarrje afatgjata', '{"en":"Long-term loans and borrowings"}'::jsonb, 'liability_non_current', false, null, 730),
  ('XK', 'default', '2410', 'Detyrimi afatgjatë i qirasë', '{"en":"Long-term lease liability"}'::jsonb, 'liability_non_current', false, null, 740),
  ('XK', 'default', '2420', 'Detyrimi i shtyrë tatimor', '{"en":"Deferred tax liability"}'::jsonb, 'liability_non_current', false, null, 750),
  ('XK', 'default', '2430', 'Provizione afatgjata (pensione etj.)', '{"en":"Long-term provisions (pensions and other)"}'::jsonb, 'liability_non_current', false, null, 760),
  ('XK', 'default', '2440', 'Obligacione afatgjata', '{"en":"Long-term bonds"}'::jsonb, 'liability_non_current', false, null, 770),
  ('XK', 'default', '3000', 'Kapitali themeltar', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 780),
  ('XK', 'default', '3010', 'Primi i emetimit', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 790),
  ('XK', 'default', '3020', 'Instrumente të kapitalit vetjak të riblera', '{"en":"Treasury shares"}'::jsonb, 'equity', false, null, 800),
  ('XK', 'default', '3030', 'Rezerva e rivlerësimit', '{"en":"Revaluation reserve"}'::jsonb, 'equity', false, null, 810),
  ('XK', 'default', '3040', 'Rezerva të tjera', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 820),
  ('XK', 'default', '3050', 'Rezerva e konvertimit të operacioneve në valutë të huaj', '{"en":"Foreign operations translation reserve"}'::jsonb, 'equity', false, null, 830),
  ('XK', 'default', '3100', 'Fitimi i pashpërndarë (humbja e pambuluar)', '{"en":"Retained earnings (accumulated losses)"}'::jsonb, 'equity_retained', false, null, 840),
  ('XK', 'default', '4000', 'Të hyra nga shitja e mallrave', '{"en":"Revenue from sale of goods"}'::jsonb, 'income', false, null, 850),
  ('XK', 'default', '4010', 'Të hyra nga ofrimi i shërbimeve', '{"en":"Revenue from services rendered"}'::jsonb, 'income', false, null, 860),
  ('XK', 'default', '4020', 'Të hyra nga eksporti', '{"en":"Revenue from exports"}'::jsonb, 'income', false, null, 870),
  ('XK', 'default', '4030', 'Zbritje dhe kthime nga shitja', '{"en":"Sales discounts and returns"}'::jsonb, 'income', false, null, 880),
  ('XK', 'default', '4040', 'Të hyra nga kontratat e ndërtimit', '{"en":"Revenue from construction contracts"}'::jsonb, 'income', false, null, 890),
  ('XK', 'default', '4050', 'Të hyra nga qiraja', '{"en":"Rental income"}'::jsonb, 'income', false, null, 900),
  ('XK', 'default', '4200', 'Të hyra nga interesi', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 910),
  ('XK', 'default', '4210', 'Të hyra nga dividendët', '{"en":"Dividend income"}'::jsonb, 'income_other', false, null, 920),
  ('XK', 'default', '4220', 'Fitimi nga diferencat e këmbimit', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, null, 930),
  ('XK', 'default', '4230', 'Fitimi nga shitja e mjeteve themelore', '{"en":"Gains on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 940),
  ('XK', 'default', '4240', 'Të hyra nga grante dhe subvencione shtetërore', '{"en":"Income from government grants and subsidies"}'::jsonb, 'income_other', false, null, 950),
  ('XK', 'default', '4250', 'Të hyra të tjera operative', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 960),
  ('XK', 'default', '5000', 'Kostoja e mallrave të shitura', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 970),
  ('XK', 'default', '5010', 'Kostoja e lëndës së parë të konsumuar', '{"en":"Cost of raw materials consumed"}'::jsonb, 'expense_direct_cost', false, null, 980),
  ('XK', 'default', '5020', 'Kosto direkte e punës në prodhim', '{"en":"Direct labour cost of production"}'::jsonb, 'expense_direct_cost', false, null, 990),
  ('XK', 'default', '5030', 'Shpenzime të përgjithshme prodhimi', '{"en":"Production overheads"}'::jsonb, 'expense_direct_cost', false, null, 1000),
  ('XK', 'default', '5040', 'Shpenzimet e transportit të blerjeve', '{"en":"Freight-in on purchases"}'::jsonb, 'expense_direct_cost', false, null, 1010),
  ('XK', 'default', '6000', 'Paga dhe shpërblime', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, null, 1020),
  ('XK', 'default', '6010', 'Kontribute të sigurimeve shoqërore (punëdhënësi)', '{"en":"Social security contributions (employer)"}'::jsonb, 'expense', false, null, 1030),
  ('XK', 'default', '6020', 'Qiraja', '{"en":"Rent"}'::jsonb, 'expense', false, null, 1040),
  ('XK', 'default', '6030', 'Shërbimet komunale', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 1050),
  ('XK', 'default', '6040', 'Furnizime dhe shpenzime zyre', '{"en":"Office supplies and expenses"}'::jsonb, 'expense', false, null, 1060),
  ('XK', 'default', '6050', 'Telekomunikacion', '{"en":"Telecommunications"}'::jsonb, 'expense', false, null, 1070),
  ('XK', 'default', '6060', 'Shërbime profesionale dhe konsulencë', '{"en":"Professional and consulting services"}'::jsonb, 'expense', false, null, 1080),
  ('XK', 'default', '6070', 'Marketing dhe reklamë', '{"en":"Marketing and advertising"}'::jsonb, 'expense', false, null, 1090),
  ('XK', 'default', '6080', 'Shpenzime udhëtimi', '{"en":"Travel expenses"}'::jsonb, 'expense', false, null, 1100),
  ('XK', 'default', '6090', 'Sigurimi', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 1110),
  ('XK', 'default', '6100', 'Riparime dhe mirëmbajtje', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 1120),
  ('XK', 'default', '6110', 'Komisione dhe shpenzime bankare', '{"en":"Bank charges and commissions"}'::jsonb, 'expense', false, null, 1130),
  ('XK', 'default', '6120', 'Qira afatshkurtra dhe aktive me vlerë të vogël', '{"en":"Short-term leases and low-value assets"}'::jsonb, 'expense', false, null, 1140),
  ('XK', 'default', '6130', 'Humbje nga borxhe të pambledhshme dhe të dyshimta', '{"en":"Bad and doubtful debt expense"}'::jsonb, 'expense', false, null, 1150),
  ('XK', 'default', '6140', 'Shpenzime përfaqësimi', '{"en":"Representation expenses"}'::jsonb, 'expense', false, null, 1160),
  ('XK', 'default', '6150', 'Trajnim dhe zhvillim i personelit', '{"en":"Staff training and development"}'::jsonb, 'expense', false, null, 1170),
  ('XK', 'default', '6160', 'Sigurim fizik dhe roje', '{"en":"Security expenses"}'::jsonb, 'expense', false, null, 1180),
  ('XK', 'default', '6170', 'Karburant dhe mirëmbajtje automjetesh', '{"en":"Fuel and vehicle running costs"}'::jsonb, 'expense', false, null, 1190),
  ('XK', 'default', '6180', 'Licenca, taksa dhe leje', '{"en":"Licences, taxes and fees"}'::jsonb, 'expense', false, null, 1200),
  ('XK', 'default', '6190', 'Donacione dhe kontribute bamirëse', '{"en":"Donations and charitable contributions"}'::jsonb, 'expense', false, null, 1210),
  ('XK', 'default', '6200', 'Shpenzime të tjera administrative', '{"en":"Other administrative expenses"}'::jsonb, 'expense', false, null, 1220),
  ('XK', 'default', '6210', 'Shpenzimi i rezervave të sigurimit', '{"en":"Insurance reserve expense"}'::jsonb, 'expense', false, null, 1230),
  ('XK', 'default', '6220', 'Kërkim dhe zhvillim i pakapitalizuar', '{"en":"Non-capitalised research and development"}'::jsonb, 'expense', false, null, 1240),
  ('XK', 'default', '6900', 'Zhvlerësimi i mjeteve themelore', '{"en":"Depreciation of property, plant and equipment"}'::jsonb, 'expense_depreciation', false, null, 1250),
  ('XK', 'default', '6910', 'Amortizimi i aktiveve jomateriale', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, null, 1260),
  ('XK', 'default', '6920', 'Zhvlerësimi i aktivit të së drejtës së përdorimit', '{"en":"Depreciation of right-of-use assets"}'::jsonb, 'expense_depreciation', false, null, 1270),
  ('XK', 'default', '7000', 'Shpenzime interesi mbi huatë', '{"en":"Interest expense on borrowings"}'::jsonb, 'expense', false, null, 1280),
  ('XK', 'default', '7010', 'Humbje nga diferencat e këmbimit', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, null, 1290),
  ('XK', 'default', '7020', 'Humbje nga shitja e mjeteve themelore', '{"en":"Losses on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1300),
  ('XK', 'default', '7030', 'Shpenzimi i tatimit në fitim', '{"en":"Corporate income tax expense"}'::jsonb, 'expense', false, null, 1310),
  ('XK', 'default', '7040', 'Gjoba dhe kamatëvonesa', '{"en":"Fines and penalties"}'::jsonb, 'expense', false, null, 1320),
  ('XK', 'default', '7050', 'Shpenzime të tjera joperative', '{"en":"Other non-operating expenses"}'::jsonb, 'expense', false, null, 1330),
  ('XK', 'default', '7060', 'Diferenca e rrumbullakimit', '{"en":"Rounding difference"}'::jsonb, 'expense', false, null, 1340),
  ('XK', 'default', '9000', 'Aktive të marra me qira jashtë bilancit', '{"en":"Off-balance-sheet leased-in assets"}'::jsonb, 'off_balance', false, null, 1350),
  ('XK', 'default', '9010', 'Mallra të marra në përgjegjësi', '{"en":"Goods held on behalf of third parties"}'::jsonb, 'off_balance', false, null, 1360),
  ('XK', 'default', '9020', 'Garanci dhe dorëzani të dhëna', '{"en":"Guarantees and sureties given"}'::jsonb, 'off_balance', false, null, 1370)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('XK', 'BNK', 'Ditari i bankës', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('XK', 'CSH', 'Ditari i arkës', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('XK', 'GEN', 'Ditari i përgjithshëm', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('XK', 'OPN', 'Ditari i hapjes', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('XK', 'PUR', 'Ditari i blerjeve', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('XK', 'SAL', 'Ditari i shitjeve', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('XK', 'XK-P-18', 'TVSH 18% — norma standarde (blerje), e zbritshme', '{"en":"VAT 18% — standard rate (purchase), deductible"}'::jsonb, null, 'percent', 18, 'purchase', 'domestic', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 26, paragrafi 1 dhe neni 36, paragrafi 2, nën-paragrafi 2.1 — personi i tatueshëm mund të zbresë TVSH-në e ngarkuar mbi blerjet e mallrave ose shërbimeve brenda territorit të Kosovës, nëse ato shfrytëzohen për qëllime të transaksioneve të tij të tatueshme.', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-P-8', 'TVSH 8% — norma e reduktuar (blerje), e zbritshme', '{"en":"VAT 8% — reduced rate (purchase), deductible"}'::jsonb, null, 'percent', 8, 'purchase', 'domestic', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 26, paragrafi 2 dhe neni 36, paragrafi 2, nën-paragrafi 2.1 — e njëjta e drejtë zbritjeje, për blerjet e tatuara me normën e reduktuar.', 'S', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-P-EXEMPT', 'Blerje pa TVSH — furnizuesi kryen veprimtari të liruar (p.sh. sigurim)', '{"en":"Purchase with no VAT — supplier''s exempt activity (e.g. insurance)"}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 28, paragrafi 1, nën-paragrafi 1.1 — transaksionet e sigurimit dhe risigurimit të jetës dhe shëndetit janë të liruara nga TVSH-ja; furnizuesi nuk e ngarkon TVSH-në në faturë, kështu që blerësi nuk ka TVSH për të zbritur.', 'E', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-P-IMPORT', 'Import mallrash — TVSH paguar në doganë, e zbritshme', '{"en":"Import of goods — VAT paid at customs, deductible"}'::jsonb, null, 'percent', 18, 'purchase', 'import', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 52, paragrafi 3 — në importim, TVSH-ja paguhet nga personi i caktuar si i obliguar sipas legjislacionit doganor në fuqi, njëkohësisht me borxhin doganor. Neni 36, paragrafi 2, nën-paragrafi 2.2 — TVSH-ja e paguar për importimin e mallrave brenda territorit të Kosovës është e zbritshme.', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-P-RC-FOREIGN', 'Shërbim i pranuar nga furnizues jorezident — vetëngarkim', '{"en":"Service received from a non-established supplier — reverse charge"}'::jsonb, null, 'percent', 18, 'purchase', 'foreign_services_received', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 52, paragrafi 1, nën-paragrafi 1.2 — personi i regjistruar për TVSH në Kosovë të cilit i janë furnizuar shërbime nga një person i tatueshëm i pathemeluar në Kosovë, kur vendi i furnizimit konsiderohet Kosova (neni 20), është vetë i obliguar për TVSH-në. Neni 36, paragrafi 2, nën-paragrafi 2.1 — e njëjta TVSH e vetëngarkuar është e zbritshme nëse shërbimi shfrytëzohet për transaksionet e tatueshme të personit.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-S-18', 'TVSH 18% — norma standarde (furnizim)', '{"en":"VAT 18% — standard rate (supply)"}'::jsonb, null, 'percent', 18, 'sale', 'domestic', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 26, paragrafi 1 — TVSH-ja ngarkohet me normën standarde prej tetëmbëdhjetë përqind (18%).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-S-8', 'TVSH 8% — norma e reduktuar (furnizim)', '{"en":"VAT 8% — reduced rate (supply)"}'::jsonb, null, 'percent', 8, 'sale', 'domestic', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 26, paragrafi 2 — norma e reduktuar prej tetë përqind (8%) llogaritet dhe paguhet për furnizimin e mallrave dhe shërbimeve, si dhe importin e tyre, të renditura taksativisht në nën-paragrafët 2.1–2.13 (ujë përveç atij të ambalazhuar, energji elektrike dhe ngrohje qendrore, drithëra dhe prodhime buke, vajra gatimi, qumësht, kripë, vezë, libra shkollorë dhe botime, pajisje të teknologjisë së informacionit, barna dhe pajisje mjekësore, pajisje për personat me aftësi të kufizuara).', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-S-EXEMPT-EDU', 'Shërbime arsimore — të liruara pa të drejtë zbritjeje', '{"en":"Educational services — exempt without credit"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 27, paragrafi 1, nën-paragrafi 1.8 — ofrimi i edukimit të fëmijëve dhe të rinjve, edukimi shkollor apo universitar, trajnimi profesional apo ritrajnimi, nga organet e rregulluara me ligjet e Kosovës, është i liruar nga TVSH-ja. Kapitulli VIII, ku bën pjesë ky nen, titullohet „Lirimet pa të drejtën e zbritjes së TVSH-së së zbritshme” dhe neni 36 nuk e përfshin këtë kapitull ndër transaksionet që ruajnë të drejtën e zbritjes.', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null),
  ('XK', 'XK-S-EXPORT', 'Eksport mallrash — i liruar me të drejtë zbritjeje', '{"en":"Export of goods — exempt with credit"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 31, paragrafi 1, nën-paragrafi 1.1 — furnizimi i mallrave të dërguara ose të transportuara për destinim jashtë Kosovës nga ose në interes të shitësit është i liruar nga TVSH-ja. E drejta e zbritjes së TVSH-së hyrëse mbetet, sipas nenit 36, paragrafi 3, nën-paragrafi 3.2 — transaksionet e liruara sipas Kapitullit X (ku bën pjesë neni 31) ruajnë të drejtën e zbritjes.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ligji-tvsh', null, null, null, null)
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
    ('XK-P-18', 'invoice', 'base', 100, null, '09', array['09']::text[], 100, 'XK-TVSH', 10),
    ('XK-P-18', 'invoice', 'tax', 100, '1450', '09T', array['09T']::text[], 100, 'XK-TVSH', 20),
    ('XK-P-18', 'credit_note', 'base', 100, null, '09', array['09']::text[], -100, 'XK-TVSH', 10),
    ('XK-P-18', 'credit_note', 'tax', 100, '1450', '09T', array['09T']::text[], -100, 'XK-TVSH', 20),
    ('XK-P-8', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'XK-TVSH', 10),
    ('XK-P-8', 'invoice', 'tax', 100, '1452', '10T', array['10T']::text[], 100, 'XK-TVSH', 20),
    ('XK-P-8', 'credit_note', 'base', 100, null, '10', array['10']::text[], -100, 'XK-TVSH', 10),
    ('XK-P-8', 'credit_note', 'tax', 100, '1452', '10T', array['10T']::text[], -100, 'XK-TVSH', 20),
    ('XK-P-EXEMPT', 'invoice', 'base', 100, null, '07', array['07']::text[], 100, 'XK-TVSH', 10),
    ('XK-P-EXEMPT', 'credit_note', 'base', 100, null, '07', array['07']::text[], -100, 'XK-TVSH', 10),
    ('XK-P-IMPORT', 'invoice', 'base', 100, null, '08', array['08']::text[], 100, 'XK-TVSH', 10),
    ('XK-P-IMPORT', 'invoice', 'tax', 100, '1454', '08T', array['08T']::text[], 100, 'XK-TVSH', 20),
    ('XK-P-IMPORT', 'credit_note', 'base', 100, null, '08', array['08']::text[], -100, 'XK-TVSH', 10),
    ('XK-P-IMPORT', 'credit_note', 'tax', 100, '1454', '08T', array['08T']::text[], -100, 'XK-TVSH', 20),
    ('XK-P-RC-FOREIGN', 'invoice', 'base', 100, null, '05', array['05', '11']::text[], 100, 'XK-TVSH', 10),
    ('XK-P-RC-FOREIGN', 'invoice', 'tax', 100, '1456', '11T', array['11T']::text[], 100, 'XK-TVSH', 20),
    ('XK-P-RC-FOREIGN', 'invoice', 'tax', -100, '2104', '05T', array['05T']::text[], 100, 'XK-TVSH', 30),
    ('XK-P-RC-FOREIGN', 'credit_note', 'base', 100, null, '05', array['05', '11']::text[], -100, 'XK-TVSH', 10),
    ('XK-P-RC-FOREIGN', 'credit_note', 'tax', 100, '1456', '11T', array['11T']::text[], -100, 'XK-TVSH', 20),
    ('XK-P-RC-FOREIGN', 'credit_note', 'tax', -100, '2104', '05T', array['05T']::text[], -100, 'XK-TVSH', 30),
    ('XK-S-18', 'invoice', 'base', 100, null, '03', array['03']::text[], 100, 'XK-TVSH', 10),
    ('XK-S-18', 'invoice', 'tax', 100, '2100', '03T', array['03T']::text[], 100, 'XK-TVSH', 20),
    ('XK-S-18', 'credit_note', 'base', 100, null, '03', array['03']::text[], -100, 'XK-TVSH', 10),
    ('XK-S-18', 'credit_note', 'tax', 100, '2100', '03T', array['03T']::text[], -100, 'XK-TVSH', 20),
    ('XK-S-8', 'invoice', 'base', 100, null, '04', array['04']::text[], 100, 'XK-TVSH', 10),
    ('XK-S-8', 'invoice', 'tax', 100, '2102', '04T', array['04T']::text[], 100, 'XK-TVSH', 20),
    ('XK-S-8', 'credit_note', 'base', 100, null, '04', array['04']::text[], -100, 'XK-TVSH', 10),
    ('XK-S-8', 'credit_note', 'tax', 100, '2102', '04T', array['04T']::text[], -100, 'XK-TVSH', 20),
    ('XK-S-EXEMPT-EDU', 'invoice', 'base', 100, null, '01', array['01']::text[], 100, 'XK-TVSH', 10),
    ('XK-S-EXEMPT-EDU', 'credit_note', 'base', 100, null, '01', array['01']::text[], -100, 'XK-TVSH', 10),
    ('XK-S-EXPORT', 'invoice', 'base', 100, null, '02', array['02']::text[], 100, 'XK-TVSH', 10),
    ('XK-S-EXPORT', 'credit_note', 'base', 100, null, '02', array['02']::text[], -100, 'XK-TVSH', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'XK' and t.code = v.tax_code
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
  ('XK', 'XK-TVSH', 'Deklarata e TVSH-së', array['month']::declaration_period[], 'month'::declaration_period, date '2015-09-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 53, paragrafi 1 — periudha tatimore e të gjithë personave të tatueshëm është çdo muaj kalendarik, pa asnjë kadencë tjetër që varet nga qarkullimi (ndryshe nga Serbia ose Bosnja fqinje). Neni 54, paragrafi 1 përcakton përmbajtjen e detyrueshme të deklaratës: (1.1) shuma e furnizimeve të tatueshme dhe të liruara, e eksporteve dhe furnizimeve të trajtuara si eksporte, si dhe TVSH-ja e ngarkuar; (1.2) shuma e blerjeve dhe importeve dhe TVSH-ja e zbritshme; (1.3) shuma e blerjeve me TVSH të vetëngarkuar sipas nenit 52.1.4; (1.5) shuma neto për pagesë ose tepricë. Kutitë e këtij paketi janë organizimi i vet paketit i këtyre kategorive — numërimi ekzakt i ekranit aktual të sistemit elektronik EDI nuk u verifikua në mënyrë të pavarur, pasi specimeni i fundit publik i formularit (TV-E-3, rishikuar më 20.02.2008) i paraprin reformës së dy normave pozitive (2015) dhe sistemit EDI; shih README.md.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1 — personi i tatueshëm duhet të dorëzojë deklaratën tatimore dhe të bëjë pagesën përkatëse më së voni deri në datën 20 të muajit kalendarik që pason pas fundit të periudhës tatimore.', 'ligji-tvsh', null)
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
  ('XK', 'XK-TVSH', '01', 'base', 'Furnizime të liruara pa të drejtën e zbritjes', '{"en":"Exempt supplies without the right of deduction"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1 — shuma e furnizimeve të liruara.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '02', 'base', 'Furnizime me normën zero — eksporte dhe furnizime të trajtuara si eksporte', '{"en":"Zero-rated supplies — exports and supplies treated as exports"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1 — shuma e eksportimeve dhe furnizimeve të trajtuara si eksporte (nenet 31 dhe 33).', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '03', 'base', 'Furnizime të tatueshme me normën standarde 18% — baza', '{"en":"Taxable supplies at the standard 18% rate — base"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1, dhe neni 26, paragrafi 1.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '03T', 'tax', 'Furnizime të tatueshme me normën standarde 18% — TVSH e ngarkuar', '{"en":"Taxable supplies at the standard 18% rate — VAT charged"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1 — obligimi i tatimit të llogaritur.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '04', 'base', 'Furnizime të tatueshme me normën e reduktuar 8% — baza', '{"en":"Taxable supplies at the reduced 8% rate — base"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1, dhe neni 26, paragrafi 2.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '04T', 'tax', 'Furnizime të tatueshme me normën e reduktuar 8% — TVSH e ngarkuar', '{"en":"Taxable supplies at the reduced 8% rate — VAT charged"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '05', 'base', 'Shërbime të pranuara nga furnizues jorezidentë, objekt vetëngarkimi — baza (dalje)', '{"en":"Services received from non-established suppliers, subject to reverse charge — base (output side)"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 52, paragrafi 1, nën-paragrafi 1.2 — personi i regjistruar për TVSH e ngarkon vetë TVSH-në për shërbimet e pranuara nga furnizues jorezidentë.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '05T', 'tax', 'TVSH e vetëngarkuar mbi shërbimet nga jorezidentë — obligim (dalje)', '{"en":"Self-charged VAT on services from non-established suppliers — liability (output side)"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 52, paragrafi 1, nën-paragrafi 1.2.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '06', 'total', 'Obligimi total i TVSH-së mbi furnizimet', '{"en":"Total VAT liability on supplies"}'::jsonb, 90, null, array['03T', '04T', '05T']::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.1 — obligimi i tatimit të llogaritur në furnizimet e tatueshme.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '07', 'base', 'Blerje të liruara ose me TVSH jo të zbritshme', '{"en":"Exempt purchases or purchases with non-deductible VAT"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.2 — shuma e blerjeve pa TVSH të zbritshme.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '08', 'base', 'Importe — baza', '{"en":"Imports — base"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.2, dhe neni 52, paragrafi 3.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '08T', 'tax', 'Importe — TVSH e zbritshme', '{"en":"Imports — deductible VAT"}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 36, paragrafi 2, nën-paragrafi 2.2.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '09', 'base', 'Blerje vendase me normën standarde 18% — baza', '{"en":"Domestic purchases at the standard 18% rate — base"}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.2.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '09T', 'tax', 'Blerje vendase me normën standarde 18% — TVSH e zbritshme', '{"en":"Domestic purchases at the standard 18% rate — deductible VAT"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 36, paragrafi 2, nën-paragrafi 2.1.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '10', 'base', 'Blerje vendase me normën e reduktuar 8% — baza', '{"en":"Domestic purchases at the reduced 8% rate — base"}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.2.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '10T', 'tax', 'Blerje vendase me normën e reduktuar 8% — TVSH e zbritshme', '{"en":"Domestic purchases at the reduced 8% rate — deductible VAT"}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 36, paragrafi 2, nën-paragrafi 2.1.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '11', 'base', 'Shërbime të pranuara nga furnizues jorezidentë, objekt vetëngarkimi — baza (hyrje)', '{"en":"Services received from non-established suppliers, subject to reverse charge — base (input side)"}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.3 — shuma e blerjeve me TVSH e cila i ngarkohet pranuesit.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '11T', 'tax', 'TVSH e zbritshme mbi vetëngarkimin e shërbimeve nga jorezidentë (hyrje)', '{"en":"Deductible VAT on the reverse charge for services from non-established suppliers (input side)"}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 36, paragrafi 2, nën-paragrafi 2.1.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '12', 'total', 'Total TVSH e zbritshme', '{"en":"Total deductible VAT"}'::jsonb, 190, null, array['08T', '09T', '10T', '11T']::text[], '{}'::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.2.', 'ligji-tvsh'),
  ('XK', 'XK-TVSH', '13', 'total', 'Shuma neto e TVSH-së për pagesë ose tepricë për kreditim', '{"en":"Net VAT payable or credit balance"}'::jsonb, 200, null, array['06']::text[], array['12']::text[], null, null, false, false, null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 54, paragrafi 1, nën-paragrafi 1.5 — shuma neto e obligimit të TVSH-së që duhet t''i paguhet ATK-së, ose shuma neto e tepërt për atë periudhë tatimore.', 'ligji-tvsh')
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
  ('XK-IFRS-BS', 'XK', 'default', 'Pasqyra e pozicionit financiar', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'Ligji Nr. 06/L-032 për Kontabilitet, Raportim Financiar dhe Auditim, neni 8 — organizatat e vogla dhe të mesme (neni 5, paragrafët 3 dhe 4) përgatisin pasqyrat financiare sipas IFRS for SMEs; neni 7 — organizatat e mëdha (neni 5, paragrafi 5) përgatisin sipas IFRS-ve të plota. Ligji Nr. 06/L-032 nuk përcakton një formë të vetme e të detyrueshme të bilancit me rreshta të caktuar (ndryshe, për shembull, nga plani kombëtar serb apo boshnjak). Ky paket përdor grupimin minimal të parashikuar nga seksioni 4 i IFRS for SMEs, sipas diapazoneve të kodeve të llogarive të vetë këtij paketi (shih README.md) — kodet e llogarive nuk janë të përcaktuara me ligj.', 'ligji-kontabiliteti'),
  ('XK-IFRS-IS', 'XK', 'default', 'Pasqyra e të ardhurave gjithëpërfshirëse', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'Ligji Nr. 06/L-032 për Kontabilitet, Raportim Financiar dhe Auditim, neni 8; IFRS for SMEs, seksioni 5 — zërat minimalë të pasqyrës së të ardhurave gjithëpërfshirëse. Struktura këtu është sipas diapazoneve të kodeve të llogarive të vetë këtij paketi, jo sipas kodeve të një formulari zyrtar që nuk ekziston — shih README.md.', 'ligji-kontabiliteti')
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
  ('XK-IFRS-BS', 'A-NC-FIX', 'A-NC', 'Prona, impiantet, pajisjet dhe aktivet jomateriale', '{"en":"Property, plant, equipment and intangible assets"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-NC-OTH', 'A-NC', 'Aktive të tjera afatgjata', '{"en":"Other non-current assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-NC', null, 'Aktive afatgjata', '{"en":"Non-current assets"}'::jsonb, 30, 1, true, array['A-NC-FIX', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-C-REC', 'A-C', 'Të arkëtueshme tregtare dhe të tjera', '{"en":"Trade and other receivables"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-C-OTH', 'A-C', 'Stoqe, parapagime dhe aktive të tjera afatshkurtra', '{"en":"Inventories, prepayments and other current assets"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-C-CASH', 'A-C', 'Mjete monetare dhe ekuivalentë', '{"en":"Cash and cash equivalents"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-C', null, 'Aktive afatshkurtra', '{"en":"Current assets"}'::jsonb, 70, 1, true, array['A-C-REC', 'A-C-OTH', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'A-TOT', null, 'Totali i aktiveve', '{"en":"Total assets"}'::jsonb, 80, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'E-CAP', 'E-TOT', 'Kapitali dhe rezervat', '{"en":"Capital and reserves"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'E-RET', 'E-TOT', 'Fitimi i pashpërndarë', '{"en":"Retained earnings"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'E-RESULT', 'E-TOT', 'Rezultati i periudhës, ende i pashpërndarë', '{"en":"Result for the period, not yet allocated"}'::jsonb, 105, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'E-TOT', null, 'Totali i kapitalit', '{"en":"Total equity"}'::jsonb, 110, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'L-NC', 'L-TOT', 'Detyrime afatgjata', '{"en":"Non-current liabilities"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'L-C-PAY', 'L-C', 'Detyrime tregtare dhe të tjera', '{"en":"Trade and other payables"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'L-C-OTH', 'L-C', 'Detyrime të tjera afatshkurtra', '{"en":"Other current liabilities"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'L-C', null, 'Detyrime afatshkurtra', '{"en":"Current liabilities"}'::jsonb, 150, 1, true, array['L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'L-TOT', null, 'Totali i detyrimeve', '{"en":"Total liabilities"}'::jsonb, 160, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-BS', 'EL-TOT', null, 'Totali i kapitalit dhe detyrimeve', '{"en":"Total equity and liabilities"}'::jsonb, 170, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-IS', 'REV', null, 'Të hyrat', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-IS', 'COST', null, 'Kostoja e shitjes', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-IS', 'GROSS', null, 'Fitimi bruto', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('XK-IFRS-IS', 'OTH-INC', null, 'Të hyra të tjera', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-IS', 'OPEX', null, 'Shpenzime operative', '{"en":"Operating expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-IS', 'DEPR', null, 'Zhvlerësimi dhe amortizimi', '{"en":"Depreciation and amortisation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('XK-IFRS-IS', 'PROFIT', null, 'Fitimi (humbja) i periudhës', '{"en":"Profit (loss) for the period"}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null)
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
    ('XK-IFRS-BS', 'A-NC-FIX', 10, 'code_range', '0100', '0299', null, 'any'),
    ('XK-IFRS-BS', 'A-NC-OTH', 10, 'code_range', '0300', '0399', null, 'any'),
    ('XK-IFRS-BS', 'A-C-REC', 10, 'code_range', '1100', '1130', null, 'any'),
    ('XK-IFRS-BS', 'A-C-OTH', 10, 'code_range', '1000', '1050', null, 'any'),
    ('XK-IFRS-BS', 'A-C-OTH', 20, 'code_range', '1200', '1220', null, 'any'),
    ('XK-IFRS-BS', 'A-C-OTH', 30, 'code_range', '1450', '1490', null, 'any'),
    ('XK-IFRS-BS', 'A-C-CASH', 10, 'code_range', '1300', '1330', null, 'any'),
    ('XK-IFRS-BS', 'E-CAP', 10, 'code_range', '3000', '3050', null, 'any'),
    ('XK-IFRS-BS', 'E-RET', 10, 'account_code', '3100', null, null, 'any'),
    ('XK-IFRS-BS', 'E-RESULT', 10, 'code_range', '4000', '4050', null, 'any'),
    ('XK-IFRS-BS', 'E-RESULT', 20, 'code_range', '4200', '4250', null, 'any'),
    ('XK-IFRS-BS', 'E-RESULT', 30, 'code_range', '5000', '5040', null, 'any'),
    ('XK-IFRS-BS', 'E-RESULT', 40, 'code_range', '6000', '6220', null, 'any'),
    ('XK-IFRS-BS', 'E-RESULT', 50, 'code_range', '6900', '6920', null, 'any'),
    ('XK-IFRS-BS', 'E-RESULT', 60, 'code_range', '7000', '7060', null, 'any'),
    ('XK-IFRS-BS', 'L-NC', 10, 'code_range', '2400', '2440', null, 'any'),
    ('XK-IFRS-BS', 'L-C-PAY', 10, 'code_range', '2000', '2020', null, 'any'),
    ('XK-IFRS-BS', 'L-C-OTH', 10, 'code_range', '2100', '2200', null, 'any'),
    ('XK-IFRS-BS', 'L-C-OTH', 20, 'account_code', '2250', null, null, 'any'),
    ('XK-IFRS-BS', 'L-C-OTH', 30, 'account_code', '2300', null, null, 'any'),
    ('XK-IFRS-IS', 'REV', 10, 'code_range', '4000', '4050', null, 'any'),
    ('XK-IFRS-IS', 'COST', 10, 'code_range', '5000', '5040', null, 'any'),
    ('XK-IFRS-IS', 'OTH-INC', 10, 'code_range', '4200', '4250', null, 'any'),
    ('XK-IFRS-IS', 'OPEX', 10, 'code_range', '6000', '6220', null, 'any'),
    ('XK-IFRS-IS', 'OPEX', 20, 'code_range', '7000', '7060', null, 'any'),
    ('XK-IFRS-IS', 'DEPR', 10, 'code_range', '6900', '6920', null, 'any')
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
  ('XK', 'Kosova', '{"en":"Kosovo"}'::jsonb, array['sq', 'en']::text[], 'EUR', '1100', '2000', '2300', '7060', '3100', '4000', '5000', '1310', '1300', 'SAL', 'PUR', 'GEN', 'sq', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4220', '7010', null, null, null, null, '2108', '1458', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Ligji Nr. 05/L-037 për TVSH-në, neni 45, paragrafi 1, nën-paragrafi 1.2 — fatura duhet të përmbajë „një numër rendor që mundëson identifikimin e faturës”. Ligji nuk kërkon shprehimisht që ky varg të jetë pa boshllëqe; formati këtu është një shembull renditjeje sipas serisë dhe vitit, jo forma e vetme e lejuar.',
  numbering_source_key          = 'ligji-tvsh',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ligji Nr. 05/L-037 për TVSH-në, neni 22, paragrafi 1 — ngjarja e ngarkueshme ndodh dhe TVSH-ja bëhet e ngarkueshme kur mallrat ose shërbimet furnizohen (parimi: dorëzimi). Paragrafi 3, nën-paragrafi 3.2 e vendos përjashtimin që `invoice_if_issued` mbart: kur fatura lëshohet para furnizimit, TVSH-ja bëhet e ngarkueshme në momentin e lëshimit të faturës. I njëjti paragraf 3, nën-paragrafi 3.1, parasheh një përjashtim të tretë që ky fjalor nuk e mban veçmas: kur pagesa bëhet para furnizimit, TVSH-ja bëhet e ngarkueshme në momentin e pagesës. Ky paket zgjedh `invoice_if_issued` si vlerën më të afërt të dy përjashtimeve me parimin (dorëzim/faturë), dhe e dokumenton boshllëkun e trigerit të tretë (pagesa e bërë para furnizimit) në README.md dhe në docs/international.md, seksioni «From Kosovo» — të njëjtën zgjidhje ka bërë edhe paketa e Bosnjë-Hercegovinës (packs/ba) për një strukturë të ngjashme neni-nga-neni.',
  tax_point_source_key          = 'ligji-tvsh',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ligji Nr. 05/L-037 për TVSH-në, neni 2, paragrafët 1.33 dhe 1.34 — korrigjimi i shumës së TVSH-së pas lëshimit të një fature bëhet me notë krediti ose notë debiti, kurrë duke fshirë faturën origjinale. Ligji Nr. 06/L-032 për Kontabilitet, neni 6 — dokumenti kontabël duhet të jetë autentik dhe i përgatitur në një mënyrë që siguron mbikëqyrje në kohë; korrigjimi mban gjurmë.',
  posted_edit_policy_source_key = 'ligji-tvsh',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'Kërkimi për këtë paket nuk gjeti asnjë ligj apo akt nënligjor që të detyrojë shkëmbimin e faturave elektronike të strukturuara ndërmjet subjekteve private në Kosovë, as një platformë shtetërore vërtetimi (clearance) si SEF-i serb apo e-Faktura shqiptare. Ligji Nr. 05/L-037 për TVSH-në, neni 44, paragrafi 1 lejon që fatura t''i dërgohet blerësit „me mjete elektronike”, me kusht që të ketë pëlqimin e blerësit dhe autenticiteti e integriteti i përmbajtjes të garantohen — kjo është leje (`on_request`-like), jo detyrim mbi një profil të ndërtuar mbi modelin semantik të EN 16931. Ligji parasheh në vend të kësaj **Pajisjen Elektronike Fiskale (PEF)** (neni 2, paragrafi 1.17) — arka fiskale të licencuara nga Ministria e Financave — për regjistrimin dhe lëshimin e kuponëve fiskal të shitjeve me pakicë; kjo është një mekanizëm tjetër (arkë fiskale me kupon, jo faturë e strukturuar e shkëmbyer mes palëve) që socle-ja e Ekwo-s nuk e ka të përfaqësuar sot. Shih README.md dhe docs/international.md, seksioni «From Kosovo».',
  einvoice_source_key           = 'ligji-tvsh',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'XK';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('XK', 'reverse_charge', 'reverse_charge', 'TVSH-ja llogaritet dhe paguhet nga pranuesi i shërbimit, në pajtim me nenin 52, paragrafi 1, nën-paragrafi 1.2 i Ligjit Nr. 05/L-037 për Tatimin mbi Vlerën e Shtuar.', '{"en":"VAT is accounted for and paid by the recipient of the service, in accordance with article 52, paragraph 1, sub-paragraph 1.2 of Law No. 05/L-037 on Value Added Tax."}'::jsonb, 10, date '1970-01-01', null, 'Ligji Nr. 05/L-037 për TVSH-në, neni 52, paragrafi 1, nën-paragrafi 1.2 — personi i regjistruar për TVSH në Kosovë të cilit i janë furnizuar mallra ose shërbime nga një person i tatueshëm i pathemeluar në Kosovë, kur vendi i furnizimit konsiderohet Kosova, është vetë i obliguar për të paguar TVSH-në.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
