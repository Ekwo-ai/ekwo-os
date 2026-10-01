-- Ekwo OS — Sénégal: how this country depreciates and derecognises a fixed asset.
--
-- Generated from packs/sn/fixed_assets.json at version 0.4.0, do not edit.
-- Change the pack and run `ekwo pack build sn`; `ekwo pack check --all`
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
  ('SN', 'days', 'days', 'actual', null, true, 'gross', 'Acte uniforme relatif au droit comptable et à l''information financière (Brazzaville, 26 janvier 2017), art. 45 — la date de début d''amortissement est celle à laquelle l''actif est en état de fonctionner et au lieu d''utilisation prévu ; le mode linéaire, le mode dégressif à taux décroissant et le mode des unités de production sont nommés parmi les modes admis. Ni l''Acte uniforme ni le Code général des impôts, art. 10, ne disent comment couper la première annuité : compter les jours réels depuis la mise en service jusqu''à la clôture est la pratique courante et non une règle de texte, en linéaire comme en dégressif. Code général des impôts, art. 10, 1) — le coefficient du dégressif est de 2 pour cinq ans et de 2,5 au-delà ; le texte ne plafonne aucune annuité (donc aucun plafond ici) et ne prévoit pas le passage au linéaire, que le module applique pour que le plan s''achève, mais exige que le cumul des amortissements dégressifs ne soit jamais inférieur au cumul linéaire, sous peine de perdre la déduction de la fraction différée.')
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
    ('SN', 'software', 'Logiciels et sites internet', '{}'::jsonb, 'straight_line', 36, null, null, 'asset_fixed', 10, 'Acte uniforme relatif au droit comptable et à l''information financière, art. 45 — le montant amortissable est réparti sur la durée d''utilité selon un plan prédéfini. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.'),
    ('SN', 'building-commercial', 'Bâtiments administratifs et commerciaux', '{}'::jsonb, 'straight_line', 240, null, null, 'asset_fixed', 20, 'Acte uniforme, art. 45 — amortissement sur la durée d''utilité ; Code général des impôts, art. 10, 1) — les locaux servant à l''exercice de la profession sont exclus de l''amortissement dégressif. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.'),
    ('SN', 'fixtures', 'Aménagements, agencements et installations', '{}'::jsonb, 'straight_line', 120, null, null, 'asset_fixed', 30, 'Acte uniforme, art. 45 — amortissement sur la durée d''utilité. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.'),
    ('SN', 'machinery', 'Matériel et outillage industriel', '{}'::jsonb, 'straight_line', 120, null, null, 'asset_fixed', 40, 'Acte uniforme, art. 45 — amortissement sur la durée d''utilité. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.'),
    ('SN', 'machinery-declining', 'Matériel et outillage industriel — amortissement dégressif', '{}'::jsonb, 'declining_balance', 120, 2.5, null, 'asset_fixed', 50, 'Code général des impôts, art. 10, 1) — les biens d''équipement acquis ou fabriqués par les entreprises industrielles peuvent être amortis selon le système dégressif, le taux linéaire de la durée normale d''utilisation étant multiplié par un coefficient fixé à 2 pour une durée de cinq ans et à 2,5 pour une durée supérieure à cinq ans ; dix ans, donc 2,5, est la durée proposée ici (pratique, non un barème). Le régime est réservé aux entreprises industrielles et exclut les immeubles d''habitation, les chantiers et les locaux professionnels.'),
    ('SN', 'vehicle', 'Matériel de transport', '{}'::jsonb, 'straight_line', 60, null, null, 'asset_fixed', 60, 'Acte uniforme, art. 45 — amortissement sur la durée d''utilité. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.'),
    ('SN', 'vehicle-declining', 'Matériel de transport — amortissement dégressif', '{}'::jsonb, 'declining_balance', 60, 2, null, 'asset_fixed', 70, 'Code général des impôts, art. 10, 1) — le système dégressif s''applique aux biens d''équipement des entreprises industrielles, avec un coefficient de 2 lorsque la durée normale d''utilisation est de cinq ans ; cinq ans est la durée proposée ici (pratique, non un barème).'),
    ('SN', 'furniture', 'Mobilier de bureau', '{}'::jsonb, 'straight_line', 120, null, null, 'asset_fixed', 80, 'Acte uniforme, art. 45 — amortissement sur la durée d''utilité. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.'),
    ('SN', 'it-equipment', 'Matériel informatique et de bureau', '{}'::jsonb, 'straight_line', 36, null, null, 'asset_fixed', 90, 'Acte uniforme, art. 45 — amortissement sur la durée d''utilité. Le Sénégal ne fixe aucune durée : le Code général des impôts, art. 10, 1), admet les amortissements « dans les limites de ceux qui sont généralement admis d''après les usages de chaque nature d''industrie, de commerce ou d''exploitation », et l''Acte uniforme, art. 45, laisse l''entité fixer la durée d''utilité du bien. La durée proposée ici est la pratique courante et non une règle de texte ; elle n''a pas été lue dans un barème officiel.')
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

