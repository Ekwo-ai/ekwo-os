-- Ekwo OS — Germany: the rules of this country's corporate income tax.
--
-- Generated from packs/de/corporate_tax.json at version 0.3.0, do not edit.
-- Change the pack and run `ekwo pack build de`; `ekwo pack check --all`
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
  ('DE', 'DE-KSt', 'Körperschaftsteuer', '{"en":"Corporate income tax (Körperschaftsteuer)"}'::jsonb, 'DE-HGB-275-GKV', '17', 'HGB § 275 Abs. 2 — die Gewinn- und Verlustrechnung in Gesamtkostenverfahren weist kein Ergebnis vor Steuern aus: Posten 15 ist das Ergebnis nach Steuern und Posten 17 der Jahresüberschuss oder Jahresfehlbetrag. Die Berechnung geht vom Jahresüberschuss aus; die Steuern vom Einkommen und vom Ertrag (Posten 14) werden durch Hinzurechnungsregeln auf ihren Konten wieder hinzugerechnet (KStG § 8 Abs. 1 Satz 1 — das Einkommen bestimmt sich nach den Vorschriften des Einkommensteuergesetzes und des KStG)', 'hgb', '9610', '5220', '2247', 'HGB § 266 Abs. 3 B.2 und § 275 Abs. 2 Nr. 14 — Konto 9610 Körperschaftsteuer (Steuern vom Einkommen und vom Ertrag), 5220 Körperschaftsteuerrückstellung (Steuerrückstellungen) und 2247 Erstattungsansprüche aus Steuern vom Einkommen und vom Ertrag des Kontenplans dieses Pakets', 'hgb', 'Körperschaftsteuergesetz (KStG) — Körperschaftsteuer; ohne Solidaritätszuschlag und ohne Gewerbesteuer, die eigene Steuern sind', 'kstg')
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
  ('DE', 'income-taxes', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Steuern vom Einkommen: Körperschaftsteuer und Solidaritätszuschlag', '{"en":"Taxes on income: corporate income tax and solidarity surcharge"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"9610","code_to":"9611","kind":"code_range"}]'::jsonb, 'KStG § 10 Nr. 2 — die Steuern vom Einkommen und sonstige Personensteuern sind nicht abziehbar, ebenso die auf diese Steuern entfallenden Nebenleistungen; § 8 Abs. 1 Satz 1 — das Einkommen wird nach dem EStG und dem KStG ermittelt', 'kstg', 10),
  ('DE', 'trade-tax', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Gewerbesteuer', '{"en":"Trade tax (Gewerbesteuer)"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[{"code_from":"9620","kind":"account_code"}]'::jsonb, 'EStG § 4 Abs. 5b — die Gewerbesteuer und die darauf entfallenden Nebenleistungen sind keine Betriebsausgaben; anzuwenden über KStG § 8 Abs. 1 Satz 1', 'estg', 20),
  ('DE', 'entertainment', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Bewirtungsaufwendungen aus geschäftlichem Anlass — nicht abziehbarer Teil', '{"en":"Business entertainment — non-deductible share"}'::jsonb, 'add_back'::tax.adjustment_direction, 30, null, '[]'::jsonb, 'EStG § 4 Abs. 5 Satz 1 Nr. 2 — Aufwendungen für die Bewirtung von Personen aus geschäftlichem Anlass dürfen den Gewinn nicht mindern, soweit sie 70 Prozent der angemessenen und nachgewiesenen Aufwendungen übersteigen; die Gesellschaft nennt den Betrag der nachgewiesenen, angemessenen Aufwendungen', 'estg', 30),
  ('DE', 'gifts', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Geschenke an Nichtarbeitnehmer über der Freigrenze von 50 Euro', '{"en":"Gifts to non-employees above the 50 euro limit"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'EStG § 4 Abs. 5 Satz 1 Nr. 1 — Aufwendungen für Geschenke an Personen, die nicht Arbeitnehmer des Steuerpflichtigen sind, dürfen den Gewinn nicht mindern; Satz 2 — nicht, wenn die Anschaffungs- oder Herstellungskosten der dem Empfänger im Wirtschaftsjahr zugewendeten Gegenstände insgesamt 50 Euro nicht übersteigen; § 52 — in dieser Fassung für Wirtschaftsjahre anzuwenden, die nach dem 31. Dezember 2023 beginnen. Die Gesellschaft nennt die Geschenke an Empfänger, deren Summe 50 Euro übersteigt', 'estg', 40),
  ('DE', 'administrative-fines', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Geldbußen, Ordnungsgelder und Verwarnungsgelder', '{"en":"Fines, regulatory fines and cautionary fines"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'EStG § 4 Abs. 5 Satz 1 Nr. 8 — Geldbußen, Ordnungsgelder und Verwarnungsgelder, die von einem Gericht oder einer Behörde im Geltungsbereich des Gesetzes, von einem Mitgliedstaat oder von Organen der Europäischen Union festgesetzt wurden, sowie damit zusammenhängende Aufwendungen; anzuwenden über KStG § 8 Abs. 1 Satz 1. Der Kontenplan führt kein eigenes Konto dafür: die Gesellschaft nennt den Betrag', 'estg', 50),
  ('DE', 'criminal-fines', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Geldstrafen und Auflagen in einem Strafverfahren', '{"en":"Criminal fines and conditions imposed in criminal proceedings"}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'KStG § 10 Nr. 3 — in einem Strafverfahren festgesetzte Geldstrafen, sonstige Rechtsfolgen vermögensrechtlicher Art, bei denen der Strafcharakter überwiegt, und Leistungen zur Erfüllung von Auflagen oder Weisungen, soweit sie nicht lediglich der Wiedergutmachung des Schadens dienen, sowie damit zusammenhängende Aufwendungen. Die Gesellschaft nennt den Betrag', 'kstg', 60),
  ('DE', 'supervisory-board', date '2024-01-01', null, 'period_start'::tax.validity_basis, 'Vergütungen an den Aufsichtsrat — Hälfte', '{"en":"Remuneration of the supervisory board — one half"}'::jsonb, 'add_back'::tax.adjustment_direction, 50, null, '[]'::jsonb, 'KStG § 10 Nr. 4 — die Hälfte der Vergütungen jeder Art, die an Mitglieder des Aufsichtsrats, Verwaltungsrats oder andere mit der Überwachung der Geschäftsführung beauftragte Personen gewährt werden, ist nicht abziehbar. Die Gesellschaft nennt den Betrag der Vergütungen', 'kstg', 70)
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
  ('DE', 'standard', date '2024-01-01', date '2027-12-31', 'period_end'::tax.validity_basis, 'Körperschaftsteuer — Steuersatz', '{"en":"Corporate income tax rate"}'::jsonb, 15, null, 'none', '[]'::jsonb, 'KStG § 23 Abs. 1 Nr. 1 — die Körperschaftsteuer beträgt für Veranlagungszeiträume bis 2027 15 Prozent des zu versteuernden Einkommens; § 7 Abs. 4 Satz 2 — bei einem vom Kalenderjahr abweichenden Wirtschaftsjahr gilt der Gewinn in dem Kalenderjahr als bezogen, in dem das Wirtschaftsjahr endet', 'kstg', 10),
  ('DE', 'standard', date '2028-01-01', date '2028-12-31', 'period_end'::tax.validity_basis, 'Körperschaftsteuer — Steuersatz', '{"en":"Corporate income tax rate"}'::jsonb, 14, null, 'none', '[]'::jsonb, 'KStG § 23 Abs. 1 Nr. 2 — die Körperschaftsteuer beträgt für den Veranlagungszeitraum 2028 14 Prozent des zu versteuernden Einkommens; Wirtschaftsjahre, die im Kalenderjahr 2028 enden (§ 7 Abs. 4 Satz 2)', 'kstg', 10),
  ('DE', 'standard', date '2029-01-01', date '2029-12-31', 'period_end'::tax.validity_basis, 'Körperschaftsteuer — Steuersatz', '{"en":"Corporate income tax rate"}'::jsonb, 13, null, 'none', '[]'::jsonb, 'KStG § 23 Abs. 1 Nr. 3 — die Körperschaftsteuer beträgt für den Veranlagungszeitraum 2029 13 Prozent des zu versteuernden Einkommens; Wirtschaftsjahre, die im Kalenderjahr 2029 enden (§ 7 Abs. 4 Satz 2)', 'kstg', 10),
  ('DE', 'standard', date '2030-01-01', date '2030-12-31', 'period_end'::tax.validity_basis, 'Körperschaftsteuer — Steuersatz', '{"en":"Corporate income tax rate"}'::jsonb, 12, null, 'none', '[]'::jsonb, 'KStG § 23 Abs. 1 Nr. 4 — die Körperschaftsteuer beträgt für den Veranlagungszeitraum 2030 12 Prozent des zu versteuernden Einkommens; Wirtschaftsjahre, die im Kalenderjahr 2030 enden (§ 7 Abs. 4 Satz 2)', 'kstg', 10),
  ('DE', 'standard', date '2031-01-01', date '2031-12-31', 'period_end'::tax.validity_basis, 'Körperschaftsteuer — Steuersatz', '{"en":"Corporate income tax rate"}'::jsonb, 11, null, 'none', '[]'::jsonb, 'KStG § 23 Abs. 1 Nr. 5 — die Körperschaftsteuer beträgt für den Veranlagungszeitraum 2031 11 Prozent des zu versteuernden Einkommens; Wirtschaftsjahre, die im Kalenderjahr 2031 enden (§ 7 Abs. 4 Satz 2)', 'kstg', 10),
  ('DE', 'standard', date '2032-01-01', null, 'period_end'::tax.validity_basis, 'Körperschaftsteuer — Steuersatz', '{"en":"Corporate income tax rate"}'::jsonb, 10, null, 'none', '[]'::jsonb, 'KStG § 23 Abs. 1 Nr. 6 — die Körperschaftsteuer beträgt für Veranlagungszeiträume ab 2032 10 Prozent des zu versteuernden Einkommens; Wirtschaftsjahre, die ab dem Kalenderjahr 2032 enden (§ 7 Abs. 4 Satz 2)', 'kstg', 10)
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
  ('DE', date '2024-01-01', null, 'period_end'::tax.validity_basis, 1000000, 70, null, 'EStG § 10d Abs. 2 Satz 1 — nicht ausgeglichene negative Einkünfte sind in den folgenden Veranlagungszeiträumen bis zu einem Gesamtbetrag der Einkünfte von 1 Million Euro unbeschränkt, darüber hinaus bis zu 70 Prozent des 1 Million Euro übersteigenden Gesamtbetrags abzuziehen (Verlustvortrag), ohne zeitliche Begrenzung; Satz 2 — der Betrag von 2 Millionen Euro gilt nur für zusammenveranlagte Ehegatten; § 52 Abs. 18b Satz 3 — in der Fassung des Gesetzes vom 27. März 2024 (BGBl. 2024 I Nr. 108) erstmals für den Veranlagungszeitraum 2024; für Körperschaften über KStG § 8 Abs. 1 Satz 1', 'estg')
on conflict (country, valid_from) do update set
  valid_to            = excluded.valid_to,
  valid_on            = excluded.valid_on,
  floor_amount        = excluded.floor_amount,
  percent_above       = excluded.percent_above,
  carry_forward_years = excluded.carry_forward_years,
  legal_reference     = excluded.legal_reference,
  source_key          = excluded.source_key;
