-- Ekwo OS — an analysis for every country.
--
-- `20261014152111` gave the sixteen aggregates of an analysis a name and left
-- their accounts to the country pack, so a company whose pack carries no
-- `analysis.json` got no row at all. Most packs carry none, and their
-- companies opened an Analysis screen with nothing on it.
--
-- Most of the sixteen do not need a chart to be read. Every account carries
-- one of the eighteen account types, and the generic framework already builds
-- a balance sheet and an income statement out of those types alone, for any
-- chart of any country (`packs/generic/statements.json`). The revenue is the
-- `income` accounts, the cash the `asset_cash` accounts, the total assets
-- every asset type: thirteen aggregates are a sum of account types. Three are
-- not — the staff costs, the financial result and the tax on the result sit
-- inside `expense` and `income_other` with everything else — so the framework
-- leaves them out, and a company read through it gets no row for them rather
-- than a zero that would look like a figure.
--
-- This migration lets the framework pack say so, on the model of
-- `statement_templates`, which has held framework rows since `20260912100412`:
--
--   `analysis_templates` and `analysis_rules` — a row belongs either to a
--       country and one of its charts, as before, or to a framework, with no
--       country and no chart and the framework's code in `framework`. The
--       country seeds keep their key `(country, chart_code, aggregate)` and
--       keep upserting on it; the framework seed upserts on
--       `(framework, aggregate)`. A framework's rules are account types only:
--       it has no chart for a code to mean anything in.
--
--   `financial_analysis(company, from, to)` — reads the country pack's rows
--       when the company's chart has any; otherwise the rows of a framework:
--       the one whose statements the chart declares, else the framework the
--       installation carries, as `default_statement_code()` falls back to the
--       generic statements. A fourth column, `source`, says which: `pack` or
--       `framework`, the same on every row of one call, so a screen can say
--       that a figure was read by account type rather than by the chart.
--       The framework is found through the tables and never named here.
--
-- The return type gains a column, which `create or replace` cannot do, so the
-- function is dropped and created again with its comment and its grants.

-- ---------------------------------------------------------------------------
-- analysis_templates — a country's chart, or a framework
-- ---------------------------------------------------------------------------

-- The primary keys cannot hold a null country, so they become unique
-- constraints on the same columns. The country seeds' `on conflict (country,
-- chart_code, aggregate)` still finds its arbiter; the foreign key from the
-- rules is dropped first because it leans on the primary key's index.
alter table analysis_rules drop constraint analysis_rules_country_chart_code_aggregate_fkey;
alter table analysis_rules drop constraint analysis_rules_pkey;
alter table analysis_templates drop constraint analysis_templates_pkey;

alter table analysis_templates
  alter column country drop not null,
  alter column chart_code drop not null,
  add column framework text;

alter table analysis_templates drop constraint analysis_templates_country_format;
alter table analysis_templates
  add constraint analysis_templates_country_format check (country is null or country ~ '^[A-Z]{2}$'),
  -- A row is a chart's or a framework's, never both and never neither.
  add constraint analysis_templates_pack_or_framework check (
    case when country is null then chart_code is null and framework is not null
         else chart_code is not null and framework is null
    end
  ),
  add constraint analysis_templates_pack_key unique (country, chart_code, aggregate),
  -- Not partial, so the rules can reference it: a country row has no
  -- framework, and two nulls never collide.
  add constraint analysis_templates_framework_key unique (framework, aggregate);

comment on column analysis_templates.country is
  'The country of the pack this reading of a chart comes from. Null on a framework''s row, which reads account types and fits any chart of any country.';
comment on column analysis_templates.chart_code is
  'The chart the rules are written for. Null on a framework''s row.';
comment on column analysis_templates.framework is
  'The framework this row belongs to, as its pack names it — the code statement_templates.framework carries for the same framework. Null on a country''s row.';
comment on table analysis_templates is
  'The aggregates a pack defines for one of its charts, or a framework for any chart, and where that reading comes from. Written by the seed of a pack that carries analysis.json; financial_analysis() reads the country''s rows when the company''s chart has any, and a framework''s otherwise.';

-- ---------------------------------------------------------------------------
-- analysis_rules — the same two owners
-- ---------------------------------------------------------------------------

alter table analysis_rules
  alter column country drop not null,
  alter column chart_code drop not null,
  add column framework text;

alter table analysis_rules
  add constraint analysis_rules_country_format check (country is null or country ~ '^[A-Z]{2}$'),
  add constraint analysis_rules_pack_or_framework check (
    case when country is null then chart_code is null and framework is not null
         else chart_code is not null and framework is null
    end
  ),
  -- A framework has no chart, so a code means nothing to it.
  add constraint analysis_rules_framework_by_type check (country is not null or rule_kind = 'account_type'),
  add constraint analysis_rules_pack_key unique (country, chart_code, aggregate, sequence),
  add constraint analysis_rules_framework_key unique (framework, aggregate, sequence),
  add constraint analysis_rules_pack_template
    foreign key (country, chart_code, aggregate)
    references analysis_templates (country, chart_code, aggregate) on delete cascade,
  add constraint analysis_rules_framework_template
    foreign key (framework, aggregate)
    references analysis_templates (framework, aggregate) on delete cascade;

comment on column analysis_rules.framework is
  'The framework the rule belongs to; null on a country''s rule. A framework''s rules are account_type rules only.';

-- ---------------------------------------------------------------------------
-- financial_analysis — the pack's reading, else the framework's
-- ---------------------------------------------------------------------------

drop function financial_analysis(uuid, date, date);

create function financial_analysis(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  aggregate text,
  amount    numeric,
  accounts  jsonb,
  source    text
)
language plpgsql
stable
security invoker
as $$
#variable_conflict use_column
declare
  v_country   char(2);
  v_chart     text;
  v_framework text;
  v_source    text;
  -- The aggregates are the ledger read back, so they are written with the
  -- decimals of the currency the ledger is kept in.
  v_round     money_rounding;
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

  -- Whose reading: the country pack's for this chart when it wrote one, else
  -- a framework's. Among the frameworks, the one whose statements the chart
  -- declares comes first, then the others by code — the order
  -- `default_statement_code()` gives the statements of a framework.
  if exists (select 1 from analysis_templates t
              where t.country = v_country and t.chart_code = v_chart) then
    v_source := 'pack';
  else
    v_source := 'framework';
    select t.framework
      into v_framework
      from analysis_templates t
     where t.country is null
     group by t.framework
     order by bool_or(exists (
                select 1
                  from chart_templates ch
                  join statement_templates s on s.code = any (ch.statements)
                 where ch.country = v_country
                   and ch.code = v_chart
                   and s.country is null
                   and s.framework = t.framework)) desc,
              t.framework
     limit 1;
  end if;

  return query
    with templates as (
      select t.aggregate, g.reading, g.sign, g.adds_unclosed_result, g.sequence
        from analysis_templates t
        join analysis_aggregates g on g.code = t.aggregate
       where case v_source
               when 'pack' then t.country = v_country and t.chart_code = v_chart
               else t.country is null and t.framework = v_framework
             end
    ),
    rules as (
      select r.aggregate, r.rule_kind, r.code_from, r.code_to, r.account_type, r.balance_side
        from analysis_rules r
       where case v_source
               when 'pack' then r.country = v_country and r.chart_code = v_chart
               else r.country is null and r.framework = v_framework
             end
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
         select 1 from rules r
          where r.aggregate = x.aggregate
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
                    '[]'::jsonb),
           v_source
      from templates t
      left join by_account b on b.aggregate = t.aggregate
     group by t.aggregate, t.sequence
     order by t.sequence;
end;
$$;

comment on function financial_analysis(uuid, date, date) is
  'The aggregates of a company over a period, in the order of analysis_aggregates: the amount in the company currency, signed as the aggregate is named, the accounts that make it as [{code, name, amount}], each amount with that same sign, and source. source is pack when the company''s country pack defines an analysis for its chart, and the rows are the ones it defines; framework otherwise, and the rows are those a framework reads by account type — the framework whose statements the chart declares, else the one the installation carries — which leaves out the aggregates no account type tells apart. Movements are read from p_from to p_to, less the closing entries; balances at p_to. equity adds the result no close has moved yet, on the account year_result_account() names (code and name null where the pack names none). No row when neither the pack nor a framework defines an analysis. Security invoker: entries.read, and the caller''s own rights on the ledger.';

revoke execute on function financial_analysis(uuid, date, date) from public, anon;
grant execute on function financial_analysis(uuid, date, date) to authenticated, service_role;
