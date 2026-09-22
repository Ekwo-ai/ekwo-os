-- Ekwo OS — Việt Nam: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/vn at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build vn`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Luật Thuế giá trị gia tăng số 48/2024/QH15, thông qua ngày 26/11/2024 (Quốc hội khóa XV, kỳ họp thứ 8) (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ)
--     https://datafiles.chinhphu.vn/cpp/files/vbpq/2025/01/luat48.pdf
--   Luật số 149/2025/QH15 sửa đổi, bổ sung một số điều của Luật Thuế giá trị gia tăng, thông qua ngày 11/12/2025, hiệu lực 01/01/2026 (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ)
--     https://datafiles.chinhphu.vn/cpp/files/vbpq/2026/01/luat149.signed.pdf
--   Luật số 09/2026/QH16 sửa đổi, bổ sung một số điều của Luật Thuế thu nhập cá nhân, Luật Thuế giá trị gia tăng, Luật Thuế thu nhập doanh nghiệp và Luật Thuế tiêu thụ đặc biệt, thông qua ngày 24/04/2026 (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ)
--     https://datafiles.chinhphu.vn/cpp/files/vbpq/2026/5/09-qh.signed.pdf
--   Nghị quyết số 204/2025/QH15 của Quốc hội về giảm thuế giá trị gia tăng, thông qua ngày 17/06/2025, áp dụng từ 01/07/2025 đến hết 31/12/2026 (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ)
--     https://xaydungchinhsach.chinhphu.vn/toan-van-nghi-quyet-so-204-2025-qh15-ve-giam-thue-gia-tri-gia-tang-119250628082120511.htm
--   Nghị định số 174/2025/NĐ-CP quy định chính sách giảm thuế giá trị gia tăng theo Nghị quyết số 204/2025/QH15, ký ngày 30/06/2025 (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ)
--     https://datafiles.chinhphu.vn/cpp/files/vbpq/2025/7/174nd.signed.pdf
--   Nghị định số 70/2025/NĐ-CP sửa đổi, bổ sung Nghị định số 123/2020/NĐ-CP quy định về hóa đơn, chứng từ, ký ngày 20/03/2025, hiệu lực 01/06/2025 (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ)
--     https://datafiles.chinhphu.vn/cpp/files/vbpq/2025/3/70-nd-cp.signed.pdf
--   Nghị định số 123/2020/NĐ-CP quy định về hóa đơn, chứng từ, ký ngày 19/10/2020, hiệu lực 01/07/2022 (bản gốc, trước khi được Nghị định 70/2025/NĐ-CP sửa đổi) (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam (văn bản hợp nhất tham khảo))
--     https://hethongphapluat.com/nghi-dinh-123-2020-nd-cp-quy-dinh-ve-hoa-don-chung-tu
--   Luật Quản lý thuế số 38/2019/QH14, Điều 44 (thời hạn nộp hồ sơ khai thuế) (Quốc hội nước Cộng hòa xã hội chủ nghĩa Việt Nam (văn bản hợp nhất tham khảo))
--     https://hethongphapluat.com/luat-quan-ly-thue-2019/dieu-44
--   Nghị định số 126/2020/NĐ-CP quy định chi tiết một số điều của Luật Quản lý thuế, Điều 9 (tiêu chí khai thuế theo quý) (Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam)
--     https://hethongphapluat.com/nghi-dinh-126-2020-nd-cp-huong-dan-luat-quan-ly-thue
--   Thông tư số 99/2025/TT-BTC hướng dẫn Chế độ kế toán doanh nghiệp, ký ngày 27/10/2025, hiệu lực 01/01/2026, thay thế Thông tư 200/2014/TT-BTC (Bộ Tài chính — Công báo điện tử Chính phủ)
--     https://congbao.chinhphu.vn/van-ban/thong-tu-so-99-2025-tt-btc-46529.htm
--   Mẫu số 01/GTGT — Tờ khai thuế giá trị gia tăng (phương pháp khấu trừ), tại Thông tư 80/2021/TT-BTC (Phụ lục II) và, từ 01/07/2026, Thông tư 89/2026/TT-BTC (Phụ lục I, ký 30/06/2026) (Bộ Tài chính)
--     https://thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Thong-tu-89-2026-TT-BTC-quy-dinh-chi-tiet-thi-hanh-mot-so-dieu-cua-Luat-Quan-ly-thue.aspx
--   Cổng thông tin điện tử ngành Thuế (eTax) — nơi nộp Tờ khai thuế GTGT (Tổng cục Thuế — Bộ Tài chính)
--     https://thuedientu.gdt.gov.vn/
--   Hệ thống hóa đơn điện tử (Tổng cục Thuế — Bộ Tài chính)
--     https://hoadondientu.gdt.gov.vn/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('VN', 'Việt Nam', '0.1.0', date '2026-09-22', '20260921145425', 'community', null, null, '31a3e43ae56473a718f396b2fbb08c776d3ecd3874155ec4bcb586f457128e1a', '[{"key":"vat-law-48","title":"Luật Thuế giá trị gia tăng số 48/2024/QH15, thông qua ngày 26/11/2024 (Quốc hội khóa XV, kỳ họp thứ 8)","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ","url":"https://datafiles.chinhphu.vn/cpp/files/vbpq/2025/01/luat48.pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-law-149","title":"Luật số 149/2025/QH15 sửa đổi, bổ sung một số điều của Luật Thuế giá trị gia tăng, thông qua ngày 11/12/2025, hiệu lực 01/01/2026","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ","url":"https://datafiles.chinhphu.vn/cpp/files/vbpq/2026/01/luat149.signed.pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-law-09-2026","title":"Luật số 09/2026/QH16 sửa đổi, bổ sung một số điều của Luật Thuế thu nhập cá nhân, Luật Thuế giá trị gia tăng, Luật Thuế thu nhập doanh nghiệp và Luật Thuế tiêu thụ đặc biệt, thông qua ngày 24/04/2026","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ","url":"https://datafiles.chinhphu.vn/cpp/files/vbpq/2026/5/09-qh.signed.pdf","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-cut-nq204","title":"Nghị quyết số 204/2025/QH15 của Quốc hội về giảm thuế giá trị gia tăng, thông qua ngày 17/06/2025, áp dụng từ 01/07/2025 đến hết 31/12/2026","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ","url":"https://xaydungchinhsach.chinhphu.vn/toan-van-nghi-quyet-so-204-2025-qh15-ve-giam-thue-gia-tri-gia-tang-119250628082120511.htm","consulted_on":"2026-09-22","kind":"law"},{"key":"vat-cut-nd174","title":"Nghị định số 174/2025/NĐ-CP quy định chính sách giảm thuế giá trị gia tăng theo Nghị quyết số 204/2025/QH15, ký ngày 30/06/2025","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ","url":"https://datafiles.chinhphu.vn/cpp/files/vbpq/2025/7/174nd.signed.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"einvoice-nd70","title":"Nghị định số 70/2025/NĐ-CP sửa đổi, bổ sung Nghị định số 123/2020/NĐ-CP quy định về hóa đơn, chứng từ, ký ngày 20/03/2025, hiệu lực 01/06/2025","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam — Cổng thông tin điện tử Chính phủ","url":"https://datafiles.chinhphu.vn/cpp/files/vbpq/2025/3/70-nd-cp.signed.pdf","consulted_on":"2026-09-22","kind":"regulation"},{"key":"einvoice-nd123","title":"Nghị định số 123/2020/NĐ-CP quy định về hóa đơn, chứng từ, ký ngày 19/10/2020, hiệu lực 01/07/2022 (bản gốc, trước khi được Nghị định 70/2025/NĐ-CP sửa đổi)","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam (văn bản hợp nhất tham khảo)","url":"https://hethongphapluat.com/nghi-dinh-123-2020-nd-cp-quy-dinh-ve-hoa-don-chung-tu","consulted_on":"2026-09-22","kind":"regulation"},{"key":"tax-admin-38","title":"Luật Quản lý thuế số 38/2019/QH14, Điều 44 (thời hạn nộp hồ sơ khai thuế)","publisher":"Quốc hội nước Cộng hòa xã hội chủ nghĩa Việt Nam (văn bản hợp nhất tham khảo)","url":"https://hethongphapluat.com/luat-quan-ly-thue-2019/dieu-44","consulted_on":"2026-09-22","kind":"law"},{"key":"tax-admin-nd126","title":"Nghị định số 126/2020/NĐ-CP quy định chi tiết một số điều của Luật Quản lý thuế, Điều 9 (tiêu chí khai thuế theo quý)","publisher":"Chính phủ nước Cộng hòa xã hội chủ nghĩa Việt Nam","url":"https://hethongphapluat.com/nghi-dinh-126-2020-nd-cp-huong-dan-luat-quan-ly-thue","consulted_on":"2026-09-22","kind":"regulation"},{"key":"vas-tt99","title":"Thông tư số 99/2025/TT-BTC hướng dẫn Chế độ kế toán doanh nghiệp, ký ngày 27/10/2025, hiệu lực 01/01/2026, thay thế Thông tư 200/2014/TT-BTC","publisher":"Bộ Tài chính — Công báo điện tử Chính phủ","url":"https://congbao.chinhphu.vn/van-ban/thong-tu-so-99-2025-tt-btc-46529.htm","consulted_on":"2026-09-22","kind":"regulation"},{"key":"vat-return-form","title":"Mẫu số 01/GTGT — Tờ khai thuế giá trị gia tăng (phương pháp khấu trừ), tại Thông tư 80/2021/TT-BTC (Phụ lục II) và, từ 01/07/2026, Thông tư 89/2026/TT-BTC (Phụ lục I, ký 30/06/2026)","publisher":"Bộ Tài chính","url":"https://thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Thong-tu-89-2026-TT-BTC-quy-dinh-chi-tiet-thi-hanh-mot-so-dieu-cua-Luat-Quan-ly-thue.aspx","consulted_on":"2026-09-22","kind":"form"},{"key":"etax-portal","title":"Cổng thông tin điện tử ngành Thuế (eTax) — nơi nộp Tờ khai thuế GTGT","publisher":"Tổng cục Thuế — Bộ Tài chính","url":"https://thuedientu.gdt.gov.vn/","consulted_on":"2026-09-22","kind":"portal"},{"key":"einvoice-portal","title":"Hệ thống hóa đơn điện tử","publisher":"Tổng cục Thuế — Bộ Tài chính","url":"https://hoadondientu.gdt.gov.vn/","consulted_on":"2026-09-22","kind":"portal"}]'::jsonb)
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
  ('VN', 'default', 'Hệ thống tài khoản kế toán doanh nghiệp', '{}'::jsonb, true, 'companies', array['VN-BCTC-BCTHTC', 'VN-BCTC-KQKD']::text[], null, 'Thông tư số 99/2025/TT-BTC hướng dẫn Chế độ kế toán doanh nghiệp (Phụ lục II — Hệ thống tài khoản kế toán), hiệu lực 01/01/2026, thay thế Thông tư 200/2014/TT-BTC. Việt Nam quy định một hệ thống tài khoản thống nhất bắt buộc cho mọi doanh nghiệp (khác với PCMN của Bỉ hay PCG của Pháp, đây không phải một khung tối thiểu mà là danh mục tài khoản cấp 1 và cấp 2 áp dụng chung). Mã tài khoản ba chữ số theo Thông tư 200/2014/TT-BTC được giữ nguyên phần lớn trong Thông tư 99/2025/TT-BTC (đã xác nhận qua văn bản chính thức: các loại tài khoản Tài sản, Nợ phải trả, Vốn chủ sở hữu, Doanh thu, Chi phí sản xuất kinh doanh, Thu nhập khác, Chi phí khác vẫn dùng cùng khoảng mã — 1xx-2xx, 3xx, 4xx, 5xx, 6xx, 7xx, 8xx — nhưng nhãn « Loại 1 »/« Loại 2 » của TT200/2014 không còn, hai loại tài sản ngắn/dài hạn cũ được gộp vào một nhóm Tài sản); danh sách chi tiết từng tài khoản cấp 2 của Thông tư 99/2025/TT-BTC chưa được đối chiếu từng dòng trong lần soạn gói này — xem README.', 'vas-tt99')
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
  ('VN', 'default', '111', 'Tiền mặt', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('VN', 'default', '1111', 'Tiền Việt Nam', '{}'::jsonb, 'asset_cash', false, '111', 11),
  ('VN', 'default', '1112', 'Ngoại tệ', '{}'::jsonb, 'asset_cash', false, '111', 12),
  ('VN', 'default', '112', 'Tiền gửi ngân hàng', '{}'::jsonb, 'asset_cash', false, null, 20),
  ('VN', 'default', '1121', 'Tiền Việt Nam', '{}'::jsonb, 'asset_cash', false, '112', 21),
  ('VN', 'default', '1122', 'Ngoại tệ', '{}'::jsonb, 'asset_cash', false, '112', 22),
  ('VN', 'default', '113', 'Tiền đang chuyển', '{}'::jsonb, 'asset_cash', false, null, 30),
  ('VN', 'default', '121', 'Chứng khoán kinh doanh', '{}'::jsonb, 'asset_current', false, null, 40),
  ('VN', 'default', '128', 'Đầu tư nắm giữ đến ngày đáo hạn', '{}'::jsonb, 'asset_current', false, null, 50),
  ('VN', 'default', '131', 'Phải thu của khách hàng', '{}'::jsonb, 'asset_receivable', true, null, 60),
  ('VN', 'default', '133', 'Thuế giá trị gia tăng được khấu trừ', '{}'::jsonb, 'asset_current', true, null, 70),
  ('VN', 'default', '1331', 'Thuế GTGT được khấu trừ của hàng hóa, dịch vụ', '{}'::jsonb, 'asset_current', false, '133', 71),
  ('VN', 'default', '1332', 'Thuế GTGT được khấu trừ của tài sản cố định', '{}'::jsonb, 'asset_current', false, '133', 72),
  ('VN', 'default', '136', 'Phải thu nội bộ', '{}'::jsonb, 'asset_current', false, null, 80),
  ('VN', 'default', '138', 'Phải thu khác', '{}'::jsonb, 'asset_current', false, null, 90),
  ('VN', 'default', '1381', 'Tài sản thiếu chờ xử lý', '{}'::jsonb, 'asset_current', false, '138', 91),
  ('VN', 'default', '1385', 'Phải thu về cổ phần hóa', '{}'::jsonb, 'asset_current', false, '138', 92),
  ('VN', 'default', '1388', 'Phải thu khác', '{}'::jsonb, 'asset_current', false, '138', 93),
  ('VN', 'default', '141', 'Tạm ứng', '{}'::jsonb, 'asset_current', false, null, 100),
  ('VN', 'default', '151', 'Hàng mua đang đi đường', '{}'::jsonb, 'asset_current', false, null, 110),
  ('VN', 'default', '152', 'Nguyên liệu, vật liệu', '{}'::jsonb, 'asset_current', false, null, 120),
  ('VN', 'default', '153', 'Công cụ, dụng cụ', '{}'::jsonb, 'asset_current', false, null, 130),
  ('VN', 'default', '154', 'Chi phí sản xuất, kinh doanh dở dang', '{}'::jsonb, 'asset_current', false, null, 140),
  ('VN', 'default', '155', 'Thành phẩm', '{}'::jsonb, 'asset_current', false, null, 150),
  ('VN', 'default', '156', 'Hàng hóa', '{}'::jsonb, 'asset_current', false, null, 160),
  ('VN', 'default', '1561', 'Giá mua hàng hóa', '{}'::jsonb, 'asset_current', false, '156', 161),
  ('VN', 'default', '1562', 'Chi phí thu mua hàng hóa', '{}'::jsonb, 'asset_current', false, '156', 162),
  ('VN', 'default', '157', 'Hàng gửi đi bán', '{}'::jsonb, 'asset_current', false, null, 170),
  ('VN', 'default', '158', 'Hàng hóa kho bảo thuế', '{}'::jsonb, 'asset_current', false, null, 180),
  ('VN', 'default', '211', 'Tài sản cố định hữu hình', '{}'::jsonb, 'asset_fixed', false, null, 190),
  ('VN', 'default', '2111', 'Nhà cửa, vật kiến trúc', '{}'::jsonb, 'asset_fixed', false, '211', 191),
  ('VN', 'default', '2112', 'Máy móc, thiết bị', '{}'::jsonb, 'asset_fixed', false, '211', 192),
  ('VN', 'default', '2113', 'Phương tiện vận tải, truyền dẫn', '{}'::jsonb, 'asset_fixed', false, '211', 193),
  ('VN', 'default', '2114', 'Thiết bị, dụng cụ quản lý', '{}'::jsonb, 'asset_fixed', false, '211', 194),
  ('VN', 'default', '2118', 'Tài sản cố định hữu hình khác', '{}'::jsonb, 'asset_fixed', false, '211', 195),
  ('VN', 'default', '213', 'Tài sản cố định vô hình', '{}'::jsonb, 'asset_fixed', false, null, 200),
  ('VN', 'default', '2131', 'Quyền sử dụng đất', '{}'::jsonb, 'asset_fixed', false, '213', 201),
  ('VN', 'default', '2135', 'Phần mềm', '{}'::jsonb, 'asset_fixed', false, '213', 202),
  ('VN', 'default', '2138', 'Tài sản cố định vô hình khác', '{}'::jsonb, 'asset_fixed', false, '213', 203),
  ('VN', 'default', '214', 'Hao mòn tài sản cố định', '{}'::jsonb, 'asset_fixed', false, null, 210),
  ('VN', 'default', '2141', 'Hao mòn tài sản cố định hữu hình', '{}'::jsonb, 'asset_fixed', false, '214', 211),
  ('VN', 'default', '2143', 'Hao mòn tài sản cố định vô hình', '{}'::jsonb, 'asset_fixed', false, '214', 212),
  ('VN', 'default', '241', 'Xây dựng cơ bản dở dang', '{}'::jsonb, 'asset_non_current', false, null, 220),
  ('VN', 'default', '2411', 'Mua sắm tài sản cố định', '{}'::jsonb, 'asset_non_current', false, '241', 221),
  ('VN', 'default', '2412', 'Xây dựng cơ bản', '{}'::jsonb, 'asset_non_current', false, '241', 222),
  ('VN', 'default', '2413', 'Sửa chữa lớn tài sản cố định', '{}'::jsonb, 'asset_non_current', false, '241', 223),
  ('VN', 'default', '242', 'Chi phí trả trước', '{}'::jsonb, 'asset_prepayments', false, null, 230),
  ('VN', 'default', '243', 'Tài sản thuế thu nhập hoãn lại', '{}'::jsonb, 'asset_non_current', false, null, 240),
  ('VN', 'default', '244', 'Cầm cố, thế chấp, ký quỹ, ký cược', '{}'::jsonb, 'asset_non_current', false, null, 250),
  ('VN', 'default', '331', 'Phải trả cho người bán', '{}'::jsonb, 'liability_payable', true, null, 260),
  ('VN', 'default', '333', 'Thuế và các khoản phải nộp Nhà nước', '{}'::jsonb, 'liability_current', false, null, 270),
  ('VN', 'default', '3331', 'Thuế giá trị gia tăng phải nộp', '{}'::jsonb, 'liability_current', true, '333', 271),
  ('VN', 'default', '33311', 'Thuế giá trị gia tăng đầu ra', '{}'::jsonb, 'liability_current', false, '3331', 272),
  ('VN', 'default', '33312', 'Thuế giá trị gia tăng hàng nhập khẩu', '{}'::jsonb, 'liability_current', false, '3331', 273),
  ('VN', 'default', '3332', 'Thuế tiêu thụ đặc biệt', '{}'::jsonb, 'liability_current', false, '333', 274),
  ('VN', 'default', '3333', 'Thuế xuất, nhập khẩu', '{}'::jsonb, 'liability_current', false, '333', 275),
  ('VN', 'default', '3334', 'Thuế thu nhập doanh nghiệp', '{}'::jsonb, 'liability_current', false, '333', 276),
  ('VN', 'default', '3335', 'Thuế thu nhập cá nhân', '{}'::jsonb, 'liability_current', false, '333', 277),
  ('VN', 'default', '3336', 'Thuế tài nguyên', '{}'::jsonb, 'liability_current', false, '333', 278),
  ('VN', 'default', '3337', 'Thuế nhà đất, tiền thuê đất', '{}'::jsonb, 'liability_current', false, '333', 279),
  ('VN', 'default', '3339', 'Phí, lệ phí và các khoản phải nộp khác', '{}'::jsonb, 'liability_current', false, '333', 280),
  ('VN', 'default', '334', 'Phải trả người lao động', '{}'::jsonb, 'liability_current', false, null, 290),
  ('VN', 'default', '335', 'Chi phí phải trả', '{}'::jsonb, 'liability_current', false, null, 300),
  ('VN', 'default', '336', 'Phải trả nội bộ', '{}'::jsonb, 'liability_current', false, null, 310),
  ('VN', 'default', '338', 'Phải trả, phải nộp khác', '{}'::jsonb, 'liability_current', false, null, 320),
  ('VN', 'default', '3382', 'Kinh phí công đoàn', '{}'::jsonb, 'liability_current', false, '338', 321),
  ('VN', 'default', '3383', 'Bảo hiểm xã hội', '{}'::jsonb, 'liability_current', false, '338', 322),
  ('VN', 'default', '3384', 'Bảo hiểm y tế', '{}'::jsonb, 'liability_current', false, '338', 323),
  ('VN', 'default', '3386', 'Bảo hiểm thất nghiệp', '{}'::jsonb, 'liability_current', false, '338', 324),
  ('VN', 'default', '3387', 'Doanh thu chưa thực hiện', '{}'::jsonb, 'liability_current', false, '338', 325),
  ('VN', 'default', '3388', 'Phải trả, phải nộp khác', '{}'::jsonb, 'liability_current', false, '338', 326),
  ('VN', 'default', '341', 'Vay và nợ thuê tài chính', '{}'::jsonb, 'liability_non_current', false, null, 330),
  ('VN', 'default', '352', 'Dự phòng phải trả', '{}'::jsonb, 'liability_non_current', false, null, 340),
  ('VN', 'default', '3521', 'Dự phòng bảo hành sản phẩm hàng hóa', '{}'::jsonb, 'liability_non_current', false, '352', 341),
  ('VN', 'default', '3524', 'Dự phòng phải trả khác', '{}'::jsonb, 'liability_non_current', false, '352', 342),
  ('VN', 'default', '353', 'Quỹ khen thưởng, phúc lợi', '{}'::jsonb, 'liability_non_current', false, null, 350),
  ('VN', 'default', '411', 'Vốn đầu tư của chủ sở hữu', '{}'::jsonb, 'equity', false, null, 360),
  ('VN', 'default', '4111', 'Vốn góp của chủ sở hữu', '{}'::jsonb, 'equity', false, '411', 361),
  ('VN', 'default', '4112', 'Thặng dư vốn cổ phần', '{}'::jsonb, 'equity', false, '411', 362),
  ('VN', 'default', '4118', 'Vốn khác', '{}'::jsonb, 'equity', false, '411', 363),
  ('VN', 'default', '412', 'Chênh lệch đánh giá lại tài sản', '{}'::jsonb, 'equity', false, null, 370),
  ('VN', 'default', '413', 'Chênh lệch tỷ giá hối đoái', '{}'::jsonb, 'equity', false, null, 380),
  ('VN', 'default', '414', 'Quỹ đầu tư phát triển', '{}'::jsonb, 'equity', false, null, 390),
  ('VN', 'default', '418', 'Các quỹ khác thuộc vốn chủ sở hữu', '{}'::jsonb, 'equity', false, null, 400),
  ('VN', 'default', '419', 'Cổ phiếu quỹ', '{}'::jsonb, 'equity', false, null, 410),
  ('VN', 'default', '421', 'Lợi nhuận sau thuế chưa phân phối', '{}'::jsonb, 'equity_retained', false, null, 420),
  ('VN', 'default', '4211', 'Lợi nhuận sau thuế chưa phân phối năm trước', '{}'::jsonb, 'equity_retained', false, '421', 421),
  ('VN', 'default', '4212', 'Lợi nhuận sau thuế chưa phân phối năm nay', '{}'::jsonb, 'equity_retained', false, '421', 422),
  ('VN', 'default', '511', 'Doanh thu bán hàng và cung cấp dịch vụ', '{}'::jsonb, 'income', false, null, 430),
  ('VN', 'default', '5111', 'Doanh thu bán hàng hóa', '{}'::jsonb, 'income', false, '511', 431),
  ('VN', 'default', '5112', 'Doanh thu bán thành phẩm', '{}'::jsonb, 'income', false, '511', 432),
  ('VN', 'default', '5113', 'Doanh thu cung cấp dịch vụ', '{}'::jsonb, 'income', false, '511', 433),
  ('VN', 'default', '515', 'Doanh thu hoạt động tài chính', '{}'::jsonb, 'income_other', false, null, 440),
  ('VN', 'default', '521', 'Các khoản giảm trừ doanh thu', '{}'::jsonb, 'income', false, null, 450),
  ('VN', 'default', '611', 'Mua hàng', '{}'::jsonb, 'expense_direct_cost', false, null, 460),
  ('VN', 'default', '621', 'Chi phí nguyên liệu, vật liệu trực tiếp', '{}'::jsonb, 'expense_direct_cost', false, null, 470),
  ('VN', 'default', '622', 'Chi phí nhân công trực tiếp', '{}'::jsonb, 'expense_direct_cost', false, null, 480),
  ('VN', 'default', '623', 'Chi phí sử dụng máy thi công', '{}'::jsonb, 'expense_direct_cost', false, null, 490),
  ('VN', 'default', '627', 'Chi phí sản xuất chung', '{}'::jsonb, 'expense_direct_cost', false, null, 500),
  ('VN', 'default', '631', 'Giá thành sản xuất', '{}'::jsonb, 'expense_direct_cost', false, null, 510),
  ('VN', 'default', '632', 'Giá vốn hàng bán', '{}'::jsonb, 'expense_direct_cost', false, null, 520),
  ('VN', 'default', '635', 'Chi phí tài chính', '{}'::jsonb, 'expense', false, null, 530),
  ('VN', 'default', '641', 'Chi phí bán hàng', '{}'::jsonb, 'expense', false, null, 540),
  ('VN', 'default', '642', 'Chi phí quản lý doanh nghiệp', '{}'::jsonb, 'expense', false, null, 550),
  ('VN', 'default', '711', 'Thu nhập khác', '{}'::jsonb, 'income_other', false, null, 560),
  ('VN', 'default', '811', 'Chi phí khác', '{}'::jsonb, 'expense', false, null, 570),
  ('VN', 'default', '821', 'Chi phí thuế thu nhập doanh nghiệp', '{}'::jsonb, 'expense', false, null, 580),
  ('VN', 'default', '8211', 'Chi phí thuế thu nhập doanh nghiệp hiện hành', '{}'::jsonb, 'expense', false, '821', 581),
  ('VN', 'default', '8212', 'Chi phí thuế thu nhập doanh nghiệp hoãn lại', '{}'::jsonb, 'expense', false, '821', 582)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('VN', 'BNK', 'Sổ tiền gửi ngân hàng', '{}'::jsonb, 'bank', 30),
  ('VN', 'CSH', 'Sổ quỹ tiền mặt', '{}'::jsonb, 'cash', 40),
  ('VN', 'GEN', 'Sổ nhật ký chung', '{}'::jsonb, 'general', 50),
  ('VN', 'OPN', 'Số dư đầu kỳ', '{}'::jsonb, 'opening', 60),
  ('VN', 'PUR', 'Sổ nhật ký mua hàng', '{}'::jsonb, 'purchase', 20),
  ('VN', 'SAL', 'Sổ nhật ký bán hàng', '{}'::jsonb, 'sales', 10)
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
  ('VN', 'VN-P-10', 'Mua vào — thuế suất 10%', '{}'::jsonb, 'Thuế giá trị gia tăng đầu vào được khấu trừ, thuế suất phổ thông', 'percent', 10, 'purchase', 'domestic', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 11 — phương pháp khấu trừ thuế: số thuế giá trị gia tăng phải nộp bằng số thuế giá trị gia tăng đầu ra trừ số thuế giá trị gia tăng đầu vào được khấu trừ; Điều 14 — điều kiện khấu trừ (hóa đơn giá trị gia tăng hợp pháp, chứng từ thanh toán không dùng tiền mặt đối với hàng hóa, dịch vụ mua vào từ 5 triệu đồng trở lên). Kê khai tại chỉ tiêu [23] (giá trị) và [24] (thuế) của Mẫu 01/GTGT.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-P-5', 'Mua vào — thuế suất 5%', '{}'::jsonb, 'Thuế giá trị gia tăng đầu vào được khấu trừ, thuế suất ưu đãi', 'percent', 5, 'purchase', 'domestic', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 9, khoản 2 và Điều 14 — thuế giá trị gia tăng đầu vào trên hàng hóa, dịch vụ mua vào thuộc danh mục thuế suất 5%, được khấu trừ theo cùng điều kiện với VN-P-10.', null, null, 80, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-P-8-NQ204', 'Mua vào — thuế suất 8% (giảm tạm thời)', '{}'::jsonb, 'Thuế giá trị gia tăng đầu vào trên hàng hóa, dịch vụ được giảm thuế theo Nghị quyết 204/2025/QH15', 'percent', 8, 'purchase', 'domestic', date '2025-07-01', date '2026-12-31', 'Nghị quyết số 204/2025/QH15 và Nghị định số 174/2025/NĐ-CP — mặt mua vào tương ứng với VN-S-8-NQ204: trong thời gian áp dụng giảm thuế, người bán xuất hóa đơn thuế suất 8% và người mua khấu trừ thuế đầu vào theo cùng thuế suất và cùng điều kiện với VN-P-10 (Điều 14, Luật Thuế giá trị gia tăng số 48/2024/QH15).', null, null, 70, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-cut-nq204', null, null, null, null),
  ('VN', 'VN-P-IMP-10', 'Nhập khẩu — thuế suất 10%', '{}'::jsonb, 'Thuế giá trị gia tăng hàng nhập khẩu, nộp cho cơ quan hải quan, thuế suất phổ thông', 'percent', 10, 'purchase', 'import', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 7, khoản 2 — giá tính thuế đối với hàng hóa nhập khẩu là giá nhập tại cửa khẩu cộng thuế nhập khẩu (nếu có), cộng thuế tiêu thụ đặc biệt (nếu có), cộng thuế bảo vệ môi trường (nếu có); Điều 9, khoản 3 — thuế suất 10% khi hàng hóa không thuộc danh mục 0%/5%. Thuế do người nhập khẩu nộp cho cơ quan hải quan tại thời điểm thông quan, được khấu trừ theo Điều 14. Pack tính thuế trên giá trị hóa đơn của nhà cung cấp nước ngoài, không phải trị giá hải quan (khác biệt nằm ở thuế nhập khẩu và các khoản điều chỉnh khác mà pack không tính) — điểm cần một kế toán tại Việt Nam kiểm tra lại.', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-P-NT', 'Mua vào — không chịu thuế GTGT', '{}'::jsonb, 'Hàng hóa, dịch vụ mua vào từ người bán thuộc đối tượng không chịu thuế, hoặc không có hóa đơn giá trị gia tăng', 'percent', 0, 'purchase', 'exempt', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 5 — người bán không tính thuế giá trị gia tăng trên hóa đơn, nên không có số thuế nào để khấu trừ; không thuộc chỉ tiêu [23]/[24] của Mẫu 01/GTGT.', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-S-0-EXP', 'Bán ra — xuất khẩu, thuế suất 0%', '{}'::jsonb, 'Hàng hóa, dịch vụ xuất khẩu', 'percent', 0, 'sale', 'export', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 9, khoản 1 — thuế suất 0% áp dụng đối với hàng hóa xuất khẩu, dịch vụ xuất khẩu và một số trường hợp được coi như xuất khẩu; khoản 6 giao Chính phủ quy định điều kiện, hồ sơ, thủ tục áp dụng — hợp đồng bán hàng hóa, gia công hàng hóa, cung ứng dịch vụ; chứng từ thanh toán không dùng tiền mặt; tờ khai hải quan đối với hàng hóa xuất khẩu. `conditions: transport_evidence` ghi lại rằng quyền áp dụng thuế suất 0% phụ thuộc vào việc xuất trình các chứng từ này, việc sổ sách không tự chứng minh được.', null, null, 40, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-S-10', 'Bán ra — thuế suất 10%', '{}'::jsonb, 'Thuế giá trị gia tăng đầu ra, thuế suất phổ thông', 'percent', 10, 'sale', 'domestic', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 9, khoản 3 — mức thuế suất 10% áp dụng đối với hàng hóa, dịch vụ không thuộc đối tượng áp dụng thuế suất 0% và 5% quy định tại khoản 1 và khoản 2 Điều này. Có hiệu lực từ 01/07/2025 (Điều 18, khoản 1). Giá trị được kê khai tại chỉ tiêu [31] và thuế tại chỉ tiêu [32] của Mẫu 01/GTGT.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-S-5', 'Bán ra — thuế suất 5%', '{}'::jsonb, 'Thuế giá trị gia tăng đầu ra, thuế suất ưu đãi', 'percent', 5, 'sale', 'domestic', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 9, khoản 2 — danh mục giới hạn các nhóm hàng hóa, dịch vụ áp dụng thuế suất 5% (nước sạch; phân bón, thuốc phòng trừ sâu bệnh và chất kích thích tăng trưởng vật nuôi, cây trồng; thực phẩm tươi sống, lâm sản chưa qua chế biến; mủ cao su sơ chế; đường và phụ phẩm; thiết bị, dụng cụ y tế, thuốc chữa bệnh, phòng bệnh; giáo cụ dùng để giảng dạy; hoạt động văn hóa, triển lãm, thể dục thể thao, nhà ở xã hội…). `conditions: supply_nature` vì việc một hàng hóa/dịch vụ cụ thể có nằm trong danh mục hay không là một câu hỏi về bản chất của hàng hóa mà sổ sách không tự trả lời.', null, null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null),
  ('VN', 'VN-S-8-NQ204', 'Bán ra — thuế suất 8% (giảm tạm thời)', '{}'::jsonb, 'Hàng hóa, dịch vụ được giảm 2 điểm thuế suất theo Nghị quyết 204/2025/QH15, từ 01/07/2025 đến 31/12/2026', 'percent', 8, 'sale', 'domestic', date '2025-07-01', date '2026-12-31', 'Nghị quyết số 204/2025/QH15, Điều 1 — giảm 2% thuế suất thuế giá trị gia tăng đối với các nhóm hàng hóa, dịch vụ đang áp dụng mức thuế suất 10% (còn 8%), trừ một số nhóm hàng hóa, dịch vụ: viễn thông, hoạt động tài chính, ngân hàng, chứng khoán, bảo hiểm, kinh doanh bất động sản, sản phẩm kim loại, sản phẩm khai khoáng (trừ than), hàng hóa và dịch vụ chịu thuế tiêu thụ đặc biệt (trừ xăng); Nghị định số 174/2025/NĐ-CP quy định chi tiết danh mục loại trừ tại Phụ lục I và Phụ lục II — danh mục chi tiết theo mã HS/ngành nghề của hai phụ lục này chưa được đối chiếu từng dòng khi soạn gói này, nên `conditions: supply_nature` đánh dấu việc phân loại một hàng hóa/dịch vụ cụ thể vào hay ra khỏi danh mục giảm thuế là một câu hỏi mà sổ sách không tự trả lời được. Áp dụng từ 01/07/2025 đến hết 31/12/2026.', null, null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-cut-nq204', null, null, null, null),
  ('VN', 'VN-S-NT', 'Bán ra — không chịu thuế GTGT', '{}'::jsonb, 'Đối tượng không chịu thuế giá trị gia tăng, Điều 5', 'percent', 0, 'sale', 'exempt', date '2025-07-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 5 — hai mươi tám nhóm đối tượng không chịu thuế giá trị gia tăng (sản phẩm nông nghiệp chưa chế biến do người sản xuất trực tiếp bán ra, dịch vụ tín dụng, chuyển nhượng vốn, bảo hiểm nhân thọ, y tế, giáo dục, chuyển giao công nghệ, phần mềm…). Khoản 27 — hàng hóa, dịch vụ này không được khấu trừ, hoàn thuế GTGT đầu vào tương ứng, trừ trường hợp áp dụng thuế suất 0% tại khoản 1 Điều 9.', null, null, 50, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'vat-law-48', null, null, null, null)
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
    ('VN-P-10', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-P-10', 'invoice', 'tax', 100, '133', '24', array['24']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-10', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-P-10', 'credit_note', 'tax', 100, '133', '24', array['24']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-5', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-P-5', 'invoice', 'tax', 100, '133', '24', array['24']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-5', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-P-5', 'credit_note', 'tax', 100, '133', '24', array['24']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-8-NQ204', 'invoice', 'base', 100, null, '23', array['23']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-P-8-NQ204', 'invoice', 'tax', 100, '133', '24', array['24']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-8-NQ204', 'credit_note', 'base', 100, null, '23', array['23']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-P-8-NQ204', 'credit_note', 'tax', 100, '133', '24', array['24']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-IMP-10', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('VN-P-IMP-10', 'invoice', 'tax', 100, '133', '24', array['24']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-IMP-10', 'invoice', 'tax', -100, '33312', null, null, 100, null, 30),
    ('VN-P-IMP-10', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('VN-P-IMP-10', 'credit_note', 'tax', 100, '133', '24', array['24']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-P-IMP-10', 'credit_note', 'tax', -100, '33312', null, null, -100, null, 30),
    ('VN-P-NT', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('VN-P-NT', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('VN-S-0-EXP', 'invoice', 'base', 100, null, '28', array['28']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-0-EXP', 'credit_note', 'base', 100, null, '28', array['28']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-10', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-10', 'invoice', 'tax', 100, '3331', '32', array['32']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-S-10', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-10', 'credit_note', 'tax', 100, '3331', '32', array['32']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-S-5', 'invoice', 'base', 100, null, '29', array['29']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-5', 'invoice', 'tax', 100, '3331', '30', array['30']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-S-5', 'credit_note', 'base', 100, null, '29', array['29']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-5', 'credit_note', 'tax', 100, '3331', '30', array['30']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-S-8-NQ204', 'invoice', 'base', 100, null, '31', array['31']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-8-NQ204', 'invoice', 'tax', 100, '3331', '32', array['32']::text[], 100, 'VN-VAT-01-GTGT', 20),
    ('VN-S-8-NQ204', 'credit_note', 'base', 100, null, '31', array['31']::text[], -100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-8-NQ204', 'credit_note', 'tax', 100, '3331', '32', array['32']::text[], -100, 'VN-VAT-01-GTGT', 20),
    ('VN-S-NT', 'invoice', 'base', 100, null, '26', array['26']::text[], 100, 'VN-VAT-01-GTGT', 10),
    ('VN-S-NT', 'credit_note', 'base', 100, null, '26', array['26']::text[], -100, 'VN-VAT-01-GTGT', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'VN' and t.code = v.tax_code
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
  ('VN', 'VN-VAT-01-GTGT', 'Tờ khai thuế giá trị gia tăng (phương pháp khấu trừ) — Mẫu số 01/GTGT', array['month', 'quarter']::declaration_period[], null, date '2022-01-01', null, 'Luật Quản lý thuế số 38/2019/QH14, Điều 8 và Điều 43 — người nộp thuế theo phương pháp khấu trừ tự khai, tự nộp thuế giá trị gia tăng theo kỳ tính thuế tháng hoặc quý; Nghị định 126/2020/NĐ-CP, Điều 9, khoản 1, điểm a — khai theo quý áp dụng cho người nộp thuế có tổng doanh thu bán hàng hóa, cung cấp dịch vụ của năm trước liền kề từ 50 tỷ đồng trở xuống, người nộp thuế mới bắt đầu hoạt động khai theo quý và được lựa chọn ổn định trong 3 năm. Không có kỳ mặc định chung cho mọi người nộp thuế — kỳ tính thuế phụ thuộc vào doanh thu năm trước, một sự kiện của công ty mà pack này không biết — nên `period_default` để trống và `ekwo init` hỏi. Mẫu số 01/GTGT được ban hành tại Thông tư 80/2021/TT-BTC (Phụ lục II) và, từ 01/07/2026, tại Thông tư 89/2026/TT-BTC (Phụ lục I, ký 30/06/2026, thay thế đồng thời Thông tư 80/2021/TT-BTC). Bộ khung các chỉ tiêu của tờ khai bên dưới được chuyển thể từ cấu trúc Mẫu 01/GTGT đã ổn định qua nhiều năm dưới Thông tư 80/2021/TT-BTC; nội dung chính xác của Phụ lục I Thông tư 89/2026/TT-BTC (có điều chỉnh một số chỉ tiêu) chưa được đối chiếu trực tiếp với văn bản gốc khi soạn gói này — xem README.', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Luật Quản lý thuế số 38/2019/QH14, Điều 44, khoản 1, điểm a — chậm nhất là ngày thứ 20 của tháng tiếp theo tháng phát sinh nghĩa vụ thuế, đối với trường hợp khai và nộp theo tháng. Người nộp thuế khai theo quý có thời hạn khác — chậm nhất là ngày cuối cùng của tháng đầu của quý tiếp theo quý phát sinh nghĩa vụ thuế (điểm b cùng khoản) — mà trường `deadline` của một tờ khai chỉ giữ được MỘT quy tắc; vì kỳ tính thuế của công ty (tháng hay quý) không được biết trước ở đây, pack khai báo quy tắc tháng và ghi khoảng cách này (kỳ quý cần một quy tắc khác) trong docs/international.md.', 'tax-admin-38', null)
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
  ('VN', 'VN-VAT-01-GTGT', '22', 'tax', 'Thuế GTGT còn được khấu trừ kỳ trước chuyển sang', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [22] — bằng chỉ tiêu [43] của tờ khai kỳ tính thuế trước; không có bút toán thuế nào của pack này ghi trực tiếp vào chỉ tiêu này, giống cách chỉ tiêu tương ứng của Pháp (case 22, « report du crédit ») được xử lý.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '23', 'base', 'Tổng giá trị hàng hóa, dịch vụ mua vào trong kỳ', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [23] — tổng giá trị (chưa có thuế GTGT) của hàng hóa, dịch vụ mua vào chịu thuế GTGT trong kỳ, không kể hàng hóa, dịch vụ mua vào không chịu thuế hoặc từ người bán không xuất hóa đơn GTGT.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '24', 'tax', 'Tổng số thuế GTGT của hàng hóa, dịch vụ mua vào', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [24] — tổng số thuế giá trị gia tăng ghi trên hóa đơn giá trị gia tăng mua hàng hóa, dịch vụ hoặc chứng từ nộp thuế GTGT hàng nhập khẩu.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '25', 'total', 'Tổng số thuế GTGT được khấu trừ kỳ này', '{}'::jsonb, 40, null, array['24']::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [25] — bằng chỉ tiêu [24] khi toàn bộ hàng hóa, dịch vụ mua vào phục vụ hoạt động chịu thuế giá trị gia tăng. Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 14 quy định phân bổ khấu trừ khi hàng hóa, dịch vụ mua vào dùng chung cho hoạt động chịu thuế và không chịu thuế, theo tỷ lệ doanh thu chịu thuế trên tổng doanh thu — phép phân bổ này pack không tính, giống cách packs/jp không tính tỷ lệ 95%.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '26', 'base', 'Hàng hóa, dịch vụ bán ra không chịu thuế GTGT', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [26] — giá trị hàng hóa, dịch vụ bán ra thuộc đối tượng không chịu thuế giá trị gia tăng theo Điều 5 Luật Thuế giá trị gia tăng số 48/2024/QH15.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '27', 'total', 'Tổng doanh thu hàng hóa, dịch vụ bán ra chịu thuế GTGT', '{}'::jsonb, 60, null, array['28', '29', '31']::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [27] — tổng giá trị hàng hóa, dịch vụ bán ra chịu thuế, bằng tổng giá trị bán ra theo từng mức thuế suất (0%, 5%, 10%).', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '28', 'base', 'Hàng hóa, dịch vụ bán ra chịu thuế suất 0%', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [28] — giá trị hàng hóa, dịch vụ bán ra áp dụng thuế suất 0% (Điều 9, khoản 1, Luật Thuế giá trị gia tăng số 48/2024/QH15).', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '29', 'base', 'Hàng hóa, dịch vụ bán ra chịu thuế suất 5% — giá trị', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [29] — giá trị (chưa có thuế) hàng hóa, dịch vụ bán ra áp dụng thuế suất 5% (Điều 9, khoản 2, Luật Thuế giá trị gia tăng số 48/2024/QH15).', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '30', 'tax', 'Hàng hóa, dịch vụ bán ra chịu thuế suất 5% — thuế GTGT', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [30] — thuế giá trị gia tăng của hàng hóa, dịch vụ bán ra tại chỉ tiêu [29].', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '31', 'base', 'Hàng hóa, dịch vụ bán ra chịu thuế suất 10% — giá trị', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [31] — giá trị (chưa có thuế) hàng hóa, dịch vụ bán ra áp dụng thuế suất 10% (Điều 9, khoản 3, Luật Thuế giá trị gia tăng số 48/2024/QH15). Trong thời gian áp dụng Nghị quyết 204/2025/QH15 và Nghị định 174/2025/NĐ-CP (01/07/2025-31/12/2026), giá trị hàng hóa, dịch vụ được giảm còn thuế suất 8% cũng được kê khai trên chỉ tiêu này — pack giả định cách kê khai đó theo thực tiễn phổ biến của cơ quan thuế đối với chính sách giảm thuế theo tỷ lệ phần trăm trên thuế suất 10%, không được đối chiếu trực tiếp với hướng dẫn chính thức của Mẫu 01/GTGT cho kỳ áp dụng Nghị định 174/2025/NĐ-CP — xem README.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '32', 'tax', 'Hàng hóa, dịch vụ bán ra chịu thuế suất 10% — thuế GTGT', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [32] — thuế giá trị gia tăng của hàng hóa, dịch vụ bán ra tại chỉ tiêu [31], tại thuế suất thực tế áp dụng (10% hoặc, tạm thời, 8%).', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '33', 'total', 'Tổng doanh thu hàng hóa, dịch vụ bán ra', '{}'::jsonb, 120, null, array['26', '27']::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [33] — tổng cộng chỉ tiêu [26] và [27].', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '34', 'total', 'Tổng số thuế GTGT đầu ra', '{}'::jsonb, 130, null, array['30', '32']::text[], '{}'::text[], null, null, false, false, null, 'Mẫu số 01/GTGT — tổng số thuế giá trị gia tăng đầu ra phát sinh trong kỳ, bằng tổng chỉ tiêu [30] và [32].', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '36', 'total', 'Thuế GTGT phải nộp trong kỳ', '{}'::jsonb, 140, null, array['34']::text[], array['25', '22']::text[], null, null, true, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [36] (chỉ tiêu [40] tại một số phiên bản trước) — [34] trừ ([25] cộng [22]), khi số dương: thuế giá trị gia tăng phải nộp ngân sách nhà nước. Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 44, khoản 1, điểm g Luật Quản lý thuế 38/2019/QH14 quy định nộp thuế chậm nhất là ngày cuối cùng của thời hạn nộp hồ sơ khai thuế.', 'vat-return-form'),
  ('VN', 'VN-VAT-01-GTGT', '43', 'total', 'Thuế GTGT còn được khấu trừ chuyển kỳ sau', '{}'::jsonb, 150, null, array['25', '22']::text[], array['34']::text[], null, null, true, false, null, 'Mẫu số 01/GTGT, chỉ tiêu [43] — ([25] cộng [22]) trừ [34], khi số dương: số thuế giá trị gia tăng đầu vào chưa được khấu trừ hết, chuyển sang kỳ tính thuế sau (Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 14). Chỉ tiêu [22] của kỳ sau bằng chỉ tiêu [43] của kỳ này.', 'vat-return-form')
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
  ('VN-BCTC-BCTHTC', 'VN', 'default', 'Báo cáo tình hình tài chính (Mẫu số B01-DN)', 'balance_sheet', 'VN-VAS', date '1970-01-01', null, 'Thông tư số 99/2025/TT-BTC hướng dẫn Chế độ kế toán doanh nghiệp, Mẫu số B01-DN — trước 01/01/2026 mẫu này mang tên « Bảng cân đối kế toán » dưới Thông tư 200/2014/TT-BTC ; Thông tư 99/2025/TT-BTC giữ nguyên mã số B01-DN nhưng đổi tên thành « Báo cáo tình hình tài chính ». Các dòng dưới đây tái hiện các mục lớn (mã số cấp tổng hợp) của mẫu; danh mục chi tiết đầy đủ theo từng mã số cấp 2/cấp 3 của Thông tư 99/2025/TT-BTC chưa được đối chiếu từng dòng khi soạn gói này — xem README. Các tài khoản của lớp 6 (chi phí sản xuất, kinh doanh dở dang trung gian: 611, 621, 622, 623, 627, 631) được gộp vào giá vốn hàng bán (632) trên báo cáo kết quả kinh doanh, để đơn giản hóa: gói này không trình bày riêng một sổ giá thành sản xuất.', 'vas-tt99'),
  ('VN-BCTC-KQKD', 'VN', 'default', 'Báo cáo kết quả hoạt động kinh doanh (Mẫu số B02-DN)', 'income_statement', 'VN-VAS', date '1970-01-01', null, 'Thông tư số 99/2025/TT-BTC hướng dẫn Chế độ kế toán doanh nghiệp, Mẫu số B02-DN — mã số và tên gọi được giữ nguyên so với Thông tư 200/2014/TT-BTC.', 'vas-tt99')
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
  ('VN-BCTC-BCTHTC', '270', null, 'TỔNG CỘNG TÀI SẢN', '{}'::jsonb, 10, 1, true, array['100', '200']::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 270 — tổng cộng tài sản ngắn hạn và dài hạn.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '100', '270', 'A. TÀI SẢN NGẮN HẠN', '{}'::jsonb, 20, 1, true, array['110', '120', '130', '140', '150']::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 100.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '110', '100', 'I. Tiền và các khoản tương đương tiền', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 110.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '120', '100', 'II. Đầu tư tài chính ngắn hạn', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 120.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '130', '100', 'III. Các khoản phải thu ngắn hạn', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 130.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '140', '100', 'IV. Hàng tồn kho', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 140.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '150', '100', 'V. Tài sản ngắn hạn khác', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 150 và 152 (thuế giá trị gia tăng còn được khấu trừ).', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '200', '270', 'B. TÀI SẢN DÀI HẠN', '{}'::jsonb, 80, 1, true, array['220', '260']::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 200.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '220', '200', 'II. Tài sản cố định', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 220 — nguyên giá trừ hao mòn lũy kế (mã số 214, giá trị âm).', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '260', '200', 'VI. Tài sản dài hạn khác', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 260 — bao gồm xây dựng cơ bản dở dang (241), chi phí trả trước (242), tài sản thuế thu nhập hoãn lại (243) và các khoản ký quỹ, ký cược (244).', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '440', null, 'TỔNG CỘNG NGUỒN VỐN', '{}'::jsonb, 110, 1, true, array['300', '400']::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 440 — bằng tổng cộng tài sản (mã số 270) khi năm tài chính đã khóa sổ.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '300', '440', 'C. NỢ PHẢI TRẢ', '{}'::jsonb, 120, 1, true, array['310', '330']::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 300.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '310', '300', 'I. Nợ ngắn hạn', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 310 — phải trả người bán (331), thuế và các khoản phải nộp Nhà nước (333), phải trả người lao động (334), chi phí phải trả (335), phải trả nội bộ (336), phải trả, phải nộp khác (338).', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '330', '300', 'II. Nợ dài hạn', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 330 — vay và nợ thuê tài chính (341), dự phòng phải trả (352), quỹ khen thưởng, phúc lợi (353).', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '400', '440', 'D. VỐN CHỦ SỞ HỮU', '{}'::jsonb, 150, 1, true, array['410']::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 400.', 'vas-tt99'),
  ('VN-BCTC-BCTHTC', '410', '400', 'I. Vốn chủ sở hữu', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B01-DN, mã số 410 đến 421 — vốn đầu tư của chủ sở hữu, các quỹ thuộc vốn chủ sở hữu và lợi nhuận sau thuế chưa phân phối (421).', 'vas-tt99'),
  ('VN-BCTC-KQKD', '01', null, '1. Doanh thu bán hàng và cung cấp dịch vụ', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 01.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '02', null, '2. Các khoản giảm trừ doanh thu', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 02.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '10', null, '3. Doanh thu thuần về bán hàng và cung cấp dịch vụ', '{}'::jsonb, 30, 1, true, array['01']::text[], array['02']::text[], null, 'Mẫu B02-DN, mã số 10 = mã số 01 - mã số 02.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '11', null, '4. Giá vốn hàng bán', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 11 — gồm giá vốn hàng bán (632) và, đã gộp để đơn giản hóa, các tài khoản chi phí sản xuất trung gian của lớp 6 (611, 621, 622, 623, 627, 631) mà gói này không trình bày một sổ giá thành riêng.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '20', null, '5. Lợi nhuận gộp về bán hàng và cung cấp dịch vụ', '{}'::jsonb, 50, 1, true, array['10']::text[], array['11']::text[], null, 'Mẫu B02-DN, mã số 20 = mã số 10 - mã số 11.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '21', null, '6. Doanh thu hoạt động tài chính', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 21.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '22', null, '7. Chi phí tài chính', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 22.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '25', null, '9. Chi phí bán hàng', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 25.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '26', null, '10. Chi phí quản lý doanh nghiệp', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 26.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '30', null, '11. Lợi nhuận thuần từ hoạt động kinh doanh', '{}'::jsonb, 100, 1, true, array['20', '21']::text[], array['22', '25', '26']::text[], null, 'Mẫu B02-DN, mã số 30 = mã số 20 + (21 - 22) - (25 + 26).', 'vas-tt99'),
  ('VN-BCTC-KQKD', '31', null, '12. Thu nhập khác', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 31.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '32', null, '13. Chi phí khác', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 32.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '40', null, '14. Lợi nhuận khác', '{}'::jsonb, 130, 1, true, array['31']::text[], array['32']::text[], null, 'Mẫu B02-DN, mã số 40 = mã số 31 - mã số 32.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '50', null, '15. Tổng lợi nhuận kế toán trước thuế', '{}'::jsonb, 140, 1, true, array['30', '40']::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 50 = mã số 30 + mã số 40.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '51', null, '16. Chi phí thuế thu nhập doanh nghiệp hiện hành', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Mẫu B02-DN, mã số 51 — gồm chi phí thuế thu nhập doanh nghiệp hiện hành và hoãn lại (8211, 8212), gộp trên một dòng để đơn giản hóa.', 'vas-tt99'),
  ('VN-BCTC-KQKD', '60', null, '18. Lợi nhuận sau thuế thu nhập doanh nghiệp', '{}'::jsonb, 160, 1, true, array['50']::text[], array['51']::text[], null, 'Mẫu B02-DN, mã số 60 = mã số 50 - mã số 51 - mã số 52 (mã số 52, chi phí thuế thu nhập hoãn lại, được gộp vào mã số 51 trong gói này).', 'vas-tt99')
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
    ('VN-BCTC-BCTHTC', '110', 10, 'code_range', '111', '113', null, 'any'),
    ('VN-BCTC-BCTHTC', '120', 10, 'code_range', '121', '128', null, 'any'),
    ('VN-BCTC-BCTHTC', '130', 10, 'account_code', '131', null, null, 'any'),
    ('VN-BCTC-BCTHTC', '130', 20, 'code_range', '136', '138', null, 'any'),
    ('VN-BCTC-BCTHTC', '140', 10, 'code_range', '151', '158', null, 'any'),
    ('VN-BCTC-BCTHTC', '150', 10, 'code_range', '133', '134', null, 'any'),
    ('VN-BCTC-BCTHTC', '150', 20, 'account_code', '141', null, null, 'any'),
    ('VN-BCTC-BCTHTC', '220', 10, 'code_range', '211', '214', null, 'any'),
    ('VN-BCTC-BCTHTC', '260', 10, 'code_range', '241', '244', null, 'any'),
    ('VN-BCTC-BCTHTC', '310', 10, 'code_range', '331', '339', null, 'any'),
    ('VN-BCTC-BCTHTC', '330', 10, 'code_range', '341', '353', null, 'any'),
    ('VN-BCTC-BCTHTC', '410', 10, 'code_range', '411', '421', null, 'any'),
    ('VN-BCTC-KQKD', '01', 10, 'code_range', '511', '512', null, 'any'),
    ('VN-BCTC-KQKD', '02', 10, 'account_code', '521', null, null, 'any'),
    ('VN-BCTC-KQKD', '11', 10, 'code_range', '611', '632', null, 'any'),
    ('VN-BCTC-KQKD', '21', 10, 'account_code', '515', null, null, 'any'),
    ('VN-BCTC-KQKD', '22', 10, 'account_code', '635', null, null, 'any'),
    ('VN-BCTC-KQKD', '25', 10, 'account_code', '641', null, null, 'any'),
    ('VN-BCTC-KQKD', '26', 10, 'account_code', '642', null, null, 'any'),
    ('VN-BCTC-KQKD', '31', 10, 'account_code', '711', null, null, 'any'),
    ('VN-BCTC-KQKD', '32', 10, 'account_code', '811', null, null, 'any'),
    ('VN-BCTC-KQKD', '51', 10, 'code_range', '821', '822', null, 'any')
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
  ('VN', 'Việt Nam', '{}'::jsonb, array['vi']::text[], 'VND', '131', '331', '338', '811', '421', '511', '632', '112', '111', 'SAL', 'PUR', 'GEN', 'vi', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '515', '635', '711', '811', null, null, '3331', '133', null, null)
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
  number_format                 = '{CODE}{NNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Nghị định 123/2020/NĐ-CP, Điều 10, khoản 3 — số hóa đơn là số thứ tự, tối đa 8 chữ số, bắt đầu từ số 1 vào ngày 01/01 hoặc ngày bắt đầu sử dụng hóa đơn và kết thúc vào ngày 31/12 hằng năm (dãy số theo năm, không nhất thiết liên tục tuyệt đối giữa các mẫu số/ký hiệu khác nhau của cùng một người bán); Điều 4, khoản 1 — mỗi hóa đơn được cấp một mã của cơ quan thuế hoặc, với hóa đơn không có mã, dữ liệu được chuyển đến cơ quan thuế. `number_format` không tái tạo được ký hiệu mẫu số/ký hiệu hóa đơn (6 ký tự) mà Điều 4, khoản 1 và Phụ lục IA của Nghị định 123/2020/NĐ-CP (chưa sửa đổi bởi Nghị định 70/2025/NĐ-CP trên các điểm này) quy định.',
  numbering_source_key          = 'einvoice-nd123',
  payment_terms_legal_reference = 'Không có văn bản nào quy định một thời hạn thanh toán pháp định chung giữa các doanh nghiệp khi không có thỏa thuận, nên legal_payment_days và late_payment_reference để trống.',
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 8, khoản 1 — đối với hàng hóa là thời điểm chuyển giao quyền sở hữu hoặc quyền sử dụng hàng hóa hoặc thời điểm lập hóa đơn, tùy thời điểm nào đến trước, không phân biệt đã thu được tiền hay chưa; đối với dịch vụ là thời điểm hoàn thành việc cung cấp dịch vụ hoặc thời điểm lập hóa đơn, tùy thời điểm nào đến trước. `earliest_of_delivery_or_payment` là gần đúng nhất trong từ vựng đóng của Ekwo: luật thực ra so sánh giao hàng/hoàn thành dịch vụ với NGÀY LẬP HÓA ĐƠN chứ không phải ngày thanh toán — không có mục nào của từ vựng diễn đạt đúng "giao hàng hoặc hóa đơn, tùy cái nào trước"; khoảng cách này được ghi trong docs/international.md. Các trường hợp đặc biệt (xuất khẩu, viễn thông, bảo hiểm, điện/nước, bất động sản, xây dựng, dầu khí) được giao cho nghị định hướng dẫn và không được gói này chuyển tải.',
  tax_point_source_key          = 'vat-law-48',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Việt Nam bắt buộc hóa đơn điện tử cho hầu hết người nộp thuế (Nghị định 123/2020/NĐ-CP, Điều 5, khoản 1, và Điều 91 Luật Quản lý thuế 38/2019/QH14) nhưng đây là một hệ thống CẤP MÃ (clearance): hóa đơn điện tử có mã của cơ quan thuế chỉ có giá trị sau khi Tổng cục Thuế cấp mã xác thực trong thời gian thực trước khi gửi cho người mua (Nghị định 123/2020/NĐ-CP, Điều 3, khoản 2 và Điều 17; sửa đổi bởi Nghị định 70/2025/NĐ-CP, bổ sung hóa đơn điện tử khởi tạo từ máy tính tiền và hóa đơn thương mại điện tử với dữ liệu truyền theo thời gian thực). Đây không phải một hồ sơ EN 16931/Peppol: không có "profile" của Ekwo (peppol-bis-3, factur-x-en16931, pint-*) mô tả đúng cơ chế cấp mã của cơ quan thuế Việt Nam — dùng một trong các mã đó sẽ khiến describePack() nói rằng hóa đơn được "viết và xác thực" theo chuẩn đó và có thể gửi qua một điểm truy cập Peppol, điều không đúng ở Việt Nam. Theo đúng cách packs/mx và packs/ci đã làm cho các hệ thống cấp mã tương tự, pack này để `profile`, `mandatory_from` và `obligation` trống và ghi rõ khoảng cách này trong docs/international.md (P1-UK và cách MX/CI xử lý). Cơ chế "hóa đơn may mắn" (lottery hóa đơn khuyến khích người mua lấy hóa đơn) được bổ sung bởi Nghị định 70/2025/NĐ-CP, Điều 1, khoản 3, điểm a (sửa đổi khoản 6 Điều 4 Nghị định 123/2020/NĐ-CP) — không có trường nào của định dạng này diễn tả một chương trình khuyến khích của Nhà nước, đây không phải một khoảng cách của một hóa đơn cụ thể mà của toàn bộ pack, ghi trong README.',
  einvoice_source_key           = 'einvoice-nd70',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'VN';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('VN', 'export', 'export', 'Hàng hóa/dịch vụ xuất khẩu áp dụng thuế suất 0% (Điều 9, khoản 1, Luật Thuế giá trị gia tăng số 48/2024/QH15).', '{}'::jsonb, 10, date '1970-01-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 9, khoản 1 và khoản 6 — thuế suất 0% áp dụng cho hàng hóa, dịch vụ xuất khẩu, với điều kiện có hợp đồng, chứng từ thanh toán không dùng tiền mặt và, với hàng hóa, tờ khai hải quan.'),
  ('VN', 'exempt', 'exempt', 'Đối tượng không chịu thuế giá trị gia tăng (Điều 5, Luật Thuế giá trị gia tăng số 48/2024/QH15).', '{}'::jsonb, 20, date '1970-01-01', null, 'Luật Thuế giá trị gia tăng số 48/2024/QH15, Điều 5 — hai mươi tám nhóm hàng hóa, dịch vụ không chịu thuế giá trị gia tăng; khoản 27 — không được khấu trừ, hoàn thuế giá trị gia tăng đầu vào đối với hàng hóa, dịch vụ này, trừ trường hợp áp dụng thuế suất 0% quy định tại khoản 1 Điều 9.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
