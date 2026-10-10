-- Ekwo OS — Honduras: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/hn at version 0.1.1, do not edit.
-- Change the pack and run `ekwo pack build hn`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Decreto-Ley Número 24 del 20 de diciembre de 1963, Ley del Impuesto Sobre Ventas y sus reformas (texto actualizado hasta el 12 de enero de 2004; las tasas y la canasta básica vigentes se leen con el Decreto 278-2013) (Secretaría de Finanzas de Honduras — Dirección Ejecutiva de Ingresos)
--     https://www.sefin.gob.hn/wp-content/uploads/leyes/LEY%20DE%20IMPTO_S_VTAS.pdf
--   Decreto Número 278-2013, Ley de Ordenamiento de las Finanzas Públicas, Control de las Exoneraciones y Medidas Antievasión, La Gaceta No. 33,316 del 30 de diciembre de 2013, artículos 16 (tasas del Impuesto Sobre Ventas), 17 (canasta básica) y 18 (servicios exentos); en vigor desde el 1 de enero de 2014 (República de Honduras — Diario Oficial La Gaceta)
--     https://foprideh.org/wp-content/uploads/2020/10/DECRETO-278-2013.pdf
--   Ayuda Declaración Jurada de Impuesto Sobre Ventas (formulario 201, determinativa): secciones A a D, casillas de ventas, compras, importaciones y créditos, plazo de presentación y pago (Servicio de Administración de Rentas (SAR) — Oficina Virtual)
--     https://www.sar.gob.hn/wp-content/uploads/2024/06/AYUDA-DECLARACION-JURADA-IMPUESTO-SOBRE-VENTAS-OVI.pdf
--   Impuestos y Declaraciones — vencimientos del Impuesto Sobre Ventas (día diez de cada mes), de la Declaración Mensual de Compras (día ocho de cada mes) y de las retenciones del Impuesto Sobre Ventas (Servicio de Administración de Rentas (SAR))
--     https://www.sar.gob.hn/impuestos-y-declaraciones-20997/
--   Acuerdo No. SAR-236-2024, La Gaceta No. 36,538 del 20 de mayo de 2024, que crea la Oficina Virtual del Servicio de Administración de Rentas como plataforma para elaborar, rectificar y presentar declaraciones y generar boletines de pago (Servicio de Administración de Rentas (SAR))
--     https://www.sar.gob.hn/download/acuerdo-no-sar-236-2024-no-36538-de-fecha-20-de-mayo-2024-se-crea-la-oficina-virtual-del-servicio-de-administracion-de-rentas-sar-como-la-herramienta-que-facilita-a-los-obligados-tributarios-el/
--   Oficina Virtual del SAR — portal de presentación y pago de declaraciones tributarias (Servicio de Administración de Rentas (SAR))
--     https://oficinavirtual.sar.gob.hn/
--   Acuerdo No. 481-2017, La Gaceta No. 34,413 del 10 de agosto de 2017, Reglamento del Régimen de Facturación, Otros Documentos Fiscales y Registro Fiscal de Imprentas, reformado por los Acuerdos 609-2017, 725-2018 y 817-2018: obligación de emitir comprobante fiscal, impresión autorizada por imprenta o autoimpresor, Código de Autorización de Impresión (CAI) (Servicio de Administración de Rentas (SAR))
--     https://www.sar.gob.hn/facturacion/
--   Decreto Número 73-50, Código de Comercio de Honduras (Congreso Nacional de Honduras — texto consultado en WIPO Lex)
--     https://www.wipo.int/wipolex/es/legislation/details/2143
--   Modelo de Estados Financieros de acuerdo a la NIIF para las PYMES, adoptada por la JUNTEC para su aplicación obligatoria en Honduras (Junta Técnica de Normas de Contabilidad y de Auditoría (JUNTEC))
--     https://juntec.org.hn/2024/12/05/modelo-de-estados-financieros-de-acuerdo-a-las-niif-para-las-pymes/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('HN', 'Honduras', '0.1.1', date '2026-10-09', '20260929141500', 'community', null, null, 'e483ded0d6cd851a700b4241d64a84ba7ca7e6409ead6e335a845f96da080b99', '[{"key":"ley-isv","title":"Decreto-Ley Número 24 del 20 de diciembre de 1963, Ley del Impuesto Sobre Ventas y sus reformas (texto actualizado hasta el 12 de enero de 2004; las tasas y la canasta básica vigentes se leen con el Decreto 278-2013)","publisher":"Secretaría de Finanzas de Honduras — Dirección Ejecutiva de Ingresos","url":"https://www.sefin.gob.hn/wp-content/uploads/leyes/LEY%20DE%20IMPTO_S_VTAS.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"decreto-278-2013","title":"Decreto Número 278-2013, Ley de Ordenamiento de las Finanzas Públicas, Control de las Exoneraciones y Medidas Antievasión, La Gaceta No. 33,316 del 30 de diciembre de 2013, artículos 16 (tasas del Impuesto Sobre Ventas), 17 (canasta básica) y 18 (servicios exentos); en vigor desde el 1 de enero de 2014","publisher":"República de Honduras — Diario Oficial La Gaceta","url":"https://foprideh.org/wp-content/uploads/2020/10/DECRETO-278-2013.pdf","consulted_on":"2026-10-09","kind":"law"},{"key":"sar-isv-201","title":"Ayuda Declaración Jurada de Impuesto Sobre Ventas (formulario 201, determinativa): secciones A a D, casillas de ventas, compras, importaciones y créditos, plazo de presentación y pago","publisher":"Servicio de Administración de Rentas (SAR) — Oficina Virtual","url":"https://www.sar.gob.hn/wp-content/uploads/2024/06/AYUDA-DECLARACION-JURADA-IMPUESTO-SOBRE-VENTAS-OVI.pdf","consulted_on":"2026-10-09","kind":"guidance"},{"key":"sar-impuestos-declaraciones","title":"Impuestos y Declaraciones — vencimientos del Impuesto Sobre Ventas (día diez de cada mes), de la Declaración Mensual de Compras (día ocho de cada mes) y de las retenciones del Impuesto Sobre Ventas","publisher":"Servicio de Administración de Rentas (SAR)","url":"https://www.sar.gob.hn/impuestos-y-declaraciones-20997/","consulted_on":"2026-10-09","kind":"guidance"},{"key":"acuerdo-sar-236-2024","title":"Acuerdo No. SAR-236-2024, La Gaceta No. 36,538 del 20 de mayo de 2024, que crea la Oficina Virtual del Servicio de Administración de Rentas como plataforma para elaborar, rectificar y presentar declaraciones y generar boletines de pago","publisher":"Servicio de Administración de Rentas (SAR)","url":"https://www.sar.gob.hn/download/acuerdo-no-sar-236-2024-no-36538-de-fecha-20-de-mayo-2024-se-crea-la-oficina-virtual-del-servicio-de-administracion-de-rentas-sar-como-la-herramienta-que-facilita-a-los-obligados-tributarios-el/","consulted_on":"2026-10-09","kind":"regulation"},{"key":"oficina-virtual-sar","title":"Oficina Virtual del SAR — portal de presentación y pago de declaraciones tributarias","publisher":"Servicio de Administración de Rentas (SAR)","url":"https://oficinavirtual.sar.gob.hn/","consulted_on":"2026-10-09","kind":"portal"},{"key":"acuerdo-481-2017","title":"Acuerdo No. 481-2017, La Gaceta No. 34,413 del 10 de agosto de 2017, Reglamento del Régimen de Facturación, Otros Documentos Fiscales y Registro Fiscal de Imprentas, reformado por los Acuerdos 609-2017, 725-2018 y 817-2018: obligación de emitir comprobante fiscal, impresión autorizada por imprenta o autoimpresor, Código de Autorización de Impresión (CAI)","publisher":"Servicio de Administración de Rentas (SAR)","url":"https://www.sar.gob.hn/facturacion/","consulted_on":"2026-10-09","kind":"regulation"},{"key":"codigo-comercio","title":"Decreto Número 73-50, Código de Comercio de Honduras","publisher":"Congreso Nacional de Honduras — texto consultado en WIPO Lex","url":"https://www.wipo.int/wipolex/es/legislation/details/2143","consulted_on":"2026-10-09","kind":"law"},{"key":"juntec-niif-pymes","title":"Modelo de Estados Financieros de acuerdo a la NIIF para las PYMES, adoptada por la JUNTEC para su aplicación obligatoria en Honduras","publisher":"Junta Técnica de Normas de Contabilidad y de Auditoría (JUNTEC)","url":"https://juntec.org.hn/2024/12/05/modelo-de-estados-financieros-de-acuerdo-a-las-niif-para-las-pymes/","consulted_on":"2026-10-09","kind":"guidance"}]'::jsonb)
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
  ('HN', 'default', 'Plan de cuentas de referencia, inspirado en la NIIF para las PYMES', '{}'::jsonb, true, 'companies', array['HN-EF-ER', 'HN-EF-ESF']::text[], null, 'Honduras no impone un catálogo de cuentas único ni numerado. El Código de Comercio (Decreto Número 73-50) obliga al comerciante a llevar su contabilidad organizada por el sistema de partida doble, sin prescribir cuentas; la Junta Técnica de Normas de Contabilidad y de Auditoría (JUNTEC), creada por el Decreto Legislativo 189-2004, adoptó la NIIF para las PYMES para su aplicación obligatoria y publica un modelo oficial de estados financieros. Este plan es original: sigue una numeración propia y cada bloque de códigos corresponde a una línea de los esquemas HN-EF-ESF y HN-EF-ER, que siguen las secciones 4 y 5 de la NIIF para las PYMES. La numeración de los artículos del Código de Comercio sobre la contabilidad no se cita porque varias fuentes difieren sobre ella y parte de esas disposiciones pasó a la normativa de la JUNTEC — véase el README', 'juntec-niif-pymes')
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
  ('HN', 'default', '100', 'Activo', '{}'::jsonb, 'asset_current', false, null, 10),
  ('HN', 'default', '110', 'Activo corriente', '{}'::jsonb, 'asset_current', false, '100', 20),
  ('HN', 'default', '111', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 'asset_cash', false, '110', 30),
  ('HN', 'default', '1111', 'Caja general', '{}'::jsonb, 'asset_cash', false, '111', 40),
  ('HN', 'default', '1112', 'Caja chica', '{}'::jsonb, 'asset_cash', false, '111', 50),
  ('HN', 'default', '1113', 'Bancos - cuentas monetarias', '{}'::jsonb, 'asset_cash', false, '111', 60),
  ('HN', 'default', '1114', 'Bancos - cuentas de ahorro', '{}'::jsonb, 'asset_cash', false, '111', 70),
  ('HN', 'default', '1115', 'Inversiones temporales', '{}'::jsonb, 'asset_current', false, '111', 80),
  ('HN', 'default', '112', 'Cuentas por cobrar comerciales', '{}'::jsonb, 'asset_current', false, '110', 90),
  ('HN', 'default', '1121', 'Clientes locales', '{}'::jsonb, 'asset_receivable', true, '112', 100),
  ('HN', 'default', '1122', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '112', 110),
  ('HN', 'default', '1123', 'Documentos por cobrar', '{}'::jsonb, 'asset_receivable', true, '112', 120),
  ('HN', 'default', '113', 'Otras cuentas por cobrar', '{}'::jsonb, 'asset_current', false, '110', 130),
  ('HN', 'default', '1131', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '113', 140),
  ('HN', 'default', '1132', 'Préstamos y anticipos a empleados', '{}'::jsonb, 'asset_current', false, '113', 150),
  ('HN', 'default', '1133', 'Cuentas por cobrar a socios y accionistas', '{}'::jsonb, 'asset_current', false, '113', 160),
  ('HN', 'default', '1134', 'Deudores varios', '{}'::jsonb, 'asset_current', false, '113', 170),
  ('HN', 'default', '114', 'Impuestos por cobrar', '{}'::jsonb, 'asset_current', false, '110', 180),
  ('HN', 'default', '1141', 'ISV - Crédito fiscal', '{}'::jsonb, 'asset_current', false, '114', 190),
  ('HN', 'default', '1142', 'ISV - Saldo a favor por cobrar', '{}'::jsonb, 'asset_current', true, '114', 200),
  ('HN', 'default', '1143', 'Impuesto Sobre la Renta - Pagos a cuenta', '{}'::jsonb, 'asset_current', false, '114', 210),
  ('HN', 'default', '1144', 'ISR retenido por terceros', '{}'::jsonb, 'asset_current', false, '114', 220),
  ('HN', 'default', '115', 'Gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '110', 230),
  ('HN', 'default', '116', 'Inventarios', '{}'::jsonb, 'asset_current', false, '110', 240),
  ('HN', 'default', '1161', 'Mercaderías', '{}'::jsonb, 'asset_current', false, '116', 250),
  ('HN', 'default', '1162', 'Materias primas', '{}'::jsonb, 'asset_current', false, '116', 260),
  ('HN', 'default', '1163', 'Productos en proceso de producción', '{}'::jsonb, 'asset_current', false, '116', 270),
  ('HN', 'default', '1164', 'Productos terminados', '{}'::jsonb, 'asset_current', false, '116', 280),
  ('HN', 'default', '1165', 'Repuestos y materiales diversos', '{}'::jsonb, 'asset_current', false, '116', 290),
  ('HN', 'default', '119', 'Partidas pendientes de imputación', '{}'::jsonb, 'asset_current', false, '110', 300),
  ('HN', 'default', '120', 'Activo no corriente', '{}'::jsonb, 'asset_non_current', false, '100', 310),
  ('HN', 'default', '121', 'Propiedad, planta y equipo', '{}'::jsonb, 'asset_fixed', false, '120', 320),
  ('HN', 'default', '1211', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '121', 330),
  ('HN', 'default', '12110', 'Depreciación acumulada - Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '121', 420),
  ('HN', 'default', '12111', 'Depreciación acumulada - Vehículos', '{}'::jsonb, 'asset_fixed', false, '121', 430),
  ('HN', 'default', '12112', 'Depreciación acumulada - Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '121', 440),
  ('HN', 'default', '12113', 'Depreciación acumulada - Mejoras a propiedades arrendadas', '{}'::jsonb, 'asset_fixed', false, '121', 450),
  ('HN', 'default', '1212', 'Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '121', 340),
  ('HN', 'default', '1213', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '121', 350),
  ('HN', 'default', '1214', 'Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '121', 360),
  ('HN', 'default', '1215', 'Vehículos', '{}'::jsonb, 'asset_fixed', false, '121', 370),
  ('HN', 'default', '1216', 'Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '121', 380),
  ('HN', 'default', '1217', 'Mejoras a propiedades arrendadas', '{}'::jsonb, 'asset_fixed', false, '121', 390),
  ('HN', 'default', '1218', 'Depreciación acumulada - Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '121', 400),
  ('HN', 'default', '1219', 'Depreciación acumulada - Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '121', 410),
  ('HN', 'default', '122', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '120', 460),
  ('HN', 'default', '1221', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '122', 470),
  ('HN', 'default', '1222', 'Programas de cómputo (software)', '{}'::jsonb, 'asset_non_current', false, '122', 480),
  ('HN', 'default', '1223', 'Amortización acumulada de intangibles', '{}'::jsonb, 'asset_non_current', false, '122', 490),
  ('HN', 'default', '123', 'Otros activos no corrientes', '{}'::jsonb, 'asset_non_current', false, '120', 500),
  ('HN', 'default', '1231', 'Depósitos en garantía', '{}'::jsonb, 'asset_non_current', false, '123', 510),
  ('HN', 'default', '1232', 'Inversiones permanentes', '{}'::jsonb, 'asset_non_current', false, '123', 520),
  ('HN', 'default', '1233', 'Cuentas por cobrar a largo plazo', '{}'::jsonb, 'asset_non_current', false, '123', 530),
  ('HN', 'default', '200', 'Pasivo', '{}'::jsonb, 'liability_current', false, null, 540),
  ('HN', 'default', '210', 'Pasivo corriente', '{}'::jsonb, 'liability_current', false, '200', 550),
  ('HN', 'default', '211', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_current', false, '210', 560),
  ('HN', 'default', '2111', 'Proveedores locales', '{}'::jsonb, 'liability_payable', true, '211', 570),
  ('HN', 'default', '2112', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '211', 580),
  ('HN', 'default', '2113', 'Documentos por pagar', '{}'::jsonb, 'liability_payable', true, '211', 590),
  ('HN', 'default', '212', 'Remuneraciones y prestaciones laborales por pagar', '{}'::jsonb, 'liability_current', false, '210', 600),
  ('HN', 'default', '2121', 'Sueldos por pagar', '{}'::jsonb, 'liability_current', false, '212', 610),
  ('HN', 'default', '2122', 'Vacaciones por pagar', '{}'::jsonb, 'liability_current', false, '212', 620),
  ('HN', 'default', '2123', 'Décimo tercer mes (aguinaldo) por pagar', '{}'::jsonb, 'liability_current', false, '212', 630),
  ('HN', 'default', '2124', 'Décimo cuarto mes por pagar', '{}'::jsonb, 'liability_current', false, '212', 640),
  ('HN', 'default', '2125', 'Cuotas patronales y laborales IHSS, RAP e INFOP por pagar', '{}'::jsonb, 'liability_current', false, '212', 650),
  ('HN', 'default', '2126', 'Indemnizaciones y prestaciones laborales por pagar', '{}'::jsonb, 'liability_current', false, '212', 660),
  ('HN', 'default', '213', 'Impuestos por pagar', '{}'::jsonb, 'liability_current', false, '210', 670),
  ('HN', 'default', '2131', 'ISV - Débito fiscal', '{}'::jsonb, 'liability_current', false, '213', 680),
  ('HN', 'default', '2132', 'ISV por pagar', '{}'::jsonb, 'liability_current', true, '213', 690),
  ('HN', 'default', '2133', 'Impuesto Sobre la Renta por pagar', '{}'::jsonb, 'liability_current', false, '213', 700),
  ('HN', 'default', '2134', 'Aportación solidaria por pagar', '{}'::jsonb, 'liability_current', false, '213', 710),
  ('HN', 'default', '2135', 'Retenciones de ISV por enterar', '{}'::jsonb, 'liability_current', false, '213', 720),
  ('HN', 'default', '2136', 'Retenciones de Impuesto Sobre la Renta por enterar', '{}'::jsonb, 'liability_current', false, '213', 730),
  ('HN', 'default', '2137', 'Impuesto sobre bienes inmuebles por pagar', '{}'::jsonb, 'liability_current', false, '213', 740),
  ('HN', 'default', '214', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '210', 750),
  ('HN', 'default', '215', 'Provisiones a corto plazo', '{}'::jsonb, 'liability_current', false, '210', 760),
  ('HN', 'default', '220', 'Pasivo no corriente', '{}'::jsonb, 'liability_non_current', false, '200', 770),
  ('HN', 'default', '221', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 780),
  ('HN', 'default', '222', 'Arrendamientos financieros por pagar', '{}'::jsonb, 'liability_non_current', false, '220', 790),
  ('HN', 'default', '223', 'Provisión para indemnizaciones laborales', '{}'::jsonb, 'liability_non_current', false, '220', 800),
  ('HN', 'default', '224', 'Otras cuentas por pagar a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 810),
  ('HN', 'default', '300', 'Patrimonio neto', '{}'::jsonb, 'equity', false, null, 820),
  ('HN', 'default', '310', 'Capital autorizado', '{}'::jsonb, 'equity', false, '300', 830),
  ('HN', 'default', '311', 'Capital suscrito y pagado', '{}'::jsonb, 'equity', false, '300', 840),
  ('HN', 'default', '320', 'Aportaciones por capitalizar', '{}'::jsonb, 'equity', false, '300', 850),
  ('HN', 'default', '330', 'Reserva legal', '{}'::jsonb, 'equity', false, '300', 860),
  ('HN', 'default', '340', 'Resultados acumulados de ejercicios anteriores', '{}'::jsonb, 'equity_retained', false, '300', 870),
  ('HN', 'default', '341', 'Utilidades no distribuidas', '{}'::jsonb, 'equity_retained', false, '340', 880),
  ('HN', 'default', '342', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '340', 890),
  ('HN', 'default', '350', 'Resultado del ejercicio', '{}'::jsonb, 'equity', false, '300', 900),
  ('HN', 'default', '351', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 'equity', false, '350', 910),
  ('HN', 'default', '352', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 'equity', false, '350', 920),
  ('HN', 'default', '400', 'Ingresos', '{}'::jsonb, 'income', false, null, 930),
  ('HN', 'default', '410', 'Ventas', '{}'::jsonb, 'income', false, '400', 940),
  ('HN', 'default', '411', 'Ventas locales gravadas', '{}'::jsonb, 'income', false, '410', 950),
  ('HN', 'default', '412', 'Ventas de exportación', '{}'::jsonb, 'income', false, '410', 960),
  ('HN', 'default', '413', 'Ventas exentas', '{}'::jsonb, 'income', false, '410', 970),
  ('HN', 'default', '414', 'Prestación de servicios gravados', '{}'::jsonb, 'income', false, '410', 980),
  ('HN', 'default', '415', 'Descuentos y devoluciones sobre ventas', '{}'::jsonb, 'income', false, '410', 990),
  ('HN', 'default', '460', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '400', 1000),
  ('HN', 'default', '461', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '460', 1010),
  ('HN', 'default', '462', 'Diferencial cambiario ganado', '{}'::jsonb, 'income_other', false, '460', 1020),
  ('HN', 'default', '463', 'Descuentos obtenidos de proveedores', '{}'::jsonb, 'income_other', false, '460', 1030),
  ('HN', 'default', '464', 'Ganancia en venta de activos fijos', '{}'::jsonb, 'income_other', false, '460', 1040),
  ('HN', 'default', '465', 'Ingresos varios', '{}'::jsonb, 'income_other', false, '460', 1050),
  ('HN', 'default', '500', 'Costos y gastos', '{}'::jsonb, 'expense', false, null, 1060),
  ('HN', 'default', '510', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '500', 1070),
  ('HN', 'default', '511', 'Compras de mercadería', '{}'::jsonb, 'expense_direct_cost', false, '510', 1080),
  ('HN', 'default', '512', 'Compras sin derecho a crédito fiscal', '{}'::jsonb, 'expense_direct_cost', false, '510', 1090),
  ('HN', 'default', '513', 'Costo de servicios prestados', '{}'::jsonb, 'expense_direct_cost', false, '510', 1100),
  ('HN', 'default', '514', 'Fletes y seguros sobre compras', '{}'::jsonb, 'expense_direct_cost', false, '510', 1110),
  ('HN', 'default', '520', 'Gastos de venta', '{}'::jsonb, 'expense', false, '500', 1120),
  ('HN', 'default', '521', 'Sueldos y comisiones de ventas', '{}'::jsonb, 'expense', false, '520', 1130),
  ('HN', 'default', '522', 'Publicidad y mercadeo', '{}'::jsonb, 'expense', false, '520', 1140),
  ('HN', 'default', '523', 'Fletes y transporte sobre ventas', '{}'::jsonb, 'expense', false, '520', 1150),
  ('HN', 'default', '524', 'Gastos de viaje y representación', '{}'::jsonb, 'expense', false, '520', 1160),
  ('HN', 'default', '525', 'Otros gastos de venta', '{}'::jsonb, 'expense', false, '520', 1170),
  ('HN', 'default', '530', 'Gastos de administración', '{}'::jsonb, 'expense', false, '500', 1180),
  ('HN', 'default', '531', 'Sueldos administrativos', '{}'::jsonb, 'expense', false, '530', 1190),
  ('HN', 'default', '5310', 'Seguros', '{}'::jsonb, 'expense', false, '530', 1280),
  ('HN', 'default', '5311', 'Impuesto sobre bienes inmuebles', '{}'::jsonb, 'expense', false, '530', 1290),
  ('HN', 'default', '5312', 'Tasas e impuestos municipales', '{}'::jsonb, 'expense', false, '530', 1300),
  ('HN', 'default', '5313', 'Depreciación de propiedad planta y equipo', '{}'::jsonb, 'expense_depreciation', false, '530', 1310),
  ('HN', 'default', '5314', 'Amortización de activos intangibles', '{}'::jsonb, 'expense', false, '530', 1320),
  ('HN', 'default', '5315', 'Gastos varios de administración', '{}'::jsonb, 'expense', false, '530', 1330),
  ('HN', 'default', '532', 'Cuotas patronales IHSS, RAP e INFOP', '{}'::jsonb, 'expense', false, '530', 1200),
  ('HN', 'default', '533', 'Décimo tercer y décimo cuarto mes', '{}'::jsonb, 'expense', false, '530', 1210),
  ('HN', 'default', '534', 'Indemnizaciones laborales', '{}'::jsonb, 'expense', false, '530', 1220),
  ('HN', 'default', '535', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '530', 1230),
  ('HN', 'default', '536', 'Arrendamientos', '{}'::jsonb, 'expense', false, '530', 1240),
  ('HN', 'default', '537', 'Servicios básicos (agua, energía, teléfono)', '{}'::jsonb, 'expense', false, '530', 1250),
  ('HN', 'default', '538', 'Papelería y útiles de oficina', '{}'::jsonb, 'expense', false, '530', 1260),
  ('HN', 'default', '539', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '530', 1270),
  ('HN', 'default', '540', 'Gastos financieros', '{}'::jsonb, 'expense', false, '500', 1340),
  ('HN', 'default', '541', 'Intereses pagados', '{}'::jsonb, 'expense', false, '540', 1350),
  ('HN', 'default', '542', 'Diferencial cambiario perdido', '{}'::jsonb, 'expense', false, '540', 1360),
  ('HN', 'default', '543', 'Comisiones y gastos bancarios', '{}'::jsonb, 'expense', false, '540', 1370),
  ('HN', 'default', '544', 'Redondeo', '{}'::jsonb, 'expense', false, '540', 1380),
  ('HN', 'default', '550', 'Impuesto Sobre la Renta del ejercicio', '{}'::jsonb, 'expense', false, '500', 1390),
  ('HN', 'default', '551', 'Aportación solidaria del ejercicio', '{}'::jsonb, 'expense', false, '500', 1400),
  ('HN', 'default', '560', 'Otros gastos', '{}'::jsonb, 'expense', false, '500', 1410)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('HN', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('HN', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('HN', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('HN', 'COM', 'Compras', '{}'::jsonb, 'purchase', 20),
  ('HN', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('HN', 'VEN', 'Ventas', '{}'::jsonb, 'sales', 10)
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
  ('HN', 'HN-C-15', 'Compra o servicio gravado, 15 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición interna de bienes o servicios gravados a la tasa general, con derecho a crédito fiscal', 'percent', 15, 'purchase', 'domestic', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 12, apartado B — el crédito fiscal está constituido por el impuesto pagado con motivo de la importación y por las compras internas de bienes o servicios, menos el impuesto devuelto por compras anuladas o rescindidas y por reducciones de precio; art. 6 reformado por el art. 16 del Decreto 278-2013 — tasa del 15 %. El formulario 201 declara la base en «Compras netas en el mercado interno (gravadas al 15 %)» y el «Crédito por compras en el mercado interno» que el sistema calcula.', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-isv', null, null, null, null),
  ('HN', 'HN-C-18', 'Compra gravada, 18 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición interna de cerveza, bebidas alcohólicas, cigarrillos o boletos aéreos de clase ejecutiva, con derecho a crédito fiscal', 'percent', 18, 'purchase', 'domestic', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 12, apartado B — crédito fiscal por las compras internas; Decreto 278-2013, art. 16 — tasa del 18 % sobre bebidas alcohólicas, cerveza, cigarrillos y boletos aéreos de clase ejecutiva. El formulario 201 declara la base en «Compras netas en el mercado interno (gravadas al 18 %)» y el «Crédito por compras en el mercado interno (gravadas al 18 %)».', null, null, 120, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'decreto-278-2013', null, null, null, null),
  ('HN', 'HN-C-EXO', 'Compra o servicio exento o exonerado', '{}'::jsonb, 'Adquisición de bienes o servicios exentos o exonerados, que no generan crédito fiscal', 'percent', 0, 'purchase', 'exempt', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 15 — ventas de bienes y servicios exentas; formulario 201, sección B — «las compras exentas y exoneradas en el mercado interno no generan crédito fiscal». La compra de un bien gravado que no reúne los requisitos de documentación del crédito no tiene casilla propia en el formulario 201: se registra con este código y su impuesto se lleva al costo del bien.', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'sar-isv-201', null, null, null, null),
  ('HN', 'HN-C-IMP-15', 'Importación gravada, 15 %', '{}'::jsonb, 'Importación de bienes gravados a la tasa general, con crédito por el impuesto pagado en la aduana', 'percent', 15, 'purchase', 'import', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 3, letra b) — la base de las importaciones es el valor CIF incrementado con los derechos arancelarios, impuestos selectivos al consumo y demás cargos; art. 5-A, letra d) — el hecho generador se produce al nacionalizar el bien o liquidar y pagar la póliza; art. 8, letra c) — en las importaciones son responsables el importador o su agente aduanero; art. 12, apartado B — el impuesto pagado en la importación integra el crédito. El formulario 201 declara «Importaciones al 15 %» y su «Crédito Importaciones 15 %».', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-isv', null, null, null, null),
  ('HN', 'HN-C-IMP-18', 'Importación gravada, 18 %', '{}'::jsonb, 'Importación de bebidas alcohólicas, cerveza, cigarrillos u otros bienes a la tasa del dieciocho por ciento, con crédito por el impuesto pagado en la aduana', 'percent', 18, 'purchase', 'import', date '2014-01-01', null, 'Decreto 278-2013, art. 16 — tasa del 18 % sobre bebidas alcohólicas, cerveza y cigarrillos; Ley del Impuesto Sobre Ventas, art. 6 — el impuesto se capta en la importación al momento de la liquidación y pago; art. 12, apartado B — crédito por el impuesto pagado en la importación. El formulario 201 declara «Importaciones al 18 %» y su «Crédito Importaciones 18 %».', null, null, 150, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'decreto-278-2013', null, null, null, null),
  ('HN', 'HN-V-15', 'Venta o servicio gravado, 15 %', '{}'::jsonb, 'Venta de bienes y prestación de servicios gravados a la tasa general del Impuesto Sobre Ventas', 'percent', 15, 'sale', 'domestic', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 1 — se crea un impuesto sobre las ventas realizadas en todo el territorio, no acumulativo, en la importación y en cada etapa de venta de mercaderías o servicios; art. 2 — son ventas las transferencias onerosas de mercaderías y los servicios gravables; art. 3 — la base imponible es el valor del bien o servicio sin los gastos directos de financiación, seguros, fletes, comisiones y garantías; art. 6, reformado por el art. 16 del Decreto 278-2013 — la tasa general es del quince por ciento (15 %) desde el 1 de enero de 2014; art. 9 — el contribuyente puede recargar la tasa sobre el precio, con redondeo al centavo. El formulario 201 la declara en «Ventas en el mercado interno al 15 %» y calcula el débito fiscal. Honduras no forma parte del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni ningún tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`.', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'decreto-278-2013', null, null, null, null),
  ('HN', 'HN-V-18', 'Venta gravada, 18 % (cerveza, bebidas alcohólicas, cigarrillos y boletos aéreos de clase ejecutiva)', '{}'::jsonb, 'Venta o importación de bebidas alcohólicas, cerveza, cigarrillos y boletos aéreos de clase ejecutiva, a la tasa del dieciocho por ciento', 'percent', 18, 'sale', 'domestic', date '2014-01-01', null, 'Decreto 278-2013, art. 16 — reforma el art. 6 de la Ley del Impuesto Sobre Ventas para fijar en dieciocho por ciento (18 %) la tasa aplicada a las bebidas alcohólicas, la cerveza y los cigarrillos, al igual que los boletos aéreos de clase ejecutiva; Ley del Impuesto Sobre Ventas, art. 6 — para la cerveza, las aguas gaseosas y las bebidas refrescantes la base es el precio de venta en la etapa de distribuidor, y para los cigarrillos el precio en la etapa de mayorista, incluido el impuesto de producción y consumo. El texto de la reforma no nombra las aguas gaseosas ni las bebidas refrescantes entre los bienes al dieciocho por ciento: este paquete no las incluye en este código y las deja en la tasa general. El formulario 201 la declara en «Ventas en el mercado interno al 18 %». Honduras no forma parte del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni ningún tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`.', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'decreto-278-2013', null, null, null, null),
  ('HN', 'HN-V-EXO', 'Venta o servicio exento', '{}'::jsonb, 'Venta de bienes o prestación de servicios exentos conforme al artículo 15 de la Ley del Impuesto Sobre Ventas (canasta básica del Anexo I, medicamentos, servicios de enseñanza, salud, entre otros)', 'percent', 0, 'sale', 'exempt', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 15, reformado por los arts. 17 y 18 del Decreto 278-2013 — están exentos los bienes del Anexo I (canasta básica), los productos farmacéuticos para uso humano y el material de curación, quirúrgico y las jeringas, ciertos bienes como libros, periódicos y combustibles, y los servicios de energía eléctrica, agua potable y alcantarillado, construcción, honorarios profesionales de personas naturales, enseñanza, hospitalización, laboratorios y diagnóstico médico, transporte terrestre de pasajeros, servicios bancarios y financieros y primas de seguros de personas, quedando sujetos al impuesto los alimentos preparados para consumo dentro o fuera del local; además, la compraventa de inmuebles, el arrendamiento de locales comerciales con renta mensual hasta cinco mil lempiras y el arrendamiento de viviendas. Este paquete declara un único código para el conjunto; el inciso que ampara cada operación se cita en el asiento — véase el README. El formulario 201 informa estas operaciones en «Ventas exentas en el mercado interno» sin débito fiscal. Honduras no forma parte del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni ningún tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`.', null, null, 50, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ley-isv', null, null, null, null),
  ('HN', 'HN-V-EXP', 'Exportación fuera de la región centroamericana, tasa cero', '{}'::jsonb, 'Exportación de bienes o servicios a destinos fuera de Centroamérica, a tasa cero y con derecho a crédito', 'percent', 0, 'sale', 'export', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 6, último párrafo — el impuesto sobre los bienes y servicios que se exporten, incluidos los regímenes especiales y de fomento a las exportaciones, se calcula a tasa cero, quedando exentas las exportaciones y con derecho a crédito o devolución por el impuesto pagado en los insumos y servicios incorporados cuando el productor es el mismo exportador. El formulario 201 informa las «Exportaciones (fuera de la región centroamericana)» sin generar débito fiscal. La devolución del crédito al exportador es un trámite administrativo que este paquete no modela — véase el README. Honduras no forma parte del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni ningún tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`.', null, null, 30, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ley-isv', null, null, null, null),
  ('HN', 'HN-V-EXP-CA', 'Exportación a la región centroamericana, tasa cero', '{}'::jsonb, 'Exportación de bienes o servicios a otro país de la región centroamericana, a tasa cero', 'percent', 0, 'sale', 'export', date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 6, último párrafo — la exportación se calcula a tasa cero sin distinguir el destino; el formulario 201 separa, sin generar débito fiscal, las «Exportaciones región centroamericana» de las «Exportaciones (fuera de la región centroamericana)», y por eso este paquete declara dos códigos con el mismo tratamiento. Honduras no forma parte del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni ningún tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`.', null, null, 40, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'sar-isv-201', null, null, null, null)
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
    ('HN-C-15', 'invoice', 'base', 100, null, 'C15', array['C15']::text[], 100, 'HN-SAR-201', 10),
    ('HN-C-15', 'invoice', 'tax', 100, '1141', 'CR15', array['CR15']::text[], 100, 'HN-SAR-201', 20),
    ('HN-C-15', 'credit_note', 'base', 100, null, 'C15', array['C15']::text[], -100, 'HN-SAR-201', 10),
    ('HN-C-15', 'credit_note', 'tax', 100, '1141', 'CR15', array['CR15']::text[], -100, 'HN-SAR-201', 20),
    ('HN-C-18', 'invoice', 'base', 100, null, 'C18', array['C18']::text[], 100, 'HN-SAR-201', 10),
    ('HN-C-18', 'invoice', 'tax', 100, '1141', 'CR18', array['CR18']::text[], 100, 'HN-SAR-201', 20),
    ('HN-C-18', 'credit_note', 'base', 100, null, 'C18', array['C18']::text[], -100, 'HN-SAR-201', 10),
    ('HN-C-18', 'credit_note', 'tax', 100, '1141', 'CR18', array['CR18']::text[], -100, 'HN-SAR-201', 20),
    ('HN-C-EXO', 'invoice', 'base', 100, null, 'CEXO', array['CEXO']::text[], 100, 'HN-SAR-201', 10),
    ('HN-C-EXO', 'credit_note', 'base', 100, null, 'CEXO', array['CEXO']::text[], -100, 'HN-SAR-201', 10),
    ('HN-C-IMP-15', 'invoice', 'base', 100, null, 'IMP15', array['IMP15']::text[], 100, 'HN-SAR-201', 10),
    ('HN-C-IMP-15', 'invoice', 'tax', 100, '1141', 'CRIMP15', array['CRIMP15']::text[], 100, 'HN-SAR-201', 20),
    ('HN-C-IMP-15', 'credit_note', 'base', 100, null, 'IMP15', array['IMP15']::text[], -100, 'HN-SAR-201', 10),
    ('HN-C-IMP-15', 'credit_note', 'tax', 100, '1141', 'CRIMP15', array['CRIMP15']::text[], -100, 'HN-SAR-201', 20),
    ('HN-C-IMP-18', 'invoice', 'base', 100, null, 'IMP18', array['IMP18']::text[], 100, 'HN-SAR-201', 10),
    ('HN-C-IMP-18', 'invoice', 'tax', 100, '1141', 'CRIMP18', array['CRIMP18']::text[], 100, 'HN-SAR-201', 20),
    ('HN-C-IMP-18', 'credit_note', 'base', 100, null, 'IMP18', array['IMP18']::text[], -100, 'HN-SAR-201', 10),
    ('HN-C-IMP-18', 'credit_note', 'tax', 100, '1141', 'CRIMP18', array['CRIMP18']::text[], -100, 'HN-SAR-201', 20),
    ('HN-V-15', 'invoice', 'base', 100, null, 'V15', array['V15']::text[], 100, 'HN-SAR-201', 10),
    ('HN-V-15', 'invoice', 'tax', 100, '2131', 'D15', array['D15']::text[], 100, 'HN-SAR-201', 20),
    ('HN-V-15', 'credit_note', 'base', 100, null, 'V15', array['V15']::text[], -100, 'HN-SAR-201', 10),
    ('HN-V-15', 'credit_note', 'tax', 100, '2131', 'D15', array['D15']::text[], -100, 'HN-SAR-201', 20),
    ('HN-V-18', 'invoice', 'base', 100, null, 'V18', array['V18']::text[], 100, 'HN-SAR-201', 10),
    ('HN-V-18', 'invoice', 'tax', 100, '2131', 'D18', array['D18']::text[], 100, 'HN-SAR-201', 20),
    ('HN-V-18', 'credit_note', 'base', 100, null, 'V18', array['V18']::text[], -100, 'HN-SAR-201', 10),
    ('HN-V-18', 'credit_note', 'tax', 100, '2131', 'D18', array['D18']::text[], -100, 'HN-SAR-201', 20),
    ('HN-V-EXO', 'invoice', 'base', 100, null, 'VEXO', array['VEXO']::text[], 100, 'HN-SAR-201', 10),
    ('HN-V-EXO', 'credit_note', 'base', 100, null, 'VEXO', array['VEXO']::text[], -100, 'HN-SAR-201', 10),
    ('HN-V-EXP', 'invoice', 'base', 100, null, 'VEXP', array['VEXP']::text[], 100, 'HN-SAR-201', 10),
    ('HN-V-EXP', 'credit_note', 'base', 100, null, 'VEXP', array['VEXP']::text[], -100, 'HN-SAR-201', 10),
    ('HN-V-EXP-CA', 'invoice', 'base', 100, null, 'VEXPCA', array['VEXPCA']::text[], 100, 'HN-SAR-201', 10),
    ('HN-V-EXP-CA', 'credit_note', 'base', 100, null, 'VEXPCA', array['VEXPCA']::text[], -100, 'HN-SAR-201', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'HN' and t.code = v.tax_code
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
  ('HN', 'HN-SAR-201', 'Formulario 201 — Declaración Jurada del Impuesto Sobre Ventas (ISV), determinativa, mensual', array['month']::declaration_period[], 'month'::declaration_period, date '2014-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 11 — los responsables de la recaudación presentan mensualmente una declaración jurada de ventas y enteran las sumas percibidas dentro de los primeros diez (10) días calendario del mes siguiente, aun cuando la diferencia entre débito y crédito sea cero o a favor del responsable; art. 12 — la liquidación es la diferencia entre el débito y el crédito fiscal. La declaración 201 se presenta únicamente por la Oficina Virtual del SAR (Acuerdo SAR-236-2024) y consta de cuatro secciones: A, Determinación del Impuesto Ventas; B, Determinación del Impuesto Compras; C, Créditos; D, Detalle de la liquidación. Antes de ella los grandes y medianos contribuyentes presentan la Declaración Mensual de Compras (DMC), informativa y distinta, con vencimiento el día ocho: este paquete no la modela — véase el README', true,'day_of_month_after_period'::filing_deadline_rule, 10, null, 'Ley del Impuesto Sobre Ventas, art. 11 — el entero se hace dentro de los primeros diez (10) días calendario del mes siguiente a aquel en que se efectuaron las ventas; el SAR indica que, si el día diez no es hábil, el vencimiento pasa al siguiente día hábil, ajuste que esta regla no calcula', 'sar-impuestos-declaraciones', null)
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
  ('HN', 'HN-SAR-201', 'V15', 'base', 'Ventas en el mercado interno al 15 % — base imponible', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección A, Determinación del Impuesto Ventas — valor total de la base imponible de las ventas realizadas a la tasa del 15 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'D15', 'tax', 'Débito fiscal sobre ventas al 15 %', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley del Impuesto Sobre Ventas, art. 12, apartado A — el débito se determina aplicando la tarifa al valor de las ventas, menos el impuesto devuelto por ventas anuladas, rebajas y descuentos', 'ley-isv'),
  ('HN', 'HN-SAR-201', 'V18', 'base', 'Ventas en el mercado interno al 18 % — base imponible', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección A — valor total de la base imponible de las ventas realizadas a la tasa del 18 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'D18', 'tax', 'Débito fiscal sobre ventas al 18 %', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley del Impuesto Sobre Ventas, art. 12, apartado A, y Decreto 278-2013, art. 16', 'decreto-278-2013'),
  ('HN', 'HN-SAR-201', 'VEXO', 'base', 'Ventas exentas en el mercado interno', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección A — las ventas exentas no generan débito fiscal pero deben informarse', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'VEXP', 'base', 'Exportaciones (fuera de la región centroamericana)', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección A, subsección «Indica las Exportaciones» — no genera débito fiscal', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'VEXPCA', 'base', 'Exportaciones región centroamericana', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección A, subsección «Indica las Exportaciones» — no genera débito fiscal', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'TDEB', 'total', 'Total débito del período', '{}'::jsonb, 80, null, array['D15', 'D18']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección A, «Total Débito del Período» — suma de los débitos fiscales', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'C15', 'base', 'Compras netas en el mercado interno (gravadas al 15 %)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B, Determinación del Impuesto Compras — base imponible de las compras al 15 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'CR15', 'tax', 'Crédito por compras en el mercado interno (gravadas al 15 %)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — crédito que el sistema calcula al indicar las compras netas al 15 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'C18', 'base', 'Compras netas en el mercado interno (gravadas al 18 %)', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — base imponible de las compras al 18 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'CR18', 'tax', 'Crédito por compras en el mercado interno (gravadas al 18 %)', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — crédito que el sistema calcula al indicar las compras netas al 18 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'CEXO', 'base', 'Compras exentas o exoneradas en el mercado interno', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — las compras exentas y exoneradas no generan crédito fiscal', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'IMP15', 'base', 'Importaciones al 15 %', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B, subsección «Indica las Importaciones» — base imponible de las importaciones al 15 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'CRIMP15', 'tax', 'Crédito Importaciones 15 %', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — crédito que el sistema calcula al indicar las importaciones al 15 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'IMP18', 'base', 'Importaciones al 18 %', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — base imponible de las importaciones al 18 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'CRIMP18', 'tax', 'Crédito Importaciones 18 %', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — crédito que el sistema calcula al indicar las importaciones al 18 %', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'TCRED', 'total', 'Total de créditos declarados en las compras', '{}'::jsonb, 180, null, array['CR15', 'CR18', 'CRIMP15', 'CRIMP18']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 201, sección B — «Total de créditos declarados en las compras»; la sección C suma además los pagos del período, los excedentes del período anterior, las compensaciones, las cesiones y los impuestos retenidos, que Ekwo no calcula', 'sar-isv-201'),
  ('HN', 'HN-SAR-201', 'TOTAL', 'total', 'Impuesto a pagar o saldo a favor antes de la sección C', '{}'::jsonb, 190, null, array['D15', 'D18']::text[], array['CR15', 'CR18', 'CRIMP15', 'CRIMP18']::text[], null, null, false, false, null, 'Ley del Impuesto Sobre Ventas, art. 12 — la liquidación se hace sobre la diferencia entre el débito y el crédito fiscal; formulario 201, sección D, «Detalle de la liquidación» — total de débito del período frente al total de crédito originado por compras y créditos disponibles. Un resultado negativo es un excedente que el sistema traslada al período siguiente; este paquete no aplica excedentes anteriores, pagos, compensaciones ni retenciones de la sección C', 'ley-isv')
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
  ('HN-EF-ER', 'HN', 'default', 'Estado de Resultados', 'income_statement', 'HN-NIIFPYMES', date '1970-01-01', null, 'La Junta Técnica de Normas de Contabilidad y de Auditoría (JUNTEC) adoptó la NIIF para las PYMES para su aplicación obligatoria en Honduras y publica un modelo oficial de estados financieros; el Código de Comercio (Decreto Número 73-50) obliga al comerciante a llevar contabilidad por partida doble. La sección 5 de la NIIF para las PYMES admite presentar los gastos por naturaleza, que es la forma en que este paquete agrupa su plan de cuentas de gastos.', 'juntec-niif-pymes'),
  ('HN-EF-ESF', 'HN', 'default', 'Estado de Situación Financiera', 'balance_sheet', 'HN-NIIFPYMES', date '1970-01-01', null, 'La Junta Técnica de Normas de Contabilidad y de Auditoría (JUNTEC) adoptó la NIIF para las PYMES para su aplicación obligatoria en Honduras y publica un modelo oficial de estados financieros; el Código de Comercio (Decreto Número 73-50) obliga al comerciante a llevar contabilidad por partida doble. Este paquete presenta el activo y el pasivo en corriente y no corriente, que es como la sección 4 de la NIIF para las PYMES ordena el estado de situación financiera cuando la entidad no presenta por liquidez. La JUNTEC no impone un esquema de líneas único: las líneas siguen el modelo de la NIIF para las PYMES y las reglas son las de este plan de cuentas.', 'juntec-niif-pymes')
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
  ('HN-EF-ER', 'ING', null, 'Ingresos de operación', '{}'::jsonb, 10, 1, true, array['411', '412', '413', '414', '415']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ER', '411', 'ING', 'Ventas locales gravadas', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', '412', 'ING', 'Ventas de exportación', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', '413', 'ING', 'Ventas exentas', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', '414', 'ING', 'Prestación de servicios gravados', '{}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', '415', 'ING', 'Descuentos y devoluciones sobre ventas', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, cuenta de naturaleza deudora que reduce el ingreso de operación', 'juntec-niif-pymes'),
  ('HN-EF-ER', '51', null, 'Costo de ventas', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', 'UB', null, 'Utilidad (pérdida) bruta', '{}'::jsonb, 80, 1, true, array['ING']::text[], array['51']::text[], null, null, null),
  ('HN-EF-ER', '52', null, 'Gastos de venta', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', '53', null, 'Gastos de administración', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', 'GO', null, 'Gastos operativos', '{}'::jsonb, 110, 1, true, array['52', '53']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ER', 'UO', null, 'Utilidad (pérdida) de operación', '{}'::jsonb, 120, 1, true, array['UB']::text[], array['GO']::text[], null, null, null),
  ('HN-EF-ER', '46', null, 'Otros ingresos', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete: intereses ganados, diferencial cambiario ganado, descuentos obtenidos, ganancia en venta de activos fijos e ingresos varios', 'juntec-niif-pymes'),
  ('HN-EF-ER', '54', null, 'Gastos financieros', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', '56', null, 'Otros gastos', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', 'RF', null, 'Resultado financiero y otros', '{}'::jsonb, 160, 1, true, array['46']::text[], array['54', '56']::text[], null, null, null),
  ('HN-EF-ER', 'UAI', null, 'Utilidad (pérdida) antes de impuesto sobre la renta', '{}'::jsonb, 170, 1, true, array['UO', 'RF']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ER', '55', null, 'Impuesto sobre la renta e Impuesto de Solidaridad', '{}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ER', 'UN', null, 'Utilidad (pérdida) neta del ejercicio', '{}'::jsonb, 190, 1, true, array['UAI']::text[], array['55']::text[], null, null, null),
  ('HN-EF-ESF', 'ACT', null, 'Activo', '{}'::jsonb, 10, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', 'AC', 'ACT', 'Activo corriente', '{}'::jsonb, 20, 1, true, array['111', '112', '113', '114', '115', '116', '119']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', '111', 'AC', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por la JUNTEC; Honduras no prescribe un catálogo de cuentas — véase el README', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '112', 'AC', 'Cuentas por cobrar comerciales', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '113', 'AC', 'Otras cuentas por cobrar', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '114', 'AC', 'Impuestos por cobrar', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete; incluye el crédito fiscal del Impuesto Sobre Ventas (cuentas 1141 y 1142)', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '115', 'AC', 'Gastos pagados por anticipado', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '116', 'AC', 'Inventarios', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '119', 'AC', 'Partidas pendientes de imputación', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de suspenso del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', 'ANC', 'ACT', 'Activo no corriente', '{}'::jsonb, 100, 1, true, array['121', '122', '123']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', '121', 'ANC', 'Propiedad, planta y equipo', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, netas de su depreciación acumulada', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '122', 'ANC', 'Activos intangibles', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '123', 'ANC', 'Otros activos no corrientes', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', 'PYP', null, 'Pasivo y patrimonio neto', '{}'::jsonb, 140, 1, true, array['PAS', 'PAT']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', 'PAS', 'PYP', 'Pasivo', '{}'::jsonb, 150, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', 'PC', 'PAS', 'Pasivo corriente', '{}'::jsonb, 160, 1, true, array['211', '212', '213', '214', '215']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', '211', 'PC', 'Cuentas por pagar comerciales', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '212', 'PC', 'Remuneraciones y prestaciones laborales por pagar', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '213', 'PC', 'Impuestos por pagar', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete; incluye el débito fiscal y el ISV por pagar del período (cuentas 2131 y 2132)', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '214', 'PC', 'Anticipos de clientes', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '215', 'PC', 'Provisiones a corto plazo', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', 'PNC', 'PAS', 'Pasivo no corriente', '{}'::jsonb, 220, 1, true, array['221', '222', '223', '224']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', '221', 'PNC', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '222', 'PNC', 'Arrendamientos financieros por pagar', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '223', 'PNC', 'Provisión para indemnizaciones laborales', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '224', 'PNC', 'Otras cuentas por pagar a largo plazo', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', 'PAT', 'PYP', 'Patrimonio neto', '{}'::jsonb, 270, 1, true, array['310', '311', '320', '330', '341', '342', '351', '352']::text[], '{}'::text[], null, null, null),
  ('HN-EF-ESF', '310', 'PAT', 'Capital autorizado', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '311', 'PAT', 'Capital suscrito y pagado', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '320', 'PAT', 'Aportaciones por capitalizar', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '330', 'PAT', 'Reserva legal', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '341', 'PAT', 'Utilidades no distribuidas', '{}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '342', 'PAT', 'Pérdidas acumuladas', '{}'::jsonb, 330, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '351', 'PAT', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 340, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes'),
  ('HN-EF-ESF', '352', 'PAT', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 350, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete', 'juntec-niif-pymes')
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
    ('HN-EF-ER', '411', 10, 'code_prefix', '411', null, null, 'any'),
    ('HN-EF-ER', '412', 10, 'code_prefix', '412', null, null, 'any'),
    ('HN-EF-ER', '413', 10, 'code_prefix', '413', null, null, 'any'),
    ('HN-EF-ER', '414', 10, 'code_prefix', '414', null, null, 'any'),
    ('HN-EF-ER', '415', 10, 'code_prefix', '415', null, null, 'any'),
    ('HN-EF-ER', '51', 10, 'code_prefix', '51', null, null, 'any'),
    ('HN-EF-ER', '52', 10, 'code_prefix', '52', null, null, 'any'),
    ('HN-EF-ER', '53', 10, 'code_prefix', '53', null, null, 'any'),
    ('HN-EF-ER', '46', 10, 'code_prefix', '46', null, null, 'any'),
    ('HN-EF-ER', '54', 10, 'code_prefix', '54', null, null, 'any'),
    ('HN-EF-ER', '56', 10, 'code_prefix', '56', null, null, 'any'),
    ('HN-EF-ER', '55', 10, 'code_prefix', '55', null, null, 'any'),
    ('HN-EF-ESF', '111', 10, 'code_prefix', '111', null, null, 'any'),
    ('HN-EF-ESF', '112', 10, 'code_prefix', '112', null, null, 'any'),
    ('HN-EF-ESF', '113', 10, 'code_prefix', '113', null, null, 'any'),
    ('HN-EF-ESF', '114', 10, 'code_prefix', '114', null, null, 'any'),
    ('HN-EF-ESF', '115', 10, 'code_prefix', '115', null, null, 'any'),
    ('HN-EF-ESF', '116', 10, 'code_prefix', '116', null, null, 'any'),
    ('HN-EF-ESF', '119', 10, 'code_prefix', '119', null, null, 'any'),
    ('HN-EF-ESF', '121', 10, 'code_prefix', '121', null, null, 'any'),
    ('HN-EF-ESF', '122', 10, 'code_prefix', '122', null, null, 'any'),
    ('HN-EF-ESF', '123', 10, 'code_prefix', '123', null, null, 'any'),
    ('HN-EF-ESF', '211', 10, 'code_prefix', '211', null, null, 'any'),
    ('HN-EF-ESF', '212', 10, 'code_prefix', '212', null, null, 'any'),
    ('HN-EF-ESF', '213', 10, 'code_prefix', '213', null, null, 'any'),
    ('HN-EF-ESF', '214', 10, 'code_prefix', '214', null, null, 'any'),
    ('HN-EF-ESF', '215', 10, 'code_prefix', '215', null, null, 'any'),
    ('HN-EF-ESF', '221', 10, 'code_prefix', '221', null, null, 'any'),
    ('HN-EF-ESF', '222', 10, 'code_prefix', '222', null, null, 'any'),
    ('HN-EF-ESF', '223', 10, 'code_prefix', '223', null, null, 'any'),
    ('HN-EF-ESF', '224', 10, 'code_prefix', '224', null, null, 'any'),
    ('HN-EF-ESF', '310', 10, 'code_prefix', '310', null, null, 'any'),
    ('HN-EF-ESF', '311', 10, 'code_prefix', '311', null, null, 'any'),
    ('HN-EF-ESF', '320', 10, 'code_prefix', '320', null, null, 'any'),
    ('HN-EF-ESF', '330', 10, 'code_prefix', '330', null, null, 'any'),
    ('HN-EF-ESF', '341', 10, 'code_prefix', '341', null, null, 'any'),
    ('HN-EF-ESF', '342', 10, 'code_prefix', '342', null, null, 'any'),
    ('HN-EF-ESF', '351', 10, 'code_prefix', '351', null, null, 'any'),
    ('HN-EF-ESF', '352', 10, 'code_prefix', '352', null, null, 'any')
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
  ('HN', 'Honduras', '{}'::jsonb, array['es']::text[], 'HNL', '1121', '2111', '119', '544', '341', '411', '511', '1113', '1111', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', default, default, '462', '542', null, null, null, null, '2132', '1142', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Ley del Impuesto Sobre Ventas, art. 7 — los responsables entregan al adquirente el original de la factura o documento equivalente con los requisitos que señale el reglamento, y la Dirección Ejecutiva de Ingresos controla la impresión y emisión de esos documentos; el Acuerdo 481-2017 exige que toda factura lleve un Código de Autorización de Impresión (CAI) y un número correlativo dentro del rango autorizado por el SAR a una imprenta o a un autoimpresor. El número que declara este paquete es el de la pieza contable, correlativo por diario, y no el número fiscal del rango CAI — véase «Ekwo no es un autoimpresor registrado ante el SAR»',
  numbering_source_key          = 'acuerdo-481-2017',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ley del Impuesto Sobre Ventas, art. 5-A — el hecho generador se produce, en la venta de bienes, en la fecha de emisión de la factura o documento equivalente y, a falta de éste, en el momento de la entrega; en la prestación de servicios, en la fecha de emisión de la factura, en la de prestación del servicio o en la de pago o abono a cuenta, la que ocurra primero; en las importaciones, al momento de la nacionalización o de la liquidación y pago de la póliza. Para las ventas de bienes el punto de partida es la emisión de la factura, de ahí invoice_if_issued; la regla más temprana de los servicios no se distingue a este nivel — véase el README',
  tax_point_source_key          = 'ley-isv',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ley del Impuesto Sobre Ventas, art. 12 — el débito se determina aplicando la tarifa al valor de las ventas menos el impuesto devuelto por ventas anuladas o rescindidas y por rebajas, descuentos u otras deducciones normales del comercio, de modo que una venta ya facturada se corrige con un documento que la reduce y no volviendo a borrador; el Acuerdo 481-2017 exige un comprobante fiscal por cada transferencia. Un documento contabilizado en Ekwo se anula con una nota de crédito que lo nombra',
  posted_edit_policy_source_key = 'ley-isv',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'A 9 de octubre de 2026 ninguna ley ni acuerdo del Servicio de Administración de Rentas (SAR) obliga a los contribuyentes hondureños a emitir facturas electrónicas estructuradas ni a someterlas a una validación previa del SAR. El régimen vigente es el de facturación del Acuerdo 481-2017 (reformado por los Acuerdos 609-2017, 725-2018 y 817-2018): todo contribuyente que transfiera bienes o preste servicios emite un comprobante fiscal impreso por una imprenta autorizada o producido por un sistema de autoimpresor registrado ante el SAR, con un Código de Autorización de Impresión (CAI) asignado a cada rango. La factura generada por un autoimpresor puede ser digital, pero es una variante del mismo régimen de rangos CAI y no un intercambio de documentos estructurados entre las partes; el SAR no ha publicado un perfil ni una fecha de obligatoriedad. La página de facturación del SAR y sus comunicados de 2026 siguen hablando de impresión por imprenta y autoimpresor. profile y mandatory_from quedan vacíos; el Número de Registro Tributario Nacional (RTN) identifica al emisor y al receptor y no tiene un código ISO 6523 propio, de modo que party_scheme y vat_scheme quedan vacíos',
  einvoice_source_key           = 'acuerdo-481-2017',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'iban',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'HN';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('HN', 'cai_not_issued', 'always', 'Este documento no es una factura autorizada por el Servicio de Administración de Rentas (SAR): no lleva Código de Autorización de Impresión (CAI) ni rango autorizado. Solo la factura emitida por una imprenta autorizada o por un autoimpresor registrado sustenta la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Acuerdo 481-2017, Reglamento del Régimen de Facturación — los obligados emiten el comprobante fiscal impreso por una imprenta autorizada o generado por un sistema de autoimpresor registrado ante el SAR, y el SAR asigna a cada rango de facturas un Código de Autorización de Impresión (CAI) con su fecha límite de emisión. Ekwo no se inscribe ante el SAR como sistema autoimpresor ni solicita rangos CAI — véase «Ekwo no es un autoimpresor registrado ante el SAR»'),
  ('HN', 'export', 'export', 'Exportación de bienes o de servicios, exenta del Impuesto Sobre Ventas y sujeta a la tasa cero (artículo 6 de la Ley del Impuesto Sobre Ventas).', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 6, último párrafo — el impuesto sobre los bienes y servicios que se exporten, incluidos los regímenes especiales y de fomento a las exportaciones, se calcula a tasa cero, quedando exentas las exportaciones'),
  ('HN', 'exempt', 'exempt', 'Operación exenta del Impuesto Sobre Ventas (artículo 15 de la Ley del Impuesto Sobre Ventas).', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley del Impuesto Sobre Ventas, art. 15, reformado por los artículos 17 y 18 del Decreto 278-2013 — enumera las ventas de bienes y servicios exentos')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
