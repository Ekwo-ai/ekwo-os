-- Ekwo OS — United States: the rules of this country's corporate income tax.
--
-- Generated from packs/us/corporate_tax.json at version 0.10.1, do not edit.
-- Change the pack and run `ekwo pack build us`; `ekwo pack check --all`
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
  ('US', 'US-FCIT', 'Federal corporate income tax', '{}'::jsonb, 'US-SX-IS', '10', 'Regulation S-X, 17 CFR 210.5-03, caption 10 — income or loss before income tax expense and appropriate items below. The computation starts from the line that is printed before the federal and the state income tax expense, so neither enters it; the state tax the law allows as a deduction is a rule of its own below.', 'reg-s-x', '8000', '2230', '1460', 'The chart of this pack, which is original and prescribed by no statute: 8000 is the federal income tax expense of the year, 2230 the federal income taxes payable and 1460 the income taxes receivable.', 'reg-s-x', 'Internal Revenue Code, 26 U.S.C. § 11 — a tax is imposed for each taxable year on the taxable income of every corporation, and the amount of it is 21 percent of taxable income. The tax of the states and of their cities on the profit of a company is a different tax under different laws and is not computed here.', 'irc-11')
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
  ('US', 'meals', date '2018-01-01', null, 'period_start'::tax.validity_basis, 'Business meals — the half the law does not allow', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 50, null, '[]'::jsonb, 'Internal Revenue Code, 26 U.S.C. § 274(n)(1) — the amount allowable as a deduction for any expense for food or beverages shall not exceed 50 percent of the amount of the expense that would otherwise be allowable; the exceptions of § 274(n)(2) are not applied. The chart books meals and entertainment on one account, 6130, so the company states the amount of the meals.', 'irc-274', 10),
  ('US', 'entertainment', date '2018-01-01', null, 'period_start'::tax.validity_basis, 'Entertainment, amusement and recreation', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Internal Revenue Code, 26 U.S.C. § 274(a)(1) — no deduction otherwise allowable is allowed for an activity of a type generally considered to constitute entertainment, amusement or recreation, or for a facility used in connection with it; § 274(a)(2) treats club dues as facilities. Applies to amounts paid or incurred after 31 December 2017 (Pub. L. 115-97, § 13304(e)). The company states the amount.', 'irc-274', 20),
  ('US', 'fines', date '2017-12-22', null, 'period_start'::tax.validity_basis, 'Fines, penalties and other amounts paid to a government', '{}'::jsonb, 'add_back'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Internal Revenue Code, 26 U.S.C. § 162(f)(1) — no deduction is allowed for an amount paid or incurred, by suit, agreement or otherwise, to or at the direction of a government in relation to the violation of any law or the investigation of a potential violation. The company states the amount: the amounts that § 162(f)(2) excepts (restitution, compliance, and amounts the order identifies as such) are for it to leave out. Applies from 22 December 2017 (Pub. L. 115-97, § 13306(a)(2)).', 'irc-162', 30),
  ('US', 'state-income-tax', date '1954-08-16', null, 'period_start'::tax.validity_basis, 'State income tax of the year — the deduction the law allows', '{}'::jsonb, 'deduction'::tax.adjustment_direction, 100, null, '[]'::jsonb, 'Internal Revenue Code, 26 U.S.C. § 164(a)(3) — state and local income taxes are allowed as a deduction for the taxable year within which paid or accrued. The statement line the computation starts from is printed before income tax expense, so the state income tax booked on 8020 has not reduced it. The company states the amount of the current state income tax accrued for the year: the deferred tax on 8030 is not a tax of the year, and the module reads a deduction from an income account only, not from an expense account. The federal income tax needs no rule: § 275(a)(1) denies its deduction, and the starting line already leaves it out.', 'irc-164', 40)
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
  ('US', 'federal-standard', date '2018-01-01', null, 'period_start'::tax.validity_basis, 'Federal corporate income tax rate', '{}'::jsonb, 21, null, 'none', '[]'::jsonb, 'Internal Revenue Code, 26 U.S.C. § 11(b) — the amount of the tax is 21 percent of taxable income, on all of it; Instructions for Form 1120 (2025), Schedule J, line 1a: multiply taxable income by 21 percent. Applies to taxable years beginning after 31 December 2017 (Pub. L. 115-97, § 13001).', 'irc-11', 10)
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
  ('US', date '2021-01-01', null, 'period_start'::tax.validity_basis, 0, 80, null, 'Internal Revenue Code, 26 U.S.C. § 172(a)(2)(B) and (b)(1)(A)(ii)(II) — a net operating loss arising in a taxable year beginning after 31 December 2017 is carried to each later year without lapsing, and the deduction of it is limited, for taxable years beginning after 31 December 2020, to 80 percent of taxable income computed without regard to the deduction of § 172 and to sections 199A and 250. Losses of years beginning before 1 January 2018 follow § 172(a)(2)(A) and are not computed here.', 'irc-172')
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
  ('US', date '2018-01-01', null, 'period_start'::tax.validity_basis, 'share_of_reference_tax', 'fiscal', '[{"day":15,"month":4,"sequence":1,"share_percent":25},{"day":15,"month":6,"sequence":2,"share_percent":25},{"day":15,"month":9,"sequence":3,"share_percent":25},{"day":15,"month":12,"sequence":4,"share_percent":25}]'::jsonb, null, null, 'Internal Revenue Code, 26 U.S.C. § 6655(c) and (d)(1) — four required installments, due on the 15th day of the 4th, 6th, 9th and 12th months of the taxable year (15 April, 15 June, 15 September and 15 December for a calendar year; § 6655(i)(1) substitutes the corresponding months for any other year), each of 25 percent of the required annual payment. The required annual payment is the lesser of 100 percent of the tax of the year and 100 percent of the tax of the preceding year, and a large corporation (§ 6655(g)(2)) may use the preceding year for the first installment only; neither the choice of the reference nor the annualised income method of § 6655(e) is in the data, and the $500 exception of § 6655(f) is not either.', 'irc-6655')
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
