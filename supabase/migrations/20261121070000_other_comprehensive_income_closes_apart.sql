-- Ekwo OS — other comprehensive income closes to its own account.
--
-- `close_fiscal_year()` brings every income and expense account back to nil
-- and books the difference as the result of the year. Under generally
-- accepted accounting principles a few of those accounts are not part of the
-- result: other comprehensive income — a foreign currency translation
-- adjustment, an unrealised gain on a security available for sale — is
-- presented below net income, and at the end of the year it is transferred to
-- a component of equity of its own, accumulated other comprehensive income,
-- and never to retained earnings. The pack us named the gap: its income
-- statement prints caption 21 and two accounts reach it, and its README told
-- a company with such an adjustment not to use them, because the close would
-- have put the figure in retained earnings.
--
-- **The pack says which accounts, and where they go.** A pack may declare
-- `defaults.other_comprehensive_income`: the heads of the codes that are other
-- comprehensive income, the balance-sheet account they close to, and the
-- article that says so. It is compiled into four `country_defaults` columns,
-- all null where the pack says nothing — every pack before this one — and a
-- country without the notion closes exactly as before. A head catches the
-- code it names and every code that begins with it, so an account a company
-- adds under it is caught too, as a statement rule of kind `code_prefix`
-- would catch it.
--
-- **The close.** The result of the year is read over the income and expense
-- accounts the pack does not name; the closing entry still brings every one
-- of them back to nil, and books the accounts it names, summed, on the
-- account they close to — one line, beside the line of the result. An
-- appropriation entry moves the result alone. The function refuses, by name,
-- a pack whose account is missing from the company's chart or does not carry
-- forward, as it already refuses a result account in the wrong place. What it
-- returns gains `other_comprehensive_income`, the figure moved, written as
-- `result` is.
--
-- **The balance sheet before the close says the same.** Since
-- `20261011081256`, `statement_account_matches()` moves the result nobody has
-- closed onto the account the close would leave it on. It now moves the
-- other comprehensive income nobody has closed onto its own account, and the
-- rest onto `year_result_account()`, which is read for that rest only — so a
-- balance sheet drawn before the close and after it put each figure on the
-- same line. The same body otherwise, the same return type, the same grants.
--
-- Additive: four nullable columns, one function added, two functions
-- rewritten with their signature, their grants and their errors.

alter table ekwo.country_defaults
  add column other_comprehensive_income_heads text[],
  add column other_comprehensive_income_closes_to text,
  add column other_comprehensive_income_legal_reference text,
  add column other_comprehensive_income_source_key text;

alter table ekwo.country_defaults
  add constraint country_defaults_other_comprehensive_income_whole
    check (
      (other_comprehensive_income_heads is null
        and other_comprehensive_income_closes_to is null
        and other_comprehensive_income_legal_reference is null
        and other_comprehensive_income_source_key is null)
      or (cardinality(other_comprehensive_income_heads) > 0
        and other_comprehensive_income_closes_to is not null
        and other_comprehensive_income_legal_reference is not null)
    );

comment on column ekwo.country_defaults.other_comprehensive_income_heads is
  'Heads of the codes of the income and expense accounts that are other comprehensive income: a head catches the code it names and every code that begins with it. Closed by close_fiscal_year() to other_comprehensive_income_closes_to, never into the result of the year. Null where the pack declares no other comprehensive income.';
comment on column ekwo.country_defaults.other_comprehensive_income_closes_to is
  'Code of the balance-sheet account other comprehensive income is closed to — accumulated other comprehensive income. Set exactly when other_comprehensive_income_heads is.';
comment on column ekwo.country_defaults.other_comprehensive_income_legal_reference is
  'The article that keeps other comprehensive income out of the result and says where it accumulates.';
comment on column ekwo.country_defaults.other_comprehensive_income_source_key is
  'Key, in the pack''s register of texts, of the text that article is in.';

-- ---------------------------------------------------------------------------
-- other_comprehensive_income_account — where one account closes, when it is
-- other comprehensive income
-- ---------------------------------------------------------------------------

create function ekwo.other_comprehensive_income_account(
  p_company_id uuid,
  p_code       text
)
returns uuid
language sql
stable
set search_path = ekwo, pg_temp
as $$
  select account_id_by_code(c.id, d.other_comprehensive_income_closes_to)
    from companies c
    join country_defaults d on d.country = c.country
   where c.id = p_company_id
     and exists (
       select 1 from unnest(d.other_comprehensive_income_heads) h
        where left(p_code, length(h)) = h
     );
$$;

comment on function ekwo.other_comprehensive_income_account(uuid, text) is
  'The account an income or expense account of a company closes to when its pack declares it other comprehensive income — its code begins with one of country_defaults.other_comprehensive_income_heads — and null otherwise, or where the company has no such account. Read by close_fiscal_year() and statement_account_matches(), so a close and a balance sheet drawn before it put the figure in one place.';

revoke execute on function ekwo.other_comprehensive_income_account(uuid, text) from public, anon;
grant execute on function ekwo.other_comprehensive_income_account(uuid, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- close_fiscal_year — the result without the other comprehensive income, and
-- that income on its own account
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
    'appropriation_entry_id', v_appropriate,
    'closing_entry_id', v_closing
  );
end;
$$;

comment on function ekwo.close_fiscal_year(uuid) is
  'Closes a fiscal year: brings every income and expense account back to nil on the opening journal, books the result of the year where the pack''s closing_style puts it — through an appropriation entry under appropriation_accounts — and the other comprehensive income the pack names on the account it closes to, then marks the year closed. Returns the result and its kind, the other comprehensive income moved, and the entries written.';

-- ---------------------------------------------------------------------------
-- statement_account_matches — the other comprehensive income nobody has
-- closed stands where the close will put it
-- ---------------------------------------------------------------------------

create or replace function ekwo.statement_account_matches(
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
  line_code    text,
  in_progress  numeric
)
language sql
stable
set search_path = ekwo, pg_temp
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
  -- catches: together they hold the result nobody has closed yet, and the
  -- other comprehensive income beside it, each with the account the close
  -- will put it on when the pack names one. After a close they are nil, and
  -- nothing is moved.
  unclosed as (
    select b.id, b.balance,
           other_comprehensive_income_account(p_company_id, b.code) as oci
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
  -- One figure per destination: the other comprehensive income on its own
  -- account, and the rest — the result — on the account year_result_account()
  -- names for its sign.
  moved as (
    select u.oci,
           coalesce(u.oci, year_result_account(p_company_id, sum(u.balance))) as id,
           sum(u.balance) as balance
      from unclosed u
     group by u.oci
    having sum(u.balance) <> 0
  ),
  -- The ledger, with each figure on the account the close would have left it
  -- on. Where the pack names none, nothing moves and the accounts stay
  -- outside the scheme, which `unmapped_accounts()` does not report.
  --
  -- On a balance sheet, what is still in progress travels beside each
  -- balance: the whole of an income or expense account a line catches, and
  -- the moved figure on the account it was moved onto.
  balances as (
    select a.id, a.code, a.name, a.account_type,
           sum(x.balance) as balance, sum(x.in_progress) as in_progress
      from (
        select b.id, b.balance,
               case when st.kind = 'balance_sheet' and not b.carries_forward
                    then b.balance else 0 end as in_progress
          from ledger b
          cross join statement st
         where not exists (
                 select 1 from unclosed u
                   join moved m on m.oci is not distinct from u.oci and m.id is not null
                  where u.id = b.id
               )
        union all
        select m.id, m.balance, m.balance from moved m where m.id is not null
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
  select b.id, b.code, b.name, b.account_type, b.balance, r.line_code, b.in_progress
    from balances b
    left join ranked r on r.id = b.id and r.rank = 1
   order by b.code;
$$;

comment on function ekwo.statement_account_matches(uuid, text, date, date) is
  'Which line of a statement each account of a company falls on, with its balance: cumulative to the end date on a balance sheet, over the period otherwise. On a balance sheet the income and expense accounts no line catches are what nobody has closed yet: the other comprehensive income the pack names stands on the account it closes to, and the result on year_result_account(); in_progress is the part of each balance that is still unclosed — an income or expense account a line catches, or a moved figure — and nil elsewhere. The one place statement_figures() and unmapped_accounts() read.';

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
