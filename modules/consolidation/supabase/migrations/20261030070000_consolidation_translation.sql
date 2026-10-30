-- Ekwo — the `consolidation` module: the figures of a member kept in another
-- currency, translated into the group's.
--
-- A group presents its figures in one currency, and a member may keep its
-- books in another. Before anything is added up, each balance of such a member
-- is translated, by the closing rate method: what the member owns and owes at
-- the rate of the closing date, what it earned and spent at the average rate
-- of the period, its equity at the rate of the day it entered the group. The
-- three rates do not leave the translated balance at zero, and what remains is
-- the translation difference, a line of the group's equity of its own. This
-- file translates and adds nothing up: the consolidated statements read it.
--
-- **The rates are the group's.** Which rate closes a year, and which one is
-- the average of it, is a choice the group makes and documents — its source,
-- the central bank it follows — so each lives in the module's own table, typed
-- once per currency and period by whoever writes the group, and never guessed:
-- a rate that is missing refuses the translation by name, rather than letting
-- a figure come out at the wrong rate or at none. `ekwo.currency_rates` is not
-- read: it names no reference currency and the API writes nothing in it.
--
-- **A rate is written as the socle writes one.** Units of the member's
-- currency for one unit of the group's, as `documents.exchange_rate` holds
-- units of the document currency for one of the company's: the translated
-- amount is the balance divided by it.
--
-- **Read as the caller.** `require_readable()` first, then each member's trial
-- balance under its own row level security; nothing is written in a member.

create table consolidation.rates (
  id            uuid primary key default gen_random_uuid(),
  group_id      uuid not null,
  company_id    uuid not null references ekwo.companies(id) on delete cascade,
  currency_code char(3) not null references ekwo.currencies(code),
  period_from   date not null,
  period_to     date not null,
  closing_rate  numeric(18, 8) not null,
  average_rate  numeric(18, 8),
  source        text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (company_id, group_id, currency_code, period_to),
  foreign key (group_id, company_id) references consolidation.groups(id, company_id) on delete cascade,
  constraint consolidation_rates_period check (period_from <= period_to),
  constraint consolidation_rates_positive check (closing_rate > 0 and (average_rate is null or average_rate > 0))
);

comment on table consolidation.rates is
  'The rates a group translates a currency at, one row per currency and period: the closing rate of its last day, and the average rate of the period. Units of that currency for one unit of the group''s currency.';
comment on column consolidation.rates.closing_rate is
  'The rate on period_to: what a member owns and owes is translated at it on that date, and its equity at the closing rate of the last period ending on or before the day it entered the group.';
comment on column consolidation.rates.average_rate is
  'The average rate from period_from to period_to: what a member earned and spent over exactly that period is translated at it. Null for a row kept only for its closing rate.';
comment on column consolidation.rates.source is
  'Where the group took the rates from — a central bank, a published series — so that the figure can be traced.';

create index consolidation_rates_group_company_idx on consolidation.rates (group_id, company_id);
create index consolidation_rates_currency_idx on consolidation.rates (currency_code);

create trigger consolidation_rates_set_updated_at
  before update on consolidation.rates
  for each row execute function ekwo.set_updated_at();

-- ---------------------------------------------------------------------------
-- Writing a rate
-- ---------------------------------------------------------------------------

create or replace function consolidation.set_rate(
  p_company_id    uuid,
  p_group_id      uuid,
  p_currency_code char(3),
  p_period_from   date,
  p_period_to     date,
  p_closing_rate  numeric,
  p_average_rate  numeric default null,
  p_source        text default null
)
returns consolidation.rates
language plpgsql
set search_path = consolidation, ekwo, pg_temp
as $$
declare
  v_group consolidation.groups;
  v_rate  consolidation.rates;
begin
  perform consolidation.require(p_company_id, 'consolidation.write', 'setting a rate of a group');

  select * into v_group from consolidation.groups g where g.id = p_group_id and g.company_id = p_company_id;
  if not found then
    raise exception 'consolidation_group_not_found: no group % in company %', p_group_id, p_company_id
      using errcode = 'P0002';
  end if;
  if p_currency_code = v_group.currency_code then
    raise exception 'consolidation_rate_of_the_group_currency: % is the currency of the group, which is never translated', p_currency_code
      using errcode = '22023';
  end if;

  insert into consolidation.rates
    (group_id, company_id, currency_code, period_from, period_to, closing_rate, average_rate, source)
  values
    (p_group_id, p_company_id, p_currency_code, p_period_from, p_period_to, p_closing_rate, p_average_rate, p_source)
  on conflict (company_id, group_id, currency_code, period_to) do update set
    period_from  = excluded.period_from,
    closing_rate = excluded.closing_rate,
    average_rate = excluded.average_rate,
    source       = excluded.source
  returning * into v_rate;

  return v_rate;
end;
$$;

comment on function consolidation.set_rate(uuid, uuid, char, date, date, numeric, numeric, text) is
  'Sets the rates a group translates a currency at for a period: the closing rate of its last day and, when given, the average rate of the period, in units of that currency for one unit of the group''s. The same currency and last day again replaces the row: a rate is corrected, never doubled.';

-- ---------------------------------------------------------------------------
-- The balances of every company of the group, in the group's currency
-- ---------------------------------------------------------------------------

create or replace function consolidation.translated_balances(
  p_company_id uuid,
  p_group_id   uuid,
  p_from       date,
  p_to         date
)
returns table (
  company_id       uuid,
  company_name     text,
  currency_code    char(3),
  account_code     text,
  account_name     text,
  account_type     ekwo.account_type,
  balance          numeric,
  rate_kind        text,
  rate             numeric,
  translated       numeric,
  integration_rate numeric,
  integrated       numeric
)
language plpgsql
stable
set search_path = consolidation, ekwo, pg_temp
as $$
declare
  v_group    consolidation.groups;
  v_rounding ekwo.money_rounding;
  v_company  record;
  v_closing  numeric;
  v_average  numeric;
  v_entry    numeric;
  v_rate_on  date;
begin
  perform consolidation.require(p_company_id, 'consolidation.read', 'translating the figures of a group');
  select * into v_group from consolidation.groups g where g.id = p_group_id and g.company_id = p_company_id;
  if not found then
    raise exception 'consolidation_group_not_found: no group % in company %', p_group_id, p_company_id
      using errcode = 'P0002';
  end if;
  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'consolidation_period_invalid: a period runs from a first day to a last day on or after it'
      using errcode = '22023';
  end if;
  perform consolidation.require_readable(p_company_id, p_group_id, p_from, p_to);

  v_rounding := ekwo.rounding_of(p_company_id, v_group.currency_code);

  for v_company in
    select p.id, p.name, p.currency_code, 100::numeric as integration_rate, null::date as entered_on
      from ekwo.companies p
     where p.id = p_company_id
    union all
    select m.member_company_id, c.name, c.currency_code, m.integration_rate, m.entered_on
      from consolidation.members m
      join ekwo.companies c on c.id = m.member_company_id
     where m.group_id = p_group_id
       and m.company_id = p_company_id
       and m.entered_on <= p_to
       and (m.left_on is null or m.left_on >= p_from)
     order by 5 nulls first, 2, 1
  loop
    v_closing := 1;
    v_average := 1;
    v_entry   := 1;

    if v_company.currency_code <> v_group.currency_code then
      select r.closing_rate into v_closing
        from consolidation.rates r
       where r.group_id = p_group_id and r.company_id = p_company_id
         and r.currency_code = v_company.currency_code
         and r.period_to = p_to;
      if v_closing is null then
        raise exception 'consolidation_rate_missing: no closing rate of % on % in this group, which % keeps its books in; set_rate() first',
          v_company.currency_code, p_to, v_company.name
          using errcode = 'P0002';
      end if;

      select r.average_rate into v_average
        from consolidation.rates r
       where r.group_id = p_group_id and r.company_id = p_company_id
         and r.currency_code = v_company.currency_code
         and r.period_from = p_from and r.period_to = p_to;
      if v_average is null then
        raise exception 'consolidation_rate_missing: no average rate of % from % to % in this group, which % keeps its books in; set_rate() first',
          v_company.currency_code, p_from, p_to, v_company.name
          using errcode = 'P0002';
      end if;

      -- Equity stays at the rate of the day the company came in: the closing
      -- rate of the last period that ended on that day or before it.
      v_rate_on := coalesce(v_company.entered_on, p_from);
      select r.closing_rate into v_entry
        from consolidation.rates r
       where r.group_id = p_group_id and r.company_id = p_company_id
         and r.currency_code = v_company.currency_code
         and r.period_to <= v_rate_on
       order by r.period_to desc
       limit 1;
      if v_entry is null then
        raise exception 'consolidation_rate_missing: no closing rate of % on or before %, the day % came into this group, for its equity; set_rate() first',
          v_company.currency_code, v_rate_on, v_company.name
          using errcode = 'P0002';
      end if;
    end if;

    return query
      with balances as (
        select t.account_code,
               t.account_name,
               t.account_type,
               case
                 when t.account_type::text like 'income%' or t.account_type::text like 'expense%'
                   then t.debit - t.credit
                 else t.closing_balance
               end as balance,
               case
                 when v_company.currency_code = v_group.currency_code then 'none'
                 when t.account_type::text like 'income%' or t.account_type::text like 'expense%' then 'average'
                 when t.account_type::text like 'equity%' then 'entry'
                 else 'closing'
               end as rate_kind
          from ekwo.trial_balance(v_company.id, p_from, p_to) t
         where t.account_type <> 'off_balance'
      ),
      rated as (
        select b.*,
               case b.rate_kind
                 when 'average' then v_average
                 when 'entry' then v_entry
                 when 'closing' then v_closing
                 else 1
               end as rate
          from balances b
         where b.balance <> 0
      ),
      translated as (
        select r.*,
               ekwo.round_amount(r.balance / r.rate, v_rounding) as translated
          from rated r
      ),
      lines as (
        select t.account_code, t.account_name, t.account_type, t.balance, t.rate_kind, t.rate, t.translated,
               ekwo.round_amount(t.translated * v_company.integration_rate / 100, v_rounding) as integrated
          from translated t
      )
      select v_company.id, v_company.name, v_company.currency_code,
             l.account_code, l.account_name, l.account_type, l.balance, l.rate_kind, l.rate,
             l.translated, v_company.integration_rate, l.integrated
        from lines l
      union all
      -- What the three rates leave over, in the group's equity: the line that
      -- brings the translated balance of the company back to zero.
      select v_company.id, v_company.name, v_company.currency_code,
             null, null, 'equity'::ekwo.account_type, 0::numeric, 'translation_difference', null::numeric,
             -sum(l.translated), v_company.integration_rate, -sum(l.integrated)
        from lines l
       where v_company.currency_code <> v_group.currency_code
      having sum(l.translated) <> 0 or sum(l.integrated) <> 0
      order by 4 nulls last;
  end loop;
end;
$$;

comment on function consolidation.translated_balances(uuid, uuid, date, date) is
  'The balance of every account of the parent and of each member in the group between two dates, translated into the group''s currency by the closing rate method: assets and liabilities at the closing rate of p_to, income and expenses of the period at its average rate, equity at the closing rate of the day the company entered the group — then taken in at its integration rate. A company in another currency ends with its translation difference, the line of equity that brings its translated balance back to zero. A rate the group has not set refuses by name.';

-- ---------------------------------------------------------------------------
-- The archive, the rights, the privileges
-- ---------------------------------------------------------------------------

create or replace function consolidation.archive_tables()
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
set search_path = consolidation, ekwo, pg_temp
as $$
  values
    ('groups'::text, 'exported'::text, null::text, null::text, null::text, 1),
    ('members',      'excluded',
     'each row names another company of this installation by its id, which means nothing where the archive arrives; the perimeter is declared again there, once the companies it holds are there too',
     null, null, 2),
    ('rates',        'exported', null, null, null, 3);
$$;

comment on function consolidation.archive_tables() is
  'What an archive of one company does with each table of this module: its groups and the rates they translate at travel, their members do not — they name other companies of the installation. Read by `ekwo.company_archive_tables()`.';

alter table consolidation.rates enable row level security;

create policy consolidation_rates_select on consolidation.rates
  for select using (ekwo.module_enabled(company_id, 'consolidation') and ekwo.has_capability(company_id, 'consolidation.read'));
create policy consolidation_rates_write on consolidation.rates
  for all using (ekwo.module_enabled(company_id, 'consolidation') and ekwo.has_capability(company_id, 'consolidation.write'))
  with check (ekwo.module_enabled(company_id, 'consolidation') and ekwo.has_capability(company_id, 'consolidation.write'));

grant select, insert, update, delete on table consolidation.rates to authenticated, service_role;

revoke execute on function consolidation.set_rate(uuid, uuid, char, date, date, numeric, numeric, text) from public, anon;
revoke execute on function consolidation.translated_balances(uuid, uuid, date, date) from public, anon;
grant execute on function consolidation.set_rate(uuid, uuid, char, date, date, numeric, numeric, text) to authenticated, service_role;
grant execute on function consolidation.translated_balances(uuid, uuid, date, date) to authenticated, service_role;
