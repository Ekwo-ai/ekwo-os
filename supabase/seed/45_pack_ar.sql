-- Ekwo OS — Argentina: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ar at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ar`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley de Impuesto al Valor Agregado — texto ordenado en 1997 y sus modificaciones (Decreto 280/1997) (Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa)
--     https://servicios.infoleg.gob.ar/infolegInternet/anexos/40000-44999/42701/texact.htm
--   Decreto Reglamentario 692/1998 de la Ley de Impuesto al Valor Agregado, texto ordenado y sus modificaciones (Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa)
--     https://servicios.infoleg.gob.ar/infolegInternet/verNorma.do?id=51323
--   Ley General de Sociedades N.º 19.550, texto ordenado 1984 y sus modificaciones — Sección IX, De la documentación y de la contabilidad, arts. 61 a 73 (Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa)
--     https://servicios.infoleg.gob.ar/infolegInternet/anexos/25000-29999/25553/texact.htm
--   Código Civil y Comercial de la Nación (Ley 26.994) — Capítulo 4, De la contabilidad y estados contables, arts. 320 a 331 (Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa)
--     https://servicios.infoleg.gob.ar/infolegInternet/verNorma.do?id=235975
--   Decreto 953/2024 — Disolución de la Administración Federal de Ingresos Públicos (AFIP) y creación de la Agencia de Recaudación y Control Aduanero (ARCA) (Poder Ejecutivo Nacional — Boletín Oficial de la República Argentina)
--     https://www.argentina.gob.ar/normativa/nacional/decreto-953-2024-405666
--   Resolución General (AFIP) 4290/2018 — Facturación y registración. Simplificación normativa. Generalización de la emisión de comprobantes electrónicos o mediante controlador fiscal (Administración Federal de Ingresos Públicos (hoy Agencia de Recaudación y Control Aduanero) — Boletín Oficial)
--     https://www.argentina.gob.ar/normativa/nacional/norma-313087/texto
--   Resolución General (AFIP) 4291/2018 — Régimen de emisión de comprobantes electrónicos originales (factura electrónica, Código de Autorización Electrónico, CAE), en sustitución de la Resolución General 2485 y sus modificatorias (Administración Federal de Ingresos Públicos (hoy Agencia de Recaudación y Control Aduanero) — Boletín Oficial)
--     https://www.argentina.gob.ar/normativa/nacional/resoluci%C3%B3n-4291-2018-313088/actualizacion
--   Resolución General (ARCA) 5705/2025 — Régimen de determinación e ingreso del Impuesto al Valor Agregado. "IVA Simple". Formulario de declaración jurada F. 2051, en sustitución de los formularios F. 731, F. 810, F. 2082 y F. 2002 "IVA por Actividad" (Agencia de Recaudación y Control Aduanero — Boletín Oficial)
--     https://www.argentina.gob.ar/normativa/nacional/resoluci%C3%B3n-5705-2025-413494/texto
--   Resolución General (AFIP) 4172/2017 y sus modificatorias — Agenda General de Vencimientos, cronograma de vencimientos por terminación de C.U.I.T. (Administración Federal de Ingresos Públicos (hoy Agencia de Recaudación y Control Aduanero))
--     https://servicios.infoleg.gob.ar/infolegInternet/anexos/305000-309999/305148/norma.htm
--   IVA — Formularios y presentación de la declaración jurada (Agencia de Recaudación y Control Aduanero — Portal de trámites y servicios)
--     https://www.arca.gob.ar/iva/formularios/iva-listo.asp
--   Factura electrónica — Emisión y autorización, sujetos obligados (Agencia de Recaudación y Control Aduanero — Portal de trámites y servicios)
--     https://www.afip.gob.ar/fe/emision-autorizacion/sujetos.asp
--   Resoluciones Técnicas de la Federación Argentina de Consejos Profesionales de Ciencias Económicas (FACPCE), en particular la RT 8 (Normas generales de exposición contable) y la RT 9 (Normas particulares de exposición contable para entes comerciales, industriales y de servicios) (Federación Argentina de Consejos Profesionales de Ciencias Económicas (FACPCE))
--     https://www.facpce.org.ar/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('AR', 'Argentina', '0.1.0', date '2026-09-25', '20260921084143', 'community', null, null, '03bbfd5e163247ac55912a47975952ef4f01f01422f7f475c833ebe072cc1c8d', '[{"key":"liva","title":"Ley de Impuesto al Valor Agregado — texto ordenado en 1997 y sus modificaciones (Decreto 280/1997)","publisher":"Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa","url":"https://servicios.infoleg.gob.ar/infolegInternet/anexos/40000-44999/42701/texact.htm","consulted_on":"2026-09-25","kind":"law"},{"key":"rliva","title":"Decreto Reglamentario 692/1998 de la Ley de Impuesto al Valor Agregado, texto ordenado y sus modificaciones","publisher":"Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa","url":"https://servicios.infoleg.gob.ar/infolegInternet/verNorma.do?id=51323","consulted_on":"2026-09-25","kind":"regulation"},{"key":"lgs","title":"Ley General de Sociedades N.º 19.550, texto ordenado 1984 y sus modificaciones — Sección IX, De la documentación y de la contabilidad, arts. 61 a 73","publisher":"Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa","url":"https://servicios.infoleg.gob.ar/infolegInternet/anexos/25000-29999/25553/texact.htm","consulted_on":"2026-09-25","kind":"law"},{"key":"ccyc","title":"Código Civil y Comercial de la Nación (Ley 26.994) — Capítulo 4, De la contabilidad y estados contables, arts. 320 a 331","publisher":"Ministerio de Justicia y Derechos Humanos — InfoLeg, Información Legislativa","url":"https://servicios.infoleg.gob.ar/infolegInternet/verNorma.do?id=235975","consulted_on":"2026-09-25","kind":"law"},{"key":"decreto953-2024","title":"Decreto 953/2024 — Disolución de la Administración Federal de Ingresos Públicos (AFIP) y creación de la Agencia de Recaudación y Control Aduanero (ARCA)","publisher":"Poder Ejecutivo Nacional — Boletín Oficial de la República Argentina","url":"https://www.argentina.gob.ar/normativa/nacional/decreto-953-2024-405666","consulted_on":"2026-09-25","kind":"regulation"},{"key":"rg4290","title":"Resolución General (AFIP) 4290/2018 — Facturación y registración. Simplificación normativa. Generalización de la emisión de comprobantes electrónicos o mediante controlador fiscal","publisher":"Administración Federal de Ingresos Públicos (hoy Agencia de Recaudación y Control Aduanero) — Boletín Oficial","url":"https://www.argentina.gob.ar/normativa/nacional/norma-313087/texto","consulted_on":"2026-09-25","kind":"regulation"},{"key":"rg4291","title":"Resolución General (AFIP) 4291/2018 — Régimen de emisión de comprobantes electrónicos originales (factura electrónica, Código de Autorización Electrónico, CAE), en sustitución de la Resolución General 2485 y sus modificatorias","publisher":"Administración Federal de Ingresos Públicos (hoy Agencia de Recaudación y Control Aduanero) — Boletín Oficial","url":"https://www.argentina.gob.ar/normativa/nacional/resoluci%C3%B3n-4291-2018-313088/actualizacion","consulted_on":"2026-09-25","kind":"regulation"},{"key":"rg5705-2025","title":"Resolución General (ARCA) 5705/2025 — Régimen de determinación e ingreso del Impuesto al Valor Agregado. \"IVA Simple\". Formulario de declaración jurada F. 2051, en sustitución de los formularios F. 731, F. 810, F. 2082 y F. 2002 \"IVA por Actividad\"","publisher":"Agencia de Recaudación y Control Aduanero — Boletín Oficial","url":"https://www.argentina.gob.ar/normativa/nacional/resoluci%C3%B3n-5705-2025-413494/texto","consulted_on":"2026-09-25","kind":"regulation"},{"key":"rg4172","title":"Resolución General (AFIP) 4172/2017 y sus modificatorias — Agenda General de Vencimientos, cronograma de vencimientos por terminación de C.U.I.T.","publisher":"Administración Federal de Ingresos Públicos (hoy Agencia de Recaudación y Control Aduanero)","url":"https://servicios.infoleg.gob.ar/infolegInternet/anexos/305000-309999/305148/norma.htm","consulted_on":"2026-09-25","kind":"regulation"},{"key":"arca-iva-portal","title":"IVA — Formularios y presentación de la declaración jurada","publisher":"Agencia de Recaudación y Control Aduanero — Portal de trámites y servicios","url":"https://www.arca.gob.ar/iva/formularios/iva-listo.asp","consulted_on":"2026-09-25","kind":"portal"},{"key":"arca-fe-portal","title":"Factura electrónica — Emisión y autorización, sujetos obligados","publisher":"Agencia de Recaudación y Control Aduanero — Portal de trámites y servicios","url":"https://www.afip.gob.ar/fe/emision-autorizacion/sujetos.asp","consulted_on":"2026-09-25","kind":"portal"},{"key":"facpce","title":"Resoluciones Técnicas de la Federación Argentina de Consejos Profesionales de Ciencias Económicas (FACPCE), en particular la RT 8 (Normas generales de exposición contable) y la RT 9 (Normas particulares de exposición contable para entes comerciales, industriales y de servicios)","publisher":"Federación Argentina de Consejos Profesionales de Ciencias Económicas (FACPCE)","url":"https://www.facpce.org.ar/","consulted_on":"2026-09-25","kind":"standard"}]'::jsonb)
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
  ('AR', 'default', 'Plan de cuentas de referencia sobre la estructura de los arts. 63 y 64 de la Ley General de Sociedades', '{}'::jsonb, true, 'companies', array['AR-ER', 'AR-ESP']::text[], null, 'La República Argentina no impone un plan de cuentas único ni numerado: el Código Civil y Comercial, art. 321, exige sólo que la contabilidad sea llevada "sobre una base uniforme" que permita "la individualización de las operaciones", y el art. 322 enumera los registros indispensables (diario; inventario y balances) sin prescribir cuentas. La Ley General de Sociedades, arts. 63 y 64, fija en cambio el contenido mínimo del estado de situación patrimonial y del estado de resultados — activo corriente y no corriente, pasivo corriente y no corriente, patrimonio neto; ingresos por ventas o servicios agrupados por tipo de actividad, costo de lo vendido, gastos de comercialización y de administración, resultados financieros y por tenencia, resultado del ejercicio. Este plan es original: sigue una numeración propia de cuatro dígitos y cada bloque de códigos corresponde a una línea de AR-ESP o de AR-ER, de modo que las cuentas de este paquete se leen directamente sobre esos dos esquemas. Las Resoluciones Técnicas de la FACPCE (en especial la RT 8 y la RT 9) son la fuente profesional de la presentación de los estados contables, pero la Federación es una entidad profesional y no un organismo del Estado, y su texto no se transcribe aquí; ver README.md', 'lgs')
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
  ('AR', 'default', '100', 'Activo', '{}'::jsonb, 'asset_current', false, null, 10),
  ('AR', 'default', '110', 'Activo corriente', '{}'::jsonb, 'asset_current', false, '100', 20),
  ('AR', 'default', '111', 'Caja y bancos', '{}'::jsonb, 'asset_cash', false, '110', 30),
  ('AR', 'default', '1111', 'Caja', '{}'::jsonb, 'asset_cash', false, '111', 40),
  ('AR', 'default', '1112', 'Bancos', '{}'::jsonb, 'asset_cash', false, '111', 50),
  ('AR', 'default', '112', 'Inversiones corrientes', '{}'::jsonb, 'asset_current', false, '110', 60),
  ('AR', 'default', '113', 'Créditos por ventas', '{}'::jsonb, 'asset_receivable', true, '110', 70),
  ('AR', 'default', '1131', 'Deudores por ventas - Mercado interno', '{}'::jsonb, 'asset_receivable', true, '113', 80),
  ('AR', 'default', '1132', 'Deudores por ventas - Exterior', '{}'::jsonb, 'asset_receivable', true, '113', 90),
  ('AR', 'default', '1133', 'Documentos a cobrar', '{}'::jsonb, 'asset_receivable', true, '113', 100),
  ('AR', 'default', '114', 'Otros créditos', '{}'::jsonb, 'asset_current', false, '110', 110),
  ('AR', 'default', '1141', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '114', 120),
  ('AR', 'default', '1142', 'Gastos pagados por adelantado', '{}'::jsonb, 'asset_prepayments', false, '114', 130),
  ('AR', 'default', '1143', 'Anticipo Impuesto a las Ganancias', '{}'::jsonb, 'asset_current', false, '114', 140),
  ('AR', 'default', '1144', 'Préstamos a sociedades relacionadas', '{}'::jsonb, 'asset_current', false, '114', 141),
  ('AR', 'default', '1145', 'Créditos con socios y accionistas', '{}'::jsonb, 'asset_current', false, '114', 142),
  ('AR', 'default', '1146', 'Depósitos en garantía', '{}'::jsonb, 'asset_current', false, '114', 143),
  ('AR', 'default', '115', 'Créditos fiscales', '{}'::jsonb, 'asset_current', false, '110', 150),
  ('AR', 'default', '1151', 'IVA Crédito Fiscal', '{}'::jsonb, 'asset_current', false, '115', 160),
  ('AR', 'default', '1152', 'IVA Saldo a Favor - Técnico', '{}'::jsonb, 'asset_current', true, '115', 170),
  ('AR', 'default', '116', 'Bienes de cambio', '{}'::jsonb, 'asset_current', false, '110', 180),
  ('AR', 'default', '1161', 'Materias primas', '{}'::jsonb, 'asset_current', false, '116', 181),
  ('AR', 'default', '1162', 'Productos en proceso de elaboración', '{}'::jsonb, 'asset_current', false, '116', 182),
  ('AR', 'default', '1163', 'Productos terminados', '{}'::jsonb, 'asset_current', false, '116', 183),
  ('AR', 'default', '1164', 'Mercaderías de reventa', '{}'::jsonb, 'asset_current', false, '116', 184),
  ('AR', 'default', '1165', 'Envases y embalajes', '{}'::jsonb, 'asset_current', false, '116', 185),
  ('AR', 'default', '117', 'Partidas pendientes de imputación', '{}'::jsonb, 'asset_current', false, '110', 190),
  ('AR', 'default', '120', 'Activo no corriente', '{}'::jsonb, 'asset_non_current', false, '100', 200),
  ('AR', 'default', '121', 'Créditos no corrientes', '{}'::jsonb, 'asset_non_current', false, '120', 210),
  ('AR', 'default', '122', 'Bienes de uso', '{}'::jsonb, 'asset_fixed', false, '120', 220),
  ('AR', 'default', '1221', 'Bienes de uso - Valor de origen', '{}'::jsonb, 'asset_fixed', false, '122', 230),
  ('AR', 'default', '12211', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '1221', 231),
  ('AR', 'default', '12212', 'Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '1221', 232),
  ('AR', 'default', '12213', 'Maquinarias y equipos', '{}'::jsonb, 'asset_fixed', false, '1221', 233),
  ('AR', 'default', '12214', 'Muebles y útiles', '{}'::jsonb, 'asset_fixed', false, '1221', 234),
  ('AR', 'default', '12215', 'Rodados', '{}'::jsonb, 'asset_fixed', false, '1221', 235),
  ('AR', 'default', '12216', 'Equipos de computación', '{}'::jsonb, 'asset_fixed', false, '1221', 236),
  ('AR', 'default', '12217', 'Instalaciones', '{}'::jsonb, 'asset_fixed', false, '1221', 237),
  ('AR', 'default', '1222', 'Bienes de uso - Amortización acumulada', '{}'::jsonb, 'asset_fixed', false, '122', 240),
  ('AR', 'default', '12221', 'Amortización acumulada - Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '1222', 241),
  ('AR', 'default', '12222', 'Amortización acumulada - Maquinarias y equipos', '{}'::jsonb, 'asset_fixed', false, '1222', 242),
  ('AR', 'default', '12223', 'Amortización acumulada - Muebles y útiles', '{}'::jsonb, 'asset_fixed', false, '1222', 243),
  ('AR', 'default', '12224', 'Amortización acumulada - Rodados', '{}'::jsonb, 'asset_fixed', false, '1222', 244),
  ('AR', 'default', '12225', 'Amortización acumulada - Equipos de computación', '{}'::jsonb, 'asset_fixed', false, '1222', 245),
  ('AR', 'default', '12226', 'Amortización acumulada - Instalaciones', '{}'::jsonb, 'asset_fixed', false, '1222', 246),
  ('AR', 'default', '123', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '120', 250),
  ('AR', 'default', '1231', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '123', 251),
  ('AR', 'default', '1232', 'Software y licencias', '{}'::jsonb, 'asset_non_current', false, '123', 252),
  ('AR', 'default', '1233', 'Llave de negocio', '{}'::jsonb, 'asset_non_current', false, '123', 253),
  ('AR', 'default', '200', 'Pasivo', '{}'::jsonb, 'liability_current', false, null, 260),
  ('AR', 'default', '210', 'Pasivo corriente', '{}'::jsonb, 'liability_current', false, '200', 270),
  ('AR', 'default', '211', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_payable', true, '210', 280),
  ('AR', 'default', '2111', 'Proveedores - Mercado interno', '{}'::jsonb, 'liability_payable', true, '211', 290),
  ('AR', 'default', '2112', 'Proveedores - Exterior', '{}'::jsonb, 'liability_payable', true, '211', 300),
  ('AR', 'default', '2113', 'Documentos a pagar', '{}'::jsonb, 'liability_payable', true, '211', 310),
  ('AR', 'default', '212', 'Remuneraciones y cargas sociales a pagar', '{}'::jsonb, 'liability_current', false, '210', 320),
  ('AR', 'default', '2121', 'Sueldos a pagar', '{}'::jsonb, 'liability_current', false, '212', 321),
  ('AR', 'default', '2122', 'Cargas sociales a pagar - Aportes personales', '{}'::jsonb, 'liability_current', false, '212', 322),
  ('AR', 'default', '2123', 'Contribuciones patronales a pagar', '{}'::jsonb, 'liability_current', false, '212', 323),
  ('AR', 'default', '2124', 'Retenciones al personal a pagar', '{}'::jsonb, 'liability_current', false, '212', 324),
  ('AR', 'default', '2125', 'Provisión para sueldo anual complementario', '{}'::jsonb, 'liability_current', false, '212', 325),
  ('AR', 'default', '2126', 'Provisión para vacaciones', '{}'::jsonb, 'liability_current', false, '212', 326),
  ('AR', 'default', '213', 'Cargas fiscales a pagar', '{}'::jsonb, 'liability_current', false, '210', 330),
  ('AR', 'default', '2131', 'IVA Débito Fiscal', '{}'::jsonb, 'liability_current', false, '213', 340),
  ('AR', 'default', '2132', 'IVA a Pagar', '{}'::jsonb, 'liability_current', true, '213', 350),
  ('AR', 'default', '2133', 'Impuesto a las Ganancias a pagar', '{}'::jsonb, 'liability_current', false, '213', 360),
  ('AR', 'default', '2134', 'Ingresos Brutos a pagar', '{}'::jsonb, 'liability_current', false, '213', 370),
  ('AR', 'default', '214', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '210', 380),
  ('AR', 'default', '215', 'Provisiones', '{}'::jsonb, 'liability_current', false, '210', 390),
  ('AR', 'default', '220', 'Pasivo no corriente', '{}'::jsonb, 'liability_non_current', false, '200', 400),
  ('AR', 'default', '221', 'Deudas bancarias', '{}'::jsonb, 'liability_non_current', false, '220', 410),
  ('AR', 'default', '222', 'Otras deudas', '{}'::jsonb, 'liability_non_current', false, '220', 420),
  ('AR', 'default', '2221', 'Deudas con socios y accionistas', '{}'::jsonb, 'liability_non_current', false, '222', 421),
  ('AR', 'default', '2222', 'Deudas por arrendamiento financiero', '{}'::jsonb, 'liability_non_current', false, '222', 422),
  ('AR', 'default', '2223', 'Depósitos de terceros en garantía', '{}'::jsonb, 'liability_non_current', false, '222', 423),
  ('AR', 'default', '2224', 'Provisiones para juicios y contingencias', '{}'::jsonb, 'liability_non_current', false, '222', 424),
  ('AR', 'default', '300', 'Patrimonio neto', '{}'::jsonb, 'equity', false, null, 430),
  ('AR', 'default', '310', 'Capital social', '{}'::jsonb, 'equity', false, '300', 440),
  ('AR', 'default', '320', 'Reserva legal', '{}'::jsonb, 'equity', false, '300', 450),
  ('AR', 'default', '330', 'Otras reservas', '{}'::jsonb, 'equity', false, '300', 460),
  ('AR', 'default', '340', 'Resultados no asignados', '{}'::jsonb, 'equity_retained', false, '300', 470),
  ('AR', 'default', '341', 'Resultados no asignados - Ganancias', '{}'::jsonb, 'equity_retained', false, '340', 480),
  ('AR', 'default', '342', 'Resultados no asignados - Pérdidas', '{}'::jsonb, 'equity_retained', false, '340', 490),
  ('AR', 'default', '350', 'Resultado del ejercicio', '{}'::jsonb, 'equity', false, '300', 500),
  ('AR', 'default', '351', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 'equity', false, '350', 510),
  ('AR', 'default', '352', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 'equity', false, '350', 520),
  ('AR', 'default', '400', 'Ingresos', '{}'::jsonb, 'income', false, null, 530),
  ('AR', 'default', '410', 'Ventas', '{}'::jsonb, 'income', false, '400', 540),
  ('AR', 'default', '411', 'Ventas de mercaderías - Mercado interno', '{}'::jsonb, 'income', false, '410', 550),
  ('AR', 'default', '412', 'Ventas de mercaderías - Exportaciones', '{}'::jsonb, 'income', false, '410', 560),
  ('AR', 'default', '413', 'Ventas de servicios', '{}'::jsonb, 'income', false, '410', 570),
  ('AR', 'default', '460', 'Resultados financieros y por tenencia positivos', '{}'::jsonb, 'income_other', false, '400', 580),
  ('AR', 'default', '461', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '460', 590),
  ('AR', 'default', '462', 'Diferencia de cambio positiva', '{}'::jsonb, 'income_other', false, '460', 600),
  ('AR', 'default', '463', 'Descuentos obtenidos', '{}'::jsonb, 'income_other', false, '460', 601),
  ('AR', 'default', '464', 'Resultado por tenencia de bienes de cambio', '{}'::jsonb, 'income_other', false, '460', 602),
  ('AR', 'default', '480', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '400', 610),
  ('AR', 'default', '500', 'Costos y gastos', '{}'::jsonb, 'expense', false, null, 620),
  ('AR', 'default', '510', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '500', 630),
  ('AR', 'default', '511', 'Compras de mercaderías', '{}'::jsonb, 'expense_direct_cost', false, '510', 640),
  ('AR', 'default', '520', 'Gastos de comercialización', '{}'::jsonb, 'expense', false, '500', 650),
  ('AR', 'default', '521', 'Gastos de comercialización varios', '{}'::jsonb, 'expense', false, '520', 660),
  ('AR', 'default', '522', 'Publicidad y propaganda', '{}'::jsonb, 'expense', false, '520', 661),
  ('AR', 'default', '523', 'Comisiones sobre ventas', '{}'::jsonb, 'expense', false, '520', 662),
  ('AR', 'default', '524', 'Fletes sobre ventas', '{}'::jsonb, 'expense', false, '520', 663),
  ('AR', 'default', '525', 'Gastos de viajes y representación', '{}'::jsonb, 'expense', false, '520', 664),
  ('AR', 'default', '530', 'Gastos de administración', '{}'::jsonb, 'expense', false, '500', 670),
  ('AR', 'default', '531', 'Sueldos y cargas sociales', '{}'::jsonb, 'expense', false, '530', 680),
  ('AR', 'default', '5311', 'Sueldos', '{}'::jsonb, 'expense', false, '531', 681),
  ('AR', 'default', '5312', 'Cargas sociales', '{}'::jsonb, 'expense', false, '531', 682),
  ('AR', 'default', '5313', 'Sueldo anual complementario y vacaciones', '{}'::jsonb, 'expense', false, '531', 683),
  ('AR', 'default', '532', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '530', 690),
  ('AR', 'default', '533', 'Gastos generales de administración', '{}'::jsonb, 'expense', false, '530', 700),
  ('AR', 'default', '5331', 'Alquileres', '{}'::jsonb, 'expense', false, '533', 701),
  ('AR', 'default', '5332', 'Servicios públicos', '{}'::jsonb, 'expense', false, '533', 702),
  ('AR', 'default', '5333', 'Papelería y útiles de oficina', '{}'::jsonb, 'expense', false, '533', 703),
  ('AR', 'default', '5334', 'Gastos de mantenimiento', '{}'::jsonb, 'expense', false, '533', 704),
  ('AR', 'default', '5335', 'Seguros', '{}'::jsonb, 'expense', false, '533', 705),
  ('AR', 'default', '5336', 'Impuestos tasas y contribuciones', '{}'::jsonb, 'expense', false, '533', 706),
  ('AR', 'default', '534', 'Amortización de bienes de uso', '{}'::jsonb, 'expense_depreciation', false, '530', 710),
  ('AR', 'default', '560', 'Resultados financieros y por tenencia negativos', '{}'::jsonb, 'expense', false, '500', 720),
  ('AR', 'default', '561', 'Intereses pagados', '{}'::jsonb, 'expense', false, '560', 730),
  ('AR', 'default', '562', 'Diferencia de cambio negativa', '{}'::jsonb, 'expense', false, '560', 740),
  ('AR', 'default', '563', 'Redondeo', '{}'::jsonb, 'expense', false, '560', 750),
  ('AR', 'default', '564', 'Descuentos otorgados', '{}'::jsonb, 'expense', false, '560', 751),
  ('AR', 'default', '565', 'Gastos e intereses bancarios', '{}'::jsonb, 'expense', false, '560', 752),
  ('AR', 'default', '570', 'Impuesto a las Ganancias', '{}'::jsonb, 'expense', false, '500', 760),
  ('AR', 'default', '580', 'Otros egresos', '{}'::jsonb, 'expense', false, '500', 770)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('AR', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('AR', 'BCO', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('AR', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('AR', 'CPR', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('AR', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('AR', 'VTA', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('AR', 'AR-P-105', 'Compras y servicios al 10,5 %', '{}'::jsonb, 'Crédito fiscal a la alícuota reducida sobre las compras, locaciones y prestaciones enumeradas en el art. 28, tercer y cuarto párrafo', 'percent', 10.5, 'purchase', 'domestic', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 28, tercer y cuarto párrafo, para la alícuota, y art. 12 para el cómputo como crédito fiscal', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-P-21', 'Compras y servicios al 21 %', '{}'::jsonb, 'Crédito fiscal a la alícuota general sobre compras, locaciones y prestaciones de servicios gravadas destinadas a operaciones gravadas', 'percent', 21, 'purchase', 'domestic', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 28, primer párrafo, para la alícuota, y art. 12 — el crédito fiscal es el impuesto que, facturado por sus proveedores, le hubiera sido liquidado por compras, locaciones o prestaciones de servicios vinculadas a las operaciones gravadas', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-P-27', 'Compras y servicios al 27 %', '{}'::jsonb, 'Crédito fiscal sobre la compra de gas, energía eléctrica y aguas reguladas por medidor y demás prestaciones alcanzadas por la alícuota incrementada del art. 28, segundo párrafo', 'percent', 27, 'purchase', 'domestic', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 28, segundo párrafo, para la alícuota, y art. 12 para el cómputo como crédito fiscal', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-P-EXE', 'Compras y servicios exentos', '{}'::jsonb, 'Compras, locaciones y prestaciones exentas del impuesto por el art. 7 de la Ley de Impuesto al Valor Agregado', 'percent', 0, 'purchase', 'exempt', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 7', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-P-IMP', 'Importación definitiva de cosas muebles', '{}'::jsonb, 'Impuesto que se liquida e ingresa juntamente con el despacho de importación por la importación definitiva de cosas muebles, computable como crédito fiscal', 'percent', 21, 'purchase', 'import', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 1, inciso c) — el hecho imponible alcanza a las importaciones definitivas de cosas muebles; art. 25 — en el caso de importaciones definitivas el impuesto se liquida e ingresa juntamente con la liquidación y pago de los derechos de importación; art. 28 para la alícuota, que sigue la de la venta interna del mismo bien. El importe se computa como crédito fiscal por el art. 12', null, null, 100, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-S-105', 'Ventas y servicios al 10,5 %', '{}'::jsonb, 'Alícuota reducida, equivalente al cincuenta por ciento (50 %) de la alícuota general, sobre las ventas y prestaciones enumeradas en el art. 28, cuarto párrafo — entre otras, animales vivos y carnes de las especies bovina y ovina, frutas y hortalizas frescas, miel a granel, granos y legumbres secas, ciertas obras y locaciones vinculadas a esos bienes, las obras del art. 3, inciso b), destinadas a vivienda, los intereses de préstamos de entidades regidas por la Ley 21.526, ciertos bienes de capital, el transporte de pasajeros de más de 100 km, los servicios de asistencia sanitaria no exentos y la venta de diarios, revistas y publicaciones periódicas', 'percent', 10.5, 'sale', 'domestic', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 28, tercer y cuarto párrafo — estarán alcanzados por una alícuota equivalente al cincuenta por ciento (50 %) de la establecida en el primer párrafo las ventas, locaciones e importaciones definitivas que el propio artículo enumera en sus incisos a) a g)', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-S-21', 'Ventas y servicios al 21 %', '{}'::jsonb, 'Alícuota general del Impuesto al Valor Agregado sobre ventas de cosas muebles, locaciones y prestaciones de servicios gravadas', 'percent', 21, 'sale', 'domestic', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 28, primer párrafo — la alícuota del impuesto será del veintiuno por ciento (21 %)', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-S-27', 'Ventas y servicios al 27 %', '{}'::jsonb, 'Alícuota incrementada sobre la venta de gas, energía eléctrica y aguas reguladas por medidor, y demás prestaciones del art. 3, inciso e), puntos 4, 5 y 6, cuando la venta o prestación se efectúe fuera de domicilios destinados exclusivamente a vivienda y el comprador o usuario sea un responsable inscripto o un sujeto que optó por el Régimen Simplificado', 'percent', 27, 'sale', 'domestic', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 28, segundo párrafo — esta alícuota se incrementará al veintisiete por ciento (27 %) para las ventas de gas, energía eléctrica y aguas reguladas por medidor y demás prestaciones comprendidas en los puntos 4, 5 y 6 del inciso e) del artículo 3, cuando la venta o prestación se efectúe fuera de domicilios destinados exclusivamente a vivienda o casa de recreo o veraneo o en su caso, terrenos baldíos y el comprador o usuario sea un sujeto categorizado en este impuesto como responsable inscripto o se trate de sujetos que optaron por el Régimen Simplificado para pequeños contribuyentes. El decreto reglamentario, art. 46, precisa qué se entiende por prestaciones comprendidas en los puntos 4, 5 y 6 del inciso e); este paquete no condiciona el código al domicilio del comprador, que el contable elige', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-S-EXE', 'Ventas y servicios exentos', '{}'::jsonb, 'Ventas, locaciones y prestaciones exentas del impuesto por el art. 7 de la Ley de Impuesto al Valor Agregado', 'percent', 0, 'sale', 'exempt', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 7 — enumera las ventas, locaciones y prestaciones exentas del impuesto: entre otras, libros, folletos e impresos similares, sellos postales, agua ordinaria natural, pan común, leche sin aditivos destinada a consumidor final o sujetos exentos, medicamentos cuando se trate de su reventa por farmacias, servicios educativos comprendidos en la normativa respectiva, prestaciones de obras sociales y de medicina prepaga, y el transporte internacional de pasajeros y cargas', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('AR', 'AR-S-EXP', 'Exportaciones', '{}'::jsonb, 'Exportación de bienes o servicios, exenta del impuesto con derecho al cómputo, devolución o transferencia del crédito fiscal vinculado', 'percent', 0, 'sale', 'export', date '1990-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 8, inciso d) — las exportaciones están exentas del impuesto; art. 43 — los exportadores pueden computar el impuesto que les hubiera sido facturado por bienes, servicios y locaciones destinados efectivamente a las exportaciones, contra el impuesto que en definitiva adeudasen por sus operaciones internas gravadas, y si la compensación no resultara posible o se realizara sólo parcialmente, el saldo se le acreditará, devolverá o transferirá. La República Argentina no está dentro del sistema común de IVA de la Unión Europea, por lo que este paquete no declara `exemption_code`: el artículo que exime va en `legal_reference`, y no se declara ninguno de los tratamientos `intracom_*`', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null)
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
    ('AR-P-105', 'invoice', 'base', 100, null, 'PC105', array['PC105']::text[], 100, 'AR-IVA', 10),
    ('AR-P-105', 'invoice', 'tax', 100, '1151', 'CF105', array['CF105']::text[], 100, 'AR-IVA', 20),
    ('AR-P-21', 'invoice', 'base', 100, null, 'PC21', array['PC21']::text[], 100, 'AR-IVA', 10),
    ('AR-P-21', 'invoice', 'tax', 100, '1151', 'CF21', array['CF21']::text[], 100, 'AR-IVA', 20),
    ('AR-P-27', 'invoice', 'base', 100, null, 'PC27', array['PC27']::text[], 100, 'AR-IVA', 10),
    ('AR-P-27', 'invoice', 'tax', 100, '1151', 'CF27', array['CF27']::text[], 100, 'AR-IVA', 20),
    ('AR-P-EXE', 'invoice', 'base', 100, null, 'PCEXE', array['PCEXE']::text[], 100, 'AR-IVA', 10),
    ('AR-P-IMP', 'invoice', 'base', 100, null, 'PCIMP', array['PCIMP']::text[], 100, 'AR-IVA', 10),
    ('AR-P-IMP', 'invoice', 'tax', 100, '1151', 'CFIMP', array['CFIMP']::text[], 100, 'AR-IVA', 20),
    ('AR-S-105', 'invoice', 'base', 100, null, 'G105', array['G105']::text[], 100, 'AR-IVA', 10),
    ('AR-S-105', 'invoice', 'tax', 100, '2131', 'C105', array['C105']::text[], 100, 'AR-IVA', 20),
    ('AR-S-105', 'credit_note', 'base', 100, null, 'G105', array['G105']::text[], -100, 'AR-IVA', 10),
    ('AR-S-105', 'credit_note', 'tax', 100, '2131', 'C105', array['C105']::text[], -100, 'AR-IVA', 20),
    ('AR-S-21', 'invoice', 'base', 100, null, 'G21', array['G21']::text[], 100, 'AR-IVA', 10),
    ('AR-S-21', 'invoice', 'tax', 100, '2131', 'C21', array['C21']::text[], 100, 'AR-IVA', 20),
    ('AR-S-21', 'credit_note', 'base', 100, null, 'G21', array['G21']::text[], -100, 'AR-IVA', 10),
    ('AR-S-21', 'credit_note', 'tax', 100, '2131', 'C21', array['C21']::text[], -100, 'AR-IVA', 20),
    ('AR-S-27', 'invoice', 'base', 100, null, 'G27', array['G27']::text[], 100, 'AR-IVA', 10),
    ('AR-S-27', 'invoice', 'tax', 100, '2131', 'C27', array['C27']::text[], 100, 'AR-IVA', 20),
    ('AR-S-27', 'credit_note', 'base', 100, null, 'G27', array['G27']::text[], -100, 'AR-IVA', 10),
    ('AR-S-27', 'credit_note', 'tax', 100, '2131', 'C27', array['C27']::text[], -100, 'AR-IVA', 20),
    ('AR-S-EXE', 'invoice', 'base', 100, null, 'GEXE', array['GEXE']::text[], 100, 'AR-IVA', 10),
    ('AR-S-EXE', 'credit_note', 'base', 100, null, 'GEXE', array['GEXE']::text[], -100, 'AR-IVA', 10),
    ('AR-S-EXP', 'invoice', 'base', 100, null, 'GEXP', array['GEXP']::text[], 100, 'AR-IVA', 10),
    ('AR-S-EXP', 'credit_note', 'base', 100, null, 'GEXP', array['GEXP']::text[], -100, 'AR-IVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'AR' and t.code = v.tax_code
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
  ('AR', 'AR-IVA', 'Declaración jurada del Impuesto al Valor Agregado', array['month']::declaration_period[], 'month'::declaration_period, date '2025-11-01', null, 'Ley de Impuesto al Valor Agregado, art. 27, primer párrafo — el impuesto resultante por aplicación de los arts. 11 a 24 se liquidará y abonará por mes calendario sobre la base de declaración jurada efectuada en formulario oficial. El art. 27 admite una opción trimestral para responsables cuyas operaciones correspondan exclusivamente a la actividad agropecuaria, que este paquete no modela. Desde el período fiscal noviembre de 2025 la declaración se presenta mediante el sistema "IVA Simple" y el formulario F. 2051, que reemplazó a los formularios F. 731, F. 810, F. 2082 y F. 2002 "IVA por Actividad" (Resolución General (ARCA) 5705/2025, arts. 2, 3 y 8). El nuevo sistema pone a disposición del contribuyente los comprobantes electrónicos ya autorizados y no numera sus campos como los formularios que reemplaza; los identificadores de este paquete son siglas propias sobre la sustancia de la determinación que fijan los arts. 11, 12 y 24 de la ley — débito fiscal, crédito fiscal y saldo técnico — y no los nombres de pantalla del portal, que este paquete no pudo verificar; ver README.md', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Resolución General (AFIP) 4172/2017 y sus modificatorias, Anexo — la Agenda General de Vencimientos fija, para cada obligación, un día de vencimiento por cada terminación del número de C.U.I.T. del contribuyente, calendario que la (hoy) Agencia de Recaudación y Control Aduanero actualiza y publica cada año; la Resolución General (ARCA) 5705/2025, art. 5, remite a ese mismo cronograma vigente para la presentación de la declaración jurada mensual y el ingreso del saldo resultante del "IVA Simple"', 'rg4172', null)
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
  ('AR', 'AR-IVA', 'G21', 'base', 'Ventas y prestaciones gravadas al 21 %', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 27 — base sobre la que se liquida el débito fiscal del art. 11 a la alícuota general del art. 28, primer párrafo', 'liva'),
  ('AR', 'AR-IVA', 'C21', 'tax', 'Débito fiscal al 21 %', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 11 — el débito fiscal resulta de aplicar la alícuota fijada para las operaciones a los precios netos totales de las ventas, locaciones y prestaciones de servicios gravadas', 'liva'),
  ('AR', 'AR-IVA', 'G27', 'base', 'Ventas y prestaciones gravadas al 27 %', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 27 — base sobre la que se liquida el débito fiscal del art. 11 a la alícuota incrementada del art. 28, segundo párrafo', 'liva'),
  ('AR', 'AR-IVA', 'C27', 'tax', 'Débito fiscal al 27 %', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 11', 'liva'),
  ('AR', 'AR-IVA', 'G105', 'base', 'Ventas y prestaciones gravadas al 10,5 %', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 27 — base sobre la que se liquida el débito fiscal del art. 11 a la alícuota reducida del art. 28, tercer y cuarto párrafo', 'liva'),
  ('AR', 'AR-IVA', 'C105', 'tax', 'Débito fiscal al 10,5 %', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 11', 'liva'),
  ('AR', 'AR-IVA', 'GEXP', 'base', 'Exportaciones', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 8, inciso d) y art. 43 — el valor de las operaciones de exportación, que no generan débito fiscal y dan derecho al cómputo, devolución o transferencia del crédito fiscal vinculado', 'liva'),
  ('AR', 'AR-IVA', 'GEXE', 'base', 'Operaciones exentas', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 7 — el valor de las ventas, locaciones y prestaciones exentas del impuesto', 'liva'),
  ('AR', 'AR-IVA', 'DEBFIS', 'total', 'Débito fiscal del período', '{}'::jsonb, 90, null, array['C21', 'C27', 'C105']::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 11 — la suma de los débitos fiscales de todas las operaciones gravadas del período', 'liva'),
  ('AR', 'AR-IVA', 'PC21', 'base', 'Compras y prestaciones recibidas gravadas al 21 %, destinadas a operaciones gravadas', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12 — base sobre la que se computa el crédito fiscal vinculado a operaciones gravadas a la alícuota general', 'liva'),
  ('AR', 'AR-IVA', 'CF21', 'tax', 'Crédito fiscal al 21 %', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12 — el crédito fiscal es el impuesto que, facturado por los proveedores, le hubiera sido liquidado al responsable por compras, locaciones o prestaciones vinculadas a las operaciones gravadas', 'liva'),
  ('AR', 'AR-IVA', 'PC27', 'base', 'Compras y prestaciones recibidas gravadas al 27 %', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12', 'liva'),
  ('AR', 'AR-IVA', 'CF27', 'tax', 'Crédito fiscal al 27 %', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12', 'liva'),
  ('AR', 'AR-IVA', 'PC105', 'base', 'Compras y prestaciones recibidas gravadas al 10,5 %', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12', 'liva'),
  ('AR', 'AR-IVA', 'CF105', 'tax', 'Crédito fiscal al 10,5 %', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12', 'liva'),
  ('AR', 'AR-IVA', 'PCEXE', 'base', 'Compras exentas', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 7', 'liva'),
  ('AR', 'AR-IVA', 'PCIMP', 'base', 'Importaciones definitivas gravadas', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 1, inciso c) y art. 25', 'liva'),
  ('AR', 'AR-IVA', 'CFIMP', 'tax', 'Crédito fiscal por importaciones definitivas', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12 y art. 25', 'liva'),
  ('AR', 'AR-IVA', 'CREDFIS', 'total', 'Crédito fiscal del período', '{}'::jsonb, 190, null, array['CF21', 'CF27', 'CF105', 'CFIMP']::text[], '{}'::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 12 — la suma del crédito fiscal computable del período', 'liva'),
  ('AR', 'AR-IVA', 'SALDOTEC', 'total', 'Saldo técnico del período — a ingresar, o a favor del contribuyente', '{}'::jsonb, 200, null, array['DEBFIS']::text[], array['CREDFIS']::text[], null, null, false, false, null, 'Ley de Impuesto al Valor Agregado, art. 24, primer párrafo — cuando el crédito fiscal supere al débito fiscal, el excedente sólo se aplicará a los débitos fiscales de los ejercicios fiscales siguientes; el saldo técnico se muestra aquí como una resta, de modo que un período a favor sale con signo negativo. Este paquete no liquida el saldo de libre disponibilidad del art. 24, segundo párrafo (retenciones, percepciones y otros ingresos directos), fuera de su alcance — ver README.md', 'liva')
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
  ('AR-ER', 'AR', 'default', 'Estado de resultados', 'income_statement', 'AR-LGS', date '1970-01-01', null, 'Ley General de Sociedades 19.550, art. 64 — el estado de resultados mostrará: el producido de las ventas o servicios agrupado por tipo de actividad, deducidos los gastos necesarios para obtenerlo a fin de determinar el resultado; los gastos ordinarios de administración, comercialización, financiación y otros que corresponda cargar al ejercicio, discriminados adecuadamente; los resultados financieros y por tenencia; y las ganancias y gastos extraordinarios del ejercicio, que este paquete no separa de los ordinarios', 'lgs'),
  ('AR-ESP', 'AR', 'default', 'Estado de situación patrimonial', 'balance_sheet', 'AR-LGS', date '1970-01-01', null, 'Ley General de Sociedades 19.550, art. 63 — contenido mínimo del estado de situación patrimonial: el activo se presenta distinguiendo el corriente del no corriente, discriminado por rubros (caja y bancos; créditos; bienes de cambio; bienes de uso; activos intangibles; otros); el pasivo, distinguiendo también el corriente del no corriente (deudas comerciales, bancarias, sociales y fiscales; previsiones); y el patrimonio neto, de acuerdo con las normas que rigen a la sociedad. Este esquema es una estructura mínima sobre esos rubros; la presentación normativa completa es la de las Resoluciones Técnicas 8 y 9 de la FACPCE, cuyo texto pertenece a esa Federación y no se transcribe aquí — ver README.md', 'lgs')
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
  ('AR-ER', 'VEN', null, 'Ventas netas', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso a) — el producido de las ventas o servicios, agrupado por tipo de actividad', 'lgs'),
  ('AR-ER', 'CV', null, 'Costo de ventas', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso a) — el costo de los bienes o servicios vendidos', 'lgs'),
  ('AR-ER', 'RB', null, 'Resultado bruto', '{}'::jsonb, 30, 1, true, array['VEN']::text[], array['CV']::text[], null, 'Ley General de Sociedades, art. 64, inciso a)', 'lgs'),
  ('AR-ER', 'GC', null, 'Gastos de comercialización', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso b) — gastos ordinarios de comercialización', 'lgs'),
  ('AR-ER', 'GA', null, 'Gastos de administración', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso b) — gastos ordinarios de administración', 'lgs'),
  ('AR-ER', 'RO', null, 'Resultado operativo', '{}'::jsonb, 60, 1, true, array['RB']::text[], array['GC', 'GA']::text[], null, 'Ley General de Sociedades, art. 64', 'lgs'),
  ('AR-ER', 'RFPOS', null, 'Resultados financieros y por tenencia, positivos', '{}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso b) — resultados financieros y por tenencia, incluidas las diferencias de cambio', 'lgs'),
  ('AR-ER', 'RFNEG', null, 'Resultados financieros y por tenencia, negativos', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso b)', 'lgs'),
  ('AR-ER', 'OTRI', null, 'Otros ingresos', '{}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso b)', 'lgs'),
  ('AR-ER', 'OTRE', null, 'Otros egresos', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 64, inciso b)', 'lgs'),
  ('AR-ER', 'RAI', null, 'Resultado antes del impuesto a las ganancias', '{}'::jsonb, 110, 1, true, array['RO', 'RFPOS', 'OTRI']::text[], array['RFNEG', 'OTRE']::text[], null, 'Ley General de Sociedades, art. 64', 'lgs'),
  ('AR-ER', 'IG', null, 'Impuesto a las ganancias', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Ley de Impuesto a las Ganancias — no modelado por este paquete; la cuenta existe para que el estado de resultados pueda presentarlo cuando la empresa lo liquide manualmente. Ver README.md', 'lgs'),
  ('AR-ER', 'RN', null, 'Resultado neto del ejercicio', '{}'::jsonb, 130, 1, true, array['RAI']::text[], array['IG']::text[], null, 'Ley General de Sociedades, art. 64 — determinación de la ganancia o pérdida neta del ejercicio', 'lgs'),
  ('AR-ESP', 'CB', null, 'Caja y bancos', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 1) — caja y bancos', 'lgs'),
  ('AR-ESP', 'INV', null, 'Inversiones corrientes', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 2) — inversiones', 'lgs'),
  ('AR-ESP', 'CXV', null, 'Créditos por ventas', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 3) — créditos provenientes de las actividades sociales', 'lgs'),
  ('AR-ESP', 'OCR', null, 'Otros créditos', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 3) — otros créditos', 'lgs'),
  ('AR-ESP', 'CFI', null, 'Créditos fiscales', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Ley de Impuesto al Valor Agregado, art. 12 y art. 24 — el crédito fiscal computable y el saldo técnico a favor del contribuyente', 'liva'),
  ('AR-ESP', 'BCA', null, 'Bienes de cambio', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 4) — bienes de cambio', 'lgs'),
  ('AR-ESP', 'PPI', null, 'Partidas pendientes de imputación', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de uso interno, sin correspondencia en un rubro propio del art. 63 de la Ley General de Sociedades', 'lgs'),
  ('AR-ESP', 'AC', null, 'Total del activo corriente', '{}'::jsonb, 80, 1, true, array['CB', 'INV', 'CXV', 'OCR', 'CFI', 'BCA', 'PPI']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63 — el activo se agrupará de manera de distinguir el activo corriente del no corriente', 'lgs'),
  ('AR-ESP', 'CNC', null, 'Créditos no corrientes', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 3)', 'lgs'),
  ('AR-ESP', 'BUS', null, 'Bienes de uso', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 5) — bienes de uso, con indicación de sus amortizaciones', 'lgs'),
  ('AR-ESP', 'AIN', null, 'Activos intangibles', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso a) 6) — activos intangibles', 'lgs'),
  ('AR-ESP', 'ANC', null, 'Total del activo no corriente', '{}'::jsonb, 120, 1, true, array['CNC', 'BUS', 'AIN']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63', 'lgs'),
  ('AR-ESP', 'ACT', null, 'Total del activo', '{}'::jsonb, 130, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63', 'lgs'),
  ('AR-ESP', 'CPC', null, 'Cuentas por pagar comerciales', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso b) 1) — deudas, indicando los saldos con sociedades controlantes, controladas o vinculadas, los que corresponden a otras empresas y los que correspondan a directores y síndicos', 'lgs'),
  ('AR-ESP', 'REM', null, 'Remuneraciones y cargas sociales a pagar', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso b) 1)', 'lgs'),
  ('AR-ESP', 'CFP', null, 'Cargas fiscales a pagar', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Ley de Impuesto al Valor Agregado, art. 24 — el impuesto a ingresar de un período en que el débito fiscal supera al crédito fiscal', 'liva'),
  ('AR-ESP', 'ANT', null, 'Anticipos de clientes', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso b) 3) — anticipos de clientes', 'lgs'),
  ('AR-ESP', 'PRO', null, 'Provisiones', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso b) 2) — previsiones', 'lgs'),
  ('AR-ESP', 'PC', null, 'Total del pasivo corriente', '{}'::jsonb, 190, 1, true, array['CPC', 'REM', 'CFP', 'ANT', 'PRO']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63', 'lgs'),
  ('AR-ESP', 'DBL', null, 'Deudas bancarias no corrientes', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso b) 1)', 'lgs'),
  ('AR-ESP', 'ODL', null, 'Otras deudas no corrientes', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso b) 1)', 'lgs'),
  ('AR-ESP', 'PNC', null, 'Total del pasivo no corriente', '{}'::jsonb, 220, 1, true, array['DBL', 'ODL']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63', 'lgs'),
  ('AR-ESP', 'PAS', null, 'Total del pasivo', '{}'::jsonb, 230, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63', 'lgs'),
  ('AR-ESP', 'CAP', null, 'Capital social', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso c) — el capital social', 'lgs'),
  ('AR-ESP', 'RES', null, 'Reservas', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso c) — reservas legales, contractuales o voluntarias', 'lgs'),
  ('AR-ESP', 'RNA', null, 'Resultados no asignados', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso c) — resultados acumulados', 'lgs'),
  ('AR-ESP', 'REJ', null, 'Resultado del ejercicio', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso c) y art. 64 — el resultado del ejercicio, hasta que la asamblea resuelva su afectación', 'lgs'),
  ('AR-ESP', 'PN', null, 'Total del patrimonio neto', '{}'::jsonb, 280, 1, true, array['CAP', 'RES', 'RNA', 'REJ']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63, inciso c)', 'lgs'),
  ('AR-ESP', 'PASPN', null, 'Total del pasivo más patrimonio neto', '{}'::jsonb, 290, 1, true, array['PAS', 'PN']::text[], '{}'::text[], null, 'Ley General de Sociedades, art. 63', 'lgs')
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
    ('AR-ER', 'VEN', 10, 'code_prefix', '41', null, null, 'any'),
    ('AR-ER', 'CV', 10, 'code_prefix', '51', null, null, 'any'),
    ('AR-ER', 'GC', 10, 'code_prefix', '52', null, null, 'any'),
    ('AR-ER', 'GA', 10, 'code_prefix', '53', null, null, 'any'),
    ('AR-ER', 'RFPOS', 10, 'code_prefix', '46', null, null, 'any'),
    ('AR-ER', 'RFNEG', 10, 'code_prefix', '56', null, null, 'any'),
    ('AR-ER', 'OTRI', 10, 'code_prefix', '48', null, null, 'any'),
    ('AR-ER', 'OTRE', 10, 'code_prefix', '58', null, null, 'any'),
    ('AR-ER', 'IG', 10, 'code_prefix', '57', null, null, 'any'),
    ('AR-ESP', 'CB', 10, 'code_prefix', '111', null, null, 'any'),
    ('AR-ESP', 'INV', 10, 'code_prefix', '112', null, null, 'any'),
    ('AR-ESP', 'CXV', 10, 'code_prefix', '113', null, null, 'any'),
    ('AR-ESP', 'OCR', 10, 'code_prefix', '114', null, null, 'any'),
    ('AR-ESP', 'CFI', 10, 'code_prefix', '115', null, null, 'any'),
    ('AR-ESP', 'BCA', 10, 'code_prefix', '116', null, null, 'any'),
    ('AR-ESP', 'PPI', 10, 'code_prefix', '117', null, null, 'any'),
    ('AR-ESP', 'CNC', 10, 'code_prefix', '121', null, null, 'any'),
    ('AR-ESP', 'BUS', 10, 'code_prefix', '122', null, null, 'any'),
    ('AR-ESP', 'AIN', 10, 'code_prefix', '123', null, null, 'any'),
    ('AR-ESP', 'CPC', 10, 'code_prefix', '211', null, null, 'any'),
    ('AR-ESP', 'REM', 10, 'code_prefix', '212', null, null, 'any'),
    ('AR-ESP', 'CFP', 10, 'code_prefix', '213', null, null, 'any'),
    ('AR-ESP', 'ANT', 10, 'code_prefix', '214', null, null, 'any'),
    ('AR-ESP', 'PRO', 10, 'code_prefix', '215', null, null, 'any'),
    ('AR-ESP', 'DBL', 10, 'code_prefix', '221', null, null, 'any'),
    ('AR-ESP', 'ODL', 10, 'code_prefix', '222', null, null, 'any'),
    ('AR-ESP', 'CAP', 10, 'code_prefix', '31', null, null, 'any'),
    ('AR-ESP', 'RES', 10, 'code_prefix', '32', null, null, 'any'),
    ('AR-ESP', 'RES', 20, 'code_prefix', '33', null, null, 'any'),
    ('AR-ESP', 'RNA', 10, 'code_prefix', '34', null, null, 'any'),
    ('AR-ESP', 'REJ', 10, 'code_prefix', '35', null, null, 'any')
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
  ('AR', 'Argentina', '{}'::jsonb, array['es']::text[], 'ARS', '1131', '2111', '117', '563', '341', '411', '511', '1112', '1111', 'VTA', 'CPR', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', default, default, '462', '562', null, null, null, null, '2132', '1152', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Resolución General (AFIP) 4291/2018, arts. 1 a 4 y Anexo — el comprobante electrónico se identifica por punto de venta y número correlativo, sin admitir saltos, asignado por el emisor y validado por el servicio web de la (hoy) Agencia de Recaudación y Control Aduanero al momento de autorizarlo con el Código de Autorización Electrónico (CAE); Resolución General (AFIP) 4290/2018 generaliza la obligación de emitir por este medio o por controlador fiscal a la generalidad de las operaciones de venta de cosas muebles, locaciones y prestaciones de servicios. El número que declara este paquete es el de la pieza contable — correlativo por diario, sin reinicio anual — y no el número de comprobante fiscal, que sólo asigna el emisor bajo las reglas de la Resolución General 4291; ver README.md',
  numbering_source_key          = 'rg4291',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ley de Impuesto al Valor Agregado, art. 5, inciso a) — en el caso de ventas, el hecho imponible se perfecciona en el momento de la entrega del bien, emisión de la factura respectiva, o acto equivalente, el que fuere anterior; inciso b) — en el caso de prestaciones de servicios y locaciones de obras y servicios, en el momento en que se termina la ejecución o prestación, o en el de la percepción total o parcial del precio, el que fuere anterior, salvo que se facture antes de alguno de esos hechos. Dado que la Resolución General 4291/2018 exige emitir la factura electrónica no después de la entrega o de la prestación, en la generalidad de los casos la factura es contemporánea o anterior a la entrega, de modo que el hecho que en la práctica fija el impuesto es el de la emisión — de ahí invoice_if_issued, en el sentido del vocabulario de este formato: la entrega es el principio y la factura lo desplaza cuando se emite',
  tax_point_source_key          = 'liva',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Código Civil y Comercial, art. 321 — los asientos deben respaldarse con la documentación respectiva y no está prevista su alteración; art. 331 — impugnación de los registros contables. Resolución General (AFIP) 4291/2018, art. 21 — un comprobante electrónico autorizado con CAE sólo se anula o corrige mediante una nota de crédito que lo referencia; no existe un procedimiento para volver un comprobante autorizado a borrador',
  posted_edit_policy_source_key = 'ccyc',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Resolución General (AFIP) 4290/2018 y Resolución General (AFIP) 4291/2018 — desde el 1 de abril de 2019 (cronograma de la Resolución General 4291, Anexo IV, completado en esa fecha) toda persona humana o jurídica que emite comprobantes por operaciones de venta de cosas muebles, locaciones y prestaciones de servicios, locaciones de obras y señas o anticipos que congelen el precio, sea responsable inscripto, exento o monotributista, debe hacerlo como comprobante electrónico con Código de Autorización Electrónico (CAE) o mediante controlador fiscal, en sustitución de la Resolución General 2485. Es un régimen de validación previa (clearance): antes de entregar el comprobante al receptor, el emisor solicita su autorización a un servicio web de la (hoy) Agencia de Recaudación y Control Aduanero, que valida los datos y devuelve el CAE; sin ese código el comprobante no respalda la operación. El formato del comprobante no es el de una factura construida sobre EN 16931 — no hay Peppol, no hay perfil semántico europeo, y no existe una pieza de packages/formats que redacte el XML del webservice de facturación de ARCA ni que hable con ese servicio. EKWO NO GENERA, NO SOLICITA AUTORIZACIÓN NI TRANSMITE COMPROBANTES A ARCA: un documento emitido desde Ekwo registra la operación en la contabilidad y no es la factura fiscal. Por eso profile, mandatory_from y obligation quedan vacíos aunque la obligación exista: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe, y este formato no tiene una palabra para "válido sólo tras la autorización previa de un tercero" — ver docs/international.md. La C.U.I.T. identifica al emisor y al receptor y no tiene código ISO 6523: party_scheme y vat_scheme quedan vacíos',
  einvoice_source_key           = 'rg4291',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'AR';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('AR', 'no_cae', 'always', 'Este comprobante no lleva el Código de Autorización Electrónico (CAE) de la Agencia de Recaudación y Control Aduanero (ARCA, ex AFIP): no es válido como factura a los efectos fiscales hasta ser autorizado por ese organismo.', '{}'::jsonb, 10, date '1970-01-01', null, 'Resolución General (AFIP) 4291/2018, arts. 1, 7 y 8 — el comprobante electrónico se autoriza mediante un servicio web de la Agencia antes de su entrega, que le asigna el Código de Autorización Electrónico; sin él el documento no respalda la operación frente al fisco. Ekwo no emite, no solicita autorización ni transmite comprobantes a la Agencia — ver README.md'),
  ('AR', 'export', 'export', 'Exportación — operación gravada a tasa cero del Impuesto al Valor Agregado (artículo 8, inciso d), de la Ley de Impuesto al Valor Agregado).', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 8, inciso d) — las exportaciones están exentas del impuesto; art. 43 — el exportador puede computar el impuesto que le hubiera sido facturado por bienes, servicios y locaciones destinados efectivamente a la exportación contra el impuesto que en definitiva adeudase, o, si no fuera absorbido, se le acredite, devuelva o transfiera. La combinación de ambos artículos es la exención con derecho a recupero que en este paquete se declara con tasa 0 %'),
  ('AR', 'exempt', 'exempt', 'Operación exenta del Impuesto al Valor Agregado (artículo 7 de la Ley de Impuesto al Valor Agregado).', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley de Impuesto al Valor Agregado, art. 7 — enumera las ventas, locaciones y prestaciones exentas: entre otras, libros, folletos e impresos similares, sellos postales, agua ordinaria natural, pan común, leche sin aditivos, medicamentos cuando se trate de su reventa por farmacias, servicios educativos, prestaciones de obras sociales y de medicina prepaga, transporte internacional de pasajeros y cargas, y las demás que el propio artículo detalla')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
