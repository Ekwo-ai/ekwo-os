-- Ekwo OS — Costa Rica: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/cr at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build cr`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley del Impuesto sobre el Valor Agregado (Ley N.° 6826 del 8 de noviembre de 1982), texto integralmente reformado por la Ley N.° 9635 de Fortalecimiento de las Finanzas Públicas del 3 de diciembre de 2018, vigente a partir del 1 de julio de 2019 (Sistema Costarricense de Información Jurídica (SCIJ) — Procuraduría General de la República)
--     https://pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?param1=NRTC&nValor1=1&nValor2=87720&nValor3=125773&strTipM=TC
--   Reglamento a la Ley del Impuesto sobre el Valor Agregado (Decreto Ejecutivo N.° 41779-H del 3 de junio de 2019 y sus reformas) (Sistema Costarricense de Información Jurídica (SCIJ) — Poder Ejecutivo, Ministerio de Hacienda)
--     https://pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?param1=NRTC&nValor1=1&nValor2=88953&nValor3=116520&strTipM=TC
--   Código de Comercio (Ley N.° 3284 del 30 de abril de 1964), Capítulo V del Título I — De la Contabilidad y de la Correspondencia, y Capítulo VIII de las sociedades anónimas (Sistema Costarricense de Información Jurídica (SCIJ) — Procuraduría General de la República)
--     https://pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?param1=NRTC&nValor1=1&nValor2=6239&nValor3=6635&strTipM=TC
--   Resolución N.° MH-DGT-RES-0033-2025, "Formularios y medio para la presentación de declaraciones del Impuesto al Valor Agregado", publicada en el Alcance N.° 113 a La Gaceta N.° 163 del 2 de setiembre de 2025, vigente desde el 6 de octubre de 2025 (Ministerio de Hacienda — Dirección General de Tributación, Imprenta Nacional (Diario Oficial La Gaceta))
--     https://www.imprentanacional.go.cr/pub/2025/09/02/ALCA113_02_09_2025.pdf
--   Reglamento de Comprobantes Electrónicos para Efectos Tributarios (Decreto Ejecutivo N.° 44739-H, publicado en La Gaceta el 8 de noviembre de 2024) (Ministerio de Hacienda — Dirección General de Tributación)
--     https://www.hacienda.go.cr/docs/REGLAMENTO_DE_COMPROBANTES_ELECTRONICOS.pdf
--   Resolución General MH-DGT-RES-0027-2024 sobre las disposiciones técnicas de los comprobantes electrónicos para efectos tributarios (Anexos y Estructuras versión 4.4), publicada el 19 de noviembre de 2024, obligatoria desde el 1 de setiembre de 2025 (Ministerio de Hacienda — Dirección General de Tributación)
--     https://www.hacienda.go.cr/docs/Resolucion_General_sobre_disposiciones_tecnicas_comprobantes_electronicos_para.pdf
--   TRIBU-CR — sistema integrado de administración tributaria, plataforma única de presentación de declaraciones desde el 6 de octubre de 2025 (Ministerio de Hacienda)
--     https://www.hacienda.go.cr/TRIBU-CR.html
--   Normas de Información Financiera aplicables en Costa Rica: NIIF completas y NIIF para las PYMES, adoptadas por Acuerdo N.° 324-2002 y actualizadas por circulares del Colegio (Colegio de Contadores Públicos de Costa Rica (CCPA))
--     https://ccpa.or.cr/niif-para-las-pymes/
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('CR', 'Costa Rica', '0.1.0', date '2026-09-26', '20260921084143', 'community', null, null, 'e47124d43648deb7aed09b74d89cdd2da7ebbcd247f3c3440e4a6ee59f5af766', '[{"key":"liva","title":"Ley del Impuesto sobre el Valor Agregado (Ley N.° 6826 del 8 de noviembre de 1982), texto integralmente reformado por la Ley N.° 9635 de Fortalecimiento de las Finanzas Públicas del 3 de diciembre de 2018, vigente a partir del 1 de julio de 2019","publisher":"Sistema Costarricense de Información Jurídica (SCIJ) — Procuraduría General de la República","url":"https://pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?param1=NRTC&nValor1=1&nValor2=87720&nValor3=125773&strTipM=TC","consulted_on":"2026-09-26","kind":"law"},{"key":"rliva","title":"Reglamento a la Ley del Impuesto sobre el Valor Agregado (Decreto Ejecutivo N.° 41779-H del 3 de junio de 2019 y sus reformas)","publisher":"Sistema Costarricense de Información Jurídica (SCIJ) — Poder Ejecutivo, Ministerio de Hacienda","url":"https://pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?param1=NRTC&nValor1=1&nValor2=88953&nValor3=116520&strTipM=TC","consulted_on":"2026-09-26","kind":"regulation"},{"key":"ccom","title":"Código de Comercio (Ley N.° 3284 del 30 de abril de 1964), Capítulo V del Título I — De la Contabilidad y de la Correspondencia, y Capítulo VIII de las sociedades anónimas","publisher":"Sistema Costarricense de Información Jurídica (SCIJ) — Procuraduría General de la República","url":"https://pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?param1=NRTC&nValor1=1&nValor2=6239&nValor3=6635&strTipM=TC","consulted_on":"2026-09-26","kind":"law"},{"key":"res0033-2025","title":"Resolución N.° MH-DGT-RES-0033-2025, \"Formularios y medio para la presentación de declaraciones del Impuesto al Valor Agregado\", publicada en el Alcance N.° 113 a La Gaceta N.° 163 del 2 de setiembre de 2025, vigente desde el 6 de octubre de 2025","publisher":"Ministerio de Hacienda — Dirección General de Tributación, Imprenta Nacional (Diario Oficial La Gaceta)","url":"https://www.imprentanacional.go.cr/pub/2025/09/02/ALCA113_02_09_2025.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"reg-comprobantes","title":"Reglamento de Comprobantes Electrónicos para Efectos Tributarios (Decreto Ejecutivo N.° 44739-H, publicado en La Gaceta el 8 de noviembre de 2024)","publisher":"Ministerio de Hacienda — Dirección General de Tributación","url":"https://www.hacienda.go.cr/docs/REGLAMENTO_DE_COMPROBANTES_ELECTRONICOS.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"res0027-2024","title":"Resolución General MH-DGT-RES-0027-2024 sobre las disposiciones técnicas de los comprobantes electrónicos para efectos tributarios (Anexos y Estructuras versión 4.4), publicada el 19 de noviembre de 2024, obligatoria desde el 1 de setiembre de 2025","publisher":"Ministerio de Hacienda — Dirección General de Tributación","url":"https://www.hacienda.go.cr/docs/Resolucion_General_sobre_disposiciones_tecnicas_comprobantes_electronicos_para.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"tribucr","title":"TRIBU-CR — sistema integrado de administración tributaria, plataforma única de presentación de declaraciones desde el 6 de octubre de 2025","publisher":"Ministerio de Hacienda","url":"https://www.hacienda.go.cr/TRIBU-CR.html","consulted_on":"2026-09-26","kind":"portal"},{"key":"ccpa-niif","title":"Normas de Información Financiera aplicables en Costa Rica: NIIF completas y NIIF para las PYMES, adoptadas por Acuerdo N.° 324-2002 y actualizadas por circulares del Colegio","publisher":"Colegio de Contadores Públicos de Costa Rica (CCPA)","url":"https://ccpa.or.cr/niif-para-las-pymes/","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('CR', 'default', 'Plan de cuentas de referencia sobre el contenido mínimo del Código de Comercio y las NIIF para las PYMES', '{}'::jsonb, true, 'companies', array['CR-CCOM-ER', 'CR-CCOM-ESF']::text[], null, 'Costa Rica no impone un plan de cuentas único ni numerado. El Código de Comercio, art. 251, exige llevar los registros contables y financieros "en medios que permitan conocer, de forma fácil, clara y precisa, de sus operaciones comerciales y su situación económica", sin que deban legalizarse; el art. 258 fija en cambio el contenido mínimo de los estados que se asientan cada cierre de ejercicio en el libro de Balances: Balance de Comprobación, Estado de Ganancias y Pérdidas, Balance General de Situación y, en las sociedades, Estado de superávit o aplicación de sobrantes. El Colegio de Contadores Públicos de Costa Rica (CCPA), como ente profesional y no estatal, adoptó las Normas Internacionales de Información Financiera y las NIIF para las PYMES como marco de preparación (Acuerdo N.° 324-2002 y circulares posteriores), pero ese marco no numera cuentas — cada entidad define su propio catálogo. Este plan es original: sigue una numeración propia de tres a cinco dígitos, y cada grupo de códigos corresponde a una línea de CR-CCOM-ESF o de CR-CCOM-ER, de modo que las cuentas de este paquete se leen directamente sobre esos dos esquemas. El texto de las NIIF pertenece al IASB y el de su adopción al CCPA; ninguno de los dos se transcribe aquí — ver README.md', 'ccom')
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
  ('CR', 'default', '100', 'Activo', '{}'::jsonb, 'asset_current', false, null, 10),
  ('CR', 'default', '110', 'Activo corriente', '{}'::jsonb, 'asset_current', false, '100', 20),
  ('CR', 'default', '111', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 'asset_cash', false, '110', 30),
  ('CR', 'default', '1111', 'Caja general', '{}'::jsonb, 'asset_cash', false, '111', 40),
  ('CR', 'default', '1112', 'Bancos - cuenta corriente colones', '{}'::jsonb, 'asset_cash', false, '111', 50),
  ('CR', 'default', '1113', 'Bancos - cuenta corriente moneda extranjera', '{}'::jsonb, 'asset_cash', false, '111', 60),
  ('CR', 'default', '112', 'Inversiones corrientes', '{}'::jsonb, 'asset_current', false, '110', 70),
  ('CR', 'default', '113', 'Cuentas por cobrar comerciales', '{}'::jsonb, 'asset_receivable', true, '110', 80),
  ('CR', 'default', '1131', 'Clientes nacionales', '{}'::jsonb, 'asset_receivable', true, '113', 90),
  ('CR', 'default', '1132', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '113', 100),
  ('CR', 'default', '1133', 'Documentos por cobrar', '{}'::jsonb, 'asset_current', false, '113', 110),
  ('CR', 'default', '1134', 'Estimación para incobrables', '{}'::jsonb, 'asset_current', false, '113', 120),
  ('CR', 'default', '114', 'Otras cuentas por cobrar', '{}'::jsonb, 'asset_current', false, '110', 130),
  ('CR', 'default', '1141', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '114', 140),
  ('CR', 'default', '1142', 'Gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '114', 150),
  ('CR', 'default', '1143', 'Anticipo de impuesto sobre la renta', '{}'::jsonb, 'asset_current', false, '114', 160),
  ('CR', 'default', '1144', 'Préstamos al personal', '{}'::jsonb, 'asset_current', false, '114', 170),
  ('CR', 'default', '1145', 'Depósitos en garantía', '{}'::jsonb, 'asset_current', false, '114', 180),
  ('CR', 'default', '115', 'Créditos fiscales de IVA', '{}'::jsonb, 'asset_current', false, '110', 190),
  ('CR', 'default', '1151', 'IVA crédito fiscal - tarifa general 13%', '{}'::jsonb, 'asset_current', false, '115', 200),
  ('CR', 'default', '1152', 'IVA crédito fiscal - tarifa reducida 4%', '{}'::jsonb, 'asset_current', false, '115', 210),
  ('CR', 'default', '1153', 'IVA crédito fiscal - tarifa reducida 2%', '{}'::jsonb, 'asset_current', false, '115', 220),
  ('CR', 'default', '1154', 'IVA crédito fiscal - tarifa reducida 1%', '{}'::jsonb, 'asset_current', false, '115', 230),
  ('CR', 'default', '1155', 'IVA saldo a favor', '{}'::jsonb, 'asset_current', true, '115', 240),
  ('CR', 'default', '116', 'Inventarios', '{}'::jsonb, 'asset_current', false, '110', 250),
  ('CR', 'default', '1161', 'Mercancías para la venta', '{}'::jsonb, 'asset_current', false, '116', 260),
  ('CR', 'default', '1162', 'Materias primas', '{}'::jsonb, 'asset_current', false, '116', 270),
  ('CR', 'default', '1163', 'Productos en proceso', '{}'::jsonb, 'asset_current', false, '116', 280),
  ('CR', 'default', '1164', 'Productos terminados', '{}'::jsonb, 'asset_current', false, '116', 290),
  ('CR', 'default', '117', 'Partidas pendientes de imputación', '{}'::jsonb, 'asset_current', false, '110', 300),
  ('CR', 'default', '120', 'Activo no corriente', '{}'::jsonb, 'asset_non_current', false, '100', 310),
  ('CR', 'default', '121', 'Créditos no corrientes', '{}'::jsonb, 'asset_non_current', false, '120', 320),
  ('CR', 'default', '122', 'Propiedad, planta y equipo', '{}'::jsonb, 'asset_fixed', false, '120', 330),
  ('CR', 'default', '1221', 'Propiedad, planta y equipo - Valor de origen', '{}'::jsonb, 'asset_fixed', false, '122', 340),
  ('CR', 'default', '12211', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '1221', 350),
  ('CR', 'default', '12212', 'Edificios', '{}'::jsonb, 'asset_fixed', false, '1221', 360),
  ('CR', 'default', '12213', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '1221', 370),
  ('CR', 'default', '12214', 'Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1221', 380),
  ('CR', 'default', '12215', 'Vehículos', '{}'::jsonb, 'asset_fixed', false, '1221', 390),
  ('CR', 'default', '12216', 'Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '1221', 400),
  ('CR', 'default', '1222', 'Propiedad, planta y equipo - Depreciación acumulada', '{}'::jsonb, 'asset_fixed', false, '122', 410),
  ('CR', 'default', '12221', 'Depreciación acumulada - Edificios', '{}'::jsonb, 'asset_fixed', false, '1222', 420),
  ('CR', 'default', '12222', 'Depreciación acumulada - Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '1222', 430),
  ('CR', 'default', '12223', 'Depreciación acumulada - Mobiliario y equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1222', 440),
  ('CR', 'default', '12224', 'Depreciación acumulada - Vehículos', '{}'::jsonb, 'asset_fixed', false, '1222', 450),
  ('CR', 'default', '12225', 'Depreciación acumulada - Equipo de cómputo', '{}'::jsonb, 'asset_fixed', false, '1222', 460),
  ('CR', 'default', '123', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '120', 470),
  ('CR', 'default', '1231', 'Software', '{}'::jsonb, 'asset_non_current', false, '123', 480),
  ('CR', 'default', '1232', 'Amortización acumulada de software', '{}'::jsonb, 'asset_non_current', false, '123', 490),
  ('CR', 'default', '1233', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '123', 500),
  ('CR', 'default', '200', 'Pasivo', '{}'::jsonb, 'liability_current', false, null, 510),
  ('CR', 'default', '210', 'Pasivo corriente', '{}'::jsonb, 'liability_current', false, '200', 520),
  ('CR', 'default', '211', 'Cuentas por pagar comerciales', '{}'::jsonb, 'liability_payable', true, '210', 530),
  ('CR', 'default', '2111', 'Proveedores nacionales', '{}'::jsonb, 'liability_payable', true, '211', 540),
  ('CR', 'default', '2112', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '211', 550),
  ('CR', 'default', '2113', 'Documentos por pagar', '{}'::jsonb, 'liability_current', false, '211', 560),
  ('CR', 'default', '212', 'Remuneraciones y cargas sociales por pagar', '{}'::jsonb, 'liability_current', false, '210', 570),
  ('CR', 'default', '2121', 'Salarios por pagar', '{}'::jsonb, 'liability_current', false, '212', 580),
  ('CR', 'default', '2122', 'Cargas sociales por pagar - CCSS', '{}'::jsonb, 'liability_current', false, '212', 590),
  ('CR', 'default', '2123', 'Provisión de aguinaldo', '{}'::jsonb, 'liability_current', false, '212', 600),
  ('CR', 'default', '2124', 'Provisión de vacaciones', '{}'::jsonb, 'liability_current', false, '212', 610),
  ('CR', 'default', '2125', 'Provisión de cesantía', '{}'::jsonb, 'liability_current', false, '212', 620),
  ('CR', 'default', '213', 'Cargas fiscales por pagar', '{}'::jsonb, 'liability_current', false, '210', 630),
  ('CR', 'default', '2131', 'IVA débito fiscal - tarifa general 13%', '{}'::jsonb, 'liability_current', false, '213', 640),
  ('CR', 'default', '2132', 'IVA débito fiscal - tarifa reducida 4%', '{}'::jsonb, 'liability_current', false, '213', 650),
  ('CR', 'default', '2133', 'IVA débito fiscal - tarifa reducida 2%', '{}'::jsonb, 'liability_current', false, '213', 660),
  ('CR', 'default', '2134', 'IVA débito fiscal - tarifa reducida 1%', '{}'::jsonb, 'liability_current', false, '213', 670),
  ('CR', 'default', '2135', 'IVA por pagar', '{}'::jsonb, 'liability_current', true, '213', 680),
  ('CR', 'default', '2136', 'Impuesto sobre la renta por pagar', '{}'::jsonb, 'liability_current', false, '213', 690),
  ('CR', 'default', '2137', 'Retenciones por pagar', '{}'::jsonb, 'liability_current', false, '213', 700),
  ('CR', 'default', '214', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '210', 710),
  ('CR', 'default', '215', 'Provisiones y otros pasivos corrientes', '{}'::jsonb, 'liability_current', false, '210', 720),
  ('CR', 'default', '220', 'Pasivo no corriente', '{}'::jsonb, 'liability_non_current', false, '200', 730),
  ('CR', 'default', '221', 'Préstamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 740),
  ('CR', 'default', '222', 'Otras deudas a largo plazo', '{}'::jsonb, 'liability_non_current', false, '220', 750),
  ('CR', 'default', '2221', 'Deudas con socios y accionistas', '{}'::jsonb, 'liability_non_current', false, '222', 760),
  ('CR', 'default', '2222', 'Depósitos de terceros en garantía', '{}'::jsonb, 'liability_non_current', false, '222', 770),
  ('CR', 'default', '300', 'Patrimonio', '{}'::jsonb, 'equity', false, null, 780),
  ('CR', 'default', '31', 'Capital social', '{}'::jsonb, 'equity', false, '300', 790),
  ('CR', 'default', '32', 'Reserva legal', '{}'::jsonb, 'equity', false, '300', 800),
  ('CR', 'default', '33', 'Otras reservas de patrimonio', '{}'::jsonb, 'equity', false, '300', 810),
  ('CR', 'default', '34', 'Resultados acumulados de ejercicios anteriores', '{}'::jsonb, 'equity_retained', false, '300', 820),
  ('CR', 'default', '341', 'Utilidades acumuladas', '{}'::jsonb, 'equity_retained', false, '34', 830),
  ('CR', 'default', '342', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '34', 840),
  ('CR', 'default', '35', 'Resultado del periodo', '{}'::jsonb, 'equity', false, '300', 850),
  ('CR', 'default', '351', 'Resultado del periodo - Ganancia', '{}'::jsonb, 'equity', false, '35', 860),
  ('CR', 'default', '352', 'Resultado del periodo - Pérdida', '{}'::jsonb, 'equity', false, '35', 870),
  ('CR', 'default', '400', 'Ingresos', '{}'::jsonb, 'income', false, null, 880),
  ('CR', 'default', '41', 'Ventas', '{}'::jsonb, 'income', false, '400', 890),
  ('CR', 'default', '411', 'Ventas de mercancías - mercado nacional', '{}'::jsonb, 'income', false, '41', 900),
  ('CR', 'default', '412', 'Ventas de exportación', '{}'::jsonb, 'income', false, '41', 910),
  ('CR', 'default', '413', 'Ventas de servicios', '{}'::jsonb, 'income', false, '41', 920),
  ('CR', 'default', '46', 'Ingresos financieros y otros ingresos', '{}'::jsonb, 'income_other', false, '400', 930),
  ('CR', 'default', '461', 'Intereses ganados', '{}'::jsonb, 'income_other', false, '46', 940),
  ('CR', 'default', '462', 'Diferencial cambiario - ganancia', '{}'::jsonb, 'income_other', false, '46', 950),
  ('CR', 'default', '463', 'Descuentos obtenidos', '{}'::jsonb, 'income_other', false, '46', 960),
  ('CR', 'default', '48', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '400', 970),
  ('CR', 'default', '500', 'Costos y gastos', '{}'::jsonb, 'expense', false, null, 980),
  ('CR', 'default', '51', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '500', 990),
  ('CR', 'default', '511', 'Compras de mercancías', '{}'::jsonb, 'expense_direct_cost', false, '51', 1000),
  ('CR', 'default', '52', 'Gastos de venta', '{}'::jsonb, 'expense', false, '500', 1010),
  ('CR', 'default', '521', 'Publicidad y mercadeo', '{}'::jsonb, 'expense', false, '52', 1020),
  ('CR', 'default', '522', 'Comisiones sobre ventas', '{}'::jsonb, 'expense', false, '52', 1030),
  ('CR', 'default', '523', 'Fletes sobre ventas', '{}'::jsonb, 'expense', false, '52', 1040),
  ('CR', 'default', '53', 'Gastos de administración', '{}'::jsonb, 'expense', false, '500', 1050),
  ('CR', 'default', '531', 'Salarios y cargas sociales', '{}'::jsonb, 'expense', false, '53', 1060),
  ('CR', 'default', '5311', 'Salarios', '{}'::jsonb, 'expense', false, '531', 1070),
  ('CR', 'default', '5312', 'Cargas sociales patronales - CCSS', '{}'::jsonb, 'expense', false, '531', 1080),
  ('CR', 'default', '5313', 'Aguinaldo y vacaciones', '{}'::jsonb, 'expense', false, '531', 1090),
  ('CR', 'default', '532', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '53', 1100),
  ('CR', 'default', '533', 'Gastos generales de administración', '{}'::jsonb, 'expense', false, '53', 1110),
  ('CR', 'default', '5331', 'Alquileres', '{}'::jsonb, 'expense', false, '533', 1120),
  ('CR', 'default', '5332', 'Servicios públicos', '{}'::jsonb, 'expense', false, '533', 1130),
  ('CR', 'default', '5333', 'Papelería y útiles de oficina', '{}'::jsonb, 'expense', false, '533', 1140),
  ('CR', 'default', '5334', 'Mantenimiento', '{}'::jsonb, 'expense', false, '533', 1150),
  ('CR', 'default', '5335', 'Seguros', '{}'::jsonb, 'expense', false, '533', 1160),
  ('CR', 'default', '5336', 'Impuestos, tasas y timbres', '{}'::jsonb, 'expense', false, '533', 1170),
  ('CR', 'default', '534', 'Depreciación y amortización', '{}'::jsonb, 'expense_depreciation', false, '53', 1180),
  ('CR', 'default', '56', 'Gastos financieros y otros gastos', '{}'::jsonb, 'expense', false, '500', 1190),
  ('CR', 'default', '561', 'Intereses pagados', '{}'::jsonb, 'expense', false, '56', 1200),
  ('CR', 'default', '562', 'Diferencial cambiario - pérdida', '{}'::jsonb, 'expense', false, '56', 1210),
  ('CR', 'default', '563', 'Redondeo', '{}'::jsonb, 'expense', false, '56', 1220),
  ('CR', 'default', '564', 'Descuentos concedidos', '{}'::jsonb, 'expense', false, '56', 1230),
  ('CR', 'default', '565', 'Gastos e intereses bancarios', '{}'::jsonb, 'expense', false, '56', 1240),
  ('CR', 'default', '57', 'Impuesto sobre la renta', '{}'::jsonb, 'expense', false, '500', 1250),
  ('CR', 'default', '58', 'Otros gastos', '{}'::jsonb, 'expense', false, '500', 1260)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('CR', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('CR', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('CR', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('CR', 'COM', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('CR', 'DIA', 'Asientos de diario', '{}'::jsonb, 'general', 50),
  ('CR', 'VEN', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('CR', 'CR-P-13', 'Compras a la tarifa general', '{}'::jsonb, 'Adquisición de bienes y servicios gravados a la tarifa general, destinados a operaciones sujetas y no exentas', 'percent', 13, 'purchase', 'domestic', date '2019-07-01', null, 'Ley del IVA, art. 25 — el impuesto se determina por la diferencia entre el débito y el crédito fiscal del período; Reglamento, art. 30, numeral 1 — como regla general, solo da derecho a crédito fiscal el impuesto soportado en bienes y servicios destinados a operaciones sujetas y no exentas', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rliva', null, null, null, null),
  ('CR', 'CR-P-2', 'Compras de medicamentos para la reventa', '{}'::jsonb, 'Adquisición de medicamentos gravados a la tarifa reducida del dos por ciento, para su reventa gravada', 'percent', 2, 'purchase', 'domestic', date '2019-07-01', null, 'Ley del IVA, art. 11, numeral 2, inciso a), y art. 25; Reglamento, art. 30, numeral 1 — el impuesto facturado en la compra de medicamentos gravados a tarifa reducida es descontable para quien los revende gravados a esa misma tarifa', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rliva', null, null, null, null),
  ('CR', 'CR-P-EXE', 'Compras de bienes y servicios exentos', '{}'::jsonb, 'Adquisición de bienes y servicios exentos del impuesto, sin derecho a crédito fiscal', 'percent', 0, 'purchase', 'exempt', date '2019-07-01', null, 'Ley del IVA, art. 8, y Reglamento, art. 30, numeral 1 — la compra de un bien o servicio exento no soporta impuesto, y aun cuando lo soportara por error del proveedor, no daría derecho a crédito fiscal al no estar destinada a una operación gravada; el formulario de declaración reúne estas compras en la casilla "Bienes y servicios exentos" de la sección de compras sin IVA soportado o no acreditable', null, null, 90, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'res0033-2025', null, null, null, null),
  ('CR', 'CR-S-1', 'Canasta Básica Tributaria', '{}'::jsonb, 'Venta de artículos incluidos en la Lista de la Canasta Básica Tributaria, a la tarifa reducida del uno por ciento', 'percent', 1, 'sale', 'domestic', date '2019-07-01', null, 'Ley del IVA, art. 11, numeral 3, inciso a) — tarifa reducida del uno por ciento (1%) para los artículos de la Canasta Básica Tributaria; Reglamento, art. 23, numeral 3, inciso a) — la lista se fija por decreto ejecutivo conjunto del Ministerio de Hacienda y el Ministerio de Economía, Industria y Comercio', null, null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('CR', 'CR-S-13', 'Ventas y servicios a la tarifa general', '{}'::jsonb, 'Venta de bienes y prestación de servicios en el territorio nacional a la tarifa general del Impuesto sobre el Valor Agregado', 'percent', 13, 'sale', 'domestic', date '2019-07-01', null, 'Ley del Impuesto al Valor Agregado, art. 10 — la tarifa general del impuesto es del trece por ciento (13%); Reglamento, art. 22 — reitera esa tarifa general', null, null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('CR', 'CR-S-2', 'Medicamentos', '{}'::jsonb, 'Venta de medicamentos incluidos en la lista que fija resolución general del Ministerio de Hacienda, a la tarifa reducida del dos por ciento', 'percent', 2, 'sale', 'domestic', date '2019-07-01', null, 'Ley del IVA, art. 11, numeral 2, inciso a) — tarifa reducida del dos por ciento (2%) para los medicamentos; Reglamento, art. 23, numeral 2, inciso a) — el Ministerio de Hacienda establece mediante resolución general la lista de medicamentos sujetos a esta tarifa reducida', null, null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('CR', 'CR-S-4', 'Servicios de salud humana privados', '{}'::jsonb, 'Servicios personales de salud humana prestados por centros de salud o profesionales en ciencias de la salud debidamente autorizados, a la tarifa reducida del cuatro por ciento', 'percent', 4, 'sale', 'domestic', date '2019-07-01', null, 'Ley del IVA, art. 11, numeral 1, inciso b) — tarifa reducida del cuatro por ciento (4%) para los servicios de salud humana privados; Reglamento, art. 23, numeral 1, inciso b) — precisa qué se consideran servicios de salud humana privados, incluidos los de laboratorios clínicos privados', null, null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null),
  ('CR', 'CR-S-EXE', 'Bienes exentos — libros', '{}'::jsonb, 'Venta local de libros, con independencia de su formato, exenta sin derecho a crédito fiscal', 'percent', 0, 'sale', 'exempt', date '2019-07-01', null, 'Ley del IVA, art. 8 — bienes exentos del impuesto; Reglamento, art. 11, numeral 4, inciso b) — están exentos los libros, con independencia de su formato, exención que no alcanza a los medios electrónicos que permiten el acceso y la lectura de libros en soporte diferente del papel. A diferencia de la exportación, el libro no figura entre las excepciones de crédito pleno del numeral 2 del artículo 30 del Reglamento, por lo que la regla general del numeral 1 de ese artículo se aplica: no da derecho a crédito fiscal', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'rliva', null, null, null, null),
  ('CR', 'CR-S-EXP', 'Exportación de bienes', '{}'::jsonb, 'Exportación de bienes, exenta con derecho a crédito fiscal pleno', 'percent', 0, 'sale', 'export', date '2019-07-01', null, 'Ley del IVA, art. 8, numeral 1, inciso a) — están exentas del impuesto las exportaciones de bienes; Reglamento, art. 30, numeral 2, inciso c) — las exportaciones y las operaciones relacionadas con ellas dan derecho a crédito fiscal pleno, por excepción a la regla general del numeral 1 de ese mismo artículo. En el formulario de declaración se declaran junto con las demás ventas exentas con derecho a crédito pleno del artículo 30 del Reglamento', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'liva', null, null, null, null)
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
    ('CR-P-13', 'invoice', 'base', 100, null, 'CB13', array['CB13']::text[], 100, 'CR-IVA', 10),
    ('CR-P-13', 'invoice', 'tax', 100, '1151', 'CF13', array['CF13']::text[], 100, 'CR-IVA', 20),
    ('CR-P-13', 'credit_note', 'base', 100, null, 'CB13', array['CB13']::text[], -100, 'CR-IVA', 10),
    ('CR-P-13', 'credit_note', 'tax', 100, '1151', 'CF13', array['CF13']::text[], -100, 'CR-IVA', 20),
    ('CR-P-2', 'invoice', 'base', 100, null, 'CB2', array['CB2']::text[], 100, 'CR-IVA', 10),
    ('CR-P-2', 'invoice', 'tax', 100, '1153', 'CF2', array['CF2']::text[], 100, 'CR-IVA', 20),
    ('CR-P-2', 'credit_note', 'base', 100, null, 'CB2', array['CB2']::text[], -100, 'CR-IVA', 10),
    ('CR-P-2', 'credit_note', 'tax', 100, '1153', 'CF2', array['CF2']::text[], -100, 'CR-IVA', 20),
    ('CR-P-EXE', 'invoice', 'base', 100, null, 'CBEXE', array['CBEXE']::text[], 100, 'CR-IVA', 10),
    ('CR-P-EXE', 'credit_note', 'base', 100, null, 'CBEXE', array['CBEXE']::text[], -100, 'CR-IVA', 10),
    ('CR-S-1', 'invoice', 'base', 100, null, 'V1', array['V1']::text[], 100, 'CR-IVA', 10),
    ('CR-S-1', 'invoice', 'tax', 100, '2134', 'T1', array['T1']::text[], 100, 'CR-IVA', 20),
    ('CR-S-1', 'credit_note', 'base', 100, null, 'V1', array['V1']::text[], -100, 'CR-IVA', 10),
    ('CR-S-1', 'credit_note', 'tax', 100, '2134', 'T1', array['T1']::text[], -100, 'CR-IVA', 20),
    ('CR-S-13', 'invoice', 'base', 100, null, 'V13', array['V13']::text[], 100, 'CR-IVA', 10),
    ('CR-S-13', 'invoice', 'tax', 100, '2131', 'T13', array['T13']::text[], 100, 'CR-IVA', 20),
    ('CR-S-13', 'credit_note', 'base', 100, null, 'V13', array['V13']::text[], -100, 'CR-IVA', 10),
    ('CR-S-13', 'credit_note', 'tax', 100, '2131', 'T13', array['T13']::text[], -100, 'CR-IVA', 20),
    ('CR-S-2', 'invoice', 'base', 100, null, 'V2', array['V2']::text[], 100, 'CR-IVA', 10),
    ('CR-S-2', 'invoice', 'tax', 100, '2133', 'T2', array['T2']::text[], 100, 'CR-IVA', 20),
    ('CR-S-2', 'credit_note', 'base', 100, null, 'V2', array['V2']::text[], -100, 'CR-IVA', 10),
    ('CR-S-2', 'credit_note', 'tax', 100, '2133', 'T2', array['T2']::text[], -100, 'CR-IVA', 20),
    ('CR-S-4', 'invoice', 'base', 100, null, 'V4', array['V4']::text[], 100, 'CR-IVA', 10),
    ('CR-S-4', 'invoice', 'tax', 100, '2132', 'T4', array['T4']::text[], 100, 'CR-IVA', 20),
    ('CR-S-4', 'credit_note', 'base', 100, null, 'V4', array['V4']::text[], -100, 'CR-IVA', 10),
    ('CR-S-4', 'credit_note', 'tax', 100, '2132', 'T4', array['T4']::text[], -100, 'CR-IVA', 20),
    ('CR-S-EXE', 'invoice', 'base', 100, null, 'VEXESC', array['VEXESC']::text[], 100, 'CR-IVA', 10),
    ('CR-S-EXE', 'credit_note', 'base', 100, null, 'VEXESC', array['VEXESC']::text[], -100, 'CR-IVA', 10),
    ('CR-S-EXP', 'invoice', 'base', 100, null, 'VEXECP', array['VEXECP']::text[], 100, 'CR-IVA', 10),
    ('CR-S-EXP', 'credit_note', 'base', 100, null, 'VEXECP', array['VEXECP']::text[], -100, 'CR-IVA', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'CR' and t.code = v.tax_code
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
  ('CR', 'CR-IVA', 'Declaración del Impuesto al Valor Agregado — Régimen Tradicional', array['month']::declaration_period[], 'month'::declaration_period, date '1970-01-01', null, 'Reglamento a la Ley del IVA, art. 24 — el período del impuesto es de un mes calendario. Resolución MH-DGT-RES-0033-2025, Anexo 1 — formulario denominado "Impuesto al Valor Agregado" para los contribuyentes inscritos en el Régimen Tradicional, presentado por el sistema TRIBU-CR. Este paquete declara los campos de las secciones I (Ventas y otras operaciones del período) y IV (Cálculo del impuesto) del Anexo 1 que sus impuestos alcanzan; no modela la sección II en su mecánica completa de proporcionalidad de créditos, los regímenes especiales de bienes usados o agropecuario, la actividad de casinos y juegos de azar, el pago diferido de ventas a crédito, la autorrepercusión del impuesto por servicios del exterior ni la devolución del IVA de servicios de salud pagados con tarjeta — ver README.md', true,'day_of_month_after_period'::filing_deadline_rule, 15, null, 'Resolución MH-DGT-RES-0033-2025, art. 4 — remite al artículo 27 de la Ley del Impuesto al Valor Agregado; Reglamento, art. 40 — la declaración jurada de las ventas de un mes debe presentarse a más tardar el decimoquinto día natural del mes siguiente al que se refiere', 'rliva', null)
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
  ('CR', 'CR-IVA', 'V13', 'base', 'Total ventas a 13%', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — monto de las ventas realizadas durante el período fiscal con tarifa del 13% del IVA', 'res0033-2025'),
  ('CR', 'CR-IVA', 'T13', 'tax', 'Monto de impuesto a 13%', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — resultado de multiplicar el valor de la casilla "Total ventas a 13%" por 13%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'V4', 'base', 'Total ventas a 4%', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — monto de las ventas realizadas durante el período fiscal con tarifa del 4% del IVA', 'res0033-2025'),
  ('CR', 'CR-IVA', 'T4', 'tax', 'Monto de impuesto a 4%', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — resultado de multiplicar el valor de la casilla "Total ventas a 4%" por 4%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'V2', 'base', 'Total ventas a 2%', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — monto de las ventas realizadas durante el período fiscal con tarifa del 2% del IVA', 'res0033-2025'),
  ('CR', 'CR-IVA', 'T2', 'tax', 'Monto de impuesto a 2%', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — resultado de multiplicar el valor de la casilla "Total ventas a 2%" por 2%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'V1', 'base', 'Total ventas a 1%', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — monto de las ventas realizadas durante el período fiscal con tarifa del 1% del IVA', 'res0033-2025'),
  ('CR', 'CR-IVA', 'T1', 'tax', 'Monto de impuesto a 1%', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — resultado de multiplicar el valor de la casilla "Total ventas a 1%" por 1%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'VEXECP', 'base', 'Total ventas exentas con derecho a crédito pleno', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — monto de las ventas exentas, exoneradas o no sujetas realizadas durante el período que dan derecho a crédito fiscal pleno de acuerdo con el artículo 30 del Reglamento a la Ley del IVA, entre ellas las exportaciones', 'res0033-2025'),
  ('CR', 'CR-IVA', 'VEXESC', 'base', 'Total ventas exentas sin derecho a crédito', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — monto de las ventas exentas, exoneradas o no sujetas realizadas durante el período que no dan derecho a crédito fiscal de acuerdo con el artículo 30 del Reglamento a la Ley del IVA', 'res0033-2025'),
  ('CR', 'CR-IVA', 'VGRAV', 'total', 'Total ventas gravadas', '{}'::jsonb, 110, null, array['V13', 'V4', 'V2', 'V1']::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — suma de las casillas de ventas gravadas a cada tarifa; este paquete solo declara las tarifas del 13%, 4%, 2% y 1% vigentes', 'res0033-2025'),
  ('CR', 'CR-IVA', 'VGEN', 'total', 'Total ventas generales', '{}'::jsonb, 120, null, array['VGRAV', 'VEXECP', 'VEXESC']::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — suma de las casillas de ventas gravadas y de ventas exentas, exoneradas o no sujetas, con y sin derecho a crédito pleno', 'res0033-2025'),
  ('CR', 'CR-IVA', 'DEBITO', 'total', 'Monto del impuesto ventas generales', '{}'::jsonb, 130, null, array['T13', 'T4', 'T2', 'T1']::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección I — suma de las casillas "Monto de impuesto a 13%", "Monto de impuesto a 4%", "Monto de impuesto a 2%" y "Monto de impuesto a 1%", que constituye el débito del período', 'res0033-2025'),
  ('CR', 'CR-IVA', 'CB13', 'base', 'Total importe compras a 13%', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección II — importe de las compras del período gravadas a la tarifa del 13%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'CF13', 'tax', 'Impuesto soportado a 13%', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección II — impuesto soportado en las compras del período a la tarifa del 13%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'CB2', 'base', 'Total importe compras a 2%', '{}'::jsonb, 160, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección II — importe de las compras del período gravadas a la tarifa del 2%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'CF2', 'tax', 'Impuesto soportado a 2%', '{}'::jsonb, 170, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección II — impuesto soportado en las compras del período a la tarifa del 2%', 'res0033-2025'),
  ('CR', 'CR-IVA', 'CBEXE', 'base', 'Bienes y servicios exentos', '{}'::jsonb, 180, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección II, "Compras sin IVA soportado o no acreditable" — importe de los bienes y servicios exentos adquiridos durante el período', 'res0033-2025'),
  ('CR', 'CR-IVA', 'CFTOTAL', 'total', 'Total crédito fiscal del periodo', '{}'::jsonb, 190, null, array['CF13', 'CF2']::text[], '{}'::text[], null, null, false, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección II — suma del impuesto soportado en las compras que dan derecho a crédito fiscal; este paquete no aplica la regla de proporcionalidad del artículo 34 del Reglamento, por lo que solo es exacto para un contribuyente cuyas ventas son en su totalidad gravadas o exentas con derecho a crédito pleno', 'res0033-2025'),
  ('CR', 'CR-IVA', 'IMPDET', 'total', 'Impuesto determinado', '{}'::jsonb, 200, null, array['DEBITO']::text[], array['CFTOTAL']::text[], null, null, true, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección IV — resultado de restar del "Total monto del impuesto" el "Total crédito fiscal para el IVA"; si el resultado es negativo se completa la casilla "Saldo a favor" y no esta', 'res0033-2025'),
  ('CR', 'CR-IVA', 'SAFAVOR', 'total', 'Saldo a favor', '{}'::jsonb, 210, null, array['CFTOTAL']::text[], array['DEBITO']::text[], null, null, true, false, null, 'Resolución MH-DGT-RES-0033-2025, Anexo 1, sección IV — cuando el crédito fiscal supera el débito del período, la diferencia se declara en esta casilla y no en "Impuesto determinado"', 'res0033-2025')
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
  ('CR-CCOM-ER', 'CR', 'default', 'Estado de Ganancias y Pérdidas', 'income_statement', 'CR-CCOM', date '1970-01-01', null, 'Código de Comercio, art. 258, inciso b) — cada cierre de ejercicio fiscal se asienta en el libro de Balances el Estado de Ganancias y Pérdidas', 'ccom'),
  ('CR-CCOM-ESF', 'CR', 'default', 'Balance General de Situación', 'balance_sheet', 'CR-CCOM', date '1970-01-01', null, 'Código de Comercio, art. 258 — cada cierre de ejercicio fiscal se asienta en el libro de Balances, entre otros, el Balance General de Situación posterior al cierre, distinguiendo el activo del pasivo y del patrimonio. Este esquema es una estructura mínima sobre esos rubros; la presentación completa de acuerdo con las NIIF o las NIIF para las PYMES es la que adopta el Colegio de Contadores Públicos de Costa Rica, cuyo texto pertenece al IASB y al Colegio y no se transcribe aquí — ver README.md', 'ccom')
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
  ('CR-CCOM-ER', 'VEN', null, 'Ventas netas', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'CV', null, 'Costo de ventas', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'RB', null, 'Utilidad bruta', '{}'::jsonb, 30, 1, true, array['VEN']::text[], array['CV']::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'GV', null, 'Gastos de venta', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'GA', null, 'Gastos de administración', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'RO', null, 'Utilidad de operación', '{}'::jsonb, 60, 1, true, array['RB']::text[], array['GV', 'GA']::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'IFO', null, 'Ingresos financieros y otros ingresos', '{}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'OTRI', null, 'Otros ingresos', '{}'::jsonb, 80, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'GFO', null, 'Gastos financieros y otros gastos', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'OTRE', null, 'Otros gastos', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'UAI', null, 'Utilidad antes de impuesto sobre la renta', '{}'::jsonb, 110, 1, true, array['RO', 'IFO', 'OTRI']::text[], array['GFO', 'OTRE']::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ER', 'ISR', null, 'Impuesto sobre la renta', '{}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Ley del Impuesto sobre la Renta — no modelada por este paquete; la cuenta existe para que el estado de resultados la presente cuando la empresa la liquide manualmente. Ver README.md', 'ccom'),
  ('CR-CCOM-ER', 'UN', null, 'Utilidad neta del periodo', '{}'::jsonb, 130, 1, true, array['UAI']::text[], array['ISR']::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CB', null, 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'INV', null, 'Inversiones corrientes', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CXC', null, 'Cuentas por cobrar comerciales', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'OCR', null, 'Otras cuentas por cobrar', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CFI', null, 'Créditos fiscales de IVA', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Ley del IVA, art. 25 — el crédito fiscal computable y el saldo a favor del contribuyente', 'liva'),
  ('CR-CCOM-ESF', 'INVT', null, 'Inventarios', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PPI', null, 'Partidas pendientes de imputación', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de uso interno, sin correspondencia en un rubro propio del Código de Comercio', 'ccom'),
  ('CR-CCOM-ESF', 'AC', null, 'Total del activo corriente', '{}'::jsonb, 80, 1, true, array['CB', 'INV', 'CXC', 'OCR', 'CFI', 'INVT', 'PPI']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CNC', null, 'Créditos no corrientes', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PPE', null, 'Propiedad, planta y equipo', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'AIN', null, 'Activos intangibles', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'ANC', null, 'Total del activo no corriente', '{}'::jsonb, 120, 1, true, array['CNC', 'PPE', 'AIN']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'ACT', null, 'Total del activo', '{}'::jsonb, 130, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CPC', null, 'Cuentas por pagar comerciales', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'REM', null, 'Remuneraciones y cargas sociales por pagar', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CFP', null, 'Cargas fiscales por pagar', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Ley del IVA, art. 25 — el impuesto a pagar de un período en que el débito fiscal supera al crédito fiscal', 'liva'),
  ('CR-CCOM-ESF', 'ANT', null, 'Anticipos de clientes', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PRO', null, 'Provisiones y otros pasivos corrientes', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PC', null, 'Total del pasivo corriente', '{}'::jsonb, 190, 1, true, array['CPC', 'REM', 'CFP', 'ANT', 'PRO']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PBL', null, 'Préstamos bancarios a largo plazo', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'ODL', null, 'Otras deudas a largo plazo', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PNC', null, 'Total del pasivo no corriente', '{}'::jsonb, 220, 1, true, array['PBL', 'ODL']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'PAS', null, 'Total del pasivo', '{}'::jsonb, 230, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'CAP', null, 'Capital social', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'RES', null, 'Reservas de patrimonio', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'RAA', null, 'Resultados acumulados de ejercicios anteriores', '{}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom'),
  ('CR-CCOM-ESF', 'RDP', null, 'Resultado del periodo', '{}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 258, inciso d) — el Estado de superávit o aplicación de sobrantes recoge el resultado del ejercicio hasta su aplicación', 'ccom'),
  ('CR-CCOM-ESF', 'PAT', null, 'Total del patrimonio', '{}'::jsonb, 280, 1, true, array['CAP', 'RES', 'RAA', 'RDP']::text[], '{}'::text[], null, 'Código de Comercio, art. 258', 'ccom')
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
    ('CR-CCOM-ER', 'VEN', 10, 'code_prefix', '41', null, null, 'any'),
    ('CR-CCOM-ER', 'CV', 10, 'code_prefix', '51', null, null, 'any'),
    ('CR-CCOM-ER', 'GV', 10, 'code_prefix', '52', null, null, 'any'),
    ('CR-CCOM-ER', 'GA', 10, 'code_prefix', '53', null, null, 'any'),
    ('CR-CCOM-ER', 'IFO', 10, 'code_prefix', '46', null, null, 'any'),
    ('CR-CCOM-ER', 'OTRI', 10, 'code_prefix', '48', null, null, 'any'),
    ('CR-CCOM-ER', 'GFO', 10, 'code_prefix', '56', null, null, 'any'),
    ('CR-CCOM-ER', 'OTRE', 10, 'code_prefix', '58', null, null, 'any'),
    ('CR-CCOM-ER', 'ISR', 10, 'code_prefix', '57', null, null, 'any'),
    ('CR-CCOM-ESF', 'CB', 10, 'code_prefix', '111', null, null, 'any'),
    ('CR-CCOM-ESF', 'INV', 10, 'code_prefix', '112', null, null, 'any'),
    ('CR-CCOM-ESF', 'CXC', 10, 'code_prefix', '113', null, null, 'any'),
    ('CR-CCOM-ESF', 'OCR', 10, 'code_prefix', '114', null, null, 'any'),
    ('CR-CCOM-ESF', 'CFI', 10, 'code_prefix', '115', null, null, 'any'),
    ('CR-CCOM-ESF', 'INVT', 10, 'code_prefix', '116', null, null, 'any'),
    ('CR-CCOM-ESF', 'PPI', 10, 'code_prefix', '117', null, null, 'any'),
    ('CR-CCOM-ESF', 'CNC', 10, 'code_prefix', '121', null, null, 'any'),
    ('CR-CCOM-ESF', 'PPE', 10, 'code_prefix', '122', null, null, 'any'),
    ('CR-CCOM-ESF', 'AIN', 10, 'code_prefix', '123', null, null, 'any'),
    ('CR-CCOM-ESF', 'CPC', 10, 'code_prefix', '211', null, null, 'any'),
    ('CR-CCOM-ESF', 'REM', 10, 'code_prefix', '212', null, null, 'any'),
    ('CR-CCOM-ESF', 'CFP', 10, 'code_prefix', '213', null, null, 'any'),
    ('CR-CCOM-ESF', 'ANT', 10, 'code_prefix', '214', null, null, 'any'),
    ('CR-CCOM-ESF', 'PRO', 10, 'code_prefix', '215', null, null, 'any'),
    ('CR-CCOM-ESF', 'PBL', 10, 'code_prefix', '221', null, null, 'any'),
    ('CR-CCOM-ESF', 'ODL', 10, 'code_prefix', '222', null, null, 'any'),
    ('CR-CCOM-ESF', 'CAP', 10, 'code_prefix', '31', null, null, 'any'),
    ('CR-CCOM-ESF', 'RES', 10, 'code_prefix', '32', null, null, 'any'),
    ('CR-CCOM-ESF', 'RES', 20, 'code_prefix', '33', null, null, 'any'),
    ('CR-CCOM-ESF', 'RAA', 10, 'code_prefix', '34', null, null, 'any'),
    ('CR-CCOM-ESF', 'RDP', 10, 'code_prefix', '35', null, null, 'any')
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
  ('CR', 'Costa Rica', '{}'::jsonb, array['es']::text[], 'CRC', '1131', '2111', '117', '563', '341', '411', '511', '1112', '1111', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', 'half_up', default, '462', '562', null, null, null, null, '2135', '1155', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Reglamento de Comprobantes Electrónicos para Efectos Tributarios (Decreto 44739-H) — todo comprobante fiscal se identifica por la clave numérica de cincuenta dígitos que asigna la estructura del documento electrónico, validada por el sistema de Hacienda al momento de su recepción; no es un número que el emisor elija libremente. El número que declara este paquete es el de la pieza contable — correlativo por diario — y no la clave numérica del comprobante electrónico, que Ekwo no calcula ni asigna: ver la sección de facturación electrónica de este README',
  numbering_source_key          = 'reg-comprobantes',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Reglamento a la Ley del IVA, art. 4 — en la venta de bienes el impuesto se devenga "en el momento de la emisión del comprobante electrónico autorizado o la entrega del bien, el acto que se realice primero"; art. 6 — en la prestación de servicios, "al momento de la emisión del comprobante electrónico o de la prestación del servicio, lo que se configure primero". La entrega o la prestación es el principio y el comprobante electrónico — obligatorio para prácticamente todo contribuyente desde la versión 4.4 — lo desplaza cuando se emite antes, de ahí invoice_if_issued en el sentido del vocabulario de este formato',
  tax_point_source_key          = 'rliva',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Reglamento a la Ley del IVA, art. 15, numeral 2 — un descuento posterior a la emisión del comprobante se reconoce "por medio de una nota de crédito electrónica debidamente autorizada por la Administración Tributaria", declarada en el período en que se emite dicha nota; el Reglamento de Comprobantes Electrónicos exige la misma vía — una nota de crédito o de débito electrónica que referencia el comprobante original — para toda corrección de un comprobante ya validado por el sistema de Hacienda. No existe un procedimiento para devolver a borrador un comprobante aceptado',
  posted_edit_policy_source_key = 'rliva',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Reglamento de Comprobantes Electrónicos para Efectos Tributarios (Decreto 44739-H) y Resolución General MH-DGT-RES-0027-2024 — todo obligado tributario que vende bienes o presta servicios debe emitir comprobante electrónico, en el formato de los Anexos y Estructuras del Comprobante Electrónico versión 4.4 (obligatoria desde el 1 de setiembre de 2025), y transmitirlo al sistema del Ministerio de Hacienda para su validación previa: el sistema recibe el XML firmado digitalmente, lo valida contra el esquema y las reglas de negocio publicadas, le asigna la clave numérica de cincuenta dígitos y devuelve un mensaje de aceptación, aceptación parcial o rechazo. Es un régimen de validación previa (clearance) — como el CFDI mexicano o la factura electrónica colombiana — y no un intercambio entre partes construido sobre el modelo semántico de EN 16931: no hay Peppol, no hay perfil semántico europeo. EKWO NO GENERA, NO FIRMA NI TRANSMITE COMPROBANTES ELECTRÓNICOS AL SISTEMA DE HACIENDA: ningún componente de packages/formats escribe el XML de la versión 4.4 ni dialoga con ese sistema; un documento emitido desde Ekwo registra la operación en la contabilidad y no es el comprobante fiscal. Por eso profile, mandatory_from, party_scheme y vat_scheme quedan vacíos aunque la obligación exista: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe (peppol-bis-3, factur-x-en16931, xrechnung, un PINT), y la versión 4.4 no es ninguno de ellos; el formato tampoco tiene una palabra para "válido solo tras la validación previa de un tercero" — ver docs/international.md. La cédula jurídica o física identifica al emisor y al receptor y no tiene un código ISO 6523 registrado: party_scheme y vat_scheme quedan vacíos por la misma razón que en los paquetes de México y Colombia',
  einvoice_source_key           = 'reg-comprobantes',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'CR';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('CR', 'clave_no_asignada', 'always', 'Este documento no es un comprobante electrónico: no lleva la clave numérica de cincuenta dígitos ni el mensaje de aceptación del sistema de Hacienda. Solo el comprobante electrónico validado ampara la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Reglamento de Comprobantes Electrónicos para Efectos Tributarios (Decreto 44739-H) y Resolución MH-DGT-RES-0027-2024 — todo comprobante debe transmitirse al sistema de Hacienda, que lo valida, le asigna la clave numérica y devuelve un mensaje de aceptación o rechazo, antes de poder entregarse al receptor. Ekwo no genera, no timbra ni transmite comprobantes electrónicos: ver la sección de facturación electrónica de este paquete'),
  ('CR', 'export', 'export', 'Exportación de bienes — exenta del Impuesto sobre el Valor Agregado con derecho a crédito fiscal pleno (artículo 8, numeral 1, de la Ley del IVA, y artículo 30, numeral 2, inciso c), de su Reglamento).', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley del IVA, art. 8, numeral 1, inciso a) — exención en las exportaciones de bienes; Reglamento, art. 30, numeral 2, inciso c) — las exportaciones dan derecho a crédito fiscal pleno por excepción a la regla general del numeral 1 del mismo artículo, que solo da crédito por operaciones gravadas y no exentas'),
  ('CR', 'exento', 'exempt', 'Bien o servicio exento del Impuesto sobre el Valor Agregado, sin derecho a crédito fiscal (artículo 8 de la Ley del IVA).', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley del IVA, art. 8 — bienes, servicios y operaciones exentos del impuesto; Reglamento, art. 30, numeral 1 — como regla general solo da derecho a crédito fiscal el impuesto soportado en la adquisición de bienes y servicios destinados a operaciones sujetas y no exentas, por lo que una venta exenta del artículo 8 que no figura entre las excepciones de crédito pleno del numeral 2 de ese mismo artículo no genera derecho a crédito')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
