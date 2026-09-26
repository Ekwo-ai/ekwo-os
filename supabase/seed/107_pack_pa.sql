-- Ekwo OS — Panamá: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/pa at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build pa`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Código Fiscal de la República de Panamá — Ley N.° 8 de 27 de enero de 1956, texto con sus reformas (Ministerio de Economía y Finanzas)
--     https://www.mef.gob.pa/wp-content/uploads/2019/11/Codigo-Fiscal-Ley-8.pdf
--   Ley 75 de 22 de diciembre de 1976 — adiciona el artículo 1057-V al Código Fiscal, creando el Impuesto de Transferencia de Bienes Corporales Muebles y la Prestación de Servicios (ITBMS) (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Normativa/Ley-75-22-diciembre-1976.pdf
--   Ley 61 de 26 de diciembre de 2002 — medidas de reordenamiento y simplificación del sistema tributario (Gaceta Oficial N.° 24,708) (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Normativa/Ley-61-2002-Reforma-Fiscal-2002-itbms.pdf
--   Ley 6 de 2 de febrero de 2005 — programa de equidad fiscal, que reforma el artículo 1057-V del Código Fiscal (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Normativa/Ley-6-2-febrero-2005.pdf
--   Ley 49 de 17 de septiembre de 2009 — medidas fiscales adicionales, que reforma el artículo 1057-V del Código Fiscal (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Normativa/Ley-49-17-septiembre-2009.pdf
--   Ley 8 de 15 de marzo de 2010 — que reforma el Código Fiscal y crea el Tribunal Administrativo Tributario; eleva la tarifa general del ITBMS al 7 % (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Normativa/Ley-8-15-marzo-2010.pdf
--   Ley 33 de 30 de junio de 2010 — normas de adecuación a los convenios para evitar la doble tributación internacional, que reforma el artículo 1057-V del Código Fiscal (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Normativa/Ley-33-30-junio-2010-ITBMS.pdf
--   Generalidades del ITBMS — tarifas, hecho generador y plazo de presentación (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/Generalidades
--   Servicios exentos de ITBMS (artículo 1057 del Código Fiscal) (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/itbms/SE-Itbms
--   Instructivo V6 para llenar la Declaración Jurada del ITBMS (Formulario 430) (Dirección General de Ingresos — Departamento de Sistemas de Información Tributaria)
--     https://dgi.mef.gob.pa/DInforme/pdf/Instructivo-ITBMS-2023-V6-(002).pdf
--   Formulario 430 — Declaración Jurada de ITBMS (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/DInforme/Formulario430
--   e-Tax 2.0 — portal de declaraciones y pagos en línea de la Dirección General de Ingresos (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://etax2.mef.gob.pa/
--   Base legal de la facturación electrónica — Sistema de Facturación Electrónica de Panamá (SFEP), incluida la Resolución N.° 201-6299 de 29 de julio de 2025 (Dirección General de Ingresos — Ministerio de Economía y Finanzas)
--     https://dgi.mef.gob.pa/_7FacturaElectronica/Blegales
--   Panamá y el compromiso de establecer el uso de normas contables estándares y de aceptación a nivel mundial — reseña de la Resolución N.° 03-2010 de 28 de octubre de 2010, por la que la Junta Técnica de Contabilidad adopta la NIIF para las PYMES (Colegio de Contadores Públicos Autorizados de Panamá)
--     https://www.colegiocpapanama.org/articulos/sala-de-expresidentes/panam%C3%A1-y-el-compromiso-de-establecer-el-uso-de-normas-contables-est%C3%A1ndares-y-de-aceptaci%C3%B3n-a-nivel-mundial
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('PA', 'Panamá', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'e30342c08164ea77036020d730d4929ed8a01431ec7401ff9a65bfc1d20632b6', '[{"key":"codigo-fiscal","title":"Código Fiscal de la República de Panamá — Ley N.° 8 de 27 de enero de 1956, texto con sus reformas","publisher":"Ministerio de Economía y Finanzas","url":"https://www.mef.gob.pa/wp-content/uploads/2019/11/Codigo-Fiscal-Ley-8.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-75-1976","title":"Ley 75 de 22 de diciembre de 1976 — adiciona el artículo 1057-V al Código Fiscal, creando el Impuesto de Transferencia de Bienes Corporales Muebles y la Prestación de Servicios (ITBMS)","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Normativa/Ley-75-22-diciembre-1976.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-61-2002","title":"Ley 61 de 26 de diciembre de 2002 — medidas de reordenamiento y simplificación del sistema tributario (Gaceta Oficial N.° 24,708)","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Normativa/Ley-61-2002-Reforma-Fiscal-2002-itbms.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-6-2005","title":"Ley 6 de 2 de febrero de 2005 — programa de equidad fiscal, que reforma el artículo 1057-V del Código Fiscal","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Normativa/Ley-6-2-febrero-2005.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-49-2009","title":"Ley 49 de 17 de septiembre de 2009 — medidas fiscales adicionales, que reforma el artículo 1057-V del Código Fiscal","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Normativa/Ley-49-17-septiembre-2009.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-8-2010","title":"Ley 8 de 15 de marzo de 2010 — que reforma el Código Fiscal y crea el Tribunal Administrativo Tributario; eleva la tarifa general del ITBMS al 7 %","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Normativa/Ley-8-15-marzo-2010.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-33-2010","title":"Ley 33 de 30 de junio de 2010 — normas de adecuación a los convenios para evitar la doble tributación internacional, que reforma el artículo 1057-V del Código Fiscal","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Normativa/Ley-33-30-junio-2010-ITBMS.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"itbms-generalidades","title":"Generalidades del ITBMS — tarifas, hecho generador y plazo de presentación","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/Generalidades","consulted_on":"2026-09-26","kind":"guidance"},{"key":"itbms-exentos","title":"Servicios exentos de ITBMS (artículo 1057 del Código Fiscal)","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/itbms/SE-Itbms","consulted_on":"2026-09-26","kind":"guidance"},{"key":"instructivo-430","title":"Instructivo V6 para llenar la Declaración Jurada del ITBMS (Formulario 430)","publisher":"Dirección General de Ingresos — Departamento de Sistemas de Información Tributaria","url":"https://dgi.mef.gob.pa/DInforme/pdf/Instructivo-ITBMS-2023-V6-(002).pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"formulario-430","title":"Formulario 430 — Declaración Jurada de ITBMS","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/DInforme/Formulario430","consulted_on":"2026-09-26","kind":"form"},{"key":"etax","title":"e-Tax 2.0 — portal de declaraciones y pagos en línea de la Dirección General de Ingresos","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://etax2.mef.gob.pa/","consulted_on":"2026-09-26","kind":"portal"},{"key":"dgi-facturacion-legal","title":"Base legal de la facturación electrónica — Sistema de Facturación Electrónica de Panamá (SFEP), incluida la Resolución N.° 201-6299 de 29 de julio de 2025","publisher":"Dirección General de Ingresos — Ministerio de Economía y Finanzas","url":"https://dgi.mef.gob.pa/_7FacturaElectronica/Blegales","consulted_on":"2026-09-26","kind":"guidance"},{"key":"niif-pymes","title":"Panamá y el compromiso de establecer el uso de normas contables estándares y de aceptación a nivel mundial — reseña de la Resolución N.° 03-2010 de 28 de octubre de 2010, por la que la Junta Técnica de Contabilidad adopta la NIIF para las PYMES","publisher":"Colegio de Contadores Públicos Autorizados de Panamá","url":"https://www.colegiocpapanama.org/articulos/sala-de-expresidentes/panam%C3%A1-y-el-compromiso-de-establecer-el-uso-de-normas-contables-est%C3%A1ndares-y-de-aceptaci%C3%B3n-a-nivel-mundial","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('PA', 'default', 'Catálogo de cuentas propio, organizado sobre la NIIF para las PYMES', '{}'::jsonb, true, 'companies', array['PA-NIIFPYME-ERI', 'PA-NIIFPYME-ESF']::text[], null, 'Panamá no impone un catálogo de cuentas único: la Resolución N.° 03-2010 de 28 de octubre de 2010 de la Junta Técnica de Contabilidad adopta la NIIF para las PYMES del IASB como marco de preparación de los estados financieros con propósito general de toda entidad panameña sin obligación pública de rendir cuentas, sin fijar una numeración de cuentas. Este paquete usa, como catálogo propio, una selección de cuentas ordenadas por las secciones de esa norma (activo, pasivo, patrimonio, ingresos y gastos), de la misma manera que los paquetes de México y Colombia usan un catálogo propio ordenado sobre su propio marco', 'niif-pymes')
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
  ('PA', 'default', '11', 'EFECTIVO Y EQUIVALENTES DE EFECTIVO', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('PA', 'default', '1105', 'Caja', '{}'::jsonb, 'asset_cash', false, '11', 20),
  ('PA', 'default', '110501', 'Caja general', '{}'::jsonb, 'asset_cash', false, '1105', 30),
  ('PA', 'default', '110502', 'Caja menuda', '{}'::jsonb, 'asset_cash', false, '1105', 40),
  ('PA', 'default', '1110', 'Bancos', '{}'::jsonb, 'asset_cash', false, '11', 50),
  ('PA', 'default', '111001', 'Bancos — cuentas corrientes', '{}'::jsonb, 'asset_cash', false, '1110', 60),
  ('PA', 'default', '111002', 'Bancos — cuentas de ahorro', '{}'::jsonb, 'asset_cash', false, '1110', 70),
  ('PA', 'default', '12', 'INVERSIONES', '{}'::jsonb, 'asset_current', false, null, 80),
  ('PA', 'default', '1205', 'Inversiones temporales', '{}'::jsonb, 'asset_current', false, '12', 90),
  ('PA', 'default', '120501', 'Certificados de depósito a corto plazo', '{}'::jsonb, 'asset_current', false, '1205', 100),
  ('PA', 'default', '13', 'CUENTAS POR COBRAR', '{}'::jsonb, 'asset_current', false, null, 110),
  ('PA', 'default', '1305', 'Clientes', '{}'::jsonb, 'asset_current', false, '13', 120),
  ('PA', 'default', '130501', 'Clientes nacionales', '{}'::jsonb, 'asset_receivable', true, '1305', 130),
  ('PA', 'default', '130502', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '1305', 140),
  ('PA', 'default', '130590', 'Estimación para cuentas incobrables', '{}'::jsonb, 'asset_current', false, '1305', 150),
  ('PA', 'default', '1310', 'Cuentas por cobrar a empleados y socios', '{}'::jsonb, 'asset_current', false, '13', 160),
  ('PA', 'default', '131001', 'Préstamos a empleados', '{}'::jsonb, 'asset_current', false, '1310', 170),
  ('PA', 'default', '131002', 'Cuentas por cobrar a accionistas', '{}'::jsonb, 'asset_current', false, '1310', 180),
  ('PA', 'default', '1315', 'Anticipos y avances', '{}'::jsonb, 'asset_current', false, '13', 190),
  ('PA', 'default', '131501', 'Anticipo a proveedores', '{}'::jsonb, 'asset_current', false, '1315', 200),
  ('PA', 'default', '1395', 'Impuestos por cobrar', '{}'::jsonb, 'asset_current', false, '13', 210),
  ('PA', 'default', '139501', 'ITBMS crédito fiscal', '{}'::jsonb, 'asset_current', false, '1395', 220),
  ('PA', 'default', '139502', 'ITBMS a favor del contribuyente', '{}'::jsonb, 'asset_current', true, '1395', 230),
  ('PA', 'default', '139503', 'Impuesto sobre la renta pagado por anticipado', '{}'::jsonb, 'asset_current', false, '1395', 240),
  ('PA', 'default', '14', 'INVENTARIOS', '{}'::jsonb, 'asset_current', false, null, 250),
  ('PA', 'default', '1405', 'Inventario de mercancías', '{}'::jsonb, 'asset_current', false, '14', 260),
  ('PA', 'default', '140501', 'Mercancías para la venta', '{}'::jsonb, 'asset_current', false, '1405', 270),
  ('PA', 'default', '1410', 'Inventario de materia prima', '{}'::jsonb, 'asset_current', false, '14', 280),
  ('PA', 'default', '141001', 'Materia prima', '{}'::jsonb, 'asset_current', false, '1410', 290),
  ('PA', 'default', '15', 'GASTOS PAGADOS POR ANTICIPADO', '{}'::jsonb, 'asset_prepayments', false, null, 300),
  ('PA', 'default', '1505', 'Seguros pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '15', 310),
  ('PA', 'default', '1510', 'Arrendamientos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '15', 320),
  ('PA', 'default', '1515', 'Otros gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '15', 330),
  ('PA', 'default', '16', 'PROPIEDAD, PLANTA Y EQUIPO', '{}'::jsonb, 'asset_fixed', false, null, 340),
  ('PA', 'default', '1605', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '16', 350),
  ('PA', 'default', '1610', 'Edificaciones', '{}'::jsonb, 'asset_fixed', false, '16', 360),
  ('PA', 'default', '1611', 'Depreciación acumulada de edificaciones', '{}'::jsonb, 'asset_fixed', false, '16', 370),
  ('PA', 'default', '1615', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '16', 380),
  ('PA', 'default', '1616', 'Depreciación acumulada de maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '16', 390),
  ('PA', 'default', '1620', 'Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '16', 400),
  ('PA', 'default', '1621', 'Depreciación acumulada de mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '16', 410),
  ('PA', 'default', '1625', 'Equipo de computación', '{}'::jsonb, 'asset_fixed', false, '16', 420),
  ('PA', 'default', '1626', 'Depreciación acumulada de equipo de computación', '{}'::jsonb, 'asset_fixed', false, '16', 430),
  ('PA', 'default', '1630', 'Vehículos', '{}'::jsonb, 'asset_fixed', false, '16', 440),
  ('PA', 'default', '1631', 'Depreciación acumulada de vehículos', '{}'::jsonb, 'asset_fixed', false, '16', 450),
  ('PA', 'default', '17', 'ACTIVOS INTANGIBLES', '{}'::jsonb, 'asset_non_current', false, null, 460),
  ('PA', 'default', '1705', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '17', 470),
  ('PA', 'default', '1710', 'Software', '{}'::jsonb, 'asset_non_current', false, '17', 480),
  ('PA', 'default', '1715', 'Amortización acumulada de intangibles', '{}'::jsonb, 'asset_non_current', false, '17', 490),
  ('PA', 'default', '18', 'OTROS ACTIVOS NO CORRIENTES', '{}'::jsonb, 'asset_non_current', false, null, 500),
  ('PA', 'default', '1805', 'Depósitos en garantía', '{}'::jsonb, 'asset_non_current', false, '18', 510),
  ('PA', 'default', '1810', 'Gastos de organización y preoperativos', '{}'::jsonb, 'asset_non_current', false, '18', 520),
  ('PA', 'default', '19', 'INVERSIONES A LARGO PLAZO', '{}'::jsonb, 'asset_non_current', false, null, 530),
  ('PA', 'default', '1905', 'Inversiones permanentes en otras sociedades', '{}'::jsonb, 'asset_non_current', false, '19', 540),
  ('PA', 'default', '21', 'OBLIGACIONES FINANCIERAS A CORTO PLAZO', '{}'::jsonb, 'liability_current', false, null, 550),
  ('PA', 'default', '2105', 'Préstamos bancarios nacionales', '{}'::jsonb, 'liability_current', false, '21', 560),
  ('PA', 'default', '2110', 'Préstamos bancarios del exterior', '{}'::jsonb, 'liability_current', false, '21', 570),
  ('PA', 'default', '22', 'PROVEEDORES', '{}'::jsonb, 'liability_current', false, null, 580),
  ('PA', 'default', '2205', 'Proveedores', '{}'::jsonb, 'liability_current', false, '22', 590),
  ('PA', 'default', '220501', 'Proveedores nacionales', '{}'::jsonb, 'liability_payable', true, '2205', 600),
  ('PA', 'default', '220502', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '2205', 610),
  ('PA', 'default', '23', 'CUENTAS POR PAGAR', '{}'::jsonb, 'liability_current', false, null, 620),
  ('PA', 'default', '2305', 'Costos y gastos acumulados por pagar', '{}'::jsonb, 'liability_current', false, '23', 630),
  ('PA', 'default', '2310', 'Documentos por pagar', '{}'::jsonb, 'liability_current', false, '23', 640),
  ('PA', 'default', '24', 'IMPUESTOS POR PAGAR', '{}'::jsonb, 'liability_current', false, null, 650),
  ('PA', 'default', '2405', 'ITBMS', '{}'::jsonb, 'liability_current', false, '24', 660),
  ('PA', 'default', '240501', 'ITBMS débito fiscal (ventas)', '{}'::jsonb, 'liability_current', false, '2405', 670),
  ('PA', 'default', '2410', 'Impuesto sobre la renta por pagar', '{}'::jsonb, 'liability_current', false, '24', 680),
  ('PA', 'default', '2415', 'ITBMS por pagar', '{}'::jsonb, 'liability_current', false, '24', 690),
  ('PA', 'default', '241501', 'ITBMS por pagar al Tesoro Nacional', '{}'::jsonb, 'liability_current', true, '2415', 700),
  ('PA', 'default', '2420', 'Cuota obrero-patronal por pagar (CSS)', '{}'::jsonb, 'liability_current', false, '24', 710),
  ('PA', 'default', '2425', 'Retenciones de impuesto sobre la renta por pagar', '{}'::jsonb, 'liability_current', false, '24', 720),
  ('PA', 'default', '25', 'OBLIGACIONES LABORALES', '{}'::jsonb, 'liability_current', false, null, 730),
  ('PA', 'default', '2505', 'Salarios por pagar', '{}'::jsonb, 'liability_current', false, '25', 740),
  ('PA', 'default', '2510', 'Prestaciones laborales por pagar', '{}'::jsonb, 'liability_current', false, '25', 750),
  ('PA', 'default', '2515', 'Indemnización por pagar', '{}'::jsonb, 'liability_current', false, '25', 760),
  ('PA', 'default', '26', 'PASIVOS ESTIMADOS Y PROVISIONES', '{}'::jsonb, 'liability_current', false, null, 770),
  ('PA', 'default', '2605', 'Provisión para prestaciones laborales', '{}'::jsonb, 'liability_current', false, '26', 780),
  ('PA', 'default', '27', 'INGRESOS DIFERIDOS', '{}'::jsonb, 'liability_current', false, null, 790),
  ('PA', 'default', '2705', 'Ingresos recibidos por anticipado', '{}'::jsonb, 'liability_current', false, '27', 800),
  ('PA', 'default', '28', 'OTROS PASIVOS CORRIENTES', '{}'::jsonb, 'liability_current', false, null, 810),
  ('PA', 'default', '2805', 'Cuenta de orden', '{}'::jsonb, 'liability_current', false, '28', 820),
  ('PA', 'default', '280501', 'Cuenta de orden — partidas por clasificar', '{}'::jsonb, 'liability_current', false, '2805', 830),
  ('PA', 'default', '29', 'OBLIGACIONES A LARGO PLAZO', '{}'::jsonb, 'liability_non_current', false, null, 840),
  ('PA', 'default', '2905', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '29', 850),
  ('PA', 'default', '2910', 'Documentos por pagar a largo plazo', '{}'::jsonb, 'liability_non_current', false, '29', 860),
  ('PA', 'default', '31', 'CAPITAL', '{}'::jsonb, 'equity', false, null, 870),
  ('PA', 'default', '3105', 'Capital social', '{}'::jsonb, 'equity', false, '31', 880),
  ('PA', 'default', '3110', 'Aportes de capital adicional', '{}'::jsonb, 'equity', false, '31', 890),
  ('PA', 'default', '32', 'RESERVAS', '{}'::jsonb, 'equity', false, null, 900),
  ('PA', 'default', '3205', 'Reserva legal', '{}'::jsonb, 'equity', false, '32', 910),
  ('PA', 'default', '33', 'RESULTADOS ACUMULADOS', '{}'::jsonb, 'equity_retained', false, null, 920),
  ('PA', 'default', '3305', 'Utilidades retenidas', '{}'::jsonb, 'equity_retained', false, '33', 930),
  ('PA', 'default', '330501', 'Utilidades retenidas', '{}'::jsonb, 'equity_retained', false, '3305', 940),
  ('PA', 'default', '3310', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '33', 950),
  ('PA', 'default', '331001', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '3310', 960),
  ('PA', 'default', '34', 'RESULTADO DEL EJERCICIO', '{}'::jsonb, 'equity', false, null, 970),
  ('PA', 'default', '3405', 'Utilidad del ejercicio', '{}'::jsonb, 'equity', false, '34', 980),
  ('PA', 'default', '340501', 'Utilidad del ejercicio', '{}'::jsonb, 'equity', false, '3405', 990),
  ('PA', 'default', '3410', 'Pérdida del ejercicio', '{}'::jsonb, 'equity', false, '34', 1000),
  ('PA', 'default', '341001', 'Pérdida del ejercicio', '{}'::jsonb, 'equity', false, '3410', 1010),
  ('PA', 'default', '41', 'INGRESOS OPERACIONALES', '{}'::jsonb, 'income', false, null, 1020),
  ('PA', 'default', '4105', 'Ventas', '{}'::jsonb, 'income', false, '41', 1030),
  ('PA', 'default', '410501', 'Ventas gravadas al 7 %', '{}'::jsonb, 'income', false, '4105', 1040),
  ('PA', 'default', '410502', 'Ventas gravadas al 10 % — bebidas alcohólicas', '{}'::jsonb, 'income', false, '4105', 1050),
  ('PA', 'default', '410503', 'Ventas gravadas al 10 % — hospedaje', '{}'::jsonb, 'income', false, '4105', 1060),
  ('PA', 'default', '410504', 'Ventas gravadas al 15 % — tabaco', '{}'::jsonb, 'income', false, '4105', 1070),
  ('PA', 'default', '410505', 'Ventas de exportación', '{}'::jsonb, 'income', false, '4105', 1080),
  ('PA', 'default', '410506', 'Ventas exentas', '{}'::jsonb, 'income', false, '4105', 1090),
  ('PA', 'default', '410507', 'Ventas no gravadas', '{}'::jsonb, 'income', false, '4105', 1100),
  ('PA', 'default', '4110', 'Prestación de servicios', '{}'::jsonb, 'income', false, '41', 1110),
  ('PA', 'default', '411001', 'Servicios gravados', '{}'::jsonb, 'income', false, '4110', 1120),
  ('PA', 'default', '4190', 'Devoluciones y descuentos en ventas', '{}'::jsonb, 'income', false, '41', 1130),
  ('PA', 'default', '42', 'OTROS INGRESOS', '{}'::jsonb, 'income_other', false, null, 1140),
  ('PA', 'default', '4205', 'Ingresos financieros', '{}'::jsonb, 'income_other', false, '42', 1150),
  ('PA', 'default', '4210', 'Ganancia en venta de activos', '{}'::jsonb, 'income_other', false, '42', 1160),
  ('PA', 'default', '4215', 'Ganancia por diferencia en cambio', '{}'::jsonb, 'income_other', false, '42', 1170),
  ('PA', 'default', '421501', 'Ganancia por diferencia en cambio', '{}'::jsonb, 'income_other', false, '4215', 1180),
  ('PA', 'default', '51', 'COSTO DE VENTAS', '{}'::jsonb, 'expense_direct_cost', false, null, 1190),
  ('PA', 'default', '5105', 'Costo de mercancía vendida', '{}'::jsonb, 'expense_direct_cost', false, '51', 1200),
  ('PA', 'default', '510501', 'Costo de mercancía vendida', '{}'::jsonb, 'expense_direct_cost', false, '5105', 1210),
  ('PA', 'default', '5110', 'Costo de servicios prestados', '{}'::jsonb, 'expense_direct_cost', false, '51', 1220),
  ('PA', 'default', '61', 'GASTOS DE ADMINISTRACIÓN', '{}'::jsonb, 'expense', false, null, 1230),
  ('PA', 'default', '6105', 'Sueldos y salarios administrativos', '{}'::jsonb, 'expense', false, '61', 1240),
  ('PA', 'default', '6110', 'Prestaciones laborales', '{}'::jsonb, 'expense', false, '61', 1250),
  ('PA', 'default', '6115', 'Cuota obrero-patronal (CSS)', '{}'::jsonb, 'expense', false, '61', 1260),
  ('PA', 'default', '6120', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '61', 1270),
  ('PA', 'default', '6125', 'Arrendamientos', '{}'::jsonb, 'expense', false, '61', 1280),
  ('PA', 'default', '6130', 'Depreciación', '{}'::jsonb, 'expense_depreciation', false, '61', 1290),
  ('PA', 'default', '6135', 'Amortización de intangibles', '{}'::jsonb, 'expense_depreciation', false, '61', 1300),
  ('PA', 'default', '6140', 'Papelería y útiles de oficina', '{}'::jsonb, 'expense', false, '61', 1310),
  ('PA', 'default', '6145', 'Servicios públicos', '{}'::jsonb, 'expense', false, '61', 1320),
  ('PA', 'default', '6150', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '61', 1330),
  ('PA', 'default', '6155', 'Seguros', '{}'::jsonb, 'expense', false, '61', 1340),
  ('PA', 'default', '6160', 'Impuestos y tasas municipales', '{}'::jsonb, 'expense', false, '61', 1350),
  ('PA', 'default', '6165', 'Gastos de representación', '{}'::jsonb, 'expense', false, '61', 1360),
  ('PA', 'default', '6170', 'Otros gastos de administración', '{}'::jsonb, 'expense', false, '61', 1370),
  ('PA', 'default', '62', 'GASTOS DE VENTA', '{}'::jsonb, 'expense', false, null, 1380),
  ('PA', 'default', '6205', 'Sueldos y comisiones de ventas', '{}'::jsonb, 'expense', false, '62', 1390),
  ('PA', 'default', '6210', 'Publicidad y promoción', '{}'::jsonb, 'expense', false, '62', 1400),
  ('PA', 'default', '6215', 'Fletes y transporte de ventas', '{}'::jsonb, 'expense', false, '62', 1410),
  ('PA', 'default', '6220', 'Otros gastos de venta', '{}'::jsonb, 'expense', false, '62', 1420),
  ('PA', 'default', '6299', 'Diferencia de redondeo', '{}'::jsonb, 'expense', false, '62', 1430),
  ('PA', 'default', '629905', 'Diferencia de redondeo', '{}'::jsonb, 'expense', false, '6299', 1440),
  ('PA', 'default', '63', 'GASTOS FINANCIEROS', '{}'::jsonb, 'expense', false, null, 1450),
  ('PA', 'default', '6305', 'Intereses pagados', '{}'::jsonb, 'expense', false, '63', 1460),
  ('PA', 'default', '6310', 'Comisiones bancarias', '{}'::jsonb, 'expense', false, '63', 1470),
  ('PA', 'default', '6315', 'Pérdida por diferencia en cambio', '{}'::jsonb, 'expense', false, '63', 1480),
  ('PA', 'default', '631501', 'Pérdida por diferencia en cambio', '{}'::jsonb, 'expense', false, '6315', 1490),
  ('PA', 'default', '64', 'IMPUESTO SOBRE LA RENTA', '{}'::jsonb, 'expense', false, null, 1500),
  ('PA', 'default', '6405', 'Impuesto sobre la renta, gasto del período', '{}'::jsonb, 'expense', false, '64', 1510)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PA', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('PA', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('PA', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('PA', 'COM', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('PA', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('PA', 'VEN', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('PA', 'PA-P-10', 'Compras gravadas a la tarifa del 10 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes, servicios e importaciones gravadas al 10 % (bebidas alcohólicas u hospedaje), imputables directamente a operaciones gravadas', 'percent', 10, 'purchase', 'domestic', date '2010-07-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 12, en los mismos términos que la compra a la tarifa general; el Formulario 430 declara el crédito fiscal de la tarifa del 10 % en una casilla distinta de la del 7 %', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'codigo-fiscal', null, null, null, null),
  ('PA', 'PA-P-15', 'Compras gravadas a la tarifa del 15 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes, servicios e importaciones gravadas al 15 % (cigarrillos y derivados del tabaco), imputables directamente a operaciones gravadas', 'percent', 15, 'purchase', 'domestic', date '2010-07-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 12, en los mismos términos que la compra a la tarifa general; el Formulario 430 declara el crédito fiscal de la tarifa del 15 % en una casilla distinta de la del 7 %', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'codigo-fiscal', null, null, null, null),
  ('PA', 'PA-P-7', 'Compras gravadas a la tarifa general del 7 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes, servicios e importaciones gravadas al 7 %, imputables directamente a operaciones gravadas', 'percent', 7, 'purchase', 'domestic', date '2010-07-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 12 — el contribuyente tiene derecho a un crédito fiscal contra el débito fiscal del mismo período, por el impuesto pagado en la adquisición de bienes y servicios destinados a operaciones gravadas', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'codigo-fiscal', null, null, null, null),
  ('PA', 'PA-P-7-NOCRED', 'Compra gravada al 7 %, sin derecho a crédito fiscal', '{}'::jsonb, 'Adquisición gravada al 7 %, destinada directamente a una operación exenta o no gravada', 'percent', 7, 'purchase', 'domestic', date '2010-07-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 12 — el crédito fiscal exige que la adquisición se destine a una operación gravada; el impuesto de una adquisición gravada destinada directamente a una operación exenta o no gravada no da derecho a crédito fiscal y forma parte del costo o gasto de la adquisición. El Formulario 430 declara la base en la casilla 34, «destinadas directamente a operaciones exentas», sin casilla propia de impuesto', null, null, 140, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'instructivo-430', null, null, null, null),
  ('PA', 'PA-P-EXE', 'Compra exenta o no gravada', '{}'::jsonb, 'Adquisición de bienes o servicios exentos o no gravados, sin ITBMS facturado por el proveedor', 'percent', 0, 'purchase', 'exempt', date '1976-12-22', null, 'Código Fiscal, artículo 1057-V, parágrafos 7 y 8 — la compra de un bien o servicio exento o no gravado no liquida impuesto; el Formulario 430 la declara en la casilla 39, «compras locales e importaciones exentas»', null, null, 150, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'instructivo-430', null, null, null, null),
  ('PA', 'PA-S-10-ALC', 'Operaciones gravadas a la tarifa del 10 % — bebidas alcohólicas', '{}'::jsonb, 'Venta de bebidas alcohólicas', 'percent', 10, 'sale', 'domestic', date '2001-01-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 6, numeral 1, en la redacción del artículo 1 de la Ley 28 de 2001 — las operaciones de venta de bebidas alcohólicas están gravadas a la tarifa del 10 %', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'codigo-fiscal', null, null, null, null),
  ('PA', 'PA-S-10-HOSP', 'Operaciones gravadas a la tarifa del 10 % — hospedaje', '{}'::jsonb, 'Servicio de hospedaje o alojamiento público', 'percent', 10, 'sale', 'domestic', date '2010-07-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 1, numeral 7, en la redacción del artículo 73 de la Ley 8 de 15 de marzo de 2010 — el servicio de hospedaje o alojamiento público está gravado a la tarifa del 10 %', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-8-2010', null, null, null, null),
  ('PA', 'PA-S-15-TAB', 'Operaciones gravadas a la tarifa del 15 % — tabaco', '{}'::jsonb, 'Venta al por mayor y al detal de cigarrillos y demás derivados del tabaco', 'percent', 15, 'sale', 'domestic', date '2001-01-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 6, numeral 2, en la redacción del artículo 1 de la Ley 28 de 2001 — las operaciones de venta de cigarrillos están gravadas a la tarifa del 15 %', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'codigo-fiscal', null, null, null, null),
  ('PA', 'PA-S-7', 'Operaciones gravadas a la tarifa general del 7 %', '{}'::jsonb, 'Transferencia de bienes corporales muebles y prestación de servicios en general, a la tarifa general', 'percent', 7, 'sale', 'domestic', date '2010-07-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 1, literales a) y b), en la redacción del artículo 6 de la Ley 33 de 30 de junio de 2010 — la tarifa general del impuesto es del 7 %, vigente desde el 1 de julio de 2010 (artículo 73 de la Ley 8 de 15 de marzo de 2010)', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-33-2010', null, null, null, null),
  ('PA', 'PA-S-EXE', 'Otras operaciones exentas', '{}'::jsonb, 'Transferencias de bienes y prestaciones de servicios exentas del parágrafo 8 del artículo 1057-V — entre otras, los servicios de salud, la educación, el arrendamiento de vivienda por más de seis meses, el transporte de carga y de pasajeros, los seguros y los alimentos servidos en locales sin venta de bebidas alcohólicas', 'percent', 0, 'sale', 'exempt', date '1976-12-22', null, 'Código Fiscal, artículo 1057-V, parágrafo 8, con excepción del numeral 2) del literal a), en la redacción del artículo 39 de la Ley 6 de 2 de febrero de 2005 — transferencias de bienes y prestaciones de servicios exentas del impuesto', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6-2005', null, null, null, null),
  ('PA', 'PA-S-EXP', 'Exportación y reexportación de bienes', '{}'::jsonb, 'Operaciones de exportación y reexportación de bienes gravados y no gravados', 'percent', 0, 'sale', 'export', date '1976-12-22', null, 'Código Fiscal, artículo 1057-V, parágrafo 8, literal a), numeral 2 — la exportación y reexportación de bienes no causa el impuesto, y da derecho a recuperar, mediante Certificado con Poder Cancelatorio, el ITBMS pagado en las compras e importaciones destinadas directamente a ella', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'codigo-fiscal', null, null, null, null),
  ('PA', 'PA-S-NG', 'Operaciones no gravadas', '{}'::jsonb, 'Transmisiones en capitulaciones matrimoniales, expropiación y ventas que haga el Estado, adjudicaciones judiciales de bienes, transferencia de documentos negociables y de títulos y valores, pagos e intereses de servicios financieros y de fondos de pensión, entre otras operaciones que el parágrafo 7 no somete al hecho generador', 'percent', 0, 'sale', 'not_subject', date '2005-02-02', null, 'Código Fiscal, artículo 1057-V, parágrafo 7, en la redacción de la Ley 6 de 2 de febrero de 2005 — operaciones que no causan el impuesto', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-6-2005', null, null, null, null)
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
    ('PA-P-10', 'invoice', 'base', 100, null, '232', array['232']::text[], 100, 'PA-DGI-430', 10),
    ('PA-P-10', 'invoice', 'tax', 100, '139501', '233', array['233']::text[], 100, 'PA-DGI-430', 20),
    ('PA-P-10', 'credit_note', 'base', 100, null, '232', array['232']::text[], -100, 'PA-DGI-430', 10),
    ('PA-P-10', 'credit_note', 'tax', 100, '139501', '233', array['233']::text[], -100, 'PA-DGI-430', 20),
    ('PA-P-15', 'invoice', 'base', 100, null, '242', array['242']::text[], 100, 'PA-DGI-430', 10),
    ('PA-P-15', 'invoice', 'tax', 100, '139501', '243', array['243']::text[], 100, 'PA-DGI-430', 20),
    ('PA-P-15', 'credit_note', 'base', 100, null, '242', array['242']::text[], -100, 'PA-DGI-430', 10),
    ('PA-P-15', 'credit_note', 'tax', 100, '139501', '243', array['243']::text[], -100, 'PA-DGI-430', 20),
    ('PA-P-7', 'invoice', 'base', 100, null, '222', array['222']::text[], 100, 'PA-DGI-430', 10),
    ('PA-P-7', 'invoice', 'tax', 100, '139501', '223', array['223']::text[], 100, 'PA-DGI-430', 20),
    ('PA-P-7', 'credit_note', 'base', 100, null, '222', array['222']::text[], -100, 'PA-DGI-430', 10),
    ('PA-P-7', 'credit_note', 'tax', 100, '139501', '223', array['223']::text[], -100, 'PA-DGI-430', 20),
    ('PA-P-7-NOCRED', 'invoice', 'base', 100, null, '34', array['34']::text[], 100, 'PA-DGI-430', 10),
    ('PA-P-7-NOCRED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('PA-P-7-NOCRED', 'credit_note', 'base', 100, null, '34', array['34']::text[], -100, 'PA-DGI-430', 10),
    ('PA-P-7-NOCRED', 'credit_note', 'tax_on_base', 100, null, null, null, -100, null, 20),
    ('PA-P-EXE', 'invoice', 'base', 100, null, '39', array['39']::text[], 100, 'PA-DGI-430', 10),
    ('PA-P-EXE', 'credit_note', 'base', 100, null, '39', array['39']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-10-ALC', 'invoice', 'base', 100, null, '13', array['13']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-10-ALC', 'invoice', 'tax', 100, '240501', '131', array['131']::text[], 100, 'PA-DGI-430', 20),
    ('PA-S-10-ALC', 'credit_note', 'base', 100, null, '13', array['13']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-10-ALC', 'credit_note', 'tax', 100, '240501', '131', array['131']::text[], -100, 'PA-DGI-430', 20),
    ('PA-S-10-HOSP', 'invoice', 'base', 100, null, '14', array['14']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-10-HOSP', 'invoice', 'tax', 100, '240501', '141', array['141']::text[], 100, 'PA-DGI-430', 20),
    ('PA-S-10-HOSP', 'credit_note', 'base', 100, null, '14', array['14']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-10-HOSP', 'credit_note', 'tax', 100, '240501', '141', array['141']::text[], -100, 'PA-DGI-430', 20),
    ('PA-S-15-TAB', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-15-TAB', 'invoice', 'tax', 100, '240501', '151', array['151']::text[], 100, 'PA-DGI-430', 20),
    ('PA-S-15-TAB', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-15-TAB', 'credit_note', 'tax', 100, '240501', '151', array['151']::text[], -100, 'PA-DGI-430', 20),
    ('PA-S-7', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-7', 'invoice', 'tax', 100, '240501', '111', array['111']::text[], 100, 'PA-DGI-430', 20),
    ('PA-S-7', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-7', 'credit_note', 'tax', 100, '240501', '111', array['111']::text[], -100, 'PA-DGI-430', 20),
    ('PA-S-EXE', 'invoice', 'base', 100, null, '17', array['17']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-EXE', 'credit_note', 'base', 100, null, '17', array['17']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-EXP', 'invoice', 'base', 100, null, '16', array['16']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-EXP', 'credit_note', 'base', 100, null, '16', array['16']::text[], -100, 'PA-DGI-430', 10),
    ('PA-S-NG', 'invoice', 'base', 100, null, '18', array['18']::text[], 100, 'PA-DGI-430', 10),
    ('PA-S-NG', 'credit_note', 'base', 100, null, '18', array['18']::text[], -100, 'PA-DGI-430', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PA' and t.code = v.tax_code
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
  ('PA', 'PA-DGI-430', 'Declaración Jurada del Impuesto de Transferencia de Bienes Corporales Muebles y la Prestación de Servicios (Formulario 430)', array['month', 'quarter']::declaration_period[], 'month'::declaration_period, date '2016-01-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 11 — el impuesto se liquida y paga en el formulario que señale la Dirección General de Ingresos, dentro de los primeros quince días del mes siguiente al período declarado. El Instructivo V6 del Formulario 430 (sección B) fija la periodicidad: mensual para toda persona natural o jurídica, salvo la persona natural que preste servicios profesionales u oficios por cuenta propia o en forma independiente, que liquida y paga trimestralmente — un hecho propio de cada contribuyente y no una regla que aplique a toda persona jurídica, por lo que este paquete declara el mes como period_default y deja la cuatrimestralidad de los profesionales independientes fuera de esa proposición. Este paquete declara sólo las casillas de las operaciones y del crédito fiscal directo a operaciones gravadas del Instructivo V6; no declara las devoluciones y descuentos (casillas 20, 201, 402, 403), el crédito fiscal proporcional a operaciones mixtas (casillas 26 a 37, 43 y 47), el crédito de retención (casilla 52), el saldo a favor del período anterior (casilla 51) ni el recargo, la multa y el interés (casillas 56 a 57) — véase el README de este paquete', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Código Fiscal, artículo 1057-V, parágrafo 11 — la declaración con saldo a pagar presentada después de los quince (15) días siguientes a aquel en que termine el período declarado causa un recargo del 10 % sobre el impuesto a pagar, lo que fija el plazo de presentación en los primeros quince días del mes siguiente al período', 'instructivo-430', null)
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
  ('PA', 'PA-DGI-430', '11', 'base', 'Operaciones gravadas del período 7 % (ventas y prestación de servicios)', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 11 — monto de las operaciones gravadas del período a la tarifa del 7 %. Este paquete no declara la casilla 12 (transporte aéreo de pasajeros al 7 %), un numeral especial del parágrafo 1 que su escenario no ejercita', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '111', 'tax', 'Impuesto causado — operaciones gravadas del período 7 %', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 111 (columna «Impuesto causado» de la casilla 11)', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '13', 'base', 'Operaciones gravadas del período 10 % (bebidas alcohólicas)', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 13 — monto de las operaciones de venta de bebidas alcohólicas, a la tarifa del 10 %', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '131', 'tax', 'Impuesto causado — bebidas alcohólicas 10 %', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 131 (columna «Impuesto causado» de la casilla 13)', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '14', 'base', 'Servicios gravados del período 10 % (hospedaje o alojamiento público)', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 14 — monto de las operaciones del servicio de hospedaje o alojamiento público, a la tarifa del 10 %', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '141', 'tax', 'Impuesto causado — hospedaje 10 %', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 141 (columna «Impuesto causado» de la casilla 14)', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '15', 'base', 'Operaciones gravadas del período 15 % (cigarrillos)', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 15 — monto de las operaciones de venta al por mayor y al detal de cigarrillos, a la tarifa del 15 %', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '151', 'tax', 'Impuesto causado — cigarrillos 15 %', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 151 (columna «Impuesto causado» de la casilla 15)', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '16', 'base', 'Operaciones de exportación y reexportación de bienes (ventas)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 16 — monto de las operaciones de exportación y reexportación de bienes gravados y no gravados', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '17', 'base', 'Otras operaciones exentas (ventas y prestación de servicios)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 17 — monto de las operaciones exentas del parágrafo 8 del artículo 1057-V realizadas en el período', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '18', 'base', 'Operaciones no gravadas (ventas y prestación de servicios)', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 18 — monto de las operaciones que no causan el impuesto, del parágrafo 7 del artículo 1057-V', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '19', 'total', 'Total de operaciones del período', '{}'::jsonb, 120, null, array['11', '13', '14', '15', '16', '17', '18']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 19 — totaliza las casillas 11 a 18; este paquete omite la casilla 12 (transporte aéreo de pasajeros), que su escenario no ejercita, de la suma que en el formulario oficial también la incluye', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '191', 'total', 'Total impuesto causado', '{}'::jsonb, 130, null, array['111', '131', '141', '151']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 191 — totaliza las casillas 111, 121, 131, 141 y 151; este paquete omite la casilla 121 (impuesto de la casilla 12, no declarada)', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '211', 'total', 'Total débito fiscal', '{}'::jsonb, 140, null, array['191']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 211 — totaliza la casilla 191 más la casilla 201 (impuesto de las devoluciones y descuentos en ventas); este paquete no declara la casilla 201, de modo que la casilla 211 iguala aquí la 191', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '222', 'base', 'Compras e importaciones gravadas al 7 %, imputables directamente a operaciones gravadas', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 222 — monto total (compras locales de la casilla 22 más importaciones de la casilla 221) de las compras e importaciones gravadas al 7 % imputables directamente a operaciones gravadas; este paquete no separa la compra local de la importación', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '223', 'tax', 'ITBMS cargado al 7 % — crédito fiscal directo', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 223 — columna «ITBMS cargado» de la casilla 222', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '232', 'base', 'Compras e importaciones gravadas al 10 %, imputables directamente a operaciones gravadas', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 232 — monto total de las compras e importaciones gravadas al 10 % imputables directamente a operaciones gravadas', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '233', 'tax', 'ITBMS cargado al 10 % — crédito fiscal directo', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 233 — columna «ITBMS cargado» de la casilla 232', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '242', 'base', 'Compras e importaciones gravadas al 15 %, imputables directamente a operaciones gravadas', '{}'::jsonb, 190, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 242 — monto total de las compras e importaciones gravadas al 15 % imputables directamente a operaciones gravadas', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '243', 'tax', 'ITBMS cargado al 15 % — crédito fiscal directo', '{}'::jsonb, 200, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 243 — columna «ITBMS cargado» de la casilla 242', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '253', 'total', 'Total ITBMS cargado — crédito fiscal directo a operaciones gravadas', '{}'::jsonb, 210, null, array['223', '233', '243']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 253 — totaliza las casillas 223, 233 y 243', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '34', 'base', 'Compras e importaciones gravadas al 7 %, destinadas directamente a operaciones exentas', '{}'::jsonb, 220, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 34 — monto de las compras e importaciones gravadas al 7 % que el contribuyente destina directamente a operaciones exentas del parágrafo 8, salvo la exportación del numeral 2) del literal a); el impuesto de esta casilla no da derecho a crédito fiscal y queda en el costo, sin casilla propia', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '39', 'base', 'Compras locales e importaciones exentas', '{}'::jsonb, 230, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 39 — monto de las compras locales e importaciones exentas, sin ITBMS facturado por el proveedor', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '42', 'total', 'Crédito fiscal directo a operaciones gravadas', '{}'::jsonb, 240, null, array['253']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 42 — traslada el resultado de la casilla 253', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '45', 'total', 'Crédito fiscal deducible por operaciones gravadas del período', '{}'::jsonb, 250, null, array['42']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 45 — suma de las casillas 42, 43 y 44; este paquete no declara el crédito fiscal proporcional (casilla 43) ni el crédito por devoluciones y descuentos en ventas gravadas (casilla 44), de modo que la casilla 45 iguala aquí la 42', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '49', 'total', 'Débito fiscal del período', '{}'::jsonb, 260, null, array['211']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 49 — traslada el importe del débito fiscal consignado en la casilla 211', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '50', 'total', 'Crédito fiscal deducible por operaciones gravadas del período', '{}'::jsonb, 270, null, array['45']::text[], '{}'::text[], null, null, false, false, null, 'Instructivo V6, casilla 50 — traslada el importe determinado en la casilla 45', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '54', 'total', 'Saldo a favor del contribuyente que se trasladará al siguiente período fiscal', '{}'::jsonb, 280, null, array['50']::text[], array['49']::text[], null, null, true, false, null, 'Instructivo V6, casilla 54 — casillas 50 + 51 + 52 + 53 menos la casilla 49, cuando la primera suma es mayor; este paquete no declara el saldo a favor del período anterior (casilla 51), el crédito de retención (casilla 52) ni el crédito fiscal por operaciones al exterior susceptible de Certificado con Poder Cancelatorio (casilla 53)', 'instructivo-430'),
  ('PA', 'PA-DGI-430', '55', 'total', 'Impuesto a pagar', '{}'::jsonb, 290, null, array['49']::text[], array['50']::text[], null, null, true, false, null, 'Instructivo V6, casilla 55 — la casilla 49 menos las casillas 50 + 51 + 52 + 53, cuando la primera es mayor', 'instructivo-430')
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
  ('PA-NIIFPYME-ERI', 'PA', 'default', 'Estado de resultado integral', 'income_statement', 'PA-NIIF-PYME', date '1970-01-01', null, 'Resolución N.° 03-2010 de 28 de octubre de 2010 de la Junta Técnica de Contabilidad — adopción de la NIIF para las PYMES; sección 5 de esa norma (Estado del resultado integral), que clasifica el gasto por función. Este paquete presenta el resultado por función, sobre el catálogo propio agrupado por secciones', 'niif-pymes'),
  ('PA-NIIFPYME-ESF', 'PA', 'default', 'Estado de situación financiera', 'balance_sheet', 'PA-NIIF-PYME', date '1970-01-01', null, 'Resolución N.° 03-2010 de 28 de octubre de 2010 de la Junta Técnica de Contabilidad — adopción de la NIIF para las PYMES como marco de los estados financieros con propósito general de la entidad panameña sin obligación pública de rendir cuentas; sección 4 de esa norma (Estado de situación financiera), que clasifica activos y pasivos entre corrientes y no corrientes. Panamá no impone una numeración de cuentas ni un formato de estado impreso: las líneas de este estado agrupan el catálogo propio de este paquete por esas secciones', 'niif-pymes')
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
  ('PA-NIIFPYME-ERI', '41', 'ING', 'Ingresos operacionales', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', '42', 'ING', 'Otros ingresos', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', 'ING', null, 'Total ingresos', '{}'::jsonb, 30, 1, true, array['41', '42']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', '51', null, 'Costo de ventas', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', '61', null, 'Gastos de administración', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', '62', null, 'Gastos de venta', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', '63', null, 'Gastos financieros', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', '64', null, 'Impuesto sobre la renta', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ERI', 'UN', null, 'Utilidad o pérdida del ejercicio', '{}'::jsonb, 90, 1, true, array['ING']::text[], array['51', '61', '62', '63', '64']::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '11', 'AC', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '12', 'AC', 'Inversiones', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '13', 'AC', 'Cuentas por cobrar', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '14', 'AC', 'Inventarios', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '15', 'AC', 'Gastos pagados por anticipado', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'AC', 'ACT', 'Total activo corriente', '{}'::jsonb, 60, 1, true, array['11', '12', '13', '14', '15']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '16', 'ANC', 'Propiedad, planta y equipo', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '17', 'ANC', 'Activos intangibles', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '18', 'ANC', 'Otros activos no corrientes', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '19', 'ANC', 'Inversiones a largo plazo', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'ANC', 'ACT', 'Total activo no corriente', '{}'::jsonb, 110, 1, true, array['16', '17', '18', '19']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'ACT', null, 'Total activo', '{}'::jsonb, 120, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '21', 'PC', 'Obligaciones financieras a corto plazo', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '22', 'PC', 'Proveedores', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '23', 'PC', 'Cuentas por pagar', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '24', 'PC', 'Impuestos por pagar', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '25', 'PC', 'Obligaciones laborales', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '26', 'PC', 'Pasivos estimados y provisiones', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '27', 'PC', 'Ingresos diferidos', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '28', 'PC', 'Otros pasivos corrientes', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'PC', 'PAS', 'Total pasivo corriente', '{}'::jsonb, 210, 1, true, array['21', '22', '23', '24', '25', '26', '27', '28']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '29', 'PNC', 'Obligaciones a largo plazo', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'PNC', 'PAS', 'Total pasivo no corriente', '{}'::jsonb, 230, 1, true, array['29']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'PAS', null, 'Total pasivo', '{}'::jsonb, 240, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '31', 'PAT', 'Capital', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '32', 'PAT', 'Reservas', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '33', 'PAT', 'Resultados acumulados', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', '34', 'PAT', 'Resultado del ejercicio', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('PA-NIIFPYME-ESF', 'PAT', null, 'Total patrimonio', '{}'::jsonb, 290, 1, true, array['31', '32', '33', '34']::text[], '{}'::text[], null, null, null)
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
    ('PA-NIIFPYME-ERI', '41', 10, 'code_prefix', '41', null, null, 'any'),
    ('PA-NIIFPYME-ERI', '42', 10, 'code_prefix', '42', null, null, 'any'),
    ('PA-NIIFPYME-ERI', '51', 10, 'code_prefix', '51', null, null, 'any'),
    ('PA-NIIFPYME-ERI', '61', 10, 'code_prefix', '61', null, null, 'any'),
    ('PA-NIIFPYME-ERI', '62', 10, 'code_prefix', '62', null, null, 'any'),
    ('PA-NIIFPYME-ERI', '63', 10, 'code_prefix', '63', null, null, 'any'),
    ('PA-NIIFPYME-ERI', '64', 10, 'code_prefix', '64', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '11', 10, 'code_prefix', '11', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '12', 10, 'code_prefix', '12', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '13', 10, 'code_prefix', '13', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '14', 10, 'code_prefix', '14', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '15', 10, 'code_prefix', '15', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '16', 10, 'code_prefix', '16', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '17', 10, 'code_prefix', '17', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '18', 10, 'code_prefix', '18', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '19', 10, 'code_prefix', '19', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '21', 10, 'code_prefix', '21', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '22', 10, 'code_prefix', '22', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '23', 10, 'code_prefix', '23', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '24', 10, 'code_prefix', '24', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '25', 10, 'code_prefix', '25', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '26', 10, 'code_prefix', '26', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '27', 10, 'code_prefix', '27', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '28', 10, 'code_prefix', '28', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '29', 10, 'code_prefix', '29', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '31', 10, 'code_prefix', '31', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '32', 10, 'code_prefix', '32', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '33', 10, 'code_prefix', '33', null, null, 'any'),
    ('PA-NIIFPYME-ESF', '34', 10, 'code_prefix', '34', null, null, 'any')
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
  ('PA', 'Panamá', '{}'::jsonb, array['es']::text[], 'USD', '130501', '220501', '280501', '629905', '330501', '410501', '510501', '111001', '110501', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '340501', '341001', '331001', 'APE', 'half_up', default, '421501', '631501', null, null, null, null, '241501', '139502', 'Asiento de apertura', 'month'::declaration_period)
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
  number_format                 = '{CODE}/{YYYY}/{NNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'El Código Fiscal no fija un régimen de numeración consecutiva de la factura interna, y el Sistema de Facturación Electrónica de Panamá (SFEP) asigna su propio Código Único de Factura Electrónica (CUFE) al validar el documento — ver la sección de facturación electrónica. El número que declara este paquete es el de la pieza contable, correlativo por diario y por año, y no el CUFE',
  numbering_source_key          = 'dgi-facturacion-legal',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Código Fiscal, artículo 1057-V, parágrafo 2 — en la transferencia de bienes corporales muebles, la obligación de pagar el impuesto nace en el momento de emitir la factura o al momento de la entrega del bien, lo que ocurra primero. Para la prestación de servicios, el mismo parágrafo hace nacer la obligación con la terminación del servicio prestado, o con la percepción del pago total o parcial, un tercer punto de anclaje que el vocabulario cerrado de esta casilla no nombra en una sola palabra — véase docs/international.md. Este paquete declara la regla de los bienes, invoice_if_issued, que es también la más cercana a la práctica general de la factura como hecho generador',
  tax_point_source_key          = 'codigo-fiscal',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'El Código Fiscal no prevé un mecanismo para devolver a borrador un documento contabilizado; una factura se corrige mediante una nota de crédito que la nombra, nunca volviendo a borrador',
  posted_edit_policy_source_key = 'codigo-fiscal',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Panamá exige la factura electrónica del Sistema de Facturación Electrónica de Panamá (SFEP) por fases desde 2022: todos los nuevos Registros Únicos de Contribuyente (RUC) desde 2023, los proveedores del Estado desde octubre de 2023, y los profesionales independientes y prestadores de servicios desde 2024; desde el 1 de enero de 2026, la Resolución N.° 201-6299 de 29 de julio de 2025 exige el uso exclusivo de un Proveedor Autorizado Calificado (PAC) a todo contribuyente cuyos ingresos brutos anuales superen los treinta y seis mil balboas (B/.36,000.00) o que emita más de cien documentos electrónicos al mes. Es un régimen de validación previa (clearance): antes de su expedición, el documento se transmite a un PAC o a la herramienta gratuita de la DGI para su validación, que le asigna un Código Único de Factura Electrónica (CUFE) — no un intercambio par a par entre el emisor y el comprador construido sobre el modelo semántico de EN 16931. EKWO NO GENERA, NO CALCULA EL CUFE Y NO TRANSMITE NINGÚN DOCUMENTO AL SFEP: ningún componente de packages/formats escribe el XML de la factura electrónica panameña ni dialoga con un PAC o con la DGI. Por eso profile, mandatory_from, party_scheme y vat_scheme quedan vacíos aunque la obligación exista: profile nombra un perfil construido sobre EN 16931 (peppol-bis-3, factur-x-en16931, xrechnung, un PINT), y la factura electrónica panameña no es ninguno de ellos; el formato tampoco tiene una palabra para «válida sólo tras la validación previa de un tercero» — véase docs/international.md. El Registro Único de Contribuyente (RUC) identifica al emisor y al receptor y no tiene un código ISO 6523 registrado: party_scheme y vat_scheme quedan vacíos por la misma razón que en México y Colombia',
  einvoice_source_key           = 'dgi-facturacion-legal',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'PA';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('PA', 'sfep_not_cleared', 'always', 'Este documento no es una factura del Sistema de Facturación Electrónica de Panamá (SFEP): no lleva el Código Único de Factura Electrónica (CUFE) ni ha sido validado por un Proveedor Autorizado Calificado (PAC) ni por la Dirección General de Ingresos. Sólo la factura electrónica validada ampara la operación para efectos fiscales.', '{}'::jsonb, 10, date '1970-01-01', null, 'Resolución N.° 201-6299 de 29 de julio de 2025 y demás normativa del SFEP — la factura electrónica se transmite a un PAC o a la DGI para su validación antes de amparar la operación. Ekwo no genera, no transmite ni valida ningún documento del SFEP: ningún componente de packages/formats habla con un PAC ni con la DGI — ver la sección de facturación electrónica de este paquete'),
  ('PA', 'export', 'export', 'Exportación o reexportación de bienes — tarifa del 0 % del Impuesto de Transferencia de Bienes Corporales Muebles y la Prestación de Servicios (artículo 1057-V, parágrafo 8, literal a, numeral 2, del Código Fiscal).', '{}'::jsonb, 20, date '1970-01-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 8, literal a), numeral 2 — las exportaciones y reexportaciones de bienes gravados y no gravados dan derecho a recuperar, mediante Certificado con Poder Cancelatorio, el ITBMS pagado en las compras e importaciones destinadas a ellas'),
  ('PA', 'exempt', 'exempt', 'Operación exenta del Impuesto de Transferencia de Bienes Corporales Muebles y la Prestación de Servicios (artículo 1057-V, parágrafo 8, del Código Fiscal).', '{}'::jsonb, 30, date '1970-01-01', null, 'Código Fiscal, artículo 1057-V, parágrafo 8 — transferencias de bienes y prestaciones de servicios exentas del impuesto')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
