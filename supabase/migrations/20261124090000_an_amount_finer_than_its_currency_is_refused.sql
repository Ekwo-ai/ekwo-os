-- Ekwo OS — an amount finer than its currency is refused.
--
-- `20261123203000_an_amount_holds_the_decimals_of_its_currency` made every
-- money column a bare `numeric`, so that a dinar keeps the thousandth
-- `round_amount()` computed. The column no longer cuts anything, which is
-- right for what the engine writes — every document, tax, payment booking,
-- matching and exchange difference goes through `round_amount()` — and wrong
-- for what a caller writes as it is: `12.3456` keyed on a draft entry line, on
-- a statement line or on a payment would now be stored as it was sent, a
-- hundredth of a cent the euro does not have.
--
-- **The database refuses such an amount; it never rounds it.** Rounding behind
-- the writer's back was ruled out when the rounding rule was written
-- (`20260914120500`), and it would be wrong here too: two lines of a balanced
-- entry, each rounded on its own, can end a unit apart. The writer is told
-- which amount, in which currency, how many decimals it holds and how many
-- the currency has — `amount_finer_than_currency` — and decides.
--
-- **One check.** `assert_amount_of_currency(company, currency, amount, what)`
-- asks `rounding_of()` how the company writes that currency and compares the
-- amount with `round_amount()` of itself. It is not a second rounding rule:
-- an amount passes exactly when the one rule would leave it as it is. Numeric
-- equality ignores trailing zeros, so `12.30` and `12.300` are a euro amount
-- and `1200.00` is a yen amount. A whole number fits every currency and is
-- answered without a lookup.
--
-- **Where it is asked.** On the tables a caller writes amounts into directly,
-- not through a function of the engine, by an `after insert or update`
-- trigger that checks only the amounts the statement wrote:
--
--   entry_lines        debit, credit (the company's currency), amount_currency
--                      (the line's own currency) — lines keyed on a draft
--                      entry, imported books, and every engine path, which
--                      passes because it rounded
--   bank_transactions  amount (the line's currency) — import_bank_statement(),
--                      a line created by hand
--   bank_statements    balance_start, balance_end_declared (the currency of
--                      the bank account)
--   payments           amount (the payment's currency) — recorded by a client
--                      straight into the table
--   reconciliations    amount (the company's currency) — reconcile() takes
--                      the amount to match from its caller
--   document_lines     stated_tax_amount (the document's currency) — the tax
--                      a supplier's invoice states for the line
--   companies          share_capital (share_capital_currency)
--
-- Unit prices, quantities, rates and percentages are not amounts of a
-- currency, and a unit price is legitimately finer than its currency (a litre
-- at 1.8459): nothing here touches them. The amounts the engine derives —
-- document totals and line amounts, analytic shares, `box_amount`,
-- `matched_amount`, `balance_end_computed` — are written by `round_amount()`
-- or summed from amounts that were, and are not checked twice.
--
-- **Nothing written before is judged.** The triggers are created; no row is
-- read, nothing is validated, no table is rewritten. An update judges a
-- column only when it changes its value, so a row of an older release is not
-- refused for an edit that does not touch its amounts. The installer passes,
-- as it does through every guard of the socle: an archive is restored as it
-- was written.
--
-- The modules that hold raw amounts (`assets`, `budgets`, `contracts`, `crm`)
-- attach the same trigger in a migration of their own.

set search_path = ekwo, pg_temp;

-- ---------------------------------------------------------------------------
-- 1. The check
-- ---------------------------------------------------------------------------

create or replace function ekwo.assert_amount_of_currency(
  p_company_id    uuid,
  p_currency_code text,
  p_amount        numeric,
  p_what          text
)
returns void
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_round   money_rounding;
  v_rounded numeric;
begin
  -- Nothing to judge, and a whole number fits every currency: no lookup.
  if p_amount is null or p_amount = trunc(p_amount) then
    return;
  end if;

  v_round   := rounding_of(p_company_id, p_currency_code);
  v_rounded := round_amount(p_amount, v_round);
  if v_rounded = p_amount then
    return;
  end if;

  -- The amount refused is written as it was sent, since the mask of its
  -- currency would round away the very decimals that are the problem; the
  -- amount it would be at the currency's decimals is written with that mask.
  raise exception 'amount_finer_than_currency: % % holds % decimals, and % is written with %. Write it at the decimals of its currency — % — or correct the source it came from; the database does not round an amount it is given',
    p_what,
    trim_scale(p_amount)::text,
    scale(trim_scale(p_amount)),
    coalesce(p_currency_code, (select c.currency_code::text from companies c where c.id = p_company_id)),
    (v_round).decimals,
    to_char(v_rounded, amount_text_format(v_round));
end;
$$;

comment on function ekwo.assert_amount_of_currency(uuid, text, numeric, text) is
  'Refuses, amount_finer_than_currency, an amount with more decimals than its currency has for this company (rounding_of(); the company''s own currency when none is named): it passes exactly when round_amount() would leave it as it is, so 12.30 and 12.300 are euro amounts and 1200.00 a yen amount. p_what names the amount in the sentence. Never rounds. Called by amounts_of_currency_guard() and by the guards of the modules.';

-- ---------------------------------------------------------------------------
-- 2. The trigger
--
-- One function for every table whose row says its own currency. Its
-- arguments: the column holding the company, then one argument per amount,
-- `column` for an amount in the company's currency or `column:currency_column`
-- for one in the currency the row names in that column (the company's when
-- that column is empty). The row is read as JSON, which is how a trigger
-- function reads a column it is given by name.
-- ---------------------------------------------------------------------------

create or replace function ekwo.amounts_of_currency_guard()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_new      jsonb;
  v_old      jsonb;
  v_company  uuid;
  v_spec     text;
  v_column   text;
  v_currency text;
  i          integer;
begin
  if is_installer() then
    return null;
  end if;

  v_new     := to_jsonb(new);
  v_old     := case when tg_op = 'UPDATE' then to_jsonb(old) end;
  v_company := (v_new ->> tg_argv[0])::uuid;

  for i in 1 .. tg_nargs - 1 loop
    v_spec   := tg_argv[i];
    v_column := split_part(v_spec, ':', 1);
    -- An update judges the amounts it changes, never the ones it carries.
    continue when v_old is not null
              and (v_old -> v_column) is not distinct from (v_new -> v_column);
    v_currency := case when position(':' in v_spec) > 0
                       then v_new ->> split_part(v_spec, ':', 2) end;
    perform assert_amount_of_currency(
      v_company, v_currency, (v_new ->> v_column)::numeric,
      format('%s.%s', tg_table_name, v_column));
  end loop;
  return null;
end;
$$;

comment on function ekwo.amounts_of_currency_guard() is
  'After insert or update: refuses, through assert_amount_of_currency(), an amount of the row finer than its currency. Arguments: the column of the company, then each amount as column (the company''s currency) or column:currency_column. An update judges only the amounts it changes; the installer passes.';

create or replace trigger entry_lines_amounts_of_currency
  after insert or update on ekwo.entry_lines
  for each row execute function ekwo.amounts_of_currency_guard(
    'company_id', 'debit', 'credit', 'amount_currency:currency_code');

create or replace trigger bank_transactions_amounts_of_currency
  after insert or update on ekwo.bank_transactions
  for each row execute function ekwo.amounts_of_currency_guard(
    'company_id', 'amount:currency_code');

create or replace trigger payments_amounts_of_currency
  after insert or update on ekwo.payments
  for each row execute function ekwo.amounts_of_currency_guard(
    'company_id', 'amount:currency_code');

create or replace trigger reconciliations_amounts_of_currency
  after insert or update on ekwo.reconciliations
  for each row execute function ekwo.amounts_of_currency_guard(
    'company_id', 'amount');

create or replace trigger companies_amounts_of_currency
  after insert or update on ekwo.companies
  for each row execute function ekwo.amounts_of_currency_guard(
    'id', 'share_capital:share_capital_currency');

-- ---------------------------------------------------------------------------
-- 3. The two tables whose currency is their parent's
-- ---------------------------------------------------------------------------

create or replace function ekwo.bank_statements_amounts_of_currency()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_currency text;
begin
  if is_installer() then
    return null;
  end if;
  if tg_op = 'UPDATE'
     and old.balance_start is not distinct from new.balance_start
     and old.balance_end_declared is not distinct from new.balance_end_declared then
    return null;
  end if;

  select b.currency_code into v_currency from bank_accounts b where b.id = new.bank_account_id;
  if tg_op = 'INSERT' or old.balance_start is distinct from new.balance_start then
    perform assert_amount_of_currency(new.company_id, v_currency, new.balance_start,
                                      'bank_statements.balance_start');
  end if;
  if tg_op = 'INSERT' or old.balance_end_declared is distinct from new.balance_end_declared then
    perform assert_amount_of_currency(new.company_id, v_currency, new.balance_end_declared,
                                      'bank_statements.balance_end_declared');
  end if;
  return null;
end;
$$;

comment on function ekwo.bank_statements_amounts_of_currency() is
  'After insert or update: refuses, through assert_amount_of_currency(), an opening or declared closing balance finer than the currency of the statement''s bank account. The computed closing balance is a sum of lines that were checked. The installer passes.';

create or replace trigger bank_statements_amounts_of_currency
  after insert or update on ekwo.bank_statements
  for each row execute function ekwo.bank_statements_amounts_of_currency();

create or replace function ekwo.document_lines_amounts_of_currency()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_currency text;
begin
  if is_installer() or new.stated_tax_amount is null then
    return null;
  end if;
  if tg_op = 'UPDATE' and old.stated_tax_amount is not distinct from new.stated_tax_amount then
    return null;
  end if;

  select d.currency_code into v_currency from documents d where d.id = new.document_id;
  perform assert_amount_of_currency(new.company_id, v_currency, new.stated_tax_amount,
                                    'document_lines.stated_tax_amount');
  return null;
end;
$$;

comment on function ekwo.document_lines_amounts_of_currency() is
  'After insert or update: refuses, through assert_amount_of_currency(), a stated tax finer than the currency of the line''s document. The line''s other amounts are derived and rounded by the engine; its unit price may be finer than the currency and is not an amount. The installer passes.';

create or replace trigger document_lines_amounts_of_currency
  after insert or update on ekwo.document_lines
  for each row execute function ekwo.document_lines_amounts_of_currency();

-- ---------------------------------------------------------------------------
-- 4. A statement file is read at the decimals of its currency
--
-- `import_bank_statement()` refused a booked line or a balance with more than
-- two decimals, whatever the currency, because two was all
-- `bank_transactions.amount` could hold. The column now holds what the
-- currency has, so the limit is the currency's: a dinar statement imports its
-- thousandths, and a yen statement with a fraction of a yen is refused before
-- anything is written, under the name it always had
-- (`unreadable_statement_line`), the whole file with it. The sentences that
-- name a balance — `unbalanced_statement`, `statement_conflict`,
-- `statement_already_covered` — write it with `amount_text_format()`, the
-- balances judged first so that the mask hides no decimal. Rewritten from the
-- catalogue, the way `20261123203500` rewrote it, so nothing else of its
-- latest definition moves.
-- ---------------------------------------------------------------------------

do $$
declare
  v_oid oid := 'ekwo.import_bank_statement(uuid, jsonb, jsonb, uuid)'::regprocedure;
  v_def text := pg_get_functiondef(v_oid);
  v_new text;
begin
  v_new := replace(v_def,
    $old$and no finer than the column that will hold them — which is two
    --    decimals whatever the currency, a limit of `bank_transactions.amount`
    --    written in docs/international.md. Nothing is rounded here: a figure
    --    the column cannot hold is refused, not adjusted.$old$,
    $new$and no finer than their currency — round_amount() at the decimals
    --    rounding_of() gives the account's currency leaves them as they are.
    --    Nothing is rounded here: a figure finer than its currency is
    --    refused, not adjusted.$new$);
  v_new := replace(v_new,
    $old$else 'more than two decimals'$old$,
    $new$else format('more decimals than %s has', v_currency)$new$);
  v_new := replace(v_new,
    $old$or scale(trim_scale((l.value ->> 'amount')::numeric)) > 2);$old$,
    $new$or round_amount((l.value ->> 'amount')::numeric, rounding_of(p_company_id, v_currency))
               <> (l.value ->> 'amount')::numeric);$new$);
  -- The balances are judged before they are added up, so that the sentence
  -- of an unbalanced statement can write them with the mask of the currency.
  v_new := replace(v_new,
    $old$    if scale(trim_scale(v_opening)) > 2 or scale(trim_scale(v_closing)) > 2 then
      raise exception 'unreadable_statement_line: the balances of statement % carry more than two decimals', v_ref;
    end if;
$old$, '');
  v_new := replace(v_new,
    $old$    if v_opening + v_movement <> v_closing then
      raise exception 'unbalanced_statement: statement % opens at %, its booked lines add up to %, and it closes at % — a difference of %',
        v_ref, v_opening, v_movement, v_closing, v_closing - (v_opening + v_movement);
    end if;$old$,
    $new$    if round_amount(v_opening, rounding_of(p_company_id, v_currency)) <> v_opening
       or round_amount(v_closing, rounding_of(p_company_id, v_currency)) <> v_closing then
      raise exception 'unreadable_statement_line: the balances of statement % carry more decimals than % has', v_ref, v_currency;
    end if;
    if v_opening + v_movement <> v_closing then
      raise exception 'unbalanced_statement: statement % opens at %, its booked lines add up to %, and it closes at % — a difference of %',
        v_ref,
        to_char(v_opening, amount_text_format(rounding_of(p_company_id, v_currency))),
        to_char(v_movement, amount_text_format(rounding_of(p_company_id, v_currency))),
        to_char(v_closing, amount_text_format(rounding_of(p_company_id, v_currency))),
        to_char(v_closing - (v_opening + v_movement), amount_text_format(rounding_of(p_company_id, v_currency)));
    end if;$new$);
  v_new := replace(v_new,
    $old$          v_ref, v_end, v_existing.balance_start, v_existing.balance_end_declared, v_opening, v_closing;$old$,
    $new$          v_ref, v_end,
          to_char(v_existing.balance_start, amount_text_format(rounding_of(p_company_id, v_currency))),
          to_char(v_existing.balance_end_declared, amount_text_format(rounding_of(p_company_id, v_currency))),
          to_char(v_opening, amount_text_format(rounding_of(p_company_id, v_currency))),
          to_char(v_closing, amount_text_format(rounding_of(p_company_id, v_currency)));$new$);
  v_new := replace(v_new,
    $old$          v_ref, v_account.name, v_end, v_opening, v_closing, v_covering.source_format, v_covering.statement_ref;$old$,
    $new$          v_ref, v_account.name, v_end,
          to_char(v_opening, amount_text_format(rounding_of(p_company_id, v_currency))),
          to_char(v_closing, amount_text_format(rounding_of(p_company_id, v_currency))),
          v_covering.source_format, v_covering.statement_ref;$new$);
  if position('two decimals' in v_new) > 0 or position('> 2' in v_new) > 0
     or position('v_ref, v_opening, v_movement' in v_new) > 0
     or position('v_existing.balance_end_declared, v_opening' in v_new) > 0
     or position('v_end, v_opening, v_closing' in v_new) > 0 then
    raise exception 'an_amount_finer_than_its_currency_is_refused: import_bank_statement no longer reads the decimals it was written against.';
  end if;
  execute v_new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. Rights
--
-- The check is read by triggers and by the modules' guards, under the role of
-- whoever writes; a signed-in member may ask it of an amount before sending it.
-- ---------------------------------------------------------------------------

revoke execute on function ekwo.assert_amount_of_currency(uuid, text, numeric, text) from public, anon;
revoke execute on function ekwo.amounts_of_currency_guard()           from public, anon;
revoke execute on function ekwo.bank_statements_amounts_of_currency() from public, anon;
revoke execute on function ekwo.document_lines_amounts_of_currency()  from public, anon;

grant execute on function ekwo.assert_amount_of_currency(uuid, text, numeric, text) to authenticated, service_role;
