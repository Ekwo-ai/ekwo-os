-- ---------------------------------------------------------------------------
-- Ekwo OS — a bank account is created by a function of the schema.
-- ---------------------------------------------------------------------------
--
-- Until now a bank account came into the books by two roads, each in
-- TypeScript: `ekwo init --bank-identifier` and the `create_bank_account` tool
-- of the MCP server. A client of the REST API — a web application, a script —
-- had neither: it inserted a row into `bank_accounts` and had to know, by
-- itself, which scheme the banks of the company's country use, how an
-- identifier is written in it, which journal books it and which ledger account
-- stands behind it. A screen that cannot answer those questions sends its user
-- to somebody else to add the account.
--
-- This migration gives the schema both answers, so every client takes the
-- same road:
--
-- * `read_bank_account_identifier(scheme, raw)` reads what a person typed
--   against one scheme and returns the canonical identifier — the parts in
--   order, one space between them — or raises `invalid_bank_account` with the
--   reason and the shape expected. It is the reader of `@ekwo-ai/core`
--   (`BANK_ACCOUNT_SCHEMES`, `readBankAccountIdentifier`) written in SQL, and
--   `tests/bank_account_identifier_sql.test.ts` holds the two together, scheme
--   by scheme, on the same inputs: a scheme added to one and not to the other
--   fails there. A null scheme is the free-text account number, never an IBAN,
--   as `20260929141500_a_bank_account_is_not_an_iban.sql` decided.
--
-- * `create_bank_account(company, identifier, …)` registers the account in the
--   scheme the company's country pack declares (`country_defaults
--   .bank_account_scheme`), wires it to a bank journal — the one named, or the
--   first active one of the company — and to the ledger account behind it —
--   the one named, or the journal's default, which the country template chose.
--   The journal points back when it pointed at nothing yet. It is safe to
--   repeat: the identifier is the natural key of an account in a company, so
--   the same identifier, however spelled, answers the account that exists with
--   `created = false`. A second account under the name of another is refused,
--   `bank_account_exists`, so that two lines of a list never read the same.
--
-- `security invoker`: row level security and `bank.write` decide, as they do
-- for an insert into the table; the function says why when they refuse.
--
-- Both functions live in the schema `ekwo`, created by their qualified name
-- with the path of the socle (`ekwo, pg_temp`), as every function since
-- `20261028040000`; the Data API reaches them through the profile `ekwo`.
-- ---------------------------------------------------------------------------

create or replace function ekwo.read_bank_account_identifier(p_scheme text, p_raw text)
returns text
language plpgsql
immutable
set search_path = ekwo, pg_temp
as $$
declare
  v_key       text := coalesce(p_scheme, 'account-number');
  v_label     text;
  v_example   text;
  v_upper     boolean := false;
  -- One entry per part of the identifier: what it is called, its exact length
  -- (null for the last, which takes what is left) and what it looks like.
  v_names     text[];
  v_lengths   integer[];
  v_patterns  text[];
  v_clean     text;
  v_rest      text;
  v_value     text;
  v_parts     text[] := '{}';
  v_failed    text;
  v_sum       integer;
  v_remainder integer;
  v_char      text;
  v_digits    text;
  i           integer;
begin
  case v_key
    when 'iban' then
      v_label := 'IBAN';
      v_example := 'two letters, two check digits, then the national account number';
      v_upper := true;
      v_names := array['IBAN'];
      v_lengths := array[null]::integer[];
      v_patterns := array['^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$'];
    when 'aba-routing-account' then
      v_label := 'ABA routing number and account number';
      v_example := '9-digit routing number, then the account number';
      v_names := array['ABA routing number', 'account number'];
      v_lengths := array[9, null];
      v_patterns := array['^[0-9]{9}$', '^[0-9]{4,17}$'];
    when 'sort-code-account' then
      v_label := 'sort code and account number';
      v_example := '6-digit sort code, then the 8-digit account number';
      v_names := array['sort code', 'account number'];
      v_lengths := array[6, null];
      v_patterns := array['^[0-9]{6}$', '^[0-9]{6,8}$'];
    when 'bsb-account' then
      v_label := 'BSB and account number';
      v_example := '6-digit BSB, then the account number';
      v_names := array['BSB', 'account number'];
      v_lengths := array[6, null];
      v_patterns := array['^[0-9]{6}$', '^[0-9]{5,9}$'];
    when 'ifsc-account' then
      v_label := 'IFSC and account number';
      v_example := '11-character IFSC, then the account number';
      v_upper := true;
      v_names := array['IFSC', 'account number'];
      v_lengths := array[11, null];
      v_patterns := array['^[A-Z]{4}0[A-Z0-9]{6}$', '^[0-9]{9,18}$'];
    when 'clabe' then
      v_label := 'CLABE';
      v_example := '18 digits, the last one a check digit';
      v_names := array['CLABE'];
      v_lengths := array[null]::integer[];
      v_patterns := array['^[0-9]{18}$'];
    when 'zengin' then
      v_label := 'bank code, branch code and account number';
      v_example := '4-digit bank code, 3-digit branch code, then the account number';
      v_names := array['bank code', 'branch code', 'account number'];
      v_lengths := array[4, 3, null];
      v_patterns := array['^[0-9]{4}$', '^[0-9]{3}$', '^[0-9]{6,8}$'];
    when 'transit-institution-account' then
      v_label := 'transit number, institution number and account number';
      v_example := '5-digit transit, 3-digit institution, then the account number';
      v_names := array['transit number', 'institution number', 'account number'];
      v_lengths := array[5, 3, null];
      v_patterns := array['^[0-9]{5}$', '^[0-9]{3}$', '^[0-9]{7,12}$'];
    when 'account-number' then
      -- A number as the bank gave it: trimmed, its spaces folded, never checked.
      v_value := regexp_replace(regexp_replace(coalesce(p_raw, ''), '^[[:space:]]+|[[:space:]]+$', '', 'g'),
                                '[[:space:]]+', ' ', 'g');
      if length(v_value) between 1 and 64 then
        return v_value;
      end if;
      raise exception 'invalid_bank_account: the account number is empty or too long. Expected account number: the number your bank gives it, as written.'
        using errcode = '22023';
    else
      raise exception 'unknown_bank_account_scheme: % is not a scheme this release reads.', v_key
        using errcode = '22023';
  end case;

  -- Spaces, hyphens, slashes, colons and dots are separators a person types;
  -- none of them is part of an identifier.
  v_clean := coalesce(p_raw, '');
  if v_upper then
    v_clean := upper(v_clean);
  end if;
  v_clean := regexp_replace(v_clean, '[[:space:]/:.-]', '', 'g');

  v_rest := v_clean;
  for i in 1 .. array_length(v_names, 1) loop
    if i = array_length(v_names, 1) or v_lengths[i] is null then
      v_value := v_rest;
      v_rest := '';
    else
      v_value := substr(v_rest, 1, v_lengths[i]);
      v_rest := substr(v_rest, v_lengths[i] + 1);
    end if;
    if v_value !~ v_patterns[i] then
      raise exception 'invalid_bank_account: the % is not valid. Expected %: %.', v_names[i], v_label, v_example
        using errcode = '22023';
    end if;
    v_parts := v_parts || v_value;
  end loop;

  -- The schemes that carry a check digit.
  if v_key = 'iban' then
    -- ISO 7064 mod 97-10: the first four characters moved to the end, every
    -- letter read as two digits (A = 10 … Z = 35), the whole taken modulo 97.
    v_digits := '';
    foreach v_char in array regexp_split_to_array(substr(v_parts[1], 5) || substr(v_parts[1], 1, 4), '') loop
      v_digits := v_digits || case when v_char >= 'A' then (ascii(v_char) - 55)::text else v_char end;
    end loop;
    v_remainder := 0;
    foreach v_char in array regexp_split_to_array(v_digits, '') loop
      v_remainder := (v_remainder * 10 + v_char::integer) % 97;
    end loop;
    if v_remainder <> 1 then
      v_failed := 'the IBAN check digits do not add up';
    end if;
  elsif v_key = 'aba-routing-account' then
    -- Weights 3-7-1 over the nine digits; a valid routing number sums to a multiple of ten.
    v_sum := 0;
    for i in 1 .. 9 loop
      v_sum := v_sum + substr(v_parts[1], i, 1)::integer * (array[3, 7, 1])[((i - 1) % 3) + 1];
    end loop;
    if v_sum % 10 <> 0 then
      v_failed := 'the ABA routing number check digit does not add up';
    end if;
  elsif v_key = 'clabe' then
    -- Weights 3-7-1 over the first seventeen digits, each product modulo 10;
    -- the eighteenth digit is ten less the sum, modulo 10.
    v_sum := 0;
    for i in 1 .. 17 loop
      v_sum := v_sum + (substr(v_parts[1], i, 1)::integer * (array[3, 7, 1])[((i - 1) % 3) + 1]) % 10;
    end loop;
    if substr(v_parts[1], 18, 1)::integer <> (10 - v_sum % 10) % 10 then
      v_failed := 'the CLABE check digit does not add up';
    end if;
  end if;

  if v_failed is not null then
    raise exception 'invalid_bank_account: %. Expected %: %.', v_failed, v_label, v_example
      using errcode = '22023';
  end if;

  return array_to_string(v_parts, ' ');
end;
$$;

comment on function ekwo.read_bank_account_identifier(text, text) is
  'Reads a bank account identifier as a person typed it against one scheme — iban, aba-routing-account, sort-code-account, bsb-account, ifsc-account, clabe, zengin, transit-institution-account, or a null scheme for a free-text account number — and returns it in the canonical form of that scheme: its parts in order, one space between them, spaces, hyphens, slashes, colons and dots dropped. Raises invalid_bank_account with the reason and the shape expected, and unknown_bank_account_scheme for a scheme this release does not read. The same reader as readBankAccountIdentifier() of @ekwo-ai/core.';

revoke execute on function ekwo.read_bank_account_identifier(text, text) from public, anon;
grant execute on function ekwo.read_bank_account_identifier(text, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- create_bank_account()
-- ---------------------------------------------------------------------------

create or replace function ekwo.create_bank_account(
  p_company_id         uuid,
  p_account_identifier text,
  p_name               text default null,
  p_bank_name          text default null,
  p_bic                text default null,
  p_currency_code      text default null,
  p_journal_id         uuid default null,
  p_account_id         uuid default null
)
returns jsonb
language plpgsql
volatile
security invoker
set search_path = ekwo, pg_temp
as $$
declare
  v_company    companies;
  v_scheme     text;
  v_identifier text;
  v_name       text;
  v_journal    journals;
  v_account    accounts;
  v_existing   bank_accounts;
  v_created    bank_accounts;
begin
  select * into v_company from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %. Either it does not exist or you are not a member of it.', p_company_id
      using errcode = 'no_data_found';
  end if;
  -- Row level security is what refuses; this is what says why.
  -- Null-safe on purpose: `if NULL` does not raise.
  if not coalesce(is_installer(), false)
     and not coalesce(has_capability(p_company_id, 'bank.write'), false) then
    raise exception 'not_allowed: adding a bank account to this company needs bank.write'
      using errcode = '42501';
  end if;

  -- The scheme is the country's, from its pack. A pack that declares none
  -- leaves a null, which is a free-text account number.
  select cd.bank_account_scheme into v_scheme
    from country_defaults cd
   where cd.country = v_company.country;

  if p_account_identifier is null or btrim(p_account_identifier) = '' then
    raise exception 'missing_account_identifier: a bank account is registered by what identifies it at its bank — for this company''s country, %.',
      coalesce(v_scheme, 'the account number')
      using errcode = '22023';
  end if;
  v_identifier := read_bank_account_identifier(v_scheme, p_account_identifier);

  -- The journal it books through: the one named, or the company's first
  -- active bank journal.
  if p_journal_id is not null then
    select * into v_journal from journals j
     where j.id = p_journal_id and j.company_id = p_company_id;
    if not found then
      raise exception 'unknown_journal: % is not a journal of this company', p_journal_id
        using errcode = 'no_data_found';
    end if;
    if v_journal.journal_type not in ('bank', 'cash') then
      raise exception 'not_a_bank_journal: journal % is a % journal; a bank account books through a bank or a cash journal',
        v_journal.code, v_journal.journal_type
        using errcode = '22023';
    end if;
  else
    select * into v_journal from journals j
     where j.company_id = p_company_id and j.journal_type = 'bank' and j.active
     order by j.code
     limit 1;
    if not found then
      raise exception 'no_bank_journal: this company has no active journal of type bank, so a bank account has nothing to book through. install_country_template creates it.'
        using errcode = 'no_data_found';
    end if;
  end if;

  -- The same identifier, however it was spelled, is the same account.
  select * into v_existing from bank_accounts b
   where b.company_id = p_company_id and b.account_identifier = v_identifier;
  if found then
    return jsonb_build_object(
      'bank_account', to_jsonb(v_existing),
      'created', false,
      'journal', (select jsonb_build_object('id', j.id, 'code', j.code, 'name', j.name)
                    from journals j where j.id = v_existing.journal_id)
    );
  end if;

  -- The ledger account behind it: the one named, or the journal's default,
  -- which the country template chose.
  select * into v_account from accounts a
   where a.id = coalesce(p_account_id, v_journal.default_account_id)
     and a.company_id = p_company_id;
  if not found then
    if p_account_id is not null then
      raise exception 'unknown_account: % is not an account of this company', p_account_id
        using errcode = 'no_data_found';
    end if;
    raise exception 'no_bank_ledger_account: journal % has no default account, so this bank account would book nowhere. Name the ledger account, or set the journal''s default account.',
      v_journal.code
      using errcode = '22023';
  end if;

  v_name := coalesce(nullif(btrim(p_name), ''), nullif(btrim(p_bank_name), ''), v_identifier);
  if exists (select 1 from bank_accounts b
              where b.company_id = p_company_id and lower(b.name) = lower(v_name)) then
    raise exception 'bank_account_exists: this company already has a bank account named "%", with another identifier. Give this one a name of its own.',
      v_name
      using errcode = '23505';
  end if;

  insert into bank_accounts (company_id, name, account_scheme, account_identifier, bic,
                             bank_name, currency_code, account_id, journal_id)
  values (p_company_id, v_name, nullif(v_scheme, 'account-number'), v_identifier, nullif(btrim(p_bic), ''),
          nullif(btrim(p_bank_name), ''), coalesce(upper(p_currency_code), v_company.currency_code),
          v_account.id, v_journal.id)
  returning * into v_created;

  -- The journal points back, so a payment finds the money side from either
  -- direction. A journal that already names an account keeps it.
  update journals set bank_account_id = v_created.id
   where id = v_journal.id and bank_account_id is null;

  return jsonb_build_object(
    'bank_account', to_jsonb(v_created),
    'created', true,
    'journal', jsonb_build_object('id', v_journal.id, 'code', v_journal.code, 'name', v_journal.name)
  );
end;
$$;

comment on function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid) is
  'Registers a bank account of a company from what identifies it at its bank, read in the scheme the company''s country pack declares (read_bank_account_identifier()), and wires it to a bank journal — the one named, or the first active one — and to a ledger account — the one named, or the journal''s default. The journal points back when it pointed at nothing. Safe to repeat: the same identifier, however spelled, returns the existing account with created = false. Refused by name: unknown_company, not_allowed (bank.write), missing_account_identifier, invalid_bank_account, unknown_journal, not_a_bank_journal, no_bank_journal, unknown_account, no_bank_ledger_account, bank_account_exists (the name of another account). Returns {bank_account, created, journal}.';

revoke execute on function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid) from public, anon;
grant execute on function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid) to authenticated, service_role;

-- The revoke every file of this directory ends with, and the Data API told
-- the functions are there.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
