-- Ekwo OS — Indonesia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/id at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build id`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Undang-Undang Nomor 42 Tahun 2009 tentang Perubahan Ketiga atas Undang-Undang Nomor 8 Tahun 1983 tentang Pajak Pertambahan Nilai Barang dan Jasa dan Pajak Penjualan atas Barang Mewah (Badan Pemeriksa Keuangan Republik Indonesia — JDIH BPK)
--     https://peraturan.bpk.go.id/Details/38787/uu-no-42-tahun-2009
--   Undang-Undang Nomor 7 Tahun 2021 tentang Harmonisasi Peraturan Perpajakan, Bab IV — Pajak Pertambahan Nilai, mengubah Undang-Undang Nomor 8 Tahun 1983 (Pasal 7, 9, 4A, 16B dan lain-lain) (Sekretariat Negara — JDIH BPK)
--     https://peraturan.bpk.go.id/Download/178620/UU%20Nomor%207%20Tahun%202021.pdf
--   Undang-Undang Nomor 6 Tahun 1983 tentang Ketentuan Umum dan Tata Cara Perpajakan, sebagaimana diubah terakhir dengan Undang-Undang Nomor 7 Tahun 2021, Pasal 3 ayat (3) huruf b — batas waktu penyampaian Surat Pemberitahuan Masa (Badan Pemeriksa Keuangan Republik Indonesia — JDIH BPK)
--     https://peraturan.bpk.go.id/Details/46986/uu-no-6-tahun-1983
--   Peraturan Menteri Keuangan Nomor 131 Tahun 2024 tentang Perlakuan Pajak Pertambahan Nilai atas Impor Barang Kena Pajak, Penyerahan Barang Kena Pajak, Penyerahan Jasa Kena Pajak, Pemanfaatan Barang Kena Pajak Tidak Berwujud dari Luar Daerah Pabean di Dalam Daerah Pabean, dan Pemanfaatan Jasa Kena Pajak dari Luar Daerah Pabean di Dalam Daerah Pabean (Kementerian Keuangan — JDIH Kemenkeu)
--     https://jdih.kemenkeu.go.id/api/download/ad276b82-94bd-4197-b409-af33e2842cd6/2024pmkeuangan131.pdf
--   Peraturan Pemerintah Nomor 49 Tahun 2022 tentang Pajak Pertambahan Nilai Dibebaskan dan Pajak Pertambahan Nilai atau Pajak Pertambahan Nilai dan Pajak Penjualan atas Barang Mewah Tidak Dipungut atas Impor dan/atau Penyerahan Barang Kena Pajak Tertentu dan/atau Penyerahan Jasa Kena Pajak Tertentu dan/atau Pemanfaatan Jasa Kena Pajak Tertentu dari Luar Daerah Pabean (Sekretariat Negara — JDIH BPK)
--     https://peraturan.bpk.go.id/Download/280043/PP%20Nomor%2049%20Tahun%202022.pdf
--   Peraturan Menteri Keuangan Nomor 197/PMK.03/2013 tentang Perubahan atas Peraturan Menteri Keuangan Nomor 68/PMK.03/2010 tentang Batasan Pengusaha Kecil Pajak Pertambahan Nilai (Kementerian Keuangan — JDIH BPK)
--     https://peraturan.bpk.go.id/Details/150339/pmk-no-197pmk032013
--   Peraturan Menteri Keuangan Nomor 81 Tahun 2024 tentang Ketentuan Perpajakan dalam Rangka Pelaksanaan Sistem Inti Administrasi Perpajakan (Coretax) (Kementerian Keuangan — JDIH Nasional)
--     https://www.jdihn.go.id/api/download/637047be-3dba-4347-aba1-98fa7fd5ab3f/2024pmkeuangan081.pdf
--   Peraturan Direktur Jenderal Pajak Nomor PER-11/PJ/2025 tentang Ketentuan Pelaporan Pajak Penghasilan, Pajak Pertambahan Nilai, Pajak Penjualan atas Barang Mewah, dan Bea Meterai dalam Rangka Pelaksanaan Sistem Inti Administrasi Perpajakan — Pasal 44, batas unggah Faktur Pajak (Direktorat Jenderal Pajak)
--     https://www.pajak.go.id/sites/default/files/lampiran/PER-11_PJ_2025_0.pdf
--   Formulir 1111 — Surat Pemberitahuan Masa Pajak Pertambahan Nilai (SPT Masa PPN), lampiran Peraturan Direktur Jenderal Pajak Nomor PER-29/PJ/2015 (Direktorat Jenderal Pajak)
--     https://www.pajak.go.id/en/node/10244
--   Coretax DJP — sistem inti administrasi perpajakan: pembuatan Faktur Pajak elektronik dan pelaporan SPT Masa PPN (Direktorat Jenderal Pajak)
--     https://coretaxdjp.pajak.go.id/
--   Kerangka Standar Pelaporan Keuangan Indonesia dan PSAK 201 (dahulu PSAK 1) — Penyajian Laporan Keuangan; SAK EMKM — Standar Akuntansi Keuangan Entitas Mikro, Kecil, dan Menengah (Dewan Standar Akuntansi Keuangan — Ikatan Akuntan Indonesia)
--     https://web.iaiglobal.or.id/SAK-IAI
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('ID', 'Indonesia', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '93e456544f20663bf45d4694161a9e474b52ec554a6fb6e6c6d2540eaa781fa0', '[{"key":"vat-law-42-2009","title":"Undang-Undang Nomor 42 Tahun 2009 tentang Perubahan Ketiga atas Undang-Undang Nomor 8 Tahun 1983 tentang Pajak Pertambahan Nilai Barang dan Jasa dan Pajak Penjualan atas Barang Mewah","publisher":"Badan Pemeriksa Keuangan Republik Indonesia — JDIH BPK","url":"https://peraturan.bpk.go.id/Details/38787/uu-no-42-tahun-2009","consulted_on":"2026-09-25","kind":"law"},{"key":"vat-law-hpp-7-2021","title":"Undang-Undang Nomor 7 Tahun 2021 tentang Harmonisasi Peraturan Perpajakan, Bab IV — Pajak Pertambahan Nilai, mengubah Undang-Undang Nomor 8 Tahun 1983 (Pasal 7, 9, 4A, 16B dan lain-lain)","publisher":"Sekretariat Negara — JDIH BPK","url":"https://peraturan.bpk.go.id/Download/178620/UU%20Nomor%207%20Tahun%202021.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"kup-law-6-1983","title":"Undang-Undang Nomor 6 Tahun 1983 tentang Ketentuan Umum dan Tata Cara Perpajakan, sebagaimana diubah terakhir dengan Undang-Undang Nomor 7 Tahun 2021, Pasal 3 ayat (3) huruf b — batas waktu penyampaian Surat Pemberitahuan Masa","publisher":"Badan Pemeriksa Keuangan Republik Indonesia — JDIH BPK","url":"https://peraturan.bpk.go.id/Details/46986/uu-no-6-tahun-1983","consulted_on":"2026-09-25","kind":"law"},{"key":"pmk-131-2024","title":"Peraturan Menteri Keuangan Nomor 131 Tahun 2024 tentang Perlakuan Pajak Pertambahan Nilai atas Impor Barang Kena Pajak, Penyerahan Barang Kena Pajak, Penyerahan Jasa Kena Pajak, Pemanfaatan Barang Kena Pajak Tidak Berwujud dari Luar Daerah Pabean di Dalam Daerah Pabean, dan Pemanfaatan Jasa Kena Pajak dari Luar Daerah Pabean di Dalam Daerah Pabean","publisher":"Kementerian Keuangan — JDIH Kemenkeu","url":"https://jdih.kemenkeu.go.id/api/download/ad276b82-94bd-4197-b409-af33e2842cd6/2024pmkeuangan131.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"pp-49-2022","title":"Peraturan Pemerintah Nomor 49 Tahun 2022 tentang Pajak Pertambahan Nilai Dibebaskan dan Pajak Pertambahan Nilai atau Pajak Pertambahan Nilai dan Pajak Penjualan atas Barang Mewah Tidak Dipungut atas Impor dan/atau Penyerahan Barang Kena Pajak Tertentu dan/atau Penyerahan Jasa Kena Pajak Tertentu dan/atau Pemanfaatan Jasa Kena Pajak Tertentu dari Luar Daerah Pabean","publisher":"Sekretariat Negara — JDIH BPK","url":"https://peraturan.bpk.go.id/Download/280043/PP%20Nomor%2049%20Tahun%202022.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"pmk-197-2013","title":"Peraturan Menteri Keuangan Nomor 197/PMK.03/2013 tentang Perubahan atas Peraturan Menteri Keuangan Nomor 68/PMK.03/2010 tentang Batasan Pengusaha Kecil Pajak Pertambahan Nilai","publisher":"Kementerian Keuangan — JDIH BPK","url":"https://peraturan.bpk.go.id/Details/150339/pmk-no-197pmk032013","consulted_on":"2026-09-25","kind":"regulation"},{"key":"pmk-81-2024-coretax","title":"Peraturan Menteri Keuangan Nomor 81 Tahun 2024 tentang Ketentuan Perpajakan dalam Rangka Pelaksanaan Sistem Inti Administrasi Perpajakan (Coretax)","publisher":"Kementerian Keuangan — JDIH Nasional","url":"https://www.jdihn.go.id/api/download/637047be-3dba-4347-aba1-98fa7fd5ab3f/2024pmkeuangan081.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"per-11-2025-efaktur","title":"Peraturan Direktur Jenderal Pajak Nomor PER-11/PJ/2025 tentang Ketentuan Pelaporan Pajak Penghasilan, Pajak Pertambahan Nilai, Pajak Penjualan atas Barang Mewah, dan Bea Meterai dalam Rangka Pelaksanaan Sistem Inti Administrasi Perpajakan — Pasal 44, batas unggah Faktur Pajak","publisher":"Direktorat Jenderal Pajak","url":"https://www.pajak.go.id/sites/default/files/lampiran/PER-11_PJ_2025_0.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"vat-return-form-1111","title":"Formulir 1111 — Surat Pemberitahuan Masa Pajak Pertambahan Nilai (SPT Masa PPN), lampiran Peraturan Direktur Jenderal Pajak Nomor PER-29/PJ/2015","publisher":"Direktorat Jenderal Pajak","url":"https://www.pajak.go.id/en/node/10244","consulted_on":"2026-09-25","kind":"form"},{"key":"coretax-portal","title":"Coretax DJP — sistem inti administrasi perpajakan: pembuatan Faktur Pajak elektronik dan pelaporan SPT Masa PPN","publisher":"Direktorat Jenderal Pajak","url":"https://coretaxdjp.pajak.go.id/","consulted_on":"2026-09-25","kind":"portal"},{"key":"sak-iai","title":"Kerangka Standar Pelaporan Keuangan Indonesia dan PSAK 201 (dahulu PSAK 1) — Penyajian Laporan Keuangan; SAK EMKM — Standar Akuntansi Keuangan Entitas Mikro, Kecil, dan Menengah","publisher":"Dewan Standar Akuntansi Keuangan — Ikatan Akuntan Indonesia","url":"https://web.iaiglobal.or.id/SAK-IAI","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('ID', 'default', 'Bagan akun umum Indonesia', '{}'::jsonb, true, 'companies', array['ID-LK-BS', 'ID-LK-LR']::text[], null, 'Indonesia tidak mewajibkan satu bagan akun tunggal oleh undang-undang: Undang-Undang Nomor 40 Tahun 2007 tentang Perseroan Terbatas dan Undang-Undang Nomor 8 Tahun 1997 tentang Dokumen Perusahaan mewajibkan pembukuan dan penyimpanan dokumen, dan Kerangka Standar Pelaporan Keuangan Indonesia serta PSAK 201 (dahulu PSAK 1, disahkan oleh Dewan Standar Akuntansi Keuangan — Ikatan Akuntan Indonesia) menetapkan struktur dan isi minimal laporan keuangan, tidak pernah kode akun bernomor. Bagan akun ini karena itu original, empat digit per kelas (1 aset, 2 liabilitas, 3 ekuitas, 4 pendapatan, 5 beban pokok penjualan, 6 beban usaha, 7 pendapatan/beban lain-lain, 8 beban pajak penghasilan), mengikuti semangat yang sama dengan packs/th dan packs/sg untuk negara Asia Tenggara tanpa bagan akun yang diwajibkan undang-undang — lihat README.', 'sak-iai')
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
  ('ID', 'default', '1000', 'Kas dan bank', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('ID', 'default', '1010', 'Kas kecil', '{}'::jsonb, 'asset_cash', false, '1000', 11),
  ('ID', 'default', '1011', 'Kas besar', '{}'::jsonb, 'asset_cash', false, '1000', 12),
  ('ID', 'default', '1020', 'Bank', '{}'::jsonb, 'asset_cash', false, '1000', 13),
  ('ID', 'default', '1021', 'Bank Rupiah', '{}'::jsonb, 'asset_cash', false, '1020', 14),
  ('ID', 'default', '1022', 'Bank valuta asing', '{}'::jsonb, 'asset_cash', false, '1020', 15),
  ('ID', 'default', '1100', 'Piutang usaha - pihak ketiga', '{}'::jsonb, 'asset_receivable', true, null, 20),
  ('ID', 'default', '1105', 'Piutang usaha - pihak berelasi', '{}'::jsonb, 'asset_receivable', true, null, 21),
  ('ID', 'default', '1110', 'Piutang karyawan', '{}'::jsonb, 'asset_current', false, null, 22),
  ('ID', 'default', '1120', 'Piutang lain-lain', '{}'::jsonb, 'asset_current', false, null, 23),
  ('ID', 'default', '1130', 'Penyisihan kerugian piutang', '{}'::jsonb, 'asset_current', false, null, 24),
  ('ID', 'default', '1150', 'Pajak Pertambahan Nilai Masukan', '{}'::jsonb, 'asset_current', true, null, 30),
  ('ID', 'default', '1151', 'PPN Masukan - perolehan dalam negeri', '{}'::jsonb, 'asset_current', false, '1150', 31),
  ('ID', 'default', '1152', 'PPN Masukan - impor dan pemanfaatan dari luar Daerah Pabean', '{}'::jsonb, 'asset_current', false, '1150', 32),
  ('ID', 'default', '1160', 'Pajak Penghasilan dibayar dimuka', '{}'::jsonb, 'asset_current', false, null, 33),
  ('ID', 'default', '1161', 'PPh Pasal 22 dibayar dimuka', '{}'::jsonb, 'asset_current', false, '1160', 34),
  ('ID', 'default', '1162', 'PPh Pasal 23 dibayar dimuka', '{}'::jsonb, 'asset_current', false, '1160', 35),
  ('ID', 'default', '1163', 'PPh Pasal 25 dibayar dimuka', '{}'::jsonb, 'asset_current', false, '1160', 36),
  ('ID', 'default', '1200', 'Persediaan barang dagangan', '{}'::jsonb, 'asset_current', false, null, 40),
  ('ID', 'default', '1210', 'Persediaan bahan baku', '{}'::jsonb, 'asset_current', false, null, 41),
  ('ID', 'default', '1220', 'Persediaan barang dalam proses', '{}'::jsonb, 'asset_current', false, null, 42),
  ('ID', 'default', '1230', 'Persediaan barang jadi', '{}'::jsonb, 'asset_current', false, null, 43),
  ('ID', 'default', '1240', 'Persediaan perlengkapan', '{}'::jsonb, 'asset_current', false, null, 44),
  ('ID', 'default', '1250', 'Uang muka pembelian', '{}'::jsonb, 'asset_current', false, null, 50),
  ('ID', 'default', '1260', 'Biaya dibayar dimuka', '{}'::jsonb, 'asset_prepayments', false, null, 51),
  ('ID', 'default', '1261', 'Sewa dibayar dimuka', '{}'::jsonb, 'asset_prepayments', false, '1260', 52),
  ('ID', 'default', '1262', 'Asuransi dibayar dimuka', '{}'::jsonb, 'asset_prepayments', false, '1260', 53),
  ('ID', 'default', '1270', 'Aset lancar lainnya', '{}'::jsonb, 'asset_current', false, null, 54),
  ('ID', 'default', '1300', 'Tanah', '{}'::jsonb, 'asset_fixed', false, null, 70),
  ('ID', 'default', '1310', 'Bangunan', '{}'::jsonb, 'asset_fixed', false, null, 71),
  ('ID', 'default', '1311', 'Akumulasi penyusutan bangunan', '{}'::jsonb, 'asset_fixed', false, null, 72),
  ('ID', 'default', '1320', 'Mesin dan peralatan', '{}'::jsonb, 'asset_fixed', false, null, 73),
  ('ID', 'default', '1321', 'Akumulasi penyusutan mesin dan peralatan', '{}'::jsonb, 'asset_fixed', false, null, 74),
  ('ID', 'default', '1330', 'Kendaraan', '{}'::jsonb, 'asset_fixed', false, null, 75),
  ('ID', 'default', '1331', 'Akumulasi penyusutan kendaraan', '{}'::jsonb, 'asset_fixed', false, null, 76),
  ('ID', 'default', '1340', 'Peralatan kantor', '{}'::jsonb, 'asset_fixed', false, null, 77),
  ('ID', 'default', '1341', 'Akumulasi penyusutan peralatan kantor', '{}'::jsonb, 'asset_fixed', false, null, 78),
  ('ID', 'default', '1350', 'Perabot dan perlengkapan', '{}'::jsonb, 'asset_fixed', false, null, 79),
  ('ID', 'default', '1351', 'Akumulasi penyusutan perabot dan perlengkapan', '{}'::jsonb, 'asset_fixed', false, null, 80),
  ('ID', 'default', '1400', 'Aset tak berwujud', '{}'::jsonb, 'asset_non_current', false, null, 90),
  ('ID', 'default', '1410', 'Piutang jangka panjang', '{}'::jsonb, 'asset_non_current', false, null, 91),
  ('ID', 'default', '1420', 'Investasi jangka panjang', '{}'::jsonb, 'asset_non_current', false, null, 92),
  ('ID', 'default', '1430', 'Uang jaminan', '{}'::jsonb, 'asset_non_current', false, null, 93),
  ('ID', 'default', '1490', 'Aset tidak lancar lainnya', '{}'::jsonb, 'asset_non_current', false, null, 94),
  ('ID', 'default', '2000', 'Utang usaha - pihak ketiga', '{}'::jsonb, 'liability_payable', true, null, 100),
  ('ID', 'default', '2005', 'Utang usaha - pihak berelasi', '{}'::jsonb, 'liability_payable', true, null, 101),
  ('ID', 'default', '2100', 'Utang Pajak Pertambahan Nilai', '{}'::jsonb, 'liability_current', false, null, 110),
  ('ID', 'default', '2110', 'PPN Keluaran - akun penyelesaian SPT Masa PPN', '{}'::jsonb, 'liability_current', true, '2100', 111),
  ('ID', 'default', '2111', 'PPN Keluaran - dipungut sendiri', '{}'::jsonb, 'liability_current', false, '2110', 112),
  ('ID', 'default', '2112', 'PPN yang harus dipungut sendiri atas impor dan pemanfaatan dari luar Daerah Pabean', '{}'::jsonb, 'liability_current', false, '2110', 113),
  ('ID', 'default', '2150', 'Utang Pajak Penghasilan', '{}'::jsonb, 'liability_current', false, null, 120),
  ('ID', 'default', '2151', 'Utang PPh Pasal 21', '{}'::jsonb, 'liability_current', false, '2150', 121),
  ('ID', 'default', '2152', 'Utang PPh Pasal 23', '{}'::jsonb, 'liability_current', false, '2150', 122),
  ('ID', 'default', '2153', 'Utang PPh Pasal 25/29', '{}'::jsonb, 'liability_current', false, '2150', 123),
  ('ID', 'default', '2154', 'Utang PPh Pasal 4 ayat (2)', '{}'::jsonb, 'liability_current', false, '2150', 124),
  ('ID', 'default', '2200', 'Uang muka penjualan', '{}'::jsonb, 'liability_current', false, null, 130),
  ('ID', 'default', '2250', 'Utang gaji dan upah', '{}'::jsonb, 'liability_current', false, null, 140),
  ('ID', 'default', '2260', 'Utang BPJS Ketenagakerjaan dan Kesehatan', '{}'::jsonb, 'liability_current', false, null, 141),
  ('ID', 'default', '2300', 'Biaya masih harus dibayar', '{}'::jsonb, 'liability_current', false, null, 150),
  ('ID', 'default', '2310', 'Bunga masih harus dibayar', '{}'::jsonb, 'liability_current', false, '2300', 151),
  ('ID', 'default', '2320', 'Utang lain-lain', '{}'::jsonb, 'liability_current', false, '2300', 152),
  ('ID', 'default', '2400', 'Akun antara', '{}'::jsonb, 'liability_current', false, null, 160),
  ('ID', 'default', '2500', 'Utang bank jangka pendek', '{}'::jsonb, 'liability_current', false, null, 170),
  ('ID', 'default', '2900', 'Utang bank jangka panjang', '{}'::jsonb, 'liability_non_current', false, null, 200),
  ('ID', 'default', '2910', 'Liabilitas imbalan kerja', '{}'::jsonb, 'liability_non_current', false, null, 201),
  ('ID', 'default', '2990', 'Liabilitas jangka panjang lainnya', '{}'::jsonb, 'liability_non_current', false, null, 202),
  ('ID', 'default', '3000', 'Modal disetor', '{}'::jsonb, 'equity', false, null, 210),
  ('ID', 'default', '3010', 'Tambahan modal disetor', '{}'::jsonb, 'equity', false, null, 211),
  ('ID', 'default', '3200', 'Saldo laba (rugi)', '{}'::jsonb, 'equity_retained', false, null, 212),
  ('ID', 'default', '3300', 'Laba (rugi) tahun berjalan', '{}'::jsonb, 'equity', false, null, 213),
  ('ID', 'default', '4000', 'Penjualan dalam negeri', '{}'::jsonb, 'income', false, null, 300),
  ('ID', 'default', '4010', 'Penjualan ekspor', '{}'::jsonb, 'income', false, null, 301),
  ('ID', 'default', '4020', 'Pendapatan jasa', '{}'::jsonb, 'income', false, null, 302),
  ('ID', 'default', '4100', 'Retur dan potongan penjualan', '{}'::jsonb, 'income', false, null, 310),
  ('ID', 'default', '4110', 'Potongan tunai penjualan', '{}'::jsonb, 'income', false, null, 311),
  ('ID', 'default', '5000', 'Beban pokok penjualan', '{}'::jsonb, 'expense_direct_cost', false, null, 400),
  ('ID', 'default', '5010', 'Biaya angkut pembelian', '{}'::jsonb, 'expense_direct_cost', false, null, 401),
  ('ID', 'default', '5020', 'Retur dan potongan pembelian', '{}'::jsonb, 'expense_direct_cost', false, null, 402),
  ('ID', 'default', '5090', 'Selisih persediaan', '{}'::jsonb, 'expense_direct_cost', false, null, 403),
  ('ID', 'default', '6000', 'Beban penjualan', '{}'::jsonb, 'expense', false, null, 500),
  ('ID', 'default', '6010', 'Beban iklan dan promosi', '{}'::jsonb, 'expense', false, '6000', 501),
  ('ID', 'default', '6020', 'Beban pengiriman', '{}'::jsonb, 'expense', false, '6000', 502),
  ('ID', 'default', '6030', 'Beban komisi penjualan', '{}'::jsonb, 'expense', false, '6000', 503),
  ('ID', 'default', '6100', 'Beban administrasi dan umum', '{}'::jsonb, 'expense', false, null, 510),
  ('ID', 'default', '6110', 'Beban gaji dan tunjangan', '{}'::jsonb, 'expense', false, '6100', 511),
  ('ID', 'default', '6120', 'Beban BPJS Ketenagakerjaan dan Kesehatan', '{}'::jsonb, 'expense', false, '6100', 512),
  ('ID', 'default', '6130', 'Beban sewa kantor', '{}'::jsonb, 'expense', false, '6100', 513),
  ('ID', 'default', '6140', 'Beban listrik air dan telepon', '{}'::jsonb, 'expense', false, '6100', 514),
  ('ID', 'default', '6150', 'Beban alat tulis kantor', '{}'::jsonb, 'expense', false, '6100', 515),
  ('ID', 'default', '6160', 'Beban perjalanan dinas', '{}'::jsonb, 'expense', false, '6100', 516),
  ('ID', 'default', '6170', 'Beban pemeliharaan dan perbaikan', '{}'::jsonb, 'expense', false, '6100', 517),
  ('ID', 'default', '6180', 'Beban asuransi', '{}'::jsonb, 'expense', false, '6100', 518),
  ('ID', 'default', '6190', 'Beban jasa profesional', '{}'::jsonb, 'expense', false, '6100', 519),
  ('ID', 'default', '6200', 'Beban penyusutan', '{}'::jsonb, 'expense_depreciation', false, null, 520),
  ('ID', 'default', '6210', 'Beban penyusutan bangunan', '{}'::jsonb, 'expense_depreciation', false, '6200', 521),
  ('ID', 'default', '6220', 'Beban penyusutan mesin dan peralatan', '{}'::jsonb, 'expense_depreciation', false, '6200', 522),
  ('ID', 'default', '6230', 'Beban penyusutan kendaraan', '{}'::jsonb, 'expense_depreciation', false, '6200', 523),
  ('ID', 'default', '6240', 'Beban penyusutan peralatan kantor', '{}'::jsonb, 'expense_depreciation', false, '6200', 524),
  ('ID', 'default', '6250', 'Beban penyusutan perabot dan perlengkapan', '{}'::jsonb, 'expense_depreciation', false, '6200', 525),
  ('ID', 'default', '6300', 'Beban umum lainnya', '{}'::jsonb, 'expense', false, null, 530),
  ('ID', 'default', '7000', 'Pendapatan lain-lain', '{}'::jsonb, 'income_other', false, null, 600),
  ('ID', 'default', '7010', 'Pendapatan bunga', '{}'::jsonb, 'income_other', false, '7000', 601),
  ('ID', 'default', '7020', 'Keuntungan selisih kurs', '{}'::jsonb, 'income_other', false, '7000', 602),
  ('ID', 'default', '7030', 'Keuntungan pelepasan aset tetap', '{}'::jsonb, 'income_other', false, '7000', 603),
  ('ID', 'default', '7040', 'Pendapatan sewa', '{}'::jsonb, 'income_other', false, '7000', 604),
  ('ID', 'default', '7050', 'Pendapatan lain-lain sundry', '{}'::jsonb, 'income_other', false, '7000', 605),
  ('ID', 'default', '7500', 'Beban lain-lain', '{}'::jsonb, 'expense', false, null, 700),
  ('ID', 'default', '7510', 'Beban bunga', '{}'::jsonb, 'expense', false, '7500', 701),
  ('ID', 'default', '7520', 'Kerugian selisih kurs', '{}'::jsonb, 'expense', false, '7500', 702),
  ('ID', 'default', '7530', 'Kerugian pelepasan aset tetap', '{}'::jsonb, 'expense', false, '7500', 703),
  ('ID', 'default', '7540', 'Selisih pembulatan', '{}'::jsonb, 'expense', false, '7500', 704),
  ('ID', 'default', '7550', 'Beban administrasi bank', '{}'::jsonb, 'expense', false, '7500', 705),
  ('ID', 'default', '7560', 'Beban lain-lain sundry', '{}'::jsonb, 'expense', false, '7500', 706),
  ('ID', 'default', '8000', 'Beban pajak penghasilan', '{}'::jsonb, 'expense', false, null, 800),
  ('ID', 'default', '8010', 'Beban pajak penghasilan kini', '{}'::jsonb, 'expense', false, '8000', 801),
  ('ID', 'default', '8020', 'Beban (manfaat) pajak penghasilan tangguhan', '{}'::jsonb, 'expense', false, '8000', 802)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('ID', 'BNK', 'Jurnal bank', '{}'::jsonb, 'bank', 30),
  ('ID', 'CSH', 'Jurnal kas kecil', '{}'::jsonb, 'cash', 40),
  ('ID', 'GEN', 'Jurnal umum', '{}'::jsonb, 'general', 50),
  ('ID', 'OPN', 'Saldo awal', '{}'::jsonb, 'opening', 60),
  ('ID', 'PUR', 'Jurnal pembelian', '{}'::jsonb, 'purchase', 20),
  ('ID', 'SAL', 'Jurnal penjualan', '{}'::jsonb, 'sales', 10)
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
  ('ID', 'ID-P-11', 'Pembelian - PPN 11% (tarif efektif), dapat dikreditkan', '{}'::jsonb, 'Pajak Pertambahan Nilai masukan atas perolehan Barang Kena Pajak/Jasa Kena Pajak dalam negeri', 'percent', 11, 'purchase', 'domestic', date '2025-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 9 — Pajak Masukan dalam suatu Masa Pajak dikreditkan dengan Pajak Keluaran dalam Masa Pajak yang sama, sepanjang memenuhi syarat Faktur Pajak yang sah (Pasal 9 ayat (2) dan (8)); tarif efektif 11% mengikuti mekanisme nilai lain Peraturan Menteri Keuangan Nomor 131 Tahun 2024 yang sama dengan sisi penjualan (lihat ID-S-11).', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pmk-131-2024', null, null, null, null),
  ('ID', 'ID-P-IMP-11', 'Impor - PPN 11% (tarif efektif), dibayar sendiri kepada Bea Cukai', '{}'::jsonb, 'Pajak Pertambahan Nilai atas impor Barang Kena Pajak, dibayar pada saat impor dan dikreditkan sebagai Pajak Masukan', 'percent', 11, 'purchase', 'import', date '2025-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 7 ayat (1) dan Pasal 9, jo. Peraturan Menteri Keuangan Nomor 131 Tahun 2024 (yang secara eksplisit turut mengatur impor Barang Kena Pajak) — Pajak Pertambahan Nilai atas impor dipungut dan disetor oleh importir pada saat impor melalui dokumen kepabeanan, dengan tarif efektif 11% dari mekanisme nilai lain yang sama dengan penyerahan dalam negeri, dan dapat dikreditkan sebagai Pajak Masukan. Pack ini menghitung pajak atas nilai faktur pemasok luar negeri, bukan nilai pabean (yang menambahkan bea masuk dan pungutan impor lain) — perbedaan yang harus diperiksa oleh akuntan di Indonesia.', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pmk-131-2024', null, null, null, null),
  ('ID', 'ID-P-RC', 'Pemanfaatan JKP/BKP tidak berwujud dari luar Daerah Pabean - dipungut sendiri', '{}'::jsonb, 'Pajak Pertambahan Nilai atas pemanfaatan Jasa Kena Pajak dan/atau Barang Kena Pajak Tidak Berwujud dari luar Daerah Pabean, dipungut, disetor, dan dilaporkan sendiri oleh pihak yang memanfaatkan, dan dikreditkan pada Masa Pajak yang sama', 'percent', 11, 'purchase', 'foreign_services_received', date '2025-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 3A ayat (3) — orang pribadi atau badan yang memanfaatkan Barang Kena Pajak Tidak Berwujud dan/atau Jasa Kena Pajak dari luar Daerah Pabean di dalam Daerah Pabean wajib memungut, menyetor, dan melaporkan sendiri Pajak Pertambahan Nilai yang terutang, dengan tarif efektif mengikuti Peraturan Menteri Keuangan Nomor 131 Tahun 2024. Pajak Masukan atas pemanfaatan ini dapat dikreditkan sepanjang tidak termasuk dalam Pajak Masukan yang tidak dapat dikreditkan (Pasal 9 ayat (8)). Pack ini membukukan pemungutan sendiri dan pengkreditannya pada satu dokumen yang sama, yang melebih-lebihkan kecepatan tersedianya kredit dibanding praktik administratif sesungguhnya — kesenjangan yang dicatat dalam docs/international.md, mengikuti pendekatan yang sama dengan packs/th (TH-P-RC).', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'vat-law-42-2009', null, null, null, null),
  ('ID', 'ID-S-0-EXP', 'Penjualan - ekspor, tarif 0%', '{}'::jsonb, 'Ekspor Barang Kena Pajak Berwujud, Barang Kena Pajak Tidak Berwujud, atau Jasa Kena Pajak', 'percent', 0, 'sale', 'export', date '2022-04-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 7 ayat (2) sebagaimana diubah dengan Undang-Undang Nomor 7 Tahun 2021 — Pajak Pertambahan Nilai dengan tarif 0% (nol persen) diterapkan atas ekspor Barang Kena Pajak Berwujud, ekspor Barang Kena Pajak Tidak Berwujud, dan ekspor Jasa Kena Pajak; Pasal 9 ayat (4) memungkinkan pengkreditan Pajak Masukan atas penyerahan ini. `conditions: transport_evidence` mencatat bahwa hak atas tarif 0% bergantung pada dokumen yang membuktikan barang/jasa benar keluar dari Daerah Pabean (kontrak, bukti pembayaran, dan untuk barang, Pemberitahuan Ekspor Barang), yang tidak dibuktikan sendiri oleh pembukuan.', null, null, 30, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'vat-law-hpp-7-2021', null, null, null, null),
  ('ID', 'ID-S-11', 'Penjualan - PPN 11% (tarif efektif)', '{}'::jsonb, 'Pajak Pertambahan Nilai keluaran atas penyerahan dalam negeri, selain barang mewah tertentu', 'percent', 11, 'sale', 'domestic', date '2025-01-01', null, 'Peraturan Menteri Keuangan Nomor 131 Tahun 2024, Pasal 2 dan Pasal 3 — atas penyerahan Barang Kena Pajak dan/atau Jasa Kena Pajak selain barang mewah tertentu, Pajak Pertambahan Nilai dihitung dengan cara mengalikan tarif 12% (Undang-Undang Nomor 42 Tahun 2009, Pasal 7 ayat (1) sebagaimana diubah dengan Undang-Undang Nomor 7 Tahun 2021) dengan Dasar Pengenaan Pajak berupa nilai lain sebesar 11/12 dari harga jual atau penggantian (Undang-Undang Nomor 42 Tahun 2009, Pasal 8A ayat (1) jo. Pasal 16G). Hasilnya setara tarif efektif 11%: 12% x (11/12 x harga jual) = 11% x harga jual. Pack ini memodelkan langsung tarif efektif 11% atas harga jual, karena format Ekwo tidak memiliki mekanisme perkalian dua tahap (tarif nominal x pecahan nilai lain) — kode tarif ini menghasilkan angka yang sama dengan mekanisme resmi, tetapi tidak mereproduksi langkah nilai lain itu sendiri pada dokumen, yang dicatat sebagai kesenjangan dalam docs/international.md.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'pmk-131-2024', null, null, null, null),
  ('ID', 'ID-S-12-LUX', 'Penjualan - PPN 12% (barang mewah tertentu)', '{}'::jsonb, 'Pajak Pertambahan Nilai keluaran atas penyerahan barang mewah tertentu kepada konsumen akhir, tanpa mekanisme nilai lain', 'percent', 12, 'sale', 'domestic', date '2025-02-01', null, 'Peraturan Menteri Keuangan Nomor 131 Tahun 2024, Pasal 5 — atas penyerahan barang mewah tertentu (yang tergolong sangat mewah dan dikenai Pajak Penjualan atas Barang Mewah, antara lain kendaraan bermotor tertentu, hunian mewah, kapal pesiar, dan pesawat udara pribadi tertentu) kepada konsumen akhir, Pajak Pertambahan Nilai dihitung dengan tarif 12% dikalikan Dasar Pengenaan Pajak berupa nilai lain sebesar 100% dari harga jual, sehingga tarif efektifnya tetap 12%; berlaku sejak 1 Februari 2025. `conditions: supply_nature` mencatat bahwa apakah suatu barang termasuk daftar barang mewah tertentu ini adalah pertanyaan tentang sifat barang yang tidak dijawab sendiri oleh pembukuan. Daftar rinci barang yang termasuk kategori ini tidak ditelusuri baris demi baris pada sesi ini — lihat README.', null, null, 20, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'pmk-131-2024', null, null, null, null),
  ('ID', 'ID-S-EXEMPT', 'Penjualan - dibebaskan dari pengenaan PPN', '{}'::jsonb, 'Barang Kena Pajak tertentu dan/atau Jasa Kena Pajak tertentu yang dibebaskan dari pengenaan Pajak Pertambahan Nilai', 'percent', 0, 'sale', 'exempt', date '2022-12-12', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 16B, dan Peraturan Pemerintah Nomor 49 Tahun 2022 — fasilitas Pajak Pertambahan Nilai dibebaskan atas penyerahan barang kebutuhan pokok tertentu (antara lain beras, jagung, kedelai, garam konsumsi, daging, telur, susu, buah-buahan dan sayur-sayuran) serta jasa tertentu (antara lain jasa pelayanan kesehatan medis, jasa pendidikan, dan jasa keuangan dan asuransi tertentu). Pajak Masukan atas penyerahan yang dibebaskan ini tidak dapat dikreditkan (Undang-Undang Nomor 42 Tahun 2009, Pasal 16B ayat (3)). `conditions: supply_nature` mencatat bahwa apakah suatu barang/jasa termasuk daftar ini adalah pertanyaan tentang sifatnya. Tanggal `valid_from` adalah tanggal pengundangan Peraturan Pemerintah Nomor 49 Tahun 2022; tanggal mulai berlaku efektif untuk setiap kategori barang/jasa tidak ditelusuri secara terperinci pada sesi ini — lihat README.', null, null, 40, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'pp-49-2022', null, null, null, null)
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
    ('ID-P-11', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ID-P-11', 'invoice', 'tax', 100, '1151', '5', array['5']::text[], 100, 'ID-SPT-MASA-PPN', 20),
    ('ID-P-11', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ID-P-11', 'credit_note', 'tax', 100, '1151', '5', array['5']::text[], -100, 'ID-SPT-MASA-PPN', 20),
    ('ID-P-IMP-11', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ID-P-IMP-11', 'invoice', 'tax', 100, '1152', '5', array['5']::text[], 100, 'ID-SPT-MASA-PPN', 20),
    ('ID-P-IMP-11', 'invoice', 'tax', -100, '2112', null, null, 100, null, 30),
    ('ID-P-IMP-11', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ID-P-IMP-11', 'credit_note', 'tax', 100, '1152', '5', array['5']::text[], -100, 'ID-SPT-MASA-PPN', 20),
    ('ID-P-IMP-11', 'credit_note', 'tax', -100, '2112', null, null, -100, null, 30),
    ('ID-P-RC', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('ID-P-RC', 'invoice', 'tax', 100, '1152', '5', array['5']::text[], 100, 'ID-SPT-MASA-PPN', 20),
    ('ID-P-RC', 'invoice', 'tax', -100, '2112', null, null, 100, null, 30),
    ('ID-P-RC', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('ID-P-RC', 'credit_note', 'tax', 100, '1152', '5', array['5']::text[], -100, 'ID-SPT-MASA-PPN', 20),
    ('ID-P-RC', 'credit_note', 'tax', -100, '2112', null, null, -100, null, 30),
    ('ID-S-0-EXP', 'invoice', 'base', 100, null, 'A1', array['A1']::text[], 100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-0-EXP', 'credit_note', 'base', 100, null, 'A1', array['A1']::text[], -100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-11', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-11', 'invoice', 'tax', 100, '2111', '1', array['1']::text[], 100, 'ID-SPT-MASA-PPN', 20),
    ('ID-S-11', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-11', 'credit_note', 'tax', 100, '2111', '1', array['1']::text[], -100, 'ID-SPT-MASA-PPN', 20),
    ('ID-S-12-LUX', 'invoice', 'base', 100, null, '1', array['1']::text[], 100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-12-LUX', 'invoice', 'tax', 100, '2111', '1', array['1']::text[], 100, 'ID-SPT-MASA-PPN', 20),
    ('ID-S-12-LUX', 'credit_note', 'base', 100, null, '1', array['1']::text[], -100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-12-LUX', 'credit_note', 'tax', 100, '2111', '1', array['1']::text[], -100, 'ID-SPT-MASA-PPN', 20),
    ('ID-S-EXEMPT', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'ID-SPT-MASA-PPN', 10),
    ('ID-S-EXEMPT', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'ID-SPT-MASA-PPN', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'ID' and t.code = v.tax_code
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
  ('ID', 'ID-SPT-MASA-PPN', 'Surat Pemberitahuan Masa Pajak Pertambahan Nilai (SPT Masa PPN) - Formulir 1111', array['month']::declaration_period[], 'month'::declaration_period, date '2015-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 3A ayat (1) jo. Undang-Undang Nomor 6 Tahun 1983 tentang Ketentuan Umum dan Tata Cara Perpajakan — Pengusaha Kena Pajak wajib memungut, menyetor, dan melaporkan Pajak Pertambahan Nilai yang terutang untuk setiap Masa Pajak, yaitu setiap bulan kalender; tidak ada pilihan periode triwulanan untuk Pajak Pertambahan Nilai, berbeda dari beberapa jenis pajak penghasilan. Struktur kotak (kode I.A, I.B, II.A-II.D) di bawah ini ditranskripsi dari Formulir 1111 (lampiran Peraturan Direktur Jenderal Pajak Nomor PER-29/PJ/2015), yang tetap menjadi struktur perhitungan yang berlaku secara substansi; sejak 1 Januari 2025 formulir ini disampaikan melalui Coretax DJP (Peraturan Menteri Keuangan Nomor 81 Tahun 2024 dan Peraturan Direktur Jenderal Pajak Nomor PER-11/PJ/2025), dan tampilan layar Coretax tidak ditelusuri baris demi baris pada sesi riset ini untuk memastikan kode kotak tetap identik - lihat README.', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Undang-Undang Nomor 6 Tahun 1983 tentang Ketentuan Umum dan Tata Cara Perpajakan, Pasal 3 ayat (3) huruf b — Surat Pemberitahuan Masa disampaikan paling lama 20 (dua puluh) hari setelah akhir Masa Pajak, KECUALI untuk Surat Pemberitahuan Masa Pajak Pertambahan Nilai yang disampaikan paling lama pada akhir bulan berikutnya setelah berakhirnya Masa Pajak. Teks konsolidasi pasal ini setelah perubahan oleh Undang-Undang Nomor 7 Tahun 2021 tidak dibaca langsung dari salinan resmi pada sesi ini; aturan yang dinyatakan di sini bersumber dari silang beberapa referensi sekunder yang konsisten (Online Pajak, Pajakku) dan merupakan hal pertama yang perlu diverifikasi terhadap teks resmi. Batas waktu PEMBAYARAN adalah tanggal 15 bulan berikutnya (Peraturan Menteri Keuangan Nomor 81 Tahun 2024, Pasal 94), yang mendahului batas waktu pelaporan ini dan tidak dimodelkan secara terpisah oleh field ini.', 'kup-law-6-1983', null)
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
  ('ID', 'ID-SPT-MASA-PPN', 'A1', 'base', 'I.A.1 Ekspor', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.A.1 — Dasar Pengenaan Pajak atas ekspor Barang Kena Pajak Berwujud, Barang Kena Pajak Tidak Berwujud, dan/atau Jasa Kena Pajak, tarif 0% (Undang-Undang Nomor 42 Tahun 2009, Pasal 7 ayat (2)).', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', '1', 'base', 'I.A.2 Penyerahan dalam negeri yang PPN-nya dipungut sendiri - Dasar Pengenaan Pajak', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.A.2 — Dasar Pengenaan Pajak atas penyerahan dalam negeri yang Pajak Pertambahan Nilai-nya harus dipungut sendiri oleh Pengusaha Kena Pajak penjual, termasuk pemanfaatan Barang Kena Pajak Tidak Berwujud/Jasa Kena Pajak dari luar Daerah Pabean yang dipungut sendiri oleh pihak yang memanfaatkan.', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', '1', 'tax', 'I.A.2 Penyerahan dalam negeri yang PPN-nya dipungut sendiri - Pajak Pertambahan Nilai', '{}'::jsonb, 25, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.A.2 — Pajak Pertambahan Nilai atas penyerahan pada baris di atas.', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', '4', 'base', 'I.A.5 Penyerahan yang dibebaskan dari pengenaan PPN', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.A.5 — Dasar Pengenaan Pajak atas penyerahan yang dibebaskan dari pengenaan Pajak Pertambahan Nilai (Undang-Undang Nomor 42 Tahun 2009, Pasal 16B; Peraturan Pemerintah Nomor 49 Tahun 2022).', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', 'IA', 'total', 'Jumlah I.A (I.A.1 + I.A.2 + I.A.3 + I.A.4 + I.A.5)', '{}'::jsonb, 40, null, array['A1', '1:base', '4']::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.A — jumlah seluruh penyerahan yang terutang Pajak Pertambahan Nilai. Baris I.A.3 (penyerahan yang PPN-nya dipungut oleh Pemungut PPN, Pasal 16A) dan I.A.4 (penyerahan yang PPN-nya tidak dipungut, fasilitas kawasan tertentu) tidak dimodelkan oleh pack ini - lihat README.', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', 'IB', 'base', 'I.B Penyerahan yang tidak terutang PPN', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.B — penyerahan barang dan/atau jasa yang bukan Barang Kena Pajak/Jasa Kena Pajak (Undang-Undang Nomor 42 Tahun 2009, Pasal 4A). Tidak ada kode pajak dari pack ini yang membukukan langsung ke kotak ini: sebuah baris dokumen di luar cakupan PPN sama sekali menggunakan tax:null, bukan sebuah kode pajak - lihat docs/packs.md.', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', 'IC', 'total', 'I.C Jumlah Seluruh Penyerahan (I.A + I.B)', '{}'::jsonb, 60, null, array['IA', 'IB']::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian I.C.', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', '5', 'tax', 'II.C Pajak Masukan yang dapat diperhitungkan', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian II.C, sama dengan bagian III.C Formulir 1111 AB — jumlah Pajak Masukan atas perolehan dalam negeri, impor, dan pemanfaatan Barang Kena Pajak Tidak Berwujud/Jasa Kena Pajak dari luar Daerah Pabean yang dapat dikreditkan (Undang-Undang Nomor 42 Tahun 2009, Pasal 9).', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', 'IIA', 'total', 'II.A Pajak Keluaran yang harus dipungut sendiri', '{}'::jsonb, 80, null, array['1:tax']::text[], '{}'::text[], null, null, false, false, null, 'Formulir 1111, bagian II.A — sama dengan jumlah Pajak Pertambahan Nilai pada I.A.2.', 'vat-return-form-1111'),
  ('ID', 'ID-SPT-MASA-PPN', 'IID', 'total', 'II.D PPN kurang atau (lebih) bayar', '{}'::jsonb, 90, null, array['IIA']::text[], array['5']::text[], null, null, false, false, null, 'Formulir 1111, bagian II.D = II.A - II.B - II.C. Baris II.B (PPN disetor dimuka dalam Masa Pajak yang sama) tidak dimodelkan oleh pack ini, sehingga rumus di sini adalah II.A - II.C. Nilai negatif berarti lebih bayar (dikompensasikan ke Masa Pajak berikutnya atau dimintakan restitusi, bagian II.H Formulir 1111), sehingga kotak ini tidak dibulatkan ke nol.', 'vat-return-form-1111')
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
  ('ID-LK-BS', 'ID', 'default', 'Laporan Posisi Keuangan', 'balance_sheet', 'ID-SAK', date '1970-01-01', null, 'Kerangka Standar Pelaporan Keuangan Indonesia dan PSAK 201 (dahulu PSAK 1) - Penyajian Laporan Keuangan, disahkan oleh Dewan Standar Akuntansi Keuangan - Ikatan Akuntan Indonesia, menetapkan pemisahan aset dan liabilitas menjadi lancar/tidak lancar dan komponen minimal laporan posisi keuangan, tanpa menetapkan nomor kode akun. Baris di bawah ini mengelompokkan akun bagan akun original pack ini (accounts.csv) menurut struktur umum tersebut; isi baris demi baris PSAK 201 yang lengkap, dan SAK EMKM sebagai kerangka yang lebih sederhana bagi entitas mikro, kecil dan menengah, tidak ditelusuri secara terperinci pada sesi riset ini - lihat README.', 'sak-iai'),
  ('ID-LK-LR', 'ID', 'default', 'Laporan Laba Rugi', 'income_statement', 'ID-SAK', date '1970-01-01', null, 'Kerangka Standar Pelaporan Keuangan Indonesia dan PSAK 201 (dahulu PSAK 1) - Penyajian Laporan Keuangan; struktur di bawah adalah pengelompokan original berdasarkan kelas akun bagan akun ini (accounts.csv), bukan transkripsi baris demi baris dari suatu format resmi bernomor, karena tidak ada satu pun - lihat README.', 'sak-iai')
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
  ('ID-LK-BS', 'TOTAL-ASET', null, 'TOTAL ASET', '{}'::jsonb, 10, 1, true, array['ASET-LANCAR', 'ASET-TIDAK-LANCAR']::text[], '{}'::text[], null, 'Kerangka Standar Pelaporan Keuangan Indonesia - total aset.', 'sak-iai'),
  ('ID-LK-BS', 'ASET-LANCAR', 'TOTAL-ASET', 'Aset Lancar', '{}'::jsonb, 20, 1, true, array['KAS-BANK', 'PIUTANG', 'PPN-MASUKAN', 'PERSEDIAAN', 'ASET-LANCAR-LAIN']::text[], '{}'::text[], null, 'Kerangka Standar Pelaporan Keuangan Indonesia - klasifikasi aset lancar.', 'sak-iai'),
  ('ID-LK-BS', 'KAS-BANK', 'ASET-LANCAR', 'Kas dan bank', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1000-1099.', 'sak-iai'),
  ('ID-LK-BS', 'PIUTANG', 'ASET-LANCAR', 'Piutang usaha', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1100-1149.', 'sak-iai'),
  ('ID-LK-BS', 'PPN-MASUKAN', 'ASET-LANCAR', 'Pajak Pertambahan Nilai Masukan', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1150-1199.', 'sak-iai'),
  ('ID-LK-BS', 'PERSEDIAAN', 'ASET-LANCAR', 'Persediaan', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1200-1249.', 'sak-iai'),
  ('ID-LK-BS', 'ASET-LANCAR-LAIN', 'ASET-LANCAR', 'Aset lancar lainnya', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1250-1299.', 'sak-iai'),
  ('ID-LK-BS', 'ASET-TIDAK-LANCAR', 'TOTAL-ASET', 'Aset Tidak Lancar', '{}'::jsonb, 80, 1, true, array['ASET-TETAP', 'ASET-LAIN']::text[], '{}'::text[], null, 'Kerangka Standar Pelaporan Keuangan Indonesia - klasifikasi aset tidak lancar.', 'sak-iai'),
  ('ID-LK-BS', 'ASET-TETAP', 'ASET-TIDAK-LANCAR', 'Aset tetap (setelah akumulasi penyusutan)', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1300-1399, termasuk akumulasi penyusutan (1390).', 'sak-iai'),
  ('ID-LK-BS', 'ASET-LAIN', 'ASET-TIDAK-LANCAR', 'Aset tidak lancar lainnya', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 1400-1499.', 'sak-iai'),
  ('ID-LK-BS', 'TOTAL-PASIVA', null, 'TOTAL LIABILITAS DAN EKUITAS', '{}'::jsonb, 110, 1, true, array['TOTAL-LIABILITAS', 'TOTAL-EKUITAS']::text[], '{}'::text[], null, 'Kerangka Standar Pelaporan Keuangan Indonesia - sama dengan TOTAL ASET pada tahun buku yang ditutup.', 'sak-iai'),
  ('ID-LK-BS', 'TOTAL-LIABILITAS', 'TOTAL-PASIVA', 'Total Liabilitas', '{}'::jsonb, 120, 1, true, array['LIABILITAS-LANCAR', 'LIABILITAS-TIDAK-LANCAR']::text[], '{}'::text[], null, 'Kerangka Standar Pelaporan Keuangan Indonesia - total liabilitas.', 'sak-iai'),
  ('ID-LK-BS', 'LIABILITAS-LANCAR', 'TOTAL-LIABILITAS', 'Liabilitas Jangka Pendek', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 2000-2899.', 'sak-iai'),
  ('ID-LK-BS', 'LIABILITAS-TIDAK-LANCAR', 'TOTAL-LIABILITAS', 'Liabilitas Jangka Panjang', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 2900-2999.', 'sak-iai'),
  ('ID-LK-BS', 'TOTAL-EKUITAS', 'TOTAL-PASIVA', 'Ekuitas', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 3000-3999.', 'sak-iai'),
  ('ID-LK-LR', 'PENDAPATAN-NETO', null, 'Pendapatan usaha (neto)', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 4000-4899, termasuk retur dan potongan penjualan (4100).', 'sak-iai'),
  ('ID-LK-LR', 'HPP', null, 'Beban pokok penjualan', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 5000-5999.', 'sak-iai'),
  ('ID-LK-LR', 'LABA-KOTOR', null, 'Laba Kotor', '{}'::jsonb, 30, 1, true, array['PENDAPATAN-NETO']::text[], array['HPP']::text[], null, 'Pendapatan usaha neto dikurangi beban pokok penjualan.', 'sak-iai'),
  ('ID-LK-LR', 'BEBAN-USAHA', null, 'Beban Usaha', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 6000-6999 (beban penjualan, administrasi dan umum, penyusutan).', 'sak-iai'),
  ('ID-LK-LR', 'LABA-USAHA', null, 'Laba Usaha', '{}'::jsonb, 50, 1, true, array['LABA-KOTOR']::text[], array['BEBAN-USAHA']::text[], null, 'Laba kotor dikurangi beban usaha.', 'sak-iai'),
  ('ID-LK-LR', 'PENDAPATAN-LAIN', null, 'Pendapatan lain-lain', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 7000-7099.', 'sak-iai'),
  ('ID-LK-LR', 'BEBAN-LAIN', null, 'Beban lain-lain', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 7500-7599.', 'sak-iai'),
  ('ID-LK-LR', 'LABA-SEBELUM-PAJAK', null, 'Laba Sebelum Pajak Penghasilan', '{}'::jsonb, 80, 1, true, array['LABA-USAHA', 'PENDAPATAN-LAIN']::text[], array['BEBAN-LAIN']::text[], null, 'Laba usaha ditambah pendapatan lain-lain dikurangi beban lain-lain.', 'sak-iai'),
  ('ID-LK-LR', 'BEBAN-PPH', null, 'Beban Pajak Penghasilan', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'accounts.csv, kode 8000-8099.', 'sak-iai'),
  ('ID-LK-LR', 'LABA-BERSIH', null, 'Laba (Rugi) Bersih Tahun Berjalan', '{}'::jsonb, 100, 1, true, array['LABA-SEBELUM-PAJAK']::text[], array['BEBAN-PPH']::text[], null, 'Laba sebelum pajak penghasilan dikurangi beban pajak penghasilan.', 'sak-iai')
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
    ('ID-LK-BS', 'KAS-BANK', 10, 'code_range', '1000', '1099', null, 'any'),
    ('ID-LK-BS', 'PIUTANG', 10, 'code_range', '1100', '1149', null, 'any'),
    ('ID-LK-BS', 'PPN-MASUKAN', 10, 'code_range', '1150', '1199', null, 'any'),
    ('ID-LK-BS', 'PERSEDIAAN', 10, 'code_range', '1200', '1249', null, 'any'),
    ('ID-LK-BS', 'ASET-LANCAR-LAIN', 10, 'code_range', '1250', '1299', null, 'any'),
    ('ID-LK-BS', 'ASET-TETAP', 10, 'code_range', '1300', '1399', null, 'any'),
    ('ID-LK-BS', 'ASET-LAIN', 10, 'code_range', '1400', '1499', null, 'any'),
    ('ID-LK-BS', 'LIABILITAS-LANCAR', 10, 'code_range', '2000', '2899', null, 'any'),
    ('ID-LK-BS', 'LIABILITAS-TIDAK-LANCAR', 10, 'code_range', '2900', '2999', null, 'any'),
    ('ID-LK-BS', 'TOTAL-EKUITAS', 10, 'code_range', '3000', '3999', null, 'any'),
    ('ID-LK-LR', 'PENDAPATAN-NETO', 10, 'code_range', '4000', '4899', null, 'any'),
    ('ID-LK-LR', 'HPP', 10, 'code_range', '5000', '5999', null, 'any'),
    ('ID-LK-LR', 'BEBAN-USAHA', 10, 'code_range', '6000', '6999', null, 'any'),
    ('ID-LK-LR', 'PENDAPATAN-LAIN', 10, 'code_range', '7000', '7099', null, 'any'),
    ('ID-LK-LR', 'BEBAN-LAIN', 10, 'code_range', '7500', '7599', null, 'any'),
    ('ID-LK-LR', 'BEBAN-PPH', 10, 'code_range', '8000', '8099', null, 'any')
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
  ('ID', 'Indonesia', '{}'::jsonb, array['id']::text[], 'IDR', '1100', '2000', '2400', '7540', '3200', '4000', '5000', '1021', '1010', 'SAL', 'PUR', 'GEN', 'id', 'retained_earnings', null, null, null, 'OPN', 'half_up', default, '7020', '7520', '7030', '7530', null, null, '2110', '1150', null, 'month'::declaration_period)
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
  number_format                 = '{CODE}/{NNNN}/{MM}/{YYYY}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Undang-Undang Nomor 42 Tahun 2009, Pasal 13 ayat (5) — Faktur Pajak harus mencantumkan nomor seri Faktur Pajak; sejak berlakunya Coretax (Peraturan Menteri Keuangan Nomor 81 Tahun 2024 dan Peraturan Direktur Jenderal Pajak Nomor PER-11/PJ/2025), nomor seri Faktur Pajak diterbitkan dan divalidasi oleh Coretax DJP saat faktur diunggah (lihat einvoicing di bawah); format di atas hanya menjelaskan nomor internal dokumen Ekwo sebelum divalidasi oleh Coretax, bukan nomor seri Faktur Pajak itu sendiri (13 digit, dialokasikan oleh DJP) — kesenjangan ini dicatat dalam docs/international.md.',
  numbering_source_key          = 'vat-law-42-2009',
  payment_terms_legal_reference = 'Tidak ditemukan ketentuan yang menetapkan jangka waktu pembayaran hukum baku antar-pelaku usaha tanpa kesepakatan pada sesi riset ini; pencarian tidak menyeluruh dan ketentuan semacam itu mungkin ada dalam Kitab Undang-Undang Hukum Perdata. legal_payment_days dan late_payment_reference dibiarkan kosong daripada ditebak.',
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Undang-Undang Nomor 42 Tahun 2009, Pasal 11 jo. Pasal 17 Peraturan Pemerintah Nomor 1 Tahun 2012 — terutangnya pajak atas penyerahan barang berwujud terjadi pada saat penyerahan barang, atau saat pembayaran jika pembayaran diterima sebelum penyerahan, atau saat Faktur Pajak dibuat jika lebih dahulu dari keduanya; atas jasa, pada saat mulai tersedianya fasilitas atau pemberian jasa, atau saat pembayaran jika lebih dahulu. `invoice_if_issued` adalah pendekatan terdekat dalam kosakata tertutup Ekwo: undang-undang pada prinsipnya mengacu pada penyerahan/pemberian jasa, kecuali pembayaran atau Faktur Pajak terjadi lebih dahulu — sesuatu yang tidak sepenuhnya tercakup baik oleh `delivery_date` maupun `earliest_of_delivery_or_payment` sendiri (tidak ada satu pun dari lima kata yang menyatakan "penyerahan, kecuali faktur atau pembayaran lebih dahulu, mana yang lebih cepat" dengan Faktur Pajak sebagai pemicu tersendiri) — kesenjangan ini dicatat dalam docs/international.md.',
  tax_point_source_key          = 'vat-law-42-2009',
  posted_edit_policy            = null,
  posted_edit_policy_legal_reference = null,
  posted_edit_policy_source_key = null,
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Setiap Pengusaha Kena Pajak (PKP) wajib membuat Faktur Pajak untuk setiap penyerahan (Undang-Undang Nomor 42 Tahun 2009, Pasal 13), dan sejak Peraturan Menteri Keuangan Nomor 81 Tahun 2024 (berlaku 1 Januari 2025) serta Peraturan Direktur Jenderal Pajak Nomor PER-11/PJ/2025, setiap Faktur Pajak dibuat dan DIVALIDASI secara real time oleh Coretax DJP (coretaxdjp.pajak.go.id) sebelum sampai ke pembeli — sebuah mekanisme clearance oleh otoritas pajak, dan bukan format terstruktur yang dipertukarkan langsung antar pihak. Tidak ada `profile` Ekwo (peppol-bis-3, factur-x-en16931, pint-*) yang menggambarkan mekanisme ini: mendeklarasikan salah satunya akan membuat describePack() menyatakan bahwa Ekwo menulis dan mengirimkan Faktur Pajak yang sah, padahal tidak — pilihan yang sama dengan packs/vn (Nghị định 123/2020/NĐ-CP) dan packs/mx untuk sistem clearance mereka sendiri. `party_scheme` dan `vat_scheme` dibiarkan kosong: identitas wajib pajak Indonesia (NPWP, 16 digit sejak Coretax) bukan register ISO 6523. Nomor seri Faktur Pajak (13 digit) dialokasikan oleh Coretax saat validasi, bukan oleh pack ini — lihat docs/international.md.',
  einvoice_source_key           = 'pmk-81-2024-coretax',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'ID';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('ID', 'export', 'export', 'Ekspor Barang Kena Pajak/Jasa Kena Pajak dikenai Pajak Pertambahan Nilai dengan tarif 0% (nol persen).', '{}'::jsonb, 10, date '1970-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 7 ayat (2) sebagaimana diubah dengan Undang-Undang Nomor 7 Tahun 2021 — tarif 0% atas ekspor Barang Kena Pajak Berwujud, Barang Kena Pajak Tidak Berwujud, dan Jasa Kena Pajak.'),
  ('ID', 'exempt', 'exempt', 'Penyerahan ini dibebaskan dari pengenaan Pajak Pertambahan Nilai.', '{}'::jsonb, 20, date '1970-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 16B, dan Peraturan Pemerintah Nomor 49 Tahun 2022 — fasilitas Pajak Pertambahan Nilai dibebaskan atas impor dan/atau penyerahan Barang Kena Pajak tertentu dan/atau Jasa Kena Pajak tertentu.'),
  ('ID', 'reverse_charge', 'reverse_charge', 'Pajak Pertambahan Nilai atas pemanfaatan Jasa Kena Pajak dari luar Daerah Pabean ini dipungut, disetor, dan dilaporkan sendiri oleh pihak yang memanfaatkan.', '{}'::jsonb, 30, date '1970-01-01', null, 'Undang-Undang Nomor 42 Tahun 2009, Pasal 3A ayat (3) — Pajak Pertambahan Nilai yang terutang atas pemanfaatan Barang Kena Pajak Tidak Berwujud dan/atau Jasa Kena Pajak dari luar Daerah Pabean di dalam Daerah Pabean wajib dipungut, disetor, dan dilaporkan oleh orang pribadi atau badan yang memanfaatkannya.')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
