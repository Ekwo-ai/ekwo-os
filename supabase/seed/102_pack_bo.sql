-- Ekwo OS — Bolivia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/bo at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build bo`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley N.° 843 (Texto Ordenado), Ley de Reforma Tributaria de 20 de mayo de 1986 — Título I (Impuesto al Valor Agregado, arts. 1° a 18°) y Título VI (Impuesto a las Transacciones, arts. 72° a 79°) (Servicio de Impuestos Nacionales (SIN) — Biblioteca Virtual)
--     https://sac.impuestos.gob.bo/formularios/pdf/1.-LEY%20N%C2%B0%20843-06-24.pdf
--   Decreto Supremo N.° 21530 de 27 de febrero de 1987, Reglamento del Impuesto al Valor Agregado, texto ordenado y concordado (LexiVox — Fundación Ciencia y Cultura, compilación de la Gaceta Oficial del Estado Plurinacional de Bolivia)
--     https://www.lexivox.org/norms/BO-DS-21530.html
--   Ley N.° 2492 de 2 de agosto de 2003, Código Tributario Boliviano, texto actualizado (Servicio de Impuestos Nacionales (SIN) — Legislación tributaria)
--     https://www.impuestos.gob.bo/wp-content/uploads/2025/10/2.-LEY-N%C2%B0-2492-09-25.pdf
--   Ley N.° 366 de 29 de abril de 2013, Ley del Libro y la Lectura "Óscar Alfaro", y su Reglamento (Decreto Supremo N.° 1768) (Servicio de Impuestos Nacionales (SIN) — Legislación tributaria)
--     https://www.impuestos.gob.bo/wp-content/uploads/2025/11/LEY366.pdf
--   Ley N.° 3249 de 1 de diciembre de 2005, tasa cero del IVA para el transporte internacional de carga por carretera (LexiVox — Fundación Ciencia y Cultura, compilación de la Gaceta Oficial del Estado Plurinacional de Bolivia)
--     https://www.lexivox.org/norms/BO-L-3249.html
--   Código de Comercio, Decreto Ley N.° 14379 de 25 de febrero de 1977 — Libro Primero, Título II (arts. 36°, 37° y 331°) (Organización de los Estados Americanos — Mecanismo de Seguimiento de la Convención Interamericana contra la Corrupción)
--     https://www.oas.org/juridico/spanish/mesicic3_blv_codcomer.pdf
--   Resolución CTNAC N.° 01/2012 del Consejo Técnico Nacional de Auditoría y Contabilidad, que ratifica las Normas de Contabilidad Generalmente Aceptadas en Bolivia y adopta las NIIF como marco supletorio (HLB Bolivia — reseña del marco normativo contable boliviano)
--     https://www.hlbbolivia.com/marco-normativo-para-la-preparacion-de-estados-financieros-de-proposito-general-en-bolivia/
--   Formulario 200 v.5 Extendido — Impuesto al Valor Agregado, Declaración Jurada mensual, e instructivo de llenado (Servicio de Impuestos Nacionales (SIN))
--     https://www.impuestos.gob.bo/wp-content/uploads/2025/10/200v5-extendido.pdf
--   Calendario Tributario 2026 (Servicio de Impuestos Nacionales (SIN))
--     https://www.impuestos.gob.bo/wp-content/uploads/2026/01/CALENDARIO-TRIBUTARIO-2026.pdf
--   Resolución Normativa de Directorio N.° 102100000011 de 11 de agosto de 2021, Sistema de Facturación, texto compilado con sus modificaciones (Servicio de Impuestos Nacionales (SIN))
--     https://www.impuestos.gob.bo/wp-content/uploads/2025/10/RND11.pdf
--   Oficina Virtual del Servicio de Impuestos Nacionales (Servicio de Impuestos Nacionales (SIN))
--     https://www.impuestos.gob.bo
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('BO', 'Bolivia', '0.1.0', date '2026-09-26', '20260921084143', 'community', null, null, 'b479cc318a123848d59ec458ae799e21f9318a5cb54dc03cbe3b17f87aefc7c1', '[{"key":"ley-843","title":"Ley N.° 843 (Texto Ordenado), Ley de Reforma Tributaria de 20 de mayo de 1986 — Título I (Impuesto al Valor Agregado, arts. 1° a 18°) y Título VI (Impuesto a las Transacciones, arts. 72° a 79°)","publisher":"Servicio de Impuestos Nacionales (SIN) — Biblioteca Virtual","url":"https://sac.impuestos.gob.bo/formularios/pdf/1.-LEY%20N%C2%B0%20843-06-24.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ds-21530","title":"Decreto Supremo N.° 21530 de 27 de febrero de 1987, Reglamento del Impuesto al Valor Agregado, texto ordenado y concordado","publisher":"LexiVox — Fundación Ciencia y Cultura, compilación de la Gaceta Oficial del Estado Plurinacional de Bolivia","url":"https://www.lexivox.org/norms/BO-DS-21530.html","consulted_on":"2026-09-26","kind":"regulation"},{"key":"ley-2492","title":"Ley N.° 2492 de 2 de agosto de 2003, Código Tributario Boliviano, texto actualizado","publisher":"Servicio de Impuestos Nacionales (SIN) — Legislación tributaria","url":"https://www.impuestos.gob.bo/wp-content/uploads/2025/10/2.-LEY-N%C2%B0-2492-09-25.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-366","title":"Ley N.° 366 de 29 de abril de 2013, Ley del Libro y la Lectura \"Óscar Alfaro\", y su Reglamento (Decreto Supremo N.° 1768)","publisher":"Servicio de Impuestos Nacionales (SIN) — Legislación tributaria","url":"https://www.impuestos.gob.bo/wp-content/uploads/2025/11/LEY366.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley-3249","title":"Ley N.° 3249 de 1 de diciembre de 2005, tasa cero del IVA para el transporte internacional de carga por carretera","publisher":"LexiVox — Fundación Ciencia y Cultura, compilación de la Gaceta Oficial del Estado Plurinacional de Bolivia","url":"https://www.lexivox.org/norms/BO-L-3249.html","consulted_on":"2026-09-26","kind":"law"},{"key":"codigo-comercio","title":"Código de Comercio, Decreto Ley N.° 14379 de 25 de febrero de 1977 — Libro Primero, Título II (arts. 36°, 37° y 331°)","publisher":"Organización de los Estados Americanos — Mecanismo de Seguimiento de la Convención Interamericana contra la Corrupción","url":"https://www.oas.org/juridico/spanish/mesicic3_blv_codcomer.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ctnac-01-2012","title":"Resolución CTNAC N.° 01/2012 del Consejo Técnico Nacional de Auditoría y Contabilidad, que ratifica las Normas de Contabilidad Generalmente Aceptadas en Bolivia y adopta las NIIF como marco supletorio","publisher":"HLB Bolivia — reseña del marco normativo contable boliviano","url":"https://www.hlbbolivia.com/marco-normativo-para-la-preparacion-de-estados-financieros-de-proposito-general-en-bolivia/","consulted_on":"2026-09-26","kind":"guidance"},{"key":"formulario-200","title":"Formulario 200 v.5 Extendido — Impuesto al Valor Agregado, Declaración Jurada mensual, e instructivo de llenado","publisher":"Servicio de Impuestos Nacionales (SIN)","url":"https://www.impuestos.gob.bo/wp-content/uploads/2025/10/200v5-extendido.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"calendario-2026","title":"Calendario Tributario 2026","publisher":"Servicio de Impuestos Nacionales (SIN)","url":"https://www.impuestos.gob.bo/wp-content/uploads/2026/01/CALENDARIO-TRIBUTARIO-2026.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"rnd-facturacion","title":"Resolución Normativa de Directorio N.° 102100000011 de 11 de agosto de 2021, Sistema de Facturación, texto compilado con sus modificaciones","publisher":"Servicio de Impuestos Nacionales (SIN)","url":"https://www.impuestos.gob.bo/wp-content/uploads/2025/10/RND11.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"oficina-virtual","title":"Oficina Virtual del Servicio de Impuestos Nacionales","publisher":"Servicio de Impuestos Nacionales (SIN)","url":"https://www.impuestos.gob.bo","consulted_on":"2026-09-26","kind":"portal"}]'::jsonb)
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
  ('BO', 'default', 'Plan de cuentas de referencia sobre los arts. 36°, 37° y 331° del Código de Comercio y las Normas de Contabilidad', '{"en":"Chart of accounts (this pack''s own convention, over the Código de Comercio and the Normas de Contabilidad)"}'::jsonb, true, 'companies', array['BO-EF-BG', 'BO-EF-ER']::text[], null, 'Bolivia no impone un plan de cuentas único ni numerado: el Código de Comercio (Decreto Ley N.° 14379), art. 36°, exige sólo que todo comerciante lleve una contabilidad "adecuada a la naturaleza, importancia y organización de la empresa" sobre una base uniforme, y el art. 37° enumera los libros indispensables — Diario, Mayor, de Inventario y Balances — sin prescribir cuentas. El art. 331° exige que la memoria anual de una sociedad anónima contenga el balance general y el estado de resultados del ejercicio. El marco técnico es el de las Normas de Contabilidad Generalmente Aceptadas que emite el Consejo Técnico Nacional de Auditoría y Contabilidad (CTNAC) del Colegio de Auditores o Contadores Públicos de Bolivia, con las NIIF como marco supletorio desde la Resolución CTNAC N.° 01/2012; ninguna de las dos prescribe cuentas de detalle. Este plan es por tanto original: sigue una numeración propia de hasta cinco dígitos en la que el primer dígito es Activo (1), Pasivo (2), Patrimonio (3), Ingresos (4) o Costos y Gastos (5), y cada bloque de tres dígitos corresponde a una línea de BO-EF-BG o de BO-EF-ER — véase el README', 'codigo-comercio')
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
  ('BO', 'default', '100', 'Activo', '{"en":"Assets"}'::jsonb, 'asset_current', false, null, 10),
  ('BO', 'default', '110', 'Activo corriente', '{"en":"Current assets"}'::jsonb, 'asset_current', false, '100', 20),
  ('BO', 'default', '111', 'Caja y bancos moneda nacional', '{"en":"Cash and banks, local currency"}'::jsonb, 'asset_cash', false, '110', 30),
  ('BO', 'default', '1111', 'Caja moneda nacional', '{"en":"Cash on hand, local currency"}'::jsonb, 'asset_cash', false, '111', 40),
  ('BO', 'default', '1112', 'Bancos moneda nacional', '{"en":"Banks, local currency"}'::jsonb, 'asset_cash', false, '111', 50),
  ('BO', 'default', '1113', 'Caja moneda extranjera', '{"en":"Cash on hand, foreign currency"}'::jsonb, 'asset_cash', false, '111', 60),
  ('BO', 'default', '1114', 'Bancos moneda extranjera', '{"en":"Banks, foreign currency"}'::jsonb, 'asset_cash', false, '111', 70),
  ('BO', 'default', '112', 'Inversiones corrientes', '{"en":"Current investments"}'::jsonb, 'asset_current', false, '110', 80),
  ('BO', 'default', '113', 'Cuentas por cobrar comerciales', '{"en":"Trade receivables"}'::jsonb, 'asset_receivable', true, '110', 90),
  ('BO', 'default', '1131', 'Deudores por ventas - mercado interno', '{"en":"Trade debtors - domestic market"}'::jsonb, 'asset_receivable', true, '113', 100),
  ('BO', 'default', '1132', 'Deudores por ventas - exportación', '{"en":"Trade debtors - export"}'::jsonb, 'asset_receivable', true, '113', 110),
  ('BO', 'default', '1133', 'Documentos por cobrar', '{"en":"Notes receivable"}'::jsonb, 'asset_receivable', true, '113', 120),
  ('BO', 'default', '1134', 'Previsión para incobrables', '{"en":"Allowance for doubtful accounts"}'::jsonb, 'asset_current', false, '113', 130),
  ('BO', 'default', '114', 'Otros créditos', '{"en":"Other receivables"}'::jsonb, 'asset_current', false, '110', 140),
  ('BO', 'default', '1141', 'Anticipo a proveedores', '{"en":"Advances to suppliers"}'::jsonb, 'asset_current', false, '114', 150),
  ('BO', 'default', '1142', 'Gastos pagados por anticipado', '{"en":"Prepaid expenses"}'::jsonb, 'asset_prepayments', false, '114', 160),
  ('BO', 'default', '1143', 'Anticipo del Impuesto sobre las Utilidades de las Empresas (IUE)', '{"en":"Advance payment of the Corporate Income Tax (IUE)"}'::jsonb, 'asset_current', false, '114', 170),
  ('BO', 'default', '1144', 'Préstamos a empresas relacionadas', '{"en":"Loans to related companies"}'::jsonb, 'asset_current', false, '114', 180),
  ('BO', 'default', '1145', 'Créditos con socios', '{"en":"Receivables from shareholders"}'::jsonb, 'asset_current', false, '114', 190),
  ('BO', 'default', '1146', 'Depósitos en garantía otorgados', '{"en":"Security deposits given"}'::jsonb, 'asset_current', false, '114', 200),
  ('BO', 'default', '115', 'Créditos fiscales', '{"en":"Tax receivables"}'::jsonb, 'asset_current', false, '110', 210),
  ('BO', 'default', '1151', 'IVA Crédito Fiscal', '{"en":"VAT input tax"}'::jsonb, 'asset_current', false, '115', 220),
  ('BO', 'default', '1152', 'IVA Saldo a Favor del Contribuyente', '{"en":"VAT credit balance due to the taxpayer"}'::jsonb, 'asset_current', true, '115', 230),
  ('BO', 'default', '116', 'Existencias', '{"en":"Inventories"}'::jsonb, 'asset_current', false, '110', 240),
  ('BO', 'default', '1161', 'Materias primas', '{"en":"Raw materials"}'::jsonb, 'asset_current', false, '116', 250),
  ('BO', 'default', '1162', 'Productos en proceso', '{"en":"Work in progress"}'::jsonb, 'asset_current', false, '116', 260),
  ('BO', 'default', '1163', 'Productos terminados', '{"en":"Finished goods"}'::jsonb, 'asset_current', false, '116', 270),
  ('BO', 'default', '1164', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, '116', 280),
  ('BO', 'default', '1165', 'Envases y embalajes', '{"en":"Containers and packaging"}'::jsonb, 'asset_current', false, '116', 290),
  ('BO', 'default', '117', 'Partidas pendientes de imputación', '{"en":"Suspense items"}'::jsonb, 'asset_current', false, '110', 300),
  ('BO', 'default', '120', 'Activo no corriente', '{"en":"Non-current assets"}'::jsonb, 'asset_non_current', false, '100', 310),
  ('BO', 'default', '121', 'Créditos no corrientes', '{"en":"Non-current receivables"}'::jsonb, 'asset_non_current', false, '120', 320),
  ('BO', 'default', '122', 'Activo fijo', '{"en":"Fixed assets"}'::jsonb, 'asset_fixed', false, '120', 330),
  ('BO', 'default', '1221', 'Activo fijo - Valor de origen', '{"en":"Fixed assets - Cost"}'::jsonb, 'asset_fixed', false, '122', 340),
  ('BO', 'default', '12211', 'Terrenos', '{"en":"Land"}'::jsonb, 'asset_fixed', false, '1221', 350),
  ('BO', 'default', '12212', 'Edificios y construcciones', '{"en":"Buildings and construction"}'::jsonb, 'asset_fixed', false, '1221', 360),
  ('BO', 'default', '12213', 'Maquinaria y equipo', '{"en":"Machinery and equipment"}'::jsonb, 'asset_fixed', false, '1221', 370),
  ('BO', 'default', '12214', 'Muebles y enseres', '{"en":"Furniture and fixtures"}'::jsonb, 'asset_fixed', false, '1221', 380),
  ('BO', 'default', '12215', 'Vehículos', '{"en":"Vehicles"}'::jsonb, 'asset_fixed', false, '1221', 390),
  ('BO', 'default', '12216', 'Equipos de computación', '{"en":"Computer equipment"}'::jsonb, 'asset_fixed', false, '1221', 400),
  ('BO', 'default', '12217', 'Instalaciones', '{"en":"Installations"}'::jsonb, 'asset_fixed', false, '1221', 410),
  ('BO', 'default', '1222', 'Activo fijo - Depreciación acumulada', '{"en":"Fixed assets - Accumulated depreciation"}'::jsonb, 'asset_fixed', false, '122', 420),
  ('BO', 'default', '12221', 'Depreciación acumulada - Edificios y construcciones', '{"en":"Accumulated depreciation - Buildings and construction"}'::jsonb, 'asset_fixed', false, '1222', 430),
  ('BO', 'default', '12222', 'Depreciación acumulada - Maquinaria y equipo', '{"en":"Accumulated depreciation - Machinery and equipment"}'::jsonb, 'asset_fixed', false, '1222', 440),
  ('BO', 'default', '12223', 'Depreciación acumulada - Muebles y enseres', '{"en":"Accumulated depreciation - Furniture and fixtures"}'::jsonb, 'asset_fixed', false, '1222', 450),
  ('BO', 'default', '12224', 'Depreciación acumulada - Vehículos', '{"en":"Accumulated depreciation - Vehicles"}'::jsonb, 'asset_fixed', false, '1222', 460),
  ('BO', 'default', '12225', 'Depreciación acumulada - Equipos de computación', '{"en":"Accumulated depreciation - Computer equipment"}'::jsonb, 'asset_fixed', false, '1222', 470),
  ('BO', 'default', '12226', 'Depreciación acumulada - Instalaciones', '{"en":"Accumulated depreciation - Installations"}'::jsonb, 'asset_fixed', false, '1222', 480),
  ('BO', 'default', '123', 'Activos intangibles', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, '120', 490),
  ('BO', 'default', '1231', 'Marcas y patentes', '{"en":"Trademarks and patents"}'::jsonb, 'asset_non_current', false, '123', 500),
  ('BO', 'default', '1232', 'Programas y licencias informáticas', '{"en":"Software and licences"}'::jsonb, 'asset_non_current', false, '123', 510),
  ('BO', 'default', '1233', 'Derecho de llave', '{"en":"Goodwill"}'::jsonb, 'asset_non_current', false, '123', 520),
  ('BO', 'default', '200', 'Pasivo', '{"en":"Liabilities"}'::jsonb, 'liability_current', false, null, 530),
  ('BO', 'default', '210', 'Pasivo corriente', '{"en":"Current liabilities"}'::jsonb, 'liability_current', false, '200', 540),
  ('BO', 'default', '211', 'Cuentas por pagar comerciales', '{"en":"Trade payables"}'::jsonb, 'liability_payable', true, '210', 550),
  ('BO', 'default', '2111', 'Proveedores - mercado interno', '{"en":"Suppliers - domestic market"}'::jsonb, 'liability_payable', true, '211', 560),
  ('BO', 'default', '2112', 'Proveedores del exterior', '{"en":"Foreign suppliers"}'::jsonb, 'liability_payable', true, '211', 570),
  ('BO', 'default', '2113', 'Documentos por pagar', '{"en":"Notes payable"}'::jsonb, 'liability_payable', true, '211', 580),
  ('BO', 'default', '212', 'Sueldos y cargas sociales por pagar', '{"en":"Payroll and social charges payable"}'::jsonb, 'liability_current', false, '210', 590),
  ('BO', 'default', '2121', 'Sueldos por pagar', '{"en":"Salaries payable"}'::jsonb, 'liability_current', false, '212', 600),
  ('BO', 'default', '2122', 'Aportes laborales a las AFP por pagar', '{"en":"Employee pension fund (AFP) contributions payable"}'::jsonb, 'liability_current', false, '212', 610),
  ('BO', 'default', '2123', 'Aportes patronales a las AFP por pagar', '{"en":"Employer pension fund (AFP) contributions payable"}'::jsonb, 'liability_current', false, '212', 620),
  ('BO', 'default', '2124', 'Retenciones RC-IVA por pagar', '{"en":"RC-IVA withholdings payable"}'::jsonb, 'liability_current', false, '212', 630),
  ('BO', 'default', '2125', 'Provisión para aguinaldo', '{"en":"Christmas bonus (aguinaldo) provision"}'::jsonb, 'liability_current', false, '212', 640),
  ('BO', 'default', '2126', 'Provisión para prima', '{"en":"Profit-sharing bonus (prima) provision"}'::jsonb, 'liability_current', false, '212', 650),
  ('BO', 'default', '2127', 'Provisión para indemnización', '{"en":"Severance indemnity provision"}'::jsonb, 'liability_current', false, '212', 660),
  ('BO', 'default', '213', 'Cargas fiscales por pagar', '{"en":"Taxes payable"}'::jsonb, 'liability_current', false, '210', 670),
  ('BO', 'default', '2131', 'IVA Débito Fiscal', '{"en":"VAT output tax"}'::jsonb, 'liability_current', false, '213', 680),
  ('BO', 'default', '2132', 'IVA por Pagar', '{"en":"VAT payable"}'::jsonb, 'liability_current', true, '213', 690),
  ('BO', 'default', '2133', 'Impuesto sobre las Utilidades de las Empresas (IUE) por pagar', '{"en":"Corporate Income Tax (IUE) payable"}'::jsonb, 'liability_current', false, '213', 700),
  ('BO', 'default', '2134', 'Impuesto a las Transacciones (IT) por pagar', '{"en":"Transactions Tax (IT) payable"}'::jsonb, 'liability_current', false, '213', 710),
  ('BO', 'default', '214', 'Anticipos de clientes', '{"en":"Customer advances"}'::jsonb, 'liability_current', false, '210', 720),
  ('BO', 'default', '215', 'Provisiones', '{"en":"Provisions"}'::jsonb, 'liability_current', false, '210', 730),
  ('BO', 'default', '220', 'Pasivo no corriente', '{"en":"Non-current liabilities"}'::jsonb, 'liability_non_current', false, '200', 740),
  ('BO', 'default', '221', 'Deudas bancarias a largo plazo', '{"en":"Long-term bank debt"}'::jsonb, 'liability_non_current', false, '220', 750),
  ('BO', 'default', '222', 'Otras deudas no corrientes', '{"en":"Other non-current debt"}'::jsonb, 'liability_non_current', false, '220', 760),
  ('BO', 'default', '2221', 'Deudas con socios', '{"en":"Payables to shareholders"}'::jsonb, 'liability_non_current', false, '222', 770),
  ('BO', 'default', '2222', 'Deudas por arrendamiento financiero', '{"en":"Finance lease liabilities"}'::jsonb, 'liability_non_current', false, '222', 780),
  ('BO', 'default', '2223', 'Depósitos en garantía recibidos', '{"en":"Security deposits received"}'::jsonb, 'liability_non_current', false, '222', 790),
  ('BO', 'default', '300', 'Patrimonio', '{"en":"Equity"}'::jsonb, 'equity', false, null, 800),
  ('BO', 'default', '310', 'Capital social', '{"en":"Share capital"}'::jsonb, 'equity', false, '300', 810),
  ('BO', 'default', '320', 'Reserva legal', '{"en":"Legal reserve"}'::jsonb, 'equity', false, '300', 820),
  ('BO', 'default', '330', 'Ajuste de capital y otras reservas', '{"en":"Capital adjustment and other reserves"}'::jsonb, 'equity', false, '300', 830),
  ('BO', 'default', '340', 'Resultados acumulados', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, '300', 840),
  ('BO', 'default', '341', 'Resultados acumulados - Ganancias', '{"en":"Retained earnings - Profits"}'::jsonb, 'equity_retained', false, '340', 850),
  ('BO', 'default', '342', 'Resultados acumulados - Pérdidas', '{"en":"Retained earnings - Losses"}'::jsonb, 'equity_retained', false, '340', 860),
  ('BO', 'default', '350', 'Resultado del ejercicio', '{"en":"Result for the year"}'::jsonb, 'equity', false, '300', 870),
  ('BO', 'default', '351', 'Resultado del ejercicio - Ganancia', '{"en":"Result for the year - Profit"}'::jsonb, 'equity', false, '350', 880),
  ('BO', 'default', '352', 'Resultado del ejercicio - Pérdida', '{"en":"Result for the year - Loss"}'::jsonb, 'equity', false, '350', 890),
  ('BO', 'default', '400', 'Ingresos', '{"en":"Income"}'::jsonb, 'income', false, null, 900),
  ('BO', 'default', '410', 'Ventas', '{"en":"Sales"}'::jsonb, 'income', false, '400', 910),
  ('BO', 'default', '411', 'Ventas de mercaderías - mercado interno', '{"en":"Sales of goods - domestic market"}'::jsonb, 'income', false, '410', 920),
  ('BO', 'default', '412', 'Ventas de mercaderías - exportación', '{"en":"Sales of goods - export"}'::jsonb, 'income', false, '410', 930),
  ('BO', 'default', '413', 'Ventas de servicios', '{"en":"Sales of services"}'::jsonb, 'income', false, '410', 940),
  ('BO', 'default', '414', 'Ventas gravadas a tasa cero', '{"en":"Zero-rated sales"}'::jsonb, 'income', false, '410', 950),
  ('BO', 'default', '460', 'Resultados financieros y por tenencia positivos', '{"en":"Positive financial and holding results"}'::jsonb, 'income_other', false, '400', 960),
  ('BO', 'default', '461', 'Intereses ganados', '{"en":"Interest income"}'::jsonb, 'income_other', false, '460', 970),
  ('BO', 'default', '462', 'Diferencia de cambio positiva', '{"en":"Positive exchange difference"}'::jsonb, 'income_other', false, '460', 980),
  ('BO', 'default', '463', 'Descuentos obtenidos', '{"en":"Discounts received"}'::jsonb, 'income_other', false, '460', 990),
  ('BO', 'default', '480', 'Otros ingresos', '{"en":"Other income"}'::jsonb, 'income_other', false, '400', 1000),
  ('BO', 'default', '500', 'Costos y gastos', '{"en":"Costs and expenses"}'::jsonb, 'expense', false, null, 1010),
  ('BO', 'default', '510', 'Costo de ventas', '{"en":"Cost of sales"}'::jsonb, 'expense_direct_cost', false, '500', 1020),
  ('BO', 'default', '511', 'Compra de mercaderías', '{"en":"Purchase of merchandise"}'::jsonb, 'expense_direct_cost', false, '510', 1030),
  ('BO', 'default', '520', 'Gastos de comercialización', '{"en":"Selling expenses"}'::jsonb, 'expense', false, '500', 1040),
  ('BO', 'default', '521', 'Publicidad y propaganda', '{"en":"Advertising"}'::jsonb, 'expense', false, '520', 1050),
  ('BO', 'default', '522', 'Comisiones sobre ventas', '{"en":"Sales commissions"}'::jsonb, 'expense', false, '520', 1060),
  ('BO', 'default', '523', 'Fletes sobre ventas', '{"en":"Freight on sales"}'::jsonb, 'expense', false, '520', 1070),
  ('BO', 'default', '530', 'Gastos de administración', '{"en":"Administrative expenses"}'::jsonb, 'expense', false, '500', 1080),
  ('BO', 'default', '531', 'Sueldos y cargas sociales', '{"en":"Payroll and social charges"}'::jsonb, 'expense', false, '530', 1090),
  ('BO', 'default', '5311', 'Sueldos', '{"en":"Salaries"}'::jsonb, 'expense', false, '531', 1100),
  ('BO', 'default', '5312', 'Aportes patronales', '{"en":"Employer contributions"}'::jsonb, 'expense', false, '531', 1110),
  ('BO', 'default', '5313', 'Provisión para aguinaldo', '{"en":"Christmas bonus (aguinaldo) provision"}'::jsonb, 'expense', false, '531', 1120),
  ('BO', 'default', '5314', 'Provisión para prima e indemnización', '{"en":"Profit-sharing bonus and severance provision"}'::jsonb, 'expense', false, '531', 1130),
  ('BO', 'default', '532', 'Honorarios profesionales', '{"en":"Professional fees"}'::jsonb, 'expense', false, '530', 1140),
  ('BO', 'default', '533', 'Gastos generales de administración', '{"en":"General administrative expenses"}'::jsonb, 'expense', false, '530', 1150),
  ('BO', 'default', '5331', 'Alquileres', '{"en":"Rent"}'::jsonb, 'expense', false, '533', 1160),
  ('BO', 'default', '5332', 'Servicios básicos', '{"en":"Utilities"}'::jsonb, 'expense', false, '533', 1170),
  ('BO', 'default', '5333', 'Materiales de escritorio', '{"en":"Office supplies"}'::jsonb, 'expense', false, '533', 1180),
  ('BO', 'default', '5334', 'Mantenimiento y reparaciones', '{"en":"Maintenance and repairs"}'::jsonb, 'expense', false, '533', 1190),
  ('BO', 'default', '5335', 'Seguros', '{"en":"Insurance"}'::jsonb, 'expense', false, '533', 1200),
  ('BO', 'default', '5336', 'Patentes municipales e impuestos no recuperables', '{"en":"Municipal licence fees and non-recoverable taxes"}'::jsonb, 'expense', false, '533', 1210),
  ('BO', 'default', '534', 'Depreciación del activo fijo', '{"en":"Depreciation of fixed assets"}'::jsonb, 'expense_depreciation', false, '530', 1220),
  ('BO', 'default', '560', 'Resultados financieros y por tenencia negativos', '{"en":"Negative financial and holding results"}'::jsonb, 'expense', false, '500', 1230),
  ('BO', 'default', '561', 'Intereses pagados', '{"en":"Interest expense"}'::jsonb, 'expense', false, '560', 1240),
  ('BO', 'default', '562', 'Diferencia de cambio negativa', '{"en":"Negative exchange difference"}'::jsonb, 'expense', false, '560', 1250),
  ('BO', 'default', '563', 'Redondeo', '{"en":"Rounding"}'::jsonb, 'expense', false, '560', 1260),
  ('BO', 'default', '564', 'Descuentos otorgados', '{"en":"Discounts granted"}'::jsonb, 'expense', false, '560', 1270),
  ('BO', 'default', '565', 'Gastos e intereses bancarios', '{"en":"Bank charges and interest"}'::jsonb, 'expense', false, '560', 1280),
  ('BO', 'default', '570', 'Impuesto sobre las Utilidades de las Empresas (IUE) del ejercicio', '{"en":"Corporate Income Tax (IUE) for the year"}'::jsonb, 'expense', false, '500', 1290),
  ('BO', 'default', '580', 'Otros egresos', '{"en":"Other expenses"}'::jsonb, 'expense', false, '500', 1300)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('BO', 'APE', 'Asiento de apertura', '{"en":"Opening entry"}'::jsonb, 'opening', 60),
  ('BO', 'BAN', 'Bancos', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('BO', 'CAJ', 'Caja', '{"en":"Cash"}'::jsonb, 'cash', 40),
  ('BO', 'COM', 'Diario de compras', '{"en":"Purchase journal"}'::jsonb, 'purchase', 20),
  ('BO', 'DIA', 'Diario general', '{"en":"General journal"}'::jsonb, 'general', 50),
  ('BO', 'VEN', 'Diario de ventas', '{"en":"Sales journal"}'::jsonb, 'sales', 10)
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
  ('BO', 'BO-C-13', 'Compra gravada, 13 % (por dentro), con derecho a crédito fiscal', '{"en":"Taxable purchase, 13 % (tax-inclusive), with right to input tax credit"}'::jsonb, 'Compra, contratación o importación definitiva directamente vinculada a operaciones gravadas, a la exportación o a operaciones exentas con derecho a crédito', 'percent', 14.9425, 'purchase', 'domestic', date '1987-01-01', null, 'Ley N.° 843, art. 8° — el crédito fiscal computable es el impuesto que, en el período fiscal, se hubiera facturado al sujeto pasivo por compras, adquisiciones, contrataciones o importaciones definitivas, en la medida en que se vinculen con las operaciones gravadas; art. 5° — el impuesto forma parte integrante del precio facturado, sin mostrarse por separado. La misma tasa efectiva 14,9425 (13/87, redondeada) de BO-V-13 se aplica en compras porque el crédito fiscal se determina, igual que el débito, aplicando el 13 % sobre el importe total facturado por el proveedor (Formulario 200 v.5 Extendido, casilla 26 y su fórmula C26*13%), y no sobre un precio neto distinto del facturado. Decreto Supremo N.° 21530, art. 8° — requisitos formales del crédito fiscal (factura del proveedor con los requisitos del Sistema de Facturación, registro en el Libro de Compras IVA)', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'ley-843', null, null, null, null),
  ('BO', 'BO-C-13-NOCRED', 'Compra gravada, 13 % (por dentro), sin derecho a crédito fiscal', '{"en":"Taxable purchase, 13 % (tax-inclusive), no right to input tax credit"}'::jsonb, 'Compra gravada a la tasa general, destinada exclusivamente a una venta gravada a tasa cero sin derecho a crédito', 'percent', 14.9425, 'purchase', 'exempt', date '1987-01-01', null, 'Ley N.° 843, art. 8° — el crédito fiscal sólo es computable en la medida en que la compra se vincule con operaciones gravadas; una compra destinada exclusivamente a una venta gravada a tasa cero sin derecho a crédito (Ley N.° 366, art. 8°) no genera crédito fiscal y el impuesto facturado forma parte del costo de la adquisición. Formulario 200 v.5 Extendido, instructivo de la casilla 26 — «Excepto compras destinadas a actividades gravadas con tasa cero»: el formulario no lleva casilla propia para esta compra, que queda fuera de la determinación del crédito fiscal del período; véase el README', null, null, 120, 'vat', false, '{}'::tax_condition[], null, true, false, null, 'ley-843', null, null, null, null),
  ('BO', 'BO-V-13', 'Venta gravada, 13 % (por dentro)', '{"en":"Taxable sale, 13 % (tax-inclusive)"}'::jsonb, 'Venta de bienes muebles, contratos de obra o prestación de servicios en el mercado interno', 'percent', 14.9425, 'sale', 'domestic', date '1987-01-01', null, 'Ley N.° 843, art. 1° — objeto del impuesto: ventas de bienes muebles en el territorio nacional, contratos de obras y toda prestación de servicios; art. 5° — «el impuesto de este Título forma parte integrante del precio neto de la venta, el contrato de obra o de prestación de servicio y se facturará juntamente con éste, es decir, no se mostrará por separado»; art. 15° — «la alícuota general única del impuesto será del 13 % (TRECE POR CIENTO)». Como el 13 % legal se aplica sobre un precio que ya lo contiene, el impuesto equivale a 13/87 del precio neto de venta sin el impuesto — 14,942528…, redondeado a los cuatro decimales que admite este campo (14,9425) — y no a 13/100: sobre una venta facturada en 1.000,00 Bs, el débito fiscal es 130,00 Bs y no 113,27 Bs. El paquete declara price_include con esta tasa efectiva para que el motor, que separa la base del impuesto sobre el precio ya cargado con él, reproduzca exactamente ese resultado; véase «El IVA se calcula por dentro» en el README', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, true, false, null, 'ley-843', null, null, null, null),
  ('BO', 'BO-V-CERO', 'Venta gravada a tasa cero, sin derecho a crédito fiscal', '{"en":"Taxable sale at zero rate, no right to input tax credit"}'::jsonb, 'Venta de libros de producción nacional o importados, y otras operaciones sujetas a tasa cero por ley especial', 'percent', 0, 'sale', 'exempt', date '2013-04-29', null, 'Ley N.° 366, art. 8°, y su Reglamento (Decreto Supremo N.° 1768) — la venta de libros de producción nacional e importados, y de las publicaciones oficiales de las instituciones del Estado Plurinacional, en versión impresa, está sujeta a tasa cero del Impuesto al Valor Agregado. A diferencia de la exportación del art. 11° de la Ley N.° 843, esta tasa cero no da derecho a crédito fiscal: el contribuyente debe emitir la factura con la leyenda «TASA CERO - SIN DERECHO A CREDITO FISCAL, LEY N.° 366». Formulario 200 v.5 Extendido, casilla 15 — «Ventas gravadas a Tasa Cero (Venta de Libros Ley N.° 366, Transporte Internacional Ley N.° 3249 y otras establecidas por Ley)» — casilla distinta de la 14 precisamente porque las compras vinculadas a esta tasa cero quedan excluidas de la casilla 26 del crédito fiscal (instructivo del Formulario 200, fila 13). El transporte internacional de carga por carretera goza de la misma tasa cero y de la misma exclusión de crédito fiscal bajo la Ley N.° 3249, que este paquete no transcribe en un código separado por no llevar el paquete una actividad de transporte en su plan de cuentas', 'E', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ley-366', null, null, null, null),
  ('BO', 'BO-V-EXP', 'Exportación, liberada del débito fiscal', '{"en":"Export, relieved of output tax"}'::jsonb, 'Exportación de bienes y operaciones asimiladas a exportación', 'percent', 0, 'sale', 'export', date '1987-01-01', null, 'Ley N.° 843, art. 11° — «las exportaciones quedan liberadas del débito fiscal que les corresponda. Los exportadores podrán computar contra el impuesto que en definitiva adeudaren por sus operaciones gravadas en el mercado interno, el crédito fiscal correspondiente a las compras o insumos efectuados en el mercado interno con destino a operaciones de exportación […]»; el saldo no compensado da lugar a la devolución mediante Certificados de Devolución de Impuestos (CEDEIM), conforme el Decreto Supremo N.° 25465. Formulario 200 v.5 Extendido, casilla 14 — «Exportación de bienes y operaciones exentas»', 'G', null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ley-843', null, null, null, null)
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
    ('BO-C-13', 'invoice', 'base', 100, null, 'BASE26', array['BASE26']::text[], 100, 'BO-SIN-200', 10),
    ('BO-C-13', 'invoice', 'tax', 100, '1151', '114', array['114']::text[], 100, 'BO-SIN-200', 20),
    ('BO-C-13', 'credit_note', 'base', 100, null, 'BASE26', array['BASE26']::text[], -100, 'BO-SIN-200', 10),
    ('BO-C-13', 'credit_note', 'tax', 100, '1151', '114', array['114']::text[], -100, 'BO-SIN-200', 20),
    ('BO-C-13-NOCRED', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('BO-C-13-NOCRED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('BO-C-13-NOCRED', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('BO-C-13-NOCRED', 'credit_note', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('BO-V-13', 'invoice', 'base', 100, null, 'BASE13', array['BASE13']::text[], 100, 'BO-SIN-200', 10),
    ('BO-V-13', 'invoice', 'tax', 100, '2131', '39', array['39']::text[], 100, 'BO-SIN-200', 20),
    ('BO-V-13', 'credit_note', 'base', 100, null, 'BASE13', array['BASE13']::text[], -100, 'BO-SIN-200', 10),
    ('BO-V-13', 'credit_note', 'tax', 100, '2131', '39', array['39']::text[], -100, 'BO-SIN-200', 20),
    ('BO-V-CERO', 'invoice', 'base', 100, null, '15', array['15']::text[], 100, 'BO-SIN-200', 10),
    ('BO-V-CERO', 'credit_note', 'base', 100, null, '15', array['15']::text[], -100, 'BO-SIN-200', 10),
    ('BO-V-EXP', 'invoice', 'base', 100, null, '14', array['14']::text[], 100, 'BO-SIN-200', 10),
    ('BO-V-EXP', 'credit_note', 'base', 100, null, '14', array['14']::text[], -100, 'BO-SIN-200', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'BO' and t.code = v.tax_code
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
  ('BO', 'BO-SIN-200', 'Formulario 200 — Impuesto al Valor Agregado, Declaración Jurada mensual', array['month']::declaration_period[], 'month'::declaration_period, date '2026-01-01', null, 'Ley N.° 843, art. 7° y art. 10° — el impuesto resultante de cada período se determina mensualmente, restando del débito fiscal el crédito fiscal computable; Ley N.° 2492, art. 78° — la declaración jurada se presenta en la forma, medios, plazos y lugares que fije la Administración Tributaria. El Formulario 200 v.5 (Resumido y Extendido) es la declaración jurada mensual del IVA de uso obligatorio; las casillas de este paquete son las del Formulario 200 v.5 Extendido, que desagrega exportaciones, tasa cero y operaciones no gravadas — el Resumido reúne las tres en la sola casilla 13', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Ley N.° 2492, art. 78° — la Administración Tributaria fija en sus reglamentaciones la forma y el plazo de la declaración jurada; en la práctica el Servicio de Impuestos Nacionales escalona el vencimiento del IVA entre el día 13 y el día 22 del mes siguiente al período declarado, según el último dígito del Número de Identificación Tributaria (NIT) del contribuyente, en el calendario tributario que publica cada año. El día exacto depende del NIT de cada contribuyente y no de una regla que el paquete pueda calcular', 'calendario-2026', null)
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
  ('BO', 'BO-SIN-200', 'BASE13', 'base', 'Ventas gravadas en el mercado interno, netas del impuesto (uso interno del paquete)', '{"en":"Domestic taxable sales, net of tax (this pack''s own bookkeeping box)"}'::jsonb, 5, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'No es una casilla del Formulario 200: es el importe neto del impuesto que el motor separa de un precio facturado con el impuesto ya incluido (art. 5° de la Ley N.° 843). La casilla 13 del formulario, que pide el importe total facturado, se reconstruye como el total de esta casilla más el débito fiscal de la casilla 39 — véase «El IVA se calcula por dentro» en el README', 'ley-843'),
  ('BO', 'BO-SIN-200', '13', 'total', 'Ventas de bienes y/o servicios gravados en el mercado interno, excepto ventas gravadas con Tasa Cero', '{"en":"Sales of goods and/or services taxed in the domestic market, except sales at Zero Rate"}'::jsonb, 10, null, array['BASE13:base', '39:tax']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 1, casilla 13 — «Consignar el importe total por actividades gravadas […] que constituye el precio neto de venta, conforme establece el Artículo 5 de la Ley N.° 843». Como ese «precio neto» ya incluye el impuesto (art. 5°, Ley N.° 843), esta casilla es aquí la suma del importe neto (BASE13) y el débito fiscal (39) que el motor determinó sobre el mismo precio facturado', 'formulario-200'),
  ('BO', 'BO-SIN-200', '14', 'base', 'Exportación de bienes y operaciones exentas', '{"en":"Export of goods and exempt operations"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 2, casilla 14 — «Consignar el importe total correspondiente a ventas por exportación de bienes y operaciones exentas»', 'formulario-200'),
  ('BO', 'BO-SIN-200', '15', 'base', 'Ventas gravadas a Tasa Cero', '{"en":"Sales taxed at Zero Rate"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 3, casilla 15 — «Consignar el importe total correspondiente a ventas gravadas a Tasa Cero (Venta de Libros Ley N.° 366, Transporte Internacional Ley N.° 3249 y otras establecidas por Ley)»', 'formulario-200'),
  ('BO', 'BO-SIN-200', '39', 'tax', 'Débito Fiscal correspondiente a ventas gravadas', '{"en":"Output tax on taxable sales"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 8, casilla 39 — «Débito Fiscal correspondiente a: [(C13+C16+C17+C18) * 13 %]». Este paquete no lleva cuentas ni documentos para el valor atribuido a bienes retirados (C16), las devoluciones y rescisiones efectuadas (C17) ni los descuentos obtenidos (C18): la nota de crédito de este paquete resta directamente de esta misma casilla y de la 13, en vez de sumarse en C17. La casilla 39 es aquí la suma del débito fiscal que cada venta gravada contabilizó, y no una segunda multiplicación sobre la 13 — las dos maneras de calcularla coinciden porque una sola tasa nominal (13 %) grava toda venta interna de este paquete', 'formulario-200'),
  ('BO', 'BO-SIN-200', '1002', 'total', 'Total Débito Fiscal del período', '{"en":"Total output tax for the period"}'::jsonb, 50, null, array['39']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 11, casilla 1002 — «Total Débito Fiscal del período (C39+C55+C19)». Este paquete no lleva reintegros de crédito fiscal por donaciones (C55, art. 8° del Decreto Supremo N.° 21530) ni conciliaciones (C19)', 'formulario-200'),
  ('BO', 'BO-SIN-200', 'BASE26', 'base', 'Compras vinculadas a actividades gravadas, netas del impuesto (uso interno del paquete)', '{"en":"Purchases linked to taxable activities, net of tax (this pack''s own bookkeeping box)"}'::jsonb, 55, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'No es una casilla del Formulario 200: es el importe neto del impuesto que el motor separa de un precio facturado por el proveedor con el impuesto ya incluido. La casilla 26 del formulario, que pide el importe total de la compra, se reconstruye como el total de esta casilla más el crédito fiscal de la casilla 114', 'ley-843'),
  ('BO', 'BO-SIN-200', '26', 'total', 'Compras directamente vinculadas a actividades gravadas', '{"en":"Purchases directly linked to taxable activities"}'::jsonb, 60, null, array['BASE26:base', '114:tax']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 13, casilla 26 — «Consignar el total de compras, contrataciones e importaciones definitivas directamente vinculadas con operaciones gravadas, incluyendo las compras vinculadas a exportación de bienes y operaciones exentas. Excepto compras destinadas a actividades gravadas con tasa cero»', 'formulario-200'),
  ('BO', 'BO-SIN-200', '114', 'tax', 'Crédito Fiscal correspondiente a compras vinculadas a actividades gravadas', '{"en":"Input tax credit on purchases linked to taxable activities"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 17, casilla 114 — «Crédito Fiscal correspondiente a: [(C26+C27+C28)*13%]». Este paquete no lleva devoluciones y rescisiones recibidas (C27) ni descuentos otorgados (C28): la nota de crédito de una compra resta directamente de esta misma casilla y de la 26', 'formulario-200'),
  ('BO', 'BO-SIN-200', '1004', 'total', 'Total Crédito Fiscal del período', '{"en":"Total input tax credit for the period"}'::jsonb, 80, null, array['114']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 200 v.5 Extendido, fila 20, casilla 1004 — «Total Crédito Fiscal del período (C114+C30+C1003)». Este paquete no lleva conciliaciones de crédito (C30) ni el crédito fiscal proporcional de compras no discriminables (C1003, art. 8° del Decreto Supremo N.° 21530) — véase el README', 'formulario-200'),
  ('BO', 'BO-SIN-200', '909', 'total', 'Diferencia a favor del Fisco o Impuesto Determinado', '{"en":"Balance due to the Treasury or tax determined"}'::jsonb, 90, null, array['1002']::text[], array['1004']::text[], null, null, true, false, null, 'Formulario 200 v.5 Extendido, fila 22, casilla 909 — «Diferencia a favor del Fisco o Impuesto Determinado (C1002-C1004; Si >0)»', 'formulario-200'),
  ('BO', 'BO-SIN-200', '693', 'total', 'Diferencia a favor del Contribuyente', '{"en":"Balance due to the taxpayer"}'::jsonb, 100, null, array['1004']::text[], array['1002']::text[], null, null, true, false, null, 'Formulario 200 v.5 Extendido, fila 21, casilla 693 — «Diferencia a favor del Contribuyente (C1004-C1002; Si >0)»', 'formulario-200')
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
  ('BO-EF-BG', 'BO', 'default', 'Balance General', 'balance_sheet', 'BO-NC', date '1970-01-01', null, 'Código de Comercio (Decreto Ley N.° 14379), art. 331° — el directorio de toda sociedad anónima debe elaborar y publicar anualmente una memoria que contenga el balance general y el estado de resultados del ejercicio; el mismo artículo exige, además, un balance de comprobación de sumas y saldos y un inventario valorado del patrimonio social. Ni el Código de Comercio ni las Normas de Contabilidad Generalmente Aceptadas del Consejo Técnico Nacional de Auditoría y Contabilidad (CTNAC) prescriben las líneas de un balance general modelo; este esquema agrupa el activo en corriente y no corriente y el pasivo en corriente y no corriente, que es la práctica seguida bajo las NIIF adoptadas como marco supletorio por la Resolución CTNAC N.° 01/2012 — véase el README', 'codigo-comercio'),
  ('BO-EF-ER', 'BO', 'default', 'Estado de Resultados', 'income_statement', 'BO-NC', date '1970-01-01', null, 'Código de Comercio (Decreto Ley N.° 14379), art. 331° — la memoria anual de una sociedad anónima contiene el estado de resultados del ejercicio; el artículo no detalla sus líneas. Este esquema presenta el resultado por naturaleza (ventas, costo de ventas, gastos de comercialización y de administración, resultados financieros, impuesto sobre las utilidades), que es la práctica seguida bajo las NIIF adoptadas como marco supletorio por la Resolución CTNAC N.° 01/2012', 'codigo-comercio')
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
  ('BO-EF-BG', 'CB', null, 'Caja y bancos', '{"en":"Cash and banks"}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'INV', null, 'Inversiones corrientes', '{"en":"Current investments"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'CXV', null, 'Cuentas por cobrar comerciales', '{"en":"Trade receivables"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'OCR', null, 'Otros créditos', '{"en":"Other receivables"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'CFI', null, 'Créditos fiscales', '{"en":"Tax receivables"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 843, art. 8° y art. 11° — el crédito fiscal computable y el saldo a favor del contribuyente', 'ley-843'),
  ('BO-EF-BG', 'EXI', null, 'Existencias', '{"en":"Inventories"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'PPI', null, 'Partidas pendientes de imputación', '{"en":"Suspense items"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Cuenta de uso interno de este paquete, sin correspondencia en un rubro propio de las Normas de Contabilidad', 'codigo-comercio'),
  ('BO-EF-BG', 'AC', null, 'Total del activo corriente', '{"en":"Total current assets"}'::jsonb, 80, 1, true, array['CB', 'INV', 'CXV', 'OCR', 'CFI', 'EXI', 'PPI']::text[], '{}'::text[], null, 'Presentación usual de un activo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'CNC', null, 'Créditos no corrientes', '{"en":"Non-current receivables"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'AF', null, 'Activo fijo', '{"en":"Fixed assets"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'AIN', null, 'Activos intangibles', '{"en":"Intangible assets"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un activo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'ANC', null, 'Total del activo no corriente', '{"en":"Total non-current assets"}'::jsonb, 120, 1, true, array['CNC', 'AF', 'AIN']::text[], '{}'::text[], null, 'Presentación usual de un activo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'ACT', null, 'Total del activo', '{"en":"Total assets"}'::jsonb, 130, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-BG', 'CPC', null, 'Cuentas por pagar comerciales', '{"en":"Trade payables"}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un pasivo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'REM', null, 'Sueldos y cargas sociales por pagar', '{"en":"Payroll and social charges payable"}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un pasivo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'CFP', null, 'Cargas fiscales por pagar', '{"en":"Taxes payable"}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 843, art. 10° — el impuesto a ingresar de un período en que el débito fiscal supera al crédito fiscal', 'ley-843'),
  ('BO-EF-BG', 'ANT', null, 'Anticipos de clientes', '{"en":"Customer advances"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un pasivo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'PRO', null, 'Provisiones', '{"en":"Provisions"}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un pasivo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'PC', null, 'Total del pasivo corriente', '{"en":"Total current liabilities"}'::jsonb, 190, 1, true, array['CPC', 'REM', 'CFP', 'ANT', 'PRO']::text[], '{}'::text[], null, 'Presentación usual de un pasivo corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'DBL', null, 'Deudas bancarias no corrientes', '{"en":"Non-current bank debt"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un pasivo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'ODL', null, 'Otras deudas no corrientes', '{"en":"Other non-current debt"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un pasivo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'PNC', null, 'Total del pasivo no corriente', '{"en":"Total non-current liabilities"}'::jsonb, 220, 1, true, array['DBL', 'ODL']::text[], '{}'::text[], null, 'Presentación usual de un pasivo no corriente bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-BG', 'PAS', null, 'Total del pasivo', '{"en":"Total liabilities"}'::jsonb, 230, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-BG', 'CAP', null, 'Capital social', '{"en":"Share capital"}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-BG', 'RES', null, 'Reservas', '{"en":"Reserves"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-BG', 'RNA', null, 'Resultados acumulados', '{"en":"Retained earnings"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-BG', 'REJ', null, 'Resultado del ejercicio', '{"en":"Result for the year"}'::jsonb, 270, -1, false, '{}'::text[], '{}'::text[], null, 'Código de Comercio, art. 331° — el resultado del ejercicio se muestra hasta que la junta de accionistas resuelva su distribución', 'codigo-comercio'),
  ('BO-EF-BG', 'PN', null, 'Total del patrimonio', '{"en":"Total equity"}'::jsonb, 280, 1, true, array['CAP', 'RES', 'RNA', 'REJ']::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-BG', 'PASPN', null, 'Total del pasivo más patrimonio', '{"en":"Total liabilities and equity"}'::jsonb, 290, 1, true, array['PAS', 'PN']::text[], '{}'::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-ER', 'VEN', null, 'Ventas netas', '{"en":"Net sales"}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'CV', null, 'Costo de ventas', '{"en":"Cost of sales"}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'RB', null, 'Resultado bruto', '{"en":"Gross result"}'::jsonb, 30, 1, true, array['VEN']::text[], array['CV']::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-ER', 'GC', null, 'Gastos de comercialización', '{"en":"Selling expenses"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'GA', null, 'Gastos de administración', '{"en":"Administrative expenses"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'RO', null, 'Resultado operativo', '{"en":"Operating result"}'::jsonb, 60, 1, true, array['RB']::text[], array['GC', 'GA']::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-ER', 'RFPOS', null, 'Resultados financieros positivos', '{"en":"Positive financial results"}'::jsonb, 70, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'RFNEG', null, 'Resultados financieros negativos', '{"en":"Negative financial results"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'OTRI', null, 'Otros ingresos', '{"en":"Other income"}'::jsonb, 90, -1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'OTRE', null, 'Otros egresos', '{"en":"Other expenses"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Presentación usual de un estado de resultados por naturaleza bajo las NIIF adoptadas como marco supletorio (Resolución CTNAC N.° 01/2012)', 'ctnac-01-2012'),
  ('BO-EF-ER', 'RAI', null, 'Resultado antes del Impuesto sobre las Utilidades de las Empresas', '{"en":"Result before Corporate Income Tax"}'::jsonb, 110, 1, true, array['RO', 'RFPOS', 'OTRI']::text[], array['RFNEG', 'OTRE']::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio'),
  ('BO-EF-ER', 'IUE', null, 'Impuesto sobre las Utilidades de las Empresas', '{"en":"Corporate Income Tax"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Ley N.° 843, Título III (Impuesto sobre las Utilidades de las Empresas) — no modelado por este paquete; la cuenta existe para que el estado de resultados pueda presentarlo cuando la empresa lo liquide manualmente. Ver README', 'codigo-comercio'),
  ('BO-EF-ER', 'RN', null, 'Resultado neto del ejercicio', '{"en":"Net result for the year"}'::jsonb, 130, 1, true, array['RAI']::text[], array['IUE']::text[], null, 'Código de Comercio, art. 331°', 'codigo-comercio')
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
    ('BO-EF-BG', 'CB', 10, 'code_prefix', '111', null, null, 'any'),
    ('BO-EF-BG', 'INV', 10, 'code_prefix', '112', null, null, 'any'),
    ('BO-EF-BG', 'CXV', 10, 'code_prefix', '113', null, null, 'any'),
    ('BO-EF-BG', 'OCR', 10, 'code_prefix', '114', null, null, 'any'),
    ('BO-EF-BG', 'CFI', 10, 'code_prefix', '115', null, null, 'any'),
    ('BO-EF-BG', 'EXI', 10, 'code_prefix', '116', null, null, 'any'),
    ('BO-EF-BG', 'PPI', 10, 'code_prefix', '117', null, null, 'any'),
    ('BO-EF-BG', 'CNC', 10, 'code_prefix', '121', null, null, 'any'),
    ('BO-EF-BG', 'AF', 10, 'code_prefix', '122', null, null, 'any'),
    ('BO-EF-BG', 'AIN', 10, 'code_prefix', '123', null, null, 'any'),
    ('BO-EF-BG', 'CPC', 10, 'code_prefix', '211', null, null, 'any'),
    ('BO-EF-BG', 'REM', 10, 'code_prefix', '212', null, null, 'any'),
    ('BO-EF-BG', 'CFP', 10, 'code_prefix', '213', null, null, 'any'),
    ('BO-EF-BG', 'ANT', 10, 'code_prefix', '214', null, null, 'any'),
    ('BO-EF-BG', 'PRO', 10, 'code_prefix', '215', null, null, 'any'),
    ('BO-EF-BG', 'DBL', 10, 'code_prefix', '221', null, null, 'any'),
    ('BO-EF-BG', 'ODL', 10, 'code_prefix', '222', null, null, 'any'),
    ('BO-EF-BG', 'CAP', 10, 'code_prefix', '31', null, null, 'any'),
    ('BO-EF-BG', 'RES', 10, 'code_prefix', '32', null, null, 'any'),
    ('BO-EF-BG', 'RES', 20, 'code_prefix', '33', null, null, 'any'),
    ('BO-EF-BG', 'RNA', 10, 'code_prefix', '34', null, null, 'any'),
    ('BO-EF-BG', 'REJ', 10, 'code_prefix', '35', null, null, 'any'),
    ('BO-EF-ER', 'VEN', 10, 'code_prefix', '41', null, null, 'any'),
    ('BO-EF-ER', 'CV', 10, 'code_prefix', '51', null, null, 'any'),
    ('BO-EF-ER', 'GC', 10, 'code_prefix', '52', null, null, 'any'),
    ('BO-EF-ER', 'GA', 10, 'code_prefix', '53', null, null, 'any'),
    ('BO-EF-ER', 'RFPOS', 10, 'code_prefix', '46', null, null, 'any'),
    ('BO-EF-ER', 'RFNEG', 10, 'code_prefix', '56', null, null, 'any'),
    ('BO-EF-ER', 'OTRI', 10, 'code_prefix', '48', null, null, 'any'),
    ('BO-EF-ER', 'OTRE', 10, 'code_prefix', '58', null, null, 'any'),
    ('BO-EF-ER', 'IUE', 10, 'code_prefix', '57', null, null, 'any')
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
  ('BO', 'Bolivia', '{"en":"Bolivia"}'::jsonb, array['es', 'en']::text[], 'BOB', '1131', '2111', '117', '563', '341', '411', '511', '1112', '1111', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '351', '352', '342', 'APE', 'half_up', default, '462', '562', null, null, null, null, '2132', '1152', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Resolución Normativa de Directorio N.° 102100000011 (Sistema de Facturación), que exige la dosificación previa de rangos de numeración correlativa por punto de venta y modalidad de facturación, sin saltos dentro del rango autorizado. El número que declara este paquete es el de la pieza contable, correlativo por diario, y no el número de Factura, Nota Fiscal o Documento Equivalente que el Sistema de Facturación del SIN dosifica y que Ekwo no emite — véase «Ekwo no emite una Factura boliviana» en el README',
  numbering_source_key          = 'rnd-facturacion',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Ley N.° 843, art. 4° — en la venta de bienes, el hecho imponible se perfecciona con la entrega del bien o acto equivalente que suponga la transferencia de dominio, la cual deberá obligatoriamente estar respaldada por la emisión de la factura, nota fiscal o documento equivalente; en los contratos de obras o de prestación de servicios, en el momento en que se finalice la ejecución o prestación, o en el de la percepción total o parcial del precio, el que fuere anterior. La Resolución Normativa de Directorio N.° 102100000011 exige emitir la factura en el momento de la entrega del bien o de la conclusión del servicio, de modo que la emisión coincide en la práctica con el hecho que la ley toma como principio; el paquete declara invoice_if_issued por esa razón. Queda sin representar el caso en que el servicio se cobra, total o parcialmente, antes de concluirse y antes de emitirse la factura, que adelantaría el nacimiento del hecho imponible a la fecha de cobro — véase el README',
  tax_point_source_key          = 'ley-843',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ley N.° 2492, art. 87°, numeral 4 — el sujeto pasivo debe respaldar sus actividades con los libros, registros generales y especiales, y demás documentos, sin alterar los hechos registrados; Resolución Normativa de Directorio N.° 102100000011, que sólo admite corregir una factura ya emitida mediante una Nota de Crédito-Débito que la referencia. Un documento contabilizado se anula con una nota de crédito que lo nombra, nunca volviendo a borrador',
  posted_edit_policy_source_key = 'rnd-facturacion',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'El comprobante boliviano exigido para toda venta o servicio es una Factura, Nota Fiscal o Documento Equivalente del Sistema de Facturación del Servicio de Impuestos Nacionales (SIN), regulado por la Resolución Normativa de Directorio N.° 102100000011 (Sistema de Facturación, «NSF-07»), de 11 de agosto de 2021, que reemplazó al sistema aprobado por la Resolución Normativa de Directorio N.° 10-0016-07 de 2007. La resolución define varias modalidades — Manual, Prevalorada, Computarizada, Electrónica en Línea, Computarizada en Línea, Portal Web — y asigna a cada contribuyente la suya mediante resoluciones sucesivas que designan «grupos» por su actividad, tamaño o facturación (entre otras, las Resoluciones Normativas de Directorio N.° 102400000004, 102400000005, 102400000012 y 102400000025, del noveno al duodécimo grupo, y la Resolución N.° 102600000007, que amplió el plazo de adecuación al 30 de septiembre de 2026 antes de exigir el uso exclusivo de la modalidad asignada desde el 1 de octubre de 2026). En las modalidades en línea, cada documento se genera con un Código Único de Facturación (CUF) calculado a partir de un Código Único de Facturación Diario (CUFD) que el sistema del SIN emite por adelantado — una validación distinta de una compensación (clearance) en tiempo real de tipo Peppol, pero igualmente ajena a cualquier pieza de packages/formats. Ekwo no genera, no envía ni valida el CUF ni el CUFD de ninguna modalidad: por eso profile y mandatory_from quedan vacíos aunque la obligación exista para prácticamente todo contribuyente desde 2026; profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe y transmite por Peppol, y el comprobante boliviano no es ni lo uno ni lo otro. El NIT identifica al emisor y al receptor y no tiene código ISO 6523 propio: party_scheme y vat_scheme quedan vacíos — véase «Ekwo no emite una Factura boliviana» y docs/international.md',
  einvoice_source_key           = 'rnd-facturacion',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'BO';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('BO', 'factura_not_issued', 'always', 'Este documento no es una Factura, Nota Fiscal o Documento Equivalente boliviano: no ha sido generado con la dosificación del Sistema de Facturación del Servicio de Impuestos Nacionales (SIN) ni lleva el Código Único de Facturación (CUF) que la valida. Sólo la Factura, Nota Fiscal o Documento Equivalente válido respalda el crédito fiscal, el gasto y la operación a efectos tributarios.', '{"en":"This document is not a Factura, Nota Fiscal or equivalent Bolivian tax document: it was not generated with the dosificación of the Servicio de Impuestos Nacionales (SIN) invoicing system and carries no Código Único de Facturación (CUF). Only a valid Factura, Nota Fiscal or equivalent document supports input tax credit, deductible expense or the operation for tax purposes."}'::jsonb, 10, date '1970-01-01', null, 'Resolución Normativa de Directorio N.° 102100000011 (Sistema de Facturación) — toda venta de bienes o prestación de servicios debe respaldarse con una Factura, Nota Fiscal o Documento Equivalente emitida bajo una de las modalidades de facturación que la resolución autoriza (Manual, Prevalorada, Computarizada, Electrónica en Línea, entre otras), dosificada por el SIN y, en las modalidades en línea, validada con un Código Único de Facturación (CUF) generado a partir de un Código Único de Facturación Diario (CUFD). Ekwo no genera, transmite ni valida ninguno de los dos códigos: ningún componente de packages/formats habla con el Sistema de Facturación del SIN — véase «Ekwo no emite una Factura boliviana»'),
  ('BO', 'export', 'export', 'Operación de exportación, liberada del débito fiscal del Impuesto al Valor Agregado (artículo 11° de la Ley N.° 843).', '{"en":"Export operation, relieved of output Value Added Tax (article 11 of Ley N.° 843)."}'::jsonb, 20, date '1970-01-01', null, 'Ley N.° 843, art. 11° — las exportaciones quedan liberadas del débito fiscal que les corresponda; el crédito fiscal vinculado da lugar al cómputo contra el impuesto del mercado interno y, en su caso, a la devolución mediante Certificados de Devolución de Impuestos (CEDEIM)'),
  ('BO', 'zero_rate_book', 'exempt', 'TASA CERO - SIN DERECHO A CREDITO FISCAL, LEY N.º 366, DEL LIBRO Y LA LECTURA.', '{"en":"ZERO RATE - NO RIGHT TO INPUT TAX CREDIT, LAW No. 366, OF THE BOOK AND READING."}'::jsonb, 30, date '1970-01-01', null, 'Ley N.° 366, art. 8°, y su Reglamento (Decreto Supremo N.° 1768) — la venta de libros de producción nacional e importados, y de las publicaciones oficiales de las instituciones del Estado Plurinacional, en versión impresa, está sujeta a tasa cero del Impuesto al Valor Agregado, sin derecho a crédito fiscal; el contribuyente cuya actividad económica sea la venta de libros debe emitir la factura con la leyenda «TASA CERO - SIN DERECHO A CREDITO FISCAL, LEY N.° 366, DEL LIBRO Y LA LECTURA»')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
