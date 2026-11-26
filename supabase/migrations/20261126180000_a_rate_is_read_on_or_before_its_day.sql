-- Ekwo OS — the rate of a currency for a company on a day, read in one place.
--
-- `ekwo rates fetch` (20261126160000) writes the installation's rates: one row
-- of `currency_rates` per currency and day, with no company, in units of the
-- currency for one unit of `instance.reference_currency`. Until this file
-- nothing read them. A document in another currency kept the rate written on
-- it, 1 when none was, and a close read only the company's own row of its last
-- day (decision 0100). This file adds the one reader and its two callers.
--
-- **The reader.** `exchange_rate_on(company, currency, day)` answers the rate
-- of a currency for a company on a day, in the convention of
-- `documents.exchange_rate` — units of that currency for one unit of the
-- company's — with the day the rate is of, its source and where it came from:
--   1. the company's own row for that day exactly (`origin` 'company'), the
--      rate it chose, which always wins; otherwise
--   2. the installation's rows of the last day on or before it that quotes
--      both legs (`origin` 'instance'): the currency's quote divided by the
--      company currency's quote, both of that same day, in `numeric`,
--      rounded to the eight decimals `currency_rates.rate` and
--      `documents.exchange_rate` keep (numeric(18, 8)): a rate, not an amount. A leg in the reference currency itself
--      is 1. Nothing is carried forward into the table: an earlier day is read
--      where it is.
-- A day further back than `p_max_age_days` is not taken: the function refuses
-- by name, `exchange_rate_missing`, rather than answer an old rate. A caller
-- that has its own refusal for a missing rate asks with `p_required` false and
-- gets no row instead.
--
-- **The bound, five days.** The first source, the European Central Bank's
-- reference rates, is published at around 16:00 CET on every TARGET working
-- day, and TARGET closes on Saturdays and Sundays, 1 January, Good Friday,
-- Easter Monday, 1 May, 25 and 26 December. The longest run of days without a
-- publication is Good Friday to Easter Monday, or Saturday 23 to Tuesday 26
-- December when Christmas is a Monday: four days on the rate of the last
-- working day. A fifth covers the next working day before the release of its
-- rate. A longer gap is a series that stopped being fetched, which is said,
-- not papered over. The bound is a parameter, so a reader with another source
-- or another tolerance passes its own.
--
-- **Reader 1, a new document.** `create_document()` takes `exchange_rate` in
-- its header. A rate given is stored as it is. A document in another currency
-- given none takes the reader's rate for its accounting date (its document
-- date when it has none, the day `post_document()` books it on) — when the
-- installation names a reference currency, so reads published rates, and a
-- missing rate is then refused by name; when it names none, the company's own
-- rate of that day if there is one, and otherwise 1, the column's default, as
-- before. The rate stored on a document is never changed by anything here.
--
-- **Reader 2, the close.** `currency_revaluation()` takes its closing rate
-- from the reader, so a currency still open without a company rate for the
-- last day of the year is revalued at the installation's rate on or before
-- it, and says which: two columns, `closing_rate_date` and
-- `closing_rate_source`, are added at the end of its answer. With no rate the
-- closing rate stays null and `revalue_currency_positions()` refuses the close
-- as before, `fx_closing_rate_missing`.
--
-- An installation that never fetched a rate behaves exactly as before.
-- Additive: one function added, two rewritten with their signature, grants
-- and errors.

-- ---------------------------------------------------------------------------
-- 1. exchange_rate_on — the one reader
-- ---------------------------------------------------------------------------

create function ekwo.exchange_rate_on(
  p_company_id    uuid,
  p_currency_code char(3),
  p_on            date,
  p_max_age_days  integer default 5,
  p_required      boolean default true
)
returns table (
  rate      numeric,
  rate_date date,
  source    text,
  origin    text
)
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_home char(3);
  v_ref  char(3);
begin
  if p_currency_code is null or p_on is null then
    raise exception 'exchange_rate_question_incomplete: a rate is asked for a currency and a day'
      using errcode = '22023';
  end if;
  if p_max_age_days is null or p_max_age_days < 0 then
    raise exception 'exchange_rate_max_age_invalid: the number of days a rate may be older than its day is zero or more, not %', p_max_age_days
      using errcode = '22023';
  end if;

  select c.currency_code into v_home from companies c where c.id = p_company_id;
  if v_home is null then
    raise exception 'company_not_found: no company % this caller may read', p_company_id
      using errcode = '22023';
  end if;

  if p_currency_code = v_home then
    return query select 1::numeric, p_on, null::text, 'company_currency'::text;
    return;
  end if;

  -- The company's own rate of that day: the rate it chose.
  return query
    select r.rate, r.rate_date, r.source, 'company'::text
      from currency_rates r
     where r.company_id = p_company_id
       and r.currency_code = p_currency_code
       and r.rate_date = p_on;
  if found then
    return;
  end if;

  -- The installation's, of the last day on or before that quotes both legs.
  select i.reference_currency into v_ref from instance i where i.id = 1;
  if v_ref is not null then
    return query
      with legs as (
        select r.rate_date, r.currency_code, r.rate, r.source
          from currency_rates r
         where r.company_id is null
           and r.currency_code in (p_currency_code, v_home)
           and r.rate_date between p_on - p_max_age_days and p_on
      ),
      days as (
        select d.rate_date,
               case when p_currency_code = v_ref then 1::numeric
                    else (select l.rate from legs l
                           where l.rate_date = d.rate_date and l.currency_code = p_currency_code) end as quote,
               case when v_home = v_ref then 1::numeric
                    else (select l.rate from legs l
                           where l.rate_date = d.rate_date and l.currency_code = v_home) end as base,
               (select string_agg(distinct l.source, ' / ') from legs l where l.rate_date = d.rate_date) as source
          from (select distinct legs.rate_date from legs) d
      )
      select round(days.quote / days.base, 8), days.rate_date, days.source, 'instance'::text
        from days
       where days.quote is not null
         and days.base is not null
       order by days.rate_date desc
       limit 1;
    if found then
      return;
    end if;
  end if;

  if p_required then
    raise exception 'exchange_rate_missing: no rate of % for this company on % nor in the % days before it; give the rate, record the company''s rate of that day, or fetch the installation''s rates (ekwo rates fetch)',
      p_currency_code, p_on, p_max_age_days
      using errcode = '55006';
  end if;
end;
$$;

comment on function ekwo.exchange_rate_on(uuid, char, date, integer, boolean) is
  'The rate of a currency for a company on a day, in units of that currency for one unit of the company''s (the convention of documents.exchange_rate), with the day it is of, its source and its origin: the company''s own row of currency_rates for that day (origin company), otherwise the installation''s rows of the last day on or before it, no more than p_max_age_days earlier, that quote both the currency and the company''s currency against instance.reference_currency, divided in numeric and rounded to the 8 decimals a stored rate keeps (origin instance). Five days by default: the longest closure of the first source''s calendar, plus the day before its release. No rate: exchange_rate_missing, or no row when p_required is false. Security invoker: the caller reads what row level security lets it read. The one reader of currency_rates for a figure; create_document() and currency_revaluation() call it.';

revoke execute on function ekwo.exchange_rate_on(uuid, char, date, integer, boolean) from public, anon;
grant execute on function ekwo.exchange_rate_on(uuid, char, date, integer, boolean) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. create_document — a rate given is kept, a rate not given is proposed
-- ---------------------------------------------------------------------------

create or replace function ekwo.create_document(p_document jsonb, p_lines jsonb)
returns uuid
language plpgsql
security invoker
set search_path = ekwo, pg_temp
as $$
declare
  v_id       uuid;
  v_company  uuid;
  v_currency char(3);
  v_rate     numeric;
begin
  if p_document is null or jsonb_typeof(p_document) <> 'object' then
    raise exception 'document_not_an_object: the header of a document is a JSON object'
      using errcode = '22023';
  end if;

  v_company  := (p_document ->> 'company_id')::uuid;
  v_currency := p_document ->> 'currency_code';
  v_rate     := (p_document ->> 'exchange_rate')::numeric;

  -- No rate given for another currency: the reader's, of the day the
  -- document is booked on. Required once the installation reads published
  -- rates; before that, only the company's own rate of the day is found, and
  -- otherwise the column keeps its default, as it always did.
  if v_rate is null
     and v_currency is not null
     and v_currency is distinct from (select c.currency_code from companies c where c.id = v_company) then
    select r.rate into v_rate
      from exchange_rate_on(
             v_company,
             v_currency,
             coalesce((p_document ->> 'accounting_date')::date, (p_document ->> 'document_date')::date),
             p_required => (select i.reference_currency from instance i where i.id = 1) is not null
           ) r;
  end if;

  insert into documents (
    company_id, doc_type, contact_id, document_date, due_date, accounting_date, number,
    supplier_reference, currency_code, exchange_rate, journal_id, payment_reference, client_ref
  )
  values (
    v_company,
    (p_document ->> 'doc_type')::doc_type,
    (p_document ->> 'contact_id')::uuid,
    (p_document ->> 'document_date')::date,
    (p_document ->> 'due_date')::date,
    (p_document ->> 'accounting_date')::date,
    p_document ->> 'number',
    p_document ->> 'supplier_reference',
    v_currency,
    coalesce(v_rate, 1),
    (p_document ->> 'journal_id')::uuid,
    p_document ->> 'payment_reference',
    p_document ->> 'client_ref'
  )
  returning id into v_id;

  perform replace_document_lines(v_id, p_lines);
  return v_id;
end;
$$;

comment on function ekwo.create_document(jsonb, jsonb) is
  'Creates a draft and its lines in one statement: a refused line creates nothing, rather than an empty draft. The header names company_id, doc_type, contact_id, document_date and currency_code, and optionally due_date, accounting_date, number, supplier_reference, exchange_rate, journal_id, payment_reference and client_ref. A document in another currency with no exchange_rate takes exchange_rate_on() for its accounting date, or its document date — refused by name (exchange_rate_missing) when the installation names a reference currency and has no rate close enough, 1 as before when it names none and the company has no rate of that day. Security invoker.';

revoke execute on function ekwo.create_document(jsonb, jsonb) from public, anon;
grant execute on function ekwo.create_document(jsonb, jsonb) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. currency_revaluation — the closing rate from the reader, and which one
-- ---------------------------------------------------------------------------

-- Two columns more in its answer: a function's result type is changed by
-- dropping it. Nothing depends on it in the catalogue; the close calls it by
-- name and reads its columns by name.
drop function ekwo.currency_revaluation(uuid, date);

create function ekwo.currency_revaluation(
  p_company_id uuid,
  p_at         date
)
returns table (
  account_id          uuid,
  account_code        text,
  contact_id          uuid,
  currency_code       char(3),
  position_kind       text,
  amount_currency     numeric,
  carrying_amount     numeric,
  closing_rate        numeric,
  revalued_amount     numeric,
  difference          numeric,
  closing_rate_date   date,
  closing_rate_source text
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
         round_amount(p.amount_currency / r.rate, (select rnd from company)) - p.carrying,
         r.rate_date, r.source
    from positions p
    left join lateral exchange_rate_on(p_company_id, p.currency_code, p_at, p_required => false) r on true
   where p.amount_currency <> 0
   order by p.code, p.currency_code, p.contact_id;
$$;

comment on function ekwo.currency_revaluation(uuid, date) is
  'The foreign-currency positions of a company still open on a day, and what stating them at the closing rate of that day moves: per account, counterparty and currency, the amount in the currency, the amount the ledger carries it at, the closing rate exchange_rate_on() gives for that day — the company''s own row of currency_rates for the day, otherwise the installation''s rate on or before it — with the day it is of and its source (all three null where there is none), the amount at that rate and the difference. A position is the open part of the lines in that currency of a receivable or payable account — what no matching dated on or before the day settled — or the whole of the lines in that currency of the account of a bank account kept in it. What close_fiscal_year() books, and nothing is written here.';

revoke execute on function ekwo.currency_revaluation(uuid, date) from public, anon;
grant execute on function ekwo.currency_revaluation(uuid, date) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
