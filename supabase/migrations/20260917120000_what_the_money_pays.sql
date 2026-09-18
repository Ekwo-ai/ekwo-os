-- Ekwo OS — what the money pays.
--
-- The other half of recognising a statement line. `confirm_contact()` says who
-- the money came from; this says what it settles, which is a different
-- question and a stricter one: getting the counterparty wrong misfiles a line,
-- getting the settlement wrong marks an invoice paid that nobody paid.
--
-- Three rules hold the whole file together.
--
-- **A statement line does not become an entry.** It becomes a *payment* —
-- the object the ledger already knows, with its journal, its direction, its
-- counterpart account — and `post_payment()` books it. There is no second way
-- of writing a ledger here, and nothing in this file inserts an `entries` or
-- an `entry_lines` row.
--
-- **Only identification is applied; resemblance is proposed.** A reference
-- that matches, or an exact amount with exactly one candidate, is an
-- identification. A sum of invoices that happens to reach the right total is a
-- resemblance: it is offered and never applied on its own. The production this
-- comes from does apply combinations, at two cents of tolerance, and it is
-- right often enough to be tempting — but a combination that lands on the
-- right total from the wrong invoices leaves no trace that anything went
-- wrong, and that is the one mistake a ledger cannot show you afterwards.
--
-- **Partial is never automatic.** A payment smaller than the invoice may be a
-- deposit, a discount, a short payment or an error — four different treatments
-- and the ledger cannot tell them apart. `settle_from_statement()` will settle
-- partially when a person names the lines; `auto_settle()` never will.

-- ---------------------------------------------------------------------------
-- open_items
--
-- What is still owed, line by line, in the shape matching needs: the side, the
-- amount still open, the document behind it and the references it carries.
-- `aged_balance()` answers a neighbouring question for a human to read; this
-- one is keyed for a machine to search.
-- ---------------------------------------------------------------------------

create or replace function open_items(
  p_company_id uuid,
  p_contact_id uuid default null,
  p_as_of      date default null
)
returns table (
  line_id         uuid,
  contact_id      uuid,
  account_id      uuid,
  side            text,
  amount_open     numeric,
  entry_date      date,
  date_maturity   date,
  document_id     uuid,
  document_number text,
  reference       text
)
language sql
stable
security invoker
as $$
  select l.id,
         l.contact_id,
         l.account_id,
         case when l.debit > 0 then 'debit' else 'credit' end,
         abs(l.balance) - l.matched_amount,
         e.entry_date,
         l.date_maturity,
         d.id,
         d.number,
         coalesce(d.payment_reference, d.number)
  from entry_lines l
  join entries e   on e.id = l.entry_id
  join accounts a  on a.id = l.account_id
  left join documents d on d.entry_id = e.id
  where l.company_id = p_company_id
    and e.state = 'posted'
    and a.reconcilable
    and abs(l.balance) - l.matched_amount > 0
    and (p_contact_id is null or l.contact_id = p_contact_id)
    and (p_as_of is null or e.entry_date <= p_as_of);
$$;

comment on function open_items(uuid, uuid, date) is
  'Third-party lines with something still open, with the document behind each and the references it carries. Read by the matching, and by anybody asking what is still owed.';

revoke execute on function open_items(uuid, uuid, date) from public, anon;
grant execute on function open_items(uuid, uuid, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- suggest_matches
--
-- Read-only, and — like `suggest_contacts()` — it decides nothing. Every
-- candidate says what kind of evidence it rests on and how many other
-- candidates the same evidence produced.
-- ---------------------------------------------------------------------------

create or replace function suggest_matches(p_transaction_id uuid)
returns table (
  kind         text,
  line_ids     uuid[],
  amount       numeric,
  method       text,
  score        numeric,
  because      text,
  alternatives integer
)
language plpgsql
stable
security invoker
as $$
declare
  v_tx        bank_transactions;
  v_policy    matching_policy;
  v_round     money_rounding;
  v_tolerance numeric;
  v_side      text;
  v_target    numeric;
  v_home      char(3);
  v_internal  boolean;
begin
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;

  v_policy := matching_policy_of(v_tx.company_id);
  select c.currency_code into v_home from companies c where c.id = v_tx.company_id;

  -- One smallest unit of the currency, whatever that currency calls a unit.
  -- A yen has none, a dinar has three, and `round_amount` has known that since
  -- the rounding read the currency.
  v_round     := rounding_of(v_tx.company_id, v_tx.currency_code);
  v_tolerance := v_policy.amount_tolerance_units * power(10::numeric, -v_round.decimals);

  -- Money in settles what a customer owes, which is a debit still open. Money
  -- out settles what we owe, which is a credit.
  v_side   := case when v_tx.amount > 0 then 'debit' else 'credit' end;
  v_target := abs(v_tx.amount);

  -- A transfer between two accounts of this company is not a settlement of
  -- anything, and saying so is the point: the production this comes from
  -- learnt that an internal wire left alone gets matched to whatever invoice
  -- happens to carry the same amount.
  select exists (
    select 1 from bank_accounts b
    where b.company_id = v_tx.company_id
      and b.iban is not null
      and v_tx.counterpart_iban is not null
      and upper(replace(b.iban, ' ', '')) = upper(replace(v_tx.counterpart_iban, ' ', ''))
  ) into v_internal;

  if v_internal then
    return query
      select 'internal_transfer'::text, '{}'::uuid[], v_target, 'own_account'::text, 1::numeric,
             'the counterparty account is an account of this company'::text, 1;
    return;
  end if;

  -- Matching across currencies is not done here. The ledger amount and the
  -- statement amount are then two numbers in two currencies, and the rate that
  -- reconciles them is a question `reconcile()` answers at the moment of
  -- matching, not one a search may assume. Recorded in docs/international.md.
  if v_tx.currency_code <> v_home then
    return;
  end if;

  return query
  with items as (
    select * from open_items(v_tx.company_id, v_tx.contact_id)
    where side = v_side
  ),
  -- 1. A reference. The strongest evidence there is, because it was put there
  --    for this purpose — and the weakest link in the chain too, which is why
  --    its check digits are a gap written down rather than a guess made here.
  by_reference as (
    select 'document'::text as kind, array[i.line_id] as line_ids,
           least(i.amount_open, v_target) as amount,
           'reference'::text as method, 1::numeric as score,
           format('the statement carries the reference of %s', coalesce(i.document_number, i.reference)) as because
    from items i
    where i.reference is not null
      and (
        (v_tx.structured_reference is not null
         and upper(regexp_replace(v_tx.structured_reference, '[^0-9A-Za-z]', '', 'g'))
           = upper(regexp_replace(i.reference, '[^0-9A-Za-z]', '', 'g')))
        or (v_tx.reference is not null
            and upper(regexp_replace(v_tx.reference, '[^0-9A-Za-z]', '', 'g'))
              = upper(regexp_replace(i.reference, '[^0-9A-Za-z]', '', 'g')))
        or (v_tx.description is not null
            and position(upper(i.reference) in upper(v_tx.description)) > 0)
      )
  ),
  -- 2. The amount, to the tolerance the company set, inside the window it set.
  by_amount as (
    select 'document'::text, array[i.line_id], i.amount_open,
           'exact_amount'::text, 0.900::numeric,
           format('%s is open on %s and the statement is for the same amount',
                  i.amount_open, coalesce(i.document_number, 'an entry')) as because
    from items i
    where abs(i.amount_open - v_target) <= v_tolerance
      and abs(i.entry_date - v_tx.transaction_date) <= v_policy.date_window_days
  ),
  candidates as (
    select * from by_reference
    union all select * from by_amount
  )
  select c.kind, c.line_ids, c.amount, c.method, c.score, c.because,
         count(*) over (partition by c.method)::integer
  from candidates c
  order by c.score desc, c.amount desc;
end;
$$;

comment on function suggest_matches(uuid) is
  'What a statement line could settle: the open items it matches, the evidence, and how many candidates that same evidence produced. Writes nothing. A combination of several documents is offered by suggest_combination(), separately, because it is a resemblance and not an identification.';

revoke execute on function suggest_matches(uuid) from public, anon;
grant execute on function suggest_matches(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- suggest_combination
--
-- One transaction paying several invoices at once — the ordinary shape of a
-- customer who settles a month of them in one wire. Deliberately its own
-- function: the answer is a *proposal*, never applied by `auto_settle()`, and
-- keeping it apart makes that visible rather than buried in a score.
--
-- The walk is oldest first and greedy, which is what the production this comes
-- from does, and it is deterministic — the same statement and the same ledger
-- give the same answer every time. It does not prove the subset is the only
-- one that works, and that is exactly why it is not applied.
-- ---------------------------------------------------------------------------

create or replace function suggest_combination(p_transaction_id uuid)
returns table (
  line_ids uuid[],
  amount   numeric,
  because  text
)
language plpgsql
stable
security invoker
as $$
declare
  v_tx        bank_transactions;
  v_policy    matching_policy;
  v_round     money_rounding;
  v_tolerance numeric;
  v_side      text;
  v_remaining numeric;
  v_picked    uuid[] := '{}';
  v_total     numeric := 0;
  v_home      char(3);
  r           record;
begin
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
  if not found then
    raise exception 'not_found: bank transaction %', p_transaction_id
      using errcode = 'no_data_found';
  end if;

  -- Without a counterparty the search space is every open item of the company,
  -- and a sum that reaches the right total across unrelated customers is
  -- arithmetic, not evidence.
  if v_tx.contact_id is null then return; end if;

  select c.currency_code into v_home from companies c where c.id = v_tx.company_id;
  if v_tx.currency_code <> v_home then return; end if;

  v_policy    := matching_policy_of(v_tx.company_id);
  v_round     := rounding_of(v_tx.company_id, v_tx.currency_code);
  -- Each document was rounded on its own, so a sum of them may miss by more
  -- than one unit. Two, by default, and the company may say otherwise.
  v_tolerance := v_policy.sum_tolerance_units * power(10::numeric, -v_round.decimals);
  v_side      := case when v_tx.amount > 0 then 'debit' else 'credit' end;
  v_remaining := abs(v_tx.amount);

  for r in
    select * from open_items(v_tx.company_id, v_tx.contact_id)
    where side = v_side
      and abs(entry_date - v_tx.transaction_date) <= v_policy.date_window_days
    order by entry_date, line_id
  loop
    if r.amount_open <= v_remaining + v_tolerance then
      v_picked    := v_picked || r.line_id;
      v_total     := v_total + r.amount_open;
      v_remaining := v_remaining - r.amount_open;
    end if;
    exit when abs(v_remaining) <= v_tolerance;
  end loop;

  if cardinality(v_picked) > 1 and abs(v_remaining) <= v_tolerance then
    return query select v_picked, v_total,
      format('%s open items of this counterparty add up to %s', cardinality(v_picked), v_total);
  end if;
end;
$$;

comment on function suggest_combination(uuid) is
  'A subset of one counterparty''s open items that adds up to the statement line, oldest first. A proposal only: it is never applied automatically, because a sum that reaches the right total from the wrong documents leaves nothing behind to notice.';

revoke execute on function suggest_combination(uuid) from public, anon;
grant execute on function suggest_combination(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- settle_from_statement
--
-- The act. A person — or an agent acting as one — names the lines this money
-- settles, and this books the payment and matches it.
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
  select * into v_tx from bank_transactions t where t.id = p_transaction_id;
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

  update bank_transactions t
     set entry_id   = v_entry.id,
         contact_id = coalesce(t.contact_id, v_contact),
         state      = 'reconciled'
   where t.id = p_transaction_id
  returning * into v_tx;

  return v_tx;
end;
$$;

comment on function settle_from_statement(uuid, uuid[]) is
  'Books the payment a statement line is, and matches it against the open items named. One counterparty, one payment, `post_payment()` and `reconcile()` doing the accounting — nothing here writes a ledger of its own.';

revoke execute on function settle_from_statement(uuid, uuid[]) from public, anon;
grant execute on function settle_from_statement(uuid, uuid[]) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- auto_settle
--
-- The pass over a period. It applies what is an identification and leaves
-- everything else with a reason, which is the report a bookkeeper actually
-- reads: what went through, what is waiting for them, and what nobody can
-- decide from the ledger alone.
-- ---------------------------------------------------------------------------

create or replace function auto_settle(
  p_company_id uuid,
  p_from       date,
  p_to         date,
  p_apply      boolean default false
)
returns table (
  transaction_id uuid,
  action         text,
  method         text,
  line_ids       uuid[],
  because        text
)
language plpgsql
volatile
security invoker
as $$
declare
  v_policy    matching_policy;
  v_round     money_rounding;
  v_tolerance numeric;
  t           record;
  best        record;
  v_count     integer;
  v_open      numeric;
begin
  v_policy := matching_policy_of(p_company_id);

  for t in
    select * from bank_transactions b
    where b.company_id = p_company_id
      and b.state = 'pending'
      and b.entry_id is null
      and b.transaction_date between p_from and p_to
    order by b.transaction_date, b.sequence
  loop
    v_round     := rounding_of(p_company_id, t.currency_code);
    v_tolerance := v_policy.amount_tolerance_units * power(10::numeric, -v_round.decimals);

    select count(*) into v_count
    from suggest_matches(t.id) s
    where s.kind = 'internal_transfer';
    if v_count > 0 then
      transaction_id := t.id; action := 'left'; method := 'internal_transfer';
      line_ids := '{}'::uuid[];
      because := 'a transfer between two accounts of this company settles nothing, and its other side is its own statement line';
      return next; continue;
    end if;

    -- The one candidate whose evidence identified exactly one thing.
    select * into best
    from suggest_matches(t.id) s
    where s.alternatives = 1 and s.method in ('reference', 'exact_amount')
    order by s.score desc
    limit 1;

    if not found then
      select count(*) into v_count from suggest_matches(t.id);
      transaction_id := t.id; action := 'proposed'; method := 'none';
      line_ids := '{}'::uuid[];
      because := case when v_count = 0
                      then 'nothing open matches this line'
                      else format('%s candidates, none of them an identification', v_count) end;
      return next; continue;
    end if;

    -- Partial settlement is four different accounting treatments wearing the
    -- same face. The machine proposes; a person decides which one it is.
    select sum(i.amount_open) into v_open
    from open_items(p_company_id) i where i.line_id = any(best.line_ids);
    if abs(t.amount) + v_tolerance < v_open then
      transaction_id := t.id; action := 'proposed'; method := best.method;
      line_ids := best.line_ids;
      because := format('%s of %s — a deposit, a discount, a short payment or an error, and the ledger cannot tell which',
                        abs(t.amount), v_open);
      return next; continue;
    end if;

    if p_apply then
      perform settle_from_statement(t.id, best.line_ids);
      transaction_id := t.id; action := 'settled';
    else
      transaction_id := t.id; action := 'would_settle';
    end if;
    method := best.method; line_ids := best.line_ids; because := best.because;
    return next;
  end loop;
end;
$$;

comment on function auto_settle(uuid, date, date, boolean) is
  'Walks the pending statement lines of a period and settles the ones a single piece of evidence identifies — a reference, or an exact amount with one candidate. Everything else comes back with the reason it was left: a combination, a partial payment, an internal transfer, or nothing open that fits. With p_apply false it changes nothing and says what it would do.';

revoke execute on function auto_settle(uuid, date, date, boolean) from public, anon;
grant execute on function auto_settle(uuid, date, date, boolean) to authenticated, service_role;
