-- Ekwo OS — the statement of account of a contact.
--
-- What a customer owes and what is owed to a supplier is in the ledger, on
-- the lines of the receivable and payable accounts that name them. Until now
-- a screen that showed it read `entry_lines` itself, and worked out its own
-- opening balance, its own running balance and its own idea of which lines
-- count — one more reading of the ledger, beside the ones the reports make,
-- free to disagree with them.
--
--   `contact_statement(company, contact, from, to)` — one row for the balance
--       carried forward to `from`, then every posted line of the period on a
--       receivable or payable account that names the contact, in the order
--       of the ledger: the date, the journal, the entry, the document the
--       entry books, the debit, the credit and the running balance, all in
--       the currency of the company; and, for each line, how far a matching
--       has settled it.
--
-- **The accounts are told by their type, not by their code.** A line counts
-- when its account is `asset_receivable` or `liability_payable` — what
-- `aged_balance()` reads — so the statement and the aged balance of a
-- contact add up to the same thing, on every chart. A contact that is a
-- customer and a supplier at once has one statement over both, and its
-- running balance is what is left once one is set against the other; every
-- row names its account, for whoever wants them apart. The other lines of an
-- entry that name the contact — the income of an invoice, the bank side of a
-- payment — are the other side of these, and are not repeated.
--
-- **The balance carried forward is a row.** It comes first, dated `from`,
-- with `row_kind = 'opening'`, the debit or the credit it amounts to and the
-- balance itself; a period without a line still answers with it. Debit minus
-- credit, as everywhere in the ledger: positive is what the contact owes.
--
-- **The matching is today's.** `matched_amount`, `open_amount` and
-- `matching_state` say how far the line is settled now, as `open_items()`
-- does, whatever `to` is: a statement is read to know what is still open.
--
-- **In the schema `ekwo`.** The function is created there by its qualified
-- name, with the path of the socle (`ekwo, pg_temp`), as every function since
-- `20261028040000`; the Data API reaches it through the profile `ekwo`.
--
-- **Paged by its caller.** The running balance is worked out over the whole
-- period before anything is returned, so a page cut out of the result —
-- PostgREST's `limit` and `offset` — carries the right balance on its first
-- row.

-- ---------------------------------------------------------------------------
-- contact_statement — the lines of a contact, with the balance they run to
-- ---------------------------------------------------------------------------

create or replace function ekwo.contact_statement(
  p_company_id uuid,
  p_contact_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  row_kind        text,
  entry_date      date,
  journal_code    text,
  entry_id        uuid,
  entry_number    text,
  entry_line_id   uuid,
  document_id     uuid,
  document_number text,
  doc_type        ekwo.doc_type,
  account_id      uuid,
  account_code    text,
  account_name    text,
  line_name       text,
  reference       text,
  date_maturity   date,
  debit           numeric,
  credit          numeric,
  running_balance numeric,
  matching_number text,
  matched_amount  numeric,
  open_amount     numeric,
  matching_state  text
)
language plpgsql
stable
security invoker
set search_path = ekwo, pg_temp
as $$
#variable_conflict use_column
declare
  -- The balances are the ledger added up, so they are written with the
  -- decimals of the currency it is kept in: a sum of nothing is 0.00, not 0.
  v_round   money_rounding;
  v_opening numeric;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id;
  end if;

  if not is_installer() and not coalesce(has_capability(p_company_id, 'entries.read'), false) then
    raise exception 'not_allowed: reading the statement of a contact needs entries.read'
      using errcode = '42501';
  end if;

  if not exists (select 1 from contacts c where c.id = p_contact_id and c.company_id = p_company_id) then
    raise exception 'unknown_contact: this company has no contact %', coalesce(p_contact_id::text, 'nothing')
      using hint = 'search_contacts (ekwo contact list) gives the id of a contact.';
  end if;

  if p_from is null or p_to is null or p_from > p_to then
    raise exception 'invalid_period: a statement reads a period from its first day to its last, and % to % is not one',
      coalesce(p_from::text, 'nothing'), coalesce(p_to::text, 'nothing')
      using errcode = '22023';
  end if;

  v_round := rounding_of(p_company_id);

  select round_amount(coalesce(sum(l.balance), 0), v_round)
    into v_opening
    from entry_lines l
    join entries e on e.id = l.entry_id
    join accounts a on a.id = l.account_id
   where l.company_id = p_company_id
     and l.contact_id = p_contact_id
     and e.state = 'posted'
     and e.entry_date < p_from
     and a.account_type in ('asset_receivable', 'liability_payable');

  -- Two queries, one after the other: the balance carried forward is the
  -- first row because it is returned first, not because a sort says so.
  return query
    select 'opening'::text, p_from, null::text, null::uuid, null::text, null::uuid,
           null::uuid, null::text, null::doc_type,
           null::uuid, null::text, null::text, null::text, null::text, null::date,
           round_amount(greatest(v_opening, 0), v_round), round_amount(greatest(-v_opening, 0), v_round), v_opening,
           null::text, null::numeric, null::numeric, null::text;

  return query
    select 'line'::text, e.entry_date, j.code, e.id, e.number, l.id,
           e.document_id, d.number, d.doc_type,
           a.id, a.code, a.name, l.name, e.reference, l.date_maturity,
           l.debit, l.credit,
           round_amount(v_opening + sum(l.balance) over (order by e.entry_date, e.number, l.sequence, l.id
                                                         rows between unbounded preceding and current row),
                        v_round),
           l.matching_number, l.matched_amount, round_amount(abs(l.balance) - l.matched_amount, v_round),
           case when abs(l.balance) - l.matched_amount <= 0 then 'matched'
                when l.matched_amount > 0 then 'partial'
                else 'open' end
      from entry_lines l
      join entries e on e.id = l.entry_id
      join journals j on j.id = e.journal_id
      join accounts a on a.id = l.account_id
      left join documents d on d.id = e.document_id
     where l.company_id = p_company_id
       and l.contact_id = p_contact_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
       and a.account_type in ('asset_receivable', 'liability_payable')
     order by e.entry_date, e.number, l.sequence, l.id;
end;
$$;

comment on function ekwo.contact_statement(uuid, uuid, date, date) is
  'The statement of account of a contact over a period: first the balance carried forward to p_from (row_kind opening, dated p_from), then every posted line of the period on an asset_receivable or liability_payable account that names the contact (row_kind line), in ledger order, with its journal, entry, document, debit, credit and the running balance — debit minus credit, in the company currency, positive when the contact owes. matched_amount, open_amount and matching_state (open, partial, matched) say how far a matching has settled each line today. The running balance is computed over the whole period, so a page of the result keeps it. Security invoker: entries.read, and the caller''s own rights on the ledger. Refused by name: unknown_company, not_allowed, unknown_contact, invalid_period.';

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on function ekwo.contact_statement(uuid, uuid, date, date) from public, anon;
grant execute on function ekwo.contact_statement(uuid, uuid, date, date) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the function is there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
