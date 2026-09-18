-- Ekwo OS — a statement is imported once.
--
-- `bank_statements` and `bank_transactions` have existed since the bank
-- migration, `suggest_matches()` and `auto_settle()` work on their lines, and
-- nothing wrote them but a test. This is the way in: `import_bank_statement()`
-- takes what a format brick read out of a file — statements and lines, as
-- jsonb — and writes the two tables.
--
-- **A statement never becomes an entry.** The function writes no ledger line,
-- no payment and no matching. A statement line becomes a payment when
-- `settle_from_statement()` says what it pays, and only then; an import that
-- booked would be a second way of booking money, with its own idea of the
-- counterpart account. It stops at `bank_transactions`, state `pending`.
--
-- **Idempotent, and the database is what refuses.** A statement is replayed
-- all the time: the same file twice, a whole month after its first fortnight,
-- two people importing the same extract. So every imported line carries an
-- `import_key`, unique per bank account, and the insert is `on conflict do
-- nothing` — it is the index that refuses the duplicate, not a lookup that
-- might race.
--
-- The key, and why it is that one:
--
--   * **When the bank gave the movement a reference** (`bankReference`, the
--     `AcctSvcrRef` of ISO 20022) the key is that reference, with the position
--     inside a split batch, the booking date and the amount. The reference is
--     the identity; date and amount are there because nothing promises a bank
--     never reuses a reference across years, and because they cost nothing: a
--     replayed movement has the same date and the same amount.
--
--   * **When it did not**, the movement has no identity of its own, and the
--     key is everything the statement says about it — dates, amount, currency,
--     counterparty, communications, end-to-end and mandate identifiers — plus
--     **which occurrence it is** among the lines of the same file that say
--     exactly the same. Two identical transfers on the same day are two lines,
--     numbered 1 and 2; they are both imported, and the same file replayed
--     numbers them 1 and 2 again and imports neither. A key without the
--     occurrence would silently drop the second rent of two tenants who pay
--     the same amount with the same words.
--
--     What this cannot tell apart: two *different* files, neither overlapping
--     the other, that each carry one line identical in every field, from a
--     bank that references nothing. The second is taken for the first. That
--     takes two statements on one day, no bank reference and no end-to-end
--     identifier at once; it is written in docs/decisions.md and not guessed
--     around here.
--
--   * The position of an entry inside its statement (`entryReference`,
--     `index`) is in neither key: a line is the sixteenth of a fortnight and
--     the sixteenth of a month only by accident.
--
-- **An overlapping statement imports what is new and lists everything.** A
-- line exists once, in `bank_transactions`; a statement *lists* lines, in
-- `bank_statement_lines`, whether it brought them or found them. So the month
-- that arrives after its first fortnight adds the second fortnight, lists
-- thirty-one days, and still proves its closing balance — which it could not
-- if a line belonged to one statement only. `balance_end_computed` reads the
-- list from now on.

-- ---------------------------------------------------------------------------
-- What an import has to remember about a statement
-- ---------------------------------------------------------------------------

alter table bank_statements
  add column if not exists statement_ref    text,
  add column if not exists sequence_number  numeric(18, 0),
  add column if not exists period_start     date,
  add column if not exists source_format    text,
  add column if not exists source_file_name text,
  add column if not exists source_checksum  text;

comment on column bank_statements.statement_ref is
  'The identifier the bank gave the statement (Stmt/Id of a camt.053). With the account and the closing date it is what makes a replayed statement the same statement. Null on a statement entered by hand.';
comment on column bank_statements.sequence_number is
  'The bank''s own numbering of the statements of this account — the legal sequence number where the format has one, else the electronic one. A hole in it is a statement nobody imported; `bank_statement_continuity` shows it.';
comment on column bank_statements.period_start is
  'The day the statement opens on: the date of its opening balance, else the start of its period, else its first line. `statement_date` is the day it closes on.';
comment on column bank_statements.source_format is
  'What the statement was read from, as the reader named it — camt.053.001.08. Null on a statement entered by hand.';
comment on column bank_statements.source_file_name is
  'The name of the file the statement was first imported from, when the caller gave one.';
comment on column bank_statements.source_checksum is
  'The checksum of the file the statement was first imported from, as the caller computed it — the core never sees the bytes. Kept so that the file can be recognised later; not what makes an import idempotent, because the same statement arrives in files that differ by a timestamp.';

create unique index if not exists bank_statements_account_ref_idx
  on bank_statements (bank_account_id, statement_ref, statement_date)
  where statement_ref is not null;

alter table bank_transactions
  add column if not exists import_key text;

comment on column bank_transactions.import_key is
  'What makes an imported line the same line when its statement is replayed or overlapped: `ref:` and a digest when the bank gave the movement a reference, `fp:` and a digest of everything the statement says about it, with its occurrence among identical lines, when it did not. Unique per bank account, and written by import_bank_statement() only. Null on a line entered by hand.';

create unique index if not exists bank_transactions_import_key_idx
  on bank_transactions (bank_account_id, import_key)
  where import_key is not null;

-- ---------------------------------------------------------------------------
-- A statement lists lines; a line exists once
-- ---------------------------------------------------------------------------

create table if not exists bank_statement_lines (
  company_id     uuid not null references companies(id) on delete cascade,
  statement_id   uuid not null,
  transaction_id uuid not null references bank_transactions(id) on delete cascade,
  position       integer not null,
  created_at     timestamptz not null default now(),
  primary key (statement_id, transaction_id),
  foreign key (statement_id, company_id)
    references bank_statements(id, company_id) on delete cascade
);

comment on table bank_statement_lines is
  'Which lines a statement lists. A line is stored once, in bank_transactions, under the first statement that brought it; a later statement that overlaps the first lists the same line here instead of duplicating it, and its closing balance is proved over the list.';
comment on column bank_statement_lines.position is
  'Where the line stands in this statement, from 1 — which is not where it stood in another.';

create index if not exists bank_statement_lines_transaction_idx
  on bank_statement_lines (transaction_id);
create index if not exists bank_statement_lines_statement_company_idx
  on bank_statement_lines (statement_id, company_id);
create index if not exists bank_statement_lines_company_idx
  on bank_statement_lines (company_id);

alter table bank_statement_lines enable row level security;

-- The form every policy has had since `a_policy_asks_once`: the set of
-- companies is worked out once per statement, not once per row.
create policy bank_statement_lines_select on bank_statement_lines
  for select using (company_id = any ((select companies_with_capability('bank.read'))::uuid[]));
create policy bank_statement_lines_write on bank_statement_lines
  for all using (company_id = any ((select companies_with_capability('bank.write'))::uuid[]))
  with check (company_id = any ((select companies_with_capability('bank.write'))::uuid[]));

grant select, insert, update, delete on table bank_statement_lines to authenticated, service_role;

-- The computed closing balance is over what the statement lists *or* holds: a
-- line entered by hand under a statement has no row in the list, and counts
-- as it always has.

create or replace function bank_statement_movement(p_statement_id uuid)
returns numeric
language sql
stable
security invoker
as $$
  select coalesce(sum(t.amount), 0)
    from bank_transactions t
   where t.statement_id = p_statement_id
      or exists (
        select 1 from bank_statement_lines l
         where l.statement_id = p_statement_id and l.transaction_id = t.id
      );
$$;

comment on function bank_statement_movement(uuid) is
  'The sum of the lines a statement lists or holds, each counted once. What balance_end_computed adds to balance_start.';

revoke execute on function bank_statement_movement(uuid) from public, anon;
grant execute on function bank_statement_movement(uuid) to authenticated, service_role;

create or replace function bank_statements_refresh_balance()
returns trigger
language plpgsql
as $$
declare
  v_transaction uuid;
  v_new         uuid;
  v_old         uuid;
begin
  if tg_op <> 'DELETE' then
    v_transaction := new.id;
    v_new := new.statement_id;
  end if;
  if tg_op <> 'INSERT' then
    v_transaction := old.id;
    v_old := old.statement_id;
  end if;
  update bank_statements s
     set balance_end_computed = s.balance_start + bank_statement_movement(s.id)
   where s.id in (v_new, v_old)
      or s.id in (select l.statement_id from bank_statement_lines l
                   where l.transaction_id = v_transaction);
  return null;
end;
$$;

create or replace function bank_statements_recompute()
returns trigger
language plpgsql
as $$
begin
  new.balance_end_computed := new.balance_start + bank_statement_movement(new.id);
  return new;
end;
$$;

create or replace function bank_statement_lines_refresh_balance()
returns trigger
language plpgsql
as $$
declare
  v_statement uuid;
begin
  if tg_op = 'DELETE' then v_statement := old.statement_id; else v_statement := new.statement_id; end if;
  update bank_statements s
     set balance_end_computed = s.balance_start + bank_statement_movement(s.id)
   where s.id = v_statement;
  return null;
end;
$$;

revoke execute on function bank_statement_lines_refresh_balance() from public, anon, authenticated, service_role;

create trigger bank_statement_lines_refresh_balance
  after insert or delete on bank_statement_lines
  for each row execute function bank_statement_lines_refresh_balance();

-- ---------------------------------------------------------------------------
-- A missing statement shows
-- ---------------------------------------------------------------------------
--
-- The closing balance of one statement is the opening balance of the next. The
-- *previous* statement of an account is the latest one that closed on or
-- before the day this one opens **and opened before it** — the second
-- condition is what keeps a fortnight from being taken for the predecessor of
-- the month that contains it. Computed at each read: importing the missing
-- month afterwards closes the gap without anybody touching a row.

create or replace view bank_statement_continuity
with (security_invoker = true) as
select s.id                as statement_id,
       s.company_id,
       s.bank_account_id,
       s.statement_ref,
       s.sequence_number,
       coalesce(s.period_start, s.statement_date) as period_start,
       s.statement_date,
       s.balance_start,
       p.id                as previous_statement_id,
       p.statement_ref     as previous_statement_ref,
       p.statement_date    as previous_statement_date,
       p.balance_end_declared as previous_balance_end,
       s.balance_start - p.balance_end_declared as balance_gap,
       case when s.sequence_number is not null and p.sequence_number is not null
            then s.sequence_number - p.sequence_number - 1 end as missing_statements,
       (p.id is not null and s.balance_start <> p.balance_end_declared) as is_broken
  from bank_statements s
  left join lateral (
    select q.*
      from bank_statements q
     where q.bank_account_id = s.bank_account_id
       and q.id <> s.id
       and q.statement_date <= coalesce(s.period_start, s.statement_date)
       and coalesce(q.period_start, q.statement_date) < coalesce(s.period_start, s.statement_date)
     order by q.statement_date desc, coalesce(q.period_start, q.statement_date) desc, q.created_at desc
     limit 1
  ) p on true;

comment on view bank_statement_continuity is
  'Each statement beside the one before it on the same account: whether its opening balance is the closing balance of the previous one (`is_broken`, `balance_gap`), and how many statements the bank numbered in between (`missing_statements`). A break is shown and never refused: the statement that is there is still true, and the one that is missing can only be seen from here.';

grant select on bank_statement_continuity to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- import_bank_statement
-- ---------------------------------------------------------------------------
--
-- What it reads, which is what `@ekwo-ai/camt053` returns and what any other
-- reader can return — the contract is this list, not that package:
--
--   p_file.version | .namespace          what was read, kept in source_format
--   p_file.statements[]                  one or more
--     .id                                the bank's identifier of the statement
--     .legalSequenceNumber | .electronicSequenceNumber
--     .account.identifier { kind, value } `iban`, or anything else
--     .account.currency
--     .period { from, to }
--     .openingBalance | .closingBalance { amount, currency, date }
--     .lines[]
--        .index .detail .booked .bookingDate .valueDate .amount .currency
--        .bankReference .endToEndId .transactionId .mandateId
--        .counterparty { name, account { kind, value } }
--        .remittance { unstructured[], structured[] { reference } }
--        .additionalInformation
--
-- Amounts are decimal strings, signed from the account holder's side, and are
-- cast here and nowhere before: no figure of a statement is ever a float.
--
-- p_source is what the caller knows about the file and the core cannot:
-- { file_name, checksum, byte_size, mime_type, storage_path }. With a
-- `storage_path` the file is recorded in `attachments`, on the statement; the
-- bytes themselves are the caller's to store.

create or replace function import_bank_statement(
  p_company_id      uuid,
  p_file            jsonb,
  p_source          jsonb default null,
  p_bank_account_id uuid default null
)
returns table (
  statement_index   integer,
  statement_id      uuid,
  bank_account_id   uuid,
  statement_ref     text,
  already_imported  boolean,
  lines_read        integer,
  lines_imported    integer,
  lines_known       integer,
  lines_not_booked  integer,
  warnings          jsonb
)
language plpgsql
security invoker
as $$
-- The columns this function returns share their names with columns it writes;
-- inside a statement a bare name is the column.
#variable_conflict use_column
declare
  v_statements jsonb := p_file -> 'statements';
  v_format     text  := coalesce(p_file ->> 'namespace', p_file ->> 'version');
  v_stmt       jsonb;
  v_index      integer := 0;
  v_identifier jsonb;
  v_value      text;
  v_account    bank_accounts;
  v_currency   text;
  v_opening    numeric;
  v_closing    numeric;
  v_movement   numeric;
  v_bad        jsonb;
  v_ref        text;
  v_start      date;
  v_end        date;
  v_existing   bank_statements;
  v_id         uuid;
  v_already    boolean;
  v_read       integer;
  v_imported   integer;
  v_listed     integer;
  v_skipped    integer;
  v_warnings   jsonb;
  v_chain      record;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id using errcode = 'no_data_found';
  end if;
  -- Row level security is what refuses; this is what says why. Without it a
  -- viewer reads "new row violates row-level security policy", which names a
  -- mechanism and not a reason.
  -- Null-safe on purpose: `not NULL` is NULL and `if NULL` does not raise, which
  -- is how a guard of this shape was once skipped for a caller with no session.
  if not coalesce(is_installer(), false)
     and not coalesce(has_capability(p_company_id, 'bank.write'), false) then
    raise exception 'not_allowed: importing a statement into this company needs bank.write'
      using errcode = '42501';
  end if;
  if v_statements is null or jsonb_typeof(v_statements) <> 'array'
     or jsonb_array_length(v_statements) = 0 then
    raise exception 'invalid_statement_file: no statement in what was given — expected { statements: [ … ] } as a format reader returns it';
  end if;
  if p_bank_account_id is not null and jsonb_array_length(v_statements) <> 1 then
    raise exception 'invalid_statement_file: a bank account can be named for a file of one statement, and this one holds %',
      jsonb_array_length(v_statements);
  end if;

  for v_stmt in select value from jsonb_array_elements(v_statements) loop
    v_index      := v_index + 1;
    v_identifier := v_stmt #> '{account,identifier}';
    v_value      := upper(regexp_replace(coalesce(v_identifier ->> 'value', ''), '\s', '', 'g'));
    v_ref        := nullif(v_stmt ->> 'id', '');

    if v_value = '' or v_ref is null then
      raise exception 'invalid_statement_file: statement % has no identifier or names no account', v_index;
    end if;

    -- 1. The account. Known, or refused by name: an account created by an
    --    import is an account nobody decided, mapped to no journal and no
    --    ledger account.
    if p_bank_account_id is not null then
      select * into v_account from bank_accounts b
       where b.id = p_bank_account_id and b.company_id = p_company_id;
      if not found then
        raise exception 'unknown_bank_account: % is not a bank account of this company', p_bank_account_id
          using errcode = 'no_data_found';
      end if;
      if v_account.iban is not null and v_identifier ->> 'kind' = 'iban'
         and upper(regexp_replace(v_account.iban, '\s', '', 'g')) <> v_value then
        raise exception 'bank_account_mismatch: the statement is of account % and the bank account named holds %',
          v_value, v_account.iban;
      end if;
    else
      -- `bank_accounts.iban` is the only column the core has for what
      -- identifies an account, and it is compared with whatever the statement
      -- wrote — IBAN or not. The column is misnamed, which is a known gap with
      -- a change of its own; a second, stricter lookup here would not fix it.
      select * into v_account from bank_accounts b
       where b.company_id = p_company_id
         and b.iban is not null
         and upper(regexp_replace(b.iban, '\s', '', 'g')) = v_value;
      if not found then
        raise exception 'unknown_bank_account: no bank account of this company is identified by % (%) — create it, or name the one this statement belongs to',
          v_value, coalesce(v_identifier ->> 'kind', 'unknown kind')
          using errcode = 'no_data_found';
      end if;
    end if;

    -- 2. The currency. A statement in another currency than its account is
    --    not converted; it is a statement of another account.
    v_currency := coalesce(v_stmt #>> '{account,currency}', v_stmt #>> '{openingBalance,currency}',
                           v_stmt #>> '{closingBalance,currency}');
    if v_currency is distinct from v_account.currency_code::text then
      raise exception 'statement_currency_mismatch: statement % is in % and the bank account % in %',
        v_ref, coalesce(v_currency, 'no currency'), v_account.name, v_account.currency_code;
    end if;

    -- 3. The lines that count: booked, readable, in the account's currency
    --    and no finer than the column that will hold them — which is two
    --    decimals whatever the currency, a limit of `bank_transactions.amount`
    --    written in docs/international.md. Nothing is rounded here: a figure
    --    the column cannot hold is refused, not adjusted.
    select jsonb_agg(jsonb_build_object('line', l.value -> 'index', 'why',
             case
               when l.value ->> 'amount' is null then 'no readable amount'
               when coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate') is null then 'no date'
               when l.value ->> 'currency' is distinct from v_currency then
                 format('in %s, not converted', coalesce(l.value ->> 'currency', 'no currency'))
               else 'more than two decimals'
             end))
      into v_bad
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false)
       and (l.value ->> 'amount' is null
            or coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate') is null
            or l.value ->> 'currency' is distinct from v_currency
            or scale(trim_scale((l.value ->> 'amount')::numeric)) > 2);
    if v_bad is not null then
      raise exception 'unreadable_statement_line: statement % holds booked lines that cannot be imported as they are: %',
        v_ref, v_bad;
    end if;

    -- 4. The balance, recomputed here: what a client says it checked is not a
    --    check. Opening plus what is booked is the closing, or nothing is
    --    written — a statement that does not add up is a file that lost a
    --    line on the way, and importing it would hide which.
    if v_stmt #>> '{openingBalance,amount}' is null or v_stmt #>> '{closingBalance,amount}' is null then
      raise exception 'statement_without_balances: statement % carries no opening or no closing balance, so nothing proves its lines are all there', v_ref;
    end if;
    v_opening := (v_stmt #>> '{openingBalance,amount}')::numeric;
    v_closing := (v_stmt #>> '{closingBalance,amount}')::numeric;
    select coalesce(sum((l.value ->> 'amount')::numeric), 0), count(*)
      into v_movement, v_read
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false);
    select count(*) into v_skipped
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where not coalesce((l.value ->> 'booked')::boolean, false);
    if v_opening + v_movement <> v_closing then
      raise exception 'unbalanced_statement: statement % opens at %, its booked lines add up to %, and it closes at % — a difference of %',
        v_ref, v_opening, v_movement, v_closing, v_closing - (v_opening + v_movement);
    end if;
    if scale(trim_scale(v_opening)) > 2 or scale(trim_scale(v_closing)) > 2 then
      raise exception 'unreadable_statement_line: the balances of statement % carry more than two decimals', v_ref;
    end if;

    -- 5. The statement: the same one, or a new one.
    select min(coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate')::date),
           max(coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate')::date)
      into v_start, v_end
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false);
    v_start := coalesce((v_stmt #>> '{openingBalance,date}')::date, (v_stmt #>> '{period,from}')::date, v_start);
    v_end   := coalesce((v_stmt #>> '{closingBalance,date}')::date, (v_stmt #>> '{period,to}')::date, v_end);
    if v_end is null then
      raise exception 'invalid_statement_file: statement % has no closing date, no period and no line to take one from', v_ref;
    end if;

    select * into v_existing from bank_statements s
     where s.bank_account_id = v_account.id and s.statement_ref = v_ref and s.statement_date = v_end;
    v_already := found;
    if v_already then
      if v_existing.balance_start <> v_opening or v_existing.balance_end_declared <> v_closing then
        raise exception 'statement_conflict: statement % of % was imported with balances % → %, and this file says % → %',
          v_ref, v_end, v_existing.balance_start, v_existing.balance_end_declared, v_opening, v_closing;
      end if;
      v_id := v_existing.id;
    else
      insert into bank_statements
        (company_id, bank_account_id, name, statement_date, period_start, balance_start,
         balance_end_declared, source, statement_ref, sequence_number, source_format,
         source_file_name, source_checksum)
      values
        (p_company_id, v_account.id, v_ref, v_end, coalesce(v_start, v_end), v_opening,
         v_closing, 'import', v_ref,
         coalesce(v_stmt ->> 'legalSequenceNumber', v_stmt ->> 'electronicSequenceNumber')::numeric,
         v_format, p_source ->> 'file_name', p_source ->> 'checksum')
      returning id into v_id;
    end if;

    -- 6. The lines. Keyed, inserted where the key is new, listed either way.
    with read as (
      select l.value as line,
             (l.value ->> 'index')::integer as position,
             coalesce(l.value ->> 'bookingDate', l.value ->> 'valueDate')::date as booked_on,
             (l.value ->> 'amount')::numeric as amount,
             nullif(l.value ->> 'bankReference', '') as bank_reference,
             (select string_agg(u.value, ' ' order by u.ordinality)
                from jsonb_array_elements_text(coalesce(l.value #> '{remittance,unstructured}', '[]'::jsonb))
                     with ordinality u) as free_text,
             (select string_agg(s.value ->> 'reference', ' ' order by s.ordinality)
                from jsonb_array_elements(coalesce(l.value #> '{remittance,structured}', '[]'::jsonb))
                     with ordinality s) as structured
        from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
       where coalesce((l.value ->> 'booked')::boolean, false)
    ),
    described as (
      select r.*,
             case when r.bank_reference is not null
               then concat_ws(chr(31), 'ref', r.bank_reference, coalesce(r.line ->> 'detail', '0'),
                              r.booked_on::text, trim_scale(r.amount)::text)
               else concat_ws(chr(31), 'fp', r.booked_on::text, coalesce(r.line ->> 'valueDate', ''),
                              trim_scale(r.amount)::text, r.line ->> 'currency',
                              coalesce(upper(regexp_replace(r.line #>> '{counterparty,account,value}', '\s', '', 'g')), ''),
                              coalesce(r.line #>> '{counterparty,name}', ''),
                              coalesce(r.structured, ''), coalesce(r.free_text, ''),
                              coalesce(r.line ->> 'endToEndId', ''), coalesce(r.line ->> 'transactionId', ''),
                              coalesce(r.line ->> 'mandateId', ''),
                              coalesce(r.line ->> 'additionalInformation', ''))
             end as said
        from read r
    ),
    keyed as (
      select d.*,
             (case when d.bank_reference is not null then 'ref:' else 'fp:' end)
             || encode(sha256(convert_to(
                  d.said || chr(31)
                  || (row_number() over (partition by d.said order by d.position))::text, 'UTF8')), 'hex')
               as import_key
        from described d
    ),
    inserted as (
      insert into bank_transactions
        (company_id, statement_id, bank_account_id, sequence, transaction_date, value_date,
         amount, currency_code, description, counterpart_name, counterpart_iban, reference,
         structured_reference, state, raw, import_key)
      select p_company_id, v_id, v_account.id, k.position, k.booked_on,
             (k.line ->> 'valueDate')::date, k.amount, v_account.currency_code,
             coalesce(k.free_text, k.line ->> 'additionalInformation'),
             k.line #>> '{counterparty,name}',
             -- What the statement wrote, IBAN or not: it is what recognising a
             -- counterparty compares, and `contact_patterns` already calls it
             -- an account and not an IBAN.
             upper(regexp_replace(k.line #>> '{counterparty,account,value}', '\s', '', 'g')),
             k.bank_reference,
             k.line #>> '{remittance,structured,0,reference}',
             'pending', k.line, k.import_key
        from keyed k
      on conflict (bank_account_id, import_key) where import_key is not null do nothing
      returning id, import_key
    ),
    -- Listed either way: the lines this statement just brought, which the
    -- table as this statement sees it does not hold yet, and the ones it found.
    listed as (
      insert into bank_statement_lines (company_id, statement_id, transaction_id, position)
      select p_company_id, v_id, t.id, k.position
        from keyed k
        join (select i.id, i.import_key from inserted i
              union all
              select b.id, b.import_key from bank_transactions b
               where b.bank_account_id = v_account.id and b.import_key is not null) t
          on t.import_key = k.import_key
      on conflict (statement_id, transaction_id) do nothing
      returning 1
    )
    select (select count(*) from inserted), (select count(*) from listed) into v_imported, v_listed;

    -- 7. The file, when the caller stored it somewhere.
    if p_source ->> 'storage_path' is not null and not exists (
      select 1 from attachments a
       where a.entity_type = 'bank_statement' and a.entity_id = v_id
         and a.checksum is not distinct from p_source ->> 'checksum'
         and a.storage_path = p_source ->> 'storage_path'
    ) then
      insert into attachments
        (company_id, entity_type, entity_id, file_name, mime_type, byte_size, storage_path,
         checksum, uploaded_by)
      values
        (p_company_id, 'bank_statement', v_id,
         coalesce(p_source ->> 'file_name', v_ref), p_source ->> 'mime_type',
         (p_source ->> 'byte_size')::bigint, p_source ->> 'storage_path',
         p_source ->> 'checksum', auth.uid());
    end if;

    -- 8. What is signalled and never refused: a missing statement.
    v_warnings := '[]'::jsonb;
    select * into v_chain from bank_statement_continuity c where c.statement_id = v_id;
    if v_chain.is_broken then
      v_warnings := v_warnings || jsonb_build_object(
        'code', 'balance_chain_broken',
        'message', format('statement %s opens at %s and the previous one, %s of %s, closed at %s: %s is unaccounted for between them',
                          v_ref, v_opening, coalesce(v_chain.previous_statement_ref, 'unnamed'),
                          v_chain.previous_statement_date, v_chain.previous_balance_end, v_chain.balance_gap),
        'previous_statement_id', v_chain.previous_statement_id,
        'balance_gap', v_chain.balance_gap);
    end if;
    if v_chain.missing_statements is distinct from 0 and v_chain.missing_statements is not null then
      v_warnings := v_warnings || jsonb_build_object(
        'code', 'statement_number_gap',
        'message', format('statement %s is numbered %s and the previous one %s',
                          v_ref, v_chain.sequence_number, v_chain.sequence_number - v_chain.missing_statements - 1),
        'missing_statements', v_chain.missing_statements);
    end if;

    statement_index  := v_index;
    statement_id     := v_id;
    bank_account_id  := v_account.id;
    statement_ref    := v_ref;
    already_imported := v_already;
    lines_read       := v_read;
    lines_imported   := v_imported;
    lines_known      := v_read - v_imported;
    lines_not_booked := v_skipped;
    warnings         := v_warnings;
    return next;
  end loop;
end;
$$;

comment on function import_bank_statement(uuid, jsonb, jsonb, uuid) is
  'Writes what a format reader read out of a bank file into bank_statements and bank_transactions, and nothing else: no entry, no payment, no matching. Idempotent on import_key — a replayed file imports nothing, an overlapping statement imports what is new and lists the rest. Refuses, by name and before writing anything: an account the company does not have (unknown_bank_account), a statement that does not add up (unbalanced_statement) or has no balances, a booked line it cannot hold as it is (unreadable_statement_line), a currency that is not the account''s, and the same statement with other balances (statement_conflict). Signals and does not refuse: an opening balance that is not the previous closing one, a hole in the bank''s numbering. One row per statement of the file; the whole file is imported or none of it.';

revoke execute on function import_bank_statement(uuid, jsonb, jsonb, uuid) from public, anon;
grant execute on function import_bank_statement(uuid, jsonb, jsonb, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The column that said "no reader yet"
-- ---------------------------------------------------------------------------

comment on column country_defaults.bank_statement_formats is
  'Statement formats a bank of this country sends — coda, camt.053, cfonb120 — from the pack. **Read by clients, not by the socle**: import_bank_statement() takes what a format reader returned and does not ask which format it came from, so this list is what a client offers, and a name in it is a promise only where a reader exists. camt.053 has one; the others are owed, by name, in tests/bank_statement_formats.test.ts.';

-- ---------------------------------------------------------------------------
-- The list leaves with the company
-- ---------------------------------------------------------------------------
--
-- A company that leaves an installation takes its statements and their lines
-- with it. Which lines a statement lists is part of the statement: without it
-- an overlapping statement would arrive with a closing balance nothing proves.
-- Loaded after both of the tables it points at.

insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('bank_statement_lines', 'exported', 59, null, null, 'Which lines a statement lists, so a statement that overlaps another still proves its closing balance where it arrives.')
on conflict (table_schema, table_name) do nothing;
