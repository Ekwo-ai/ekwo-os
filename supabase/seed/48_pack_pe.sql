-- Ekwo OS — Perú: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/pe at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build pe`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Texto Único Ordenado de la Ley del Impuesto General a las Ventas e Impuesto Selectivo al Consumo, aprobado por Decreto Supremo N.° 055-99-EF, y sus modificatorias — incluye los Apéndices I y II (SUNAT — Legislación tributaria)
--     https://www.sunat.gob.pe/legislacion/igv/ley/ds055-99-ef.pdf
--   Apéndice II del TUO de la Ley del IGV e ISC — Servicios exonerados del Impuesto General a las Ventas (SUNAT — Legislación tributaria)
--     https://www.sunat.gob.pe/legislacion/igv/ley/apendice2.pdf
--   Reglamento de la Ley del Impuesto General a las Ventas e Impuesto Selectivo al Consumo, aprobado por Decreto Supremo N.° 029-94-EF, texto actualizado (Congreso de la República — Departamento de Investigación y Documentación Parlamentaria)
--     https://www2.congreso.gob.pe/sicr/cendocbib/con5_uibd.nsf/245019EA7FB96099052581B4006ECD5E/$FILE/Reglamento_IGV-ISC.pdf
--   Decreto Legislativo N.° 776, Ley de Tributación Municipal, texto actualizado (Congreso de la República — Departamento de Investigación y Documentación Parlamentaria)
--     https://www2.congreso.gob.pe/sicr/cendocbib/con4_uibd.nsf/9FB09CDC75082094052581560074771E/$FILE/2.Ley_de_Tributaci%C3%B3n_Municipal.pdf
--   Ley N.° 32387, Ley que promueve la descentralización fiscal para incentivar el desarrollo de los gobiernos locales fortaleciendo el Fondo de Compensación Municipal (FONCOMUN), publicada el 16 de junio de 2025 — reduce progresivamente la tasa del IGV y aumenta la del Impuesto de Promoción Municipal a partir del 1 de enero de 2026, sin variar la tasa combinada de 18 % (SUNAT — Orientación al contribuyente)
--     https://orientacion.sunat.gob.pe/3053-concepto-tasa-y-operaciones-gravadas-igv-empresas
--   Texto Único Ordenado del Código Tributario, aprobado por Decreto Supremo N.° 133-2013-EF, y sus modificatorias (SUNAT — Legislación tributaria)
--     https://www.sunat.gob.pe/legislacion/codigo/textoCompleto-TUO-CT.pdf
--   Ley N.° 26887, Ley General de Sociedades (Congreso de la República — Archivo Digital de la Legislación del Perú)
--     https://leyes.congreso.gob.pe/Documentos/Leyes/26887.pdf
--   Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad, que aprueba el Plan Contable General Empresarial modificado 2019, de uso obligatorio desde el 1 de enero de 2020 (Diario Oficial El Peruano — Sistema de Búsqueda de Dispositivos Legales)
--     https://busquedas.elperuano.pe/dispositivo/NL/1772236-1
--   Ayuda para el registro del Formulario Virtual N.° 621 — IGV Renta Mensual (SUNAT — Operaciones en línea)
--     https://www.sunat.gob.pe/operacLinea/ayudas/Ayuda_621_IGV_Renta_Mensual.pdf
--   Formulario Virtual N.° 621 IGV Renta Mensual — presentación en Sunat Operaciones en Línea (SUNAT — Orientación al contribuyente)
--     https://www.gob.pe/8006-formulario-virtual-n-621-igv-renta-mensual
--   Cronograma de vencimientos mensuales de obligaciones tributarias del año 2026, por último dígito del RUC (SUNAT — Noticias institucionales)
--     https://www.gob.pe/institucion/sunat/noticias/1352241-conozca-el-cronograma-de-vencimientos-mensuales-de-obligaciones-tributarias-del-ano-2026
--   Reglamento de Comprobantes de Pago, aprobado por Resolución de Superintendencia N.° 007-99/SUNAT, texto actualizado (SUNAT — Legislación tributaria)
--     https://www.sunat.gob.pe/legislacion/comprob/regla/
--   Resolución de Superintendencia N.° 155-2017/SUNAT, que designa emisores electrónicos del Sistema de Emisión Electrónica por su volumen de ingresos o exportaciones (SUNAT — Legislación tributaria)
--     https://www.sunat.gob.pe/legislacion/superin/2017/155-2017.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('PE', 'Perú', '0.1.0', date '2026-09-25', '20260921084143', 'community', null, null, 'c3322a814afa13201a0a9c552dab8841a9b1ccbd553967498b2ef466747d446a', '[{"key":"ley-igv","title":"Texto Único Ordenado de la Ley del Impuesto General a las Ventas e Impuesto Selectivo al Consumo, aprobado por Decreto Supremo N.° 055-99-EF, y sus modificatorias — incluye los Apéndices I y II","publisher":"SUNAT — Legislación tributaria","url":"https://www.sunat.gob.pe/legislacion/igv/ley/ds055-99-ef.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"apendice-ii","title":"Apéndice II del TUO de la Ley del IGV e ISC — Servicios exonerados del Impuesto General a las Ventas","publisher":"SUNAT — Legislación tributaria","url":"https://www.sunat.gob.pe/legislacion/igv/ley/apendice2.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"reglamento-igv","title":"Reglamento de la Ley del Impuesto General a las Ventas e Impuesto Selectivo al Consumo, aprobado por Decreto Supremo N.° 029-94-EF, texto actualizado","publisher":"Congreso de la República — Departamento de Investigación y Documentación Parlamentaria","url":"https://www2.congreso.gob.pe/sicr/cendocbib/con5_uibd.nsf/245019EA7FB96099052581B4006ECD5E/$FILE/Reglamento_IGV-ISC.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"dl-776","title":"Decreto Legislativo N.° 776, Ley de Tributación Municipal, texto actualizado","publisher":"Congreso de la República — Departamento de Investigación y Documentación Parlamentaria","url":"https://www2.congreso.gob.pe/sicr/cendocbib/con4_uibd.nsf/9FB09CDC75082094052581560074771E/$FILE/2.Ley_de_Tributaci%C3%B3n_Municipal.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"ley-32387","title":"Ley N.° 32387, Ley que promueve la descentralización fiscal para incentivar el desarrollo de los gobiernos locales fortaleciendo el Fondo de Compensación Municipal (FONCOMUN), publicada el 16 de junio de 2025 — reduce progresivamente la tasa del IGV y aumenta la del Impuesto de Promoción Municipal a partir del 1 de enero de 2026, sin variar la tasa combinada de 18 %","publisher":"SUNAT — Orientación al contribuyente","url":"https://orientacion.sunat.gob.pe/3053-concepto-tasa-y-operaciones-gravadas-igv-empresas","consulted_on":"2026-09-25","kind":"guidance"},{"key":"codigo-tributario","title":"Texto Único Ordenado del Código Tributario, aprobado por Decreto Supremo N.° 133-2013-EF, y sus modificatorias","publisher":"SUNAT — Legislación tributaria","url":"https://www.sunat.gob.pe/legislacion/codigo/textoCompleto-TUO-CT.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"lgs","title":"Ley N.° 26887, Ley General de Sociedades","publisher":"Congreso de la República — Archivo Digital de la Legislación del Perú","url":"https://leyes.congreso.gob.pe/Documentos/Leyes/26887.pdf","consulted_on":"2026-09-25","kind":"law"},{"key":"pcge-2019","title":"Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad, que aprueba el Plan Contable General Empresarial modificado 2019, de uso obligatorio desde el 1 de enero de 2020","publisher":"Diario Oficial El Peruano — Sistema de Búsqueda de Dispositivos Legales","url":"https://busquedas.elperuano.pe/dispositivo/NL/1772236-1","consulted_on":"2026-09-25","kind":"regulation"},{"key":"form-621-ayuda","title":"Ayuda para el registro del Formulario Virtual N.° 621 — IGV Renta Mensual","publisher":"SUNAT — Operaciones en línea","url":"https://www.sunat.gob.pe/operacLinea/ayudas/Ayuda_621_IGV_Renta_Mensual.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"portal-sol","title":"Formulario Virtual N.° 621 IGV Renta Mensual — presentación en Sunat Operaciones en Línea","publisher":"SUNAT — Orientación al contribuyente","url":"https://www.gob.pe/8006-formulario-virtual-n-621-igv-renta-mensual","consulted_on":"2026-09-25","kind":"portal"},{"key":"cronograma-2026","title":"Cronograma de vencimientos mensuales de obligaciones tributarias del año 2026, por último dígito del RUC","publisher":"SUNAT — Noticias institucionales","url":"https://www.gob.pe/institucion/sunat/noticias/1352241-conozca-el-cronograma-de-vencimientos-mensuales-de-obligaciones-tributarias-del-ano-2026","consulted_on":"2026-09-25","kind":"guidance"},{"key":"rcp","title":"Reglamento de Comprobantes de Pago, aprobado por Resolución de Superintendencia N.° 007-99/SUNAT, texto actualizado","publisher":"SUNAT — Legislación tributaria","url":"https://www.sunat.gob.pe/legislacion/comprob/regla/","consulted_on":"2026-09-25","kind":"regulation"},{"key":"see-clearance","title":"Resolución de Superintendencia N.° 155-2017/SUNAT, que designa emisores electrónicos del Sistema de Emisión Electrónica por su volumen de ingresos o exportaciones","publisher":"SUNAT — Legislación tributaria","url":"https://www.sunat.gob.pe/legislacion/superin/2017/155-2017.pdf","consulted_on":"2026-09-25","kind":"regulation"}]'::jsonb)
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
  ('PE', 'default', 'Plan Contable General Empresarial (selección)', '{"en":"Chart of accounts (selection from the Plan Contable General Empresarial)"}'::jsonb, true, 'companies', array['PE-EF-ER', 'PE-EF-ESF']::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — el Plan Contable General Empresarial (PCGE) no es un catálogo obligatorio de cuentas de nivel detallado: prescribe las cuentas de mayor (dos dígitos) y su dinámica, y las empresas abren las subcuentas que necesitan bajo ellas. Este paquete usa una selección de 174 cuentas del PCGE 2019, con sus códigos y nombres oficiales hasta el nivel de subcuenta (cinco dígitos), y abre subcuentas propias de un dígito más allí donde una sola cuenta del PCGE debe servir a la vez de cuenta de posteo y de cuenta de liquidación de la declaración — véase el README', 'pcge-2019')
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
  ('PE', 'default', '1', 'Activo disponible y exigible', '{"en":"Cash and receivables"}'::jsonb, 'asset_current', false, null, 10),
  ('PE', 'default', '10', 'Efectivo y equivalentes de efectivo', '{"en":"Cash and cash equivalents"}'::jsonb, 'asset_cash', false, '1', 20),
  ('PE', 'default', '101', 'Caja', '{"en":"Cash on hand"}'::jsonb, 'asset_cash', false, '10', 30),
  ('PE', 'default', '104', 'Cuentas corrientes en instituciones financieras', '{"en":"Current accounts with financial institutions"}'::jsonb, 'asset_cash', false, '10', 40),
  ('PE', 'default', '1041', 'Cuentas corrientes operativas', '{"en":"Operating current accounts"}'::jsonb, 'asset_cash', false, '104', 50),
  ('PE', 'default', '106', 'Depósitos en instituciones financieras', '{"en":"Deposits with financial institutions"}'::jsonb, 'asset_cash', false, '10', 60),
  ('PE', 'default', '1062', 'Depósitos a plazo', '{"en":"Term deposits"}'::jsonb, 'asset_cash', false, '106', 70),
  ('PE', 'default', '12', 'Cuentas por cobrar comerciales – Terceros', '{"en":"Trade receivables – third parties"}'::jsonb, 'asset_receivable', true, '1', 80),
  ('PE', 'default', '121', 'Facturas, boletas y otros comprobantes por cobrar', '{"en":"Invoices, receipts and other vouchers receivable"}'::jsonb, 'asset_receivable', true, '12', 90),
  ('PE', 'default', '1212', 'Emitidas en cartera', '{"en":"Issued, held"}'::jsonb, 'asset_receivable', true, '121', 100),
  ('PE', 'default', '122', 'Anticipos de clientes', '{"en":"Advances from customers"}'::jsonb, 'asset_current', false, '12', 110),
  ('PE', 'default', '123', 'Letras por cobrar', '{"en":"Bills receivable"}'::jsonb, 'asset_receivable', true, '12', 120),
  ('PE', 'default', '1232', 'En cartera', '{"en":"Held"}'::jsonb, 'asset_receivable', true, '123', 130),
  ('PE', 'default', '14', 'Cuentas por cobrar al personal, a los accionistas (socios) y directores', '{"en":"Receivables from staff, shareholders and directors"}'::jsonb, 'asset_current', false, '1', 140),
  ('PE', 'default', '141', 'Personal', '{"en":"Staff"}'::jsonb, 'asset_current', false, '14', 150),
  ('PE', 'default', '1413', 'Entregas a rendir cuenta', '{"en":"Advances subject to accounting"}'::jsonb, 'asset_current', false, '141', 160),
  ('PE', 'default', '142', 'Accionistas (o socios)', '{"en":"Shareholders"}'::jsonb, 'asset_current', false, '14', 170),
  ('PE', 'default', '1422', 'Préstamos', '{"en":"Loans"}'::jsonb, 'asset_current', false, '142', 180),
  ('PE', 'default', '16', 'Cuentas por cobrar diversas – Terceros', '{"en":"Other receivables – third parties"}'::jsonb, 'asset_current', false, '1', 190),
  ('PE', 'default', '167', 'Tributos por acreditar', '{"en":"Taxes to be credited"}'::jsonb, 'asset_current', false, '16', 200),
  ('PE', 'default', '1671', 'Pagos a cuenta del impuesto a la renta', '{"en":"Income tax prepayments"}'::jsonb, 'asset_current', false, '167', 210),
  ('PE', 'default', '169', 'Otras cuentas por cobrar diversas', '{"en":"Other miscellaneous receivables"}'::jsonb, 'asset_current', false, '16', 220),
  ('PE', 'default', '1699', 'Otras cuentas por cobrar diversas', '{"en":"Other miscellaneous receivables"}'::jsonb, 'asset_current', false, '169', 230),
  ('PE', 'default', '18', 'Servicios y otros contratados por anticipado', '{"en":"Prepaid services and other prepayments"}'::jsonb, 'asset_prepayments', false, '1', 240),
  ('PE', 'default', '182', 'Seguros', '{"en":"Insurance"}'::jsonb, 'asset_prepayments', false, '18', 250),
  ('PE', 'default', '183', 'Alquileres', '{"en":"Rent"}'::jsonb, 'asset_prepayments', false, '18', 260),
  ('PE', 'default', '189', 'Otros gastos contratados por anticipado', '{"en":"Other prepaid expenses"}'::jsonb, 'asset_prepayments', false, '18', 270),
  ('PE', 'default', '19', 'Estimación de cuentas de cobranza dudosa', '{"en":"Allowance for doubtful accounts"}'::jsonb, 'asset_current', false, '1', 280),
  ('PE', 'default', '191', 'Cuentas por cobrar comerciales – Terceros', '{"en":"Trade receivables – third parties"}'::jsonb, 'asset_current', false, '19', 290),
  ('PE', 'default', '1911', 'Facturas, boletas y otros comprobantes por cobrar', '{"en":"Invoices, receipts and other vouchers receivable"}'::jsonb, 'asset_current', false, '191', 300),
  ('PE', 'default', '2', 'Activo realizable', '{"en":"Inventories"}'::jsonb, 'asset_current', false, null, 310),
  ('PE', 'default', '20', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, '2', 320),
  ('PE', 'default', '201', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, '20', 330),
  ('PE', 'default', '2011', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, '201', 340),
  ('PE', 'default', '29', 'Desvalorización de inventarios', '{"en":"Inventory write-down"}'::jsonb, 'asset_current', false, '2', 350),
  ('PE', 'default', '291', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'asset_current', false, '29', 360),
  ('PE', 'default', '3', 'Activo inmovilizado', '{"en":"Fixed assets"}'::jsonb, 'asset_fixed', false, null, 370),
  ('PE', 'default', '33', 'Propiedad, planta y equipo', '{"en":"Property, plant and equipment"}'::jsonb, 'asset_fixed', false, '3', 380),
  ('PE', 'default', '331', 'Terrenos', '{"en":"Land"}'::jsonb, 'asset_fixed', false, '33', 390),
  ('PE', 'default', '332', 'Edificaciones', '{"en":"Buildings"}'::jsonb, 'asset_fixed', false, '33', 400),
  ('PE', 'default', '3321', 'Edificaciones', '{"en":"Buildings"}'::jsonb, 'asset_fixed', false, '332', 410),
  ('PE', 'default', '333', 'Maquinaria y equipo de explotación', '{"en":"Machinery and operating equipment"}'::jsonb, 'asset_fixed', false, '33', 420),
  ('PE', 'default', '3331', 'Maquinaria y equipo de explotación', '{"en":"Machinery and operating equipment"}'::jsonb, 'asset_fixed', false, '333', 430),
  ('PE', 'default', '334', 'Unidades de transporte', '{"en":"Transport units"}'::jsonb, 'asset_fixed', false, '33', 440),
  ('PE', 'default', '3341', 'Vehículos motorizados', '{"en":"Motor vehicles"}'::jsonb, 'asset_fixed', false, '334', 450),
  ('PE', 'default', '335', 'Muebles y enseres', '{"en":"Furniture and fixtures"}'::jsonb, 'asset_fixed', false, '33', 460),
  ('PE', 'default', '3351', 'Muebles', '{"en":"Furniture"}'::jsonb, 'asset_fixed', false, '335', 470),
  ('PE', 'default', '336', 'Equipos diversos', '{"en":"Miscellaneous equipment"}'::jsonb, 'asset_fixed', false, '33', 480),
  ('PE', 'default', '3361', 'Equipo para procesamiento de información', '{"en":"IT equipment"}'::jsonb, 'asset_fixed', false, '336', 490),
  ('PE', 'default', '34', 'Intangibles', '{"en":"Intangible assets"}'::jsonb, 'asset_non_current', false, '3', 500),
  ('PE', 'default', '343', 'Programas de computadora (software)', '{"en":"Computer software"}'::jsonb, 'asset_non_current', false, '34', 510),
  ('PE', 'default', '3431', 'Aplicaciones informáticas', '{"en":"Software applications"}'::jsonb, 'asset_non_current', false, '343', 520),
  ('PE', 'default', '37', 'Activo diferido', '{"en":"Deferred assets"}'::jsonb, 'asset_non_current', false, '3', 530),
  ('PE', 'default', '371', 'Impuesto a la renta diferido', '{"en":"Deferred income tax"}'::jsonb, 'asset_non_current', false, '37', 540),
  ('PE', 'default', '39', 'Depreciación y amortización acumulados', '{"en":"Accumulated depreciation and amortisation"}'::jsonb, 'asset_fixed', false, '3', 550),
  ('PE', 'default', '395', 'Depreciación acumulada de propiedad, planta y equipo', '{"en":"Accumulated depreciation of property, plant and equipment"}'::jsonb, 'asset_fixed', false, '39', 560),
  ('PE', 'default', '3952', 'Depreciación acumulada – Costo', '{"en":"Accumulated depreciation – cost"}'::jsonb, 'asset_fixed', false, '395', 570),
  ('PE', 'default', '396', 'Amortización acumulada', '{"en":"Accumulated amortisation"}'::jsonb, 'asset_fixed', false, '39', 580),
  ('PE', 'default', '3961', 'Intangibles – Costo', '{"en":"Intangible assets – cost"}'::jsonb, 'asset_fixed', false, '396', 590),
  ('PE', 'default', '4', 'Pasivo', '{"en":"Liabilities"}'::jsonb, 'liability_current', false, null, 600),
  ('PE', 'default', '40', 'Tributos, contraprestaciones y aportes al sistema público de pensiones y de salud por pagar', '{"en":"Taxes, contributions and public pension and health system payments payable"}'::jsonb, 'liability_current', false, '4', 610),
  ('PE', 'default', '401', 'Gobierno nacional', '{"en":"National government"}'::jsonb, 'liability_current', false, '40', 620),
  ('PE', 'default', '4011', 'Impuesto general a las ventas', '{"en":"General sales tax"}'::jsonb, 'liability_current', false, '401', 630),
  ('PE', 'default', '40111', 'IGV – Cuenta propia', '{"en":"VAT – own account"}'::jsonb, 'liability_current', false, '4011', 640),
  ('PE', 'default', '401111', 'IGV – Débito fiscal (IGV de ventas)', '{"en":"VAT – output tax (VAT on sales)"}'::jsonb, 'liability_current', false, '40111', 650),
  ('PE', 'default', '401112', 'IGV – Crédito fiscal (IGV de compras)', '{"en":"VAT – input tax credit (VAT on purchases)"}'::jsonb, 'asset_current', false, '40111', 660),
  ('PE', 'default', '401113', 'IGV – Tributo por pagar', '{"en":"VAT – tax payable"}'::jsonb, 'liability_current', true, '40111', 670),
  ('PE', 'default', '401114', 'IGV – Saldo a favor del IGV', '{"en":"VAT – credit balance"}'::jsonb, 'asset_current', true, '40111', 680),
  ('PE', 'default', '4017', 'Impuesto a la renta', '{"en":"Income tax"}'::jsonb, 'liability_current', false, '401', 690),
  ('PE', 'default', '40171', 'Renta de tercera categoría', '{"en":"Third-category income tax"}'::jsonb, 'liability_current', false, '4017', 700),
  ('PE', 'default', '403', 'Instituciones públicas', '{"en":"Public institutions"}'::jsonb, 'liability_current', false, '40', 710),
  ('PE', 'default', '4031', 'ESSALUD', '{"en":"ESSALUD (public health insurance)"}'::jsonb, 'liability_current', false, '403', 720),
  ('PE', 'default', '4032', 'ONP', '{"en":"ONP (public pension system)"}'::jsonb, 'liability_current', false, '403', 730),
  ('PE', 'default', '41', 'Remuneraciones y participaciones por pagar', '{"en":"Payroll and profit-sharing payable"}'::jsonb, 'liability_current', false, '4', 740),
  ('PE', 'default', '411', 'Remuneraciones por pagar', '{"en":"Payroll payable"}'::jsonb, 'liability_current', false, '41', 750),
  ('PE', 'default', '4111', 'Sueldos y salarios por pagar', '{"en":"Wages and salaries payable"}'::jsonb, 'liability_current', false, '411', 760),
  ('PE', 'default', '415', 'Beneficios sociales de los trabajadores por pagar', '{"en":"Employee benefits payable"}'::jsonb, 'liability_current', false, '41', 770),
  ('PE', 'default', '4151', 'Compensación por tiempo de servicios', '{"en":"Length-of-service compensation (CTS)"}'::jsonb, 'liability_current', false, '415', 780),
  ('PE', 'default', '42', 'Cuentas por pagar comerciales – Terceros', '{"en":"Trade payables – third parties"}'::jsonb, 'liability_payable', true, '4', 790),
  ('PE', 'default', '421', 'Facturas, boletas y otros comprobantes por pagar', '{"en":"Invoices, receipts and other vouchers payable"}'::jsonb, 'liability_payable', true, '42', 800),
  ('PE', 'default', '4212', 'Emitidas', '{"en":"Issued"}'::jsonb, 'liability_payable', true, '421', 810),
  ('PE', 'default', '422', 'Anticipos a proveedores', '{"en":"Advances to suppliers"}'::jsonb, 'liability_current', false, '42', 820),
  ('PE', 'default', '423', 'Letras por pagar', '{"en":"Bills payable"}'::jsonb, 'liability_payable', true, '42', 830),
  ('PE', 'default', '4231', 'Letras por pagar', '{"en":"Bills payable"}'::jsonb, 'liability_payable', true, '423', 840),
  ('PE', 'default', '45', 'Obligaciones financieras', '{"en":"Financial liabilities"}'::jsonb, 'liability_non_current', false, '4', 850),
  ('PE', 'default', '451', 'Préstamos de instituciones financieras y otras entidades', '{"en":"Loans from financial institutions and other entities"}'::jsonb, 'liability_non_current', false, '45', 860),
  ('PE', 'default', '4511', 'Instituciones financieras', '{"en":"Financial institutions"}'::jsonb, 'liability_non_current', false, '451', 870),
  ('PE', 'default', '46', 'Cuentas por pagar diversas – Terceros', '{"en":"Other payables – third parties"}'::jsonb, 'liability_current', false, '4', 880),
  ('PE', 'default', '469', 'Otras cuentas por pagar diversas', '{"en":"Other miscellaneous payables"}'::jsonb, 'liability_current', false, '46', 890),
  ('PE', 'default', '4699', 'Otras cuentas por pagar', '{"en":"Other payables"}'::jsonb, 'liability_current', false, '469', 900),
  ('PE', 'default', '48', 'Provisiones', '{"en":"Provisions"}'::jsonb, 'liability_non_current', false, '4', 910),
  ('PE', 'default', '486', 'Provisión para garantías', '{"en":"Warranty provision"}'::jsonb, 'liability_non_current', false, '48', 920),
  ('PE', 'default', '5', 'Patrimonio neto', '{"en":"Equity"}'::jsonb, 'equity', false, null, 930),
  ('PE', 'default', '50', 'Capital', '{"en":"Share capital"}'::jsonb, 'equity', false, '5', 940),
  ('PE', 'default', '501', 'Capital social', '{"en":"Share capital"}'::jsonb, 'equity', false, '50', 950),
  ('PE', 'default', '5011', 'Acciones', '{"en":"Shares"}'::jsonb, 'equity', false, '501', 960),
  ('PE', 'default', '58', 'Reservas', '{"en":"Reserves"}'::jsonb, 'equity', false, '5', 970),
  ('PE', 'default', '582', 'Legal', '{"en":"Legal reserve"}'::jsonb, 'equity', false, '58', 980),
  ('PE', 'default', '59', 'Resultados acumulados', '{"en":"Retained earnings"}'::jsonb, 'equity_retained', false, '5', 990),
  ('PE', 'default', '591', 'Utilidades no distribuidas', '{"en":"Undistributed profits"}'::jsonb, 'equity_retained', false, '59', 1000),
  ('PE', 'default', '5911', 'Utilidades acumuladas', '{"en":"Accumulated profits"}'::jsonb, 'equity_retained', false, '591', 1010),
  ('PE', 'default', '592', 'Pérdidas acumuladas', '{"en":"Accumulated losses"}'::jsonb, 'equity_retained', false, '59', 1020),
  ('PE', 'default', '5921', 'Pérdidas acumuladas', '{"en":"Accumulated losses"}'::jsonb, 'equity_retained', false, '592', 1030),
  ('PE', 'default', '6', 'Gastos por naturaleza', '{"en":"Expenses by nature"}'::jsonb, 'expense', false, null, 1040),
  ('PE', 'default', '60', 'Compras', '{"en":"Purchases"}'::jsonb, 'expense_direct_cost', false, '6', 1050),
  ('PE', 'default', '601', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'expense_direct_cost', false, '60', 1060),
  ('PE', 'default', '6011', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'expense_direct_cost', false, '601', 1070),
  ('PE', 'default', '62', 'Gastos de personal, directores y gerentes', '{"en":"Personnel, directors and management expenses"}'::jsonb, 'expense', false, '6', 1080),
  ('PE', 'default', '621', 'Remuneraciones', '{"en":"Payroll"}'::jsonb, 'expense', false, '62', 1090),
  ('PE', 'default', '6211', 'Sueldos y salarios', '{"en":"Wages and salaries"}'::jsonb, 'expense', false, '621', 1100),
  ('PE', 'default', '627', 'Seguridad, previsión social y otras contribuciones', '{"en":"Social security and other contributions"}'::jsonb, 'expense', false, '62', 1110),
  ('PE', 'default', '6271', 'Régimen de prestaciones de salud', '{"en":"Health benefits scheme"}'::jsonb, 'expense', false, '627', 1120),
  ('PE', 'default', '629', 'Beneficios sociales de los trabajadores', '{"en":"Employee benefits"}'::jsonb, 'expense', false, '62', 1130),
  ('PE', 'default', '6291', 'Compensación por tiempo de servicio', '{"en":"Length-of-service compensation (CTS)"}'::jsonb, 'expense', false, '629', 1140),
  ('PE', 'default', '63', 'Gastos de servicios prestados por terceros', '{"en":"Third-party services expense"}'::jsonb, 'expense', false, '6', 1150),
  ('PE', 'default', '631', 'Transporte, correos y gastos de viaje', '{"en":"Transport, postage and travel expenses"}'::jsonb, 'expense', false, '63', 1160),
  ('PE', 'default', '6311', 'Transporte', '{"en":"Transport"}'::jsonb, 'expense', false, '631', 1170),
  ('PE', 'default', '632', 'Asesoría y consultoría', '{"en":"Advisory and consulting services"}'::jsonb, 'expense', false, '63', 1180),
  ('PE', 'default', '6323', 'Auditoría y contable', '{"en":"Audit and accounting services"}'::jsonb, 'expense', false, '632', 1190),
  ('PE', 'default', '635', 'Alquileres', '{"en":"Rent"}'::jsonb, 'expense', false, '63', 1200),
  ('PE', 'default', '6352', 'Edificaciones', '{"en":"Buildings"}'::jsonb, 'expense', false, '635', 1210),
  ('PE', 'default', '636', 'Servicios básicos', '{"en":"Utilities"}'::jsonb, 'expense', false, '63', 1220),
  ('PE', 'default', '6364', 'Teléfono', '{"en":"Telephone"}'::jsonb, 'expense', false, '636', 1230),
  ('PE', 'default', '6365', 'Internet', '{"en":"Internet"}'::jsonb, 'expense', false, '636', 1240),
  ('PE', 'default', '637', 'Publicidad, publicaciones, relaciones públicas', '{"en":"Advertising, publications, public relations"}'::jsonb, 'expense', false, '63', 1250),
  ('PE', 'default', '6371', 'Publicidad', '{"en":"Advertising"}'::jsonb, 'expense', false, '637', 1260),
  ('PE', 'default', '639', 'Otros servicios prestados por terceros', '{"en":"Other third-party services"}'::jsonb, 'expense', false, '63', 1270),
  ('PE', 'default', '6391', 'Gastos bancarios', '{"en":"Bank charges"}'::jsonb, 'expense', false, '639', 1280),
  ('PE', 'default', '64', 'Gastos por tributos', '{"en":"Tax expenses"}'::jsonb, 'expense', false, '6', 1290),
  ('PE', 'default', '641', 'Gobierno nacional', '{"en":"National government"}'::jsonb, 'expense', false, '64', 1300),
  ('PE', 'default', '6412', 'Impuesto a las transacciones financieras', '{"en":"Financial transactions tax"}'::jsonb, 'expense', false, '641', 1310),
  ('PE', 'default', '6413', 'Impuesto temporal a los activos netos', '{"en":"Temporary net assets tax"}'::jsonb, 'expense', false, '641', 1320),
  ('PE', 'default', '643', 'Gobierno local', '{"en":"Local government"}'::jsonb, 'expense', false, '64', 1330),
  ('PE', 'default', '6431', 'Impuesto predial', '{"en":"Property tax"}'::jsonb, 'expense', false, '643', 1340),
  ('PE', 'default', '65', 'Otros gastos de gestión', '{"en":"Other management expenses"}'::jsonb, 'expense', false, '6', 1350),
  ('PE', 'default', '651', 'Seguros', '{"en":"Insurance"}'::jsonb, 'expense', false, '65', 1360),
  ('PE', 'default', '659', 'Otros gastos de gestión', '{"en":"Other management expenses"}'::jsonb, 'expense', false, '65', 1370),
  ('PE', 'default', '67', 'Gastos financieros', '{"en":"Financial expenses"}'::jsonb, 'expense', false, '6', 1380),
  ('PE', 'default', '673', 'Intereses por préstamos y otras obligaciones', '{"en":"Interest on loans and other liabilities"}'::jsonb, 'expense', false, '67', 1390),
  ('PE', 'default', '6731', 'Préstamos de instituciones financieras y otras entidades', '{"en":"Loans from financial institutions and other entities"}'::jsonb, 'expense', false, '673', 1400),
  ('PE', 'default', '676', 'Diferencia de cambio', '{"en":"Foreign exchange loss"}'::jsonb, 'expense', false, '67', 1410),
  ('PE', 'default', '68', 'Valuación y deterioro de activos y provisiones', '{"en":"Valuation and impairment of assets and provisions"}'::jsonb, 'expense_depreciation', false, '6', 1420),
  ('PE', 'default', '684', 'Depreciación de propiedad, planta y equipo', '{"en":"Depreciation of property, plant and equipment"}'::jsonb, 'expense_depreciation', false, '68', 1430),
  ('PE', 'default', '6841', 'Depreciación de propiedad, planta y equipo – Costo', '{"en":"Depreciation of property, plant and equipment – cost"}'::jsonb, 'expense_depreciation', false, '684', 1440),
  ('PE', 'default', '686', 'Amortización de intangibles', '{"en":"Amortisation of intangible assets"}'::jsonb, 'expense_depreciation', false, '68', 1450),
  ('PE', 'default', '6861', 'Amortización de intangibles – Costo', '{"en":"Amortisation of intangible assets – cost"}'::jsonb, 'expense_depreciation', false, '686', 1460),
  ('PE', 'default', '687', 'Valuación de activos', '{"en":"Valuation of assets"}'::jsonb, 'expense', false, '68', 1470),
  ('PE', 'default', '6871', 'Estimación de cuentas de cobranza dudosa', '{"en":"Allowance for doubtful accounts"}'::jsonb, 'expense', false, '687', 1480),
  ('PE', 'default', '69', 'Costo de ventas', '{"en":"Cost of sales"}'::jsonb, 'expense_direct_cost', false, '6', 1490),
  ('PE', 'default', '691', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'expense_direct_cost', false, '69', 1500),
  ('PE', 'default', '6911', 'Mercaderías – exportación', '{"en":"Merchandise – export"}'::jsonb, 'expense_direct_cost', false, '691', 1530),
  ('PE', 'default', '69111', 'Terceros', '{"en":"Third parties"}'::jsonb, 'expense_direct_cost', false, '6911', 1540),
  ('PE', 'default', '6912', 'Mercaderías – venta local', '{"en":"Merchandise – domestic sale"}'::jsonb, 'expense_direct_cost', false, '691', 1510),
  ('PE', 'default', '69121', 'Terceros', '{"en":"Third parties"}'::jsonb, 'expense_direct_cost', false, '6912', 1520),
  ('PE', 'default', '7', 'Ingresos', '{"en":"Income"}'::jsonb, 'income', false, null, 1570),
  ('PE', 'default', '70', 'Ventas', '{"en":"Sales"}'::jsonb, 'income', false, '7', 1580),
  ('PE', 'default', '701', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 'income', false, '70', 1590),
  ('PE', 'default', '7011', 'Mercaderías – venta de exportación', '{"en":"Merchandise – export sale"}'::jsonb, 'income', false, '701', 1600),
  ('PE', 'default', '7012', 'Mercaderías – venta local', '{"en":"Merchandise – domestic sale"}'::jsonb, 'income', false, '701', 1610),
  ('PE', 'default', '709', 'Devoluciones sobre ventas', '{"en":"Sales returns"}'::jsonb, 'income', false, '70', 1620),
  ('PE', 'default', '7091', 'Mercaderías – Venta de exportación', '{"en":"Merchandise – export sale"}'::jsonb, 'income', false, '709', 1630),
  ('PE', 'default', '7092', 'Mercaderías – Venta local', '{"en":"Merchandise – domestic sale"}'::jsonb, 'income', false, '709', 1640),
  ('PE', 'default', '73', 'Descuentos, rebajas y bonificaciones obtenidos', '{"en":"Discounts, rebates and allowances received"}'::jsonb, 'income', false, '7', 1650),
  ('PE', 'default', '731', 'Descuentos, rebajas y bonificaciones obtenidos', '{"en":"Discounts, rebates and allowances received"}'::jsonb, 'income', false, '73', 1660),
  ('PE', 'default', '7311', 'Terceros', '{"en":"Third parties"}'::jsonb, 'income', false, '731', 1670),
  ('PE', 'default', '75', 'Otros ingresos de gestión', '{"en":"Other operating income"}'::jsonb, 'income_other', false, '7', 1680),
  ('PE', 'default', '759', 'Otros ingresos de gestión', '{"en":"Other operating income"}'::jsonb, 'income_other', false, '75', 1690),
  ('PE', 'default', '7599', 'Otros ingresos de gestión', '{"en":"Other operating income"}'::jsonb, 'income_other', false, '759', 1700),
  ('PE', 'default', '77', 'Ingresos financieros', '{"en":"Financial income"}'::jsonb, 'income_other', false, '7', 1710),
  ('PE', 'default', '772', 'Rendimientos ganados', '{"en":"Earned income"}'::jsonb, 'income_other', false, '77', 1730),
  ('PE', 'default', '7721', 'Depósitos en instituciones financieras', '{"en":"Deposits with financial institutions"}'::jsonb, 'income_other', false, '772', 1740),
  ('PE', 'default', '776', 'Diferencia en cambio', '{"en":"Foreign exchange gain"}'::jsonb, 'income_other', false, '77', 1720),
  ('PE', 'default', '88', 'Impuesto a las ganancias', '{"en":"Income tax expense"}'::jsonb, 'expense', false, '6', 1550),
  ('PE', 'default', '881', 'Impuesto a las ganancias – Corriente', '{"en":"Income tax expense – current"}'::jsonb, 'expense', false, '88', 1560)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('PE', 'APE', 'Asiento de apertura', '{"en":"Opening entry"}'::jsonb, 'opening', 60),
  ('PE', 'BAN', 'Bancos', '{"en":"Bank"}'::jsonb, 'bank', 30),
  ('PE', 'CAJ', 'Caja', '{"en":"Cash"}'::jsonb, 'cash', 40),
  ('PE', 'COM', 'Registro de compras', '{"en":"Purchase register"}'::jsonb, 'purchase', 20),
  ('PE', 'DIA', 'Diario', '{"en":"Journal"}'::jsonb, 'general', 50),
  ('PE', 'VEN', 'Registro de ventas', '{"en":"Sales register"}'::jsonb, 'sales', 10)
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
  ('PE', 'PE-C-18', 'Compra gravada, 18 %, con derecho a crédito fiscal', '{"en":"Purchase, taxed, 18 %, with input tax credit"}'::jsonb, 'Adquisición de bienes, servicios o contratos de construcción destinados exclusivamente a operaciones gravadas o de exportación', 'percent', 18, 'purchase', 'domestic', date '2026-01-01', null, 'TUO de la Ley del IGV e ISC, art. 18° — el crédito fiscal está constituido por el IGV consignado en el comprobante de pago que grava la adquisición de bienes, servicios y contratos de construcción, siempre que sean permitidos como costo o gasto de la renta de tercera categoría y se destinen a operaciones gravadas (requisitos sustanciales); art. 19° — el impuesto debe estar consignado por separado en el comprobante, que debe cumplir los requisitos de la Ley del IGV y del Reglamento de Comprobantes de Pago, y la operación anotada en el Registro de Compras (requisitos formales); art. 17° y Ley N.° 32387 — tasa de 15,5 % de IGV más 2,5 % de Impuesto de Promoción Municipal (Decreto Legislativo N.° 776, art. 76°) desde el 1 de enero de 2026, tasa combinada 18 %', 'S', null, 110, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-igv', null, null, null, null),
  ('PE', 'PE-C-18-NOCRED', 'Compra gravada, 18 %, sin derecho a crédito fiscal', '{"en":"Purchase, taxed, 18 %, without input tax credit"}'::jsonb, 'Adquisición gravada destinada a operaciones no gravadas, o que no cumple los requisitos del crédito fiscal', 'percent', 18, 'purchase', 'domestic', date '2026-01-01', null, 'TUO de la Ley del IGV e ISC, art. 18°, inciso b) — el crédito fiscal exige que las adquisiciones se destinen a operaciones gravadas con el impuesto; el IGV de una adquisición destinada a una operación no gravada, o que no cumple los demás requisitos del art. 18° o del art. 19°, no otorga derecho a crédito fiscal y forma parte del costo o gasto de la adquisición (art. 69°, referido al IGV que no constituye costo o gasto para el Impuesto a la Renta salvo esta excepción). El Formulario Virtual N.° 621 no tiene casilla propia para este impuesto no deducible: la base se declara en la casilla 113 y el impuesto queda en el costo de la línea, sin casilla', 'S', null, 120, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ley-igv', null, null, null, null),
  ('PE', 'PE-C-EXO', 'Compra no gravada', '{"en":"Purchase, not taxed"}'::jsonb, 'Adquisición de bienes o servicios exonerados o inafectos del IGV', 'percent', 0, 'purchase', 'exempt', date '2026-01-01', null, 'TUO de la Ley del IGV e ISC, art. 5° y Apéndices I y II — bienes y servicios exonerados; art. 2° — conceptos no gravados (entre otros, la transferencia de bienes usados que efectúan las personas naturales o jurídicas que no realizan actividad empresarial). El Formulario Virtual N.° 621 declara esta adquisición en la casilla 120, «Compras internas no gravadas»', 'E', null, 130, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-igv', null, null, null, null),
  ('PE', 'PE-V-18', 'Venta gravada, 18 %', '{"en":"Sale, taxed, 18 %"}'::jsonb, 'Venta de bienes muebles, prestación de servicios, contratos de construcción o primera venta de inmuebles por el constructor, en el país', 'percent', 18, 'sale', 'domestic', date '2026-01-01', null, 'TUO de la Ley del IGV e ISC (Decreto Supremo N.° 055-99-EF), art. 1° — operaciones gravadas (venta de bienes muebles, prestación o utilización de servicios, contratos de construcción, primera venta de inmuebles por el constructor, importación de bienes) y art. 17° — la tasa del impuesto es 15,5 % desde el 1 de enero de 2026 (Ley N.° 32387, que reduce progresivamente la tasa del IGV del 16 % vigente hasta el 31 de diciembre de 2025); a ella se agrega el 2,5 % del Impuesto de Promoción Municipal del mismo período (Ley de Tributación Municipal, Decreto Legislativo N.° 776, art. 76°, en la redacción de la Ley N.° 32387), que grava las mismas operaciones con las mismas normas del IGV, de modo que la tasa combinada que se traslada en el comprobante de pago es 18 %. El comprobante no desagrega el 15,5 % del 2,5 %; SUNAT recauda ambos como IGV y distribuye el segundo al FONCOMUN', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley-igv', null, null, null, null),
  ('PE', 'PE-V-EXO', 'Venta exonerada', '{"en":"Sale, exempt"}'::jsonb, 'Venta de bienes y servicios comprendidos en los Apéndices I y II de la Ley del IGV', 'percent', 0, 'sale', 'exempt', date '2026-01-01', null, 'TUO de la Ley del IGV e ISC, art. 5° — «están exoneradas del Impuesto General a las Ventas las operaciones contenidas en los Apéndices I y II». El Apéndice II, numeral 2 (texto vigente según el Decreto Supremo N.° 180-2007-EF), exonera el servicio de transporte público terrestre de pasajeros dentro del país, con excepción del transporte ferroviario y aéreo; el Apéndice I exonera, entre otros bienes, ciertos productos agropecuarios, los libros y publicaciones culturales. El paquete declara la exoneración con esta cita genérica; el bien o servicio exonerado concreto y su numeral corresponden a cada operación y no al código — véase el README', 'E', null, 30, 'vat', true, array['supply_nature']::tax_condition[], null, false, false, null, 'ley-igv', null, null, null, null),
  ('PE', 'PE-V-EXP', 'Exportación, inafecta', '{"en":"Export, out of scope"}'::jsonb, 'Exportación de bienes, servicios y contratos de construcción ejecutados en el exterior', 'percent', 0, 'sale', 'export', date '2026-01-01', null, 'TUO de la Ley del IGV e ISC, art. 33° — «la exportación de bienes o servicios, así como los contratos de construcción ejecutados en el exterior, no están afectos al Impuesto General a las Ventas», y los numerales que asimilan a exportación ciertas operaciones realizadas en el país (ventas a establecimientos ubicados en zona internacional de puertos y aeropuertos, hospedaje a no domiciliados, entre otras). El servicio de exportación exige además figurar en el Apéndice V de la misma ley y cumplir los requisitos de su art. 33°, penúltimo párrafo (uso, explotación o aprovechamiento económico fuera del país). El paquete no distingue estos casos especiales: declara la exportación ordinaria de bienes y servicios; véase el README', 'G', null, 20, 'vat', true, array['transport_evidence']::tax_condition[], null, false, false, null, 'ley-igv', null, null, null, null)
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
    ('PE-C-18', 'invoice', 'base', 100, null, '107', array['107']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-C-18', 'invoice', 'tax', 100, '401112', '108', array['108']::text[], 100, 'PE-SUNAT-621', 20),
    ('PE-C-18', 'credit_note', 'base', 100, null, '107', array['107']::text[], -100, 'PE-SUNAT-621', 10),
    ('PE-C-18', 'credit_note', 'tax', 100, '401112', '108', array['108']::text[], -100, 'PE-SUNAT-621', 20),
    ('PE-C-18-NOCRED', 'invoice', 'base', 100, null, '113', array['113']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-C-18-NOCRED', 'invoice', 'tax_on_base', 100, null, null, null, 100, null, 20),
    ('PE-C-18-NOCRED', 'credit_note', 'base', 100, null, '113', array['113']::text[], -100, 'PE-SUNAT-621', 10),
    ('PE-C-18-NOCRED', 'credit_note', 'tax_on_base', 100, null, null, null, -100, null, 20),
    ('PE-C-EXO', 'invoice', 'base', 100, null, '120', array['120']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-C-EXO', 'credit_note', 'base', 100, null, '120', array['120']::text[], -100, 'PE-SUNAT-621', 10),
    ('PE-V-18', 'invoice', 'base', 100, null, '100', array['100']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-V-18', 'invoice', 'tax', 100, '401111', '101', array['101']::text[], 100, 'PE-SUNAT-621', 20),
    ('PE-V-18', 'credit_note', 'base', 100, null, '102', array['102']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-V-18', 'credit_note', 'tax', 100, '401111', '103', array['103']::text[], 100, 'PE-SUNAT-621', 20),
    ('PE-V-EXO', 'invoice', 'base', 100, null, '105', array['105']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-V-EXO', 'credit_note', 'base', 100, null, '105', array['105']::text[], -100, 'PE-SUNAT-621', 10),
    ('PE-V-EXP', 'invoice', 'base', 100, null, '106', array['106']::text[], 100, 'PE-SUNAT-621', 10),
    ('PE-V-EXP', 'credit_note', 'base', 100, null, '106', array['106']::text[], -100, 'PE-SUNAT-621', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'PE' and t.code = v.tax_code
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
  ('PE', 'PE-SUNAT-621', 'Formulario Virtual N.° 621 — IGV Renta mensual (declaración del IGV)', array['month']::declaration_period[], 'month'::declaration_period, date '2026-01-01', null, 'TUO de la Ley del IGV e ISC, art. 29° — el impuesto se determina mensualmente deduciendo del impuesto bruto de cada período el crédito fiscal; Código Tributario (Decreto Supremo N.° 133-2013-EF), art. 29° — los tributos de determinación mensual se declaran y pagan dentro de los primeros doce días hábiles del mes siguiente, según el cronograma que aprueba la SUNAT. El Formulario Virtual N.° 621 sustituyó al PDT N.° 621 y es de uso obligatorio desde el período enero de 2016; las casillas de este paquete son las de la «Ayuda para el registro del Formulario Virtual N.° 621» de la SUNAT', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Código Tributario, art. 29°, penúltimo párrafo — la SUNAT puede establecer cronogramas de vencimiento con carácter general, que en la práctica escalonan la fecha según el último dígito del RUC del contribuyente; el cronograma de cada año se aprueba por resolución de superintendencia (para 2026, la Resolución de Superintendencia que fija el cronograma de vencimientos mensuales del ejercicio 2026). El día exacto depende del RUC de cada contribuyente y no de una regla que el paquete pueda calcular', 'cronograma-2026', null)
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
  ('PE', 'PE-SUNAT-621', '100', 'base', 'Ventas netas gravadas', '{"en":"Net taxed sales"}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 100 – Ventas netas gravadas (Base imponible)»: monto correspondiente a las operaciones gravadas, sin incluir el impuesto', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '101', 'tax', 'Ventas netas gravadas — IGV', '{"en":"Net taxed sales — VAT"}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 101 – Ventas netas gravadas (Tributo)»: el sistema calcula el IGV que resulta de aplicar la tasa del impuesto al monto declarado en la casilla 100', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '102', 'base', 'Descuentos concedidos y devolución de ventas', '{"en":"Discounts granted and sales returns"}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 102 – Descuentos concedidos y devolución de ventas (Base imponible)»: monto por descuentos concedidos y devoluciones efectuadas por las ventas realizadas y declaradas en períodos anteriores', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '103', 'tax', 'Descuentos concedidos y devolución de ventas — IGV', '{"en":"Discounts granted and sales returns — VAT"}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 103 – Descuentos concedidos y devolución de ventas (Tributo)»: el sistema calcula el IGV que resulta de aplicar la tasa del impuesto al monto declarado en la casilla 102', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '106', 'base', 'Exportaciones facturadas en el período', '{"en":"Exports invoiced in the period"}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 106: Exportaciones facturadas en el periodo»: monto neto de las exportaciones que cuenten con comprobante de pago o notas de débito y crédito, luego de deducir las devoluciones', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '105', 'base', 'Ventas no gravadas (sin considerar exportaciones)', '{"en":"Sales not taxed (excluding exports)"}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 105: Ventas no gravadas (sin considerar exportaciones)»: monto de las ventas de bienes y servicios no gravados, sin incluir las exportaciones, netos de descuentos y rebajas; se entiende por ventas no gravadas a las que se encuentran exoneradas o inafectas del IGV', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '107', 'base', 'Compras netas destinadas a ventas gravadas', '{"en":"Net purchases allocated to taxed sales"}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 107 - Compras netas destinadas a ventas gravadas (Base imponible)»: monto de las adquisiciones internas de bienes o servicios gravadas, netas de descuentos, devoluciones y/o reintegros, destinadas exclusivamente a ventas gravadas', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '108', 'tax', 'Compras netas destinadas a ventas gravadas — crédito fiscal', '{"en":"Net purchases allocated to taxed sales — input tax credit"}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 108 - Compras netas destinadas a ventas gravadas (Tributo)»: el sistema calcula el IGV que resulta de aplicar la tasa del impuesto al monto declarado en la casilla 107', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '113', 'base', 'Compras netas destinadas a ventas no gravadas', '{"en":"Net purchases allocated to sales not taxed"}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 113 - Compras netas destinadas a ventas no gravadas (Base imponible)»: monto de compras internas totales de bienes y servicios que hayan sido destinadas a operaciones no gravadas exclusivamente, netas de descuentos, devoluciones y/o reintegros', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '120', 'base', 'Compras internas no gravadas', '{"en":"Domestic purchases not taxed"}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621 — «Casilla 120 - Compras netas internas no gravadas»: monto total de las adquisiciones internas de bienes o servicios no gravadas, netas de descuentos y devoluciones', 'form-621-ayuda'),
  ('PE', 'PE-SUNAT-621', '140', 'total', 'Impuesto resultante o saldo a favor', '{"en":"Tax due or credit balance"}'::jsonb, 110, null, array['101']::text[], array['103', '108']::text[], null, null, false, false, null, 'Ayuda del Formulario Virtual N.° 621, sección III «Determinación de la deuda» — «Casilla Impuesto Resultante o Saldo a Favor (casillas 140, …): el sistema calcula para la casilla 140 el importe resultante de calcular las ventas menos las compras»: IGV de ventas (casilla 101) menos IGV de descuentos y devoluciones de ventas (casilla 103) menos crédito fiscal (casilla 108). Un resultado positivo es tributo a pagar y uno negativo, saldo a favor del período; este paquete no declara la compensación con el saldo a favor de períodos anteriores (casillas 145/184), las percepciones ni las retenciones del IGV, que se llevan en cuentas y casillas propias fuera del alcance de este paquete — véase el README', 'form-621-ayuda')
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
  ('PE-EF-ER', 'PE', 'default', 'Estado de Resultados (por naturaleza)', 'income_statement', 'PE-PCGE', date '1970-01-01', null, 'Ley General de Sociedades, Ley N.° 26887, art. 223 — los estados financieros se preparan y presentan de conformidad con las disposiciones legales sobre la materia y con principios de contabilidad generalmente aceptados en el país, que remiten a las Normas Internacionales de Información Financiera (NIIF) oficializadas por el Consejo Normativo de Contabilidad. El Plan Contable General Empresarial presenta el resultado por naturaleza del gasto (elementos 6 y 7); la reclasificación por función (administración, ventas) que un estado por función exige se hace, cuando corresponde, con las cuentas 94 a 96, que este paquete no incorpora — véase el README.', 'lgs'),
  ('PE-EF-ESF', 'PE', 'default', 'Estado de Situación Financiera', 'balance_sheet', 'PE-PCGE', date '1970-01-01', null, 'Ley General de Sociedades, Ley N.° 26887, art. 223 — los estados financieros se preparan y presentan de conformidad con las disposiciones legales sobre la materia y con principios de contabilidad generalmente aceptados en el país, que remiten a las Normas Internacionales de Información Financiera (NIIF) oficializadas por el Consejo Normativo de Contabilidad.', 'lgs')
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
  ('PE-EF-ER', 'ING', null, 'Ingresos de operación', '{"en":"Operating income"}'::jsonb, 10, 1, true, array['70', '73', '75']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ER', '70', 'ING', 'Ventas', '{"en":"Sales"}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '73', 'ING', 'Descuentos, rebajas y bonificaciones obtenidos', '{"en":"Discounts, rebates and allowances received"}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '75', 'ING', 'Otros ingresos de gestión', '{"en":"Other operating income"}'::jsonb, 40, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', 'CV', null, 'Costo de ventas', '{"en":"Cost of sales"}'::jsonb, 50, 1, true, array['60', '69']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ER', '60', 'CV', 'Compras', '{"en":"Purchases"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '69', 'CV', 'Costo de ventas', '{"en":"Cost of sales"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', 'UB', null, 'Utilidad (pérdida) bruta', '{"en":"Gross profit (loss)"}'::jsonb, 80, 1, true, array['ING']::text[], array['CV']::text[], null, null, null),
  ('PE-EF-ER', 'GO', null, 'Gastos operativos', '{"en":"Operating expenses"}'::jsonb, 90, 1, true, array['62', '63', '64', '65', '68']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ER', '62', 'GO', 'Gastos de personal, directores y gerentes', '{"en":"Personnel, directors and management expenses"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '63', 'GO', 'Gastos de servicios prestados por terceros', '{"en":"Third-party services expense"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '64', 'GO', 'Gastos por tributos', '{"en":"Tax expenses"}'::jsonb, 120, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '65', 'GO', 'Otros gastos de gestión', '{"en":"Other management expenses"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '68', 'GO', 'Valuación y deterioro de activos y provisiones', '{"en":"Valuation and impairment of assets and provisions"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', 'UO', null, 'Utilidad (pérdida) de operación', '{"en":"Operating profit (loss)"}'::jsonb, 150, 1, true, array['UB']::text[], array['GO']::text[], null, null, null),
  ('PE-EF-ER', 'RF', null, 'Resultado financiero', '{"en":"Financial result"}'::jsonb, 160, 1, true, array['77']::text[], array['67']::text[], null, null, null),
  ('PE-EF-ER', '77', 'RF', 'Ingresos financieros', '{"en":"Financial income"}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', '67', 'RF', 'Gastos financieros', '{"en":"Financial expenses"}'::jsonb, 180, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', 'UAI', null, 'Utilidad (pérdida) antes de impuesto a las ganancias', '{"en":"Profit (loss) before income tax"}'::jsonb, 190, 1, true, array['UO', 'RF']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ER', '88', null, 'Impuesto a las ganancias', '{"en":"Income tax expense"}'::jsonb, 200, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ER', 'UN', null, 'Utilidad (pérdida) neta del ejercicio', '{"en":"Net profit (loss) for the year"}'::jsonb, 210, 1, true, array['UAI']::text[], array['88']::text[], null, null, null),
  ('PE-EF-ESF', 'ACT', null, 'Activo', '{"en":"Assets"}'::jsonb, 10, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', 'AC', 'ACT', 'Activo corriente', '{"en":"Current assets"}'::jsonb, 20, 1, true, array['10', '12', '14', '16', '18', '19', '20', '29', 'IGVCF']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', '10', 'AC', 'Efectivo y equivalentes de efectivo', '{"en":"Cash and cash equivalents"}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '12', 'AC', 'Cuentas por cobrar comerciales – Terceros', '{"en":"Trade receivables – third parties"}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '14', 'AC', 'Cuentas por cobrar al personal, accionistas y directores', '{"en":"Receivables from staff, shareholders and directors"}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '16', 'AC', 'Cuentas por cobrar diversas – Terceros', '{"en":"Other receivables – third parties"}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '18', 'AC', 'Servicios y otros contratados por anticipado', '{"en":"Prepaid services and other prepayments"}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '19', 'AC', 'Estimación de cuentas de cobranza dudosa', '{"en":"Allowance for doubtful accounts"}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '20', 'AC', 'Mercaderías', '{"en":"Merchandise"}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '29', 'AC', 'Desvalorización de inventarios', '{"en":"Inventory write-down"}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', 'IGVCF', 'AC', 'Crédito fiscal y saldo a favor del IGV', '{"en":"VAT input tax credit and credit balance"}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara. El plan contable no separa cuentas de dos dígitos para el crédito fiscal y el saldo a favor: 401112 y 401114 son subcuentas de la cuenta 40111 «IGV – Cuenta propia» abiertas por este paquete — véase el README.', 'pcge-2019'),
  ('PE-EF-ESF', 'ANC', 'ACT', 'Activo no corriente', '{"en":"Non-current assets"}'::jsonb, 120, 1, true, array['33', '34', '37', '39']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', '33', 'ANC', 'Propiedad, planta y equipo', '{"en":"Property, plant and equipment"}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '34', 'ANC', 'Intangibles', '{"en":"Intangible assets"}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '37', 'ANC', 'Activo diferido', '{"en":"Deferred assets"}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '39', 'ANC', 'Depreciación y amortización acumulados', '{"en":"Accumulated depreciation and amortisation"}'::jsonb, 160, 1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', 'PYP', null, 'Pasivo y patrimonio', '{"en":"Liabilities and equity"}'::jsonb, 170, 1, true, array['PAS', 'PAT']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', 'PAS', 'PYP', 'Pasivo', '{"en":"Liabilities"}'::jsonb, 180, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', 'PC', 'PAS', 'Pasivo corriente', '{"en":"Current liabilities"}'::jsonb, 190, 1, true, array['IGVDEB', '41', '42', '46']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', 'IGVDEB', 'PC', 'Tributos por pagar', '{"en":"Taxes payable"}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara. 401111 y 401113 son subcuentas de 40111 abiertas por este paquete; 40171 y 403 son cuentas del propio agrupador (impuesto a la renta de tercera categoría, ESSALUD, ONP).', 'pcge-2019'),
  ('PE-EF-ESF', '41', 'PC', 'Remuneraciones y participaciones por pagar', '{"en":"Payroll and profit-sharing payable"}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '42', 'PC', 'Cuentas por pagar comerciales – Terceros', '{"en":"Trade payables – third parties"}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '46', 'PC', 'Cuentas por pagar diversas – Terceros', '{"en":"Other payables – third parties"}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', 'PNC', 'PAS', 'Pasivo no corriente', '{"en":"Non-current liabilities"}'::jsonb, 240, 1, true, array['45', '48']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', '45', 'PNC', 'Obligaciones financieras', '{"en":"Financial liabilities"}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '48', 'PNC', 'Provisiones', '{"en":"Provisions"}'::jsonb, 260, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', 'PAT', 'PYP', 'Patrimonio neto', '{"en":"Equity"}'::jsonb, 270, 1, true, array['50', '58', '59']::text[], '{}'::text[], null, null, null),
  ('PE-EF-ESF', '50', 'PAT', 'Capital', '{"en":"Share capital"}'::jsonb, 280, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '58', 'PAT', 'Reservas', '{"en":"Reserves"}'::jsonb, 290, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019'),
  ('PE-EF-ESF', '59', 'PAT', 'Resultados acumulados', '{"en":"Retained earnings"}'::jsonb, 300, -1, false, '{}'::text[], '{}'::text[], null, 'Resolución N.° 002-2019-EF/30 del Consejo Normativo de Contabilidad — Plan Contable General Empresarial modificado 2019, cuyas cuentas de mayor (dos dígitos) agrupan los elementos 1 a 7; la correspondencia con las líneas del estado es la que aquí se declara.', 'pcge-2019')
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
    ('PE-EF-ER', '70', 10, 'code_prefix', '70', null, null, 'any'),
    ('PE-EF-ER', '73', 10, 'code_prefix', '73', null, null, 'any'),
    ('PE-EF-ER', '75', 10, 'code_prefix', '75', null, null, 'any'),
    ('PE-EF-ER', '60', 10, 'code_prefix', '60', null, null, 'any'),
    ('PE-EF-ER', '69', 10, 'code_prefix', '69', null, null, 'any'),
    ('PE-EF-ER', '62', 10, 'code_prefix', '62', null, null, 'any'),
    ('PE-EF-ER', '63', 10, 'code_prefix', '63', null, null, 'any'),
    ('PE-EF-ER', '64', 10, 'code_prefix', '64', null, null, 'any'),
    ('PE-EF-ER', '65', 10, 'code_prefix', '65', null, null, 'any'),
    ('PE-EF-ER', '68', 10, 'code_prefix', '68', null, null, 'any'),
    ('PE-EF-ER', '77', 10, 'code_prefix', '77', null, null, 'any'),
    ('PE-EF-ER', '67', 10, 'code_prefix', '67', null, null, 'any'),
    ('PE-EF-ER', '88', 10, 'code_prefix', '88', null, null, 'any'),
    ('PE-EF-ESF', '10', 10, 'code_prefix', '10', null, null, 'any'),
    ('PE-EF-ESF', '12', 10, 'code_prefix', '12', null, null, 'any'),
    ('PE-EF-ESF', '14', 10, 'code_prefix', '14', null, null, 'any'),
    ('PE-EF-ESF', '16', 10, 'code_prefix', '16', null, null, 'any'),
    ('PE-EF-ESF', '18', 10, 'code_prefix', '18', null, null, 'any'),
    ('PE-EF-ESF', '19', 10, 'code_prefix', '19', null, null, 'any'),
    ('PE-EF-ESF', '20', 10, 'code_prefix', '20', null, null, 'any'),
    ('PE-EF-ESF', '29', 10, 'code_prefix', '29', null, null, 'any'),
    ('PE-EF-ESF', 'IGVCF', 10, 'account_code', '401112', null, null, 'any'),
    ('PE-EF-ESF', 'IGVCF', 20, 'account_code', '401114', null, null, 'any'),
    ('PE-EF-ESF', '33', 10, 'code_prefix', '33', null, null, 'any'),
    ('PE-EF-ESF', '34', 10, 'code_prefix', '34', null, null, 'any'),
    ('PE-EF-ESF', '37', 10, 'code_prefix', '37', null, null, 'any'),
    ('PE-EF-ESF', '39', 10, 'code_prefix', '39', null, null, 'any'),
    ('PE-EF-ESF', 'IGVDEB', 10, 'account_code', '401111', null, null, 'any'),
    ('PE-EF-ESF', 'IGVDEB', 20, 'account_code', '401113', null, null, 'any'),
    ('PE-EF-ESF', 'IGVDEB', 30, 'code_prefix', '4017', null, null, 'any'),
    ('PE-EF-ESF', 'IGVDEB', 40, 'code_prefix', '403', null, null, 'any'),
    ('PE-EF-ESF', '41', 10, 'code_prefix', '41', null, null, 'any'),
    ('PE-EF-ESF', '42', 10, 'code_prefix', '42', null, null, 'any'),
    ('PE-EF-ESF', '46', 10, 'code_prefix', '46', null, null, 'any'),
    ('PE-EF-ESF', '45', 10, 'code_prefix', '45', null, null, 'any'),
    ('PE-EF-ESF', '48', 10, 'code_prefix', '48', null, null, 'any'),
    ('PE-EF-ESF', '50', 10, 'code_prefix', '50', null, null, 'any'),
    ('PE-EF-ESF', '58', 10, 'code_prefix', '58', null, null, 'any'),
    ('PE-EF-ESF', '59', 10, 'code_prefix', '59', null, null, 'any')
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
  ('PE', 'Perú', '{"en":"Peru"}'::jsonb, array['es', 'en']::text[], 'PEN', '1212', '4212', '1699', '659', '5911', '7012', '6011', '1041', '101', 'VEN', 'COM', 'DIA', 'es', 'retained_earnings', null, null, '5921', 'APE', default, default, '776', '676', null, null, null, null, '401113', '401114', 'Asiento de apertura', 'month'::declaration_period)
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
  numbering_legal_reference     = 'Reglamento de Comprobantes de Pago (Resolución de Superintendencia N.° 007-99/SUNAT), art. 4° y art. 8°, numeral 1.2 — el comprobante de pago se identifica por una serie (cuatro caracteres) y un número correlativo, que se emite en estricto orden correlativo y ascendente dentro de cada serie, sin saltos permitidos salvo los que el propio reglamento admite; el correlativo no se reinicia cada año. El número que declara este paquete es el de la pieza contable, correlativo por diario, y no el del comprobante de pago propiamente dicho, que numera SUNAT o el sistema del emisor autorizado y no Ekwo — véase «Ekwo no emite un comprobante de pago peruano»',
  numbering_source_key          = 'rcp',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'TUO de la Ley del IGV e ISC, art. 4° — en la venta de bienes, la obligación tributaria nace en la fecha en que se emita el comprobante de pago o en la fecha en que se entregue el bien, lo que ocurra primero; en la prestación de servicios, en la fecha en que se emita el comprobante de pago o en la fecha en que se percibe la retribución, lo que ocurra primero. El Reglamento de Comprobantes de Pago exige emitir el comprobante en el momento de la entrega del bien o, en los servicios, a la culminación del servicio o antes, de modo que la emisión del comprobante coincide en la práctica con el hecho que la ley toma como principio o lo antecede; el paquete declara invoice_if_issued por esa razón. Queda sin representar en este paquete el caso en que el servicio se cobra antes de emitirse el comprobante, que adelantaría el nacimiento de la obligación a la fecha de cobro — véase el README',
  tax_point_source_key          = 'ley-igv',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Código Tributario, art. 87°, numeral 4 — el deudor tributario debe llevar los libros y registros de acuerdo con las normas correspondientes, sin alterar los hechos registrados; Reglamento de Comprobantes de Pago, art. 10° — un comprobante de pago solo se anula, después de emitido, mediante una nota de crédito que lo sustente. Un documento contabilizado se anula con una nota de crédito que lo nombra, nunca volviendo a borrador',
  posted_edit_policy_source_key = 'rcp',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'El comprobante de pago peruano exigido para toda venta, servicio o exportación es, para casi todo contribuyente, un comprobante de pago electrónico (factura electrónica, boleta de venta electrónica y sus notas de crédito y débito electrónicas) del Sistema de Emisión Electrónica (SEE) de SUNAT: Reglamento de Comprobantes de Pago (Resolución de Superintendencia N.° 007-99/SUNAT); Resolución de Superintendencia N.° 300-2014/SUNAT, que crea el SEE desde los sistemas del contribuyente; Resolución de Superintendencia N.° 155-2017/SUNAT, que designa emisores electrónicos automáticamente por su volumen anual de ingresos o de exportaciones (75 UIT o 150 UIT en el año base, según el supuesto) y sus prórrogas sucesivas, que entre 2022 y 2023 alcanzaron a la generalidad de los contribuyentes del Régimen General, del Régimen MYPE Tributario y del Régimen Especial. El comprobante solo existe una vez que su XML es enviado a SUNAT o a un Operador de Servicios Electrónicos (OSE) autorizado, que lo valida antes o inmediatamente después de la emisión (control de tipo «clearance», no un intercambio directo entre empresas). Ekwo no genera, no envía ni valida el XML del comprobante de pago electrónico: ningún componente de packages/formats habla con SUNAT ni con un OSE. Por eso profile y mandatory_from quedan vacíos aunque la obligación exista: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe y transmite por Peppol, y el comprobante de pago electrónico peruano no es ni lo uno ni lo otro; el formato tampoco tiene una palabra para «válido solo tras la validación de SUNAT o de un OSE» — véase «Ekwo no emite un comprobante de pago peruano» y docs/international.md. El RUC identifica al emisor y al receptor y no tiene código ISO 6523 propio: party_scheme y vat_scheme quedan vacíos',
  einvoice_source_key           = 'see-clearance',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = null,
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'PE';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('PE', 'cpe_not_issued', 'always', 'Este documento no es un comprobante de pago electrónico: no ha sido validado por SUNAT ni por un Operador de Servicios Electrónicos (OSE) y no tiene el código de generación ni el resumen diario que exige el Sistema de Emisión Electrónica. Solo el comprobante de pago electrónico válido sustenta la operación para efectos tributarios.', '{"en":"This document is not an electronic payment voucher: it has not been validated by SUNAT or by an Electronic Services Operator (OSE) and carries none of the codes the Electronic Emission System requires. Only a valid electronic payment voucher supports the operation for tax purposes."}'::jsonb, 10, date '1970-01-01', null, 'Reglamento de Comprobantes de Pago (Resolución de Superintendencia N.° 007-99/SUNAT), art. 1° — solo se consideran comprobantes de pago, siempre que cumplan los requisitos de ley, los documentos que allí se señalan, entre ellos el comprobante de pago electrónico; Resolución de Superintendencia N.° 155-2017/SUNAT y las normas del Sistema de Emisión Electrónica — el comprobante de pago electrónico se genera, se envía a SUNAT o a un OSE para su validación y solo entonces tiene esa calidad. Ekwo no emite, no envía ni valida comprobantes de pago electrónicos: ningún componente de packages/formats genera el documento que el Sistema de Emisión Electrónica exige — véase «Ekwo no emite un comprobante de pago peruano»'),
  ('PE', 'export', 'export', 'Operación de exportación, inafecta al Impuesto General a las Ventas (artículo 33° del Texto Único Ordenado de la Ley del IGV e ISC).', '{"en":"Export operation, out of the scope of the General Sales Tax (article 33 of the consolidated text of the VAT and Excise Tax Act)."}'::jsonb, 20, date '1970-01-01', null, 'TUO de la Ley del IGV e ISC, art. 33° — la exportación de bienes o servicios, así como los contratos de construcción ejecutados en el exterior, no están afectos al Impuesto General a las Ventas'),
  ('PE', 'exempt', 'exempt', 'Operación exonerada del Impuesto General a las Ventas, comprendida en los Apéndices I o II del Texto Único Ordenado de la Ley del IGV e ISC (artículo 5°).', '{"en":"Operation exempt from the General Sales Tax, listed in Appendix I or II of the consolidated text of the VAT and Excise Tax Act (article 5)."}'::jsonb, 30, date '1970-01-01', null, 'TUO de la Ley del IGV e ISC, art. 5° — están exoneradas del Impuesto General a las Ventas las operaciones contenidas en los Apéndices I y II')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
