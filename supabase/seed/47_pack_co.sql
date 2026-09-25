-- Ekwo OS — Colombia: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/co at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build co`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Estatuto Tributario Nacional (Decreto 624 de 1989) — compilación jurídica vigente (Dirección de Impuestos y Aduanas Nacionales (DIAN))
--     https://normograma.dian.gov.co/dian/compilacion/docs/estatuto_tributario.htm
--   Decreto 1625 de 2016 — Decreto Único Reglamentario en materia tributaria, Título 1 (plazos para declarar y pagar), modificado cada año por el decreto que fija el calendario tributario (Departamento Administrativo de la Función Pública — Gestor Normativo)
--     https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=83233
--   Formulario 300 — Declaración del Impuesto sobre las Ventas (IVA), y su instructivo de diligenciamiento (Dirección de Impuestos y Aduanas Nacionales (DIAN))
--     https://www.dian.gov.co/atencionciudadano/formulariosinstructivos/Formularios/2024/Formulario_300_2025.pdf
--   Resolución DIAN No. 000165 del 1 de noviembre de 2023 — sistema de facturación electrónica, Anexo Técnico de Factura Electrónica de Venta (Dirección de Impuestos y Aduanas Nacionales (DIAN))
--     https://www.dian.gov.co/normatividad/Normatividad/Resoluci%C3%B3n%20000165%20de%2001-11-2023.pdf
--   Anexo Técnico del Documento Equivalente Electrónico, versión 1.0 (Dirección de Impuestos y Aduanas Nacionales (DIAN))
--     https://www.dian.gov.co/impuestos/factura-electronica/Documents/Anexo-Tecnico-Documento-Equivalente-Electronico-V1-0-final.pdf
--   Validación previa de la factura electrónica — cómo funciona el sistema de facturación electrónica (Dirección de Impuestos y Aduanas Nacionales (DIAN))
--     https://www.dian.gov.co/impuestos/factura-electronica/factura-electronica/Paginas/validacion-previa.aspx
--   Calendario Tributario (Dirección de Impuestos y Aduanas Nacionales (DIAN))
--     https://www.dian.gov.co/Paginas/CalendarioTributario.aspx
--   Decreto 2650 de 1993 — Plan Único de Cuentas para comerciantes (Superintendencia de Sociedades)
--     https://www.supersociedades.gov.co/documents/107391/831530/Decreto+2650+del+29+de+diciembre+de+1993.pdf/4c2f354e-2505-e1a1-10c9-b5e10e0da0f2?t=1670597246533&download=true
--   Decreto 2420 de 2015 — Decreto Único Reglamentario de las Normas de Contabilidad, de Información Financiera y de Aseguramiento de la Información (Departamento Administrativo de la Función Pública — Gestor Normativo)
--     https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=76745
--   Decreto 2706 de 2012 — Marco técnico normativo de información financiera para los preparadores de información financiera que se clasifican en el grupo 3 (microempresas) (Departamento Administrativo de la Función Pública — Gestor Normativo)
--     https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=51148
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('CO', 'Colombia', '0.1.0', date '2026-09-25', '20260923110000', 'community', null, null, '160a316667b71aef0e84121b56a39981c3925dd204c1244075a1bd1288878a4f', '[{"key":"et","title":"Estatuto Tributario Nacional (Decreto 624 de 1989) — compilación jurídica vigente","publisher":"Dirección de Impuestos y Aduanas Nacionales (DIAN)","url":"https://normograma.dian.gov.co/dian/compilacion/docs/estatuto_tributario.htm","consulted_on":"2026-09-25","kind":"law"},{"key":"dur1625","title":"Decreto 1625 de 2016 — Decreto Único Reglamentario en materia tributaria, Título 1 (plazos para declarar y pagar), modificado cada año por el decreto que fija el calendario tributario","publisher":"Departamento Administrativo de la Función Pública — Gestor Normativo","url":"https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=83233","consulted_on":"2026-09-25","kind":"regulation"},{"key":"form300","title":"Formulario 300 — Declaración del Impuesto sobre las Ventas (IVA), y su instructivo de diligenciamiento","publisher":"Dirección de Impuestos y Aduanas Nacionales (DIAN)","url":"https://www.dian.gov.co/atencionciudadano/formulariosinstructivos/Formularios/2024/Formulario_300_2025.pdf","consulted_on":"2026-09-25","kind":"form"},{"key":"res165","title":"Resolución DIAN No. 000165 del 1 de noviembre de 2023 — sistema de facturación electrónica, Anexo Técnico de Factura Electrónica de Venta","publisher":"Dirección de Impuestos y Aduanas Nacionales (DIAN)","url":"https://www.dian.gov.co/normatividad/Normatividad/Resoluci%C3%B3n%20000165%20de%2001-11-2023.pdf","consulted_on":"2026-09-25","kind":"regulation"},{"key":"anexo-doc-equivalente","title":"Anexo Técnico del Documento Equivalente Electrónico, versión 1.0","publisher":"Dirección de Impuestos y Aduanas Nacionales (DIAN)","url":"https://www.dian.gov.co/impuestos/factura-electronica/Documents/Anexo-Tecnico-Documento-Equivalente-Electronico-V1-0-final.pdf","consulted_on":"2026-09-25","kind":"standard"},{"key":"dian-validacion","title":"Validación previa de la factura electrónica — cómo funciona el sistema de facturación electrónica","publisher":"Dirección de Impuestos y Aduanas Nacionales (DIAN)","url":"https://www.dian.gov.co/impuestos/factura-electronica/factura-electronica/Paginas/validacion-previa.aspx","consulted_on":"2026-09-25","kind":"guidance"},{"key":"dian-calendario","title":"Calendario Tributario","publisher":"Dirección de Impuestos y Aduanas Nacionales (DIAN)","url":"https://www.dian.gov.co/Paginas/CalendarioTributario.aspx","consulted_on":"2026-09-25","kind":"portal"},{"key":"decreto2650","title":"Decreto 2650 de 1993 — Plan Único de Cuentas para comerciantes","publisher":"Superintendencia de Sociedades","url":"https://www.supersociedades.gov.co/documents/107391/831530/Decreto+2650+del+29+de+diciembre+de+1993.pdf/4c2f354e-2505-e1a1-10c9-b5e10e0da0f2?t=1670597246533&download=true","consulted_on":"2026-09-25","kind":"regulation"},{"key":"decreto2420","title":"Decreto 2420 de 2015 — Decreto Único Reglamentario de las Normas de Contabilidad, de Información Financiera y de Aseguramiento de la Información","publisher":"Departamento Administrativo de la Función Pública — Gestor Normativo","url":"https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=76745","consulted_on":"2026-09-25","kind":"regulation"},{"key":"decreto2706","title":"Decreto 2706 de 2012 — Marco técnico normativo de información financiera para los preparadores de información financiera que se clasifican en el grupo 3 (microempresas)","publisher":"Departamento Administrativo de la Función Pública — Gestor Normativo","url":"https://www.funcionpublica.gov.co/eva/gestornormativo/norma.php?i=51148","consulted_on":"2026-09-25","kind":"regulation"}]'::jsonb)
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
  ('CO', 'default', 'Plan Único de Cuentas (Decreto 2650 de 1993) — selección para pymes', '{}'::jsonb, true, 'companies', array['CO-DECRETO2649-ER', 'CO-DECRETO2649-ESF']::text[], null, 'Decreto 2650 de 1993, art. 4 — el catálogo de cuentas ordena las clases, grupos, cuentas y subcuentas de activo, pasivo, patrimonio, ingresos, gastos y costos de ventas con un código numérico y su denominación. Desde el 1 de enero de 2015, con la convergencia a las Normas Internacionales de Información Financiera (Ley 1314 de 2009, Decreto 2420 de 2015), la aplicación de este plan dejó de ser obligatoria para quien prepara estados financieros bajo NIIF: cada entidad define su propio catálogo. Colombia no impone entonces un catálogo único a toda empresa, y este paquete usa, como catálogo propio, una selección de códigos de la nomenclatura del Decreto 2650 — la que casi todo software contable colombiano y la propia información exógena de la DIAN siguen empleando en la práctica — de la misma manera que el paquete de México usa el código agrupador del SAT: la identidad de código y de nombre es la asociación, no una obligación legal de usar precisamente esta numeración', 'decreto2650')
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
  ('CO', 'default', '11', 'DISPONIBLE', '{}'::jsonb, 'asset_cash', false, null, 10),
  ('CO', 'default', '1105', 'Caja', '{}'::jsonb, 'asset_cash', false, '11', 20),
  ('CO', 'default', '110505', 'Caja general', '{}'::jsonb, 'asset_cash', false, '1105', 30),
  ('CO', 'default', '1110', 'Bancos', '{}'::jsonb, 'asset_cash', false, '11', 40),
  ('CO', 'default', '111005', 'Bancos moneda nacional', '{}'::jsonb, 'asset_cash', false, '1110', 50),
  ('CO', 'default', '12', 'Inversiones', '{}'::jsonb, 'asset_non_current', false, null, 60),
  ('CO', 'default', '1205', 'Acciones', '{}'::jsonb, 'asset_non_current', false, '12', 70),
  ('CO', 'default', '13', 'Deudores', '{}'::jsonb, 'asset_current', false, null, 80),
  ('CO', 'default', '1305', 'Clientes', '{}'::jsonb, 'asset_receivable', true, '13', 90),
  ('CO', 'default', '130505', 'Clientes nacionales', '{}'::jsonb, 'asset_receivable', true, '1305', 100),
  ('CO', 'default', '1355', 'Anticipo de impuestos y contribuciones o saldos a favor', '{}'::jsonb, 'asset_current', false, '13', 110),
  ('CO', 'default', '135505', 'Anticipo impuesto de renta y complementarios', '{}'::jsonb, 'asset_current', false, '1355', 120),
  ('CO', 'default', '135520', 'Sobrantes en liquidación privada de impuestos', '{}'::jsonb, 'asset_current', true, '1355', 130),
  ('CO', 'default', '1365', 'Cuentas por cobrar a trabajadores', '{}'::jsonb, 'asset_current', false, '13', 140),
  ('CO', 'default', '1380', 'Deudores varios', '{}'::jsonb, 'asset_current', false, '13', 150),
  ('CO', 'default', '1399', 'Provisiones', '{}'::jsonb, 'asset_current', false, '13', 160),
  ('CO', 'default', '139905', 'Provisión clientes', '{}'::jsonb, 'asset_current', false, '1399', 170),
  ('CO', 'default', '14', 'Inventarios', '{}'::jsonb, 'asset_current', false, null, 180),
  ('CO', 'default', '1435', 'Mercancías no fabricadas por la empresa', '{}'::jsonb, 'asset_current', false, '14', 190),
  ('CO', 'default', '1499', 'Provisiones', '{}'::jsonb, 'asset_current', false, '14', 200),
  ('CO', 'default', '15', 'Propiedades planta y equipo', '{}'::jsonb, 'asset_fixed', false, null, 210),
  ('CO', 'default', '1504', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '15', 220),
  ('CO', 'default', '1516', 'Construcciones y edificaciones', '{}'::jsonb, 'asset_fixed', false, '15', 230),
  ('CO', 'default', '1520', 'Maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '15', 240),
  ('CO', 'default', '1524', 'Equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '15', 250),
  ('CO', 'default', '1528', 'Equipo de computación y comunicación', '{}'::jsonb, 'asset_fixed', false, '15', 260),
  ('CO', 'default', '1540', 'Flota y equipo de transporte', '{}'::jsonb, 'asset_fixed', false, '15', 270),
  ('CO', 'default', '1592', 'Depreciación acumulada', '{}'::jsonb, 'asset_fixed', false, '15', 280),
  ('CO', 'default', '159205', 'Depreciación acumulada construcciones y edificaciones', '{}'::jsonb, 'asset_fixed', false, '1592', 290),
  ('CO', 'default', '159210', 'Depreciación acumulada maquinaria y equipo', '{}'::jsonb, 'asset_fixed', false, '1592', 300),
  ('CO', 'default', '159215', 'Depreciación acumulada equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1592', 310),
  ('CO', 'default', '159220', 'Depreciación acumulada equipo de computación y comunicación', '{}'::jsonb, 'asset_fixed', false, '1592', 320),
  ('CO', 'default', '159235', 'Depreciación acumulada flota y equipo de transporte', '{}'::jsonb, 'asset_fixed', false, '1592', 330),
  ('CO', 'default', '16', 'Intangibles', '{}'::jsonb, 'asset_non_current', false, null, 340),
  ('CO', 'default', '1605', 'Crédito mercantil', '{}'::jsonb, 'asset_non_current', false, '16', 350),
  ('CO', 'default', '1610', 'Marcas', '{}'::jsonb, 'asset_non_current', false, '16', 360),
  ('CO', 'default', '1698', 'Depreciación y/o amortización acumulada', '{}'::jsonb, 'asset_non_current', false, '16', 370),
  ('CO', 'default', '17', 'Diferidos', '{}'::jsonb, 'asset_prepayments', false, null, 380),
  ('CO', 'default', '1705', 'Gastos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '17', 390),
  ('CO', 'default', '1710', 'Cargos diferidos', '{}'::jsonb, 'asset_prepayments', false, '17', 400),
  ('CO', 'default', '21', 'Obligaciones financieras', '{}'::jsonb, 'liability_current', false, null, 410),
  ('CO', 'default', '2105', 'Bancos nacionales', '{}'::jsonb, 'liability_current', false, '21', 420),
  ('CO', 'default', '22', 'Proveedores', '{}'::jsonb, 'liability_current', false, null, 430),
  ('CO', 'default', '2205', 'Proveedores nacionales', '{}'::jsonb, 'liability_payable', true, '22', 440),
  ('CO', 'default', '23', 'Cuentas por pagar', '{}'::jsonb, 'liability_current', false, null, 450),
  ('CO', 'default', '2335', 'Costos y gastos por pagar', '{}'::jsonb, 'liability_current', false, '23', 460),
  ('CO', 'default', '2365', 'Retención en la fuente', '{}'::jsonb, 'liability_current', false, '23', 470),
  ('CO', 'default', '2370', 'Retenciones y aportes de nómina', '{}'::jsonb, 'liability_current', false, '23', 480),
  ('CO', 'default', '2380', 'Acreedores varios', '{}'::jsonb, 'liability_current', false, '23', 490),
  ('CO', 'default', '24', 'Impuestos gravámenes y tasas', '{}'::jsonb, 'liability_current', false, null, 500),
  ('CO', 'default', '2408', 'Impuesto sobre las ventas por pagar', '{}'::jsonb, 'liability_current', false, '24', 510),
  ('CO', 'default', '240805', 'IVA generado tarifa general', '{}'::jsonb, 'liability_current', false, '2408', 520),
  ('CO', 'default', '240810', 'IVA generado tarifa 5%', '{}'::jsonb, 'liability_current', false, '2408', 530),
  ('CO', 'default', '240815', 'IVA descontable tarifa general', '{}'::jsonb, 'liability_current', false, '2408', 540),
  ('CO', 'default', '240820', 'IVA descontable tarifa 5%', '{}'::jsonb, 'liability_current', false, '2408', 550),
  ('CO', 'default', '240825', 'Saldo a pagar impuesto sobre las ventas', '{}'::jsonb, 'liability_current', true, '2408', 560),
  ('CO', 'default', '25', 'Obligaciones laborales', '{}'::jsonb, 'liability_current', false, null, 570),
  ('CO', 'default', '2505', 'Salarios por pagar', '{}'::jsonb, 'liability_current', false, '25', 580),
  ('CO', 'default', '2510', 'Cesantías consolidadas', '{}'::jsonb, 'liability_current', false, '25', 590),
  ('CO', 'default', '2515', 'Intereses sobre cesantías', '{}'::jsonb, 'liability_current', false, '25', 600),
  ('CO', 'default', '2520', 'Prima de servicios', '{}'::jsonb, 'liability_current', false, '25', 610),
  ('CO', 'default', '2525', 'Vacaciones consolidadas', '{}'::jsonb, 'liability_current', false, '25', 620),
  ('CO', 'default', '26', 'Pasivos estimados y provisiones', '{}'::jsonb, 'liability_current', false, null, 630),
  ('CO', 'default', '2605', 'Para costos y gastos', '{}'::jsonb, 'liability_current', false, '26', 640),
  ('CO', 'default', '2610', 'Para obligaciones laborales', '{}'::jsonb, 'liability_current', false, '26', 650),
  ('CO', 'default', '27', 'Diferidos', '{}'::jsonb, 'liability_current', false, null, 660),
  ('CO', 'default', '2705', 'Ingresos recibidos por anticipado', '{}'::jsonb, 'liability_current', false, '27', 670),
  ('CO', 'default', '28', 'Otros pasivos', '{}'::jsonb, 'liability_current', false, null, 680),
  ('CO', 'default', '2805', 'Anticipos y avances recibidos', '{}'::jsonb, 'liability_current', false, '28', 690),
  ('CO', 'default', '2810', 'Depósitos recibidos', '{}'::jsonb, 'liability_current', false, '28', 700),
  ('CO', 'default', '2815', 'Ingresos recibidos para terceros', '{}'::jsonb, 'liability_current', false, '28', 710),
  ('CO', 'default', '31', 'Capital social', '{}'::jsonb, 'equity', false, null, 720),
  ('CO', 'default', '3105', 'Capital suscrito y pagado', '{}'::jsonb, 'equity', false, '31', 730),
  ('CO', 'default', '3115', 'Aportes sociales', '{}'::jsonb, 'equity', false, '31', 740),
  ('CO', 'default', '311505', 'Cuotas o partes de interés social', '{}'::jsonb, 'equity', false, '3115', 750),
  ('CO', 'default', '33', 'Reservas', '{}'::jsonb, 'equity', false, null, 760),
  ('CO', 'default', '3305', 'Reservas obligatorias', '{}'::jsonb, 'equity', false, '33', 770),
  ('CO', 'default', '330505', 'Reserva legal', '{}'::jsonb, 'equity', false, '3305', 780),
  ('CO', 'default', '36', 'Resultados del ejercicio', '{}'::jsonb, 'equity_retained', false, null, 790),
  ('CO', 'default', '3605', 'Utilidad del ejercicio', '{}'::jsonb, 'equity_retained', false, '36', 800),
  ('CO', 'default', '3610', 'Pérdida del ejercicio', '{}'::jsonb, 'equity_retained', false, '36', 810),
  ('CO', 'default', '37', 'Resultados de ejercicios anteriores', '{}'::jsonb, 'equity_retained', false, null, 820),
  ('CO', 'default', '3705', 'Utilidades acumuladas', '{}'::jsonb, 'equity_retained', false, '37', 830),
  ('CO', 'default', '3710', 'Pérdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '37', 840),
  ('CO', 'default', '41', 'Operacionales', '{}'::jsonb, 'income', false, null, 850),
  ('CO', 'default', '4135', 'Comercio al por mayor y al por menor', '{}'::jsonb, 'income', false, '41', 860),
  ('CO', 'default', '4155', 'Actividades inmobiliarias empresariales y de alquiler', '{}'::jsonb, 'income', false, '41', 870),
  ('CO', 'default', '4175', 'Devoluciones en ventas', '{}'::jsonb, 'income', false, '41', 880),
  ('CO', 'default', '42', 'No operacionales', '{}'::jsonb, 'income_other', false, null, 890),
  ('CO', 'default', '4210', 'Financieros', '{}'::jsonb, 'income_other', false, '42', 900),
  ('CO', 'default', '421005', 'Intereses', '{}'::jsonb, 'income_other', false, '4210', 910),
  ('CO', 'default', '421020', 'Diferencia en cambio', '{}'::jsonb, 'income_other', false, '4210', 920),
  ('CO', 'default', '4295', 'Diversos', '{}'::jsonb, 'income_other', false, '42', 930),
  ('CO', 'default', '429581', 'Ajuste al peso', '{}'::jsonb, 'income_other', false, '4295', 940),
  ('CO', 'default', '51', 'Operacionales de administración', '{}'::jsonb, 'expense', false, null, 950),
  ('CO', 'default', '5105', 'Gastos de personal', '{}'::jsonb, 'expense', false, '51', 960),
  ('CO', 'default', '5110', 'Honorarios', '{}'::jsonb, 'expense', false, '51', 970),
  ('CO', 'default', '5115', 'Impuestos', '{}'::jsonb, 'expense', false, '51', 980),
  ('CO', 'default', '5120', 'Arrendamientos', '{}'::jsonb, 'expense', false, '51', 990),
  ('CO', 'default', '5135', 'Servicios', '{}'::jsonb, 'expense', false, '51', 1000),
  ('CO', 'default', '5140', 'Gastos legales', '{}'::jsonb, 'expense', false, '51', 1010),
  ('CO', 'default', '5145', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '51', 1020),
  ('CO', 'default', '5150', 'Adecuación e instalación', '{}'::jsonb, 'expense', false, '51', 1030),
  ('CO', 'default', '5155', 'Gastos de viaje', '{}'::jsonb, 'expense', false, '51', 1040),
  ('CO', 'default', '5160', 'Depreciaciones', '{}'::jsonb, 'expense_depreciation', false, '51', 1050),
  ('CO', 'default', '5195', 'Diversos', '{}'::jsonb, 'expense', false, '51', 1060),
  ('CO', 'default', '5199', 'Provisiones', '{}'::jsonb, 'expense', false, '51', 1070),
  ('CO', 'default', '52', 'Operacionales de ventas', '{}'::jsonb, 'expense', false, null, 1080),
  ('CO', 'default', '5205', 'Gastos de personal', '{}'::jsonb, 'expense', false, '52', 1090),
  ('CO', 'default', '5210', 'Honorarios', '{}'::jsonb, 'expense', false, '52', 1100),
  ('CO', 'default', '5215', 'Impuestos', '{}'::jsonb, 'expense', false, '52', 1110),
  ('CO', 'default', '5220', 'Arrendamientos', '{}'::jsonb, 'expense', false, '52', 1120),
  ('CO', 'default', '5235', 'Servicios', '{}'::jsonb, 'expense', false, '52', 1130),
  ('CO', 'default', '53', 'No operacionales', '{}'::jsonb, 'expense', false, null, 1140),
  ('CO', 'default', '5305', 'Financieros', '{}'::jsonb, 'expense', false, '53', 1150),
  ('CO', 'default', '530520', 'Intereses', '{}'::jsonb, 'expense', false, '5305', 1160),
  ('CO', 'default', '530525', 'Diferencia en cambio', '{}'::jsonb, 'expense', false, '5305', 1170),
  ('CO', 'default', '5310', 'Pérdida en venta y retiro de bienes', '{}'::jsonb, 'expense', false, '53', 1180),
  ('CO', 'default', '5315', 'Gastos extraordinarios', '{}'::jsonb, 'expense', false, '53', 1190),
  ('CO', 'default', '5395', 'Gastos diversos', '{}'::jsonb, 'expense', false, '53', 1200),
  ('CO', 'default', '54', 'Impuesto de renta y complementarios', '{}'::jsonb, 'expense', false, null, 1210),
  ('CO', 'default', '5405', 'Impuesto de renta y complementarios', '{}'::jsonb, 'expense', false, '54', 1220),
  ('CO', 'default', '61', 'Costo de ventas y de prestación de servicios', '{}'::jsonb, 'expense_direct_cost', false, null, 1230),
  ('CO', 'default', '6135', 'Comercio al por mayor y al por menor', '{}'::jsonb, 'expense_direct_cost', false, '61', 1240),
  ('CO', 'default', '6155', 'Actividades inmobiliarias empresariales y de alquiler', '{}'::jsonb, 'expense_direct_cost', false, '61', 1250),
  ('CO', 'default', '62', 'Compras', '{}'::jsonb, 'expense_direct_cost', false, null, 1260),
  ('CO', 'default', '6205', 'De mercancías', '{}'::jsonb, 'expense_direct_cost', false, '62', 1270),
  ('CO', 'default', '6210', 'De materias primas', '{}'::jsonb, 'expense_direct_cost', false, '62', 1280),
  ('CO', 'default', '6225', 'Devoluciones en compras', '{}'::jsonb, 'expense_direct_cost', false, '62', 1290)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('CO', 'APE', 'Comprobante de apertura', '{}'::jsonb, 'opening', 60),
  ('CO', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('CO', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('CO', 'COM', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('CO', 'DIA', 'Comprobantes de contabilidad', '{}'::jsonb, 'general', 50),
  ('CO', 'VEN', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('CO', 'CO-P-19', 'Compras a la tarifa general — bienes', '{}'::jsonb, 'Adquisición de bienes corporales muebles gravados a la tarifa general, destinados a operaciones gravadas', 'percent', 19, 'purchase', 'domestic', date '2017-01-01', null, 'Estatuto Tributario, art. 483 — el impuesto sobre las ventas resulta de restar del impuesto generado por las operaciones gravadas el impuesto descontable; art. 488 — sólo son descontables los impuestos originados en operaciones que constituyan costo o gasto en el impuesto sobre la renta y se destinen a operaciones gravadas o exentas', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-P-19-SERV', 'Compras a la tarifa general — servicios', '{}'::jsonb, 'Adquisición de servicios gravados a la tarifa general, destinados a operaciones gravadas', 'percent', 19, 'purchase', 'domestic', date '2017-01-01', null, 'Estatuto Tributario, art. 483 y art. 488, en los mismos términos que la compra de bienes; el Formulario 300 declara el impuesto descontable de servicios en una casilla distinta de la de bienes (casilla 75 frente a la 72)', null, null, 70, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-P-5', 'Compras a la tarifa del cinco por ciento — bienes', '{}'::jsonb, 'Adquisición de café tostado y demás bienes del artículo 468-1, para su reventa', 'percent', 5, 'purchase', 'domestic', date '2017-01-01', null, 'Estatuto Tributario, art. 468-1, numeral 1, y art. 483 — el impuesto facturado en la compra de café tostado, gravado a la tarifa del cinco por ciento, es descontable para quien lo revende gravado', null, null, 80, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-P-EXC', 'Compras de bienes y servicios excluidos, exentos y no gravados', '{}'::jsonb, 'Adquisición de papa y demás bienes o servicios excluidos, exentos o no gravados', 'percent', 0, 'purchase', 'exempt', date '1990-01-01', null, 'Estatuto Tributario, art. 424 — la compra de un bien excluido, como la papa, no liquida impuesto sobre las ventas; el Formulario 300 reúne en una sola casilla (54) las compras de bienes y servicios excluidos, exentos y no gravados', null, null, 90, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-S-19', 'Ventas y servicios a la tarifa general', '{}'::jsonb, 'Venta de bienes corporales muebles y prestación de servicios en el territorio nacional a la tarifa general', 'percent', 19, 'sale', 'domestic', date '2017-01-01', null, 'Estatuto Tributario, art. 468, en la redacción del art. 184 de la Ley 1819 de 2016 — la tarifa general del impuesto sobre las ventas es del diecinueve por ciento (19 %), salvo las excepciones del título III del libro tercero del Estatuto; en vigor desde el año gravable 2017', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-S-5', 'Ventas y servicios a la tarifa del cinco por ciento', '{}'::jsonb, 'Café tostado, incluso descafeinado, y demás bienes y servicios del artículo 468-1 del Estatuto Tributario', 'percent', 5, 'sale', 'domestic', date '2017-01-01', null, 'Estatuto Tributario, art. 468-1, numeral 1 — el café, incluso tostado o descafeinado, tostado o sin tostar, cáscara y cascarilla de café y los sucedáneos del café que contengan café en cualquier proporción (partida arancelaria 09.01), gravados a la tarifa del cinco por ciento (5 %)', 'S', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-S-EXC', 'Bienes excluidos — productos agrícolas en estado natural', '{}'::jsonb, 'Papa y demás productos agrícolas en estado natural, excluidos del impuesto', 'percent', 0, 'sale', 'exempt', date '1990-01-01', null, 'Estatuto Tributario, art. 424 — bienes que no causan el impuesto sobre las ventas, entre ellos las hortalizas, legumbres, tubérculos y demás productos agrícolas en estado natural de la canasta familiar, como la papa (partida arancelaria 07.01). A diferencia del bien exento del artículo 477, la venta de un bien excluido no genera el impuesto y no da derecho a descontar el impuesto pagado en su producción (art. 491)', 'E', null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-S-EXE', 'Bienes exentos — leche', '{}'::jsonb, 'Leche fresca (partida arancelaria 04.01), exenta con derecho a descuento y devolución bimestral para su productor', 'percent', 0, 'sale', 'domestic', date '1990-01-01', null, 'Estatuto Tributario, art. 477 — bienes que se encuentran exentos del impuesto sobre las ventas, con derecho a compensación y devolución, entre ellos la leche de la partida arancelaria 04.01; a diferencia de un bien excluido, el productor del bien exento sí descuenta el impuesto que le facturaron en su producción (art. 489)', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null),
  ('CO', 'CO-S-EXP', 'Exportación de bienes', '{}'::jsonb, 'Bienes corporales muebles exportados, exentos con derecho a devolución bimestral', 'percent', 0, 'sale', 'export', date '1990-01-01', null, 'Estatuto Tributario, art. 481, literal a) — están exentos del impuesto, con derecho a devolución bimestral, los bienes corporales muebles que se exporten, así como los bienes que se vendan en el país a sociedades de comercialización internacional o a través de zonas francas siempre que efectivamente se exporten', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'et', null, null, null, null)
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
    ('CO-P-19', 'invoice', 'base', 100, null, '51', array['51']::text[], 100, 'CO-VAT-300', 10),
    ('CO-P-19', 'invoice', 'tax', 100, '240815', '72', array['72']::text[], 100, 'CO-VAT-300', 20),
    ('CO-P-19', 'credit_note', 'base', 100, null, '51', array['51']::text[], -100, 'CO-VAT-300', 10),
    ('CO-P-19', 'credit_note', 'tax', 100, '240815', '72', array['72']::text[], -100, 'CO-VAT-300', 20),
    ('CO-P-19-SERV', 'invoice', 'base', 100, null, '53', array['53']::text[], 100, 'CO-VAT-300', 10),
    ('CO-P-19-SERV', 'invoice', 'tax', 100, '240815', '75', array['75']::text[], 100, 'CO-VAT-300', 20),
    ('CO-P-19-SERV', 'credit_note', 'base', 100, null, '53', array['53']::text[], -100, 'CO-VAT-300', 10),
    ('CO-P-19-SERV', 'credit_note', 'tax', 100, '240815', '75', array['75']::text[], -100, 'CO-VAT-300', 20),
    ('CO-P-5', 'invoice', 'base', 100, null, '50', array['50']::text[], 100, 'CO-VAT-300', 10),
    ('CO-P-5', 'invoice', 'tax', 100, '240820', '71', array['71']::text[], 100, 'CO-VAT-300', 20),
    ('CO-P-5', 'credit_note', 'base', 100, null, '50', array['50']::text[], -100, 'CO-VAT-300', 10),
    ('CO-P-5', 'credit_note', 'tax', 100, '240820', '71', array['71']::text[], -100, 'CO-VAT-300', 20),
    ('CO-P-EXC', 'invoice', 'base', 100, null, '54', array['54']::text[], 100, 'CO-VAT-300', 10),
    ('CO-P-EXC', 'credit_note', 'base', 100, null, '54', array['54']::text[], -100, 'CO-VAT-300', 10),
    ('CO-S-19', 'invoice', 'base', 100, null, '28', array['28']::text[], 100, 'CO-VAT-300', 10),
    ('CO-S-19', 'invoice', 'tax', 100, '240805', '59', array['59']::text[], 100, 'CO-VAT-300', 20),
    ('CO-S-19', 'credit_note', 'base', 100, null, '28', array['28']::text[], -100, 'CO-VAT-300', 10),
    ('CO-S-19', 'credit_note', 'tax', 100, '240805', '59', array['59']::text[], -100, 'CO-VAT-300', 20),
    ('CO-S-5', 'invoice', 'base', 100, null, '27', array['27']::text[], 100, 'CO-VAT-300', 10),
    ('CO-S-5', 'invoice', 'tax', 100, '240810', '58', array['58']::text[], 100, 'CO-VAT-300', 20),
    ('CO-S-5', 'credit_note', 'base', 100, null, '27', array['27']::text[], -100, 'CO-VAT-300', 10),
    ('CO-S-5', 'credit_note', 'tax', 100, '240810', '58', array['58']::text[], -100, 'CO-VAT-300', 20),
    ('CO-S-EXC', 'invoice', 'base', 100, null, '39', array['39']::text[], 100, 'CO-VAT-300', 10),
    ('CO-S-EXC', 'credit_note', 'base', 100, null, '39', array['39']::text[], -100, 'CO-VAT-300', 10),
    ('CO-S-EXE', 'invoice', 'base', 100, null, '35', array['35']::text[], 100, 'CO-VAT-300', 10),
    ('CO-S-EXE', 'credit_note', 'base', 100, null, '35', array['35']::text[], -100, 'CO-VAT-300', 10),
    ('CO-S-EXP', 'invoice', 'base', 100, null, '30', array['30']::text[], 100, 'CO-VAT-300', 10),
    ('CO-S-EXP', 'credit_note', 'base', 100, null, '30', array['30']::text[], -100, 'CO-VAT-300', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'CO' and t.code = v.tax_code
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
   deadline_reference, deadline_source_key, file_format,
   rounding_unit, rounding_reference, rounding_source_key)
values
  ('CO', 'CO-VAT-300', 'Declaración del Impuesto sobre las Ventas — IVA (Formulario 300)', array['bimonth', 'four_month']::declaration_period[], null, date '1970-01-01', null, 'Estatuto Tributario, art. 600 — los responsables del impuesto sobre las ventas declaran de forma bimestral cuando son grandes contribuyentes, cuando se trata de los sujetos de los artículos 477 y 481, cuando inician actividades en el ejercicio, o cuando sus ingresos brutos a 31 de diciembre del año anterior fueron iguales o superiores a 92.000 UVT; o de forma cuatrimestral cuando esos ingresos fueron inferiores a 92.000 UVT. La ley no da una respuesta única a todo declarante — depende de un hecho propio de cada uno, el monto de sus ingresos del año anterior — por lo que este formulario no declara un period_default', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Decreto 1625 de 2016 (Decreto Único Reglamentario en materia tributaria), a partir del art. 1.6.1.13.2.6 — los plazos para presentar y pagar la declaración del impuesto sobre las ventas, bimestral o cuatrimestral, se asignan por el último dígito del Número de Identificación Tributaria (NIT) del declarante, sin el dígito de verificación, y se fijan de nuevo cada año por el decreto que compila el calendario tributario del período siguiente', 'dur1625', null, 1000, 'Estatuto Tributario, art. 868 — aproximación de las cifras al múltiplo de mil más cercano cuando el resultado supera diez mil pesos; el instructivo del Formulario 300 lo repite para toda casilla: «todas las casillas destinadas a valores deben ser diligenciadas y aproximadas al múltiplo de mil (1000) más cercano»', 'form300')
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
  rounding_unit       = excluded.rounding_unit,
  rounding_reference  = excluded.rounding_reference,
  rounding_source_key = excluded.rounding_source_key,
  file_format         = excluded.file_format;

insert into tax_report_box_templates
  (country, report_code, box, kind, name, name_i18n, sequence, print_sequence,
   plus_boxes, minus_boxes, rate, rate_of_box, floor_zero, hidden, xml_element,
   legal_reference, source_key)
values
  ('CO', 'CO-VAT-300', '27', 'base', 'Por operaciones gravadas al 5 %', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 27 — ingresos por operaciones gravadas a la tarifa del 5 %, de los artículos 468-1 y 468-3 del Estatuto Tributario', 'form300'),
  ('CO', 'CO-VAT-300', '28', 'base', 'Por operaciones gravadas a la tarifa general', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 28 — ingresos por operaciones gravadas a la tarifa general del impuesto sobre las ventas', 'form300'),
  ('CO', 'CO-VAT-300', '30', 'base', 'Por exportación de bienes', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 30 — valor FOB de las exportaciones de bienes realizadas en el período (Estatuto Tributario, art. 481, literal a)', 'form300'),
  ('CO', 'CO-VAT-300', '35', 'base', 'Por operaciones exentas', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 35 — ingresos por operaciones exentas realizadas en el territorio nacional (Estatuto Tributario, art. 477)', 'form300'),
  ('CO', 'CO-VAT-300', '39', 'base', 'Por operaciones excluidas', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 39 — valores de operaciones de venta de bienes y de prestación de servicios que la ley ha calificado como excluidas (Estatuto Tributario, arts. 424, 426, 427 y 476)', 'form300'),
  ('CO', 'CO-VAT-300', '50', 'base', 'De bienes gravados a la tarifa del 5 %', '{}'::jsonb, 60, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 50 — compras nacionales de bienes del artículo 468-1 del Estatuto Tributario', 'form300'),
  ('CO', 'CO-VAT-300', '51', 'base', 'De bienes gravados a la tarifa general', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 51 — compras nacionales de bienes gravados a la tarifa general', 'form300'),
  ('CO', 'CO-VAT-300', '53', 'base', 'De servicios gravados a la tarifa general', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 53 — servicios gravados a la tarifa general tomados en el período', 'form300'),
  ('CO', 'CO-VAT-300', '54', 'base', 'De bienes y servicios excluidos, exentos y no gravados', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 54 — compras de bienes y servicios excluidos, exentos y no gravados efectuadas en el período', 'form300'),
  ('CO', 'CO-VAT-300', '58', 'tax', 'A la tarifa del 5 %', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 58 — impuesto generado durante el período a la tarifa del 5 %, sobre las operaciones de los artículos 468-1 y 468-3 del Estatuto Tributario', 'form300'),
  ('CO', 'CO-VAT-300', '59', 'tax', 'A la tarifa general', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 59 — impuesto generado durante el período a la tarifa general', 'form300'),
  ('CO', 'CO-VAT-300', '67', 'total', 'Total impuesto generado por operaciones gravadas', '{}'::jsonb, 120, null, array['58', '59']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 67 — suma de los valores del impuesto generado declarados en las casillas 58 a 66; este paquete sólo declara las casillas 58 y 59', 'form300'),
  ('CO', 'CO-VAT-300', '71', 'tax', 'Por compras de bienes gravados a la tarifa del 5 %', '{}'::jsonb, 130, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 71 — impuesto sobre las ventas facturado en la compra de bienes gravados a la tarifa del 5 % para el desarrollo de las actividades productoras de renta', 'form300'),
  ('CO', 'CO-VAT-300', '72', 'tax', 'Por compras de bienes gravados a la tarifa general', '{}'::jsonb, 140, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 72 — impuesto sobre las ventas facturado en la compra de bienes gravados a la tarifa general', 'form300'),
  ('CO', 'CO-VAT-300', '75', 'tax', 'Por servicios gravados a la tarifa general', '{}'::jsonb, 150, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 75 — impuesto sobre las ventas facturado en la prestación de servicios gravados a la tarifa general, necesarios para el desarrollo de las actividades productoras de renta', 'form300'),
  ('CO', 'CO-VAT-300', '77', 'total', 'Total impuesto pagado o facturado', '{}'::jsonb, 160, null, array['71', '72', '75']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 77 — suma de los valores registrados en las casillas 68 a 76; este paquete sólo declara las casillas 71, 72 y 75', 'form300'),
  ('CO', 'CO-VAT-300', '81', 'total', 'Total impuestos descontables', '{}'::jsonb, 170, null, array['77']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 300, casilla 81 — suma de la casilla 77 (total impuesto pagado o facturado), la casilla 78 (IVA retenido por servicios de no domiciliados) y la casilla 79 (IVA de devoluciones en ventas), menos la casilla 80 (ajuste por pérdidas, hurto o castigo de inventarios); este paquete no declara las casillas 78, 79 y 80', 'form300'),
  ('CO', 'CO-VAT-300', '82', 'total', 'Saldo a pagar por el período fiscal', '{}'::jsonb, 180, null, array['67']::text[], array['81']::text[], null, null, true, false, null, 'Formulario 300, casilla 82 — resultado de tomar la casilla 67 (total impuesto generado) y restar la casilla 81 (total impuestos descontables); si el resultado es negativo, se escribe cero', 'form300'),
  ('CO', 'CO-VAT-300', '83', 'total', 'Saldo a favor del período fiscal', '{}'::jsonb, 190, null, array['81']::text[], array['67']::text[], null, null, true, false, null, 'Formulario 300, casilla 83 — resultado de tomar la casilla 81 (total impuestos descontables) y restar la casilla 67 (total impuesto generado); si el resultado es negativo, se escribe cero', 'form300')
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
  ('CO-DECRETO2649-ER', 'CO', 'default', 'Estado de resultado integral', 'income_statement', 'CO-PUC', date '1970-01-01', null, 'Decreto 2650 de 1993, art. 4 — el catálogo de cuentas agrupa las clases 4 (ingresos), 5 (gastos) y 6 (costos de ventas), de las que resulta el estado de resultados; Decreto 2706 de 2012, sección 4 — estado de resultado integral abreviado del grupo 3 (microempresas)', 'decreto2706'),
  ('CO-DECRETO2649-ESF', 'CO', 'default', 'Estado de situación financiera', 'balance_sheet', 'CO-PUC', date '1970-01-01', null, 'Decreto 2650 de 1993, art. 4 — el catálogo de cuentas agrupa las clases 1 (activo), 2 (pasivo) y 3 (patrimonio), que conforman el balance general; Decreto 2706 de 2012, sección 4 (grupo 3, microempresas) — estado de situación financiera abreviado, el formato oficial más simple para quien no está obligado a la presentación completa de los grupos 1 y 2', 'decreto2706')
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
  ('CO-DECRETO2649-ER', '41', 'ING', 'Ingresos operacionales', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '42', 'ING', 'Ingresos no operacionales', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', 'ING', null, 'Total ingresos', '{}'::jsonb, 30, 1, true, array['41', '42']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '61', 'CV', 'Costo de ventas y de prestación de servicios', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '62', 'CV', 'Compras', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', 'CV', null, 'Total costo de ventas', '{}'::jsonb, 60, 1, true, array['61', '62']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '51', 'GO', 'Gastos operacionales de administración', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '52', 'GO', 'Gastos operacionales de ventas', '{}'::jsonb, 80, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', 'GO', null, 'Total gastos operacionales', '{}'::jsonb, 90, 1, true, array['51', '52']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '53', null, 'Gastos no operacionales', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', '54', null, 'Impuesto de renta y complementarios', '{}'::jsonb, 110, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ER', 'UN', null, 'Utilidad o pérdida del ejercicio', '{}'::jsonb, 120, 1, true, array['ING']::text[], array['CV', 'GO', '53', '54']::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '11', 'AC', 'Disponible', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '12', 'ANC', 'Inversiones', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '13', 'AC', 'Deudores', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '14', 'AC', 'Inventarios', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '15', 'ANC', 'Propiedades, planta y equipo', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '16', 'ANC', 'Intangibles', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '17', 'AC', 'Diferidos', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', 'AC', 'ACT', 'Total activo corriente', '{}'::jsonb, 80, 1, true, array['11', '13', '14', '17']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', 'ANC', 'ACT', 'Total activo no corriente', '{}'::jsonb, 90, 1, true, array['12', '15', '16']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', 'ACT', null, 'Total activo', '{}'::jsonb, 100, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '21', 'PAS', 'Obligaciones financieras', '{}'::jsonb, 110, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '22', 'PAS', 'Proveedores', '{}'::jsonb, 120, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '23', 'PAS', 'Cuentas por pagar', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '24', 'PAS', 'Impuestos, gravámenes y tasas', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '25', 'PAS', 'Obligaciones laborales', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '26', 'PAS', 'Pasivos estimados y provisiones', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '27', 'PAS', 'Diferidos', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '28', 'PAS', 'Otros pasivos', '{}'::jsonb, 180, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', 'PAS', null, 'Total pasivo', '{}'::jsonb, 190, 1, true, array['21', '22', '23', '24', '25', '26', '27', '28']::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '31', 'PAT', 'Capital social', '{}'::jsonb, 200, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '33', 'PAT', 'Reservas', '{}'::jsonb, 210, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '36', 'PAT', 'Resultado del ejercicio', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', '37', 'PAT', 'Resultados de ejercicios anteriores', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('CO-DECRETO2649-ESF', 'PAT', null, 'Total patrimonio', '{}'::jsonb, 240, 1, true, array['31', '33', '36', '37']::text[], '{}'::text[], null, null, null)
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
    ('CO-DECRETO2649-ER', '41', 10, 'code_prefix', '41', null, null, 'any'),
    ('CO-DECRETO2649-ER', '42', 10, 'code_prefix', '42', null, null, 'any'),
    ('CO-DECRETO2649-ER', '61', 10, 'code_prefix', '61', null, null, 'any'),
    ('CO-DECRETO2649-ER', '62', 10, 'code_prefix', '62', null, null, 'any'),
    ('CO-DECRETO2649-ER', '51', 10, 'code_prefix', '51', null, null, 'any'),
    ('CO-DECRETO2649-ER', '52', 10, 'code_prefix', '52', null, null, 'any'),
    ('CO-DECRETO2649-ER', '53', 10, 'code_prefix', '53', null, null, 'any'),
    ('CO-DECRETO2649-ER', '54', 10, 'code_prefix', '54', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '11', 10, 'code_prefix', '11', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '12', 10, 'code_prefix', '12', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '13', 10, 'code_prefix', '13', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '14', 10, 'code_prefix', '14', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '15', 10, 'code_prefix', '15', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '16', 10, 'code_prefix', '16', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '17', 10, 'code_prefix', '17', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '21', 10, 'code_prefix', '21', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '22', 10, 'code_prefix', '22', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '23', 10, 'code_prefix', '23', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '24', 10, 'code_prefix', '24', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '25', 10, 'code_prefix', '25', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '26', 10, 'code_prefix', '26', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '27', 10, 'code_prefix', '27', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '28', 10, 'code_prefix', '28', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '31', 10, 'code_prefix', '31', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '33', 10, 'code_prefix', '33', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '36', 10, 'code_prefix', '36', null, null, 'any'),
    ('CO-DECRETO2649-ESF', '37', 10, 'code_prefix', '37', null, null, 'any')
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
  ('CO', 'Colombia', '{}'::jsonb, array['es']::text[], 'COP', '1305', '2205', '2815', '429581', '3705', '4135', '6205', '111005', '110505', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '3605', '3610', '3710', 'APE', 'half_up', default, '421020', '530525', null, null, null, null, '240825', '135520', 'Comprobante de apertura', null)
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
  number_format                 = '{CODE}{NNNNNNNN}',
  legal_payment_days            = null,
  late_payment_reference        = null,
  numbering_legal_reference     = 'Estatuto Tributario, art. 617, literal d) — la factura debe llevar «un número que corresponda a un sistema de numeración consecutiva de facturas de venta», y la Resolución DIAN 000165 de 2023 (título de numeración) autoriza rangos de numeración por prefijo a cada facturador. Ese consecutivo — el número de la pieza contable de este paquete — es distinto del CUFE (Código Único de Factura Electrónica), la huella criptográfica de 96 caracteres que la validación previa añade a cada documento y que Ekwo no calcula: ver la sección de facturación electrónica',
  numbering_source_key          = 'et',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'invoice_if_issued',
  tax_point_legal_reference     = 'Estatuto Tributario, art. 429 — en las ventas de bienes, el impuesto se causa en la fecha de emisión de la factura o documento equivalente y, a falta de estos, en el momento de la entrega, aunque se haya pactado reserva de dominio, pacto de retroventa o condición resolutoria (literal a); en la prestación de servicios, en la fecha de emisión de la factura, o en la fecha de terminación de los servicios, o en la fecha del pago o abono en cuenta, la que fuere anterior (literal b). El paquete declara la regla general de la venta de bienes, invoice_if_issued; la prestación de servicios añade un tercer punto de anclaje (la terminación del servicio) que el vocabulario cerrado de esta casilla no nombra — ver docs/international.md',
  tax_point_source_key          = 'et',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Estatuto Tributario, art. 617 y art. 616-1 en concordancia con la Resolución DIAN 000165 de 2023 — una factura de venta validada previamente por la DIAN sólo se anula o corrige mediante una nota crédito o una nota débito que la referencie; no existe un mecanismo para devolver un documento validado a borrador',
  posted_edit_policy_source_key = 'res165',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Estatuto Tributario, art. 615 y art. 616-1 — todo obligado a facturar debe expedir factura electrónica de venta con validación previa por parte de la DIAN, y la Resolución DIAN 000165 de 2023, título I, adopta el Anexo Técnico de Factura Electrónica de Venta, versión 1.9, en vigor desde el 1 de mayo de 2024. Es un régimen de validación previa (clearance): antes de su expedición, el documento se transmite a la DIAN (o a un proveedor tecnológico autorizado) para su validación, que le asigna el Código Único de Factura Electrónica (CUFE), un resumen criptográfico de 96 caracteres calculado sobre los datos de la factura y una clave técnica de la DIAN — no un intercambio par a par entre el emisor y el comprador construido sobre el modelo semántico de EN 16931. EKWO NO GENERA, NO CALCULA EL CUFE Y NO TRANSMITE NINGÚN DOCUMENTO A LA DIAN: ningún componente de packages/formats escribe el XML UBL de la factura electrónica de venta ni dialoga con la DIAN o con un proveedor tecnológico. Por eso profile, mandatory_from, party_scheme y vat_scheme quedan vacíos aunque la obligación exista: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe (peppol-bis-3, factur-x-en16931, xrechnung, un PINT), y la factura electrónica colombiana no es ninguno de ellos; el formato tampoco tiene una palabra para «válida sólo tras la validación previa de un tercero» — véase docs/international.md. El Número de Identificación Tributaria (NIT) identifica al emisor y al receptor y no tiene un código ISO 6523 registrado: party_scheme y vat_scheme quedan vacíos por la misma razón que en México',
  einvoice_source_key           = 'res165',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'CO';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('CO', 'cufe_not_assigned', 'always', 'Este documento no es una factura electrónica de venta: no lleva el Código Único de Factura Electrónica (CUFE) ni ha sido validado previamente por la DIAN. Sólo la factura electrónica validada ampara la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Estatuto Tributario, art. 616-1, y Resolución DIAN 000165 de 2023 — el sistema de facturación electrónica exige la validación previa del documento por la DIAN, o por su plataforma gratuita, antes de su expedición; la validación asigna el CUFE. Ekwo no genera ni transmite el XML UBL de la factura electrónica ni habla con el sistema de la DIAN: ver la sección de facturación electrónica de este paquete'),
  ('CO', 'export', 'export', 'Exportación de bienes — bien exento del impuesto sobre las ventas con derecho a devolución bimestral (artículo 481, literal a, del Estatuto Tributario).', '{}'::jsonb, 20, date '1970-01-01', null, 'Estatuto Tributario, art. 481, literal a) — los bienes corporales muebles que se exporten están exentos del impuesto sobre las ventas, con derecho a devolución bimestral para su productor'),
  ('CO', 'exempt', 'exempt', 'Bien excluido del impuesto sobre las ventas: su venta no causa el impuesto y no da derecho a descontar el impuesto pagado en su producción (artículos 424 y 476 del Estatuto Tributario).', '{}'::jsonb, 30, date '1970-01-01', null, 'Estatuto Tributario, art. 424 — bienes que no causan el impuesto, entre ellos productos agrícolas de la canasta familiar en su estado natural, como la papa; art. 476 — servicios excluidos del impuesto. Ninguno de los dos da derecho a descontar el impuesto pagado en la producción del bien o la prestación del servicio (art. 491), a diferencia del bien exento del artículo 477, que si lo da y que este paquete declara con tratamiento domestic a tarifa cero — véase la tabla de tratamientos de docs/packs.md')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
