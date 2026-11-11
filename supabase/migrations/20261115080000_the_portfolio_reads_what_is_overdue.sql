-- Ekwo OS — what customers and suppliers owe past their date, across the
-- portfolio, one row per company.
--
-- A firm asks two questions of all the books it keeps on a Monday morning:
-- which returns fall due (`portfolio_upcoming_filings()`), and who is paying
-- late, on either side. The second was asked company by company:
-- `aged_balance()` once for the customers and once for the suppliers of each
-- company, and the sums worked out by whoever called. `portfolio_overview()`
-- asks it once, with the same answer.
--
-- **Built on `aged_balance()`, never beside it** (decision 0040). Each company
-- of the portfolio is read through the per-company function in a lateral
-- join, for both groups, so "overdue" means here exactly what the ageing
-- shows: what is still open on a reconcilable receivable or payable account,
-- after the matching, past its due date on `p_on`. Nothing is recomputed: the
-- open amount is the ageing's `total`, the overdue amount its four buckets
-- after the due date, the amount over ninety days its last bucket. The
-- figures are the ageing's, already at the decimals of the company's
-- currency, and the currency is on the row: a portfolio holds companies that
-- keep their books in different currencies, and two of its rows are never
-- added together.
--
-- **The portfolio is the companies the caller holds `entries.read` on**, the
-- capability the ageing reads the ledger with. Decision 0040 filters the
-- calendar of returns on `filings.read`, the capability that reading needs,
-- because a company's row is visible to people its declarations are closed
-- to; the same reasoning, applied to the ledger, filters on `entries.read`.
-- A company whose ledger the caller may not read is absent, rather than
-- listed with nothing owed.
--
-- **Silence is not an output.** Every company of the portfolio is a row,
-- with zeros where nothing is open: a company left out would be
-- indistinguishable from one that owes nothing. A count says how many
-- parties are late on each side; the open lines that name nobody count as
-- one party, the way the ageing groups them.
--
-- `security invoker`: it reads what the caller could have read company by
-- company, through the same policies.

create function ekwo.portfolio_overview(
  p_on date default current_date
)
returns table (
  company_id                uuid,
  company_name              text,
  currency_code             text,
  customers_open            numeric,
  customers_overdue         numeric,
  customers_overdue_over_90 numeric,
  customers_late            integer,
  suppliers_open            numeric,
  suppliers_overdue         numeric,
  suppliers_overdue_over_90 numeric,
  suppliers_late            integer
)
language plpgsql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
begin
  if p_on is null then
    raise exception 'invalid_date: the day the portfolio is read on is required';
  end if;

  return query
  with portfolio as (
    select c.id, c.name, c.currency_code::text as currency_code
      from companies c
     where c.id = any (companies_with_capability('entries.read'))
  ),
  -- One row per party and side: the ageing groups by contact and account,
  -- and a party late on two accounts is one late party.
  parties as (
    select p.id as company_id,
           g.side,
           a.contact_id,
           sum(coalesce(a.total, 0)) as open_amount,
           sum(coalesce(a.days_1_30, 0) + coalesce(a.days_31_60, 0)
               + coalesce(a.days_61_90, 0) + coalesce(a.days_over_90, 0)) as overdue,
           sum(coalesce(a.days_over_90, 0)) as over_90
      from portfolio p
      cross join (values ('receivable'), ('payable')) as g(side)
      cross join lateral aged_balance(p.id, p_on, g.side) a
     group by p.id, g.side, a.contact_id
  ),
  sides as (
    select x.company_id,
           x.side,
           sum(x.open_amount) as open_amount,
           sum(x.overdue) as overdue,
           sum(x.over_90) as over_90,
           (count(*) filter (where x.overdue > 0))::integer as late
      from parties x
     group by x.company_id, x.side
  )
  select p.id,
         p.name,
         p.currency_code,
         coalesce(r.open_amount, 0),
         coalesce(r.overdue, 0),
         coalesce(r.over_90, 0),
         coalesce(r.late, 0),
         coalesce(s.open_amount, 0),
         coalesce(s.overdue, 0),
         coalesce(s.over_90, 0),
         coalesce(s.late, 0)
    from portfolio p
    left join sides r on r.company_id = p.id and r.side = 'receivable'
    left join sides s on s.company_id = p.id and s.side = 'payable'
   order by p.name, p.id;
end;
$$;

comment on function ekwo.portfolio_overview(date) is
  'What customers and suppliers owe past their due date on a day, one row per company the caller holds entries.read on, and for no other: aged_balance() of each company, for both groups, summed. open is the ageing''s total, overdue the four buckets after the due date, overdue_over_90 the last one, late the number of parties with something overdue (the open lines that name nobody count as one). Amounts are in the company''s currency_code, never added across rows. Every company of the portfolio is a row, with zeros where nothing is open. Invoker: it reads what the caller could have read company by company.';

revoke execute on function ekwo.portfolio_overview(date) from public, anon;
grant execute on function ekwo.portfolio_overview(date) to authenticated, service_role;
