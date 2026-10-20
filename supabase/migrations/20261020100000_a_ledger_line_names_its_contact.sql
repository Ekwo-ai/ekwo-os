-- Ekwo OS — a ledger line names its contact.
--
-- `general_ledger()` gave the name of the contact on a line and not the
-- contact itself, so a screen drawing the ledger of a receivable or payable
-- account could print the customer but not open them: the name was dead
-- text, and a line of 400000 could not lead to the statement of the party
-- it is about. `journal_book()` (20261020080000) carries `contact_id`; the
-- ledger now does too, beside `contact_name`, read from the same column of
-- the line.
--
-- A function's set of columns is its type, and Postgres does not let
-- `create or replace` change it, so the function is dropped and created
-- again under the same signature. Nothing else in the schema calls it;
-- the privileges are granted again below, as every migration grants what
-- it creates. The body and the order of the rows are the ones of
-- 20260911121000, unchanged.

drop function if exists general_ledger(uuid, date, date, uuid[]);

create function general_ledger(
  p_company_id uuid,
  p_from       date,
  p_to         date,
  p_account_ids uuid[] default null
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
  with opening as (
    select l.account_id, sum(l.balance) as balance
      from entry_lines l
      join entries e on e.id = l.entry_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date < p_from
     group by l.account_id
  ),
  movements as (
    select l.id, l.account_id, l.entry_id, e.number, e.entry_date, j.code as journal_code,
           e.reference, l.name, c.id as contact_id, c.name as contact_name, l.debit, l.credit, l.balance,
           l.matching_number, l.sequence
      from entry_lines l
      join entries e on e.id = l.entry_id
      join journals j on j.id = e.journal_id
      left join contacts c on c.id = l.contact_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
  )
  select a.id, a.code, a.name,
         m.id, m.entry_id, m.number, m.entry_date, m.journal_code, m.reference,
         m.name, m.contact_id, m.contact_name, m.debit, m.credit, m.matching_number,
         (coalesce(o.balance, 0)
          + sum(m.balance) over (partition by a.id
                                 order by m.entry_date, m.number, m.sequence, m.id
                                 rows between unbounded preceding and current row))::numeric
    from movements m
    join accounts a on a.id = m.account_id
    left join opening o on o.account_id = a.id
   where p_account_ids is null or a.id = any (p_account_ids)
   order by a.code, m.entry_date, m.number, m.sequence, m.id;
$$;

comment on function general_ledger(uuid, date, date, uuid[]) is
  'Posted lines of a period per account, with the balance carried forward from before the period. Each line names its contact (contact_id, contact_name) when it has one.';

revoke execute on all functions in schema public from public;
revoke execute on function general_ledger(uuid, date, date, uuid[]) from public, anon;
grant execute on function general_ledger(uuid, date, date, uuid[]) to authenticated, service_role;
