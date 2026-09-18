-- Ekwo OS — what a declaration owes.
--
-- A return that was accepted leaves the books in a state nothing clears: the
-- tax accounts keep the collected and the deductible of the period, side by
-- side, and the amount actually owed to the administration is a subtraction
-- nobody wrote down. Every month that passes adds another period to the same
-- two accounts, and by the end of a year their balances say nothing at all —
-- not what is owed, not what was paid, not what is still open.
--
-- What is missing is one entry per declaration: the tax accounts of the period
-- go back to zero, and the net lands on the account that carries the debt
-- towards the administration. From there the money has somewhere to go —
-- the debt is a position that stays open until a payment settles it, and
-- `auto_settle()` matches that payment the way it matches any other.
--
-- Three rules, and they are the rules of the rest of this schema:
--
-- **The accounts come from the pack.** `tax_payable` and `tax_receivable` are
-- roles, like `rounding` or `retained_earnings`, and a pack that names neither
-- gets a refusal by name rather than the account another country happens to
-- use.
--
-- **The entry goes through `post_entry()`.** Nothing here inserts a posted
-- entry: the numbering, the period locks, the balance check and the audit
-- trail are the ones every other entry goes through.
--
-- **A declaration has at most one settlement.** The link is a column with a
-- unique index, so replaying is refused by the database and not by a caller
-- remembering.
--
-- Two things this does not do, on purpose.
--
-- *It settles the ledger, not the boxes.* The lines it clears are the ones the
-- return read — same window, same `tax_point_date` rule — but the figure it
-- carries to the debt account is what those lines sum to, not what the frozen
-- boxes say. The two can differ: a country that rounds what it claims to the
-- unit, a box a form asks for that no posting fills. Where they differ,
-- `filing_drift()` is the function that says so, and inventing an account to
-- absorb the difference here would be hiding exactly what it exists to show.
--
-- *A late entry in a settled period is not picked up.* It falls in the window
-- of a declaration that has gone; its treatment is a corrective, and a
-- corrective is what supersedes the filing and settles the difference.

-- ---------------------------------------------------------------------------
-- The two roles
-- ---------------------------------------------------------------------------

alter table country_defaults
  add column if not exists tax_payable_code    text,
  add column if not exists tax_receivable_code text;

comment on column country_defaults.tax_payable_code is
  'The account that carries what a filed declaration owes to the administration, once the tax accounts of the period have been cleared into it (FR 445510, LU 461412, GB 2210). It has to be an account apart from the ones the taxes themselves post to, and reconcilable, because the payment is matched against it. Null until a pack names one, and then settling refuses by name.';
comment on column country_defaults.tax_receivable_code is
  'The same account for a period that ends in a credit, where the chart keeps the two apart (FR 445670). Null falls back to tax_payable_code, for a chart that keeps one control account whose sign says which way it goes.';

-- ---------------------------------------------------------------------------
-- What happens to a credit
--
-- A period that ends in the company's favour has two outcomes and they are not
-- the same object afterwards: carried forward, it will be absorbed by the next
-- declaration and nobody is waiting for money; claimed back, it is a
-- receivable that a repayment settles, and it belongs in the aged balance
-- until it arrives. Which of the two is the company's decision — most
-- administrations ask, and some make the answer conditional on an amount — so
-- it is asked for rather than defaulted.
-- ---------------------------------------------------------------------------

create type tax_credit_treatment as enum ('carry_forward', 'refund');

comment on type tax_credit_treatment is
  'What a company does with a period that ends in a credit: carry it to the next declaration, or claim it back. There is no default: the choice is the company''s, and both are ordinary.';

alter table tax_filings
  add column if not exists settlement_entry_id uuid references entries(id) on delete restrict,
  add column if not exists credit_treatment    tax_credit_treatment;

comment on column tax_filings.settlement_entry_id is
  'The entry that cleared the tax accounts of this period into the debt towards the administration. One per declaration, enforced by a unique index: replaying the settlement is refused rather than doubling the debt.';
comment on column tax_filings.credit_treatment is
  'Set when the period ended in a credit, and only then: carried forward to the next declaration, or claimed back.';

create unique index tax_filings_settlement_entry_idx
  on tax_filings (settlement_entry_id)
  where settlement_entry_id is not null;

-- ---------------------------------------------------------------------------
-- open_items, with one more place a reference can come from
--
-- Matching by reference reads the document behind the line. The debt of a
-- declaration has no document — it is an entry, keyed by this file — and
-- without this it would only ever be found by its amount. So the entry's own
-- reference answers where there is no document: it is the field an operator
-- fills with the structured communication of a tax payment, and the one a
-- manual entry carries in every other case too.
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
         coalesce(d.payment_reference, d.number, e.reference)
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
  'Third-party lines with something still open, with the document behind each and the references it carries. Where there is no document — the debt of a declaration, an entry keyed by hand — the entry''s own reference answers. Read by the matching, and by anybody asking what is still owed.';

revoke execute on function open_items(uuid, uuid, date) from public, anon;
grant execute on function open_items(uuid, uuid, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- filing_tax_movements
--
-- What a declared period actually moved, account by account, in the window and
-- under the date rule `vat_return()` reads. Its own function because settling
-- is not the only reason to ask: before an entry exists, this is what the
-- settlement will be, and after one exists it is what the settlement was
-- computed from.
-- ---------------------------------------------------------------------------

create or replace function filing_tax_movements(p_filing_id uuid)
returns table (account_id uuid, balance numeric)
language sql
stable
security invoker
as $$
  select l.account_id,
         round_amount(sum(l.balance), rounding_of(f.company_id))
    from tax_filings f
    join entry_lines l on l.company_id = f.company_id
    join entries e     on e.id = l.entry_id
   where f.id = p_filing_id
     and e.state = 'posted'
     and l.tax_line
     and coalesce(l.tax_point_date, e.entry_date) between f.period_start and f.period_end
   group by l.account_id, f.company_id
  having round_amount(sum(l.balance), rounding_of(f.company_id)) <> 0;
$$;

comment on function filing_tax_movements(uuid) is
  'The tax accounts a declared period moved and by how much, on the same window and the same tax-point rule the return read. What settle_filing() clears, and what anybody can read before it does.';

revoke execute on function filing_tax_movements(uuid) from public, anon;
grant execute on function filing_tax_movements(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- settle_filing
--
-- One entry, at the end of the period it settles, in the miscellaneous
-- journal: every tax account the period moved goes back to zero, and the net
-- lands on the account the pack names. It runs on an accepted declaration —
-- the administration has agreed to the figures, which is the moment the debt
-- becomes certain — and it refuses everything else by naming the state it
-- found.
-- ---------------------------------------------------------------------------

create or replace function settle_filing(
  p_filing_id  uuid,
  p_credit     tax_credit_treatment default null,
  p_reference  text default null,
  p_contact_id uuid default null,
  p_date       date default null
)
returns entries
language plpgsql
volatile
security invoker
as $$
declare
  v_filing     tax_filings;
  v_country    char(2);
  v_payable    text;
  v_receivable text;
  v_account    uuid;
  v_contact_account uuid;
  v_journal    uuid;
  v_round      money_rounding;
  v_date       date;
  v_label      text;
  v_reference  text;
  v_net        numeric := 0;
  v_seq        integer := 0;
  v_entry      entries;
  r            record;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id for update;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if v_filing.state <> 'accepted' then
    raise exception 'filing_not_accepted: settling follows acceptance, and this one is %', v_filing.state;
  end if;
  if v_filing.settlement_entry_id is not null then
    raise exception 'filing_already_settled: % was settled by entry %',
      p_filing_id, v_filing.settlement_entry_id;
  end if;

  select c.fiscal_country, c.miscellaneous_journal_id
    into v_country, v_journal
    from companies c where c.id = v_filing.company_id;

  if v_journal is null then
    raise exception 'no_miscellaneous_journal: this company has no journal for an entry that belongs to no document. Set defaults.journal_roles.miscellaneous in the pack, which fills country_defaults.misc_journal_code.';
  end if;

  select d.tax_payable_code, d.tax_receivable_code
    into v_payable, v_receivable
    from country_defaults d where d.country = v_country;

  if v_payable is null then
    raise exception 'no_tax_payable_account: the pack of this company names no account for what a declaration owes. Set defaults.roles.tax_payable in the pack, which fills country_defaults.tax_payable_code.';
  end if;

  v_round := rounding_of(v_filing.company_id);
  v_date  := coalesce(p_date, v_filing.period_end);
  v_label := v_filing.report_code || ' ' || v_filing.period_start || ' — ' || v_filing.period_end;
  v_reference := coalesce(p_reference, v_filing.reference);

  if not exists (select 1 from filing_tax_movements(p_filing_id)) then
    raise exception 'nothing_to_settle: % moved no tax account between % and %',
      v_filing.report_code, v_filing.period_start, v_filing.period_end;
  end if;

  select sum(m.balance) into v_net from filing_tax_movements(p_filing_id) m;

  -- A positive net is a debit balance left on the tax accounts, which is a
  -- credit in the company's favour; a negative one is what it owes.
  if v_net > 0 then
    if p_credit is null then
      raise exception 'no_credit_treatment: % to % ends in a credit of %, and what happens to it — carried to the next declaration or claimed back — is this company''s decision',
        v_filing.period_start, v_filing.period_end, v_net;
    end if;
    v_account := account_id_by_code(v_filing.company_id, coalesce(v_receivable, v_payable));
    if v_account is null then
      raise exception 'unknown_tax_account: the pack names % for a credit and this chart has no such account',
        coalesce(v_receivable, v_payable);
    end if;
  else
    if p_credit is not null then
      raise exception 'not_a_credit: this declaration owes money, and a credit treatment does not apply to it';
    end if;
    v_account := account_id_by_code(v_filing.company_id, v_payable);
    if v_account is null then
      raise exception 'unknown_tax_account: the pack names % for what is owed and this chart has no such account',
        v_payable;
    end if;
  end if;

  -- The debt is matched against a payment, and matching reads reconcilable
  -- accounts. A pack that names an account that is not one has named the
  -- wrong account, and the settlement would be posted where no payment could
  -- ever find it.
  if not exists (select 1 from accounts a where a.id = v_account and a.reconcilable) then
    raise exception 'tax_account_not_reconcilable: % carries a debt that a payment settles, so the chart has to keep it reconcilable',
      coalesce(case when v_net > 0 then v_receivable end, v_payable);
  end if;

  -- Naming the administration is what lets the payment settle by itself, and
  -- it only works if the ledger books that payment where the debt sits. A
  -- contact whose third-party account is the default supplier one would send
  -- the payment to the payables and leave the debt open for ever — a silence,
  -- and this file's whole job is to end one. So it is checked here, where the
  -- sentence can still name what to change.
  if p_contact_id is not null then
    v_contact_account := resolve_counterpart_account(v_filing.company_id, p_contact_id, v_net > 0);
    if v_contact_account <> v_account then
      raise exception 'contact_account_mismatch: the payment of this declaration would be booked on the third-party account of that contact, and the debt sits on %. Set that contact''s account to the one the pack names, or leave the contact out.',
        coalesce(case when v_net > 0 then v_receivable end, v_payable);
    end if;
  end if;

  -- The account the net lands on is never one of the accounts being cleared:
  -- a chart that used the same one for both would net the period against
  -- itself and post an entry that says nothing.
  if exists (select 1 from filing_tax_movements(p_filing_id) m where m.account_id = v_account) then
    raise exception 'tax_account_is_a_posting_account: % is an account the taxes of this period post to, so clearing them into it would leave nothing',
      coalesce(case when v_net > 0 then v_receivable end, v_payable);
  end if;

  insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                       reference, description, state)
  values (v_filing.company_id, v_journal,
          fiscal_year_at(v_filing.company_id, v_date), v_date,
          v_reference, v_label, 'draft')
  returning * into v_entry;

  -- Each tax account, on the side that empties it.
  for r in select * from filing_tax_movements(p_filing_id) order by account_id loop
    v_seq := v_seq + 10;
    insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
    values (v_entry.id, v_filing.company_id, r.account_id, v_seq, v_label,
            case when r.balance < 0 then -r.balance else 0 end,
            case when r.balance > 0 then  r.balance else 0 end);
  end loop;

  -- And the net, on the account that carries it. A period whose tax accounts
  -- cancel each other out leaves nothing to carry, and the entry is the
  -- clearing alone: balanced, and worth having, because the accounts are back
  -- to zero either way.
  if v_net <> 0 then
    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, contact_id, date_maturity)
    values (v_entry.id, v_filing.company_id, v_account, v_seq + 10, v_label,
            case when v_net > 0 then  v_net else 0 end,
            case when v_net < 0 then -v_net else 0 end,
            p_contact_id, v_filing.due_date);
  end if;

  v_entry := post_entry(v_entry.id);

  update tax_filings
     set settlement_entry_id = v_entry.id,
         credit_treatment    = p_credit
   where id = p_filing_id;

  return v_entry;
end;
$$;

comment on function settle_filing(uuid, tax_credit_treatment, text, uuid, date) is
  'Clears the tax accounts a declared period moved and carries the net to the account the pack names for what is owed to the administration — or, where the period ends in a credit, to the one it names for a credit, once the company has said whether it is carried forward or claimed back. One entry per declaration, through post_entry(), with the reference the payment will be matched by. Naming the administration as the contact is what makes the debt settle by itself: matching books a payment, and a payment is made to somebody.';

revoke execute on function settle_filing(uuid, tax_credit_treatment, text, uuid, date) from public, anon;
grant execute on function settle_filing(uuid, tax_credit_treatment, text, uuid, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- auto_settle, which no longer dies on one line it cannot book
--
-- Found by the test below, and worth more than the feature it was found by.
-- `settle_from_statement()` refuses an open item that names nobody — a payment
-- is made to or by somebody — and the debt of a declaration names nobody
-- unless the caller passes the administration as its contact. That refusal is
-- right. What was wrong is what it did to the pass: the exception propagated
-- out of `auto_settle()` and **the whole run stopped**, with the lines it had
-- already settled rolled back and no report of anything.
--
-- A pass over a month of statements is exactly where one line must not be able
-- to silence the other forty. So the refusal is caught, reported against the
-- line it belongs to, in the words the database used, and the walk goes on:
-- the rule that a report has a row for every line of the window is the rule
-- this one serves.
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
  v_refusal   text;
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
      v_refusal := null;
      begin
        perform settle_from_statement(t.id, best.line_ids);
      exception when others then
        v_refusal := sqlerrm;
      end;
      if v_refusal is not null then
        transaction_id := t.id; action := 'refused'; method := best.method;
        line_ids := best.line_ids; because := v_refusal;
        return next; continue;
      end if;
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
  'Walks the pending statement lines of a period and settles the ones a single piece of evidence identifies — a reference, or an exact amount with one candidate. Everything else comes back with the reason it was left: a combination, a partial payment, an internal transfer, nothing open that fits, or a refusal the database made, quoted. With p_apply false it changes nothing and says what it would do.';

revoke execute on function auto_settle(uuid, date, date, boolean) from public, anon;
grant execute on function auto_settle(uuid, date, date, boolean) to authenticated, service_role;
