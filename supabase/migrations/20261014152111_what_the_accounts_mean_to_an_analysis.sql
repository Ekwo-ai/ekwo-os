-- Ekwo OS — what the accounts of a pack mean to an analysis of the books.
--
-- A financial statement knows its national lines and nothing else: rubric
-- `21/28` of one country's balance sheet, line `CO` of another's. A ratio —
-- a net margin, a current ratio, the days a company takes to be paid — needs
-- the same figure in every country, so a screen that draws one had nothing to
-- read it from but the codes of a chart, which is the one thing the core is
-- not allowed to know.
--
-- This migration gives the figure a name and leaves its accounts to the pack.
--
--   `analysis_aggregates` — the closed list, written here because it is
--       vocabulary and not law: sixteen aggregates, each with how it is read
--       (the movements of a period, or the balance at its end) and the sign
--       it comes back with, so that every pack reads `revenue` the same way
--       up. No country is named and no account: a row says "revenue is read
--       on the movements, and positive when earned", which is true anywhere.
--
--   `analysis_templates` and `analysis_rules` — filled by the seed of a pack
--       that carries `analysis.json`, per chart: the accounts that make each
--       aggregate, by the rules a statement line already uses — a code, a
--       range or a head of code, an account type, and a side — and the text
--       that reading of the chart comes from.
--
--   `financial_analysis(company, from, to)` — one row per aggregate the
--       company's pack defines, the amount in the company's currency and the
--       accounts that make it.
--
-- A company whose pack carries no section gets no row. That is the answer,
-- not a gap to fill: an aggregate read on another country's chart would be a
-- figure, plausible and wrong.
--
-- **The rule predicate is spelled once.** A rule of an aggregate takes an
-- account exactly when the same rule on a statement line would. The test
-- `statement_rule_catches()` made is moved, word for word, into
-- `account_rule_catches()`, which takes the parts of a rule rather than a row
-- of `statement_line_rules`, and `statement_rule_catches()` is republished as
-- a call to it. Two copies of that test would one day disagree about which
-- accounts are the equity.
--
-- **Equity takes the result nobody has closed.** Until a year is closed its
-- result stands on the income and expense accounts, and the equity accounts
-- of a chart hold none of it. `equity` therefore adds, as its balance sheet
-- does since `20261011081256`, the balance at the end of the period of every
-- income and expense account its rules do not catch — the result of every
-- earlier year not closed and of the year in progress — on the account
-- `year_result_account()` names, the one the close would leave it on. After a
-- close those accounts are nil and nothing is added. With the books balanced,
-- `total_assets` is then `equity` plus everything else the balance sheet
-- holds, to the cent.

-- ---------------------------------------------------------------------------
-- account_rule_catches — whether one rule takes one account
-- ---------------------------------------------------------------------------

create or replace function account_rule_catches(
  p_rule_kind    text,
  p_code_from    text,
  p_code_to      text,
  p_rule_type    account_type,
  p_side         text,
  p_code         text,
  p_account_type account_type,
  p_balance      numeric
)
returns boolean
language sql
immutable
as $$
  select case p_rule_kind
           when 'account_code' then p_code = p_code_from
           when 'code_prefix'  then left(p_code, length(p_code_from)) = p_code_from
           when 'code_range'   then left(p_code, length(p_code_from)) >= p_code_from
                                and left(p_code, length(p_code_to))   <= p_code_to
           else                     p_account_type = p_rule_type
         end
     and case p_side
           when 'debit'  then p_balance > 0
           when 'credit' then p_balance < 0
           else               true
         end;
$$;

comment on function account_rule_catches(text, text, text, account_type, text, text, account_type, numeric) is
  'Whether a rule takes an account with this code, type and balance: by one code, by the head of the code, by a range of heads or by account type, on the side the rule names. The one spelling of that test, read through statement_rule_catches() by the statements and directly by financial_analysis().';

create or replace function statement_rule_catches(
  p_rule         statement_line_rules,
  p_code         text,
  p_account_type account_type,
  p_balance      numeric
)
returns boolean
language sql
immutable
as $$
  select account_rule_catches(p_rule.rule_kind, p_rule.code_from, p_rule.code_to, p_rule.account_type,
                              p_rule.balance_side, p_code, p_account_type, p_balance);
$$;

comment on function statement_rule_catches(statement_line_rules, text, account_type, numeric) is
  'Whether a rule of a statement line takes an account with this code, type and balance. A call to account_rule_catches(), so a statement and an analysis read a rule the same way; read by statement_account_matches().';

-- ---------------------------------------------------------------------------
-- analysis_aggregates — the closed list
-- ---------------------------------------------------------------------------

create table analysis_aggregates (
  code                 text primary key,
  reading              text not null,
  sign                 smallint not null,
  adds_unclosed_result boolean not null default false,
  sequence             integer not null,
  description          text not null,
  constraint analysis_aggregates_reading check (reading in ('movements', 'closing')),
  constraint analysis_aggregates_sign check (sign in (1, -1)),
  constraint analysis_aggregates_unclosed_on_a_balance check (not adds_unclosed_result or reading = 'closing')
);

comment on table analysis_aggregates is
  'The aggregates an analysis of the books is computed from, and how each is read. Vocabulary of the core, the same in every country; the accounts that make each one are a pack''s, in analysis_rules.';
comment on column analysis_aggregates.reading is
  'movements: what the period added, posted entries dated inside it, less the entries close_fiscal_year() marks closing — as an income statement reads. closing: the balance at the end of the period, every posted entry up to it — as a balance sheet reads.';
comment on column analysis_aggregates.sign is
  'Multiplies the debit-minus-credit balance so the aggregate reads as its name says: 1 where a debit is the figure (an asset, a charge), -1 where a credit is (revenue, equity, a debt, a profit).';
comment on column analysis_aggregates.adds_unclosed_result is
  'Whether the aggregate also takes the result nobody has closed: the balance of every income and expense account its rules do not catch, on the account year_result_account() names. True of equity alone.';

insert into analysis_aggregates (code, reading, sign, adds_unclosed_result, sequence, description) values
  ('revenue',                'movements', -1, false,  10, 'Revenue: what the company sold in the period. Positive when earned.'),
  ('other_operating_income', 'movements', -1, false,  20, 'Other operating income: production stored or capitalised, operating subsidies and other income of the activity. Positive.'),
  ('purchases',              'movements',  1, false,  30, 'Purchases and external charges, with the change in stock. Positive.'),
  ('staff_costs',            'movements',  1, false,  40, 'Staff costs: wages, social charges and pensions. Positive.'),
  ('depreciation',           'movements',  1, false,  50, 'Depreciation, impairment and provisions charged in the period. Positive.'),
  ('financial_result',       'movements', -1, false,  60, 'Financial income less financial charges. Positive when a gain.'),
  ('income_tax',             'movements',  1, false,  70, 'Tax on the result. Positive when a charge.'),
  ('net_result',             'movements', -1, false,  80, 'The result of the period: income less expense. Positive when a profit.'),
  ('equity',                 'closing',   -1, true,   90, 'Equity at the end of the period, with the result of every year not closed yet. Positive.'),
  ('total_assets',           'closing',    1, false, 100, 'Total assets at the end of the period. Positive.'),
  ('current_assets',         'closing',    1, false, 110, 'Current assets at the end of the period: stocks, receivables within a year, investments and cash. Positive.'),
  ('cash',                   'closing',    1, false, 120, 'Cash at bank and in hand at the end of the period. Positive.'),
  ('trade_receivables',      'closing',    1, false, 130, 'What customers owe at the end of the period. Positive.'),
  ('current_liabilities',    'closing',   -1, false, 140, 'Debts due within a year at the end of the period. Positive.'),
  ('trade_payables',         'closing',   -1, false, 150, 'What is owed to suppliers at the end of the period. Positive.'),
  ('long_term_debt',         'closing',   -1, false, 160, 'Debts due after more than a year at the end of the period. Positive.');

-- ---------------------------------------------------------------------------
-- analysis_templates and analysis_rules — the accounts, per pack and chart
-- ---------------------------------------------------------------------------

create table analysis_templates (
  country         char(2) not null,
  chart_code      text not null,
  aggregate       text not null references analysis_aggregates (code),
  legal_reference text not null,
  source_key      text,
  primary key (country, chart_code, aggregate),
  foreign key (country, chart_code) references chart_templates (country, code) on delete cascade,
  constraint analysis_templates_country_format check (country ~ '^[A-Z]{2}$')
);

create index analysis_templates_aggregate_idx on analysis_templates (aggregate);

comment on table analysis_templates is
  'The aggregates a pack defines for one of its charts, and where that reading of the chart comes from. Written by the seed of a pack that carries analysis.json; a chart with no row has no analysis, and financial_analysis() returns nothing for its companies.';
comment on column analysis_templates.legal_reference is
  'The classes of the chart or the rubric of the statement the aggregate mirrors, cited as the country cites them.';
comment on column analysis_templates.source_key is
  'Key of the entry of the pack''s source register where that reference can be read.';

create table analysis_rules (
  country      char(2) not null,
  chart_code   text not null,
  aggregate    text not null,
  sequence     integer not null default 10,
  rule_kind    text not null,
  code_from    text,
  code_to      text,
  account_type account_type,
  balance_side text not null default 'any',
  primary key (country, chart_code, aggregate, sequence),
  foreign key (country, chart_code, aggregate)
    references analysis_templates (country, chart_code, aggregate) on delete cascade,
  constraint analysis_rules_kind check (
    rule_kind in ('account_code', 'code_range', 'code_prefix', 'account_type')
  ),
  constraint analysis_rules_side check (balance_side in ('debit', 'credit', 'any')),
  constraint analysis_rules_arguments check (
    case rule_kind
      when 'account_type' then account_type is not null and code_from is null and code_to is null
      when 'code_range'   then code_from is not null and code_to is not null and account_type is null
      else                     code_from is not null and code_to is null and account_type is null
    end
  )
);

comment on table analysis_rules is
  'How an account of a company reaches an aggregate: the rules of a statement line, with the same columns and the same test, account_rule_catches(). An account reaches an aggregate once, whatever the number of its rules that take it; two aggregates may take the same account — cash is part of the current assets, which are part of the total.';
comment on column analysis_rules.balance_side is
  'Which side of the account the aggregate takes, read on the balance the aggregate reads: `debit` and `credit` split an account the balance sheet itself splits — a bank account in debit is cash, in credit a debt.';

-- ---------------------------------------------------------------------------
-- Row level security
--
-- Reference data, like the statement schemes: readable by a caller this
-- installation knows, written by the seed alone.
-- ---------------------------------------------------------------------------

alter table analysis_aggregates enable row level security;
alter table analysis_templates  enable row level security;
alter table analysis_rules      enable row level security;

create policy analysis_aggregates_select on analysis_aggregates
  for select using (is_known_caller());
create policy analysis_templates_select on analysis_templates
  for select using (is_known_caller());
create policy analysis_rules_select on analysis_rules
  for select using (is_known_caller());

comment on policy analysis_aggregates_select on analysis_aggregates is
  'Reference data, readable by a signed-in user or a machine key. No write policy: the list is the core''s.';
comment on policy analysis_templates_select on analysis_templates is
  'Reference data, readable by a signed-in user or a machine key. No write policy: an aggregate comes from a pack.';
comment on policy analysis_rules_select on analysis_rules is
  'Reference data, readable by a signed-in user or a machine key. No write policy: a rule comes from a pack.';

-- ---------------------------------------------------------------------------
-- financial_analysis — the aggregates of a company, and their accounts
-- ---------------------------------------------------------------------------

create or replace function financial_analysis(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  aggregate text,
  amount    numeric,
  accounts  jsonb
)
language plpgsql
stable
security invoker
as $$
#variable_conflict use_column
declare
  v_country char(2);
  v_chart   text;
  -- The aggregates are the ledger read back, so they are written with the
  -- decimals of the currency the ledger is kept in.
  v_round   money_rounding;
begin
  -- The chart the company keeps its books on, resolved as
  -- `available_statements()` resolves it: the chart its pack was installed
  -- with, or the default chart of its country.
  select c.fiscal_country,
         coalesce(
           (select p.chart_code from company_packs p
             where p.company_id = c.id and p.country = c.fiscal_country),
           (select ch.code from chart_templates ch
             where ch.country = c.fiscal_country and ch.is_default))
    into v_country, v_chart
    from companies c
   where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  if not is_installer() and not coalesce(has_capability(p_company_id, 'entries.read'), false) then
    raise exception 'not_allowed: reading the financial analysis of this company needs entries.read'
      using errcode = '42501';
  end if;

  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'invalid_period: an analysis reads a period from its first day to its last, and % to % is not one',
      coalesce(p_from::text, 'nothing'), coalesce(p_to::text, 'nothing')
      using errcode = '22023';
  end if;

  v_round := rounding_of(p_company_id);

  return query
    with templates as (
      select t.aggregate, g.reading, g.sign, g.adds_unclosed_result, g.sequence
        from analysis_templates t
        join analysis_aggregates g on g.code = t.aggregate
       where t.country = v_country
         and t.chart_code = v_chart
    ),
    -- Each account once, read both ways. The movements leave out the entry
    -- that closes a year, which books the mirror image of every income and
    -- expense account: left in, a closed year would read as having earned
    -- nothing. The balance at the end keeps it, because it is what moves the
    -- result into equity.
    ledger as (
      select a.id, a.code, a.name, a.account_type, a.carries_forward,
             round_amount(coalesce(sum(l.balance) filter (where e.entry_date >= p_from
                                                            and e.kind <> 'closing'), 0),
                          v_round) as movement,
             round_amount(coalesce(sum(l.balance), 0), v_round) as closing
        from accounts a
        join entry_lines l on l.account_id = a.id
        join entries e on e.id = l.entry_id
       where a.company_id = p_company_id
         and e.state = 'posted'
         and e.entry_date <= p_to
       group by a.id, a.code, a.name, a.account_type, a.carries_forward
    ),
    readings as (
      select t.aggregate, t.sign, t.adds_unclosed_result,
             b.id, b.code, b.name, b.account_type, b.carries_forward,
             case t.reading when 'movements' then b.movement else b.closing end as balance
        from templates t
        cross join ledger b
    ),
    caught as (
      select x.aggregate, x.id, x.code, x.name, x.balance * x.sign as amount
        from readings x
       where exists (
         select 1 from analysis_rules r
          where r.country = v_country
            and r.chart_code = v_chart
            and r.aggregate = x.aggregate
            and account_rule_catches(r.rule_kind, r.code_from, r.code_to, r.account_type,
                                     r.balance_side, x.code, x.account_type, x.balance))
    ),
    -- The result nobody has closed, for the aggregate that takes it: every
    -- income and expense account its rules leave out, at the end of the
    -- period, as one balance on the account the close would leave it on.
    unclosed as (
      select x.aggregate, x.sign, sum(x.balance) as balance
        from readings x
       where x.adds_unclosed_result
         and not x.carries_forward
         and not exists (select 1 from caught c where c.aggregate = x.aggregate and c.id = x.id)
       group by x.aggregate, x.sign
      having sum(x.balance) <> 0
    ),
    parts as (
      select c.aggregate, c.id, c.code, c.name, c.amount from caught c
      union all
      select u.aggregate, a.id, a.code, a.name, u.balance * u.sign
        from unclosed u
        left join accounts a on a.id = year_result_account(p_company_id, u.balance)
    ),
    by_account as (
      select p.aggregate, p.code, p.name, round_amount(sum(p.amount), v_round) as amount
        from parts p
       group by p.aggregate, p.id, p.code, p.name
    )
    select t.aggregate,
           round_amount(coalesce(sum(b.amount), 0), v_round),
           coalesce(jsonb_agg(jsonb_build_object('code', b.code, 'name', b.name, 'amount', b.amount)
                              order by b.code) filter (where b.amount <> 0),
                    '[]'::jsonb)
      from templates t
      left join by_account b on b.aggregate = t.aggregate
     group by t.aggregate, t.sequence
     order by t.sequence;
end;
$$;

comment on function financial_analysis(uuid, date, date) is
  'The aggregates of a company over a period, one row per aggregate its pack defines for its chart, in the order of analysis_aggregates: the amount in the company currency, signed as the aggregate is named, and the accounts that make it as [{code, name, amount}], each amount with that same sign. Movements are read from p_from to p_to, less the closing entries; balances at p_to. equity adds the result no close has moved yet, on the account year_result_account() names (code and name null where the pack names none). No row for a company whose pack defines no analysis. Security invoker: entries.read, and the caller''s own rights on the ledger.';

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

grant select on table analysis_aggregates, analysis_templates, analysis_rules to authenticated, service_role;

revoke execute on function account_rule_catches(text, text, text, account_type, text, text, account_type, numeric) from public, anon;
grant execute on function account_rule_catches(text, text, text, account_type, text, text, account_type, numeric) to authenticated, service_role;

revoke execute on function financial_analysis(uuid, date, date) from public, anon;
grant execute on function financial_analysis(uuid, date, date) to authenticated, service_role;
