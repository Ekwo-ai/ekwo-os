-- ---------------------------------------------------------------------------
-- Ekwo OS — a statement is recognised in any format.
-- ---------------------------------------------------------------------------
--
-- `20260918150931` made an import idempotent line by line, and the readers of
-- CODA and CFONB 120 (`@ekwo-ai/coda`, `@ekwo-ai/cfonb120`) showed what that
-- leaves open. `tests/coda_cfonb120.test.ts` asserted each gap as it was; this
-- file closes four of them, and the test now asserts the closed form.
--
-- 1. **The same statement in two formats is imported once.** Across formats a
--    line is recognised only when the bank writes the same reference in both.
--    CODA's own standard calls its bank reference informative, and a CFONB 120
--    gives a movement none at all, so a bank that delivers a month in two
--    formats had it imported twice, silently. What is recognised now is the
--    *statement*: the same bank account, the same closing day, the same
--    opening and closing balances, read from another source format. Such a
--    file is refused by name, `statement_already_covered`, before anything is
--    written — a person decides whether it is the same month, and nothing is
--    half imported. The same format replayed is unchanged: `already_imported`,
--    nothing new. A statement entered by hand has no source format and is
--    never taken for a duplicate.
--
-- 2. **A numbering that restarts each year is not a hole.** CODA numbers the
--    statements of an account from 001 each year, so the first statement of
--    January sat 'minus two hundred' statements after the last of December and
--    raised `statement_number_gap` every year, on every account. The view
--    `bank_statement_continuity` now reads a number that does not grow, on a
--    statement of a later year than the previous one, as a new year's count:
--    the statements missing are the ones numbered before it that year. It
--    also gives the previous statement's number, `previous_sequence_number`,
--    which the warning now quotes instead of working it backwards.
--
-- 3. **A day without movement is a statement.** A CODA of a day without
--    movement has no new balance record, by its standard, and the reader
--    invents none. A statement with no booked line closes where it opens —
--    at its opening balance, on the end of its period or the day of that
--    balance — so it is imported instead of being refused
--    `statement_without_balances`. A statement *with* lines and no closing
--    balance is refused as before: nothing proves its lines are all there.
--
-- 4. **The source format has its own key.** The import read the format from
--    `namespace`, the word of camt.053's XML, which the two other readers
--    filled for that reason alone. It reads `format` and `version` first —
--    `coda` and `2` make `coda.2`, `cfonb120` alone makes `cfonb120` — and
--    `namespace` after, so every reader published so far, and every
--    statement already stored, keeps the same word.
--
-- Left as it was, and written in docs/decisions/0047: a CODA amount carries
-- three decimals whatever the currency; a third decimal that is not zero is
-- kept by the reader and refused by the import, which holds two.
--
-- `security invoker` as before; the function now carries the path of the
-- socle (`ekwo, pg_temp`), as every function since `20261028040000`.

-- ---------------------------------------------------------------------------
-- 1. The chain of statements, with a numbering that restarts each year
-- ---------------------------------------------------------------------------

create or replace view ekwo.bank_statement_continuity
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
       case when s.sequence_number is null or p.sequence_number is null then null
            -- A number that does not grow, in a later year: the bank counts
            -- from 1 again, and what is missing is what it numbered before
            -- this one since then.
            when extract(year from s.statement_date) > extract(year from p.statement_date)
                 and s.sequence_number <= p.sequence_number
              then greatest(s.sequence_number - 1, 0)
            else s.sequence_number - p.sequence_number - 1 end as missing_statements,
       (p.id is not null and s.balance_start <> p.balance_end_declared) as is_broken,
       p.sequence_number   as previous_sequence_number
  from ekwo.bank_statements s
  left join lateral (
    select q.*
      from ekwo.bank_statements q
     where q.bank_account_id = s.bank_account_id
       and q.id <> s.id
       and q.statement_date <= coalesce(s.period_start, s.statement_date)
       and coalesce(q.period_start, q.statement_date) < coalesce(s.period_start, s.statement_date)
     order by q.statement_date desc, coalesce(q.period_start, q.statement_date) desc, q.created_at desc
     limit 1
  ) p on true;

comment on view ekwo.bank_statement_continuity is
  'Each statement beside the one before it on the same account: whether its opening balance is the closing balance of the previous one (`is_broken`, `balance_gap`), and how many statements the bank numbered in between (`missing_statements`) — counted within the year when the numbering starts again from 1 in a later year, as CODA''s does. A break is shown and never refused: the statement that is there is still true, and the one that is missing can only be seen from here.';

grant select on ekwo.bank_statement_continuity to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. import_bank_statement: the statement recognised, the empty day read,
--    the format read from its key
-- ---------------------------------------------------------------------------

create or replace function ekwo.import_bank_statement(p_company_id uuid, p_file jsonb, p_source jsonb DEFAULT NULL::jsonb, p_bank_account_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(statement_index integer, statement_id uuid, bank_account_id uuid, statement_ref text, already_imported boolean, lines_read integer, lines_imported integer, lines_known integer, lines_not_booked integer, warnings jsonb)
 LANGUAGE plpgsql
 SET search_path TO 'ekwo', 'pg_temp'
AS $function$
-- The columns this function returns share their names with columns it writes;
-- inside a statement a bare name is the column.
#variable_conflict use_column
declare
  v_statements jsonb := p_file -> 'statements';
  -- What the file was read as: `format` and `version` where the reader names
  -- them (`coda` and `2` make `coda.2`, `cfonb120` alone makes `cfonb120`),
  -- else the key the first reader used, `namespace` — the XML namespace of a
  -- camt.053, which is its version. The stored word is the same either way.
  v_format     text  := coalesce(
                          case when nullif(p_file ->> 'format', '') is not null
                               then concat_ws('.', p_file ->> 'format', nullif(p_file ->> 'version', '')) end,
                          p_file ->> 'namespace', p_file ->> 'version');
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
  v_covering   bank_statements;
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
    --    A statement with no booked line closes where it opens: a CODA of a
    --    day without movement carries no new balance record, by its
    --    standard, and the reader rightly invents none. That is the import's
    --    to know, and only for a statement with nothing booked on it.
    select coalesce(sum((l.value ->> 'amount')::numeric), 0), count(*)
      into v_movement, v_read
      from jsonb_array_elements(coalesce(v_stmt -> 'lines', '[]'::jsonb)) l
     where coalesce((l.value ->> 'booked')::boolean, false);
    if v_read = 0 and v_stmt #>> '{openingBalance,amount}' is not null
       and v_stmt #>> '{closingBalance,amount}' is null then
      v_stmt := jsonb_set(v_stmt, '{closingBalance}',
                  (v_stmt -> 'openingBalance')
                  || jsonb_build_object('date', coalesce(v_stmt #>> '{period,to}', v_stmt #>> '{openingBalance,date}')));
    end if;
    if v_stmt #>> '{openingBalance,amount}' is null or v_stmt #>> '{closingBalance,amount}' is null then
      raise exception 'statement_without_balances: statement % carries no opening or no closing balance, so nothing proves its lines are all there', v_ref;
    end if;
    v_opening := (v_stmt #>> '{openingBalance,amount}')::numeric;
    v_closing := (v_stmt #>> '{closingBalance,amount}')::numeric;
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
      -- The same statement, read from another format: the same account, the
      -- same closing day, the same two balances, and another source format.
      -- Its lines cannot be recognised one by one — a CFONB 120 gives a
      -- movement no bank reference, and CODA's is informative only — so the
      -- statement is what is recognised, and the file is refused by name
      -- rather than imported a second time beside the first. A person
      -- decides. A statement entered by hand (no source format) is nobody's
      -- duplicate.
      select * into v_covering from bank_statements s
       where s.bank_account_id = v_account.id
         and s.statement_date = v_end
         and s.balance_start = v_opening
         and s.balance_end_declared = v_closing
         and s.source_format is not null
         and s.source_format is distinct from v_format
       order by s.created_at
       limit 1;
      if found then
        raise exception 'statement_already_covered: statement % of account % closing on % (% → %) was already imported from % as %; nothing was written',
          v_ref, v_account.name, v_end, v_opening, v_closing, v_covering.source_format, v_covering.statement_ref;
      end if;
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
      on conflict (bank_account_id, import_key, company_id) where import_key is not null do nothing
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
      on conflict (statement_id, transaction_id, company_id) do nothing
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
         p_source ->> 'checksum', acting_user());
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
                          v_ref, v_chain.sequence_number, v_chain.previous_sequence_number),
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
$function$;

comment on function ekwo.import_bank_statement(uuid, jsonb, jsonb, uuid) is
  'Writes what a format reader read out of a bank file into bank_statements and bank_transactions, and nothing else: no entry, no payment, no matching. Idempotent on import_key — a replayed file imports nothing, an overlapping statement imports what is new and lists the rest. Refuses, by name and before writing anything: an account the company does not have (unknown_bank_account), a statement that does not add up (unbalanced_statement) or has lines and no balances, a booked line it cannot hold as it is (unreadable_statement_line), a currency that is not the account''s, the same statement with other balances (statement_conflict), and the same statement read from another format — same account, closing day and balances (statement_already_covered). A statement with no booked line closes at its opening balance. Signals and does not refuse: an opening balance that is not the previous closing one, a hole in the bank''s numbering. One row per statement of the file; the whole file is imported or none of it.';

revoke execute on function ekwo.import_bank_statement(uuid, jsonb, jsonb, uuid) from public, anon;
grant execute on function ekwo.import_bank_statement(uuid, jsonb, jsonb, uuid) to authenticated, service_role;
