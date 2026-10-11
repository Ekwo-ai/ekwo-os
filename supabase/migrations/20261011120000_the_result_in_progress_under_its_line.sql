-- Ekwo OS — the result of the year in progress, as a sub-line of the line
-- that carries it.
--
-- Since `20261011081256_a_balance_sheet_before_the_close`, a balance sheet
-- drawn before the close carries the result nobody has closed yet on the line
-- the close would leave it on. On some schemes that line is the result of the
-- year and nothing else — a French DI takes 120 and 129. On others it also
-- takes what earlier years left: a Belgian rubric 14 takes 140 and 141, the
-- result brought forward, and a scheme that closes into retained earnings
-- takes every year before this one on the same line. There the figure is
-- right and the reader cannot tell the year in progress from the rest.
--
-- So the pack says which, per balance sheet, from its own model:
-- `statement_templates.result_in_progress` is `combined` or `alone`, and a
-- combined scheme names the label of the sub-line
-- (`result_in_progress_name`, translated in `result_in_progress_name_i18n`).
-- `ekwo pack check` works the answer out of the scheme and the chart and
-- refuses a pack that leaves it undecided or contradicts its own model. No
-- country is named here: the rule is a column, the label is the pack's.
--
-- Three functions carry it, and none of them changes a figure:
--
--   `statement_account_matches()` returns one more column, `in_progress`:
--       the part of an account's balance that is the result nobody closed —
--       the whole balance of an income or expense account a line of the
--       balance sheet catches, the amount moved onto the account
--       `year_result_account()` names, and nil for everything else and on
--       every statement that is not a balance sheet.
--
--   `statement_figures()` is what `financial_statement()` computed, with that
--       column summed per line and read with the line's sign. Summed once:
--       `financial_statement()` is republished on it with the same table, and
--       its rows, its totals and every filing read from it are unchanged.
--
--   `financial_statement_of_kind()`, the statement an application draws,
--       adds under each line of a combined balance sheet that carries a
--       result in progress one row: its key is the line's code followed by
--       `:result_in_progress`, its parent the line, its name the pack's
--       label, its amount the result in progress. It is a detail of its
--       parent, never a line of the scheme: no total names it, and a reader
--       that adds up lines skips it as it skips any child of a line it has
--       already counted. A line that is the result alone shows nothing more,
--       and after a close there is nothing in progress, so nothing either.

-- ---------------------------------------------------------------------------
-- The rule, per balance sheet
-- ---------------------------------------------------------------------------

alter table statement_templates
  add column result_in_progress text,
  add column result_in_progress_name text,
  add column result_in_progress_name_i18n jsonb not null default '{}'::jsonb;

alter table statement_templates
  add constraint statement_templates_result_in_progress_check
    check (result_in_progress in ('combined', 'alone')),
  add constraint statement_templates_result_in_progress_kind
    check (result_in_progress is null or kind = 'balance_sheet'),
  add constraint statement_templates_result_in_progress_name
    check (case when result_in_progress = 'combined' then result_in_progress_name is not null
                else result_in_progress_name is null end);

comment on column statement_templates.result_in_progress is
  'On a balance sheet: whether the line that receives the result of the year in progress also takes other balances (combined: the result brought forward, retained earnings, reserves) or is the result alone. A combined scheme shows the result in progress as a sub-line in financial_statement_of_kind(). Set by the pack and checked against its model by ekwo pack check; null on any other statement.';
comment on column statement_templates.result_in_progress_name is
  'The label of the sub-line of the result in progress, in the language of the pack. Set exactly when result_in_progress is combined.';
comment on column statement_templates.result_in_progress_name_i18n is
  'The same label in the other languages of the pack, by language code.';

-- ---------------------------------------------------------------------------
-- statement_account_matches — which part of a balance is the result in
-- progress
--
-- The same function as `20261011081256`, with `in_progress` at the end. A new
-- column is a new return type, which `create or replace` cannot give, so the
-- function is dropped and created again; every caller reads it by column
-- name, and the grants are given again below.
-- ---------------------------------------------------------------------------

drop function statement_account_matches(uuid, text, date, date);

create function statement_account_matches(
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
  --
  -- On a balance sheet, what is still in progress travels beside each
  -- balance: the whole of an income or expense account a line catches, and
  -- the moved result on the account it was moved onto.
  balances as (
    select a.id, a.code, a.name, a.account_type,
           sum(x.balance) as balance, sum(x.in_progress) as in_progress
      from (
        select b.id, b.balance,
               case when st.kind = 'balance_sheet' and not b.carries_forward
                    then b.balance else 0 end as in_progress
          from ledger b
          cross join statement st
         where not exists (select 1 from unclosed u where u.id = b.id)
            or not exists (select 1 from moved m where m.id is not null)
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

comment on function statement_account_matches(uuid, text, date, date) is
  'Which line of a statement each account of a company falls on, with its balance: cumulative to the end date on a balance sheet, over the period otherwise. On a balance sheet the income and expense accounts no line catches are the result nobody has closed yet, and stand as one balance on year_result_account(); in_progress is the part of each balance that is that result — an income or expense account a line catches, or the moved result — and nil elsewhere. The one place statement_figures() and unmapped_accounts() read.';

-- ---------------------------------------------------------------------------
-- statement_figures — a statement, with the result in progress of each line
-- ---------------------------------------------------------------------------

create or replace function statement_figures(
  p_company_id     uuid,
  p_statement_code text,
  p_from           date,
  p_to             date
)
returns table (
  line_code    text,
  parent_code  text,
  name         text,
  sequence     integer,
  is_total     boolean,
  amount       numeric,
  xbrl_element text,
  in_progress  numeric
)
language plpgsql
stable
as $$
declare
  -- line code -> amount: the lines summed from the ledger, then the totals
  -- `evaluate_totals()` derives from them.
  v_values   jsonb := '{}'::jsonb;
  -- line code -> the part of it that is the result in progress, read with the
  -- sign of the line. Lines summed from the ledger only: a total is never
  -- given a sub-line.
  v_progress jsonb := '{}'::jsonb;
  v_formulas jsonb := '[]'::jsonb;
  v_rows     jsonb := '[]'::jsonb;
  -- A statement is the ledger read back, so it is written with the decimals
  -- of the currency the ledger is kept in.
  v_round    money_rounding;
  r          record;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  v_round := rounding_of(p_company_id);
  if not exists (select 1 from statement_templates s where s.code = p_statement_code) then
    raise exception 'unknown_statement: % is not a statement of this installation', p_statement_code;
  end if;

  -- 1. The lines summed from the ledger. All of them first, whatever their
  --    place in the scheme: a scheme prints a subtotal above the lines it adds
  --    up — every balance sheet does — and only a total that names another
  --    total depends on an order, which the evaluator keeps.
  select coalesce(jsonb_object_agg(l.code,
           round_amount(coalesce(s.balance, 0) * l.sign, v_round)), '{}'::jsonb),
         coalesce(jsonb_object_agg(l.code,
           round_amount(coalesce(s.in_progress, 0) * l.sign, v_round)), '{}'::jsonb)
    into v_values, v_progress
    from statement_line_templates l
    left join (
      select m.line_code,
             round_amount(sum(m.balance), v_round) as balance,
             round_amount(sum(m.in_progress), v_round) as in_progress
        from statement_account_matches(p_company_id, p_statement_code, p_from, p_to) m
       where m.line_code is not null
       group by m.line_code
    ) s on s.line_code = l.code
   where l.statement_code = p_statement_code
     and not l.is_total;

  -- 2. The totals, worked out by the one evaluator the declaration forms use.
  --    A statement prints its whole frame, so every total comes back, and the
  --    sign it reads the line with is the factor.
  select coalesce(jsonb_agg(jsonb_build_object(
           'key', l.code, 'plus', to_jsonb(l.plus_lines), 'minus', to_jsonb(l.minus_lines),
           'factor', l.sign, 'sequence', l.sequence
         ) order by l.sequence, l.code), '[]'::jsonb)
    into v_formulas
    from statement_line_templates l
   where l.statement_code = p_statement_code
     and l.is_total;

  v_values := v_values || evaluate_totals(v_values, v_formulas, v_round, true);

  -- 3. The frame, in the order it is printed. Every line is returned, nil
  --    included: a statement is read top to bottom and tied out, where a
  --    declaration prints what it has — which is why `vat_return()` drops a
  --    nil box and this does not.
  for r in
    select l.code, l.parent_code, l.name, l.sequence, l.is_total, l.xbrl_element
      from statement_line_templates l
     where l.statement_code = p_statement_code
     order by l.sequence, l.code
  loop
    v_rows := v_rows || jsonb_build_array(jsonb_build_object(
      'line_code', r.code, 'parent_code', r.parent_code, 'name', r.name,
      'sequence', r.sequence, 'is_total', r.is_total,
      'amount', coalesce((v_values ->> r.code)::numeric, 0),
      'xbrl_element', r.xbrl_element,
      'in_progress', coalesce((v_progress ->> r.code)::numeric, 0)));
  end loop;

  return query
  select (x ->> 'line_code')::text,
         (x ->> 'parent_code')::text,
         (x ->> 'name')::text,
         (x ->> 'sequence')::integer,
         (x ->> 'is_total')::boolean,
         (x ->> 'amount')::numeric,
         (x ->> 'xbrl_element')::text,
         (x ->> 'in_progress')::numeric
    from jsonb_array_elements(v_rows) as x;
end;
$$;

comment on function statement_figures(uuid, text, date, date) is
  'A financial statement as financial_statement() returns it, with in_progress beside each line: the part of the line that is the result of the year nobody has closed, read with the line''s sign — nil on a total, on a statement that is not a balance sheet, and once the year is closed. Read by financial_statement() and financial_statement_of_kind(), so the ledger is summed once.';

-- ---------------------------------------------------------------------------
-- financial_statement — the scheme as it is filed, unchanged
-- ---------------------------------------------------------------------------

create or replace function financial_statement(
  p_company_id     uuid,
  p_statement_code text,
  p_from           date,
  p_to             date
)
returns table (
  line_code    text,
  parent_code  text,
  name         text,
  sequence     integer,
  is_total     boolean,
  amount       numeric,
  xbrl_element text
)
language sql
stable
as $$
  select f.line_code, f.parent_code, f.name, f.sequence, f.is_total, f.amount, f.xbrl_element
    from statement_figures(p_company_id, p_statement_code, p_from, p_to) f;
$$;

-- ---------------------------------------------------------------------------
-- financial_statement_of_kind — the sub-line of the result in progress
-- ---------------------------------------------------------------------------

create or replace function financial_statement_of_kind(
  p_company_id uuid,
  p_kind       text,
  p_from       date,
  p_to         date
)
returns table (
  statement_code text,
  line_code      text,
  parent_code    text,
  name           text,
  sequence       integer,
  is_total       boolean,
  amount         numeric,
  xbrl_element   text
)
language plpgsql
stable
as $$
declare
  v_code  text;
  v_kinds text;
  v_label text;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  v_code := default_statement_code(p_company_id, p_kind, p_to);
  if v_code is null then
    select string_agg(distinct s.kind, ', ' order by s.kind) into v_kinds
      from available_statements(p_company_id, p_to) s;
    raise exception 'unknown_statement: this company reports no % — it reports %. available_statements() names each one by code.',
      p_kind, coalesce(v_kinds, 'nothing');
  end if;

  -- The label of the sub-line, where the scheme combines the result in
  -- progress with other balances. Null on every other scheme, and then no
  -- sub-line is drawn.
  select s.result_in_progress_name into v_label
    from statement_templates s
   where s.code = v_code
     and s.kind = 'balance_sheet'
     and s.result_in_progress = 'combined';

  -- Each line, then right after it the result in progress it carries. The key
  -- starts with the line's own code, so a reader that orders by sequence and
  -- code keeps the sub-line under its line.
  return query
    with f as materialized (
      select *
        from statement_figures(p_company_id, v_code, p_from, p_to)
             with ordinality as x (line_code, parent_code, name, sequence, is_total, amount,
                                   xbrl_element, in_progress, ord)
    )
    select v_code, y.line_code, y.parent_code, y.name, y.sequence,
           y.is_total, y.amount, y.xbrl_element
      from (
        select f.line_code, f.parent_code, f.name, f.sequence, f.is_total, f.amount,
               f.xbrl_element, f.ord, 0 as part
          from f
        union all
        select f.line_code || ':result_in_progress', f.line_code, v_label, f.sequence, false,
               f.in_progress, null::text, f.ord, 1
          from f
         where v_label is not null
           and not f.is_total
           and f.in_progress <> 0
      ) y
     order by y.ord, y.part;
end;
$$;

comment on function financial_statement_of_kind(uuid, text, date, date) is
  'One financial statement of a company by kind — balance_sheet, income_statement, allocation, cash_flow — for a caller that does not know which scheme its country pack carries. Resolves through default_statement_code() at the end date of the period, then answers as financial_statement() does, with the code it chose in the first column. On a balance sheet whose line for the result also takes other balances (statement_templates.result_in_progress = combined), the result nobody has closed yet follows that line as a row of its own: key <line>:result_in_progress, parent the line, the pack''s label, not a total — a detail of its parent that no total adds.';

-- `drop` took the grants of statement_account_matches() with it, and the new
-- function is granted as every reader of a statement is.
revoke execute on all functions in schema public from public;

revoke execute on function statement_account_matches(uuid, text, date, date) from public, anon;
grant execute on function statement_account_matches(uuid, text, date, date) to authenticated, service_role;
revoke execute on function statement_figures(uuid, text, date, date) from public, anon;
grant execute on function statement_figures(uuid, text, date, date) to authenticated, service_role;
revoke execute on function financial_statement(uuid, text, date, date) from public, anon;
grant execute on function financial_statement(uuid, text, date, date) to authenticated, service_role;
revoke execute on function financial_statement_of_kind(uuid, text, date, date) from public, anon;
grant execute on function financial_statement_of_kind(uuid, text, date, date) to authenticated, service_role;
