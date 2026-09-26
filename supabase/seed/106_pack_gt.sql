-- Ekwo OS — Guatemala: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/gt at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build gt`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Decreto Número 27-92, Ley del Impuesto al Valor Agregado, texto con sus reformas (Decretos 29-94, 60-94, 142-96, 39-99, 44-2000, 80-2000, 32-2001, 48-2001, 62-2001, 66-2002, 88-2002 y 4-2012) (Congreso de la República de Guatemala — Departamento de Información Legislativa)
--     https://www.congreso.gob.gt/detalle_pdf/decretos/1196
--   Decreto Número 4-2012, Disposiciones para el Fortalecimiento del Sistema Tributario y el Combate a la Defraudación y al Contrabando — Libro II, reformas a la Ley del Impuesto al Valor Agregado (régimen de Pequeño Contribuyente, documentación del crédito fiscal, documentos obligatorios) (Congreso de la República de Guatemala)
--     https://www.congreso.gob.gt/assets/uploads/info_legislativo/decretos/2012/004-2012.pdf
--   Acuerdo Gubernativo Número 5-2013, Reglamento de la Ley del Impuesto al Valor Agregado (Ministerio de Finanzas Públicas de Guatemala)
--     https://www.minfin.gob.gt/images/leyes%20solicitadas/Leyes%20tributarias/ACUERDO%20GUBERNATIVO%205-2013%20(Reglamento%20ley%20del%20IVA).doc
--   Decreto Número 2-70, Código de Comercio de Guatemala, texto con sus reformas (Congreso de la República de Guatemala)
--     https://www.congreso.gob.gt/assets/uploads/info_legislativo/decretos/1970/gtdcx00021970np.pdf
--   Resolución de la Asamblea General Extraordinaria del Colegio de Contadores Públicos y Auditores de Guatemala, del 29 de junio de 2010, que adopta la Norma Internacional de Información Financiera para Pequeñas y Medianas Entidades (NIIF para PYMES), publicada en el Diario de Centro América el 13 de julio de 2010, de aplicación obligatoria desde el 1 de enero de 2011 (Colegio de Contadores Públicos y Auditores de Guatemala)
--     https://cpa.org.gt/
--   Cumplimiento Tributario — preguntas frecuentes sobre la Declaración Jurada y Pago Mensual del Impuesto al Valor Agregado, Formulario SAT-2237, Régimen General (Superintendencia de Administración Tributaria — Portal SAT)
--     https://portal.sat.gob.gt/portal/preguntas-frecuentes/cumplimiento-tributario/
--   Declaraguate — sistema electrónico de declaraciones y boletas de pago de la Superintendencia de Administración Tributaria (Superintendencia de Administración Tributaria)
--     https://declaraguate.sat.gob.gt/
--   Acuerdo de Directorio Número 13-2018, que establece el Régimen de Factura Electrónica en Línea (FEL), modificado por el Acuerdo de Directorio Número 26-2019 (Superintendencia de Administración Tributaria)
--     https://portal.sat.gob.gt/portal/descarga/1740/factura-electronica/25094/acuerdo-de-directorio-13-2018.pdf
--   Factura Electrónica en Línea (FEL) — información institucional del régimen y de los certificadores autorizados (Superintendencia de Administración Tributaria — Portal SAT)
--     https://portal.sat.gob.gt/portal/efactura/
--   Libro Electrónico Tributario — Régimen de Pequeño Contribuyente del Impuesto al Valor Agregado (Superintendencia de Administración Tributaria — Portal SAT)
--     https://portal.sat.gob.gt/portal/libro-electronico-tributario/pequeno-contribuyente/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('GT', 'Guatemala', '0.1.0', date '2026-09-26', '20260921084143', 'community', null, null, '1229bc40389b53e3fdc687d6a3eda73cd4e46bcfe69c069aabb012577b2e49f1', '[{"key":"ley-iva","title":"Decreto Número 27-92, Ley del Impuesto al Valor Agregado, texto con sus reformas (Decretos 29-94, 60-94, 142-96, 39-99, 44-2000, 80-2000, 32-2001, 48-2001, 62-2001, 66-2002, 88-2002 y 4-2012)","publisher":"Congreso de la República de Guatemala — Departamento de Información Legislativa","url":"https://www.congreso.gob.gt/detalle_pdf/decretos/1196","consulted_on":"2026-09-26","kind":"law"},{"key":"decreto-4-2012","title":"Decreto Número 4-2012, Disposiciones para el Fortalecimiento del Sistema Tributario y el Combate a la Defraudación y al Contrabando — Libro II, reformas a la Ley del Impuesto al Valor Agregado (régimen de Pequeño Contribuyente, documentación del crédito fiscal, documentos obligatorios)","publisher":"Congreso de la República de Guatemala","url":"https://www.congreso.gob.gt/assets/uploads/info_legislativo/decretos/2012/004-2012.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"reglamento-iva","title":"Acuerdo Gubernativo Número 5-2013, Reglamento de la Ley del Impuesto al Valor Agregado","publisher":"Ministerio de Finanzas Públicas de Guatemala","url":"https://www.minfin.gob.gt/images/leyes%20solicitadas/Leyes%20tributarias/ACUERDO%20GUBERNATIVO%205-2013%20(Reglamento%20ley%20del%20IVA).doc","consulted_on":"2026-09-26","kind":"regulation"},{"key":"codigo-comercio","title":"Decreto Número 2-70, Código de Comercio de Guatemala, texto con sus reformas","publisher":"Congreso de la República de Guatemala","url":"https://www.congreso.gob.gt/assets/uploads/info_legislativo/decretos/1970/gtdcx00021970np.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"niif-pymes-ccpag","title":"Resolución de la Asamblea General Extraordinaria del Colegio de Contadores Públicos y Auditores de Guatemala, del 29 de junio de 2010, que adopta la Norma Internacional de Información Financiera para Pequeñas y Medianas Entidades (NIIF para PYMES), publicada en el Diario de Centro América el 13 de julio de 2010, de aplicación obligatoria desde el 1 de enero de 2011","publisher":"Colegio de Contadores Públicos y Auditores de Guatemala","url":"https://cpa.org.gt/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"sat-2237-guia","title":"Cumplimiento Tributario — preguntas frecuentes sobre la Declaración Jurada y Pago Mensual del Impuesto al Valor Agregado, Formulario SAT-2237, Régimen General","publisher":"Superintendencia de Administración Tributaria — Portal SAT","url":"https://portal.sat.gob.gt/portal/preguntas-frecuentes/cumplimiento-tributario/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"declaraguate","title":"Declaraguate — sistema electrónico de declaraciones y boletas de pago de la Superintendencia de Administración Tributaria","publisher":"Superintendencia de Administración Tributaria","url":"https://declaraguate.sat.gob.gt/","consulted_on":"2026-09-26","kind":"portal"},{"key":"fel-acuerdo-13-2018","title":"Acuerdo de Directorio Número 13-2018, que establece el Régimen de Factura Electrónica en Línea (FEL), modificado por el Acuerdo de Directorio Número 26-2019","publisher":"Superintendencia de Administración Tributaria","url":"https://portal.sat.gob.gt/portal/descarga/1740/factura-electronica/25094/acuerdo-de-directorio-13-2018.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"sat-efactura","title":"Factura Electrónica en Línea (FEL) — información institucional del régimen y de los certificadores autorizados","publisher":"Superintendencia de Administración Tributaria — Portal SAT","url":"https://portal.sat.gob.gt/portal/efactura/","consulted_on":"2026-09-26","kind":"portal"},{"key":"sat-pequeno-contribuyente","title":"Libro Electrónico Tributario — Régimen de Pequeño Contribuyente del Impuesto al Valor Agregado","publisher":"Superintendencia de Administración Tributaria — Portal SAT","url":"https://portal.sat.gob.gt/portal/libro-electronico-tributario/pequeno-contribuyente/","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('GT', 'default', 'Plan de cuentas de referencia, sobre la NIIF para PYMES', '{}'::jsonb, true, 'companies', array['GT-EF-ER', 'GT-EF-ESF']::text[], null, 'Guatemala no impone un catálogo de cuentas único ni numerado: el Código de Comercio, Decreto Número 2-70, art. 368, exige sólo que la contabilidad se lleve de forma organizada, por partida doble y conforme a los principios de contabilidad generalmente aceptados, sin prescribir cuentas. La Resolución del 29 de junio de 2010 del Colegio de Contadores Públicos y Auditores de Guatemala adopta la NIIF para PYMES como esos principios generalmente aceptados desde el 1 de enero de 2011, y sus secciones 4 y 5 fijan el contenido mínimo del estado de situación financiera y del estado de resultados que GT-EF-ESF y GT-EF-ER siguen. Este plan es original: sigue una numeración propia y cada bloque de códigos corresponde a una línea de esos dos esquemas — véase el README', 'codigo-comercio')
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
  ('GT', 'default', '100', 'Activo', '{}'::jsonb, 'asset_current', false, null, 10),
  ('GT', 'default', '110', 'Activo corriente', '{}'::jsonb, 'asset_current', false, '100', 20),
  ('GT', 'default', '111', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 'asset_cash', false, '110', 30),
  ('GT', 'default', '1111', 'Caja general', '{}'::jsonb, 'asset_cash', false, '111', 40),
  ('GT', 'default', '1112', 'Caja chica', '{}'::jsonb, 'asset_cash', false, '111', 50),
  ('GT', 'default', '1113', 'Bancos - cuentas monetarias', '{}'::jsonb, 'asset_cash', false, '111', 60),
  ('GT', 'default', '1114', 'Bancos - cuentas de ahorro', '{}'::jsonb, 'asset_cash', false, '111', 70),
  ('GT', 'default', '1115', 'Inversiones temporales', '{}'::jsonb, 'asset_current', false, '111', 80),
  ('GT', 'default', '112', 'Cuentas por cobrar comerciales', '{}'::jsonb, 'asset_current', false, '110', 90),
  ('GT', 'default', '1121', 'Clientes locales', '{}'::jsonb, 'asset_receivable', true, '112', 100),
  ('GT', 'default', '1122', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '112', 110),
  ('GT', 'default', '1123', 'Documentos por cobrar', '{}'::jsonb, 'asset_receivable', true, '112', 120),
  ('GT', 'default', '113', 'Otras cuentas por cobrar', '{}'::jsonb, 'asset_current', false, '110', 130),
  ('GT', 'default', '1131', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '113', 140),
  ('GT', 'default', '1132', 'Préstamos y anticipos a empleados', '{}'::jsonb, 'asset_current', false, '113', 150),
  ('GT', 'default', '1133', 'Cuentas por cobrar a socios y accionistas', '{}'::jsonb, 'asset_current', false, '113', 160),
  ('GT', 'default', '1134', 'Deudores varios', '{}'::jsonb, 'asset_current', false, '113', 170),
  ('GT', 'default', '114', 'Impuestos por cobrar', '{}'::jsonb, 'asset_current', false, '110', 180),
  ('GT', 'default', '1141', 'IVA - Crédito Fiscal', '{}'::jsonb, 'asset_current', false, '114', 190),
  ('GT', 'default', '1142', 'IVA - Crédito Fiscal por Cobrar', '{}'::jsonb, 'asset_current', true, '114', 200),
  ('GT', 'default', '1143', 'Impuesto Sobre la Renta - Pagos a cuenta', '{}'::jsonb, 'asset_current', false, '114', 210),
  ('GT', 'default', '1144', 'Isr Retenido por Terceros', '{}'::jsonb, 'asset_current', false, '114', 220),
  ('GT', 'default', '115', 'Gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '110', 230),
  ('GT', 'default', '116', 'Inventarios', '{}'::jsonb, 'asset_current', false, '110', 240),
  ('GT', 'default', '1161', 'Mercaderías', '{}'::jsonb, 'asset_current', false, '116', 250),
  ('GT', 'default', '1162', 'Materias primas', '{}'::jsonb, 'asset_current', false, '116', 260),
  ('GT', 'default', '1163', 'Productos en proceso de producción', '{}'::jsonb, 'asset_current', false, '116', 270),
  ('GT', 'default', '1164', 'Productos terminados', '{}'::jsonb, 'asset_current', false, '116', 280),
  ('GT', 'default', '1165', 'Repuestos y materiales diversos', '{}'::jsonb, 'asset_current', false, '116', 290),
  ('GT', 'default', '119', 'Partidas pendientes de imputación', '{}'::jsonb, 'asset_current', false, '110', 300),
  ('GT', 'default', '120', 'Activo no corriente', '{}'::jsonb, 'asset_non_current', false, '100', 310),
  ('GT', 'default', '121', 'Propiedad, planta y equipo', '{}'::jsonb, 'asset_fixed', false, '120', 320),
  ('GT', 'default', '1211', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '121', 330),
  ('GT', 'default', '12110', 'Depreciación acumulada - Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '121', 420),
  ('GT', 'default', '12111', 'Depreciación acumulada - Vehículos', '{}'::jsonb, 'asset_fixed', false, '121', 430),
  ('GT', 'default', '12112', 'Depreciación acumulada - Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '121', 440),
  ('GT', 'default', '12113', 'Depreciación acumulada - Mejoras a propiedades arrendadas', '{}'::jsonb, 'asset_fixed', false, '121', 450),
  ('GT', 'default', '1212', 'Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '121', 340),
  ('GT', 'default', '1213', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '121', 350),
  ('GT', 'default', '1214', 'Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '121', 360),
  ('GT', 'default', '1215', 'Vehículos', '{}'::jsonb, 'asset_fixed', false, '121', 370),
  ('GT', 'default', '1216', 'Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '121', 380),
  ('GT', 'default', '1217', 'Mejoras a propiedades arrendadas', '{}'::jsonb, 'asset_fixed', false, '121', 390),
  ('GT', 'default', '1218', 'Depreciación acumulada - Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '121', 400),
  ('GT', 'default', '1219', 'Depreciación acumulada - Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '121', 410),
  ('GT', 'default', '122', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '120', 460),
  ('GT', 'default', '1221', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '122', 470),
  ('GT', 'default', '1222', 'Programas de cómputo (software)', '{}'::jsonb, 'asset_non_current', false, '122', 480),
  ('GT', 'default', '1223', 'Amortización acumulada de intangibles', '{}'::jsonb, 'asset_non_current', false, '122', 490),
  ('GT', 'default', '123', 'Otros activos no corrientes', '{}'::jsonb, 'asset_non_current', false, '120', 500),
  ('GT', 'default', '1231', 'Depósitos en garantía', '{}'::jsonb, 'asset_non_current', false, '123', 510),
  ('GT', 'default', '1232', 'Inversiones permanentes', '{}'::jsonb, 'asset_non_current', false, '123', 520),
  ('GT', 'default', '1233', 'Cuentas por cobrar a largo plazo', '{}'::jsonb, 'asset_non_current', false, '123', 530),
  ('GT', 'default', '200', 'Pasivo', '{}'::jsonb, 'liability_current', false, null, 540),
  ('GT', 'default', '210', 'Pasivo corriente', '{}'::jsonb, 'liability_current', false, '200', 550),
  ('GT', 'default', '211', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_current', false, '210', 560),
  ('GT', 'default', '2111', 'Proveedores locales', '{}'::jsonb, 'liability_payable', true, '211', 570),
  ('GT', 'default', '2112', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '211', 580),
  ('GT', 'default', '2113', 'Documentos por pagar', '{}'::jsonb, 'liability_payable', true, '211', 590),
  ('GT', 'default', '212', 'Remuneraciones y prestaciones laborales por pagar', '{}'::jsonb, 'liability_current', false, '210', 600),
  ('GT', 'default', '2121', 'Sueldos por pagar', '{}'::jsonb, 'liability_current', false, '212', 610),
  ('GT', 'default', '2122', 'Bonificación incentivo por pagar', '{}'::jsonb, 'liability_current', false, '212', 620),
  ('GT', 'default', '2123', 'Aguinaldo por pagar', '{}'::jsonb, 'liability_current', false, '212', 630),
  ('GT', 'default', '2124', 'Bono 14 por pagar', '{}'::jsonb, 'liability_current', false, '212', 640),
  ('GT', 'default', '2125', 'Cuotas patronales y laborales IGSS por pagar', '{}'::jsonb, 'liability_current', false, '212', 650),
  ('GT', 'default', '2126', 'Indemnizaciones y prestaciones laborales por pagar', '{}'::jsonb, 'liability_current', false, '212', 660),
  ('GT', 'default', '213', 'Impuestos por pagar', '{}'::jsonb, 'liability_current', false, '210', 670),
  ('GT', 'default', '2131', 'IVA - Débito Fiscal', '{}'::jsonb, 'liability_current', false, '213', 680),
  ('GT', 'default', '2132', 'IVA por Pagar', '{}'::jsonb, 'liability_current', true, '213', 690),
  ('GT', 'default', '2133', 'Impuesto Sobre la Renta por pagar', '{}'::jsonb, 'liability_current', false, '213', 700),
  ('GT', 'default', '2134', 'Impuesto de Solidaridad (ISO) por pagar', '{}'::jsonb, 'liability_current', false, '213', 710),
  ('GT', 'default', '2135', 'Retenciones de IVA por enterar', '{}'::jsonb, 'liability_current', false, '213', 720),
  ('GT', 'default', '2136', 'Retenciones de Impuesto Sobre la Renta por enterar', '{}'::jsonb, 'liability_current', false, '213', 730),
  ('GT', 'default', '2137', 'Impuesto Único Sobre Inmuebles (IUSI) por pagar', '{}'::jsonb, 'liability_current', false, '213', 740),
  ('GT', 'default', '214', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '210', 750),
  ('GT', 'default', '215', 'Provisiones a corto plazo', '{}'::jsonb, 'liability_current', false, '210', 760),
  ('GT', 'default', '220', 'Pasivo no corriente', '{}'::jsonb, 'liability_non_current', false, '200', 770),
  ('GT', 'default', '221', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 780),
  ('GT', 'default', '222', 'Arrendamientos financieros por pagar', '{}'::jsonb, 'liability_non_current', false, '220', 790),
  ('GT', 'default', '223', 'Provisión para indemnizaciones laborales', '{}'::jsonb, 'liability_non_current', false, '220', 800),
  ('GT', 'default', '224', 'Otras cuentas por pagar a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 810),
  ('GT', 'default', '300', 'Patrimonio neto', '{}'::jsonb, 'equity', false, null, 820),
  ('GT', 'default', '310', 'Capital autorizado', '{}'::jsonb, 'equity', false, '300', 830),
  ('GT', 'default', '311', 'Capital suscrito y pagado', '{}'::jsonb, 'equity', false, '300', 840),
  ('GT', 'default', '320', 'Aportaciones por capitalizar', '{}'::jsonb, 'equity', false, '300', 850),
  ('GT', 'default', '330', 'Reserva legal', '{}'::jsonb, 'equity', false, '300', 860),
  ('GT', 'default', '340', 'Resultados acumulados de ejercicios anteriores', '{}'::jsonb, 'equity_retained', false, '300', 870),
  ('GT', 'default', '341', 'Utilidades no distribuidas', '{}'::jsonb, 'equity_retained', false, '340', 880),
  ('GT', 'default', '342', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '340', 890),
  ('GT', 'default', '350', 'Resultado del ejercicio', '{}'::jsonb, 'equity', false, '300', 900),
  ('GT', 'default', '351', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 'equity', false, '350', 910),
  ('GT', 'default', '352', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 'equity', false, '350', 920),
  ('GT', 'default', '400', 'Ingresos', '{}'::jsonb, 'income', false, null, 930),
  ('GT', 'default', '410', 'Ventas', '{}'::jsonb, 'income', false, '400', 940),
  ('GT', 'default', '411', 'Ventas locales gravadas', '{}'::jsonb, 'income', false, '410', 950),
  ('GT', 'default', '412', 'Ventas de exportación', '{}'::jsonb, 'income', false, '410', 960),
  ('GT', 'default', '413', 'Ventas exentas', '{}'::jsonb, 'income', false, '410', 970),
  ('GT', 'default', '414', 'Prestación de servicios gravados', '{}'::jsonb, 'income', false, '410', 980),
  ('GT', 'default', '415', 'Descuentos y devoluciones sobre ventas', '{}'::jsonb, 'income', false, '410', 990),
  ('GT', 'default', '460', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '400', 1000),
  ('GT', 'default', '461', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '460', 1010),
  ('GT', 'default', '462', 'Diferencial cambiario ganado', '{}'::jsonb, 'income_other', false, '460', 1020),
  ('GT', 'default', '463', 'Descuentos obtenidos de proveedores', '{}'::jsonb, 'income_other', false, '460', 1030),
  ('GT', 'default', '464', 'Ganancia en venta de activos fijos', '{}'::jsonb, 'income_other', false, '460', 1040),
  ('GT', 'default', '465', 'Ingresos varios', '{}'::jsonb, 'income_other', false, '460', 1050),
  ('GT', 'default', '500', 'Costos y gastos', '{}'::jsonb, 'expense', false, null, 1060),
  ('GT', 'default', '510', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '500', 1070),
  ('GT', 'default', '511', 'Compras de mercadería', '{}'::jsonb, 'expense_direct_cost', false, '510', 1080),
  ('GT', 'default', '512', 'Compras que no generan crédito fiscal', '{}'::jsonb, 'expense_direct_cost', false, '510', 1090),
  ('GT', 'default', '513', 'Costo de servicios prestados', '{}'::jsonb, 'expense_direct_cost', false, '510', 1100),
  ('GT', 'default', '514', 'Fletes y seguros sobre compras', '{}'::jsonb, 'expense_direct_cost', false, '510', 1110),
  ('GT', 'default', '520', 'Gastos de venta', '{}'::jsonb, 'expense', false, '500', 1120),
  ('GT', 'default', '521', 'Sueldos y comisiones de ventas', '{}'::jsonb, 'expense', false, '520', 1130),
  ('GT', 'default', '522', 'Publicidad y mercadeo', '{}'::jsonb, 'expense', false, '520', 1140),
  ('GT', 'default', '523', 'Fletes y transporte sobre ventas', '{}'::jsonb, 'expense', false, '520', 1150),
  ('GT', 'default', '524', 'Gastos de viaje y representación', '{}'::jsonb, 'expense', false, '520', 1160),
  ('GT', 'default', '525', 'Otros gastos de venta', '{}'::jsonb, 'expense', false, '520', 1170),
  ('GT', 'default', '530', 'Gastos de administración', '{}'::jsonb, 'expense', false, '500', 1180),
  ('GT', 'default', '531', 'Sueldos administrativos', '{}'::jsonb, 'expense', false, '530', 1190),
  ('GT', 'default', '5310', 'Seguros', '{}'::jsonb, 'expense', false, '530', 1280),
  ('GT', 'default', '5311', 'Impuesto Único Sobre Inmuebles (IUSI)', '{}'::jsonb, 'expense', false, '530', 1290),
  ('GT', 'default', '5312', 'Arbitrios municipales', '{}'::jsonb, 'expense', false, '530', 1300),
  ('GT', 'default', '5313', 'Depreciación de propiedad planta y equipo', '{}'::jsonb, 'expense_depreciation', false, '530', 1310),
  ('GT', 'default', '5314', 'Amortización de activos intangibles', '{}'::jsonb, 'expense', false, '530', 1320),
  ('GT', 'default', '5315', 'Gastos varios de administración', '{}'::jsonb, 'expense', false, '530', 1330),
  ('GT', 'default', '532', 'Cuotas patronales IGSS', '{}'::jsonb, 'expense', false, '530', 1200),
  ('GT', 'default', '533', 'Aguinaldo y bono 14', '{}'::jsonb, 'expense', false, '530', 1210),
  ('GT', 'default', '534', 'Indemnizaciones laborales', '{}'::jsonb, 'expense', false, '530', 1220),
  ('GT', 'default', '535', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '530', 1230),
  ('GT', 'default', '536', 'Arrendamientos', '{}'::jsonb, 'expense', false, '530', 1240),
  ('GT', 'default', '537', 'Servicios básicos (agua, energía, teléfono)', '{}'::jsonb, 'expense', false, '530', 1250),
  ('GT', 'default', '538', 'Papelería y útiles de oficina', '{}'::jsonb, 'expense', false, '530', 1260),
  ('GT', 'default', '539', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '530', 1270),
  ('GT', 'default', '540', 'Gastos financieros', '{}'::jsonb, 'expense', false, '500', 1340),
  ('GT', 'default', '541', 'Intereses pagados', '{}'::jsonb, 'expense', false, '540', 1350),
  ('GT', 'default', '542', 'Diferencial cambiario perdido', '{}'::jsonb, 'expense', false, '540', 1360),
  ('GT', 'default', '543', 'Comisiones y gastos bancarios', '{}'::jsonb, 'expense', false, '540', 1370),
  ('GT', 'default', '544', 'Redondeo', '{}'::jsonb, 'expense', false, '540', 1380),
  ('GT', 'default', '550', 'Impuesto Sobre la Renta del ejercicio', '{}'::jsonb, 'expense', false, '500', 1390),
  ('GT', 'default', '551', 'Impuesto de Solidaridad (ISO) del ejercicio', '{}'::jsonb, 'expense', false, '500', 1400),
  ('GT', 'default', '560', 'Otros gastos', '{}'::jsonb, 'expense', false, '500', 1410)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('GT', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('GT', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('GT', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('GT', 'COM', 'Compras', '{}'::jsonb, 'purchase', 20),
  ('GT', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('GT', 'VEN', 'Ventas', '{}'::jsonb, 'sales', 10)
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
  ('GT', 'GT-C-12', 'Compra o servicio gravado, 12 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes o utilización de servicios gravados, destinados a actos gravados o a operaciones afectas por la ley', 'percent', 12, 'purchase', 'domestic', date '1992-07-01', null, 'Decreto Número 27-92, art. 15 — el crédito fiscal es la suma del impuesto cargado al contribuyente por las operaciones afectas realizadas durante el período; art. 16, primer párrafo, reformado por el art. 14 del Decreto Número 80-2000 — «procede el derecho al crédito fiscal, por la importación o adquisición de bienes y la utilización de servicios, que se apliquen a actos gravados o a operaciones afectas por esta ley», salvo activos fijos no vinculados directamente al proceso productivo; art. 18, reformado por el art. 8 del Decreto Número 4-2012 — documentación del crédito fiscal: factura, factura especial, nota de débito o crédito, o el recibo de pago en una importación, a nombre del contribuyente y con su Número de Identificación Tributaria, registrada en el libro de compras del artículo 37 y en la contabilidad', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null),
  ('GT', 'GT-C-12-NOCRED', 'Compra o servicio gravado, 12 %, sin derecho a crédito fiscal', '{}'::jsonb, 'Adquisición gravada destinada a operaciones no gravadas o exentas, o que no reúne los requisitos de documentación del crédito fiscal', 'percent', 12, 'purchase', 'domestic', date '1992-07-01', null, 'Decreto Número 27-92, art. 16, primer párrafo — el crédito fiscal procede por adquisiciones que se apliquen a actos gravados o a operaciones afectas por la ley; contrario sensu, la adquisición destinada a una operación exenta o no gravada, o que no reúne los requisitos de documentación del art. 18, no genera crédito fiscal y el impuesto pagado integra el costo del bien o servicio adquirido. Este paquete declara ese caso con una posición `tax_on_base`, sin casilla propia: el Formulario SAT-2237 no separa el impuesto no acreditable de la base de la compra', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null),
  ('GT', 'GT-C-EXO', 'Compra o servicio no gravado', '{}'::jsonb, 'Adquisición de bienes o servicios exentos, o a un proveedor que no carga el impuesto', 'percent', 0, 'purchase', 'exempt', date '1992-07-01', null, 'Decreto Número 27-92, art. 7 — exenciones generales; art. 9 — las personas y entidades del art. 8 no cargan el impuesto en sus ventas ni en la prestación de sus servicios', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null),
  ('GT', 'GT-C-IMP-12', 'Importación gravada, 12 %', '{}'::jsonb, 'Importación de bienes muebles, con derecho a crédito fiscal por el impuesto pagado en la aduana', 'percent', 12, 'purchase', 'import', date '1992-07-01', null, 'Decreto Número 27-92, art. 3, numeral 3 — las importaciones están gravadas; art. 4, numeral 2 — el impuesto se paga en la fecha en que se efectúe el pago de los derechos respectivos, conforme recibo legalmente extendido, y las aduanas no autorizan el retiro de los bienes sin que estén cancelados los impuestos correspondientes; art. 13, numeral 1 — la base imponible es el valor CIF de las mercancías importadas más los derechos arancelarios y demás recargos; art. 16, primer párrafo — procede el crédito fiscal por la importación de bienes que se apliquen a actos gravados', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null),
  ('GT', 'GT-V-12', 'Venta o servicio gravado, 12 %', '{}'::jsonb, 'Venta o permuta de bienes muebles, prestación de servicios, arrendamiento e importaciones gravadas por la tarifa única del Impuesto al Valor Agregado', 'percent', 12, 'sale', 'domestic', date '1992-07-01', null, 'Decreto Número 27-92, Ley del Impuesto al Valor Agregado, art. 1 — hecho generador; art. 3, numerales 1, 2, 4, 5, 8 y 9 — la venta o permuta de bienes muebles o inmuebles, la prestación de servicios, el arrendamiento y las adjudicaciones en pago están gravados; art. 10 — «los contribuyentes afectos a las disposiciones de esta ley pagarán el impuesto con una tarifa del doce por ciento (12%) sobre la base imponible. La tarifa del impuesto en todos los casos deberá estar incluida en el precio de venta de los bienes o el valor de los servicios». Guatemala no forma parte del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni ningún tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null),
  ('GT', 'GT-V-EXO', 'Venta o servicio exento', '{}'::jsonb, 'Venta de bienes o prestación de servicios comprendidos en las exenciones generales del artículo 7 del Decreto Número 27-92 (distintas de la exportación)', 'percent', 0, 'sale', 'exempt', date '1992-07-01', null, 'Decreto Número 27-92, art. 7 — enumera las exenciones generales: entre otras, la transferencia de bienes por fusión de sociedades, herencias, legados y donaciones por causa de muerte (numeral 3); los servicios de las instituciones fiscalizadas por la Superintendencia de Bancos y las bolsas de valores autorizadas (numeral 4); las operaciones de las cooperativas con sus asociados (numeral 5); los aportes y donaciones a asociaciones, fundaciones e instituciones educativas, culturales, de asistencia o de servicio social y religiosas no lucrativas (numeral 9); la venta al menudeo de carnes, pescado, mariscos, frutas, verduras, cereales, legumbres y granos básicos en mercados cantonales y municipales hasta cien quetzales (Q.100.00) por transacción (numeral 11); la venta de vivienda popular y de lotes urbanizados dentro de los límites de valor y superficie del numeral 12; y los servicios que prestan las asociaciones, fundaciones e instituciones educativas, de asistencia o de servicio social y religiosas no lucrativas (numeral 13). Este paquete declara un único código para el conjunto de estas exenciones; el numeral exacto de cada operación se cita en el asiento, no en el código — véase el README', null, null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null),
  ('GT', 'GT-V-EXP', 'Exportación de bienes y servicios', '{}'::jsonb, 'Exportación de bienes muebles nacionales o nacionalizados, y exportación de servicios prestados en el país a usuarios sin domicilio ni residencia, destinados exclusivamente a ser utilizados en el exterior', 'percent', 0, 'sale', 'export', date '1992-07-01', null, 'Decreto Número 27-92, art. 2, numeral 4 — define «exportación de bienes» como la venta, cumplidos todos los trámites legales, de bienes muebles nacionales o nacionalizados para su uso o consumo en el exterior, y «exportación de servicios» como la prestación de servicios en el país a usuarios que no tienen domicilio ni residencia en el mismo, destinados exclusivamente a ser utilizados en el exterior, siempre que las divisas hayan sido negociadas conforme a la legislación cambiaria vigente; art. 7, numeral 2 — «están exentas del impuesto establecido en esta ley: … las exportaciones de bienes y las exportaciones de servicios, conforme la definición del artículo 2 numeral 4 de esta ley»; art. 16, segundo párrafo, y art. 23 — el exportador tiene derecho a la devolución del crédito fiscal vinculado a la actividad exportadora, en efectivo, por período mensual vencido. Este paquete declara la exportación ordinaria de bienes y servicios; no distingue los servicios de exportación asimilados que enumera el Apéndice V ni el Régimen especial de devolución del artículo 25 (75 % o 60 % del crédito fiscal según el monto), que es un mecanismo administrativo de reintegro y no una tarifa ni una exención — véase el README', null, null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ley-iva', null, null, null, null)
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
    ('GT-C-12', 'invoice', 'base', 100, null, 'CG', array['CG']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-C-12', 'invoice', 'tax', 100, '1141', 'CF', array['CF']::text[], 100, 'GT-SAT-2237', 20),
    ('GT-C-12', 'credit_note', 'base', 100, null, 'CG', array['CG']::text[], -100, 'GT-SAT-2237', 10),
    ('GT-C-12', 'credit_note', 'tax', 100, '1141', 'CF', array['CF']::text[], -100, 'GT-SAT-2237', 20),
    ('GT-C-12-NOCRED', 'invoice', 'base', 100, null, 'CNOCRED', array['CNOCRED']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-C-12-NOCRED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('GT-C-12-NOCRED', 'credit_note', 'base', 100, null, 'CNOCRED', array['CNOCRED']::text[], -100, 'GT-SAT-2237', 10),
    ('GT-C-12-NOCRED', 'credit_note', 'tax_on_base', 100, null, null, null, -100, null, 20),
    ('GT-C-EXO', 'invoice', 'base', 100, null, 'CEXO', array['CEXO']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-C-EXO', 'credit_note', 'base', 100, null, 'CEXO', array['CEXO']::text[], -100, 'GT-SAT-2237', 10),
    ('GT-C-IMP-12', 'invoice', 'base', 100, null, 'IMP', array['IMP']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-C-IMP-12', 'invoice', 'tax', 100, '1141', 'CFIMP', array['CFIMP']::text[], 100, 'GT-SAT-2237', 20),
    ('GT-C-IMP-12', 'credit_note', 'base', 100, null, 'IMP', array['IMP']::text[], -100, 'GT-SAT-2237', 10),
    ('GT-C-IMP-12', 'credit_note', 'tax', 100, '1141', 'CFIMP', array['CFIMP']::text[], -100, 'GT-SAT-2237', 20),
    ('GT-V-12', 'invoice', 'base', 100, null, 'VG', array['VG']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-V-12', 'invoice', 'tax', 100, '2131', 'DF', array['DF']::text[], 100, 'GT-SAT-2237', 20),
    ('GT-V-12', 'credit_note', 'base', 100, null, 'VG', array['VG']::text[], -100, 'GT-SAT-2237', 10),
    ('GT-V-12', 'credit_note', 'tax', 100, '2131', 'DF', array['DF']::text[], -100, 'GT-SAT-2237', 20),
    ('GT-V-EXO', 'invoice', 'base', 100, null, 'VEXO', array['VEXO']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-V-EXO', 'credit_note', 'base', 100, null, 'VEXO', array['VEXO']::text[], -100, 'GT-SAT-2237', 10),
    ('GT-V-EXP', 'invoice', 'base', 100, null, 'VEXP', array['VEXP']::text[], 100, 'GT-SAT-2237', 10),
    ('GT-V-EXP', 'credit_note', 'base', 100, null, 'VEXP', array['VEXP']::text[], -100, 'GT-SAT-2237', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'GT' and t.code = v.tax_code
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
  ('GT', 'GT-SAT-2237', 'Formulario SAT-2237 — Declaración Jurada y Pago Mensual del Impuesto al Valor Agregado, Régimen General', array['month']::declaration_period[], 'month'::declaration_period, date '1992-07-01', null, 'Decreto Número 27-92, art. 19 — la suma neta que el contribuyente debe enterar al fisco en cada período impositivo es la diferencia entre el total de débitos y el total de créditos fiscales generados; art. 40 — los contribuyentes deben presentar, dentro del mes calendario siguiente al del vencimiento de cada período impositivo, una declaración del monto total de las operaciones realizadas en el mes calendario anterior, incluso las exentas, y pagar el impuesto resultante junto con la declaración. El Formulario SAT-2237 sustituyó a los formularios impresos y se presenta a través de la Agencia Virtual SAT o de Declaraguate; sus campos son secciones nombradas del formulario electrónico y no casillas numeradas de un formulario impreso, así que este paquete les da un acrónimo propio con el nombre exacto del campo — véase el README', true,'last_day_of_month_after_period'::filing_deadline_rule, null, null, 'Decreto Número 27-92, art. 40 — la declaración y el pago del impuesto deben presentarse «dentro del mes calendario siguiente al del vencimiento de cada período impositivo»: la ley no fija un día del mes siguiente, sino que abre todo el mes calendario siguiente, sin escalonamiento por dígito del Número de Identificación Tributaria', 'ley-iva', null)
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
  ('GT', 'GT-SAT-2237', 'VG', 'base', 'Ventas gravadas (Débito Fiscal) — base imponible', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario SAT-2237, sección de Débito Fiscal — monto de las ventas y prestaciones de servicios gravadas con el 12 %, sin incluir el impuesto', 'sat-2237-guia'),
  ('GT', 'GT-SAT-2237', 'DF', 'tax', 'Ventas gravadas — Impuesto al Valor Agregado (Débito Fiscal)', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Decreto Número 27-92, art. 14 — el débito fiscal es la suma del impuesto cargado por el contribuyente en las operaciones afectas realizadas en el período impositivo', 'ley-iva'),
  ('GT', 'GT-SAT-2237', 'VEXP', 'base', 'Exportaciones', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario SAT-2237, sección de Débito Fiscal — monto de las exportaciones de bienes y de servicios facturadas en el período', 'sat-2237-guia'),
  ('GT', 'GT-SAT-2237', 'VEXO', 'base', 'Ventas y servicios exentos', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Decreto Número 27-92, art. 40, segundo párrafo — la declaración informa el monto total de las operaciones realizadas en el mes, incluso las exentas del impuesto', 'ley-iva'),
  ('GT', 'GT-SAT-2237', 'CG', 'base', 'Compras gravadas con derecho a crédito fiscal — base imponible', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario SAT-2237, sección de Crédito Fiscal — monto de las adquisiciones internas gravadas con derecho a crédito fiscal, sin incluir el impuesto', 'sat-2237-guia'),
  ('GT', 'GT-SAT-2237', 'CF', 'tax', 'Compras gravadas — Crédito Fiscal', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Decreto Número 27-92, art. 15 — el crédito fiscal es la suma del impuesto cargado al contribuyente por las operaciones afectas realizadas durante el mismo período', 'ley-iva'),
  ('GT', 'GT-SAT-2237', 'CNOCRED', 'base', 'Compras que no generan derecho a crédito fiscal', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario SAT-2237, sección de Crédito Fiscal — monto de las adquisiciones gravadas que, conforme al artículo 16 de la ley, no otorgan derecho a crédito fiscal', 'sat-2237-guia'),
  ('GT', 'GT-SAT-2237', 'CEXO', 'base', 'Compras y servicios exentos', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario SAT-2237, sección de Crédito Fiscal — monto de las adquisiciones no gravadas o exentas del período', 'sat-2237-guia'),
  ('GT', 'GT-SAT-2237', 'IMP', 'base', 'Importaciones — base imponible', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario SAT-2237, sección de Crédito Fiscal — monto de las importaciones gravadas del período, según el recibo de pago de derechos de importación', 'sat-2237-guia'),
  ('GT', 'GT-SAT-2237', 'CFIMP', 'tax', 'Importaciones — Crédito Fiscal', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Decreto Número 27-92, art. 16, primer párrafo — procede el crédito fiscal por la importación de bienes que se apliquen a actos gravados o a operaciones afectas por la ley', 'ley-iva'),
  ('GT', 'GT-SAT-2237', 'TOTAL', 'total', 'Impuesto a pagar o remanente de crédito fiscal', '{}'::jsonb, 110, null, array['DF']::text[], array['CF', 'CFIMP']::text[], null, null, false, false, null, 'Decreto Número 27-92, art. 19 — «la suma neta que el contribuyente debe enterar al fisco en cada período impositivo, es la diferencia entre el total de débitos y el total de créditos fiscales generados»; art. 21 y 22 — si el resultado es un remanente de crédito a favor del contribuyente, se acumula al período impositivo siguiente hasta agotarlo mediante compensación de débitos fiscales, salvo el caso de devolución a exportadores del artículo 23. Este paquete no aplica un piso en cero: un resultado negativo es el remanente de crédito fiscal que la ley traslada al período siguiente, y no declara las casillas de arrastre del remanente del período anterior, de percepciones ni de retenciones del IVA — véase el README', 'ley-iva')
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
  ('GT-EF-ER', 'GT', 'default', 'Estado de Resultados', 'income_statement', 'GT-NIIFPYMES', date '1970-01-01', null, 'Decreto Número 2-70, Código de Comercio de Guatemala, art. 368 — el comerciante debe establecer, por lo menos una vez al año, la situación financiera de su empresa mediante el balance general y el estado de pérdidas y ganancias, firmados por el comerciante y el contador. La Resolución del 29 de junio de 2010 del Colegio de Contadores Públicos y Auditores de Guatemala adopta la NIIF para PYMES, cuya sección 5 admite presentar los gastos por naturaleza, que es la forma en que este paquete agrupa su plan de cuentas de gastos', 'codigo-comercio'),
  ('GT-EF-ESF', 'GT', 'default', 'Estado de Situación Financiera', 'balance_sheet', 'GT-NIIFPYMES', date '1970-01-01', null, 'Decreto Número 2-70, Código de Comercio de Guatemala, art. 368 — todo comerciante debe llevar su contabilidad de forma organizada, de acuerdo con el sistema de partida doble y los principios de contabilidad generalmente aceptados o aceptados por la ley de la materia, así como establecer, al iniciar sus operaciones y por lo menos una vez al año, la situación financiera de su empresa mediante el balance general firmado por el comerciante y el contador. La Resolución del 29 de junio de 2010 de la Asamblea General Extraordinaria del Colegio de Contadores Públicos y Auditores de Guatemala, publicada en el Diario de Centro América el 13 de julio de 2010, adopta la Norma Internacional de Información Financiera para Pequeñas y Medianas Entidades (NIIF para PYMES) como parte de los principios de contabilidad generalmente aceptados a que remite el Código de Comercio, de aplicación obligatoria desde el 1 de enero de 2011. Este paquete presenta el activo y el pasivo en corriente/no corriente, que es como la NIIF para PYMES (sección 4) ordena el estado de situación financiera cuando la entidad no presenta por liquidez', 'codigo-comercio')
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
  ('GT-EF-ER', 'ING', null, 'Ingresos de operación', '{}'::jsonb, 10, 1, true, array['411', '412', '413', '414', '415']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ER', '411', 'ING', 'Ventas locales gravadas', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', '412', 'ING', 'Ventas de exportación', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', '413', 'ING', 'Ventas exentas', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', '414', 'ING', 'Prestación de servicios gravados', '{}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', '415', 'ING', 'Descuentos y devoluciones sobre ventas', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, cuenta de naturaleza deudora que reduce el ingreso de operación', 'codigo-comercio'),
  ('GT-EF-ER', '51', null, 'Costo de ventas', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', 'UB', null, 'Utilidad (pérdida) bruta', '{}'::jsonb, 80, 1, true, array['ING']::text[], array['51']::text[], null, null, null),
  ('GT-EF-ER', '52', null, 'Gastos de venta', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', '53', null, 'Gastos de administración', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', 'GO', null, 'Gastos operativos', '{}'::jsonb, 110, 1, true, array['52', '53']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ER', 'UO', null, 'Utilidad (pérdida) de operación', '{}'::jsonb, 120, 1, true, array['UB']::text[], array['GO']::text[], null, null, null),
  ('GT-EF-ER', '46', null, 'Otros ingresos', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete: intereses ganados, diferencial cambiario ganado, descuentos obtenidos, ganancia en venta de activos fijos e ingresos varios', 'codigo-comercio'),
  ('GT-EF-ER', '54', null, 'Gastos financieros', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', '56', null, 'Otros gastos', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', 'RF', null, 'Resultado financiero y otros', '{}'::jsonb, 160, 1, true, array['46']::text[], array['54', '56']::text[], null, null, null),
  ('GT-EF-ER', 'UAI', null, 'Utilidad (pérdida) antes de impuesto sobre la renta', '{}'::jsonb, 170, 1, true, array['UO', 'RF']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ER', '55', null, 'Impuesto sobre la renta e Impuesto de Solidaridad', '{}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ER', 'UN', null, 'Utilidad (pérdida) neta del ejercicio', '{}'::jsonb, 190, 1, true, array['UAI']::text[], array['55']::text[], null, null, null),
  ('GT-EF-ESF', 'ACT', null, 'Activo', '{}'::jsonb, 10, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', 'AC', 'ACT', 'Activo corriente', '{}'::jsonb, 20, 1, true, array['111', '112', '113', '114', '115', '116', '119']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', '111', 'AC', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para PYMES adoptada por el Colegio de Contadores Públicos y Auditores de Guatemala; el Código de Comercio no prescribe un catálogo de cuentas — véase el README', 'codigo-comercio'),
  ('GT-EF-ESF', '112', 'AC', 'Cuentas por cobrar comerciales', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '113', 'AC', 'Otras cuentas por cobrar', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '114', 'AC', 'Impuestos por cobrar', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete; incluye el Crédito Fiscal del Impuesto al Valor Agregado (cuentas 1141 y 1142)', 'codigo-comercio'),
  ('GT-EF-ESF', '115', 'AC', 'Gastos pagados por anticipado', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '116', 'AC', 'Inventarios', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '119', 'AC', 'Partidas pendientes de imputación', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de suspenso del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', 'ANC', 'ACT', 'Activo no corriente', '{}'::jsonb, 100, 1, true, array['121', '122', '123']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', '121', 'ANC', 'Propiedad, planta y equipo', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, netas de su depreciación acumulada', 'codigo-comercio'),
  ('GT-EF-ESF', '122', 'ANC', 'Activos intangibles', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '123', 'ANC', 'Otros activos no corrientes', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', 'PYP', null, 'Pasivo y patrimonio neto', '{}'::jsonb, 140, 1, true, array['PAS', 'PAT']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', 'PAS', 'PYP', 'Pasivo', '{}'::jsonb, 150, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', 'PC', 'PAS', 'Pasivo corriente', '{}'::jsonb, 160, 1, true, array['211', '212', '213', '214', '215']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', '211', 'PC', 'Cuentas por pagar comerciales', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '212', 'PC', 'Remuneraciones y prestaciones laborales por pagar', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '213', 'PC', 'Impuestos por pagar', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete; incluye el Débito Fiscal y el IVA por Pagar del período (cuentas 2131 y 2132)', 'codigo-comercio'),
  ('GT-EF-ESF', '214', 'PC', 'Anticipos de clientes', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '215', 'PC', 'Provisiones a corto plazo', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', 'PNC', 'PAS', 'Pasivo no corriente', '{}'::jsonb, 220, 1, true, array['221', '222', '223', '224']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', '221', 'PNC', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '222', 'PNC', 'Arrendamientos financieros por pagar', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '223', 'PNC', 'Provisión para indemnizaciones laborales', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '224', 'PNC', 'Otras cuentas por pagar a largo plazo', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', 'PAT', 'PYP', 'Patrimonio neto', '{}'::jsonb, 270, 1, true, array['310', '311', '320', '330', '341', '342', '351', '352']::text[], '{}'::text[], null, null, null),
  ('GT-EF-ESF', '310', 'PAT', 'Capital autorizado', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '311', 'PAT', 'Capital suscrito y pagado', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '320', 'PAT', 'Aportaciones por capitalizar', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '330', 'PAT', 'Reserva legal', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '341', 'PAT', 'Utilidades no distribuidas', '{}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '342', 'PAT', 'Pérdidas acumuladas', '{}'::jsonb, 330, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '351', 'PAT', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 340, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio'),
  ('GT-EF-ESF', '352', 'PAT', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 350, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'codigo-comercio')
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
    ('GT-EF-ER', '411', 10, 'code_prefix', '411', null, null, 'any'),
    ('GT-EF-ER', '412', 10, 'code_prefix', '412', null, null, 'any'),
    ('GT-EF-ER', '413', 10, 'code_prefix', '413', null, null, 'any'),
    ('GT-EF-ER', '414', 10, 'code_prefix', '414', null, null, 'any'),
    ('GT-EF-ER', '415', 10, 'code_prefix', '415', null, null, 'any'),
    ('GT-EF-ER', '51', 10, 'code_prefix', '51', null, null, 'any'),
    ('GT-EF-ER', '52', 10, 'code_prefix', '52', null, null, 'any'),
    ('GT-EF-ER', '53', 10, 'code_prefix', '53', null, null, 'any'),
    ('GT-EF-ER', '46', 10, 'code_prefix', '46', null, null, 'any'),
    ('GT-EF-ER', '54', 10, 'code_prefix', '54', null, null, 'any'),
    ('GT-EF-ER', '56', 10, 'code_prefix', '56', null, null, 'any'),
    ('GT-EF-ER', '55', 10, 'code_prefix', '55', null, null, 'any'),
    ('GT-EF-ESF', '111', 10, 'code_prefix', '111', null, null, 'any'),
    ('GT-EF-ESF', '112', 10, 'code_prefix', '112', null, null, 'any'),
    ('GT-EF-ESF', '113', 10, 'code_prefix', '113', null, null, 'any'),
    ('GT-EF-ESF', '114', 10, 'code_prefix', '114', null, null, 'any'),
    ('GT-EF-ESF', '115', 10, 'code_prefix', '115', null, null, 'any'),
    ('GT-EF-ESF', '116', 10, 'code_prefix', '116', null, null, 'any'),
    ('GT-EF-ESF', '119', 10, 'code_prefix', '119', null, null, 'any'),
    ('GT-EF-ESF', '121', 10, 'code_prefix', '121', null, null, 'any'),
    ('GT-EF-ESF', '122', 10, 'code_prefix', '122', null, null, 'any'),
    ('GT-EF-ESF', '123', 10, 'code_prefix', '123', null, null, 'any'),
    ('GT-EF-ESF', '211', 10, 'code_prefix', '211', null, null, 'any'),
    ('GT-EF-ESF', '212', 10, 'code_prefix', '212', null, null, 'any'),
    ('GT-EF-ESF', '213', 10, 'code_prefix', '213', null, null, 'any'),
    ('GT-EF-ESF', '214', 10, 'code_prefix', '214', null, null, 'any'),
    ('GT-EF-ESF', '215', 10, 'code_prefix', '215', null, null, 'any'),
    ('GT-EF-ESF', '221', 10, 'code_prefix', '221', null, null, 'any'),
    ('GT-EF-ESF', '222', 10, 'code_prefix', '222', null, null, 'any'),
    ('GT-EF-ESF', '223', 10, 'code_prefix', '223', null, null, 'any'),
    ('GT-EF-ESF', '224', 10, 'code_prefix', '224', null, null, 'any'),
    ('GT-EF-ESF', '310', 10, 'code_prefix', '310', null, null, 'any'),
    ('GT-EF-ESF', '311', 10, 'code_prefix', '311', null, null, 'any'),
    ('GT-EF-ESF', '320', 10, 'code_prefix', '320', null, null, 'any'),
    ('GT-EF-ESF', '330', 10, 'code_prefix', '330', null, null, 'any'),
    ('GT-EF-ESF', '341', 10, 'code_prefix', '341', null, null, 'any'),
    ('GT-EF-ESF', '342', 10, 'code_prefix', '342', null, null, 'any'),
    ('GT-EF-ESF', '351', 10, 'code_prefix', '351', null, null, 'any'),
    ('GT-EF-ESF', '352', 10, 'code_prefix', '352', null, null, 'any')
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
  ('GT', 'Guatemala', '{}'::jsonb, array['es']::text[], 'GTQ', '1121', '2111', '119', '544', '341', '411', '511', '1113', '1111', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', default, default, '462', '542', null, null, null, null, '2132', '1142', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Decreto Número 27-92, art. 29, reformado por el art. 9 del Decreto Número 4-2012 — los contribuyentes están obligados a emitir, con caracteres legibles y permanentes o por medio electrónico, facturas, notas de débito y notas de crédito por sus ventas y servicios. Bajo el Régimen de Factura Electrónica en Línea (Acuerdo de Directorio 13-2018), cada documento recibe un número de autorización (UUID) que asigna el certificador autorizado, además del número y la serie que el propio emisor lleva. El número que declara este paquete es el de la pieza contable, correlativo por diario, y no el número de autorización ni la serie-número del Documento Tributario Electrónico — véase «Ekwo no emite un Documento Tributario Electrónico guatemalteco»',
  numbering_source_key          = 'ley-iva',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Decreto Número 27-92, art. 4, numeral 1 — en la venta o permuta de bienes muebles, el impuesto se paga en la fecha de la emisión de la factura, y si la entrega es anterior a la emisión, en la fecha de la entrega real del bien; en la prestación de servicios, en la fecha de la emisión de la factura o, si no se ha emitido, en la fecha en que el contribuyente perciba la remuneración. El art. 34 exige emitir la factura en el momento de la entrega real del bien o, en los servicios, en el momento de recibir la remuneración, de modo que la emisión coincide en la práctica con el hecho que la ley toma como principio o lo antecede — de ahí invoice_if_issued',
  tax_point_source_key          = 'ley-iva',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Decreto Número 27-92, art. 29, inciso c) — las notas de crédito son el documento para devoluciones, anulaciones o descuentos sobre operaciones ya facturadas. Bajo el Régimen de Factura Electrónica en Línea, un Documento Tributario Electrónico certificado sólo se anula dentro de un plazo breve tras su emisión o se corrige mediante una nota de crédito o de débito que lo referencia; no existe un procedimiento para devolver a borrador un documento ya certificado. Un documento contabilizado en Ekwo se anula con una nota de crédito que lo nombra, nunca volviendo a borrador',
  posted_edit_policy_source_key = 'fel-acuerdo-13-2018',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Toda factura, nota de débito y nota de crédito que respalda una venta, un servicio o una exportación en Guatemala es, desde marzo de 2023, un Documento Tributario Electrónico (DTE) del Régimen de Factura Electrónica en Línea (FEL): Acuerdo de Directorio Número 13-2018 y su modificatoria, el Acuerdo de Directorio Número 26-2019, ambos de la Superintendencia de Administración Tributaria. El emisor genera el DTE, lo transmite a un Certificador autorizado por la SAT — o a la propia SAT, que actúa como certificador de última instancia — que valida las reglas vigentes del régimen y lo firma electrónicamente antes de que el documento exista como comprobante válido: un régimen de validación previa (clearance), no un intercambio directo entre las partes. La incorporación fue gradual según el volumen de facturación de cada contribuyente y alcanzó al cien por ciento de los contribuyentes, incluidos los del Régimen de Pequeño Contribuyente, en marzo de 2023. Ekwo no genera, no certifica ni transmite el XML de un Documento Tributario Electrónico: ningún componente de packages/formats habla con un Certificador ni con la SAT, y un documento emitido desde Ekwo no es un comprobante de pago guatemalteco. Por eso profile y mandatory_from quedan vacíos aunque la obligación exista en los hechos: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe y transmite por Peppol, y el DTE guatemalteco no es ni lo uno ni lo otro; el formato tampoco tiene una palabra para «válido sólo tras la certificación de un tercero» — véase el README y docs/international.md. El Número de Identificación Tributaria (NIT) identifica al emisor y al receptor y no tiene un código ISO 6523 propio: party_scheme y vat_scheme quedan vacíos, como en los paquetes de México y el Perú',
  einvoice_source_key           = 'fel-acuerdo-13-2018',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'GT';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('GT', 'dte_not_issued', 'always', 'Este documento no es un Documento Tributario Electrónico (DTE): no ha sido certificado por un Certificador autorizado ni firmado por la Superintendencia de Administración Tributaria conforme al Régimen de Factura Electrónica en Línea (FEL). Solo el DTE certificado sustenta la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Acuerdo de Directorio Número 13-2018, que crea el Régimen FEL: el emisor genera el documento, lo transmite a un Certificador autorizado por la SAT, que valida las reglas del régimen y lo firma electrónicamente antes de que exista como comprobante válido — un modelo de validación previa (clearance) y no un intercambio directo entre las partes. Ekwo no genera, no certifica ni transmite Documentos Tributarios Electrónicos: ningún componente de packages/formats habla con un Certificador ni con la SAT — véase «Ekwo no emite un Documento Tributario Electrónico guatemalteco»'),
  ('GT', 'export', 'export', 'Exportación de bienes o de servicios, exenta del Impuesto al Valor Agregado (artículo 7, numeral 2, del Decreto Número 27-92).', '{}'::jsonb, 20, date '1970-01-01', null, 'Decreto Número 27-92, art. 7, numeral 2, y art. 2, numeral 4 — la exportación de bienes y de servicios, conforme se define en esta ley, está exenta del impuesto'),
  ('GT', 'exempt', 'exempt', 'Operación exenta del Impuesto al Valor Agregado (artículo 7 del Decreto Número 27-92).', '{}'::jsonb, 30, date '1970-01-01', null, 'Decreto Número 27-92, art. 7 — enumera las exenciones generales del impuesto')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
