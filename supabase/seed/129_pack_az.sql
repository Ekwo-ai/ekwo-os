-- Ekwo OS — Azərbaycan: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/az at version 0.2.0, do not edit.
-- Change the pack and run `ekwo pack build az`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Azərbaycan Respublikasının Vergi Məcəlləsi (maddələr 155, 161, 164, 165, 175, 177) (Azərbaycan Respublikasının Ədliyyə Nazirliyi — e-qanun.az)
--     https://e-qanun.az/framework/46948
--   Azərbaycan Respublikasının Vergi Məcəlləsi — maddə 164 (ƏDV-dən azadolmalar və güzəştlər) və maddə 165 (verginin sıfır (0) dərəcəsi ilə tutulması) son redaksiyada (Azərbaycan Respublikasının Dövlət Gömrük Komitəsi — customs.gov.az)
--     https://customs.gov.az/uploads/payment/8/c779b17981504c2145340a931615c148.pdf
--   Əlavə dəyər vergisi (ƏDV) — məlumat kitabçası, Bakı 2025 (Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az)
--     https://www.taxes.gov.az/uploads/2025/buklet/12.pdf
--   Vergilərin ödənilməsi və bəyannamələrin təqdim edilməsi müddətləri (Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az)
--     https://www.taxes.gov.az/az/page/vergilerin-odenilmesi-ve-beyannamelerin-teqdim-edilmesi-muddetleri
--   Əlavə Dəyər Vergisinin bəyannaməsi — 2026-cı il forması (Dövlət Vergi Xidmətinin 03.04.2026-cı il tarixli 2617140100317700 №-li Əmri ilə təsdiq edilmişdir) (Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az)
--     https://www.taxes.gov.az/uploads/2026/beyanname/EDV/EDV.xlsx
--   Vergi Məcəlləsində edilmiş dəyişikliklər üzrə suallar və cavablar (2026) — maddələr 155.1-1, 165.5 (Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az)
--     https://www.taxes.gov.az/uploads/2026/faq/FAQ2026.pdf
--   Elektron xidmətlər — İnternet vergi idarəsi (e-taxes.gov.az): elektron bəyannamənin və elektron qaimə-fakturanın qəbulu (Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az)
--     https://www.taxes.gov.az/az/page/elektron-xidmetler
--   Azərbaycan Respublikasının «Mühasibat uçotu haqqında» Qanunu (maddələr 6, 9) (Azərbaycan Respublikasının Maliyyə Nazirliyi yanında Fiskal Mühasibat Mərkəzi — frc.az)
--     https://frc.az/qanunvericilik/muhasibat-ucotu-haqqinda-qanun/19
--   Kommersiya təşkilatları üçün Milli Mühasibat Uçotu Standartları (qüvvədən düşmüşdür) (Azərbaycan Respublikasının Maliyyə Nazirliyi — maliyye.gov.az)
--     https://maliyye.gov.az/static/144/kommersiya-teskilatlari-ucun-milli-muhasibat-ucotu-standartlari-quvveden-dusmusdur-
--   Yeni hesablar planı (Maliyyə Nazirliyinin 18 aprel 2006-cı il tarixli İ-38 saylı əmri ilə təsdiq edilmiş hesablar planının mətni) (muhasib.az (özəl mühasibat portalı; rəsmi mətnin surəti))
--     https://muhasib.az/Muhasibat/teshkili/hesablar_plani_yeni.php
--   Hesablar planı (hesab 226 «ƏDV sub-uçot hesabı» daxil olmaqla, 2020-ci il redaksiyası) (e-muhasib.az (özəl mühasibat portalı; rəsmi mətnin surəti))
--     https://e-muhasib.az/hesablar.php?n=1
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('AZ', 'Azərbaycan', '0.2.0', date '2026-10-09', '20260929141500', 'community', null, null, '8a881d7521c47da25bceceb9f6783ae2086fcfb71a331f512aca04ff45c3ccd1', '[{"key":"tax-code","title":"Azərbaycan Respublikasının Vergi Məcəlləsi (maddələr 155, 161, 164, 165, 175, 177)","publisher":"Azərbaycan Respublikasının Ədliyyə Nazirliyi — e-qanun.az","url":"https://e-qanun.az/framework/46948","consulted_on":"2026-10-09","kind":"law"},{"key":"tax-code-extract","title":"Azərbaycan Respublikasının Vergi Məcəlləsi — maddə 164 (ƏDV-dən azadolmalar və güzəştlər) və maddə 165 (verginin sıfır (0) dərəcəsi ilə tutulması) son redaksiyada","publisher":"Azərbaycan Respublikasının Dövlət Gömrük Komitəsi — customs.gov.az","url":"https://customs.gov.az/uploads/payment/8/c779b17981504c2145340a931615c148.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"vat-booklet","title":"Əlavə dəyər vergisi (ƏDV) — məlumat kitabçası, Bakı 2025","publisher":"Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az","url":"https://www.taxes.gov.az/uploads/2025/buklet/12.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"filing-deadlines","title":"Vergilərin ödənilməsi və bəyannamələrin təqdim edilməsi müddətləri","publisher":"Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az","url":"https://www.taxes.gov.az/az/page/vergilerin-odenilmesi-ve-beyannamelerin-teqdim-edilmesi-muddetleri","consulted_on":"2026-10-09","kind":"guidance"},{"key":"vat-return-form","title":"Əlavə Dəyər Vergisinin bəyannaməsi — 2026-cı il forması (Dövlət Vergi Xidmətinin 03.04.2026-cı il tarixli 2617140100317700 №-li Əmri ilə təsdiq edilmişdir)","publisher":"Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az","url":"https://www.taxes.gov.az/uploads/2026/beyanname/EDV/EDV.xlsx","consulted_on":"2026-10-09","kind":"form"},{"key":"tax-faq-2026","title":"Vergi Məcəlləsində edilmiş dəyişikliklər üzrə suallar və cavablar (2026) — maddələr 155.1-1, 165.5","publisher":"Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az","url":"https://www.taxes.gov.az/uploads/2026/faq/FAQ2026.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"e-services","title":"Elektron xidmətlər — İnternet vergi idarəsi (e-taxes.gov.az): elektron bəyannamənin və elektron qaimə-fakturanın qəbulu","publisher":"Azərbaycan Respublikasının İqtisadiyyat Nazirliyi yanında Dövlət Vergi Xidməti — taxes.gov.az","url":"https://www.taxes.gov.az/az/page/elektron-xidmetler","consulted_on":"2026-10-09","kind":"portal"},{"key":"accounting-law","title":"Azərbaycan Respublikasının «Mühasibat uçotu haqqında» Qanunu (maddələr 6, 9)","publisher":"Azərbaycan Respublikasının Maliyyə Nazirliyi yanında Fiskal Mühasibat Mərkəzi — frc.az","url":"https://frc.az/qanunvericilik/muhasibat-ucotu-haqqinda-qanun/19","consulted_on":"2026-10-09","kind":"law"},{"key":"nas-status","title":"Kommersiya təşkilatları üçün Milli Mühasibat Uçotu Standartları (qüvvədən düşmüşdür)","publisher":"Azərbaycan Respublikasının Maliyyə Nazirliyi — maliyye.gov.az","url":"https://maliyye.gov.az/static/144/kommersiya-teskilatlari-ucun-milli-muhasibat-ucotu-standartlari-quvveden-dusmusdur-","consulted_on":"2026-10-09","kind":"guidance"},{"key":"chart-muhasib","title":"Yeni hesablar planı (Maliyyə Nazirliyinin 18 aprel 2006-cı il tarixli İ-38 saylı əmri ilə təsdiq edilmiş hesablar planının mətni)","publisher":"muhasib.az (özəl mühasibat portalı; rəsmi mətnin surəti)","url":"https://muhasib.az/Muhasibat/teshkili/hesablar_plani_yeni.php","consulted_on":"2026-10-09","kind":"guidance"},{"key":"chart-e-muhasib","title":"Hesablar planı (hesab 226 «ƏDV sub-uçot hesabı» daxil olmaqla, 2020-ci il redaksiyası)","publisher":"e-muhasib.az (özəl mühasibat portalı; rəsmi mətnin surəti)","url":"https://e-muhasib.az/hesablar.php?n=1","consulted_on":"2026-10-09","kind":"guidance"}]'::jsonb)
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
  ('AZ', 'default', 'Mühasibat uçotunun hesablar planı (Maliyyə Nazirliyinin İ-38 saylı əmri)', '{"en":"Chart of accounts (Ministry of Finance order İ-38)"}'::jsonb, true, 'companies', array['AZ-BS', 'AZ-IS']::text[], null, 'Maliyyə Nazirliyinin 18 aprel 2006-cı il tarixli İ-38 saylı əmri ilə təsdiq edilmiş hesablar planı (üç rəqəmli hesablar; sətirlər «Yeni hesablar planı» səhifəsindən götürülüb). Kommersiya təşkilatları üçün Milli Mühasibat Uçotu Standartları Maliyyə Nazirliyinin saytında «qüvvədən düşmüşdür» kimi qeyd olunub, «Mühasibat uçotu haqqında» Qanun isə MHBS və KOS üçün MHBS-ni tələb edir və milli hesablar planı barədə müddəa saxlamır — plan MHBS ilə uçot aparan şirkətlər tərəfindən praktikada tətbiq olunur, ona görə də onun hazırkı hüquqi statusu mühasib tərəfindən təsdiqlənməlidir. 2411, 2412, 2413, 5211, 5212 alt hesabları bu pack-ın əlavəsidir (ƏDV-nin ödənişdə hesablanması və bəyannamə hesabı üçün); qalan hesablar rəsmi planın mətnidir, 226 «ƏDV sub-uçot hesabı» daxil olmaqla.', 'chart-muhasib')
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
  ('AZ', 'default', '101', 'Qeyri-maddi aktivlərin dəyəri', '{"en":"Intangible assets — cost"}'::jsonb, 'asset_fixed', false, null, 10),
  ('AZ', 'default', '102', 'Qeyri-maddi aktivlər üzrə yığılmış amortizasiya və qiymətdəndüşmə zərərləri', '{"en":"Intangible assets — accumulated amortisation and impairment losses"}'::jsonb, 'asset_fixed', false, null, 20),
  ('AZ', 'default', '103', 'Qeyri-maddi aktivlərlə bağlı məsrəflərin kapitallaşdırılması', '{"en":"Intangible assets — capitalised costs"}'::jsonb, 'asset_fixed', false, null, 30),
  ('AZ', 'default', '111', 'Torpaq, tikili və avadanlıqların dəyəri', '{"en":"Property, plant and equipment — cost"}'::jsonb, 'asset_fixed', false, null, 40),
  ('AZ', 'default', '112', 'Torpaq, tikili və avadanlıqlar üzrə yığılmış amortizasiya və qiymətdəndüşmə zərərləri', '{"en":"Property, plant and equipment — accumulated depreciation and impairment losses"}'::jsonb, 'asset_fixed', false, null, 50),
  ('AZ', 'default', '113', 'Torpaq, tikili və avadanlıqlarla bağlı məsrəflərin kapitallaşdırılması', '{"en":"Property, plant and equipment — capitalised costs"}'::jsonb, 'asset_fixed', false, null, 60),
  ('AZ', 'default', '121', 'İnvestisiya mülkiyyətinin dəyəri', '{"en":"Investment property — cost"}'::jsonb, 'asset_fixed', false, null, 70),
  ('AZ', 'default', '122', 'İnvestisiya mülkiyyəti üzrə yığılmış amortizasiya və qiymətdəndüşmə zərərləri', '{"en":"Investment property — accumulated depreciation and impairment losses"}'::jsonb, 'asset_fixed', false, null, 80),
  ('AZ', 'default', '123', 'İnvestisiya mülkiyyəti ilə bağlı məsrəflərin kapitallaşdırılması', '{"en":"Investment property — capitalised costs"}'::jsonb, 'asset_fixed', false, null, 90),
  ('AZ', 'default', '131', 'Bioloji aktivlərin dəyəri', '{"en":"Biological assets — cost"}'::jsonb, 'asset_non_current', false, null, 100),
  ('AZ', 'default', '132', 'Bioloji aktivlər üzrə yığılmış amortizasiya və qiymətdəndüşmə zərərləri', '{"en":"Biological assets — accumulated depreciation and impairment losses"}'::jsonb, 'asset_non_current', false, null, 110),
  ('AZ', 'default', '141', 'Təbii sərvətlərin dəyəri', '{"en":"Natural resources — cost"}'::jsonb, 'asset_non_current', false, null, 120),
  ('AZ', 'default', '142', 'Təbii sərvətlərin tükənməsi', '{"en":"Natural resources — depletion"}'::jsonb, 'asset_non_current', false, null, 130),
  ('AZ', 'default', '151', 'Asılı müəssisələrə investisiyalar', '{"en":"Investments in associates"}'::jsonb, 'asset_non_current', false, null, 140),
  ('AZ', 'default', '152', 'Birgə müəssisələrə investisiyalar', '{"en":"Investments in joint ventures"}'::jsonb, 'asset_non_current', false, null, 150),
  ('AZ', 'default', '153', 'Asılı və birgə müəssisələrə investisiyaların dəyərinin azalmasına görə düzəlişlər', '{"en":"Investments in associates and joint ventures — impairment adjustments"}'::jsonb, 'asset_non_current', false, null, 160),
  ('AZ', 'default', '161', 'Mənfəət vergisi üzrə təxirə salınmış vergi aktivləri', '{"en":"Deferred tax assets — profit tax"}'::jsonb, 'asset_non_current', false, null, 170),
  ('AZ', 'default', '162', 'Digər təxirə salınmış vergi aktivləri', '{"en":"Deferred tax assets — other"}'::jsonb, 'asset_non_current', false, null, 180),
  ('AZ', 'default', '171', 'Alıcıların və sifarişçilərin uzunmüddətli debitor borcları', '{"en":"Long-term receivables from customers"}'::jsonb, 'asset_non_current', false, null, 190),
  ('AZ', 'default', '172', 'Törəmə müəssisələrin uzunmüddətli debitor borcları', '{"en":"Long-term receivables from subsidiaries"}'::jsonb, 'asset_non_current', false, null, 200),
  ('AZ', 'default', '173', 'Əsas idarəetmə heyətinin uzunmüddətli debitor borcları', '{"en":"Long-term receivables from key management personnel"}'::jsonb, 'asset_non_current', false, null, 210),
  ('AZ', 'default', '174', 'İcarə üzrə uzunmüddətli debitor borcları', '{"en":"Long-term lease receivables"}'::jsonb, 'asset_non_current', false, null, 220),
  ('AZ', 'default', '175', 'Tikinti müqavilələri üzrə uzunmüddətli debitor borcları', '{"en":"Long-term receivables on construction contracts"}'::jsonb, 'asset_non_current', false, null, 230),
  ('AZ', 'default', '176', 'Faizlər üzrə uzunmüddətli debitor borcları', '{"en":"Long-term interest receivable"}'::jsonb, 'asset_non_current', false, null, 240),
  ('AZ', 'default', '177', 'Digər uzunmüddətli debitor borcları', '{"en":"Other long-term receivables"}'::jsonb, 'asset_non_current', false, null, 250),
  ('AZ', 'default', '181', 'Ödənişə qədər saxlanılan uzunmüddətli investisiyalar', '{"en":"Long-term held-to-maturity investments"}'::jsonb, 'asset_non_current', false, null, 260),
  ('AZ', 'default', '182', 'Verilmiş uzunmüddətli borclar', '{"en":"Long-term loans granted"}'::jsonb, 'asset_non_current', false, null, 270),
  ('AZ', 'default', '183', 'Digər uzunmüddətli investisiyalar', '{"en":"Other long-term investments"}'::jsonb, 'asset_non_current', false, null, 280),
  ('AZ', 'default', '184', 'Sair uzunmüddətli maliyyə aktivlərinin dəyərinin azalmasına görə düzəlişlər', '{"en":"Other long-term financial assets — impairment adjustments"}'::jsonb, 'asset_non_current', false, null, 290),
  ('AZ', 'default', '191', 'Gələcək hesabat dövrlərinin xərcləri', '{"en":"Prepaid expenses of future reporting periods (long-term)"}'::jsonb, 'asset_non_current', false, null, 300),
  ('AZ', 'default', '192', 'Verilmiş uzunmüddətli avanslar', '{"en":"Long-term advances paid"}'::jsonb, 'asset_non_current', false, null, 310),
  ('AZ', 'default', '193', 'Digər uzunmüddətli aktivlər', '{"en":"Other long-term assets"}'::jsonb, 'asset_non_current', false, null, 320),
  ('AZ', 'default', '201', 'Material ehtiyatları', '{"en":"Raw materials and supplies"}'::jsonb, 'asset_current', false, null, 330),
  ('AZ', 'default', '202', 'İstehsalat məsrəfləri', '{"en":"Production costs (work in progress)"}'::jsonb, 'asset_current', false, null, 340),
  ('AZ', 'default', '203', 'Tikinti müqavilələri üzrə məsrəflər', '{"en":"Costs on construction contracts"}'::jsonb, 'asset_current', false, null, 350),
  ('AZ', 'default', '204', 'Hazır məhsul', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 360),
  ('AZ', 'default', '205', 'Mallar', '{"en":"Goods for resale"}'::jsonb, 'asset_current', false, null, 370),
  ('AZ', 'default', '206', 'Satış məqsədi ilə saxlanılan digər aktivlər', '{"en":"Other assets held for sale"}'::jsonb, 'asset_current', false, null, 380),
  ('AZ', 'default', '207', 'Digər ehtiyatlar', '{"en":"Other inventories"}'::jsonb, 'asset_current', false, null, 390),
  ('AZ', 'default', '208', 'Ehtiyatların dəyərinin azalmasına görə düzəlişlər', '{"en":"Inventories — impairment adjustments"}'::jsonb, 'asset_current', false, null, 400),
  ('AZ', 'default', '211', 'Alıcıların və sifarişçilərin qısamüddətli debitor borcları', '{"en":"Short-term receivables from customers"}'::jsonb, 'asset_receivable', true, null, 410),
  ('AZ', 'default', '212', 'Törəmə müəssisələrin qısamüddətli debitor borcları', '{"en":"Short-term receivables from subsidiaries"}'::jsonb, 'asset_current', false, null, 420),
  ('AZ', 'default', '213', 'Əsas idarəetmə heyətinin qısamüddətli debitor borcları', '{"en":"Short-term receivables from key management personnel"}'::jsonb, 'asset_current', false, null, 430),
  ('AZ', 'default', '214', 'İcarə üzrə qısamüddətli debitor borcları', '{"en":"Short-term lease receivables"}'::jsonb, 'asset_current', false, null, 440),
  ('AZ', 'default', '215', 'Tikinti müqavilələri üzrə qısamüddətli debitor borcları', '{"en":"Short-term receivables on construction contracts"}'::jsonb, 'asset_current', false, null, 450),
  ('AZ', 'default', '216', 'Faizlər üzrə qısamüddətli debitor borcları', '{"en":"Short-term interest receivable"}'::jsonb, 'asset_current', false, null, 460),
  ('AZ', 'default', '217', 'Digər qısamüddətli debitor borcları', '{"en":"Other short-term receivables"}'::jsonb, 'asset_current', false, null, 470),
  ('AZ', 'default', '218', 'Şübhəli borclar üzrə düzəlişlər', '{"en":"Allowance for doubtful receivables"}'::jsonb, 'asset_current', false, null, 480),
  ('AZ', 'default', '221', 'Kassa', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 490),
  ('AZ', 'default', '222', 'Yolda olan pul köçürmələri', '{"en":"Cash in transit"}'::jsonb, 'asset_current', false, null, 500),
  ('AZ', 'default', '223', 'Bank hesablaşma hesabları', '{"en":"Bank settlement accounts"}'::jsonb, 'asset_cash', false, null, 510),
  ('AZ', 'default', '224', 'Tələblərə əsasən açılan digər bank hesabları', '{"en":"Other bank accounts opened on demand"}'::jsonb, 'asset_cash', false, null, 520),
  ('AZ', 'default', '225', 'Pul vəsaitlərinin ekvivalentləri', '{"en":"Cash equivalents"}'::jsonb, 'asset_cash', false, null, 530),
  ('AZ', 'default', '226', 'ƏDV sub-uçot hesabı', '{"en":"VAT sub-account (deposit account held with the tax authority)"}'::jsonb, 'asset_current', false, null, 540),
  ('AZ', 'default', '231', 'Satış məqsədi ilə saxlanılan qısamüddətli investisiyalar', '{"en":"Short-term investments held for trading"}'::jsonb, 'asset_current', false, null, 550),
  ('AZ', 'default', '232', 'Ödənişə qədər saxlanılan qısamüddətli investisiyalar', '{"en":"Short-term held-to-maturity investments"}'::jsonb, 'asset_current', false, null, 560),
  ('AZ', 'default', '233', 'Verilmiş qısamüddətli borclar', '{"en":"Short-term loans granted"}'::jsonb, 'asset_current', false, null, 570),
  ('AZ', 'default', '234', 'Digər qısamüddətli investisiyalar', '{"en":"Other short-term investments"}'::jsonb, 'asset_current', false, null, 580),
  ('AZ', 'default', '235', 'Sair qısamüddətli maliyyə aktivlərinin dəyərinin azalmasına görə düzəlişlər', '{"en":"Other short-term financial assets — impairment adjustments"}'::jsonb, 'asset_current', false, null, 590),
  ('AZ', 'default', '241', 'Əvəzləşdirilən vergilər', '{"en":"Recoverable taxes (input VAT settlement account)"}'::jsonb, 'asset_current', true, null, 600),
  ('AZ', 'default', '2411', 'Əvəzləşdirilən ƏDV — yerli alışlar', '{"en":"Input VAT — domestic purchases"}'::jsonb, 'asset_current', false, '241', 610),
  ('AZ', 'default', '2412', 'Əvəzləşdirilən ƏDV — idxal', '{"en":"Input VAT — imports"}'::jsonb, 'asset_current', false, '241', 620),
  ('AZ', 'default', '2413', 'Ödənişi gözlənilən əvəzləşdirilən ƏDV', '{"en":"Input VAT awaiting payment of the supplier invoice"}'::jsonb, 'asset_current', false, '241', 630),
  ('AZ', 'default', '242', 'Gələcək hesabat dövrünün xərcləri', '{"en":"Prepaid expenses of future reporting periods"}'::jsonb, 'asset_prepayments', false, null, 640),
  ('AZ', 'default', '243', 'Verilmiş qısamüddətli avanslar', '{"en":"Short-term advances paid"}'::jsonb, 'asset_prepayments', false, null, 650),
  ('AZ', 'default', '244', 'Təhtəlhesab məbləğlər', '{"en":"Amounts accountable by employees"}'::jsonb, 'asset_current', false, null, 660),
  ('AZ', 'default', '245', 'Digər qısamüddətli aktivlər', '{"en":"Other short-term assets"}'::jsonb, 'asset_current', false, null, 670),
  ('AZ', 'default', '301', 'Nizamnamə kapitalı', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 680),
  ('AZ', 'default', '302', 'Nizamnamə kapitalın ödənilməmiş hissəsi', '{"en":"Unpaid share capital"}'::jsonb, 'equity', false, null, 690),
  ('AZ', 'default', '311', 'Emissiya gəliri', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 700),
  ('AZ', 'default', '321', 'Geri alınmış kapital', '{"en":"Treasury shares"}'::jsonb, 'equity', false, null, 710),
  ('AZ', 'default', '331', 'Yenidən qiymətləndirilmə üzrə ehtiyat', '{"en":"Revaluation reserve"}'::jsonb, 'equity', false, null, 720),
  ('AZ', 'default', '332', 'Məzənnə fərqləri üzrə ehtiyat', '{"en":"Exchange differences reserve"}'::jsonb, 'equity', false, null, 730),
  ('AZ', 'default', '333', 'Qanunvericilik üzrə ehtiyat', '{"en":"Statutory reserve"}'::jsonb, 'equity', false, null, 740),
  ('AZ', 'default', '334', 'Nizamnamə üzrə ehtiyat', '{"en":"Reserve required by the articles of association"}'::jsonb, 'equity', false, null, 750),
  ('AZ', 'default', '335', 'Digər ehtiyatlar', '{"en":"Other reserves"}'::jsonb, 'equity', false, null, 760),
  ('AZ', 'default', '341', 'Hesabat dövründə xalis mənfəət (zərər)', '{"en":"Net profit (loss) of the reporting period"}'::jsonb, 'equity', false, null, 770),
  ('AZ', 'default', '342', 'Mühasibat uçotu siyasətində dəyişikliklərlə bağlı düzəlişlər', '{"en":"Adjustments for changes in accounting policy"}'::jsonb, 'equity', false, null, 780),
  ('AZ', 'default', '343', 'Keçmiş illər üzrə bölüşdürülməmiş mənfəət', '{"en":"Retained earnings of previous years"}'::jsonb, 'equity_retained', false, null, 790),
  ('AZ', 'default', '344', 'Elan edilmiş dividentlər', '{"en":"Dividends declared"}'::jsonb, 'equity', false, null, 800),
  ('AZ', 'default', '401', 'Uzunmüddətli bank kreditləri', '{"en":"Long-term bank loans"}'::jsonb, 'liability_non_current', false, null, 810),
  ('AZ', 'default', '402', 'İşçilər üçün uzunmüddətli bank kreditləri', '{"en":"Long-term bank loans for employees"}'::jsonb, 'liability_non_current', false, null, 820),
  ('AZ', 'default', '403', 'Uzunmüddətli konvertasiya olunan istiqrazlar', '{"en":"Long-term convertible bonds"}'::jsonb, 'liability_non_current', false, null, 830),
  ('AZ', 'default', '404', 'Uzunmüddətli borclar', '{"en":"Long-term borrowings"}'::jsonb, 'liability_non_current', false, null, 840),
  ('AZ', 'default', '405', 'Geri alınan məhdud tədavül müddətli imtiyazlı səhmlər', '{"en":"Redeemable preference shares of limited life (long-term)"}'::jsonb, 'liability_non_current', false, null, 850),
  ('AZ', 'default', '406', 'Maliyyə icarəsi üzrə uzunmüddətli öhdəliklər', '{"en":"Long-term finance lease liabilities"}'::jsonb, 'liability_non_current', false, null, 860),
  ('AZ', 'default', '407', 'Törəmə müəssisələrə uzunmüddətli faiz xərcləri yaradan öhdəliklər', '{"en":"Long-term interest-bearing liabilities to subsidiaries"}'::jsonb, 'liability_non_current', false, null, 870),
  ('AZ', 'default', '408', 'Digər uzunmüddətli faiz xərcləri yaradan öhdəliklər', '{"en":"Other long-term interest-bearing liabilities"}'::jsonb, 'liability_non_current', false, null, 880),
  ('AZ', 'default', '411', 'İşdən azad olma ilə bağlı uzunmüddətli müavinətlər', '{"en":"Long-term termination benefits"}'::jsonb, 'liability_non_current', false, null, 890),
  ('AZ', 'default', '412', 'Uzunmüddətli zəmanət öhdəlikləri', '{"en":"Long-term warranty provisions"}'::jsonb, 'liability_non_current', false, null, 900),
  ('AZ', 'default', '413', 'Uzunmüddətli hüquqi öhdəliklər', '{"en":"Long-term legal provisions"}'::jsonb, 'liability_non_current', false, null, 910),
  ('AZ', 'default', '414', 'Digər uzunmüddətli qiymətləndirilmiş öhdəliklər', '{"en":"Other long-term provisions"}'::jsonb, 'liability_non_current', false, null, 920),
  ('AZ', 'default', '414-1', 'Sığorta müqavilələri üzrə uzunmüddətli öhdəliklər', '{"en":"Long-term insurance contract liabilities"}'::jsonb, 'liability_non_current', false, '414', 930),
  ('AZ', 'default', '421', 'Mənfəət vergisi üzrə təxirə salınmış vergi öhdəlikləri', '{"en":"Deferred tax liabilities — profit tax"}'::jsonb, 'liability_non_current', false, null, 940),
  ('AZ', 'default', '422', 'Digər təxirə salınmış vergi öhdəlikləri', '{"en":"Deferred tax liabilities — other"}'::jsonb, 'liability_non_current', false, null, 950),
  ('AZ', 'default', '431', 'Malsatan və podratçılara uzunmüddətli kreditor borcları', '{"en":"Long-term payables to suppliers and contractors"}'::jsonb, 'liability_non_current', false, null, 960),
  ('AZ', 'default', '432', 'Törəmə müəssisələrə uzunmüddətli kreditor borcları', '{"en":"Long-term payables to subsidiaries"}'::jsonb, 'liability_non_current', false, null, 970),
  ('AZ', 'default', '433', 'Tikinti müqavilələri üzrə uzunmüddətli kreditor borcları', '{"en":"Long-term payables on construction contracts"}'::jsonb, 'liability_non_current', false, null, 980),
  ('AZ', 'default', '434', 'Faizlər üzrə uzunmüddətli kreditor borcları', '{"en":"Long-term interest payable"}'::jsonb, 'liability_non_current', false, null, 990),
  ('AZ', 'default', '435', 'Digər uzunmüddətli kreditor borcları', '{"en":"Other long-term payables"}'::jsonb, 'liability_non_current', false, null, 1000),
  ('AZ', 'default', '441', 'Uzunmüddətli pensiya öhdəlikləri', '{"en":"Long-term pension liabilities"}'::jsonb, 'liability_non_current', false, null, 1010),
  ('AZ', 'default', '442', 'Gələcək hesabat dövrlərinin gəlirləri', '{"en":"Deferred income (long-term)"}'::jsonb, 'liability_non_current', false, null, 1020),
  ('AZ', 'default', '443', 'Alınmış uzunmüddətli avanslar', '{"en":"Long-term advances received"}'::jsonb, 'liability_non_current', false, null, 1030),
  ('AZ', 'default', '444', 'Uzunmüddətli məqsədli maliyyələşmələr', '{"en":"Long-term targeted financing"}'::jsonb, 'liability_non_current', false, null, 1040),
  ('AZ', 'default', '445', 'Digər uzunmüddətli öhdəliklər', '{"en":"Other long-term liabilities"}'::jsonb, 'liability_non_current', false, null, 1050),
  ('AZ', 'default', '501', 'Qısamüddətli bank kreditləri', '{"en":"Short-term bank loans"}'::jsonb, 'liability_current', false, null, 1060),
  ('AZ', 'default', '501-1', 'Bank overdraftı', '{"en":"Bank overdraft"}'::jsonb, 'liability_current', false, '501', 1070),
  ('AZ', 'default', '502', 'İşçilər üçün qısamüddətli bank kreditləri', '{"en":"Short-term bank loans for employees"}'::jsonb, 'liability_current', false, null, 1080),
  ('AZ', 'default', '503', 'Qısamüddətli konvertasiya olunan istiqrazlar', '{"en":"Short-term convertible bonds"}'::jsonb, 'liability_current', false, null, 1090),
  ('AZ', 'default', '504', 'Qısamüddətli borclar', '{"en":"Short-term borrowings"}'::jsonb, 'liability_current', false, null, 1100),
  ('AZ', 'default', '505', 'Geri alınan məhdud tədavül müddətli imtiyazlı səhmlər', '{"en":"Redeemable preference shares of limited life (short-term)"}'::jsonb, 'liability_current', false, null, 1110),
  ('AZ', 'default', '506', 'Törəmə müəssisələrə qısamüddətli faiz xərcləri yaradan öhdəliklər', '{"en":"Short-term interest-bearing liabilities to subsidiaries"}'::jsonb, 'liability_current', false, null, 1120),
  ('AZ', 'default', '507', 'Digər qısamüddətli faiz xərcləri yaradan öhdəliklər', '{"en":"Other short-term interest-bearing liabilities"}'::jsonb, 'liability_current', false, null, 1130),
  ('AZ', 'default', '511', 'İşdən azad olma ilə bağlı qısamüddətli müavinətlər', '{"en":"Short-term termination benefits"}'::jsonb, 'liability_current', false, null, 1140),
  ('AZ', 'default', '512', 'Qısamüddətli zəmanət öhdəlikləri', '{"en":"Short-term warranty provisions"}'::jsonb, 'liability_current', false, null, 1150),
  ('AZ', 'default', '513', 'Qısamüddətli hüquqi öhdəliklər', '{"en":"Short-term legal provisions"}'::jsonb, 'liability_current', false, null, 1160),
  ('AZ', 'default', '514', 'Mənfəətdə iştirak planı və müavinət planları', '{"en":"Profit-sharing and bonus plans"}'::jsonb, 'liability_current', false, null, 1170),
  ('AZ', 'default', '515', 'Digər qısamüddətli qiymətləndirilmiş öhdəliklər', '{"en":"Other short-term provisions"}'::jsonb, 'liability_current', false, null, 1180),
  ('AZ', 'default', '515-1', 'Sığorta müqavilələri üzrə qısamüddətli öhdəliklər', '{"en":"Short-term insurance contract liabilities"}'::jsonb, 'liability_current', false, '515', 1190),
  ('AZ', 'default', '521', 'Vergi öhdəlikləri', '{"en":"Tax liabilities (VAT settlement account)"}'::jsonb, 'liability_current', true, null, 1200),
  ('AZ', 'default', '5211', 'ƏDV üzrə hesablanmış vergi', '{"en":"Output VAT due"}'::jsonb, 'liability_current', false, '521', 1210),
  ('AZ', 'default', '5212', 'Ödənişi gözlənilən hesablanmış ƏDV', '{"en":"Output VAT awaiting collection from the customer"}'::jsonb, 'liability_current', false, '521', 1220),
  ('AZ', 'default', '5213', 'ƏDV — qeyri-rezidentin xidmətləri üzrə vergi agenti kimi hesablanmış vergi', '{"en":"VAT calculated as tax agent on services of non-residents"}'::jsonb, 'liability_current', false, '521', 1225),
  ('AZ', 'default', '522', 'Sosial sığorta və təminat üzrə öhdəliklər', '{"en":"Social insurance and security liabilities"}'::jsonb, 'liability_current', false, null, 1230),
  ('AZ', 'default', '523', 'Digər məcburi ödənişlər üzrə öhdəliklər', '{"en":"Other compulsory payments"}'::jsonb, 'liability_current', false, null, 1240),
  ('AZ', 'default', '531', 'Malsatan və podratçılara qısamüddətli kreditor borcları', '{"en":"Short-term payables to suppliers and contractors"}'::jsonb, 'liability_payable', true, null, 1250),
  ('AZ', 'default', '532', 'Törəmə müəssisələrə qısamüddətli kreditor borcları', '{"en":"Short-term payables to subsidiaries"}'::jsonb, 'liability_current', false, null, 1260),
  ('AZ', 'default', '533', 'Əməyin ödənişi üzrə işçi heyətinə olan borclar', '{"en":"Payables to employees for remuneration"}'::jsonb, 'liability_current', false, null, 1270),
  ('AZ', 'default', '534', 'Dividendlərin ödənilməsi üzrə təsisçilərə kreditor borcları', '{"en":"Dividends payable to founders"}'::jsonb, 'liability_current', false, null, 1280),
  ('AZ', 'default', '535', 'İcarə üzrə qısamüddətli kreditor borcları', '{"en":"Short-term lease payables"}'::jsonb, 'liability_current', false, null, 1290),
  ('AZ', 'default', '536', 'Tikinti müqavilələri üzrə qısamüddətli kreditor borcları', '{"en":"Short-term payables on construction contracts"}'::jsonb, 'liability_current', false, null, 1300),
  ('AZ', 'default', '537', 'Faizlər üzrə qısamüddətli kreditor borcları', '{"en":"Short-term interest payable"}'::jsonb, 'liability_current', false, null, 1310),
  ('AZ', 'default', '538', 'Digər qısamüddətli kreditor borcları', '{"en":"Other short-term payables"}'::jsonb, 'liability_current', false, null, 1320),
  ('AZ', 'default', '541', 'Qısamüddətli pensiya öhdəlikləri', '{"en":"Short-term pension liabilities"}'::jsonb, 'liability_current', false, null, 1330),
  ('AZ', 'default', '542', 'Gələcək hesabat dövrünün gəlirləri', '{"en":"Deferred income (short-term)"}'::jsonb, 'liability_current', false, null, 1340),
  ('AZ', 'default', '543', 'Alınmış qısamüddətli avanslar', '{"en":"Short-term advances received"}'::jsonb, 'liability_current', false, null, 1350),
  ('AZ', 'default', '544', 'Qısamüddətli məqsədli maliyyələşmələr', '{"en":"Short-term targeted financing"}'::jsonb, 'liability_current', false, null, 1360),
  ('AZ', 'default', '545', 'Digər qısamüddətli öhdəliklər', '{"en":"Other short-term liabilities"}'::jsonb, 'liability_current', false, null, 1370),
  ('AZ', 'default', '601', 'Satış', '{"en":"Sales"}'::jsonb, 'income', false, null, 1380),
  ('AZ', 'default', '602', 'Satılmış malların qaytarılması və ucuzlaşdırılması', '{"en":"Sales returns and price reductions"}'::jsonb, 'income', false, null, 1390),
  ('AZ', 'default', '603', 'Verilmiş güzəştlər', '{"en":"Discounts granted"}'::jsonb, 'income', false, null, 1400),
  ('AZ', 'default', '611', 'Sair əməliyyat gəlirləri', '{"en":"Other operating income"}'::jsonb, 'income_other', false, null, 1410),
  ('AZ', 'default', '621', 'Fəaliyyətin dayandırılmasından yaranan gəlirlər', '{"en":"Income from discontinued operations"}'::jsonb, 'income_other', false, null, 1420),
  ('AZ', 'default', '631', 'Maliyyə gəlirləri', '{"en":"Finance income"}'::jsonb, 'income_other', false, null, 1430),
  ('AZ', 'default', '641', 'Fövqəladə gəlirlər', '{"en":"Extraordinary income"}'::jsonb, 'income_other', false, null, 1440),
  ('AZ', 'default', '701', 'Satışın maya dəyəri üzrə xərclər', '{"en":"Cost of sales"}'::jsonb, 'expense_direct_cost', false, null, 1450),
  ('AZ', 'default', '711', 'Kommersiya xərcləri', '{"en":"Selling expenses"}'::jsonb, 'expense', false, null, 1460),
  ('AZ', 'default', '721', 'İnzibati xərclər', '{"en":"Administrative expenses"}'::jsonb, 'expense', false, null, 1470),
  ('AZ', 'default', '731', 'Sair əməliyyat xərcləri', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, null, 1480),
  ('AZ', 'default', '741', 'Fəaliyyətin dayandırılmasından yaranan xərclər', '{"en":"Expenses of discontinued operations"}'::jsonb, 'expense', false, null, 1490),
  ('AZ', 'default', '751', 'Maliyyə xərcləri', '{"en":"Finance expenses"}'::jsonb, 'expense', false, null, 1500),
  ('AZ', 'default', '761', 'Fövqəladə xərclər', '{"en":"Extraordinary expenses"}'::jsonb, 'expense', false, null, 1510),
  ('AZ', 'default', '801', 'Ümumi mənfəət', '{"en":"Gross profit (closing account)"}'::jsonb, 'equity', false, null, 1520),
  ('AZ', 'default', '811', 'Asılı və birgə müəssisələrin mənfəətlərində pay', '{"en":"Share of profit of associates and joint ventures"}'::jsonb, 'income_other', false, null, 1530),
  ('AZ', 'default', '901', 'Cari mənfəət vergisi üzrə xərclər', '{"en":"Current profit tax expense"}'::jsonb, 'expense', false, null, 1540),
  ('AZ', 'default', '902', 'Təxirə salınmış mənfəət vergisi üzrə xərclər', '{"en":"Deferred profit tax expense"}'::jsonb, 'expense', false, null, 1550)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('AZ', 'BNK', 'Bank jurnalı', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('AZ', 'CSH', 'Kassa jurnalı', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('AZ', 'GEN', 'Ümumi jurnal', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('AZ', 'OPN', 'Açılış jurnalı', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('AZ', 'PUR', 'Alış jurnalı', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('AZ', 'SAL', 'Satış jurnalı', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('AZ', 'AZ-P-18', 'ƏDV 18 % — yerli alış (elektron qaimə-faktura üzrə əvəzləşdirmə)', '{"en":"VAT 18% — domestic purchase (deduction on the electronic tax invoice)"}'::jsonb, null, 'percent', 18, 'purchase', 'domestic', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 175.1 — ödənilmiş ƏDV yalnız alınmış elektron qaimə-fakturaya əsasən, malların (işlərin, xidmətlərin) dəyəri alıcının bank hesabından təqdim edənin hesabına nağdsız köçürüldükdə və ƏDV məbləği bir iş günü ərzində satıcının ƏDV depozit hesabına ödənildikdə əvəzləşdirilir (ƏDV kitabçası, «Malların alışı zamanı ödənilmiş ƏDV məbləğinin əvəzləşdirilməsi şərtləri»). Bəyannamə: sətir 308 (elektron qaimə-fakturalar üzrə nağdsız ödənilmiş məbləğ) — ƏDV nəzərə alınmadan ödənilmiş məbləğ və ƏDV məbləği. Əvəzləşdirmə alıcının ödənişi ilə ayın hesabına düşür: faktura 2413 hesabında gözləyir, ödəniş zamanı 2411 hesabına keçir. Pack depozit hesabına ödənişi yoxlaya bilmir — README-yə bax.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, true, '2413', 'vat-booklet', null, null, null, null),
  ('AZ', 'AZ-P-18-NONRES', 'ƏDV 18 % — qeyri-rezidentin xidmətləri (vergi agenti kimi hesablanma və əvəzləşdirmə)', '{"en":"VAT 18% — services of a non-resident, calculated and offset as tax agent"}'::jsonb, 'ƏDV-nin məqsədləri üçün qeydiyyatda olmayan qeyri-rezidentin göstərdiyi xidmətlər üzrə vergi agentinin hesabladığı, bəyannamə ilə ödədiyi və eyni ayda əvəzləşdirdiyi ƏDV', 'percent', 18, 'purchase', 'foreign_services_received', date '2020-01-01', null, 'Tax Code of the Republic of Azerbaijan, art. 169.1 — services of a non-resident not registered for VAT, supplied in Azerbaijan to a tax agent, are taxed under art. 169, and every VAT-registered person is a tax agent for its purposes; art. 169.3 — the tax agent calculates the VAT at the rate of art. 173.1 (18 %) on the amount payable to the non-resident; art. 169.4 — a VAT-registered agent pays it with the VAT return of the month of the operation, and the payment document stands for the electronic tax invoice of art. 175 for its offset. VAT return (2026 form): line 306.1 for the tax calculated, line 312 ("VM 169.4-cü maddəsinə əsasən qeyri-rezidentə ödənilmiş məbləğ") for its offset, inside line 317. Since 1 January 2020 the operation occurs when the amount is paid to the non-resident, and the tax is declared and offset in the return of that month', null, null, 65, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code', null, null, null, null),
  ('AZ', 'AZ-P-EXEMPT', 'ƏDV-dən azad alış (ƏDV tutulmayan əməliyyat)', '{"en":"VAT-exempt purchase (no VAT charged)"}'::jsonb, null, 'percent', 0, 'purchase', 'exempt', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 164.1 — ƏDV-dən azad edilən malların, işlərin və xidmətlərin alışında ƏDV ödənilmir və əvəzləşdirilmir; bəyannamədə ayrıca sətir yoxdur.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-booklet', null, null, null, null),
  ('AZ', 'AZ-P-IMPORT', 'ƏDV 18 % — malların idxalı (gömrük bəyannaməsi)', '{"en":"VAT 18% — import of goods (customs declaration)"}'::jsonb, null, 'percent', 18, 'purchase', 'import', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 161 — vergi tutulan idxalın dəyərinə ƏDV 18 faiz dərəcə ilə tətbiq edilir; idxalda ƏDV-nin ödənildiyini göstərən sənədlər (yük gömrük bəyannaməsi) üzrə əvəzləşdirmə (ƏDV kitabçası, «Vergi tutulan dövriyyədən büdcəyə ödənilməli ƏDV»). Bəyannamə: sətir 310 (idxalda ƏDV-yə cəlb olunmuş mallara görə ödənilmiş məbləğ; təsnifat Əlavə 1 ilə).', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-booklet', null, null, null, null),
  ('AZ', 'AZ-S-0', 'ƏDV 0 % — beynəlxalq və tranzit daşımalar və 165-ci maddədə sadalanan digər əməliyyatlar (satış)', '{"en":"VAT 0% — international and transit transport and other operations listed in article 165 (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'domestic', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 165.1.4 — beynəlxalq poçt xidmətləri istisna olmaqla, beynəlxalq və tranzit yük və sərnişin daşınması, tranzit yük daşınması ilə bilavasitə bağlı yük aşırılma xidməti, beynəlxalq və tranzit uçuşlarla bağlı işlər və xidmətlər, ekspeditor xidmətləri sıfır (0) dərəcəsi ilə tutulur; maddə 165.1 — maddənin digər bəndləri (məsələn 165.1.1, 165.1.2, 165.1.11) də bu vergi ilə modelləşdirilir. Sıfır dərəcə azadolma deyil, vergi tutulan əməliyyatdır (maddə 164 ilə 165 fərqi). Bəyannamə: sətir 302. Pack bu vergi üçün bazanı faktura tarixində göstərir.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-extract', null, null, null, null),
  ('AZ', 'AZ-S-18', 'ƏDV 18 % — Azərbaycan ərazisində mal, iş və xidmətlərin təqdim edilməsi (satış)', '{"en":"VAT 18% — supply of goods, works and services in Azerbaijan (sale)"}'::jsonb, null, 'percent', 18, 'sale', 'domestic', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 161 — vergi tutulan əməliyyatın və vergi tutulan idxalın dəyərinə ƏDV 18 faiz dərəcə ilə tətbiq edilir (ƏDV kitabçası, «ƏDV-nin dərəcəsi neçə faizdir?»). Bəyannamə: sətir 301 (18 faiz dərəcə ilə cəlb olunan əməliyyatlar) — daxil olmuş məbləğ (ƏDV nəzərə alınmadan) və ƏDV məbləği. Vergi tutulan əməliyyatın vaxtı ödəmənin aparıldığı vaxtdır (ƏDV kitabçası, «Vergi tutulan əməliyyatın aparıldığı vaxt»): faktura verildikdə ƏDV 5212 hesabında gözləyir, ödəniş alındıqda 5211 hesabına keçir və bəyannamənin həmin ayında görünür. Pack-in qüvvəsi 2026-01-01-dən götürülür; daha əvvəlki tarixçə araşdırılmayıb.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, true, '5212', 'vat-booklet', null, null, null, null),
  ('AZ', 'AZ-S-EXEMPT', 'ƏDV-dən azad — ödənişli təhsil xidmətləri (satış)', '{"en":"VAT exempt — paid education services (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'exempt', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 164.1 — ödənişli təhsil xidmətlərinin göstərilməsi (digər fəaliyyətləri ilə bağlı xidmətlər istisna olmaqla) ƏDV-dən azaddır (ƏDV kitabçası, «ƏDV-dən azadolma halları»); maddə 164 digər azadolmaları da sadalayır — pack bu vergi ilə yalnız ən çox rast gəlinən nümunəni göstərir, istənilən 164-cü maddə azadolması üçün başqa kod əlavə edilməlidir. Bəyannamə: sətir 303.', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-booklet', null, null, null, null),
  ('AZ', 'AZ-S-EXPORT', 'ƏDV 0 % — malların ixracı (satış)', '{"en":"VAT 0% — export of goods (sale)"}'::jsonb, null, 'percent', 0, 'sale', 'export', date '2026-01-01', null, 'Vergi Məcəlləsi, maddə 165.1.3 — malların və 168.1.5-ci maddədə göstərilmiş xidmətlərin ixracı ƏDV-yə sıfır (0) dərəcə ilə cəlb olunur; maddə 164.1 — azadolmalar ixrac əməliyyatlarına şamil edilmir. Bəyannamə: sətir 302 (ƏDV-yə sıfır dərəcə ilə cəlb olunan əməliyyatlar). Pack bu vergi üçün bazanı faktura tarixində göstərir.', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'tax-code-extract', null, null, null, null)
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
    ('AZ-P-18', 'invoice', 'base', 100, null, '308B', array['308B']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-P-18', 'invoice', 'tax', 100, '2411', '308T', array['308T']::text[], 100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-P-18', 'credit_note', 'base', 100, null, '308B', array['308B']::text[], -100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-P-18', 'credit_note', 'tax', 100, '2411', '308T', array['308T']::text[], -100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-P-18-NONRES', 'invoice', 'base', 100, null, '306R', array['306R', '312B']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-P-18-NONRES', 'invoice', 'tax', 100, '2411', '312T', array['312T']::text[], 100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-P-18-NONRES', 'invoice', 'tax', -100, '5213', '306T', array['306T']::text[], 100, 'AZ-EDV-AYLIQ', 30),
    ('AZ-P-18-NONRES', 'credit_note', 'base', 100, null, '306R', array['306R', '312B']::text[], -100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-P-18-NONRES', 'credit_note', 'tax', 100, '2411', '312T', array['312T']::text[], -100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-P-18-NONRES', 'credit_note', 'tax', -100, '5213', '306T', array['306T']::text[], -100, 'AZ-EDV-AYLIQ', 30),
    ('AZ-P-EXEMPT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('AZ-P-EXEMPT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('AZ-P-IMPORT', 'invoice', 'base', 100, null, '310B', array['310B']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-P-IMPORT', 'invoice', 'tax', 100, '2412', '310T', array['310T']::text[], 100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-P-IMPORT', 'credit_note', 'base', 100, null, '310B', array['310B']::text[], -100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-P-IMPORT', 'credit_note', 'tax', 100, '2412', '310T', array['310T']::text[], -100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-S-0', 'invoice', 'base', 100, null, '302R', array['302R']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-0', 'credit_note', 'base', 100, null, '302R', array['302R']::text[], -100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-18', 'invoice', 'base', 100, null, '301R', array['301R']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-18', 'invoice', 'tax', 100, '5211', '301T', array['301T']::text[], 100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-S-18', 'credit_note', 'base', 100, null, '301R', array['301R']::text[], -100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-18', 'credit_note', 'tax', 100, '5211', '301T', array['301T']::text[], -100, 'AZ-EDV-AYLIQ', 20),
    ('AZ-S-EXEMPT', 'invoice', 'base', 100, null, '303R', array['303R']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-EXEMPT', 'credit_note', 'base', 100, null, '303R', array['303R']::text[], -100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-EXPORT', 'invoice', 'base', 100, null, '302R', array['302R']::text[], 100, 'AZ-EDV-AYLIQ', 10),
    ('AZ-S-EXPORT', 'credit_note', 'base', 100, null, '302R', array['302R']::text[], -100, 'AZ-EDV-AYLIQ', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'AZ' and t.code = v.tax_code
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
  ('AZ', 'AZ-EDV-AYLIQ', 'Əlavə dəyər vergisinin bəyannaməsi (aylıq)', array['month']::declaration_period[], 'month'::declaration_period, date '2026-01-01', null, 'Dövlət Vergi Xidmətinin 03.04.2026-cı il tarixli 2617140100317700 №-li Əmri ilə təsdiq edilmiş «Əlavə Dəyər Vergisinin bəyannaməsi» (2026-cı il forması, Hissə 1-5); Vergi Məcəlləsi, maddə 177.2 — ƏDV üzrə hesabat dövrü təqvim ayıdır. Pack bəyannamənin yalnız öz vergilərinin yazdığı sətirlərini göstərir: 301, 302, 303, 305, 308, 310, 317, 326, 327. Sətir 301.2/301-2 (kənd təsərrüfatı ticarət əlavəsi), 304, 306 (qeyri-rezident), 307 (debitor borclar), 309, 311-316, 318-324 (artırılan və azaldılan dövriyyələr, ƏDV geri al mexanizmi 319.2-319.4) və Əlavələr modelləşdirilmir — README-yə bax.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Vergi Məcəlləsi, maddə 177.2 — ƏDV bəyannaməsi hesabat dövründən sonrakı ayın 20-dən gec olmayaraq təqdim edilir və vergi həmin müddətdə ödənilir (cədvəl «Vergilərin ödənilməsi və bəyannamələrin təqdim edilməsi müddətləri»: «Hesabat ayından sonrakı ayın 20-dən gec olmayaraq (20/I-XII)»). Son gün qeyri-iş gününə düşərsə, növbəti iş gününə keçir — pack bu keçidi hesablamır.', 'filing-deadlines', null)
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
  ('AZ', 'AZ-EDV-AYLIQ', '301R', 'base', 'Sətir 301 — ƏDV-nə 18 faiz dərəcə ilə cəlb olunan əməliyyatlar: daxil olmuş məbləğ (ƏDV nəzərə alınmadan)', '{"en":"Line 301 — operations taxed at 18%: amount received (excluding VAT)"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 301, ikinci sütun «Daxil olmuş məbləğ (ƏDV nəzərə alınmadan)»', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '301T', 'tax', 'Sətir 301 — ƏDV-nə 18 faiz dərəcə ilə cəlb olunan əməliyyatlar: ƏDV məbləği', '{"en":"Line 301 — operations taxed at 18%: VAT amount"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 301, üçüncü sütun «Əlavə dəyər vergisi məbləği»', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '302R', 'base', 'Sətir 302 — ƏDV-nə sıfır (0) faiz dərəcə ilə cəlb olunan əməliyyatlar (ixrac daxil)', '{"en":"Line 302 — operations taxed at the zero rate (exports included)"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 302', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '303R', 'base', 'Sətir 303 — ƏDV-dən azad olunan əməliyyatlar', '{"en":"Line 303 — VAT-exempt operations"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 303', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '305R', 'total', 'Sətir 305 — Əməliyyatlar üzrə CƏMİ: daxil olmuş məbləğ', '{"en":"Line 305 — TOTAL operations: amount received"}'::jsonb, 50, null, array['301R', '302R', '303R']::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 305 = 301 + 302 + 303 (modelləşdirilən sətirlər)', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '305T', 'total', 'Sətir 305 — Əməliyyatlar üzrə CƏMİ: ƏDV məbləği', '{"en":"Line 305 — TOTAL operations: VAT amount"}'::jsonb, 60, null, array['301T']::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 305, üçüncü sütun = sətir 301 + sətir 304', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '306R', 'base', 'Sətir 306.1 — ƏDV-nin məqsədləri üçün qeydiyyata alınmayan qeyri-rezidentin göstərdiyi xidmətlər üzrə vergiyə cəlb olunan əməliyyatlar: ödənilmiş məbləğ', '{"en":"Line 306.1 — taxable services of a non-resident not registered for VAT: amount paid"}'::jsonb, 62, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 306.1, birinci sütun; Vergi Məcəlləsi, maddə 169', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '306T', 'tax', 'Sətir 306.1 — vergi agenti kimi hesablanmış ƏDV məbləği', '{"en":"Line 306.1 — VAT calculated as tax agent"}'::jsonb, 64, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 306.1, ikinci sütun; Vergi Məcəlləsi, maddə 169.3 və 169.4', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '308B', 'base', 'Sətir 308 — elektron qaimə-fakturalar üzrə nağdsız qaydada ödənilmiş məbləğ (ƏDV nəzərə alınmadan)', '{"en":"Line 308 — amount paid by non-cash means on electronic tax invoices (excluding VAT)"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 308, birinci sütun', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '308T', 'tax', 'Sətir 308 — əvəzləşdirilən ƏDV məbləği', '{"en":"Line 308 — deductible VAT amount"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 308, ikinci sütun', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '310B', 'base', 'Sətir 310 — idxalda ƏDV-yə cəlb olunmuş mallara görə ödənilmiş məbləğ (ƏDV nəzərə alınmadan)', '{"en":"Line 310 — amount paid on imported goods subject to VAT (excluding VAT)"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 310, birinci sütun', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '310T', 'tax', 'Sətir 310 — idxalda ödənilmiş və əvəzləşdirilən ƏDV məbləği', '{"en":"Line 310 — VAT paid on import and deductible"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 310, ikinci sütun', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '312B', 'base', 'Sətir 312 — VM 169.4-cü maddəsinə əsasən qeyri-rezidentə ödənilmiş məbləğ', '{"en":"Line 312 — amount paid to a non-resident under Tax Code art. 169.4"}'::jsonb, 102, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 312, birinci sütun', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '312T', 'tax', 'Sətir 312 — qeyri-rezidentin xidmətləri üzrə ödənilmiş və əvəzləşdirilən ƏDV', '{"en":"Line 312 — VAT paid and offset on services of a non-resident"}'::jsonb, 104, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 312, ikinci sütun; Vergi Məcəlləsi, maddə 169.4 və 175', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '317T', 'total', 'Sətir 317 — Əməliyyatlar üzrə CƏMİ: əvəzləşdirilən ƏDV', '{"en":"Line 317 — TOTAL deductible VAT"}'::jsonb, 110, null, array['308T', '310T', '312T']::text[], '{}'::text[], null, null, false, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 317, ikinci sütun = sətir 308 + 309 + 310 + 312 − 313 − 315 (modelləşdirilən sətirlər)', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '326', 'total', 'Sətir 326 — BÜDCƏYƏ ÖDƏNİLMƏLİDİR', '{"en":"Line 326 — PAYABLE TO THE BUDGET"}'::jsonb, 120, null, array['305T', '306T']::text[], array['317T']::text[], null, null, true, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 326 = 305 + 306 + 318 + 324 − 317 − 319 (modelləşdirilən sətirlər)', 'vat-return-form'),
  ('AZ', 'AZ-EDV-AYLIQ', '327', 'total', 'Sətir 327 — BÜDCƏDƏN QAYTARILIR', '{"en":"Line 327 — REFUNDABLE FROM THE BUDGET"}'::jsonb, 130, null, array['317T']::text[], array['305T', '306T']::text[], null, null, true, false, null, 'ƏDV bəyannaməsi (2026-cı il forması), sətir 327 = 317 + 319 − 305 − 306 − 318 − 324 (modelləşdirilən sətirlər)', 'vat-return-form')
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
  ('AZ-BS', 'AZ', 'default', 'Maliyyə vəziyyəti haqqında hesabat (balans)', 'balance_sheet', 'AZ-CHART', date '1970-01-01', null, 'Azərbaycan Respublikasının «Mühasibat uçotu haqqında» Qanunu, maddə 6 — maliyyə hesabatları MHBS, KOS üçün MHBS və ya (mikro və kiçik sahibkarlıq subyektləri üçün) sadələşdirilmiş milli qaydalara əsasən tərtib edilir; qanun balansın vahid məcburi sətirlərini müəyyən etmir. Bu pack MHBS-nin maliyyə vəziyyəti haqqında hesabatının minimal qruplaşdırmasından və hesablar planının iki rəqəmli qruplarından (10-19, 20-24, 30-34, 40-44, 50-54) istifadə edir.', 'accounting-law'),
  ('AZ-IS', 'AZ', 'default', 'Mənfəət və zərər haqqında hesabat', 'income_statement', 'AZ-CHART', date '1970-01-01', null, 'Azərbaycan Respublikasının «Mühasibat uçotu haqqında» Qanunu, maddə 6 — qanun mənfəət və zərər haqqında hesabatın vahid məcburi sətirlərini müəyyən etmir; bu pack hesablar planının 6-7-ci bölmələrini (gəlirlər, xərclər) və 90-cı qrupunu (mənfəət vergisi) xərclərin funksiyasına görə qruplaşdırır.', 'accounting-law')
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
  ('AZ-BS', 'A-NC-INT', 'A-NC', 'Qeyri-maddi aktivlər', '{"en":"Intangible assets"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-NC-PPE', 'A-NC', 'Torpaq, tikili və avadanlıqlar', '{"en":"Property, plant and equipment"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-NC-OTH', 'A-NC', 'Digər uzunmüddətli aktivlər', '{"en":"Other long-term assets"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-NC', null, 'Uzunmüddətli aktivlər', '{"en":"Long-term assets"}'::jsonb, 40, 1, true, array['A-NC-INT', 'A-NC-PPE', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-C-INV', 'A-C', 'Ehtiyatlar', '{"en":"Inventories"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-C-REC', 'A-C', 'Qısamüddətli debitor borcları', '{"en":"Short-term receivables"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-C-CASH', 'A-C', 'Pul vəsaitləri və onların ekvivalentləri', '{"en":"Cash and cash equivalents"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-C-OTH', 'A-C', 'Sair qısamüddətli maliyyə aktivləri və sair qısamüddətli aktivlər', '{"en":"Other short-term financial and other assets"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-C', null, 'Qısamüddətli aktivlər', '{"en":"Short-term assets"}'::jsonb, 90, 1, true, array['A-C-INV', 'A-C-REC', 'A-C-CASH', 'A-C-OTH']::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'A-TOT', null, 'AKTİVLƏR — CƏMİ', '{"en":"TOTAL ASSETS"}'::jsonb, 100, 1, true, array['A-NC', 'A-C']::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'E-CAP', 'E-TOT', 'Ödənilmiş nizamnamə kapitalı, emissiya gəliri və geri alınmış kapital', '{"en":"Paid-in capital, share premium and treasury shares"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'E-RES', 'E-TOT', 'Kapital ehtiyatları', '{"en":"Capital reserves"}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'E-RET', 'E-TOT', 'Bölüşdürülməmiş mənfəət (keçmiş illər, düzəlişlər, dividentlər)', '{"en":"Retained earnings (previous years, adjustments, dividends)"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'E-RESULT', 'E-TOT', 'Hesabat dövrünün nəticəsi (gəlir və xərc hesabları)', '{"en":"Result of the period (income and expense accounts)"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'E-TOT', null, 'KAPİTAL — CƏMİ', '{"en":"TOTAL EQUITY"}'::jsonb, 150, 1, true, array['E-CAP', 'E-RES', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-NC', 'L-TOT', 'Uzunmüddətli öhdəliklər', '{"en":"Long-term liabilities"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-C-DEBT', 'L-C', 'Qısamüddətli faiz xərcləri yaradan öhdəliklər və qiymətləndirilmiş öhdəliklər', '{"en":"Short-term interest-bearing liabilities and provisions"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-C-TAX', 'L-C', 'Vergi və sair məcburi ödənişlər üzrə öhdəliklər', '{"en":"Tax and other compulsory payment liabilities"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-C-PAY', 'L-C', 'Qısamüddətli kreditor borcları', '{"en":"Short-term payables"}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-C-OTH', 'L-C', 'Sair qısamüddətli öhdəliklər', '{"en":"Other short-term liabilities"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-C', null, 'Qısamüddətli öhdəliklər', '{"en":"Short-term liabilities"}'::jsonb, 210, 1, true, array['L-C-DEBT', 'L-C-TAX', 'L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'L-TOT', null, 'ÖHDƏLİKLƏR — CƏMİ', '{"en":"TOTAL LIABILITIES"}'::jsonb, 220, 1, true, array['L-NC', 'L-C']::text[], '{}'::text[], null, null, null),
  ('AZ-BS', 'EL-TOT', null, 'KAPİTAL VƏ ÖHDƏLİKLƏR — CƏMİ', '{"en":"TOTAL EQUITY AND LIABILITIES"}'::jsonb, 230, 1, true, array['E-TOT', 'L-TOT']::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'REV', null, 'Əsas əməliyyat gəliri (satış, qaytarılmalar və güzəştlər)', '{"en":"Revenue (sales, returns and discounts)"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'COST', null, 'Satışın maya dəyəri', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'GROSS', null, 'Ümumi mənfəət', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('AZ-IS', 'OTH-INC', null, 'Sair əməliyyat gəlirləri və digər gəlirlər', '{"en":"Other operating and other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'SELL', null, 'Kommersiya xərcləri', '{"en":"Selling expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'ADMIN', null, 'İnzibati xərclər', '{"en":"Administrative expenses"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'OTH-EXP', null, 'Sair əməliyyat xərcləri və digər xərclər', '{"en":"Other operating and other expenses"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'FIN-INC', null, 'Maliyyə gəlirləri', '{"en":"Finance income"}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'FIN-EXP', null, 'Maliyyə xərcləri', '{"en":"Finance expenses"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'PBT', null, 'Mənfəət vergisindən əvvəl mənfəət', '{"en":"Profit before profit tax"}'::jsonb, 100, 1, true, array['GROSS', 'OTH-INC', 'FIN-INC']::text[], array['SELL', 'ADMIN', 'OTH-EXP', 'FIN-EXP']::text[], null, null, null),
  ('AZ-IS', 'TAX', null, 'Mənfəət vergisi', '{"en":"Profit tax"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('AZ-IS', 'PROFIT', null, 'Hesabat dövrünün xalis mənfəəti (zərəri)', '{"en":"Net profit (loss) of the period"}'::jsonb, 120, 1, true, array['PBT']::text[], array['TAX']::text[], null, null, null)
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
    ('AZ-BS', 'A-NC-INT', 10, 'code_prefix', '10', null, null, 'any'),
    ('AZ-BS', 'A-NC-PPE', 10, 'code_prefix', '11', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 10, 'code_prefix', '12', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 20, 'code_prefix', '13', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 30, 'code_prefix', '14', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 40, 'code_prefix', '15', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 50, 'code_prefix', '16', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 60, 'code_prefix', '17', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 70, 'code_prefix', '18', null, null, 'any'),
    ('AZ-BS', 'A-NC-OTH', 80, 'code_prefix', '19', null, null, 'any'),
    ('AZ-BS', 'A-C-INV', 10, 'code_prefix', '20', null, null, 'any'),
    ('AZ-BS', 'A-C-REC', 10, 'code_prefix', '21', null, null, 'any'),
    ('AZ-BS', 'A-C-CASH', 10, 'code_prefix', '22', null, null, 'any'),
    ('AZ-BS', 'A-C-OTH', 10, 'code_prefix', '23', null, null, 'any'),
    ('AZ-BS', 'A-C-OTH', 20, 'code_prefix', '24', null, null, 'any'),
    ('AZ-BS', 'E-CAP', 10, 'code_prefix', '30', null, null, 'any'),
    ('AZ-BS', 'E-CAP', 20, 'code_prefix', '31', null, null, 'any'),
    ('AZ-BS', 'E-CAP', 30, 'code_prefix', '32', null, null, 'any'),
    ('AZ-BS', 'E-RES', 10, 'code_prefix', '33', null, null, 'any'),
    ('AZ-BS', 'E-RET', 10, 'code_prefix', '34', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 10, 'code_prefix', '60', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 20, 'code_prefix', '61', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 30, 'code_prefix', '62', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 40, 'code_prefix', '63', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 50, 'code_prefix', '64', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 60, 'code_prefix', '70', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 70, 'code_prefix', '71', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 80, 'code_prefix', '72', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 90, 'code_prefix', '73', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 100, 'code_prefix', '74', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 110, 'code_prefix', '75', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 120, 'code_prefix', '76', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 130, 'code_prefix', '80', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 140, 'code_prefix', '81', null, null, 'any'),
    ('AZ-BS', 'E-RESULT', 150, 'code_prefix', '90', null, null, 'any'),
    ('AZ-BS', 'L-NC', 10, 'code_prefix', '40', null, null, 'any'),
    ('AZ-BS', 'L-NC', 20, 'code_prefix', '41', null, null, 'any'),
    ('AZ-BS', 'L-NC', 30, 'code_prefix', '42', null, null, 'any'),
    ('AZ-BS', 'L-NC', 40, 'code_prefix', '43', null, null, 'any'),
    ('AZ-BS', 'L-NC', 50, 'code_prefix', '44', null, null, 'any'),
    ('AZ-BS', 'L-C-DEBT', 10, 'code_prefix', '50', null, null, 'any'),
    ('AZ-BS', 'L-C-DEBT', 20, 'code_prefix', '51', null, null, 'any'),
    ('AZ-BS', 'L-C-TAX', 10, 'code_prefix', '52', null, null, 'any'),
    ('AZ-BS', 'L-C-PAY', 10, 'code_prefix', '53', null, null, 'any'),
    ('AZ-BS', 'L-C-OTH', 10, 'code_prefix', '54', null, null, 'any'),
    ('AZ-IS', 'REV', 10, 'code_prefix', '60', null, null, 'any'),
    ('AZ-IS', 'COST', 10, 'code_prefix', '70', null, null, 'any'),
    ('AZ-IS', 'OTH-INC', 10, 'code_prefix', '61', null, null, 'any'),
    ('AZ-IS', 'OTH-INC', 20, 'code_prefix', '62', null, null, 'any'),
    ('AZ-IS', 'OTH-INC', 30, 'code_prefix', '64', null, null, 'any'),
    ('AZ-IS', 'OTH-INC', 40, 'code_prefix', '81', null, null, 'any'),
    ('AZ-IS', 'SELL', 10, 'code_prefix', '71', null, null, 'any'),
    ('AZ-IS', 'ADMIN', 10, 'code_prefix', '72', null, null, 'any'),
    ('AZ-IS', 'OTH-EXP', 10, 'code_prefix', '73', null, null, 'any'),
    ('AZ-IS', 'OTH-EXP', 20, 'code_prefix', '74', null, null, 'any'),
    ('AZ-IS', 'OTH-EXP', 30, 'code_prefix', '76', null, null, 'any'),
    ('AZ-IS', 'FIN-INC', 10, 'code_prefix', '63', null, null, 'any'),
    ('AZ-IS', 'FIN-EXP', 10, 'code_prefix', '75', null, null, 'any'),
    ('AZ-IS', 'TAX', 10, 'code_prefix', '90', null, null, 'any')
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
  ('AZ', 'Azərbaycan', '{"en":"Azerbaijan"}'::jsonb, array['az', 'en']::text[], 'AZN', '211', '531', '545', '731', '343', '601', '701', '223', '221', 'SAL', 'PUR', 'GEN', 'az', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '611', '731', '611', '731', null, null, '521', '241', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Vergi Məcəlləsi, maddə 175.1 və ƏDV kitabçası — ƏDV ödəyicisi arasında əməliyyat elektron qaimə-fakturanın (EQF) vergi orqanının sistemində (e-taxes.gov.az) yazılması ilə rəsmiləşdirilir; EQF-nin seriya və nömrəsini sistem verir və kommersiya sənədinin öz nömrələnməsindən asılı deyil. Kommersiya sənədinin nömrə formatını qanun məcburi etmir — burada göstərilən ardıcıl nömrələmə nümunədir.',
  numbering_source_key          = 'vat-booklet',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'payment_date',
  tax_point_legal_reference     = 'ƏDV kitabçası, «Vergi tutulan əməliyyatın aparıldığı vaxt və idxalın vaxtı» — vergi tutulan əməliyyatın vaxtı təqdim edilən mallar (işlər və xidmətlər) üçün ödəmənin aparıldığı vaxtdır (nağd vəsaitin alındığı, nağdsız ödəmədə vəsaitin bank hesabına daxil olduğu, NKA çekinin vurulduğu, qarşılıqlı hesablaşmada öhdəliyin ləğv edildiyi vaxt); ödəmə mallar təqdim edilənədək aparılıbsa, ödəmənin vaxtıdır; iki və ya daha çox ödəmə olarsa, hər ödəniş ayrıca əməliyyatdır. Bu qaydadan ƏDV vergisinin özü nağd əsasla (`cash_basis`) hesablanır.',
  tax_point_source_key          = 'vat-booklet',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Vergi Məcəlləsi və EQF qaydaları — təqdim edilmiş elektron qaimə-faktura silinmir, düzəliş yeni (düzəliş) EQF ilə rəsmiləşdirilir; «Mühasibat uçotu haqqında» Qanun uçot qeydlərinin izsiz dəyişdirilməsini qadağan edir. Konkret maddə nömrəsi yerli mühasib tərəfindən təsdiqlənməlidir.',
  posted_edit_policy_source_key = 'accounting-law',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'ƏDV kitabçası: ƏDV ödəyicisi vergi ödəyicisi olan alıcıya elektron qaimə-faktura verməlidir və alıcı yalnız alınmış elektron qaimə-faktura üzrə ƏDV-ni əvəzləşdirə bilər; EQF Dövlət Vergi Xidmətinin e-taxes.gov.az sistemində tərtib edilir və göndərilir (dövlət tərəfindən təsdiqləmə — clearance tipli sistem). Bu mexanizm EN 16931 semantik modelinə (Peppol BIS, Factur-X, XRechnung, PINT) əsaslanmır və ISO 6523 iştirakçı sxemini istifadə etmir — buna görə `profile`, `party_scheme`, `vat_scheme` boşdur. Məcburiliyin başlanğıc tarixi rəsmi mətndə təsdiqlənmədiyi üçün `obligation` və `mandatory_from` göstərilmir. Real vaxtda dövlət sisteminə yazılma, 2026-cı ildən təkrarlanan xidmətlər üçün ayda bir EQF (maddə 71-1.1.3-2) və sistemlə bağlı qalan hər şey pack-ın hüdudlarından kənardadır — README və docs/international.md «From Azerbaijan» bölməsinə bax.',
  einvoice_source_key           = 'vat-booklet',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'iban',
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'AZ';
