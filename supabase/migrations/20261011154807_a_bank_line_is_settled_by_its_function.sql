-- Ekwo OS — a bank line is settled by the function that settles it.
--
-- Reported by Pieterjan Muller on 11 October 2026 (issue #91).
--
-- `bank_transactions` carries two columns that say a statement line has been
-- dealt with: `entry_id`, the payment entry the money was booked as, and
-- `state`, which `settle_from_statement()` moves to `reconciled` in the same
-- statement. Both were plain columns under the `bank.write` policy of
-- `20260913083216`, and the only triggers on the table kept `updated_at`, the
-- balance of the statement and the currency. So a member who may import a
-- statement could also, with one PATCH through the API:
--
--   * set `entry_id` back to null on a settled line. `settle_from_statement()`
--     refuses a second settlement only by reading that column, so the same
--     money could be booked and matched a second time against other invoices;
--   * write `reconciled` on a line nothing settled, and take it out of every
--     list of what is still to be done;
--   * change the amount, the day or the account of a line already booked as a
--     payment, so that the statement and the ledger no longer say the same
--     thing.
--
-- **The rule, written where every writer meets it.** A trigger,
-- `bank_transactions_guard()`, before every insert and update:
--
--   * `state` moves freely between `pending` and `ignored`: deciding that a
--     line needs no booking — a transfer between two of one's own accounts,
--     say — is the user's call, and it is a column a person writes;
--   * `reconciled` and `entry_id` are written by `settle_from_statement()` and
--     by nothing else. It raises `ekwo.settling_statement` around its one
--     update, the pattern of `ekwo.year_end_entry`, and the guard honours the
--     setting only for a caller the function itself lets through — one who
--     holds `reconcile.write`, since settling is matching — because any
--     session may write a setting (`20260929094126`). The same holds for a
--     line inserted already settled;
--   * once a line points at an entry, its amount, its day, its currency and
--     its bank account no longer move: they are what the entry was booked
--     from. `bank_transaction_settled` otherwise;
--   * the foreign key goes on doing its work. When the entry a line points at
--     is gone — the company is being deleted, in practice, since a posted
--     entry is never deleted — `entry_id` becomes null as the key says, and
--     the line goes back to `pending` with it, because nothing settles it any
--     more.
--
-- The installer — the migration runner, the seeds, `ekwo init`, a test
-- arranging a fixture as the owner — passes, as it passes every guard of this
-- schema: it owns the table and could switch the trigger off. `import_company()`
-- switches the user triggers of the tables it fills off for the length of the
-- load, and so restores a settled line as it was exported.
--
-- `settle_from_statement()` is replaced whole, for two lines: the setting
-- around its update, and a `for update` on the line it reads first, so that
-- two calls for the same line wait for each other and the second one meets
-- `statement_line_already_settled` instead of a stale read. Nothing else in it
-- moves.

-- ---------------------------------------------------------------------------
-- 1. The guard
-- ---------------------------------------------------------------------------

create or replace function bank_transactions_guard()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_settles boolean;
begin
  if is_installer() then
    return new;
  end if;

  -- The entry the line pointed at is gone, and the foreign key is setting the
  -- column to null: nothing settles the line any more.
  if tg_op = 'UPDATE' and old.entry_id is not null and new.entry_id is null
     and not exists (select 1 from entries e where e.id = old.entry_id) then
    if new.state = 'reconciled' then
      new.state := 'pending';
    end if;
    return new;
  end if;

  -- What only settling writes: an entry, and the reconciled state, arriving
  -- with the row or moving on it.
  if tg_op = 'INSERT' then
    v_settles := new.entry_id is not null or new.state = 'reconciled';
  else
    v_settles := new.entry_id is distinct from old.entry_id
              or (new.state = 'reconciled') is distinct from (old.state = 'reconciled');
  end if;

  if v_settles then
    if coalesce(current_setting('ekwo.settling_statement', true), '') <> 'on' then
      raise exception 'bank_transaction_settled_by_rpc: the entry and the reconciled state of a statement line are written by settle_from_statement(), which books the payment the line is. By hand, a line is pending or ignored.'
        using errcode = '55006';
    end if;
    if not has_capability(new.company_id, 'reconcile.write') then
      raise exception 'not_allowed: settling a statement line in this company needs reconcile.write'
        using errcode = '42501';
    end if;
  end if;

  if tg_op = 'UPDATE' and old.entry_id is not null
     and (new.amount is distinct from old.amount
          or new.transaction_date is distinct from old.transaction_date
          or new.currency_code is distinct from old.currency_code
          or new.bank_account_id is distinct from old.bank_account_id
          or new.company_id is distinct from old.company_id) then
    raise exception 'bank_transaction_settled: statement line % was booked as entry % and keeps its amount, its day, its currency and its account.',
      old.id, old.entry_id
      using errcode = '55006';
  end if;

  return new;
end;
$$;

comment on function bank_transactions_guard() is
  'Keeps a statement line honest about whether it is settled. state moves between pending and ignored by hand; reconciled and entry_id are written by settle_from_statement() alone, under the setting ekwo.settling_statement, honoured for a caller holding reconcile.write (bank_transaction_settled_by_rpc otherwise, and on an insert that arrives settled). A line pointing at an entry keeps its amount, day, currency and bank account (bank_transaction_settled). When the entry is gone, the foreign key nulls entry_id and the line is pending again. The installer passes.';

create trigger bank_transactions_guard
  before insert or update on bank_transactions
  for each row execute function bank_transactions_guard();

-- ---------------------------------------------------------------------------
-- 2. settle_from_statement — `20260917120000`, the setting and the lock
-- ---------------------------------------------------------------------------

create or replace function settle_from_statement(p_transaction_id uuid, p_line_ids uuid[])
returns bank_transactions
language plpgsql
volatile
security invoker
as $$
declare
  v_tx        bank_transactions;
  v_policy    matching_policy;
  v_round     money_rounding;
  v_tolerance numeric;
  v_side      text;
  v_contact   uuid;
  v_contacts  integer;
  v_open      numeric;
  v_journal   uuid;
  v_payment   uuid;
  v_entry     entries;
  v_pay_line  uuid;
  v_remaining numeric;
  v_amount    numeric;
  r           record;
begin
  -- Locked, so that two calls for the same line wait for each other and the
  -- second one reads the entry the first one wrote.
  select * into v_tx from bank_transactions t where t.id = p_transaction_id for update;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;
  if v_tx.entry_id is not null then
    raise exception 'statement_line_already_settled: % already points at entry %',
      p_transaction_id, v_tx.entry_id;
  end if;
  if p_line_ids is null or cardinality(p_line_ids) = 0 then
    raise exception 'no_lines_named: settling needs the open items this money pays';
  end if;

  v_side := case when v_tx.amount > 0 then 'debit' else 'credit' end;

  -- Every line has to be open, of this company, and on the side this money can
  -- settle. Anything else is a caller that has not looked.
  select count(distinct i.contact_id), count(*), sum(i.amount_open)
    into v_contacts, v_amount, v_open
  from open_items(v_tx.company_id) i
  where i.line_id = any(p_line_ids) and i.side = v_side;

  if v_amount is distinct from cardinality(p_line_ids) then
    raise exception 'line_not_open: one of the lines named is not an open item of this company on the % side', v_side;
  end if;
  if v_contacts > 1 then
    raise exception 'mixed_contacts: one payment settles the items of one counterparty';
  end if;

  select i.contact_id into v_contact
  from open_items(v_tx.company_id) i where i.line_id = p_line_ids[1];
  if v_contact is null then
    raise exception 'no_contact_on_open_item: a payment is made to or by somebody, and this item names nobody';
  end if;

  v_policy    := matching_policy_of(v_tx.company_id);
  v_round     := rounding_of(v_tx.company_id, v_tx.currency_code);
  v_tolerance := v_policy.amount_tolerance_units * power(10::numeric, -v_round.decimals);
  if abs(v_tx.amount) > v_open + v_tolerance then
    raise exception 'more_money_than_open: the statement line is % and the items named leave % open',
      abs(v_tx.amount), v_open;
  end if;

  select coalesce(b.journal_id, (select j.id from journals j
                                  where j.company_id = v_tx.company_id and j.bank_account_id = b.id
                                  limit 1))
    into v_journal
  from bank_accounts b where b.id = v_tx.bank_account_id;
  if v_journal is null then
    raise exception 'no_journal_for_bank_account: account % books through no journal', v_tx.bank_account_id;
  end if;

  insert into payments (company_id, direction, payment_date, amount, currency_code,
                        contact_id, journal_id, bank_account_id, reference, memo)
  values (v_tx.company_id,
          (case when v_tx.amount > 0 then 'inbound' else 'outbound' end)::payment_direction,
          v_tx.transaction_date, abs(v_tx.amount), v_tx.currency_code,
          v_contact, v_journal, v_tx.bank_account_id,
          coalesce(v_tx.structured_reference, v_tx.reference),
          v_tx.description)
  returning id into v_payment;

  v_entry := post_payment(v_payment);

  -- The third-party side of the payment: the line the open items are matched
  -- against. The other side is the bank account, which settles nothing.
  select l.id into v_pay_line
  from entry_lines l
  join accounts a on a.id = l.account_id
  where l.entry_id = v_entry.id and a.reconcilable
  limit 1;
  if v_pay_line is null then
    raise exception 'payment_has_no_third_party_line: entry % books against no reconcilable account',
      v_entry.id;
  end if;

  -- Oldest first, each item settled up to what is left of the money. A partial
  -- settlement is possible here because a person asked for it by naming the
  -- lines; `auto_settle()` never gets here with less money than is open.
  v_remaining := abs(v_tx.amount);
  for r in
    select * from open_items(v_tx.company_id) i
    where i.line_id = any(p_line_ids)
    order by i.entry_date, i.line_id
  loop
    exit when v_remaining <= 0;
    perform reconcile(v_pay_line, r.line_id, least(r.amount_open, v_remaining));
    v_remaining := v_remaining - least(r.amount_open, v_remaining);
  end loop;

  -- The one write of `entry_id` and of `reconciled` there is, under the
  -- setting `bank_transactions_guard()` honours. Raised for this statement
  -- and lowered after it, so nothing else in the transaction inherits it.
  perform set_config('ekwo.settling_statement', 'on', true);
  update bank_transactions t
     set entry_id   = v_entry.id,
         contact_id = coalesce(t.contact_id, v_contact),
         state      = 'reconciled'
   where t.id = p_transaction_id
  returning * into v_tx;
  perform set_config('ekwo.settling_statement', 'off', true);

  return v_tx;
end;
$$;

comment on function settle_from_statement(uuid, uuid[]) is
  'Books the payment a statement line is, and matches it against the open items named. One counterparty, one payment, `post_payment()` and `reconcile()` doing the accounting — nothing here writes a ledger of its own. The one writer of bank_transactions.entry_id and of the reconciled state, which bank_transactions_guard() holds it to.';

-- ---------------------------------------------------------------------------
-- Grants
--
-- settle_from_statement() is replaced, which keeps its privileges; they are
-- said again all the same. The guard is a trigger body, callable by nobody.
-- ---------------------------------------------------------------------------

revoke execute on function bank_transactions_guard() from public, anon, authenticated, service_role;

revoke execute on function settle_from_statement(uuid, uuid[]) from public, anon;
grant execute on function settle_from_statement(uuid, uuid[]) to authenticated, service_role;
