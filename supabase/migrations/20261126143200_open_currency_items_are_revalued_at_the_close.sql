-- Ekwo OS — what is still open in a foreign currency is revalued at the close.
--
-- Since `20260912112132` a document or a payment in a foreign currency is
-- booked in the company's currency at its own rate, with the amount in the
-- foreign currency beside it, and a matching realises the exchange difference
-- (decision 0021). Until the item is settled, nothing moves it: a receivable
-- of 1 000 USD booked at 909,09 still stands at 909,09 on the balance sheet
-- of a year that ends with the dollar at 1,20. Every framework in scope asks
-- for the monetary items in a foreign currency to be stated at the closing
-- rate, and this file does it, at the close (decision 0100).
--
-- **What is revalued.** Every posted line in a currency that is not the
-- company's, with its amount in that currency, dated on or before the last day
-- of the year, on
--   - a receivable or payable account, for the part still open on that day —
--     the part a matching whose two lines are both dated on or before it has
--     not settled; and
--   - the ledger account of a bank account kept in that currency, whole.
-- Summed by account, counterparty and currency: one position each.
--
-- **At which rate.** The closing rate is an input, as every rate of the
-- schema is: `closing_rates` holds, per company, currency and day, the units
-- of that currency for one unit of the company's — the convention of
-- `documents.exchange_rate`. The close reads the rate of the last day of the
-- year, that day exactly, and refuses by name (`fx_closing_rate_missing`) a
-- currency still open without one. `currency_rates` is not read, for the
-- reasons decision 0097 gives.
--
-- **Where the difference goes.** On the position's own account, against the
-- counterparty, and on the accounts the pack names:
--   - for a receivable or payable, `country_defaults.fx_unrealised_gain_code`
--     and `fx_unrealised_loss_code`, from `defaults.roles.fx_unrealised_gain`
--     and `fx_unrealised_loss` — a balance-sheet account where the chart
--     defers an unrealised difference, an income or expense account where it
--     goes to the result;
--   - for a bank account, the exchange gain and loss accounts a matching
--     already uses, `fx_gain_code` and `fx_loss_code`: money held in a
--     currency is stated at the closing rate and its difference is part of
--     the result in every chart in scope.
-- A role the difference needs and the pack does not name refuses the close by
-- name (`no_fx_revaluation_accounts`, `no_fx_accounts`), never a default
-- account. A company with nothing open in a foreign currency needs neither
-- the roles nor a rate, and closes exactly as before.
--
-- **And back.** The revaluation is an entry of the miscellaneous journal on
-- the last day of the year, posted before the result is worked out, so the
-- result includes it where the pack puts it there. Its mirror is posted on
-- the next day — the first of the next year — so that a matching in the new
-- year realises the difference from the rate the item was booked at, as
-- decision 0021 computes it, and nothing is counted twice. On a receivable or
-- payable account the two lines are matched with each other, and neither
-- stands as an open item. `currency_revaluations` records the pair for the
-- year; `reopen_fiscal_year()` takes both back with their mirrors.
--
-- Additive: two nullable columns, two tables, three functions added, two
-- rewritten with their signature, their grants and their errors.

-- ---------------------------------------------------------------------------
-- 1. The roles
-- ---------------------------------------------------------------------------

alter table ekwo.country_defaults
  add column fx_unrealised_gain_code text,
  add column fx_unrealised_loss_code text;

comment on column ekwo.country_defaults.fx_unrealised_gain_code is
  'Account an unrealised exchange gain on a receivable or payable still open at the close is booked on, from defaults.roles.fx_unrealised_gain of the pack. Null until the pack names one, and then a close that finds such a gain is refused (no_fx_revaluation_accounts) rather than booked somewhere else.';
comment on column ekwo.country_defaults.fx_unrealised_loss_code is
  'The same for an unrealised loss. A pair, because a chart that defers the difference keeps the two on opposite sides of the balance sheet.';

-- ---------------------------------------------------------------------------
-- 2. closing_rates — the rates a company closes at
-- ---------------------------------------------------------------------------

create table ekwo.closing_rates (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references ekwo.companies(id) on delete cascade,
  currency_code char(3) not null references ekwo.currencies(code),
  rate_date     date not null,
  rate          numeric(18, 8) not null,
  source        text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (company_id, currency_code, rate_date),
  constraint closing_rates_positive check (rate > 0)
);

comment on table ekwo.closing_rates is
  'The exchange rates a company states its open foreign-currency items at on a closing date: one row per currency and day. close_fiscal_year() reads the row of the last day of the year for every currency still open, and refuses one that is missing (fx_closing_rate_missing).';
comment on column ekwo.closing_rates.rate is
  'Units of currency_code for one unit of the company''s currency, as documents.exchange_rate holds a rate. The amount in the company''s currency is the amount in currency_code divided by it.';
comment on column ekwo.closing_rates.rate_date is
  'The day the rate is the closing rate of. A close reads this day exactly: a rate of another day is never taken for it.';
comment on column ekwo.closing_rates.source is
  'Where the rate comes from — a central bank, a published series — so that a revaluation can be traced to it.';

create index closing_rates_currency_idx on ekwo.closing_rates (currency_code);

create trigger closing_rates_set_updated_at
  before update on ekwo.closing_rates
  for each row execute function ekwo.set_updated_at();

alter table ekwo.closing_rates enable row level security;

create policy closing_rates_select on ekwo.closing_rates
  for select using (company_id = any ((select ekwo.companies_with_capability('entries.read'))::uuid[]));
create policy closing_rates_write on ekwo.closing_rates
  for all using (company_id = any ((select ekwo.companies_with_capability('year_end.close'))::uuid[]))
  with check (company_id = any ((select ekwo.companies_with_capability('year_end.close'))::uuid[]));

comment on policy closing_rates_select on ekwo.closing_rates is
  'Whoever reads the ledger reads the rates its revaluations were made at.';
comment on policy closing_rates_write on ekwo.closing_rates is
  'year_end.close: the rate a year is closed at is chosen by whoever closes it.';

grant select, insert, update, delete on table ekwo.closing_rates to authenticated, service_role;

create trigger closing_rates_audit
  after insert or update or delete on ekwo.closing_rates
  for each row execute function ekwo.audit_changes('{"company":"company_id","key":["currency_code","rate_date"]}');

-- ---------------------------------------------------------------------------
-- 3. currency_revaluations — the pair of entries a close wrote
-- ---------------------------------------------------------------------------

create table ekwo.currency_revaluations (
  id                   uuid primary key default gen_random_uuid(),
  company_id           uuid not null references ekwo.companies(id) on delete cascade,
  fiscal_year_id       uuid not null references ekwo.fiscal_years(id) on delete cascade,
  revaluation_entry_id uuid not null references ekwo.entries(id),
  reversal_entry_id    uuid not null references ekwo.entries(id),
  difference           numeric not null,
  created_at           timestamptz not null default now(),
  unique (fiscal_year_id)
);

comment on table ekwo.currency_revaluations is
  'The revaluation close_fiscal_year() posted for a year — the entry on its last day and its mirror on the next — so that reopen_fiscal_year() takes both back. Written and deleted by those two functions only, under the setting ekwo.revaluing.';
comment on column ekwo.currency_revaluations.revaluation_entry_id is
  'The entry, dated the last day of the year, that states the open foreign-currency positions at the closing rate.';
comment on column ekwo.currency_revaluations.reversal_entry_id is
  'Its mirror, dated the first day after the year, which puts the positions back at the rates they were booked at.';
comment on column ekwo.currency_revaluations.difference is
  'What the revaluation moved, in the company''s currency, the sum of the differences of its positions: a gain positive, a loss negative.';

create index currency_revaluations_company_idx on ekwo.currency_revaluations (company_id);
create index currency_revaluations_revaluation_entry_idx on ekwo.currency_revaluations (revaluation_entry_id);
create index currency_revaluations_reversal_entry_idx on ekwo.currency_revaluations (reversal_entry_id);

alter table ekwo.currency_revaluations enable row level security;

create policy currency_revaluations_select on ekwo.currency_revaluations
  for select using (company_id = any ((select ekwo.companies_with_capability('entries.read'))::uuid[]));
create policy currency_revaluations_insert on ekwo.currency_revaluations
  for insert with check (company_id = any ((select ekwo.companies_with_capability('year_end.close'))::uuid[]));
create policy currency_revaluations_delete on ekwo.currency_revaluations
  for delete using (company_id = any ((select ekwo.companies_with_capability('year_end.close'))::uuid[]));

comment on policy currency_revaluations_select on ekwo.currency_revaluations is
  'Whoever reads the ledger reads which of its entries a close wrote.';
comment on policy currency_revaluations_insert on ekwo.currency_revaluations is
  'year_end.close, and only inside close_fiscal_year(), which the guard enforces.';
comment on policy currency_revaluations_delete on ekwo.currency_revaluations is
  'year_end.close, and only inside reopen_fiscal_year(), which the guard enforces.';

grant select, insert, delete on table ekwo.currency_revaluations to authenticated, service_role;

create function ekwo.currency_revaluations_guard()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
begin
  if is_installer() then
    return coalesce(new, old);
  end if;
  -- The cascades of a company and of a year pass.
  if tg_op = 'DELETE'
     and (not exists (select 1 from companies c where c.id = old.company_id)
          or not exists (select 1 from fiscal_years f where f.id = old.fiscal_year_id)) then
    return old;
  end if;
  if coalesce(current_setting('ekwo.revaluing', true), '') <> 'on' then
    raise exception 'currency_revaluation_by_close: a revaluation is written by close_fiscal_year() and taken back by reopen_fiscal_year()'
      using errcode = '55006';
  end if;
  return coalesce(new, old);
end;
$$;

comment on function ekwo.currency_revaluations_guard() is
  'Keeps currency_revaluations to the close that writes it and the reopening that takes it back, under the setting ekwo.revaluing. The cascades of a company and of a fiscal year pass, and so does the installer.';

revoke execute on function ekwo.currency_revaluations_guard() from public, anon, authenticated, service_role;

create trigger currency_revaluations_guard
  before insert or update or delete on ekwo.currency_revaluations
  for each row execute function ekwo.currency_revaluations_guard();

create trigger currency_revaluations_audit
  after insert or update or delete on ekwo.currency_revaluations
  for each row execute function ekwo.audit_changes('{"company":"company_id","key":["id"]}');

-- A company leaves with its rates, and with the revaluations after the
-- entries they name.
insert into ekwo.company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('closing_rates', 'exported', 42, null, null,
   'The rates the company closed its years at: a revaluation in the ledger was made at them.'),
  ('currency_revaluations', 'exported', 64, null, null,
   'Which entries a close wrote to revalue the open foreign-currency items, after those entries, so that the year can still be reopened where it arrives.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 4. currency_revaluation — what a close at a date would revalue
-- ---------------------------------------------------------------------------

create function ekwo.currency_revaluation(
  p_company_id uuid,
  p_at         date
)
returns table (
  account_id      uuid,
  account_code    text,
  contact_id      uuid,
  currency_code   char(3),
  position_kind   text,
  amount_currency numeric,
  carrying_amount numeric,
  closing_rate    numeric,
  revalued_amount numeric,
  difference      numeric
)
language sql
stable
set search_path = ekwo, pg_temp
as $$
  with company as (
    select c.id, c.currency_code as home, rounding_of(c.id) as rnd
      from companies c where c.id = p_company_id
  ),
  -- The ledger accounts of the bank accounts kept in a foreign currency.
  banks as (
    select distinct b.account_id, b.currency_code
      from bank_accounts b, company
     where b.company_id = company.id
       and b.account_id is not null
       and b.currency_code <> company.home
  ),
  lines as (
    select l.id, l.account_id, a.code, l.contact_id, l.currency_code,
           l.balance, l.amount_currency,
           case when bk.account_id is not null then 'bank' else 'third_party' end as kind
      from entry_lines l
      join entries e on e.id = l.entry_id and e.state = 'posted'
      join accounts a on a.id = l.account_id
      cross join company
      left join banks bk on bk.account_id = l.account_id and bk.currency_code = l.currency_code
     where l.company_id = company.id
       and e.entry_date <= p_at
       and l.currency_code is not null
       and l.currency_code <> company.home
       and coalesce(l.amount_currency, 0) <> 0
       and l.balance <> 0
       and (bk.account_id is not null
            or (a.reconcilable and a.account_type in ('asset_receivable', 'liability_payable')))
  ),
  -- What a matching had settled of each line on that day: the matchings
  -- whose other line is dated on or before it. A matching made later of a
  -- payment received later leaves the item open on the day.
  settled as (
    select x.id, coalesce(sum(r.amount), 0) as amount
      from lines x
      join reconciliations r on x.id in (r.debit_line_id, r.credit_line_id)
      join entry_lines o on o.id = case when r.debit_line_id = x.id then r.credit_line_id else r.debit_line_id end
      join entries oe on oe.id = o.entry_id
     where x.kind = 'third_party'
       and oe.entry_date <= p_at
     group by x.id
  ),
  open_part as (
    select x.account_id, x.code, x.contact_id, x.currency_code, x.kind,
           greatest(abs(x.balance) - coalesce(s.amount, 0), 0) / abs(x.balance) as share,
           sign(x.balance) * x.amount_currency as amount_currency,
           x.balance
      from lines x
      left join settled s on s.id = x.id
  ),
  positions as (
    select p.account_id, p.code, p.contact_id, p.currency_code, p.kind,
           round_amount(sum(p.amount_currency * p.share), rounding_of(p_company_id, p.currency_code)) as amount_currency,
           round_amount(sum(p.balance * p.share), (select rnd from company)) as carrying
      from open_part p
     group by p.account_id, p.code, p.contact_id, p.currency_code, p.kind
  )
  select p.account_id, p.code, p.contact_id, p.currency_code, p.kind,
         p.amount_currency, p.carrying, r.rate,
         round_amount(p.amount_currency / r.rate, (select rnd from company)),
         round_amount(p.amount_currency / r.rate, (select rnd from company)) - p.carrying
    from positions p
    left join closing_rates r
      on r.company_id = p_company_id
     and r.currency_code = p.currency_code
     and r.rate_date = p_at
   where p.amount_currency <> 0
   order by p.code, p.currency_code, p.contact_id;
$$;

comment on function ekwo.currency_revaluation(uuid, date) is
  'The foreign-currency positions of a company still open on a day, and what stating them at the closing rate of that day moves: per account, counterparty and currency, the amount in the currency, the amount the ledger carries it at, the rate of closing_rates for that day (null where none is recorded), the amount at that rate and the difference. A position is the open part of the lines in that currency of a receivable or payable account — what no matching dated on or before the day settled — or the whole of the lines in that currency of the account of a bank account kept in it. What close_fiscal_year() books, and nothing is written here.';

revoke execute on function ekwo.currency_revaluation(uuid, date) from public, anon;
grant execute on function ekwo.currency_revaluation(uuid, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. revalue_currency_positions — the entry, its mirror and their matching
-- ---------------------------------------------------------------------------

create function ekwo.revalue_currency_positions(p_fiscal_year_id uuid)
returns ekwo.currency_revaluations
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_year      fiscal_years%rowtype;
  v_company   companies%rowtype;
  v_defaults  country_defaults%rowtype;
  v_missing   text;
  v_entry     entries%rowtype;
  v_reversal  entries%rowtype;
  v_row       currency_revaluations%rowtype;
  v_gain      uuid;
  v_loss      uuid;
  v_bank_gain uuid;
  v_bank_loss uuid;
  v_seq       integer := 0;
  v_positions integer;          -- the last sequence of a position line; the other sides follow
  p           record;
begin
  -- Called by close_fiscal_year() for the year it is closing, and by nothing
  -- else: on its own it would state a year at a rate nobody is closing it at.
  if coalesce(current_setting('ekwo.closing_fiscal_year_id', true), '') <> p_fiscal_year_id::text then
    raise exception 'currency_revaluation_by_close: open foreign-currency items are revalued by close_fiscal_year()'
      using errcode = '55006';
  end if;

  select * into v_year from fiscal_years where id = p_fiscal_year_id;
  select * into v_company from companies where id = v_year.company_id;
  select * into v_defaults from country_defaults where country = v_company.country;

  -- A currency still open without its closing rate is a sentence, not a
  -- figure at another day's rate.
  select string_agg(distinct currency_code::text, ', ' order by currency_code::text) into v_missing
    from currency_revaluation(v_year.company_id, v_year.end_date) where closing_rate is null;
  if v_missing is not null then
    raise exception 'fx_closing_rate_missing: % still open on %; record the closing rate of that day in closing_rates before closing %',
      v_missing, v_year.end_date, v_year.name
      using errcode = '55006';
  end if;

  if not exists (select 1 from currency_revaluation(v_year.company_id, v_year.end_date) where difference <> 0) then
    return null;
  end if;

  -- The accounts, from the pack, and only those a difference of the year
  -- needs: a pack that names none still closes a year that moves nothing.
  v_gain      := account_id_by_code(v_year.company_id, v_defaults.fx_unrealised_gain_code);
  v_loss      := account_id_by_code(v_year.company_id, v_defaults.fx_unrealised_loss_code);
  v_bank_gain := account_id_by_code(v_year.company_id, v_defaults.fx_gain_code);
  v_bank_loss := account_id_by_code(v_year.company_id, v_defaults.fx_loss_code);

  if exists (select 1 from currency_revaluation(v_year.company_id, v_year.end_date)
              where position_kind = 'third_party'
                and ((difference > 0 and v_gain is null) or (difference < 0 and v_loss is null))) then
    raise exception 'no_fx_revaluation_accounts: % holds receivables or payables in a foreign currency whose revaluation at % moves them, and the country model of % names no account for an unrealised exchange % (defaults.roles.fx_unrealised_gain and fx_unrealised_loss of the pack), or the company has none',
      v_year.name, v_year.end_date, v_company.country,
      case when exists (select 1 from currency_revaluation(v_year.company_id, v_year.end_date)
                         where position_kind = 'third_party' and difference > 0 and v_gain is null)
           then 'gain' else 'loss' end
      using errcode = '55006';
  end if;
  if exists (select 1 from currency_revaluation(v_year.company_id, v_year.end_date)
              where position_kind = 'bank'
                and ((difference > 0 and v_bank_gain is null) or (difference < 0 and v_bank_loss is null))) then
    raise exception 'no_fx_accounts: a bank account in a foreign currency is revalued at % and the country model of % names no exchange gain and loss account (defaults.roles.fx_gain and fx_loss of the pack), or the company has none',
      v_year.end_date, v_company.country
      using errcode = '55006';
  end if;
  if v_company.miscellaneous_journal_id is null then
    raise exception 'no_miscellaneous_journal: company % has no journal for an exchange difference', v_company.id
      using errcode = '55006';
  end if;

  -- The revaluation, on the last day of the year.
  insert into entries (company_id, journal_id, fiscal_year_id, entry_date, description, state, currency_code)
  values (v_year.company_id, v_company.miscellaneous_journal_id, v_year.id, v_year.end_date,
          'Revaluation of open foreign-currency items at ' || v_year.end_date, 'draft', v_company.currency_code)
  returning * into v_entry;

  for p in
    select * from currency_revaluation(v_year.company_id, v_year.end_date) where difference <> 0
  loop
    v_seq := v_seq + 10;
    insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id, currency_code)
    values (v_entry.id, v_year.company_id, p.account_id, v_seq,
            'Revaluation of ' || p.amount_currency || ' ' || p.currency_code || ' at ' || p.closing_rate,
            greatest(p.difference, 0), greatest(-p.difference, 0), p.contact_id, v_company.currency_code);
  end loop;

  v_positions := v_seq;

  -- The other side, gains and losses apart: a chart that defers them keeps
  -- them on opposite sides of the balance sheet.
  for p in
    select case when position_kind = 'bank'
                then case when difference > 0 then v_bank_gain else v_bank_loss end
                else case when difference > 0 then v_gain else v_loss end end as account_id,
           sum(difference) as difference
      from currency_revaluation(v_year.company_id, v_year.end_date)
     where difference <> 0
     group by 1
     order by 1
  loop
    v_seq := v_seq + 10;
    insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, currency_code)
    values (v_entry.id, v_year.company_id, p.account_id, v_seq,
            case when p.difference > 0 then 'Unrealised exchange gain' else 'Unrealised exchange loss' end,
            greatest(-p.difference, 0), greatest(p.difference, 0), v_company.currency_code);
  end loop;

  v_entry := post_entry(v_entry.id);

  -- Its mirror, on the first day after the year, through reverse_entry():
  -- the gesture that undoes an entry, which matches each line of a
  -- receivable or payable with its mirror, so that neither stands as an item
  -- anybody has to collect or pay.
  v_reversal := reverse_entry(v_entry.id, v_year.end_date + 1);

  perform set_config('ekwo.revaluing', 'on', true);
  insert into currency_revaluations (company_id, fiscal_year_id, revaluation_entry_id, reversal_entry_id, difference)
  values (v_year.company_id, v_year.id, v_entry.id, v_reversal.id,
          (select sum(l.debit - l.credit) from entry_lines l
            where l.entry_id = v_entry.id and l.sequence <= v_positions))
  returning * into v_row;
  perform set_config('ekwo.revaluing', 'off', true);

  return v_row;
end;
$$;

comment on function ekwo.revalue_currency_positions(uuid) is
  'Posts what currency_revaluation() finds at the last day of a year: one entry of the miscellaneous journal that day, each position against the unrealised exchange gain or loss account of the pack (the exchange gain or loss account for a bank account), and its mirror the next day through reverse_entry(), which matches the two lines of each receivable or payable with each other; and the pair recorded in currency_revaluations. Refuses a currency open without a closing rate (fx_closing_rate_missing) and a difference the pack names no account for (no_fx_revaluation_accounts, no_fx_accounts). Called by close_fiscal_year() for the year it closes, and refused otherwise.';

revoke execute on function ekwo.revalue_currency_positions(uuid) from public, anon;
grant execute on function ekwo.revalue_currency_positions(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. close_fiscal_year — the open foreign-currency items at the closing rate,
-- before the result is worked out
-- ---------------------------------------------------------------------------

create or replace function ekwo.close_fiscal_year(p_fiscal_year_id uuid)
returns jsonb
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_year        fiscal_years%rowtype;
  v_company     companies%rowtype;
  v_defaults    country_defaults%rowtype;
  v_journal     uuid;
  v_result      numeric;
  v_profit      boolean;
  v_kind        text;
  v_cyr         uuid;          -- current-year result account, the side that applies
  v_retained    uuid;          -- retained earnings, the side that applies
  v_carries     boolean;
  v_appropriate uuid;
  v_closing     uuid;
  v_entry       entries%rowtype;
  v_lines       integer;
  v_debits      numeric;
  v_credits     numeric;
  v_oci_account uuid;          -- where other comprehensive income closes, if the pack names it
  v_oci         numeric := 0;  -- other comprehensive income of the year, a credit being a gain
  v_reval       currency_revaluations%rowtype;
  v_unrealised  numeric := 0;  -- what the revaluation moved, a gain being positive
  -- A close is written in the ledger's own currency, and the figure it
  -- reports is written with the decimals that currency has.
  v_round       money_rounding;
begin
  select * into v_year from fiscal_years where id = p_fiscal_year_id for update;
  if not found then
    raise exception 'unknown_fiscal_year: fiscal year % does not exist', p_fiscal_year_id;
  end if;
  if v_year.is_closed then
    raise exception 'fiscal_year_already_closed: % was closed on %', v_year.name, v_year.closed_at;
  end if;

  select * into v_company from companies where id = v_year.company_id;
  v_round := rounding_of(v_year.company_id);

  -- 1. What has to be true before a year can be closed.

  if exists (
    select 1 from entries e
     where e.company_id = v_year.company_id
       and e.entry_date between v_year.start_date and v_year.end_date
       and e.state = 'draft'
  ) then
    raise exception 'fiscal_year_has_drafts: % still holds draft entries; post or cancel them first', v_year.name;
  end if;

  if exists (
    select 1 from fiscal_years f
     where f.company_id = v_year.company_id
       and f.start_date < v_year.start_date
       and not f.is_closed
       and exists (select 1 from entries e where e.fiscal_year_id = f.id and e.state = 'posted')
  ) then
    raise exception 'earlier_fiscal_year_open: a year before % holds posted entries and is not closed', v_year.name;
  end if;

  if exists (
    select 1 from fiscal_years f
     where f.company_id = v_year.company_id
       and f.start_date > v_year.start_date
       and f.is_closed
  ) then
    raise exception 'later_fiscal_year_closed: a year after % is already closed; re-open it first', v_year.name;
  end if;

  -- 2. The accounts the result travels through, from the country model.

  select * into v_defaults from country_defaults where country = v_company.country;
  if not found then
    raise exception 'unknown_country_template: no country model for %; close_fiscal_year reads its accounts from the pack',
      v_company.country;
  end if;

  if v_defaults.closing_style is null then
    raise exception 'no_closing_defaults: the pack of this company says nothing about how a year is closed. Set defaults.closing_style, and the account roles it needs, in the pack.'
      using errcode = '55006';
  end if;

  v_journal := opening_journal_id(v_year.company_id);
  if v_journal is null then
    raise exception 'no_opening_journal: the pack of this company names no journal of type opening. Set defaults.journal_roles.opening in the pack, which fills country_defaults.opening_journal_code.'
      using errcode = '55006';
  end if;

  -- Where other comprehensive income closes, when the pack says it has some.
  -- Asserted like the result account below: an account that does not carry
  -- forward would take the figure out of the balance sheet, silently.
  if v_defaults.other_comprehensive_income_heads is not null then
    v_oci_account := account_id_by_code(v_year.company_id, v_defaults.other_comprehensive_income_closes_to);
    if v_oci_account is null then
      raise exception 'no_other_comprehensive_income_account: the country model of % closes other comprehensive income to %, and the company has no such account',
        v_company.country, v_defaults.other_comprehensive_income_closes_to;
    end if;
    select a.carries_forward into v_carries from accounts a where a.id = v_oci_account;
    if not v_carries then
      raise exception 'closing_style_mismatch: other comprehensive income closes to an account on the balance sheet, and % does not carry forward',
        v_defaults.other_comprehensive_income_closes_to;
    end if;
  end if;

  -- 2b. What is still open in a foreign currency, at the closing rate. First,
  --     so the result below includes the difference wherever the pack puts it.

  perform set_config('ekwo.closing_fiscal_year_id', p_fiscal_year_id::text, true);
  v_reval := revalue_currency_positions(p_fiscal_year_id);
  perform set_config('ekwo.closing_fiscal_year_id', '', true);

  v_unrealised := coalesce(v_reval.difference, 0);

  -- The result of the year: income less expense, over the accounts that do
  -- not carry forward and are not other comprehensive income. A credit
  -- balance is a profit.
  select round_amount(coalesce(-sum(l.balance), 0), v_round) into v_result
    from entry_lines l
    join entries e on e.id = l.entry_id and e.state = 'posted'
    join accounts a on a.id = l.account_id
   where l.company_id = v_year.company_id
     and e.entry_date between v_year.start_date and v_year.end_date
     and not a.carries_forward
     and other_comprehensive_income_account(v_year.company_id, a.code) is null;

  v_profit := v_result >= 0;
  v_kind := case when v_result > 0 then 'profit'
                 when v_result < 0 then 'loss'
                 else 'nil' end;

  v_retained := coalesce(
    case when v_profit then v_company.retained_earnings_account_id end,
    account_id_by_code(v_year.company_id,
      case when v_profit then v_defaults.retained_earnings_code
           else coalesce(v_defaults.retained_earnings_loss_code, v_defaults.retained_earnings_code) end));

  v_cyr := account_id_by_code(v_year.company_id,
    case when v_profit then v_defaults.current_year_result_profit_code
         else v_defaults.current_year_result_loss_code end);

  if v_defaults.closing_style = 'retained_earnings' then
    if v_retained is null then
      raise exception 'no_retained_earnings_account: the country model of % names none, and the company has none',
        v_company.country;
    end if;
    v_cyr := v_retained;
  else
    if v_cyr is null then
      raise exception 'no_current_year_result_account: the country model of % names no account for a %',
        v_company.country, v_kind;
    end if;
  end if;

  -- A style is a promise about where the result sits at the end. Assert it
  -- rather than trust it: a pack that names an income account where the
  -- balance sheet is expected would carry nothing forward, silently.
  select a.carries_forward into v_carries from accounts a where a.id = v_cyr;
  if v_defaults.closing_style = 'appropriation_accounts' and v_carries then
    raise exception 'closing_style_mismatch: % expects an appropriation account inside the income statement, and % carries forward',
      v_defaults.closing_style, v_cyr;
  end if;
  if v_defaults.closing_style <> 'appropriation_accounts' and not v_carries then
    raise exception 'closing_style_mismatch: % expects an account on the balance sheet, and % does not carry forward',
      v_defaults.closing_style, v_cyr;
  end if;

  -- 3. The appropriation entry: the result leaves the income statement
  --    through an account that is itself part of it, and lands on retained
  --    earnings. Only the third style has one, and only when there is a
  --    result to move. Other comprehensive income is not part of it.

  if v_defaults.closing_style = 'appropriation_accounts' and v_result <> 0 then
    if v_retained is null then
      raise exception 'no_retained_earnings_account: the country model of % names none, and the company has none',
        v_company.country;
    end if;

    perform set_config('ekwo.year_end_entry', 'on', true);
    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, kind)
    values (v_year.company_id, v_journal, v_year.id, v_year.end_date,
            'Result of the year', 'draft', 'appropriation')
    returning * into v_entry;
    perform set_config('ekwo.year_end_entry', 'off', true);
    v_appropriate := v_entry.id;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
    values (v_appropriate, v_year.company_id, v_cyr, 10, 'Result of the year',
            case when v_profit then abs(v_result) else 0 end,
            case when v_profit then 0 else abs(v_result) end),
           (v_appropriate, v_year.company_id, v_retained, 20, 'Result of the year',
            case when v_profit then 0 else abs(v_result) end,
            case when v_profit then abs(v_result) else 0 end);

    perform post_entry(v_appropriate);
  end if;

  -- 4. The closing entry: every income and expense account back to zero.
  --    In the first two styles the difference is the result and goes to the
  --    account chosen above; in the third the accounts already net to zero,
  --    because the appropriation entry put the result among them. Other
  --    comprehensive income, in every style, goes to its own account.

  perform set_config('ekwo.year_end_entry', 'on', true);
  insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                       description, state, kind)
  values (v_year.company_id, v_journal, v_year.id, v_year.end_date,
          'Closing entry', 'draft', 'closing')
  returning * into v_entry;
  perform set_config('ekwo.year_end_entry', 'off', true);
  v_closing := v_entry.id;

  insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
  select v_closing, v_year.company_id, s.account_id,
         row_number() over (order by s.code) * 10,
         'Closing entry',
         case when s.balance < 0 then -s.balance else 0 end,
         case when s.balance > 0 then s.balance else 0 end
    from (
      select a.id as account_id, a.code,
             round_amount(sum(l.balance), v_round) as balance
        from entry_lines l
        join entries e on e.id = l.entry_id and e.state = 'posted'
        join accounts a on a.id = l.account_id
       where l.company_id = v_year.company_id
         and e.entry_date between v_year.start_date and v_year.end_date
         and not a.carries_forward
       group by a.id, a.code
      having round_amount(sum(l.balance), v_round) <> 0
    ) s;

  select count(*) into v_lines from entry_lines where entry_id = v_closing;

  if v_lines = 0 then
    delete from entries where id = v_closing;
    v_closing := null;
  else
    -- What the lines above took off the accounts of other comprehensive
    -- income, summed: a gain is a credit balance, so it is the debit those
    -- lines wrote less their credit.
    if v_oci_account is not null then
      select coalesce(sum(l.debit - l.credit), 0) into v_oci
        from entry_lines l
        join accounts a on a.id = l.account_id
       where l.entry_id = v_closing
         and other_comprehensive_income_account(v_year.company_id, a.code) is not null;

      if v_oci <> 0 then
        insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
        values (v_closing, v_year.company_id, v_oci_account, 999990, 'Other comprehensive income',
                case when v_oci < 0 then -v_oci else 0 end,
                case when v_oci > 0 then v_oci else 0 end);
      end if;
    end if;

    if v_defaults.closing_style <> 'appropriation_accounts' and v_result <> 0 then
      insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
      values (v_closing, v_year.company_id, v_cyr, 1000000, 'Result of the year',
              case when v_profit then 0 else abs(v_result) end,
              case when v_profit then abs(v_result) else 0 end);
    end if;

    select total_debit, total_credit into v_debits, v_credits from entries where id = v_closing;
    if v_debits <> v_credits then
      raise exception 'closing_unbalanced: the closing entry has debit % and credit %. The income statement of % does not net to its result.',
        v_debits, v_credits, v_year.name;
    end if;

    perform post_entry(v_closing);
  end if;

  -- 5. The year is closed, and only from here.

  perform set_config('ekwo.closing_fiscal_year', 'on', true);
  update fiscal_years
     set is_closed = true,
         closed_at = now()
   where id = p_fiscal_year_id;
  perform set_config('ekwo.closing_fiscal_year', 'off', true);

  return jsonb_build_object(
    'fiscal_year_id', p_fiscal_year_id,
    'closing_style', v_defaults.closing_style,
    -- The figure is written the way the currency writes it: a yen result
    -- carries no decimals and a dinar one carries three.
    'result', to_char(v_result, amount_text_format(v_round)),
    'result_kind', v_kind,
    'other_comprehensive_income', to_char(v_oci, amount_text_format(v_round)),
    'unrealised_exchange_difference', to_char(v_unrealised, amount_text_format(v_round)),
    'revaluation_entry_id', v_reval.revaluation_entry_id,
    'revaluation_reversal_entry_id', v_reval.reversal_entry_id,
    'appropriation_entry_id', v_appropriate,
    'closing_entry_id', v_closing
  );
end;
$$;

comment on function ekwo.close_fiscal_year(uuid) is
  'Closes a fiscal year: states what is still open in a foreign currency at the closing rate of its last day (revalue_currency_positions(), reversed the next day), brings every income and expense account back to nil on the opening journal, books the result of the year where the pack''s closing_style puts it — through an appropriation entry under appropriation_accounts — and the other comprehensive income the pack names on the account it closes to, then marks the year closed. Returns the result and its kind, the other comprehensive income moved, the unrealised exchange difference booked (a gain positive), and the entries written.';

-- ---------------------------------------------------------------------------
-- 7. reopen_fiscal_year — the revaluation goes back with the close
-- ---------------------------------------------------------------------------

create or replace function ekwo.reopen_fiscal_year(p_fiscal_year_id uuid)
returns jsonb
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_year      fiscal_years%rowtype;
  v_original  entries%rowtype;
  v_reversal  entries%rowtype;
  v_reversed  uuid[] := '{}';
  v_reval     currency_revaluations%rowtype;
  v_mirror_a  uuid;
  v_mirror_b  uuid;
  m           record;
begin
  select * into v_year from fiscal_years where id = p_fiscal_year_id for update;
  if not found then
    raise exception 'unknown_fiscal_year: fiscal year % does not exist', p_fiscal_year_id;
  end if;
  if v_year.finally_closed_at is not null then
    raise exception 'fiscal_year_finally_closed: % was finally closed on %; a final close is not reopened',
      v_year.name, v_year.finally_closed_at
      using errcode = '55006';
  end if;
  if not v_year.is_closed then
    raise exception 'fiscal_year_not_closed: % is already open', v_year.name;
  end if;

  -- Entries posted in a later year are no reason to refuse: the close wrote
  -- nothing there but the mirror of its revaluation, and the later year reads
  -- this one's result from the ledger. A later year that is closed is
  -- reopened first, as close_fiscal_year() refuses a year whose successor is
  -- closed.
  if exists (
    select 1 from fiscal_years f
     where f.company_id = v_year.company_id
       and f.start_date > v_year.end_date
       and f.is_closed
  ) then
    raise exception 'later_fiscal_year_closed: a year after % is closed; reopen it first', v_year.name;
  end if;

  -- The flag first: the reversals are dated inside the year being re-opened,
  -- and the period guard would refuse them while it is closed.
  perform set_config('ekwo.closing_fiscal_year', 'on', true);
  update fiscal_years
     set is_closed = false,
         closed_at = null
   where id = p_fiscal_year_id;
  perform set_config('ekwo.closing_fiscal_year', 'off', true);

  for v_original in
    select e.*
      from entries e
     where e.company_id = v_year.company_id
       and e.state = 'posted'
       and e.kind in ('closing', 'appropriation')
       and e.fiscal_year_id = p_fiscal_year_id
       and e.reversed_entry_id is null
       and not exists (
         select 1 from entries r where r.reversed_entry_id = e.id and r.state = 'posted'
       )
     order by e.entry_date, e.number
  loop
    -- A reversal carries the kind of what it undoes: it belongs to the same
    -- report exclusion, and a closing entry undone by a `normal` one would
    -- reappear in the income statement on its own.
    perform set_config('ekwo.year_end_entry', 'on', true);
    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, reversed_entry_id, currency_code, kind)
    values (v_original.company_id, v_original.journal_id, v_original.fiscal_year_id,
            v_original.entry_date, 'Reversal of ' || v_original.number, 'draft',
            v_original.id, v_original.currency_code, v_original.kind)
    returning * into v_reversal;
    perform set_config('ekwo.year_end_entry', 'off', true);

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, contact_id, date_maturity, currency_code)
    select v_reversal.id, l.company_id, l.account_id, l.sequence, l.name,
           l.credit, l.debit, l.contact_id, l.date_maturity, l.currency_code
      from entry_lines l
     where l.entry_id = v_original.id
     order by l.sequence;

    perform post_entry(v_reversal.id);
    v_reversed := v_reversed || v_reversal.id;
  end loop;

  -- The revaluation and its mirror of the next day, each taken back on its
  -- own date. The two mirrors settle each other as the two originals do, and
  -- the next close revalues from the rates the items were booked at.
  select * into v_reval from currency_revaluations where fiscal_year_id = p_fiscal_year_id;
  if found then
    foreach v_mirror_a in array array[v_reval.revaluation_entry_id, v_reval.reversal_entry_id]
    loop
      select * into v_original from entries where id = v_mirror_a;
      insert into entries (company_id, journal_id, fiscal_year_id, entry_date, description, state,
                           reversed_entry_id, currency_code)
      values (v_original.company_id, v_original.journal_id, v_original.fiscal_year_id,
              v_original.entry_date, 'Reversal of ' || v_original.number, 'draft',
              v_original.id, v_original.currency_code)
      returning * into v_reversal;

      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, contact_id, currency_code)
      select v_reversal.id, l.company_id, l.account_id, l.sequence, l.name,
             l.credit, l.debit, l.contact_id, l.currency_code
        from entry_lines l
       where l.entry_id = v_original.id
       order by l.sequence;

      perform post_entry(v_reversal.id);
      v_reversed := v_reversed || v_reversal.id;
      if v_mirror_b is null then
        v_mirror_b := v_reversal.id;   -- the mirror of the revaluation
      end if;
    end loop;

    -- The revaluation and its mirror were matched with each other, so
    -- posting their mirrors matched nothing: the two new entries settle each
    -- other, line by line.
    for m in
      select a.id as one, b.id as other
        from entry_lines a
        join entry_lines b on b.entry_id = v_reversal.id and b.sequence = a.sequence
        join accounts ac on ac.id = a.account_id
       where a.entry_id = v_mirror_b and ac.reconcilable
         and abs(a.balance) > a.matched_amount
    loop
      perform reconcile(m.one, m.other);
    end loop;

    perform set_config('ekwo.revaluing', 'on', true);
    delete from currency_revaluations where id = v_reval.id;
    perform set_config('ekwo.revaluing', 'off', true);
  end if;

  return jsonb_build_object(
    'fiscal_year_id', p_fiscal_year_id,
    'reversal_entry_ids', to_jsonb(v_reversed)
  );
end;
$$;

comment on function ekwo.reopen_fiscal_year(uuid) is
  'Undoes an ordinary close: reverses the appropriation and closing entries it wrote and the revaluation of the open foreign-currency items with the mirror it posted the next day, and clears is_closed, whatever a later year holds — the close wrote nothing else there, and the later year reads the result from the ledger. Refused for a year under a final close (fiscal_year_finally_closed), for everybody, and while a later year is closed (later_fiscal_year_closed), which is reopened first.';

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
