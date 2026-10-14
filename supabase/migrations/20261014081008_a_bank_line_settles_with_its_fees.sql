-- Ekwo OS — a bank line settles what it pays, net of what it costs.
--
-- Reported by Pieterjan Muller on 14 October 2026 (issue #93).
--
-- `settle_from_statement()` booked a statement line as one payment of the
-- whole amount and matched it oldest first against the open items named. Two
-- lines every company meets did not fit:
--
--   * a payout of a payment service provider, 97.00 for an invoice of 100.00
--     the customer paid in full, the provider keeping 3.00. The function
--     refused it as soon as the money was more than open, and never booked a
--     line for the fee when it was less: the 3.00 stayed open on the invoice;
--   * a payment of a supplier that the bank charged for, the bank line being
--     the invoice plus the charges, or a charge on its own with no invoice.
--
-- What a user did instead was a manual entry, a `reconcile()` and a PATCH of
-- the bank line to point it at the entry — which `bank_transactions_guard()`
-- forbids since `20261011154807` (issue #91). And the oldest-first walk was the
-- only way to say how much settles what: a line paying one invoice in part and
-- another in full, in that order, could not be said.
--
-- **Two optional arguments.** Same name, and every existing call keeps its
-- meaning: the old signature is dropped and the new one answers it through its
-- defaults, `auto_settle()` included.
--
--   * `p_amounts numeric[]`, beside `p_line_ids`: how much of the money settles
--     each item, in the order the items are named. Each one positive and no
--     more than the item has open. Given, nothing is spread: each item is
--     matched for its amount, and partial settlement is the caller's word for
--     it, which decision 0046 asks for.
--   * `p_extra_lines jsonb`: an array of `{account, amount, tax?,
--     description?}`, booked in the same entry beside the settlement. The
--     account and the tax are codes of the company; the amount is a decimal.
--     A positive amount is a charge — debited, the fee a provider kept, the
--     charges a bank took — and a negative one a credit, a small surplus or
--     interest. A tax is taken out of the amount, which is what left the bank
--     line: the amount holds it.
--
-- **The line balances to the cent, or nothing is booked.** The money of the
-- line is the items it settles less the charges for money coming in, and the
-- items plus the charges for money going out. With amounts named, a cent off
-- is `settlement_unbalanced`, with the difference. With extra lines and no
-- amounts, the items are settled in full, and the same refusal names a cent
-- off: a fee beside a partial settlement is two guesses at once, and a fee
-- keyed a cent wrong would otherwise leave that cent open on the invoice. With
-- neither, nothing moves: the money settles the items oldest first, in part if
-- it is less, and more than is open is `more_money_than_open` within the
-- company's tolerance. A bank charge alone names no item: its extra lines are
-- the whole line.
--
-- **One entry, through `post_entry()`.** Without extra lines nothing moves:
-- a payment, `post_payment()`, and the matchings. With them, the entry is
-- written here, the two lines `post_payment()` writes — the bank account on
-- the same ladder, the counterparty on `resolve_counterpart_account()` — and
-- the extra lines beside them, and the payment of the counterparty points at
-- it for the amount it settles. A tax on an extra line is booked from its
-- postings for a purchase invoice, as `post_document()` books them: the base
-- on the account named with the box of the base posting, each tax posting on
-- its account with its box, a share that is a cost on the account named. Its
-- tax point is the day of the bank line. The matchings are written by
-- `reconcile()`, which holds its counterparty rule; the bank line by this
-- function, under `ekwo.settling_statement`.
--
-- **Refused by name**, before anything is written: an extra line that is not
-- an object, carries a field it does not know (a misspelt `tax` would book a
-- fee with no tax), names no account or an account the company does not have
-- (`unknown_account`), an account that takes no entry by hand — deprecated, off
-- the balance sheet, or reconcilable, whose line would be an open item nobody
-- settles (`account_takes_no_entries`) — an amount of nothing or finer than the
-- currency, a tax the company does not have (`unknown_tax`), a tax not in
-- force on the day, not a percentage, falling due on collection, or not one a
-- company bears on what it buys, and a negative amount with a tax: a charge
-- refunded is a credit note, not a fee (`extra_line_sign`). Amounts named for
-- other than the items (`settlement_amounts_mismatch`), not positive, or over
-- what an item has open (`settlement_over_open`). Extra lines on a line in a
-- currency other than the company's (`extra_lines_foreign_currency`): the
-- bank line carries no rate to book them at.
--
-- Nothing in the function names a country, a currency or an account: the fee
-- account and its tax are the caller's, by code, because no pack names a role
-- for them.

-- ---------------------------------------------------------------------------
-- 1. settle_from_statement — `20261011154807`, amounts and extra lines
-- ---------------------------------------------------------------------------

drop function settle_from_statement(uuid, uuid[]);

create function settle_from_statement(
  p_transaction_id uuid,
  p_line_ids       uuid[]  default null,
  p_amounts        numeric[] default null,
  p_extra_lines    jsonb   default null
)
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
  v_inbound   boolean;
  v_contact   uuid;
  v_contacts  integer;
  v_open      numeric;
  v_journal   uuid;
  v_payment   uuid;
  v_entry     entries;
  v_pay_line  uuid;
  v_remaining numeric;
  v_amount    numeric;
  v_has_items boolean;
  v_extras    jsonb := coalesce(p_extra_lines, '[]'::jsonb);
  v_extra_sum numeric := 0;
  v_settle    numeric;
  v_named     numeric;
  v_home      char(3);
  v_money     uuid;
  v_third     uuid;
  v_label     text;
  v_seq       integer;
  v_base_seq  integer;
  v_has_base  boolean;
  -- One extra line, as it is checked and then booked.
  v_e         jsonb;
  v_n         integer;
  v_code      text;
  v_account   accounts;
  v_tax       taxes;
  v_rate      numeric;
  v_name      text;
  v_base_post record;
  v_net       numeric;
  v_base      numeric;
  v_tax_total numeric;
  v_side_left     numeric;
  v_side_left_neg numeric;
  v_booked    numeric;
  v_box       numeric;
  r           record;
  p           record;
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

  if jsonb_typeof(v_extras) <> 'array' then
    raise exception 'extra_lines_not_a_list: p_extra_lines is an array of {account, amount, tax, description}, got %',
      jsonb_typeof(v_extras);
  end if;

  v_has_items := coalesce(cardinality(p_line_ids), 0) > 0;
  if not v_has_items and jsonb_array_length(v_extras) = 0 then
    raise exception 'no_lines_named: settling needs the open items this money pays';
  end if;

  if p_amounts is not null then
    if coalesce(cardinality(p_amounts), 0) <> coalesce(cardinality(p_line_ids), 0) then
      raise exception 'settlement_amounts_mismatch: % amounts for % items; one amount per item named, in the same order',
        coalesce(cardinality(p_amounts), 0), coalesce(cardinality(p_line_ids), 0);
    end if;
    if exists (select 1 from unnest(p_amounts) a where a is null or a <= 0) then
      raise exception 'settlement_amount_not_positive: every amount an item is settled by is more than nothing';
    end if;
  end if;

  v_inbound := v_tx.amount > 0;
  v_side    := case when v_inbound then 'debit' else 'credit' end;
  v_round   := rounding_of(v_tx.company_id, v_tx.currency_code);

  if v_has_items then
    -- Every line has to be open, of this company, and on the side this money
    -- can settle. Anything else is a caller that has not looked.
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

    if p_amounts is not null then
      select i.line_id, i.amount_open, a.amount into r
        from unnest(p_line_ids, p_amounts) as a (line_id, amount)
        join open_items(v_tx.company_id) i on i.line_id = a.line_id
       where a.amount > i.amount_open
       limit 1;
      if found then
        raise exception 'settlement_over_open: item % has % open and % was named against it',
          r.line_id, r.amount_open, r.amount;
      end if;
    end if;
  end if;

  -- ------------------------------------------------- the extra lines, checked
  if jsonb_array_length(v_extras) > 0 then
    select c.currency_code into v_home from companies c where c.id = v_tx.company_id;
    if v_tx.currency_code <> v_home then
      raise exception 'extra_lines_foreign_currency: statement line % is in %, and an extra line is booked in the company''s currency at a rate the line does not carry',
        p_transaction_id, v_tx.currency_code;
    end if;
  end if;

  for v_e, v_n in select e.value, e.ordinality from jsonb_array_elements(v_extras) with ordinality e loop
    if jsonb_typeof(v_e) <> 'object' then
      raise exception 'extra_line_not_an_object: extra line % is %, not {account, amount, tax, description}',
        v_n, jsonb_typeof(v_e);
    end if;
    select k into v_code from jsonb_object_keys(v_e) k
     where k not in ('account', 'amount', 'tax', 'description') limit 1;
    if found then
      raise exception 'extra_line_unknown_field: extra line % carries "%"; an extra line is {account, amount, tax, description}',
        v_n, v_code;
    end if;

    v_code := nullif(btrim(v_e->>'account'), '');
    if v_code is null then
      raise exception 'extra_line_without_account: extra line % names no account', v_n;
    end if;
    select * into v_account from accounts a
     where a.company_id = v_tx.company_id and a.code = v_code;
    if not found then
      raise exception 'unknown_account: extra line % names account %, which this company does not have', v_n, v_code
        using errcode = 'no_data_found';
    end if;
    if v_account.deprecated or v_account.account_type = 'off_balance' or v_account.reconcilable then
      raise exception 'account_takes_no_entries: account % is %; an extra line is booked on an account that takes a charge or an income',
        v_code,
        case when v_account.deprecated then 'deprecated'
             when v_account.account_type = 'off_balance' then 'off the balance sheet'
             else 'reconcilable, and its line would be an open item nothing settles' end;
    end if;

    begin
      v_amount := (v_e->>'amount')::numeric;
    exception when others then
      raise exception 'extra_line_bad_amount: extra line % has amount "%", which is not a decimal', v_n, v_e->>'amount';
    end;
    if v_amount is null or v_amount = 0 then
      raise exception 'extra_line_zero: extra line % books nothing; an extra line has an amount', v_n;
    end if;
    if v_amount <> round_amount(v_amount, v_round) then
      raise exception 'extra_line_not_rounded: extra line % is %, finer than the currency is counted in', v_n, v_amount;
    end if;

    if v_e ? 'tax' and jsonb_typeof(v_e->'tax') <> 'null' then
      v_code := nullif(btrim(v_e->>'tax'), '');
      select * into v_tax from taxes t where t.company_id = v_tx.company_id and t.code = v_code;
      if not found then
        raise exception 'unknown_tax: extra line % names tax %, which this company does not have', v_n, v_code
          using errcode = 'no_data_found';
      end if;
      if v_amount < 0 then
        raise exception 'extra_line_sign: extra line % is % with tax %; a charge bearing a tax is positive, and a charge refunded is a credit note',
          v_n, v_amount, v_code;
      end if;
      if v_tax.amount_type <> 'percent' then
        raise exception 'unsupported_tax_amount_type: tax % is not a percentage, and an extra line takes its tax out of its amount', v_code;
      end if;
      if tax_rate_at(v_tax.id, v_tx.transaction_date) is null then
        raise exception 'tax_not_in_force: tax % is not applicable on %', v_code, v_tx.transaction_date;
      end if;
      if v_tax.applies_to = 'sale' then
        raise exception 'extra_line_tax_on_sales: tax % applies to sales; an extra line is a charge the company bears, and takes a tax on purchases', v_code;
      end if;
      if v_tax.cash_basis then
        raise exception 'extra_line_cash_basis_tax: tax % falls due on collection, and an extra line is settled the day it is booked', v_code;
      end if;
    end if;

    v_extra_sum := v_extra_sum + v_amount;
  end loop;

  -- ------------------------------------------------------------ the balance
  -- Money in: the items settle the money plus the charges kept back. Money
  -- out: the items settle the money less the charges paid with it.
  v_settle := abs(v_tx.amount) + case when v_inbound then v_extra_sum else -v_extra_sum end;

  if not v_has_items then
    if v_settle <> 0 then
      raise exception 'settlement_unbalanced: the statement line is % and the extra lines book %; off by %',
        v_tx.amount, v_extra_sum, v_settle
        using errcode = '23514';
    end if;
  elsif p_amounts is not null then
    select sum(a) into v_named from unnest(p_amounts) a;
    if v_named <> v_settle then
      raise exception 'settlement_unbalanced: the statement line is %, the items named settle % and the extra lines book %; off by %',
        v_tx.amount, v_named, v_extra_sum, v_named - v_settle
        using errcode = '23514';
    end if;
  elsif jsonb_array_length(v_extras) > 0 then
    -- Extra lines and no amount: the items are settled in full. A fee beside
    -- a partial settlement is two guesses at once, and a fee keyed a cent off
    -- would leave that cent open on the invoice with nobody told.
    if v_settle <> v_open then
      raise exception 'settlement_unbalanced: the statement line is %, the items named leave % open and the extra lines book %; off by %. Name the amount each item is settled by to settle one in part',
        v_tx.amount, v_open, v_extra_sum, v_open - v_settle
        using errcode = '23514';
    end if;
  else
    v_policy    := matching_policy_of(v_tx.company_id);
    v_tolerance := v_policy.amount_tolerance_units * power(10::numeric, -v_round.decimals);
    if v_settle > v_open + v_tolerance then
      raise exception 'more_money_than_open: the statement line is % and the items named leave % open',
        v_settle, v_open;
    end if;
  end if;

  select coalesce(b.journal_id, (select j.id from journals j
                                  where j.company_id = v_tx.company_id and j.bank_account_id = b.id
                                  limit 1))
    into v_journal
  from bank_accounts b where b.id = v_tx.bank_account_id;
  if v_journal is null then
    raise exception 'no_journal_for_bank_account: account % books through no journal', v_tx.bank_account_id;
  end if;

  if v_has_items then
    insert into payments (company_id, direction, payment_date, amount, currency_code,
                          contact_id, journal_id, bank_account_id, reference, memo)
    values (v_tx.company_id,
            (case when v_inbound then 'inbound' else 'outbound' end)::payment_direction,
            v_tx.transaction_date, v_settle, v_tx.currency_code,
            v_contact, v_journal, v_tx.bank_account_id,
            coalesce(v_tx.structured_reference, v_tx.reference),
            v_tx.description)
    returning id into v_payment;
  end if;

  if jsonb_array_length(v_extras) = 0 then
    -- Nothing beside the payment: `post_payment()` books it, as it always has.
    v_entry := post_payment(v_payment);

    -- The third-party side of the payment: the line the open items are
    -- matched against. The other side is the bank account, which settles
    -- nothing.
    select l.id into v_pay_line
    from entry_lines l
    join accounts a on a.id = l.account_id
    where l.entry_id = v_entry.id and a.reconcilable
    limit 1;
    if v_pay_line is null then
      raise exception 'payment_has_no_third_party_line: entry % books against no reconcilable account',
        v_entry.id;
    end if;
  else
    -- ------------------------------------------- one entry, extra lines beside
    -- The bank side, on the ladder `post_payment()` climbs.
    select b.account_id into v_money from bank_accounts b where b.id = v_tx.bank_account_id;
    if v_money is null then
      select j.default_account_id into v_money from journals j where j.id = v_journal;
    end if;
    if v_money is null then
      select b.account_id into v_money
        from bank_accounts b
       where b.journal_id = v_journal and b.active and b.account_id is not null
       order by b.created_at
       limit 1;
    end if;
    if v_money is null then
      raise exception 'no_bank_account: set account_id on bank account %, or default_account_id on journal %',
        v_tx.bank_account_id, v_journal;
    end if;

    v_label := coalesce(v_tx.structured_reference, v_tx.reference, v_tx.description, 'statement line');

    insert into entries (company_id, journal_id, fiscal_year_id, entry_date, reference,
                         description, state, currency_code)
    values (v_tx.company_id, v_journal,
            fiscal_year_at(v_tx.company_id, v_tx.transaction_date), v_tx.transaction_date,
            coalesce(v_tx.structured_reference, v_tx.reference), v_label, 'draft', v_tx.currency_code)
    returning * into v_entry;

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, currency_code)
    values (v_entry.id, v_tx.company_id, v_money, 10, v_label,
            case when v_inbound then abs(v_tx.amount) else 0 end,
            case when v_inbound then 0 else abs(v_tx.amount) end,
            v_tx.currency_code);

    if v_has_items then
      v_contact := commercial_entity(v_contact);
      v_third   := resolve_counterpart_account(v_tx.company_id, v_contact, v_inbound);
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, contact_id, currency_code)
      values (v_entry.id, v_tx.company_id, v_third, 20, v_label,
              case when v_inbound then 0 else v_settle end,
              case when v_inbound then v_settle else 0 end,
              v_contact, v_tx.currency_code)
      returning id into v_pay_line;
    end if;

    v_seq := 20;
    for v_e in select e.value from jsonb_array_elements(v_extras) e loop
      select * into v_account from accounts a
       where a.company_id = v_tx.company_id and a.code = btrim(v_e->>'account');
      v_amount := (v_e->>'amount')::numeric;
      v_name   := left(coalesce(nullif(btrim(v_e->>'description'), ''), v_label), 200);

      if not (v_e ? 'tax') or jsonb_typeof(v_e->'tax') = 'null' then
        v_seq := v_seq + 10;
        insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                                 debit, credit, currency_code)
        values (v_entry.id, v_tx.company_id, v_account.id, v_seq, v_name,
                greatest(v_amount, 0), greatest(-v_amount, 0), v_tx.currency_code);
        continue;
      end if;

      -- A charge bearing a tax, booked from the postings of a purchase
      -- invoice: the base debited, a positive factor on the side of the base
      -- and a negative one on the other. The amount holds the tax, so the
      -- base is what is left once every posting has taken its share — which
      -- is the amount itself where the postings net out, as a self-assessed
      -- tax does.
      select * into v_tax from taxes t
       where t.company_id = v_tx.company_id and t.code = btrim(v_e->>'tax');
      v_rate := tax_rate_at(v_tax.id, v_tx.transaction_date);

      select tp.declaration_box, tp.box_factor_percent, tp.factor_percent
        into v_base_post
        from tax_postings tp
       where tp.tax_id = v_tax.id and tp.document_kind = 'invoice' and tp.posting_type = 'base'
       limit 1;
      v_has_base := found;

      select coalesce(sum(tp.factor_percent), 0) / 100 into v_net
        from tax_postings tp
       where tp.tax_id = v_tax.id and tp.document_kind = 'invoice'
         and tp.posting_type in ('tax', 'tax_on_base');

      v_base := round_amount(
        v_amount / (coalesce(v_base_post.factor_percent, 100) / 100 + v_rate / 100 * v_net), v_round);
      v_tax_total := round_amount(v_base * v_rate / 100, v_round);

      -- The base line is written last, for what the postings leave of the
      -- amount, so that the extra line books its amount to the cent.
      v_booked := 0;
      v_seq := v_seq + 10;
      v_base_seq := v_seq;
      v_side_left     := null;
      v_side_left_neg := null;

      for p in
        select tp.posting_type, tp.factor_percent, tp.account_id,
               tp.declaration_box, tp.box_factor_percent,
               case when tp.factor_percent >= 0 then 1 else -1 end as side,
               sum(abs(tp.factor_percent))
                 over (partition by case when tp.factor_percent >= 0 then 1 else -1 end)
                 as side_factor,
               row_number() over (
                 partition by case when tp.factor_percent >= 0 then 1 else -1 end
                 order by tp.sequence, tp.id)
               = count(*) over (
                 partition by case when tp.factor_percent >= 0 then 1 else -1 end)
                 as is_last_of_side
          from tax_postings tp
         where tp.tax_id = v_tax.id
           and tp.document_kind = 'invoice'
           and tp.posting_type in ('tax', 'tax_on_base')
         order by tp.sequence, tp.id
      loop
        -- The shares of one side add up to that side's share of the one tax
        -- figure, the last taking what is left, as `post_document()` does.
        if p.side >= 0 then
          if v_side_left is null then
            v_side_left := round_amount(v_tax_total * p.side_factor / 100, v_round);
          end if;
          if p.is_last_of_side then
            v_amount := v_side_left;
          else
            v_amount    := round_amount(v_tax_total * abs(p.factor_percent) / 100, v_round);
            v_side_left := v_side_left - v_amount;
          end if;
        else
          if v_side_left_neg is null then
            v_side_left_neg := round_amount(v_tax_total * p.side_factor / 100, v_round);
          end if;
          if p.is_last_of_side then
            v_amount := v_side_left_neg;
          else
            v_amount        := round_amount(v_tax_total * abs(p.factor_percent) / 100, v_round);
            v_side_left_neg := v_side_left_neg - v_amount;
          end if;
        end if;
        if v_amount = 0 then
          continue;
        end if;

        v_box := case when p.declaration_box is null then null
                      else round_amount(v_tax_total * p.box_factor_percent / 100, v_round) end;
        v_booked := v_booked + p.side * v_amount;
        v_seq := v_seq + 10;

        -- A `tax_on_base` share is a cost: it lands on the account named.
        insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                                 debit, credit, tax_id, tax_line, posting_type,
                                 declaration_box, box_amount, tax_point_date, currency_code)
        values (v_entry.id, v_tx.company_id,
                case when p.posting_type = 'tax' then p.account_id else v_account.id end,
                v_seq, left(v_tax.name, 200),
                case when p.side >= 0 then v_amount else 0 end,
                case when p.side >= 0 then 0 else v_amount end,
                v_tax.id, p.posting_type = 'tax', p.posting_type,
                p.declaration_box, v_box, v_tx.transaction_date, v_tx.currency_code);
      end loop;

      v_amount := (v_e->>'amount')::numeric - v_booked;
      if v_amount <= 0 then
        raise exception 'extra_line_tax_exceeds_amount: extra line on account % is %, and tax % takes %',
          v_account.code, (v_e->>'amount')::numeric, v_tax.code, v_booked;
      end if;
      insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                               debit, credit, tax_id, tax_line, posting_type,
                               declaration_box, box_amount, tax_point_date, currency_code)
      values (v_entry.id, v_tx.company_id, v_account.id, v_base_seq,
              v_name, v_amount, 0,
              v_tax.id, false, case when v_has_base then 'base'::tax_posting_type end,
              v_base_post.declaration_box,
              case when v_base_post.declaration_box is null then null
                   else round_amount(v_base * v_base_post.box_factor_percent / 100, v_round) end,
              v_tx.transaction_date, v_tx.currency_code);
    end loop;

    v_entry := post_entry(v_entry.id);

    if v_payment is not null then
      update payments set entry_id = v_entry.id, state = 'posted' where id = v_payment;
    end if;
  end if;

  -- The matchings. Amounts named: each item for its amount. Otherwise oldest
  -- first, each item settled up to what is left of the money — a partial
  -- settlement is possible here because a person asked for it by naming the
  -- lines; `auto_settle()` never gets here with less money than is open.
  if v_has_items then
    if p_amounts is not null then
      for r in
        select a.line_id, a.amount
          from unnest(p_line_ids, p_amounts) with ordinality as a (line_id, amount, n)
         order by a.n
      loop
        perform reconcile(v_pay_line, r.line_id, r.amount);
      end loop;
    else
      v_remaining := least(v_settle, v_open);
      for r in
        select * from open_items(v_tx.company_id) i
        where i.line_id = any(p_line_ids)
        order by i.entry_date, i.line_id
      loop
        exit when v_remaining <= 0;
        perform reconcile(v_pay_line, r.line_id, least(r.amount_open, v_remaining));
        v_remaining := v_remaining - least(r.amount_open, v_remaining);
      end loop;
    end if;
  end if;

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

comment on function settle_from_statement(uuid, uuid[], numeric[], jsonb) is
  'Books the payment a statement line is, and matches it against the open items named, in one entry through post_entry() and one transaction. p_amounts, beside p_line_ids, says how much settles each item (partial settlement, several items at once); without it the items are settled oldest first, and in full when there are extra lines. p_extra_lines books beside the settlement what the money is net of or carries besides — a fee a payment provider kept, bank charges, a small difference — as [{account, amount, tax?, description?}]: account and tax are codes of the company, a positive amount is a charge (debit) and a negative one a credit, and a tax is taken out of the amount from the postings of a purchase invoice. The line balances to the cent — money in is the items less the charges, money out the items plus the charges — or settlement_unbalanced names the difference; extra lines alone settle a bank charge with no item. Without extra lines, post_payment() books the payment as before. The matchings are reconcile()''s, one counterparty; the one writer of bank_transactions.entry_id and of the reconciled state, which bank_transactions_guard() holds it to.';

-- ---------------------------------------------------------------------------
-- Grants
--
-- The function is created anew under its new signature, so its privileges
-- are said again: the old signature's went with it.
-- ---------------------------------------------------------------------------

revoke execute on function settle_from_statement(uuid, uuid[], numeric[], jsonb) from public, anon;
grant execute on function settle_from_statement(uuid, uuid[], numeric[], jsonb) to authenticated, service_role;
