-- Ekwo OS — Paraguay: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/py at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build py`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley N° 6.380/2019, De Modernización y Simplificación del Sistema Tributario Nacional — Libro III, Impuesto al Valor Agregado (IVA), arts. 80 a 103 (Dirección Nacional de Ingresos Tributarios (DNIT))
--     https://www.dnit.gov.py/documents/20123/399318/LEY+6380-2019.pdf/7437353b-7f7e-28e6-c41a-da57f1af1439?t=1708599743388
--   Ley N° 1.034/1983, Del Comerciante — Título II, De los libros y la documentación comercial, arts. 74 a 89 (Biblioteca y Archivo del Congreso Nacional (BACN))
--     https://www.bacn.gov.py/leyes-paraguayas/2538/ley-n-1034-del-comerciante
--   Código Civil, Ley N° 1.183/1985 — Libro Segundo, Título II, De las sociedades, Capítulo IX, De las sociedades anónimas, arts. 1079 a 1081 (Comisión Nacional de Telecomunicaciones (CONATEL), texto del Código Civil paraguayo)
--     https://www.conatel.gov.py/conatel/wp-content/uploads/2019/10/ley-1183_1985-cdigo-civil-paraguayo.pdf
--   Instructivo del Formulario N.° 120 — Declaración Jurada del Impuesto al Valor Agregado (IVA), Versión 4 (Dirección Nacional de Ingresos Tributarios (DNIT))
--     https://www.dnit.gov.py/documents/47797/47809/Instructivo+del+Formulario+N%C2%B0+120+IVA+Versi%C3%B3n+4.pdf/63799cd8-6212-3c22-779b-51b2f97a136b?t=1680624028092
--   IVA — presentación de la Declaración Jurada a través del Sistema de Gestión Tributaria Marangatú (Dirección Nacional de Ingresos Tributarios (DNIT))
--     https://www.dnit.gov.py/en/web/portal-institucional/iva
--   Manual Técnico del Sistema Integrado de Facturación Electrónica Nacional (SIFEN), Versión 150 — sección 4.2, Fundamento legal, y sección 6, Modelo Operativo (Dirección Nacional de Ingresos Tributarios (DNIT))
--     https://www.dnit.gov.py/documents/20123/420592/Manual+T%C3%A9cnico+Versi%C3%B3n+150.pdf
--   e-Kuatia — Sistema Integrado de Facturación Electrónica Nacional, emisión y consulta de documentos tributarios electrónicos (Dirección Nacional de Ingresos Tributarios (DNIT))
--     https://www.dnit.gov.py/en/web/e-kuatia
--   Resolución General N.° 38/2020, por la cual se establece el Calendario Perpetuo de Vencimientos para la presentación de declaraciones juradas determinativas y el pago de las obligaciones tributarias (Dirección Nacional de Ingresos Tributarios (DNIT))
--     https://www.dnit.gov.py/en/web/portal-institucional/w/resolucion-general-n-38-20
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('PY', 'Paraguay', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'a38198b269cb7dac305b68d7ecbb735987442e1c7f4a116bb3e136bb7bf06af3', '[{"key":"ley-6380","title":"Ley N° 6.380/2019, De Modernización y Simplificación del Sistema Tributario Nacional — Libro III, Impuesto al Valor Agregado (IVA), arts. 80 a 103","publisher":"Dirección Nacional de Ingresos Tributarios (DNIT)","url":"https://www.dnit.gov.py/documents/20123/399318/LEY+6380-2019.pdf/7437353b-7f7e-28e6-c41a-da57f1af1439?t=1708599743388","consulted_on":"2026-09-26","kind":"law"},{"key":"comerciante-1034","title":"Ley N° 1.034/1983, Del Comerciante — Título II, De los libros y la documentación comercial, arts. 74 a 89","publisher":"Biblioteca y Archivo del Congreso Nacional (BACN)","url":"https://www.bacn.gov.py/leyes-paraguayas/2538/ley-n-1034-del-comerciante","consulted_on":"2026-09-26","kind":"law"},{"key":"codigo-civil","title":"Código Civil, Ley N° 1.183/1985 — Libro Segundo, Título II, De las sociedades, Capítulo IX, De las sociedades anónimas, arts. 1079 a 1081","publisher":"Comisión Nacional de Telecomunicaciones (CONATEL), texto del Código Civil paraguayo","url":"https://www.conatel.gov.py/conatel/wp-content/uploads/2019/10/ley-1183_1985-cdigo-civil-paraguayo.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"f120-instructivo","title":"Instructivo del Formulario N.° 120 — Declaración Jurada del Impuesto al Valor Agregado (IVA), Versión 4","publisher":"Dirección Nacional de Ingresos Tributarios (DNIT)","url":"https://www.dnit.gov.py/documents/47797/47809/Instructivo+del+Formulario+N%C2%B0+120+IVA+Versi%C3%B3n+4.pdf/63799cd8-6212-3c22-779b-51b2f97a136b?t=1680624028092","consulted_on":"2026-09-26","kind":"form"},{"key":"marangatu-portal","title":"IVA — presentación de la Declaración Jurada a través del Sistema de Gestión Tributaria Marangatú","publisher":"Dirección Nacional de Ingresos Tributarios (DNIT)","url":"https://www.dnit.gov.py/en/web/portal-institucional/iva","consulted_on":"2026-09-26","kind":"portal"},{"key":"sifen-manual","title":"Manual Técnico del Sistema Integrado de Facturación Electrónica Nacional (SIFEN), Versión 150 — sección 4.2, Fundamento legal, y sección 6, Modelo Operativo","publisher":"Dirección Nacional de Ingresos Tributarios (DNIT)","url":"https://www.dnit.gov.py/documents/20123/420592/Manual+T%C3%A9cnico+Versi%C3%B3n+150.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"ekuatia-portal","title":"e-Kuatia — Sistema Integrado de Facturación Electrónica Nacional, emisión y consulta de documentos tributarios electrónicos","publisher":"Dirección Nacional de Ingresos Tributarios (DNIT)","url":"https://www.dnit.gov.py/en/web/e-kuatia","consulted_on":"2026-09-26","kind":"portal"},{"key":"vencimientos-38-2020","title":"Resolución General N.° 38/2020, por la cual se establece el Calendario Perpetuo de Vencimientos para la presentación de declaraciones juradas determinativas y el pago de las obligaciones tributarias","publisher":"Dirección Nacional de Ingresos Tributarios (DNIT)","url":"https://www.dnit.gov.py/en/web/portal-institucional/w/resolucion-general-n-38-20","consulted_on":"2026-09-26","kind":"regulation"}]'::jsonb)
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
  ('PY', 'default', 'Plan de cuentas de referencia sobre el libro de inventario y el balance general de la Ley N.° 1.034/1983', '{}'::jsonb, true, 'companies', array['PY-ER', 'PY-ESP']::text[], null, 'La República del Paraguay no impone un plan de cuentas único ni numerado. La Ley N.° 1.034/1983, Del Comerciante, art. 75, sólo exige llevar «indispensablemente un libro Diario y uno de Inventario», y su art. 82 fija el contenido mínimo del libro de Inventario: la situación patrimonial al iniciar las operaciones y, al cierre de cada ejercicio, la situación patrimonial con el «cuadro demostrativo de ganancias y pérdidas» — sin prescribir cuentas. El Código Civil, art. 1079, añade que la asamblea ordinaria de una sociedad anónima debe considerar el «balance y cuenta de ganancias y pérdidas» del ejercicio. Este plan es original: sigue una numeración propia de tres a cinco dígitos y cada bloque de códigos corresponde a una línea de PY-ESP o de PY-ER, de modo que las cuentas de este paquete se leen directamente sobre esos dos esquemas — véase el README.md', 'comerciante-1034')
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
  ('PY', 'default', '1', 'Activo', '{}'::jsonb, 'asset_current', false, null, 10),
  ('PY', 'default', '10', 'Activo corriente', '{}'::jsonb, 'asset_current', false, '1', 20),
  ('PY', 'default', '101', 'Disponibilidades', '{}'::jsonb, 'asset_cash', false, '10', 30),
  ('PY', 'default', '1011', 'Caja', '{}'::jsonb, 'asset_cash', false, '101', 40),
  ('PY', 'default', '1012', 'Bancos', '{}'::jsonb, 'asset_cash', false, '101', 50),
  ('PY', 'default', '102', 'Créditos por ventas', '{}'::jsonb, 'asset_receivable', true, '10', 60),
  ('PY', 'default', '1021', 'Clientes del mercado interno', '{}'::jsonb, 'asset_receivable', true, '102', 70),
  ('PY', 'default', '1022', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '102', 80),
  ('PY', 'default', '1023', 'Documentos a cobrar', '{}'::jsonb, 'asset_receivable', true, '102', 90),
  ('PY', 'default', '103', 'Otros créditos', '{}'::jsonb, 'asset_current', false, '10', 100),
  ('PY', 'default', '1031', 'Anticipo a proveedores', '{}'::jsonb, 'asset_current', false, '103', 110),
  ('PY', 'default', '1032', 'Gastos pagados por adelantado', '{}'::jsonb, 'asset_prepayments', false, '103', 120),
  ('PY', 'default', '1033', 'Anticipo Impuesto a la Renta Empresarial', '{}'::jsonb, 'asset_current', false, '103', 130),
  ('PY', 'default', '1034', 'Préstamos a sociedades vinculadas', '{}'::jsonb, 'asset_current', false, '103', 140),
  ('PY', 'default', '1035', 'Depósitos en garantía', '{}'::jsonb, 'asset_current', false, '103', 150),
  ('PY', 'default', '104', 'Créditos fiscales', '{}'::jsonb, 'asset_current', false, '10', 160),
  ('PY', 'default', '1041', 'IVA Crédito Fiscal', '{}'::jsonb, 'asset_current', false, '104', 170),
  ('PY', 'default', '1042', 'IVA Saldo a Favor del Contribuyente', '{}'::jsonb, 'asset_current', true, '104', 180),
  ('PY', 'default', '105', 'Bienes de cambio', '{}'::jsonb, 'asset_current', false, '10', 190),
  ('PY', 'default', '1051', 'Mercaderías de reventa', '{}'::jsonb, 'asset_current', false, '105', 200),
  ('PY', 'default', '1052', 'Materias primas', '{}'::jsonb, 'asset_current', false, '105', 210),
  ('PY', 'default', '1053', 'Productos en proceso de elaboración', '{}'::jsonb, 'asset_current', false, '105', 220),
  ('PY', 'default', '1054', 'Productos terminados', '{}'::jsonb, 'asset_current', false, '105', 230),
  ('PY', 'default', '106', 'Partidas pendientes de imputación', '{}'::jsonb, 'asset_current', false, '10', 240),
  ('PY', 'default', '11', 'Activo no corriente', '{}'::jsonb, 'asset_non_current', false, '1', 250),
  ('PY', 'default', '111', 'Créditos no corrientes', '{}'::jsonb, 'asset_non_current', false, '11', 260),
  ('PY', 'default', '112', 'Bienes de uso', '{}'::jsonb, 'asset_fixed', false, '11', 270),
  ('PY', 'default', '1121', 'Bienes de uso — valor de costo', '{}'::jsonb, 'asset_fixed', false, '112', 280),
  ('PY', 'default', '11211', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '1121', 290),
  ('PY', 'default', '11212', 'Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '1121', 300),
  ('PY', 'default', '11213', 'Maquinarias y equipos', '{}'::jsonb, 'asset_fixed', false, '1121', 310),
  ('PY', 'default', '11214', 'Muebles y útiles', '{}'::jsonb, 'asset_fixed', false, '1121', 320),
  ('PY', 'default', '11215', 'Rodados', '{}'::jsonb, 'asset_fixed', false, '1121', 330),
  ('PY', 'default', '11216', 'Equipos de computación', '{}'::jsonb, 'asset_fixed', false, '1121', 340),
  ('PY', 'default', '1122', 'Bienes de uso — depreciación acumulada', '{}'::jsonb, 'asset_fixed', false, '112', 350),
  ('PY', 'default', '11221', 'Depreciación acumulada — Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '1122', 360),
  ('PY', 'default', '11222', 'Depreciación acumulada — Maquinarias y equipos', '{}'::jsonb, 'asset_fixed', false, '1122', 370),
  ('PY', 'default', '11223', 'Depreciación acumulada — Muebles y útiles', '{}'::jsonb, 'asset_fixed', false, '1122', 380),
  ('PY', 'default', '11224', 'Depreciación acumulada — Rodados', '{}'::jsonb, 'asset_fixed', false, '1122', 390),
  ('PY', 'default', '11225', 'Depreciación acumulada — Equipos de computación', '{}'::jsonb, 'asset_fixed', false, '1122', 400),
  ('PY', 'default', '113', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '11', 410),
  ('PY', 'default', '1131', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '113', 420),
  ('PY', 'default', '1132', 'Programas y licencias informáticas', '{}'::jsonb, 'asset_non_current', false, '113', 430),
  ('PY', 'default', '2', 'Pasivo', '{}'::jsonb, 'liability_current', false, null, 440),
  ('PY', 'default', '20', 'Pasivo corriente', '{}'::jsonb, 'liability_current', false, '2', 450),
  ('PY', 'default', '201', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_payable', true, '20', 460),
  ('PY', 'default', '2011', 'Proveedores del mercado interno', '{}'::jsonb, 'liability_payable', true, '201', 470),
  ('PY', 'default', '2012', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '201', 480),
  ('PY', 'default', '2013', 'Documentos a pagar', '{}'::jsonb, 'liability_payable', true, '201', 490),
  ('PY', 'default', '202', 'Remuneraciones y cargas sociales a pagar', '{}'::jsonb, 'liability_current', false, '20', 500),
  ('PY', 'default', '2021', 'Sueldos a pagar', '{}'::jsonb, 'liability_current', false, '202', 510),
  ('PY', 'default', '2022', 'Aportes al Instituto de Previsión Social a pagar', '{}'::jsonb, 'liability_current', false, '202', 520),
  ('PY', 'default', '2023', 'Provisión de aguinaldo', '{}'::jsonb, 'liability_current', false, '202', 530),
  ('PY', 'default', '2024', 'Provisión de vacaciones', '{}'::jsonb, 'liability_current', false, '202', 540),
  ('PY', 'default', '203', 'Cargas fiscales a pagar', '{}'::jsonb, 'liability_current', false, '20', 550),
  ('PY', 'default', '2031', 'IVA Débito Fiscal', '{}'::jsonb, 'liability_current', false, '203', 560),
  ('PY', 'default', '2032', 'IVA a Pagar', '{}'::jsonb, 'liability_current', true, '203', 570),
  ('PY', 'default', '2033', 'Impuesto a la Renta Empresarial a pagar', '{}'::jsonb, 'liability_current', false, '203', 580),
  ('PY', 'default', '2034', 'Retenciones a pagar', '{}'::jsonb, 'liability_current', false, '203', 590),
  ('PY', 'default', '204', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '20', 600),
  ('PY', 'default', '205', 'Provisiones', '{}'::jsonb, 'liability_current', false, '20', 610),
  ('PY', 'default', '21', 'Pasivo no corriente', '{}'::jsonb, 'liability_non_current', false, '2', 620),
  ('PY', 'default', '211', 'Deudas bancarias no corrientes', '{}'::jsonb, 'liability_non_current', false, '21', 630),
  ('PY', 'default', '212', 'Otras deudas no corrientes', '{}'::jsonb, 'liability_non_current', false, '21', 640),
  ('PY', 'default', '2121', 'Deudas con socios y accionistas', '{}'::jsonb, 'liability_non_current', false, '212', 650),
  ('PY', 'default', '2122', 'Depósitos de terceros en garantía', '{}'::jsonb, 'liability_non_current', false, '212', 660),
  ('PY', 'default', '3', 'Patrimonio neto', '{}'::jsonb, 'equity', false, null, 670),
  ('PY', 'default', '31', 'Capital integrado', '{}'::jsonb, 'equity', false, '3', 680),
  ('PY', 'default', '32', 'Reserva legal', '{}'::jsonb, 'equity', false, '3', 690),
  ('PY', 'default', '33', 'Otras reservas', '{}'::jsonb, 'equity', false, '3', 700),
  ('PY', 'default', '34', 'Resultados acumulados', '{}'::jsonb, 'equity_retained', false, '3', 710),
  ('PY', 'default', '341', 'Resultados acumulados — Ganancias', '{}'::jsonb, 'equity_retained', false, '34', 720),
  ('PY', 'default', '342', 'Resultados acumulados — Pérdidas', '{}'::jsonb, 'equity_retained', false, '34', 730),
  ('PY', 'default', '35', 'Resultado del ejercicio', '{}'::jsonb, 'equity', false, '3', 740),
  ('PY', 'default', '351', 'Resultado del ejercicio — Ganancia', '{}'::jsonb, 'equity', false, '35', 750),
  ('PY', 'default', '352', 'Resultado del ejercicio — Pérdida', '{}'::jsonb, 'equity', false, '35', 760),
  ('PY', 'default', '4', 'Ingresos', '{}'::jsonb, 'income', false, null, 770),
  ('PY', 'default', '41', 'Ventas', '{}'::jsonb, 'income', false, '4', 780),
  ('PY', 'default', '411', 'Ventas de mercaderías — mercado interno', '{}'::jsonb, 'income', false, '41', 790),
  ('PY', 'default', '412', 'Ventas de mercaderías — exportaciones', '{}'::jsonb, 'income', false, '41', 800),
  ('PY', 'default', '413', 'Ventas de servicios', '{}'::jsonb, 'income', false, '41', 810),
  ('PY', 'default', '46', 'Resultados financieros positivos', '{}'::jsonb, 'income_other', false, '4', 820),
  ('PY', 'default', '461', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '46', 830),
  ('PY', 'default', '462', 'Diferencia de cambio positiva', '{}'::jsonb, 'income_other', false, '46', 840),
  ('PY', 'default', '463', 'Descuentos obtenidos', '{}'::jsonb, 'income_other', false, '46', 850),
  ('PY', 'default', '48', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '4', 860),
  ('PY', 'default', '5', 'Costos y gastos', '{}'::jsonb, 'expense', false, null, 870),
  ('PY', 'default', '51', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '5', 880),
  ('PY', 'default', '511', 'Compras de mercaderías', '{}'::jsonb, 'expense_direct_cost', false, '51', 890),
  ('PY', 'default', '52', 'Gastos de comercialización', '{}'::jsonb, 'expense', false, '5', 900),
  ('PY', 'default', '521', 'Comisiones sobre ventas', '{}'::jsonb, 'expense', false, '52', 910),
  ('PY', 'default', '522', 'Fletes sobre ventas', '{}'::jsonb, 'expense', false, '52', 920),
  ('PY', 'default', '523', 'Publicidad', '{}'::jsonb, 'expense', false, '52', 930),
  ('PY', 'default', '524', 'Gastos varios de comercialización', '{}'::jsonb, 'expense', false, '52', 940),
  ('PY', 'default', '53', 'Gastos de administración', '{}'::jsonb, 'expense', false, '5', 950),
  ('PY', 'default', '531', 'Sueldos y cargas sociales', '{}'::jsonb, 'expense', false, '53', 960),
  ('PY', 'default', '5311', 'Sueldos', '{}'::jsonb, 'expense', false, '531', 970),
  ('PY', 'default', '5312', 'Aportes al Instituto de Previsión Social', '{}'::jsonb, 'expense', false, '531', 980),
  ('PY', 'default', '5313', 'Aguinaldo y vacaciones', '{}'::jsonb, 'expense', false, '531', 990),
  ('PY', 'default', '532', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '53', 1000),
  ('PY', 'default', '533', 'Gastos generales de administración', '{}'::jsonb, 'expense', false, '53', 1010),
  ('PY', 'default', '5331', 'Alquileres', '{}'::jsonb, 'expense', false, '533', 1020),
  ('PY', 'default', '5332', 'Servicios básicos', '{}'::jsonb, 'expense', false, '533', 1030),
  ('PY', 'default', '5333', 'Útiles de oficina', '{}'::jsonb, 'expense', false, '533', 1040),
  ('PY', 'default', '5334', 'Gastos de mantenimiento', '{}'::jsonb, 'expense', false, '533', 1050),
  ('PY', 'default', '5335', 'Seguros', '{}'::jsonb, 'expense', false, '533', 1060),
  ('PY', 'default', '5336', 'Impuestos, tasas y contribuciones', '{}'::jsonb, 'expense', false, '533', 1070),
  ('PY', 'default', '534', 'Depreciación de bienes de uso', '{}'::jsonb, 'expense_depreciation', false, '53', 1080),
  ('PY', 'default', '535', 'Amortización de intangibles', '{}'::jsonb, 'expense_depreciation', false, '53', 1090),
  ('PY', 'default', '56', 'Resultados financieros negativos', '{}'::jsonb, 'expense', false, '5', 1100),
  ('PY', 'default', '561', 'Intereses pagados', '{}'::jsonb, 'expense', false, '56', 1110),
  ('PY', 'default', '562', 'Diferencia de cambio negativa', '{}'::jsonb, 'expense', false, '56', 1120),
  ('PY', 'default', '563', 'Redondeo', '{}'::jsonb, 'expense', false, '56', 1130),
  ('PY', 'default', '564', 'Descuentos otorgados', '{}'::jsonb, 'expense', false, '56', 1140),
  ('PY', 'default', '565', 'Gastos e intereses bancarios', '{}'::jsonb, 'expense', false, '56', 1150),
  ('PY', 'default', '57', 'Impuesto a la Renta Empresarial', '{}'::jsonb, 'expense', false, '5', 1160),
  ('PY', 'default', '58', 'Otros egresos', '{}'::jsonb, 'expense', false, '5', 1170)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PY', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('PY', 'BCO', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('PY', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('PY', 'CPR', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('PY', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('PY', 'VTA', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('PY', 'PY-C-10', 'Compra gravada, tasa general 10 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes o servicios gravada a la tasa general, atribuida directamente a operaciones gravadas en el mercado interno', 'percent', 10, 'purchase', 'domestic', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 88, numeral 1 — el IVA Crédito se integra con la suma del impuesto incluido en los comprobantes de compras en plaza realizadas en el mes; art. 89 — la deducción sólo procede cuando el bien o servicio esté afectado directa o indistintamente a operaciones gravadas, represente una erogación real y el comprobante identifique al comprador y el bien o servicio adquirido; art. 90, inciso g) — tasa del 10 %', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-C-10-NOCRED', 'Compra gravada, tasa general 10 %, sin derecho a crédito fiscal', '{}'::jsonb, 'Adquisición gravada a la tasa general, destinada exclusivamente a operaciones exoneradas o no alcanzadas por el impuesto', 'percent', 10, 'purchase', 'domestic', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 89, numeral 1 — el IVA Crédito sólo se deduce cuando el bien o servicio esté afectado directa o indistintamente a operaciones gravadas por el impuesto; art. 91 — para quien enajene bienes o preste servicios exonerados o no gravados, el impuesto consignado en los comprobantes de las compras relacionadas constituye un costo o gasto para el Impuesto a la Renta. El Formulario N.° 120 declara esta adquisición y su IVA en las casillas 59 y 65 del Rubro 6', null, null, 130, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-C-5', 'Compra gravada, tasa reducida 5 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes o servicios gravada a la tasa reducida, atribuida directamente a operaciones gravadas en el mercado interno', 'percent', 5, 'purchase', 'domestic', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 88, numeral 1, y art. 89 — requisitos del crédito fiscal; art. 90, incisos a), b), c), e) y f) — tasa del 5 %', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-C-5-NOCRED', 'Compra gravada, tasa reducida 5 %, sin derecho a crédito fiscal', '{}'::jsonb, 'Adquisición gravada a la tasa reducida, destinada exclusivamente a operaciones exoneradas o no alcanzadas por el impuesto', 'percent', 5, 'purchase', 'domestic', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 89, numeral 1, y art. 91 — el IVA de una adquisición destinada a una operación no gravada constituye costo o gasto para el Impuesto a la Renta. El Formulario N.° 120 declara esta adquisición y su IVA en las casillas 60 y 66 del Rubro 6', null, null, 140, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-C-EXO', 'Compra no gravada', '{}'::jsonb, 'Adquisición de bienes o servicios exentos, exonerados o no alcanzados por el IVA, relacionada a operaciones exoneradas o no alcanzadas', 'percent', 0, 'purchase', 'exempt', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 100 — bienes y servicios exonerados que el vendedor no traslada como IVA. El Formulario N.° 120 declara esta adquisición en la casilla 62 del Rubro 6, «Compras exentas relacionadas a operaciones exoneradas o no alcanzadas»', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-V-10', 'Venta gravada, tasa general 10 %', '{}'::jsonb, 'Enajenación de bienes y prestación de servicios gravada a la tasa general del Impuesto al Valor Agregado', 'percent', 10, 'sale', 'domestic', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 90, inciso g) — 10 % (diez por ciento) para todos los demás casos, distintos de los enumerados en los incisos a) a f) del mismo artículo', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-V-5', 'Venta gravada, tasa reducida 5 %', '{}'::jsonb, 'Enajenación de bienes y prestación de servicios gravada a la tasa reducida del 5 %: arrendamiento de inmuebles para vivienda, enajenación de inmuebles, productos de la canasta familiar, productos pecuarios, medicamentos de uso humano', 'percent', 5, 'sale', 'domestic', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 90, incisos a), b), c), e) y f) — 5 % para el arrendamiento de inmuebles destinados a la vivienda de manera exclusiva; para la enajenación de bienes inmuebles; para la enajenación e importación de los productos de la canasta familiar (arroz, fideos, aceite vegetal, yerba mate, leche, huevos, harina y sal yodada); para los productos pecuarios y sus derivados primarios sin transformación; y para los productos registrados como medicamentos de uso humano ante el Ministerio de Salud Pública y Bienestar Social. No incluye los productos agrícolas, hortícolas y frutícolas del inciso d), que este paquete no distingue de los demás bienes al 5 % — véase el README', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-V-EXO', 'Venta exonerada', '{}'::jsonb, 'Enajenación de bienes o prestación de servicios comprendida en las exoneraciones del artículo 100 de la Ley del IVA', 'percent', 0, 'sale', 'exempt', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 100 — enumera las enajenaciones e importaciones exoneradas (moneda extranjera y valores; libros y periódicos; bienes donados a entidades educativas sin fines de lucro) y las prestaciones de servicios exoneradas (intereses de valores públicos y privados; depósitos bancarios y financieros; enseñanza inicial, preescolar, básica, media, técnica, terciaria y universitaria reconocida; transporte público urbano e interurbano de pasajeros de hasta 100 km de recorrido total). El paquete declara la exoneración con esta cita genérica; el bien o servicio exonerado concreto y su inciso corresponden a cada operación y no al código — véase el README', null, null, 40, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null),
  ('PY', 'PY-V-EXP', 'Exportación de bienes, exonerada', '{}'::jsonb, 'Exportación de bienes', 'percent', 0, 'sale', 'export', date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 100, numeral 2 — está exonerada del IVA la exportación de bienes; el contribuyente debe conservar la copia de la documentación correspondiente debidamente contabilizada, y la Administración Tributaria puede exigir otros instrumentos que demuestren el arribo de la mercadería al destino previsto en el extranjero. A falta de esa documentación se presume de derecho que los bienes fueron enajenados en el mercado interno, debiendo abonarse el IVA. El paquete declara la exportación ordinaria de bienes; no distingue la exportación de productos agrícolas en estado natural, sujeta a un tratamiento distinto del crédito fiscal del exportador (art. 101) — véase el README', null, null, 30, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ley-6380', null, null, null, null)
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
    ('PY-C-10', 'invoice', 'base', 100, null, '35', array['35']::text[], 100, 'PY-F120', 10),
    ('PY-C-10', 'invoice', 'tax', 100, '1041', '38', array['38']::text[], 100, 'PY-F120', 20),
    ('PY-C-10', 'credit_note', 'base', 100, null, '35', array['35']::text[], -100, 'PY-F120', 10),
    ('PY-C-10', 'credit_note', 'tax', 100, '1041', '38', array['38']::text[], -100, 'PY-F120', 20),
    ('PY-C-10-NOCRED', 'invoice', 'base', 100, null, '59', array['59']::text[], 100, 'PY-F120', 10),
    ('PY-C-10-NOCRED', 'invoice', 'tax_on_base', 100, null, '65', array['65']::text[], 100, 'PY-F120', 20),
    ('PY-C-10-NOCRED', 'credit_note', 'base', 100, null, '59', array['59']::text[], -100, 'PY-F120', 10),
    ('PY-C-10-NOCRED', 'credit_note', 'tax_on_base', 100, null, '65', array['65']::text[], -100, 'PY-F120', 20),
    ('PY-C-5', 'invoice', 'base', 100, null, '32', array['32']::text[], 100, 'PY-F120', 10),
    ('PY-C-5', 'invoice', 'tax', 100, '1041', '38', array['38']::text[], 100, 'PY-F120', 20),
    ('PY-C-5', 'credit_note', 'base', 100, null, '32', array['32']::text[], -100, 'PY-F120', 10),
    ('PY-C-5', 'credit_note', 'tax', 100, '1041', '38', array['38']::text[], -100, 'PY-F120', 20),
    ('PY-C-5-NOCRED', 'invoice', 'base', 100, null, '60', array['60']::text[], 100, 'PY-F120', 10),
    ('PY-C-5-NOCRED', 'invoice', 'tax_on_base', 100, null, '66', array['66']::text[], 100, 'PY-F120', 20),
    ('PY-C-5-NOCRED', 'credit_note', 'base', 100, null, '60', array['60']::text[], -100, 'PY-F120', 10),
    ('PY-C-5-NOCRED', 'credit_note', 'tax_on_base', 100, null, '66', array['66']::text[], -100, 'PY-F120', 20),
    ('PY-C-EXO', 'invoice', 'base', 100, null, '62', array['62']::text[], 100, 'PY-F120', 10),
    ('PY-C-EXO', 'credit_note', 'base', 100, null, '62', array['62']::text[], -100, 'PY-F120', 10),
    ('PY-V-10', 'invoice', 'base', 100, null, '10', array['10']::text[], 100, 'PY-F120', 10),
    ('PY-V-10', 'invoice', 'tax', 100, '2031', '22', array['22']::text[], 100, 'PY-F120', 20),
    ('PY-V-10', 'credit_note', 'base', 100, null, '15', array['15']::text[], 100, 'PY-F120', 10),
    ('PY-V-10', 'credit_note', 'tax', 100, '2031', '23', array['23']::text[], 100, 'PY-F120', 20),
    ('PY-V-5', 'invoice', 'base', 100, null, '151', array['151']::text[], 100, 'PY-F120', 10),
    ('PY-V-5', 'invoice', 'tax', 100, '2031', '157', array['157']::text[], 100, 'PY-F120', 20),
    ('PY-V-5', 'credit_note', 'base', 100, null, '16', array['16']::text[], 100, 'PY-F120', 10),
    ('PY-V-5', 'credit_note', 'tax', 100, '2031', '20', array['20']::text[], 100, 'PY-F120', 20),
    ('PY-V-EXO', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'PY-F120', 10),
    ('PY-V-EXO', 'credit_note', 'base', 100, null, '17', array['17']::text[], 100, 'PY-F120', 10),
    ('PY-V-EXP', 'invoice', 'base', 100, null, '14', array['14']::text[], 100, 'PY-F120', 10),
    ('PY-V-EXP', 'credit_note', 'base', 100, null, '14', array['14']::text[], -100, 'PY-F120', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PY' and t.code = v.tax_code
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
  ('PY', 'PY-F120', 'Formulario N.° 120 — Declaración Jurada del Impuesto al Valor Agregado (IVA)', array['month']::declaration_period[], 'month'::declaration_period, date '2020-01-01', null, 'Ley N.° 6.380/2019, art. 86 — el impuesto se liquida mensualmente por la diferencia entre el IVA Débito y el IVA Crédito; art. 96 — el impuesto se liquida por declaración jurada, en la forma y oportunidad que establezca la Administración Tributaria. El Formulario N.° 120, Versión 4, es de uso obligatorio desde el período fiscal de enero de 2020 y se presenta exclusivamente por vía electrónica a través del Sistema de Gestión Tributaria Marangatú; las casillas de este paquete son las de su instructivo oficial', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Resolución General N.° 38/2020 — Calendario Perpetuo de Vencimientos: la fecha de vencimiento mensual de cada contribuyente se fija según el último dígito de su RUC, sin contar el dígito verificador, entre el día 7 (dígito 0) y el día 25 (dígito 9) del mes siguiente al que se liquida, avanzando de dos en dos días por dígito; si la fecha recae en día no laborable, se traslada al día hábil siguiente. El día exacto depende del RUC de cada contribuyente y no de una regla que el paquete pueda calcular por sí sola', 'vencimientos-38-2020', null)
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
  ('PY', 'PY-F120', '10', 'base', 'Enajenación de bienes y/o prestación de servicios gravados con tasa del 10 %', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 10 se debe consignar el monto imponible de las operaciones gravadas a la tasa del 10 % por enajenación de bienes y/o prestación de servicios»', 'f120-instructivo'),
  ('PY', 'PY-F120', '22', 'tax', 'IVA Débito — operaciones gravadas al 10 %', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 22 se consigna el IVA Débito correspondiente» a la casilla 10', 'f120-instructivo'),
  ('PY', 'PY-F120', '15', 'base', 'Ajustes de precios, devoluciones y descuentos, ventas a la tasa del 10 %', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 1, inciso f) — ajustes de precios, devoluciones realizadas, descuentos obtenidos y recupero de impuestos por operaciones incobrables, declaradas a la tasa del 10 %', 'f120-instructivo'),
  ('PY', 'PY-F120', '23', 'tax', 'IVA Débito — ajustes de ventas al 10 %', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 23 se debe consignar el IVA Débito correspondiente» a la casilla 15', 'f120-instructivo'),
  ('PY', 'PY-F120', '151', 'base', 'Enajenación de otros bienes y/o servicios gravados con tasa del 5 %', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 151 se debe consignar el monto imponible de las operaciones gravadas a la tasa del 5 % por enajenación de otros bienes (distintos a los productos agrícolas en estado natural del inciso b) y/o prestación de servicios»', 'f120-instructivo'),
  ('PY', 'PY-F120', '157', 'tax', 'IVA Débito — operaciones gravadas al 5 %', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 157 se consigna el IVA Débito correspondiente» a la casilla 151', 'f120-instructivo'),
  ('PY', 'PY-F120', '16', 'base', 'Ajustes de precios, devoluciones y descuentos, ventas a la tasa del 5 %', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 1, inciso g) — ajustes de precios, devoluciones realizadas, descuentos obtenidos y recupero de impuestos por operaciones incobrables, declaradas a la tasa del 5 %', 'f120-instructivo'),
  ('PY', 'PY-F120', '20', 'tax', 'IVA Débito — ajustes de ventas al 5 %', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 1 — columna IVA Débito al 5 % de la fila de ajustes del inciso g)', 'f120-instructivo'),
  ('PY', 'PY-F120', '12', 'base', 'Enajenación de bienes y/o prestación de servicios exonerados o no alcanzados', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 12 se debe consignar el monto correspondiente a las operaciones de enajenación de bienes y/o prestación de servicios exoneradas o no alcanzadas por el impuesto, incluidos los servicios digitales prestados para el exterior»', 'f120-instructivo'),
  ('PY', 'PY-F120', '17', 'base', 'Ajustes de precios, devoluciones y descuentos, ventas exoneradas o no alcanzadas', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 17 se debe consignar el monto de los ajustes de precios, devoluciones realizadas y descuentos obtenidos, por operaciones exoneradas o no alcanzadas por el impuesto»', 'f120-instructivo'),
  ('PY', 'PY-F120', '14', 'base', 'Exportación de bienes', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 14 se debe consignar el monto de la exportación de otros bienes», es decir, la exportación de bienes distinta de los productos agrícolas en estado natural del artículo 90, inciso d), numeral 1, y de los fletes de exportación', 'f120-instructivo'),
  ('PY', 'PY-F120', '32', 'base', 'Compras gravadas al 5 %, crédito atribuido directamente al mercado interno', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 3, inciso a) — crédito fiscal atribuido directamente a operaciones gravadas en el mercado interno, columna «al 5 %»', 'f120-instructivo'),
  ('PY', 'PY-F120', '35', 'base', 'Compras gravadas al 10 %, crédito atribuido directamente al mercado interno', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 3, inciso a) — crédito fiscal atribuido directamente a operaciones gravadas en el mercado interno, columna «al 10 %»', 'f120-instructivo'),
  ('PY', 'PY-F120', '38', 'tax', 'IVA Crédito atribuido directamente al mercado interno', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 38 se debe consignar la suma del IVA Crédito resultante de la aplicación de dichas tasas» a las casillas 32 y 35', 'f120-instructivo'),
  ('PY', 'PY-F120', '43', 'total', 'Total de crédito fiscal para operaciones en el mercado interno', '{}'::jsonb, 180, null, array['38']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — «En la casilla 43 se debe consignar el total del IVA Crédito atribuido a operaciones gravadas en el mercado interno, resultante de la suma de las casillas 38, 164, 165 y 42». Este paquete no atribuye crédito de forma indistinta ni proporcional, ni declara los ajustes de la casilla 42 (Rubro 3, inciso e — cuyo propio instructivo los describe, de forma inconsistente con el resto del Rubro 3, como referidos a «ventas ya declaradas»), por lo que la suma se limita a la casilla 38 y las notas de crédito de compra se declaran con signo negativo sobre las mismas casillas 32/35/38 de la factura original — véase el README', 'f120-instructivo'),
  ('PY', 'PY-F120', '59', 'base', 'Compras con crédito fiscal del 10 %, relacionadas directamente a operaciones exoneradas o no alcanzadas', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 6, inciso a) — compras con crédito fiscal del 10 % relacionadas directamente a operaciones exoneradas o no alcanzadas', 'f120-instructivo'),
  ('PY', 'PY-F120', '65', 'base', 'IVA de las compras al 10 % relacionadas a operaciones exoneradas', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 6, inciso a) — IVA correspondiente a la casilla 59', 'f120-instructivo'),
  ('PY', 'PY-F120', '60', 'base', 'Compras con crédito fiscal del 5 %, relacionadas directamente a operaciones exoneradas o no alcanzadas', '{}'::jsonb, 210, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 6, inciso b) — compras con crédito fiscal del 5 % relacionadas directamente a operaciones exoneradas o no alcanzadas', 'f120-instructivo'),
  ('PY', 'PY-F120', '66', 'base', 'IVA de las compras al 5 % relacionadas a operaciones exoneradas', '{}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 6, inciso b) — IVA correspondiente a la casilla 60', 'f120-instructivo'),
  ('PY', 'PY-F120', '62', 'base', 'Compras exentas relacionadas a operaciones exoneradas o no alcanzadas', '{}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 6, inciso d) — compras exentas relacionadas a operaciones exoneradas o no alcanzadas', 'f120-instructivo'),
  ('PY', 'PY-F120', '64', 'total', 'IVA Costo/Gasto', '{}'::jsonb, 240, null, array['65', '66']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo del Formulario N.° 120 — la casilla 64 consigna la suma correspondiente al IVA Costo y/o Gasto del período, entre otros conceptos, la sumatoria de las casillas 65 y 66 del Rubro 6', 'f120-instructivo'),
  ('PY', 'PY-F120', '44', 'total', 'Débito fiscal', '{}'::jsonb, 250, null, array['22', '157', '23', '20']::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 4, inciso a) — débito fiscal, proveniente del Rubro 1, columnas II y III del inciso «Total»', 'f120-instructivo'),
  ('PY', 'PY-F120', '45', 'total', 'Crédito fiscal', '{}'::jsonb, 260, null, array['43']::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 4, inciso b) — crédito fiscal, proveniente del Rubro 3, inciso f) (casilla 43 en este paquete)', 'f120-instructivo'),
  ('PY', 'PY-F120', '48', 'total', 'Saldo a favor del Fisco', '{}'::jsonb, 270, null, array['44']::text[], array['45']::text[], null, null, true, false, null, 'Formulario N.° 120, Versión 3, Rubro 4, inciso e) — saldo a favor del Fisco, cuando el débito fiscal (inciso a) es mayor que la suma del crédito fiscal (inciso b) más el saldo a favor del período anterior (inciso c), aquí no declarado', 'f120-instructivo'),
  ('PY', 'PY-F120', '47', 'total', 'Saldo a favor del contribuyente', '{}'::jsonb, 280, null, array['45']::text[], array['44']::text[], null, null, true, false, null, 'Formulario N.° 120, Versión 3, Rubro 4, inciso d) — saldo a favor del contribuyente, a trasladar al período fiscal siguiente, cuando el débito fiscal (inciso a) es menor que el crédito fiscal (inciso b)', 'f120-instructivo'),
  ('PY', 'PY-F120', '50', 'total', 'Impuesto determinado', '{}'::jsonb, 290, null, array['48']::text[], '{}'::text[], null, null, false, false, null, 'Formulario N.° 120, Versión 3, Rubro 4, inciso g) — impuesto determinado, diferencia entre el saldo a favor del Fisco (inciso e) y el crédito fiscal por exportación utilizado en el período (inciso f), aquí no declarado por no modelar este paquete el Anexo del Exportador — véase el README', 'f120-instructivo')
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
  ('PY-ER', 'PY', 'default', 'Estado de resultados', 'income_statement', 'PY-LC', date '1970-01-01', null, 'Ley N.° 1.034/1983, art. 82 — el libro de Inventario registra, al cierre de cada ejercicio, el «cuadro demostrativo de ganancias y pérdidas»; Código Civil, art. 1079 — la asamblea ordinaria de una sociedad anónima considera la «cuenta de ganancias y pérdidas» del ejercicio. Ninguno de los dos textos prescribe rubros: este esquema agrupa los ingresos y los gastos por naturaleza — véase el README.md', 'comerciante-1034'),
  ('PY-ESP', 'PY', 'default', 'Estado de situación patrimonial (Balance general)', 'balance_sheet', 'PY-LC', date '1970-01-01', null, 'Ley N.° 1.034/1983, Del Comerciante, art. 82 — el libro de Inventario registra la situación patrimonial al iniciar las operaciones, con indicación y valoración del activo y del pasivo, y, al cierre de cada ejercicio, la situación patrimonial correspondiente; art. 83 — todo comerciante confecciona dentro de los tres primeros meses de cada año el balance general de sus operaciones, con una relación precisa de sus bienes, créditos y acciones, así como de sus obligaciones pendientes a la fecha de balance. Para una sociedad anónima, el Código Civil, art. 1079, añade que la asamblea ordinaria debe considerar y resolver el balance del ejercicio dentro de los cuatro meses del cierre. Ninguno de los dos textos prescribe cuentas ni rubros: este esquema es una estructura original sobre los rubros mínimos que exigen — véase el README.md', 'comerciante-1034')
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
  ('PY-ER', 'VEN', null, 'Ventas netas', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — ganancias del ejercicio, ventas', 'comerciante-1034'),
  ('PY-ER', 'CV', null, 'Costo de ventas', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — pérdidas del ejercicio, costo de lo vendido', 'comerciante-1034'),
  ('PY-ER', 'RB', null, 'Resultado bruto', '{}'::jsonb, 30, 1, true, array['VEN']::text[], array['CV']::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ER', 'GC', null, 'Gastos de comercialización', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — pérdidas del ejercicio, gastos de comercialización', 'comerciante-1034'),
  ('PY-ER', 'GA', null, 'Gastos de administración', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — pérdidas del ejercicio, gastos de administración', 'comerciante-1034'),
  ('PY-ER', 'RO', null, 'Resultado operativo', '{}'::jsonb, 60, 1, true, array['RB']::text[], array['GC', 'GA']::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ER', 'RFPOS', null, 'Resultados financieros positivos', '{}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — ganancias del ejercicio, resultados financieros, incluida la diferencia de cambio', 'comerciante-1034'),
  ('PY-ER', 'RFNEG', null, 'Resultados financieros negativos', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — pérdidas del ejercicio, resultados financieros', 'comerciante-1034'),
  ('PY-ER', 'OTRI', null, 'Otros ingresos', '{}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ER', 'OTRE', null, 'Otros egresos', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ER', 'RAI', null, 'Resultado antes del Impuesto a la Renta Empresarial', '{}'::jsonb, 110, 1, true, array['RO', 'RFPOS', 'OTRI']::text[], array['RFNEG', 'OTRE']::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ER', 'IRE', null, 'Impuesto a la Renta Empresarial', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 6.380/2019, Libro I, Impuesto a la Renta Empresarial — no modelado por este paquete; la cuenta existe para que el estado de resultados pueda presentarlo cuando la empresa lo liquide manualmente. Ver README.md', 'ley-6380'),
  ('PY-ER', 'RN', null, 'Resultado neto del ejercicio', '{}'::jsonb, 130, 1, true, array['RAI']::text[], array['IRE']::text[], null, 'Código Civil, Ley N.° 1.183/1985, art. 1079 — determinación de la ganancia o pérdida neta del ejercicio', 'codigo-civil'),
  ('PY-ESP', 'DISP', null, 'Disponibilidades', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — indicación y valoración del activo, rubro disponibilidades', 'comerciante-1034'),
  ('PY-ESP', 'CXV', null, 'Créditos por ventas', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — indicación y valoración del activo, rubro créditos', 'comerciante-1034'),
  ('PY-ESP', 'OCR', null, 'Otros créditos', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — indicación y valoración del activo, otros créditos', 'comerciante-1034'),
  ('PY-ESP', 'CFI', null, 'Créditos fiscales', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 6.380/2019, art. 88 — el IVA Crédito del período y el saldo a favor del contribuyente', 'ley-6380'),
  ('PY-ESP', 'BCA', null, 'Bienes de cambio', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — indicación y valoración del activo, bienes de cambio', 'comerciante-1034'),
  ('PY-ESP', 'PPI', null, 'Partidas pendientes de imputación', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de uso interno, sin correspondencia en un rubro propio del art. 82 de la Ley N.° 1.034/1983', 'comerciante-1034'),
  ('PY-ESP', 'AC', null, 'Total del activo corriente', '{}'::jsonb, 70, 1, true, array['DISP', 'CXV', 'OCR', 'CFI', 'BCA', 'PPI']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'CNC', null, 'Créditos no corrientes', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'BUS', null, 'Bienes de uso', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — indicación y valoración del activo, bienes de uso', 'comerciante-1034'),
  ('PY-ESP', 'AIN', null, 'Activos intangibles', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'ANC', null, 'Total del activo no corriente', '{}'::jsonb, 110, 1, true, array['CNC', 'BUS', 'AIN']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'ACT', null, 'Total del activo', '{}'::jsonb, 120, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'CPC', null, 'Cuentas por pagar comerciales', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82 — obligaciones pendientes a la fecha de balance, deudas comerciales', 'comerciante-1034'),
  ('PY-ESP', 'REM', null, 'Remuneraciones y cargas sociales a pagar', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'CFP', null, 'Cargas fiscales a pagar', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 6.380/2019, art. 86 — el IVA a pagar cuando el débito fiscal supera al crédito fiscal del período', 'ley-6380'),
  ('PY-ESP', 'ANT', null, 'Anticipos de clientes', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'PRO', null, 'Provisiones', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'PC', null, 'Total del pasivo corriente', '{}'::jsonb, 180, 1, true, array['CPC', 'REM', 'CFP', 'ANT', 'PRO']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'DBL', null, 'Deudas bancarias no corrientes', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'ODL', null, 'Otras deudas no corrientes', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'PNC', null, 'Total del pasivo no corriente', '{}'::jsonb, 210, 1, true, array['DBL', 'ODL']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'PAS', null, 'Total del pasivo', '{}'::jsonb, 220, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034'),
  ('PY-ESP', 'CAP', null, 'Capital integrado', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'Código Civil, Ley N.° 1.183/1985, art. 1079 — patrimonio de la sociedad', 'codigo-civil'),
  ('PY-ESP', 'RES', null, 'Reservas', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Código Civil, Ley N.° 1.183/1985, art. 1079 — reserva legal y otras reservas', 'codigo-civil'),
  ('PY-ESP', 'RNA', null, 'Resultados acumulados', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Código Civil, Ley N.° 1.183/1985, art. 1079 — distribución de utilidades resuelta por la asamblea', 'codigo-civil'),
  ('PY-ESP', 'REJ', null, 'Resultado del ejercicio', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Código Civil, Ley N.° 1.183/1985, art. 1079 — balance y cuenta de ganancias y pérdidas del ejercicio, hasta que la asamblea resuelva su afectación', 'codigo-civil'),
  ('PY-ESP', 'PN', null, 'Total del patrimonio neto', '{}'::jsonb, 270, 1, true, array['CAP', 'RES', 'RNA', 'REJ']::text[], '{}'::text[], null, 'Código Civil, Ley N.° 1.183/1985, art. 1079', 'codigo-civil'),
  ('PY-ESP', 'PASPN', null, 'Total del pasivo más patrimonio neto', '{}'::jsonb, 280, 1, true, array['PAS', 'PN']::text[], '{}'::text[], null, 'Ley N.° 1.034/1983, art. 82', 'comerciante-1034')
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
    ('PY-ER', 'VEN', 10, 'code_prefix', '41', null, null, 'any'),
    ('PY-ER', 'CV', 10, 'code_prefix', '51', null, null, 'any'),
    ('PY-ER', 'GC', 10, 'code_prefix', '52', null, null, 'any'),
    ('PY-ER', 'GA', 10, 'code_prefix', '53', null, null, 'any'),
    ('PY-ER', 'RFPOS', 10, 'code_prefix', '46', null, null, 'any'),
    ('PY-ER', 'RFNEG', 10, 'code_prefix', '56', null, null, 'any'),
    ('PY-ER', 'OTRI', 10, 'code_prefix', '48', null, null, 'any'),
    ('PY-ER', 'OTRE', 10, 'code_prefix', '58', null, null, 'any'),
    ('PY-ER', 'IRE', 10, 'code_prefix', '57', null, null, 'any'),
    ('PY-ESP', 'DISP', 10, 'code_prefix', '101', null, null, 'any'),
    ('PY-ESP', 'CXV', 10, 'code_prefix', '102', null, null, 'any'),
    ('PY-ESP', 'OCR', 10, 'code_prefix', '103', null, null, 'any'),
    ('PY-ESP', 'CFI', 10, 'code_prefix', '104', null, null, 'any'),
    ('PY-ESP', 'BCA', 10, 'code_prefix', '105', null, null, 'any'),
    ('PY-ESP', 'PPI', 10, 'code_prefix', '106', null, null, 'any'),
    ('PY-ESP', 'CNC', 10, 'code_prefix', '111', null, null, 'any'),
    ('PY-ESP', 'BUS', 10, 'code_prefix', '112', null, null, 'any'),
    ('PY-ESP', 'AIN', 10, 'code_prefix', '113', null, null, 'any'),
    ('PY-ESP', 'CPC', 10, 'code_prefix', '201', null, null, 'any'),
    ('PY-ESP', 'REM', 10, 'code_prefix', '202', null, null, 'any'),
    ('PY-ESP', 'CFP', 10, 'code_prefix', '203', null, null, 'any'),
    ('PY-ESP', 'ANT', 10, 'code_prefix', '204', null, null, 'any'),
    ('PY-ESP', 'PRO', 10, 'code_prefix', '205', null, null, 'any'),
    ('PY-ESP', 'DBL', 10, 'code_prefix', '211', null, null, 'any'),
    ('PY-ESP', 'ODL', 10, 'code_prefix', '212', null, null, 'any'),
    ('PY-ESP', 'CAP', 10, 'code_prefix', '31', null, null, 'any'),
    ('PY-ESP', 'RES', 10, 'code_prefix', '32', null, null, 'any'),
    ('PY-ESP', 'RES', 20, 'code_prefix', '33', null, null, 'any'),
    ('PY-ESP', 'RNA', 10, 'code_prefix', '34', null, null, 'any'),
    ('PY-ESP', 'REJ', 10, 'code_prefix', '35', null, null, 'any')
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
  ('PY', 'Paraguay', '{}'::jsonb, array['es']::text[], 'PYG', '1021', '2011', '106', '563', '341', '411', '511', '1012', '1011', 'VTA', 'CPR', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', default, default, '462', '562', null, null, null, null, '2032', '1042', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Ley N.° 1.034/1983, Del Comerciante, art. 76 — el libro Diario debe llevarse con asientos que permitan la individualización de las operaciones, así como sus correspondientes cuentas deudoras y acreedoras y su posterior verificación. El número que declara este paquete es el de la pieza contable, correlativo por diario, y no el número de timbrado, establecimiento y punto de expedición que el Sistema Integrado de Facturación Electrónica Nacional (SIFEN) asigna al comprobante de venta electrónico — véase «Ekwo no emite un comprobante de venta paraguayo»',
  numbering_source_key          = 'comerciante-1034',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Ley N.° 6.380/2019, art. 83, numeral 1 — la configuración del hecho imponible se produce con el primero de estos hechos: a) la entrega del bien o la prestación del servicio; b) la percepción del importe total o de un pago parcial; c) el vencimiento del plazo previsto para el pago del servicio. Los incisos a) y b) son la entrega y el cobro, el primero que ocurra — earliest_of_delivery_or_payment en el vocabulario de este formato —; el inciso c), un tercer hecho que adelanta la obligación al vencimiento de un plazo de pago aun sin cobro ni entrega, no tiene una palabra en este vocabulario y queda sin representar — véase el README. El art. 92 exige además que el comprobante de venta se emita coincidiendo con el nacimiento de la obligación, salvo los casos de los numerales 4, 5 y 6 del art. 83 (suministros por vencimiento de plazo, importaciones y servicios desde el exterior)',
  tax_point_source_key          = 'ley-6380',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ley N.° 1.034/1983, art. 79 — no podrán hacerse enmiendas, raspaduras ni cualquier otra alteración en los libros de contabilidad, y si fuere necesaria alguna rectificación, ésta debe practicarse mediante el correspondiente contraasiento. Un documento contabilizado se anula con una nota de crédito que lo referencia, nunca volviendo a borrador',
  posted_edit_policy_source_key = 'comerciante-1034',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'El comprobante de venta exigido en Paraguay es, para un número creciente de contribuyentes, un Documento Tributario Electrónico (DTE) del Sistema Integrado de Facturación Electrónica Nacional (SIFEN), cuya marca pública es e-Kuatia: Decreto N.° 7.795/2017, que crea el SIFEN y faculta a la Administración Tributaria a implementar la obligación de manera gradual, en fases de plan piloto, adhesión voluntaria y obligatoriedad; sucesivas Resoluciones Generales (entre ellas la N.° 95/2021) incorporan nuevos grupos de contribuyentes obligados, y desde enero de 2026 alcanzan a los proveedores del Estado y a nuevos grupos incorporados hasta 2027. El DTE sólo existe una vez que su archivo XML, firmado digitalmente, es transmitido al SIFEN y validado por éste — antes o después de la entrega al receptor, según el modelo de aprobación elegido —, control de tipo «clearance» y no un intercambio directo entre las partes. Ekwo no genera, no firma digitalmente ni transmite el XML del DTE: ningún componente de packages/formats habla con el SIFEN. Por eso profile y mandatory_from quedan vacíos aunque la obligación exista y esté en expansión: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats redacta y transmite por Peppol, y el DTE paraguayo no es ni lo uno ni lo otro; el formato tampoco tiene una palabra para «válido sólo tras la validación del SIFEN» — véase «Ekwo no emite un comprobante de venta paraguayo» y docs/international.md. El RUC identifica al emisor y al receptor y no tiene código ISO 6523 propio: party_scheme y vat_scheme quedan vacíos',
  einvoice_source_key           = 'sifen-manual',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'PY';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('PY', 'dte_not_issued', 'always', 'Este documento no es un Documento Tributario Electrónico (DTE) del Sistema Integrado de Facturación Electrónica Nacional (SIFEN): no ha sido firmado digitalmente por un facturador electrónico ni validado por la Dirección Nacional de Ingresos Tributarios (DNIT). Sólo el DTE aprobado por el SIFEN, o el comprobante de venta timbrado, respalda la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Decreto N.° 7.795/2017, art. 2° — el documento tributario electrónico es el emitido por el facturador electrónico con firma digital, validado formalmente por la Administración Tributaria, y que sirve para respaldar el débito y el crédito fiscal del IVA. Ekwo no emite, no firma digitalmente ni transmite documentos al SIFEN: ningún componente de packages/formats habla con el SIFEN — véase «Ekwo no emite un comprobante de venta paraguayo»'),
  ('PY', 'export', 'export', 'Exportación de bienes, exonerada del Impuesto al Valor Agregado (artículo 100, numeral 2, de la Ley N.° 6.380/2019).', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley N.° 6.380/2019, art. 100, numeral 2 — está exonerada del IVA la exportación de bienes, debiendo el contribuyente conservar la documentación que acredite el arribo de la mercadería al destino previsto en el extranjero'),
  ('PY', 'exempt', 'exempt', 'Operación exonerada del Impuesto al Valor Agregado (artículo 100 de la Ley N.° 6.380/2019).', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley N.° 6.380/2019, art. 100 — enumera las enajenaciones, prestaciones de servicios e importaciones exoneradas del IVA')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
