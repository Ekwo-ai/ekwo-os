-- Ekwo OS — 대한민국: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/kr at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build kr`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   부가가치세법 (Value-Added Tax Act) — 법률 제20776호, 2025. 3. 14. 일부개정, 2025. 7. 1. 시행 (국가법령정보센터 (Korea Ministry of Government Legislation))
--     https://www.law.go.kr/법령/부가가치세법
--   부가가치세법 시행령 (Enforcement Decree of the Value-Added Tax Act) (국가법령정보센터 (Korea Ministry of Government Legislation))
--     https://www.law.go.kr/법령/부가가치세법시행령
--   부가가치세법 시행규칙 [별지 제21호서식] 일반과세자 부가가치세[예정, 확정, 기한후과세표준, 영세율 등 조기환급]신고서, 개정 2021. 3. 16. (국가법령정보센터 (Korea Ministry of Government Legislation))
--     https://www.law.go.kr/LSW/flDownload.do?flSeq=97706537
--   법인세법 (Corporate Tax Act), 제6조 (사업연도) (국가법령정보센터 (Korea Ministry of Government Legislation))
--     https://www.law.go.kr/법령/법인세법
--   상법 (Commercial Act), 제29조 (상업장부) 및 제447조 (재무제표의 작성) (국가법령정보센터 (Korea Ministry of Government Legislation))
--     https://www.law.go.kr/법령/상법
--   국고금 관리법 (State Funds Management Act), 제47조 (국고금의 끝수 계산) (국가법령정보센터 (Korea Ministry of Government Legislation))
--     https://www.law.go.kr/법령/국고금관리법
--   부가가치세 신고·납부기한 안내 (국세청 (National Tax Service))
--     https://www.nts.go.kr/nts/cm/cntnts/cntntsView.do?mi=2273&cntntsId=7694
--   전자(세금)계산서 — 발급의무대상자 (국세청 (National Tax Service))
--     https://www.nts.go.kr/nts/cm/cntnts/cntntsView.do?mi=2461&cntntsId=7787
--   전자세금계산서 발급 및 전송 기한, 가산세 (국세청 (National Tax Service))
--     https://www.nts.go.kr/nts/cm/cntnts/cntntsView.do?mi=2463&cntntsId=7789
--   홈택스 (Hometax) — 국세청 국세전자신고·납부 시스템 (국세청 (National Tax Service))
--     https://www.hometax.go.kr
--   간이과세 기준금액 1억 400만원으로 상향 (2024. 7. 1. 시행) (대한민국 정책브리핑 (Korea Policy Briefing, korea.kr))
--     https://www.korea.kr/news/policyNewsView.do?newsId=148930428
--   Peppol Authorities — list of members (OpenPeppol)
--     https://peppol.org/members/peppol-authorities/
--   한국회계기준원 (Korea Accounting Standards Board) — 일반기업회계기준 (한국회계기준원)
--     https://www.kasb.or.kr
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('KR', '대한민국', '0.1.0', date '2026-09-22', '20260917170000', 'community', null, null, '498890fd447cecf7e6aa3543b006433147d6634eba3605c916e4d3cbda766c0b', '[{"key":"vat-act","title":"부가가치세법 (Value-Added Tax Act) — 법률 제20776호, 2025. 3. 14. 일부개정, 2025. 7. 1. 시행","publisher":"국가법령정보센터 (Korea Ministry of Government Legislation)","url":"https://www.law.go.kr/법령/부가가치세법","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-decree","title":"부가가치세법 시행령 (Enforcement Decree of the Value-Added Tax Act)","publisher":"국가법령정보센터 (Korea Ministry of Government Legislation)","url":"https://www.law.go.kr/법령/부가가치세법시행령","consulted_on":"2026-09-22","kind":"regulation"},{"key":"vat-form21","title":"부가가치세법 시행규칙 [별지 제21호서식] 일반과세자 부가가치세[예정, 확정, 기한후과세표준, 영세율 등 조기환급]신고서, 개정 2021. 3. 16.","publisher":"국가법령정보센터 (Korea Ministry of Government Legislation)","url":"https://www.law.go.kr/LSW/flDownload.do?flSeq=97706537","consulted_on":"2026-09-22","kind":"form"},{"key":"corp-tax-act","title":"법인세법 (Corporate Tax Act), 제6조 (사업연도)","publisher":"국가법령정보센터 (Korea Ministry of Government Legislation)","url":"https://www.law.go.kr/법령/법인세법","consulted_on":"2026-09-22","kind":"law"},{"key":"commercial-act","title":"상법 (Commercial Act), 제29조 (상업장부) 및 제447조 (재무제표의 작성)","publisher":"국가법령정보센터 (Korea Ministry of Government Legislation)","url":"https://www.law.go.kr/법령/상법","consulted_on":"2026-09-22","kind":"law"},{"key":"treasury-funds-act","title":"국고금 관리법 (State Funds Management Act), 제47조 (국고금의 끝수 계산)","publisher":"국가법령정보센터 (Korea Ministry of Government Legislation)","url":"https://www.law.go.kr/법령/국고금관리법","consulted_on":"2026-09-22","kind":"law"},{"key":"nts-filing-deadline","title":"부가가치세 신고·납부기한 안내","publisher":"국세청 (National Tax Service)","url":"https://www.nts.go.kr/nts/cm/cntnts/cntntsView.do?mi=2273&cntntsId=7694","consulted_on":"2026-09-22","kind":"guidance"},{"key":"nts-einvoice-obligors","title":"전자(세금)계산서 — 발급의무대상자","publisher":"국세청 (National Tax Service)","url":"https://www.nts.go.kr/nts/cm/cntnts/cntntsView.do?mi=2461&cntntsId=7787","consulted_on":"2026-09-22","kind":"guidance"},{"key":"nts-einvoice-deadline","title":"전자세금계산서 발급 및 전송 기한, 가산세","publisher":"국세청 (National Tax Service)","url":"https://www.nts.go.kr/nts/cm/cntnts/cntntsView.do?mi=2463&cntntsId=7789","consulted_on":"2026-09-22","kind":"guidance"},{"key":"hometax","title":"홈택스 (Hometax) — 국세청 국세전자신고·납부 시스템","publisher":"국세청 (National Tax Service)","url":"https://www.hometax.go.kr","consulted_on":"2026-09-22","kind":"portal"},{"key":"simplified-threshold","title":"간이과세 기준금액 1억 400만원으로 상향 (2024. 7. 1. 시행)","publisher":"대한민국 정책브리핑 (Korea Policy Briefing, korea.kr)","url":"https://www.korea.kr/news/policyNewsView.do?newsId=148930428","consulted_on":"2026-09-22","kind":"guidance"},{"key":"peppol-authorities","title":"Peppol Authorities — list of members","publisher":"OpenPeppol","url":"https://peppol.org/members/peppol-authorities/","consulted_on":"2026-09-22","kind":"standard"},{"key":"kasb","title":"한국회계기준원 (Korea Accounting Standards Board) — 일반기업회계기준","publisher":"한국회계기준원","url":"https://www.kasb.or.kr","consulted_on":"2026-09-22","kind":"standard"}]'::jsonb)
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
  ('KR', 'default', '대한민국 참고 계정과목표 (일반기업회계기준 기준)', '{"en":"South Korea reference chart of accounts (general accounting practice)"}'::jsonb, true, 'companies', array['KR-GAAP-BS', 'KR-GAAP-IS']::text[], null, '대한민국은 법정 계정과목표를 두지 않는다. 상법 제29조는 상업장부(회계장부와 대차대조표)의 작성 의무를, 제447조는 주식회사의 재무제표(대차대조표, 손익계산서 등) 작성 의무를 정할 뿐, 계정과목의 번호나 명칭을 지정하지 않는다. 외부감사 대상이 아니거나 한국채택국제회계기준(K-IFRS)을 적용하지 않는 회사는 한국회계기준원(KASB)이 제정한 일반기업회계기준에 따라 재무제표를 작성하며, 이 기준은 재무상태표의 유동·비유동 구분과 손익계산서의 단계별 이익(매출총이익·영업이익·법인세비용차감전순이익·당기순이익) 구조는 정하지만 계정과목표 자체는 정하지 않는다(작성사·회계프로그램마다 계정과목이 다르다). 이 계정과목표는 독자적으로 작성한 것으로, 네 자리 숫자로 대분류(1 자산, 2 부채, 3 자본, 4 수익, 5 매출원가, 6 판매비와관리비, 7 영업외비용, 8 법인세비용)를 나누고, 한국 실무에서 통용되는 계정명을 사용한다. 어떤 공식·상용 계정과목표도 그대로 옮기지 않았다. 부가가치세는 세금계산서에 부가가치세액을 별도로 표시하는 방식(세액 별도)으로 기장하며, 매출 시 부가세예수금(계정 2150), 매입 시 부가세대급금(계정 1250)에 각각 계상하고 신고·납부 시 미지급세금(2155) 또는 미수금(부가세환급세액)(1255)으로 정산한다.', 'commercial-act')
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
  ('KR', 'default', '1100', '현금', '{"en":"Cash"}'::jsonb, 'asset_cash', false, null, 10),
  ('KR', 'default', '1110', '보통예금', '{"en":"Checking deposit"}'::jsonb, 'asset_cash', false, null, 20),
  ('KR', 'default', '1120', '정기예금(1년 이내)', '{"en":"Time deposit (within 1 year)"}'::jsonb, 'asset_cash', false, null, 30),
  ('KR', 'default', '1130', '외화예금', '{"en":"Foreign currency deposit"}'::jsonb, 'asset_cash', false, null, 40),
  ('KR', 'default', '1200', '받을어음', '{"en":"Notes receivable"}'::jsonb, 'asset_receivable', true, null, 50),
  ('KR', 'default', '1210', '외상매출금', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, null, 60),
  ('KR', 'default', '1215', '미수금', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, null, 70),
  ('KR', 'default', '1219', '대손충당금(매출채권)', '{"en":"Allowance for doubtful accounts (trade receivables)"}'::jsonb, 'asset_current', false, null, 80),
  ('KR', 'default', '1225', '부도어음과수표', '{"en":"Dishonored notes and checks"}'::jsonb, 'asset_receivable', true, null, 85),
  ('KR', 'default', '1230', '선급금', '{"en":"Advances paid"}'::jsonb, 'asset_prepayments', false, null, 90),
  ('KR', 'default', '1240', '선급비용', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, null, 100),
  ('KR', 'default', '1250', '부가세대급금', '{"en":"Input VAT"}'::jsonb, 'asset_current', false, null, 110),
  ('KR', 'default', '1255', '미수금(부가세환급세액)', '{"en":"VAT refundable"}'::jsonb, 'asset_current', true, null, 120),
  ('KR', 'default', '1260', '미수수익', '{"en":"Accrued income"}'::jsonb, 'asset_current', false, null, 130),
  ('KR', 'default', '1270', '유가증권', '{"en":"Marketable securities"}'::jsonb, 'asset_current', false, null, 140),
  ('KR', 'default', '1310', '상품', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, null, 150),
  ('KR', 'default', '1320', '제품', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, null, 160),
  ('KR', 'default', '1330', '재공품', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, null, 170),
  ('KR', 'default', '1340', '원재료', '{"en":"Raw materials"}'::jsonb, 'asset_current', false, null, 180),
  ('KR', 'default', '1345', '미착상품', '{"en":"Goods in transit"}'::jsonb, 'asset_current', false, null, 185),
  ('KR', 'default', '1350', '저장품', '{"en":"Supplies"}'::jsonb, 'asset_current', false, null, 190),
  ('KR', 'default', '1500', '토지', '{"en":"Land"}'::jsonb, 'asset_fixed', false, null, 200),
  ('KR', 'default', '1510', '건물', '{"en":"Buildings"}'::jsonb, 'asset_fixed', false, null, 210),
  ('KR', 'default', '1511', '건물감가상각누계액', '{"en":"Accumulated depreciation — buildings"}'::jsonb, 'asset_fixed', false, null, 220),
  ('KR', 'default', '1520', '구축물', '{"en":"Structures"}'::jsonb, 'asset_fixed', false, null, 230),
  ('KR', 'default', '1521', '구축물감가상각누계액', '{"en":"Accumulated depreciation — structures"}'::jsonb, 'asset_fixed', false, null, 240),
  ('KR', 'default', '1530', '기계장치', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 250),
  ('KR', 'default', '1531', '기계장치감가상각누계액', '{"en":"Accumulated depreciation — machinery and equipment"}'::jsonb, 'asset_fixed', false, null, 260),
  ('KR', 'default', '1540', '차량운반구', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, null, 270),
  ('KR', 'default', '1541', '차량운반구감가상각누계액', '{"en":"Accumulated depreciation — vehicles"}'::jsonb, 'asset_fixed', false, null, 280),
  ('KR', 'default', '1550', '비품', '{"en":"Fixtures and fittings"}'::jsonb, 'asset_fixed', false, null, 290),
  ('KR', 'default', '1551', '비품감가상각누계액', '{"en":"Accumulated depreciation — fixtures and fittings"}'::jsonb, 'asset_fixed', false, null, 300),
  ('KR', 'default', '1560', '건설중인자산', '{"en":"Construction in progress"}'::jsonb, 'asset_fixed', false, null, 310),
  ('KR', 'default', '1610', '영업권', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, null, 320),
  ('KR', 'default', '1620', '산업재산권', '{"en":"Industrial property rights"}'::jsonb, 'asset_non_current', false, null, 330),
  ('KR', 'default', '1630', '개발비', '{"en":"Development costs"}'::jsonb, 'asset_non_current', false, null, 340),
  ('KR', 'default', '1640', '소프트웨어', '{"en":"Software"}'::jsonb, 'asset_non_current', false, null, 350),
  ('KR', 'default', '1650', '회원권', '{"en":"Membership rights"}'::jsonb, 'asset_non_current', false, null, 355),
  ('KR', 'default', '1710', '임차보증금', '{"en":"Lease deposits"}'::jsonb, 'asset_non_current', false, null, 360),
  ('KR', 'default', '1720', '장기대여금', '{"en":"Long-term loans receivable"}'::jsonb, 'asset_non_current', false, null, 370),
  ('KR', 'default', '1730', '이연법인세자산', '{"en":"Deferred tax assets"}'::jsonb, 'asset_non_current', false, null, 380),
  ('KR', 'default', '1740', '투자부동산', '{"en":"Investment property"}'::jsonb, 'asset_non_current', false, null, 390),
  ('KR', 'default', '2100', '지급어음', '{"en":"Notes payable"}'::jsonb, 'liability_payable', true, null, 400),
  ('KR', 'default', '2110', '외상매입금', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, null, 410),
  ('KR', 'default', '2120', '미지급금', '{"en":"Other payables"}'::jsonb, 'liability_current', false, null, 420),
  ('KR', 'default', '2130', '미지급비용', '{"en":"Accrued expenses"}'::jsonb, 'liability_current', false, null, 430),
  ('KR', 'default', '2135', '미지급관세등', '{"en":"Customs duties payable"}'::jsonb, 'liability_current', false, null, 440),
  ('KR', 'default', '2140', '예수금', '{"en":"Withholdings payable"}'::jsonb, 'liability_current', false, null, 450),
  ('KR', 'default', '2145', '미지급배당금', '{"en":"Dividends payable"}'::jsonb, 'liability_current', false, null, 455),
  ('KR', 'default', '2150', '부가세예수금', '{"en":"Output VAT"}'::jsonb, 'liability_current', false, null, 460),
  ('KR', 'default', '2155', '미지급세금', '{"en":"VAT payable"}'::jsonb, 'liability_current', true, null, 470),
  ('KR', 'default', '2160', '미지급법인세', '{"en":"Corporate income tax payable"}'::jsonb, 'liability_current', false, null, 480),
  ('KR', 'default', '2170', '선수금', '{"en":"Advances received"}'::jsonb, 'liability_current', false, null, 490),
  ('KR', 'default', '2180', '선수수익', '{"en":"Unearned revenue"}'::jsonb, 'liability_current', false, null, 500),
  ('KR', 'default', '2190', '단기차입금', '{"en":"Short-term borrowings"}'::jsonb, 'liability_current', false, null, 510),
  ('KR', 'default', '2195', '가수금', '{"en":"Suspense receipts"}'::jsonb, 'liability_current', false, null, 520),
  ('KR', 'default', '2200', '사채', '{"en":"Bonds payable"}'::jsonb, 'liability_non_current', false, null, 530),
  ('KR', 'default', '2210', '장기차입금', '{"en":"Long-term borrowings"}'::jsonb, 'liability_non_current', false, null, 540),
  ('KR', 'default', '2220', '퇴직급여충당부채', '{"en":"Provision for severance benefits"}'::jsonb, 'liability_non_current', false, null, 550),
  ('KR', 'default', '2225', '장기미지급금', '{"en":"Long-term other payables"}'::jsonb, 'liability_non_current', false, null, 555),
  ('KR', 'default', '2230', '이연법인세부채', '{"en":"Deferred tax liabilities"}'::jsonb, 'liability_non_current', false, null, 560),
  ('KR', 'default', '3100', '자본금', '{"en":"Share capital"}'::jsonb, 'equity', false, null, 570),
  ('KR', 'default', '3200', '주식발행초과금', '{"en":"Additional paid-in capital"}'::jsonb, 'equity', false, null, 580),
  ('KR', 'default', '3300', '이익준비금', '{"en":"Legal reserve"}'::jsonb, 'equity', false, null, 590),
  ('KR', 'default', '3310', '임의적립금', '{"en":"Voluntary reserve"}'::jsonb, 'equity', false, null, 600),
  ('KR', 'default', '3330', '이월이익잉여금', '{"en":"Retained earnings carried forward"}'::jsonb, 'equity_retained', false, null, 610),
  ('KR', 'default', '3400', '자기주식', '{"en":"Treasury shares"}'::jsonb, 'equity', false, null, 620),
  ('KR', 'default', '4100', '상품매출', '{"en":"Merchandise sales"}'::jsonb, 'income', false, null, 630),
  ('KR', 'default', '4110', '제품매출', '{"en":"Product sales"}'::jsonb, 'income', false, null, 640),
  ('KR', 'default', '4120', '용역매출', '{"en":"Service revenue"}'::jsonb, 'income', false, null, 650),
  ('KR', 'default', '4200', '이자수익', '{"en":"Interest income"}'::jsonb, 'income_other', false, null, 660),
  ('KR', 'default', '4210', '배당금수익', '{"en":"Dividend income"}'::jsonb, 'income_other', false, null, 670),
  ('KR', 'default', '4220', '외환차익', '{"en":"Foreign exchange gain"}'::jsonb, 'income_other', false, null, 680),
  ('KR', 'default', '4230', '유형자산처분이익', '{"en":"Gain on disposal of property and equipment"}'::jsonb, 'income_other', false, null, 690),
  ('KR', 'default', '4240', '잡이익', '{"en":"Miscellaneous income"}'::jsonb, 'income_other', false, null, 700),
  ('KR', 'default', '5100', '상품매출원가', '{"en":"Cost of merchandise sold"}'::jsonb, 'expense_direct_cost', false, null, 710),
  ('KR', 'default', '5110', '기초상품재고액', '{"en":"Merchandise inventory, beginning"}'::jsonb, 'expense_direct_cost', false, null, 720),
  ('KR', 'default', '5120', '당기상품매입액', '{"en":"Merchandise purchases"}'::jsonb, 'expense_direct_cost', false, null, 730),
  ('KR', 'default', '5130', '기말상품재고액', '{"en":"Merchandise inventory, ending"}'::jsonb, 'expense_direct_cost', false, null, 740),
  ('KR', 'default', '6100', '급여', '{"en":"Salaries"}'::jsonb, 'expense', false, null, 750),
  ('KR', 'default', '6110', '퇴직급여', '{"en":"Severance benefits"}'::jsonb, 'expense', false, null, 760),
  ('KR', 'default', '6120', '복리후생비', '{"en":"Employee benefits"}'::jsonb, 'expense', false, null, 770),
  ('KR', 'default', '6130', '여비교통비', '{"en":"Travel expenses"}'::jsonb, 'expense', false, null, 780),
  ('KR', 'default', '6140', '통신비', '{"en":"Communication expenses"}'::jsonb, 'expense', false, null, 790),
  ('KR', 'default', '6150', '수도광열비', '{"en":"Utilities"}'::jsonb, 'expense', false, null, 800),
  ('KR', 'default', '6160', '세금과공과', '{"en":"Taxes and dues"}'::jsonb, 'expense', false, null, 810),
  ('KR', 'default', '6170', '감가상각비', '{"en":"Depreciation expense"}'::jsonb, 'expense_depreciation', false, null, 820),
  ('KR', 'default', '6180', '지급임차료', '{"en":"Rent expense"}'::jsonb, 'expense', false, null, 830),
  ('KR', 'default', '6190', '보험료', '{"en":"Insurance premiums"}'::jsonb, 'expense', false, null, 840),
  ('KR', 'default', '6200', '차량유지비', '{"en":"Vehicle maintenance"}'::jsonb, 'expense', false, null, 850),
  ('KR', 'default', '6210', '기업업무추진비', '{"en":"Business promotion expenses"}'::jsonb, 'expense', false, null, 860),
  ('KR', 'default', '6220', '광고선전비', '{"en":"Advertising"}'::jsonb, 'expense', false, null, 870),
  ('KR', 'default', '6230', '소모품비', '{"en":"Supplies expense"}'::jsonb, 'expense', false, null, 880),
  ('KR', 'default', '6240', '지급수수료', '{"en":"Fees paid"}'::jsonb, 'expense', false, null, 890),
  ('KR', 'default', '6250', '대손상각비', '{"en":"Bad debt expense"}'::jsonb, 'expense', false, null, 900),
  ('KR', 'default', '6255', '잡급', '{"en":"Daily wages"}'::jsonb, 'expense', false, null, 905),
  ('KR', 'default', '6260', '잡비', '{"en":"Miscellaneous expenses"}'::jsonb, 'expense', false, null, 910),
  ('KR', 'default', '7100', '이자비용', '{"en":"Interest expense"}'::jsonb, 'expense', false, null, 920),
  ('KR', 'default', '7110', '외환차손', '{"en":"Foreign exchange loss"}'::jsonb, 'expense', false, null, 930),
  ('KR', 'default', '7120', '기부금', '{"en":"Donations"}'::jsonb, 'expense', false, null, 940),
  ('KR', 'default', '7130', '유형자산처분손실', '{"en":"Loss on disposal of property and equipment"}'::jsonb, 'expense', false, null, 950),
  ('KR', 'default', '7140', '잡손실', '{"en":"Miscellaneous loss"}'::jsonb, 'expense', false, null, 960),
  ('KR', 'default', '7145', '단수차이', '{"en":"Rounding difference"}'::jsonb, 'expense', false, null, 970),
  ('KR', 'default', '8100', '법인세비용', '{"en":"Corporate income tax expense"}'::jsonb, 'expense', false, null, 980)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('KR', 'BNK', '예금출납장', '{"en":"Bank journal"}'::jsonb, 'bank', 30),
  ('KR', 'CSH', '현금출납장', '{"en":"Cash journal"}'::jsonb, 'cash', 40),
  ('KR', 'GEN', '분개장', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('KR', 'OPN', '기초분개', '{"en":"Opening journal"}'::jsonb, 'opening', 60),
  ('KR', 'PUR', '매입장', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('KR', 'SAL', '매출장', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('KR', 'KR-P-10', '과세 매입 10%(세금계산서 수취분, 일반매입)', '{"en":"Taxable purchase 10% (tax invoice received, general)"}'::jsonb, '국내 재화·용역의 매입, 세금계산서 수취분', 'percent', 10, 'purchase', 'domestic', date '2000-01-01', null, '부가가치세법 제38조 — 사업자가 자기의 사업을 위하여 사용하였거나 사용할 재화 또는 용역의 공급에 대한 세액은 매출세액에서 공제한다. 세금계산서를 발급받은 일반매입은 신고서 별지 제21호서식 (10)란 ''세금계산서 수취분 — 일반매입''에 적는다.', 'S', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-P-10-NC', '과세 매입 10%(공제받지 못할 매입세액)', '{"en":"Taxable purchase 10% (input tax not creditable)"}'::jsonb, '기업업무추진비 관련 매입, 비영업용 소형승용차의 구입·유지 등 매입세액이 공제되지 않는 매입', 'percent', 10, 'purchase', 'domestic', date '2000-01-01', null, '부가가치세법 제39조제1항 — 기업업무추진비 및 이와 유사한 비용의 지출에 관련된 매입세액(제5호), 개별소비세법 제1조제2항제3호에 따른 비영업용 소형승용자동차의 구입·임차·유지에 관한 매입세액(제5호의2) 등은 매출세액에서 공제하지 아니한다. 세금계산서는 발급받았으나 공제되지 않으므로 세액은 그 매입 자산·비용의 원가에 산입되고, 신고서 별지 제21호서식 (16)란 ''공제받지 못할 매입세액''에 적는다.', 'S', null, 60, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-P-EXO', '면세 매입', '{"en":"Exempt purchase"}'::jsonb, '면세 사업자로부터 계산서를 받고 매입하는 재화·용역', 'percent', 0, 'purchase', 'exempt', date '2000-01-01', null, '부가가치세법 제26조 및 제38조 — 면세 사업자는 부가가치세를 거래징수하지 않으므로 매입세액이 존재하지 않는다. 계산서(소득세법 제163조, 법인세법 제121조)로 매입하며, 신고서 별지 제21호서식 어느 란에도 적지 않는다(계산서 수취 명세는 (85)란에 별도 집계될 뿐 세액 계산에는 들어가지 않는다).', 'E', null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-P-IMP-10', '수입 재화 10%(세관 징수분)', '{"en":"Imported goods 10% (collected by customs)"}'::jsonb, '보세구역에서 반입하는 수입 재화에 대하여 세관장이 징수하는 부가가치세', 'percent', 10, 'purchase', 'import', date '2000-01-01', null, '부가가치세법 제50조 — 세관장은 수입되는 재화에 대하여 관세를 징수하는 때에 부가가치세를 징수한다. 제35조에 따라 세관장이 발급하는 수입세금계산서는 매입세액공제의 근거가 되며, 실무상 일반 세금계산서 수취분과 함께 신고서 별지 제21호서식 (10)란에 합산하여 적는다. 세액은 공급자가 아닌 세관에 납부하므로 상대 계정은 미지급관세등(2135)으로 한다.', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-S-0-EXP', '영세율 매출(재화의 수출)', '{"en":"Zero-rated sale (export of goods)"}'::jsonb, '본邦으로부터 국외로 반출하는 재화의 공급', 'percent', 0, 'sale', 'export', date '2000-01-01', null, '부가가치세법 제21조 — 재화의 수출에는 영의 세율을 적용한다. 수출은 관세법에 따라 신고필증 등으로 그 반출 사실이 증명되어야 한다. 세금계산서 발급의무가 없는 수출에 해당하므로 신고서 별지 제21호서식 (6)란 ''기타'' 영세율란에 적는다. 영세율은 매입세액 공제를 유지한다는 점에서 면세(제26조)와 다르다.', 'G', null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-S-0-SVC', '영세율 매출(국외 공급 용역·외국항행용역)', '{"en":"Zero-rated sale (services supplied abroad / international transport)"}'::jsonb, '국외에서 공급하는 용역, 외국을 항행하는 선박·항공기에 의한 용역', 'percent', 0, 'sale', 'export', date '2000-01-01', null, '부가가치세법 제22조(용역의 국외공급) 및 제23조(외국항행용역의 공급) — 국외에서 공급하는 용역과 외국항행 선박·항공기에 의한 여객·화물 운송 용역에는 영의 세율을 적용한다. 세금계산서 발급의무가 없으므로 신고서 별지 제21호서식 (6)란 ''기타'' 영세율란에 적는다.', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-S-10', '과세 매출 10%(세금계산서 발급분)', '{"en":"Taxable sale 10% (tax invoice issued)"}'::jsonb, '국내 재화·용역의 공급, 세금계산서 발급분', 'percent', 10, 'sale', 'domestic', date '2000-01-01', null, '부가가치세법 제30조 — 부가가치세의 세율은 10퍼센트로 한다. 제32조제1항에 따라 사업자는 재화 또는 용역을 공급하는 경우 세금계산서를 발급하여야 한다. 신고서 별지 제21호서식 (1)란 ''세금계산서 발급분''에 공급가액과 세액을 적는다.', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null),
  ('KR', 'KR-S-EXO', '면세 매출', '{"en":"Exempt sale"}'::jsonb, '미가공식료품, 의료보건 용역, 교육 용역 등 부가가치세법 제26조의 면세 공급', 'percent', 0, 'sale', 'exempt', date '2000-01-01', null, '부가가치세법 제26조제1항 — 다음 각 호의 재화 또는 용역의 공급에 대하여는 부가가치세를 면제한다: 1호 가공되지 아니한 식료품(농산물·축산물·수산물·임산물 포함), 5호 의료보건 용역(수의사의 용역 포함), 6호 대통령령으로 정하는 교육 용역. 면세 사업자는 세금계산서가 아닌 계산서(소득세법 제163조, 법인세법 제121조)를 발급하며, 그 매출은 세금계산서 발급 의무가 있는 과세표준에 포함되지 않고 신고서 별지 제21호서식 하단 ''면세사업 수입금액''란(28)~(83)에 별도로 적는다. 면세는 매입세액을 공제받지 못한다는 점에서 영세율과 다르다(제39조).', 'E', null, 40, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-act', null, null, null, null)
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
    ('KR-P-10', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-10', 'invoice', 'tax', 100, '1250', '10', array['10']::text[], 100, 'KR-VAT-21', 20),
    ('KR-P-10', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-10', 'credit_note', 'tax', 100, '1250', '10', array['10']::text[], -100, 'KR-VAT-21', 20),
    ('KR-P-10-NC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-10-NC', 'invoice', 'tax_on_base', 100, null, '16', array['16']::text[], 100, 'KR-VAT-21', 20),
    ('KR-P-10-NC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-10-NC', 'credit_note', 'tax_on_base', 100, null, '16', array['16']::text[], -100, 'KR-VAT-21', 20),
    ('KR-P-EXO', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-EXO', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-IMP-10', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-IMP-10', 'invoice', 'tax', 100, '1250', '10', array['10']::text[], 100, 'KR-VAT-21', 20),
    ('KR-P-IMP-10', 'invoice', 'tax', -100, '2135', null, null, 100, null, 30),
    ('KR-P-IMP-10', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('KR-P-IMP-10', 'credit_note', 'tax', 100, '1250', '10', array['10']::text[], -100, 'KR-VAT-21', 20),
    ('KR-P-IMP-10', 'credit_note', 'tax', -100, '2135', null, null, 100, null, 30),
    ('KR-S-0-EXP', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'KR-VAT-21', 10),
    ('KR-S-0-EXP', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'KR-VAT-21', 10),
    ('KR-S-0-SVC', 'invoice', 'base', 100, null, '6', array['6']::text[], 100, 'KR-VAT-21', 10),
    ('KR-S-0-SVC', 'credit_note', 'base', 100, null, '6', array['6']::text[], -100, 'KR-VAT-21', 10),
    ('KR-S-10', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'KR-VAT-21', 10),
    ('KR-S-10', 'invoice', 'tax', 100, '2150', '1', array['1']::text[], 100, 'KR-VAT-21', 20),
    ('KR-S-10', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'KR-VAT-21', 10),
    ('KR-S-10', 'credit_note', 'tax', 100, '2150', '1', array['1']::text[], -100, 'KR-VAT-21', 20),
    ('KR-S-EXO', 'invoice', 'base', 100, null, '80', array['80']::text[], 100, 'KR-VAT-21', 10),
    ('KR-S-EXO', 'credit_note', 'base', 100, null, '80', array['80']::text[], -100, 'KR-VAT-21', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'KR' and t.code = v.tax_code
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
  ('KR', 'KR-VAT-21', '일반과세자 부가가치세[예정, 확정] 신고서 (별지 제21호서식)', array['quarter']::declaration_period[], 'quarter'::declaration_period, date '2021-03-16', null, '부가가치세법 제48조(예정신고와 납부) — 법인사업자는 각 예정신고기간(제1기 1.1.~3.31., 제2기 7.1.~9.30.)이 끝난 후 25일 이내에 그 기간의 과세표준과 납부세액을 신고·납부하여야 한다. 제49조(확정신고와 납부) — 사업자는 각 과세기간이 끝난 후 25일 이내에 그 과세기간(제1기 1.1.~6.30., 제2기 7.1.~12.31.)에 대한 과세표준과 납부세액을 신고·납부하되, 이미 예정신고한 부분은 제외한다 — 즉 확정신고는 그 과세기간의 뒤쪽 3개월(4~6월, 10~12월)의 실적만을 신고한다(국세청, 부가가치세 신고·납부기한 안내). 그 결과 법인사업자는 사실상 매 3개월마다 신고하므로 이 팩은 period를 quarter로 선언한다. 이 신고서(별지 제21호서식)는 개인 일반과세자에게도 같은 서식이 쓰이나, 다수의 개인사업자는 예정신고 대신 국세청이 직전 과세기간 납부세액의 50%를 예정고지하여 징수한다(제48조제3항) — 이 예정고지·직권징수 방식은 ''신고''가 아니므로 이 팩의 period 목록에 반영하지 않았고, docs/international.md에 남긴다.', true,'day_of_month_after_period'::filing_deadline_rule, 25, null, '부가가치세법 제48조제1항 및 제49조제1항 — 예정신고·확정신고 모두 해당 기간이 끝난 후 25일 이내에 신고·납부한다. 국세청, 부가가치세 신고·납부기한 안내: 1기 예정신고 4/25, 1기 확정신고 7/25, 2기 예정신고 10/25, 2기 확정신고 익년 1/25.', 'nts-filing-deadline', null)
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
  ('KR', 'KR-VAT-21', '1', 'base', '세금계산서 발급분 — 과세표준', '{"en":"Tax invoice issued — taxable base"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 ① 신고내용, 과세표준 및 매출세액 (1)란 ''세금계산서 발급분'' — 금액란.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '1', 'tax', '세금계산서 발급분 — 세액', '{"en":"Tax invoice issued — tax amount"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 (1)란 세액란, 세율 10/100.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '6', 'base', '영세율 — 기타(세금계산서 발급의무 없는 수출 등)', '{"en":"Zero rate — other"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 과세표준 및 매출세액, 영세율 (6)란 ''기타'' — 세율 0/100이므로 세액란은 항상 0이다.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '9', 'total', '매출세액 합계(㉮)', '{"en":"Total output tax"}'::jsonb, 40, null, array['1:tax']::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 (9)란 ''합계'', 세액란의 값이 ㉮로 이후 계산에 쓰인다. 이 팩은 (2)~(8)란(매입자발행세금계산서, 신용카드·현금영수증 발행분, 기타, 예정신고 누락분, 대손세액가감)을 모델링하지 않으므로 ㉮는 (1)란의 세액만을 합산한다 — docs/international.md.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '10', 'tax', '세금계산서 수취분 — 일반매입, 매입세액', '{"en":"Tax invoice received — general purchases, tax amount"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 매입세액, 세금계산서 수취분 (10)란 ''일반매입'' 세액란. 수입세금계산서(제50조, 제35조)의 매입세액도 실무상 이 란에 합산한다.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '15', 'total', '매입세액 합계', '{"en":"Total input tax"}'::jsonb, 60, null, array['10']::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 (15)란 ''합계 (10)-(10-1)+(11)+(12)+(13)+(14)''. 이 팩은 (10)란만을 모델링하므로 합계는 (10)과 같다 — docs/international.md.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '16', 'base', '공제받지 못할 매입세액', '{"en":"Input tax not creditable"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 매입세액 (16)란 ''공제받지 못할 매입세액'', 부가가치세법 제39조.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '17', 'total', '차감계(㉯)', '{"en":"Net input tax"}'::jsonb, 80, null, array['15']::text[], array['16']::text[], null, null, false, false, null, '별지 제21호서식 (17)란 ''차감 계 (15)-(16)'', 세액란의 값이 ㉯로 이후 계산에 쓰인다.', 'vat-form21'),
  ('KR', 'KR-VAT-21', 'PAY', 'total', '납부(환급)세액(㉰)', '{"en":"Tax payable (refundable) before adjustments"}'::jsonb, 90, null, array['9']::text[], array['17']::text[], null, null, false, true, null, '별지 제21호서식 ''납부(환급)세액(매출세액 ㉮ - 매입세액 ㉯) ㉰'' — 서식 고유 번호가 없는 계산 중간값이므로 hidden으로 둔다.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '27', 'total', '차감·가감하여 납부할 세액(환급받을 세액)', '{"en":"Tax payable (refundable) after adjustment"}'::jsonb, 100, null, array['PAY']::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 (27)란 ''차감·가감하여 납부할 세액(환급받을 세액)(㉰-㉱-㉲-㉳-㉴-㉵-㉶-㉷+㉸)''. 이 팩은 경감·공제세액(18)~(25)와 가산세액(26)을 모델링하지 않으므로 (27)란은 ㉰와 같다 — docs/international.md. 음수이면 환급받을 세액이다.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '80', 'base', '면세사업 수입금액', '{"en":"Exempt business revenue"}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 ⑤ 과세표준 명세 아래 ''면세사업 수입금액'' (80)란, 업태별 금액. 부가가치세법 제26조에 따른 면세 공급가액이 여기에 들어가며, 과세표준 (1)~(9)란에는 들어가지 않는다.', 'vat-form21'),
  ('KR', 'KR-VAT-21', '83', 'total', '면세사업 수입금액 합계', '{"en":"Total exempt business revenue"}'::jsonb, 120, null, array['80']::text[], '{}'::text[], null, null, false, false, null, '별지 제21호서식 (83)란 ''합계''.', 'vat-form21')
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
  ('KR-GAAP-BS', 'KR', 'default', '재무상태표', 'balance_sheet', 'KR-GAAP', date '1970-01-01', null, '상법 제447조는 주식회사의 이사가 매 결산기에 대차대조표(재무상태표)와 손익계산서를 작성하도록 정하나, 계정과목이나 표시 항목을 지정하지 않는다. 한국채택국제회계기준(K-IFRS)을 적용하지 않는 회사는 한국회계기준원(KASB)이 제정한 일반기업회계기준에 따라 재무제표를 작성하며, 이 기준은 자산·부채를 1년 또는 정상영업주기를 기준으로 유동·비유동으로 구분하여 표시할 것을 요구한다. 이 재무상태표는 그 유동·비유동 구분 원칙과 대한민국 실무의 일반적 표시 순서를 따라 이 팩이 작성한 것으로, 일반기업회계기준의 세부 항목별 배열을 문언 그대로 검증하지는 못했다 — docs/international.md 및 packs/kr/README.md 참조.', 'commercial-act'),
  ('KR-GAAP-IS', 'KR', 'default', '손익계산서', 'income_statement', 'KR-GAAP', date '1970-01-01', null, '상법 제447조가 요구하는 손익계산서를, 일반기업회계기준이 정하는 단계별 이익 구조(매출총이익, 영업이익, 법인세비용차감전순이익, 당기순이익)에 따라 이 팩이 작성한 것이다.', 'commercial-act')
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
  ('KR-GAAP-BS', 'A', null, '자산총계', '{"en":"Total assets"}'::jsonb, 10, 1, true, array['A1', 'A2']::text[], '{}'::text[], null, '상법 제447조.', 'commercial-act'),
  ('KR-GAAP-BS', 'A1', 'A', '유동자산', '{"en":"Current assets"}'::jsonb, 20, 1, true, array['A1.1', 'A1.2', 'A1.3', 'A1.4', 'A1.5', 'A1.6', 'A1.7', 'A1.8', 'A1.9', 'A1.10', 'A1.11', 'A1.12', 'A1.13']::text[], '{}'::text[], null, '일반기업회계기준의 유동·비유동 구분 원칙(1년 또는 정상영업주기 기준).', 'kasb'),
  ('KR-GAAP-BS', 'A1.1', 'A1', '현금및현금성자산', '{"en":"Cash and cash equivalents"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, '현금, 보통예금, 정기예금(1년 이내), 외화예금.', 'kasb'),
  ('KR-GAAP-BS', 'A1.2', 'A1', '받을어음', '{"en":"Notes receivable"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, '매출채권 중 어음 형태.', 'kasb'),
  ('KR-GAAP-BS', 'A1.3', 'A1', '외상매출금', '{"en":"Trade receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, '매출채권.', 'kasb'),
  ('KR-GAAP-BS', 'A1.4', 'A1', '대손충당금(매출채권)', '{"en":"Allowance for doubtful accounts (trade receivables)"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, '매출채권에 대한 차감계정으로 표시한다.', 'kasb'),
  ('KR-GAAP-BS', 'A1.5', 'A1', '미수금', '{"en":"Other receivables"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, '매출채권 외의 채권.', 'kasb'),
  ('KR-GAAP-BS', 'A1.6', 'A1', '선급금', '{"en":"Advances paid"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, '재화·용역 대가의 선지급액.', 'kasb'),
  ('KR-GAAP-BS', 'A1.7', 'A1', '선급비용', '{"en":"Prepaid expenses"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, '기간 미경과 비용.', 'kasb'),
  ('KR-GAAP-BS', 'A1.8', 'A1', '부가세대급금', '{"en":"Input VAT"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, '부가가치세법 제38조에 따라 매입 시 거래징수당한 매입세액으로, 신고·납부 전까지 자산으로 계상한다.', 'vat-act'),
  ('KR-GAAP-BS', 'A1.9', 'A1', '미수금(부가세환급세액)', '{"en":"VAT refundable"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, '신고 결과 환급받을 부가가치세액.', 'vat-act'),
  ('KR-GAAP-BS', 'A1.10', 'A1', '미수수익', '{"en":"Accrued income"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, '발생하였으나 아직 받지 못한 수익.', 'kasb'),
  ('KR-GAAP-BS', 'A1.11', 'A1', '유가증권', '{"en":"Marketable securities"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, '단기매매 목적 등 유동자산으로 분류되는 유가증권.', 'kasb'),
  ('KR-GAAP-BS', 'A1.12', 'A1', '재고자산', '{"en":"Inventories"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, '상품, 제품, 재공품, 원재료, 미착상품, 저장품.', 'kasb'),
  ('KR-GAAP-BS', 'A1.13', 'A1', '부도어음과수표', '{"en":"Dishonored notes and checks"}'::jsonb, 145, 1, false, '{}'::text[], '{}'::text[], null, '지급거절된 어음·수표로 정상적인 매출채권과 구분하여 표시한다.', 'kasb'),
  ('KR-GAAP-BS', 'A2', 'A', '비유동자산', '{"en":"Non-current assets"}'::jsonb, 150, 1, true, array['A2.1', 'A2.2', 'A2.3']::text[], '{}'::text[], null, '일반기업회계기준의 유동·비유동 구분 원칙.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1', 'A2', '유형자산', '{"en":"Property and equipment"}'::jsonb, 160, 1, true, array['A2.1.1', 'A2.1.2', 'A2.1.3', 'A2.1.4', 'A2.1.5', 'A2.1.6', 'A2.1.7']::text[], '{}'::text[], null, '물리적 실체가 있는 자산으로, 감가상각누계액을 차감한 순액으로 표시한다.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.1', 'A2.1', '토지', '{"en":"Land"}'::jsonb, 170, 1, false, '{}'::text[], '{}'::text[], null, '감가상각 대상이 아니다.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.2', 'A2.1', '건물', '{"en":"Buildings"}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, '취득원가에서 감가상각누계액을 차감한 순액.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.3', 'A2.1', '구축물', '{"en":"Structures"}'::jsonb, 190, 1, false, '{}'::text[], '{}'::text[], null, '순액 표시.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.4', 'A2.1', '기계장치', '{"en":"Machinery and equipment"}'::jsonb, 200, 1, false, '{}'::text[], '{}'::text[], null, '순액 표시.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.5', 'A2.1', '차량운반구', '{"en":"Vehicles"}'::jsonb, 210, 1, false, '{}'::text[], '{}'::text[], null, '순액 표시.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.6', 'A2.1', '비품', '{"en":"Fixtures and fittings"}'::jsonb, 220, 1, false, '{}'::text[], '{}'::text[], null, '순액 표시.', 'kasb'),
  ('KR-GAAP-BS', 'A2.1.7', 'A2.1', '건설중인자산', '{"en":"Construction in progress"}'::jsonb, 230, 1, false, '{}'::text[], '{}'::text[], null, '완성 전까지 감가상각하지 않는다.', 'kasb'),
  ('KR-GAAP-BS', 'A2.2', 'A2', '무형자산', '{"en":"Intangible assets"}'::jsonb, 240, 1, true, array['A2.2.1', 'A2.2.2', 'A2.2.3', 'A2.2.4', 'A2.2.5']::text[], '{}'::text[], null, '물리적 실체가 없는 식별가능한 비화폐성자산.', 'kasb'),
  ('KR-GAAP-BS', 'A2.2.1', 'A2.2', '영업권', '{"en":"Goodwill"}'::jsonb, 250, 1, false, '{}'::text[], '{}'::text[], null, '사업결합 등에서 발생한 영업권.', 'kasb'),
  ('KR-GAAP-BS', 'A2.2.2', 'A2.2', '산업재산권', '{"en":"Industrial property rights"}'::jsonb, 260, 1, false, '{}'::text[], '{}'::text[], null, '특허권·상표권 등.', 'kasb'),
  ('KR-GAAP-BS', 'A2.2.3', 'A2.2', '개발비', '{"en":"Development costs"}'::jsonb, 270, 1, false, '{}'::text[], '{}'::text[], null, '자산 인식요건을 충족한 개발단계 지출.', 'kasb'),
  ('KR-GAAP-BS', 'A2.2.4', 'A2.2', '소프트웨어', '{"en":"Software"}'::jsonb, 280, 1, false, '{}'::text[], '{}'::text[], null, '구입한 소프트웨어.', 'kasb'),
  ('KR-GAAP-BS', 'A2.2.5', 'A2.2', '회원권', '{"en":"Membership rights"}'::jsonb, 285, 1, false, '{}'::text[], '{}'::text[], null, '골프회원권 등 이용 권리.', 'kasb'),
  ('KR-GAAP-BS', 'A2.3', 'A2', '기타비유동자산', '{"en":"Other non-current assets"}'::jsonb, 290, 1, true, array['A2.3.1', 'A2.3.2', 'A2.3.3', 'A2.3.4']::text[], '{}'::text[], null, '투자자산·기타 비유동자산.', 'kasb'),
  ('KR-GAAP-BS', 'A2.3.1', 'A2.3', '임차보증금', '{"en":"Lease deposits"}'::jsonb, 300, 1, false, '{}'::text[], '{}'::text[], null, '임대차계약상의 보증금.', 'kasb'),
  ('KR-GAAP-BS', 'A2.3.2', 'A2.3', '장기대여금', '{"en":"Long-term loans receivable"}'::jsonb, 310, 1, false, '{}'::text[], '{}'::text[], null, '회수기한이 1년 이후인 대여금.', 'kasb'),
  ('KR-GAAP-BS', 'A2.3.3', 'A2.3', '이연법인세자산', '{"en":"Deferred tax assets"}'::jsonb, 320, 1, false, '{}'::text[], '{}'::text[], null, '일시적차이 등에서 발생.', 'kasb'),
  ('KR-GAAP-BS', 'A2.3.4', 'A2.3', '투자부동산', '{"en":"Investment property"}'::jsonb, 330, 1, false, '{}'::text[], '{}'::text[], null, '임대수익이나 시세차익을 얻기 위하여 보유하는 부동산.', 'kasb'),
  ('KR-GAAP-BS', 'L', null, '부채총계', '{"en":"Total liabilities"}'::jsonb, 340, 1, true, array['L1', 'L2']::text[], '{}'::text[], null, '상법 제447조.', 'commercial-act'),
  ('KR-GAAP-BS', 'L1', 'L', '유동부채', '{"en":"Current liabilities"}'::jsonb, 350, 1, true, array['L1.1', 'L1.2', 'L1.3', 'L1.4', 'L1.5', 'L1.6', 'L1.7', 'L1.8', 'L1.9', 'L1.10', 'L1.11', 'L1.12', 'L1.13', 'L1.14']::text[], '{}'::text[], null, '일반기업회계기준의 유동·비유동 구분 원칙.', 'kasb'),
  ('KR-GAAP-BS', 'L1.1', 'L1', '지급어음', '{"en":"Notes payable"}'::jsonb, 360, -1, false, '{}'::text[], '{}'::text[], null, '매입채무 중 어음 형태.', 'kasb'),
  ('KR-GAAP-BS', 'L1.2', 'L1', '외상매입금', '{"en":"Trade payables"}'::jsonb, 370, -1, false, '{}'::text[], '{}'::text[], null, '매입채무.', 'kasb'),
  ('KR-GAAP-BS', 'L1.3', 'L1', '미지급금', '{"en":"Other payables"}'::jsonb, 380, -1, false, '{}'::text[], '{}'::text[], null, '매입채무 외의 채무.', 'kasb'),
  ('KR-GAAP-BS', 'L1.4', 'L1', '미지급비용', '{"en":"Accrued expenses"}'::jsonb, 390, -1, false, '{}'::text[], '{}'::text[], null, '발생하였으나 아직 지급하지 않은 비용.', 'kasb'),
  ('KR-GAAP-BS', 'L1.5', 'L1', '미지급관세등', '{"en":"Customs duties payable"}'::jsonb, 400, -1, false, '{}'::text[], '{}'::text[], null, '수입 시 세관에 납부할 관세 및 부가가치세.', 'vat-act'),
  ('KR-GAAP-BS', 'L1.6', 'L1', '예수금', '{"en":"Withholdings payable"}'::jsonb, 410, -1, false, '{}'::text[], '{}'::text[], null, '원천징수세액 등 일시 예수액.', 'kasb'),
  ('KR-GAAP-BS', 'L1.7', 'L1', '부가세예수금', '{"en":"Output VAT"}'::jsonb, 420, -1, false, '{}'::text[], '{}'::text[], null, '부가가치세법 제31조에 따라 매출 시 거래징수한 세액.', 'vat-act'),
  ('KR-GAAP-BS', 'L1.8', 'L1', '미지급세금', '{"en":"VAT payable"}'::jsonb, 430, -1, false, '{}'::text[], '{}'::text[], null, '신고 결과 납부할 부가가치세액.', 'vat-act'),
  ('KR-GAAP-BS', 'L1.9', 'L1', '미지급법인세', '{"en":"Corporate income tax payable"}'::jsonb, 440, -1, false, '{}'::text[], '{}'::text[], null, '법인세법상 납부할 법인세.', 'kasb'),
  ('KR-GAAP-BS', 'L1.10', 'L1', '선수금', '{"en":"Advances received"}'::jsonb, 450, -1, false, '{}'::text[], '{}'::text[], null, '재화·용역 대가의 선수액.', 'kasb'),
  ('KR-GAAP-BS', 'L1.11', 'L1', '선수수익', '{"en":"Unearned revenue"}'::jsonb, 460, -1, false, '{}'::text[], '{}'::text[], null, '기간 미경과 수익.', 'kasb'),
  ('KR-GAAP-BS', 'L1.12', 'L1', '단기차입금', '{"en":"Short-term borrowings"}'::jsonb, 470, -1, false, '{}'::text[], '{}'::text[], null, '상환기한 1년 이내 차입금.', 'kasb'),
  ('KR-GAAP-BS', 'L1.13', 'L1', '가수금', '{"en":"Suspense receipts"}'::jsonb, 480, -1, false, '{}'::text[], '{}'::text[], null, '내용이 확정되지 않은 일시적 수입액.', 'kasb'),
  ('KR-GAAP-BS', 'L1.14', 'L1', '미지급배당금', '{"en":"Dividends payable"}'::jsonb, 485, -1, false, '{}'::text[], '{}'::text[], null, '상법 제464조에 따라 결의되었으나 아직 지급되지 않은 배당금.', 'commercial-act'),
  ('KR-GAAP-BS', 'L2', 'L', '비유동부채', '{"en":"Non-current liabilities"}'::jsonb, 490, 1, true, array['L2.1', 'L2.2', 'L2.3', 'L2.4', 'L2.5']::text[], '{}'::text[], null, '일반기업회계기준의 유동·비유동 구분 원칙.', 'kasb'),
  ('KR-GAAP-BS', 'L2.1', 'L2', '사채', '{"en":"Bonds payable"}'::jsonb, 500, -1, false, '{}'::text[], '{}'::text[], null, '상법 제469조에 따라 발행한 사채.', 'commercial-act'),
  ('KR-GAAP-BS', 'L2.2', 'L2', '장기차입금', '{"en":"Long-term borrowings"}'::jsonb, 510, -1, false, '{}'::text[], '{}'::text[], null, '상환기한 1년 이후 차입금.', 'kasb'),
  ('KR-GAAP-BS', 'L2.3', 'L2', '퇴직급여충당부채', '{"en":"Provision for severance benefits"}'::jsonb, 520, -1, false, '{}'::text[], '{}'::text[], null, '퇴직급여에 대한 충당부채.', 'kasb'),
  ('KR-GAAP-BS', 'L2.4', 'L2', '이연법인세부채', '{"en":"Deferred tax liabilities"}'::jsonb, 530, -1, false, '{}'::text[], '{}'::text[], null, '일시적차이 등에서 발생.', 'kasb'),
  ('KR-GAAP-BS', 'L2.5', 'L2', '장기미지급금', '{"en":"Long-term other payables"}'::jsonb, 535, -1, false, '{}'::text[], '{}'::text[], null, '상환기한 1년 이후의 미지급금.', 'kasb'),
  ('KR-GAAP-BS', 'E', null, '자본총계', '{"en":"Total equity"}'::jsonb, 540, 1, true, array['E1', 'E2', 'E3', 'E4']::text[], '{}'::text[], null, '상법 제447조. 상법 제451조의 자본금, 이익준비금(제458조), 임의적립금 및 이월이익잉여금으로 구성된다.', 'commercial-act'),
  ('KR-GAAP-BS', 'E1', 'E', '자본금', '{"en":"Share capital"}'::jsonb, 550, -1, false, '{}'::text[], '{}'::text[], null, '상법 제451조 — 발행주식의 액면총액.', 'commercial-act'),
  ('KR-GAAP-BS', 'E2', 'E', '자본잉여금', '{"en":"Capital surplus"}'::jsonb, 560, -1, false, '{}'::text[], '{}'::text[], null, '주식발행초과금 등.', 'kasb'),
  ('KR-GAAP-BS', 'E3', 'E', '이익잉여금', '{"en":"Retained earnings"}'::jsonb, 570, 1, true, array['E3.1', 'E3.2', 'E3.3']::text[], '{}'::text[], null, '상법 제458조(이익준비금) 및 정관·주주총회 결의에 따른 임의적립금, 미처분 이익.', 'commercial-act'),
  ('KR-GAAP-BS', 'E3.1', 'E3', '이익준비금', '{"en":"Legal reserve"}'::jsonb, 580, -1, false, '{}'::text[], '{}'::text[], null, '상법 제458조 — 자본금의 2분의 1에 달할 때까지 매 결산기 이익배당액의 10분의 1 이상을 적립한다.', 'commercial-act'),
  ('KR-GAAP-BS', 'E3.2', 'E3', '임의적립금', '{"en":"Voluntary reserve"}'::jsonb, 590, -1, false, '{}'::text[], '{}'::text[], null, '정관 또는 주주총회 결의에 따른 적립금.', 'kasb'),
  ('KR-GAAP-BS', 'E3.3', 'E3', '이월이익잉여금', '{"en":"Retained earnings carried forward"}'::jsonb, 600, -1, false, '{}'::text[], '{}'::text[], null, '처분되지 않고 다음 기로 이월되는 이익잉여금. 당기순이익이 결산 시 이 계정으로 대체된다.', 'kasb'),
  ('KR-GAAP-BS', 'E4', 'E', '자기주식', '{"en":"Treasury shares"}'::jsonb, 610, -1, false, '{}'::text[], '{}'::text[], null, '자본에서 차감하는 형식으로 표시한다(상법 제341조).', 'commercial-act'),
  ('KR-GAAP-BS', 'LE', null, '부채와자본총계', '{"en":"Total liabilities and equity"}'::jsonb, 620, 1, true, array['L', 'E']::text[], '{}'::text[], null, '결산이 마쳐진 사업연도의 재무상태표에서 자산총계와 일치한다.', 'commercial-act'),
  ('KR-GAAP-IS', '1', null, '매출액', '{"en":"Revenue"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, '상품매출, 제품매출, 용역매출.', 'kasb'),
  ('KR-GAAP-IS', '2', null, '매출원가', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, '기초상품재고액 + 당기상품매입액 - 기말상품재고액.', 'kasb'),
  ('KR-GAAP-IS', '3', null, '매출총이익', '{"en":"Gross profit"}'::jsonb, 30, 1, true, array['1']::text[], array['2']::text[], null, '매출액에서 매출원가를 차감한 금액. 음수이면 매출총손실이다.', 'kasb'),
  ('KR-GAAP-IS', '4', null, '판매비와관리비', '{"en":"Selling and administrative expenses"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, '급여, 복리후생비, 감가상각비 등 판매 및 관리 활동에서 발생하는 비용.', 'kasb'),
  ('KR-GAAP-IS', '5', null, '영업이익', '{"en":"Operating profit"}'::jsonb, 50, 1, true, array['3']::text[], array['4']::text[], null, '매출총이익에서 판매비와관리비를 차감한 금액. 음수이면 영업손실이다.', 'kasb'),
  ('KR-GAAP-IS', '6', null, '영업외수익', '{"en":"Non-operating income"}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, '이자수익, 배당금수익, 외환차익, 유형자산처분이익, 잡이익.', 'kasb'),
  ('KR-GAAP-IS', '7', null, '영업외비용', '{"en":"Non-operating expenses"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, '이자비용, 외환차손, 기부금, 유형자산처분손실, 잡손실, 단수차이.', 'kasb'),
  ('KR-GAAP-IS', '8', null, '법인세비용차감전순이익', '{"en":"Profit before income tax"}'::jsonb, 80, 1, true, array['5', '6']::text[], array['7']::text[], null, '영업이익에 영업외수익을 더하고 영업외비용을 뺀 금액. 음수이면 법인세비용차감전순손실이다.', 'kasb'),
  ('KR-GAAP-IS', '9', null, '법인세비용', '{"en":"Income tax expense"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, '법인세법에 따라 부담할 법인세 및 지방소득세(법인세분).', 'kasb'),
  ('KR-GAAP-IS', '10', null, '당기순이익', '{"en":"Net profit"}'::jsonb, 100, 1, true, array['8']::text[], array['9']::text[], null, '법인세비용차감전순이익에서 법인세비용을 차감한 금액. 음수이면 당기순손실이다.', 'kasb')
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
    ('KR-GAAP-BS', 'A1.1', 10, 'code_range', '1100', '1130', null, 'any'),
    ('KR-GAAP-BS', 'A1.2', 10, 'account_code', '1200', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.3', 10, 'account_code', '1210', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.4', 10, 'account_code', '1219', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.5', 10, 'account_code', '1215', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.6', 10, 'account_code', '1230', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.7', 10, 'account_code', '1240', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.8', 10, 'account_code', '1250', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.9', 10, 'account_code', '1255', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.10', 10, 'account_code', '1260', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.11', 10, 'account_code', '1270', null, null, 'any'),
    ('KR-GAAP-BS', 'A1.12', 10, 'code_range', '1310', '1350', null, 'any'),
    ('KR-GAAP-BS', 'A1.13', 10, 'account_code', '1225', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.1.1', 10, 'account_code', '1500', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.1.2', 10, 'code_range', '1510', '1511', null, 'any'),
    ('KR-GAAP-BS', 'A2.1.3', 10, 'code_range', '1520', '1521', null, 'any'),
    ('KR-GAAP-BS', 'A2.1.4', 10, 'code_range', '1530', '1531', null, 'any'),
    ('KR-GAAP-BS', 'A2.1.5', 10, 'code_range', '1540', '1541', null, 'any'),
    ('KR-GAAP-BS', 'A2.1.6', 10, 'code_range', '1550', '1551', null, 'any'),
    ('KR-GAAP-BS', 'A2.1.7', 10, 'account_code', '1560', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.2.1', 10, 'account_code', '1610', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.2.2', 10, 'account_code', '1620', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.2.3', 10, 'account_code', '1630', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.2.4', 10, 'account_code', '1640', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.2.5', 10, 'account_code', '1650', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.3.1', 10, 'account_code', '1710', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.3.2', 10, 'account_code', '1720', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.3.3', 10, 'account_code', '1730', null, null, 'any'),
    ('KR-GAAP-BS', 'A2.3.4', 10, 'account_code', '1740', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.1', 10, 'account_code', '2100', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.2', 10, 'account_code', '2110', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.3', 10, 'account_code', '2120', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.4', 10, 'account_code', '2130', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.5', 10, 'account_code', '2135', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.6', 10, 'account_code', '2140', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.7', 10, 'account_code', '2150', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.8', 10, 'account_code', '2155', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.9', 10, 'account_code', '2160', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.10', 10, 'account_code', '2170', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.11', 10, 'account_code', '2180', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.12', 10, 'account_code', '2190', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.13', 10, 'account_code', '2195', null, null, 'any'),
    ('KR-GAAP-BS', 'L1.14', 10, 'account_code', '2145', null, null, 'any'),
    ('KR-GAAP-BS', 'L2.1', 10, 'account_code', '2200', null, null, 'any'),
    ('KR-GAAP-BS', 'L2.2', 10, 'account_code', '2210', null, null, 'any'),
    ('KR-GAAP-BS', 'L2.3', 10, 'account_code', '2220', null, null, 'any'),
    ('KR-GAAP-BS', 'L2.4', 10, 'account_code', '2230', null, null, 'any'),
    ('KR-GAAP-BS', 'L2.5', 10, 'account_code', '2225', null, null, 'any'),
    ('KR-GAAP-BS', 'E1', 10, 'account_code', '3100', null, null, 'any'),
    ('KR-GAAP-BS', 'E2', 10, 'account_code', '3200', null, null, 'any'),
    ('KR-GAAP-BS', 'E3.1', 10, 'account_code', '3300', null, null, 'any'),
    ('KR-GAAP-BS', 'E3.2', 10, 'account_code', '3310', null, null, 'any'),
    ('KR-GAAP-BS', 'E3.3', 10, 'account_code', '3330', null, null, 'any'),
    ('KR-GAAP-BS', 'E4', 10, 'account_code', '3400', null, null, 'any'),
    ('KR-GAAP-IS', '1', 10, 'code_range', '4100', '4120', null, 'any'),
    ('KR-GAAP-IS', '2', 10, 'code_range', '5100', '5130', null, 'any'),
    ('KR-GAAP-IS', '4', 10, 'code_range', '6100', '6260', null, 'any'),
    ('KR-GAAP-IS', '6', 10, 'code_range', '4200', '4240', null, 'any'),
    ('KR-GAAP-IS', '7', 10, 'code_range', '7100', '7145', null, 'any'),
    ('KR-GAAP-IS', '9', 10, 'account_code', '8100', null, null, 'any')
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
  ('KR', '대한민국', '{"en":"South Korea"}'::jsonb, array['ko', 'en']::text[], 'KRW', '1210', '2110', '2195', '7145', '3330', '4100', '5120', '1110', '1100', 'SAL', 'PUR', 'GEN', 'ko', 'retained_earnings', null, null, null, 'OPN', 'down', default, '4220', '7110', '4230', '7130', null, null, '2155', '1255', null, 'quarter'::declaration_period)
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
  numbering_legal_reference     = '부가가치세법 제32조 및 같은 법 시행령 제53조 — 세금계산서는 작성 연월일 등 필요적 기재사항을 갖추어야 하고, 국세청이 부여하는 승인번호(전자세금계산서의 경우)를 가지지만, 법령은 사업자 스스로 매기는 일련번호에 대해 연간 결번 없는 하나의 체계를 강제하지 않는다. 그래서 numbering은 free이며, number_format은 그러한 자유 안에서 이 팩이 제안하는 관례일 뿐이다.',
  numbering_source_key          = 'vat-act',
  payment_terms_legal_reference = '상법에는 사업자 간 매매대금의 지급기한을 일반적으로 정하는 규정이 없다(당사자의 약정에 따른다). 하도급거래 공정화에 관한 법률 제13조는 원사업자가 수급사업자에게 목적물 수령일로부터 60일 이내에 대금을 지급하도록 정하지만, 이는 하도급거래라는 특정 관계에만 적용되므로 이 팩은 이를 일반 규칙으로 반영하지 않는다. 그래서 legal_payment_days와 late_payment_reference는 비워 둔다.',
  payment_terms_source_key      = 'commercial-act',
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = '부가가치세법 제15조(재화의 공급시기) — 재화가 이동하는 경우에는 재화가 인도되는 때, 이동이 필요하지 않은 경우에는 재화가 이용 가능하게 되는 때를 원칙으로 한다. 같은 법 제16조(용역의 공급시기)는 역무의 제공이 완료되는 때를 원칙으로 한다. 이 팩은 재화에 대한 제15조의 원칙을 delivery_date로 선언하며, 용역의 완료 시점도 같은 개념으로 다룬다. 세금계산서를 공급시기 전에 먼저 발급하는 경우 등 시행령이 정하는 특례는 이 팩이 검증하지 못했고, docs/international.md에 남긴다.',
  tax_point_source_key          = 'vat-act',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = '부가가치세법 제32조제2항 — 법인사업자와 대통령령으로 정하는 개인사업자(같은 법 시행령 제68조: 직전 연도 재화·용역 공급가액 합계액이 8천만원 이상인 개인사업자, 2024. 7. 1.부터 적용)는 세금계산서를 전자적 방법으로 발급하는 전자세금계산서(전자세금계산서)를 발급하여야 하고, 같은 조제3항에 따라 발급일의 다음 날까지 그 발급명세를 국세청장에게 전송하여야 한다(국세청, 전자세금계산서 발급 및 전송 기한). 법인사업자는 2011년 1월부터 의무 대상이다(국세청 안내). 전송이 지연되거나 이루어지지 않으면 공급가액의 0.3%(지연전송) 또는 0.5%(미전송)의 가산세가 부과된다(부가가치세법 시행규칙 별지 제21호서식 작성방법, (65)·(66)란). 이 제도는 국세청 홈택스로의 발급명세 전송을 요구하는 대한민국 고유의 전자세금계산서 체계이며, EN 16931/UBL에 기반한 프로파일이 아니고, OpenPeppol의 Peppol Authority 목록에도 대한민국은 올라 있지 않다(peppol.org, 회원 목록, 2026-09-22 확인) — 일본의 JP PINT나 싱가포르의 PINT SG처럼 Peppol 위에 구축된 프로파일이 존재하지 않는다. packages/formats/의 어떤 브릭도 전자세금계산서의 XML(국세청 표준 전자문서 표준)을 작성하거나 홈택스로 전송하지 않으므로, Ekwo가 발행한 문서는 전자세금계산서가 아니다. profile, mandatory_from, party_scheme, vat_scheme은 그래서 비워 둔다: profile은 packages/formats/의 한 조각이 실제로 작성하는 EN 16931 계열 프로파일을 가리키는 자리이고, 전자세금계산서는 그런 프로파일이 아니다. 사업자등록번호는 ISO 6523 식별자 목록에 없다. 자세한 내용은 docs/international.md의 ''From South Korea'' 절에 남긴다.',
  einvoice_source_key           = 'nts-einvoice-obligors',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = array['csv']::text[],
  fiscal_year_default           = 'calendar'
 where country = 'KR';
