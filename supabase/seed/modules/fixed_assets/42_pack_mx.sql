-- Ekwo OS — México: how this country depreciates and derecognises a fixed asset.
--
-- Generated from packs/mx/fixed_assets.json at version 0.5.0, do not edit.
-- Change the pack and run `ekwo pack build mx`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Applied by the module migration runner — `ekwo migrate`, or `ekwo module
-- migrate` — and never by the socle seed step: these tables exist only on an
-- installation that carries the fixed assets module.
--
-- The accounts a disposal lands on are not here. They are roles of the chart,
-- in `country_defaults`, written by the pack seed beside every other role.

insert into fixed_assets.country_rules
  (country, prorata_straight_line, prorata_declining, day_count,
   declining_cap_percent, declining_switch_to_linear, disposal_style, legal_reference)
values
  ('MX', 'months', 'months', 'actual', null, true, 'net_result', 'Ley del Impuesto sobre la Renta, art. 31 (texto consolidado del SAT, leído el 1 de octubre de 2026) — las inversiones sólo se deducen aplicando en cada ejercicio los por cientos máximos autorizados sobre el monto original de la inversión; el contribuyente puede aplicar por cientos menores y empieza a deducir en el ejercicio en que inicia la utilización del bien o en el siguiente, a su elección. Ni la LISR ni lo leído de ella fija una convención contable de primer ejercicio: se toma la práctica de contar los meses desde aquel en que el bien se pone en uso, que es también la proporción en meses que el artículo 31 aplica a los ejercicios irregulares. La ley no conoce el saldo decreciente, de modo que no hay tope ni coeficiente que declarar.')
on conflict (country) do update set
  prorata_straight_line      = excluded.prorata_straight_line,
  prorata_declining          = excluded.prorata_declining,
  day_count                  = excluded.day_count,
  declining_cap_percent      = excluded.declining_cap_percent,
  declining_switch_to_linear = excluded.declining_switch_to_linear,
  disposal_style             = excluded.disposal_style,
  legal_reference            = excluded.legal_reference;

insert into fixed_assets.category_templates
  (country, code, name, name_i18n, method, duration_months, coefficient,
   prorata, account_type, sequence, legal_reference)
select v.country::char(2), v.code, v.name, v.name_i18n::jsonb,
       v.method::fixed_assets.depreciation_method, v.duration_months::integer,
       v.coefficient::numeric, v.prorata::fixed_assets.prorata_rule,
       v.account_type::account_type, v.sequence::integer, v.legal_reference
  from (values
    ('MX', 'construcciones', 'Construcciones', '{"en":"Constructions"}'::jsonb, 'straight_line', 240, null, null, 'asset_fixed', 10, 'Ley del Impuesto sobre la Renta, art. 34, fracción I (texto consolidado del SAT, leído el 1 de octubre de 2026) — el por ciento máximo autorizado para las construcciones distintas de monumentos con certificado de restauración es de 5 % anual sobre el monto original de la inversión, es decir 240 meses en línea recta. Es un tope de la deducción fiscal, no una vida útil que la ley contable imponga: la depreciación contable es la que el contribuyente estima para su propio bien (NIF C-6, nombrada y no transcrita en este paquete), y muchas empresas toman el tope como su tasa; aquí es la práctica corriente y un contribuyente que deprecia de otro modo lo dice en las columnas de su propio activo. La actualización por el INPC y la deducción fiscal propiamente dicha no están en este vocabulario.'),
    ('MX', 'mobiliario-equipo-oficina', 'Mobiliario y equipo de oficina', '{"en":"Office furniture and equipment"}'::jsonb, 'straight_line', 120, null, null, 'asset_fixed', 20, 'Ley del Impuesto sobre la Renta, art. 34, fracción III (texto consolidado del SAT, leído el 1 de octubre de 2026) — el por ciento máximo autorizado para el mobiliario y equipo de oficina es de 10 % anual sobre el monto original de la inversión, es decir 120 meses en línea recta. Es un tope de la deducción fiscal, no una vida útil que la ley contable imponga: la depreciación contable es la que el contribuyente estima para su propio bien (NIF C-6, nombrada y no transcrita en este paquete), y muchas empresas toman el tope como su tasa; aquí es la práctica corriente y un contribuyente que deprecia de otro modo lo dice en las columnas de su propio activo. La actualización por el INPC y la deducción fiscal propiamente dicha no están en este vocabulario.'),
    ('MX', 'embarcaciones', 'Embarcaciones', '{"en":"Vessels"}'::jsonb, 'straight_line', 200, null, null, 'asset_fixed', 30, 'Ley del Impuesto sobre la Renta, art. 34, fracción IV (texto consolidado del SAT, leído el 1 de octubre de 2026) — el por ciento máximo autorizado para las embarcaciones es de 6 % anual sobre el monto original de la inversión, es decir 200 meses en línea recta. Es un tope de la deducción fiscal, no una vida útil que la ley contable imponga: la depreciación contable es la que el contribuyente estima para su propio bien (NIF C-6, nombrada y no transcrita en este paquete), y muchas empresas toman el tope como su tasa; aquí es la práctica corriente y un contribuyente que deprecia de otro modo lo dice en las columnas de su propio activo. La actualización por el INPC y la deducción fiscal propiamente dicha no están en este vocabulario.'),
    ('MX', 'automoviles-camiones', 'Automóviles, autobuses, camiones de carga, tractocamiones, montacargas y remolques', '{"en":"Cars, buses, cargo trucks, tractor units, forklifts and trailers"}'::jsonb, 'straight_line', 48, null, null, 'asset_fixed', 40, 'Ley del Impuesto sobre la Renta, art. 34, fracción VI (texto consolidado del SAT, leído el 1 de octubre de 2026) — el por ciento máximo autorizado para los automóviles, autobuses, camiones de carga, tractocamiones, montacargas y remolques es de 25 % anual sobre el monto original de la inversión, es decir 48 meses en línea recta. Es un tope de la deducción fiscal, no una vida útil que la ley contable imponga: la depreciación contable es la que el contribuyente estima para su propio bien (NIF C-6, nombrada y no transcrita en este paquete), y muchas empresas toman el tope como su tasa; aquí es la práctica corriente y un contribuyente que deprecia de otro modo lo dice en las columnas de su propio activo. La actualización por el INPC y la deducción fiscal propiamente dicha no están en este vocabulario.'),
    ('MX', 'equipo-computo', 'Computadoras personales, servidores, impresoras y equipo periférico', '{"en":"Personal computers, servers, printers and peripheral equipment"}'::jsonb, 'straight_line', 40, null, null, 'asset_fixed', 50, 'Ley del Impuesto sobre la Renta, art. 34, fracción VII (texto consolidado del SAT, leído el 1 de octubre de 2026) — el por ciento máximo autorizado para las computadoras personales, los servidores, las impresoras y el equipo periférico es de 30 % anual sobre el monto original de la inversión, es decir 40 meses en línea recta. Es un tope de la deducción fiscal, no una vida útil que la ley contable imponga: la depreciación contable es la que el contribuyente estima para su propio bien (NIF C-6, nombrada y no transcrita en este paquete), y muchas empresas toman el tope como su tasa; aquí es la práctica corriente y un contribuyente que deprecia de otro modo lo dice en las columnas de su propio activo. La actualización por el INPC y la deducción fiscal propiamente dicha no están en este vocabulario.')
  ) as v (country, code, name, name_i18n, method, duration_months, coefficient,
          prorata, account_type, sequence, legal_reference)
on conflict (country, code) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  method          = excluded.method,
  duration_months = excluded.duration_months,
  coefficient     = excluded.coefficient,
  prorata         = excluded.prorata,
  account_type    = excluded.account_type,
  sequence        = excluded.sequence,
  legal_reference = excluded.legal_reference;

