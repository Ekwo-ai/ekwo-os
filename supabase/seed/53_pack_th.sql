-- Ekwo OS — ประเทศไทย: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/th at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build th`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Revenue Code, Title IV Chapter 4 (Value Added Tax) — sections 80, 80/1, 81 and 81/1: the standard rate, the zero rate, the exempt businesses and the small-business threshold (Revenue Department of Thailand (English translation))
--     https://www.rd.go.th/english/37732.html
--   Revenue Code, sections 83 to 84/4 — section 83/6: remittance of value added tax by the payer of a service performed abroad and used in Thailand (Revenue Department of Thailand (English translation))
--     https://www.rd.go.th/english/37735.html
--   Revenue Code, section 86/4 — the particulars a tax invoice states (Revenue Department of Thailand (English translation))
--     https://www.rd.go.th/english/37741.html
--   Value Added Tax — registration threshold, form VAT 30 (ภ.พ.30) and its filing deadline, form VAT 36 (ภ.พ.36) (Revenue Department of Thailand)
--     https://www.rd.go.th/english/6043.html
--   Withholding tax on payments to a juristic person — rates and the form (ภ.ง.ด.53) (Revenue Department of Thailand)
--     https://www.rd.go.th/english/6044.html
--   Withholding tax on payments to an individual — rates and the form (ภ.ง.ด.3) (Revenue Department of Thailand)
--     https://www.rd.go.th/english/6045.html
--   Specific Business Tax — the businesses it reaches, its bases and rates, and the return (ภธ.40) (Revenue Department of Thailand)
--     https://www.rd.go.th/english/6042.html
--   RD e-Filing — the Revenue Department's portal for submitting every kind of return and paying tax, including form VAT 30 (Revenue Department of Thailand)
--     https://efiling.rd.go.th
--   Royal Decree issued under the Revenue Code Governing Reduction of the Rate of Value Added Tax (No. 799), B.E. 2568 (2025), continuing the reduction to 6.3 % national plus 0.7 % local tax, 7 % combined (Revenue Department of Thailand, publishing the Royal Gazette text)
--     https://www.rd.go.th/fileadmin/user_upload/kormor/newlaw/dc799.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('TH', 'ประเทศไทย', '0.1.0', date '2026-09-22', '20260917170000', 'community', null, null, '96cbed738192310c1e1b66b264dcd22208742f10e470f673d773e4566fbbf35f', '[{"key":"rc-vat-80","title":"Revenue Code, Title IV Chapter 4 (Value Added Tax) — sections 80, 80/1, 81 and 81/1: the standard rate, the zero rate, the exempt businesses and the small-business threshold","publisher":"Revenue Department of Thailand (English translation)","url":"https://www.rd.go.th/english/37732.html","consulted_on":"2026-09-22","kind":"law"},{"key":"rc-vat-83","title":"Revenue Code, sections 83 to 84/4 — section 83/6: remittance of value added tax by the payer of a service performed abroad and used in Thailand","publisher":"Revenue Department of Thailand (English translation)","url":"https://www.rd.go.th/english/37735.html","consulted_on":"2026-09-22","kind":"law"},{"key":"rc-vat-86","title":"Revenue Code, section 86/4 — the particulars a tax invoice states","publisher":"Revenue Department of Thailand (English translation)","url":"https://www.rd.go.th/english/37741.html","consulted_on":"2026-09-22","kind":"law"},{"key":"rd-vat-guide","title":"Value Added Tax — registration threshold, form VAT 30 (ภ.พ.30) and its filing deadline, form VAT 36 (ภ.พ.36)","publisher":"Revenue Department of Thailand","url":"https://www.rd.go.th/english/6043.html","consulted_on":"2026-09-22","kind":"guidance"},{"key":"rd-wht-corp","title":"Withholding tax on payments to a juristic person — rates and the form (ภ.ง.ด.53)","publisher":"Revenue Department of Thailand","url":"https://www.rd.go.th/english/6044.html","consulted_on":"2026-09-22","kind":"guidance"},{"key":"rd-wht-indiv","title":"Withholding tax on payments to an individual — rates and the form (ภ.ง.ด.3)","publisher":"Revenue Department of Thailand","url":"https://www.rd.go.th/english/6045.html","consulted_on":"2026-09-22","kind":"guidance"},{"key":"rd-sbt","title":"Specific Business Tax — the businesses it reaches, its bases and rates, and the return (ภธ.40)","publisher":"Revenue Department of Thailand","url":"https://www.rd.go.th/english/6042.html","consulted_on":"2026-09-22","kind":"guidance"},{"key":"rd-efiling","title":"RD e-Filing — the Revenue Department''s portal for submitting every kind of return and paying tax, including form VAT 30","publisher":"Revenue Department of Thailand","url":"https://efiling.rd.go.th","consulted_on":"2026-09-22","kind":"portal"},{"key":"dc799","title":"Royal Decree issued under the Revenue Code Governing Reduction of the Rate of Value Added Tax (No. 799), B.E. 2568 (2025), continuing the reduction to 6.3 % national plus 0.7 % local tax, 7 % combined","publisher":"Revenue Department of Thailand, publishing the Royal Gazette text","url":"https://www.rd.go.th/fileadmin/user_upload/kormor/newlaw/dc799.pdf","consulted_on":"2026-09-22","kind":"regulation"}]'::jsonb)
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
  ('TH', 'default', 'ผังบัญชีอ้างอิงของประเทศไทย', '{"en":"Thailand reference chart of accounts"}'::jsonb, true, 'companies', array['TH-BS', 'TH-IS']::text[], null, 'Thailand prescribes no chart of accounts. What this session could verify is that the Federation of Accounting Professions (สภาวิชาชีพบัญชี, tfac.or.th) issues Thai Financial Reporting Standards, among them a simplified standard for entities that are not publicly accountable, under the Accounting Professions Act B.E. 2547 (2004); and that the Department of Business Development (กรมพัฒนาธุรกิจการค้า) administers the Accounting Act B.E. 2543 (2000), which requires a business to keep accounts and file financial statements. Neither text, nor the standard''s own paragraphs, could be read from here this session (see README, "Sources"), so this chart transcribes no numbered line item of a Thai standard the way the Belgian or the Australian chart does its own. It is original, four digits by class in the numbering the sibling Asian packs (Singapore, Japan) use — 1 assets, 2 liabilities, 3 equity, 4 revenue, 5 cost of sales, 6 operating expenses, 7 finance items, 8 income tax — with the accounts a VAT-registered Thai company''s books hold: output and input value added tax, the VAT payable or refundable account a filed return settles to, withholding tax payable on a supplier''s invoice, the Social Security Fund and a provident fund. Its statements, `TH-BS` and `TH-IS` in `statements.json`, are original: lines grouped by the code ranges this chart''s own numbering gives its accounts, current and non-current, without transcribing a Thai standard''s own line items or their numbering.', null)
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
  ('TH', 'default', '1000', 'เงินสด', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, null, 10),
  ('TH', 'default', '1010', 'เงินฝากธนาคาร - กระแสรายวัน', '{"en":"Bank — current account"}'::jsonb, 'asset_cash', false, null, 20),
  ('TH', 'default', '1020', 'เงินฝากธนาคาร - ออมทรัพย์', '{"en":"Bank — savings account"}'::jsonb, 'asset_cash', false, null, 30),
  ('TH', 'default', '1030', 'เงินฝากธนาคาร - เงินตราต่างประเทศ (ดอลลาร์สหรัฐ)', '{"en":"Bank — foreign currency account (US dollar)"}'::jsonb, 'asset_cash', false, null, 40),
  ('TH', 'default', '1040', 'เงินฝากธนาคาร - เงินตราต่างประเทศ (อื่น ๆ)', '{"en":"Bank — foreign currency account (other)"}'::jsonb, 'asset_cash', false, null, 50),
  ('TH', 'default', '1090', 'เงินสดระหว่างนำฝาก', '{"en":"Cash in transit"}'::jsonb, 'asset_cash', false, null, 60),
  ('TH', 'default', '1100', 'ลูกหนี้การค้า', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 70),
  ('TH', 'default', '1105', 'ตั๋วเงินรับ', '{"en":"Notes receivable"}'::jsonb, 'asset_receivable', true, null, 80),
  ('TH', 'default', '1110', 'ลูกหนี้กิจการที่เกี่ยวข้องกัน', '{"en":"Receivables from related parties"}'::jsonb, 'asset_receivable', true, null, 90),
  ('TH', 'default', '1120', 'ลูกหนี้ตามสัญญายังไม่วางบิล', '{"en":"Unbilled receivables"}'::jsonb, 'asset_current', false, null, 100),
  ('TH', 'default', '1121', 'เงินมัดจำจ่ายล่วงหน้าค่าสินค้า', '{"en":"Advances paid for goods"}'::jsonb, 'asset_current', false, null, 110),
  ('TH', 'default', '1125', 'ดอกเบี้ยค้างรับ', '{"en":"Accrued interest receivable"}'::jsonb, 'asset_current', false, null, 120),
  ('TH', 'default', '1140', 'ค่าเผื่อหนี้สงสัยจะสูญ', '{"en":"Allowance for doubtful accounts"}'::jsonb, 'asset_current', false, null, 130),
  ('TH', 'default', '1150', 'ภาษีซื้อ', '{"en":"Input value added tax"}'::jsonb, 'asset_current', false, null, 140),
  ('TH', 'default', '1155', 'ภาษีมูลค่าเพิ่มรอขอคืน', '{"en":"Value added tax refundable"}'::jsonb, 'asset_current', true, null, 150),
  ('TH', 'default', '1160', 'เงินทดรองจ่ายพนักงาน', '{"en":"Advances to employees"}'::jsonb, 'asset_current', false, null, 160),
  ('TH', 'default', '1170', 'ลูกหนี้อื่น', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 170),
  ('TH', 'default', '1180', 'เงินให้กู้ยืมพนักงานระยะสั้น', '{"en":"Short-term loans to employees"}'::jsonb, 'asset_current', false, null, 180),
  ('TH', 'default', '1200', 'สินค้าสำเร็จรูปคงเหลือ', '{"en":"Finished goods inventory"}'::jsonb, 'asset_current', false, null, 190),
  ('TH', 'default', '1210', 'วัตถุดิบและวัสดุคงเหลือ', '{"en":"Raw materials and supplies inventory"}'::jsonb, 'asset_current', false, null, 200),
  ('TH', 'default', '1220', 'งานระหว่างผลิต', '{"en":"Work in process"}'::jsonb, 'asset_current', false, null, 210),
  ('TH', 'default', '1230', 'วัสดุบรรจุภัณฑ์และของใช้สิ้นเปลือง', '{"en":"Packaging and consumable supplies"}'::jsonb, 'asset_current', false, null, 220),
  ('TH', 'default', '1240', 'สินค้าระหว่างทาง', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 230),
  ('TH', 'default', '1300', 'ค่าใช้จ่ายจ่ายล่วงหน้า', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 240),
  ('TH', 'default', '1310', 'เงินประกันจ่าย', '{"en":"Deposits paid"}'::jsonb, 'asset_prepayments', false, null, 250),
  ('TH', 'default', '1320', 'ค่าเบี้ยประกันภัยจ่ายล่วงหน้า', '{"en":"Prepaid insurance"}'::jsonb, 'asset_prepayments', false, null, 260),
  ('TH', 'default', '1330', 'ค่าเช่าจ่ายล่วงหน้า', '{"en":"Prepaid rent"}'::jsonb, 'asset_prepayments', false, null, 270),
  ('TH', 'default', '1350', 'เงินทดรองจ่ายค่าเดินทางล่วงหน้า', '{"en":"Advances to employees for travel"}'::jsonb, 'asset_prepayments', false, null, 280),
  ('TH', 'default', '1600', 'ที่ดิน', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 290),
  ('TH', 'default', '1610', 'อาคารและสิ่งปลูกสร้าง', '{"en":"Buildings and structures"}'::jsonb, 'asset_fixed', false, null, 300),
  ('TH', 'default', '1611', 'ค่าเสื่อมราคาสะสม - อาคารและสิ่งปลูกสร้าง', '{"en":"Accumulated depreciation — buildings and structures"}'::jsonb, 'asset_fixed', false, '1610', 310),
  ('TH', 'default', '1620', 'เครื่องตกแต่งและอุปกรณ์สำนักงาน', '{"en":"Furniture and office equipment"}'::jsonb, 'asset_fixed', false, null, 320),
  ('TH', 'default', '1621', 'ค่าเสื่อมราคาสะสม - เครื่องตกแต่งและอุปกรณ์สำนักงาน', '{"en":"Accumulated depreciation — furniture and office equipment"}'::jsonb, 'asset_fixed', false, '1620', 330),
  ('TH', 'default', '1630', 'ยานพาหนะ', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, null, 340),
  ('TH', 'default', '1631', 'ค่าเสื่อมราคาสะสม - ยานพาหนะ', '{"en":"Accumulated depreciation — vehicles"}'::jsonb, 'asset_fixed', false, '1630', 350),
  ('TH', 'default', '1640', 'คอมพิวเตอร์และอุปกรณ์', '{"en":"Computer equipment"}'::jsonb, 'asset_fixed', false, null, 360),
  ('TH', 'default', '1641', 'ค่าเสื่อมราคาสะสม - คอมพิวเตอร์และอุปกรณ์', '{"en":"Accumulated depreciation — computer equipment"}'::jsonb, 'asset_fixed', false, '1640', 370),
  ('TH', 'default', '1650', 'ส่วนปรับปรุงอาคารเช่า', '{"en":"Leasehold improvements"}'::jsonb, 'asset_fixed', false, null, 380),
  ('TH', 'default', '1651', 'ค่าเสื่อมราคาสะสม - ส่วนปรับปรุงอาคารเช่า', '{"en":"Accumulated depreciation — leasehold improvements"}'::jsonb, 'asset_fixed', false, '1650', 390),
  ('TH', 'default', '1660', 'เครื่องจักรและอุปกรณ์การผลิต', '{"en":"Machinery and production equipment"}'::jsonb, 'asset_fixed', false, null, 400),
  ('TH', 'default', '1661', 'ค่าเสื่อมราคาสะสม - เครื่องจักรและอุปกรณ์การผลิต', '{"en":"Accumulated depreciation — machinery and production equipment"}'::jsonb, 'asset_fixed', false, '1660', 410),
  ('TH', 'default', '1670', 'เครื่องมือและอุปกรณ์', '{"en":"Tools and equipment"}'::jsonb, 'asset_fixed', false, null, 420),
  ('TH', 'default', '1671', 'ค่าเสื่อมราคาสะสม - เครื่องมือและอุปกรณ์', '{"en":"Accumulated depreciation — tools and equipment"}'::jsonb, 'asset_fixed', false, '1670', 430),
  ('TH', 'default', '1700', 'สินทรัพย์ไม่มีตัวตน', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, null, 440),
  ('TH', 'default', '1710', 'เงินมัดจำระยะยาว', '{"en":"Long-term deposits"}'::jsonb, 'asset_non_current', false, null, 450),
  ('TH', 'default', '1720', 'โปรแกรมคอมพิวเตอร์และใบอนุญาตใช้งาน', '{"en":"Computer software and licences"}'::jsonb, 'asset_non_current', false, null, 460),
  ('TH', 'default', '1730', 'ค่าความนิยม', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 470),
  ('TH', 'default', '1740', 'เงินลงทุนระยะยาว', '{"en":"Long-term investments"}'::jsonb, 'asset_non_current', false, null, 480),
  ('TH', 'default', '1750', 'สินทรัพย์ภาษีเงินได้รอการตัดบัญชี', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 490),
  ('TH', 'default', '1760', 'ภาษีเงินได้หัก ณ ที่จ่ายรอเครดิต', '{"en":"Withholding tax certificates awaiting credit"}'::jsonb, 'asset_non_current', false, null, 500),
  ('TH', 'default', '2000', 'เจ้าหนี้การค้า', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 510),
  ('TH', 'default', '2005', 'ตั๋วเงินจ่าย', '{"en":"Notes payable"}'::jsonb, 'liability_payable', true, null, 520),
  ('TH', 'default', '2020', 'ค่าแรงและเงินเดือนค้างจ่าย', '{"en":"Accrued payroll"}'::jsonb, 'liability_current', false, null, 530),
  ('TH', 'default', '2030', 'โบนัสค้างจ่าย', '{"en":"Accrued bonus"}'::jsonb, 'liability_current', false, null, 540),
  ('TH', 'default', '2040', 'เงินมัดจำรับล่วงหน้าจากลูกค้า', '{"en":"Advances from customers"}'::jsonb, 'liability_current', false, null, 550),
  ('TH', 'default', '2050', 'เจ้าหนี้อื่น', '{"en":"Other payables"}'::jsonb, 'liability_current', false, null, 560),
  ('TH', 'default', '2060', 'รายได้รับล่วงหน้า', '{"en":"Deferred revenue"}'::jsonb, 'liability_current', false, null, 570),
  ('TH', 'default', '2070', 'เงินกู้ยืมระยะยาวส่วนที่ถึงกำหนดชำระภายในหนึ่งปี', '{"en":"Current portion of long-term loans"}'::jsonb, 'liability_current', false, null, 580),
  ('TH', 'default', '2080', 'ประมาณการหนี้สินค่ารับประกันสินค้า', '{"en":"Provision for product warranty"}'::jsonb, 'liability_current', false, null, 590),
  ('TH', 'default', '2090', 'ภาษีเงินปันผลหัก ณ ที่จ่ายค้างนำส่ง', '{"en":"Dividend withholding tax payable"}'::jsonb, 'liability_current', true, null, 600),
  ('TH', 'default', '2100', 'ภาษีขาย', '{"en":"Output value added tax"}'::jsonb, 'liability_current', false, null, 610),
  ('TH', 'default', '2110', 'ภาษีมูลค่าเพิ่มค้างจ่าย', '{"en":"Value added tax payable"}'::jsonb, 'liability_current', true, null, 620),
  ('TH', 'default', '2130', 'อากรขาเข้าค้างจ่าย', '{"en":"Import duty payable"}'::jsonb, 'liability_current', false, null, 630),
  ('TH', 'default', '2140', 'ภาษีหัก ณ ที่จ่ายค้างนำส่ง', '{"en":"Withholding tax payable"}'::jsonb, 'liability_current', true, null, 640),
  ('TH', 'default', '2150', 'ภาษีเงินได้นิติบุคคลค้างจ่าย', '{"en":"Corporate income tax payable"}'::jsonb, 'liability_current', false, null, 650),
  ('TH', 'default', '2160', 'เงินสมทบกองทุนประกันสังคมค้างจ่าย', '{"en":"Social Security Fund contributions payable"}'::jsonb, 'liability_current', false, null, 660),
  ('TH', 'default', '2170', 'เงินสมทบกองทุนสำรองเลี้ยงชีพค้างจ่าย', '{"en":"Provident fund contributions payable"}'::jsonb, 'liability_current', false, null, 670),
  ('TH', 'default', '2180', 'หนี้สินภาษีเงินได้รอการตัดบัญชี', '{"en":"Deferred tax liability"}'::jsonb, 'liability_current', false, null, 680),
  ('TH', 'default', '2195', 'ค่าสอบบัญชีค้างจ่าย', '{"en":"Accrued audit fee"}'::jsonb, 'liability_current', false, null, 690),
  ('TH', 'default', '2200', 'เงินกู้ยืมระยะสั้น', '{"en":"Short-term loans"}'::jsonb, 'liability_current', false, null, 700),
  ('TH', 'default', '2210', 'ค่าใช้จ่ายค้างจ่ายอื่น', '{"en":"Other accrued expenses"}'::jsonb, 'liability_current', false, null, 710),
  ('TH', 'default', '2220', 'รายได้รับล่วงหน้าจากการให้บริการ', '{"en":"Deferred service revenue"}'::jsonb, 'liability_current', false, null, 720),
  ('TH', 'default', '2230', 'เงินปันผลค้างจ่าย', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 730),
  ('TH', 'default', '2240', 'เงินกองทุนสวัสดิการพนักงานค้างจ่าย', '{"en":"Employee welfare fund payable"}'::jsonb, 'liability_current', false, null, 740),
  ('TH', 'default', '2250', 'ประมาณการหนี้สินวันลาสะสม', '{"en":"Provision for accumulated leave"}'::jsonb, 'liability_current', false, null, 750),
  ('TH', 'default', '2500', 'เงินกู้ยืมระยะยาว', '{"en":"Long-term loans"}'::jsonb, 'liability_non_current', false, null, 800),
  ('TH', 'default', '2510', 'หุ้นกู้', '{"en":"Debentures payable"}'::jsonb, 'liability_non_current', false, null, 810),
  ('TH', 'default', '2520', 'หนี้สินตามสัญญาเช่าการเงินระยะยาว', '{"en":"Finance lease liability, non-current"}'::jsonb, 'liability_non_current', false, null, 820),
  ('TH', 'default', '2530', 'ประมาณการหนี้สินผลประโยชน์พนักงานเมื่อเกษียณอายุ', '{"en":"Provision for employee retirement benefits"}'::jsonb, 'liability_non_current', false, null, 830),
  ('TH', 'default', '2540', 'รายได้รับล่วงหน้าระยะยาว', '{"en":"Deferred revenue, non-current"}'::jsonb, 'liability_non_current', false, null, 840),
  ('TH', 'default', '2900', 'เงินกู้ยืมจากกรรมการ', '{"en":"Due to directors"}'::jsonb, 'liability_current', false, null, 760),
  ('TH', 'default', '2910', 'เงินกู้ยืมจากบริษัทในเครือ', '{"en":"Due to affiliated companies"}'::jsonb, 'liability_current', false, null, 770),
  ('TH', 'default', '2920', 'เงินกู้ยืมจากผู้ถือหุ้น', '{"en":"Due to shareholders"}'::jsonb, 'liability_current', false, null, 780),
  ('TH', 'default', '2990', 'บัญชีพักรอตรวจสอบ', '{"en":"Suspense account"}'::jsonb, 'liability_current', false, null, 790),
  ('TH', 'default', '3000', 'ทุนจดทะเบียนและเรียกชำระแล้ว', '{"en":"Registered and paid-up share capital"}'::jsonb, 'equity', false, null, 850),
  ('TH', 'default', '3050', 'หุ้นสามัญค้างชำระ', '{"en":"Subscribed share capital not yet paid"}'::jsonb, 'equity', false, '3000', 860),
  ('TH', 'default', '3100', 'ส่วนเกินมูลค่าหุ้น', '{"en":"Share premium"}'::jsonb, 'equity', false, null, 870),
  ('TH', 'default', '3110', 'สำรองตามกฎหมาย', '{"en":"Legal reserve"}'::jsonb, 'equity', false, null, 880),
  ('TH', 'default', '3200', 'กำไรสะสม', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, null, 890),
  ('TH', 'default', '3210', 'เงินปันผลจ่าย', '{"en":"Dividends paid"}'::jsonb, 'equity_retained', false, null, 900),
  ('TH', 'default', '4000', 'รายได้จากการขายสินค้าในประเทศ', '{"en":"Domestic sales revenue"}'::jsonb, 'income', false, null, 910),
  ('TH', 'default', '4010', 'รายได้จากการให้บริการในประเทศ', '{"en":"Domestic service revenue"}'::jsonb, 'income', false, null, 920),
  ('TH', 'default', '4020', 'รายได้จากการส่งออกสินค้า', '{"en":"Export sales revenue"}'::jsonb, 'income', false, null, 930),
  ('TH', 'default', '4030', 'รายได้จากการให้บริการแก่ลูกค้าต่างประเทศ', '{"en":"Revenue from services to a foreign customer"}'::jsonb, 'income', false, null, 940),
  ('TH', 'default', '4040', 'รายได้ค่าบริการอื่น', '{"en":"Other service revenue"}'::jsonb, 'income', false, null, 950),
  ('TH', 'default', '4050', 'รายได้จากการติดตั้งและบำรุงรักษา', '{"en":"Installation and maintenance revenue"}'::jsonb, 'income', false, null, 960),
  ('TH', 'default', '4060', 'รายได้จากการขายให้กิจการที่เกี่ยวข้องกัน', '{"en":"Sales revenue from related parties"}'::jsonb, 'income', false, null, 970),
  ('TH', 'default', '4090', 'ส่วนลดจ่าย', '{"en":"Sales discounts"}'::jsonb, 'income', false, null, 980),
  ('TH', 'default', '4500', 'รายได้ค่าเช่าอสังหาริมทรัพย์', '{"en":"Rental income"}'::jsonb, 'income', false, null, 990),
  ('TH', 'default', '4510', 'รายได้ค่าเช่าอุปกรณ์', '{"en":"Equipment rental income"}'::jsonb, 'income', false, null, 1000),
  ('TH', 'default', '4700', 'กำไรจากอัตราแลกเปลี่ยน', '{"en":"Foreign exchange gain"}'::jsonb, 'income_other', false, null, 1010),
  ('TH', 'default', '4710', 'ดอกเบี้ยรับ', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 1020),
  ('TH', 'default', '4720', 'เงินปันผลรับ', '{"en":"Dividend income"}'::jsonb, 'income_other', false, null, 1030),
  ('TH', 'default', '4750', 'กำไรจากการจำหน่ายสินทรัพย์ถาวร', '{"en":"Gain on disposal of fixed assets"}'::jsonb, 'income_other', false, null, 1040),
  ('TH', 'default', '4760', 'กำไรจากการแปลงค่างบการเงิน', '{"en":"Gain on translation of financial statements"}'::jsonb, 'income_other', false, null, 1050),
  ('TH', 'default', '4770', 'รายได้ค่าสินไหมทดแทนจากการประกันภัย', '{"en":"Insurance claim income"}'::jsonb, 'income_other', false, null, 1060),
  ('TH', 'default', '4800', 'โอนกลับค่าเผื่อหนี้สงสัยจะสูญ', '{"en":"Reversal of allowance for doubtful accounts"}'::jsonb, 'income_other', false, null, 1070),
  ('TH', 'default', '4900', 'รายได้อื่น', '{"en":"Other income"}'::jsonb, 'income_other', false, null, 1080),
  ('TH', 'default', '5000', 'ต้นทุนขาย', '{"en":"Cost of goods sold"}'::jsonb, 'expense_direct_cost', false, null, 1090),
  ('TH', 'default', '5010', 'ค่าขนส่งขาเข้า', '{"en":"Freight in"}'::jsonb, 'expense_direct_cost', false, null, 1100),
  ('TH', 'default', '5020', 'ค่าแรงงานทางตรง', '{"en":"Direct labour"}'::jsonb, 'expense_direct_cost', false, null, 1110),
  ('TH', 'default', '5030', 'ค่าใช้จ่ายการผลิตทางอ้อม', '{"en":"Manufacturing overhead"}'::jsonb, 'expense_direct_cost', false, null, 1120),
  ('TH', 'default', '5040', 'อากรขาเข้าสินค้า', '{"en":"Import duty on goods purchased"}'::jsonb, 'expense_direct_cost', false, null, 1130),
  ('TH', 'default', '5050', 'ผลขาดทุนจากการลดมูลค่าสินค้าคงเหลือ', '{"en":"Loss on write-down of inventory"}'::jsonb, 'expense_direct_cost', false, null, 1140),
  ('TH', 'default', '6000', 'เงินเดือนและค่าแรง', '{"en":"Salaries and wages"}'::jsonb, 'expense', false, null, 1150),
  ('TH', 'default', '6001', 'ค่าล่วงเวลา', '{"en":"Overtime pay"}'::jsonb, 'expense', false, null, 1160),
  ('TH', 'default', '6005', 'โบนัสพนักงาน', '{"en":"Employee bonus"}'::jsonb, 'expense', false, null, 1170),
  ('TH', 'default', '6010', 'เงินสมทบกองทุนประกันสังคม (นายจ้าง)', '{"en":"Social Security Fund contributions (employer)"}'::jsonb, 'expense', false, null, 1180),
  ('TH', 'default', '6015', 'ค่าฝึกอบรมพนักงาน', '{"en":"Staff training"}'::jsonb, 'expense', false, null, 1190),
  ('TH', 'default', '6020', 'เงินสมทบกองทุนสำรองเลี้ยงชีพ (นายจ้าง)', '{"en":"Provident fund contributions (employer)"}'::jsonb, 'expense', false, null, 1200),
  ('TH', 'default', '6025', 'ค่าเครื่องแบบพนักงาน', '{"en":"Staff uniforms"}'::jsonb, 'expense', false, null, 1210),
  ('TH', 'default', '6030', 'ค่าใช้จ่ายในการสรรหาบุคลากร', '{"en":"Recruitment expenses"}'::jsonb, 'expense', false, null, 1220),
  ('TH', 'default', '6040', 'ค่าประกันสุขภาพพนักงาน', '{"en":"Staff health insurance"}'::jsonb, 'expense', false, null, 1230),
  ('TH', 'default', '6050', 'ค่าสวัสดิการพนักงาน', '{"en":"Staff welfare"}'::jsonb, 'expense', false, null, 1240),
  ('TH', 'default', '6060', 'ค่าประกันชีวิตและอุบัติเหตุพนักงาน', '{"en":"Staff life and accident insurance"}'::jsonb, 'expense', false, null, 1250),
  ('TH', 'default', '6100', 'ค่าเช่าสำนักงาน', '{"en":"Office rent"}'::jsonb, 'expense', false, null, 1260),
  ('TH', 'default', '6110', 'ค่าน้ำค่าไฟ', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 1270),
  ('TH', 'default', '6120', 'ค่าโทรศัพท์และอินเทอร์เน็ต', '{"en":"Telephone and internet"}'::jsonb, 'expense', false, null, 1280),
  ('TH', 'default', '6130', 'ค่าพาหนะและเดินทาง', '{"en":"Transport and travel expenses"}'::jsonb, 'expense', false, null, 1290),
  ('TH', 'default', '6140', 'ค่าน้ำมันเชื้อเพลิงและยานพาหนะ', '{"en":"Fuel and vehicle expenses"}'::jsonb, 'expense', false, null, 1300),
  ('TH', 'default', '6150', 'ค่าที่จอดรถและทางด่วน', '{"en":"Parking and toll fees"}'::jsonb, 'expense', false, null, 1310),
  ('TH', 'default', '6160', 'ค่าไปรษณีย์และขนส่งเอกสาร', '{"en":"Postage and courier"}'::jsonb, 'expense', false, null, 1320),
  ('TH', 'default', '6170', 'ค่าเครื่องเขียนแบบพิมพ์', '{"en":"Stationery and printed forms"}'::jsonb, 'expense', false, null, 1330),
  ('TH', 'default', '6180', 'ค่าสมาชิกและค่าธรรมเนียมสมาคม', '{"en":"Membership and association fees"}'::jsonb, 'expense', false, null, 1340),
  ('TH', 'default', '6190', 'ค่าบริการซอฟต์แวร์ในประเทศ', '{"en":"Domestic software subscription"}'::jsonb, 'expense', false, null, 1350),
  ('TH', 'default', '6200', 'ค่าธรรมเนียมธนาคาร', '{"en":"Bank charges"}'::jsonb, 'expense', false, null, 1360),
  ('TH', 'default', '6210', 'ค่าที่ปรึกษาและค่าบริการวิชาชีพในประเทศ', '{"en":"Domestic consultancy and professional fees"}'::jsonb, 'expense', false, null, 1370),
  ('TH', 'default', '6220', 'ค่าโฆษณาและส่งเสริมการขาย', '{"en":"Advertising and promotion"}'::jsonb, 'expense', false, null, 1380),
  ('TH', 'default', '6230', 'ค่าซ่อมแซมและบำรุงรักษา', '{"en":"Repairs and maintenance"}'::jsonb, 'expense', false, null, 1390),
  ('TH', 'default', '6240', 'ค่ารับรอง', '{"en":"Entertainment expenses"}'::jsonb, 'expense', false, null, 1400),
  ('TH', 'default', '6250', 'ค่าวัสดุสำนักงาน', '{"en":"Office supplies"}'::jsonb, 'expense', false, null, 1410),
  ('TH', 'default', '6260', 'ค่าธรรมเนียมกฎหมายในประเทศ', '{"en":"Domestic legal fees"}'::jsonb, 'expense', false, null, 1420),
  ('TH', 'default', '6270', 'ค่าสอบบัญชี', '{"en":"Audit fees"}'::jsonb, 'expense', false, null, 1430),
  ('TH', 'default', '6280', 'ค่าแปลเอกสารและรับรองเอกสาร', '{"en":"Translation and notarisation fees"}'::jsonb, 'expense', false, null, 1440),
  ('TH', 'default', '6290', 'ค่าธรรมเนียมเอกสารนำเข้าส่งออก', '{"en":"Import and export documentation fees"}'::jsonb, 'expense', false, null, 1450),
  ('TH', 'default', '6300', 'ค่าเบี้ยประกันภัย', '{"en":"Insurance"}'::jsonb, 'expense', false, null, 1460),
  ('TH', 'default', '6310', 'ภาษีที่ดินและสิ่งปลูกสร้าง', '{"en":"Land and building tax"}'::jsonb, 'expense', false, null, 1470),
  ('TH', 'default', '6320', 'ภาษีป้าย', '{"en":"Signboard tax"}'::jsonb, 'expense', false, null, 1480),
  ('TH', 'default', '6330', 'ค่าธรรมเนียมจดทะเบียนยานพาหนะ', '{"en":"Vehicle registration fees"}'::jsonb, 'expense', false, null, 1490),
  ('TH', 'default', '6340', 'เงินบริจาค', '{"en":"Donations"}'::jsonb, 'expense', false, null, 1500),
  ('TH', 'default', '6350', 'ค่าบริการซอฟต์แวร์และดิจิทัลจากต่างประเทศ', '{"en":"Foreign software and digital services"}'::jsonb, 'expense', false, null, 1510),
  ('TH', 'default', '6360', 'ค่าบริการวิชาชีพจากผู้ประกอบการรายย่อยที่ไม่จดทะเบียนภาษีมูลค่าเพิ่ม', '{"en":"Fees paid to a small supplier not registered for value added tax"}'::jsonb, 'expense', false, null, 1520),
  ('TH', 'default', '6370', 'ค่าธรรมเนียมการโอนเงินระหว่างประเทศ', '{"en":"International funds transfer fees"}'::jsonb, 'expense', false, null, 1530),
  ('TH', 'default', '6380', 'ผลต่างอัตราแลกเปลี่ยนจากการทำธุรกรรม', '{"en":"Foreign exchange transaction differences"}'::jsonb, 'expense', false, null, 1540),
  ('TH', 'default', '6390', 'ค่าธรรมเนียมบัตรเครดิต', '{"en":"Credit card merchant fees"}'::jsonb, 'expense', false, null, 1550),
  ('TH', 'default', '6400', 'ค่าเบี้ยประชุมกรรมการ', '{"en":"Directors'' meeting fees"}'::jsonb, 'expense', false, null, 1560),
  ('TH', 'default', '6410', 'หนี้สูญตัดบัญชีโดยตรง', '{"en":"Bad debts written off directly"}'::jsonb, 'expense', false, null, 1570),
  ('TH', 'default', '6420', 'ผลขาดทุนจากการตัดจำหน่ายสินค้าคงเหลือ', '{"en":"Loss on disposal of inventory"}'::jsonb, 'expense', false, null, 1580),
  ('TH', 'default', '6430', 'ผลขาดทุนจากภัยพิบัติ', '{"en":"Loss from natural disaster"}'::jsonb, 'expense', false, null, 1590),
  ('TH', 'default', '6440', 'เบี้ยปรับและเงินเพิ่มทางภาษี', '{"en":"Tax penalties and surcharges"}'::jsonb, 'expense', false, null, 1600),
  ('TH', 'default', '6450', 'ค่าใช้จ่ายเบ็ดเตล็ด', '{"en":"Miscellaneous expenses"}'::jsonb, 'expense', false, null, 1610),
  ('TH', 'default', '6900', 'หนี้สงสัยจะสูญ', '{"en":"Bad debt expense"}'::jsonb, 'expense', false, null, 1620),
  ('TH', 'default', '6950', 'ขาดทุนจากอัตราแลกเปลี่ยน', '{"en":"Foreign exchange loss"}'::jsonb, 'expense', false, null, 1630),
  ('TH', 'default', '6960', 'ขาดทุนจากการจำหน่ายสินทรัพย์ถาวร', '{"en":"Loss on disposal of fixed assets"}'::jsonb, 'expense', false, null, 1640),
  ('TH', 'default', '6970', 'ค่าเสื่อมราคา', '{"en":"Depreciation"}'::jsonb, 'expense_depreciation', false, null, 1650),
  ('TH', 'default', '6975', 'ค่าตัดจำหน่ายสินทรัพย์ไม่มีตัวตน', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, null, 1660),
  ('TH', 'default', '6990', 'ผลต่างจากการปัดเศษ', '{"en":"Rounding differences"}'::jsonb, 'expense', false, null, 1670),
  ('TH', 'default', '7000', 'ดอกเบี้ยจ่าย', '{"en":"Interest expense"}'::jsonb, 'expense', false, null, 1680),
  ('TH', 'default', '7010', 'ดอกเบี้ยจ่ายตามสัญญาเช่าการเงิน', '{"en":"Interest expense on finance leases"}'::jsonb, 'expense', false, null, 1690),
  ('TH', 'default', '7020', 'ค่าธรรมเนียมจัดหาเงินกู้', '{"en":"Loan arrangement fees"}'::jsonb, 'expense', false, null, 1700),
  ('TH', 'default', '7030', 'ผลขาดทุนจากการชำระคืนเงินกู้ก่อนกำหนด', '{"en":"Loss on early repayment of a loan"}'::jsonb, 'expense', false, null, 1710),
  ('TH', 'default', '8000', 'ภาษีเงินได้นิติบุคคล', '{"en":"Corporate income tax"}'::jsonb, 'expense', false, null, 1720),
  ('TH', 'default', '8010', 'ภาษีเงินได้รอการตัดบัญชี', '{"en":"Deferred tax expense"}'::jsonb, 'expense', false, null, 1730)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('TH', 'BNK', 'สมุดรายวันธนาคาร', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('TH', 'CSH', 'สมุดรายวันเงินสดย่อย', '{"en":"Petty cash journal"}'::jsonb, 'cash', 40),
  ('TH', 'GEN', 'สมุดรายวันทั่วไป', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('TH', 'OPN', 'รายการยกยอดต้นงวด', '{"en":"Opening balances"}'::jsonb, 'opening', 60),
  ('TH', 'PUR', 'สมุดรายวันซื้อ', '{"en":"Purchases journal"}'::jsonb, 'purchase', 20),
  ('TH', 'SAL', 'สมุดรายวันขาย', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('TH', 'TH-P-EX', 'ซื้อ ไม่มีภาษีมูลค่าเพิ่ม (ผู้ขายได้รับยกเว้นหรือไม่อยู่ในระบบภาษีมูลค่าเพิ่ม)', '{"en":"Purchase, no value added tax (exempt or unregistered supplier)"}'::jsonb, 'การซื้อสินค้าหรือรับบริการจากผู้ประกอบการที่ประกอบกิจการซึ่งได้รับยกเว้นภาษีมูลค่าเพิ่มตามมาตรา 81 เช่น ค่าธรรมเนียมธนาคาร', 'percent', 0, 'purchase', 'exempt', date '2017-10-01', null, 'Revenue Code, section 81, as for TH-S-EX: what is bought carries no value added tax because the seller''s activity is exempt, so there is no input tax and no box.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rc-vat-80', null, null, null, null),
  ('TH', 'TH-P-RC', 'ซื้อบริการจากต่างประเทศ นำส่งภาษีมูลค่าเพิ่มตามมาตรา 83/6', '{"en":"Service bought from abroad, value added tax remitted under section 83/6"}'::jsonb, 'บริการที่ทำในต่างประเทศและได้มีการใช้บริการนั้นในราชอาณาจักร ผู้จ่ายเงินมีหน้าที่นำส่งภาษีมูลค่าเพิ่ม', 'percent', 7, 'purchase', 'foreign_services_received', date '2017-10-01', null, 'Revenue Code, section 83/6(2), read directly this session: where the payment for a service is made to a business person providing services abroad and the service is used in Thailand, the payer must remit value added tax — form VAT 36 per rd.go.th/english/6043.html, read directly this session. What is not carried is the two-form timing the law actually has: VAT 36 is remitted within seven days of the payment (rd-vat-guide, general topic list, not read to the article) and the amount remitted is then a credit on form VAT 30 of that month or the next, rather than on the same document as this pack posts it. This code books the self-assessment and the credit on the one document, which overstates how fast the credit is available and is named as a gap below; a reader who needs the timing right should not rely on this code alone.', null, null, 70, 'vat', true, array['buyer_status']::tax_condition[], null, false, false, null, 'rc-vat-83', null, null, null, null),
  ('TH', 'TH-P-STD', 'ซื้อ ภาษีมูลค่าเพิ่มอัตราร้อยละ 7 เครดิตภาษีซื้อได้', '{"en":"Purchase, standard rate 7 %, input tax creditable"}'::jsonb, 'การซื้อสินค้าหรือรับบริการที่ต้องเสียภาษีมูลค่าเพิ่มในประเทศ ซึ่งนำภาษีซื้อมาหักในการคำนวณภาษีได้', 'percent', 7, 'purchase', 'domestic', date '2017-10-01', null, 'Revenue Code, section 80, as for TH-S-STD, at the same 7 % combined rate under the same chain of Royal Decrees. This session did not read section 82/3 (the right to credit input tax) or section 82/5 (input tax the law excludes from credit — entertainment expenses and passenger cars among them, by general reputation and not by a text read this session) against their primary text, so this code assumes the purchase is one whose input tax is creditable in full; a purchase whose credit section 82/5 excludes is not carried, and is named as a gap of this pack below.', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rc-vat-80', null, null, null, null),
  ('TH', 'TH-P-WHT-RENT-5', 'ค่าเช่า หัก ณ ที่จ่ายร้อยละ 5', '{"en":"Rent, 5 % withheld"}'::jsonb, 'ค่าเช่าอสังหาริมทรัพย์ที่จ่ายให้บุคคลธรรมดา ซึ่งเป็นกิจการที่ได้รับยกเว้นภาษีมูลค่าเพิ่ม', 'percent', 5, 'purchase', 'not_subject', date '2026-01-01', null, 'Revenue Department, Withholding tax on payments to an individual — rent is withheld at 5 % and remitted on form ภ.ง.ด.3. The Revenue Code provision setting the rate, and the day it started, were not read this session; `valid_from` is 1 January of the golden scenario''s year and not a verified commencement date. The rent itself carries no value added tax (section 81, TH-S-EX/TH-P-EX), so the two never need to share a line.', null, null, 90, 'withholding', true, array['buyer_status']::tax_condition[], null, false, false, null, 'rd-wht-indiv', null, null, null, null),
  ('TH', 'TH-P-WHT-SVC-3', 'ค่าบริการ/ค่าที่ปรึกษา หัก ณ ที่จ่ายร้อยละ 3', '{"en":"Service or consultancy fee, 3 % withheld"}'::jsonb, 'ค่าจ้างทำของหรือค่าบริการที่จ่ายให้บริษัทหรือผู้ประกอบการในประเทศที่ไม่ได้จดทะเบียนภาษีมูลค่าเพิ่ม', 'percent', 3, 'purchase', 'not_subject', date '2026-01-01', null, 'Revenue Department, Withholding tax on payments to a juristic person — the rate for a service fee or professional fee paid to a Thai company or branch is 3 %, withheld and remitted with form CIT 53 (ภ.ง.ด.53) within seven days of the month of payment. The rate is generally set under Revenue Code, section 3 tredecim and the Director-General''s departmental instruction (คำสั่งกรมสรรพากร ที่ ท.ป.4/2528), which this session did not read; the day the 3 % rate itself first applied was not carried, so `valid_from` is 1 January of the golden scenario''s year, not a verified commencement date. Modelled here for a fee paid to a small business person not registered for value added tax, so no value added tax code shares the line; a fee that is both value added tax-able and subject to withholding needs two postings this pack does not compose on one line, which is a gap named below.', null, null, 80, 'withholding', true, array['buyer_status']::tax_condition[], null, false, false, null, 'rd-wht-corp', null, null, null, null),
  ('TH', 'TH-S-EX', 'ขาย ได้รับยกเว้นภาษีมูลค่าเพิ่ม', '{"en":"Sale, exempt from value added tax"}'::jsonb, 'การประกอบกิจการที่ได้รับยกเว้นภาษีมูลค่าเพิ่มตามมาตรา 81 เช่น การให้เช่าอสังหาริมทรัพย์', 'percent', 0, 'sale', 'exempt', date '2017-10-01', null, 'Revenue Code, section 81, read directly this session: the businesses it exempts include (among the others the page lists) ''rental of immovable property''. It carries no report box because nothing read this session shows form VAT 30 asking for the value of an exempt supply the way Singapore''s form GST F5 does at its box 3; a business exempt under section 81 is, for that activity, outside the value added tax system rather than a registrant reporting a nil-rated line, which section 81/1''s own small-business exemption confirms by its own separate threshold.', 'E', null, 40, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'rc-vat-80', null, null, null, null),
  ('TH', 'TH-S-STD', 'ขาย ภาษีมูลค่าเพิ่มอัตราร้อยละ 7', '{"en":"Sale, standard rate, value added tax 7 %"}'::jsonb, 'การขายสินค้าหรือให้บริการในประเทศ', 'percent', 7, 'sale', 'domestic', date '2017-10-01', null, 'Revenue Code, section 80 — the rate of value added tax calculation is 10.00 %, read directly this session. Royal Decree issued under the Revenue Code Governing Reduction of the Rate of Value Added Tax (No. 799), B.E. 2568 (2025) continues the reduction to 6.3 % plus a 0.7 % local tax, 7 % combined, a chain of decrees this session could not read as machine text (the PDF resisted extraction twice); the period this code opens on, 1 October 2017, is when a predecessor in the same chain of decrees is reported to have started it, and could not be independently re-verified against the Royal Gazette this session either. The 0.7 % local tax is not modelled as a second posting: it is an allocation the Revenue Department makes internally once it has collected the 7 %, and nothing read this session asks a taxpayer''s own return or books to show the two shares apart, unlike Japan''s national and local consumption tax. The base is reported and the tax charged, without a box this pack could verify the printed number of (see the pack''s own README).', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rc-vat-80', null, null, null, null),
  ('TH', 'TH-S-ZR-EXP', 'ขายส่งออก อัตราร้อยละ 0', '{"en":"Export sale, zero rate"}'::jsonb, 'การส่งออกสินค้าซึ่งมิใช่การส่งออกที่ได้รับยกเว้นภาษีมูลค่าเพิ่มตามมาตรา 81(3)', 'percent', 0, 'sale', 'export', date '2017-10-01', null, 'Revenue Code, section 80/1(1), read directly this session: zero rate applies to the export of goods which is not exempt from value added tax under section 81(3). This session did not read what section 81(3) excludes, nor the export documents a business must hold, which stays a matter of `legal_reference` on a specific line and not of a ledger fact this pack can check.', 'G', null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'rc-vat-80', null, null, null, null),
  ('TH', 'TH-S-ZR-SVC', 'ขายบริการระหว่างประเทศ อัตราร้อยละ 0', '{"en":"International service, zero rate"}'::jsonb, 'บริการที่กระทำในราชอาณาจักรและได้มีการใช้บริการนั้นในต่างประเทศ หรือการขนส่งระหว่างประเทศ', 'percent', 0, 'sale', 'export', date '2017-10-01', null, 'Revenue Code, section 80/1(2), read directly this session: zero rate applies to the provision of services performed in Thailand and used in a foreign country, and (per the same page''s paraphrase, not read word for word) to international transport by aircraft or vessel. Which service qualifies, and where its benefit is received, is a fact of the engagement the ledger does not hold, which is why this code carries `conditions` rather than a rule the core evaluates.', 'G', null, 30, 'vat', true, array['supply_nature', 'buyer_status']::tax_condition[], null, false, false, null, 'rc-vat-80', null, null, null, null)
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
    ('TH-P-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TH-P-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TH-P-RC', 'invoice', 'base', 100, null, 'RC', array['RC']::text[], 100, 'TH-VAT-30', 10),
    ('TH-P-RC', 'invoice', 'tax', -100, '2100', 'OT', array['OT']::text[], 100, 'TH-VAT-30', 20),
    ('TH-P-RC', 'invoice', 'tax', 100, '1150', 'IT', array['IT']::text[], 100, 'TH-VAT-30', 30),
    ('TH-P-RC', 'credit_note', 'base', 100, null, 'RC', array['RC']::text[], -100, 'TH-VAT-30', 10),
    ('TH-P-RC', 'credit_note', 'tax', -100, '2100', 'OT', array['OT']::text[], -100, 'TH-VAT-30', 20),
    ('TH-P-RC', 'credit_note', 'tax', 100, '1150', 'IT', array['IT']::text[], -100, 'TH-VAT-30', 30),
    ('TH-P-STD', 'invoice', 'base', 100, null, 'PB', array['PB']::text[], 100, 'TH-VAT-30', 10),
    ('TH-P-STD', 'invoice', 'tax', 100, '1150', 'IT', array['IT']::text[], 100, 'TH-VAT-30', 20),
    ('TH-P-STD', 'credit_note', 'base', 100, null, 'PB', array['PB']::text[], -100, 'TH-VAT-30', 10),
    ('TH-P-STD', 'credit_note', 'tax', 100, '1150', 'IT', array['IT']::text[], -100, 'TH-VAT-30', 20),
    ('TH-P-WHT-RENT-5', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TH-P-WHT-RENT-5', 'invoice', 'tax', -100, '2140', null, null, 100, null, 20),
    ('TH-P-WHT-RENT-5', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TH-P-WHT-RENT-5', 'credit_note', 'tax', -100, '2140', null, null, 100, null, 20),
    ('TH-P-WHT-SVC-3', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TH-P-WHT-SVC-3', 'invoice', 'tax', -100, '2140', null, null, 100, null, 20),
    ('TH-P-WHT-SVC-3', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TH-P-WHT-SVC-3', 'credit_note', 'tax', -100, '2140', null, null, 100, null, 20),
    ('TH-S-EX', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('TH-S-EX', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('TH-S-STD', 'invoice', 'base', 100, null, 'SB', array['SB']::text[], 100, 'TH-VAT-30', 10),
    ('TH-S-STD', 'invoice', 'tax', 100, '2100', 'OT', array['OT']::text[], 100, 'TH-VAT-30', 20),
    ('TH-S-STD', 'credit_note', 'base', 100, null, 'SB', array['SB']::text[], -100, 'TH-VAT-30', 10),
    ('TH-S-STD', 'credit_note', 'tax', 100, '2100', 'OT', array['OT']::text[], -100, 'TH-VAT-30', 20),
    ('TH-S-ZR-EXP', 'invoice', 'base', 100, null, 'SZ', array['SZ']::text[], 100, 'TH-VAT-30', 10),
    ('TH-S-ZR-EXP', 'credit_note', 'base', 100, null, 'SZ', array['SZ']::text[], -100, 'TH-VAT-30', 10),
    ('TH-S-ZR-SVC', 'invoice', 'base', 100, null, 'SZ', array['SZ']::text[], 100, 'TH-VAT-30', 10),
    ('TH-S-ZR-SVC', 'credit_note', 'base', 100, null, 'SZ', array['SZ']::text[], -100, 'TH-VAT-30', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'TH' and t.code = v.tax_code
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
  ('TH', 'TH-VAT-30', 'แบบแสดงรายการภาษีมูลค่าเพิ่ม (ภ.พ.30)', array['month']::declaration_period[], 'month'::declaration_period, date '2017-10-01', null, 'Revenue Code, section 83, read only through the Revenue Department''s own English summary this session (rd-vat-guide) and not word for word: a VAT-registered business files a return every calendar month, with no other cadence the way some of this repository''s forms offer a quarter or a half-year. That page names form ''VAT 30'' in English for what is filed as ภ.พ.30; it lists what the form covers by topic — taxable person, exemptions, tax base, tax rates, time of supply, tax invoice, tax calculation, refund, registration, return and payment — and not the form''s own printed item numbers or their exact wording. The boxes below are therefore this pack''s own short codes for the mechanics that page confirms the form has — a base and an output tax on standard-rated sales, the same for zero-rated sales, a base and an input tax on purchases entitled to credit, and the net amount owed or carried forward — and they do not claim to reproduce the numbering or the Thai wording ภ.พ.30 prints. That is the first thing for a reviewer with a specimen return in hand to check.', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Revenue Department, Value Added Tax page, read directly this session: ''VAT return (Form VAT 30) together with tax payment, if any, must be submitted to Area Revenue Branch Office within 15 days of the following month.'' This session could not confirm or rule out an extended deadline for filing through the Revenue Department''s e-filing system, which several other countries in this repository grant; none is declared.', 'rd-vat-guide', null)
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
  ('TH', 'TH-VAT-30', 'SB', 'base', 'มูลค่าขายที่ต้องเสียภาษีมูลค่าเพิ่มในอัตราร้อยละ 7 (ไม่รวมภาษีมูลค่าเพิ่ม)', '{"en":"Value of standard-rated sales (without value added tax)"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value, without value added tax, of a sale taxed at the standard combined rate under section 80 and the Royal Decree reducing it — see TH-S-STD.', 'rc-vat-80'),
  ('TH', 'TH-VAT-30', 'SZ', 'base', 'มูลค่าขายที่เสียภาษีมูลค่าเพิ่มในอัตราร้อยละ 0', '{"en":"Value of zero-rated sales"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of an export of goods (section 80/1(1)) or a zero-rated service (section 80/1(2)) — see TH-S-ZR-EXP and TH-S-ZR-SVC.', 'rc-vat-80'),
  ('TH', 'TH-VAT-30', 'OT', 'tax', 'ภาษีขาย', '{"en":"Output tax"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value added tax charged on box SB, and the tax a payer self-assesses under section 83/6 on a service bought from abroad and used in Thailand — see TH-S-STD and TH-P-RC.', 'rc-vat-80'),
  ('TH', 'TH-VAT-30', 'PB', 'base', 'มูลค่าซื้อที่นำภาษีซื้อมาหักในการคำนวณภาษีได้ (ไม่รวมภาษีมูลค่าเพิ่ม)', '{"en":"Value of purchases entitled to input tax credit (without value added tax)"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value, without value added tax, of a purchase whose input tax this pack takes as fully creditable — see TH-P-STD.', 'rc-vat-80'),
  ('TH', 'TH-VAT-30', 'RC', 'base', 'มูลค่าบริการจากต่างประเทศที่นำส่งภาษีมูลค่าเพิ่มตามมาตรา 83/6', '{"en":"Value of services from abroad remitted under section 83/6"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The value of a service bought from abroad and used in Thailand, reported separately from box PB because it reaches the return through the payer''s own self-assessment under section 83/6 and not through a Thai supplier''s tax invoice — see TH-P-RC.', 'rc-vat-83'),
  ('TH', 'TH-VAT-30', 'IT', 'tax', 'ภาษีซื้อ', '{"en":"Input tax"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'The input tax of box PB, and the tax self-assessed on box RC that section 83/6 lets the same payer credit — see TH-P-STD and TH-P-RC. This pack claims that credit in the same period it is self-assessed, which is a simplification named in the pack''s README and in docs/international.md.', 'rc-vat-80'),
  ('TH', 'TH-VAT-30', 'NET', 'total', 'ภาษีมูลค่าเพิ่มที่ต้องชำระ หรือภาษีที่ชำระไว้เกิน (ขอคืนหรือยกไป)', '{"en":"Value added tax payable, or tax overpaid (refundable or carried forward)"}'::jsonb, 70, null, array['OT']::text[], array['IT']::text[], null, null, false, false, null, 'Output tax less input tax for the period. A negative figure is not floored to zero: this session could not verify Thailand''s own rule for a small net amount (Singapore''s equivalent form waives one under 5 Singapore dollars; nothing read here says whether Thailand has an equivalent), and a Revenue Code provision on carrying a credit forward or claiming a refund was not read, so what a negative NET becomes — a refund, a credit carried to the next month, or a choice between the two — is not modelled beyond the figure itself.', 'rd-vat-guide')
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
  ('TH-BS', 'TH', 'default', 'งบแสดงฐานะการเงิน', 'balance_sheet', 'TH-ORIGINAL', date '1970-01-01', null, 'Thailand prescribes no line items of its own that this session could read: the Federation of Accounting Professions issues a Thai Financial Reporting Standard for entities that are not publicly accountable, and this session could not open its text (see the pack''s README, "Sources"). This statement is original: it groups this chart''s own accounts by the code ranges accounts.csv gives them — current and non-current, receivables and payables split from other balances — the same classification IFRS for SMEs, section 4, uses without transcribing that section''s own line items or their numbering.', null),
  ('TH-IS', 'TH', 'default', 'งบกำไรขาดทุน', 'income_statement', 'TH-ORIGINAL', date '1970-01-01', null, 'As TH-BS: original, grouped by the code ranges accounts.csv gives this chart''s revenue, cost and expense accounts.', null)
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
  ('TH-BS', 'A-C-CASH', 'A-C', 'เงินสดและรายการเทียบเท่าเงินสด', '{"en":"Cash and cash equivalents"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-C-REC', 'A-C', 'ลูกหนี้การค้า', '{"en":"Trade receivables"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-C-OTH', 'A-C', 'ภาษีซื้อ ลูกหนี้อื่น และสินค้าคงเหลือ', '{"en":"Input value added tax, other receivables and inventory"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-C-PREP', 'A-C', 'ค่าใช้จ่ายจ่ายล่วงหน้าและเงินประกันจ่าย', '{"en":"Prepaid expenses and deposits paid"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-C', null, 'สินทรัพย์หมุนเวียน', '{"en":"Current assets"}'::jsonb, 50, 1, true, array['A-C-CASH', 'A-C-REC', 'A-C-OTH', 'A-C-PREP']::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-NC-FIX', 'A-NC', 'ที่ดิน อาคาร และอุปกรณ์ (สุทธิจากค่าเสื่อมราคาสะสม)', '{"en":"Property, plant and equipment (net of accumulated depreciation)"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-NC-OTH', 'A-NC', 'สินทรัพย์ไม่มีตัวตนและสินทรัพย์ไม่หมุนเวียนอื่น', '{"en":"Intangible assets and other non-current assets"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-NC', null, 'สินทรัพย์ไม่หมุนเวียน', '{"en":"Non-current assets"}'::jsonb, 80, 1, true, array['A-NC-FIX', 'A-NC-OTH']::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'A-TOT', null, 'รวมสินทรัพย์', '{"en":"Total assets"}'::jsonb, 90, 1, true, array['A-C', 'A-NC']::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'L-C-PAY', 'L-C', 'เจ้าหนี้การค้า', '{"en":"Trade payables"}'::jsonb, 100, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'L-C-OTH', 'L-C', 'ภาษีขาย ภาษีค้างจ่าย เจ้าหนี้อื่น และหนี้สินหมุนเวียนอื่น', '{"en":"Output value added tax, tax payables, other payables and other current liabilities"}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'L-C', null, 'หนี้สินหมุนเวียน', '{"en":"Current liabilities"}'::jsonb, 120, 1, true, array['L-C-PAY', 'L-C-OTH']::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'L-NC', 'L-TOT', 'หนี้สินไม่หมุนเวียน', '{"en":"Non-current liabilities"}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'L-TOT', null, 'รวมหนี้สิน', '{"en":"Total liabilities"}'::jsonb, 140, 1, true, array['L-C', 'L-NC']::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'E-CAP', 'E-TOT', 'ทุนจดทะเบียนและเรียกชำระแล้ว และส่วนเกินมูลค่าหุ้น', '{"en":"Registered and paid-up share capital, and share premium"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'E-RET', 'E-TOT', 'กำไรสะสม', '{"en":"Retained earnings"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'E-RESULT', 'E-TOT', 'ผลการดำเนินงานของงวดที่ยังไม่ได้จัดสรร', '{"en":"Result for the period, not yet allocated"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'E-TOT', null, 'รวมส่วนของเจ้าของ', '{"en":"Total equity"}'::jsonb, 180, 1, true, array['E-CAP', 'E-RET', 'E-RESULT']::text[], '{}'::text[], null, null, null),
  ('TH-BS', 'EL-TOT', null, 'รวมหนี้สินและส่วนของเจ้าของ', '{"en":"Total liabilities and equity"}'::jsonb, 190, 1, true, array['L-TOT', 'E-TOT']::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'REV', null, 'รายได้', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'COST', null, 'ต้นทุนขาย', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'GROSS', null, 'กำไรขั้นต้น', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['REV']::text[], array['COST']::text[], null, null, null),
  ('TH-IS', 'OTH-INC', null, 'รายได้อื่น', '{"en":"Other income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'OPEX', null, 'ค่าใช้จ่ายในการขายและบริหาร และต้นทุนทางการเงิน', '{"en":"Selling, administrative and finance expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'DEPR', null, 'ค่าเสื่อมราคา', '{"en":"Depreciation"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'PRETAX', null, 'กำไรก่อนภาษีเงินได้', '{"en":"Profit before income tax"}'::jsonb, 70, 1, true, array['GROSS', 'OTH-INC']::text[], array['OPEX', 'DEPR']::text[], null, null, null),
  ('TH-IS', 'TAX', null, 'ภาษีเงินได้นิติบุคคล', '{"en":"Corporate income tax"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('TH-IS', 'PROFIT', null, 'กำไร (ขาดทุน) สุทธิสำหรับงวด', '{"en":"Profit (loss) for the period"}'::jsonb, 90, 1, true, array['PRETAX']::text[], array['TAX']::text[], null, null, null)
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
    ('TH-BS', 'A-C-CASH', 10, 'code_range', '1000', '1099', null, 'any'),
    ('TH-BS', 'A-C-REC', 10, 'code_range', '1100', '1119', null, 'any'),
    ('TH-BS', 'A-C-OTH', 10, 'code_range', '1120', '1299', null, 'any'),
    ('TH-BS', 'A-C-PREP', 10, 'code_range', '1300', '1399', null, 'any'),
    ('TH-BS', 'A-NC-FIX', 10, 'code_range', '1600', '1699', null, 'any'),
    ('TH-BS', 'A-NC-OTH', 10, 'code_range', '1700', '1799', null, 'any'),
    ('TH-BS', 'L-C-PAY', 10, 'code_range', '2000', '2009', null, 'any'),
    ('TH-BS', 'L-C-OTH', 10, 'code_range', '2010', '2499', null, 'any'),
    ('TH-BS', 'L-C-OTH', 20, 'code_range', '2900', '2999', null, 'any'),
    ('TH-BS', 'L-NC', 10, 'code_range', '2500', '2599', null, 'any'),
    ('TH-BS', 'E-CAP', 10, 'code_range', '3000', '3199', null, 'any'),
    ('TH-BS', 'E-RET', 10, 'code_range', '3200', '3299', null, 'any'),
    ('TH-BS', 'E-RESULT', 10, 'code_range', '4000', '5999', null, 'any'),
    ('TH-BS', 'E-RESULT', 20, 'code_range', '6000', '8999', null, 'any'),
    ('TH-IS', 'REV', 10, 'code_range', '4000', '4599', null, 'any'),
    ('TH-IS', 'COST', 10, 'code_range', '5000', '5099', null, 'any'),
    ('TH-IS', 'OTH-INC', 10, 'code_range', '4700', '4999', null, 'any'),
    ('TH-IS', 'OPEX', 10, 'code_range', '6000', '6969', null, 'any'),
    ('TH-IS', 'OPEX', 20, 'code_range', '6980', '7099', null, 'any'),
    ('TH-IS', 'DEPR', 10, 'code_range', '6970', '6979', null, 'any'),
    ('TH-IS', 'TAX', 10, 'code_range', '8000', '8099', null, 'any')
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
  ('TH', 'ประเทศไทย', '{"en":"Thailand"}'::jsonb, array['th', 'en']::text[], 'THB', '1100', '2000', '2990', '6990', '3200', '4000', '5000', '1010', '1000', 'SAL', 'PUR', 'GEN', 'th', 'retained_earnings', null, null, null, 'OPN', default, default, '4700', '6950', '4750', '6960', null, null, '2110', '1155', null, 'month'::declaration_period)
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
  numbering_legal_reference     = 'Revenue Code, section 86/4(4), read directly this session — a tax invoice states ''serial number of tax invoice and, if any, of book''. The text asks for an identifying number and not, in so many words, for a series with no gap, which is why numbering is `sequential` and not one of the gapless kinds; the pattern in number_format is one a business may choose.',
  numbering_source_key          = 'rc-vat-86',
  payment_terms_legal_reference = 'No statute setting a payment term between businesses in the absence of an agreement was found this session; the search was not exhaustive, and a duty analogous to the European late-payment directives may or may not exist in the Civil and Commercial Code. legal_payment_days and late_payment_reference are left null rather than guessed.',
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Not independently read this session against the primary text of sections 78 and 78/1, which this session''s attempts to open returned a server error. The rule stated here — a supply of goods is taxed at the earliest of transfer of ownership or possession, receipt of payment, or issue of a tax invoice, and a supply of services at the earliest of payment or the issue of a tax invoice — is the one consistently given by secondary guidance on the Revenue Code, and `earliest_of_delivery_or_payment` is the closest of this format''s five values to it; the vocabulary has no word for a tax invoice itself as an independent third trigger, which is a gap of the core and not of this reading, and is carried in docs/international.md. The first thing for a reviewer to check against sections 78 and 78/1 directly.',
  tax_point_source_key          = 'rc-vat-80',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'The Revenue Department operates e-Tax Invoice & e-Receipt (etax.rd.go.th), a system a business submits the data of its tax invoices to, by XML with a digital signature or, for a smaller business, by time stamp; it is not built on Peppol and this pack names no `profile`. This session could not open the portal (it renders through client-side script the tools available here could not execute) and so could not verify whether any turnover threshold makes participation mandatory rather than voluntary for a class of taxpayer, or from what date. `obligation` is therefore left at `none` rather than a guess, which states only that no statute was found requiring it — not that none exists. The first thing for a reviewer to check directly on etax.rd.go.th, and the leading item of this pack''s section of docs/international.md.',
  einvoice_source_key           = null,
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'TH';
