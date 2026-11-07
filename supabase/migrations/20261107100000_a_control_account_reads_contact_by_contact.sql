-- Ekwo OS — a control account reads contact by contact.
--
-- An accountant reads a receivable or a payable account the way it is
-- audited: contact by contact, each with the balance brought forward, the
-- debits and credits of the period and the balance it closes on, the sum of
-- the contacts being the account itself, and the lines that name nobody
-- counted apart. Until now the schema gave the account (`trial_balance()`),
-- its lines (`general_ledger()`) and one contact across its accounts
-- (`contact_statement()`), and a screen that wanted the subsidiary ledger
-- added the lines up itself — one more reading of the ledger, free to
-- disagree with the others.
--
--   `subledger(company, from, to, accounts)` — one row per account and
--       contact: the opening balance before `from`, the debit and the credit
--       of the period, the closing balance at `to`, the number of lines of
--       the period and the number of lines still open today; and one row per
--       account for the lines that name no contact, `contact_id` null.
--
--   `general_ledger(company, from, to, accounts, contacts)` — a fifth
--       argument, `p_contact_ids`, keeps the lines of those contacts only,
--       each contact's lines with the balance it carried forward on the
--       account and its own running balance: the detail of a row of the
--       subsidiary ledger, from the function that already reads the lines.
--
-- **The accounts are told by their type, not by their code.** Left null,
-- `p_account_ids` reads every account of type `asset_receivable` or
-- `liability_payable` — the types the pack gives the accounts, the ones
-- `aged_balance()` and `contact_statement()` read — so the same call works on
-- every chart. (`accounts.internal_group` says asset or liability, which is
-- not enough to tell a receivable from a bank account.) Named, the accounts
-- are read whatever their type: a subsidiary ledger of an employee account or
-- of a suspense account is the same reading.
--
-- **The rows add up to the trial balance.** The lines are the posted ones,
-- dated up to `to`, as `trial_balance()` reads them: per account, the opening
-- balances, the debits, the credits and the closing balances of the rows
-- sum to the account's own figures in `trial_balance()`, to the cent. A
-- contact with nothing brought forward, nothing in the period and nothing
-- open is left out; it adds nothing to the sums.
--
-- **The open items are today's.** `open_items` counts the lines dated up to
-- `to` whose matching has not settled them yet, below half a unit of the
-- currency being nothing, as `aged_balance()` counts them: the matching of a
-- line has no date, so a subsidiary ledger read for a past period says what
-- of it is still open now, as `contact_statement()` does.
--
-- **Security.** `subledger()` is `security invoker`, refused by name to whoever
-- may not read the ledger of the company, exactly as `contact_statement()`:
-- unknown_company, not_allowed (entries.read), invalid_period, and
-- unknown_account for an account the company does not have.
-- `general_ledger()` stays what it was — SQL, under the caller's rights, with
-- no path of its own so that a report folds it into one plan.
--
-- **A call that names four arguments is answered as before.** The function is
-- dropped and created again because an argument is added; it defaults to
-- null, which reads every contact with the running balance of the account,
-- so the command line, the MCP server and the Cloud of the previous release
-- — and PostgREST resolving a call without `p_contact_ids` — get exactly what
-- they got. An overload beside the former signature would make every call
-- with four arguments or fewer ambiguous, which is why there is none.

-- ---------------------------------------------------------------------------
-- general_ledger — the lines of an account, of some contacts if asked
-- ---------------------------------------------------------------------------

drop function if exists ekwo.general_ledger(uuid, date, date, uuid[]);

create function ekwo.general_ledger(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_account_ids uuid[] default null,
  p_contact_ids uuid[] default null
)
returns table (
  account_id      uuid,
  account_code    text,
  account_name    text,
  entry_line_id   uuid,
  entry_id        uuid,
  entry_number    text,
  entry_date      date,
  journal_code    text,
  reference       text,
  line_name       text,
  contact_id      uuid,
  contact_name    text,
  debit           numeric,
  credit          numeric,
  matching_number text,
  running_balance numeric
)
language sql
stable
as $$
  -- `party` is the contact a balance runs for: none when every contact is
  -- read — one running balance per account, as always — and the line's
  -- contact when some are asked for.
  with opening as (
    select l.account_id,
           case when p_contact_ids is null then null else l.contact_id end as party,
           sum(l.balance) as balance
      from entry_lines l
      join entries e on e.id = l.entry_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date < p_from
       and (p_contact_ids is null or l.contact_id = any (p_contact_ids))
     group by 1, 2
  ),
  movements as (
    select l.id, l.account_id, l.entry_id, e.number, e.entry_date, j.code as journal_code,
           e.reference, l.name, c.id as contact_id, c.name as contact_name, l.debit, l.credit, l.balance,
           l.matching_number, l.sequence,
           case when p_contact_ids is null then null else l.contact_id end as party
      from entry_lines l
      join entries e on e.id = l.entry_id
      join journals j on j.id = e.journal_id
      left join contacts c on c.id = l.contact_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
       and (p_contact_ids is null or l.contact_id = any (p_contact_ids))
  )
  select a.id, a.code, a.name,
         m.id, m.entry_id, m.number, m.entry_date, m.journal_code, m.reference,
         m.name, m.contact_id, m.contact_name, m.debit, m.credit, m.matching_number,
         (coalesce(o.balance, 0)
          + sum(m.balance) over (partition by a.id, m.party
                                 order by m.entry_date, m.number, m.sequence, m.id
                                 rows between unbounded preceding and current row))::numeric
    from movements m
    join accounts a on a.id = m.account_id
    left join opening o on o.account_id = a.id and o.party is not distinct from m.party
   where p_account_ids is null or a.id = any (p_account_ids)
   -- Every contact read: the order of the ledger, as always. Some asked
   -- for: each contact's lines together, by name, within the account.
   order by a.code,
            case when p_contact_ids is null then null else m.contact_name end,
            m.party,
            m.entry_date, m.number, m.sequence, m.id;
$$;

comment on function ekwo.general_ledger(uuid, date, date, uuid[], uuid[]) is
  'Posted lines of a period per account, with the balance carried forward from before the period. Each line names its contact (contact_id, contact_name) when it has one. p_contact_ids keeps the lines of those contacts only, each contact with its own balance carried forward on the account and its own running balance — the detail of a row of subledger(); left null, every line, with one running balance per account.';

revoke execute on function ekwo.general_ledger(uuid, date, date, uuid[], uuid[]) from public, anon;
grant execute on function ekwo.general_ledger(uuid, date, date, uuid[], uuid[]) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- subledger — a control account, contact by contact
-- ---------------------------------------------------------------------------

create or replace function ekwo.subledger(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_account_ids uuid[] default null
)
returns table (
  account_id      uuid,
  account_code    text,
  account_name    text,
  account_type    ekwo.account_type,
  contact_id      uuid,
  contact_name    text,
  opening_balance numeric,
  debit           numeric,
  credit          numeric,
  closing_balance numeric,
  line_count      integer,
  open_items      integer
)
language plpgsql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
#variable_conflict use_column
declare
  -- The sums are the ledger added up, so they are written with the decimals
  -- of the currency it is kept in: a sum of nothing is 0.00, not 0.
  v_round   money_rounding;
  v_unknown uuid;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  if not is_installer() and not coalesce(has_capability(p_company_id, 'entries.read'), false) then
    raise exception 'not_allowed: reading the subsidiary ledger needs entries.read'
      using errcode = '42501';
  end if;

  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'invalid_period: a subsidiary ledger reads a period from its first day to its last, and % to % is not one',
      coalesce(p_from::text, 'nothing'), coalesce(p_to::text, 'nothing')
      using errcode = '22023';
  end if;

  select x.id into v_unknown
    from unnest(p_account_ids) as x(id)
   where not exists (select 1 from accounts a where a.id = x.id and a.company_id = p_company_id)
   limit 1;
  if v_unknown is not null then
    raise exception 'unknown_account: this company has no account %', v_unknown
      using hint = 'list_accounts (ekwo account list) gives the id of an account.';
  end if;

  v_round := rounding_of(p_company_id);

  return query
  with scope as (
    select a.id, a.code, a.name, a.account_type
      from accounts a
     where a.company_id = p_company_id
       and case when p_account_ids is null
                then a.account_type in ('asset_receivable', 'liability_payable')
                else a.id = any (p_account_ids) end
  ),
  -- Posted, dated up to `to`: the lines `trial_balance()` adds up.
  posted as (
    select l.account_id, l.contact_id, e.entry_date, l.debit, l.credit, l.balance, l.matched_amount
      from entry_lines l
      join entries e on e.id = l.entry_id
      join scope s on s.id = l.account_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date <= p_to
  ),
  by_contact as (
    select p.account_id, p.contact_id,
           coalesce(sum(p.balance) filter (where p.entry_date < p_from), 0) as opening,
           coalesce(sum(p.debit)   filter (where p.entry_date >= p_from), 0) as debit,
           coalesce(sum(p.credit)  filter (where p.entry_date >= p_from), 0) as credit,
           coalesce(sum(p.balance), 0) as closing,
           count(*) filter (where p.entry_date >= p_from) as lines,
           -- Half a unit of the currency: below that, nothing is open.
           count(*) filter (where abs(p.balance) - p.matched_amount > currency_unit(v_round) / 2) as open_lines
      from posted p
     group by p.account_id, p.contact_id
  )
  select s.id, s.code, s.name, s.account_type,
         b.contact_id, c.name,
         round_amount(b.opening, v_round),
         round_amount(b.debit, v_round),
         round_amount(b.credit, v_round),
         round_amount(b.closing, v_round),
         b.lines::integer,
         b.open_lines::integer
    from by_contact b
    join scope s on s.id = b.account_id
    left join contacts c on c.id = b.contact_id
   where b.opening <> 0 or b.lines > 0 or b.open_lines > 0
   order by s.code, c.name nulls last, b.contact_id nulls last;
end;
$$;

comment on function ekwo.subledger(uuid, date, date, uuid[]) is
  'The subsidiary ledger of control accounts over a period: one row per account and contact with the balance brought forward before p_from (opening_balance), the debit and credit of the period, the closing balance at p_to, the number of lines of the period (line_count) and the number of lines dated up to p_to that a matching has not settled today (open_items); one row per account with contact_id null for the lines that name no contact. Debit minus credit, in the company currency. p_account_ids null reads every asset_receivable and liability_payable account. Posted entries only; per account, the rows sum to trial_balance() to the cent. A contact with nothing brought forward, no line in the period and nothing open is left out. Security invoker: entries.read. Refused by name: unknown_company, not_allowed, invalid_period, unknown_account.';

revoke execute on function ekwo.subledger(uuid, date, date, uuid[]) from public, anon;
grant execute on function ekwo.subledger(uuid, date, date, uuid[]) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
