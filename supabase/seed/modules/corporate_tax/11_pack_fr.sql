-- Ekwo OS — France: the rules of this country's corporate income tax.
--
-- Generated from packs/fr/corporate_tax.json at version 1.17.1, do not edit.
-- Change the pack and run `ekwo pack build fr`; `ekwo pack check --all`
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
  ('FR', 'FR-IS', 'Impôt sur les sociétés', '{"en":"Corporate income tax"}'::jsonb, 'FR-2052', 'HN', 'Formulaire n° 2058-A-SD « Détermination du résultat fiscal » — le calcul part du bénéfice comptable (ligne WA) ou de la perte comptable (ligne WS) de l''exercice, qui est la ligne HN du compte de résultat', 'liasse-2050', '695000', '444000', null, 'Règlement ANC n° 2014-03 modifié par le règlement n° 2022-06 — le compte 444 « État — Impôts sur les bénéfices » est crédité de l''impôt dû par le débit du compte 695 « Impôts sur les bénéfices », et débité des acomptes et du solde versés', 'anc-2022-06', 'Code général des impôts, art. 205 et suivants — impôt sur les sociétés', 'cgi')
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

insert into tax.parameter_templates
  (country, code, name, name_i18n, value_type, legal_reference, source_key, sequence)
values
  ('FR', 'turnover_twelve_months', 'Chiffre d''affaires hors taxes de l''exercice, ramené s''il y a lieu à douze mois', '{"en":"Turnover excluding tax for the financial year, restated to twelve months where needed"}'::jsonb, 'amount'::tax.parameter_type, 'Code général des impôts, art. 219, I, b — chiffre d''affaires n''excédant pas 10 millions d''euros au cours de l''exercice ou de la période d''imposition, ramené s''il y a lieu à douze mois ; pour la société mère d''un groupe, somme des chiffres d''affaires des sociétés membres', 'cgi', 10),
  ('FR', 'capital_fully_paid_up', 'Le capital est entièrement libéré', '{"en":"The share capital is fully paid up"}'::jsonb, 'boolean'::tax.parameter_type, 'Code général des impôts, art. 219, I, b', 'cgi', 20),
  ('FR', 'held_75_percent_by_individuals', 'Le capital est détenu de manière continue pour 75 % au moins par des personnes physiques, ou par une société répondant aux mêmes conditions', '{"en":"At least 75 % of the capital is held continuously by individuals, or by a company meeting the same conditions"}'::jsonb, 'boolean'::tax.parameter_type, 'Code général des impôts, art. 219, I, b', 'cgi', 30)
on conflict (country, code) do update set
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  value_type      = excluded.value_type,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;

insert into tax.adjustment_rule_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, direction, percent, formula, account_rules, legal_reference, source_key, sequence)
values
  ('FR', 'corporate-income-tax', date '2022-01-01', null, 'period_start'::tax.validity_basis, 'Impôt sur les sociétés', '{"en":"Corporate income tax"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"695","kind":"code_prefix"}]'::jsonb, 'Code général des impôts, art. 213 — l''impôt sur les sociétés n''est pas admis dans les charges déductibles ; formulaire n° 2058-A-SD, ligne I7', 'cgi', 10),
  ('FR', 'fines-penalties', date '2022-01-01', null, 'period_start'::tax.validity_basis, 'Amendes et pénalités', '{"en":"Fines and penalties"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"671200","kind":"account_code"}]'::jsonb, 'Code général des impôts, art. 39, 2 — les sanctions pécuniaires et pénalités de toute nature mises à la charge des contrevenants à des obligations légales ; formulaire n° 2058-A-SD, ligne WJ', 'cgi', 20),
  ('FR', 'vehicle-taxes', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Taxes annuelles sur les véhicules de tourisme affectés à des fins économiques', '{"en":"Annual taxes on passenger vehicles used for business purposes"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Code général des impôts, art. 39, 1, 4° — taxes prévues au 1° de l''article L. 421-94 du code des impositions sur les biens et services ; notice n° 2857-FC-NOT-SD : la taxe annuelle sur les émissions de dioxyde de carbone et la taxe annuelle sur les émissions de polluants atmosphériques ne sont pas déductibles du résultat imposable ; formulaire n° 2058-A-SD, ligne WG', 'notice-2857', 30),
  ('FR', 'excess-depreciation', date '2022-01-01', null, 'period_start'::tax.validity_basis, 'Amortissements excédentaires des véhicules de tourisme', '{"en":"Excess depreciation of passenger vehicles"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Code général des impôts, art. 39, 4 — amortissement des véhicules de tourisme pour la fraction de leur prix d''acquisition qui dépasse le plafond applicable selon leurs émissions de dioxyde de carbone ; formulaire n° 2058-A-SD, ligne WE. Le plafond n''est pas calculé ici : la société déclare la fraction excédentaire de l''amortissement.', 'cgi', 40),
  ('FR', 'sumptuary-expenses', date '2022-01-01', null, 'period_start'::tax.validity_basis, 'Dépenses somptuaires', '{"en":"Sumptuary expenses"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Code général des impôts, art. 39, 4 — dépenses et charges ayant trait à l''exercice de la chasse et à l''exercice non professionnel de la pêche, et charges des résidences de plaisance ou d''agrément ; formulaire n° 2058-A-SD, ligne WF', 'cgi', 50)
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
  ('FR', 'reduced-sme', date '2022-12-31', null, 'period_end'::tax.validity_basis, 'Taux réduit des petites et moyennes entreprises', '{"en":"Reduced rate for small and medium-sized enterprises"}'::jsonb, 15, 42500, 'months', '[{"amount":10000000,"parameter":"turnover_twelve_months","test":"at_most"},{"parameter":"capital_fully_paid_up","test":"is_true"},{"parameter":"held_75_percent_by_individuals","test":"is_true"}]'::jsonb, 'Code général des impôts, art. 219, I, b — 15 % dans la limite de 42 500 € de bénéfice imposable par période de douze mois ; BOI-IS-LIQ-20-20 — la limite de 42 500 € s''applique aux exercices clos à compter du 31 décembre 2022 et, pour un exercice d''une durée différente de douze mois, elle est affectée du rapport entre le nombre de mois de l''exercice et 12', 'boi-is-liq-20-20', 10),
  ('FR', 'standard', date '2022-01-01', null, 'period_start'::tax.validity_basis, 'Taux normal', '{"en":"Standard rate"}'::jsonb, 25, null, 'none', '[]'::jsonb, 'Code général des impôts, art. 219, I, al. 2 — le taux normal de l''impôt est fixé à 25 % ; exercices ouverts à compter du 1er janvier 2022 (BOI-IS-LIQ-10)', 'cgi', 20)
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
  ('FR', date '2012-12-31', null, 'period_end'::tax.validity_basis, 1000000, 50, null, 'Code général des impôts, art. 209, I, al. 3 — le déficit est déduit du bénéfice de l''exercice suivant dans la limite de 1 000 000 € majoré de 50 % du bénéfice imposable qui excède ce montant, et l''excédent est reporté dans les mêmes conditions sur les exercices suivants ; BOI-IS-DEF-10-30 — exercices clos à compter du 31 décembre 2012, report sans limitation de durée', 'boi-is-def-10-30')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;

insert into tax.prepayment_templates
  (country, valid_from, valid_to, valid_on, method, month_basis, instalments, surcharge_percent, exempt_up_to, legal_reference, source_key)
values
  ('FR', date '2022-01-01', null, 'period_start'::tax.validity_basis, 'share_of_reference_tax', 'calendar', '[{"day":15,"month":3,"sequence":1,"share_percent":25},{"day":15,"month":6,"sequence":2,"share_percent":25},{"day":15,"month":9,"sequence":3,"share_percent":25},{"day":15,"month":12,"sequence":4,"share_percent":25}]'::jsonb, null, 3000, 'Code général des impôts, art. 1668, 1 — acomptes trimestriels déterminés à partir des résultats du dernier exercice clos, payés au plus tard les 15 mars, 15 juin, 15 septembre et 15 décembre ; BOI-IS-DECLA-20-10 — chacun des quatre acomptes est égal au quart de l''impôt de référence, et le premier, calculé sur l''avant-dernier exercice, est régularisé ensuite ; notice n° 2571-NOT-SD — dispense d''acomptes lorsque l''impôt de référence n''excède pas 3 000 €, et ordre des acomptes selon la date de clôture. Une société nouvelle est dispensée d''acomptes au cours de son premier exercice.', 'notice-2571')
on conflict (country, valid_from) do update set
  valid_to          = excluded.valid_to,
  valid_on          = excluded.valid_on,
  method            = excluded.method,
  month_basis       = excluded.month_basis,
  instalments       = excluded.instalments,
  surcharge_percent = excluded.surcharge_percent,
  exempt_up_to      = excluded.exempt_up_to,
  legal_reference   = excluded.legal_reference,
  source_key        = excluded.source_key;
