-- Ekwo OS — Ecuador: chart of accounts, journals, taxes and defaults.
--
-- Generated from packs/ec at version 0.1.0, do not edit.
-- Change the pack and run `ekwo pack build ec`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Community pack — not reviewed.
-- Written from:
--   Ley de Régimen Tributario Interno (Codificación No. 2004-026), con sus reformas — incluida la Ley Orgánica para Enfrentar el Conflicto Armado Interno, la Crisis Social y Económica (Registro Oficial Suplemento 516, 14 de marzo de 2024), que reformó el artículo 65 (Servicio de Rentas Internas (SRI) — Dirección Nacional Jurídica)
--     https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/1c04850c-093e-44bf-ba98-e9bc8baae57e/Ley_Regimen_Tributario_Interno_20_jun_2023.pdf
--   Decreto Ejecutivo No. 198 del 15 de marzo de 2024 — aplica la tarifa general del impuesto al valor agregado del 15 % a partir del 1 de abril de 2024, dentro del rango del 13 % al 15 % que fija el artículo 65 de la Ley de Régimen Tributario Interno (Servicio Nacional de Aduana del Ecuador (SENAE) — publicación oficial del decreto)
--     https://www.aduana.gob.ec/gaceta-boletin/aplicacion-de-la-tarifa-15-del-impuesto-al-valor-agregado-iva-a-la-importacion-de-bienes-a-partir-del-01-de-abril-de-2024/
--   Reglamento para la Aplicación de la Ley de Régimen Tributario Interno (RALRTI) (Servicio de Rentas Internas (SRI))
--     https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/aa569bb7-b871-458c-a8c7-6bcf49841843/Reglamento_LRTI_24Nov2023.pdf
--   Formulario IVA (Formulario 104) y Guía para contribuyentes — Elaboración y envío de la declaración del Impuesto al Valor Agregado (Servicio de Rentas Internas (SRI))
--     https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/e084fae5-9677-450c-8161-21e7c3a9f65b/Gu%C3%ADa%20para%20el%20llenado%20del%20Formulario%20Impuesto%20al%20Valor%20Agregado%20IVA.PDF
--   Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios (Servicio de Rentas Internas (SRI))
--     https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar?id=142f0d6e-b156-4ac6-b804-0bd4938bc7b8&nombre=Reglamento+de+Comprobantes+de+Venta%2C+Retenci%EF%BF%BDn+y+Documentos+Complementarios.pdf
--   Facturación electrónica — esquema de validación previa (autorización, clave de acceso), esquema offline y transmisión inmediata de comprobantes (Servicio de Rentas Internas (SRI))
--     https://www.sri.gob.ec/en/facturacion-electronica
--   SRI en línea — portal de declaración de impuestos (Declaraciones / Declaración de Impuestos / Elaboración y envío de declaraciones) (Servicio de Rentas Internas (SRI))
--     https://srienlinea.sri.gob.ec
--   Ley de Régimen Tributario Interno, arts. 19 a 21 — obligación de llevar contabilidad, principios generales y estados financieros (Servicio de Rentas Internas (SRI) — SRinforma)
--     https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/e48abc39-3dee-49d2-93d7-3cbe5d01c704/Art.+19+Contabilidad+y+Estados+Financieros.pdf
--
-- Reference data: `install_country_template()` copies it into a company,
-- nothing here belongs to a company.

insert into country_packs
  (country, name, version, released_at, schema_min, certification_status,
   certified_by, certified_at, checksum, sources)
values
  ('EC', 'Ecuador', '0.1.0', date '2026-09-26', '20260923110000', 'community', null, null, '2483f460ed5afe31dd2c72c7b6eecfdaa6c613673045ec9b451bdd664db85ace', '[{"key":"lrti","title":"Ley de Régimen Tributario Interno (Codificación No. 2004-026), con sus reformas — incluida la Ley Orgánica para Enfrentar el Conflicto Armado Interno, la Crisis Social y Económica (Registro Oficial Suplemento 516, 14 de marzo de 2024), que reformó el artículo 65","publisher":"Servicio de Rentas Internas (SRI) — Dirección Nacional Jurídica","url":"https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/1c04850c-093e-44bf-ba98-e9bc8baae57e/Ley_Regimen_Tributario_Interno_20_jun_2023.pdf","consulted_on":"2026-09-26","kind":"law"},{"key":"decreto198","title":"Decreto Ejecutivo No. 198 del 15 de marzo de 2024 — aplica la tarifa general del impuesto al valor agregado del 15 % a partir del 1 de abril de 2024, dentro del rango del 13 % al 15 % que fija el artículo 65 de la Ley de Régimen Tributario Interno","publisher":"Servicio Nacional de Aduana del Ecuador (SENAE) — publicación oficial del decreto","url":"https://www.aduana.gob.ec/gaceta-boletin/aplicacion-de-la-tarifa-15-del-impuesto-al-valor-agregado-iva-a-la-importacion-de-bienes-a-partir-del-01-de-abril-de-2024/","consulted_on":"2026-09-26","kind":"regulation"},{"key":"ralrti","title":"Reglamento para la Aplicación de la Ley de Régimen Tributario Interno (RALRTI)","publisher":"Servicio de Rentas Internas (SRI)","url":"https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/aa569bb7-b871-458c-a8c7-6bcf49841843/Reglamento_LRTI_24Nov2023.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"form104","title":"Formulario IVA (Formulario 104) y Guía para contribuyentes — Elaboración y envío de la declaración del Impuesto al Valor Agregado","publisher":"Servicio de Rentas Internas (SRI)","url":"https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/e084fae5-9677-450c-8161-21e7c3a9f65b/Gu%C3%ADa%20para%20el%20llenado%20del%20Formulario%20Impuesto%20al%20Valor%20Agregado%20IVA.PDF","consulted_on":"2026-09-26","kind":"form"},{"key":"reglamento-comprobantes","title":"Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios","publisher":"Servicio de Rentas Internas (SRI)","url":"https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar?id=142f0d6e-b156-4ac6-b804-0bd4938bc7b8&nombre=Reglamento+de+Comprobantes+de+Venta%2C+Retenci%EF%BF%BDn+y+Documentos+Complementarios.pdf","consulted_on":"2026-09-26","kind":"regulation"},{"key":"sri-facturacion","title":"Facturación electrónica — esquema de validación previa (autorización, clave de acceso), esquema offline y transmisión inmediata de comprobantes","publisher":"Servicio de Rentas Internas (SRI)","url":"https://www.sri.gob.ec/en/facturacion-electronica","consulted_on":"2026-09-26","kind":"guidance"},{"key":"sri-en-linea","title":"SRI en línea — portal de declaración de impuestos (Declaraciones / Declaración de Impuestos / Elaboración y envío de declaraciones)","publisher":"Servicio de Rentas Internas (SRI)","url":"https://srienlinea.sri.gob.ec","consulted_on":"2026-09-26","kind":"portal"},{"key":"lrti-contabilidad","title":"Ley de Régimen Tributario Interno, arts. 19 a 21 — obligación de llevar contabilidad, principios generales y estados financieros","publisher":"Servicio de Rentas Internas (SRI) — SRinforma","url":"https://www.sri.gob.ec/o/sri-portlet-biblioteca-alfresco-internet/descargar/e48abc39-3dee-49d2-93d7-3cbe5d01c704/Art.+19+Contabilidad+y+Estados+Financieros.pdf","consulted_on":"2026-09-26","kind":"guidance"}]'::jsonb)
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
  ('EC', 'default', 'Plan de cuentas — clasificación NIIF', '{}'::jsonb, true, 'companies', array['EC-NIIF-ER', 'EC-NIIF-ESF']::text[], null, 'No existe en Ecuador un catálogo de cuentas obligatorio para toda sociedad. La Ley de Régimen Tributario Interno, art. 20 (reformado por el art. 80 de la Ley s/n, R.O. 242-3S, 29-XII-2007), exige llevar la contabilidad por el sistema de partida doble, en idioma castellano y en dólares de los Estados Unidos de América, tomando en consideración los principios contables de general aceptación — en la práctica actual, las Normas Internacionales de Información Financiera (NIIF completas o NIIF para las PYMES, según el tamaño de la compañía) que adoptó la Superintendencia de Compañías, Valores y Seguros; y el art. 21 dispone que esos mismos estados financieros sirven de base tanto para las declaraciones de impuestos como para su presentación a la Superintendencia de Compañías. Este plan es original: sigue la clasificación en activo, pasivo, patrimonio, ingresos y gastos que las NIIF prescriben, de modo que cada cuenta de detalle alcanza exactamente una línea de EC-NIIF-ESF o de EC-NIIF-ER, tal como lo hacen los planes de cuentas de los paquetes de Estados Unidos y del Reino Unido para el mismo motivo', 'lrti-contabilidad')
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
  ('EC', 'default', '1', 'ACTIVO', '{}'::jsonb, 'asset_current', false, null, 10),
  ('EC', 'default', '1.1', 'ACTIVO CORRIENTE', '{}'::jsonb, 'asset_current', false, '1', 20),
  ('EC', 'default', '1.1.01', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 'asset_cash', false, '1.1', 30),
  ('EC', 'default', '1.1.01.01', 'Caja general', '{}'::jsonb, 'asset_cash', false, '1.1.01', 40),
  ('EC', 'default', '1.1.01.02', 'Caja chica', '{}'::jsonb, 'asset_cash', false, '1.1.01', 50),
  ('EC', 'default', '1.1.01.03', 'Bancos', '{}'::jsonb, 'asset_cash', false, '1.1.01', 60),
  ('EC', 'default', '1.1.02', 'Activos financieros', '{}'::jsonb, 'asset_current', false, '1.1', 70),
  ('EC', 'default', '1.1.02.01', 'Inversiones a corto plazo', '{}'::jsonb, 'asset_current', false, '1.1.02', 80),
  ('EC', 'default', '1.1.02.02', 'Documentos por cobrar a corto plazo', '{}'::jsonb, 'asset_current', false, '1.1.02', 90),
  ('EC', 'default', '1.1.03', 'Cuentas y documentos por cobrar comerciales', '{}'::jsonb, 'asset_current', false, '1.1', 100),
  ('EC', 'default', '1.1.03.01', 'Clientes locales', '{}'::jsonb, 'asset_receivable', true, '1.1.03', 110),
  ('EC', 'default', '1.1.03.02', 'Clientes del exterior', '{}'::jsonb, 'asset_receivable', true, '1.1.03', 120),
  ('EC', 'default', '1.1.03.03', '(-) Provision cuentas incobrables', '{}'::jsonb, 'asset_current', false, '1.1.03', 130),
  ('EC', 'default', '1.1.04', 'Otras cuentas por cobrar', '{}'::jsonb, 'asset_current', false, '1.1', 140),
  ('EC', 'default', '1.1.04.01', 'Anticipos a proveedores', '{}'::jsonb, 'asset_current', false, '1.1.04', 150),
  ('EC', 'default', '1.1.04.02', 'Cuentas por cobrar empleados', '{}'::jsonb, 'asset_current', false, '1.1.04', 160),
  ('EC', 'default', '1.1.04.03', 'Depositos en garantia', '{}'::jsonb, 'asset_current', false, '1.1.04', 170),
  ('EC', 'default', '1.1.05', 'Inventarios', '{}'::jsonb, 'asset_current', false, '1.1', 180),
  ('EC', 'default', '1.1.05.01', 'Inventario de mercaderias', '{}'::jsonb, 'asset_current', false, '1.1.05', 190),
  ('EC', 'default', '1.1.05.02', 'Inventario de materia prima', '{}'::jsonb, 'asset_current', false, '1.1.05', 200),
  ('EC', 'default', '1.1.06', 'Servicios y otros pagos anticipados', '{}'::jsonb, 'asset_prepayments', false, '1.1', 210),
  ('EC', 'default', '1.1.06.01', 'Seguros pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '1.1.06', 220),
  ('EC', 'default', '1.1.06.02', 'Arriendos pagados por anticipado', '{}'::jsonb, 'asset_prepayments', false, '1.1.06', 230),
  ('EC', 'default', '1.1.07', 'Activos por impuestos corrientes', '{}'::jsonb, 'asset_current', false, '1.1', 240),
  ('EC', 'default', '1.1.07.01', 'Credito tributario de IVA por compensar', '{}'::jsonb, 'asset_current', true, '1.1.07', 250),
  ('EC', 'default', '1.1.07.02', 'Retenciones en la fuente de impuesto a la renta que le han sido efectuadas', '{}'::jsonb, 'asset_current', false, '1.1.07', 260),
  ('EC', 'default', '1.1.07.03', 'Anticipo de impuesto a la renta', '{}'::jsonb, 'asset_current', false, '1.1.07', 270),
  ('EC', 'default', '1.2', 'ACTIVO NO CORRIENTE', '{}'::jsonb, 'asset_non_current', false, '1', 280),
  ('EC', 'default', '1.2.01', 'Propiedades planta y equipo', '{}'::jsonb, 'asset_fixed', false, '1.2', 290),
  ('EC', 'default', '1.2.01.01', 'Terrenos', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 300),
  ('EC', 'default', '1.2.01.02', 'Edificios', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 310),
  ('EC', 'default', '1.2.01.03', 'Muebles y enseres', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 320),
  ('EC', 'default', '1.2.01.04', 'Equipo de computacion', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 330),
  ('EC', 'default', '1.2.01.05', 'Vehiculos', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 340),
  ('EC', 'default', '1.2.01.06', 'Equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 350),
  ('EC', 'default', '1.2.01.07', '(-) Depreciacion acumulada edificios', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 360),
  ('EC', 'default', '1.2.01.08', '(-) Depreciacion acumulada muebles y enseres', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 370),
  ('EC', 'default', '1.2.01.09', '(-) Depreciacion acumulada equipo de computacion', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 380),
  ('EC', 'default', '1.2.01.10', '(-) Depreciacion acumulada vehiculos', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 390),
  ('EC', 'default', '1.2.01.11', '(-) Depreciacion acumulada equipo de oficina', '{}'::jsonb, 'asset_fixed', false, '1.2.01', 400),
  ('EC', 'default', '1.2.02', 'Activos intangibles', '{}'::jsonb, 'asset_non_current', false, '1.2', 410),
  ('EC', 'default', '1.2.02.01', 'Marcas y patentes', '{}'::jsonb, 'asset_non_current', false, '1.2.02', 420),
  ('EC', 'default', '1.2.02.02', '(-) Amortizacion acumulada activos intangibles', '{}'::jsonb, 'asset_non_current', false, '1.2.02', 430),
  ('EC', 'default', '2', 'PASIVO', '{}'::jsonb, 'liability_current', false, null, 440),
  ('EC', 'default', '2.1', 'PASIVO CORRIENTE', '{}'::jsonb, 'liability_current', false, '2', 450),
  ('EC', 'default', '2.1.01', 'Cuentas y documentos por pagar', '{}'::jsonb, 'liability_current', false, '2.1', 460),
  ('EC', 'default', '2.1.01.01', 'Proveedores locales', '{}'::jsonb, 'liability_payable', true, '2.1.01', 470),
  ('EC', 'default', '2.1.01.02', 'Proveedores del exterior', '{}'::jsonb, 'liability_payable', true, '2.1.01', 480),
  ('EC', 'default', '2.1.01.03', 'Documentos por pagar proveedores', '{}'::jsonb, 'liability_payable', true, '2.1.01', 490),
  ('EC', 'default', '2.1.02', 'Obligaciones con instituciones financieras', '{}'::jsonb, 'liability_current', false, '2.1', 500),
  ('EC', 'default', '2.1.02.01', 'Prestamos bancarios a corto plazo', '{}'::jsonb, 'liability_current', false, '2.1.02', 510),
  ('EC', 'default', '2.1.03', 'Otras obligaciones corrientes con la administracion tributaria', '{}'::jsonb, 'liability_current', false, '2.1', 520),
  ('EC', 'default', '2.1.03.01', 'Retenciones en la fuente de impuesto a la renta por pagar', '{}'::jsonb, 'liability_current', false, '2.1.03', 530),
  ('EC', 'default', '2.1.03.02', 'Retenciones en la fuente de IVA por pagar', '{}'::jsonb, 'liability_current', false, '2.1.03', 540),
  ('EC', 'default', '2.1.03.03', 'Impuesto a la renta por pagar del ejercicio', '{}'::jsonb, 'liability_current', false, '2.1.03', 550),
  ('EC', 'default', '2.1.04', 'Impuesto al valor agregado', '{}'::jsonb, 'liability_current', false, '2.1', 560),
  ('EC', 'default', '2.1.04.01', 'IVA en ventas tarifa 15%', '{}'::jsonb, 'liability_current', false, '2.1.04', 570),
  ('EC', 'default', '2.1.04.02', 'Credito tributario de IVA en compras tarifa 15%', '{}'::jsonb, 'liability_current', false, '2.1.04', 580),
  ('EC', 'default', '2.1.04.03', 'IVA por pagar del periodo', '{}'::jsonb, 'liability_current', true, '2.1.04', 590),
  ('EC', 'default', '2.1.05', 'Otras cuentas por pagar', '{}'::jsonb, 'liability_current', false, '2.1', 600),
  ('EC', 'default', '2.1.05.01', 'Anticipos de clientes', '{}'::jsonb, 'liability_current', false, '2.1.05', 610),
  ('EC', 'default', '2.1.05.02', 'Obligaciones con el IESS', '{}'::jsonb, 'liability_current', false, '2.1.05', 620),
  ('EC', 'default', '2.1.05.03', 'Participacion trabajadores por pagar', '{}'::jsonb, 'liability_current', false, '2.1.05', 630),
  ('EC', 'default', '2.2', 'PASIVO NO CORRIENTE', '{}'::jsonb, 'liability_non_current', false, '2', 640),
  ('EC', 'default', '2.2.01', 'Prestamos bancarios a largo plazo', '{}'::jsonb, 'liability_non_current', false, '2.2', 650),
  ('EC', 'default', '3', 'PATRIMONIO NETO', '{}'::jsonb, 'equity', false, null, 660),
  ('EC', 'default', '3.1', 'Capital', '{}'::jsonb, 'equity', false, '3', 670),
  ('EC', 'default', '3.1.01', 'Capital suscrito y/o asignado', '{}'::jsonb, 'equity', false, '3.1', 680),
  ('EC', 'default', '3.1.02', 'Aportes de socios o accionistas para futura capitalizacion', '{}'::jsonb, 'equity', false, '3.1', 690),
  ('EC', 'default', '3.3', 'Reservas', '{}'::jsonb, 'equity', false, '3', 700),
  ('EC', 'default', '3.3.01', 'Reserva legal', '{}'::jsonb, 'equity', false, '3.3', 710),
  ('EC', 'default', '3.6', 'Resultados acumulados', '{}'::jsonb, 'equity_retained', false, '3', 720),
  ('EC', 'default', '3.6.01', 'Utilidades acumuladas', '{}'::jsonb, 'equity_retained', false, '3.6', 730),
  ('EC', 'default', '3.6.02', '(-) Perdidas acumuladas', '{}'::jsonb, 'equity_retained', false, '3.6', 740),
  ('EC', 'default', '3.7', 'Resultados del ejercicio', '{}'::jsonb, 'equity_retained', false, '3', 750),
  ('EC', 'default', '3.7.01', 'Ganancia neta del periodo', '{}'::jsonb, 'equity_retained', false, '3.7', 760),
  ('EC', 'default', '3.7.02', '(-) Perdida neta del periodo', '{}'::jsonb, 'equity_retained', false, '3.7', 770),
  ('EC', 'default', '4', 'INGRESOS', '{}'::jsonb, 'income', false, null, 780),
  ('EC', 'default', '4.1', 'Ingresos de actividades ordinarias', '{}'::jsonb, 'income', false, '4', 790),
  ('EC', 'default', '4.1.01', 'Venta de bienes', '{}'::jsonb, 'income', false, '4.1', 800),
  ('EC', 'default', '4.1.02', 'Prestacion de servicios', '{}'::jsonb, 'income', false, '4.1', 810),
  ('EC', 'default', '4.1.03', 'Venta de bienes al exterior (exportaciones)', '{}'::jsonb, 'income', false, '4.1', 820),
  ('EC', 'default', '4.1.04', '(-) Devoluciones en ventas', '{}'::jsonb, 'income', false, '4.1', 830),
  ('EC', 'default', '4.2', 'Otros ingresos', '{}'::jsonb, 'income_other', false, '4', 840),
  ('EC', 'default', '4.2.01', 'Intereses financieros ganados', '{}'::jsonb, 'income_other', false, '4.2', 850),
  ('EC', 'default', '4.2.02', 'Ganancia en cambio', '{}'::jsonb, 'income_other', false, '4.2', 860),
  ('EC', 'default', '4.2.03', 'Ajuste por redondeo', '{}'::jsonb, 'income_other', false, '4.2', 870),
  ('EC', 'default', '5', 'GASTOS Y COSTOS', '{}'::jsonb, 'expense', false, null, 880),
  ('EC', 'default', '5.1', 'Costo de ventas', '{}'::jsonb, 'expense_direct_cost', false, '5', 890),
  ('EC', 'default', '5.1.01', 'Costo de mercaderias vendidas', '{}'::jsonb, 'expense_direct_cost', false, '5.1', 900),
  ('EC', 'default', '5.1.02', 'Compras netas', '{}'::jsonb, 'expense_direct_cost', false, '5.1', 910),
  ('EC', 'default', '5.2', 'Gastos de administracion', '{}'::jsonb, 'expense', false, '5', 920),
  ('EC', 'default', '5.2.01', 'Sueldos y beneficios sociales', '{}'::jsonb, 'expense', false, '5.2', 930),
  ('EC', 'default', '5.2.02', 'Honorarios profesionales', '{}'::jsonb, 'expense', false, '5.2', 940),
  ('EC', 'default', '5.2.03', 'Arrendamientos', '{}'::jsonb, 'expense', false, '5.2', 950),
  ('EC', 'default', '5.2.04', 'Suministros y materiales', '{}'::jsonb, 'expense', false, '5.2', 960),
  ('EC', 'default', '5.2.05', 'Mantenimiento y reparaciones', '{}'::jsonb, 'expense', false, '5.2', 970),
  ('EC', 'default', '5.2.06', 'Depreciacion propiedades planta y equipo', '{}'::jsonb, 'expense_depreciation', false, '5.2', 980),
  ('EC', 'default', '5.2.07', 'Servicios basicos', '{}'::jsonb, 'expense', false, '5.2', 990),
  ('EC', 'default', '5.2.08', 'Seguros', '{}'::jsonb, 'expense', false, '5.2', 1000),
  ('EC', 'default', '5.2.09', 'Impuestos contribuciones y otros', '{}'::jsonb, 'expense', false, '5.2', 1010),
  ('EC', 'default', '5.2.10', 'Gastos de viaje', '{}'::jsonb, 'expense', false, '5.2', 1020),
  ('EC', 'default', '5.3', 'Gastos de venta', '{}'::jsonb, 'expense', false, '5', 1030),
  ('EC', 'default', '5.3.01', 'Publicidad y promocion', '{}'::jsonb, 'expense', false, '5.3', 1040),
  ('EC', 'default', '5.3.02', 'Comisiones en ventas', '{}'::jsonb, 'expense', false, '5.3', 1050),
  ('EC', 'default', '5.3.03', 'Transporte y fletes en ventas', '{}'::jsonb, 'expense', false, '5.3', 1060),
  ('EC', 'default', '5.3.04', 'Empaques y embalajes', '{}'::jsonb, 'expense', false, '5.3', 1070),
  ('EC', 'default', '5.4', 'Gastos financieros', '{}'::jsonb, 'expense', false, '5', 1080),
  ('EC', 'default', '5.4.01', 'Intereses pagados', '{}'::jsonb, 'expense', false, '5.4', 1090),
  ('EC', 'default', '5.4.02', 'Perdida en cambio', '{}'::jsonb, 'expense', false, '5.4', 1100),
  ('EC', 'default', '5.4.03', 'Comisiones bancarias', '{}'::jsonb, 'expense', false, '5.4', 1110),
  ('EC', 'default', '5.5', 'Gasto por impuesto a la renta', '{}'::jsonb, 'expense', false, '5', 1120),
  ('EC', 'default', '5.5.01', 'Impuesto a la renta corriente', '{}'::jsonb, 'expense', false, '5.5', 1130)
on conflict (country, chart_code, code) do update set
  name         = excluded.name,
  name_i18n    = excluded.name_i18n,
  account_type = excluded.account_type,
  reconcilable = excluded.reconcilable,
  parent_code  = excluded.parent_code,
  sequence     = excluded.sequence;

insert into journal_templates (country, code, name, name_i18n, journal_type, sequence) values
  ('EC', 'APE', 'Asiento de apertura', '{}'::jsonb, 'opening', 60),
  ('EC', 'BAN', 'Bancos', '{}'::jsonb, 'bank', 30),
  ('EC', 'CAJ', 'Caja', '{}'::jsonb, 'cash', 40),
  ('EC', 'COM', 'Diario de compras', '{}'::jsonb, 'purchase', 20),
  ('EC', 'DIA', 'Diario general', '{}'::jsonb, 'general', 50),
  ('EC', 'VEN', 'Diario de ventas', '{}'::jsonb, 'sales', 10)
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
  ('EC', 'EC-P-0', 'Adquisiciones y pagos gravados con tarifa cero', '{}'::jsonb, 'Adquisición de bienes (incluidos activos fijos) o de servicios gravados con tarifa cero del impuesto al valor agregado', 'percent', 0, 'purchase', 'domestic', date '1989-12-29', null, 'Ley de Régimen Tributario Interno, arts. 55 y 56 — la adquisición de un bien o servicio gravado con tarifa cero no liquida impuesto que pudiera generar crédito tributario', null, null, 70, 'vat', false, '{}'::tax_condition[], null, false, false, null, 'lrti', null, null, null, null),
  ('EC', 'EC-P-15', 'Adquisiciones y pagos a la tarifa general, con derecho a crédito tributario', '{}'::jsonb, 'Adquisición de bienes (excepto activos fijos) o de servicios gravados a la tarifa general, destinados a la producción o comercialización de bienes y servicios gravados', 'percent', 15, 'purchase', 'domestic', date '2024-04-01', null, 'Ley de Régimen Tributario Interno, art. 66, inciso primero, numeral 1 — el IVA pagado en la adquisición local de bienes y servicios utilizados en la producción y comercialización de otros bienes y servicios gravados con tarifa distinta de cero, o en la exportación de bienes y servicios, da derecho a crédito tributario; art. 65 y Decreto Ejecutivo No. 198 del 15 de marzo de 2024 para la tarifa del 15 %', null, null, 50, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lrti', null, null, null, null),
  ('EC', 'EC-P-15-FIJO', 'Adquisiciones locales de activos fijos a la tarifa general, con derecho a crédito tributario', '{}'::jsonb, 'Adquisición local de propiedades, planta y equipo gravada a la tarifa general y destinada a la actividad económica del sujeto pasivo', 'percent', 15, 'purchase', 'domestic', date '2024-04-01', null, 'Ley de Régimen Tributario Interno, art. 66, inciso primero, numeral 1, en los mismos términos que la adquisición de bienes y servicios; el Formulario 104 declara la adquisición de activos fijos en una casilla distinta de la de los demás bienes y servicios (casilla 501/521 frente a 500/520)', null, null, 60, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'form104', null, null, null, null),
  ('EC', 'EC-S-0', 'Transferencias y servicios con tarifa cero, sin derecho a crédito tributario', '{}'::jsonb, 'Bienes y servicios de primera necesidad y demás casos del régimen general de tarifa cero — por ejemplo el pan, producto alimenticio de origen agrícola en estado natural', 'percent', 0, 'sale', 'exempt', date '1989-12-29', null, 'Ley de Régimen Tributario Interno, art. 55, numeral 1 (productos alimenticios de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuáticos, y de la pesca que se mantengan en estado natural, es decir que no hayan sido objeto de elaboración, proceso o tratamiento que implique modificación de su naturaleza, como el pan) — en concordancia con el art. 66, inciso primero, numeral 3: quien produce o comercializa bienes gravados con tarifa cero no tiene, por regla general, derecho a crédito tributario por el IVA pagado en las adquisiciones destinadas a esa actividad', 'E', null, 20, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lrti', null, null, null, null),
  ('EC', 'EC-S-0-PUBLICO', 'Transferencias con tarifa cero a instituciones del Estado, con derecho a crédito tributario', '{}'::jsonb, 'Venta de bienes o prestación de servicios a las instituciones del Estado y empresas públicas, uno de los casos de excepción en que la tarifa cero sí da derecho a crédito tributario', 'percent', 0, 'sale', 'domestic', date '1989-12-29', null, 'Ley de Régimen Tributario Interno, art. 57, y el artículo innumerado agregado a continuación del art. 66 — quienes vendan bienes o presten servicios a las instituciones del Estado y empresas públicas tienen derecho a crédito tributario por el IVA pagado en las adquisiciones destinadas a esas transferencias, a diferencia de la regla general del art. 66, inciso primero, numeral 3; Reglamento para la Aplicación de la Ley de Régimen Tributario Interno, art. 153', 'Z', null, 30, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lrti', null, null, null, null),
  ('EC', 'EC-S-15', 'Transferencias y servicios a la tarifa general', '{}'::jsonb, 'Transferencia de dominio de bienes muebles de naturaleza corporal y prestación de servicios en el territorio nacional, a la tarifa general del impuesto al valor agregado', 'percent', 15, 'sale', 'domestic', date '2024-04-01', null, 'Ley de Régimen Tributario Interno, art. 65, en la redacción vigente desde la Ley Orgánica para Enfrentar el Conflicto Armado Interno, la Crisis Social y Económica (R.O. Suplemento 516, 14-III-2024), que faculta al Presidente de la República a fijar la tarifa entre el 13 % y el 15 %; Decreto Ejecutivo No. 198 del 15 de marzo de 2024, art. 2 — aplica la tarifa general del 15 % a partir del 1 de abril de 2024', 'S', null, 10, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'decreto198', null, null, null, null),
  ('EC', 'EC-S-EXP', 'Exportación de bienes', '{}'::jsonb, 'Bienes corporales muebles exportados, gravados con tarifa cero, siempre que la exportación se perfeccione con la declaración aduanera de exportación', 'percent', 0, 'sale', 'export', date '1989-12-29', null, 'Ley de Régimen Tributario Interno, art. 55, numeral 14 — tienen tarifa cero las transferencias e importaciones de los bienes que se exporten, entendiéndose que ello incluye a los proveedores de las empresas exportadoras; la tarifa cero exige que el bien efectivamente salga del país, lo que se acredita con la declaración aduanera de exportación (DAE)', 'G', null, 40, 'vat', true, '{}'::tax_condition[], null, false, false, null, 'lrti', null, null, null, null)
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
    ('EC-P-0', 'invoice', 'base', 100, null, '507', array['507']::text[], 100, 'EC-IVA-104', 10),
    ('EC-P-15', 'invoice', 'base', 100, null, '500', array['500']::text[], 100, 'EC-IVA-104', 10),
    ('EC-P-15', 'invoice', 'tax', 100, '2.1.04.02', '520', array['520']::text[], 100, 'EC-IVA-104', 20),
    ('EC-P-15', 'credit_note', 'base', 100, null, '500', array['500']::text[], -100, 'EC-IVA-104', 10),
    ('EC-P-15', 'credit_note', 'tax', 100, '2.1.04.02', '520', array['520']::text[], -100, 'EC-IVA-104', 20),
    ('EC-P-15-FIJO', 'invoice', 'base', 100, null, '501', array['501']::text[], 100, 'EC-IVA-104', 10),
    ('EC-P-15-FIJO', 'invoice', 'tax', 100, '2.1.04.02', '521', array['521']::text[], 100, 'EC-IVA-104', 20),
    ('EC-S-0', 'invoice', 'base', 100, null, '403', array['403']::text[], 100, 'EC-IVA-104', 10),
    ('EC-S-0', 'credit_note', 'base', 100, null, '403', array['403']::text[], -100, 'EC-IVA-104', 10),
    ('EC-S-0-PUBLICO', 'invoice', 'base', 100, null, '405', array['405']::text[], 100, 'EC-IVA-104', 10),
    ('EC-S-0-PUBLICO', 'credit_note', 'base', 100, null, '405', array['405']::text[], -100, 'EC-IVA-104', 10),
    ('EC-S-15', 'invoice', 'base', 100, null, '401', array['401']::text[], 100, 'EC-IVA-104', 10),
    ('EC-S-15', 'invoice', 'tax', 100, '2.1.04.01', '421', array['421']::text[], 100, 'EC-IVA-104', 20),
    ('EC-S-15', 'credit_note', 'base', 100, null, '401', array['401']::text[], -100, 'EC-IVA-104', 10),
    ('EC-S-15', 'credit_note', 'tax', 100, '2.1.04.01', '421', array['421']::text[], -100, 'EC-IVA-104', 20),
    ('EC-S-EXP', 'invoice', 'base', 100, null, '407', array['407']::text[], 100, 'EC-IVA-104', 10),
    ('EC-S-EXP', 'credit_note', 'base', 100, null, '407', array['407']::text[], -100, 'EC-IVA-104', 10)
  ) as v (tax_code, document_kind, posting_type, factor_percent, account_code,
          declaration_box, declaration_boxes, box_factor_percent, report_code, sequence)
  join tax_templates t on t.country = 'EC' and t.code = v.tax_code
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
  ('EC', 'EC-IVA-104', 'Declaración del Impuesto al Valor Agregado — Formulario 104', array['month', 'half_year']::declaration_period[], null, date '1970-01-01', null, 'Ley de Régimen Tributario Interno, art. 67 — los sujetos pasivos del IVA declaran mensualmente dentro del mes siguiente a aquel en que se realizaron las operaciones; quienes transfieran exclusivamente bienes o presten exclusivamente servicios gravados con tarifa cero o no gravados, así como quienes estén sujetos a la retención total del IVA causado, presentan una declaración semestral. La ley no da una sola respuesta a todo declarante — depende de un hecho propio de cada uno, si sus ventas son exclusivamente de tarifa cero — por lo que este formulario no declara un period_default', true,'depends_on_taxpayer'::filing_deadline_rule, null, null, 'Reglamento para la Aplicación de la Ley de Régimen Tributario Interno, art. 158 — el plazo para presentar la declaración y pago del IVA se asigna según el noveno dígito del Registro Único de Contribuyentes (RUC), entre el día 10 y el día 28 del mes siguiente al que se declara; los contribuyentes especiales, el sector público y los domiciliados en Galápagos tienen fechas propias fijadas por el mismo artículo', 'ralrti', null)
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
  ('EC', 'EC-IVA-104', '401', 'base', 'Ventas locales (excluye activos fijos) gravadas tarifa diferente de cero', '{}'::jsonb, 10, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 401 — operaciones locales gravadas con tarifa diferente de cero, conforme los arts. 52 y 53 de la Ley de Régimen Tributario Interno', 'form104'),
  ('EC', 'EC-IVA-104', '421', 'tax', 'IVA generado tarifa diferente de cero', '{}'::jsonb, 20, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 421 — impuesto generado sobre las ventas locales gravadas con tarifa diferente de cero del casillero 401', 'form104'),
  ('EC', 'EC-IVA-104', '403', 'base', 'Ventas locales gravadas tarifa 0% que no dan derecho a crédito tributario', '{}'::jsonb, 30, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 403 — operaciones locales gravadas con tarifa 0%, conforme los arts. 55 y 56 de la Ley de Régimen Tributario Interno, sujetas a la regla general del art. 66 que no da derecho a crédito tributario', 'form104'),
  ('EC', 'EC-IVA-104', '405', 'base', 'Ventas locales gravadas tarifa 0% que dan derecho a crédito tributario', '{}'::jsonb, 40, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 405 — operaciones gravadas con tarifa 0% de las excepciones del art. 57 y del artículo innumerado agregado a continuación del art. 66 de la Ley de Régimen Tributario Interno, entre ellas la venta a instituciones del Estado y empresas públicas', 'form104'),
  ('EC', 'EC-IVA-104', '407', 'base', 'Exportaciones de bienes', '{}'::jsonb, 50, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 407 — exportaciones de bienes, tarifa cero del art. 55, numeral 14 de la Ley de Régimen Tributario Interno', 'form104'),
  ('EC', 'EC-IVA-104', '429', 'total', 'Total impuesto generado', '{}'::jsonb, 60, null, array['421']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 429 — total del impuesto generado en las ventas y otras operaciones del período; este paquete solo declara el impuesto del casillero 421', 'form104'),
  ('EC', 'EC-IVA-104', '500', 'base', 'Adquisiciones y pagos (excluye activos fijos) gravados tarifa diferente de cero, con derecho a crédito tributario', '{}'::jsonb, 70, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 500', 'form104'),
  ('EC', 'EC-IVA-104', '520', 'tax', 'IVA en adquisiciones y pagos gravados tarifa diferente de cero', '{}'::jsonb, 80, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 520 — impuesto pagado en las adquisiciones del casillero 500', 'form104'),
  ('EC', 'EC-IVA-104', '501', 'base', 'Adquisiciones locales de activos fijos gravados tarifa diferente de cero, con derecho a crédito tributario', '{}'::jsonb, 90, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 501', 'form104'),
  ('EC', 'EC-IVA-104', '521', 'tax', 'IVA en adquisiciones locales de activos fijos gravados tarifa diferente de cero', '{}'::jsonb, 100, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 521 — impuesto pagado en las adquisiciones del casillero 501', 'form104'),
  ('EC', 'EC-IVA-104', '507', 'base', 'Adquisiciones y pagos (incluye activos fijos) gravados con tarifa 0%', '{}'::jsonb, 110, null, '{}'::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 507', 'form104'),
  ('EC', 'EC-IVA-104', '564', 'total', 'Crédito tributario aplicable en este período', '{}'::jsonb, 120, null, array['520', '521']::text[], '{}'::text[], null, null, false, false, null, 'Formulario 104, casillero 564 — de acuerdo al factor de proporcionalidad o a la contabilidad del sujeto pasivo, conforme los arts. 66 de la Ley de Régimen Tributario Interno y 153 y 157 de su Reglamento. Este paquete simplifica el casillero al total del impuesto pagado en las adquisiciones que dan derecho a crédito tributario (520 más 521): el factor de proporcionalidad del art. 66, inciso segundo, para quien no puede atribuir directamente sus adquisiciones a una actividad gravada o a una gravada con tarifa cero sin derecho a crédito, no está modelado — véase el README de este paquete', 'form104'),
  ('EC', 'EC-IVA-104', '601', 'total', 'Impuesto causado', '{}'::jsonb, 130, null, array['429']::text[], array['564']::text[], null, null, true, false, null, 'Formulario 104, casillero 601 — diferencia entre el total del impuesto generado (429) y el crédito tributario aplicable (564), cuando esa diferencia es mayor que cero; este paquete no modela la liquidación de casilleros 482 a 499 (que difiere el impuesto de una venta a crédito) ni el arrastre de crédito tributario de períodos anteriores (casilleros 605 a 619) — véase el README de este paquete', 'form104'),
  ('EC', 'EC-IVA-104', '602', 'total', 'Crédito tributario aplicable en este período (saldo a favor)', '{}'::jsonb, 140, null, array['564']::text[], array['429']::text[], null, null, true, false, null, 'Formulario 104, casillero 602 — diferencia entre el crédito tributario aplicable (564) y el total del impuesto generado (429), cuando esa diferencia es mayor que cero; el Formulario 104 exige que, si el casillero 601 tiene un valor, el casillero 602 quede en blanco, y viceversa', 'form104')
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
  ('EC-NIIF-ER', 'EC', 'default', 'Estado de resultado integral', 'income_statement', 'EC-NIIF', date '1970-01-01', null, 'Ley de Régimen Tributario Interno, art. 20 y 21, en los mismos términos que EC-NIIF-ESF. Este paquete presenta un estado de resultados resumido, por naturaleza de la clasificación NIIF de ingresos, costos y gastos', 'lrti-contabilidad'),
  ('EC-NIIF-ESF', 'EC', 'default', 'Estado de situación financiera', 'balance_sheet', 'EC-NIIF', date '1970-01-01', null, 'Ley de Régimen Tributario Interno, art. 20 y 21 — los estados financieros se elaboran tomando en cuenta los principios contables de general aceptación (en la práctica actual, las NIIF completas o las NIIF para las PYMES adoptadas por la Superintendencia de Compañías, Valores y Seguros) y sirven de base tanto para la declaración de impuestos como para su presentación societaria. No existe un formato único obligatorio para toda sociedad: este paquete presenta un estado de situación financiera resumido, por clasificación NIIF de corriente y no corriente', 'lrti-contabilidad')
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
  ('EC-NIIF-ER', 'ING', 'UN', 'Ingresos de actividades ordinarias', '{}'::jsonb, 10, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'OIN', 'UN', 'Otros ingresos', '{}'::jsonb, 20, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'COV', 'UN', 'Costo de ventas', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'GAD', 'UN', 'Gastos de administración', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'GVE', 'UN', 'Gastos de venta', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'GFI', 'UN', 'Gastos financieros', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'GIR', 'UN', 'Gasto por impuesto a la renta', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ER', 'UN', null, 'Ganancia (pérdida) neta del período', '{}'::jsonb, 80, 1, true, array['ING', 'OIN']::text[], array['COV', 'GAD', 'GVE', 'GFI', 'GIR']::text[], null, null, null),
  ('EC-NIIF-ESF', 'EFEC', 'AC', 'Efectivo y equivalentes de efectivo', '{}'::jsonb, 10, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'FIN', 'AC', 'Activos financieros', '{}'::jsonb, 20, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'CXC', 'AC', 'Cuentas y documentos por cobrar comerciales', '{}'::jsonb, 30, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'OCXC', 'AC', 'Otras cuentas por cobrar', '{}'::jsonb, 40, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'INV', 'AC', 'Inventarios', '{}'::jsonb, 50, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'ANT', 'AC', 'Servicios y otros pagos anticipados', '{}'::jsonb, 60, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'IMPC', 'AC', 'Activos por impuestos corrientes', '{}'::jsonb, 70, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'AC', 'ACT', 'Total activo corriente', '{}'::jsonb, 80, 1, true, array['EFEC', 'FIN', 'CXC', 'OCXC', 'INV', 'ANT', 'IMPC']::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'PPE', 'ANC', 'Propiedades, planta y equipo', '{}'::jsonb, 90, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'INT', 'ANC', 'Activos intangibles', '{}'::jsonb, 100, 1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'ANC', 'ACT', 'Total activo no corriente', '{}'::jsonb, 110, 1, true, array['PPE', 'INT']::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'ACT', null, 'Total activo', '{}'::jsonb, 120, 1, true, array['AC', 'ANC']::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'CXP', 'PC', 'Cuentas y documentos por pagar', '{}'::jsonb, 130, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'OFCP', 'PC', 'Obligaciones con instituciones financieras', '{}'::jsonb, 140, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'ADMT', 'PC', 'Otras obligaciones con la administración tributaria', '{}'::jsonb, 150, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'IVAP', 'PC', 'Impuesto al valor agregado', '{}'::jsonb, 160, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'OCXP', 'PC', 'Otras cuentas por pagar', '{}'::jsonb, 170, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'PC', 'PAS', 'Total pasivo corriente', '{}'::jsonb, 180, 1, true, array['CXP', 'OFCP', 'ADMT', 'IVAP', 'OCXP']::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'OFLP', 'PNC', 'Obligaciones con instituciones financieras a largo plazo', '{}'::jsonb, 190, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'PNC', 'PAS', 'Total pasivo no corriente', '{}'::jsonb, 200, 1, true, array['OFLP']::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'PAS', null, 'Total pasivo', '{}'::jsonb, 210, 1, true, array['PC', 'PNC']::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'CAP', 'PAT', 'Capital', '{}'::jsonb, 220, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'RES', 'PAT', 'Reservas', '{}'::jsonb, 230, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'RACU', 'PAT', 'Resultados acumulados', '{}'::jsonb, 240, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'REJE', 'PAT', 'Resultados del ejercicio', '{}'::jsonb, 250, -1, false, '{}'::text[], '{}'::text[], null, null, null),
  ('EC-NIIF-ESF', 'PAT', null, 'Total patrimonio neto', '{}'::jsonb, 260, 1, true, array['CAP', 'RES', 'RACU', 'REJE']::text[], '{}'::text[], null, null, null)
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
    ('EC-NIIF-ER', 'ING', 10, 'code_prefix', '4.1', null, null, 'any'),
    ('EC-NIIF-ER', 'OIN', 10, 'code_prefix', '4.2', null, null, 'any'),
    ('EC-NIIF-ER', 'COV', 10, 'code_prefix', '5.1', null, null, 'any'),
    ('EC-NIIF-ER', 'GAD', 10, 'code_prefix', '5.2', null, null, 'any'),
    ('EC-NIIF-ER', 'GVE', 10, 'code_prefix', '5.3', null, null, 'any'),
    ('EC-NIIF-ER', 'GFI', 10, 'code_prefix', '5.4', null, null, 'any'),
    ('EC-NIIF-ER', 'GIR', 10, 'code_prefix', '5.5', null, null, 'any'),
    ('EC-NIIF-ESF', 'EFEC', 10, 'code_prefix', '1.1.01', null, null, 'any'),
    ('EC-NIIF-ESF', 'FIN', 10, 'code_prefix', '1.1.02', null, null, 'any'),
    ('EC-NIIF-ESF', 'CXC', 10, 'code_prefix', '1.1.03', null, null, 'any'),
    ('EC-NIIF-ESF', 'OCXC', 10, 'code_prefix', '1.1.04', null, null, 'any'),
    ('EC-NIIF-ESF', 'INV', 10, 'code_prefix', '1.1.05', null, null, 'any'),
    ('EC-NIIF-ESF', 'ANT', 10, 'code_prefix', '1.1.06', null, null, 'any'),
    ('EC-NIIF-ESF', 'IMPC', 10, 'code_prefix', '1.1.07', null, null, 'any'),
    ('EC-NIIF-ESF', 'PPE', 10, 'code_prefix', '1.2.01', null, null, 'any'),
    ('EC-NIIF-ESF', 'INT', 10, 'code_prefix', '1.2.02', null, null, 'any'),
    ('EC-NIIF-ESF', 'CXP', 10, 'code_prefix', '2.1.01', null, null, 'any'),
    ('EC-NIIF-ESF', 'OFCP', 10, 'code_prefix', '2.1.02', null, null, 'any'),
    ('EC-NIIF-ESF', 'ADMT', 10, 'code_prefix', '2.1.03', null, null, 'any'),
    ('EC-NIIF-ESF', 'IVAP', 10, 'code_prefix', '2.1.04', null, null, 'any'),
    ('EC-NIIF-ESF', 'OCXP', 10, 'code_prefix', '2.1.05', null, null, 'any'),
    ('EC-NIIF-ESF', 'OFLP', 10, 'code_prefix', '2.2.01', null, null, 'any'),
    ('EC-NIIF-ESF', 'CAP', 10, 'code_prefix', '3.1', null, null, 'any'),
    ('EC-NIIF-ESF', 'RES', 10, 'code_prefix', '3.3', null, null, 'any'),
    ('EC-NIIF-ESF', 'RACU', 10, 'code_prefix', '3.6', null, null, 'any'),
    ('EC-NIIF-ESF', 'REJE', 10, 'code_prefix', '3.7', null, null, 'any')
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
  ('EC', 'Ecuador', '{}'::jsonb, array['es']::text[], 'USD', '1.1.03.01', '2.1.01.01', '2.1.05.01', '4.2.03', '3.6.01', '4.1.01', '5.1.02', '1.1.01.03', '1.1.01.01', 'VEN', 'COM', 'DIA', 'es', 'result_accounts', '3.7.01', '3.7.02', null, 'APE', 'half_up', default, '4.2.02', '5.4.02', null, null, null, null, '2.1.04.03', '1.1.07.01', 'Asiento de apertura', null)
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
  numbering_legal_reference     = 'Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios, art. 17 y 18 — la numeración de los comprobantes es secuencial, de nueve dígitos, autorizada por establecimiento y por punto de emisión (cada uno identificado por tres dígitos), y no se reinicia por año; el código de esta pieza contable es la combinación establecimiento-punto de emisión y el consecutivo, los nueve dígitos del secuencial',
  numbering_source_key          = 'reglamento-comprobantes',
  payment_terms_legal_reference = null,
  payment_terms_source_key      = null,
  tax_point_rule                = 'delivery_date',
  tax_point_legal_reference     = 'Ley de Régimen Tributario Interno, art. 61, numeral 1 — en las transferencias locales de dominio de bienes, sean al contado o a crédito, el hecho generador del IVA se verifica en el momento de la entrega del bien, o en el momento del pago total o parcial del precio o acreditación en cuenta, lo que suceda primero; el Reglamento de Comprobantes de Venta, art. 8, exige que el comprobante se emita en el momento de esa transferencia, por lo que entrega y facturación coinciden en la práctica general. El numeral 2 del mismo artículo 61 da una segunda regla para la prestación de servicios (el hecho generador se verifica a elección del contribuyente entre la fecha en que efectivamente se presta el servicio y la del pago o abono en cuenta), que el vocabulario cerrado de esta casilla no distingue de la regla de los bienes — ver la sección de este paquete en docs/international.md',
  tax_point_source_key          = 'lrti',
  posted_edit_policy            = 'reversal_only',
  posted_edit_policy_legal_reference = 'Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios, y Resolución Nro. NAC-DGERCGC25-00000017 (Registro Oficial Tercer Suplemento 92, 30 de julio de 2025), en vigor desde el 1 de enero de 2026 — un comprobante electrónico transmitido y autorizado por el SRI solo se corrige mediante una nota de crédito o una nota de débito que lo referencie; la anulación de un comprobante ya autorizado es excepcional y, desde el 1 de enero de 2026, está prohibida para una factura emitida a consumidor final',
  posted_edit_policy_source_key = 'sri-facturacion',
  einvoice_profile              = null,
  einvoice_mandatory_from       = null,
  einvoice_legal_reference      = 'Ley de Régimen Tributario Interno, art. 61-A y Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios — todo sujeto obligado a emitir comprobantes de venta debe hacerlo, según el calendario de incorporación fijado por sucesivas resoluciones del SRI (entre ellas la Resolución NAC-DGERCGC19-00000433), como comprobante electrónico. Es un régimen de validación previa (clearance): antes de su emisión, el comprobante se transmite al SRI —en esquema en línea (Facturador SRI) o en esquema offline, con contingencia— que lo autoriza de oficio si cumple la ficha técnica y le asigna una clave de acceso de 49 dígitos y un número de autorización, y no un intercambio par a par construido sobre el modelo semántico de EN 16931. Desde el 1 de enero de 2026, la Resolución Nro. NAC-DGERCGC25-00000017 exige además la transmisión inmediata (en tiempo real o casi inmediato) de cada comprobante al SRI. EKWO NO GENERA, NO CALCULA LA CLAVE DE ACCESO NI TRANSMITE NINGÚN COMPROBANTE AL SRI: ningún componente de packages/formats dialoga con el SRI. Por eso profile y mandatory_from quedan vacíos aunque la obligación exista: profile nombra un perfil construido sobre EN 16931 que una pieza de packages/formats escribe (peppol-bis-3, factur-x-en16931, xrechnung, un PINT), y el comprobante electrónico ecuatoriano no es ninguno de ellos; el calendario de incorporación es, además, escalonado por tipo de contribuyente y no una fecha única para todos. El Registro Único de Contribuyentes (RUC) no tiene un esquema ISO 6523 registrado: party_scheme y vat_scheme quedan vacíos por la misma razón que en los paquetes de México y Colombia',
  einvoice_source_key           = 'sri-facturacion',
  party_scheme                  = null,
  vat_scheme                    = null,
  bank_statement_formats        = array['csv']::text[],
  payment_formats               = null,
  fiscal_year_default           = 'calendar'
 where country = 'EC';

insert into legal_mention_templates
  (country, code, applies_when, text, text_i18n, sequence, valid_from, valid_to, legal_reference)
values
  ('EC', 'sri_authorization_pending', 'always', 'Este documento no constituye un comprobante de venta autorizado por el Servicio de Rentas Internas: no lleva la clave de acceso ni el número de autorización que asigna la validación previa del SRI. Solo el comprobante electrónico autorizado ampara la operación para efectos tributarios.', '{}'::jsonb, 10, date '1970-01-01', null, 'Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios, en concordancia con la normativa de facturación electrónica del SRI — el sistema de comprobantes electrónicos exige la validación previa del documento por el SRI, que le asigna una clave de acceso de 49 dígitos y un número de autorización; Ekwo no genera ni transmite el XML de un comprobante electrónico ecuatoriano ni dialoga con el SRI: ver la sección de facturación electrónica de este paquete'),
  ('EC', 'export', 'export', 'Exportación de bienes — bien gravado con tarifa cero por ciento del impuesto al valor agregado, siempre que la exportación se perfeccione con la declaración aduanera de exportación (DAE).', '{}'::jsonb, 20, date '1970-01-01', null, 'Ley de Régimen Tributario Interno, art. 55, numeral 14 (transferencias e importaciones con tarifa cero) — las que se exporten, tarifa que se aplica siempre que el bien efectivamente salga del país'),
  ('EC', 'exempt', 'exempt', 'Bien o servicio gravado con tarifa cero por ciento del impuesto al valor agregado, sin derecho a crédito tributario por el impuesto pagado en su producción.', '{}'::jsonb, 30, date '1970-01-01', null, 'Ley de Régimen Tributario Interno, arts. 55 y 56 (bienes y servicios con tarifa cero) en concordancia con el art. 66, inciso primero, numeral 3 — quien produce o comercializa bienes o presta servicios gravados con tarifa cero no tiene, por regla general, derecho a crédito tributario por el IVA pagado en las adquisiciones destinadas a esa actividad')
on conflict (country, code) do update set
  applies_when    = excluded.applies_when,
  text            = excluded.text,
  text_i18n       = excluded.text_i18n,
  sequence        = excluded.sequence,
  valid_from      = excluded.valid_from,
  valid_to        = excluded.valid_to,
  legal_reference = excluded.legal_reference;
