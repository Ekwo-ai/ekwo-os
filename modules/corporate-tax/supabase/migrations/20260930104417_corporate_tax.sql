-- Ekwo — the `tax` module: corporate income tax, estimated from the books.
--
-- Corporate income tax starts from the accounting result. Everything after
-- that is a rule of a country — what is added back, what is deducted, how far
-- a loss carries, which rate applies to which slice and under which
-- conditions — plus a handful of facts only the company can state: whether it
-- is a small company, what it paid its director. So this module holds three
-- things and no fourth:
--
--   * **what a country says**, in reference tables filled from
--     `packs/<cc>/corporate_tax.json` and read where they stand;
--   * **what a company declares**, in tables of its own: its parameters for a
--     financial year, the expenses it says fall under a rule, the losses it
--     carried in, the credits it holds;
--   * **the computation**, `tax.estimate(company, fiscal_year, at)`, which
--     reads the two and the ledger and writes nothing.
--
-- **The engine knows no country.** There is no rate, no threshold, no account
-- and no article in this file. A company whose pack carries no `corporate_tax`
-- section is refused by name, `no_corporate_tax_rules`, rather than given a
-- neighbour's law.
--
-- **The ledger is read through the socle's own statements.** The accounting
-- result is one line of the income statement the pack names, asked of
-- `public.financial_statement()`; the balance of an account over the period is
-- asked of `public.statement_account_matches()`, which is what that statement
-- is summed from. The two therefore cannot disagree, a closed year still reads
-- as the year it was, and nothing here sums a ledger line.
--
-- **Nothing is inferred.** A reduced rate depends on conditions, and each
-- condition is a parameter the company declares for the year. One that is not
-- declared is not met, and the estimate says which one in a line of its own
-- rather than guessing from the books.
--
-- **An estimate is called an estimate.** `tax.estimate()` returns lines whose
-- last one is `estimated_tax`. The words `tax_due` appear only on a
-- computation somebody holding `tax.finalize` — the owner preset, and nobody
-- else by default — has finalised, for a whole financial year, against a
-- ledger that still says what the recorded computation says.
--
-- **Rounding.** Every amount is rounded by `public.round_amount()` at the
-- decimals of the company's currency, by the method of its country. A
-- percentage is a `numeric`, never a float.
--
-- This module posts nothing. The provision entry and the prepayment plan are
-- a later version; its manifest says `"posts": false` and a test holds it to
-- that.

create schema tax;

comment on schema tax is
  'Ekwo module `tax`: corporate income tax estimated from the books. Country rules are pack data, company parameters are declared, and the computation writes nothing to the ledger.';

-- ---------------------------------------------------------------------------
-- Vocabulary
-- ---------------------------------------------------------------------------

create type tax.adjustment_direction as enum ('add_back', 'deduction');

comment on type tax.adjustment_direction is
  'What a rule does to the accounting result. add_back: an expense the books carry and the tax does not accept, in whole or in part. deduction: an income the books carry and the tax leaves out, or an allowance the books do not carry.';

create type tax.validity_basis as enum ('period_start', 'period_end');

comment on type tax.validity_basis is
  'Which day of a financial year a rule''s validity is read on. A law that applies to "financial years opened from" a date is read on the first day; one that applies to "financial years closed from" a date is read on the last.';

create type tax.parameter_type as enum ('boolean', 'amount');

create type tax.computation_status as enum ('estimate', 'final', 'superseded');

comment on type tax.computation_status is
  'estimate: recorded as it stood on a day, and nothing more. final: what the company holds to be the tax of the year, set by somebody holding tax.finalize. superseded: a final computation that was withdrawn; kept, never deleted.';

-- ---------------------------------------------------------------------------
-- What a country says
--
-- Seven tables, all keyed on the country and none of them copied into a
-- company: a rate of a country is not something an operator redefines. Every
-- row carries the article it comes from, and every dated row says from which
-- day and on which day of the financial year that date is read.
-- ---------------------------------------------------------------------------

create table tax.country_rules (
  country                 char(2) primary key,
  tax_code                text not null,
  name                    text not null,
  name_i18n               jsonb not null default '{}'::jsonb,
  result_statement_code   text not null,
  result_line_code        text not null,
  result_legal_reference  text not null,
  result_source_key       text,
  expense_account_code    text not null,
  payable_account_code    text not null,
  receivable_account_code text,
  accounts_legal_reference text not null,
  accounts_source_key     text,
  legal_reference         text not null,
  source_key              text,
  constraint tax_country_rules_country_format check (country ~ '^[A-Z]{2}$')
);

comment on table tax.country_rules is
  'What one country calls its corporate income tax, which line of which income statement the computation starts from, and the accounts of its chart the tax is booked on. Filled by `ekwo pack build` from packs/<cc>/corporate_tax.json, read where it stands, never copied into a company.';
comment on column tax.country_rules.result_line_code is
  'The line of result_statement_code that is the accounting result the tax starts from. A country whose statement prints a result before income tax names that line; one that prints only the net result names it and adds the tax charge back by a rule.';
comment on column tax.country_rules.expense_account_code is
  'The account the tax charge of the year is booked on. **Declared, no reader yet**: this version posts nothing.';
comment on column tax.country_rules.payable_account_code is
  'The account the estimated tax debt is carried on. **Declared, no reader yet**: this version posts nothing.';
comment on column tax.country_rules.receivable_account_code is
  'The account a prepayment or a refund to come is carried on, where the chart keeps one apart. **Declared, no reader yet.**';

create table tax.parameter_templates (
  country         char(2) not null,
  code            text not null,
  name            text not null,
  name_i18n       jsonb not null default '{}'::jsonb,
  value_type      tax.parameter_type not null,
  legal_reference text not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, code)
);

comment on table tax.parameter_templates is
  'The facts a company of one country has to declare for its tax to be computed: a judgement (is it a small company) or an amount (what it paid its director). The conditions of a rate name them, and nothing infers one.';

create table tax.adjustment_rule_templates (
  country         char(2) not null,
  code            text not null,
  valid_from      date not null,
  valid_to        date,
  valid_on        tax.validity_basis not null default 'period_start',
  name            text not null,
  name_i18n       jsonb not null default '{}'::jsonb,
  direction       tax.adjustment_direction not null,
  percent         numeric(9, 6),
  formula         jsonb,
  account_rules   jsonb not null default '[]'::jsonb,
  legal_reference text not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, code, valid_from),
  constraint tax_adjustment_rule_validity check (valid_to is null or valid_to >= valid_from),
  constraint tax_adjustment_rule_percent_or_formula check ((percent is null) <> (formula is null)),
  constraint tax_adjustment_rule_percent check (percent is null or percent >= 0),
  constraint tax_adjustment_rule_accounts check (jsonb_typeof(account_rules) = 'array')
);

comment on table tax.adjustment_rule_templates is
  'One rule of a country between the accounting result and the taxable one, for the days it is in force. A rule is never edited: a percentage that changes is a new row with a new valid_from and a valid_to on the old one, so a past year keeps its answer.';
comment on column tax.adjustment_rule_templates.percent is
  'The share of the base the rule moves: 100 for an expense refused in full, 31 for one refused for 31 %. Null where a formula works it out from what the company declares.';
comment on column tax.adjustment_rule_templates.formula is
  'A closed vocabulary, read by tax.formula_percent(): a straight line of one declared variable, with an optional coefficient picked by a declared word, a floor, a ceiling and steps. Data, not an expression language.';
comment on column tax.adjustment_rule_templates.account_rules is
  'The accounts of the pack''s chart whose whole balance falls under this rule, in the vocabulary of statement_line_rules: account_code, code_prefix, code_range. Empty where the chart keeps no account for it, and then a company says which of its accounts, or which amount, the rule applies to.';

create table tax.rate_templates (
  country         char(2) not null,
  code            text not null,
  valid_from      date not null,
  valid_to        date,
  valid_on        tax.validity_basis not null default 'period_start',
  name            text not null,
  name_i18n       jsonb not null default '{}'::jsonb,
  rate            numeric(9, 6) not null,
  up_to           numeric,
  up_to_prorata   text not null default 'none',
  conditions      jsonb not null default '[]'::jsonb,
  legal_reference text not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, code, valid_from),
  constraint tax_rate_validity check (valid_to is null or valid_to >= valid_from),
  constraint tax_rate_bounds check (rate >= 0 and rate <= 100),
  constraint tax_rate_up_to check (up_to is null or up_to > 0),
  constraint tax_rate_prorata check (up_to_prorata in ('none', 'months')),
  constraint tax_rate_conditions check (jsonb_typeof(conditions) = 'array')
);

comment on table tax.rate_templates is
  'One rate of a country, for the days it is in force. A rate with up_to applies to the slice of the taxable base below that amount; the one without applies to what is left. A rate whose conditions are not all met is not applied, and the estimate says which condition failed.';
comment on column tax.rate_templates.up_to_prorata is
  'none: the threshold is the same whatever the length of the financial year. months: it is stated for twelve months and shared out over the months the year actually has.';
comment on column tax.rate_templates.conditions is
  'Every one has to be met. Each names a parameter the company declares and a test from a closed list — is_true, is_false, at_least, at_most, below, above — read by tax.condition_failure().';

create table tax.loss_rule_templates (
  country             char(2) not null,
  valid_from          date not null,
  valid_to            date,
  valid_on            tax.validity_basis not null default 'period_start',
  floor_amount        numeric,
  percent_above       numeric(9, 6),
  carry_forward_years integer,
  legal_reference     text not null,
  source_key          text,
  primary key (country, valid_from),
  constraint tax_loss_rule_validity check (valid_to is null or valid_to >= valid_from),
  constraint tax_loss_rule_limit check ((floor_amount is null) = (percent_above is null)),
  constraint tax_loss_rule_years check (carry_forward_years is null or carry_forward_years > 0)
);

comment on table tax.loss_rule_templates is
  'How far a loss of an earlier year may be set against the profit of this one: in full where the two limits are null, otherwise up to floor_amount plus percent_above of the profit beyond it. carry_forward_years is null where a loss never lapses.';

create table tax.prepayment_templates (
  country         char(2) not null,
  valid_from      date not null,
  valid_to        date,
  valid_on        tax.validity_basis not null default 'period_start',
  method          text not null,
  month_basis     text not null,
  instalments     jsonb not null,
  surcharge_percent numeric(9, 6),
  exempt_up_to    numeric,
  legal_reference text not null,
  source_key      text,
  primary key (country, valid_from),
  constraint tax_prepayment_validity check (valid_to is null or valid_to >= valid_from),
  constraint tax_prepayment_method check (method in ('surcharge_on_shortfall', 'share_of_reference_tax')),
  constraint tax_prepayment_month_basis check (month_basis in ('fiscal', 'calendar')),
  constraint tax_prepayment_instalments check (jsonb_typeof(instalments) = 'array')
);

comment on table tax.prepayment_templates is
  'When a company of this country pays its tax in advance, and what each payment is worth. **Declared, no reader yet**: the prepayment plan is a later version of this module, and the shape is published now so a pack can carry the figures of a year before anything reads them.';
comment on column tax.prepayment_templates.method is
  'surcharge_on_shortfall: nothing is compulsory, the tax is raised by surcharge_percent and each instalment paid in time earns the credit_percent it carries. share_of_reference_tax: each instalment is share_percent of the tax of a reference year, and none is asked where that tax does not exceed exempt_up_to.';
comment on column tax.prepayment_templates.month_basis is
  'fiscal: an instalment falls in the n-th month of the financial year. calendar: it falls in a month of the calendar, whatever the financial year.';

create table tax.credit_templates (
  country         char(2) not null,
  code            text not null,
  valid_from      date not null,
  valid_to        date,
  valid_on        tax.validity_basis not null default 'period_start',
  name            text not null,
  name_i18n       jsonb not null default '{}'::jsonb,
  refundable      boolean not null default false,
  legal_reference text not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, code, valid_from),
  constraint tax_credit_validity check (valid_to is null or valid_to >= valid_from)
);

comment on table tax.credit_templates is
  'A credit a company of this country may set against its tax. The amount is the company''s to declare; what the pack says is that the credit exists, whether what exceeds the tax is paid back, and the article it comes from.';

-- ---------------------------------------------------------------------------
-- What a company declares
-- ---------------------------------------------------------------------------

create table tax.company_parameters (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references public.companies(id) on delete cascade,
  fiscal_year_id uuid not null references public.fiscal_years(id),
  code           text not null,
  value_boolean  boolean,
  value_amount   numeric,
  note           text,
  declared_by    uuid default auth.uid(),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (company_id, fiscal_year_id, code),
  constraint tax_company_parameters_one_value check ((value_boolean is null) <> (value_amount is null))
);

comment on table tax.company_parameters is
  'What a company states about itself for one financial year, under a code its country pack declares: a judgement or an amount. Stated per year because both change from one year to the next, and never worked out from the books.';

create index tax_company_parameters_fiscal_year_idx on tax.company_parameters (fiscal_year_id);

create trigger tax_company_parameters_set_updated_at
  before update on tax.company_parameters
  for each row execute function public.set_updated_at();

create table tax.adjustments (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references public.companies(id) on delete cascade,
  fiscal_year_id uuid references public.fiscal_years(id),
  rule_code      text not null,
  account_id     uuid references public.accounts(id) on delete restrict,
  amount         numeric,
  parameters     jsonb not null default '{}'::jsonb,
  note           text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint tax_adjustments_account_or_amount check ((account_id is null) <> (amount is null)),
  constraint tax_adjustments_amount_has_year check (amount is null or fiscal_year_id is not null),
  constraint tax_adjustments_amount_positive check (amount is null or amount >= 0),
  constraint tax_adjustments_parameters check (jsonb_typeof(parameters) = 'object'),
  foreign key (account_id, company_id) references public.accounts(id, company_id)
);

comment on table tax.adjustments is
  'What a company says falls under a rule of its country, in one of two ways. An account: its balance over the year is the base, read from the ledger each time, for one year or — with no fiscal_year_id — for every year. An amount: stated once, for one year. The rule, its percentage and its article stay in the pack.';
comment on column tax.adjustments.account_id is
  'An account of the company whose whole balance is the base of the rule. An account named here is taken out of what the pack''s own account rules catch, so it is never counted twice.';
comment on column tax.adjustments.parameters is
  'What a rule with a formula needs to know about this expense — the emission of a car, its fuel — under the names the formula uses.';

create unique index tax_adjustments_account_standing_idx
  on tax.adjustments (company_id, account_id) where account_id is not null and fiscal_year_id is null;
create unique index tax_adjustments_account_year_idx
  on tax.adjustments (company_id, fiscal_year_id, account_id) where account_id is not null and fiscal_year_id is not null;
create index tax_adjustments_fiscal_year_idx on tax.adjustments (fiscal_year_id);
create index tax_adjustments_account_company_idx on tax.adjustments (account_id, company_id);
create index tax_adjustments_company_idx on tax.adjustments (company_id);

create trigger tax_adjustments_set_updated_at
  before update on tax.adjustments
  for each row execute function public.set_updated_at();

create table tax.credits (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references public.companies(id) on delete cascade,
  fiscal_year_id uuid not null references public.fiscal_years(id),
  credit_code    text not null,
  amount         numeric not null,
  note           text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint tax_credits_amount_positive check (amount > 0)
);

comment on table tax.credits is
  'A credit a company holds against the tax of one financial year, under a code its country pack declares. The amount is declared: working out a credit is the business of whatever grants it.';

create index tax_credits_company_year_idx on tax.credits (company_id, fiscal_year_id);
create index tax_credits_fiscal_year_idx on tax.credits (fiscal_year_id);

create trigger tax_credits_set_updated_at
  before update on tax.credits
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- What was computed, and kept
-- ---------------------------------------------------------------------------

create table tax.computations (
  id                uuid primary key default gen_random_uuid(),
  company_id        uuid not null references public.companies(id) on delete cascade,
  fiscal_year_id    uuid not null references public.fiscal_years(id),
  version           integer not null,
  status            tax.computation_status not null default 'estimate',
  computed_at       date not null,
  tax_code          text not null,
  currency_code     char(3) not null,
  accounting_result numeric not null,
  taxable_base      numeric not null,
  loss_of_period    numeric not null default 0,
  tax               numeric not null,
  recorded_by       uuid,
  recorded_at       timestamptz not null default now(),
  finalised_by      uuid,
  finalised_at      timestamptz,
  superseded_by     uuid,
  superseded_at     timestamptz,
  unique (company_id, fiscal_year_id, version),
  constraint tax_computations_version_positive check (version > 0),
  constraint tax_computations_final_is_signed check ((status = 'estimate') = (finalised_at is null)),
  constraint tax_computations_superseded_is_dated check ((status = 'superseded') = (superseded_at is not null))
);

comment on table tax.computations is
  'One computation of the tax of one financial year as it stood on a day, numbered per year. Written by tax.record_computation() and by nothing else: no role holds a write privilege on it. The four figures on the row are read off its lines when it is recorded.';
comment on column tax.computations.computed_at is
  'The day the ledger was read up to. A final computation is read up to the last day of the financial year.';
comment on column tax.computations.tax is
  'The tax this computation comes to. An estimate while status is estimate; what the company holds to be due once status is final.';

create unique index tax_computations_id_company_idx on tax.computations (id, company_id);
create unique index tax_computations_one_final_idx on tax.computations (company_id, fiscal_year_id) where status = 'final';
create index tax_computations_fiscal_year_idx on tax.computations (fiscal_year_id);

create table tax.computation_lines (
  id              uuid primary key default gen_random_uuid(),
  computation_id  uuid not null references tax.computations(id) on delete cascade,
  company_id      uuid not null references public.companies(id) on delete cascade,
  sequence        integer not null,
  kind            text not null,
  code            text,
  name            text,
  base            numeric,
  rate            numeric,
  amount          numeric,
  legal_reference text,
  source_key      text,
  unique (computation_id, sequence),
  foreign key (computation_id, company_id) references tax.computations(id, company_id) on delete cascade
);

comment on table tax.computation_lines is
  'The lines tax.estimate() returned when a computation was recorded, as they were: the result, each adjustment with its rule and its article, the losses used, the base, each rate with its slice, the credits and the tax.';

create index tax_computation_lines_company_idx on tax.computation_lines (company_id);
create index tax_computation_lines_computation_company_idx on tax.computation_lines (computation_id, company_id);

create table tax.losses (
  id                uuid primary key default gen_random_uuid(),
  company_id        uuid not null references public.companies(id) on delete cascade,
  origin_period_end date not null,
  amount            numeric not null,
  computation_id    uuid,
  note              text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (company_id, origin_period_end),
  constraint tax_losses_amount_positive check (amount > 0),
  foreign key (computation_id, company_id) references tax.computations(id, company_id)
);

comment on table tax.losses is
  'The tax losses of a company by the year they come from. A row with no computation_id is declared: the stock a company brought in from before these books. A row with one was written when that computation was finalised. What is left of each is tax.loss_stock().';
comment on column tax.losses.origin_period_end is
  'The last day of the financial year the loss was made in. Losses are used oldest first.';

create index tax_losses_computation_company_idx on tax.losses (computation_id, company_id);

create trigger tax_losses_set_updated_at
  before update on tax.losses
  for each row execute function public.set_updated_at();

create table tax.loss_uses (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references public.companies(id) on delete cascade,
  loss_id        uuid not null references tax.losses(id) on delete restrict,
  computation_id uuid not null,
  amount         numeric not null,
  created_at     timestamptz not null default now(),
  unique (loss_id, computation_id),
  constraint tax_loss_uses_amount_positive check (amount > 0),
  foreign key (computation_id, company_id) references tax.computations(id, company_id)
);

comment on table tax.loss_uses is
  'How much of one loss a final computation set against its profit. Written when the computation is finalised and removed when it is withdrawn, so the stock is always what the final computations say.';

create index tax_loss_uses_company_idx on tax.loss_uses (company_id);
create index tax_loss_uses_computation_company_idx on tax.loss_uses (computation_id, company_id);

-- ---------------------------------------------------------------------------
-- Reading a rule
--
-- Four small functions, each the only reader of one piece of vocabulary. None
-- of them touches a table, so they are immutable and a test can ask them
-- anything.
-- ---------------------------------------------------------------------------

create or replace function tax.in_force(
  p_valid_from date,
  p_valid_to   date,
  p_valid_on   tax.validity_basis,
  p_start      date,
  p_end        date
)
returns boolean
language sql
immutable
as $$
  select p_valid_from <= d.day and (p_valid_to is null or p_valid_to >= d.day)
    from (select case p_valid_on when 'period_start' then p_start else p_end end as day) d;
$$;

comment on function tax.in_force(date, date, tax.validity_basis, date, date) is
  'Whether a dated rule applies to a financial year: its validity read on the first or on the last day of the year, as the rule itself says. The only place valid_on is read.';

create or replace function tax.account_matches(p_account_code text, p_account_rules jsonb)
returns boolean
language sql
immutable
as $$
  select exists (
    select 1
      from jsonb_array_elements(coalesce(p_account_rules, '[]'::jsonb)) r
     where case r ->> 'kind'
             when 'account_code' then p_account_code = r ->> 'code_from'
             when 'code_prefix'  then left(p_account_code, length(r ->> 'code_from')) = r ->> 'code_from'
             when 'code_range'   then left(p_account_code, length(r ->> 'code_from')) >= r ->> 'code_from'
                                  and left(p_account_code, length(r ->> 'code_to'))   <= r ->> 'code_to'
             else false
           end
  );
$$;

comment on function tax.account_matches(text, jsonb) is
  'Whether an account code is caught by the account rules of an adjustment rule. The three kinds are the ones a statement line maps accounts with, compared the same way.';

create or replace function tax.formula_percent(p_formula jsonb, p_parameters jsonb)
returns numeric
language plpgsql
immutable
as $$
declare
  v_variable    text := p_formula ->> 'variable';
  v_value       numeric;
  v_coefficient numeric := 1;
  v_word        text;
  v_result      numeric;
  v_step        jsonb;
begin
  if p_parameters ->> v_variable is null then
    raise exception 'adjustment_parameter_missing: this rule works its percentage out from %, which the adjustment does not state', v_variable
      using errcode = '22023';
  end if;
  if jsonb_typeof(p_parameters -> v_variable) <> 'number' then
    raise exception 'adjustment_parameter_type: % is a number, and the adjustment states %', v_variable, p_parameters -> v_variable
      using errcode = '22023';
  end if;
  v_value := (p_parameters ->> v_variable)::numeric;

  if p_formula ? 'coefficient' then
    v_word := p_parameters ->> (p_formula -> 'coefficient' ->> 'parameter');
    if v_word is null then
      raise exception 'adjustment_parameter_missing: this rule picks a coefficient by %, which the adjustment does not state',
        p_formula -> 'coefficient' ->> 'parameter'
        using errcode = '22023';
    end if;
    v_coefficient := (p_formula -> 'coefficient' -> 'values' ->> v_word)::numeric;
    if v_coefficient is null then
      raise exception 'adjustment_parameter_unknown: % is not a % this rule knows; it knows %',
        v_word, p_formula -> 'coefficient' ->> 'parameter',
        (select string_agg(k, ', ' order by k) from jsonb_object_keys(p_formula -> 'coefficient' -> 'values') k)
        using errcode = '22023';
    end if;
  end if;

  v_result := (p_formula ->> 'intercept')::numeric
            + (p_formula ->> 'slope')::numeric * v_coefficient * v_value;
  -- Where the law rounds the percentage itself, before it is held between
  -- its bounds.
  if p_formula ? 'decimals' then
    v_result := round(v_result, (p_formula ->> 'decimals')::integer);
  end if;
  if p_formula ? 'min' then
    v_result := greatest(v_result, (p_formula ->> 'min')::numeric);
  end if;
  if p_formula ? 'max' then
    v_result := least(v_result, (p_formula ->> 'max')::numeric);
  end if;

  -- A step replaces the line from a value of the variable upwards. The last
  -- one reached wins, so they are read in ascending order.
  for v_step in
    select s from jsonb_array_elements(coalesce(p_formula -> 'steps', '[]'::jsonb)) s
     order by (s ->> 'from')::numeric
  loop
    if v_value >= (v_step ->> 'from')::numeric then
      v_result := (v_step ->> 'percent')::numeric;
    end if;
  end loop;

  return case p_formula ->> 'yields'
           when 'deductible_percent' then 100 - v_result
           else v_result
         end;
end;
$$;

comment on function tax.formula_percent(jsonb, jsonb) is
  'The percentage of its base a rule with a formula moves, from what an adjustment states. A straight line of one variable — intercept plus slope times coefficient times the variable — rounded where the law rounds it, held between a floor and a ceiling, then replaced by a step where one is reached. A formula that yields the deductible share answers with what is left of a hundred. Raises by name when the adjustment does not state what the formula needs.';

create or replace function tax.condition_failure(p_condition jsonb, p_values jsonb, p_taxable_base numeric)
returns text
language plpgsql
immutable
as $$
declare
  v_parameter text := p_condition ->> 'parameter';
  v_test      text := p_condition ->> 'test';
  v_value     jsonb := p_values -> v_parameter;
  v_amount    numeric := (p_condition ->> 'amount')::numeric;
  v_met       boolean;
begin
  -- A condition another declaration lifts: a starting company is not held to
  -- the threshold an established one is. Any one of the parameters named,
  -- declared true, is enough.
  if exists (
    select 1 from jsonb_array_elements_text(coalesce(p_condition -> 'waived_by', '[]'::jsonb)) w
     where p_values -> w = 'true'::jsonb
  ) then
    return null;
  end if;

  if v_value is null then
    return 'not_declared: ' || v_parameter;
  end if;

  v_met := case v_test
             when 'is_true'  then v_value = 'true'::jsonb
             when 'is_false' then v_value = 'false'::jsonb
             when 'at_least' then (v_value #>> '{}')::numeric >= v_amount
             when 'at_most'  then (v_value #>> '{}')::numeric <= v_amount
             when 'below'    then (v_value #>> '{}')::numeric <  v_amount
             when 'above'    then (v_value #>> '{}')::numeric >  v_amount
           end;
  if v_met is null then
    raise exception 'unknown_condition_test: % is not a test a rate condition may use', v_test
      using errcode = '22023';
  end if;

  -- The one alternative the vocabulary carries: an amount that is below the
  -- threshold and still at least the taxable base of the year.
  if not v_met and p_condition ->> 'or_at_least' = 'taxable_base' then
    v_met := (v_value #>> '{}')::numeric >= p_taxable_base;
  end if;

  return case when v_met then null else 'not_met: ' || v_parameter end;
end;
$$;

comment on function tax.condition_failure(jsonb, jsonb, numeric) is
  'Null when a condition of a rate is met by what the company declared, otherwise which parameter stands in the way and how: not_declared, or not_met. A parameter nobody declared is never assumed either way.';

-- ---------------------------------------------------------------------------
-- The loss stock
-- ---------------------------------------------------------------------------

create or replace function tax.loss_stock(p_company_id uuid, p_before date default null)
returns table (
  loss_id           uuid,
  origin_period_end date,
  amount            numeric,
  used              numeric,
  remaining         numeric
)
language sql
stable
as $$
  select l.id, l.origin_period_end, l.amount,
         coalesce(u.used, 0),
         l.amount - coalesce(u.used, 0)
    from tax.losses l
    left join (
      select x.loss_id, sum(x.amount) as used
        from tax.loss_uses x
        join tax.computations c on c.id = x.computation_id
        join public.fiscal_years f on f.id = c.fiscal_year_id
       where x.company_id = p_company_id
         and (p_before is null or f.start_date < p_before)
       group by x.loss_id
    ) u on u.loss_id = l.id
   where l.company_id = p_company_id
     and (p_before is null or l.origin_period_end < p_before)
   order by l.origin_period_end;
$$;

comment on function tax.loss_stock(uuid, date) is
  'The losses of a company by year of origin: what each was, what final computations have used of it, and what is left. With a date, as the stock stood for a financial year opening on that day: losses of earlier years, less what earlier years used.';

-- ---------------------------------------------------------------------------
-- The computation
-- ---------------------------------------------------------------------------

create or replace function tax.line(
  p_kind            text,
  p_code            text,
  p_name            text,
  p_base            numeric,
  p_rate            numeric,
  p_amount          numeric,
  p_legal_reference text default null,
  p_source_key      text default null
)
returns jsonb
language sql
immutable
as $$
  select jsonb_build_array(jsonb_build_object(
    'kind', p_kind, 'code', p_code, 'name', p_name, 'base', p_base, 'rate', p_rate,
    'amount', p_amount, 'legal_reference', p_legal_reference, 'source_key', p_source_key));
$$;

comment on function tax.line(text, text, text, numeric, numeric, numeric, text, text) is
  'One line of an estimate, as tax.estimate() gathers them before returning them in order.';

create or replace function tax.estimate(
  p_company_id     uuid,
  p_fiscal_year_id uuid,
  p_at             date default null
)
returns table (
  sequence        integer,
  kind            text,
  code            text,
  name            text,
  base            numeric,
  rate            numeric,
  amount          numeric,
  legal_reference text,
  source_key      text
)
language plpgsql
stable
as $$
#variable_conflict use_column
declare
  v_company   public.companies%rowtype;
  v_year      public.fiscal_years%rowtype;
  v_country   char(2);
  v_rules     tax.country_rules%rowtype;
  v_loss_rule tax.loss_rule_templates%rowtype;
  v_round     public.money_rounding;
  v_languages text[];
  v_to        date;
  v_months    numeric;
  v_values    jsonb;
  v_rows      jsonb := '[]'::jsonb;
  v_result    numeric;
  v_label     text;
  v_fiscal    numeric;
  v_base      numeric := 0;
  v_tax       numeric := 0;
  v_stock     numeric;
  v_limit     numeric;
  v_use       numeric;
  v_used      numeric := 0;
  v_previous  numeric := 0;
  v_cap       numeric;
  v_slice     numeric;
  v_percent   numeric;
  v_amount    numeric;
  v_failure   text;
  v_rest      boolean := false;
  r           record;
begin
  -- 1. Who is asking, and about what.

  if not public.is_installer() then
    if not public.module_enabled(p_company_id, 'tax') then
      raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company, or the caller is not a member of it'
        using errcode = '42501';
    end if;
    if not public.has_capability(p_company_id, 'tax.read') then
      raise exception 'not_allowed: estimating the tax of this company needs tax.read'
        using errcode = '42501';
    end if;
  end if;

  select * into v_company from public.companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  select * into v_year from public.fiscal_years f
   where f.id = p_fiscal_year_id and f.company_id = p_company_id;
  if not found then
    raise exception 'unknown_fiscal_year: % is not a financial year of this company', p_fiscal_year_id;
  end if;

  v_to := least(coalesce(p_at, v_year.end_date), v_year.end_date);
  if v_to < v_year.start_date then
    raise exception 'estimate_before_period: % opens on %, and an estimate at % would read nothing',
      v_year.name, v_year.start_date, p_at
      using errcode = '22023';
  end if;

  v_country := coalesce(v_company.fiscal_country, v_company.country);
  select * into v_rules from tax.country_rules t where t.country = v_country;
  if not found then
    raise exception 'no_corporate_tax_rules: the country pack of % carries no corporate_tax section, so there is no rule to estimate a tax from. A pack says it in packs/<cc>/corporate_tax.json.',
      v_country
      using errcode = '55006';
  end if;

  v_round     := public.rounding_of(p_company_id);
  v_languages := public.preferred_languages(p_company_id);

  -- One answer per day. `ekwo pack check` refuses a pack whose versions
  -- overlap, but a seed only ever adds: a version whose valid_from was edited
  -- in a pack leaves the earlier row behind, and two rows in force would count
  -- an expense twice without a word.
  select v.what || ' ' || v.code into v_label
    from (
      select 'adjustment rule' as what, t.code, t.valid_from, t.valid_to, t.valid_on
        from tax.adjustment_rule_templates t where t.country = v_country
      union all
      select 'rate', t.code, t.valid_from, t.valid_to, t.valid_on
        from tax.rate_templates t where t.country = v_country
      union all
      select 'credit', t.code, t.valid_from, t.valid_to, t.valid_on
        from tax.credit_templates t where t.country = v_country
      union all
      select 'loss rule', '', t.valid_from, t.valid_to, t.valid_on
        from tax.loss_rule_templates t where t.country = v_country
    ) v
   where tax.in_force(v.valid_from, v.valid_to, v.valid_on, v_year.start_date, v_year.end_date)
   group by v.what, v.code
  having count(*) > 1
   order by 1
   limit 1;
  if found then
    raise exception 'rule_versions_overlap: the corporate tax rules of % hold two versions of the % in force for %. Close the earlier one with a valid_to.',
      v_country, trim(v_label), v_year.name
      using errcode = '55006';
  end if;

  -- 2. The accounting result: one line of the income statement the pack
  --    names, as the socle prints it for the period.

  if not exists (
    select 1 from public.available_statements(p_company_id, v_to) s
     where s.code = v_rules.result_statement_code
  ) then
    raise exception 'no_result_statement: the corporate tax rules of % start from the statement %, which the chart of this company does not report on',
      v_country, v_rules.result_statement_code
      using errcode = '55006';
  end if;

  select f.amount, f.name into v_result, v_label
    from public.financial_statement(p_company_id, v_rules.result_statement_code, v_year.start_date, v_to) f
   where f.line_code = v_rules.result_line_code;
  if not found then
    raise exception 'no_result_line: the statement % carries no line %', v_rules.result_statement_code, v_rules.result_line_code
      using errcode = '55006';
  end if;

  v_rows := v_rows || tax.line('accounting_result', v_rules.result_line_code, v_label,
    null, null, v_result, v_rules.result_legal_reference, v_rules.result_source_key);
  v_fiscal := v_result;

  -- 3. The adjustments. Three sources, in this order for one rule: what the
  --    pack's own account rules catch, the accounts the company says fall
  --    under the rule, the amounts it states. An account the company names is
  --    taken out of the first, whichever rule it names it for.

  for r in
    with balances as (
      select m.account_id, m.account_code, m.balance
        from public.statement_account_matches(p_company_id, v_rules.result_statement_code, v_year.start_date, v_to) m
    ),
    named as (
      -- The year's own word before the standing one.
      select distinct on (a.account_id) a.id, a.account_id, a.rule_code, a.parameters
        from tax.adjustments a
       where a.company_id = p_company_id
         and a.account_id is not null
         and (a.fiscal_year_id is null or a.fiscal_year_id = p_fiscal_year_id)
       order by a.account_id, (a.fiscal_year_id is null), a.id
    ),
    rules as (
      select t.*
        from tax.adjustment_rule_templates t
       where t.country = v_country
         and tax.in_force(t.valid_from, t.valid_to, t.valid_on, v_year.start_date, v_year.end_date)
    ),
    sources as (
      select t.code as rule_code, 1 as origin, null::uuid as adjustment_id,
             '{}'::jsonb as parameters, sum(b.balance) as ledger, null::numeric as stated
        from rules t
        join balances b on tax.account_matches(b.account_code, t.account_rules)
       where not exists (select 1 from named n where n.account_id = b.account_id)
       group by t.code
      union all
      select n.rule_code, 2, n.id, n.parameters, coalesce(b.balance, 0), null
        from named n
        left join balances b on b.account_id = n.account_id
      union all
      select a.rule_code, 3, a.id, a.parameters, null, a.amount
        from tax.adjustments a
       where a.company_id = p_company_id
         and a.fiscal_year_id = p_fiscal_year_id
         and a.amount is not null
    )
    select s.rule_code, s.origin, s.adjustment_id, s.parameters, s.ledger, s.stated,
           t.code as in_force, t.direction, t.percent, t.formula,
           public.label_for(t.name, t.name_i18n, v_languages) as label,
           t.legal_reference as reference, t.source_key as source
      from sources s
      left join rules t on t.code = s.rule_code
     order by t.sequence nulls last, s.rule_code, s.origin, s.adjustment_id
  loop
    if r.in_force is null then
      -- A rule the pack has closed, or never carried for this year. Said, not
      -- dropped: the company named an expense under it and should know it no
      -- longer moves the result.
      v_rows := v_rows || tax.line('adjustment_not_applied', r.rule_code, 'rule_not_in_force',
        coalesce(r.stated, r.ledger), null, null);
      continue;
    end if;

    v_percent := coalesce(r.percent, tax.formula_percent(r.formula, r.parameters));
    -- A ledger balance is a debit less a credit: an expense is positive and
    -- an income negative. A deduction reads the income side.
    v_amount := coalesce(r.stated, case r.direction when 'add_back' then r.ledger else -r.ledger end);
    v_amount := public.round_amount(v_amount, v_round);

    v_rows := v_rows || tax.line('adjustment', r.rule_code, r.label, v_amount, v_percent,
      case r.direction when 'add_back' then 1 else -1 end
        * public.round_amount(v_amount * v_percent / 100, v_round),
      r.reference, r.source);
    v_fiscal := v_fiscal
      + case r.direction when 'add_back' then 1 else -1 end
        * public.round_amount(v_amount * v_percent / 100, v_round);
  end loop;

  v_rows := v_rows || tax.line('fiscal_result', null, null, null, null, v_fiscal);

  -- 4. The losses of earlier years, oldest first, as far as the country lets
  --    them reach.

  select coalesce(sum(s.remaining), 0) into v_stock
    from tax.loss_stock(p_company_id, v_year.start_date) s;

  if v_fiscal > 0 and v_stock > 0 then
    select * into v_loss_rule from tax.loss_rule_templates t
     where t.country = v_country
       and tax.in_force(t.valid_from, t.valid_to, t.valid_on, v_year.start_date, v_year.end_date);
    if not found then
      raise exception 'no_loss_carryforward_rule: this company carries losses and the corporate tax rules of % say nothing in force for % about setting them against a profit',
        v_country, v_year.name
        using errcode = '55006';
    end if;

    v_limit := v_fiscal;
    if v_loss_rule.floor_amount is not null then
      v_limit := least(v_fiscal,
        v_loss_rule.floor_amount
        + public.round_amount(greatest(v_fiscal - v_loss_rule.floor_amount, 0) * v_loss_rule.percent_above / 100, v_round));
    end if;

    for r in
      select s.origin_period_end, s.remaining
        from tax.loss_stock(p_company_id, v_year.start_date) s
       where s.remaining > 0
         and (v_loss_rule.carry_forward_years is null
              or s.origin_period_end >= (v_year.start_date - make_interval(years => v_loss_rule.carry_forward_years))::date)
       order by s.origin_period_end
    loop
      v_use := least(r.remaining, v_limit - v_used);
      exit when v_use <= 0;
      v_rows := v_rows || tax.line('loss_used', r.origin_period_end::text, null, r.remaining, null, -v_use,
        v_loss_rule.legal_reference, v_loss_rule.source_key);
      v_used := v_used + v_use;
    end loop;
  end if;

  -- 5. The base. A year that ends below zero has none, and what it lost is a
  --    line of its own: the stock a later year draws on.

  v_base := greatest(v_fiscal - v_used, 0);
  v_rows := v_rows || tax.line('taxable_base', null, null, null, null, v_base);
  if v_fiscal < 0 then
    v_rows := v_rows || tax.line('loss_of_period', null, null, null, null, -v_fiscal);
  end if;

  -- 6. The rates. What the company declared for the year, then each rate in
  --    force: the ones with a threshold first, lowest threshold first, each
  --    taking its slice; the one without takes what is left.

  select coalesce(jsonb_object_agg(p.code,
           case when p.value_boolean is not null then to_jsonb(p.value_boolean) else to_jsonb(p.value_amount) end),
         '{}'::jsonb)
    into v_values
    from tax.company_parameters p
   where p.company_id = p_company_id and p.fiscal_year_id = p_fiscal_year_id;

  -- Twelve where the year is a year. A part of a month counts in thirtieths.
  select a.years * 12 + a.months + a.days / 30.0 into v_months
    from (select extract(year  from age(v_year.end_date + 1, v_year.start_date))::numeric as years,
                 extract(month from age(v_year.end_date + 1, v_year.start_date))::numeric as months,
                 extract(day   from age(v_year.end_date + 1, v_year.start_date))::numeric as days) a;

  for r in
    select t.code, t.rate, t.up_to, t.up_to_prorata, t.conditions,
           public.label_for(t.name, t.name_i18n, v_languages) as label,
           t.legal_reference as reference, t.source_key as source
      from tax.rate_templates t
     where t.country = v_country
       and tax.in_force(t.valid_from, t.valid_to, t.valid_on, v_year.start_date, v_year.end_date)
     order by (t.up_to is null), t.up_to, t.sequence, t.code
  loop
    -- The first condition that fails, in the order the pack wrote them.
    select f.failure into v_failure
      from (select tax.condition_failure(c.condition, v_values, v_base) as failure, c.position
              from jsonb_array_elements(r.conditions) with ordinality as c (condition, position)) f
     where f.failure is not null
     order by f.position
     limit 1;
    if found then
      v_rows := v_rows || tax.line('rate_not_applied', r.code, v_failure, null, r.rate, null, r.reference, r.source);
      continue;
    end if;

    if r.up_to is null then
      -- One rate takes what is left. A second one in force at the same time
      -- would be two answers to one question, and the first by sequence wins.
      continue when v_rest;
      v_slice := public.round_amount(greatest(v_base - v_previous, 0), v_round);
      v_rest := true;
    else
      v_cap := case r.up_to_prorata
                 when 'months' then public.round_amount(r.up_to * v_months / 12, v_round)
                 else r.up_to
               end;
      v_slice := public.round_amount(greatest(least(v_base, v_cap) - v_previous, 0), v_round);
      v_previous := greatest(v_previous, v_cap);
    end if;

    if v_slice > 0 then
      v_amount := public.round_amount(v_slice * r.rate / 100, v_round);
      v_rows := v_rows || tax.line('rate', r.code, r.label, v_slice, r.rate, v_amount, r.reference, r.source);
      v_tax := v_tax + v_amount;
    end if;
  end loop;

  if v_base > v_previous and not v_rest then
    raise exception 'no_rate_in_force: the corporate tax rules of % carry no rate for % that applies to a base of %',
      v_country, v_year.name, v_base
      using errcode = '55006';
  end if;

  v_rows := v_rows || tax.line('tax_before_credits', null, null, v_base, null, v_tax);

  -- 7. The credits the company holds for the year. One that is not paid back
  --    stops at the tax; one that is may take the figure below zero.

  for r in
    select c.credit_code, c.amount, t.code as in_force, t.refundable,
           public.label_for(t.name, t.name_i18n, v_languages) as label,
           t.legal_reference as reference, t.source_key as source
      from tax.credits c
      left join tax.credit_templates t
        on t.country = v_country and t.code = c.credit_code
       and tax.in_force(t.valid_from, t.valid_to, t.valid_on, v_year.start_date, v_year.end_date)
     where c.company_id = p_company_id and c.fiscal_year_id = p_fiscal_year_id
     order by coalesce(t.refundable, false), t.sequence nulls last, c.credit_code, c.id
  loop
    if r.in_force is null then
      v_rows := v_rows || tax.line('credit_not_applied', r.credit_code, 'credit_not_in_force', r.amount, null, null);
      continue;
    end if;
    v_amount := case when r.refundable then r.amount else least(r.amount, greatest(v_tax, 0)) end;
    v_rows := v_rows || tax.line('credit', r.credit_code, r.label, r.amount, null, -v_amount, r.reference, r.source);
    v_tax := v_tax - v_amount;
  end loop;

  -- 8. The figure, under the only name an estimate may give it.

  v_rows := v_rows || tax.line('estimated_tax', v_rules.tax_code,
    public.label_for(v_rules.name, v_rules.name_i18n, v_languages),
    v_base, null, v_tax, v_rules.legal_reference, v_rules.source_key);

  return query
  select x.position::integer,
         x.line ->> 'kind',
         x.line ->> 'code',
         x.line ->> 'name',
         (x.line ->> 'base')::numeric,
         (x.line ->> 'rate')::numeric,
         (x.line ->> 'amount')::numeric,
         x.line ->> 'legal_reference',
         x.line ->> 'source_key'
    from jsonb_array_elements(v_rows) with ordinality as x (line, position)
   order by x.position;
end;
$$;

comment on function tax.estimate(uuid, uuid, date) is
  'The corporate income tax of one financial year as the ledger stands on a day — the whole year when no day is given — line by line: the accounting result the country pack names, each adjustment with its rule and its article, the losses of earlier years as far as they reach, the taxable base, each rate with the slice it takes, the credits, and the figure, called estimated_tax. Reads and writes nothing. A condition the company has not declared is not met and is said so in a rate_not_applied line. No country rule lives in this function.';

-- ---------------------------------------------------------------------------
-- Keeping a computation, and calling one final
--
-- Three functions, written like their neighbours in the socle: `security
-- definer`, the caller checked first, a refusal named and prefixed. They are
-- the only way a row reaches `tax.computations`, `tax.computation_lines` and
-- `tax.loss_uses`: no role holds a write privilege on those tables, so the
-- rule holds for psql and PostgREST alike.
--
-- Each takes the same advisory lock on the company and the year before it
-- reads what it is about to change, held until the transaction ends. An
-- advisory lock rather than a row lock on the year: it holds nothing a
-- declaration referring to that year would wait for. It is written in each
-- of the three rather than in a function of its own, which would be one more
-- thing a client could call.
-- ---------------------------------------------------------------------------

create or replace function tax.record_computation(
  p_company_id     uuid,
  p_fiscal_year_id uuid,
  p_at             date default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_year    public.fiscal_years%rowtype;
  v_id      uuid;
  v_version integer;
  v_to      date;
begin
  if not public.module_is_enabled(p_company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(p_company_id, 'tax.write') then
    raise exception 'not_allowed: recording a computation of the tax needs tax.write'
      using errcode = '42501';
  end if;

  select * into v_year from public.fiscal_years f
   where f.id = p_fiscal_year_id and f.company_id = p_company_id;
  if not found then
    raise exception 'unknown_fiscal_year: % is not a financial year of this company', p_fiscal_year_id;
  end if;

  -- One writer per year at a time: two recordings cannot take the same
  -- number, and a recording cannot slip in beside a finalisation.
  perform pg_advisory_xact_lock(hashtextextended('tax:' || p_company_id::text || ':' || p_fiscal_year_id::text, 0));

  if exists (
    select 1 from tax.computations c
     where c.company_id = p_company_id and c.fiscal_year_id = p_fiscal_year_id and c.status = 'final'
  ) then
    raise exception 'fiscal_year_has_final_computation: the tax of % has a final computation. Withdraw it with tax.withdraw_computation() before recording another.',
      v_year.name
      using errcode = '55006';
  end if;

  v_to := least(coalesce(p_at, v_year.end_date), v_year.end_date);

  select coalesce(max(c.version), 0) + 1 into v_version
    from tax.computations c
   where c.company_id = p_company_id and c.fiscal_year_id = p_fiscal_year_id;

  v_id := gen_random_uuid();

  with lines as (
    select * from tax.estimate(p_company_id, p_fiscal_year_id, v_to)
  ),
  header as (
    insert into tax.computations
      (id, company_id, fiscal_year_id, version, status, computed_at, tax_code, currency_code,
       accounting_result, taxable_base, loss_of_period, tax, recorded_by)
    select v_id, p_company_id, p_fiscal_year_id, v_version, 'estimate', v_to,
           (select l.code from lines l where l.kind = 'estimated_tax'),
           (select c.currency_code from public.companies c where c.id = p_company_id),
           (select l.amount from lines l where l.kind = 'accounting_result'),
           (select l.amount from lines l where l.kind = 'taxable_base'),
           coalesce((select l.amount from lines l where l.kind = 'loss_of_period'), 0),
           (select l.amount from lines l where l.kind = 'estimated_tax'),
           auth.uid()
    returning id
  )
  insert into tax.computation_lines
    (computation_id, company_id, sequence, kind, code, name, base, rate, amount, legal_reference, source_key)
  select h.id, p_company_id, l.sequence, l.kind, l.code, l.name, l.base, l.rate, l.amount,
         l.legal_reference, l.source_key
    from lines l cross join header h;

  return v_id;
end;
$$;

comment on function tax.record_computation(uuid, uuid, date) is
  'Keeps what tax.estimate() says on a day as the next computation of the year, with every line. An estimate, and called one. Refused once the year has a final computation. Needs tax.write.';

create or replace function tax.finalise_computation(p_computation_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row  tax.computations%rowtype;
  v_year public.fiscal_years%rowtype;
begin
  -- Who is asking comes before anything is locked or said: a computation of a
  -- company the caller is not on does not exist for them.
  select * into v_row from tax.computations c where c.id = p_computation_id;
  if not found or not (public.is_installer() or public.is_company_member(v_row.company_id)) then
    raise exception 'unknown_computation: %', p_computation_id;
  end if;
  if not public.module_is_enabled(v_row.company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(v_row.company_id, 'tax.finalize') then
    raise exception 'not_allowed: calling a computation of the tax final needs tax.finalize'
      using errcode = '42501';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('tax:' || v_row.company_id::text || ':' || v_row.fiscal_year_id::text, 0));
  select * into v_row from tax.computations c where c.id = p_computation_id for update;
  if v_row.status <> 'estimate' then
    raise exception 'computation_not_an_estimate: version % is %, and only an estimate is finalised', v_row.version, v_row.status
      using errcode = '55006';
  end if;

  select * into v_year from public.fiscal_years f where f.id = v_row.fiscal_year_id;
  if v_row.computed_at <> v_year.end_date then
    raise exception 'computation_not_whole_year: version % reads the ledger up to %, and % ends on %. Record the whole year first.',
      v_row.version, v_row.computed_at, v_year.name, v_year.end_date
      using errcode = '55006';
  end if;
  if exists (
    select 1 from tax.computations c
     where c.company_id = v_row.company_id and c.fiscal_year_id = v_row.fiscal_year_id
       and c.version > v_row.version
  ) then
    raise exception 'computation_not_latest: a later computation of % was recorded after version %', v_year.name, v_row.version
      using errcode = '55006';
  end if;

  -- The years are called final in their order. A later year that is already
  -- final read the loss stock as it stood without this one, and would go on
  -- saying so: it is withdrawn first.
  if exists (
    select 1 from tax.computations c
      join public.fiscal_years f on f.id = c.fiscal_year_id
     where c.company_id = v_row.company_id and c.status = 'final'
       and f.start_date > v_year.start_date
  ) then
    raise exception 'later_year_final: a financial year after % has a final computation. Withdraw it first: the losses are used in the order of the years.',
      v_year.name
      using errcode = '55006';
  end if;
  if v_row.loss_of_period > 0 and exists (
    select 1 from tax.losses s
     where s.company_id = v_row.company_id and s.origin_period_end = v_year.end_date
  ) then
    raise exception 'loss_already_declared: a loss is already recorded for the year ending %. A loss the company declared for a year these books compute is removed before that year is called final.',
      v_year.end_date
      using errcode = '55006';
  end if;

  -- What is called final is what the books say today. A ledger that moved
  -- since the computation was recorded gives a different estimate, and then
  -- the recorded one is history rather than the tax of the year.
  if exists (
    (select l.sequence, l.kind, l.code, l.base, l.rate, l.amount
       from tax.computation_lines l where l.computation_id = v_row.id
     except
     select e.sequence, e.kind, e.code, e.base, e.rate, e.amount
       from tax.estimate(v_row.company_id, v_row.fiscal_year_id, v_row.computed_at) e)
    union all
    (select e.sequence, e.kind, e.code, e.base, e.rate, e.amount
       from tax.estimate(v_row.company_id, v_row.fiscal_year_id, v_row.computed_at) e
     except
     select l.sequence, l.kind, l.code, l.base, l.rate, l.amount
       from tax.computation_lines l where l.computation_id = v_row.id)
  ) then
    raise exception 'computation_stale: the books, the declarations or the rules moved since version % was recorded, and it no longer says what an estimate says today. Record the year again and finalise that.',
      v_row.version
      using errcode = '55006';
  end if;

  update tax.computations
     set status = 'final', finalised_by = auth.uid(), finalised_at = now()
   where id = v_row.id;

  update tax.computation_lines
     set kind = 'tax_due'
   where computation_id = v_row.id and kind = 'estimated_tax';

  -- The stock moves with the final computation and with nothing else: what it
  -- used of each earlier loss, and the loss it leaves behind if it made one.
  insert into tax.loss_uses (company_id, loss_id, computation_id, amount)
  select v_row.company_id, s.id, v_row.id, -l.amount
    from tax.computation_lines l
    join tax.losses s
      on s.company_id = v_row.company_id and s.origin_period_end = l.code::date
   where l.computation_id = v_row.id and l.kind = 'loss_used';

  -- Never more than a loss was. The order of the years makes this
  -- unreachable; it is asserted because a stock below zero would quietly eat
  -- the other losses.
  if exists (select 1 from tax.loss_stock(v_row.company_id) s where s.remaining < 0) then
    raise exception 'loss_overused: a loss would be used for more than it is'
      using errcode = '55006';
  end if;

  if v_row.loss_of_period > 0 then
    insert into tax.losses (company_id, origin_period_end, amount, computation_id)
    values (v_row.company_id, v_year.end_date, v_row.loss_of_period, v_row.id);
  end if;

  return v_row.id;
end;
$$;

comment on function tax.finalise_computation(uuid) is
  'Calls the latest computation of a financial year final: what the company holds to be the tax of the year. Only a computation of the whole year, only while the ledger, the declarations and the rules still give the same lines, and only while no later year is final. Its last line becomes tax_due, the losses it used leave the stock and the loss it made enters it. Needs tax.finalize, which the owner preset holds and the accountant preset does not.';

create or replace function tax.withdraw_computation(p_computation_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row tax.computations%rowtype;
begin
  select * into v_row from tax.computations c where c.id = p_computation_id;
  if not found or not (public.is_installer() or public.is_company_member(v_row.company_id)) then
    raise exception 'unknown_computation: %', p_computation_id;
  end if;
  if not public.module_is_enabled(v_row.company_id, 'tax') then
    raise exception 'module_not_enabled: the corporate income tax module (tax) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(v_row.company_id, 'tax.finalize') then
    raise exception 'not_allowed: withdrawing a final computation of the tax needs tax.finalize'
      using errcode = '42501';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('tax:' || v_row.company_id::text || ':' || v_row.fiscal_year_id::text, 0));
  select * into v_row from tax.computations c where c.id = p_computation_id for update;
  if v_row.status <> 'final' then
    raise exception 'computation_not_final: version % is %, and only a final computation is withdrawn', v_row.version, v_row.status
      using errcode = '55006';
  end if;

  -- A loss this computation left behind, and a later final computation
  -- already drew on: that one goes first.
  if exists (
    select 1 from tax.loss_uses u
      join tax.losses s on s.id = u.loss_id
     where s.computation_id = v_row.id and u.computation_id <> v_row.id
  ) then
    raise exception 'loss_already_used: a later final computation used the loss this one recorded. Withdraw that one first.'
      using errcode = '55006';
  end if;

  -- And the years are taken back in the reverse of their order, for the
  -- reason they are called final in it.
  if exists (
    select 1 from tax.computations c
      join public.fiscal_years f on f.id = c.fiscal_year_id
      join public.fiscal_years mine on mine.id = v_row.fiscal_year_id
     where c.company_id = v_row.company_id and c.status = 'final'
       and f.start_date > mine.start_date
  ) then
    raise exception 'later_year_final: a later financial year has a final computation. Withdraw that one first.'
      using errcode = '55006';
  end if;

  delete from tax.loss_uses where computation_id = v_row.id;
  delete from tax.losses where computation_id = v_row.id;

  update tax.computations
     set status = 'superseded', superseded_by = auth.uid(), superseded_at = now()
   where id = v_row.id;

  update tax.computation_lines
     set kind = 'estimated_tax'
   where computation_id = v_row.id and kind = 'tax_due';

  return v_row.id;
end;
$$;

comment on function tax.withdraw_computation(uuid) is
  'Withdraws a final computation: it becomes superseded and is kept, the losses it used go back to the stock and the loss it recorded leaves it. Refused while a later financial year has a final computation: the years are taken back in the reverse of their order. Needs tax.finalize.';

-- ---------------------------------------------------------------------------
-- What a declaration has to agree with
--
-- A parameter, a rule and a credit are named by a code of the pack. A code
-- the pack does not carry is refused when it is written, by name, rather than
-- ignored when the tax is computed.
-- ---------------------------------------------------------------------------

create or replace function tax.guard_declaration()
returns trigger
language plpgsql
as $$
declare
  v_country char(2);
  v_type    tax.parameter_type;
begin
  select coalesce(c.fiscal_country, c.country) into v_country
    from public.companies c where c.id = new.company_id;

  if new.fiscal_year_id is not null and not exists (
    select 1 from public.fiscal_years f
     where f.id = new.fiscal_year_id and f.company_id = new.company_id
  ) then
    raise exception 'unknown_fiscal_year: % is not a financial year of this company', new.fiscal_year_id
      using errcode = '23503';
  end if;

  if tg_table_name = 'company_parameters' then
    select t.value_type into v_type
      from tax.parameter_templates t where t.country = v_country and t.code = new.code;
    if not found then
      raise exception 'unknown_tax_parameter: % is not a parameter the corporate tax rules of % declare', new.code, v_country
        using errcode = '23503';
    end if;
    if (v_type = 'boolean') <> (new.value_boolean is not null) then
      raise exception 'tax_parameter_type: % is declared as %', new.code, v_type
        using errcode = '22023';
    end if;
    new.value_amount := public.round_amount(new.value_amount, public.rounding_of(new.company_id));

  elsif tg_table_name = 'adjustments' then
    if not exists (
      select 1 from tax.adjustment_rule_templates t where t.country = v_country and t.code = new.rule_code
    ) then
      raise exception 'unknown_adjustment_rule: % is not a rule the corporate tax rules of % carry', new.rule_code, v_country
        using errcode = '23503';
    end if;
    -- A rule that works its percentage out is told what it needs when the
    -- adjustment is written, by name, rather than when the year is estimated.
    perform tax.formula_percent(t.formula, new.parameters)
       from tax.adjustment_rule_templates t
      where t.country = v_country and t.code = new.rule_code and t.formula is not null;
    new.amount := public.round_amount(new.amount, public.rounding_of(new.company_id));

  elsif tg_table_name = 'credits' then
    if not exists (
      select 1 from tax.credit_templates t where t.country = v_country and t.code = new.credit_code
    ) then
      raise exception 'unknown_tax_credit: % is not a credit the corporate tax rules of % carry', new.credit_code, v_country
        using errcode = '23503';
    end if;
    new.amount := public.round_amount(new.amount, public.rounding_of(new.company_id));
  end if;

  return new;
end;
$$;

comment on function tax.guard_declaration() is
  'Holds what a company declares to the codes its country pack carries — a parameter and its type, a rule, a credit — and to a financial year of its own, and writes every declared amount at the decimals of the company''s currency.';

create trigger tax_company_parameters_guard
  before insert or update on tax.company_parameters
  for each row execute function tax.guard_declaration();

create trigger tax_adjustments_guard
  before insert or update on tax.adjustments
  for each row execute function tax.guard_declaration();

create trigger tax_credits_guard
  before insert or update on tax.credits
  for each row execute function tax.guard_declaration();

create or replace function tax.guard_loss()
returns trigger
language plpgsql
as $$
begin
  new.amount := public.round_amount(new.amount, public.rounding_of(new.company_id));
  if tg_op = 'UPDATE'
     and (new.amount, new.origin_period_end, new.company_id)
         is distinct from (old.amount, old.origin_period_end, old.company_id)
     and exists (select 1 from tax.loss_uses u where u.loss_id = old.id) then
    raise exception 'loss_in_use: a final computation has set this loss against a profit. Withdraw that computation before changing the loss.'
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function tax.guard_loss() is
  'Writes a loss at the decimals of the company''s currency, and refuses to change the amount or the year of one a final computation has used.';

create trigger tax_losses_guard
  before insert or update on tax.losses
  for each row execute function tax.guard_loss();

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

create or replace function tax.accounts_in_use(p_company_id uuid)
returns setof uuid
language sql
stable
as $$
  select distinct a.account_id
    from tax.adjustments a
   where a.company_id = p_company_id and a.account_id is not null;
$$;

comment on function tax.accounts_in_use(uuid) is
  'The accounts this module points at for one company: every account it says falls under an adjustment rule. Read by public.accounts_in_use() through the module convention.';

create or replace function tax.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('company_parameters'::text, 'exported'::text, null::text, null::text, null::text, 1),
    ('adjustments',              'exported',       null,       null,       null,       2),
    ('credits',                  'exported',       null,       null,       null,       3),
    ('computations',             'exported',       null,       null,       null,       4),
    ('computation_lines',        'exported',       null,       null,       null,       5),
    ('losses',                   'exported',       null,       null,       null,       6),
    ('loss_uses',                'exported',       null,       null,       null,       7);
$$;

comment on function tax.archive_tables() is
  'What an archive of one company does with each table of this module: all seven travel. The seven reference tables belong to the installation and to no company. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Capabilities
--
-- The module's own words, with the module code as their area. Reading goes to
-- whoever reads the books, client included; writing to whoever keeps them;
-- and calling a computation final to the owner alone, because that is the
-- company saying what it owes.
-- ---------------------------------------------------------------------------

insert into public.capabilities (code, area, description) values
  ('tax.read',     'tax', 'Read the corporate income tax of a company: what it declared, its estimates and its final computations.'),
  ('tax.write',    'tax', 'Declare the parameters, adjustments, losses and credits the corporate income tax is computed from, and record an estimate.'),
  ('tax.finalize', 'tax', 'Call a computation of the corporate income tax final, or withdraw one. The company saying what it owes.')
on conflict (code) do update set area = excluded.area, description = excluded.description;

insert into public.role_capabilities (role, capability) values
  ('viewer'::public.member_role,     'tax.read'),
  ('accountant'::public.member_role, 'tax.read'),
  ('accountant'::public.member_role, 'tax.write'),
  ('owner'::public.member_role,      'tax.read'),
  ('owner'::public.member_role,      'tax.write'),
  ('owner'::public.member_role,      'tax.finalize')
on conflict do nothing;

-- The client preset holds what a viewer holds. Its label is read from the
-- catalogue rather than written as a literal, so this file applies on a socle
-- older than the preset.
insert into public.role_capabilities (role, capability)
select e.enumlabel::text::public.member_role, 'tax.read'
  from pg_catalog.pg_enum e
  join pg_catalog.pg_type t on t.oid = e.enumtypid
  join pg_catalog.pg_namespace n on n.oid = t.typnamespace
 where n.nspname = 'public' and t.typname = 'member_role' and e.enumlabel = 'client'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table tax.country_rules             enable row level security;
alter table tax.parameter_templates       enable row level security;
alter table tax.adjustment_rule_templates enable row level security;
alter table tax.rate_templates            enable row level security;
alter table tax.loss_rule_templates       enable row level security;
alter table tax.prepayment_templates      enable row level security;
alter table tax.credit_templates          enable row level security;
alter table tax.company_parameters        enable row level security;
alter table tax.adjustments               enable row level security;
alter table tax.credits                   enable row level security;
alter table tax.computations              enable row level security;
alter table tax.computation_lines         enable row level security;
alter table tax.losses                    enable row level security;
alter table tax.loss_uses                 enable row level security;

-- Reference data of the installation: a caller this installation knows.
create policy tax_country_rules_select on tax.country_rules
  for select using (public.is_known_caller());
create policy tax_parameter_templates_select on tax.parameter_templates
  for select using (public.is_known_caller());
create policy tax_adjustment_rule_templates_select on tax.adjustment_rule_templates
  for select using (public.is_known_caller());
create policy tax_rate_templates_select on tax.rate_templates
  for select using (public.is_known_caller());
create policy tax_loss_rule_templates_select on tax.loss_rule_templates
  for select using (public.is_known_caller());
create policy tax_prepayment_templates_select on tax.prepayment_templates
  for select using (public.is_known_caller());
create policy tax_credit_templates_select on tax.credit_templates
  for select using (public.is_known_caller());

-- What a company declares: read with tax.read, written with tax.write.
create policy tax_company_parameters_select on tax.company_parameters
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_company_parameters_write on tax.company_parameters
  for all using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  )
  with check (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  );

create policy tax_adjustments_select on tax.adjustments
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_adjustments_write on tax.adjustments
  for all using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  )
  with check (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  );

create policy tax_credits_select on tax.credits
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_credits_write on tax.credits
  for all using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  )
  with check (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
  );

-- A loss a company declares is its own to write. One a final computation
-- recorded is not: it carries that computation, and the policy stops there.
create policy tax_losses_select on tax.losses
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_losses_write on tax.losses
  for all using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
    and computation_id is null
  )
  with check (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.write')
    and computation_id is null
  );

-- What was computed is read and never written by hand: the three functions
-- above are the way in, and they are definer.
create policy tax_computations_select on tax.computations
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_computation_lines_select on tax.computation_lines
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );
create policy tax_loss_uses_select on tax.loss_uses
  for select using (
    public.module_enabled(company_id, 'tax')
    and public.has_capability(company_id, 'tax.read')
  );

-- ---------------------------------------------------------------------------
-- Privileges, by name
--
-- A module schema does its own grants: `public` gets them from Supabase and a
-- schema a migration created gets nothing. Each grant says what the policies
-- of its table are prepared to judge, and no default privilege is left behind.
-- ---------------------------------------------------------------------------

grant usage on schema tax to anon, authenticated, service_role;

grant select, insert, update, delete on table
  tax.company_parameters,
  tax.adjustments,
  tax.credits,
  tax.losses
to authenticated, service_role;

grant select on table
  tax.country_rules,
  tax.parameter_templates,
  tax.adjustment_rule_templates,
  tax.rate_templates,
  tax.loss_rule_templates,
  tax.prepayment_templates,
  tax.credit_templates,
  tax.computations,
  tax.computation_lines,
  tax.loss_uses
to authenticated, service_role;

revoke execute on function tax.in_force(date, date, tax.validity_basis, date, date) from public, anon;
revoke execute on function tax.account_matches(text, jsonb) from public, anon;
revoke execute on function tax.formula_percent(jsonb, jsonb) from public, anon;
revoke execute on function tax.condition_failure(jsonb, jsonb, numeric) from public, anon;
revoke execute on function tax.line(text, text, text, numeric, numeric, numeric, text, text) from public, anon;
revoke execute on function tax.loss_stock(uuid, date) from public, anon;
revoke execute on function tax.estimate(uuid, uuid, date) from public, anon;
revoke execute on function tax.record_computation(uuid, uuid, date) from public, anon;
revoke execute on function tax.finalise_computation(uuid) from public, anon;
revoke execute on function tax.withdraw_computation(uuid) from public, anon;
revoke execute on function tax.accounts_in_use(uuid) from public, anon;
revoke execute on function tax.archive_tables() from public, anon;

grant execute on function tax.in_force(date, date, tax.validity_basis, date, date) to authenticated, service_role;
grant execute on function tax.account_matches(text, jsonb) to authenticated, service_role;
grant execute on function tax.formula_percent(jsonb, jsonb) to authenticated, service_role;
grant execute on function tax.condition_failure(jsonb, jsonb, numeric) to authenticated, service_role;
grant execute on function tax.line(text, text, text, numeric, numeric, numeric, text, text) to authenticated, service_role;
grant execute on function tax.loss_stock(uuid, date) to authenticated, service_role;
grant execute on function tax.estimate(uuid, uuid, date) to authenticated, service_role;
grant execute on function tax.record_computation(uuid, uuid, date) to authenticated, service_role;
grant execute on function tax.finalise_computation(uuid) to authenticated, service_role;
grant execute on function tax.withdraw_computation(uuid) to authenticated, service_role;
grant execute on function tax.accounts_in_use(uuid) to authenticated, service_role;
grant execute on function tax.archive_tables() to authenticated, service_role;

-- The trigger bodies are fired by their tables and called by nobody.
revoke execute on function tax.guard_declaration() from public, anon, authenticated, service_role;
revoke execute on function tax.guard_loss() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

insert into public.modules (code, name, description, schema_name, version, status, requires_socle_min)
values (
  'tax',
  'Corporate income tax',
  'Corporate income tax estimated from the books: the accounting result, the adjustments, the losses, the rates and their conditions of a country are pack data, and what a company declares about itself is its own. Writes nothing to the ledger.',
  'tax',
  '1.0.0',
  'available',
  '20260922162500'
)
on conflict (code) do update set
  name               = excluded.name,
  description        = excluded.description,
  schema_name        = excluded.schema_name,
  version            = excluded.version,
  status             = excluded.status,
  requires_socle_min = excluded.requires_socle_min;
