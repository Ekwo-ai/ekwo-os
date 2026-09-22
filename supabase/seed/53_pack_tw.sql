-- Ekwo OS — 臺灣: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/tw at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build tw`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   加值型及非加值型營業稅法 — Value-Added and Non-Value-Added Business Tax Act (全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice))
--     https://law.moj.gov.tw/ENG/LawClass/LawAll.aspx?pcode=G0340080
--   所得稅法第23條 — Income Tax Act, article 23 (the accounting year) (全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice))
--     https://law.moj.gov.tw/LawClass/LawSingle.aspx?pcode=G0340003&flno=23
--   商業會計法 — Business Accounting Act (全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice))
--     https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=J0080009
--   商業會計處理準則 — Regulations Governing Business Entity Accounting Handling (全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice))
--     https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=J0080010
--   商業會計項目表（112年度及以後適用版本） — Business Accounting Items Table, issued under article 27 of the Business Accounting Act (經濟部商業發展署 Department of Commerce, Ministry of Economic Affairs)
--     https://gcis.nat.gov.tw/F/t70492_p
--   營業人銷售額與稅額申報書及說明欄（401、403及404）A4格式 — General Business Entity Sales Amount and Tax Amount Return, form 401 and its notes (財政部稅務入口網 Ministry of Finance e-Tax Portal)
--     https://www.etax.nat.gov.tw/etwmain/api/functions/etw212w/download/189b50a490600000c0cddfef1a752804/%E7%87%9F%E6%A5%AD%E4%BA%BA%E9%8A%B7%E5%94%AE%E9%A1%8D%E8%88%87%E7%A8%85%E9%A1%8D%E7%94%B3%E5%A0%B1%E6%9B%B8%E5%8F%8A%E8%AA%AA%E6%98%8E%E6%AC%84(401%E3%80%81403%E5%8F%8A404)A4%E6%A0%BC%E5%BC%8F.pdf
--   統一發票使用辦法 — Uniform Invoice Using Method (全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice))
--     https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=G0340082
--   電子發票實施作業要點 — Electronic Invoice Implementation Points (財政部 Ministry of Finance)
--     https://law-out.mof.gov.tw/LawContent.aspx?id=FL041411
--   財政部電子發票整合服務平台 — Ministry of Finance Electronic Invoice Integration Service Platform (財政部 Ministry of Finance)
--     https://www.einvoice.nat.gov.tw/
--   自114年1月1日起調高小規模營業人營業稅起徵點 — Small-scale business entity threshold raised from 1 January 2025 (財政部稅務入口網 Ministry of Finance e-Tax Portal)
--     https://www.etax.nat.gov.tw/etwmain/tax-info/network-transaction-taxtation-area/press/PEwQK1V
--   財政部稅務入口網 — Ministry of Finance e-Tax Portal, where the return is filed (財政部 Ministry of Finance)
--     https://www.etax.nat.gov.tw/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('TW', '臺灣', '0.1.0', date '2026-09-22', '20260917170000', 'community', null, null, '5f67fdbac5053d2ceb447090e900b5f0f4a85d6de80fd75d05ef9ed55c680c4e', '[{"key":"bt-act","title":"加值型及非加值型營業稅法 — Value-Added and Non-Value-Added Business Tax Act","publisher":"全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice)","url":"https://law.moj.gov.tw/ENG/LawClass/LawAll.aspx?pcode=G0340080","consulted_on":"2026-09-22","kind":"law"},{"key":"income-tax-act","title":"所得稅法第23條 — Income Tax Act, article 23 (the accounting year)","publisher":"全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice)","url":"https://law.moj.gov.tw/LawClass/LawSingle.aspx?pcode=G0340003&flno=23","consulted_on":"2026-09-22","kind":"law"},{"key":"accounting-act","title":"商業會計法 — Business Accounting Act","publisher":"全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice)","url":"https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=J0080009","consulted_on":"2026-09-22","kind":"law"},{"key":"accounting-rules","title":"商業會計處理準則 — Regulations Governing Business Entity Accounting Handling","publisher":"全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice)","url":"https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=J0080010","consulted_on":"2026-09-22","kind":"regulation"},{"key":"accounting-items-table","title":"商業會計項目表（112年度及以後適用版本） — Business Accounting Items Table, issued under article 27 of the Business Accounting Act","publisher":"經濟部商業發展署 Department of Commerce, Ministry of Economic Affairs","url":"https://gcis.nat.gov.tw/F/t70492_p","consulted_on":"2026-09-22","kind":"regulation"},{"key":"form-401","title":"營業人銷售額與稅額申報書及說明欄（401、403及404）A4格式 — General Business Entity Sales Amount and Tax Amount Return, form 401 and its notes","publisher":"財政部稅務入口網 Ministry of Finance e-Tax Portal","url":"https://www.etax.nat.gov.tw/etwmain/api/functions/etw212w/download/189b50a490600000c0cddfef1a752804/%E7%87%9F%E6%A5%AD%E4%BA%BA%E9%8A%B7%E5%94%AE%E9%A1%8D%E8%88%87%E7%A8%85%E9%A1%8D%E7%94%B3%E5%A0%B1%E6%9B%B8%E5%8F%8A%E8%AA%AA%E6%98%8E%E6%AC%84(401%E3%80%81403%E5%8F%8A404)A4%E6%A0%BC%E5%BC%8F.pdf","consulted_on":"2026-09-22","kind":"form"},{"key":"uniform-invoice-rules","title":"統一發票使用辦法 — Uniform Invoice Using Method","publisher":"全國法規資料庫 Laws & Regulations Database of the Republic of China (Ministry of Justice)","url":"https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=G0340082","consulted_on":"2026-09-22","kind":"regulation"},{"key":"einvoice-rules","title":"電子發票實施作業要點 — Electronic Invoice Implementation Points","publisher":"財政部 Ministry of Finance","url":"https://law-out.mof.gov.tw/LawContent.aspx?id=FL041411","consulted_on":"2026-09-22","kind":"regulation"},{"key":"einvoice-portal","title":"財政部電子發票整合服務平台 — Ministry of Finance Electronic Invoice Integration Service Platform","publisher":"財政部 Ministry of Finance","url":"https://www.einvoice.nat.gov.tw/","consulted_on":"2026-09-22","kind":"portal"},{"key":"small-scale-threshold","title":"自114年1月1日起調高小規模營業人營業稅起徵點 — Small-scale business entity threshold raised from 1 January 2025","publisher":"財政部稅務入口網 Ministry of Finance e-Tax Portal","url":"https://www.etax.nat.gov.tw/etwmain/tax-info/network-transaction-taxtation-area/press/PEwQK1V","consulted_on":"2026-09-22","kind":"guidance"},{"key":"etax-portal","title":"財政部稅務入口網 — Ministry of Finance e-Tax Portal, where the return is filed","publisher":"財政部 Ministry of Finance","url":"https://www.etax.nat.gov.tw/","consulted_on":"2026-09-22","kind":"portal"}]'::jsonb)
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
  ('TW', 'default', '商業會計項目表（節錄） — Business Accounting Items Table, abridged', '{"en":"Business Accounting Items Table (abridged)"}'::jsonb, true, 'companies', array['TW-BAA-BS', 'TW-BAA-IS']::text[], null, '商業會計法 (Business Accounting Act) article 27 — an accounting item is classified by the element of the financial statements it belongs to, and a business may add to or reduce them as actually needed ("商業得視實際需要增減之"). The codes and the Chinese and English names of every account of this chart are transcribed, unabridged where used, from 商業會計項目表 (the Business Accounting Items Table the Department of Commerce publishes under that article): 1111 is Cash on hand there and nowhere else. This chart carries a working subset of a table that runs to several hundred items across financial instruments, biological assets and construction contracts this pack''s companies do not need; nothing renamed, nothing renumbered, and no code invented that the table does not carry, except the one rounding account it does not provide for and 401 asks a return to be filed in whole dollars, noted at its own row.', 'accounting-items-table')
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
  ('TW', 'default', '1111', '庫存現金', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 10),
  ('TW', 'default', '1112', '零用金／週轉金', '{"en":"Petty cash / revolving funds"}'::jsonb, 'asset_cash', false, null, 20),
  ('TW', 'default', '1113', '銀行存款', '{"en":"Cash in banks"}'::jsonb, 'asset_cash', false, null, 30),
  ('TW', 'default', '1182', '應收票據貼現', '{"en":"Discounted notes receivable"}'::jsonb, 'asset_current', false, null, 40),
  ('TW', 'default', '1184', '其他應收票據', '{"en":"Other notes receivable"}'::jsonb, 'asset_current', false, null, 50),
  ('TW', 'default', '1185', '備抵損失－應收票據', '{"en":"Loss allowance, notes receivable"}'::jsonb, 'asset_current', false, null, 60),
  ('TW', 'default', '1191', '應收帳款', '{"en":"Accounts receivable"}'::jsonb, 'asset_receivable', true, null, 70),
  ('TW', 'default', '1192', '備抵銷售退回及折讓', '{"en":"Allowance for sales returns and allowances"}'::jsonb, 'asset_current', false, null, 80),
  ('TW', 'default', '1193', '應收分期帳款', '{"en":"Installment accounts receivable"}'::jsonb, 'asset_current', false, null, 90),
  ('TW', 'default', '1199', '備抵損失－應收帳款', '{"en":"Loss allowance, accounts receivable"}'::jsonb, 'asset_current', false, null, 100),
  ('TW', 'default', '1211', '應收收益', '{"en":"Non-operating revenues receivable"}'::jsonb, 'asset_current', false, null, 110),
  ('TW', 'default', '1212', '其他應收款－關係人', '{"en":"Other receivables due from related parties"}'::jsonb, 'asset_current', false, null, 120),
  ('TW', 'default', '1213', '其他應收款－其他', '{"en":"Other receivables, others"}'::jsonb, 'asset_current', false, null, 130),
  ('TW', 'default', '1222', '預付所得稅', '{"en":"Prepaid income tax"}'::jsonb, 'asset_current', false, null, 140),
  ('TW', 'default', '1231', '商品存貨', '{"en":"Merchandise inventory"}'::jsonb, 'asset_current', false, null, 150),
  ('TW', 'default', '1232', '寄銷品', '{"en":"Goods on consignment"}'::jsonb, 'asset_current', false, null, 160),
  ('TW', 'default', '1233', '在途商品', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 170),
  ('TW', 'default', '1235', '製成品', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 190),
  ('TW', 'default', '1236', '副產品', '{"en":"By-products"}'::jsonb, 'asset_current', false, null, 180),
  ('TW', 'default', '1237', '在製品', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 200),
  ('TW', 'default', '1239', '原料', '{"en":"Raw materials"}'::jsonb, 'asset_current', false, null, 210),
  ('TW', 'default', '1240', '物料', '{"en":"Supplies"}'::jsonb, 'asset_current', false, null, 220),
  ('TW', 'default', '1243', '農業產品', '{"en":"Agricultural produce"}'::jsonb, 'asset_current', false, null, 230),
  ('TW', 'default', '1244', '在建工程', '{"en":"Construction in progress"}'::jsonb, 'asset_fixed', false, null, 240),
  ('TW', 'default', '1261', '預付薪資', '{"en":"Advance wages and salaries"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('TW', 'default', '1262', '預付租金', '{"en":"Prepaid rents"}'::jsonb, 'asset_prepayments', false, null, 260),
  ('TW', 'default', '1263', '預付保險費', '{"en":"Prepaid insurance premiums"}'::jsonb, 'asset_prepayments', false, null, 270),
  ('TW', 'default', '1264', '用品盤存', '{"en":"Office supplies inventory"}'::jsonb, 'asset_current', false, null, 280),
  ('TW', 'default', '1265', '其他預付費用', '{"en":"Other prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 290),
  ('TW', 'default', '1266', '預付貨款', '{"en":"Prepayments to suppliers"}'::jsonb, 'asset_current', false, null, 300),
  ('TW', 'default', '1267', '預付投資款', '{"en":"Current prepayments for investments"}'::jsonb, 'asset_current', false, null, 310),
  ('TW', 'default', '1268', '進項稅額', '{"en":"Business tax paid (input VAT)"}'::jsonb, 'asset_current', false, null, 320),
  ('TW', 'default', '1269', '留抵稅額', '{"en":"Excess business tax paid (input VAT carried forward)"}'::jsonb, 'asset_current', true, null, 330),
  ('TW', 'default', '1270', '其他預付款項', '{"en":"Other prepayments"}'::jsonb, 'asset_prepayments', false, null, 340),
  ('TW', 'default', '1281', '暫付款', '{"en":"Temporary debits"}'::jsonb, 'asset_current', false, null, 350),
  ('TW', 'default', '1282', '代付款', '{"en":"Payment on behalf of others"}'::jsonb, 'asset_current', false, null, 360),
  ('TW', 'default', '1283', '員工借支', '{"en":"Advances to employees"}'::jsonb, 'asset_current', false, null, 370),
  ('TW', 'default', '1391', '土地－成本', '{"en":"Land, cost"}'::jsonb, 'asset_fixed', false, null, 380),
  ('TW', 'default', '1411', '房屋及建築－成本', '{"en":"Buildings and structures, cost"}'::jsonb, 'asset_fixed', false, null, 390),
  ('TW', 'default', '1413', '累計折舊－房屋及建築', '{"en":"Accumulated depreciation, buildings and structures"}'::jsonb, 'asset_fixed', false, null, 400),
  ('TW', 'default', '1421', '機器設備－成本', '{"en":"Machinery and equipment, cost"}'::jsonb, 'asset_fixed', false, null, 410),
  ('TW', 'default', '1422', '累計折舊－機器設備', '{"en":"Accumulated depreciation, machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 420),
  ('TW', 'default', '1431', '辦公設備－成本', '{"en":"Office equipment, cost"}'::jsonb, 'asset_fixed', false, null, 430),
  ('TW', 'default', '1432', '累計折舊－辦公設備', '{"en":"Accumulated depreciation, office equipment"}'::jsonb, 'asset_fixed', false, null, 440),
  ('TW', 'default', '1531', '電腦軟體－成本', '{"en":"Computer software, cost"}'::jsonb, 'asset_fixed', false, null, 450),
  ('TW', 'default', '1533', '累計攤銷－電腦軟體', '{"en":"Accumulated amortization, computer software"}'::jsonb, 'asset_fixed', false, null, 460),
  ('TW', 'default', '1541', '商譽－成本', '{"en":"Goodwill, cost"}'::jsonb, 'asset_non_current', false, null, 470),
  ('TW', 'default', '1561', '遞延所得稅資產', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 480),
  ('TW', 'default', '1583', '存出保證金', '{"en":"Guarantee deposits paid"}'::jsonb, 'asset_non_current', false, null, 490),
  ('TW', 'default', '2111', '銀行透支', '{"en":"Bank overdrafts"}'::jsonb, 'liability_current', false, null, 500),
  ('TW', 'default', '2112', '銀行借款', '{"en":"Bank loan"}'::jsonb, 'liability_current', false, null, 510),
  ('TW', 'default', '2161', '應付票據', '{"en":"Notes payable"}'::jsonb, 'liability_current', false, null, 520),
  ('TW', 'default', '2162', '應付票據－關係人', '{"en":"Notes payable to related parties"}'::jsonb, 'liability_current', false, null, 530),
  ('TW', 'default', '2171', '應付帳款', '{"en":"Accounts payable"}'::jsonb, 'liability_payable', true, null, 540),
  ('TW', 'default', '2191', '應付薪資', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', false, null, 550),
  ('TW', 'default', '2192', '應付租金', '{"en":"Rents payable"}'::jsonb, 'liability_current', false, null, 560),
  ('TW', 'default', '2193', '應付利息', '{"en":"Interest payable"}'::jsonb, 'liability_current', false, null, 570),
  ('TW', 'default', '2194', '應付營業稅', '{"en":"Business tax payable"}'::jsonb, 'liability_current', true, null, 580),
  ('TW', 'default', '2195', '應付稅捐－其他', '{"en":"Other tax payable"}'::jsonb, 'liability_current', false, null, 590),
  ('TW', 'default', '2196', '應付退休金費用', '{"en":"Pension expense payable"}'::jsonb, 'liability_current', false, null, 600),
  ('TW', 'default', '2197', '其他應付費用', '{"en":"Other accrued expenses"}'::jsonb, 'liability_current', false, null, 610),
  ('TW', 'default', '2199', '應付設備款', '{"en":"Payable on machinery and equipment"}'::jsonb, 'liability_current', false, null, 620),
  ('TW', 'default', '2201', '應付股利', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 630),
  ('TW', 'default', '2204', '銷項稅額', '{"en":"Business tax received (output VAT)"}'::jsonb, 'liability_current', false, null, 640),
  ('TW', 'default', '2211', '本期所得稅負債', '{"en":"Current tax liabilities"}'::jsonb, 'liability_current', false, null, 650),
  ('TW', 'default', '2221', '預收貨款', '{"en":"Advance sales receipts"}'::jsonb, 'liability_current', false, null, 660),
  ('TW', 'default', '2232', '一年內到期長期借款', '{"en":"Long-term borrowings, current portion"}'::jsonb, 'liability_current', false, null, 670),
  ('TW', 'default', '2251', '暫收款', '{"en":"Temporary credits"}'::jsonb, 'liability_current', true, null, 680),
  ('TW', 'default', '2351', '長期銀行借款', '{"en":"Long-term bank loans"}'::jsonb, 'liability_non_current', false, null, 690),
  ('TW', 'default', '2372', '除役、復原及修復成本之長期負債準備', '{"en":"Long-term provision for decommissioning, restoration and rehabilitation costs"}'::jsonb, 'liability_non_current', false, null, 700),
  ('TW', 'default', '2382', '遞延所得稅負債', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 710),
  ('TW', 'default', '2391', '遞延收入', '{"en":"Unearned revenue"}'::jsonb, 'liability_non_current', false, null, 720),
  ('TW', 'default', '2392', '存入保證金', '{"en":"Guarantee deposits received"}'::jsonb, 'liability_non_current', false, null, 730),
  ('TW', 'default', '3111', '普通股股本', '{"en":"Ordinary share capital"}'::jsonb, 'equity', false, null, 740),
  ('TW', 'default', '3113', '預收股本', '{"en":"Advance receipts for ordinary share"}'::jsonb, 'equity', false, null, 750),
  ('TW', 'default', '3211', '資本公積', '{"en":"Capital surplus"}'::jsonb, 'equity', false, null, 760),
  ('TW', 'default', '3311', '法定盈餘公積', '{"en":"Legal reserve"}'::jsonb, 'equity_retained', false, null, 770),
  ('TW', 'default', '3321', '特別盈餘公積', '{"en":"Special reserve"}'::jsonb, 'equity_retained', false, null, 780),
  ('TW', 'default', '3351', '累積盈虧', '{"en":"Accumulated profit and loss"}'::jsonb, 'equity_retained', false, null, 790),
  ('TW', 'default', '3352', '追溯適用及追溯重編之影響數', '{"en":"Effect of retrospective application and restatement"}'::jsonb, 'equity_retained', false, null, 800),
  ('TW', 'default', '3511', '庫藏股票', '{"en":"Treasury shares"}'::jsonb, 'equity', false, null, 810),
  ('TW', 'default', '4111', '銷貨收入', '{"en":"Sales revenue"}'::jsonb, 'income', false, null, 820),
  ('TW', 'default', '4113', '銷貨退回', '{"en":"Sales returns"}'::jsonb, 'income', false, null, 830),
  ('TW', 'default', '4114', '銷貨折讓', '{"en":"Sales discounts and allowances"}'::jsonb, 'income', false, null, 840),
  ('TW', 'default', '4121', '勞務收入', '{"en":"Service revenue"}'::jsonb, 'income', false, null, 850),
  ('TW', 'default', '4141', '其他營業收入', '{"en":"Other operating revenue"}'::jsonb, 'income_other', false, null, 860),
  ('TW', 'default', '5111', '銷貨成本', '{"en":"Cost of sales"}'::jsonb, 'expense_direct_cost', false, null, 870),
  ('TW', 'default', '5121', '進貨', '{"en":"Purchase of goods"}'::jsonb, 'expense_direct_cost', false, null, 880),
  ('TW', 'default', '5122', '進貨費用', '{"en":"Purchasing expense"}'::jsonb, 'expense_direct_cost', false, null, 890),
  ('TW', 'default', '5123', '進貨退出', '{"en":"Purchases returns"}'::jsonb, 'expense_direct_cost', false, null, 900),
  ('TW', 'default', '5124', '進貨折讓', '{"en":"Purchases discounts and allowances"}'::jsonb, 'expense_direct_cost', false, null, 910),
  ('TW', 'default', '5141', '直接人工', '{"en":"Direct labor"}'::jsonb, 'expense_direct_cost', false, null, 920),
  ('TW', 'default', '5165', '伙食費', '{"en":"Meal expense"}'::jsonb, 'expense_direct_cost', false, null, 930),
  ('TW', 'default', '5166', '職工福利', '{"en":"Employee benefits and welfare"}'::jsonb, 'expense_direct_cost', false, null, 940),
  ('TW', 'default', '5611', '勞務成本', '{"en":"Cost of services"}'::jsonb, 'expense_direct_cost', false, null, 950),
  ('TW', 'default', '5911', '其他營業成本', '{"en":"Other operating costs"}'::jsonb, 'expense_direct_cost', false, null, 960),
  ('TW', 'default', '6111', '薪資支出', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, null, 970),
  ('TW', 'default', '6112', '租金支出', '{"en":"Rent expense"}'::jsonb, 'expense', false, null, 980),
  ('TW', 'default', '6113', '文具用品', '{"en":"Stationery supplies"}'::jsonb, 'expense', false, null, 990),
  ('TW', 'default', '6114', '旅費', '{"en":"Traveling expense"}'::jsonb, 'expense', false, null, 1000),
  ('TW', 'default', '6115', '運費', '{"en":"Freight"}'::jsonb, 'expense', false, null, 1010),
  ('TW', 'default', '6116', '郵電費', '{"en":"Postage expenses"}'::jsonb, 'expense', false, null, 1020),
  ('TW', 'default', '6117', '修繕費', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 1030),
  ('TW', 'default', '6118', '廣告費', '{"en":"Advertisement expense"}'::jsonb, 'expense', false, null, 1040),
  ('TW', 'default', '6119', '水電瓦斯費', '{"en":"Utilities expense"}'::jsonb, 'expense', false, null, 1050),
  ('TW', 'default', '6120', '保險費', '{"en":"Insurance expense"}'::jsonb, 'expense', false, null, 1060),
  ('TW', 'default', '6121', '交際費', '{"en":"Entertainment expense"}'::jsonb, 'expense', false, null, 1070),
  ('TW', 'default', '6122', '捐贈', '{"en":"Donation expense"}'::jsonb, 'expense', false, null, 1080),
  ('TW', 'default', '6123', '稅捐', '{"en":"Taxes"}'::jsonb, 'expense', false, null, 1090),
  ('TW', 'default', '6124', '呆帳損失', '{"en":"Losses on doubtful debts"}'::jsonb, 'expense', false, null, 1100),
  ('TW', 'default', '6125', '折舊', '{"en":"Depreciation"}'::jsonb, 'expense_depreciation', false, null, 1110),
  ('TW', 'default', '6126', '各項耗竭及攤提', '{"en":"Depletions and amortizations"}'::jsonb, 'expense_depreciation', false, null, 1120),
  ('TW', 'default', '6129', '職工福利', '{"en":"Employee benefits and welfare"}'::jsonb, 'expense', false, null, 1130),
  ('TW', 'default', '6130', '研究發展費用', '{"en":"Research and development expense"}'::jsonb, 'expense', false, null, 1140),
  ('TW', 'default', '6131', '佣金支出', '{"en":"Commissions expense"}'::jsonb, 'expense', false, null, 1150),
  ('TW', 'default', '6133', '勞務費', '{"en":"Services expense"}'::jsonb, 'expense', false, null, 1160),
  ('TW', 'default', '6134', '其他營業費用', '{"en":"Other operating expenses"}'::jsonb, 'expense', false, null, 1170),
  ('TW', 'default', '6135', '元捨去差額調整', '{"en":"Rounding adjustment"}'::jsonb, 'expense', false, null, 1180),
  ('TW', 'default', '7111', '利息收入', '{"en":"Interest revenue"}'::jsonb, 'income_other', false, null, 1190),
  ('TW', 'default', '7121', '租金收入', '{"en":"Rent income"}'::jsonb, 'income_other', false, null, 1200),
  ('TW', 'default', '7131', '權利金收入', '{"en":"Royalty income"}'::jsonb, 'income_other', false, null, 1210),
  ('TW', 'default', '7141', '股利收入', '{"en":"Dividend revenue"}'::jsonb, 'income_other', false, null, 1220),
  ('TW', 'default', '7151', '利息費用', '{"en":"Interest expense"}'::jsonb, 'expense', false, null, 1230),
  ('TW', 'default', '7181', '兌換利益', '{"en":"Foreign exchange gains"}'::jsonb, 'income_other', false, null, 1240),
  ('TW', 'default', '7182', '兌換損失', '{"en":"Foreign exchange losses"}'::jsonb, 'expense', false, null, 1250),
  ('TW', 'default', '7193', '處分投資利益', '{"en":"Gains on disposals of investments"}'::jsonb, 'income_other', false, null, 1260),
  ('TW', 'default', '7201', '處分不動產、廠房及設備利益', '{"en":"Gains on disposals of property, plant and equipment"}'::jsonb, 'income_other', false, null, 1270),
  ('TW', 'default', '7202', '處分不動產、廠房及設備損失', '{"en":"Losses on disposals of property, plant and equipment"}'::jsonb, 'expense', false, null, 1280),
  ('TW', 'default', '7242', '災害損失', '{"en":"Losses on disaster"}'::jsonb, 'expense', false, null, 1290),
  ('TW', 'default', '8211', '所得稅費用（或利益）', '{"en":"Tax expense (income)"}'::jsonb, 'expense', false, null, 1300)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('TW', 'BNK', '銀行存款簿', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('TW', 'CSH', '現金簿', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('TW', 'GEN', '轉帳傳票', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('TW', 'OPN', '期初分錄', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('TW', 'PUR', '進貨簿', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('TW', 'SAL', '銷貨簿', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('TW', 'TW-P-5', '進貨及費用 5%（可扣抵）', '{"en":"Purchases and expenses 5% (deductible)"}'::jsonb, '得依統一發票扣抵聯或電子發票扣抵之進貨及費用', 'percent', 5, 'purchase', 'domestic', date '1986-04-01', null, '加值型及非加值型營業稅法第15條及第33條 — the input tax on a purchase of goods or services a general-method taxpayer holds a uniform invoice for is deducted from the output tax of the same period. Reported at form 401''s 進貨及費用 total row, base 44, tax 45. This pack declares that total row and not the finer breakdown by voucher type (三聯式發票, 二聯式發票, 載有稅額之其他憑證…) the printed form also carries, which the ledger has no fact to distinguish by — see the README.', 'S', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-P-5-FA', '購買固定資產 5%（可扣抵）', '{"en":"Purchase of fixed assets 5% (deductible)"}'::jsonb, '得依統一發票扣抵聯或電子發票扣抵之購買固定資產', 'percent', 5, 'purchase', 'domestic', date '1986-04-01', null, '加值型及非加值型營業稅法第15條及第33條, as TW-P-5, on the purchase of a fixed asset — form 401 keeps this on a column of its own, base 46, tax 47, because the refund cap and the deduction total (box 13, box 7) are worked out from the two columns together (box 107 = 45 + 47).', 'S', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-P-5-NC', '進貨及費用 5%（不得扣抵）', '{"en":"Purchases and expenses 5% (non-deductible)"}'::jsonb, '交際應酬、酬勞員工個人等不得扣抵之進項稅額', 'percent', 5, 'purchase', 'domestic', date '1986-04-01', null, '加值型及非加值型營業稅法第19條第1項 — the input tax on goods or services used for entertainment, or given as an employee''s own benefit rather than the business''s, is not deductible; it is part of the cost and lands on the account of the line taxed. Reported nowhere on form 401.', 'S', null, 90, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-P-EXO', '向免稅事業或小規模營業人進貨', '{"en":"Purchase from an exempt or small-scale entity"}'::jsonb, '供應商屬免稅或未使用統一發票，未載明營業稅額', 'percent', 0, 'purchase', 'exempt', date '1986-04-01', null, '加值型及非加值型營業稅法第8條, and article 13 for a small-scale entity taxed under the special 1% method — neither charges the buyer a business tax the buyer could deduct, so the line carries no input tax. Reported nowhere on form 401.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-P-IMP-5', '進口貨物 5%（海關代徵）', '{"en":"Import of goods 5% (levied by Customs)"}'::jsonb, '進口應稅貨物，由海關代徵營業稅', 'percent', 5, 'purchase', 'import', date '1986-04-01', null, '加值型及非加值型營業稅法第41條 — the business tax on an imported good is levied by Customs, under the Customs Act, at the time of clearance, and not through form 401; article 15 and 33 still let the importer deduct it in the period it is paid, on the strength of the customs authority''s own tax payment certificate (海關代徵營業稅繳納證) rather than a supplier''s uniform invoice. The counterpart of the tax lands on the customs-clearance account rather than on the supplier, and the deduction is reported at the same total row as TW-P-5 (base 44, tax 45): form 401 keeps a voucher-type breakdown of that row this pack does not model (see the README).', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-P-NA', '非屬營業稅課稅範圍之進項', '{"en":"Purchase outside the scope of business tax"}'::jsonb, '薪資、稅捐等非屬進貨或費用之支出', 'percent', 0, 'purchase', 'not_subject', date '1986-04-01', null, '加值型及非加值型營業稅法第1條 and article 19 — a wage, a statutory duty or tax, and any outlay that is not a purchase of goods or services from a business entity carries no business tax to begin with.', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-S-0-GOODS', '外銷貨物 零稅率', '{"en":"Export of goods, zero-rated"}'::jsonb, '外銷之貨物', 'percent', 0, 'sale', 'export', date '1986-04-01', null, '加值型及非加值型營業稅法第7條第1款 — the sale of goods exported is zero-rated; the zero rate keeps the right to deduct the input tax on what went into it, unlike an exemption under article 8. Reported at the零稅率銷售額 column of form 401 (base 23, within the total 25), and at the refund-cap box 13 (得退稅限額合計), which this pack''s tax_report.json computes as 5% of that base.', 'G', null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-S-0-SVC', '外銷相關勞務或境內供境外使用之勞務 零稅率', '{"en":"Export-related or offshore-used services, zero-rated"}'::jsonb, '與外銷有關之勞務，或在中華民國境內提供而在境外使用之勞務', 'percent', 0, 'sale', 'export', date '1986-04-01', null, '加值型及非加值型營業稅法第7條第2款 — a service related to export, or a service supplied within the territory of the Republic of China but used in a foreign country, is zero-rated on the same footing as an exported good. Same boxes as TW-S-0-GOODS: this pack keeps the two apart because they are two different items of one article, the way packs/jp keeps its export-of-goods and export-of-services codes apart.', 'G', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-S-5', '銷售 5%（一般稅額計算）', '{"en":"Sale 5% (general tax calculation method)"}'::jsonb, '國內一般銷售貨物或勞務，加值型營業稅一般稅額計算方式', 'percent', 5, 'sale', 'domestic', date '1986-04-01', null, '加值型及非加值型營業稅法 (Business Tax Act) article 10 — the tax rate on a general-method taxpayer''s sale is not less than 5% and not more than 10%, the rate in force fixed by Executive Yuan order; it has stood at 5% since the value-added system itself took effect on 1 April 1986 (Ministry of Finance, 財政史料陳列室 archive). Reported in the general boxes of form 401 — sales base 21/25, output tax 22/101. This pack has not traced every Executive Yuan order since 1986 confirming no intervening change; a reviewer should hold this against the Ministry''s own rate table before relying on it for a period before this pack''s release.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-S-EXO-FIN', '金融、信託及保險業之銷售額 免稅', '{"en":"Banking, trust and insurance sales, exempt"}'::jsonb, '銀行業、保險業、信託投資業、證券業、期貨業、票券業及典當業經營之各種銀行、信託、證券、期貨及典當業務', 'percent', 0, 'sale', 'exempt', date '1986-04-01', null, '加值型及非加值型營業稅法第8條第1項第22款 — the banking, trust, securities, futures, bill and pawnbroking transactions of a business licensed to conduct them are exempt (a bank''s core business is instead taxed under article 11''s gross-receipts special rate, which this pack does not carry — see the README). This code is for the exempt insurance and financial income an ordinary company outside those licensed sectors occasionally books, such as an interest-bearing loan it is not in the business of making. Not reported on form 401, for the same reason as TW-S-EXO-LAND.', 'E', null, 50, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-S-EXO-LAND', '土地出售 免稅', '{"en":"Sale of land, exempt"}'::jsonb, '出售土地', 'percent', 0, 'sale', 'exempt', date '1986-04-01', null, '加值型及非加值型營業稅法第8條第1項第1款 — the sale of land is exempt. Form 401 is the return for a taxpayer whose sales are exclusively taxable and zero-rated (its own note 二: a taxpayer whose period includes an exempt or special-tax-calculation sale must file form 403 instead); this pack carries this code for its invoice treatment, its category and its legal reference, and its base posting names no box of TW-401 for exactly that reason — form 403''s own box layout could not be confirmed against an official Ministry of Finance publication, and is not modelled here. See this pack''s README.', 'E', null, 40, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null),
  ('TW', 'TW-S-NA', '非屬營業稅課稅範圍', '{"en":"Outside the scope of business tax"}'::jsonb, '非銷售貨物或勞務之收入，或中華民國境外之交易', 'percent', 0, 'sale', 'not_subject', date '1986-04-01', null, '加值型及非加值型營業稅法第1條 — the tax reaches only the sale of goods or services within the territory of the Republic of China and the import of goods; what is neither (compensation that is not consideration for a sale, a transaction that takes place outside the territory) is outside its scope and is reported nowhere on form 401.', 'O', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'bt-act', null, null, null, null)
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
    ('TW-P-5', 'invoice', 'base', 100, null, '44', array['44']::text[], 100, 'TW-401', 10),
    ('TW-P-5', 'invoice', 'tax', 100, '1268', '45', array['45']::text[], 100, 'TW-401', 20),
    ('TW-P-5', 'credit_note', 'base', 100, null, '44', array['44']::text[], -100, 'TW-401', 10),
    ('TW-P-5', 'credit_note', 'tax', 100, '1268', '45', array['45']::text[], -100, 'TW-401', 20),
    ('TW-P-5-FA', 'invoice', 'base', 100, null, '46', array['46']::text[], 100, 'TW-401', 10),
    ('TW-P-5-FA', 'invoice', 'tax', 100, '1268', '47', array['47']::text[], 100, 'TW-401', 20),
    ('TW-P-5-FA', 'credit_note', 'base', 100, null, '46', array['46']::text[], -100, 'TW-401', 10),
    ('TW-P-5-FA', 'credit_note', 'tax', 100, '1268', '47', array['47']::text[], -100, 'TW-401', 20),
    ('TW-P-5-NC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TW-P-5-NC', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('TW-P-5-NC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TW-P-5-NC', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('TW-P-EXO', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TW-P-EXO', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TW-P-IMP-5', 'invoice', 'base', 100, null, '44', array['44']::text[], 100, 'TW-401', 10),
    ('TW-P-IMP-5', 'invoice', 'tax', 100, '1268', '45', array['45']::text[], 100, 'TW-401', 20),
    ('TW-P-IMP-5', 'invoice', 'tax', -100, '2195', null, null, 100, null, 30),
    ('TW-P-IMP-5', 'credit_note', 'base', 100, null, '44', array['44']::text[], -100, 'TW-401', 10),
    ('TW-P-IMP-5', 'credit_note', 'tax', 100, '1268', '45', array['45']::text[], -100, 'TW-401', 20),
    ('TW-P-IMP-5', 'credit_note', 'tax', -100, '2195', null, null, -100, null, 30),
    ('TW-P-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TW-P-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TW-S-0-GOODS', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'TW-401', 10),
    ('TW-S-0-GOODS', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'TW-401', 10),
    ('TW-S-0-SVC', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'TW-401', 10),
    ('TW-S-0-SVC', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'TW-401', 10),
    ('TW-S-5', 'invoice', 'base', 100, null, '21', array['21']::text[], 100, 'TW-401', 10),
    ('TW-S-5', 'invoice', 'tax', 100, '2204', '22', array['22', '101']::text[], 100, 'TW-401', 20),
    ('TW-S-5', 'credit_note', 'base', 100, null, '21', array['21']::text[], -100, 'TW-401', 10),
    ('TW-S-5', 'credit_note', 'tax', 100, '2204', '22', array['22', '101']::text[], -100, 'TW-401', 20),
    ('TW-S-EXO-FIN', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TW-S-EXO-FIN', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TW-S-EXO-LAND', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TW-S-EXO-LAND', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TW-S-NA', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TW-S-NA', 'credit_note', 'base', 100, null, null, null, 100, null, 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'TW' and t.code = v.tax_code
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
  ('TW', 'TW-401', '營業人銷售額與稅額申報書（401）— General Business Entity Sales Amount and Tax Amount Return, general tax calculation method', array['month', 'bimonth']::declaration_period[], 'bimonth'::declaration_period, date '1986-04-01', null, '加值型及非加值型營業稅法第35條第1項 — a business entity files a return for each two-month period, before the fifteenth day of the month following it, whether or not it has any sale to report (paragraph 2 of the article requires a return even where none). Paragraph 2 also lets a taxpayer that only ever makes zero-rated sales ask to file monthly instead, once approved and for at least one year. Form 401 itself is the return for a taxpayer whose sales are exclusively taxable and zero-rated (its own note, transcribed here: "本申報書適用專營應稅及零稅率之營業人填報。如營業人申報當期（月）之銷售額包括有免稅、特種稅額計算銷售額者，請改用（403）申報書申報。" — a taxpayer whose period includes an exempt or special-tax-calculation sale files form 403 instead, whose own box layout this pack could not confirm against an official publication; see the README).', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, '加值型及非加值型營業稅法第35條第1項 — the return and the tax due are filed before the fifteenth day of the month following the two-month (or, once approved, the one-month) period.', 'bt-act', null, 1, 'The form''s own header states "金額單位：新臺幣元" (amount unit: New Taiwan dollars, whole dollars) beside every box of the printed return.', 'form-401')
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
  ('TW', 'TW-401', '21', 'base', '銷售額合計（應稅）', '{"en":"Taxable sales base, total"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, row 合計, column 銷售額 — the sum of the taxable sales base of the period, before the zero-rated column.', 'form-401'),
  ('TW', 'TW-401', '22', 'tax', '銷項稅額合計', '{"en":"Output tax, total"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, row 合計, column 稅額 — the output tax of the period; the same figure the form also prints at row 1 under code 101.', 'form-401'),
  ('TW', 'TW-401', '101', 'tax', '本期(月)銷項稅額合計', '{"en":"Output tax this period, total"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 稅額計算 section, row 1, code 101 — the same output tax total box 22 carries under the form''s ② mark, printed a second time in the box code the tax calculation section reads.', 'form-401'),
  ('TW', 'TW-401', '23', 'base', '零稅率銷售額合計', '{"en":"Zero-rated sales base, total"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, row 合計, column 零稅率銷售額 — the sum of the zero-rated sales base of the period.', 'form-401'),
  ('TW', 'TW-401', '25', 'total', '銷售額總計', '{"en":"Total sales"}'::jsonb, 50, null, array['21', '23']::text[], '{}'::text[], null, null, false, false, null, 'Form 401, row 銷售額總計, code 25⑦ — the taxable and the zero-rated sales bases added together (①+③ on the printed form).', 'form-401'),
  ('TW', 'TW-401', '44', 'base', '進貨及費用金額合計', '{"en":"Purchases and expenses, base total"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 進項 section, row 合計, column 進貨及費用金額 — the total value of the period''s deductible purchases of goods and expenses, across every voucher type the form breaks the row into (this pack declares the total row and not the voucher-type breakdown; see the README).', 'form-401'),
  ('TW', 'TW-401', '45', 'tax', '進貨及費用稅額合計', '{"en":"Purchases and expenses, deductible tax total"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 進項 section, row 合計, column 進貨及費用稅額, code 45⑨ — the deductible input tax of the period''s purchases of goods and expenses.', 'form-401'),
  ('TW', 'TW-401', '46', 'base', '固定資產金額合計', '{"en":"Fixed assets, base total"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 進項 section, row 合計, column 固定資產金額 — the total value of the period''s deductible purchases of fixed assets.', 'form-401'),
  ('TW', 'TW-401', '47', 'tax', '固定資產稅額合計', '{"en":"Fixed assets, deductible tax total"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 進項 section, row 合計, column 固定資產稅額, code 47⑩ — the deductible input tax of the period''s purchases of fixed assets.', 'form-401'),
  ('TW', 'TW-401', '107', 'total', '得扣抵進項稅額合計', '{"en":"Deductible input tax, total"}'::jsonb, 100, null, array['45', '47']::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 稅額計算 section, row 7, code 107 — ⑨+⑩, the deductible input tax of goods, expenses and fixed assets added together.', 'form-401'),
  ('TW', 'TW-401', '110', 'total', '小計', '{"en":"Subtotal"}'::jsonb, 110, null, array['107']::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 稅額計算 section, row 10, code 110 — printed as 7+8, the deductible input tax of the period (row 7, box 107) plus the credit carried in from the previous period (row 8, box 108). Box 108 is not a fact this period''s ledger holds — it is what the previous period''s own return came to — and `vat_return()` evaluates one period at a time from the ledger it replays, with no carry-forward from a period outside the one asked for. This pack declares box 110 as row 7 alone and leaves box 108 undeclared, which is the same gap packs/gq documents for its own box 027 (crédit de TVA reporté) and no invention of this pack''s own; see the README.', 'form-401'),
  ('TW', 'TW-401', '111', 'total', '本期(月)應實繳稅額', '{"en":"Tax payable this period"}'::jsonb, 120, null, array['101']::text[], array['110']::text[], null, null, true, false, null, 'Form 401, 稅額計算 section, row 11, code 111 — 1−10, the tax payable this period where output tax exceeds deductible input tax.', 'form-401'),
  ('TW', 'TW-401', '112', 'total', '本期(月)申報留抵稅額', '{"en":"Credit reported this period"}'::jsonb, 130, null, array['110']::text[], array['101']::text[], null, null, true, false, null, 'Form 401, 稅額計算 section, row 12, code 112 — 10−1, the credit reported this period where deductible input tax exceeds output tax.', 'form-401'),
  ('TW', 'TW-401', 'TWZR5', 'total', '零稅率銷售額 x 5%（計算用，未印於申報書）', '{"en":"Zero-rated sales x 5% (working box, not printed on the form)"}'::jsonb, 140, null, '{}'::text[], '{}'::text[], 5, '23', false, true, null, 'Not a box the form prints. Form 401''s own box 13 (得退稅限額合計, code 113) is printed as ③×5%+⑩ — a rate of one box plus another box on the same line — and this format''s box vocabulary offers a rate applied to one box (rate/rate_of) or a plus/minus list, never both on one box (docs/packs.md, "A box is a list or a rate, never both"). This working box carries the rate alone, on the working-box pattern packs/jp already uses for its own local-tax share, so that box 113 can still be declared as the plus of this box and box 110.', 'form-401'),
  ('TW', 'TW-401', '113', 'total', '得退稅限額合計', '{"en":"Refund cap, total"}'::jsonb, 150, null, array['TWZR5', '110']::text[], '{}'::text[], null, null, false, false, null, 'Form 401, 稅額計算 section, row 13, code 113 — ③×5%+⑩, the refund a zero-rated exporter may claim is capped at 5% of its zero-rated sales plus the credit carried in from the previous period; see box TWZR5 for how this pack computes the rate term, and box 110 for why the carried-in term is incomplete.', 'form-401')
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
  ('TW-BAA-BS', 'TW', 'default', '資產負債表 — Statement of financial position', 'balance_sheet', '商業會計處理準則', date '1970-01-01', null, '商業會計處理準則第14條 — a balance sheet presents assets (current, non-current), liabilities (current, non-current) and equity (capital or paid-in capital, capital surplus, retained earnings or accumulated deficit, other equity, treasury shares).', 'accounting-rules'),
  ('TW-BAA-IS', 'TW', 'default', '損益表 — Income statement', 'income_statement', '商業會計處理準則', date '1970-01-01', null, '商業會計處理準則第32條 — a comprehensive income statement may include operating revenue, operating costs, operating expenses, non-operating income and expense, income tax expense (or benefit), continuing and discontinued operations, and the net profit or loss of the period. This chart carries no discontinued-operations account and no item of other comprehensive income, so this statement stops at the net profit or loss of the period.', 'accounting-rules')
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
  ('TW-BAA-BS', 'CA', null, '流動資產 Current assets', '{"en":"Current assets"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'NCA', null, '非流動資產 Non-current assets', '{"en":"Non-current assets"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'TA', null, '資產總計 Total assets', '{"en":"Total assets"}'::jsonb, 30, 1, true, array['CA', 'NCA']::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'CL', null, '流動負債 Current liabilities', '{"en":"Current liabilities"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'NCL', null, '非流動負債 Non-current liabilities', '{"en":"Non-current liabilities"}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'TL', null, '負債總計 Total liabilities', '{"en":"Total liabilities"}'::jsonb, 60, 1, true, array['CL', 'NCL']::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'EQCAP', null, '股本 Share capital', '{"en":"Share capital"}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'EQCS', null, '資本公積 Capital surplus', '{"en":"Capital surplus"}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'EQRE', null, '保留盈餘（或累積虧損） Retained earnings (accumulated deficit)', '{"en":"Retained earnings (accumulated deficit)"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'EQTS', null, '庫藏股票 Treasury shares', '{"en":"Treasury shares"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, 'Treasury shares are a debit-normal deduction from equity: this line''s -1 sign, applied to a normally-debit balance, prints as the negative figure that reduces the total of equity it is added into — the same mechanism a credit-normal equity line uses, read the other way.', null),
  ('TW-BAA-BS', 'TEQ', null, '權益總計 Total equity', '{"en":"Total equity"}'::jsonb, 110, 1, true, array['EQCAP', 'EQCS', 'EQRE', 'EQTS']::text[], '{}'::text[], null, null, null),
  ('TW-BAA-BS', 'TLE', null, '負債及權益總計 Total liabilities and equity', '{"en":"Total liabilities and equity"}'::jsonb, 120, 1, true, array['TL', 'TEQ']::text[], '{}'::text[], null, null, null),
  ('TW-BAA-IS', 'REV', null, '營業收入 Operating revenue', '{"en":"Operating revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-IS', 'COGS', null, '營業成本 Operating costs', '{"en":"Operating costs"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-IS', 'GP', null, '營業毛利（毛損） Gross profit (loss)', '{"en":"Gross profit (loss)"}'::jsonb, 30, 1, true, array['REV']::text[], array['COGS']::text[], null, null, null),
  ('TW-BAA-IS', 'OPEX', null, '營業費用 Operating expenses', '{"en":"Operating expenses"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-IS', 'OI', null, '營業淨利（淨損） Operating income (loss)', '{"en":"Operating income (loss)"}'::jsonb, 50, 1, true, array['GP']::text[], array['OPEX']::text[], null, null, null),
  ('TW-BAA-IS', 'NONOP', null, '營業外收益及費損 Non-operating income and expense', '{"en":"Non-operating income and expense"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Article 32 item 4 prints non-operating income and non-operating expense as one line, not two, which is why this pack keeps one code_range over both instead of separating an income_other type from an expense type — an account_type rule could not separate them cleanly either, since 7151 (interest expense) and 7182 (foreign exchange loss) sit inside the same 71xx range as their income counterparts on the official table. sign 1 reads the debit-minus-credit balance directly: a net expense here prints positive and a net non-operating gain prints negative, which is what NI below subtracts.', null),
  ('TW-BAA-IS', 'TAX', null, '所得稅費用（或利益） Income tax expense (or benefit)', '{"en":"Income tax expense (or benefit)"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TW-BAA-IS', 'NI', null, '本期純益（純損） Net profit (loss) for the period', '{"en":"Net profit (loss) for the period"}'::jsonb, 80, 1, true, array['OI']::text[], array['NONOP', 'TAX']::text[], null, null, null)
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
    ('TW-BAA-BS', 'CA', 10, 'code_range', '11', '12', null, 'any'),
    ('TW-BAA-BS', 'NCA', 10, 'code_range', '13', '15', null, 'any'),
    ('TW-BAA-BS', 'CL', 10, 'code_range', '21', '22', null, 'any'),
    ('TW-BAA-BS', 'NCL', 10, 'code_range', '23', '23', null, 'any'),
    ('TW-BAA-BS', 'EQCAP', 10, 'code_range', '31', '31', null, 'any'),
    ('TW-BAA-BS', 'EQCS', 10, 'code_range', '32', '32', null, 'any'),
    ('TW-BAA-BS', 'EQRE', 10, 'code_range', '33', '33', null, 'any'),
    ('TW-BAA-BS', 'EQTS', 10, 'code_range', '35', '35', null, 'any'),
    ('TW-BAA-IS', 'REV', 10, 'code_range', '41', '41', null, 'any'),
    ('TW-BAA-IS', 'COGS', 10, 'code_range', '51', '59', null, 'any'),
    ('TW-BAA-IS', 'OPEX', 10, 'code_range', '61', '61', null, 'any'),
    ('TW-BAA-IS', 'NONOP', 10, 'code_range', '71', '72', null, 'any'),
    ('TW-BAA-IS', 'TAX', 10, 'code_range', '82', '82', null, 'any')
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
  ('TW', '臺灣', '{"en":"Taiwan"}'::jsonb, array['zh', 'en']::text[], 'TWD', '1191', '2171', '2251', '6135', '3351', '4111', '5121', '1113', '1111', 'SAL', 'PUR', 'GEN', 'zh', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '7181', '7182', '7201', '7202', null, null, '2194', '1269', null, 'bimonth'::declaration_period)
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
  number_format                 = '{CODE}-{NNNNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = '統一發票使用辦法 (Uniform Invoice Using Method) articles 7 and 9 — a uniform invoice''s number is two letters (字軌, a "word-rail" prefix) and eight digits, and the letters and the ranges of numbers within them are allocated to each business by the competent tax authority for each two-month filing period, not chosen by the business. `gapless` is the closer of the two numbering words the format offers — no hole is tolerated inside an allocated range — but no value says "externally pre-allocated per period", which is written up in this pack''s README rather than forced into `number_format`.',
  numbering_source_key          = 'uniform-invoice-rules',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_date',
  tax_point_legal_reference     = '加值型及非加值型營業稅法 (Business Tax Act) article 32, paragraph 1 — a business entity shall issue a uniform invoice at the time the business tax obligation arises (as article 16 defines it, in principle the day the goods are delivered or the service is completed), which in practice a general-method taxpayer states as the invoice date it is required to issue on the same occasion; article 33 conditions the buyer''s deduction on holding that invoice. No general derogation to the payment date exists outside the closed list of deferred-issuance cases article 32 itself states (deferred-payment sales, transport, and a small number of regulated trades), which this pack does not carry as a separate tax point.',
  tax_point_source_key          = 'bt-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'No statute obliges a Taiwanese business to exchange a structured electronic invoice with its trading partner under EN 16931 or a Peppol profile — no Peppol Authority is registered for Taiwan and none of `peppol-bis-3`, `factur-x-en16931`, `xrechnung` or a PINT applies here. This is a null reading of a European-shaped question, not a statement that Taiwan has no electronic invoicing: the opposite is true, and what it has instead — a government-run clearance and lottery platform for the 統一發票, 電子發票實施作業要點 and 統一發票使用辦法 article 7 — is a different mechanism this field cannot express, written up in this pack''s README and in docs/international.md under "From Taiwan".',
  einvoice_source_key           = 'einvoice-rules',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'TW';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('TW', 'export', 'export', '外銷零稅率（加值型及非加值型營業稅法第7條第1款）', '{"en":"Zero-rated export (Business Tax Act, article 7, item 1)"}'::jsonb, 10, date '1970-01-01', null, '加值型及非加值型營業稅法第7條第1款 — the sale of goods exported, or of services related to export or supplied within the territory but used in a foreign country, is zero-rated.'),
  ('TW', 'exempt', 'exempt', '免稅（加值型及非加值型營業稅法第8條）', '{"en":"Exempt (Business Tax Act, article 8)"}'::jsonb, 20, date '1970-01-01', null, '加值型及非加值型營業稅法第8條 — the sale is exempt under one of the items the article lists.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
