-- Ekwo OS — a regime where one tax on turnover replaces VAT.
--
-- Many small companies are not VAT payers. In the place of the VAT a regime
-- of their country makes them pay one tax computed on what they sold: a
-- percentage of the period's turnover, or — where the law grades it — an
-- effective rate read from a table of brackets over the turnover of a
-- trailing window, (base x nominal rate - deduction) / base, applied to the
-- turnover of the period. Their invoices carry no VAT, their purchases give
-- back none, and the return they file is the one of that tax.
--
-- The schema had no such regime: a pack could only document the gap and let
-- the company install the VAT payer's taxes and use none of them. This file
-- is the smallest brick that closes it, and nothing in it names a country:
--
--   * `turnover_tax_regimes` and `turnover_tax_brackets` are reference data
--     compiled from a pack's `turnover_tax.json`: what the regime is called,
--     which kinds of tax it replaces, the form it is declared on, the window
--     its bracket is read over, the account its tax is an expense on, and the
--     brackets — a threshold, a nominal rate and a deduction, dated, closed
--     keys and no expression.
--   * `company_tax_regimes` is the company's declaration: this regime, from
--     the first day of a financial year, to the last day of one or for as
--     long as nothing else is said. A change in the middle of a year is
--     refused by name (`regime_change_mid_year`), and two regimes on one day
--     (`regime_overlap`). The cadence of the regime's form is recorded in
--     `company_filing_periods`, so `upcoming_filings()` lists it.
--   * Under the regime a document whose line carries a tax of a kind the
--     regime replaces is refused at posting (`tax_replaced_by_regime`): the
--     line is booked without that tax.
--   * `turnover_tax_return()` computes the tax of one period from the ledger,
--     line by line of its arithmetic, and reads and writes nothing else.
--   * `post_turnover_tax()` posts what it computed — the expense on the
--     regime's account, the debt on the account the pack names for what a
--     declaration owes — prepares the filing of the period, and keeps the
--     computation as it was in `turnover_tax_assessments`.
--   * `upcoming_filings()` stops listing the periodic VAT return for the
--     periods a regime that replaces VAT covers entirely.
--
-- **The turnover** of a period is what the posted sale invoices and credit
-- notes dated in it put on the income accounts, credit less debit, in the
-- company's currency: a credit note lowers the turnover of its own period.
--
-- **The window.** A regime that reads its bracket over a trailing window of
-- N months takes the turnover of the N months before the period (or ending
-- with it, where the pack says the window includes it). A company that has
-- been active for fewer months — counted from the first month of its first
-- financial year — either has its window annualised (the turnover of the
-- months it has, times N, over their number; in its first period, the
-- period's own turnover annualised) or read as it is, as the pack says.
--
-- Additive: four tables, six functions, four triggers, two rows of
-- `company_archive_registry`, and
-- `upcoming_filings()` republished with one condition more. Decision 0080
-- records the choice.

-- ---------------------------------------------------------------------------
-- 1. What a country says
-- ---------------------------------------------------------------------------

create table if not exists turnover_tax_regimes (
  country                char(2) not null,
  code                   text    not null,
  name                   text    not null,
  -- The kinds of tax a company under the regime does not charge or recover.
  replaces               tax_kind[] not null,
  -- The form the tax is declared on: a row of tax_report_templates of the
  -- same country, which carries its cadence and its deadline.
  report_code            text    not null,
  -- The months of turnover the bracket is read over. Null: the period's own.
  window_months          smallint,
  window_includes_period boolean not null default false,
  -- What a window shorter than its months becomes: annualise or as_is.
  short_window           text    not null default 'annualise',
  -- The account of the chart the tax is an expense on, by code.
  expense_account_code   text    not null,
  legal_reference        text    not null,
  source_key             text,
  sequence               integer not null default 10,
  primary key (country, code),
  constraint turnover_tax_regimes_country_format check (country ~ '^[A-Z]{2}$'),
  constraint turnover_tax_regimes_replaces_something check (cardinality(replaces) > 0),
  constraint turnover_tax_regimes_window check (window_months is null or window_months between 1 and 60),
  constraint turnover_tax_regimes_short_window check (short_window in ('annualise', 'as_is')),
  constraint turnover_tax_regimes_window_includes check (window_months is not null or not window_includes_period)
);

comment on table turnover_tax_regimes is
  'A regime of a country where one tax on turnover replaces the kinds of tax it names, compiled from the pack''s turnover_tax.json: the form it is declared on, the window its bracket is read over, the account its tax is an expense on and the article that sets it (decision 0080).';
comment on column turnover_tax_regimes.replaces is
  'The kinds of tax a company under the regime neither charges nor recovers. A document line carrying a tax of one of them is refused at posting.';
comment on column turnover_tax_regimes.window_months is
  'The months of turnover the bracket is read over — twelve for a regime graded on the trailing year. Null: the bracket is read on the turnover of the period itself.';
comment on column turnover_tax_regimes.window_includes_period is
  'The window ends with the period declared, rather than with the month before it.';
comment on column turnover_tax_regimes.short_window is
  'What the window of a company active for fewer months than it counts becomes: annualise (the turnover of the months it has, times window_months over their number; the period''s own when it has none) or as_is (the turnover it has).';

alter table turnover_tax_regimes enable row level security;
create policy turnover_tax_regimes_select on turnover_tax_regimes
  for select using (is_known_caller());
grant select on table turnover_tax_regimes to authenticated, service_role;

create table if not exists turnover_tax_brackets (
  country         char(2) not null,
  regime_code     text    not null,
  valid_from      date    not null,
  valid_to        date,
  sequence        integer not null,
  -- The highest base this bracket takes, inclusive. Null: everything above.
  up_to           numeric(18,2),
  nominal_rate    numeric(9,4)  not null,
  deduction       numeric(18,2) not null default 0,
  legal_reference text    not null,
  source_key      text,
  primary key (country, regime_code, valid_from, sequence),
  foreign key (country, regime_code) references turnover_tax_regimes (country, code) on delete cascade,
  constraint turnover_tax_brackets_rate check (nominal_rate >= 0 and nominal_rate < 100),
  constraint turnover_tax_brackets_deduction check (deduction >= 0),
  constraint turnover_tax_brackets_up_to check (up_to is null or up_to > 0),
  constraint turnover_tax_brackets_dates check (valid_to is null or valid_to >= valid_from)
);

comment on table turnover_tax_brackets is
  'The brackets of a regime of turnover_tax_regimes, dated: the highest base each takes (inclusive; null for the last), its nominal rate in percent and the deduction subtracted from base x rate. The tax of a period is its turnover x (base x nominal_rate / 100 - deduction) / base, the base being the window''s turnover. A flat rate is one bracket with no threshold and no deduction.';

alter table turnover_tax_brackets enable row level security;
create policy turnover_tax_brackets_select on turnover_tax_brackets
  for select using (is_known_caller());
grant select on table turnover_tax_brackets to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. What a company declares
-- ---------------------------------------------------------------------------

create table if not exists company_tax_regimes (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references companies(id) on delete cascade,
  regime_code text not null,
  valid_from  date not null,
  valid_to    date,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (company_id, valid_from),
  constraint company_tax_regimes_dates check (valid_to is null or valid_to >= valid_from)
);

comment on table company_tax_regimes is
  'The regime of turnover_tax_regimes a company is under, from the first day of a financial year to the last day of one, or open-ended. No row: the company is under the ordinary regime of its taxes (decision 0080).';

create index if not exists company_tax_regimes_company_idx on company_tax_regimes (company_id, valid_from);

create trigger company_tax_regimes_set_updated_at
  before update on company_tax_regimes
  for each row execute function set_updated_at();

alter table company_tax_regimes enable row level security;
create policy company_tax_regimes_select on company_tax_regimes
  for select using (is_company_member(company_id));
create policy company_tax_regimes_write on company_tax_regimes
  for all using (company_id = any ((select companies_with_capability('company.write'))::uuid[]))
  with check (company_id = any ((select companies_with_capability('company.write'))::uuid[]));

comment on policy company_tax_regimes_select on company_tax_regimes is
  'A member of the company reads the regime it is under, as they read how often it files.';
comment on policy company_tax_regimes_write on company_tax_regimes is
  'company.write, the capability that records how often the company files: the regime decides which declarations it files.';

grant select, insert, update, delete on table company_tax_regimes to authenticated, service_role;

create trigger company_tax_regimes_audit
  after insert or update or delete on company_tax_regimes
  for each row execute function audit_changes('{"company":"company_id","key":["regime_code","valid_from"]}');

create or replace function company_tax_regimes_check()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_regime turnover_tax_regimes;
  v_period declaration_period;
begin
  select r.* into v_regime
    from turnover_tax_regimes r
    join companies c on c.fiscal_country = r.country
   where c.id = new.company_id and r.code = new.regime_code;
  if not found then
    raise exception 'unknown_turnover_regime: % is not a regime of the pack of this company''s fiscal country', new.regime_code
      using errcode = '23514';
  end if;

  -- A regime runs by whole financial years: the turnover it is graded on and
  -- the declarations it replaces are a year's.
  if not exists (select 1 from fiscal_years y
                  where y.company_id = new.company_id and y.start_date = new.valid_from) then
    raise exception 'regime_change_mid_year: % starts on %, which is not the first day of a financial year of this company',
      new.regime_code, new.valid_from
      using errcode = '23514';
  end if;
  if new.valid_to is not null
     and not exists (select 1 from fiscal_years y
                      where y.company_id = new.company_id and y.end_date = new.valid_to) then
    raise exception 'regime_change_mid_year: % ends on %, which is not the last day of a financial year of this company',
      new.regime_code, new.valid_to
      using errcode = '23514';
  end if;

  if exists (select 1 from company_tax_regimes o
              where o.company_id = new.company_id and o.id <> new.id
                and daterange(o.valid_from, o.valid_to, '[]') && daterange(new.valid_from, new.valid_to, '[]')) then
    raise exception 'regime_overlap: this company is already under a regime on part of % to %',
      new.valid_from, coalesce(new.valid_to::text, 'open-ended')
      using errcode = '23514';
  end if;

  -- The form of the regime is filed on its own cadence, which upcoming_filings()
  -- reads from company_filing_periods.
  select coalesce(t.period_default, t.periods[1]) into v_period
    from tax_report_templates t
   where t.country = v_regime.country and t.code = v_regime.report_code;
  if v_period is not null then
    insert into company_filing_periods (company_id, report_code, period)
    values (new.company_id, v_regime.report_code, v_period)
    on conflict (company_id, report_code) do nothing;
  end if;
  return new;
end;
$$;

comment on function company_tax_regimes_check() is
  'Refuses a regime the pack of the company''s fiscal country does not carry (unknown_turnover_regime), one that does not start on the first day of a financial year or end on the last day of one (regime_change_mid_year), and one that overlaps another (regime_overlap); records the cadence of the regime''s form in company_filing_periods.';

revoke execute on function company_tax_regimes_check() from public, anon, authenticated, service_role;

create trigger company_tax_regimes_check
  before insert or update on company_tax_regimes
  for each row execute function company_tax_regimes_check();

create or replace function turnover_tax_regime_at(p_company_id uuid, p_date date)
returns turnover_tax_regimes
language sql
stable
set search_path = public, pg_temp
as $$
  select r.*
    from company_tax_regimes g
    join companies c on c.id = g.company_id
    join turnover_tax_regimes r on r.country = c.fiscal_country and r.code = g.regime_code
   where g.company_id = p_company_id
     and p_date >= g.valid_from
     and (g.valid_to is null or p_date <= g.valid_to);
$$;

comment on function turnover_tax_regime_at(uuid, date) is
  'The regime of turnover_tax_regimes the company is under on that day, or null when it is under the ordinary regime of its taxes.';

revoke execute on function turnover_tax_regime_at(uuid, date) from public, anon;
grant execute on function turnover_tax_regime_at(uuid, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. Under the regime, a document carries none of the taxes it replaces
-- ---------------------------------------------------------------------------

create or replace function documents_refuse_replaced_tax()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_regime turnover_tax_regimes;
  v_tax    record;
begin
  v_regime := turnover_tax_regime_at(new.company_id, coalesce(new.accounting_date, new.document_date));
  if v_regime.code is null then
    return new;
  end if;
  select t.code, t.tax_kind, l.sequence into v_tax
    from document_lines l
    join taxes t on t.id = l.tax_id
   where l.document_id = new.id
     and t.tax_kind = any (v_regime.replaces)
   order by l.sequence
   limit 1;
  if found then
    raise exception 'tax_replaced_by_regime: line % carries %, a tax of kind %, and on % this company is under %, which replaces it; book the line without it',
      v_tax.sequence, v_tax.code, v_tax.tax_kind, coalesce(new.accounting_date, new.document_date), v_regime.code
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function documents_refuse_replaced_tax() is
  'Refuses to post a document a line of which carries a tax of a kind the company''s regime of turnover_tax_regimes replaces on the document''s date (tax_replaced_by_regime).';

revoke execute on function documents_refuse_replaced_tax() from public, anon, authenticated, service_role;

create trigger documents_refuse_replaced_tax
  before update of state on documents
  for each row
  when (new.state = 'posted' and old.state is distinct from 'posted')
  execute function documents_refuse_replaced_tax();

-- ---------------------------------------------------------------------------
-- 4. The return of a period
-- ---------------------------------------------------------------------------

create or replace function turnover_of(p_company_id uuid, p_from date, p_to date)
returns numeric
language sql
stable
set search_path = public, pg_temp
as $$
  select coalesce(sum(l.credit - l.debit), 0)
    from entry_lines l
    join entries e   on e.id = l.entry_id
    join documents d on d.id = e.document_id
    join accounts a  on a.id = l.account_id
   where l.company_id = p_company_id
     and e.state = 'posted'
     and e.kind = 'normal'
     and d.doc_type in ('sale_invoice', 'sale_credit_note')
     and a.account_type in ('income', 'income_other')
     and e.entry_date between p_from and p_to;
$$;

comment on function turnover_of(uuid, date, date) is
  'What the posted sale invoices and credit notes booked between two days put on the income accounts, credit less debit, in the company''s currency: the turnover a tax on turnover is computed on.';

revoke execute on function turnover_of(uuid, date, date) from public, anon;
grant execute on function turnover_of(uuid, date, date) to authenticated, service_role;

create or replace function turnover_tax_return(p_company_id uuid, p_from date, p_to date)
returns table (
  regime_code           text,
  report_code           text,
  period_start          date,
  period_end            date,
  turnover              numeric,
  window_start          date,
  window_end            date,
  window_months         integer,
  window_months_counted integer,
  window_turnover       numeric,
  base                  numeric,
  bracket_sequence      integer,
  bracket_up_to         numeric,
  nominal_rate          numeric,
  deduction             numeric,
  effective_rate        numeric,
  tax                   numeric
)
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_regime   turnover_tax_regimes;
  v_other    turnover_tax_regimes;
  v_bracket  turnover_tax_brackets;
  v_months   integer;
  v_active   date;
  v_counted  integer;
  v_turnover numeric;
  v_window   numeric;
  v_base     numeric;
  v_wstart   date;
  v_wend     date;
  v_rate     numeric;
begin
  if p_from is null or p_to is null or p_to < p_from then
    raise exception 'invalid_period: % to % is not a period', p_from, p_to;
  end if;
  v_regime := turnover_tax_regime_at(p_company_id, p_from);
  v_other  := turnover_tax_regime_at(p_company_id, p_to);
  if v_regime.code is null then
    raise exception 'no_turnover_regime: on % this company is under no regime of a tax on turnover', p_from
      using errcode = 'no_data_found';
  end if;
  if v_other.code is distinct from v_regime.code then
    raise exception 'regime_change_mid_year: % to % is not under one regime from its first day to its last', p_from, p_to;
  end if;

  v_months   := ((extract(year from p_to)::int * 12 + extract(month from p_to)::int)
               - (extract(year from p_from)::int * 12 + extract(month from p_from)::int)) + 1;
  v_turnover := turnover_of(p_company_id, p_from, p_to);

  if v_regime.window_months is null then
    v_base := v_turnover;
    v_window := v_turnover;
    v_counted := v_months;
  else
    v_wend   := case when v_regime.window_includes_period then p_to else p_from - 1 end;
    v_wstart := (date_trunc('month', v_wend) - make_interval(months => v_regime.window_months - 1))::date;
    v_window := turnover_of(p_company_id, v_wstart, v_wend);
    -- The company counts the months it has been active in, from the first
    -- month of its first financial year.
    select date_trunc('month', min(y.start_date))::date into v_active
      from fiscal_years y where y.company_id = p_company_id;
    v_counted := greatest(0, least(v_regime.window_months,
                   ((extract(year from v_wend)::int * 12 + extract(month from v_wend)::int)
                  - (extract(year from greatest(v_wstart, coalesce(v_active, v_wstart)))::int * 12
                     + extract(month from greatest(v_wstart, coalesce(v_active, v_wstart)))::int)) + 1));
    if v_counted >= v_regime.window_months then
      v_base := v_window;
    elsif v_counted = 0 then
      v_base := case v_regime.short_window
                  when 'annualise' then v_turnover * v_regime.window_months / v_months
                  else v_turnover end;
    else
      v_base := case v_regime.short_window
                  when 'annualise' then v_window * v_regime.window_months / v_counted
                  else v_window end;
    end if;
  end if;

  select b.* into v_bracket
    from turnover_tax_brackets b
   where b.country = v_regime.country and b.regime_code = v_regime.code
     and p_to >= b.valid_from and (b.valid_to is null or p_to <= b.valid_to)
     and (b.up_to is null or greatest(v_base, 0) <= b.up_to)
   order by b.up_to nulls last, b.sequence
   limit 1;
  if not found then
    raise exception 'no_turnover_bracket: % has no bracket in force on % for a base of %', v_regime.code, p_to, v_base;
  end if;

  v_rate := case when v_base > 0
                 then greatest((v_base * v_bracket.nominal_rate / 100 - v_bracket.deduction) / v_base, 0)
                 else v_bracket.nominal_rate / 100 end;

  return query select
    v_regime.code, v_regime.report_code, p_from, p_to, v_turnover,
    v_wstart, v_wend, v_regime.window_months::integer, v_counted, v_window,
    v_base, v_bracket.sequence, v_bracket.up_to, v_bracket.nominal_rate, v_bracket.deduction,
    v_rate,
    -- A period whose credit notes outweigh its sales owes nothing.
    greatest(round_amount(v_turnover * v_rate, filing_rounding(p_company_id, v_regime.report_code)), 0);
end;
$$;

comment on function turnover_tax_return(uuid, date, date) is
  'The tax on turnover of one period of a company under a regime of turnover_tax_regimes, with its arithmetic: the turnover of the period, the window the bracket is read over and its turnover, the months of it the company was active and the base they give, the bracket, its nominal rate and deduction, the effective rate (base x nominal_rate / 100 - deduction) / base, and the tax, the turnover times that rate rounded once at the unit of the form. Reads and writes nothing else.';

revoke execute on function turnover_tax_return(uuid, date, date) from public, anon;
grant execute on function turnover_tax_return(uuid, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. What was computed, posted and kept
-- ---------------------------------------------------------------------------

create table if not exists turnover_tax_assessments (
  id                    uuid primary key default gen_random_uuid(),
  company_id            uuid not null references companies(id) on delete cascade,
  regime_code           text not null,
  period_start          date not null,
  period_end            date not null,
  turnover              numeric(18,2) not null,
  window_turnover       numeric(18,2) not null,
  window_months_counted integer not null,
  base                  numeric not null,
  bracket_sequence      integer not null,
  nominal_rate          numeric(9,4) not null,
  deduction             numeric(18,2) not null,
  effective_rate        numeric not null,
  tax                   numeric(18,2) not null,
  entry_id              uuid references entries(id) on delete restrict,
  filing_id             uuid references tax_filings(id) on delete set null,
  created_at            timestamptz not null default now(),
  unique (company_id, regime_code, period_start, period_end)
);

comment on table turnover_tax_assessments is
  'The tax on turnover of a period as post_turnover_tax() computed and posted it: the figures of turnover_tax_return() as they were, the entry that booked the tax (null for a period that owed nothing) and the filing it prepared. Written by that function and by nothing else.';

create index if not exists turnover_tax_assessments_entry_idx on turnover_tax_assessments (entry_id);
create index if not exists turnover_tax_assessments_filing_idx on turnover_tax_assessments (filing_id);

alter table turnover_tax_assessments enable row level security;
create policy turnover_tax_assessments_select on turnover_tax_assessments
  for select using (company_id = any ((select companies_with_capability('filings.read'))::uuid[]));
create policy turnover_tax_assessments_insert on turnover_tax_assessments
  for insert with check (company_id = any ((select companies_with_capability('filings.write'))::uuid[]));

comment on policy turnover_tax_assessments_select on turnover_tax_assessments is
  'filings.read, as the declarations the assessments prepare.';
comment on policy turnover_tax_assessments_insert on turnover_tax_assessments is
  'filings.write: posting the tax of a period prepares its declaration. Never updated nor deleted: what was booked is corrected by a later entry.';

grant select, insert on table turnover_tax_assessments to authenticated, service_role;

create or replace function post_turnover_tax(p_company_id uuid, p_from date, p_to date, p_date date default null)
returns turnover_tax_assessments
language plpgsql
volatile
security invoker
set search_path = public, pg_temp
as $$
declare
  v_return  record;
  v_regime  turnover_tax_regimes;
  v_journal uuid;
  v_payable text;
  v_expense uuid;
  v_debt    uuid;
  v_date    date := coalesce(p_date, p_to);
  v_label   text;
  v_entry   entries;
  v_filing  uuid;
  v_row     turnover_tax_assessments;
begin
  select * into v_return from turnover_tax_return(p_company_id, p_from, p_to);
  v_regime := turnover_tax_regime_at(p_company_id, p_from);

  if exists (select 1 from turnover_tax_assessments a
              where a.company_id = p_company_id and a.regime_code = v_regime.code
                and a.period_start = p_from and a.period_end = p_to) then
    raise exception 'turnover_tax_already_posted: the tax of % to % under % was posted already; a later correction is an entry of its own',
      p_from, p_to, v_regime.code;
  end if;

  v_label := v_regime.report_code || ' ' || p_from || ' — ' || p_to;

  if v_return.tax > 0 then
    select c.miscellaneous_journal_id, d.tax_payable_code
      into v_journal, v_payable
      from companies c
      left join country_defaults d on d.country = c.fiscal_country
     where c.id = p_company_id;
    if v_journal is null then
      raise exception 'no_miscellaneous_journal: this company has no journal for an entry that belongs to no document. Set defaults.journal_roles.miscellaneous in the pack.';
    end if;
    v_expense := account_id_by_code(p_company_id, v_regime.expense_account_code);
    if v_expense is null then
      raise exception 'unknown_tax_account: % names % for the expense of its tax and this chart has no such account',
        v_regime.code, v_regime.expense_account_code;
    end if;
    v_debt := account_id_by_code(p_company_id, v_payable);
    if v_debt is null then
      raise exception 'no_tax_payable_account: the pack of this company names no account of its chart for what a declaration owes. Set defaults.roles.tax_payable in the pack.';
    end if;

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date, reference, description, state)
    values (p_company_id, v_journal, fiscal_year_at(p_company_id, v_date), v_date, v_label, v_label, 'draft')
    returning * into v_entry;
    insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
    values (v_entry.id, p_company_id, v_expense, 10, v_label, v_return.tax, 0),
           (v_entry.id, p_company_id, v_debt,    20, v_label, 0, v_return.tax);
    v_entry := post_entry(v_entry.id);
  end if;

  -- The declaration of the period, prepared: upcoming_filings() reads it, and
  -- the company files it, as every other, on the portal of its administration.
  insert into tax_filings (company_id, report_code, period_start, period_end, state, due_date, prepared_at)
  values (p_company_id, v_regime.report_code, p_from, p_to, 'ready',
          filing_deadline(p_company_id, v_regime.report_code, p_to), now())
  on conflict (company_id, report_code, period_start, period_end) where state <> 'superseded' do nothing
  returning id into v_filing;
  if v_filing is null then
    select f.id into v_filing from tax_filings f
     where f.company_id = p_company_id and f.report_code = v_regime.report_code
       and f.period_start = p_from and f.period_end = p_to and f.state <> 'superseded';
  end if;

  insert into turnover_tax_assessments (company_id, regime_code, period_start, period_end, turnover,
                                        window_turnover, window_months_counted, base, bracket_sequence,
                                        nominal_rate, deduction, effective_rate, tax, entry_id, filing_id)
  values (p_company_id, v_regime.code, p_from, p_to, v_return.turnover,
          v_return.window_turnover, v_return.window_months_counted, v_return.base, v_return.bracket_sequence,
          v_return.nominal_rate, v_return.deduction, v_return.effective_rate, v_return.tax, v_entry.id, v_filing)
  returning * into v_row;
  return v_row;
end;
$$;

comment on function post_turnover_tax(uuid, date, date, date) is
  'Posts the tax on turnover of one period as turnover_tax_return() computes it — the expense on the account the regime names, the debt on the account the pack names for what a declaration owes, one entry in the miscellaneous journal through post_entry() — prepares the filing of the period on the regime''s form and keeps the computation in turnover_tax_assessments. Once per period: turnover_tax_already_posted. A period that owes nothing posts no entry and still prepares its nil return.';

revoke execute on function post_turnover_tax(uuid, date, date, date) from public, anon;
grant execute on function post_turnover_tax(uuid, date, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. A company leaves with its regime and what it posted under it
-- ---------------------------------------------------------------------------

insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('company_tax_regimes', 'exported', 31, null, null,
   'The regime of a tax on turnover the company declared, after the financial years its dates are checked against.'),
  ('turnover_tax_assessments', 'exported', 67, null, null,
   'The tax on turnover of each period as it was computed and posted, after the entries and the filings it points at.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 7. What is to be filed
--
-- `20260921145412` to the letter, with one condition more: the periodic
-- return is not listed for a period a regime that replaces VAT covers from
-- its first day to its last.
-- ---------------------------------------------------------------------------

create or replace function upcoming_filings(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  report_code  text,
  period_start date,
  period_end   date,
  due_date     date,
  state        tax_filing_state,
  filing_id    uuid
)
language sql
stable
security invoker
as $$
  with forms as (
    -- Every form this company has a cadence for, and the periodic return it
    -- files even when nobody has written a cadence down for it.
    select p.report_code, p.period as cadence
      from company_filing_periods p
     where p.company_id = p_company_id
    union
    select periodic_return_code(p_company_id),
           coalesce(
             (select p.period from company_filing_periods p
               where p.company_id = p_company_id
                 and p.report_code = periodic_return_code(p_company_id)),
             (select t.period_default from tax_report_templates t
               join companies c on c.id = p_company_id
              where t.code = periodic_return_code(p_company_id)
                and t.country in (c.country, c.fiscal_country)))
     where periodic_return_code(p_company_id) is not null
  ),
  periods as (
    select f.report_code,
           g.start::date as period_start,
           (g.start + make_interval(months => declaration_period_months(f.cadence))
            - interval '1 day')::date as period_end
    from forms f
    cross join lateral generate_series(
      declaration_period_start(f.cadence, p_from)::timestamp,
      p_to::timestamp,
      make_interval(months => declaration_period_months(f.cadence))
    ) as g(start)
    where f.cadence is not null
  )
  select p.report_code,
         p.period_start,
         p.period_end,
         filing_deadline(p_company_id, p.report_code, p.period_end),
         f.state,
         f.id
  from periods p
  left join tax_filings f
    on f.company_id = p_company_id
   and f.report_code = p.report_code
   and f.period_start = p.period_start
   and f.period_end = p.period_end
   and f.state <> 'superseded'
  -- A company under a regime that replaces VAT for the whole period does not
  -- file the periodic VAT return of that period.
  where not (p.report_code is not distinct from periodic_return_code(p_company_id)
             and coalesce('vat'::tax_kind = any ((turnover_tax_regime_at(p_company_id, p.period_start)).replaces), false)
             and coalesce('vat'::tax_kind = any ((turnover_tax_regime_at(p_company_id, p.period_end)).replaces), false))
  order by p.period_end, p.report_code;
$$;

comment on function upcoming_filings(uuid, date, date) is
  'What this company has to file between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it. The periodic return is left out of the periods a regime of turnover_tax_regimes that replaces VAT covers entirely, and the form of that regime is listed instead. Read-only; sending the reminder is somebody else''s job, because a reminder needs a channel and somebody to operate it.';

revoke execute on function upcoming_filings(uuid, date, date) from public, anon;
grant execute on function upcoming_filings(uuid, date, date) to authenticated, service_role;
