-- Ekwo OS — a matching settles the items of one counterparty.
--
-- Reported by Pieterjan Muller on 11 October 2026 (issue #89).
--
-- `reconcile()` checked that the two lines were on one account of one
-- company, that the account was reconcilable and that a debit met a credit.
-- It never read `contact_id`. On a receivable account shared by every
-- customer, the payment of one customer could be matched against the invoice
-- of another, and the invoice then read as paid while the customer who owed it
-- still owed it.
--
-- And `reconciliations` itself was writable under `reconcile.write`
-- (`20260913083216`, granted in `20260914151207`): a row inserted through the
-- API skipped every check `reconcile()` makes — the account, the side, the
-- amount still open, the exchange difference, the tax a cash basis makes due —
-- and a row deleted the same way left behind what `unreconcile()` takes back.
--
-- **One counterparty.** `reconcile()` now refuses two lines that both name a
-- counterparty and whose `commercial_entity()` differs,
-- `reconcile_contact_mismatch`. A branch and its parent are one party, which
-- is what `commercial_entity()` is for, and what `post_document()` and
-- `post_payment()` already book a third-party line against. Two lines naming
-- nobody are matched as before: an account kept without counterparties is
-- still a reconcilable account.
--
-- One line naming somebody and the other nobody is matched, and that is a
-- choice. A line with no counterparty on a third-party account is a line
-- nobody has attributed yet: a receipt keyed by hand from a bank statement,
-- the open items of books brought in by `import_books()` from a system that
-- kept no counterparty on them. Matching it is the act that attributes it, and
-- the suite has always matched such receipts against an invoice. What cannot
-- happen any more is the case the ledger can see is wrong — two lines that
-- each name a party, and not the same one.
--
-- **The only way in is the function.** A guard,
-- `reconciliations_guard_reconcile()`, before every insert, update and delete:
-- a row is written by `reconcile()` and removed by `unreconcile()`, which raise
-- `ekwo.reconciling` around their writes, honoured for a caller holding
-- `reconcile.write` — the pattern of `20260929094126`, because any session may
-- write a setting. A hand-written row is `reconciliation_by_reconcile`. The
-- table keeps its grants and its policy: a guard says the same thing for a
-- person and for `service_role`, and leaves the definer functions that call
-- `reconcile()` — `cancel_document()` — exactly as they were. The cascades of
-- the foreign keys pass: a matching goes with its company and with its lines.
-- The installer passes, as everywhere.
--
-- Both functions are replaced whole: `reconcile()` for the check and the
-- setting, `unreconcile()` for the setting. Nothing else in either moves.

-- ---------------------------------------------------------------------------
-- 1. reconcile — `20260914121200`, one counterparty, and the setting
-- ---------------------------------------------------------------------------

create or replace function reconcile(
  p_line_a uuid,
  p_line_b uuid,
  p_amount numeric default null
)
returns reconciliations
language plpgsql
as $$
declare
  v_a        entry_lines%rowtype;
  v_b        entry_lines%rowtype;
  v_debit    entry_lines%rowtype;
  v_credit   entry_lines%rowtype;
  v_amount   numeric;
  v_letter   text;
  v_result   reconciliations%rowtype;
  v_reconcilable boolean;
  v_home     char(3);
  v_country  char(2);
  v_journal  uuid;
  v_fx       boolean := false;
  v_open_d   numeric;
  v_open_c   numeric;
  v_cur_d    numeric;
  v_cur_c    numeric;
  v_cur      numeric;
  v_comp_d   numeric;
  v_comp_c   numeric;
  v_gap      numeric := 0;
  -- The ledger's rounding, and the one of the currency the two lines are
  -- stated in when that is not the ledger's.
  v_round    money_rounding;
  v_cur_round money_rounding;
  v_gain     uuid;
  v_loss     uuid;
  v_result_account uuid;
  v_fx_entry entries%rowtype;
  v_fx_line  uuid;
  v_date     date;
  v_transfer uuid;
  v_doc      uuid;
begin
  select * into v_a from entry_lines where id = p_line_a for update;
  if not found then raise exception 'unknown_entry_line: %', p_line_a; end if;
  select * into v_b from entry_lines where id = p_line_b for update;
  if not found then raise exception 'unknown_entry_line: %', p_line_b; end if;

  if v_a.account_id <> v_b.account_id then
    raise exception 'reconcile_account_mismatch: lines are on different accounts';
  end if;
  if v_a.company_id <> v_b.company_id then
    raise exception 'reconcile_company_mismatch: lines belong to different companies';
  end if;

  select a.reconcilable into v_reconcilable from accounts a where a.id = v_a.account_id;
  if not v_reconcilable then
    raise exception 'account_not_reconcilable: account of line % is not reconcilable', p_line_a;
  end if;

  if (v_a.debit > 0) = (v_b.debit > 0) then
    raise exception 'reconcile_same_side: a debit must be matched against a credit';
  end if;

  -- One counterparty: a branch and its parent are one party. A line that
  -- names nobody has not been attributed yet, and matching it is what
  -- attributes it.
  if v_a.contact_id is not null and v_b.contact_id is not null
     and commercial_entity(v_a.contact_id) is distinct from commercial_entity(v_b.contact_id) then
    raise exception 'reconcile_contact_mismatch: lines % and % name two different counterparties, and a matching settles the items of one',
      p_line_a, p_line_b;
  end if;

  if v_a.debit > 0 then
    v_debit := v_a; v_credit := v_b;
  else
    v_debit := v_b; v_credit := v_a;
  end if;

  select c.currency_code, c.country, c.miscellaneous_journal_id
    into v_home, v_country, v_journal
    from companies c where c.id = v_debit.company_id;

  v_round  := rounding_of(v_debit.company_id);
  v_open_d := abs(v_debit.debit - v_debit.credit) - v_debit.matched_amount;
  v_open_c := abs(v_credit.debit - v_credit.credit) - v_credit.matched_amount;

  v_fx := v_debit.currency_code is not null
      and v_debit.currency_code = v_credit.currency_code
      and v_debit.currency_code <> v_home
      and coalesce(v_debit.amount_currency, 0) <> 0
      and coalesce(v_credit.amount_currency, 0) <> 0;

  if v_fx then
    v_cur_round := rounding_of(v_debit.company_id, v_debit.currency_code);
    -- What is still open on each line, in its own currency, in proportion to
    -- what is still open in the ledger.
    v_cur_d := round_amount(v_debit.amount_currency * v_open_d
                            / nullif(abs(v_debit.debit - v_debit.credit), 0), v_cur_round);
    v_cur_c := round_amount(v_credit.amount_currency * v_open_c
                            / nullif(abs(v_credit.debit - v_credit.credit), 0), v_cur_round);
    v_cur   := coalesce(p_amount, least(v_cur_d, v_cur_c));

    if v_cur is null or v_cur <= 0 then
      raise exception 'reconcile_nothing_left: no open amount to match';
    end if;
    -- A tenth of a unit of that currency, which is what `0.001` was when
    -- every currency was assumed to have cents.
    if v_cur > v_cur_d + currency_unit(v_cur_round) / 10
       or v_cur > v_cur_c + currency_unit(v_cur_round) / 10 then
      raise exception 'reconcile_over_currency: % exceeds what is open in %',
        v_cur, v_debit.currency_code;
    end if;

    v_comp_d := round_amount(v_cur * abs(v_debit.debit - v_debit.credit)
                             / v_debit.amount_currency, v_round);
    v_comp_c := round_amount(v_cur * abs(v_credit.debit - v_credit.credit)
                             / v_credit.amount_currency, v_round);
    v_amount := least(v_comp_d, v_comp_c);
    v_gap    := v_comp_d - v_comp_c;
  else
    v_amount := coalesce(p_amount, least(v_open_d, v_open_c));
  end if;

  if v_amount is null or v_amount <= 0 then
    raise exception 'reconcile_nothing_left: no open amount to match';
  end if;
  if v_amount > v_open_d + currency_unit(v_round) / 10 then
    raise exception 'reconcile_over_debit: % exceeds the open amount of the debit line', v_amount;
  end if;
  if v_amount > v_open_c + currency_unit(v_round) / 10 then
    raise exception 'reconcile_over_credit: % exceeds the open amount of the credit line', v_amount;
  end if;

  -- Every write of `reconciliations` below is this function's, under the
  -- setting `reconciliations_guard_reconcile()` honours.
  perform set_config('ekwo.reconciling', 'on', true);

  -- Reuse a letter already carried by either side, otherwise draw a new one.
  v_letter := coalesce(v_debit.matching_number, v_credit.matching_number,
                       next_matching_number(v_debit.company_id));

  -- Two chains meeting: merge them under a single letter.
  if v_debit.matching_number is not null
     and v_credit.matching_number is not null
     and v_debit.matching_number <> v_credit.matching_number then
    update reconciliations
       set matching_number = v_letter
     where company_id = v_debit.company_id
       and matching_number = v_credit.matching_number;
  end if;

  -- The date the settlement is complete on: the later of the two entries.
  select greatest(ed.entry_date, ec.entry_date) into v_date
    from entries ed, entries ec
   where ed.id = v_debit.entry_id and ec.id = v_credit.entry_id;

  -- ------------------------------------------------------- exchange difference
  if v_gap <> 0 then
    select account_id_by_code(v_debit.company_id, cd.fx_gain_code),
           account_id_by_code(v_debit.company_id, cd.fx_loss_code)
      into v_gain, v_loss
      from country_defaults cd where cd.country = v_country;

    -- A debit side short of the credit side means more of the company's money
    -- came in than the receivable was booked at: a gain.
    v_result_account := case when v_gap < 0 then v_gain else v_loss end;
    if v_result_account is null then
      raise exception 'no_fx_accounts: matching % with % realises % and the country model names no exchange gain and loss account',
        p_line_a, p_line_b, v_gap;
    end if;
    if v_journal is null then
      raise exception 'no_miscellaneous_journal: company % has no journal for an exchange difference',
        v_debit.company_id;
    end if;

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, currency_code)
    values (v_debit.company_id, v_journal, fiscal_year_at(v_debit.company_id, v_date), v_date,
            'Exchange difference on ' || v_letter, 'draft', v_home)
    returning * into v_fx_entry;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, contact_id, currency_code)
    values (v_fx_entry.id, v_debit.company_id, v_debit.account_id, 10,
            'Exchange difference',
            case when v_gap < 0 then abs(v_gap) else 0 end,
            case when v_gap < 0 then 0 else abs(v_gap) end,
            coalesce(v_debit.contact_id, v_credit.contact_id), v_home)
    returning id into v_fx_line;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, currency_code)
    values (v_fx_entry.id, v_debit.company_id, v_result_account, 20,
            'Exchange difference',
            case when v_gap < 0 then 0 else abs(v_gap) end,
            case when v_gap < 0 then abs(v_gap) else 0 end,
            v_home);

    v_fx_entry := post_entry(v_fx_entry.id);

    -- And it is matched with the side it completes, under the same letter.
    if v_gap < 0 then
      insert into reconciliations (company_id, debit_line_id, credit_line_id, amount, matching_number)
      values (v_debit.company_id, v_fx_line, v_credit.id, abs(v_gap), v_letter);
    else
      insert into reconciliations (company_id, debit_line_id, credit_line_id, amount, matching_number)
      values (v_debit.company_id, v_debit.id, v_fx_line, abs(v_gap), v_letter);
    end if;
  end if;

  insert into reconciliations (company_id, debit_line_id, credit_line_id, amount,
                               matching_number, fx_entry_id)
  values (v_debit.company_id, v_debit.id, v_credit.id, v_amount, v_letter, v_fx_entry.id)
  returning * into v_result;

  -- ------------------------------------------------------- a tax falling due
  for v_doc in
    select distinct d.id
      from entry_lines l join documents d on d.entry_id = l.entry_id
     where l.id in (v_debit.id, v_credit.id)
  loop
    v_transfer := coalesce(settle_cash_basis_tax(v_doc, v_date), v_transfer);
  end loop;

  if v_transfer is not null then
    update reconciliations set tax_transfer_entry_id = v_transfer where id = v_result.id
    returning * into v_result;
  end if;

  perform set_config('ekwo.reconciling', 'off', true);
  return v_result;
end;
$$;

comment on function reconcile(uuid, uuid, numeric) is
  'Matches a debit line against a credit line of one counterparty — two lines that both name one have the same commercial_entity() (reconcile_contact_mismatch otherwise), and a line naming nobody is attributed by the matching — in the currency the two share when it is not the company''s, and books what the matching reveals: the realised exchange difference, and the share of a cash-basis tax that has become due. The one writer of reconciliations, with unreconcile().';

-- ---------------------------------------------------------------------------
-- 2. unreconcile — `20260912112132`, the setting
-- ---------------------------------------------------------------------------

create or replace function unreconcile(p_reconciliation_id uuid)
returns void
language plpgsql
as $$
declare
  v_row     reconciliations%rowtype;
  v_date    date;
  v_fx      entries%rowtype;
  v_mirror  entries%rowtype;
  v_doc     uuid;
  fl        record;
begin
  select * into v_row from reconciliations where id = p_reconciliation_id;
  if not found then
    raise exception 'unknown_reconciliation: %', p_reconciliation_id;
  end if;

  select greatest(ed.entry_date, ec.entry_date) into v_date
    from entry_lines ld join entries ed on ed.id = ld.entry_id,
         entry_lines lc join entries ec on ec.id = lc.entry_id
   where ld.id = v_row.debit_line_id and lc.id = v_row.credit_line_id;

  perform set_config('ekwo.reconciling', 'on', true);
  delete from reconciliations where id = p_reconciliation_id;

  -- An exchange difference was realised by this matching and by nothing else,
  -- so undoing the matching takes it back: its own matching goes, and a mirror
  -- entry cancels it on the same date. The period has to be open, which is the
  -- honest refusal — a difference that has been declared is not unmade quietly.
  if v_row.fx_entry_id is not null then
    select * into v_fx from entries where id = v_row.fx_entry_id;

    delete from reconciliations r
     where r.company_id = v_row.company_id
       and (r.debit_line_id in (select id from entry_lines where entry_id = v_fx.id)
         or r.credit_line_id in (select id from entry_lines where entry_id = v_fx.id));

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, currency_code, reversed_entry_id)
    values (v_fx.company_id, v_fx.journal_id, v_fx.fiscal_year_id, v_fx.entry_date,
            'Exchange difference undone', 'draft', v_fx.currency_code, v_fx.id)
    returning * into v_mirror;

    for fl in select * from entry_lines where entry_id = v_fx.id order by sequence loop
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, contact_id, currency_code)
      values (v_mirror.id, fl.company_id, fl.account_id, fl.sequence, fl.name,
              fl.credit, fl.debit, fl.contact_id, fl.currency_code);
    end loop;

    perform post_entry(v_mirror.id);
  end if;

  -- The share of a cash-basis tax that is due has just fallen; the same
  -- function books the difference, which is now the other way round.
  for v_doc in
    select distinct d.id
      from entry_lines l join documents d on d.entry_id = l.entry_id
     where l.id in (v_row.debit_line_id, v_row.credit_line_id)
  loop
    perform settle_cash_basis_tax(v_doc, v_date);
  end loop;

  perform set_config('ekwo.reconciling', 'off', true);
end;
$$;

comment on function unreconcile(uuid) is
  'Undoes a matching, and with it what the matching had booked: the exchange difference it realised and the share of a cash-basis tax it had made due. The one way a matching is removed.';

-- ---------------------------------------------------------------------------
-- 3. The guard
-- ---------------------------------------------------------------------------

create or replace function reconciliations_guard_reconcile()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_company uuid := coalesce(new.company_id, old.company_id);
begin
  if is_installer() then
    return coalesce(new, old);
  end if;

  -- A matching goes with its company, and with either of its lines.
  if tg_op = 'DELETE'
     and (not exists (select 1 from companies c where c.id = old.company_id)
          or not exists (select 1 from entry_lines l where l.id = old.debit_line_id)
          or not exists (select 1 from entry_lines l where l.id = old.credit_line_id)) then
    return old;
  end if;

  if coalesce(current_setting('ekwo.reconciling', true), '') <> 'on' then
    raise exception 'reconciliation_by_reconcile: a matching is written by reconcile() and undone by unreconcile(), which check the two lines and book what the matching moves'
      using errcode = '55006';
  end if;
  if not has_capability(v_company, 'reconcile.write') then
    raise exception 'not_allowed: matching in this company needs reconcile.write'
      using errcode = '42501';
  end if;
  return coalesce(new, old);
end;
$$;

comment on function reconciliations_guard_reconcile() is
  'Keeps reconciliations to the two functions that check a matching and book what it moves: a row is inserted or updated by reconcile() and deleted by unreconcile(), under the setting ekwo.reconciling, honoured for a caller holding reconcile.write. reconciliation_by_reconcile otherwise. The cascades of a company and of an entry line pass, and so does the installer.';

create trigger reconciliations_guard_reconcile
  before insert or update or delete on reconciliations
  for each row execute function reconciliations_guard_reconcile();

-- ---------------------------------------------------------------------------
-- Grants
--
-- reconcile() and unreconcile() are replaced, which keeps their privileges;
-- they are said again all the same. The guard is a trigger body, callable by
-- nobody.
-- ---------------------------------------------------------------------------

revoke execute on function reconciliations_guard_reconcile() from public, anon, authenticated, service_role;

revoke execute on function reconcile(uuid, uuid, numeric) from public, anon;
revoke execute on function unreconcile(uuid) from public, anon;
grant execute on function reconcile(uuid, uuid, numeric) to authenticated, service_role;
grant execute on function unreconcile(uuid) to authenticated, service_role;
