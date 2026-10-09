-- Ekwo OS — Nicaragua: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ni at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ni`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley No. 822, Ley de Concertación Tributaria (La Gaceta No. 241 del 17 de diciembre de 2012, en vigor desde el 1 de enero de 2013, art. 324), con sus reformas (Ley No. 891 de 2014, Ley No. 987 del 27 de febrero de 2019, La Gaceta No. 41 del 28 de febrero de 2019, y Ley No. 1212 de 2024), y su Reglamento, Decreto No. 01-2013, reformado por el Decreto No. 08-2019 (La Gaceta No. 53 del 15 de marzo de 2019) — Título II, Capítulo IV (IVA), arts. 107 a 143 de la ley y arts. 96 a 98 del Reglamento (Nicatributos — compilación privada de los textos publicados en La Gaceta, Diario Oficial (el texto original de la ley está en la Asamblea Nacional de Nicaragua, legislacion.asamblea.gob.ni))
--     https://nicatributos.com/ley-de-concertacion-tributaria/
--   Disposición Administrativa General No. 04-2013, Presentación de declaraciones y pagos de impuestos (La Gaceta No. 18 del 30 de enero de 2013), anterior a la reforma de 2019 del plazo del IVA (Dirección General de Ingresos (DGI) — texto reproducido por Justia Nicaragua)
--     https://nicaragua.justia.com/nacionales/disposiciones-administrativas/presentacion-de-declaraciones-y-pagos-de-impuestos-jan-30-2013/gdoc/
--   DGI en Línea — Ventanilla Electrónica Tributaria (VET), portal de declaración y pago de la Dirección General de Ingresos; el servidor de la DGI rechazó las consultas automatizadas desde el entorno de redacción de este paquete, por lo que su contenido no pudo leerse (Dirección General de Ingresos (DGI))
--     https://dgienlinea.dgi.gob.ni/menu/inicio.php
--   Disposición Técnica No. 09-2007, Requisitos para uso de sistemas de facturación computarizados (La Gaceta No. 134 del 16 de julio de 2007) (Dirección General de Ingresos (DGI) — texto reproducido por Justia Nicaragua)
--     https://nicaragua.justia.com/nacionales/disposiciones-tecnicas/requisitos-para-uso-de-sistemas-de-facturacion-computarizadas-jul-16-2007/gdoc/
--   Plan Estratégico Institucional 2022-2026 de la Dirección General de Ingresos — prevé desarrollar un sistema de facturación electrónica; no fija una obligación (el servidor de la DGI rechazó la descarga automatizada, el pasaje se leyó en el extracto que devuelve un buscador) (Dirección General de Ingresos (DGI))
--     https://www.dgi.gob.ni/pdfInfo/PlanEstrategico
--   Plan de Arbitrios del Municipio de Managua, Decreto No. 10-91 (La Gaceta No. 30 del 12 de febrero de 1991), art. 3 reformado por la Ley No. 257 de 1997: impuesto municipal del 1 % sobre los ingresos brutos. El resto de los municipios aplica el Plan de Arbitrios Municipal, Decreto No. 455 de 1989, que este paquete no pudo leer en su texto vigente (Nicatributos — compilación privada de los textos publicados en La Gaceta, Diario Oficial)
--     https://nicatributos.com/plan-de-arbitrios/
--   Colegio de Contadores Públicos de Nicaragua (CCPN), creado por la Ley No. 6 del 14 de abril de 1959: único organismo reconocido por la ley como representante de la profesión contable, facultado para fijar normas de contabilidad y de auditoría (ficha de miembro de la IFAC) (International Federation of Accountants (IFAC))
--     https://www.ifac.org/about-ifac/membership/members/colegio-de-contadores-p-blicos-de-nicaragua
--   Adopción de NIIF para las PYMES en empresas de Nicaragua — cronología de las resoluciones del CCPN (resolución del 30 de mayo de 2010 que adopta la NIIF para las PYMES, aplicable a los períodos que inician después del 1 de julio de 2011) (Revista Apuntes de Economía y Sociedad, Universidad Nacional Autónoma de Nicaragua, León (CAMJOL))
--     https://www.camjol.info/index.php/aes/article/view/vol1_2_2020_arto6
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('NI', 'Nicaragua', '0.1.0', date '2026-10-09', '20260929141500', 'community', null, null, 'fa537cae4081b704902ea08e0ab665298ecd27b061adaf4ad3898093496a34f6', '[{"key":"ley-822","title":"Ley No. 822, Ley de Concertación Tributaria (La Gaceta No. 241 del 17 de diciembre de 2012, en vigor desde el 1 de enero de 2013, art. 324), con sus reformas (Ley No. 891 de 2014, Ley No. 987 del 27 de febrero de 2019, La Gaceta No. 41 del 28 de febrero de 2019, y Ley No. 1212 de 2024), y su Reglamento, Decreto No. 01-2013, reformado por el Decreto No. 08-2019 (La Gaceta No. 53 del 15 de marzo de 2019) — Título II, Capítulo IV (IVA), arts. 107 a 143 de la ley y arts. 96 a 98 del Reglamento","publisher":"Nicatributos — compilación privada de los textos publicados en La Gaceta, Diario Oficial (el texto original de la ley está en la Asamblea Nacional de Nicaragua, legislacion.asamblea.gob.ni)","url":"https://nicatributos.com/ley-de-concertacion-tributaria/","consulted_on":"2026-10-09","kind":"law"},{"key":"dag-04-2013","title":"Disposición Administrativa General No. 04-2013, Presentación de declaraciones y pagos de impuestos (La Gaceta No. 18 del 30 de enero de 2013), anterior a la reforma de 2019 del plazo del IVA","publisher":"Dirección General de Ingresos (DGI) — texto reproducido por Justia Nicaragua","url":"https://nicaragua.justia.com/nacionales/disposiciones-administrativas/presentacion-de-declaraciones-y-pagos-de-impuestos-jan-30-2013/gdoc/","consulted_on":"2026-10-09","kind":"guidance"},{"key":"dgi-vet","title":"DGI en Línea — Ventanilla Electrónica Tributaria (VET), portal de declaración y pago de la Dirección General de Ingresos; el servidor de la DGI rechazó las consultas automatizadas desde el entorno de redacción de este paquete, por lo que su contenido no pudo leerse","publisher":"Dirección General de Ingresos (DGI)","url":"https://dgienlinea.dgi.gob.ni/menu/inicio.php","consulted_on":"2026-10-09","kind":"portal"},{"key":"dt-09-2007","title":"Disposición Técnica No. 09-2007, Requisitos para uso de sistemas de facturación computarizados (La Gaceta No. 134 del 16 de julio de 2007)","publisher":"Dirección General de Ingresos (DGI) — texto reproducido por Justia Nicaragua","url":"https://nicaragua.justia.com/nacionales/disposiciones-tecnicas/requisitos-para-uso-de-sistemas-de-facturacion-computarizadas-jul-16-2007/gdoc/","consulted_on":"2026-10-09","kind":"regulation"},{"key":"dgi-plan-estrategico","title":"Plan Estratégico Institucional 2022-2026 de la Dirección General de Ingresos — prevé desarrollar un sistema de facturación electrónica; no fija una obligación (el servidor de la DGI rechazó la descarga automatizada, el pasaje se leyó en el extracto que devuelve un buscador)","publisher":"Dirección General de Ingresos (DGI)","url":"https://www.dgi.gob.ni/pdfInfo/PlanEstrategico","consulted_on":"2026-10-09","kind":"guidance"},{"key":"plan-arbitrios","title":"Plan de Arbitrios del Municipio de Managua, Decreto No. 10-91 (La Gaceta No. 30 del 12 de febrero de 1991), art. 3 reformado por la Ley No. 257 de 1997: impuesto municipal del 1 % sobre los ingresos brutos. El resto de los municipios aplica el Plan de Arbitrios Municipal, Decreto No. 455 de 1989, que este paquete no pudo leer en su texto vigente","publisher":"Nicatributos — compilación privada de los textos publicados en La Gaceta, Diario Oficial","url":"https://nicatributos.com/plan-de-arbitrios/","consulted_on":"2026-10-09","kind":"regulation"},{"key":"ccpn-ifac","title":"Colegio de Contadores Públicos de Nicaragua (CCPN), creado por la Ley No. 6 del 14 de abril de 1959: único organismo reconocido por la ley como representante de la profesión contable, facultado para fijar normas de contabilidad y de auditoría (ficha de miembro de la IFAC)","publisher":"International Federation of Accountants (IFAC)","url":"https://www.ifac.org/about-ifac/membership/members/colegio-de-contadores-p-blicos-de-nicaragua","consulted_on":"2026-10-09","kind":"guidance"},{"key":"niif-pymes-nicaragua","title":"Adopción de NIIF para las PYMES en empresas de Nicaragua — cronología de las resoluciones del CCPN (resolución del 30 de mayo de 2010 que adopta la NIIF para las PYMES, aplicable a los períodos que inician después del 1 de julio de 2011)","publisher":"Revista Apuntes de Economía y Sociedad, Universidad Nacional Autónoma de Nicaragua, León (CAMJOL)","url":"https://www.camjol.info/index.php/aes/article/view/vol1_2_2020_arto6","consulted_on":"2026-10-09","kind":"guidance"}]'::jsonb)
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
  ('NI', 'default', 'Plan de cuentas de referencia, sobre la NIIF para las PYMES', '{}'::jsonb, true, 'companies', array['NI-EF-ER', 'NI-EF-ESF']::text[], null, 'Nicaragua no impone un catálogo de cuentas único ni numerado. El marco contable lo fija el Colegio de Contadores Públicos de Nicaragua (CCPN), el organismo que la ley reconoce como representante de la profesión y que dicta las normas de contabilidad: por resolución del 30 de mayo de 2010 adoptó la NIIF para las PYMES, aplicable a los períodos que inician después del 1 de julio de 2011, y los principios de contabilidad generalmente aceptados nicaragüenses (PCGA) siguen siendo aceptados en la práctica. Este plan es original: sigue una numeración propia y cada bloque de códigos corresponde a una línea de los dos estados de este paquete — véase el README', 'niif-pymes-nicaragua')
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
  ('NI', 'default', '100', 'Activo', '{}'::jsonb, 'asset_current', false, null, 10),
  ('NI', 'default', '110', 'Activo corriente', '{}'::jsonb, 'asset_current', false, '100', 20),
  ('NI', 'default', '111', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 'asset_cash', false, '110', 30),
  ('NI', 'default', '1111', 'Caja general', '{}'::jsonb, 'asset_cash', false, '111', 40),
  ('NI', 'default', '1112', 'Caja chica', '{}'::jsonb, 'asset_cash', false, '111', 50),
  ('NI', 'default', '1113', 'Bancos - cuentas monetarias', '{}'::jsonb, 'asset_cash', false, '111', 60),
  ('NI', 'default', '1114', 'Bancos - cuentas de ahorro', '{}'::jsonb, 'asset_cash', false, '111', 70),
  ('NI', 'default', '1115', 'Inversiones temporales', '{}'::jsonb, 'asset_current', false, '111', 80),
  ('NI', 'default', '112', 'Cuentas por cobrar comerciales', '{}'::jsonb, 'asset_current', false, '110', 90),
  ('NI', 'default', '1121', 'Clientes locales', '{}'::jsonb, 'asset_receivable', true, '112', 100),
  ('NI', 'default', '1122', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '112', 110),
  ('NI', 'default', '1123', 'Documentos por cobrar', '{}'::jsonb, 'asset_receivable', true, '112', 120),
  ('NI', 'default', '113', 'Otras cuentas por cobrar', '{}'::jsonb, 'asset_current', false, '110', 130),
  ('NI', 'default', '1131', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '113', 140),
  ('NI', 'default', '1132', 'Préstamos y anticipos a empleados', '{}'::jsonb, 'asset_current', false, '113', 150),
  ('NI', 'default', '1133', 'Cuentas por cobrar a socios y accionistas', '{}'::jsonb, 'asset_current', false, '113', 160),
  ('NI', 'default', '1134', 'Deudores varios', '{}'::jsonb, 'asset_current', false, '113', 170),
  ('NI', 'default', '114', 'Impuestos por cobrar', '{}'::jsonb, 'asset_current', false, '110', 180),
  ('NI', 'default', '1141', 'IVA - Crédito fiscal', '{}'::jsonb, 'asset_current', false, '114', 190),
  ('NI', 'default', '1142', 'IVA - Saldo a favor por cobrar', '{}'::jsonb, 'asset_current', true, '114', 200),
  ('NI', 'default', '1143', 'Anticipos de IR y pago mínimo definitivo', '{}'::jsonb, 'asset_current', false, '114', 210),
  ('NI', 'default', '1144', 'IR retenido por terceros', '{}'::jsonb, 'asset_current', false, '114', 220),
  ('NI', 'default', '115', 'Gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '110', 230),
  ('NI', 'default', '116', 'Inventarios', '{}'::jsonb, 'asset_current', false, '110', 240),
  ('NI', 'default', '1161', 'Mercaderías', '{}'::jsonb, 'asset_current', false, '116', 250),
  ('NI', 'default', '1162', 'Materias primas', '{}'::jsonb, 'asset_current', false, '116', 260),
  ('NI', 'default', '1163', 'Productos en proceso de producción', '{}'::jsonb, 'asset_current', false, '116', 270),
  ('NI', 'default', '1164', 'Productos terminados', '{}'::jsonb, 'asset_current', false, '116', 280),
  ('NI', 'default', '1165', 'Repuestos y materiales diversos', '{}'::jsonb, 'asset_current', false, '116', 290),
  ('NI', 'default', '119', 'Partidas pendientes de imputación', '{}'::jsonb, 'asset_current', false, '110', 300),
  ('NI', 'default', '120', 'Activo no corriente', '{}'::jsonb, 'asset_non_current', false, '100', 310),
  ('NI', 'default', '121', 'Propiedad, planta y equipo', '{}'::jsonb, 'asset_fixed', false, '120', 320),
  ('NI', 'default', '1211', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '121', 330),
  ('NI', 'default', '12110', 'Depreciación acumulada - Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '121', 420),
  ('NI', 'default', '12111', 'Depreciación acumulada - Vehículos', '{}'::jsonb, 'asset_fixed', false, '121', 430),
  ('NI', 'default', '12112', 'Depreciación acumulada - Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '121', 440),
  ('NI', 'default', '12113', 'Depreciación acumulada - Mejoras a propiedades arrendadas', '{}'::jsonb, 'asset_fixed', false, '121', 450),
  ('NI', 'default', '1212', 'Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '121', 340),
  ('NI', 'default', '1213', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '121', 350),
  ('NI', 'default', '1214', 'Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '121', 360),
  ('NI', 'default', '1215', 'Vehículos', '{}'::jsonb, 'asset_fixed', false, '121', 370),
  ('NI', 'default', '1216', 'Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '121', 380),
  ('NI', 'default', '1217', 'Mejoras a propiedades arrendadas', '{}'::jsonb, 'asset_fixed', false, '121', 390),
  ('NI', 'default', '1218', 'Depreciación acumulada - Edificios y construcciones', '{}'::jsonb, 'asset_fixed', false, '121', 400),
  ('NI', 'default', '1219', 'Depreciación acumulada - Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '121', 410),
  ('NI', 'default', '122', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '120', 460),
  ('NI', 'default', '1221', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '122', 470),
  ('NI', 'default', '1222', 'Programas de cómputo (software)', '{}'::jsonb, 'asset_non_current', false, '122', 480),
  ('NI', 'default', '1223', 'Amortización acumulada de intangibles', '{}'::jsonb, 'asset_non_current', false, '122', 490),
  ('NI', 'default', '123', 'Otros activos no corrientes', '{}'::jsonb, 'asset_non_current', false, '120', 500),
  ('NI', 'default', '1231', 'Depósitos en garantía', '{}'::jsonb, 'asset_non_current', false, '123', 510),
  ('NI', 'default', '1232', 'Inversiones permanentes', '{}'::jsonb, 'asset_non_current', false, '123', 520),
  ('NI', 'default', '1233', 'Cuentas por cobrar a largo plazo', '{}'::jsonb, 'asset_non_current', false, '123', 530),
  ('NI', 'default', '200', 'Pasivo', '{}'::jsonb, 'liability_current', false, null, 540),
  ('NI', 'default', '210', 'Pasivo corriente', '{}'::jsonb, 'liability_current', false, '200', 550),
  ('NI', 'default', '211', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_current', false, '210', 560),
  ('NI', 'default', '2111', 'Proveedores locales', '{}'::jsonb, 'liability_payable', true, '211', 570),
  ('NI', 'default', '2112', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '211', 580),
  ('NI', 'default', '2113', 'Documentos por pagar', '{}'::jsonb, 'liability_payable', true, '211', 590),
  ('NI', 'default', '212', 'Remuneraciones y prestaciones laborales por pagar', '{}'::jsonb, 'liability_current', false, '210', 600),
  ('NI', 'default', '2121', 'Sueldos por pagar', '{}'::jsonb, 'liability_current', false, '212', 610),
  ('NI', 'default', '2122', 'Vacaciones por pagar', '{}'::jsonb, 'liability_current', false, '212', 620),
  ('NI', 'default', '2123', 'Treceavo mes (aguinaldo) por pagar', '{}'::jsonb, 'liability_current', false, '212', 630),
  ('NI', 'default', '2124', 'Aportes al INATEC por pagar', '{}'::jsonb, 'liability_current', false, '212', 640),
  ('NI', 'default', '2125', 'Cuotas patronales y laborales al INSS por pagar', '{}'::jsonb, 'liability_current', false, '212', 650),
  ('NI', 'default', '2126', 'Indemnizaciones por antigüedad por pagar', '{}'::jsonb, 'liability_current', false, '212', 660),
  ('NI', 'default', '213', 'Impuestos por pagar', '{}'::jsonb, 'liability_current', false, '210', 670),
  ('NI', 'default', '2131', 'IVA - Débito fiscal', '{}'::jsonb, 'liability_current', false, '213', 680),
  ('NI', 'default', '2132', 'IVA por pagar', '{}'::jsonb, 'liability_current', true, '213', 690),
  ('NI', 'default', '2133', 'Impuesto sobre la Renta (IR) por pagar', '{}'::jsonb, 'liability_current', false, '213', 700),
  ('NI', 'default', '2134', 'Anticipos de IR y pago mínimo definitivo por pagar', '{}'::jsonb, 'liability_current', false, '213', 710),
  ('NI', 'default', '2135', 'Retenciones de IVA por enterar', '{}'::jsonb, 'liability_current', false, '213', 720),
  ('NI', 'default', '2136', 'Retenciones de IR por enterar', '{}'::jsonb, 'liability_current', false, '213', 730),
  ('NI', 'default', '2137', 'Impuesto Municipal sobre Ingresos (IMI) por pagar', '{}'::jsonb, 'liability_current', false, '213', 740),
  ('NI', 'default', '214', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '210', 750),
  ('NI', 'default', '215', 'Provisiones a corto plazo', '{}'::jsonb, 'liability_current', false, '210', 760),
  ('NI', 'default', '220', 'Pasivo no corriente', '{}'::jsonb, 'liability_non_current', false, '200', 770),
  ('NI', 'default', '221', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 780),
  ('NI', 'default', '222', 'Arrendamientos financieros por pagar', '{}'::jsonb, 'liability_non_current', false, '220', 790),
  ('NI', 'default', '223', 'Provisión para indemnizaciones por antigüedad', '{}'::jsonb, 'liability_non_current', false, '220', 800),
  ('NI', 'default', '224', 'Otras cuentas por pagar a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 810),
  ('NI', 'default', '300', 'Patrimonio neto', '{}'::jsonb, 'equity', false, null, 820),
  ('NI', 'default', '310', 'Capital autorizado', '{}'::jsonb, 'equity', false, '300', 830),
  ('NI', 'default', '311', 'Capital suscrito y pagado', '{}'::jsonb, 'equity', false, '300', 840),
  ('NI', 'default', '320', 'Aportaciones por capitalizar', '{}'::jsonb, 'equity', false, '300', 850),
  ('NI', 'default', '330', 'Reserva legal', '{}'::jsonb, 'equity', false, '300', 860),
  ('NI', 'default', '340', 'Resultados acumulados de ejercicios anteriores', '{}'::jsonb, 'equity_retained', false, '300', 870),
  ('NI', 'default', '341', 'Utilidades no distribuidas', '{}'::jsonb, 'equity_retained', false, '340', 880),
  ('NI', 'default', '342', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '340', 890),
  ('NI', 'default', '350', 'Resultado del ejercicio', '{}'::jsonb, 'equity', false, '300', 900),
  ('NI', 'default', '351', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 'equity', false, '350', 910),
  ('NI', 'default', '352', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 'equity', false, '350', 920),
  ('NI', 'default', '400', 'Ingresos', '{}'::jsonb, 'income', false, null, 930),
  ('NI', 'default', '410', 'Ventas', '{}'::jsonb, 'income', false, '400', 940),
  ('NI', 'default', '411', 'Ventas locales gravadas', '{}'::jsonb, 'income', false, '410', 950),
  ('NI', 'default', '412', 'Ventas de exportación', '{}'::jsonb, 'income', false, '410', 960),
  ('NI', 'default', '413', 'Ventas exentas', '{}'::jsonb, 'income', false, '410', 970),
  ('NI', 'default', '414', 'Prestación de servicios gravados', '{}'::jsonb, 'income', false, '410', 980),
  ('NI', 'default', '415', 'Descuentos y devoluciones sobre ventas', '{}'::jsonb, 'income', false, '410', 990),
  ('NI', 'default', '460', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '400', 1000),
  ('NI', 'default', '461', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '460', 1010),
  ('NI', 'default', '462', 'Diferencial cambiario ganado', '{}'::jsonb, 'income_other', false, '460', 1020),
  ('NI', 'default', '463', 'Descuentos obtenidos de proveedores', '{}'::jsonb, 'income_other', false, '460', 1030),
  ('NI', 'default', '464', 'Ganancia en venta de activos fijos', '{}'::jsonb, 'income_other', false, '460', 1040),
  ('NI', 'default', '465', 'Ingresos varios', '{}'::jsonb, 'income_other', false, '460', 1050),
  ('NI', 'default', '500', 'Costos y gastos', '{}'::jsonb, 'expense', false, null, 1060),
  ('NI', 'default', '510', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '500', 1070),
  ('NI', 'default', '511', 'Compras de mercadería', '{}'::jsonb, 'expense_direct_cost', false, '510', 1080),
  ('NI', 'default', '512', 'Compras que no generan crédito fiscal', '{}'::jsonb, 'expense_direct_cost', false, '510', 1090),
  ('NI', 'default', '513', 'Costo de servicios prestados', '{}'::jsonb, 'expense_direct_cost', false, '510', 1100),
  ('NI', 'default', '514', 'Fletes y seguros sobre compras', '{}'::jsonb, 'expense_direct_cost', false, '510', 1110),
  ('NI', 'default', '520', 'Gastos de venta', '{}'::jsonb, 'expense', false, '500', 1120),
  ('NI', 'default', '521', 'Sueldos y comisiones de ventas', '{}'::jsonb, 'expense', false, '520', 1130),
  ('NI', 'default', '522', 'Publicidad y mercadeo', '{}'::jsonb, 'expense', false, '520', 1140),
  ('NI', 'default', '523', 'Fletes y transporte sobre ventas', '{}'::jsonb, 'expense', false, '520', 1150),
  ('NI', 'default', '524', 'Gastos de viaje y representación', '{}'::jsonb, 'expense', false, '520', 1160),
  ('NI', 'default', '525', 'Otros gastos de venta', '{}'::jsonb, 'expense', false, '520', 1170),
  ('NI', 'default', '530', 'Gastos de administración', '{}'::jsonb, 'expense', false, '500', 1180),
  ('NI', 'default', '531', 'Sueldos administrativos', '{}'::jsonb, 'expense', false, '530', 1190),
  ('NI', 'default', '5310', 'Seguros', '{}'::jsonb, 'expense', false, '530', 1280),
  ('NI', 'default', '5311', 'Impuesto de bienes inmuebles (IBI)', '{}'::jsonb, 'expense', false, '530', 1290),
  ('NI', 'default', '5312', 'Impuesto Municipal sobre Ingresos (IMI) y otros tributos municipales', '{}'::jsonb, 'expense', false, '530', 1300),
  ('NI', 'default', '5313', 'Depreciación de propiedad planta y equipo', '{}'::jsonb, 'expense_depreciation', false, '530', 1310),
  ('NI', 'default', '5314', 'Amortización de activos intangibles', '{}'::jsonb, 'expense', false, '530', 1320),
  ('NI', 'default', '5315', 'Gastos varios de administración', '{}'::jsonb, 'expense', false, '530', 1330),
  ('NI', 'default', '532', 'Cuotas patronales INSS e INATEC', '{}'::jsonb, 'expense', false, '530', 1200),
  ('NI', 'default', '533', 'Treceavo mes y vacaciones', '{}'::jsonb, 'expense', false, '530', 1210),
  ('NI', 'default', '534', 'Indemnizaciones por antigüedad', '{}'::jsonb, 'expense', false, '530', 1220),
  ('NI', 'default', '535', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '530', 1230),
  ('NI', 'default', '536', 'Arrendamientos', '{}'::jsonb, 'expense', false, '530', 1240),
  ('NI', 'default', '537', 'Servicios básicos (agua, energía, teléfono)', '{}'::jsonb, 'expense', false, '530', 1250),
  ('NI', 'default', '538', 'Papelería y útiles de oficina', '{}'::jsonb, 'expense', false, '530', 1260),
  ('NI', 'default', '539', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '530', 1270),
  ('NI', 'default', '540', 'Gastos financieros', '{}'::jsonb, 'expense', false, '500', 1340),
  ('NI', 'default', '541', 'Intereses pagados', '{}'::jsonb, 'expense', false, '540', 1350),
  ('NI', 'default', '542', 'Diferencial cambiario perdido', '{}'::jsonb, 'expense', false, '540', 1360),
  ('NI', 'default', '543', 'Comisiones y gastos bancarios', '{}'::jsonb, 'expense', false, '540', 1370),
  ('NI', 'default', '544', 'Redondeo', '{}'::jsonb, 'expense', false, '540', 1380),
  ('NI', 'default', '550', 'Impuesto sobre la Renta (IR) del ejercicio', '{}'::jsonb, 'expense', false, '500', 1390),
  ('NI', 'default', '551', 'Pago mínimo definitivo del ejercicio', '{}'::jsonb, 'expense', false, '500', 1400),
  ('NI', 'default', '560', 'Otros gastos', '{}'::jsonb, 'expense', false, '500', 1410)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('NI', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('NI', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('NI', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('NI', 'COM', 'Compras', '{}'::jsonb, 'purchase', 20),
  ('NI', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('NI', 'VEN', 'Ventas', '{}'::jsonb, 'sales', 10)
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
  ('NI', 'NI-C-15', 'Compra o servicio gravado, 15 %, con derecho a crédito fiscal', '{}'::jsonb, 'Adquisición de bienes o servicios gravados, destinada a operaciones gravadas con la alícuota general o con la alícuota cero', 'percent', 15, 'purchase', 'domestic', date '2013-01-01', null, 'Ley No. 822, art. 116 — constituye crédito fiscal el IVA trasladado al responsable recaudador y el pagado en importaciones, siempre que sea para efectuar operaciones gravadas con la alícuota general o con la alícuota cero; art. 117 — la acreditación resta del débito fiscal el crédito fiscal; art. 118 — requisitos de la acreditación (bienes o servicios necesarios para operaciones gravadas, gasto deducible para el IR, documento a nombre del responsable); art. 119 — el IVA se acredita en el mes en que se realiza la compra', null, null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null),
  ('NI', 'NI-C-15-NOCRED', 'Compra o servicio gravado, 15 %, sin derecho a crédito fiscal', '{}'::jsonb, 'Adquisición gravada destinada a operaciones exentas, o que no reúne los requisitos de la acreditación', 'percent', 15, 'purchase', 'domestic', date '2013-01-01', null, 'Ley No. 822, art. 120 — no es acreditable el IVA que grava bienes, servicios o uso o goce de bienes destinados a enajenaciones o prestaciones exentas, ni el autoconsumo no deducible para el IR; art. 116, último párrafo — en las operaciones exentas el IVA no acreditable se considera parte del costo; art. 121 — cuando el IVA se usa en operaciones gravadas y exentas, solo se acredita la parte proporcional (la prorrata no está modelada: este paquete ofrece el caso total). La posición `tax_on_base` lleva el impuesto al costo sin casilla propia, porque la declaración no separa el impuesto no acreditable', null, null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null),
  ('NI', 'NI-C-EXO', 'Compra o servicio no gravado', '{}'::jsonb, 'Adquisición de bienes o servicios exentos, o a un proveedor que no traslada el impuesto', 'percent', 0, 'purchase', 'exempt', date '2013-01-01', null, 'Ley No. 822, arts. 127 y 136 — bienes y servicios exentos del traslado del IVA; art. 111 — sujetos exentos que no trasladan el impuesto en sus ventas', null, null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null),
  ('NI', 'NI-C-IMP-15', 'Importación o internación gravada, 15 %', '{}'::jsonb, 'Importación o internación de bienes, con derecho a crédito fiscal por el IVA pagado en la aduana', 'percent', 15, 'purchase', 'import', date '2013-01-01', null, 'Ley No. 822, art. 107, numeral 2 — la importación e internación de bienes están gravadas; art. 128 — definiciones de importación e internación; art. 129 — el hecho generador se realiza al aceptarse la declaración o formulario aduanero; art. 130 — la base imponible es el valor en aduana más los demás tributos recaudados en la importación y los gastos de la declaración aduanera; art. 139, numeral 2 — el IVA se paga en la declaración aduanera, antes del retiro de los bienes; art. 116 — el IVA pagado en la importación es crédito fiscal', null, null, 140, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null),
  ('NI', 'NI-V-15', 'Venta o servicio gravado, 15 %', '{}'::jsonb, 'Enajenación de bienes, prestación de servicios y uso o goce de bienes gravados con la alícuota general del Impuesto al Valor Agregado', 'percent', 15, 'sale', 'domestic', date '2013-01-01', null, 'Ley No. 822, art. 107 — el IVA grava la enajenación de bienes, la importación e internación, la exportación de bienes y servicios conforme al art. 109 y la prestación de servicios y el uso o goce de bienes; art. 109 — «la alícuota del IVA es del quince por ciento (15%), salvo en las exportaciones de bienes de producción nacional y de servicios prestados al exterior, sobre las cuales se aplicará una alícuota del cero por ciento (0%)»; art. 114 — el responsable recaudador traslada el IVA al adquirente y el monto trasladado constituye su débito fiscal, que no forma parte de la base imponible. La Ley No. 987 de 2019 no cambió la alícuota. Nicaragua no tiene hoy alícuota reducida general: el 7 % transitorio de la energía eléctrica de la Ley No. 971 ya no está vigente y este paquete no lo modela. Nicaragua queda fuera del sistema común del IVA de la Unión Europea: este paquete no declara `exemption_code` ni tratamiento `intracom_*`, y el artículo que exime cada operación va en `legal_reference`', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null),
  ('NI', 'NI-V-EXO', 'Venta o servicio exento', '{}'::jsonb, 'Enajenación de bienes de las listas del art. 127, servicios del art. 136 u operaciones de los sujetos exentos del art. 111 de la Ley No. 822', 'percent', 0, 'sale', 'exempt', date '2013-01-01', null, 'Ley No. 822, art. 127 — están exentas del traslado del IVA, mediante listas taxativas establecidas por acuerdos ministeriales, las enajenaciones de libros y publicaciones periódicas, medicamentos, equipo médico, bienes agrícolas no transformados (arroz, maíz, frijol, tomate, banano, plátano y otros), alimentos básicos, carnes frescas, gas butano en envase de hasta 25 libras, bienes muebles usados, la transmisión del dominio de inmuebles y los paneles solares, entre otros; art. 136 — servicios exentos, entre ellos los médicos y odontológicos, la enseñanza, el transporte interno y el alquiler de inmuebles con fines de vivienda; art. 111 — sujetos exentos (universidades, iglesias, Cruz Roja y otros), con las condiciones del art. 112; art. 120 — el IVA que grava bienes y servicios destinados a operaciones exentas no es acreditable. Este paquete declara un único código para el conjunto; el numeral exacto de cada operación se cita en el asiento — véase el README', 'E', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null),
  ('NI', 'NI-V-EXP', 'Exportación de bienes y servicios, alícuota 0 %', '{}'::jsonb, 'Exportación de bienes de producción nacional y servicios prestados a usuarios no residentes, gravada con la alícuota del cero por ciento', 'percent', 0, 'sale', 'export', date '2013-01-01', null, 'Ley No. 822, art. 109 — alícuota del cero por ciento (0%) en las exportaciones de bienes de producción nacional y de servicios prestados al exterior; se considera exportación «la salida del territorio aduanero nacional de las mercancías de producción nacional, para su uso o consumo definitivo en el exterior», y el mismo tratamiento corresponde a los servicios prestados a usuarios no residentes; art. 107, numeral 3 — la exportación es una operación gravada (a la alícuota cero), no una operación exenta; art. 116 y 121 — conserva el derecho a acreditar el IVA de las compras; art. 140, numeral 1 — las enajenaciones con alícuota cero pueden ser objeto de compensación o devolución del saldo a favor. El procedimiento de devolución no es una alícuota ni una casilla de la declaración y este paquete no lo modela — véase el README', 'G', null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ley-822', null, null, null, null)
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
    ('NI-C-15', 'invoice', 'base', 100, null, 'CG', array['CG']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-C-15', 'invoice', 'tax', 100, '1141', 'CF', array['CF']::text[], 100, 'NI-DGI-IVA', 20),
    ('NI-C-15', 'credit_note', 'base', 100, null, 'CG', array['CG']::text[], -100, 'NI-DGI-IVA', 10),
    ('NI-C-15', 'credit_note', 'tax', 100, '1141', 'CF', array['CF']::text[], -100, 'NI-DGI-IVA', 20),
    ('NI-C-15-NOCRED', 'invoice', 'base', 100, null, 'CNOCRED', array['CNOCRED']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-C-15-NOCRED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('NI-C-15-NOCRED', 'credit_note', 'base', 100, null, 'CNOCRED', array['CNOCRED']::text[], -100, 'NI-DGI-IVA', 10),
    ('NI-C-15-NOCRED', 'credit_note', 'tax_on_base', 100, null, null, null, -100, null, 20),
    ('NI-C-EXO', 'invoice', 'base', 100, null, 'CEXO', array['CEXO']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-C-EXO', 'credit_note', 'base', 100, null, 'CEXO', array['CEXO']::text[], -100, 'NI-DGI-IVA', 10),
    ('NI-C-IMP-15', 'invoice', 'base', 100, null, 'IMP', array['IMP']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-C-IMP-15', 'invoice', 'tax', 100, '1141', 'CFIMP', array['CFIMP']::text[], 100, 'NI-DGI-IVA', 20),
    ('NI-C-IMP-15', 'credit_note', 'base', 100, null, 'IMP', array['IMP']::text[], -100, 'NI-DGI-IVA', 10),
    ('NI-C-IMP-15', 'credit_note', 'tax', 100, '1141', 'CFIMP', array['CFIMP']::text[], -100, 'NI-DGI-IVA', 20),
    ('NI-V-15', 'invoice', 'base', 100, null, 'VG', array['VG']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-V-15', 'invoice', 'tax', 100, '2131', 'DF', array['DF']::text[], 100, 'NI-DGI-IVA', 20),
    ('NI-V-15', 'credit_note', 'base', 100, null, 'VG', array['VG']::text[], -100, 'NI-DGI-IVA', 10),
    ('NI-V-15', 'credit_note', 'tax', 100, '2131', 'DF', array['DF']::text[], -100, 'NI-DGI-IVA', 20),
    ('NI-V-EXO', 'invoice', 'base', 100, null, 'VEXO', array['VEXO']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-V-EXO', 'credit_note', 'base', 100, null, 'VEXO', array['VEXO']::text[], -100, 'NI-DGI-IVA', 10),
    ('NI-V-EXP', 'invoice', 'base', 100, null, 'VEXP', array['VEXP']::text[], 100, 'NI-DGI-IVA', 10),
    ('NI-V-EXP', 'credit_note', 'base', 100, null, 'VEXP', array['VEXP']::text[], -100, 'NI-DGI-IVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'NI' and t.code = v.tax_code
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
  ('NI', 'NI-DGI-IVA', 'Declaración mensual del Impuesto al Valor Agregado (IVA) — Ventanilla Electrónica Tributaria de la DGI', array['month']::declaration_period[], 'month'::declaration_period, date '2013-01-01', null, 'Ley No. 822, art. 138 — los responsables recaudadores declaran, liquidan y pagan el IVA en la forma, plazo y lugar que establece el Reglamento; art. 117 — el IVA a pagar es el débito fiscal menos el crédito fiscal; art. 140 — un saldo a favor se imputa a los períodos siguientes dentro del plazo de prescripción. Reglamento, art. 97 — el período es el mes calendario y la declaración se hace por medios electrónicos (TIC) que autorice la Administración Tributaria, con los datos y anexos del negocio. La DGI recibe la declaración en su Ventanilla Electrónica Tributaria (VET); sus campos no están publicados en un texto abierto que este paquete haya podido leer, así que las casillas de este paquete llevan un acrónimo propio y el nombre del concepto que la ley manda declarar — véase el README', true,'day_of_month_after_period'::filing_deadline_rule, 5, null, 'Decreto No. 01-2013, Reglamento de la Ley No. 822, art. 97, numeral 2, literal c), reformado por el art. 5 del Decreto No. 08-2019 (La Gaceta No. 53 del 15 de marzo de 2019): «la declaración del IVA debe realizarse a más tardar el quinto día calendario del mes siguiente al período gravado». El pago tiene su propia fecha: art. 98, numeral 3, del mismo Reglamento — el quinto día calendario del mes siguiente para los principales y grandes contribuyentes, y hasta el día quince (15) para los demás; los grandes contribuyentes hacen además un pago anticipado por la primera quincena (art. 98, numeral 4). La Disposición Administrativa General No. 04-2013, anterior a la reforma, fijaba «quince días después de finalizado el mes» para declarar y pagar, y es la fecha que repiten los calendarios fiscales privados; el texto vigente del Reglamento prevalece sobre ella, y el día 15 es solo el plazo de pago de los contribuyentes que no son principales ni grandes. Esta regla modela la fecha de la declaración', 'ley-822', null)
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
  ('NI', 'NI-DGI-IVA', 'VG', 'base', 'Ventas y servicios gravados al 15 % — base imponible', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 109 y 126 — operaciones gravadas con la alícuota general, sobre el precio de la factura sin el IVA', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'DF', 'tax', 'Ventas y servicios gravados — IVA trasladado (débito fiscal)', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 114 — el monto total de la traslación constituye el débito fiscal del responsable recaudador', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'VEXP', 'base', 'Exportaciones a alícuota 0 %', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 109 — exportaciones de bienes de producción nacional y servicios prestados al exterior, a la alícuota del cero por ciento', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'VEXO', 'base', 'Ventas y servicios exentos', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, arts. 127 y 136 — operaciones exentas del traslado del IVA, que el responsable recaudador informa en su declaración', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'CG', 'base', 'Compras y servicios gravados con derecho a crédito fiscal — base', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 116 y 119 — adquisiciones gravadas cuyo IVA se acredita en el mes de la compra', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'CF', 'tax', 'Compras y servicios gravados — IVA acreditable (crédito fiscal)', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 116 — el IVA trasladado al responsable recaudador constituye crédito fiscal', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'CNOCRED', 'base', 'Compras gravadas sin derecho a crédito fiscal', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 120 — IVA no acreditable, que forma parte del costo', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'CEXO', 'base', 'Compras y servicios exentos o no gravados', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, arts. 127 y 136 — adquisiciones sin traslado del IVA', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'IMP', 'base', 'Importaciones e internaciones gravadas — base', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 130 — valor en aduana más los demás tributos y gastos de la declaración aduanera', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'CFIMP', 'tax', 'Importaciones e internaciones — IVA pagado en aduana (crédito fiscal)', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ley No. 822, art. 116 — el IVA pagado sobre importaciones e internaciones es crédito fiscal', 'ley-822'),
  ('NI', 'NI-DGI-IVA', 'TOTAL', 'total', 'IVA a pagar o saldo a favor', '{}'::jsonb, 110, null, array['DF']::text[], array['CF', 'CFIMP']::text[], null, null, false, false, null, 'Ley No. 822, art. 117 — el IVA a pagar es el débito fiscal menos el crédito fiscal; art. 140 — el saldo a favor se imputa a los períodos subsiguientes y, en las exportaciones a alícuota cero, puede ser objeto de compensación o devolución', 'ley-822')
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
  ('NI-EF-ER', 'NI', 'default', 'Estado de Resultados', 'income_statement', 'NI-NIIFPYMES', date '1970-01-01', null, 'NIIF para las PYMES, sección 5 (estado del resultado integral y estado de resultados): el contenido mínimo de las partidas que presenta este esquema, con los gastos clasificados por función. Nicaragua no impone un esquema propio — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', 'NI', 'default', 'Estado de Situación Financiera', 'balance_sheet', 'NI-NIIFPYMES', date '1970-01-01', null, 'NIIF para las PYMES, sección 4 (estado de situación financiera): el contenido mínimo de las partidas que presenta este esquema. Nicaragua no impone un esquema de estados financieros propio: el CCPN adoptó la NIIF para las PYMES por resolución del 30 de mayo de 2010, aplicable a los períodos que inician después del 1 de julio de 2011, y mantiene los PCGA nicaragüenses como marco aceptado; este paquete sigue la NIIF para las PYMES — véase el README', 'niif-pymes-nicaragua')
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
  ('NI-EF-ER', 'ING', null, 'Ingresos de operación', '{}'::jsonb, 10, 1, true, array['411', '412', '413', '414', '415']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ER', '411', 'ING', 'Ventas locales gravadas', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '412', 'ING', 'Ventas de exportación', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '413', 'ING', 'Ventas exentas', '{}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '414', 'ING', 'Prestación de servicios gravados', '{}'::jsonb, 50, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '415', 'ING', 'Descuentos y devoluciones sobre ventas', '{}'::jsonb, 60, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '51', null, 'Costo de ventas', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', 'UB', null, 'Utilidad (pérdida) bruta', '{}'::jsonb, 80, 1, true, array['ING']::text[], array['51']::text[], null, null, null),
  ('NI-EF-ER', '52', null, 'Gastos de venta', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '53', null, 'Gastos de administración', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', 'GO', null, 'Gastos operativos', '{}'::jsonb, 110, 1, true, array['52', '53']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ER', 'UO', null, 'Utilidad (pérdida) de operación', '{}'::jsonb, 120, 1, true, array['UB']::text[], array['GO']::text[], null, null, null),
  ('NI-EF-ER', '46', null, 'Otros ingresos', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '54', null, 'Gastos financieros', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', '56', null, 'Otros gastos', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', 'RF', null, 'Resultado financiero y otros', '{}'::jsonb, 160, 1, true, array['46']::text[], array['54', '56']::text[], null, null, null),
  ('NI-EF-ER', 'UAI', null, 'Utilidad (pérdida) antes de impuesto sobre la renta', '{}'::jsonb, 170, 1, true, array['UO', 'RF']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ER', '55', null, 'Impuesto sobre la renta y pago mínimo definitivo', '{}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ER', 'UN', null, 'Utilidad (pérdida) neta del ejercicio', '{}'::jsonb, 190, 1, true, array['UAI']::text[], array['55']::text[], null, null, null),
  ('NI-EF-ESF', 'ACT', null, 'Activo', '{}'::jsonb, 10, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', 'AC', 'ACT', 'Activo corriente', '{}'::jsonb, 20, 1, true, array['111', '112', '113', '114', '115', '116', '119']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', '111', 'AC', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '112', 'AC', 'Cuentas por cobrar comerciales', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '113', 'AC', 'Otras cuentas por cobrar', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '114', 'AC', 'Impuestos por cobrar', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete; incluye el crédito fiscal del IVA (cuentas 1141 y 1142) y los anticipos y retenciones de IR a favor (1143 y 1144)', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '115', 'AC', 'Gastos pagados por anticipado', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '116', 'AC', 'Inventarios', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '119', 'AC', 'Partidas pendientes de imputación', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de suspenso del plan de cuentas de este paquete', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', 'ANC', 'ACT', 'Activo no corriente', '{}'::jsonb, 100, 1, true, array['121', '122', '123']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', '121', 'ANC', 'Propiedad, planta y equipo', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '122', 'ANC', 'Activos intangibles', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '123', 'ANC', 'Otros activos no corrientes', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', 'PYP', null, 'Pasivo y patrimonio neto', '{}'::jsonb, 140, 1, true, array['PAS', 'PAT']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', 'PAS', 'PYP', 'Pasivo', '{}'::jsonb, 150, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', 'PC', 'PAS', 'Pasivo corriente', '{}'::jsonb, 160, 1, true, array['211', '212', '213', '214', '215']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', '211', 'PC', 'Cuentas por pagar comerciales', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '212', 'PC', 'Remuneraciones y prestaciones laborales por pagar', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '213', 'PC', 'Impuestos por pagar', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete; incluye el débito fiscal y el IVA por pagar del período (cuentas 2131 y 2132) y las retenciones por enterar', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '214', 'PC', 'Anticipos de clientes', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '215', 'PC', 'Provisiones a corto plazo', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', 'PNC', 'PAS', 'Pasivo no corriente', '{}'::jsonb, 220, 1, true, array['221', '222', '223', '224']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', '221', 'PNC', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '222', 'PNC', 'Arrendamientos financieros por pagar', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '223', 'PNC', 'Provisión para indemnizaciones laborales', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '224', 'PNC', 'Otras cuentas por pagar a largo plazo', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', 'PAT', 'PYP', 'Patrimonio neto', '{}'::jsonb, 270, 1, true, array['310', '311', '320', '330', '341', '342', '351', '352']::text[], '{}'::text[], null, null, null),
  ('NI-EF-ESF', '310', 'PAT', 'Capital autorizado', '{}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '311', 'PAT', 'Capital suscrito y pagado', '{}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '320', 'PAT', 'Aportaciones por capitalizar', '{}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '330', 'PAT', 'Reserva legal', '{}'::jsonb, 310, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '341', 'PAT', 'Utilidades no distribuidas', '{}'::jsonb, 320, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '342', 'PAT', 'Pérdidas acumuladas', '{}'::jsonb, 330, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '351', 'PAT', 'Resultado del ejercicio - Ganancia', '{}'::jsonb, 340, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua'),
  ('NI-EF-ESF', '352', 'PAT', 'Resultado del ejercicio - Pérdida', '{}'::jsonb, 350, -1, false, '{}'::text[], '{}'::text[], null, 'Cuentas de mayor del plan de cuentas de este paquete, abierto conforme a la NIIF para las PYMES adoptada por el Colegio de Contadores Públicos de Nicaragua; Nicaragua no prescribe un catálogo de cuentas — véase el README', 'niif-pymes-nicaragua')
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
    ('NI-EF-ER', '411', 10, 'code_prefix', '411', null, null, 'any'),
    ('NI-EF-ER', '412', 10, 'code_prefix', '412', null, null, 'any'),
    ('NI-EF-ER', '413', 10, 'code_prefix', '413', null, null, 'any'),
    ('NI-EF-ER', '414', 10, 'code_prefix', '414', null, null, 'any'),
    ('NI-EF-ER', '415', 10, 'code_prefix', '415', null, null, 'any'),
    ('NI-EF-ER', '51', 10, 'code_prefix', '51', null, null, 'any'),
    ('NI-EF-ER', '52', 10, 'code_prefix', '52', null, null, 'any'),
    ('NI-EF-ER', '53', 10, 'code_prefix', '53', null, null, 'any'),
    ('NI-EF-ER', '46', 10, 'code_prefix', '46', null, null, 'any'),
    ('NI-EF-ER', '54', 10, 'code_prefix', '54', null, null, 'any'),
    ('NI-EF-ER', '56', 10, 'code_prefix', '56', null, null, 'any'),
    ('NI-EF-ER', '55', 10, 'code_prefix', '55', null, null, 'any'),
    ('NI-EF-ESF', '111', 10, 'code_prefix', '111', null, null, 'any'),
    ('NI-EF-ESF', '112', 10, 'code_prefix', '112', null, null, 'any'),
    ('NI-EF-ESF', '113', 10, 'code_prefix', '113', null, null, 'any'),
    ('NI-EF-ESF', '114', 10, 'code_prefix', '114', null, null, 'any'),
    ('NI-EF-ESF', '115', 10, 'code_prefix', '115', null, null, 'any'),
    ('NI-EF-ESF', '116', 10, 'code_prefix', '116', null, null, 'any'),
    ('NI-EF-ESF', '119', 10, 'code_prefix', '119', null, null, 'any'),
    ('NI-EF-ESF', '121', 10, 'code_prefix', '121', null, null, 'any'),
    ('NI-EF-ESF', '122', 10, 'code_prefix', '122', null, null, 'any'),
    ('NI-EF-ESF', '123', 10, 'code_prefix', '123', null, null, 'any'),
    ('NI-EF-ESF', '211', 10, 'code_prefix', '211', null, null, 'any'),
    ('NI-EF-ESF', '212', 10, 'code_prefix', '212', null, null, 'any'),
    ('NI-EF-ESF', '213', 10, 'code_prefix', '213', null, null, 'any'),
    ('NI-EF-ESF', '214', 10, 'code_prefix', '214', null, null, 'any'),
    ('NI-EF-ESF', '215', 10, 'code_prefix', '215', null, null, 'any'),
    ('NI-EF-ESF', '221', 10, 'code_prefix', '221', null, null, 'any'),
    ('NI-EF-ESF', '222', 10, 'code_prefix', '222', null, null, 'any'),
    ('NI-EF-ESF', '223', 10, 'code_prefix', '223', null, null, 'any'),
    ('NI-EF-ESF', '224', 10, 'code_prefix', '224', null, null, 'any'),
    ('NI-EF-ESF', '310', 10, 'code_prefix', '310', null, null, 'any'),
    ('NI-EF-ESF', '311', 10, 'code_prefix', '311', null, null, 'any'),
    ('NI-EF-ESF', '320', 10, 'code_prefix', '320', null, null, 'any'),
    ('NI-EF-ESF', '330', 10, 'code_prefix', '330', null, null, 'any'),
    ('NI-EF-ESF', '341', 10, 'code_prefix', '341', null, null, 'any'),
    ('NI-EF-ESF', '342', 10, 'code_prefix', '342', null, null, 'any'),
    ('NI-EF-ESF', '351', 10, 'code_prefix', '351', null, null, 'any'),
    ('NI-EF-ESF', '352', 10, 'code_prefix', '352', null, null, 'any')
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
  ('NI', 'Nicaragua', '{}'::jsonb, array['es']::text[], 'NIO', '1121', '2111', '119', '544', '341', '411', '511', '1113', '1111', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', default, default, '462', '542', null, null, null, null, '2132', '1142', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Código Tributario, art. 81, y Disposición Técnica No. 09-2007 (numeral 1.7) — los sistemas de facturación computarizados deben garantizar la continuidad numérica de las facturas, con una numeración inalterable. La factura impresa lleva el pie de imprenta fiscal de una imprenta autorizada por la DGI. El número que declara este paquete es el de la pieza contable, correlativo por diario, y no el de la factura autorizada por la DGI — véase el README',
  numbering_source_key          = 'dt-09-2007',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ley No. 822, art. 125 y 133 — el hecho generador del IVA se realiza en el primero de estos actos: la expedición de la factura, el pago o abono del precio, o la entrega del bien (la exigencia de la contraprestación, en los servicios). Este paquete toma la fecha de la factura cuando existe; una entrega o un pago anteriores a la factura adelantan el hecho generador, y el formato no tiene una palabra para «el primero de tres actos» — véase el README',
  tax_point_source_key          = 'ley-822',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ley No. 822, art. 123 — toda devolución de bienes gravados debe estar soportada con la documentación contable que fije el Reglamento, y el responsable recaudador reduce su crédito o su débito fiscal en el período en que se hace la devolución. Un documento contabilizado en Ekwo se corrige con una nota de crédito que lo nombra, nunca volviendo a borrador',
  posted_edit_policy_source_key = 'ley-822',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_obligation           = 'none',
  einvoice_legal_reference      = 'A la fecha de este paquete ninguna norma obliga a las empresas nicaragüenses a intercambiar facturas electrónicas. La factura en Nicaragua es un documento impreso con pie de imprenta fiscal, de una imprenta autorizada por la DGI, o el que emite un sistema de facturación computarizado autorizado por la DGI conforme a la Disposición Técnica No. 09-2007 (La Gaceta No. 134 del 16 de julio de 2007, al amparo del Código Tributario, arts. 81 y 126, numeral 4): una autorización de uso de un sistema, que no es un formato estructurado ni un régimen de validación previa. La DGI declara en su Plan Estratégico Institucional 2022-2026 que desarrollará un sistema de facturación electrónica, y un proyecto de factura electrónica con financiamiento del Banco Interamericano de Desarrollo se anunció en 2016: un proyecto anunciado y no legislado no cambia la palabra `none`. Este paquete no pudo leer la web de la DGI (su servidor rechaza las consultas automatizadas) y no encontró en ninguna fuente abierta una resolución que imponga la facturación electrónica; hay que reverificarlo antes de confiar en él. Nicaragua tampoco publica un código ISO 6523 para su Registro Único de Contribuyentes (RUC): party_scheme y vat_scheme quedan vacíos',
  einvoice_source_key           = 'dt-09-2007',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_account_scheme           = 'account-number',
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'NI';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('NI', 'dgi_invoice_not_authorized', 'always', 'Este documento no sustituye a la factura autorizada por la Dirección General de Ingresos (DGI): solo la factura impresa por una imprenta autorizada con pie de imprenta fiscal, o la emitida por un sistema de facturación computarizado autorizado por la DGI, sustenta la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Disposición Técnica No. 09-2007, numerales primero y segundo — el contribuyente puede facturar por medios electrónicos previa autorización de la DGI, y su sistema debe cumplir los requisitos de seguridad, respaldo, numeración y formalidades que la disposición enumera. Ekwo no tiene esa autorización por sí mismo: la tiene, en su caso, el sistema de la empresa — véase el README'),
  ('NI', 'export', 'export', 'Exportación gravada con la alícuota del cero por ciento (0%) del Impuesto al Valor Agregado (artículo 109 de la Ley No. 822).', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley No. 822, art. 109 — alícuota cero para las exportaciones de bienes de producción nacional y de servicios prestados al exterior'),
  ('NI', 'exempt', 'exempt', 'Operación exenta del traslado del Impuesto al Valor Agregado (artículos 111, 127 y 136 de la Ley No. 822).', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley No. 822, arts. 111, 127 y 136 — sujetos, bienes y servicios exentos del traslado del IVA')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
