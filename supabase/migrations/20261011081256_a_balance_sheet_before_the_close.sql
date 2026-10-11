-- Ekwo OS — a balance sheet drawn before the close carries the result of the
-- year in progress.
--
-- A balance sheet is read cumulatively, to the end of the period, and its
-- lines are caught by the rules of the pack's scheme. Until a year is closed
-- its result is still spread over the income and expense accounts, and a
-- national scheme catches none of them: the Belgian frame reads class 1 to 5,
-- the French liasse its own ranges of the balance sheet. The assets then held
-- the profit the year had earned, and the equity side did not — a Belgian
-- company in the middle of its year printed TOTAL DE L'ACTIF 3 025,00 and
-- TOTAL DU PASSIF 525,00, the 2 500,00 of the year nowhere, while
-- `trial_balance()` said the books balanced. Only the generic framework
-- balanced, because it catches income and expense by account type.
--
-- The rule, stated once in `statement_account_matches()`, the function every
-- statement is summed from:
--
--   On a balance sheet, the balance of every income or expense account that
--   no line of the scheme catches is the result nobody has closed yet. It is
--   moved, as one figure, onto the account the close would have left it on,
--   and that account then reaches its line through the pack's own rules —
--   `14` in Belgium, `DI` in France, the retained earnings of a pack that
--   closes straight into them. Assets equal liabilities and equity to the
--   cent, before the close as after it.
--
-- The account is the one `year_result_account()` names, which is the choice
-- `fec_lines()` already made for the *à-nouveaux* of a year nobody closed:
-- the current-year result account of a pack whose style is
-- `result_accounts`, and retained earnings — the company's own first, for a
-- profit — for `retained_earnings` and `appropriation_accounts`, where an
-- appropriation account is part of the income statement and never what a
-- balance sheet shows. `fec_lines()` is republished on it, so the opening
-- line of a file and the equity line of a statement cannot carry an unclosed
-- result to two places.
--
-- Nothing is counted twice. After `close_fiscal_year()` the closing entry,
-- which a balance sheet keeps, has brought every income and expense account
-- back to nil and booked the result on that same account, so there is
-- nothing left to move. A period that ends inside a closed year stops before
-- the closing entry, and the result to that day is moved, which is what an
-- interim balance sheet shows. A scheme that already catches income and
-- expense on a line of its own — the generic one, by account type — keeps
-- doing so: only what no line catches is moved. And the result of an earlier
-- year nobody closed is still in those accounts, so it is moved too, onto
-- the same line, because it is equally unallocated.
--
-- Where the pack names no account for the result, nothing is moved and the
-- accounts stay outside the scheme as before: inventing an equity account
-- would print a figure on a line the pack never chose. Every pack of this
-- checkout names one, and `tests/statement_result_in_progress.test.ts` holds
-- each of them to a balanced balance sheet.

-- ---------------------------------------------------------------------------
-- year_result_account — where the result of a year nobody closed stands
-- ---------------------------------------------------------------------------

create or replace function year_result_account(
  p_company_id uuid,
  p_balance    numeric
)
returns uuid
language sql
stable
as $$
  -- `p_balance` is debit minus credit over the income and expense accounts,
  -- so a credit — a negative figure — is a profit, as `close_fiscal_year()`
  -- reads it. A company may name its own retained earnings account, and the
  -- close prefers it for a profit; the same preference here, or the two would
  -- carry the result to two different places.
  select coalesce(
           case when p_balance < 0 and d.closing_style is distinct from 'result_accounts'
                then c.retained_earnings_account_id end,
           account_id_by_code(c.id,
             case d.closing_style
               when 'result_accounts' then
                 case when p_balance < 0 then d.current_year_result_profit_code
                      else d.current_year_result_loss_code end
               when 'appropriation_accounts' then
                 case when p_balance < 0 then d.retained_earnings_code
                      else coalesce(d.retained_earnings_loss_code, d.retained_earnings_code) end
               when 'retained_earnings' then
                 case when p_balance < 0 then d.retained_earnings_code
                      else coalesce(d.retained_earnings_loss_code, d.retained_earnings_code) end
             end))
    from companies c
    left join country_defaults d on d.country = c.country
   where c.id = p_company_id;
$$;

comment on function year_result_account(uuid, numeric) is
  'The balance-sheet account the result of a year nobody has closed stands on, for a balance of the income and expense accounts (debit minus credit, so a profit is negative): the current-year result account of a result_accounts pack, retained earnings — the company''s own first, for a profit — otherwise. Null when the pack names none. Read by statement_account_matches() and fec_lines(), so a balance sheet and an opening balance put it in one place.';

-- ---------------------------------------------------------------------------
-- statement_rule_catches — whether one rule of a scheme takes one account
--
-- The predicate the ranking below has always applied, named, because the
-- balance sheet now asks it twice: once to know which income and expense
-- accounts no line catches, once to rank the lines that catch an account.
-- Two copies of it would one day disagree about what is on the statement.
-- ---------------------------------------------------------------------------

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
  select case p_rule.rule_kind
           when 'account_code' then p_code = p_rule.code_from
           when 'code_prefix'  then left(p_code, length(p_rule.code_from)) = p_rule.code_from
           when 'code_range'   then left(p_code, length(p_rule.code_from)) >= p_rule.code_from
                                and left(p_code, length(p_rule.code_to))   <= p_rule.code_to
           else                     p_account_type = p_rule.account_type
         end
     and case p_rule.balance_side
           when 'debit'  then p_balance > 0
           when 'credit' then p_balance < 0
           else               true
         end;
$$;

comment on function statement_rule_catches(statement_line_rules, text, account_type, numeric) is
  'Whether a rule of a statement line takes an account with this code, type and balance: by one code, by the head of the code, by a range of heads or by account type, on the side the rule names. The one spelling of that test, read by statement_account_matches().';

-- ---------------------------------------------------------------------------
-- statement_account_matches — the result of the year in progress reaches
-- the equity side of a balance sheet
-- ---------------------------------------------------------------------------

create or replace function statement_account_matches(
  p_company_id     uuid,
  p_statement_code text,
  p_from           date,
  p_to             date
)
returns table (
  account_id   uuid,
  account_code text,
  account_name text,
  account_type account_type,
  balance      numeric,
  line_code    text
)
language sql
stable
as $$
  with statement as (
    select s.code, s.kind from statement_templates s where s.code = p_statement_code
  ),
  ledger as (
    select a.id, a.code, a.name, a.account_type, a.carries_forward,
           round_amount(coalesce(sum(l.balance), 0), rounding_of(p_company_id)) as balance
      from accounts a
      join entry_lines l on l.account_id = a.id
      join entries e on e.id = l.entry_id
      cross join statement st
     where a.company_id = p_company_id
       and e.state = 'posted'
       and case when st.kind = 'balance_sheet'
                then e.entry_date <= p_to
                else e.entry_date between p_from and p_to
           end
       -- An income statement is what the period earned, and the entry that
       -- closes a year is not that: it books the mirror image of every income
       -- and expense account so they start the next year at nil. Left in, a
       -- closed year reads as a result of zero. An allocation section leaves
       -- it out for the same reason and keeps the appropriation entry, which
       -- is the movement it exists to show. A balance sheet keeps both, and
       -- must: together they are what puts the result on the line it shows.
       and (st.kind not in ('income_statement', 'allocation') or e.kind <> 'closing')
     group by a.id, a.code, a.name, a.account_type, a.carries_forward
  ),
  -- On a balance sheet, the income and expense accounts no line of the scheme
  -- catches: together they hold the result nobody has closed yet. After a
  -- close they are nil, and nothing is moved.
  unclosed as (
    select b.id, b.balance
      from ledger b
      cross join statement st
     where st.kind = 'balance_sheet'
       and not b.carries_forward
       and not exists (
         select 1 from statement_line_rules r
          where r.statement_code = p_statement_code
            and statement_rule_catches(r, b.code, b.account_type, b.balance)
       )
  ),
  moved as (
    select year_result_account(p_company_id, sum(u.balance)) as id,
           sum(u.balance) as balance
      from unclosed u
    having sum(u.balance) <> 0
  ),
  -- The ledger, with that result on the account the close would have left it
  -- on. Where the pack names none, nothing moves and the accounts stay
  -- outside the scheme, which `unmapped_accounts()` does not report.
  balances as (
    select a.id, a.code, a.name, a.account_type, sum(x.balance) as balance
      from (
        select b.id, b.balance
          from ledger b
         where not exists (select 1 from unclosed u where u.id = b.id)
            or not exists (select 1 from moved m where m.id is not null)
        union all
        select m.id, m.balance from moved m where m.id is not null
      ) x
      join accounts a on a.id = x.id
     group by a.id, a.code, a.name, a.account_type
  ),
  ranked as (
    select b.id, b.code, b.name, b.account_type, b.balance, r.line_code,
           row_number() over (
             partition by b.id
             order by case r.rule_kind
                        when 'account_code' then 1
                        when 'code_range'   then 2
                        when 'code_prefix'  then 2
                        else                     3
                      end,
                      length(coalesce(r.code_from, '')) desc,
                      r.sequence, r.line_code
           ) as rank
      from balances b
      join statement_line_rules r on r.statement_code = p_statement_code
     where statement_rule_catches(r, b.code, b.account_type, b.balance)
  )
  select b.id, b.code, b.name, b.account_type, b.balance, r.line_code
    from balances b
    left join ranked r on r.id = b.id and r.rank = 1
   order by b.code;
$$;

comment on function statement_account_matches(uuid, text, date, date) is
  'Which line of a statement each account of a company falls on, with its balance: cumulative to the end date on a balance sheet, over the period otherwise. On a balance sheet the income and expense accounts no line catches are the result nobody has closed yet, and stand as one balance on year_result_account(). The one place financial_statement() and unmapped_accounts() read.';

-- ---------------------------------------------------------------------------
-- fec_lines — republished on year_result_account(), and otherwise unchanged
-- ---------------------------------------------------------------------------

create or replace function fec_lines(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  journal_code   text,
  journal_lib    text,
  ecriture_num   text,
  ecriture_date  date,
  compte_num     text,
  compte_lib     text,
  comp_aux_num   text,
  comp_aux_lib   text,
  piece_ref      text,
  piece_date     date,
  ecriture_lib   text,
  debit          numeric,
  credit         numeric,
  ecriture_let   text,
  date_let       date,
  valid_date     date,
  montant_devise numeric,
  idevise        text
)
language plpgsql
stable
as $$
declare
  v_year        fiscal_years%rowtype;
  v_defaults    country_defaults%rowtype;
  v_journal     journals%rowtype;
  v_label       text;
  v_number      text;
  v_result      numeric := 0;
  -- The file is the ledger written out, so the opening lines carry the same
  -- decimals as the movements below them.
  v_round       money_rounding;
  v_carried     integer := 0;
  v_account     uuid;
  v_result_code text;
  v_result_name text;
  v_carries     boolean;
begin
  v_round := rounding_of(p_company_id);

  -- 1. Is this the file of a whole financial year? Only then are there
  --    opening balances to carry.

  select f.* into v_year
    from fiscal_years f
   where f.company_id = p_company_id
     and f.start_date = p_from
     and f.end_date = p_to;

  if found then
    -- What stands on the day before the year opens. `trial_balance` is where
    -- this repository computes a cumulative balance, and computing it a
    -- second time here is how the two would start to disagree.
    select coalesce(round_amount(sum(t.opening_balance) filter (where not a.carries_forward),
                                 v_round), 0),
           count(*) filter (where a.carries_forward
                              and round_amount(t.opening_balance, v_round) <> 0)
      into v_result, v_carried
      from trial_balance(p_company_id, p_from, p_to) t
      join accounts a on a.id = t.account_id;

    -- A first set of books has nothing to carry, and asks the pack for
    -- nothing. Everything below is needed only when there is a balance.
    if v_carried > 0 or v_result <> 0 then
      select d.* into v_defaults
        from companies c
        join country_defaults d on d.country = c.country
       where c.id = p_company_id;

      select j.* into v_journal from journals j where j.id = opening_journal_id(p_company_id);
      if not found then
        raise exception 'no_opening_journal: the pack of this company names no journal of type opening, and the opening balances of a financial year are booked on one. Set defaults.journal_roles.opening in the pack, which fills country_defaults.opening_journal_code.'
          using errcode = '55006';
      end if;

      v_label := coalesce(v_defaults.opening_entry_label, 'Opening balance');

      -- One entry, so the file has one balanced *à-nouveaux* rather than as
      -- many single-sided entries as there are accounts. The number is built
      -- from the journal the pack names and the day the year opens, which
      -- makes it stable across two exports of the same year and distinct
      -- between years — including two short years inside one calendar year.
      v_number := v_journal.code || '-' || to_char(v_year.start_date, 'YYYYMMDD');

      -- 2. The result of the years that are not closed yet, on the account
      --    the close would have left it on. `year_result_account()` makes
      --    that choice, and the balance sheet asks it the same question, so
      --    the opening line of a file and the equity line of a statement
      --    carry an unclosed result to one place.
      if v_result <> 0 then
        v_account := year_result_account(p_company_id, v_result);

        if v_account is null then
          raise exception 'no_result_account: the books hold a result of % that no year has closed, and the country model of this company names no balance-sheet account to carry it to. Set defaults.closing_style and the account roles it needs in the pack.',
            to_char(-v_result, amount_text_format(v_round))
            using errcode = '55006';
        end if;

        select a.code, a.name, a.carries_forward
          into v_result_code, v_result_name, v_carries
          from accounts a where a.id = v_account;

        if not v_carries then
          raise exception 'no_result_account: % is an income or expense account, and an opening balance is made of the balance sheet. The country model names it for a result that no year has closed; name an account that carries forward.',
            v_result_code
            using errcode = '55006';
        end if;
      end if;

      -- 3. The lines themselves. The account rows and the result row share
      --    one shape, so the side is chosen once: a positive balance is a
      --    debit, and a sign never reaches the file.
      return query
        with opening as (
          select t.account_code as code,
                 t.account_name as name,
                 round_amount(t.opening_balance, v_round) as balance
            from trial_balance(p_company_id, p_from, p_to) t
            join accounts a on a.id = t.account_id
           where a.carries_forward
             and round_amount(t.opening_balance, v_round) <> 0
          union all
          select v_result_code, v_result_name, v_result
           where v_result <> 0
        )
        select v_journal.code,
               v_journal.name,
               v_number,
               p_from,
               o.code,
               o.name,
               null::text,
               null::text,
               v_number,
               p_from,
               v_label,
               -- Down to the scale the ledger keeps, so an opening line and a
               -- movement line come back in the same shape.
               round_amount(case when o.balance > 0 then o.balance else 0 end, v_round),
               round_amount(case when o.balance < 0 then -o.balance else 0 end, v_round),
               null::text,
               null::date,
               p_from,
               null::numeric,
               null::text
          from opening o
         order by o.code;
    end if;
  end if;

  -- 4. The movements of the period, as before, less the entries the close
  --    wrote inside it.

  return query
    select j.code,
           j.name,
           e.number,
           e.entry_date,
           a.code,
           a.name,
           c.auxiliary_code,
           case when c.auxiliary_code is not null then c.name end,
           coalesce(d.number, d.supplier_reference, e.reference, e.number),
           coalesce(d.document_date, e.entry_date),
           coalesce(nullif(l.name, ''), e.description, a.name),
           l.debit,
           l.credit,
           l.matching_number,
           (select max(r.matched_at) from reconciliations r
             where r.debit_line_id = l.id or r.credit_line_id = l.id),
           coalesce(e.posted_at::date, e.entry_date),
           case when l.currency_code is not null and l.currency_code <> co.currency_code
                then l.amount_currency end,
           -- `char(3)` where the column of this function is `text`: RETURN
           -- QUERY matches types exactly, where the SQL body this replaces
           -- coerced them on the way out.
           case when l.currency_code is not null and l.currency_code <> co.currency_code
                then l.currency_code::text end
      from entry_lines l
      join entries e   on e.id = l.entry_id
      join journals j  on j.id = e.journal_id
      join accounts a  on a.id = l.account_id
      join companies co on co.id = l.company_id
      left join contacts c on c.id = l.contact_id
      left join documents d on d.id = e.document_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
       and e.kind not in ('closing', 'appropriation')
     order by e.entry_date, e.number, l.sequence, l.id;
end;
$$;

-- `create or replace` keeps the privileges a function already had; the two
-- new ones are granted as every reader of a statement is.
revoke execute on all functions in schema public from public;

revoke execute on function year_result_account(uuid, numeric) from public, anon;
grant execute on function year_result_account(uuid, numeric) to authenticated, service_role;
revoke execute on function statement_rule_catches(statement_line_rules, text, account_type, numeric) from public, anon;
grant execute on function statement_rule_catches(statement_line_rules, text, account_type, numeric) to authenticated, service_role;
