-- Ekwo OS — Nederland: the rules of this country's corporate income tax.
--
-- Generated from packs/nl/corporate_tax.json at version 0.3.0, do not edit.
-- Change the pack and run `ekwo pack build nl`; `ekwo pack check --all`
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
  ('NL', 'NL-VPB', 'Vennootschapsbelasting', '{"en":"Corporate income tax"}'::jsonb, 'NL-BMJ-E', 'E19', 'Besluit modellen jaarrekening, model E — de winst- en verliesrekening drukt het resultaat voor belastingen af vóór de post belastingen; de berekening van de winst (Wet op de vennootschapsbelasting 1969, art. 8) vertrekt van dat resultaat, zodat de belasting over de winst zelf er niet in voorkomt', 'bmj', 'WBelBgrBgr', 'BSchBepVpb', 'BVorVbkTvv', 'Referentie GrootboekSchema 3.8 — WBelBgrBgr «Belastingen uit huidig boekjaar» (onder «Belastingen over de winst of het verlies»), BSchBepVpb «Te betalen vennootschapsbelasting» en BVorVbkTvv «Terug te vorderen Vennootschapsbelasting»', 'rgs', 'Wet op de vennootschapsbelasting 1969 — de belasting naar de winst van rechtspersonen en andere belastingplichtigen als bedoeld in artikel 2', 'wet-vpb')
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
  ('NL', 'fines', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Boetes en verhogingen op belastingen en sociale premies', '{"en":"Fines and surcharges on taxes and social security contributions"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"WBedAdlBev","kind":"account_code"}]'::jsonb, 'Wet op de vennootschapsbelasting 1969, art. 8, lid 1, jo. Wet inkomstenbelasting 2001, art. 3.14, lid 1, onderdeel c — bij het bepalen van de winst komen niet in aftrek kosten en lasten die verband houden met geldboeten opgelegd door een strafrechter en met bestuurlijke boeten en daarmee vergelijkbare buitenlandse boeten. De regel leest het saldo van de rekening WBedAdlBev; een boete die de vennootschap op een andere rekening boekt, wijst zij zelf aan.', 'wet-ib', 10),
  ('NL', 'mixed-costs-fixed', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Gemengde kosten — niet aftrekbaar bedrag van € 5.700 of 0,4 % van de loonsom', '{"en":"Mixed costs — non-deductible amount of EUR 5,700 or 0.4 % of the wage bill"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Wet op de vennootschapsbelasting 1969, art. 8, lid 5 — bij aanwezigheid van een of meer werknemers wordt de winst mede bepaald op de voet van art. 3.15, lid 1, 2, 3 en 5, Wet inkomstenbelasting 2001, met voor het bedrag van lid 1 (€ 5.700) in de plaats 0,4 % van het gezamenlijke loon van de werknemers indien die uitkomst hoger is dan € 5.700; Wet inkomstenbelasting 2001, art. 3.15, lid 1 — tot dat bedrag komen niet in aftrek de kosten en lasten van voedsel, drank en genotmiddelen, van representatie en van congressen, seminars, studiereizen en dergelijke. De vennootschap geeft het niet aftrekbare bedrag op: het laagste van haar kosten van die posten en het drempelbedrag. Dit is het alternatief voor de regel mixed-costs-elected: nooit beide op dezelfde kosten.', 'wet-vpb', 20),
  ('NL', 'mixed-costs-elected', date '2025-01-01', null, 'period_start'::tax.validity_basis, 'Gemengde kosten — keuze voor 73,5 % aftrek', '{"en":"Mixed costs — election for 73.5 % deduction"}'::jsonb, 'add_back'::tax.adjustment_direction, 26.5, null, '[]'::jsonb, 'Wet op de vennootschapsbelasting 1969, art. 8, lid 5 — bij aanwezigheid van een of meer werknemers geldt art. 3.15, lid 5, Wet inkomstenbelasting 2001, waarbij het percentage van 80 wordt vervangen door 73,5; Wet inkomstenbelasting 2001, art. 3.15, lid 5 — indien de belastingplichtige daarvoor bij de aangifte kiest, komen de kosten en lasten van de in lid 1 genoemde posten voor dat percentage in aftrek, in afwijking van het drempelbedrag. Het niet aftrekbare deel is 26,5 % van die kosten; de vennootschap geeft het bedrag van de kosten op. Alternatief voor de regel mixed-costs-fixed.', 'wet-vpb', 30)
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
  ('NL', 'reduced', date '2023-01-01', null, 'period_start'::tax.validity_basis, 'Eerste schijf', '{"en":"First bracket"}'::jsonb, 19, 200000, 'none', '[]'::jsonb, 'Wet op de vennootschapsbelasting 1969, art. 22 — tabel: 19 % over het belastbare bedrag tot en met € 200.000; Belastingdienst, «Tarieven voor de vennootschapsbelasting» — de tarieven in 2026, 2025, 2024 en 2023 zijn 19,0 % tot en met € 200.000 en 25,8 % daarboven', 'bd-tarieven', 10),
  ('NL', 'standard', date '2023-01-01', null, 'period_start'::tax.validity_basis, 'Tweede schijf', '{"en":"Second bracket"}'::jsonb, 25.8, null, 'none', '[]'::jsonb, 'Wet op de vennootschapsbelasting 1969, art. 22 — tabel: € 38.000 vermeerderd met 25,8 % van het gedeelte van het belastbare bedrag dat € 200.000 te boven gaat; Belastingdienst, «Tarieven voor de vennootschapsbelasting» — 25,8 % boven € 200.000 in 2026, 2025, 2024 en 2023', 'bd-tarieven', 20)
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
  ('NL', date '2022-01-01', null, 'period_start'::tax.validity_basis, 1000000, 50, null, 'Wet op de vennootschapsbelasting 1969, art. 20, lid 2 — een verlies wordt verrekend met de belastbare winsten van het voorafgaande jaar en de volgende jaren, mits het door de inspecteur is vastgesteld bij voor bezwaar vatbare beschikking; verrekening in een jaar vindt slechts plaats tot € 1.000.000 vermeerderd met 50 % van de belastbare winst van dat jaar nadat die winst met € 1.000.000 is verminderd; lid 4 — de verrekening geschiedt in de volgorde waarin de verliezen zijn ontstaan; Belastingdienst, «Vpb: verrekenen van verliezen» — verliezen uit 2022 en later zijn onbeperkt voorwaarts verrekenbaar, met dat maximum voor de winsten van 2022 en later', 'bd-verliezen')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
