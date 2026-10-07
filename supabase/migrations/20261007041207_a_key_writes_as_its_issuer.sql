-- Ekwo OS — a key writes as the person who issued it.
--
-- Decision 0053 says the MCP server acts as the user. Since decision 0062 a
-- machine key reaches the API, and an assistant connected through a key is
-- the ordinary shape of that server operated for somebody: the key is what it
-- presents. A key is not a session, so `auth.uid()` is null for it, and every
-- write that took its author from `auth.uid()` recorded nobody — `audit_log`
-- wrote `api_key_id` beside a null `actor_id`, and `enabled_by`,
-- `invited_by`, `filed_by`, `uploaded_by` and the rest stayed empty. The
-- trail said a machine acted, and never for whom.
--
-- A key is a delegation from a person (`20260930103815`): it holds what the
-- person who issued it still holds, and nothing more. That person is who the
-- write is for, so that person is who it is recorded against. Decision 0064
-- writes this down beside 0053.
--
-- ---------------------------------------------------------------------------
-- The rule, in one function
-- ---------------------------------------------------------------------------
--
-- `acting_user()` — the person a write is recorded against: the signed-in
-- user, or else the person who issued the machine key presented in this
-- transaction (`api_keys.created_by`). Null on a direct connection of the
-- installer, and for a key the installation issued itself, as before.
--
-- Every place that recorded `auth.uid()` as the author of a write now calls
-- it, and `create_api_key()` drops its own copy of the same expression, so the
-- rule is written once.
--
-- **It attributes; it never authorises.** `auth.uid()` is unchanged, and so
-- is every policy and every guard: `has_capability()` still answers for a key
-- through `key_holds()` — its own list, and what its issuer holds today — and
-- a policy that asks for a signed-in user still answers no to a key. Nothing
-- in this file reads `acting_user()` to decide whether something may be done.
-- A key without `documents.write` still cannot create a document, whatever
-- its issuer holds; a key withdrawn or expired is refused by
-- `use_api_key()` before it writes anything, and `current_api_key()`, which
-- this reads, ignores such a key as well.
--
-- `audit_log.api_key_id` keeps saying which key it was, so the trail now says
-- both: for whom, and through what.
--
-- What is not moved: the owner of a company created or imported
-- (`create_company()`, `import_company()`) is a membership, not an
-- attribution, and a key does not choose who owns a company. The functions
-- that demand a session (`accept_invitation()`, `set_preferences()`) go on
-- demanding one.
--
-- The bodies below are the ones the database held before this file, as
-- `pg_get_functiondef()` gives them, with `auth.uid()` replaced by
-- `acting_user()` where it named the author of the write and nowhere else.
-- The functions of the `tax` module follow in its own folder.

-- ---------------------------------------------------------------------------
-- acting_user
--
-- Definer, because the invoker functions and column defaults that call it run
-- as `authenticated`, which cannot read `api_keys`. It returns one uuid and
-- never the row.
-- ---------------------------------------------------------------------------

create or replace function acting_user()
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(auth.uid(), (select k.created_by from current_api_key() k));
$$;

comment on function acting_user() is
  'The person a write is recorded against: the signed-in user, or the person who issued the machine key presented in this transaction (api_keys.created_by). Null on a direct connection and for a key the installation issued itself. It attributes and never authorises: what a key may do is still has_capability(), and auth.uid() stays null for a key.';

-- ---------------------------------------------------------------------------
-- The audit trail
-- ---------------------------------------------------------------------------

create or replace function audit_record(p_company_id uuid, p_table text, p_record_id uuid, p_record_key text, p_operation audit_operation, p_action text default NULL::text, p_old jsonb default NULL::jsonb, p_new jsonb default NULL::jsonb)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_id bigint;
begin
  insert into audit_log (actor_id, api_key_id, company_id, table_name, record_id,
                         record_key, operation, action, old_values, new_values)
  values (acting_user(), (select id from current_api_key()), p_company_id, p_table,
          p_record_id, p_record_key, p_operation, p_action, p_old, p_new)
  returning id into v_id;
  return v_id;
end;
$function$;

comment on column audit_log.actor_id is
  'The person the change was made for: the signed-in user, or the person who issued the machine key presented (acting_user()). Null on a direct connection, and for a key the installation issued itself.';

comment on column audit_log.api_key_id is
  'The machine key presented in the transaction, when one was. Beside actor_id, the trail says for whom and through what.';

-- ---------------------------------------------------------------------------
-- The key that issues a key: the same rule, now the one function
-- ---------------------------------------------------------------------------

create or replace function create_api_key(p_company_id uuid, p_name text, p_capabilities jsonb, p_expires_at timestamp with time zone default NULL::timestamp with time zone)
returns table (api_key_id uuid, secret text, prefix text, expires_at timestamp with time zone)
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_caps   text[] := coalesce(
    (select array_agg(value) from jsonb_array_elements_text(coalesce(p_capabilities, '[]'::jsonb)) as value),
    '{}');
  v_prefix text := left(replace(gen_random_uuid()::text, '-', ''), 12);
  v_secret text;
  v_cap    text;
  v_row    api_keys%rowtype;
  v_issuer uuid := acting_user();
begin
  if not is_installer() and not has_capability(p_company_id, 'members.manage') then
    raise exception 'not_allowed: issuing a key for this company needs members.manage'
      using errcode = '42501';
  end if;

  if cardinality(v_caps) = 0 then
    raise exception 'api_key_without_capability: name what this key may do; a key that may do nothing is a secret to look after for no reason';
  end if;

  foreach v_cap in array v_caps loop
    if v_cap not in (select code from capabilities) then
      raise exception 'unknown_capability: % is not a capability of this installation', v_cap;
    end if;
    -- Nobody mints a key stronger than they are, and this is only the first
    -- time it is checked. At every use `key_holds()` asks again whether the
    -- issuer still holds the capability, so a capability withdrawn from a
    -- person is withdrawn from the keys they issued.
    if not is_installer() and not has_capability(p_company_id, v_cap) then
      raise exception 'not_allowed: you do not hold % yourself, so you cannot put it on a key', v_cap
        using errcode = '42501';
    end if;
  end loop;

  v_secret := 'ekwo_' || v_prefix || '_' ||
              replace(gen_random_uuid()::text, '-', '') ||
              replace(gen_random_uuid()::text, '-', '');

  insert into api_keys (company_id, name, prefix, key_hash, capabilities, created_by, expires_at)
  values (p_company_id, p_name, v_prefix,
          encode(sha256(convert_to(v_secret, 'UTF8')), 'hex'),
          v_caps, v_issuer, p_expires_at)
  returning * into v_row;

  return query select v_row.id, v_secret, v_row.prefix, v_row.expires_at;
end;
$function$;

comment on column api_keys.created_by is
  'auth.users.id of the person the key is a delegation from: whoever issued it, or the person behind the key that issued it. Null for a key the installation issued itself. The key never holds more than this person holds today, and what it writes is recorded against this person (acting_user()). No foreign key, for the same reason company_members has none.';

-- ---------------------------------------------------------------------------
-- The other writes that name their author
-- ---------------------------------------------------------------------------

create or replace function enable_module(p_company_id uuid, p_code text, p_settings jsonb default NULL::jsonb)
returns company_modules
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_module modules%rowtype;
  v_row    company_modules%rowtype;
begin
  if not is_installer() and not has_capability(p_company_id, 'company.write') then
    raise exception 'not_allowed: enabling a module on this company needs company.write'
      using errcode = '42501';
  end if;

  select * into v_module from modules where code = p_code;
  if not found then
    raise exception 'unknown_module: % is not installed on this instance; apply its migrations first', p_code;
  end if;

  if v_module.status = 'draft' and not module_is_enabled(p_company_id, p_code) then
    raise exception 'module_not_available: % is still a draft on this installation', p_code;
  end if;
  if v_module.status = 'deprecated' and not module_is_enabled(p_company_id, p_code) then
    raise exception 'module_deprecated: % is deprecated and takes no new company', p_code;
  end if;

  insert into company_modules (company_id, module_code, enabled_by, settings)
  values (p_company_id, p_code, acting_user(), coalesce(p_settings, '{}'::jsonb))
  on conflict (company_id, module_code) do update
    set settings = coalesce(p_settings, company_modules.settings)
  returning * into v_row;

  return v_row;
end;
$function$;

create or replace function export_company_manifest(p_company_id uuid)
returns jsonb
language plpgsql
stable
set search_path = public, pg_temp
set "TimeZone" = 'UTC'
as $function$
declare
  v_company  companies%rowtype;
  v_table    record;
  v_tables   jsonb := '[]'::jsonb;
  v_rows     bigint;
  v_checksum text;
  v_values   text;
begin
  perform assert_may_export_company(p_company_id);

  select * into v_company from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: % is not a company you may read', p_company_id
      using errcode = 'P0002';
  end if;

  for v_table in
    select t.table_schema || '.' || t.table_name as name
      from company_archive_tables() t
     where t.disposition = 'exported'
     order by t.load_order, t.table_schema, t.table_name
  loop
    select count(*),
           encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex'),
           encode(sha256(convert_to(coalesce(string_agg(canonical_json(x.r)::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex')
      into v_rows, v_checksum, v_values
      from export_company_table(p_company_id, v_table.name) with ordinality as x(r, n);

    v_tables := v_tables || jsonb_build_object(
      'name', v_table.name,
      'file', 'data/' || v_table.name || '.jsonl',
      'rows', v_rows,
      'sha256', v_checksum,
      'values_sha256', v_values);
  end loop;

  return jsonb_build_object(
    'format', 'ekwo.company-archive',
    'format_version', 1,
    'exported_at', to_jsonb(now()),
    'exported_by', acting_user(),
    'socle_version', ekwo_schema_version(),
    'origin_instance', (select i.instance_id from instance i),
    'company', jsonb_build_object(
      'id', v_company.id,
      'name', v_company.name,
      'country', v_company.country,
      'fiscal_country', v_company.fiscal_country,
      'currency_code', v_company.currency_code),
    'packs', coalesce((
      select jsonb_agg(jsonb_build_object('country', p.country, 'version', p.version, 'chart_code', p.chart_code)
                       order by p.country)
        from company_packs p where p.company_id = p_company_id), '[]'::jsonb),
    'modules', coalesce((
      select jsonb_agg(jsonb_build_object('code', m.code, 'version', m.version) order by m.code)
        from company_modules cm join modules m on m.code = cm.module_code
       where cm.company_id = p_company_id), '[]'::jsonb),
    'tables', v_tables,
    'excluded', coalesce((
      select jsonb_agg(jsonb_build_object('name', t.table_schema || '.' || t.table_name, 'reason', t.reason)
                       order by t.table_schema, t.table_name)
        from company_archive_tables() t where t.disposition = 'excluded'), '[]'::jsonb),
    'files', jsonb_build_object(
      'transported', false,
      'list', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'attachment_id', a.id,
                 'storage_path', a.storage_path,
                 'file_name', a.file_name,
                 'mime_type', a.mime_type,
                 'byte_size', a.byte_size,
                 'checksum', a.checksum) order by a.id)
          from attachments a where a.company_id = p_company_id), '[]'::jsonb)));
end;
$function$;

create or replace function file_filing(p_filing_id uuid, p_reference text default NULL::text, p_filed_at timestamp with time zone default NULL::timestamp with time zone, p_channel filing_channel default 'portal'::filing_channel, p_service text default NULL::text)
returns tax_filings
language plpgsql
as $function$
declare
  v_filing tax_filings;
  v_at     timestamptz;
  v_next   integer;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;

  -- Rejected is a state a declaration is sent again from. It was never
  -- received, so there is nothing to correct and no corrective to open.
  if v_filing.state not in ('draft', 'ready', 'rejected') then
    raise exception 'filing_already_%: this declaration has already gone', v_filing.state;
  end if;

  if v_filing.prepared_at is null then
    raise exception 'filing_not_prepared: compute the figures before filing them';
  end if;

  v_at := coalesce(p_filed_at, now());

  select coalesce(max(d.sequence), 0) + 1 into v_next
    from tax_filing_deposits d where d.filing_id = p_filing_id;

  insert into tax_filing_deposits (filing_id, sequence, channel, service, sent_at, sent_by, reference)
  values (p_filing_id, v_next, p_channel, p_service, v_at, acting_user(), p_reference);

  update tax_filings
     set state     = 'filed',
         reference = coalesce(p_reference, reference),
         filed_at  = v_at,
         filed_by  = acting_user()
   where id = p_filing_id
  returning * into v_filing;

  return v_filing;
end;
$function$;

create or replace function import_bank_statement(p_company_id uuid, p_file jsonb, p_source jsonb default NULL::jsonb, p_bank_account_id uuid default NULL::uuid)
returns table (statement_index integer, statement_id uuid, bank_account_id uuid, statement_ref text, already_imported boolean, lines_read integer, lines_imported integer, lines_known integer, lines_not_booked integer, warnings jsonb)
language plpgsql
as $function$
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
$function$;

create or replace function invite_member(p_company_id uuid, p_email text, p_role member_role default 'viewer'::member_role, p_capabilities jsonb default '[]'::jsonb, p_valid_for interval default '14 days'::interval)
returns table (invitation_id uuid, token text, expires_at timestamp with time zone)
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_email   text := lower(trim(p_email));
  v_token   text;
  v_unknown text;
  v_caps    text[] := coalesce(
    (select array_agg(value) from jsonb_array_elements_text(coalesce(p_capabilities, '[]'::jsonb)) as value),
    '{}');
  v_row     company_invitations%rowtype;
begin
  if not is_installer() and not has_capability(p_company_id, 'members.manage')
     and not is_instance_admin() then
    raise exception 'not_allowed: inviting somebody into this company needs members.manage'
      using errcode = '42501';
  end if;

  if v_email is null or v_email not like '%_@_%' then
    raise exception 'bad_email: % is not an address an invitation can be sent to', p_email;
  end if;

  select c into v_unknown
    from unnest(v_caps) as c
   where c not in (select code from capabilities)
   limit 1;
  if v_unknown is not null then
    raise exception 'unknown_capability: % is not a capability of this installation', v_unknown;
  end if;

  -- Re-inviting the same address replaces the pending invitation rather than
  -- leaving two tokens alive for one seat.
  update company_invitations
     set revoked_at = now()
   where company_id = p_company_id
     and email = v_email
     and accepted_at is null
     and revoked_at is null;

  v_token := replace(gen_random_uuid()::text, '-', '') ||
             replace(gen_random_uuid()::text, '-', '');

  insert into company_invitations (company_id, email, role, capabilities_granted,
                                   token_hash, invited_by, expires_at)
  values (p_company_id, v_email, p_role, v_caps,
          encode(sha256(convert_to(v_token, 'UTF8')), 'hex'), acting_user(), now() + p_valid_for)
  returning * into v_row;

  return query select v_row.id, v_token, v_row.expires_at;
end;
$function$;

create or replace function share_document(p_document_id uuid, p_expires_at timestamp with time zone default NULL::timestamp with time zone)
returns table (share_id uuid, token text, url text)
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_doc     documents%rowtype;
  v_refusal text;
  v_token   text;
  v_base    text;
  v_row     document_shares%rowtype;
begin
  select * into v_doc from documents where id = p_document_id;
  if v_doc.id is null then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  if not is_installer() and not has_capability(v_doc.company_id, 'documents.share') then
    raise exception 'not_allowed: publishing a document of this company needs documents.share'
      using errcode = '42501';
  end if;

  v_refusal := document_share_refusal(v_doc);
  if v_refusal is not null then
    raise exception '%', v_refusal;
  end if;

  if p_expires_at is not null and p_expires_at <= now() then
    raise exception 'share_expires_in_the_past: % is not in the future, so this link would be born dead',
      p_expires_at;
  end if;

  -- 32 bytes as base64url, 43 characters, no padding. `translate` maps the two
  -- characters base64 and base64url disagree on and drops the `=`, whose
  -- position is implied by the length.
  v_token := translate(
    encode(
      decode(replace(gen_random_uuid()::text, '-', '') ||
             replace(gen_random_uuid()::text, '-', ''), 'hex'),
      'base64'),
    '+/=', '-_');

  insert into document_shares (company_id, subject_kind, document_id, token_hash,
                               expires_at, created_by)
  values (v_doc.company_id, 'document', v_doc.id,
          encode(sha256(convert_to(v_token, 'UTF8')), 'hex'),
          p_expires_at, acting_user())
  returning * into v_row;

  perform audit_record(
    v_doc.company_id, 'document_shares', v_row.id,
    coalesce(v_doc.number, v_doc.id::text), 'insert', 'document_shared',
    null,
    jsonb_build_object('document_id', v_doc.id, 'doc_type', v_doc.doc_type,
                       'expires_at', v_row.expires_at));

  select i.public_base_url into v_base from instance i where i.id = 1;

  return query select v_row.id,
                      v_token,
                      case when v_base is null then null
                           else rtrim(v_base, '/') || '/shared/' || v_token end;
end;
$function$;

alter table attachments         alter column uploaded_by set default acting_user();
alter table document_unpostings alter column unposted_by set default acting_user();
alter table book_imports        alter column created_by  set default acting_user();

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

-- A column default and an invoker function evaluate it as the caller. `anon`
-- writes nothing and is not given it.
revoke execute on function acting_user() from public, anon;
grant  execute on function acting_user() to authenticated, service_role;
