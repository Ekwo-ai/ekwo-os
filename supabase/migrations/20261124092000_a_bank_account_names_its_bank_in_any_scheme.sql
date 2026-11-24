-- Ekwo OS — a company's bank account names its bank in any scheme.
--
-- `20261123203500_an_account_is_a_scheme_and_a_value` gave `bank_accounts` a
-- `bank_scheme` and a `bank_identifier` beside `bic`, and the closed list
-- `bank_identifier_schemes` of the schemes a bank is named in: a BIC, an ABA
-- routing number, a sort code, a BSB, an IFSC, a transit and institution
-- number, a Zengin bank and branch code. `create_bank_account()` still took
-- the bank as `p_bic` alone, so an account in a country whose banks have no
-- BIC in daily use could be created only without its bank.
--
-- It now takes `p_bank_scheme` and `p_bank_identifier`, two parameters added
-- at the end with a null default: a caller that sends what it sent before —
-- `p_bic` or nothing — gets what it got before, by position or by name. The
-- pair is checked by `bank_identifier_problem()`, the one check of a bank
-- identifier, and the scheme must be one that names a bank
-- (`identifies = 'institution'`). Refused by name: `missing_bank_identifier`
-- (one of the two without the other), `unknown_bank_identifier_scheme` and
-- `invalid_bank_identifier` (from the check), `not_a_bank_scheme` (an account
-- scheme), `bank_identifier_disagrees` (`p_bic` and a pair saying two things).
-- The mirror of `20261123203500` keeps `bic` in step: filled for a BIC, empty
-- for any other scheme.
--
-- A function cannot gain parameters in place, so the eight-parameter version
-- is dropped and the ten-parameter one created, with its comment and grants.
-- Nothing in the schema calls it; clients call it by name. Additive in
-- effect: every call that worked still works.

set search_path = ekwo, pg_temp;

drop function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid);

create function ekwo.create_bank_account(
  p_company_id         uuid,
  p_account_identifier text,
  p_name               text default null,
  p_bank_name          text default null,
  p_bic                text default null,
  p_currency_code      text default null,
  p_journal_id         uuid default null,
  p_account_id         uuid default null,
  p_bank_scheme        text default null,
  p_bank_identifier    text default null
)
returns jsonb
language plpgsql
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
  v_bank_scheme text;
  v_bank_value  text;
  v_problem     text;
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

  -- The bank, in any institution scheme of bank_identifier_schemes: a BIC, an
  -- ABA routing number, a sort code, a BSB, an IFSC… named with its scheme,
  -- never assumed. p_bic alone is a BIC, as it always was.
  if p_bank_scheme is not null or p_bank_identifier is not null then
    v_bank_scheme := nullif(btrim(p_bank_scheme), '');
    v_bank_value  := nullif(btrim(p_bank_identifier), '');
    if v_bank_scheme is null or v_bank_value is null then
      raise exception 'missing_bank_identifier: a bank is named by a scheme and a value together — p_bank_scheme (bic, aba, sort-code, bsb, ifsc, …) and p_bank_identifier.'
        using errcode = '22023';
    end if;
    v_problem := bank_identifier_problem(v_bank_scheme, v_bank_value);
    if v_problem is not null then
      raise exception '%', v_problem using errcode = '22023';
    end if;
    if not exists (select 1 from bank_identifier_schemes s
                    where s.code = v_bank_scheme and s.identifies = 'institution') then
      raise exception 'not_a_bank_scheme: % identifies an account, not the bank that keeps it. Name the bank in an institution scheme of bank_identifier_schemes (bic, aba, sort-code, bsb, ifsc, …).',
        v_bank_scheme
        using errcode = '22023';
    end if;
    if nullif(btrim(p_bic), '') is not null
       and (v_bank_scheme <> 'bic' or upper(btrim(p_bic)) <> upper(v_bank_value)) then
      raise exception 'bank_identifier_disagrees: p_bic says %, and p_bank_scheme/p_bank_identifier say %/%; give one of them.',
        btrim(p_bic), v_bank_scheme, v_bank_value
        using errcode = '22023';
    end if;
  end if;

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

  -- The bank goes in as its pair when one was named, and the mirror fills
  -- bic for a BIC; as bic alone otherwise, which the mirror turns into the pair.
  if v_bank_scheme is not null then
    insert into bank_accounts (company_id, name, account_scheme, account_identifier, bank_scheme, bank_identifier,
                               bank_name, currency_code, account_id, journal_id)
    values (p_company_id, v_name, nullif(v_scheme, 'account-number'), v_identifier, v_bank_scheme, v_bank_value,
            nullif(btrim(p_bank_name), ''), coalesce(upper(p_currency_code), v_company.currency_code),
            v_account.id, v_journal.id)
    returning * into v_created;
  else
    insert into bank_accounts (company_id, name, account_scheme, account_identifier, bic,
                               bank_name, currency_code, account_id, journal_id)
    values (p_company_id, v_name, nullif(v_scheme, 'account-number'), v_identifier, nullif(btrim(p_bic), ''),
            nullif(btrim(p_bank_name), ''), coalesce(upper(p_currency_code), v_company.currency_code),
            v_account.id, v_journal.id)
    returning * into v_created;
  end if;

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

comment on function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid, text, text) is
  'Registers a bank account of a company from what identifies it at its bank, read in the scheme the company''s country pack declares (read_bank_account_identifier()), and wires it to a bank journal — the one named, or the first active one — and to a ledger account — the one named, or the journal''s default. The bank is p_bank_scheme and p_bank_identifier, in any institution scheme of bank_identifier_schemes, checked by bank_identifier_problem(); p_bic alone is a BIC, as before. The journal points back when it pointed at nothing. Safe to repeat: the same identifier, however spelled, returns the existing account with created = false. Refused by name: unknown_company, not_allowed (bank.write), missing_account_identifier, invalid_bank_account, missing_bank_identifier, unknown_bank_identifier_scheme, invalid_bank_identifier, not_a_bank_scheme, bank_identifier_disagrees, unknown_journal, not_a_bank_journal, no_bank_journal, unknown_account, no_bank_ledger_account, bank_account_exists (the name of another account). Returns {bank_account, created, journal}.';

revoke execute on function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid, text, text) from public, anon;
grant execute on function ekwo.create_bank_account(uuid, text, text, text, text, text, uuid, uuid, text, text) to authenticated, service_role;
