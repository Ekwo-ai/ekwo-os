-- Ekwo OS — México: the rules of this country's corporate income tax.
--
-- Generated from packs/mx/corporate_tax.json at version 0.3.0, do not edit.
-- Change the pack and run `ekwo pack build mx`; `ekwo pack check --all`
-- refuses a seed that is not the exact output of its pack, and the CI runs it.
--
-- Applied by the module migration runner — `ekwo migrate`, or `ekwo module
-- migrate` — and never by the socle seed step: these tables exist only on an
-- installation that carries the corporate income tax module.
--
-- Reference data: read where it stands, never copied into a company. A figure
-- that changes is a new row with a new valid_from, so a past year keeps its answer.

insert into tax.country_rules
  (country, tax_code, name, name_i18n, result_statement_code, result_line_code, result_legal_reference, result_source_key, expense_account_code, payable_account_code, receivable_account_code, accounts_legal_reference, accounts_source_key, legal_reference, source_key)
values
  ('MX', 'MX-ISR', 'Impuesto sobre la renta de las personas morales', '{"en":"Corporate income tax of legal entities"}'::jsonb, 'MX-SAT-ER', 'UAI', 'Ley del Impuesto sobre la Renta, art. 9, primer párrafo y fracción I — la ley no parte del resultado contable: la utilidad fiscal es la diferencia entre los ingresos acumulables y las deducciones autorizadas del ejercicio, menos la participación de los trabajadores en las utilidades pagada. Este paquete parte de la línea «Utilidad (pérdida) antes de impuestos a la utilidad» del estado de resultados, que se imprime antes de la cuenta 611 «Impuesto sobre la renta» y, por tanto, no contiene el impuesto, y le aplica las reintegraciones y deducciones de abajo: es una estimación hecha con los libros, no la conciliación entre el resultado contable y el fiscal', 'sat-lisr-art-9', '611.01', '213.03', '113.02', 'Anexo 24 de la RMF 2026, apartado A, inciso a) — código agrupador de cuentas del SAT: 611.01 «Impuesto Sobre la renta» (gasto), 213.03 «ISR por pagar» (pasivo) y 113.02 «ISR a favor» (activo), cuentas del catálogo de este paquete; Ley del ISR, art. 9 — el impuesto del ejercicio se paga mediante declaración dentro de los tres meses siguientes al cierre del ejercicio', 'sat-lisr-art-9', 'Ley del Impuesto sobre la Renta, Título II «De las personas morales», art. 9 — las personas morales calculan el impuesto sobre la renta aplicando al resultado fiscal del ejercicio la tasa del 30 %', 'sat-lisr-art-9')
on conflict (country) do update set
  tax_code                 = excluded.tax_code,
  name                     = excluded.name,
  name_i18n                = excluded.name_i18n,
  result_statement_code    = excluded.result_statement_code,
  result_line_code         = excluded.result_line_code,
  result_legal_reference   = excluded.result_legal_reference,
  result_source_key        = excluded.result_source_key,
  expense_account_code     = excluded.expense_account_code,
  payable_account_code     = excluded.payable_account_code,
  receivable_account_code  = excluded.receivable_account_code,
  accounts_legal_reference = excluded.accounts_legal_reference,
  accounts_source_key      = excluded.accounts_source_key,
  legal_reference          = excluded.legal_reference,
  source_key               = excluded.source_key;

insert into tax.adjustment_rule_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, direction, percent, formula, account_rules, legal_reference, source_key, sequence)
values
  ('MX', 'ptu-expense', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Participación de los trabajadores en las utilidades registrada como gasto', '{"en":"Employee profit sharing booked as an expense"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"607","kind":"code_prefix"}]'::jsonb, 'Ley del Impuesto sobre la Renta, art. 9, fracción I — la utilidad fiscal se obtiene disminuyendo de los ingresos acumulables las deducciones autorizadas y «la participación de los trabajadores en las utilidades de las empresas pagada en el ejercicio»: lo que cuenta es lo pagado, no lo registrado. El gasto de la cuenta 607 «Participación de los trabajadores en las utilidades», que no contiene otra cosa, se reintegra completo y la participación pagada se deduce en la regla ptu-paid', 'sat-lisr-art-9', 10),
  ('MX', 'ptu-paid', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Participación de los trabajadores en las utilidades pagada en el ejercicio', '{"en":"Employee profit sharing paid in the year"}'::jsonb, 'deduction'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Ley del Impuesto sobre la Renta, art. 9, fracción I — «la participación de los trabajadores en las utilidades de las empresas pagada en el ejercicio, en los términos del artículo 123 de la Constitución Política de los Estados Unidos Mexicanos»; la sociedad declara el monto pagado en el ejercicio, que los libros no distinguen del gasto registrado', 'sat-lisr-art-9', 20),
  ('MX', 'restaurants', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Consumos en restaurantes — parte no deducible', '{"en":"Restaurant consumption — non-deductible share"}'::jsonb, 'add_back'::tax.adjustment_direction, 91.5, null, '[]'::jsonb, 'Ley del Impuesto sobre la Renta, art. 28, fracción XX — no son deducibles «el 91.5% de los consumos en restaurantes»; para deducir la diferencia el pago debe hacerse mediante tarjeta de crédito, de débito o de servicios, o monederos electrónicos autorizados por el SAT. La sociedad declara el monto de los consumos en restaurantes que no cumplen los requisitos de la fracción V del mismo artículo (la página del SAT dice que los que sí los cumplen se deducen al 100 %, dentro de los límites de esa fracción, que no se leyó aquí); los consumos en bares no se deducen nunca', 'sat-lisr-art-28', 30),
  ('MX', 'fines-penalties', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Sanciones, indemnizaciones por daños y perjuicios y penas convencionales', '{"en":"Penalties, damages and contractual penalties"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Ley del Impuesto sobre la Renta, art. 28, fracción VI — no son deducibles «las sanciones, las indemnizaciones por daños y perjuicios o las penas convencionales», con excepciones limitadas cuando la ley obliga al pago por responsabilidad objetiva o por caso fortuito o fuerza mayor, que la sociedad no declara aquí. El catálogo no tiene una cuenta propia para ellas: la sociedad declara el monto', 'sat-lisr-art-28', 40)
on conflict (country, code, valid_from) do update set
  valid_to        = excluded.valid_to,
  valid_on        = excluded.valid_on,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  direction       = excluded.direction,
  percent         = excluded.percent,
  formula         = excluded.formula,
  account_rules   = excluded.account_rules,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

insert into tax.rate_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, rate, up_to, up_to_prorata, conditions, legal_reference, source_key, sequence)
values
  ('MX', 'general', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Tasa general de las personas morales', '{"en":"General rate for legal entities"}'::jsonb, 30, null, 'none', '[]'::jsonb, 'Ley del Impuesto sobre la Renta, art. 9, primer párrafo — «las personas morales deberán calcular el impuesto sobre la renta, aplicando al resultado fiscal obtenido en el ejercicio la tasa del 30%». El texto leído el 1 de octubre de 2026 no menciona tasas transitorias; la fecha de entrada en vigor de la tasa no se leyó y 2025 es el primer ejercicio que este paquete cubre', 'sat-lisr-art-9', 10)
on conflict (country, code, valid_from) do update set
  valid_to        = excluded.valid_to,
  valid_on        = excluded.valid_on,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  rate            = excluded.rate,
  up_to           = excluded.up_to,
  up_to_prorata   = excluded.up_to_prorata,
  conditions      = excluded.conditions,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

insert into tax.loss_rule_templates
  (country, valid_from, valid_to, valid_on, floor_amount, percent_above, carry_forward_years, legal_reference, source_key)
values
  ('MX', date '2025-01-01', null, 'period_start'::tax.validity_basis, null, null, 10, 'Ley del Impuesto sobre la Renta, art. 57 — la pérdida fiscal ocurrida en un ejercicio puede disminuirse de la utilidad fiscal de los diez ejercicios siguientes hasta agotarla; quien pudiendo disminuirla no lo hace en un ejercicio pierde el derecho a hacerlo después hasta por la cantidad en que pudo hacerlo. El derecho es personal y no se transmite por fusión. La actualización de la pérdida por inflación que ordena el mismo artículo no se calcula aquí', 'sat-lisr-art-57')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
