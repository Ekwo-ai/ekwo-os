-- Ekwo OS — Sénégal: the rules of this country's corporate income tax.
--
-- Generated from packs/sn/corporate_tax.json at version 0.3.0, do not edit.
-- Change the pack and run `ekwo pack build sn`; `ekwo pack check --all`
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
  ('SN', 'SN-IS', 'Impôt sur les sociétés', '{}'::jsonb, 'SN-SYSCOHADA-IS', 'XI', 'Code général des impôts, art. 8 et art. 16, 2 — le bénéfice imposable part du résultat comptable, augmenté des réintégrations extracomptables et diminué des déductions extracomptables ; le compte de résultat du Système normal n''imprime pas de résultat avant impôt : le calcul part du résultat net (ligne XI), qui est après la charge d''impôt du compte 89, d''où la règle de réintégration « corporate-income-tax »', 'cgi', '8911', '441', null, 'Système comptable OHADA, plan de comptes, classes 4 et 8 — le compte 441 « État, impôt sur les bénéfices » est crédité de l''impôt dû par le débit du compte 891 « Impôts sur les bénéfices de l''exercice », ici son sous-compte 8911 « Activités exercées dans l''État » ; le plan n''a pas de compte de créance d''impôt sur les bénéfices à part', 'syscohada', 'Code général des impôts (loi n° 2012-31 du 31 décembre 2012), art. 36 — le taux de l''impôt sur les sociétés est fixé à 30 % du bénéfice imposable ; art. 718 — les dispositions du titre premier du livre I s''appliquent aux résultats des exercices clos au 31 décembre 2012 et après', 'cgi')
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
  ('SN', 'corporate-income-tax', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'Impôts sur le résultat (impôt sur les sociétés et impôt minimum forfaitaire)', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"89","kind":"code_prefix"}]'::jsonb, 'Code général des impôts, art. 9, 7 — les impôts à la charge de l''entreprise sont déductibles, à l''exception de l''impôt sur les sociétés et de l''impôt minimum forfaitaire sur les sociétés. Le compte 89 ne porte que ces impôts sur le résultat (891 impôt sur les bénéfices, 892 rappels, 895 impôt minimum forfaitaire, 899 dégrèvements) : son solde net est réintégré.', 'cgi', 10),
  ('SN', 'fines-penalties', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'Amendes et pénalités', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"647","kind":"code_prefix"},{"code_from":"657","kind":"code_prefix"}]'::jsonb, 'Code général des impôts, art. 9, 9 — les transactions, amendes, confiscations et pénalités de toute nature, notamment celles mises à la charge des contrevenants à la réglementation des prix, du contrôle des changes et de l''assiette, de la liquidation et du recouvrement des impôts, ne sont pas admises en déduction. Comptes 647 « Pénalités, amendes fiscales » et 657 « Pénalités et amendes pénales » du Système comptable OHADA.', 'cgi', 20),
  ('SN', 'parent-subsidiary-dividends', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'Produits de participations d''une société mère dans sa filiale, déduction faite de la quote-part de frais et charges', '{}'::jsonb, 'deduction'::tax.adjustment_direction, 95, null, '[]'::jsonb, 'Code général des impôts, art. 21 — les produits bruts des participations d''une société mère dans une filiale sont retranchés du bénéfice net total, déduction faite d''une quote-part de frais et charges fixée uniformément à 5 % du produit brut, sans pouvoir excéder le total des frais et charges de la période (ce plafond n''est pas calculé) ; art. 22 — conditions : les deux sociétés imposables à l''impôt sur les sociétés, siège de la mère au Sénégal, au moins 10 % du capital, titres conservés deux ans sous la forme nominative. La société déclare le montant brut des produits qui y répondent.', 'cgi', 30),
  ('SN', 'other-participation-income', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'Produits de participations hors régime des sociétés mères et filiales', '{}'::jsonb, 'deduction'::tax.adjustment_direction, 60, null, '[]'::jsonb, 'Code général des impôts, art. 25 — lorsque les produits de participations ne sont pas éligibles au régime des sociétés mères et filiales, la société n''est imposée que sur une quote-part de 40 % du produit brut, soit une déduction de 60 %. La société déclare le montant brut des produits qui y répondent.', 'cgi', 40)
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
  ('SN', 'standard', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'Taux normal', '{}'::jsonb, 30, null, 'none', '[]'::jsonb, 'Code général des impôts, art. 36 — le taux de l''impôt sur les sociétés est fixé à 30 % du bénéfice imposable ; confirmé pour 2025 par la note « Voies et moyens » de la loi de finances rectificative pour 2025 (impôt sur les sociétés : 30 % du bénéfice imposable). La règle de l''arrondi de la base au millier de francs inférieur (art. 36, 2e phrase) n''est pas appliquée.', 'cgi', 10)
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
  ('SN', date '2012-12-31', null, 'period_end'::tax.validity_basis, null, null, 3, 'Code général des impôts, art. 16, 1 — le déficit d''un exercice est déduit du bénéfice de l''exercice suivant ; l''excédent est reporté successivement sur les exercices suivants, jusqu''au 3e exercice qui suit l''exercice déficitaire, sans autre plafond. Les amortissements comptabilisés en période déficitaire, réputés différés, échappent à cette limite de durée et ne sont pas calculés ici.', 'cgi')
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
  ('SN', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'share_of_reference_tax', 'calendar', '[{"day":15,"month":2,"sequence":1,"share_percent":33.3333},{"day":30,"month":4,"sequence":2,"share_percent":33.3333}]'::jsonb, null, null, 'Code général des impôts, art. 213 et 214 — deux acomptes, chacun égal au tiers de l''impôt dû sur les résultats du dernier exercice imposé, exigibles dans les quinze premiers jours de février et au plus tard le 30 avril ; le solde de l''impôt calculé d''après les résultats déclarés est acquitté au plus tard le 15 juin (note « Voies et moyens » de la loi de finances rectificative pour 2025 : deux acomptes, 15 février et 30 avril, solde le 15 juin). Le tiers est écrit 33,3333 %, faute d''un tiers exact. Le plancher du premier acompte (art. 215), l''arrondi à la centaine de francs et la dispense de l''art. 217 ne sont pas portés.', 'cgi')
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

insert into tax.credit_templates
  (country, code, valid_from, valid_to, valid_on, name, name_i18n, refundable, legal_reference, source_key, sequence)
values
  ('SN', 'withholding-tax-credit', date '2012-12-31', null, 'period_end'::tax.validity_basis, 'Crédit d''impôt pour la retenue à la source sur les revenus de capitaux mobiliers', '{}'::jsonb, false, 'Code général des impôts, art. 37 — la retenue à la source opérée sur les revenus de capitaux mobiliers encaissés par une personne morale et compris dans les bénéfices imposables est imputée sur l''impôt sur les sociétés, sans excéder la retenue correspondant aux revenus bruts compris dans la base ; le crédit est reportable sur trois ans et le reliquat de la troisième année est restitué sur réclamation (le report et la restitution ne sont pas calculés : la société déclare le crédit de l''exercice)', 'cgi', 10)
on conflict (country, code, valid_from) do update set
  valid_to        = excluded.valid_to,
  valid_on        = excluded.valid_on,
  name            = excluded.name,
  name_i18n       = excluded.name_i18n,
  refundable      = excluded.refundable,
  legal_reference = excluded.legal_reference,
  source_key      = excluded.source_key,
  sequence        = excluded.sequence;
