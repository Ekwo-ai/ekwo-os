-- Ekwo OS — El Salvador: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/sv at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build sv`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley de Impuesto a la Transferencia de Bienes Muebles y a la Prestación de Servicios (Decreto Legislativo No. 296 del 24 de julio de 1992), con sus reformas — art. 8 y 18 (momento en que se causa el impuesto), 45 y 46 (exenciones), 54 (tasa del 13 %, Decreto Legislativo No. 370 del 8 de junio de 1995), 74 y 75 (exportaciones a tasa cero), 93 y 94 (declaración mensual y plazo) (Asamblea Legislativa de la República de El Salvador (texto publicado en el portal de Transparencia Fiscal del Ministerio de Hacienda))
--     https://www.transparenciafiscal.gob.sv/downloads/pdf/DC9226_Ley_del_Impuesto_a_la_Transferencia_de_Bienes_Muebles_y_a_la_Prestacion_de_Servicios.pdf
--   Código Tributario (Decreto Legislativo No. 230 del 14 de diciembre de 2000) — art. 110 (notas de crédito y de débito), 114 (documentos), 162 (retención del 1 % del IVA por los grandes contribuyentes), 162-A (anticipo a cuenta del 2 % en pagos con tarjeta) y 163 (percepción del 1 %) (Asamblea Legislativa de la República de El Salvador (texto publicado en eRegulations El Salvador))
--     https://elsalvador.eregulations.org/media/codigo%20tributario%2009.pdf
--   Decreto Legislativo No. 487 — reformas al Código Tributario sobre Documentos Tributarios Electrónicos (arts. 119-A a 119-H) y disposiciones transitorias (art. 12: la Administración Tributaria fija las fechas desde las cuales cada contribuyente está obligado a emitirlos) (Asamblea Legislativa de la República de El Salvador)
--     https://www.asamblea.gob.sv/sites/default/files/documents/decretos/A607DD05-7C5C-471B-A7F6-7393107250B7.pdf
--   Declaración y Pago del Impuesto a la Transferencia de Bienes Muebles y a la Prestación de Servicios — formulario F07 (Ministerio de Hacienda — Dirección General de Impuestos Internos (DGII))
--     https://www7.mh.gob.sv/downloads/pdf/PMHDC8215.pdf
--   Boletín para nuevos contribuyentes de IVA — obligaciones formales de la Ley del IVA y del impuesto sobre la renta (tipos de documento, retención del 1 %, declaraciones F-07 y F-14, servicios en línea) (Ministerio de Hacienda — Dirección General de Impuestos Internos (DGII))
--     https://www.mh.gob.sv/wp-content/uploads/2025/12/BOLETIN-PARA-NUEVOS-CONTRIBUYENTES-01122025.pdf
--   Portal de servicios en línea de la DGII — presentar y pagar declaraciones (F-07) e informes (Ministerio de Hacienda — Dirección General de Impuestos Internos (DGII))
--     https://portaldgii.mh.gob.sv/ssc/
--   Sistema de Facturación Electrónica — Documentos Tributarios Electrónicos (DTE): documentos técnicos y consulta de la fecha de inicio obligatorio de cada emisor (Ministerio de Hacienda de la República de El Salvador)
--     https://factura.gob.sv
--   Resolución 462 del 18 de marzo de 2021 — adopta y ratifica la NIIF para las PYMES (versión en español 2015) y las NIIF completas (versión en español 2020) (Consejo de Vigilancia de la Profesión de Contaduría Pública y Auditoría (CVPCPA))
--     https://www.cvpcpa.gob.sv/download/resolucion-462/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('SV', 'El Salvador', '0.1.0', date '2026-10-09', '20260923110000', 'community', null, null, '302dd4d9985f1e4c48474d690560aa23fffce482da563c4187aaff38a6c88ea8', '[{"key":"liva","title":"Ley de Impuesto a la Transferencia de Bienes Muebles y a la Prestación de Servicios (Decreto Legislativo No. 296 del 24 de julio de 1992), con sus reformas — art. 8 y 18 (momento en que se causa el impuesto), 45 y 46 (exenciones), 54 (tasa del 13 %, Decreto Legislativo No. 370 del 8 de junio de 1995), 74 y 75 (exportaciones a tasa cero), 93 y 94 (declaración mensual y plazo)","publisher":"Asamblea Legislativa de la República de El Salvador (texto publicado en el portal de Transparencia Fiscal del Ministerio de Hacienda)","url":"https://www.transparenciafiscal.gob.sv/downloads/pdf/DC9226_Ley_del_Impuesto_a_la_Transferencia_de_Bienes_Muebles_y_a_la_Prestacion_de_Servicios.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"ct","title":"Código Tributario (Decreto Legislativo No. 230 del 14 de diciembre de 2000) — art. 110 (notas de crédito y de débito), 114 (documentos), 162 (retención del 1 % del IVA por los grandes contribuyentes), 162-A (anticipo a cuenta del 2 % en pagos con tarjeta) y 163 (percepción del 1 %)","publisher":"Asamblea Legislativa de la República de El Salvador (texto publicado en eRegulations El Salvador)","url":"https://elsalvador.eregulations.org/media/codigo%20tributario%2009.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"d487","title":"Decreto Legislativo No. 487 — reformas al Código Tributario sobre Documentos Tributarios Electrónicos (arts. 119-A a 119-H) y disposiciones transitorias (art. 12: la Administración Tributaria fija las fechas desde las cuales cada contribuyente está obligado a emitirlos)","publisher":"Asamblea Legislativa de la República de El Salvador","url":"https://www.asamblea.gob.sv/sites/default/files/documents/decretos/A607DD05-7C5C-471B-A7F6-7393107250B7.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"f07","title":"Declaración y Pago del Impuesto a la Transferencia de Bienes Muebles y a la Prestación de Servicios — formulario F07","publisher":"Ministerio de Hacienda — Dirección General de Impuestos Internos (DGII)","url":"https://www7.mh.gob.sv/downloads/pdf/PMHDC8215.pdf","consulted_on":"2026-10-09","kind":"form"},{"key":"boletin","title":"Boletín para nuevos contribuyentes de IVA — obligaciones formales de la Ley del IVA y del impuesto sobre la renta (tipos de documento, retención del 1 %, declaraciones F-07 y F-14, servicios en línea)","publisher":"Ministerio de Hacienda — Dirección General de Impuestos Internos (DGII)","url":"https://www.mh.gob.sv/wp-content/uploads/2025/12/BOLETIN-PARA-NUEVOS-CONTRIBUYENTES-01122025.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"portal","title":"Portal de servicios en línea de la DGII — presentar y pagar declaraciones (F-07) e informes","publisher":"Ministerio de Hacienda — Dirección General de Impuestos Internos (DGII)","url":"https://portaldgii.mh.gob.sv/ssc/","consulted_on":"2026-10-09","kind":"portal"},{"key":"factura","title":"Sistema de Facturación Electrónica — Documentos Tributarios Electrónicos (DTE): documentos técnicos y consulta de la fecha de inicio obligatorio de cada emisor","publisher":"Ministerio de Hacienda de la República de El Salvador","url":"https://factura.gob.sv","consulted_on":"2026-10-09","kind":"guidance"},{"key":"cvpcpa462","title":"Resolución 462 del 18 de marzo de 2021 — adopta y ratifica la NIIF para las PYMES (versión en español 2015) y las NIIF completas (versión en español 2020)","publisher":"Consejo de Vigilancia de la Profesión de Contaduría Pública y Auditoría (CVPCPA)","url":"https://www.cvpcpa.gob.sv/download/resolucion-462/","consulted_on":"2026-10-09","kind":"regulation"}]'::jsonb)
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
  ('SV', 'default', 'Plan de cuentas inspirado en las NIIF', '{}'::jsonb, true, 'companies', array['SV-NIIF-ER', 'SV-NIIF-ESF']::text[], null, 'El Salvador no tiene un catálogo de cuentas legal obligatorio. El Código de Comercio exige a los comerciantes llevar contabilidad formal, y el Consejo de Vigilancia de la Profesión de Contaduría Pública y Auditoría fija el marco: la Resolución 462 del 18 de marzo de 2021 ratifica la NIIF para las PYMES (versión en español 2015) para las entidades sin obligación pública de rendir cuentas y las NIIF completas (versión en español 2020) para las demás. Este plan es original: sigue la clasificación en activo, pasivo, patrimonio, ingresos y gastos que las NIIF prescriben, de modo que cada cuenta de detalle alcanza exactamente una línea de SV-NIIF-ESF o de SV-NIIF-ER', 'cvpcpa462')
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
  ('SV', 'default', '1', 'ACTIVO', '{}'::jsonb, 'asset_current', false, null, 10),
  ('SV', 'default', '11', 'ACTIVO CORRIENTE', '{}'::jsonb, 'asset_current', false, '1', 20),
  ('SV', 'default', '1101', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 'asset_cash', false, '11', 30),
  ('SV', 'default', '110101', 'Caja general', '{}'::jsonb, 'asset_cash', false, '1101', 40),
  ('SV', 'default', '110102', 'Caja chica', '{}'::jsonb, 'asset_cash', false, '1101', 50),
  ('SV', 'default', '110103', 'Bancos', '{}'::jsonb, 'asset_cash', false, '1101', 60),
  ('SV', 'default', '110104', 'Depósitos a plazo con vencimiento menor a tres meses', '{}'::jsonb, 'asset_cash', false, '1101', 70),
  ('SV', 'default', '1102', 'Activos financieros', '{}'::jsonb, 'asset_current', false, '11', 80),
  ('SV', 'default', '110201', 'Inversiones temporales', '{}'::jsonb, 'asset_current', false, '1102', 90),
  ('SV', 'default', '110202', 'Documentos por cobrar a corto plazo', '{}'::jsonb, 'asset_current', false, '1102', 100),
  ('SV', 'default', '1103', 'Cuentas por cobrar comerciales', '{}'::jsonb, 'asset_current', false, '11', 110),
  ('SV', 'default', '110301', 'Clientes locales', '{}'::jsonb, 'asset_receivable', true, '1103', 120),
  ('SV', 'default', '110302', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '1103', 130),
  ('SV', 'default', '110303', '(-) Estimación para cuentas incobrables', '{}'::jsonb, 'asset_current', false, '1103', 140),
  ('SV', 'default', '1104', 'Otras cuentas por cobrar', '{}'::jsonb, 'asset_current', false, '11', 150),
  ('SV', 'default', '110401', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '1104', 160),
  ('SV', 'default', '110402', 'Préstamos y cuentas por cobrar a empleados', '{}'::jsonb, 'asset_current', false, '1104', 170),
  ('SV', 'default', '110403', 'Depósitos en garantía', '{}'::jsonb, 'asset_current', false, '1104', 180),
  ('SV', 'default', '110404', 'Cuentas por cobrar a accionistas', '{}'::jsonb, 'asset_current', false, '1104', 190),
  ('SV', 'default', '1105', 'Inventarios', '{}'::jsonb, 'asset_current', false, '11', 200),
  ('SV', 'default', '110501', 'Inventario de mercaderías', '{}'::jsonb, 'asset_current', false, '1105', 210),
  ('SV', 'default', '110502', 'Inventario de materias primas', '{}'::jsonb, 'asset_current', false, '1105', 220),
  ('SV', 'default', '110503', 'Inventario de productos en proceso', '{}'::jsonb, 'asset_current', false, '1105', 230),
  ('SV', 'default', '110504', 'Inventario de productos terminados', '{}'::jsonb, 'asset_current', false, '1105', 240),
  ('SV', 'default', '110505', '(-) Estimación por deterioro de inventarios', '{}'::jsonb, 'asset_current', false, '1105', 250),
  ('SV', 'default', '1106', 'Gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '11', 260),
  ('SV', 'default', '110601', 'Seguros pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '1106', 270),
  ('SV', 'default', '110602', 'Alquileres pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '1106', 280),
  ('SV', 'default', '110603', 'Otros gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '1106', 290),
  ('SV', 'default', '1107', 'Activos por impuestos corrientes', '{}'::jsonb, 'asset_current', false, '11', 300),
  ('SV', 'default', '110701', 'Remanente de crédito fiscal de IVA por compensar', '{}'::jsonb, 'asset_current', true, '1107', 310),
  ('SV', 'default', '110702', 'IVA retenido o percibido por acreditar (anticipo del 1 %)', '{}'::jsonb, 'asset_current', false, '1107', 320),
  ('SV', 'default', '110703', 'Anticipo del 2 % de IVA por pagos con tarjeta por acreditar', '{}'::jsonb, 'asset_current', false, '1107', 330),
  ('SV', 'default', '110704', 'Pago a cuenta del impuesto sobre la renta', '{}'::jsonb, 'asset_current', false, '1107', 340),
  ('SV', 'default', '110705', 'Retenciones de impuesto sobre la renta que le han practicado', '{}'::jsonb, 'asset_current', false, '1107', 350),
  ('SV', 'default', '12', 'ACTIVO NO CORRIENTE', '{}'::jsonb, 'asset_non_current', false, '1', 360),
  ('SV', 'default', '1201', 'Propiedades planta y equipo', '{}'::jsonb, 'asset_fixed', false, '12', 370),
  ('SV', 'default', '120101', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '1201', 380),
  ('SV', 'default', '120102', 'Edificios', '{}'::jsonb, 'asset_fixed', false, '1201', 390),
  ('SV', 'default', '120103', 'Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1201', 400),
  ('SV', 'default', '120104', 'Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '1201', 410),
  ('SV', 'default', '120105', 'Vehículos', '{}'::jsonb, 'asset_fixed', false, '1201', 420),
  ('SV', 'default', '120106', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '1201', 430),
  ('SV', 'default', '120107', 'Construcciones en proceso', '{}'::jsonb, 'asset_fixed', false, '1201', 440),
  ('SV', 'default', '120108', '(-) Depreciación acumulada de edificios', '{}'::jsonb, 'asset_fixed', false, '1201', 450),
  ('SV', 'default', '120109', '(-) Depreciación acumulada de mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1201', 460),
  ('SV', 'default', '120110', '(-) Depreciación acumulada de equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '1201', 470),
  ('SV', 'default', '120111', '(-) Depreciación acumulada de vehículos', '{}'::jsonb, 'asset_fixed', false, '1201', 480),
  ('SV', 'default', '120112', '(-) Depreciación acumulada de maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '1201', 490),
  ('SV', 'default', '1202', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '12', 500),
  ('SV', 'default', '120201', 'Programas informáticos', '{}'::jsonb, 'asset_non_current', false, '1202', 510),
  ('SV', 'default', '120202', 'Marcas y licencias', '{}'::jsonb, 'asset_non_current', false, '1202', 520),
  ('SV', 'default', '120203', '(-) Amortización acumulada de activos intangibles', '{}'::jsonb, 'asset_non_current', false, '1202', 530),
  ('SV', 'default', '1203', 'Inversiones a largo plazo', '{}'::jsonb, 'asset_non_current', false, '12', 540),
  ('SV', 'default', '120301', 'Inversiones en asociadas y otras inversiones permanentes', '{}'::jsonb, 'asset_non_current', false, '1203', 550),
  ('SV', 'default', '1204', 'Activos por impuesto diferido', '{}'::jsonb, 'asset_non_current', false, '12', 560),
  ('SV', 'default', '120401', 'Impuesto sobre la renta diferido activo', '{}'::jsonb, 'asset_non_current', false, '1204', 570),
  ('SV', 'default', '2', 'PASIVO', '{}'::jsonb, 'liability_current', false, null, 580),
  ('SV', 'default', '21', 'PASIVO CORRIENTE', '{}'::jsonb, 'liability_current', false, '2', 590),
  ('SV', 'default', '2101', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_current', false, '21', 600),
  ('SV', 'default', '210101', 'Proveedores locales', '{}'::jsonb, 'liability_payable', true, '2101', 610),
  ('SV', 'default', '210102', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '2101', 620),
  ('SV', 'default', '210103', 'Documentos por pagar a proveedores', '{}'::jsonb, 'liability_payable', true, '2101', 630),
  ('SV', 'default', '2102', 'Préstamos y obligaciones financieras a corto plazo', '{}'::jsonb, 'liability_current', false, '21', 640),
  ('SV', 'default', '210201', 'Préstamos bancarios a corto plazo', '{}'::jsonb, 'liability_current', false, '2102', 650),
  ('SV', 'default', '210202', 'Sobregiros bancarios', '{}'::jsonb, 'liability_current', false, '2102', 660),
  ('SV', 'default', '210203', 'Porción corriente de préstamos a largo plazo', '{}'::jsonb, 'liability_current', false, '2102', 670),
  ('SV', 'default', '2103', 'Obligaciones laborales y de seguridad social', '{}'::jsonb, 'liability_current', false, '21', 680),
  ('SV', 'default', '210301', 'Sueldos y salarios por pagar', '{}'::jsonb, 'liability_current', false, '2103', 690),
  ('SV', 'default', '210302', 'Cotizaciones por pagar al ISSS y a las AFP', '{}'::jsonb, 'liability_current', false, '2103', 700),
  ('SV', 'default', '210303', 'Retenciones de impuesto sobre la renta a empleados por pagar', '{}'::jsonb, 'liability_current', false, '2103', 710),
  ('SV', 'default', '210304', 'Vacaciones y aguinaldo por pagar', '{}'::jsonb, 'liability_current', false, '2103', 720),
  ('SV', 'default', '210305', 'Indemnizaciones por pagar', '{}'::jsonb, 'liability_current', false, '2103', 730),
  ('SV', 'default', '2104', 'Obligaciones con la administración tributaria', '{}'::jsonb, 'liability_current', false, '21', 740),
  ('SV', 'default', '210401', 'Retenciones de impuesto sobre la renta por pagar', '{}'::jsonb, 'liability_current', false, '2104', 750),
  ('SV', 'default', '210402', 'Impuesto sobre la renta por pagar del ejercicio', '{}'::jsonb, 'liability_current', false, '2104', 760),
  ('SV', 'default', '210403', 'Pago a cuenta del impuesto sobre la renta por pagar', '{}'::jsonb, 'liability_current', false, '2104', 770),
  ('SV', 'default', '210404', 'Impuestos municipales por pagar', '{}'::jsonb, 'liability_current', false, '2104', 780),
  ('SV', 'default', '2105', 'Impuesto a la transferencia de bienes muebles y a la prestación de servicios (IVA)', '{}'::jsonb, 'liability_current', false, '21', 790),
  ('SV', 'default', '210501', 'IVA débito fiscal', '{}'::jsonb, 'liability_current', false, '2105', 800),
  ('SV', 'default', '210502', 'IVA crédito fiscal', '{}'::jsonb, 'liability_current', false, '2105', 810),
  ('SV', 'default', '210503', 'IVA por pagar del período', '{}'::jsonb, 'liability_current', true, '2105', 820),
  ('SV', 'default', '210504', 'IVA retenido a proveedores por pagar (1 %)', '{}'::jsonb, 'liability_current', false, '2105', 830),
  ('SV', 'default', '210505', 'IVA percibido a clientes por pagar (1 %)', '{}'::jsonb, 'liability_current', false, '2105', 840),
  ('SV', 'default', '2106', 'Otras cuentas por pagar', '{}'::jsonb, 'liability_current', false, '21', 850),
  ('SV', 'default', '210601', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '2106', 860),
  ('SV', 'default', '210602', 'Dividendos por pagar', '{}'::jsonb, 'liability_current', false, '2106', 870),
  ('SV', 'default', '210603', 'Cuentas por pagar a accionistas', '{}'::jsonb, 'liability_current', false, '2106', 880),
  ('SV', 'default', '210604', 'Acreedores varios', '{}'::jsonb, 'liability_current', false, '2106', 890),
  ('SV', 'default', '210605', 'Partidas pendientes de aplicar', '{}'::jsonb, 'liability_current', false, '2106', 900),
  ('SV', 'default', '22', 'PASIVO NO CORRIENTE', '{}'::jsonb, 'liability_non_current', false, '2', 910),
  ('SV', 'default', '2201', 'Préstamos y obligaciones financieras a largo plazo', '{}'::jsonb, 'liability_non_current', false, '22', 920),
  ('SV', 'default', '220101', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '2201', 930),
  ('SV', 'default', '220102', 'Otras obligaciones a largo plazo', '{}'::jsonb, 'liability_non_current', false, '2201', 940),
  ('SV', 'default', '2202', 'Provisiones a largo plazo', '{}'::jsonb, 'liability_non_current', false, '22', 950),
  ('SV', 'default', '220201', 'Provisión para indemnizaciones laborales', '{}'::jsonb, 'liability_non_current', false, '2202', 960),
  ('SV', 'default', '2203', 'Pasivos por impuesto diferido', '{}'::jsonb, 'liability_non_current', false, '22', 970),
  ('SV', 'default', '220301', 'Impuesto sobre la renta diferido pasivo', '{}'::jsonb, 'liability_non_current', false, '2203', 980),
  ('SV', 'default', '3', 'PATRIMONIO', '{}'::jsonb, 'equity', false, null, 990),
  ('SV', 'default', '31', 'Capital', '{}'::jsonb, 'equity', false, '3', 1000),
  ('SV', 'default', '310101', 'Capital social suscrito y pagado', '{}'::jsonb, 'equity', false, '31', 1010),
  ('SV', 'default', '310102', 'Aportes para futuro aumento de capital', '{}'::jsonb, 'equity', false, '31', 1020),
  ('SV', 'default', '32', 'Reservas', '{}'::jsonb, 'equity', false, '3', 1030),
  ('SV', 'default', '320101', 'Reserva legal', '{}'::jsonb, 'equity', false, '32', 1040),
  ('SV', 'default', '320102', 'Otras reservas', '{}'::jsonb, 'equity', false, '32', 1050),
  ('SV', 'default', '36', 'Resultados acumulados', '{}'::jsonb, 'equity_retained', false, '3', 1060),
  ('SV', 'default', '360101', 'Utilidades acumuladas', '{}'::jsonb, 'equity_retained', false, '36', 1070),
  ('SV', 'default', '360102', '(-) Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '36', 1080),
  ('SV', 'default', '37', 'Resultado del ejercicio', '{}'::jsonb, 'equity_retained', false, '3', 1090),
  ('SV', 'default', '370101', 'Utilidad del ejercicio', '{}'::jsonb, 'equity_retained', false, '37', 1100),
  ('SV', 'default', '370102', '(-) Pérdida del ejercicio', '{}'::jsonb, 'equity_retained', false, '37', 1110),
  ('SV', 'default', '4', 'INGRESOS', '{}'::jsonb, 'income', false, null, 1120),
  ('SV', 'default', '41', 'Ingresos de actividades ordinarias', '{}'::jsonb, 'income', false, '4', 1130),
  ('SV', 'default', '4101', 'Venta de bienes', '{}'::jsonb, 'income', false, '41', 1140),
  ('SV', 'default', '4102', 'Prestación de servicios', '{}'::jsonb, 'income', false, '41', 1150),
  ('SV', 'default', '4103', 'Exportaciones de bienes', '{}'::jsonb, 'income', false, '41', 1160),
  ('SV', 'default', '4104', 'Exportaciones de servicios', '{}'::jsonb, 'income', false, '41', 1170),
  ('SV', 'default', '4105', '(-) Devoluciones y rebajas sobre ventas', '{}'::jsonb, 'income', false, '41', 1180),
  ('SV', 'default', '42', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '4', 1190),
  ('SV', 'default', '4201', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '42', 1200),
  ('SV', 'default', '4202', 'Ganancia en cambio', '{}'::jsonb, 'income_other', false, '42', 1210),
  ('SV', 'default', '4203', 'Ajuste por redondeo', '{}'::jsonb, 'income_other', false, '42', 1220),
  ('SV', 'default', '4204', 'Ganancia en venta de activos', '{}'::jsonb, 'income_other', false, '42', 1230),
  ('SV', 'default', '4205', 'Otros ingresos varios', '{}'::jsonb, 'income_other', false, '42', 1240),
  ('SV', 'default', '5', 'COSTOS Y GASTOS', '{}'::jsonb, 'expense', false, null, 1250),
  ('SV', 'default', '51', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '5', 1260),
  ('SV', 'default', '5101', 'Costo de mercaderías vendidas', '{}'::jsonb, 'expense_direct_cost', false, '51', 1270),
  ('SV', 'default', '5102', 'Compras netas', '{}'::jsonb, 'expense_direct_cost', false, '51', 1280),
  ('SV', 'default', '5103', 'Costo de servicios prestados', '{}'::jsonb, 'expense_direct_cost', false, '51', 1290),
  ('SV', 'default', '52', 'Gastos de administración', '{}'::jsonb, 'expense', false, '5', 1300),
  ('SV', 'default', '5201', 'Sueldos y prestaciones al personal', '{}'::jsonb, 'expense', false, '52', 1310),
  ('SV', 'default', '5202', 'Cotizaciones patronales al ISSS y a las AFP', '{}'::jsonb, 'expense', false, '52', 1320),
  ('SV', 'default', '5203', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '52', 1330),
  ('SV', 'default', '5204', 'Alquileres', '{}'::jsonb, 'expense', false, '52', 1340),
  ('SV', 'default', '5205', 'Suministros y materiales', '{}'::jsonb, 'expense', false, '52', 1350),
  ('SV', 'default', '5206', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '52', 1360),
  ('SV', 'default', '5207', 'Depreciación de propiedades planta y equipo', '{}'::jsonb, 'expense_depreciation', false, '52', 1370),
  ('SV', 'default', '5208', 'Servicios básicos', '{}'::jsonb, 'expense', false, '52', 1380),
  ('SV', 'default', '5209', 'Seguros', '{}'::jsonb, 'expense', false, '52', 1390),
  ('SV', 'default', '5210', 'Impuestos tasas y contribuciones', '{}'::jsonb, 'expense', false, '52', 1400),
  ('SV', 'default', '5211', 'Gastos de viaje', '{}'::jsonb, 'expense', false, '52', 1410),
  ('SV', 'default', '5212', 'Amortización de activos intangibles', '{}'::jsonb, 'expense_depreciation', false, '52', 1420),
  ('SV', 'default', '5213', 'Gasto por estimación de cuentas incobrables', '{}'::jsonb, 'expense', false, '52', 1430),
  ('SV', 'default', '5214', 'Pérdida en venta de activos', '{}'::jsonb, 'expense', false, '52', 1440),
  ('SV', 'default', '5215', 'Indemnizaciones laborales', '{}'::jsonb, 'expense', false, '52', 1450),
  ('SV', 'default', '53', 'Gastos de venta', '{}'::jsonb, 'expense', false, '5', 1460),
  ('SV', 'default', '5301', 'Publicidad y promoción', '{}'::jsonb, 'expense', false, '53', 1470),
  ('SV', 'default', '5302', 'Comisiones sobre ventas', '{}'::jsonb, 'expense', false, '53', 1480),
  ('SV', 'default', '5303', 'Transporte y fletes sobre ventas', '{}'::jsonb, 'expense', false, '53', 1490),
  ('SV', 'default', '5304', 'Empaques y embalajes', '{}'::jsonb, 'expense', false, '53', 1500),
  ('SV', 'default', '54', 'Gastos financieros', '{}'::jsonb, 'expense', false, '5', 1510),
  ('SV', 'default', '5401', 'Intereses pagados', '{}'::jsonb, 'expense', false, '54', 1520),
  ('SV', 'default', '5402', 'Pérdida en cambio', '{}'::jsonb, 'expense', false, '54', 1530),
  ('SV', 'default', '5403', 'Comisiones bancarias', '{}'::jsonb, 'expense', false, '54', 1540),
  ('SV', 'default', '55', 'Gasto por impuesto sobre la renta', '{}'::jsonb, 'expense', false, '5', 1550),
  ('SV', 'default', '5501', 'Impuesto sobre la renta corriente', '{}'::jsonb, 'expense', false, '55', 1560),
  ('SV', 'default', '5502', 'Impuesto sobre la renta diferido', '{}'::jsonb, 'expense', false, '55', 1570)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('SV', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('SV', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('SV', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('SV', 'COM', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('SV', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('SV', 'VEN', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('SV', 'SV-P-0', 'Compras internas exentas o no sujetas', '{}'::jsonb, 'Adquisición local de bienes o servicios que no causan impuesto trasladable', 'percent', 0, 'purchase', 'exempt', date '1995-06-21', null, 'Ley del IVA, arts. 45 y 46 — una adquisición exenta o no sujeta no traslada impuesto y no genera crédito fiscal. El pack no declara estas compras en ninguna casilla porque la numeración del formulario F07 para ellas no pudo verificarse en una fuente oficial legible: véase el README', null, null, 100, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-P-13', 'Compras internas gravadas al 13 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición local de bienes y servicios gravados, documentada con comprobante de crédito fiscal, destinada a operaciones gravadas o de exportación', 'percent', 13, 'purchase', 'domestic', date '1995-06-21', null, 'Ley del IVA, arts. 54, 61 y 65 — el impuesto trasladado en las adquisiciones de bienes y servicios necesarios para la actividad del contribuyente constituye su crédito fiscal, deducible del débito fiscal del período; formulario F07, casilla 80, compras internas gravadas, y casilla 130, su crédito fiscal. La proporcionalidad del art. 66 (operaciones gravadas y exentas en el mismo período) no está modelada: véase el README', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-P-13-IMP', 'Importaciones gravadas al 13 % de fuera de Centroamérica, con derecho a crédito fiscal', '{}'::jsonb, 'Importación definitiva de bienes, cuyo impuesto se liquida ante la Dirección General de la Renta de Aduanas en el mismo acto que los derechos aduaneros', 'percent', 13, 'purchase', 'import', date '1995-06-21', null, 'Ley del IVA, art. 14 (la importación definitiva de bienes es hecho generador) y art. 94, inciso segundo — el impuesto sobre las importaciones se liquida ante la Dirección General de la Renta de Aduanas en el mismo acto que los impuestos aduaneros, y la constancia de pago constituye el comprobante de crédito fiscal; formulario F07, casilla 75 (importaciones gravadas fuera de la región) y casilla 125 (su crédito fiscal)', null, null, 90, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-0-EXP-BIENES', 'Exportación de bienes fuera de Centroamérica, tasa 0 %', '{}'::jsonb, 'Transferencia definitiva de bienes muebles corporales destinados al uso y consumo en el exterior, fuera de la región centroamericana', 'percent', 0, 'sale', 'export', date '1995-06-21', null, 'Ley del IVA, arts. 74 y 75 — las exportaciones consistentes en transferencias de dominio definitivas de bienes muebles corporales destinados al uso y consumo en el exterior están afectas a la tasa del cero por ciento; art. 76 — el crédito fiscal de las adquisiciones necesarias para la actividad exportadora se deduce del débito fiscal y su remanente se arrastra o se reintegra. Formulario F07, casilla 90, exportaciones de bienes fuera de la región centroamericana', 'G', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-0-EXP-CA', 'Exportación de bienes a Centroamérica, tasa 0 %', '{}'::jsonb, 'Transferencia definitiva de bienes muebles corporales destinados a la región centroamericana', 'percent', 0, 'sale', 'export', date '1995-06-21', null, 'Ley del IVA, arts. 74 y 75, en los mismos términos que la exportación fuera de la región; el formulario F07 la declara aparte, en la casilla 91, exportaciones de bienes a la región centroamericana', 'G', null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-0-EXP-SERV', 'Exportación de servicios, tasa 0 %', '{}'::jsonb, 'Prestación de servicios en el país a usuarios sin domicilio ni residencia en él, utilizados exclusivamente en el extranjero', 'percent', 0, 'sale', 'export', date '1995-06-21', null, 'Ley del IVA, arts. 74 y 75 — las prestaciones de servicios a usuarios que no tienen domicilio ni residencia en el país, cuando los servicios se utilizan exclusivamente en el extranjero, están afectas a la tasa del cero por ciento; no se entienden utilizados exclusivamente en el extranjero la conexión, continuación o terminación de servicios originados en el exterior, que se gravan al 13 %. Formulario F07, casilla 94, exportaciones de servicios', 'G', null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-13-CCF', 'Ventas gravadas al 13 % a contribuyentes (comprobante de crédito fiscal)', '{}'::jsonb, 'Transferencia de bienes muebles corporales y prestación de servicios gravadas, a otro contribuyente del IVA: se documenta con comprobante de crédito fiscal', 'percent', 13, 'sale', 'domestic', date '1995-06-21', null, 'Ley del IVA, art. 54 — la tasa del impuesto es el trece por ciento, aplicable sobre la base imponible (texto del Decreto Legislativo No. 370 del 8 de junio de 1995, publicado en el Diario Oficial No. 114, Tomo 327, del 21 de junio de 1995; valid_from es la fecha de publicación, la fecha exacta de entrada en vigor no se verificó). El formulario F07 declara estas ventas en la casilla 95 y su débito fiscal en la 135; el Boletín de la DGII establece que el comprobante de crédito fiscal se emite en las operaciones con otros contribuyentes', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-13-FAC', 'Ventas gravadas al 13 % a consumidores finales (factura)', '{}'::jsonb, 'Transferencia de bienes y prestación de servicios gravadas a un consumidor final: se documenta con factura', 'percent', 13, 'sale', 'domestic', date '1995-06-21', null, 'Ley del IVA, art. 54 — la tasa del impuesto es el trece por ciento, aplicable sobre la base imponible (texto del Decreto Legislativo No. 370 del 8 de junio de 1995, publicado en el Diario Oficial No. 114, Tomo 327, del 21 de junio de 1995; valid_from es la fecha de publicación, la fecha exacta de entrada en vigor no se verificó). El formulario F07 declara estas ventas en la casilla 96 y su débito fiscal en la 140; el Boletín de la DGII establece que la factura se emite en las operaciones con consumidores finales', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-EXE', 'Ventas internas exentas', '{}'::jsonb, 'Servicios exentos del impuesto, por ejemplo el arrendamiento de inmuebles destinados a vivienda', 'percent', 0, 'sale', 'exempt', date '1995-06-21', null, 'Ley del IVA, art. 46 — están exentos, entre otros, los servicios de arrendamiento, subarrendamiento o cesión del uso o goce temporal de inmuebles destinados a viviendas para la habitación (literal b), los educacionales prestados por instituciones autorizadas por el Ministerio de Educación (literal e) y el transporte público terrestre de pasajeros (literal i); la declaración mensual incluye las operaciones exentas (art. 93). Formulario F07, casilla 85, ventas internas exentas', 'E', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('SV', 'SV-S-NS', 'Ventas internas no sujetas', '{}'::jsonb, 'Operaciones que la ley no grava, declaradas en el formulario F07 junto con las gravadas y las exentas', 'percent', 0, 'sale', 'not_subject', date '1995-06-21', null, 'Ley del IVA, art. 93 — la declaración jurada mensual comprende las operaciones gravadas, exentas y no sujetas realizadas en el período; formulario F07, casilla 86, ventas internas no sujetas', 'O', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null)
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
    ('SV-P-13', 'invoice', 'base', 100, null, '80', array['80']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-P-13', 'invoice', 'tax', 100, '210502', '130', array['130']::text[], 100, 'SV-IVA-F07', 20),
    ('SV-P-13', 'credit_note', 'base', 100, null, '80', array['80']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-P-13', 'credit_note', 'tax', 100, '210502', '130', array['130']::text[], -100, 'SV-IVA-F07', 20),
    ('SV-P-13-IMP', 'invoice', 'base', 100, null, '75', array['75']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-P-13-IMP', 'invoice', 'tax', 100, '210502', '125', array['125']::text[], 100, 'SV-IVA-F07', 20),
    ('SV-S-0-EXP-BIENES', 'invoice', 'base', 100, null, '90', array['90']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-0-EXP-BIENES', 'credit_note', 'base', 100, null, '90', array['90']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-S-0-EXP-CA', 'invoice', 'base', 100, null, '91', array['91']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-0-EXP-CA', 'credit_note', 'base', 100, null, '91', array['91']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-S-0-EXP-SERV', 'invoice', 'base', 100, null, '94', array['94']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-0-EXP-SERV', 'credit_note', 'base', 100, null, '94', array['94']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-S-13-CCF', 'invoice', 'base', 100, null, '95', array['95']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-13-CCF', 'invoice', 'tax', 100, '210501', '135', array['135']::text[], 100, 'SV-IVA-F07', 20),
    ('SV-S-13-CCF', 'credit_note', 'base', 100, null, '95', array['95']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-S-13-CCF', 'credit_note', 'tax', 100, '210501', '135', array['135']::text[], -100, 'SV-IVA-F07', 20),
    ('SV-S-13-FAC', 'invoice', 'base', 100, null, '96', array['96']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-13-FAC', 'invoice', 'tax', 100, '210501', '140', array['140']::text[], 100, 'SV-IVA-F07', 20),
    ('SV-S-13-FAC', 'credit_note', 'base', 100, null, '96', array['96']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-S-13-FAC', 'credit_note', 'tax', 100, '210501', '140', array['140']::text[], -100, 'SV-IVA-F07', 20),
    ('SV-S-EXE', 'invoice', 'base', 100, null, '85', array['85']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-EXE', 'credit_note', 'base', 100, null, '85', array['85']::text[], -100, 'SV-IVA-F07', 10),
    ('SV-S-NS', 'invoice', 'base', 100, null, '86', array['86']::text[], 100, 'SV-IVA-F07', 10),
    ('SV-S-NS', 'credit_note', 'base', 100, null, '86', array['86']::text[], -100, 'SV-IVA-F07', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'SV' and t.code = v.tax_code
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
  ('SV', 'SV-IVA-F07', 'Declaración y pago del impuesto a la transferencia de bienes muebles y a la prestación de servicios — formulario F07', array['month']::declaration_period[], 'month'::declaration_period, date '1970-01-01', null, 'Ley del IVA, art. 93 — el período tributario es de un mes calendario y los contribuyentes presentan mensualmente una declaración jurada sobre las operaciones gravadas, exentas y no sujetas, con el débito fiscal, el crédito fiscal y los remanentes de períodos anteriores; la declaración se presenta aunque no haya operaciones. Se presenta en línea en el portal de servicios de la DGII', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Ley del IVA, art. 94 — la declaración jurada incluye el pago y se presenta dentro de los diez primeros días hábiles del mes siguiente al período tributario; en el mismo lapso se ingresan los impuestos retenidos o percibidos por los agentes de retención o de percepción. El plazo se cuenta en días hábiles, y el vocabulario cerrado de la regla de vencimiento solo conoce días del calendario: este paquete no calcula una fecha, para no marcar como tardía una declaración presentada a tiempo. No es una fecha asignada por contribuyente, pero es la única forma del formato que no inventa un día', 'liva', null)
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
  ('SV', 'SV-IVA-F07', '85', 'base', 'Ventas internas exentas', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 85 — ventas internas exentas (Ley del IVA, art. 46)', 'f07'),
  ('SV', 'SV-IVA-F07', '86', 'base', 'Ventas internas no sujetas', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 86 — ventas internas no sujetas', 'f07'),
  ('SV', 'SV-IVA-F07', '90', 'base', 'Exportaciones de bienes fuera de la región centroamericana', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 90 — exportaciones de bienes fuera de la región centroamericana, a tasa cero (Ley del IVA, arts. 74 y 75)', 'f07'),
  ('SV', 'SV-IVA-F07', '91', 'base', 'Exportaciones de bienes a la región centroamericana', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 91 — exportaciones de bienes a la región centroamericana, a tasa cero', 'f07'),
  ('SV', 'SV-IVA-F07', '94', 'base', 'Exportaciones de servicios', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 94 — exportaciones de servicios, a tasa cero', 'f07'),
  ('SV', 'SV-IVA-F07', '95', 'base', 'Ventas internas gravadas con comprobante de crédito fiscal', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 95 — ventas internas gravadas documentadas con comprobante de crédito fiscal', 'f07'),
  ('SV', 'SV-IVA-F07', '135', 'tax', 'Débito fiscal por ventas con comprobante de crédito fiscal', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 135 — débito fiscal de las ventas de la casilla 95', 'f07'),
  ('SV', 'SV-IVA-F07', '96', 'base', 'Ventas internas gravadas con factura', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 96 — ventas internas gravadas documentadas con factura a consumidores finales', 'f07'),
  ('SV', 'SV-IVA-F07', '140', 'tax', 'Débito fiscal por ventas con factura', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 140 — débito fiscal de las ventas de la casilla 96', 'f07'),
  ('SV', 'SV-IVA-F07', '105', 'total', 'Total de ventas', '{}'::jsonb, 100, null, array['85', '86', '90', '91', '94', '95', '96']::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 105 — suma de las ventas del período. Este paquete suma solo las casillas que declara (85, 86, 90, 91, 94, 95 y 96); no modela las ventas exentas no sujetas a proporcionalidad (92) ni las ventas por cuenta de terceros (108), que el formulario excluye de la suma', 'f07'),
  ('SV', 'SV-IVA-F07', '150', 'total', 'Total de débitos fiscales', '{}'::jsonb, 110, null, array['135', '140']::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 150 — suma de los débitos fiscales. Este paquete suma solo las casillas 135 y 140; no modela el débito proveniente de crédito negativo (146) ni los demás componentes de la suma', 'f07'),
  ('SV', 'SV-IVA-F07', '80', 'base', 'Compras internas gravadas', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 80 — compras internas gravadas', 'f07'),
  ('SV', 'SV-IVA-F07', '130', 'tax', 'Crédito fiscal por compras internas gravadas', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 130 — crédito fiscal de las compras de la casilla 80', 'f07'),
  ('SV', 'SV-IVA-F07', '75', 'base', 'Importaciones gravadas de fuera de la región centroamericana', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 75 — importaciones gravadas de bienes de fuera de la región (Ley del IVA, art. 94)', 'f07'),
  ('SV', 'SV-IVA-F07', '125', 'tax', 'Crédito fiscal por importaciones gravadas', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario F07, casilla 125 — crédito fiscal de las importaciones de la casilla 75', 'f07'),
  ('SV', 'SV-IVA-F07', 'PAGAR', 'total', 'Impuesto a pagar', '{}'::jsonb, 160, null, array['150']::text[], array['125', '130']::text[], null, null, true, false, null, 'Diferencia entre el total de débitos fiscales (150) y el crédito fiscal del período (125 más 130), cuando es mayor que cero (Ley del IVA, art. 93, inciso segundo — la declaración liquida el impuesto a pagar). El formulario F07 imprime este resultado; la numeración de su casilla no pudo verificarse en una fuente oficial legible, por lo que este paquete lo identifica con un código mnemotécnico y no inventa un número. No modela el remanente de períodos anteriores, las retenciones y percepciones sufridas (art. 162 y 163 del Código Tributario) ni el anticipo del 2 % por pagos con tarjeta: véase el README', 'liva'),
  ('SV', 'SV-IVA-F07', 'REMAN', 'total', 'Remanente de crédito fiscal', '{}'::jsonb, 170, null, array['125', '130']::text[], array['150']::text[], null, null, true, false, null, 'Diferencia entre el crédito fiscal del período (125 más 130) y el total de débitos fiscales (150), cuando es mayor que cero (Ley del IVA, arts. 67 y 76 — el remanente se deduce en los períodos siguientes o, en el caso del exportador, puede acreditarse o reintegrarse). La numeración de su casilla en el formulario F07 no pudo verificarse; este paquete lo identifica con un código mnemotécnico', 'liva')
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
  ('SV-NIIF-ER', 'SV', 'default', 'Estado de resultado integral', 'income_statement', 'SV-NIIF', date '1970-01-01', null, 'Marco contable de El Salvador — Resolución 462 del Consejo de Vigilancia de la Profesión de Contaduría Pública y Auditoría (18 de marzo de 2021): los estados financieros se preparan conforme a la NIIF para las PYMES (versión en español 2015) o a las NIIF completas (versión en español 2020), cuyos estados de situación financiera y de resultado integral se presentan por clasificación de corriente y no corriente y por naturaleza del gasto. No existe un formato legal único; este paquete presenta un estado resumido. Estado de resultados resumido, por naturaleza.', 'cvpcpa462'),
  ('SV-NIIF-ESF', 'SV', 'default', 'Estado de situación financiera', 'balance_sheet', 'SV-NIIF', date '1970-01-01', null, 'Marco contable de El Salvador — Resolución 462 del Consejo de Vigilancia de la Profesión de Contaduría Pública y Auditoría (18 de marzo de 2021): los estados financieros se preparan conforme a la NIIF para las PYMES (versión en español 2015) o a las NIIF completas (versión en español 2020), cuyos estados de situación financiera y de resultado integral se presentan por clasificación de corriente y no corriente y por naturaleza del gasto. No existe un formato legal único; este paquete presenta un estado resumido. Estado de situación financiera resumido.', 'cvpcpa462')
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
  ('SV-NIIF-ER', 'ING', 'UN', 'Ingresos de actividades ordinarias', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'OIN', 'UN', 'Otros ingresos', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'COV', 'UN', 'Costo de ventas', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'GAD', 'UN', 'Gastos de administración', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'GVE', 'UN', 'Gastos de venta', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'GFI', 'UN', 'Gastos financieros', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'GIR', 'UN', 'Gasto por impuesto sobre la renta', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ER', 'UN', null, 'Ganancia (pérdida) neta del período', '{}'::jsonb, 80, 1, true, array['ING', 'OIN']::text[], array['COV', 'GAD', 'GVE', 'GFI', 'GIR']::text[], null, null, null),
  ('SV-NIIF-ESF', 'EFEC', 'AC', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'FIN', 'AC', 'Activos financieros', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'CXC', 'AC', 'Cuentas por cobrar comerciales', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'OCXC', 'AC', 'Otras cuentas por cobrar', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'INV', 'AC', 'Inventarios', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'ANT', 'AC', 'Gastos pagados por anticipado', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'IMPC', 'AC', 'Activos por impuestos corrientes', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'AC', 'ACT', 'Total activo corriente', '{}'::jsonb, 80, 1, true, array['EFEC', 'FIN', 'CXC', 'OCXC', 'INV', 'ANT', 'IMPC']::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'PPE', 'ANC', 'Propiedades planta y equipo', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'INT', 'ANC', 'Activos intangibles', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'ILP', 'ANC', 'Inversiones a largo plazo', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'IDA', 'ANC', 'Activos por impuesto diferido', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'ANC', 'ACT', 'Total activo no corriente', '{}'::jsonb, 130, 1, true, array['PPE', 'INT', 'ILP', 'IDA']::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'ACT', null, 'Total activo', '{}'::jsonb, 140, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'CXP', 'PC', 'Cuentas por pagar comerciales', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'OFCP', 'PC', 'Préstamos y obligaciones financieras a corto plazo', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'LAB', 'PC', 'Obligaciones laborales y de seguridad social', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'ADMT', 'PC', 'Obligaciones con la administración tributaria', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'IVAP', 'PC', 'Impuesto a la transferencia de bienes muebles y a la prestación de servicios (IVA)', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'OCXP', 'PC', 'Otras cuentas por pagar', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'PC', 'PAS', 'Total pasivo corriente', '{}'::jsonb, 210, 1, true, array['CXP', 'OFCP', 'LAB', 'ADMT', 'IVAP', 'OCXP']::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'OFLP', 'PNC', 'Préstamos y obligaciones financieras a largo plazo', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'PROV', 'PNC', 'Provisiones a largo plazo', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'IDP', 'PNC', 'Pasivos por impuesto diferido', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'PNC', 'PAS', 'Total pasivo no corriente', '{}'::jsonb, 250, 1, true, array['OFLP', 'PROV', 'IDP']::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'PAS', null, 'Total pasivo', '{}'::jsonb, 260, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'CAP', 'PAT', 'Capital', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'RES', 'PAT', 'Reservas', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'RACU', 'PAT', 'Resultados acumulados', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'REJE', 'PAT', 'Resultado del ejercicio', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('SV-NIIF-ESF', 'PAT', null, 'Total patrimonio', '{}'::jsonb, 310, 1, true, array['CAP', 'RES', 'RACU', 'REJE']::text[], '{}'::text[], null, null, null)
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
    ('SV-NIIF-ER', 'ING', 10, 'code_prefix', '41', null, null, 'any'),
    ('SV-NIIF-ER', 'OIN', 10, 'code_prefix', '42', null, null, 'any'),
    ('SV-NIIF-ER', 'COV', 10, 'code_prefix', '51', null, null, 'any'),
    ('SV-NIIF-ER', 'GAD', 10, 'code_prefix', '52', null, null, 'any'),
    ('SV-NIIF-ER', 'GVE', 10, 'code_prefix', '53', null, null, 'any'),
    ('SV-NIIF-ER', 'GFI', 10, 'code_prefix', '54', null, null, 'any'),
    ('SV-NIIF-ER', 'GIR', 10, 'code_prefix', '55', null, null, 'any'),
    ('SV-NIIF-ESF', 'EFEC', 10, 'code_prefix', '1101', null, null, 'any'),
    ('SV-NIIF-ESF', 'FIN', 10, 'code_prefix', '1102', null, null, 'any'),
    ('SV-NIIF-ESF', 'CXC', 10, 'code_prefix', '1103', null, null, 'any'),
    ('SV-NIIF-ESF', 'OCXC', 10, 'code_prefix', '1104', null, null, 'any'),
    ('SV-NIIF-ESF', 'INV', 10, 'code_prefix', '1105', null, null, 'any'),
    ('SV-NIIF-ESF', 'ANT', 10, 'code_prefix', '1106', null, null, 'any'),
    ('SV-NIIF-ESF', 'IMPC', 10, 'code_prefix', '1107', null, null, 'any'),
    ('SV-NIIF-ESF', 'PPE', 10, 'code_prefix', '1201', null, null, 'any'),
    ('SV-NIIF-ESF', 'INT', 10, 'code_prefix', '1202', null, null, 'any'),
    ('SV-NIIF-ESF', 'ILP', 10, 'code_prefix', '1203', null, null, 'any'),
    ('SV-NIIF-ESF', 'IDA', 10, 'code_prefix', '1204', null, null, 'any'),
    ('SV-NIIF-ESF', 'CXP', 10, 'code_prefix', '2101', null, null, 'any'),
    ('SV-NIIF-ESF', 'OFCP', 10, 'code_prefix', '2102', null, null, 'any'),
    ('SV-NIIF-ESF', 'LAB', 10, 'code_prefix', '2103', null, null, 'any'),
    ('SV-NIIF-ESF', 'ADMT', 10, 'code_prefix', '2104', null, null, 'any'),
    ('SV-NIIF-ESF', 'IVAP', 10, 'code_prefix', '2105', null, null, 'any'),
    ('SV-NIIF-ESF', 'OCXP', 10, 'code_prefix', '2106', null, null, 'any'),
    ('SV-NIIF-ESF', 'OFLP', 10, 'code_prefix', '2201', null, null, 'any'),
    ('SV-NIIF-ESF', 'PROV', 10, 'code_prefix', '2202', null, null, 'any'),
    ('SV-NIIF-ESF', 'IDP', 10, 'code_prefix', '2203', null, null, 'any'),
    ('SV-NIIF-ESF', 'CAP', 10, 'code_prefix', '31', null, null, 'any'),
    ('SV-NIIF-ESF', 'RES', 10, 'code_prefix', '32', null, null, 'any'),
    ('SV-NIIF-ESF', 'RACU', 10, 'code_prefix', '36', null, null, 'any'),
    ('SV-NIIF-ESF', 'REJE', 10, 'code_prefix', '37', null, null, 'any')
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
  ('SV', 'El Salvador', '{}'::jsonb, array['es']::text[], 'USD', '110301', '210101', '210605', '4203', '360101', '4101', '5102', '110103', '110101', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '370101', '370102', '360102', 'APE', 'half_up', default, '4202', '5402', '4204', '5214', null, null, '210503', '110701', 'Asiento de apertura', 'month'::declaration_period)
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
  number_format                 = '{CODE}-{NNNNNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Código Tributario, art. 114 — los comprobantes de crédito fiscal y las facturas llevan numeración correlativa, independiente para cada establecimiento; en el régimen de Documentos Tributarios Electrónicos el número de control de cada documento lo fija la normativa técnica de la Administración Tributaria (arts. 119-A y siguientes). El código de esta pieza contable es el diario y un consecutivo de nueve dígitos; Ekwo no genera el número de control ni el código de generación del DTE: véase el README de este paquete',
  numbering_source_key          = 'ct',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'earliest_of_delivery_or_payment',
  tax_point_legal_reference     = 'Ley del IVA, art. 8 — en las transferencias de bienes el impuesto se causa cuando se emite el documento que da constancia de la operación, y antes si el precio se paga o los bienes se entregan real o simbólicamente antes de esa emisión; art. 18 — en las prestaciones de servicios, cuando ocurra primero la emisión del documento, el término de la prestación, la entrega del bien o el pago total o parcial. El vocabulario cerrado de esta casilla no nombra la emisión del documento como tercer hecho: la regla se aproxima con la primera de entrega o pago, que coincide con la emisión en la práctica general',
  tax_point_source_key          = 'liva',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Código Tributario, art. 110 — cuando con posterioridad a la emisión de un comprobante de crédito fiscal se produzcan devoluciones, ajustes o anulaciones, se expiden notas de crédito o de débito que referencian el documento original; Decreto Legislativo No. 487 — un documento tributario electrónico que ha obtenido el sello de recepción se corrige con un documento nuevo o se anula mediante un evento de invalidación dentro del plazo que fija la Administración Tributaria; Ekwo registra solo la corrección por nota de crédito',
  posted_edit_policy_source_key = 'd487',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Código Tributario, arts. 119-A a 119-H (Decreto Legislativo No. 487 de 2022) — los contribuyentes emiten Documentos Tributarios Electrónicos (DTE) que se generan, firman y transmiten a la Administración Tributaria, y se tienen por emitidos cuando ésta otorga el sello de recepción; el sello no implica validación ni autorización de la operación. El art. 12 transitorio faculta a la Administración Tributaria para fijar las fechas desde las cuales cada contribuyente está obligado: no hay una fecha única, la DGII notifica a cada contribuyente su fecha de inicio y cada uno la consulta en factura.gob.sv. La obligación existe para los contribuyentes notificados, pero el formato solo acepta «obligation: mandatory» junto con una fecha y un perfil construido sobre EN 16931 (que el DTE no es), por lo que obligation y mandatory_from quedan sin declarar, como en los paquetes de México y Colombia; los grandes contribuyentes empezaron el 1 de julio de 2023 según la información pública del calendario de incorporación, dato que no se contrastó con un comunicado de la Administración Tributaria — véase el README. Es un régimen de validación previa (clearance) con sello de recepción, y no un intercambio sobre EN 16931: profile queda vacío. EKWO NO GENERA, NO FIRMA NI TRANSMITE NINGÚN DTE. El RUC salvadoreño (NIT y NRC) no tiene un esquema ISO 6523 registrado: party_scheme y vat_scheme quedan vacíos',
  einvoice_source_key           = 'd487',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'SV';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('SV', 'dte_seal_pending', 'always', 'Este documento no constituye un Documento Tributario Electrónico con sello de recepción del Ministerio de Hacienda: solo el documento transmitido y sellado por la Administración Tributaria se tiene por emitido para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Código Tributario, art. 119-B y 119-C (Decreto Legislativo No. 487) — los documentos tributarios electrónicos se entienden emitidos cuando la Administración Tributaria otorga el sello de recepción; Ekwo no firma, no transmite ni obtiene el sello: véase el README de este paquete'),
  ('SV', 'export', 'export', 'Exportación — operación afecta a la tasa del cero por ciento del impuesto a la transferencia de bienes muebles y a la prestación de servicios.', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley del IVA, arts. 74 y 75 — las exportaciones de bienes destinados al uso y consumo en el exterior y de servicios utilizados exclusivamente en el extranjero están afectas a la tasa del cero por ciento'),
  ('SV', 'exempt', 'exempt', 'Operación exenta del impuesto a la transferencia de bienes muebles y a la prestación de servicios.', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley del IVA, art. 46 — servicios exentos (entre ellos el arrendamiento de inmuebles destinados a vivienda, la educación prestada por instituciones autorizadas y el transporte público terrestre de pasajeros); art. 45 para las importaciones exentas')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
