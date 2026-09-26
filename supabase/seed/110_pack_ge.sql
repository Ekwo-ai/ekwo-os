-- Ekwo OS — საქართველო: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ge at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ge`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   საქართველოს საგადასახადო კოდექსი (Tax Code of Georgia), მუხლები 156-211 — დამატებული ღირებულების გადასახადი (VAT); მუხლები 84-93 — მცირე და მიკრო ბიზნესის სტატუსი (საქართველოს საკანონმდებლო მაცნე (Legislative Herald of Georgia) — matsne.gov.ge)
--     https://matsne.gov.ge/en/document/view/1043717
--   საქართველოს ფინანსთა მინისტრის 2007 წლის 11 სექტემბრის №1048 ბრძანება „დამატებული ღირებულების გადასახადის დეკლარაციის ფორმისა და მისი შევსების წესის შესახებ ინსტრუქციის დამტკიცების თაობაზე“ (საქართველოს ფინანსთა სამინისტრო — matsne.gov.ge)
--     https://matsne.gov.ge/ka/document/view/72874
--   საქართველოს ფინანსთა მინისტრის 2005 წლის 14 თებერვლის №84 ბრძანება „საგადასახადო ანგარიშ-ფაქტურის (მათ შორის, კორექტირების) გამოწერისა და წარდგენის შესახებ ინსტრუქციის დამტკიცების თაობაზე“ (საქართველოს ფინანსთა სამინისტრო — matsne.gov.ge)
--     https://matsne.gov.ge/ka/document/view/59554
--   ელექტრონული საგადასახადო ანგარიშ-ფაქტურის მონაცემთა გაცვლის ოქმი (Electronic Data Exchange Protocol — electronic tax invoice) (შემოსავლების სამსახური (Revenue Service of Georgia))
--     https://eservices.rs.ge/Docs/invoice-protocol.pdf
--   შემოსავლების სამსახურის ელექტრონული კაბინეტი — დღგ-ის დეკლარაციისა და საგადასახადო ანგარიშ-ფაქტურის წარდგენა (შემოსავლების სამსახური (Revenue Service of Georgia))
--     https://www.rs.ge/
--   საქართველოს კანონი ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის შესახებ (Law of Georgia on Accounting, Reporting and Auditing), №5386, 2016 წლის 8 ივნისი (საქართველოს საკანონმდებლო მაცნე — matsne.gov.ge)
--     https://matsne.gov.ge/en/document/view/3311504
--   IFRS for SMEs Accounting Standard (IFRS Foundation)
--     https://www.ifrs.org/issued-standards/ifrs-for-smes-accounting-standard/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GE', 'საქართველო', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'eaa8e62489edc1f8adfdf2eb0b35ca74e1bd1adc18afde67ecca41636f19d66f', '[{"key":"tax-code","title":"საქართველოს საგადასახადო კოდექსი (Tax Code of Georgia), მუხლები 156-211 — დამატებული ღირებულების გადასახადი (VAT); მუხლები 84-93 — მცირე და მიკრო ბიზნესის სტატუსი","publisher":"საქართველოს საკანონმდებლო მაცნე (Legislative Herald of Georgia) — matsne.gov.ge","url":"https://matsne.gov.ge/en/document/view/1043717","consulted_on":"2026-09-26","kind":"law"},{"key":"vat-return-order","title":"საქართველოს ფინანსთა მინისტრის 2007 წლის 11 სექტემბრის №1048 ბრძანება „დამატებული ღირებულების გადასახადის დეკლარაციის ფორმისა და მისი შევსების წესის შესახებ ინსტრუქციის დამტკიცების თაობაზე“","publisher":"საქართველოს ფინანსთა სამინისტრო — matsne.gov.ge","url":"https://matsne.gov.ge/ka/document/view/72874","consulted_on":"2026-09-26","kind":"form"},{"key":"tax-invoice-order","title":"საქართველოს ფინანსთა მინისტრის 2005 წლის 14 თებერვლის №84 ბრძანება „საგადასახადო ანგარიშ-ფაქტურის (მათ შორის, კორექტირების) გამოწერისა და წარდგენის შესახებ ინსტრუქციის დამტკიცების თაობაზე“","publisher":"საქართველოს ფინანსთა სამინისტრო — matsne.gov.ge","url":"https://matsne.gov.ge/ka/document/view/59554","consulted_on":"2026-09-26","kind":"regulation"},{"key":"rs-invoice-protocol","title":"ელექტრონული საგადასახადო ანგარიშ-ფაქტურის მონაცემთა გაცვლის ოქმი (Electronic Data Exchange Protocol — electronic tax invoice)","publisher":"შემოსავლების სამსახური (Revenue Service of Georgia)","url":"https://eservices.rs.ge/Docs/invoice-protocol.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"rs-portal","title":"შემოსავლების სამსახურის ელექტრონული კაბინეტი — დღგ-ის დეკლარაციისა და საგადასახადო ანგარიშ-ფაქტურის წარდგენა","publisher":"შემოსავლების სამსახური (Revenue Service of Georgia)","url":"https://www.rs.ge/","consulted_on":"2026-09-26","kind":"portal"},{"key":"accounting-law","title":"საქართველოს კანონი ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის შესახებ (Law of Georgia on Accounting, Reporting and Auditing), №5386, 2016 წლის 8 ივნისი","publisher":"საქართველოს საკანონმდებლო მაცნე — matsne.gov.ge","url":"https://matsne.gov.ge/en/document/view/3311504","consulted_on":"2026-09-26","kind":"law"},{"key":"ifrs-sme","title":"IFRS for SMEs Accounting Standard","publisher":"IFRS Foundation","url":"https://www.ifrs.org/issued-standards/ifrs-for-smes-accounting-standard/","consulted_on":"2026-09-26","kind":"standard"}]'::jsonb)
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
  ('GE', 'default', 'IFRS-ზე დაფუძნებული ანგარიშთა გეგმა (არალეგალიზებული)', '{"en":"IFRS-inspired chart of accounts (not a statutory chart)"}'::jsonb, true, 'companies', array['GE-IFRS-BS', 'GE-IFRS-IS']::text[], null, 'საქართველოს კანონი ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის შესახებ, მუხლი 2 და მუხლი 7 — კანონი ადგენს ანგარიშგების სტანდარტებს (IFRS, IFRS for SMEs, სსიპ ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის ზედამხედველობის სამსახურის მიერ დამტკიცებული სტანდარტები) კატეგორიის მიხედვით, მაგრამ არ ადგენს სავალდებულო ანგარიშთა გეგმას (ბუღალტრული ანგარიშების ნუსხას) კონკრეტული კოდებით — ეს პაკეტი გვთავაზობს IFRS-ის საერთაშორისო ტერმინოლოგიაზე დაფუძნებულ ანგარიშთა გეგმას ქართული და ინგლისური სახელწოდებებით, არა კანონით დამტკიცებულს; იხ. README.md.', 'accounting-law')
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
  ('GE', 'default', '0100', 'გუდვილი', '{"en":"Goodwill"}'::jsonb, 'asset_fixed', false, null, 10),
  ('GE', 'default', '0101', 'გუდვილი — დაგროვილი ამორტიზაცია', '{"en":"Goodwill — accumulated amortisation"}'::jsonb, 'asset_fixed', false, null, 20),
  ('GE', 'default', '0110', 'პროგრამული უზრუნველყოფა და სხვა არამატერიალური აქტივები', '{"en":"Software and other intangible assets"}'::jsonb, 'asset_fixed', false, null, 30),
  ('GE', 'default', '0111', 'პროგრამული უზრუნველყოფა — დაგროვილი ამორტიზაცია', '{"en":"Software — accumulated amortisation"}'::jsonb, 'asset_fixed', false, null, 40),
  ('GE', 'default', '0120', 'კვლევისა და განვითარების კაპიტალიზებული ხარჯები', '{"en":"Capitalised research and development costs"}'::jsonb, 'asset_fixed', false, null, 50),
  ('GE', 'default', '0121', 'კვლევისა და განვითარების ხარჯები — დაგროვილი ამორტიზაცია', '{"en":"Research and development costs — accumulated amortisation"}'::jsonb, 'asset_fixed', false, null, 60),
  ('GE', 'default', '0200', 'მიწის ნაკვეთები', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 70),
  ('GE', 'default', '0210', 'შენობა-ნაგებობები', '{"en":"Buildings and structures"}'::jsonb, 'asset_fixed', false, null, 80),
  ('GE', 'default', '0211', 'შენობა-ნაგებობები — დაგროვილი ცვეთა', '{"en":"Buildings and structures — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 90),
  ('GE', 'default', '0220', 'მანქანა-დანადგარები', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 100),
  ('GE', 'default', '0221', 'მანქანა-დანადგარები — დაგროვილი ცვეთა', '{"en":"Machinery and equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 110),
  ('GE', 'default', '0230', 'სატრანსპორტო საშუალებები', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, null, 120),
  ('GE', 'default', '0231', 'სატრანსპორტო საშუალებები — დაგროვილი ცვეთა', '{"en":"Vehicles — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 130),
  ('GE', 'default', '0240', 'ავეჯი და საოფისე ინვენტარი', '{"en":"Furniture and office equipment"}'::jsonb, 'asset_fixed', false, null, 140),
  ('GE', 'default', '0241', 'ავეჯი და საოფისე ინვენტარი — დაგროვილი ცვეთა', '{"en":"Furniture and office equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 150),
  ('GE', 'default', '0250', 'კომპიუტერული ტექნიკა', '{"en":"Computer equipment"}'::jsonb, 'asset_fixed', false, null, 160),
  ('GE', 'default', '0251', 'კომპიუტერული ტექნიკა — დაგროვილი ცვეთა', '{"en":"Computer equipment — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 170),
  ('GE', 'default', '0260', 'დაუმთავრებელი მშენებლობა და მიმდინარე კაპიტალური დაბანდებები', '{"en":"Construction in progress and capital work in progress"}'::jsonb, 'asset_fixed', false, null, 180),
  ('GE', 'default', '0270', 'საიჯარო ქონების გაუმჯობესება', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 190),
  ('GE', 'default', '0271', 'საიჯარო ქონების გაუმჯობესება — დაგროვილი ცვეთა', '{"en":"Leasehold improvements — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 200),
  ('GE', 'default', '0280', 'გამოსაყენებლად უფლების აქტივი (იჯარა)', '{"en":"Right-of-use asset (lease)"}'::jsonb, 'asset_fixed', false, null, 210),
  ('GE', 'default', '0281', 'გამოსაყენებლად უფლების აქტივი — დაგროვილი ცვეთა', '{"en":"Right-of-use asset — accumulated depreciation"}'::jsonb, 'asset_fixed', false, null, 220),
  ('GE', 'default', '0300', 'გრძელვადიანი ფინანსური ინვესტიციები', '{"en":"Long-term financial investments"}'::jsonb, 'asset_non_current', false, null, 230),
  ('GE', 'default', '0310', 'შვილობილი და ასოცირებული საწარმოების წილები', '{"en":"Investments in subsidiaries and associates"}'::jsonb, 'asset_non_current', false, null, 240),
  ('GE', 'default', '0320', 'სხვა საწარმოებისთვის გაცემული გრძელვადიანი სესხები', '{"en":"Long-term loans granted to other entities"}'::jsonb, 'asset_non_current', false, null, 250),
  ('GE', 'default', '0330', 'გადავადებული საგადასახადო აქტივი', '{"en":"Deferred tax asset"}'::jsonb, 'asset_non_current', false, null, 260),
  ('GE', 'default', '0340', 'გრძელვადიანი დებიტორული დავალიანება', '{"en":"Long-term receivables"}'::jsonb, 'asset_non_current', false, null, 270),
  ('GE', 'default', '0350', 'საინვესტიციო ქონება', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, null, 280),
  ('GE', 'default', '1000', 'ნედლეული და მასალები', '{"en":"Raw materials and supplies"}'::jsonb, 'asset_current', false, null, 290),
  ('GE', 'default', '1010', 'დაუმთავრებელი წარმოება', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 300),
  ('GE', 'default', '1020', 'მზა პროდუქცია', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 310),
  ('GE', 'default', '1030', 'სასაქონლო მარაგები', '{"en":"Goods held for resale"}'::jsonb, 'asset_current', false, null, 320),
  ('GE', 'default', '1040', 'გზაში (გადაუზიდავი) საქონელი', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 330),
  ('GE', 'default', '1050', 'მცირეფასიანი და სწრაფცვეთადი საგნები', '{"en":"Low-value and fast-wearing items"}'::jsonb, 'asset_current', false, null, 340),
  ('GE', 'default', '1100', 'მყიდველთა და შემკვეთთა დებიტორული დავალიანება', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 350),
  ('GE', 'default', '1110', 'საეჭვო ვალების რეზერვი', '{"en":"Allowance for doubtful debts"}'::jsonb, 'asset_receivable', true, null, 360),
  ('GE', 'default', '1120', 'სხვა დებიტორული დავალიანება', '{"en":"Other receivables"}'::jsonb, 'asset_receivable', true, null, 370),
  ('GE', 'default', '1130', 'დაკავშირებულ მხარეებთან დებიტორული დავალიანება', '{"en":"Receivables from related parties"}'::jsonb, 'asset_receivable', true, null, 380),
  ('GE', 'default', '1200', 'მომწოდებლებზე გაცემული ავანსები', '{"en":"Advances paid to suppliers"}'::jsonb, 'asset_prepayments', false, null, 390),
  ('GE', 'default', '1210', 'მომავალი პერიოდის წინასწარგადახდილი ხარჯები', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 400),
  ('GE', 'default', '1220', 'დაზღვევის წინასწარგადახდილი პრემია', '{"en":"Prepaid insurance premium"}'::jsonb, 'asset_prepayments', false, null, 410),
  ('GE', 'default', '1300', 'სალაროში ნაღდი ფული', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 420),
  ('GE', 'default', '1310', 'საბანკო ანგარიშები ლარში', '{"en":"Bank accounts in GEL"}'::jsonb, 'asset_cash', false, null, 430),
  ('GE', 'default', '1320', 'საბანკო ანგარიშები უცხოურ ვალუტაში', '{"en":"Bank accounts in foreign currency"}'::jsonb, 'asset_cash', false, null, 440),
  ('GE', 'default', '1330', 'ინკასაციაში (გზაში) ფულადი სახსრები', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 450),
  ('GE', 'default', '1450', 'ჩასათვლელი დღგ შესყიდვებზე', '{"en":"VAT recoverable on purchases"}'::jsonb, 'asset_current', false, null, 460),
  ('GE', 'default', '1451', 'ბიუჯეტთან ანგარიშსწორება — შესამცირებელი (მისაღები) დღგ', '{"en":"VAT settlement with the budget, receivable"}'::jsonb, 'asset_current', true, null, 470),
  ('GE', 'default', '1460', 'ბიუჯეტთან ანგარიშსწორება — სხვა გადასახადები', '{"en":"Settlement with the budget — other taxes"}'::jsonb, 'asset_current', false, null, 480),
  ('GE', 'default', '1470', 'თანამშრომლებზე გაცემული ანგარიშვალდებული თანხები', '{"en":"Advances to employees (accountable amounts)"}'::jsonb, 'asset_current', false, null, 490),
  ('GE', 'default', '1480', 'მოკლევადიანი ფინანსური ინვესტიციები', '{"en":"Short-term financial investments"}'::jsonb, 'asset_current', false, null, 500),
  ('GE', 'default', '1490', 'სხვა მიმდინარე აქტივები', '{"en":"Other current assets"}'::jsonb, 'asset_current', false, null, 510),
  ('GE', 'default', '2000', 'მომწოდებელთა და კრედიტორთა დავალიანება', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 520),
  ('GE', 'default', '2010', 'დაკავშირებულ მხარეებთან კრედიტორული დავალიანება', '{"en":"Payables to related parties"}'::jsonb, 'liability_payable', true, null, 530),
  ('GE', 'default', '2020', 'მყიდველებისგან მიღებული ავანსები', '{"en":"Advances received from customers"}'::jsonb, 'liability_payable', true, null, 540),
  ('GE', 'default', '2100', 'დარიცხული დღგ რეალიზაციაზე', '{"en":"VAT charged on sales"}'::jsonb, 'liability_current', false, null, 550),
  ('GE', 'default', '2110', 'ბიუჯეტთან ანგარიშსწორება — გადასახდელი დღგ', '{"en":"VAT settlement with the budget, payable"}'::jsonb, 'liability_current', true, null, 560),
  ('GE', 'default', '2120', 'მოგების გადასახადის ვალდებულება', '{"en":"Corporate income tax liability"}'::jsonb, 'liability_current', false, null, 570),
  ('GE', 'default', '2130', 'ხელფასის ვალდებულება პერსონალის წინაშე', '{"en":"Payroll payable"}'::jsonb, 'liability_current', false, null, 580),
  ('GE', 'default', '2140', 'საშემოსავლო გადასახადისა და სავალდებულო გადასახდელების ვალდებულება', '{"en":"Personal income tax and mandatory social payments payable"}'::jsonb, 'liability_current', false, null, 590),
  ('GE', 'default', '2150', 'მოკლევადიანი დარიცხული ხარჯები', '{"en":"Short-term accrued liabilities"}'::jsonb, 'liability_current', false, null, 600),
  ('GE', 'default', '2160', 'მოკლევადიანი სესხები და კრედიტები', '{"en":"Short-term loans and borrowings"}'::jsonb, 'liability_current', false, null, 610),
  ('GE', 'default', '2170', 'მოკლევადიანი საიჯარო ვალდებულება', '{"en":"Short-term lease liability"}'::jsonb, 'liability_current', false, null, 620),
  ('GE', 'default', '2180', 'დივიდენდების ვალდებულება', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 630),
  ('GE', 'default', '2190', 'მოკლევადიანი რეზერვები (ვალდებულებები)', '{"en":"Short-term provisions"}'::jsonb, 'liability_current', false, null, 640),
  ('GE', 'default', '2200', 'სხვა მიმდინარე ვალდებულებები', '{"en":"Other current liabilities"}'::jsonb, 'liability_current', false, null, 650),
  ('GE', 'default', '2250', 'საკრედიტო ბარათით ვალდებულება', '{"en":"Credit card liability"}'::jsonb, 'liability_credit_card', false, null, 660),
  ('GE', 'default', '2300', 'გაურკვეველი შემოსულობებისა და გადახდების ანგარიში', '{"en":"Suspense account (amounts pending clarification)"}'::jsonb, 'liability_current', false, null, 670),
  ('GE', 'default', '2400', 'გრძელვადიანი სესხები და კრედიტები', '{"en":"Long-term loans and borrowings"}'::jsonb, 'liability_non_current', false, null, 680),
  ('GE', 'default', '2410', 'გრძელვადიანი საიჯარო ვალდებულება', '{"en":"Long-term lease liability"}'::jsonb, 'liability_non_current', false, null, 690),
  ('GE', 'default', '2420', 'გადავადებული საგადასახადო ვალდებულება', '{"en":"Deferred tax liability"}'::jsonb, 'liability_non_current', false, null, 700),
  ('GE', 'default', '2430', 'გრძელვადიანი რეზერვები (საპენსიო და სხვა)', '{"en":"Long-term provisions (pension and other)"}'::jsonb, 'liability_non_current', false, null, 710),
  ('GE', 'default', '2440', 'გრძელვადიანი ობლიგაციები', '{"en":"Long-term bonds payable"}'::jsonb, 'liability_non_current', false, null, 720),
  ('GE', 'default', '3000', 'საწესდებო კაპიტალი', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 730),
  ('GE', 'default', '3010', 'საემისიო კაპიტალი (პრემია)', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 740),
  ('GE', 'default', '3020', 'გამოსყიდული საკუთარი კაპიტალის ინსტრუმენტები', '{"en":"Treasury shares"}'::jsonb, 'equity', false, null, 750),
  ('GE', 'default', '3030', 'გადაფასების რეზერვი', '{"en":"Revaluation reserve"}'::jsonb, 'equity', false, null, 760),
  ('GE', 'default', '3040', 'სხვა სარეზერვო კაპიტალი', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 770),
  ('GE', 'default', '3050', 'უცხოური ოპერაციების თარგმნის რეზერვი', '{"en":"Foreign currency translation reserve"}'::jsonb, 'equity', false, null, 780),
  ('GE', 'default', '3100', 'გაუნაწილებელი მოგება (დაუფარავი ზარალი)', '{"en":"Retained earnings (accumulated losses)"}'::jsonb, 'equity_retained', false, null, 790),
  ('GE', 'default', '4000', 'საქონლის რეალიზაციიდან შემოსავალი', '{"en":"Revenue from sale of goods"}'::jsonb, 'income', false, null, 800),
  ('GE', 'default', '4010', 'მომსახურების გაწევიდან შემოსავალი', '{"en":"Revenue from rendering of services"}'::jsonb, 'income', false, null, 810),
  ('GE', 'default', '4020', 'ექსპორტიდან მიღებული შემოსავალი', '{"en":"Revenue from exports"}'::jsonb, 'income', false, null, 820),
  ('GE', 'default', '4030', 'გაყიდვის ფასდაკლებები და დაბრუნებები', '{"en":"Sales discounts and returns"}'::jsonb, 'income', false, null, 830),
  ('GE', 'default', '4040', 'სამშენებლო კონტრაქტების შემოსავალი', '{"en":"Revenue from construction contracts"}'::jsonb, 'income', false, null, 840),
  ('GE', 'default', '4050', 'იჯარიდან მიღებული შემოსავალი', '{"en":"Revenue from leases"}'::jsonb, 'income', false, null, 850),
  ('GE', 'default', '4200', 'საპროცენტო შემოსავალი', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 860),
  ('GE', 'default', '4210', 'დივიდენდის სახით მიღებული შემოსავალი', '{"en":"Dividend income"}'::jsonb, 'income_other', false, null, 870),
  ('GE', 'default', '4220', 'კურსთაშორისი სხვაობით მიღებული მოგება', '{"en":"Foreign exchange gain"}'::jsonb, 'income_other', false, null, 880),
  ('GE', 'default', '4230', 'ძირითადი საშუალებების რეალიზაციით მიღებული მოგება', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 890),
  ('GE', 'default', '4240', 'სახელმწიფო გრანტებიდან და სუბსიდიებიდან შემოსავალი', '{"en":"Government grants and subsidies income"}'::jsonb, 'income_other', false, null, 900),
  ('GE', 'default', '4250', 'სხვა საოპერაციო შემოსავალი', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 910),
  ('GE', 'default', '5000', 'რეალიზებული საქონლის თვითღირებულება', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 920),
  ('GE', 'default', '5010', 'დახარჯული ნედლეულისა და მასალების ღირებულება', '{"en":"Cost of raw materials and supplies used"}'::jsonb, 'expense_direct_cost', false, null, 930),
  ('GE', 'default', '5020', 'პირდაპირი შრომითი ხარჯები წარმოებაზე', '{"en":"Direct labour costs (production)"}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('GE', 'default', '5030', 'საწარმოო ზედნადები ხარჯები', '{"en":"Manufacturing overheads"}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('GE', 'default', '5040', 'ტრანსპორტირების ხარჯი შესყიდვებზე', '{"en":"Freight-in on purchases"}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('GE', 'default', '6000', 'ხელფასები და დანამატები', '{"en":"Salaries and wages"}'::jsonb, 'expense', false, null, 970),
  ('GE', 'default', '6010', 'სოციალური დაზღვევის ხარჯები (დამქირავებელი)', '{"en":"Employer social contributions"}'::jsonb, 'expense', false, null, 980),
  ('GE', 'default', '6020', 'ქირავნობის ხარჯი', '{"en":"Rent expense"}'::jsonb, 'expense', false, null, 990),
  ('GE', 'default', '6030', 'კომუნალური მომსახურების ხარჯი', '{"en":"Utilities expense"}'::jsonb, 'expense', false, null, 1000),
  ('GE', 'default', '6040', 'საკანცელარიო და საოფისე ხარჯები', '{"en":"Office and stationery expenses"}'::jsonb, 'expense', false, null, 1010),
  ('GE', 'default', '6050', 'საკომუნიკაციო ხარჯები', '{"en":"Communication expenses"}'::jsonb, 'expense', false, null, 1020),
  ('GE', 'default', '6060', 'პროფესიული და საკონსულტაციო მომსახურების ხარჯი', '{"en":"Professional and consulting fees"}'::jsonb, 'expense', false, null, 1030),
  ('GE', 'default', '6070', 'მარკეტინგისა და რეკლამის ხარჯი', '{"en":"Marketing and advertising expense"}'::jsonb, 'expense', false, null, 1040),
  ('GE', 'default', '6080', 'მივლინების ხარჯები', '{"en":"Travel expenses"}'::jsonb, 'expense', false, null, 1050),
  ('GE', 'default', '6090', 'დაზღვევის ხარჯი', '{"en":"Insurance expense"}'::jsonb, 'expense', false, null, 1060),
  ('GE', 'default', '6100', 'რემონტისა და მოვლის ხარჯი', '{"en":"Repairs and maintenance expense"}'::jsonb, 'expense', false, null, 1070),
  ('GE', 'default', '6110', 'საბანკო მომსახურების საკომისიო ხარჯი', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 1080),
  ('GE', 'default', '6120', 'მოკლევადიანი იჯარისა და მცირე აქტივების ხარჯი', '{"en":"Short-term lease and low-value asset expense"}'::jsonb, 'expense', false, null, 1090),
  ('GE', 'default', '6130', 'უიმედო და საეჭვო ვალების ხარჯი', '{"en":"Bad and doubtful debt expense"}'::jsonb, 'expense', false, null, 1100),
  ('GE', 'default', '6140', 'წარმომადგენლობითი ხარჯები', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 1110),
  ('GE', 'default', '6150', 'ტრენინგისა და პერსონალის განვითარების ხარჯი', '{"en":"Training and staff development expense"}'::jsonb, 'expense', false, null, 1120),
  ('GE', 'default', '6160', 'დაცვისა და უსაფრთხოების ხარჯი', '{"en":"Security expense"}'::jsonb, 'expense', false, null, 1130),
  ('GE', 'default', '6170', 'საწვავისა და ავტოპარკის საექსპლუატაციო ხარჯი', '{"en":"Fuel and vehicle running costs"}'::jsonb, 'expense', false, null, 1140),
  ('GE', 'default', '6180', 'ლიცენზიისა და საიჯარო საფასურები და ბაჟები', '{"en":"Licence and lease fees and duties"}'::jsonb, 'expense', false, null, 1150),
  ('GE', 'default', '6190', 'შემოწირულობები და საქველმოქმედო ხარჯები', '{"en":"Donations and charitable expenses"}'::jsonb, 'expense', false, null, 1160),
  ('GE', 'default', '6200', 'სხვა ადმინისტრაციული ხარჯები', '{"en":"Other administrative expenses"}'::jsonb, 'expense', false, null, 1170),
  ('GE', 'default', '6210', 'სადაზღვევო რეზერვების ხარჯი', '{"en":"Insurance reserves expense"}'::jsonb, 'expense', false, null, 1180),
  ('GE', 'default', '6220', 'არაკაპიტალიზებული კვლევისა და განვითარების ხარჯი', '{"en":"Research and development expense (not capitalised)"}'::jsonb, 'expense', false, null, 1190),
  ('GE', 'default', '6900', 'ძირითადი საშუალებების ცვეთის ხარჯი', '{"en":"Depreciation of property, plant and equipment"}'::jsonb, 'expense_depreciation', false, null, 1200),
  ('GE', 'default', '6910', 'არამატერიალური აქტივების ამორტიზაციის ხარჯი', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, null, 1210),
  ('GE', 'default', '6920', 'გამოსაყენებლად უფლების აქტივის ცვეთის ხარჯი', '{"en":"Depreciation of right-of-use assets"}'::jsonb, 'expense_depreciation', false, null, 1220),
  ('GE', 'default', '7000', 'საპროცენტო ხარჯი სესხებზე', '{"en":"Interest expense on borrowings"}'::jsonb, 'expense', false, null, 1230),
  ('GE', 'default', '7010', 'კურსთაშორისი სხვაობით მიღებული ზარალი', '{"en":"Foreign exchange loss"}'::jsonb, 'expense', false, null, 1240),
  ('GE', 'default', '7020', 'ძირითადი საშუალებების რეალიზაციით მიღებული ზარალი', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1250),
  ('GE', 'default', '7030', 'მოგების გადასახადის ხარჯი', '{"en":"Corporate income tax expense"}'::jsonb, 'expense', false, null, 1260),
  ('GE', 'default', '7040', 'ჯარიმები და საურავები', '{"en":"Fines and penalties"}'::jsonb, 'expense', false, null, 1270),
  ('GE', 'default', '7050', 'სხვა არასაოპერაციო ხარჯი', '{"en":"Other non-operating expense"}'::jsonb, 'expense', false, null, 1280),
  ('GE', 'default', '7060', 'დამრგვალების სხვაობა', '{"en":"Rounding difference"}'::jsonb, 'expense', false, null, 1290),
  ('GE', 'default', '9000', 'მოიჯარის ბალანსგარეშე იჯარით აღებული აქტივები', '{"en":"Assets held under lease (off-balance)"}'::jsonb, 'off_balance', false, null, 1300),
  ('GE', 'default', '9010', 'პასუხისმგებლობაზე მიღებული სასაქონლო-მატერიალური ფასეულობები', '{"en":"Inventory held on behalf of third parties"}'::jsonb, 'off_balance', false, null, 1310),
  ('GE', 'default', '9020', 'გაცემული გარანტიები და თავდებობები', '{"en":"Guarantees and sureties given"}'::jsonb, 'off_balance', false, null, 1320)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GE', 'BNK', 'საბანკო ჟურნალი', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('GE', 'CSH', 'სალაროს ჟურნალი', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('GE', 'GEN', 'ზოგადი ჟურნალი', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('GE', 'OPN', 'გახსნის ჟურნალი', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('GE', 'PUR', 'შესყიდვების ჟურნალი', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('GE', 'SAL', 'გაყიდვების ჟურნალი', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('GE', 'GE-P-18', 'დღგ 18 % — შესყიდვა საქართველოს ტერიტორიაზე (ადგილობრივი მომწოდებელი)', '{"en":"VAT 18% — purchase in Georgia (local supplier)"}'::jsonb, null, 'percent', 18, 'purchase', 'domestic', date '2011-01-01', null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 173 და მუხლი 174, პირველი ნაწილის „ა“ ქვეპუნქტი — ჩასათვლელი დღგ-ის თანხაა გადამხდელის მიერ გადახდილი ან გადასახდელი დღგ, ჩათვლის დოკუმენტების (საგადასახადო ანგარიშ-ფაქტურის) საფუძველზე.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('GE', 'GE-P-IMPORT', 'დღგ 18 % — საქონლის იმპორტი (საბაჟო ოპერაცია)', '{"en":"VAT 18% — import of goods (customs operation)"}'::jsonb, null, 'percent', 18, 'purchase', 'import', date '2011-01-01', null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 162 — იმპორტის დროს დასაბეგრი თანხის განსაზღვრა; მუხლი 171, მე-3 ნაწილი — იმპორტის დროს დღგ-ის თანხის გადახდა ხდება საიმპორტო გადასახდელების გადახდის წესით (საბაჟო დეკლარაციის საფუძველზე); მუხლი 173, მე-2 ნაწილის „ბ“ ქვეპუნქტი და მუხლი 174, პირველი ნაწილის „ა“ ქვეპუნქტი — ჩათვლის დოკუმენტია საბაჟო დეკლარაცია.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('GE', 'GE-S-18', 'დღგ 18 % — მიწოდება საქართველოს ტერიტორიაზე (გაყიდვა)', '{"en":"VAT 18% — supply in Georgia (sale)"}'::jsonb, null, 'percent', 18, 'sale', 'domestic', date '2011-01-01', null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 169, პირველი ნაწილის „ა“ ქვეპუნქტი — დღგ-ის განაკვეთია დასაბეგრი ბრუნვის ან დასაბეგრი იმპორტის თანხის 18 პროცენტი.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('GE', 'GE-S-EXEMPT', 'დღგ-სგან გათავისუფლებული მიწოდება (ჩათვლის უფლების გარეშე)', '{"en":"VAT exempt — without the right to deduct"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2011-01-01', null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 168, მე-2 ნაწილის „ა“ ქვეპუნქტი (საფინანსო ოპერაციები და მომსახურება) და „ე“ ქვეპუნქტი (სამედიცინო მომსახურება) — ეს ოპერაციები დღგ-სგან გათავისუფლებულია ჩათვლის უფლების გარეშე (მუხლი 167, მე-3 ნაწილი): გამყიდველი ვერ ითვლის ამ ბრუნვასთან დაკავშირებულ შესყიდვების დღგ-ს (მუხლი 174, მე-6 და მე-7 ნაწილები — შერეული ბრუნვის შემთხვევაში პროპორციული განაწილება).', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('GE', 'GE-S-EXPORT', 'დღგ 0 % — საქონლის ექსპორტი', '{"en":"VAT 0% — export of goods"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2011-01-01', null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 168, მე-4 ნაწილის „ა“ ქვეპუნქტი — დღგ-სგან გათავისუფლებულია, დაბრუნების უფლებით, საქონლის რეექსპორტი ან ექსპორტი მხოლოდ იმ საანგარიშო პერიოდისთვის, რომელშიც შეტანილია საქონლის რეექსპორტის ან ექსპორტის დეკლარაცია; მუხლი 169, მე-2 ნაწილი — დასაბეგრი ბრუნვა მოიცავს საანგარიშო პერიოდში განხორციელებულ საქონლის ექსპორტსა და რეექსპორტსაც.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null)
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
    ('GE-P-18', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GE-P-18', 'invoice', 'tax', 100, '1450', '9', array['9']::text[], 100, 'GE-VAT-MONTHLY', 20),
    ('GE-P-18', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GE-P-18', 'credit_note', 'tax', 100, '1450', '9', array['9']::text[], -100, 'GE-VAT-MONTHLY', 20),
    ('GE-P-IMPORT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('GE-P-IMPORT', 'invoice', 'tax', 100, '1450', '10', array['10']::text[], 100, 'GE-VAT-MONTHLY', 20),
    ('GE-P-IMPORT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('GE-P-IMPORT', 'credit_note', 'tax', 100, '1450', '10', array['10']::text[], -100, 'GE-VAT-MONTHLY', 20),
    ('GE-S-18', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'GE-VAT-MONTHLY', 10),
    ('GE-S-18', 'invoice', 'tax', 100, '2100', '1', array['1']::text[], 100, 'GE-VAT-MONTHLY', 20),
    ('GE-S-18', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'GE-VAT-MONTHLY', 10),
    ('GE-S-18', 'credit_note', 'tax', 100, '2100', '1', array['1']::text[], -100, 'GE-VAT-MONTHLY', 20),
    ('GE-S-EXEMPT', 'invoice', 'base', 100, null, '5', array['5']::text[], 100, 'GE-VAT-MONTHLY', 10),
    ('GE-S-EXEMPT', 'credit_note', 'base', 100, null, '5', array['5']::text[], -100, 'GE-VAT-MONTHLY', 10),
    ('GE-S-EXPORT', 'invoice', 'base', 100, null, '3', array['3']::text[], 100, 'GE-VAT-MONTHLY', 10),
    ('GE-S-EXPORT', 'credit_note', 'base', 100, null, '3', array['3']::text[], -100, 'GE-VAT-MONTHLY', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GE' and t.code = v.tax_code
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
  ('GE', 'GE-VAT-MONTHLY', 'დამატებული ღირებულების გადასახადის დეკლარაცია', array['month']::declaration_period[], 'month'::declaration_period, date '2026-01-01', null, 'საქართველოს ფინანსთა მინისტრის 2007 წლის 11 სექტემბრის №1048 ბრძანება, დანართი №1 — დამატებული ღირებულების გადასახადის დეკლარაციის ფორმა; საქართველოს საგადასახადო კოდექსი, მუხლი 172 — დღგ-ის საანგარიშო პერიოდია კალენდარული თვე ყველა გადამხდელისთვის. ეს პაკეტი აღწერს დეკლარაციის იმ ხაზებს, რომლებზეც პაკეტის საკუთარი გადასახადები აღწევს: III განაყოფის 1-ლი ხაზი (დარიცხული დღგ), მე-2 ხაზი (18 %-იანი ბრუნვა), მე-3 ხაზი (ნულოვანი განაკვეთით დასაბეგრი ბრუნვა), მე-5 ხაზი (დღგ-სგან გათავისუფლებული ბრუნვა), მე-9 და მე-10 ხაზები (ჩასათვლელი დღგ ადგილობრივ მომწოდებლებზე და საბაჟო ოპერაციებზე) და შემაჯამებელი მე-8, მე-16, მე-17, მე-18 და მე-19 ხაზები. მე-4, მე-6, მე-7 ხაზები (არადასაბეგრი ბრუნვა და კორექტირებები), უკუდაბეგვრასთან დაკავშირებული მე-11 ხაზი (საქართველოს საგადასახადო კოდექსის 176-ე მუხლი) და დეკემბრის წლიური პროპორციული გადაანგარიშების მე-20 და მე-21 ხაზები (კოდექსის 174-ე მუხლის მე-6 ნაწილი) ამ პაკეტში არ არის ასახული — იხ. README.md და docs/international.md, განყოფილება «From Georgia».', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 171, პირველი ნაწილი — დღგ-ის გადამხდელად რეგისტრირებული პირი დღგ-ის დეკლარაციას წარადგენს საგადასახადო ორგანოში და იხდის დღგ-ს არაუგვიანეს საანგარიშო პერიოდის მომდევნო თვის 15 რიცხვისა.', 'tax-code', null, 1, 'საქართველოს ფინანსთა მინისტრის 2007 წლის 11 სექტემბრის №1048 ბრძანების დანართი №2 (ინსტრუქცია), მე-9 პუნქტი — საგადასახადო ვალდებულების თანხობრივი გაანგარიშება ხდება სრულ ლარებში, 1 ლარამდე დამრგვალებით.', 'vat-return-order')
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
  ('GE', 'GE-VAT-MONTHLY', '1', 'tax', 'საანგარიშო პერიოდში განხორციელებულ ბრუნვაზე დარიცხული დღგ', '{"en":"VAT charged on turnover during the reporting period"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 1.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '2', 'base', '18 %-იანი განაკვეთით დასაბეგრი ბრუნვა', '{"en":"Turnover taxed at the 18% rate"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 2; საქართველოს საგადასახადო კოდექსი, მუხლი 169, პირველი ნაწილის „ა“ ქვეპუნქტი.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '3', 'base', '0-ვანი განაკვეთით დასაბეგრი ბრუნვა (მათ შორის, ექსპორტი)', '{"en":"Turnover taxed at the 0% rate (including export)"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 3; საქართველოს საგადასახადო კოდექსი, მუხლი 168, მე-4 ნაწილი.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '5', 'base', 'დღგ-სგან გათავისუფლებული ბრუნვა', '{"en":"VAT-exempt turnover"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 5; საქართველოს საგადასახადო კოდექსი, მუხლი 168, პირველი და მე-2 ნაწილები.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '9', 'tax', 'დღგ გადახდილი ადგილობრივი მომწოდებლებისათვის (ჩასათვლელი)', '{"en":"VAT paid to local suppliers (deductible)"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 9; საქართველოს საგადასახადო კოდექსი, მუხლი 173 და მუხლი 174.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '10', 'tax', 'დღგ გადახდილი საბაჟო ოპერაციებზე (ჩასათვლელი)', '{"en":"VAT paid on customs operations (deductible)"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 10; საქართველოს საგადასახადო კოდექსი, მუხლი 162 და მუხლი 174, პირველი ნაწილის „ა“ ქვეპუნქტი.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '8', 'total', 'ჩასათვლელი (შესამცირებელი) დღგ-ის ჯამური თანხა', '{"en":"Total deductible (creditable) VAT amount"}'::jsonb, 70, null, array['9', '10']::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 8.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '16', 'total', 'დარიცხული დღგ-ის ჯამი', '{"en":"Total VAT charged"}'::jsonb, 80, null, array['1']::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 16.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '17', 'total', 'ჩასათვლელი დღგ-ის ჯამი', '{"en":"Total VAT deductible"}'::jsonb, 90, null, array['8']::text[], '{}'::text[], null, null, false, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 17.', 'vat-return-order'),
  ('GE', 'GE-VAT-MONTHLY', '18', 'total', 'ბიუჯეტში გადასახდელად გამოანგარიშებული თანხა (ხაზი 16 > ხაზი 17)', '{"en":"Amount payable to the budget (line 16 > line 17)"}'::jsonb, 100, null, array['16']::text[], array['17']::text[], null, null, true, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 18; საქართველოს საგადასახადო კოდექსი, მუხლი 170, „ა“ ქვეპუნქტი და მუხლი 171, პირველი ნაწილი.', 'tax-code'),
  ('GE', 'GE-VAT-MONTHLY', '19', 'total', 'შესამცირებლად გამოანგარიშებული თანხა (ხაზი 17 > ხაზი 16)', '{"en":"Amount to be credited (line 17 > line 16)"}'::jsonb, 110, null, array['17']::text[], array['16']::text[], null, null, true, false, null, 'დეკლარაციის ფორმა, განაყოფი III, ხაზი 19.', 'vat-return-order')
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
  ('GE-IFRS-BS', 'GE', 'default', 'ფინანსური მდგომარეობის ანგარიშგება (ბალანსი)', 'balance_sheet', 'IFRS-SME', date '1970-01-01', null, 'საქართველოს კანონი ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის შესახებ, მუხლი 7 — II, III და IV კატეგორიის საწარმოები ადგენენ ფინანსურ ანგარიშგებას IFRS for SMEs-ის ან ბასს-ის (ბუღალტრული აღრიცხვის სტანდარტების საბჭოს) მიერ დამტკიცებული გამარტივებული სტანდარტების მიხედვით, ხოლო I კატეგორიისა და საზოგადოებრივი დაინტერესების პირები — სრული IFRS-ის მიხედვით; საქართველოს კანონმდებლობა არ ადგენს ბალანსის ერთიან სავალდებულო ფორმას კონკრეტული ხაზებით (განსხვავებით, მაგალითად, საფრანგეთის ან რუმინეთის ეროვნული გეგმისგან) — ეს პაკეტი იყენებს IFRS for SMEs-ის მე-4 განყოფილებით გათვალისწინებულ მინიმალურ დაჯგუფებას, ამ პაკეტის საკუთარი ანგარიშთა კოდების დიაპაზონების მიხედვით, რადგან ანგარიშთა კოდები კანონით დადგენილი არ არის.', 'ifrs-sme'),
  ('GE-IFRS-IS', 'GE', 'default', 'მოგება-ზარალის ანგარიშგება', 'income_statement', 'IFRS-SME', date '1970-01-01', null, 'საქართველოს კანონი ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის შესახებ, მუხლი 7; IFRS for SMEs, მე-5 განყოფილება — მოგება-ზარალის ანგარიშგება ხარჯების ბუნების მიხედვით დაჯგუფებით, რადგან საქართველოს კანონმდებლობა არ ადგენს ერთიან, კოდებზე დაფუძნებულ ფორმას.', 'ifrs-sme')
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
  ('GE-IFRS-BS', 'A-NC-FIX', 'A-NC', 'ძირითადი საშუალებები და არამატერიალური აქტივები', '{"en":"Property, plant, equipment and intangible assets"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-NC-OTH', 'A-NC', 'სხვა გრძელვადიანი აქტივები', '{"en":"Other non-current assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-NC', null, 'გრძელვადიანი (არამიმდინარე) აქტივები', '{"en":"Non-current assets"}'::jsonb, 30, 1, true, array['A-NC-FIX', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-C-REC', 'A-C', 'სავაჭრო და სხვა მოკლევადიანი დებიტორული დავალიანება', '{"en":"Trade and other receivables"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-C-OTH', 'A-C', 'მარაგები, წინასწარგადახდილი ხარჯები და სხვა მიმდინარე აქტივები', '{"en":"Inventories, prepayments and other current assets"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-C-CASH', 'A-C', 'ფულადი სახსრები და მათი ეკვივალენტები', '{"en":"Cash and cash equivalents"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-C', null, 'მიმდინარე აქტივები', '{"en":"Current assets"}'::jsonb, 70, 1, true, array['A-C-REC', 'A-C-OTH', 'A-C-CASH']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'A-TOT', null, 'აქტივები, სულ', '{"en":"Total assets"}'::jsonb, 80, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'E-CAP', 'E-TOT', 'საწესდებო კაპიტალი და სხვა კაპიტალის ინსტრუმენტები', '{"en":"Share capital and other equity instruments"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'E-RET', 'E-TOT', 'გაუნაწილებელი მოგება (დაუფარავი ზარალი)', '{"en":"Retained earnings (accumulated losses)"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'E-RESULT', 'E-TOT', 'საანგარიშგებო პერიოდის შედეგი (განუაწილებელი)', '{"en":"Result for the period, not yet allocated"}'::jsonb, 105, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'E-TOT', null, 'კაპიტალი, სულ', '{"en":"Total equity"}'::jsonb, 110, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'L-NC', 'L-TOT', 'გრძელვადიანი ვალდებულებები', '{"en":"Non-current liabilities"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'L-C-PAY', 'L-C', 'სავაჭრო და სხვა მოკლევადიანი კრედიტორული დავალიანება', '{"en":"Trade and other payables"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'L-C-OTH', 'L-C', 'სხვა მოკლევადიანი ვალდებულებები', '{"en":"Other current liabilities"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'L-C', null, 'მოკლევადიანი ვალდებულებები', '{"en":"Current liabilities"}'::jsonb, 150, 1, true, array['L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'L-TOT', null, 'ვალდებულებები, სულ', '{"en":"Total liabilities"}'::jsonb, 160, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-BS', 'EL-TOT', null, 'კაპიტალი და ვალდებულებები, სულ', '{"en":"Total equity and liabilities"}'::jsonb, 170, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-IS', 'REV', null, 'შემოსავალი რეალიზაციიდან', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-IS', 'COST', null, 'რეალიზებული პროდუქციის თვითღირებულება', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-IS', 'GROSS', null, 'საერთო მოგება', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('GE-IFRS-IS', 'OTH-INC', null, 'სხვა შემოსავალი', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-IS', 'OPEX', null, 'საოპერაციო ხარჯები', '{"en":"Operating expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-IS', 'DEPR', null, 'ცვეთისა და ამორტიზაციის ხარჯი', '{"en":"Depreciation and amortisation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('GE-IFRS-IS', 'PROFIT', null, 'საანგარიშგებო პერიოდის მოგება (ზარალი)', '{"en":"Profit (loss) for the period"}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null)
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
    ('GE-IFRS-BS', 'A-NC-FIX', 10, 'code_range', '0100', '0299', null, 'any'),
    ('GE-IFRS-BS', 'A-NC-OTH', 10, 'code_range', '0300', '0399', null, 'any'),
    ('GE-IFRS-BS', 'A-C-REC', 10, 'code_range', '1100', '1130', null, 'any'),
    ('GE-IFRS-BS', 'A-C-OTH', 10, 'code_range', '1000', '1050', null, 'any'),
    ('GE-IFRS-BS', 'A-C-OTH', 20, 'code_range', '1200', '1220', null, 'any'),
    ('GE-IFRS-BS', 'A-C-OTH', 30, 'code_range', '1450', '1490', null, 'any'),
    ('GE-IFRS-BS', 'A-C-CASH', 10, 'code_range', '1300', '1330', null, 'any'),
    ('GE-IFRS-BS', 'E-CAP', 10, 'code_range', '3000', '3050', null, 'any'),
    ('GE-IFRS-BS', 'E-RET', 10, 'code_range', '3100', '3100', null, 'any'),
    ('GE-IFRS-BS', 'E-RESULT', 10, 'code_range', '4000', '4050', null, 'any'),
    ('GE-IFRS-BS', 'E-RESULT', 20, 'code_range', '4200', '4250', null, 'any'),
    ('GE-IFRS-BS', 'E-RESULT', 30, 'code_range', '5000', '5040', null, 'any'),
    ('GE-IFRS-BS', 'E-RESULT', 40, 'code_range', '6000', '6220', null, 'any'),
    ('GE-IFRS-BS', 'E-RESULT', 50, 'code_range', '6900', '6920', null, 'any'),
    ('GE-IFRS-BS', 'E-RESULT', 60, 'code_range', '7000', '7060', null, 'any'),
    ('GE-IFRS-BS', 'L-NC', 10, 'code_range', '2400', '2440', null, 'any'),
    ('GE-IFRS-BS', 'L-C-PAY', 10, 'code_range', '2000', '2020', null, 'any'),
    ('GE-IFRS-BS', 'L-C-OTH', 10, 'code_range', '2100', '2300', null, 'any'),
    ('GE-IFRS-IS', 'REV', 10, 'code_range', '4000', '4050', null, 'any'),
    ('GE-IFRS-IS', 'COST', 10, 'code_range', '5000', '5040', null, 'any'),
    ('GE-IFRS-IS', 'OTH-INC', 10, 'code_range', '4200', '4250', null, 'any'),
    ('GE-IFRS-IS', 'OPEX', 10, 'code_range', '6000', '6220', null, 'any'),
    ('GE-IFRS-IS', 'OPEX', 20, 'code_range', '7000', '7060', null, 'any'),
    ('GE-IFRS-IS', 'DEPR', 10, 'code_range', '6900', '6920', null, 'any')
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
  ('GE', 'საქართველო', '{"en":"Georgia"}'::jsonb, array['ka', 'en']::text[], 'GEL', '1100', '2000', '2300', '7060', '3100', '4000', '5000', '1310', '1300', 'SAL', 'PUR', 'GEN', 'ka', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '4220', '7010', null, null, null, null, '2110', '1451', null, 'month'::declaration_period)
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
  number_format                 = '{CODE}-{NNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'საქართველოს საგადასახადო კოდექსი, მუხლი 175 — საგადასახადო ანგარიშ-ფაქტურის (მათ შორის, ელექტრონული საგადასახადო ანგარიშ-ფაქტურის) ფორმას ამტკიცებს ფინანსთა მინისტრი, და მისი ნომერი ენიჭება სისტემურად (rs.ge-ს მიერ ელექტრონული ანგარიშ-ფაქტურის შემთხვევაში), დამოუკიდებლად კომერციული დოკუმენტის (ინვოისის) საკუთარი ნუმერაციისგან. კანონი არ ადგენს კომერციული დოკუმენტის ნუმერაციის სავალდებულო ფორმატს — აქ მოცემული თანმიმდევრული ნუმერაცია მაგალითია და არა ერთადერთი დასაშვები ფორმა.',
  numbering_source_key          = 'tax-code',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'საქართველოს საგადასახადო კოდექსი, მუხლი 161, პირველი ნაწილის „ა.ბ“ ქვეპუნქტი — დასაბეგრი ოპერაციის შესრულების დრო არის საქონლის მიწოდების ან მომსახურების გაწევის მომენტი, მაგრამ არაუგვიანეს იმ მომენტისა, როდესაც მომწოდებელი წარუდგენს მყიდველს გადახდის მოთხოვნას (ანგარიშ-ფაქტურას) — ქვეპუნქტი „ა.ბ.ა“. ეს პაკეტი უახლოვდება ამ წესს სიტყვით `invoice_if_issued` (მიწოდება — პრინციპი, ანგარიშ-ფაქტურა — გამონაკლისი, რომელიც წინ უსწრებს მას). კოდექსის იმავე მუხლის ქვეპუნქტი „ა.ბ.დ“ ითვალისწინებს მესამე შემთხვევასაც — თუ გადახდა ხდება მიწოდებამდე, დროდ ითვლება გადახდის მომენტი; ამ მესამე ტრიგერის (წინასწარი გადახდა) ასახვა socle-ს არ შეუძლია წინასწარი გადახდის დოკუმენტის არარსებობის გამო — იხ. README.md და docs/international.md, განყოფილება «From Georgia».',
  tax_point_source_key          = 'tax-code',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'საქართველოს საგადასახადო კოდექსი, მუხლი 179 — დასაბეგრი ოპერაციის თანხის კორექტირება ხდება ცალკე დოკუმენტით (კორექტირების ანგარიშ-ფაქტურით), თავდაპირველი ჩანაწერის წაშლის გარეშე; საქართველოს კანონი ბუღალტრული აღრიცხვის, ანგარიშგებისა და აუდიტის შესახებ, მუხლი 7 — პირველადი დოკუმენტების შესწორება ხდება კვალის დატოვებით.',
  posted_edit_policy_source_key = 'tax-code',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'საქართველოს საგადასახადო კოდექსის 175-ე მუხლის 1^1 ნაწილის თანახმად, ფინანსთა მინისტრის მიერ დადგენილ შემთხვევებში საგადასახადო ანგარიშ-ფაქტურის გამოწერა და წარდგენა შესაძლებელია ელექტრონულად (ელექტრონული საგადასახადო ანგარიშ-ფაქტურა, საგადასახადო ანგარიშ-ფაქტურა — ეს არის ნებართვის მიმცემი (permissive), და არა უპირობოდ სავალდებულო ნორმა ყველა გადამხდელისთვის ყოველ ოპერაციაზე; პრაქტიკაში, დღგ-ის გადამხდელთა უმეტესობა იყენებს ელექტრონულ საგადასახადო ანგარიშ-ფაქტურას შემოსავლების სამსახურის (rs.ge) პორტალის მეშვეობით, რომელიც არის სახელმწიფოს მიერ დამოწმების (clearance) ტიპის სისტემა — გამომწერი აწარმოებს ანგარიშ-ფაქტურას პირდაპირ rs.ge-ს ერთიან რეესტრში (და არა ორმხრივი გაცვლით მყიდველთან), რის შემდეგაც დოკუმენტი ავტომატურად ხელმისაწვდომი ხდება მყიდველისთვის მისივე კაბინეტში. ეს მექანიზმი არ არის აგებული EN 16931-ის სემანტიკურ მოდელზე (Peppol BIS, Factur-X, XRechnung, PINT) და არც მონაწილეთა იდენტიფიკაციის ISO 6523 სქემას იყენებს (საქართველო არ არის Peppol-ის მონაწილეთა სქემის სიაში) — ამიტომ `profile`, `party_scheme` და `vat_scheme` ცარიელია. rs.ge-ს ერთიან რეესტრში რეგისტრირებული საგადასახადო ანგარიშ-ფაქტურის გარეშე მყიდველს არ წარმოეშობა ჩათვლის უფლება (მუხლი 173, მე-2 ნაწილის „ა“ ქვეპუნქტი). ამ სახელმწიფო რეესტრში რეგისტრაციის, დამოწმების და მისი ვადების socle-ზე ასახვის ხარვეზი დოკუმენტირებულია README.md-სა და docs/international.md-ის განყოფილებაში «From Georgia».',
  einvoice_source_key           = 'tax-invoice-order',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'GE';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('GE', 'reverse_charge', 'reverse_charge', 'დღგ ერიცხება და იხდის მომსახურების მიმღები საქართველოს საგადასახადო კოდექსის 176-ე მუხლის შესაბამისად (უკუდაბეგვრა).', '{"en":"VAT is charged and paid by the recipient of the service under article 176 of the Tax Code of Georgia (reverse charge)."}'::jsonb, 10, date '1970-01-01', null, 'საქართველოს საგადასახადო კოდექსი, მუხლი 176, პირველი ნაწილის „ა“ ქვეპუნქტი — არარეზიდენტის მიერ საქართველოს ტერიტორიაზე გაწეული მომსახურება ექვემდებარება უკუდაბეგვრას საგადასახადო აგენტის (მიმღების) მიერ.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
