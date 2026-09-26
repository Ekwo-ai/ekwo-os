-- Ekwo OS — Dominican Republic: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/do at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build do`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Código Tributario de la República Dominicana (Ley No. 11-92), Título III — Del Impuesto sobre Transferencias de Bienes Industrializados y Servicios (ITBIS), en su redacción vigente (Dirección General de Impuestos Internos (DGII))
--     https://dgii.gov.do/legislacion/codigotributario/cdigo%20tributario/titulo3.pdf
--   Ley No. 253-12, de fecha 9 de noviembre de 2012, sobre Fortalecimiento de la Capacidad Recaudatoria del Estado para la Sostenibilidad Fiscal y el Desarrollo Sostenible — modifica los artículos 341, 343, 344 y 345 del Código Tributario (Congreso Nacional de la República Dominicana)
--     https://dgii.gov.do/legislacion/codigotributario/cdigo%20tributario/titulo3.pdf
--   ITBIS — Impuesto sobre Transferencias de Bienes Industrializados y Servicios, ficha del ciclo del contribuyente (Dirección General de Impuestos Internos (DGII))
--     https://dgii.gov.do/cicloContribuyente/obligacionesTributarias/principalesImpuestos/Paginas/Itbis.aspx
--   Formulario IT-1 — Declaración Jurada y/o Pago del Impuesto sobre Transferencias de Bienes Industrializados y Servicios, e Instructivo de Llenado del Formulario IT-1 (2020) (Dirección General de Impuestos Internos (DGII))
--     https://dgii.gov.do/herramientas/formularios/formularioDeclaraciones/Paginas/ITBIS.aspx
--   Instructivo de la Declaración Jurada del Impuesto sobre la Renta Persona Jurídica (IR-2) y sus Anexos — Anexo A-1 (Balance General) y Anexo B-1 (Estado de Resultados) para los sectores manufactura, comercio y agropecuaria (Dirección General de Impuestos Internos (DGII))
--     https://dgii.gov.do/publicacionesOficiales/bibliotecaVirtual/contribuyentes/isr/ISR%20Persona%20Jurdica/9-Instructivo-IR-2-y-ANEXOS.pdf
--   Resolución de confirmación de la implementación de las Normas Internacionales de Información Financiera para Pequeñas y Medianas Entidades (NIIF para PYMES), Acta 22-2014 (Instituto de Contadores Públicos Autorizados de la República Dominicana (ICPARD))
--     https://icpard.org/wp-content/uploads/2022/01/10-RESOLUCION-CONFIRMACION-IMPLEMENTACION-DE-LAS-NIIFS-ACTA-22-2014.pdf
--   Ley No. 32-23, de fecha 16 de mayo de 2023, de Facturación Electrónica de la República Dominicana (Congreso Nacional de la República Dominicana / Dirección General de Impuestos Internos (DGII))
--     https://dgii.gov.do/cicloContribuyente/facturacion/comprobantesFiscalesElectronicosE-CF/Paginas/Listados-contribuyentes-obligados-implementar-facturacion-electronica.aspx
--   Calendario y avisos de obligatoriedad de la facturación electrónica (e-CF) por categoría de contribuyente (Dirección General de Impuestos Internos (DGII))
--     https://dgii.gov.do/cicloContribuyente/facturacion/comprobantesFiscalesElectronicosE-CF/Paginas/default.aspx
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('DO', 'Dominican Republic', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, 'dfd92847b5e67c66f24f0a9338d02a2ded07f83daaf82610b49e243db38c46bc', '[{"key":"ct-titulo3","title":"Código Tributario de la República Dominicana (Ley No. 11-92), Título III — Del Impuesto sobre Transferencias de Bienes Industrializados y Servicios (ITBIS), en su redacción vigente","publisher":"Dirección General de Impuestos Internos (DGII)","url":"https://dgii.gov.do/legislacion/codigotributario/cdigo%20tributario/titulo3.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"ley253-12","title":"Ley No. 253-12, de fecha 9 de noviembre de 2012, sobre Fortalecimiento de la Capacidad Recaudatoria del Estado para la Sostenibilidad Fiscal y el Desarrollo Sostenible — modifica los artículos 341, 343, 344 y 345 del Código Tributario","publisher":"Congreso Nacional de la República Dominicana","url":"https://dgii.gov.do/legislacion/codigotributario/cdigo%20tributario/titulo3.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"dgii-itbis","title":"ITBIS — Impuesto sobre Transferencias de Bienes Industrializados y Servicios, ficha del ciclo del contribuyente","publisher":"Dirección General de Impuestos Internos (DGII)","url":"https://dgii.gov.do/cicloContribuyente/obligacionesTributarias/principalesImpuestos/Paginas/Itbis.aspx","consulted_on":"2026-09-26","kind":"guidance"},{"key":"form-it1","title":"Formulario IT-1 — Declaración Jurada y/o Pago del Impuesto sobre Transferencias de Bienes Industrializados y Servicios, e Instructivo de Llenado del Formulario IT-1 (2020)","publisher":"Dirección General de Impuestos Internos (DGII)","url":"https://dgii.gov.do/herramientas/formularios/formularioDeclaraciones/Paginas/ITBIS.aspx","consulted_on":"2026-09-26","kind":"form"},{"key":"ir2-instructivo","title":"Instructivo de la Declaración Jurada del Impuesto sobre la Renta Persona Jurídica (IR-2) y sus Anexos — Anexo A-1 (Balance General) y Anexo B-1 (Estado de Resultados) para los sectores manufactura, comercio y agropecuaria","publisher":"Dirección General de Impuestos Internos (DGII)","url":"https://dgii.gov.do/publicacionesOficiales/bibliotecaVirtual/contribuyentes/isr/ISR%20Persona%20Jurdica/9-Instructivo-IR-2-y-ANEXOS.pdf","consulted_on":"2026-09-26","kind":"form"},{"key":"icpard-niif","title":"Resolución de confirmación de la implementación de las Normas Internacionales de Información Financiera para Pequeñas y Medianas Entidades (NIIF para PYMES), Acta 22-2014","publisher":"Instituto de Contadores Públicos Autorizados de la República Dominicana (ICPARD)","url":"https://icpard.org/wp-content/uploads/2022/01/10-RESOLUCION-CONFIRMACION-IMPLEMENTACION-DE-LAS-NIIFS-ACTA-22-2014.pdf","consulted_on":"2026-09-26","kind":"guidance"},{"key":"ley32-23","title":"Ley No. 32-23, de fecha 16 de mayo de 2023, de Facturación Electrónica de la República Dominicana","publisher":"Congreso Nacional de la República Dominicana / Dirección General de Impuestos Internos (DGII)","url":"https://dgii.gov.do/cicloContribuyente/facturacion/comprobantesFiscalesElectronicosE-CF/Paginas/Listados-contribuyentes-obligados-implementar-facturacion-electronica.aspx","consulted_on":"2026-09-26","kind":"law"},{"key":"dgii-calendario","title":"Calendario y avisos de obligatoriedad de la facturación electrónica (e-CF) por categoría de contribuyente","publisher":"Dirección General de Impuestos Internos (DGII)","url":"https://dgii.gov.do/cicloContribuyente/facturacion/comprobantesFiscalesElectronicosE-CF/Paginas/default.aspx","consulted_on":"2026-09-26","kind":"portal"}]'::jsonb)
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
  ('DO', 'default', 'Catálogo de cuentas de referencia (sin plan único oficial)', '{}'::jsonb, true, 'companies', array['DO-IR2-A1', 'DO-IR2-B1']::text[], null, 'La República Dominicana no impone un catálogo de cuentas único: la Ley No. 479-08 (Sociedades Comerciales) no prescribe una numeración, y desde la Resolución del ICPARD que confirma la implementación de las Normas Internacionales de Información Financiera para Pequeñas y Medianas Entidades (NIIF para PYMES), a partir del 1 de enero de 2014, cada entidad clasificada en los grupos correspondientes define su propio catálogo bajo NIIF o NIIF para PYMES. Este paquete usa, como catálogo propio, una numeración construida para este proyecto — sin pretender ser oficial — organizada para calzar con los renglones del Anexo A-1 (Balance General) y del Anexo B-1 (Estado de Resultados) que la Dirección General de Impuestos Internos (DGII) exige como anexos de la Declaración Jurada del Impuesto sobre la Renta (IR-2) de toda persona jurídica del sector de manufactura, comercio o agropecuaria: la identidad de agrupación es la asociación, no una obligación legal de usar precisamente esta numeración, de la misma manera que el paquete de Colombia usa una selección del Plan Único de Cuentas como catálogo propio tras la convergencia a NIIF', 'icpard-niif')
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
  ('DO', 'default', '11', 'Disponible', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('DO', 'default', '1101', 'Caja', '{}'::jsonb, 'asset_cash', false, '11', 20),
  ('DO', 'default', '110101', 'Caja General', '{}'::jsonb, 'asset_cash', false, '1101', 30),
  ('DO', 'default', '1102', 'Bancos', '{}'::jsonb, 'asset_cash', false, '11', 40),
  ('DO', 'default', '110201', 'Banco Cuenta Corriente DOP', '{}'::jsonb, 'asset_cash', false, '1102', 50),
  ('DO', 'default', '12', 'Cuentas por Cobrar', '{}'::jsonb, 'asset_current', false, null, 60),
  ('DO', 'default', '1201', 'Clientes', '{}'::jsonb, 'asset_receivable', true, '12', 70),
  ('DO', 'default', '1202', 'Cuentas por Cobrar a Relacionadas', '{}'::jsonb, 'asset_current', false, '12', 80),
  ('DO', 'default', '1203', 'Otras Cuentas por Cobrar', '{}'::jsonb, 'asset_current', false, '12', 90),
  ('DO', 'default', '120301', 'Anticipo de Impuesto Sobre la Renta', '{}'::jsonb, 'asset_current', false, '1203', 100),
  ('DO', 'default', '120302', 'ITBIS Saldo a Favor', '{}'::jsonb, 'asset_current', true, '1203', 110),
  ('DO', 'default', '1204', 'Provisión para Cuentas Incobrables', '{}'::jsonb, 'asset_current', false, '12', 120),
  ('DO', 'default', '13', 'Inventarios', '{}'::jsonb, 'asset_current', false, null, 130),
  ('DO', 'default', '1301', 'Inventario de Mercancías', '{}'::jsonb, 'asset_current', false, '13', 140),
  ('DO', 'default', '1302', 'Inventario de Materia Prima', '{}'::jsonb, 'asset_current', false, '13', 150),
  ('DO', 'default', '1303', 'Inventario de Productos en Proceso', '{}'::jsonb, 'asset_current', false, '13', 160),
  ('DO', 'default', '1304', 'Mercancías en Tránsito', '{}'::jsonb, 'asset_current', false, '13', 170),
  ('DO', 'default', '14', 'Gastos Pagados por Anticipado', '{}'::jsonb, 'asset_prepayments', false, null, 180),
  ('DO', 'default', '1401', 'Seguros Pagados por Anticipado', '{}'::jsonb, 'asset_prepayments', false, '14', 190),
  ('DO', 'default', '1402', 'Alquileres Pagados por Anticipado', '{}'::jsonb, 'asset_prepayments', false, '14', 200),
  ('DO', 'default', '15', 'Activo Fijo', '{}'::jsonb, 'asset_fixed', false, null, 210),
  ('DO', 'default', '1501', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '15', 220),
  ('DO', 'default', '1502', 'Edificaciones', '{}'::jsonb, 'asset_fixed', false, '15', 230),
  ('DO', 'default', '1503', 'Automóviles y Equipos de Transporte (Categoría 2)', '{}'::jsonb, 'asset_fixed', false, '15', 240),
  ('DO', 'default', '1504', 'Mobiliario y Equipo de Oficina (Categoría 2)', '{}'::jsonb, 'asset_fixed', false, '15', 250),
  ('DO', 'default', '1505', 'Equipos de Computación (Categoría 2)', '{}'::jsonb, 'asset_fixed', false, '15', 260),
  ('DO', 'default', '1506', 'Otros Activos Fijos (Categoría 3)', '{}'::jsonb, 'asset_fixed', false, '15', 270),
  ('DO', 'default', '1507', 'Depreciación Acumulada de Activos Fijos', '{}'::jsonb, 'asset_fixed', false, '15', 280),
  ('DO', 'default', '16', 'Inversiones', '{}'::jsonb, 'asset_non_current', false, null, 290),
  ('DO', 'default', '1601', 'Depósitos a Plazo', '{}'::jsonb, 'asset_non_current', false, '16', 300),
  ('DO', 'default', '1602', 'Acciones en Otras Compañías', '{}'::jsonb, 'asset_non_current', false, '16', 310),
  ('DO', 'default', '17', 'Otros Activos', '{}'::jsonb, 'asset_non_current', false, null, 320),
  ('DO', 'default', '1701', 'Activos Intangibles', '{}'::jsonb, 'asset_non_current', false, '17', 330),
  ('DO', 'default', '1702', 'Impuesto Sobre la Renta Diferido', '{}'::jsonb, 'asset_non_current', false, '17', 340),
  ('DO', 'default', '21', 'Pasivo Corriente', '{}'::jsonb, 'liability_current', false, null, 350),
  ('DO', 'default', '2101', 'Préstamos por Pagar a Corto Plazo', '{}'::jsonb, 'liability_current', false, '21', 360),
  ('DO', 'default', '2102', 'Proveedores', '{}'::jsonb, 'liability_payable', true, '21', 370),
  ('DO', 'default', '2103', 'Cuentas por Pagar Diversas', '{}'::jsonb, 'liability_current', false, '21', 380),
  ('DO', 'default', '2104', 'Impuestos por Pagar', '{}'::jsonb, 'liability_current', false, '21', 390),
  ('DO', 'default', '210401', 'ITBIS Cobrado Tarifa 18%', '{}'::jsonb, 'liability_current', false, '2104', 400),
  ('DO', 'default', '210402', 'ITBIS Cobrado Tarifa 16%', '{}'::jsonb, 'liability_current', false, '2104', 410),
  ('DO', 'default', '210403', 'ITBIS Pagado en Compras Locales de Bienes', '{}'::jsonb, 'liability_current', false, '2104', 420),
  ('DO', 'default', '210404', 'ITBIS Pagado en Servicios', '{}'::jsonb, 'liability_current', false, '2104', 430),
  ('DO', 'default', '210405', 'ITBIS Pagado en Importaciones', '{}'::jsonb, 'liability_current', false, '2104', 440),
  ('DO', 'default', '210406', 'ITBIS por Pagar', '{}'::jsonb, 'liability_current', true, '2104', 450),
  ('DO', 'default', '210407', 'Retenciones de ISR por Pagar', '{}'::jsonb, 'liability_current', false, '2104', 460),
  ('DO', 'default', '210408', 'Retenciones de TSS por Pagar', '{}'::jsonb, 'liability_current', false, '2104', 470),
  ('DO', 'default', '210409', 'Impuesto Sobre la Renta por Pagar', '{}'::jsonb, 'liability_current', false, '2104', 480),
  ('DO', 'default', '2105', 'Cobros Anticipados de Clientes', '{}'::jsonb, 'liability_current', false, '21', 490),
  ('DO', 'default', '2106', 'Cuentas de Orden por Clasificar', '{}'::jsonb, 'liability_current', false, '21', 500),
  ('DO', 'default', '22', 'Pasivo a Largo Plazo', '{}'::jsonb, 'liability_non_current', false, null, 510),
  ('DO', 'default', '2201', 'Préstamos por Pagar a Largo Plazo', '{}'::jsonb, 'liability_non_current', false, '22', 520),
  ('DO', 'default', '2202', 'Préstamos con Accionistas', '{}'::jsonb, 'liability_non_current', false, '22', 530),
  ('DO', 'default', '2203', 'Préstamos con Entidades Relacionadas', '{}'::jsonb, 'liability_non_current', false, '22', 540),
  ('DO', 'default', '31', 'Capital', '{}'::jsonb, 'equity', false, null, 550),
  ('DO', 'default', '3101', 'Capital Suscrito y Pagado', '{}'::jsonb, 'equity', false, '31', 560),
  ('DO', 'default', '32', 'Reservas', '{}'::jsonb, 'equity', false, null, 570),
  ('DO', 'default', '3201', 'Reserva Legal', '{}'::jsonb, 'equity', false, '32', 580),
  ('DO', 'default', '3202', 'Otras Reservas', '{}'::jsonb, 'equity', false, '32', 590),
  ('DO', 'default', '33', 'Resultados', '{}'::jsonb, 'equity_retained', false, null, 600),
  ('DO', 'default', '3301', 'Utilidades Acumuladas', '{}'::jsonb, 'equity_retained', false, '33', 610),
  ('DO', 'default', '3302', 'Pérdidas Acumuladas', '{}'::jsonb, 'equity_retained', false, '33', 620),
  ('DO', 'default', '3303', 'Utilidad del Ejercicio', '{}'::jsonb, 'equity_retained', false, '33', 630),
  ('DO', 'default', '3304', 'Pérdida del Ejercicio', '{}'::jsonb, 'equity_retained', false, '33', 640),
  ('DO', 'default', '3305', 'Superávit por Revaluación de Activos', '{}'::jsonb, 'equity', false, '33', 650),
  ('DO', 'default', '41', 'Ingresos de Operaciones', '{}'::jsonb, 'income', false, null, 660),
  ('DO', 'default', '4101', 'Ingresos por Ventas Locales', '{}'::jsonb, 'income', false, '41', 670),
  ('DO', 'default', '4102', 'Ingresos por Exportaciones', '{}'::jsonb, 'income', false, '41', 680),
  ('DO', 'default', '4103', 'Devoluciones en Ventas', '{}'::jsonb, 'income', false, '41', 690),
  ('DO', 'default', '4104', 'Descuentos en Ventas', '{}'::jsonb, 'income', false, '41', 700),
  ('DO', 'default', '42', 'Ingresos Financieros', '{}'::jsonb, 'income_other', false, null, 710),
  ('DO', 'default', '4201', 'Intereses Ganados', '{}'::jsonb, 'income_other', false, '42', 720),
  ('DO', 'default', '4202', 'Ganancia por Diferencia Cambiaria', '{}'::jsonb, 'income_other', false, '42', 730),
  ('DO', 'default', '4203', 'Ajuste por Redondeo', '{}'::jsonb, 'income_other', false, '42', 740),
  ('DO', 'default', '43', 'Ingresos Extraordinarios', '{}'::jsonb, 'income_other', false, null, 750),
  ('DO', 'default', '4301', 'Ganancia en Venta de Activos Depreciables', '{}'::jsonb, 'income_other', false, '43', 760),
  ('DO', 'default', '4302', 'Otros Ingresos', '{}'::jsonb, 'income_other', false, '43', 770),
  ('DO', 'default', '50', 'Costo de Venta', '{}'::jsonb, 'expense_direct_cost', false, null, 780),
  ('DO', 'default', '5001', 'Costo de Mercancías Vendidas', '{}'::jsonb, 'expense_direct_cost', false, '50', 790),
  ('DO', 'default', '5002', 'Costo de Materia Prima Consumida', '{}'::jsonb, 'expense_direct_cost', false, '50', 800),
  ('DO', 'default', '51', 'Gastos de Personal', '{}'::jsonb, 'expense', false, null, 810),
  ('DO', 'default', '5101', 'Sueldos y Salarios', '{}'::jsonb, 'expense', false, '51', 820),
  ('DO', 'default', '5102', 'Aportes a la Tesorería de la Seguridad Social (TSS)', '{}'::jsonb, 'expense', false, '51', 830),
  ('DO', 'default', '5103', 'Aporte al INFOTEP', '{}'::jsonb, 'expense', false, '51', 840),
  ('DO', 'default', '5104', 'Otros Gastos de Personal', '{}'::jsonb, 'expense', false, '51', 850),
  ('DO', 'default', '52', 'Gastos por Trabajos, Suministros y Servicios', '{}'::jsonb, 'expense', false, null, 860),
  ('DO', 'default', '5201', 'Honorarios Profesionales', '{}'::jsonb, 'expense', false, '52', 870),
  ('DO', 'default', '5202', 'Seguridad, Mensajería y Transporte', '{}'::jsonb, 'expense', false, '52', 880),
  ('DO', 'default', '5203', 'Otros Gastos por Servicios', '{}'::jsonb, 'expense', false, '52', 890),
  ('DO', 'default', '53', 'Arrendamientos', '{}'::jsonb, 'expense', false, null, 900),
  ('DO', 'default', '5301', 'Alquiler de Inmuebles', '{}'::jsonb, 'expense', false, '53', 910),
  ('DO', 'default', '5302', 'Otros Arrendamientos', '{}'::jsonb, 'expense', false, '53', 920),
  ('DO', 'default', '54', 'Gastos de Activos Fijos', '{}'::jsonb, 'expense_depreciation', false, null, 930),
  ('DO', 'default', '5401', 'Depreciación de Activos Fijos', '{}'::jsonb, 'expense_depreciation', false, '54', 940),
  ('DO', 'default', '5402', 'Reparaciones y Mantenimiento', '{}'::jsonb, 'expense', false, '54', 950),
  ('DO', 'default', '5403', 'Amortización de Activos Intangibles', '{}'::jsonb, 'expense', false, '54', 960),
  ('DO', 'default', '55', 'Gastos de Representación', '{}'::jsonb, 'expense', false, null, 970),
  ('DO', 'default', '5501', 'Publicidad y Promoción', '{}'::jsonb, 'expense', false, '55', 980),
  ('DO', 'default', '5502', 'Relaciones Públicas', '{}'::jsonb, 'expense', false, '55', 990),
  ('DO', 'default', '5503', 'Viajes', '{}'::jsonb, 'expense', false, '55', 1000),
  ('DO', 'default', '56', 'Gastos Financieros', '{}'::jsonb, 'expense', false, null, 1010),
  ('DO', 'default', '5601', 'Intereses Pagados', '{}'::jsonb, 'expense', false, '56', 1020),
  ('DO', 'default', '5602', 'Pérdida por Diferencia Cambiaria', '{}'::jsonb, 'expense', false, '56', 1030),
  ('DO', 'default', '5603', 'Comisiones Bancarias', '{}'::jsonb, 'expense', false, '56', 1040),
  ('DO', 'default', '57', 'Gastos Extraordinarios', '{}'::jsonb, 'expense', false, null, 1050),
  ('DO', 'default', '5701', 'Pérdida en Venta de Activos Depreciables', '{}'::jsonb, 'expense', false, '57', 1060),
  ('DO', 'default', '5702', 'Pérdidas por Cuentas Incobrables', '{}'::jsonb, 'expense', false, '57', 1070),
  ('DO', 'default', '58', 'Impuesto Sobre la Renta', '{}'::jsonb, 'expense', false, null, 1080),
  ('DO', 'default', '5801', 'Impuesto Sobre la Renta del Ejercicio', '{}'::jsonb, 'expense', false, '58', 1090)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('DO', 'APE', 'Comprobante de apertura', '{}'::jsonb, 'opening', 60),
  ('DO', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('DO', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('DO', 'COM', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('DO', 'DIA', 'Comprobantes diversos', '{}'::jsonb, 'general', 50),
  ('DO', 'VEN', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('DO', 'DO-P-18-BIENES', 'Compras de bienes a la tarifa general', '{}'::jsonb, 'Adquisición local de bienes gravados a la tarifa general, destinados a operaciones gravadas', 'percent', 18, 'purchase', 'domestic', date '2016-01-01', null, 'Código Tributario, art. 336, párrafo II, y art. 346 (modificado por la Ley No. 147-00) — el contribuyente tiene derecho a deducir del impuesto bruto los importes que por concepto de este impuesto haya adelantado a sus proveedores locales por la adquisición de bienes gravados; el Formulario IT-1 declara el ITBIS pagado en compras locales de bienes en su casilla 22, sin que el formulario pida la base imponible de la compra', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'form-it1', null, null, null, null),
  ('DO', 'DO-P-18-IMPORTACION', 'Importación de bienes a la tarifa general', '{}'::jsonb, 'Importación de bienes gravados a la tarifa general, destinados a operaciones gravadas', 'percent', 18, 'purchase', 'import', date '2016-01-01', null, 'Código Tributario, art. 335, numeral 2, y art. 339, numeral 2 — la importación de bienes industrializados está gravada, sobre una base que agrega al valor en aduana los tributos a la importación; el Formulario IT-1 declara el ITBIS pagado en importaciones en su casilla 24, distinta de las compras locales', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'form-it1', null, null, null, null),
  ('DO', 'DO-P-18-SERVICIOS', 'Compras de servicios a la tarifa general', '{}'::jsonb, 'Adquisición local de servicios gravados a la tarifa general, destinados a operaciones gravadas', 'percent', 18, 'purchase', 'domestic', date '2016-01-01', null, 'Código Tributario, art. 336, párrafo II, y art. 346, en los mismos términos que la compra de bienes; el Formulario IT-1 declara el ITBIS pagado en servicios deducibles en una casilla distinta de la de bienes (casilla 23 frente a la 22)', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'form-it1', null, null, null, null),
  ('DO', 'DO-P-EXE', 'Compras de bienes exentos', '{}'::jsonb, 'Adquisición local de arroz y demás bienes exentos del artículo 343, destinados a la reventa', 'percent', 0, 'purchase', 'exempt', date '2012-11-09', null, 'Código Tributario, art. 343 — la compra de un bien exento, como el arroz, no causa el impuesto; no hay ITBIS que declarar en ninguna casilla del Formulario IT-1 por esta adquisición', null, null, 80, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'ct-titulo3', null, null, null, null),
  ('DO', 'DO-S-16', 'Ventas a la tarifa reducida', '{}'::jsonb, 'Transferencia de azúcares (partida arancelaria 17.01) y demás bienes del párrafo II del artículo 345, gravados a la tarifa reducida', 'percent', 16, 'sale', 'domestic', date '2016-01-01', null, 'Código Tributario, art. 345, párrafo II (modificado por la Ley No. 253-12) — se establece una tasa reducida del ITBIS para los bienes que se indican en su anexo, entre ellos los azúcares de la partida arancelaria 17.01, según la tabla de tasas por año: 8 % en 2013, 11 % en 2014, 13 % en 2015 y 16 % a partir de 2016', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley253-12', null, null, null, null),
  ('DO', 'DO-S-18', 'Ventas y servicios a la tarifa general', '{}'::jsonb, 'Transferencia de bienes industrializados y prestación de servicios gravados a la tarifa general del ITBIS', 'percent', 18, 'sale', 'domestic', date '2016-01-01', null, 'Código Tributario, art. 345 (modificado por el artículo 23 de la Ley No. 253-12) — la tasa a aplicar a las transferencias gravadas y/o a los servicios prestados es del 18 % para los años 2013 y 2014, y del 16 % a partir del año 2015, en la medida en que ello permita alcanzar y mantener la meta de presión tributaria del artículo 26 de la Ley No. 1-12 (párrafo I); la Dirección General de Impuestos Internos publica en su ficha del ITBIS que la tasa a aplicar a partir del 2016 es del 18 %, la reducción condicionada del párrafo I no se ha activado', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ley253-12', null, null, null, null),
  ('DO', 'DO-S-EXE', 'Ventas locales de bienes exentos', '{}'::jsonb, 'Transferencia local de arroz (partida arancelaria 10.06) y demás bienes exentos del artículo 343, sin derecho a deducir el impuesto pagado en su producción o adquisición', 'percent', 0, 'sale', 'exempt', date '2012-11-09', null, 'Código Tributario, art. 343 (modificado por la Ley No. 253-12, de fecha 9 de noviembre de 2012) — la transferencia y la importación de los bienes que se detallan en su anexo están exentas del impuesto establecido en el artículo 335, entre ellos el arroz de la partida arancelaria 10.06; a diferencia de la exportación del artículo 342, el productor de un bien exento del artículo 343 no deduce el impuesto que le fue facturado en su producción (Formulario IT-1, casilla 45)', 'E', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-titulo3', null, null, null, null),
  ('DO', 'DO-S-EXP', 'Exportación de bienes', '{}'::jsonb, 'Bienes corporales muebles exportados, gravados con tasa cero y con derecho del exportador a deducir y a que se le reembolse el impuesto adelantado', 'percent', 0, 'sale', 'export', date '2005-12-13', null, 'Código Tributario, art. 342 (modificado por el artículo 8 de la Ley No. 557-05, de fecha 13 de diciembre de 2005) — quedan gravados con tasa cero los bienes que se exporten; los exportadores tendrán derecho a deducir de cualquier otra obligación tributaria el valor del impuesto que se hubiere cargado al adquirir bienes y servicios destinados a su actividad de exportación, con reembolso del saldo a favor por la DGII', 'G', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'ct-titulo3', null, null, null, null)
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
    ('DO-P-18-BIENES', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-18-BIENES', 'invoice', 'tax', 100, '210403', '22', array['22']::text[], 100, 'DO-ITBIS-IT1', 20),
    ('DO-P-18-BIENES', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-18-BIENES', 'credit_note', 'tax', 100, '210403', '22', array['22']::text[], -100, 'DO-ITBIS-IT1', 20),
    ('DO-P-18-IMPORTACION', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-18-IMPORTACION', 'invoice', 'tax', 100, '210405', '24', array['24']::text[], 100, 'DO-ITBIS-IT1', 20),
    ('DO-P-18-IMPORTACION', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-18-IMPORTACION', 'credit_note', 'tax', 100, '210405', '24', array['24']::text[], -100, 'DO-ITBIS-IT1', 20),
    ('DO-P-18-SERVICIOS', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-18-SERVICIOS', 'invoice', 'tax', 100, '210404', '23', array['23']::text[], 100, 'DO-ITBIS-IT1', 20),
    ('DO-P-18-SERVICIOS', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-18-SERVICIOS', 'credit_note', 'tax', 100, '210404', '23', array['23']::text[], -100, 'DO-ITBIS-IT1', 20),
    ('DO-P-EXE', 'invoice', 'base', 100, null, null, null, 100, null, 10),
    ('DO-P-EXE', 'credit_note', 'base', 100, null, null, null, 100, null, 10),
    ('DO-S-16', 'invoice', 'base', 100, null, '12', array['12']::text[], 100, 'DO-ITBIS-IT1', 10),
    ('DO-S-16', 'invoice', 'tax', 100, '210402', null, null, 100, null, 20),
    ('DO-S-16', 'credit_note', 'base', 100, null, '12', array['12']::text[], -100, 'DO-ITBIS-IT1', 10),
    ('DO-S-16', 'credit_note', 'tax', 100, '210402', null, null, 100, null, 20),
    ('DO-S-18', 'invoice', 'base', 100, null, '11', array['11']::text[], 100, 'DO-ITBIS-IT1', 10),
    ('DO-S-18', 'invoice', 'tax', 100, '210401', null, null, 100, null, 20),
    ('DO-S-18', 'credit_note', 'base', 100, null, '11', array['11']::text[], -100, 'DO-ITBIS-IT1', 10),
    ('DO-S-18', 'credit_note', 'tax', 100, '210401', null, null, 100, null, 20),
    ('DO-S-EXE', 'invoice', 'base', 100, null, '4', array['4']::text[], 100, 'DO-ITBIS-IT1', 10),
    ('DO-S-EXE', 'credit_note', 'base', 100, null, '4', array['4']::text[], -100, 'DO-ITBIS-IT1', 10),
    ('DO-S-EXP', 'invoice', 'base', 100, null, '2', array['2']::text[], 100, 'DO-ITBIS-IT1', 10),
    ('DO-S-EXP', 'credit_note', 'base', 100, null, '2', array['2']::text[], -100, 'DO-ITBIS-IT1', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'DO' and t.code = v.tax_code
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
  ('DO', 'DO-ITBIS-IT1', 'Declaración Jurada del Impuesto sobre Transferencias de Bienes Industrializados y Servicios (Formulario IT-1)', array['month']::declaration_period[], 'month'::declaration_period, date '1970-01-01', null, 'Código Tributario, art. 353, y ficha del ITBIS de la Dirección General de Impuestos Internos (DGII) — todo responsable del ITBIS declara y paga mensualmente, sobre las operaciones del mes calendario anterior, mediante el Formulario IT-1', true,'day_of_month_after_period'::filing_deadline_rule, 20, null, 'Dirección General de Impuestos Internos, ficha del ITBIS — el Formulario IT-1 se presenta y se paga dentro de los primeros veinte (20) días del mes siguiente al período declarado', 'dgii-itbis', null)
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
  ('DO', 'DO-ITBIS-IT1', '2', 'base', 'Ingresos por Exportaciones de Bienes según Art. 342 CT', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 2 — monto de las ventas de bienes al exterior durante el período a declarar, gravadas con tasa cero según el artículo 342 del Código Tributario', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '4', 'base', 'Ingresos por ventas locales de bienes o servicios exentos Art. 343 CT', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 4 — monto de las ventas de bienes o servicios prestados en el país, exentos del impuesto según el artículo 343 del Código Tributario', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '9', 'total', 'Total Ingresos por Operaciones No Gravadas', '{}'::jsonb, 30, null, array['2', '4']::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 9 — suma de los valores declarados en las casillas 2 a 8; este paquete sólo declara las casillas 2 y 4', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '11', 'base', 'Operaciones gravadas al 18%', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 11 — total de las operaciones gravadas con la tarifa general del 18 % durante el período a declarar', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '12', 'base', 'Operaciones gravadas al 16%', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 12 — total de las operaciones gravadas con la tarifa reducida del 16 % durante el período a declarar', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '10', 'total', 'Total Ingresos por Operaciones Gravadas', '{}'::jsonb, 60, null, array['11', '12']::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 10 — el formulario oficial la obtiene restando la casilla 9 de la casilla 1; este paquete, que no modela el Anexo A de comprobantes por tipo de NCF, la declara como la suma de las casillas 11 a 15 que efectivamente alcanza (11 y 12), coherente con la nota del propio formulario según la cual la sumatoria de las casillas 11 a 15 debe igualar la casilla 10', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '1', 'total', 'Total de Operaciones del Período', '{}'::jsonb, 70, null, array['9', '10']::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 1 — en el formulario oficial proviene de la casilla 11 del Anexo A (resumen de comprobantes emitidos); este paquete, que no modela ese anexo, la declara como la suma de las operaciones no gravadas y gravadas que sí modela', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '16', 'total', 'ITBIS cobrado (18% de la casilla 11)', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], 18, '11', false, false, null, 'Formulario IT-1, casilla 16 — dieciocho por ciento (18 %) del valor declarado en la casilla 11', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '17', 'total', 'ITBIS cobrado (16% de la casilla 12)', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], 16, '12', false, false, null, 'Formulario IT-1, casilla 17 — dieciséis por ciento (16 %) del valor declarado en la casilla 12', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '21', 'total', 'Total ITBIS Cobrado', '{}'::jsonb, 100, null, array['16', '17']::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 21 — suma de los valores de las casillas 16 a 20; este paquete sólo declara las casillas 16 y 17', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '22', 'tax', 'ITBIS Pagado en Compras Locales de Bienes', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 22 — ITBIS deducible pagado en compras locales de bienes, proveniente de la casilla 56 (columna Compras Locales) del Anexo A', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '23', 'tax', 'ITBIS Pagado por Servicios Deducibles', '{}'::jsonb, 120, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 23 — ITBIS deducible pagado en servicios, proveniente de la casilla 56 (columna Servicios) del Anexo A', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '24', 'tax', 'ITBIS Pagado en Importaciones', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 24 — ITBIS deducible pagado en importaciones, proveniente de la casilla 56 (columna Importaciones) del Anexo A', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '25', 'total', 'Total ITBIS Deducible', '{}'::jsonb, 140, null, array['22', '23', '24']::text[], '{}'::text[], null, null, false, false, null, 'Formulario IT-1, casilla 25 — suma de las casillas 22, 23 y 24', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '26', 'total', 'Impuesto a Pagar', '{}'::jsonb, 150, null, array['21']::text[], array['25']::text[], null, null, true, false, null, 'Formulario IT-1, casilla 26 — resultado de restar la casilla 25 (total ITBIS deducible) de la casilla 21 (total ITBIS cobrado), cuando el resultado es positivo', 'form-it1'),
  ('DO', 'DO-ITBIS-IT1', '27', 'total', 'Saldo a Favor', '{}'::jsonb, 160, null, array['25']::text[], array['21']::text[], null, null, true, false, null, 'Formulario IT-1, casilla 27 — resultado de restar la casilla 25 (total ITBIS deducible) de la casilla 21 (total ITBIS cobrado), cuando el resultado es negativo', 'form-it1')
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
  ('DO-IR2-A1', 'DO', 'default', 'Balance General (Anexo A-1)', 'balance_sheet', 'DO-IR2', date '1970-01-01', null, 'Instructivo de la Declaración Jurada del Impuesto sobre la Renta Persona Jurídica (IR-2) — el Anexo A-1, Balance General, es el estado de activos, pasivos y patrimonio que toda persona jurídica de los sectores manufactura, comercio, agropecuaria u hoteles declara junto con el IR-2; no es un estado bajo NIIF para PYMES en su forma completa, sino el resumen administrativo que la Dirección General de Impuestos Internos exige de todo contribuyente, en ausencia de un catálogo o de un formato de estados financieros único impuesto por la ley dominicana', 'ir2-instructivo'),
  ('DO-IR2-B1', 'DO', 'default', 'Estado de Resultados (Anexo B-1)', 'income_statement', 'DO-IR2', date '1970-01-01', null, 'Instructivo de la Declaración Jurada del Impuesto sobre la Renta Persona Jurídica (IR-2) — el Anexo B-1, Estado de Resultados, es el estado de ingresos, costos y gastos que toda persona jurídica de los sectores manufactura, comercio y agropecuaria declara junto con el IR-2', 'ir2-instructivo')
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
  ('DO-IR2-A1', '11', 'AC', 'Disponible', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '12', 'AC', 'Cuentas por Cobrar', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '13', 'AC', 'Inventarios', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '14', 'AC', 'Gastos Pagados por Anticipado', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', 'AC', 'ACT', 'Total Activo Corriente', '{}'::jsonb, 50, 1, true, array['11', '12', '13', '14']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '15', 'ANC', 'Activo Fijo', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '16', 'ANC', 'Inversiones', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '17', 'ANC', 'Otros Activos', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', 'ANC', 'ACT', 'Total Activo No Corriente', '{}'::jsonb, 90, 1, true, array['15', '16', '17']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', 'ACT', null, 'Total Activo', '{}'::jsonb, 100, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '21', 'PAS', 'Pasivo Corriente', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '22', 'PAS', 'Pasivo a Largo Plazo', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', 'PAS', null, 'Total Pasivo', '{}'::jsonb, 130, 1, true, array['21', '22']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '31', 'PAT', 'Capital', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '32', 'PAT', 'Reservas', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', '33', 'PAT', 'Resultados', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-A1', 'PAT', null, 'Total Patrimonio', '{}'::jsonb, 170, 1, true, array['31', '32', '33']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '41', 'ING', 'Ingresos de Operaciones', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '42', 'ING', 'Ingresos Financieros', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '43', 'ING', 'Ingresos Extraordinarios', '{}'::jsonb, 30, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', 'ING', null, 'Total Ingresos', '{}'::jsonb, 40, 1, true, array['41', '42', '43']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '50', 'CV', 'Costo de Venta', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', 'CV', null, 'Total Costo de Venta', '{}'::jsonb, 60, 1, true, array['50']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '51', 'GO', 'Gastos de Personal', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '52', 'GO', 'Gastos por Trabajos, Suministros y Servicios', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '53', 'GO', 'Arrendamientos', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '54', 'GO', 'Gastos de Activos Fijos', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '55', 'GO', 'Gastos de Representación', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', 'GO', null, 'Total Gastos Operacionales', '{}'::jsonb, 120, 1, true, array['51', '52', '53', '54', '55']::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '56', null, 'Gastos Financieros', '{}'::jsonb, 130, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '57', null, 'Gastos Extraordinarios', '{}'::jsonb, 140, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', '58', null, 'Impuesto Sobre la Renta', '{}'::jsonb, 150, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('DO-IR2-B1', 'UN', null, 'Beneficio (Pérdida) del Ejercicio', '{}'::jsonb, 160, 1, true, array['ING']::text[], array['CV', 'GO', '56', '57', '58']::text[], null, null, null)
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
    ('DO-IR2-A1', '11', 10, 'code_prefix', '11', null, null, 'any'),
    ('DO-IR2-A1', '12', 10, 'code_prefix', '12', null, null, 'any'),
    ('DO-IR2-A1', '13', 10, 'code_prefix', '13', null, null, 'any'),
    ('DO-IR2-A1', '14', 10, 'code_prefix', '14', null, null, 'any'),
    ('DO-IR2-A1', '15', 10, 'code_prefix', '15', null, null, 'any'),
    ('DO-IR2-A1', '16', 10, 'code_prefix', '16', null, null, 'any'),
    ('DO-IR2-A1', '17', 10, 'code_prefix', '17', null, null, 'any'),
    ('DO-IR2-A1', '21', 10, 'code_prefix', '21', null, null, 'any'),
    ('DO-IR2-A1', '22', 10, 'code_prefix', '22', null, null, 'any'),
    ('DO-IR2-A1', '31', 10, 'code_prefix', '31', null, null, 'any'),
    ('DO-IR2-A1', '32', 10, 'code_prefix', '32', null, null, 'any'),
    ('DO-IR2-A1', '33', 10, 'code_prefix', '33', null, null, 'any'),
    ('DO-IR2-B1', '41', 10, 'code_prefix', '41', null, null, 'any'),
    ('DO-IR2-B1', '42', 10, 'code_prefix', '42', null, null, 'any'),
    ('DO-IR2-B1', '43', 10, 'code_prefix', '43', null, null, 'any'),
    ('DO-IR2-B1', '50', 10, 'code_prefix', '50', null, null, 'any'),
    ('DO-IR2-B1', '51', 10, 'code_prefix', '51', null, null, 'any'),
    ('DO-IR2-B1', '52', 10, 'code_prefix', '52', null, null, 'any'),
    ('DO-IR2-B1', '53', 10, 'code_prefix', '53', null, null, 'any'),
    ('DO-IR2-B1', '54', 10, 'code_prefix', '54', null, null, 'any'),
    ('DO-IR2-B1', '55', 10, 'code_prefix', '55', null, null, 'any'),
    ('DO-IR2-B1', '56', 10, 'code_prefix', '56', null, null, 'any'),
    ('DO-IR2-B1', '57', 10, 'code_prefix', '57', null, null, 'any'),
    ('DO-IR2-B1', '58', 10, 'code_prefix', '58', null, null, 'any')
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
  ('DO', 'Dominican Republic', '{}'::jsonb, array['es']::text[], 'DOP', '1201', '2102', '2106', '4203', '3301', '4101', '5001', '110201', '110101', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '3303', '3304', '3302', 'APE', 'half_up', default, '4202', '5602', null, null, null, null, '210406', '120302', 'Comprobante de apertura', 'month'::declaration_period)
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
  number_format                 = '{CODE}{NNNNNNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Código Tributario, art. 335 y siguientes, y Ley No. 32-23 de Facturación Electrónica — todo comprobante fiscal debe llevar una numeración consecutiva y única, hoy asignada y validada por la Dirección General de Impuestos Internos (DGII) a través del sistema de comprobantes fiscales electrónicos (e-CF) o, transitoriamente, del Número de Comprobante Fiscal (NCF) en papel. El consecutivo que este paquete usa es el de la pieza contable; no es el e-CF ni el sello de validación de la DGII, que Ekwo no calcula ni transmite — ver la sección de facturación electrónica',
  numbering_source_key          = 'ley32-23',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Código Tributario, art. 338 — la obligación tributaria del ITBIS nace, en la transferencia de bienes, en el momento en que se emita el documento que ampara la transferencia o, a falta de documento, desde que se entregue o retire el bien; en la prestación de servicios, desde la emisión de la factura o desde el momento en que se termina la prestación o desde la percepción total o parcial del precio, el que fuere anterior. Este paquete declara la regla general de la transferencia de bienes, invoice_if_issued; la prestación de servicios añade un tercer punto de anclaje (la terminación del servicio) que el vocabulario cerrado de esta casilla no nombra — ver docs/international.md',
  tax_point_source_key          = 'ct-titulo3',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Ley No. 32-23 de Facturación Electrónica y su normativa de desarrollo — un comprobante fiscal electrónico (e-CF) validado por la DGII se corrige o anula mediante una nota de crédito o una nota de débito que lo referencie; no existe un mecanismo para devolver a borrador un documento ya validado',
  posted_edit_policy_source_key = 'ley32-23',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Ley No. 32-23 de Facturación Electrónica, del 16 de mayo de 2023, crea el marco legal del Comprobante Fiscal Electrónico (e-CF) y lo hace obligatorio de forma escalonada según la categoría del contribuyente: doce meses desde su entrada en vigor para los Grandes Contribuyentes Nacionales (a partir de mayo de 2024), veinticuatro meses para los Grandes Contribuyentes Locales y Medianos, y treinta y seis meses para los Pequeños, Micro y no Clasificados. Es un régimen de validación previa (clearance): el comprobante se transmite a la DGII, o a un proveedor tecnológico autorizado, para su validación antes de amparar la operación, y no un intercambio par a par construido sobre el modelo semántico de EN 16931. La Dirección General de Impuestos Internos ajusta las fechas exactas de cada categoría mediante avisos oficiales sucesivos, consultables en su portal de facturación electrónica. EKWO NO GENERA, NO CALCULA EL SELLO NI TRANSMITE NINGÚN e-CF: ningún componente de packages/formats dialoga con la DGII ni con un proveedor tecnológico autorizado. Por eso profile, mandatory_from, party_scheme y vat_scheme quedan vacíos aunque la obligación exista y avance por etapas: profile nombra un perfil construido sobre EN 16931 (peppol-bis-3, factur-x-en16931, xrechnung, un PINT) y el e-CF dominicano no es ninguno de ellos; el formato tampoco tiene una palabra para «válido sólo tras la validación previa de un tercero» ni para una obligación que depende del tamaño del contribuyente — véase docs/international.md. El Registro Nacional de Contribuyentes (RNC) no tiene un código de esquema ISO 6523 registrado: party_scheme y vat_scheme quedan vacíos por la misma razón que en los paquetes de México y Colombia',
  einvoice_source_key           = 'ley32-23',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'DO';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('DO', 'ecf_not_assigned', 'always', 'Este documento no es un Comprobante Fiscal Electrónico (e-CF): no ha sido transmitido a la Dirección General de Impuestos Internos (DGII) ni validado por esta. Solo el e-CF validado, o el Número de Comprobante Fiscal (NCF) autorizado durante el período de transición, amparan la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Ley No. 32-23 de Facturación Electrónica — el comprobante fiscal electrónico se transmite a la DGII, o a un proveedor tecnológico autorizado, para su validación antes de amparar la operación. Ekwo no genera, no transmite y no calcula el sello de un e-CF dominicano: ver la sección de facturación electrónica de este paquete'),
  ('DO', 'export', 'export', 'Exportación de bienes gravada con tasa cero del Impuesto sobre Transferencias de Bienes Industrializados y Servicios (ITBIS), con derecho del exportador a deducir y, en su caso, a que se le reembolse el impuesto adelantado en su producción (artículo 342 del Código Tributario).', '{}'::jsonb, 20, date '1970-01-01', null, 'Código Tributario, art. 342 (modificado por el artículo 8 de la Ley No. 557-05) — quedan gravados con tasa cero los bienes que se exporten; los exportadores tienen derecho a deducir de cualquier otra obligación tributaria el valor del impuesto que se hubiere cargado al adquirir bienes y servicios destinados a su actividad de exportación, y a que se les devuelva el saldo a favor resultante'),
  ('DO', 'exempt', 'exempt', 'Bien exento del Impuesto sobre Transferencias de Bienes Industrializados y Servicios (ITBIS): su transferencia no causa el impuesto y no da derecho a deducir el impuesto pagado en su producción o adquisición (artículo 343 del Código Tributario).', '{}'::jsonb, 30, date '1970-01-01', null, 'Código Tributario, art. 343 (modificado por la Ley No. 253-12) — la transferencia y la importación de los bienes que se detallan en su anexo, entre ellos el arroz (partida arancelaria 10.06), están exentas del impuesto establecido en el artículo 335; art. 346 y el instructivo del Formulario IT-1, casilla 45 — el impuesto pagado en la producción de un bien exento no es deducible')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
