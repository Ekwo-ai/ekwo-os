-- Ekwo OS — every account of the books is a scheme and a value.
--
-- `20260929141500_a_bank_account_is_not_an_iban.sql` gave `bank_accounts` an
-- `account_scheme` and an `account_identifier`, because half the world names
-- an account by a routing number and an account number rather than by an
-- IBAN. Five columns of the socle still named the European answer alone:
--
--   bank_accounts.bic                   the bank of the company's own account
--   contacts.iban, contacts.bic         the account a party pays from or into
--   bank_transactions.counterpart_iban  the account on the other side of a line
--   documents.payee_iban                EN 16931 BT-84, the *payment account
--                                       identifier*, which is not an IBAN
--
-- So a United States customer paid from an ABA routing number and account,
-- an Australian one from a BSB, an Indian one from an IFSC, had nowhere to be
-- recorded, and a statement line from them could not be recognised by its
-- account. This file gives each of those facts the shape the schema already
-- uses for an identifier — a scheme and a value, as `peppol_scheme` and
-- `peppol_identifier` — and keeps the old columns, exactly as
-- `20260916094500` kept `companies.vat_period`: one fact, two names, a
-- trigger holding them in step, the old name still readable and writable,
-- its removal left to a later major version. No installation wakes up with a
-- column missing, and a client that knows only the old names keeps working.
--
-- **The schemes are a closed list held by the database.**
-- `bank_identifier_schemes` lists every scheme a column of this file may name:
-- the account schemes are the keys of `BANK_ACCOUNT_SCHEMES` in
-- `@ekwo-ai/core` and of `read_bank_account_identifier()` (`iban` is one of
-- them, never the default), and the institution schemes name the bank —
-- `bic` (ISO 9362) is one of them, beside the ABA routing number, the sort
-- code, the BSB, the IFSC, the transit and institution numbers and the
-- Zengin bank and branch codes. `tests/account_identifier_schemes.test.ts`
-- holds the list and the registry together. A scheme outside the list is
-- refused by its foreign key, by name; a scheme of the list whose check this
-- release does not hold is stored as written.
--
-- **The check follows the scheme.** `bank_identifier_problem(scheme, value)`
-- reads the scheme first and answers the reason a value breaks it, or null:
-- ISO 7064 mod 97-10 for an IBAN, the weighted 3-7-1 sum for an ABA routing
-- number, the shape of ISO 9362 for a BIC, and for every account scheme what
-- `read_bank_account_identifier()` already reads. Nothing is ever refused for
-- not being an IBAN. The mirror triggers do not call it: a writer that put
-- an unchecked IBAN in `contacts.iban` yesterday is not refused today.
--
-- **The mirror.** One trigger function, `mirror_bank_identifier()`, is
-- attached to each pair with the name of its old column, of its two new ones
-- and of the scheme the old column means (`iban` or `bic`):
--
--   * a write to the old column writes the pair in that scheme, and clearing
--     it clears a pair of that scheme;
--   * a write to the pair writes the old column when the scheme is the one it
--     means, and clears it otherwise: a routing number never lands in a
--     column called iban;
--   * a write to both that says two things is refused, `bank_identifier_disagrees`.
--
-- `bank_accounts.iban` was already held to `account_scheme` and
-- `account_identifier` by `bank_accounts_read_identifier()`, and keeps it.
--
-- **The payee of a sales document** took the company's default account into
-- `payee_iban` whatever its scheme. It now takes the scheme with it, and only
-- an IBAN lands in `payee_iban`. The rows written before are backfilled with
-- the scheme of the company's account they came from where one matches, and
-- as an IBAN otherwise.
--
-- **Recognising who paid.** `contact_candidates()` compared the line's account
-- with `contacts.iban`, and its callers passed `counterpart_iban`. Both now
-- read the new value, the old column only where the new one is empty, and so
-- does `suggest_duplicate_contacts()`, which proposes two contacts sharing an
-- account as one party. The four functions are read back from the catalogue
-- and written again with that one change, the way `20261028040000` rewrote
-- the path of every function, so nothing else of their latest definition
-- moves.
--
-- **Importing a statement** wrote any account into `counterpart_iban`. It now
-- writes the pair with the scheme the file's reader recognised, and
-- `account-number` where it recognised none.
--
-- Additive: one table, ten columns, their backfill, five triggers, two
-- functions, five functions rewritten in place, one view with columns
-- appended. `SCHEMA_MIN` does not move: a client that finds none of this
-- reads the old columns.

set search_path = ekwo, pg_temp;

-- ---------------------------------------------------------------------------
-- 1. The schemes
-- ---------------------------------------------------------------------------

create table if not exists ekwo.bank_identifier_schemes (
  code         text primary key,
  identifies   text not null check (identifies in ('account', 'institution')),
  label        text not null,
  check_digits text check (check_digits in ('iso7064-mod97-10', 'aba-3-7-1', 'clabe-3-7-1')),
  created_at   timestamptz not null default now()
);

comment on table ekwo.bank_identifier_schemes is
  'The closed list of schemes a bank account or a bank is identified in. identifies says which: an account (iban, aba-routing-account, bsb-account, ifsc-account, …, account-number for a number as the bank gave it) or the institution that keeps it (bic, aba, sort-code, bsb, ifsc, transit-institution, zengin-bank-branch). The account schemes are the keys of BANK_ACCOUNT_SCHEMES in @ekwo-ai/core. Every scheme column of the socle references this table; a scheme is added by a migration together with its reader.';
comment on column ekwo.bank_identifier_schemes.check_digits is
  'The check a value of this scheme carries, read by bank_identifier_problem(): iso7064-mod97-10 (IBAN), aba-3-7-1 (ABA routing number), clabe-3-7-1 (CLABE). Null where the scheme carries none.';

insert into ekwo.bank_identifier_schemes (code, identifies, label, check_digits) values
  ('iban',                        'account',     'IBAN (ISO 13616)',                                       'iso7064-mod97-10'),
  ('aba-routing-account',         'account',     'ABA routing number and account number',                  'aba-3-7-1'),
  ('sort-code-account',           'account',     'sort code and account number',                           null),
  ('bsb-account',                 'account',     'BSB and account number',                                 null),
  ('ifsc-account',                'account',     'IFSC and account number',                                null),
  ('clabe',                       'account',     'CLABE',                                                  'clabe-3-7-1'),
  ('zengin',                      'account',     'bank code, branch code and account number',              null),
  ('transit-institution-account', 'account',     'transit number, institution number and account number',  null),
  ('account-number',              'account',     'account number, as the bank gives it',                   null),
  ('bic',                         'institution', 'BIC (ISO 9362)',                                         null),
  ('aba',                         'institution', 'ABA routing number',                                     'aba-3-7-1'),
  ('sort-code',                   'institution', 'sort code',                                              null),
  ('bsb',                         'institution', 'BSB',                                                    null),
  ('ifsc',                        'institution', 'IFSC',                                                   null),
  ('transit-institution',         'institution', 'transit number and institution number',                  null),
  ('zengin-bank-branch',          'institution', 'bank code and branch code (Zengin)',                     null)
on conflict (code) do nothing;

alter table ekwo.bank_identifier_schemes enable row level security;

create policy bank_identifier_schemes_select on ekwo.bank_identifier_schemes
  for select using (true);

comment on policy bank_identifier_schemes_select on ekwo.bank_identifier_schemes is
  'Reference data, the same for every company: anybody signed in reads it. Nobody but a migration writes it.';

grant select on table ekwo.bank_identifier_schemes to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 2. The check, by scheme
-- ---------------------------------------------------------------------------

create or replace function ekwo.bank_identifier_problem(p_scheme text, p_value text)
returns text
language plpgsql
stable
set search_path = ekwo, pg_temp
as $$
declare
  v_scheme ekwo.bank_identifier_schemes;
  v_clean  text;
  v_sum    integer := 0;
  i        integer;
begin
  if p_scheme is null or p_value is null then
    return null;
  end if;
  select * into v_scheme from ekwo.bank_identifier_schemes s where s.code = p_scheme;
  if not found then
    return format('unknown_bank_identifier_scheme: %s is not a scheme of bank_identifier_schemes.', p_scheme);
  end if;
  -- An account scheme is read by the reader every client already shares.
  if v_scheme.identifies = 'account' then
    begin
      perform ekwo.read_bank_account_identifier(p_scheme, p_value);
    exception when sqlstate '22023' then
      -- A scheme of the list the reader does not know is stored as written.
      if sqlerrm like 'unknown_bank_account_scheme:%' then
        return null;
      end if;
      return sqlerrm;
    end;
    return null;
  end if;
  v_clean := upper(regexp_replace(p_value, '[[:space:]/:.-]', '', 'g'));
  if p_scheme = 'bic' then
    if v_clean !~ '^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$' then
      return 'invalid_bank_identifier: the BIC is not valid. Expected BIC (ISO 9362): four letters, the country, two characters, and an optional branch of three.';
    end if;
  elsif v_scheme.check_digits = 'aba-3-7-1' then
    if v_clean !~ '^[0-9]{9}$' then
      return 'invalid_bank_identifier: the ABA routing number is not valid. Expected ABA routing number: nine digits.';
    end if;
    for i in 1 .. 9 loop
      v_sum := v_sum + substr(v_clean, i, 1)::integer * (array[3, 7, 1])[((i - 1) % 3) + 1];
    end loop;
    if v_sum % 10 <> 0 then
      return 'invalid_bank_identifier: the ABA routing number check digit does not add up.';
    end if;
  end if;
  return null;
end;
$$;

comment on function ekwo.bank_identifier_problem(text, text) is
  'Why a value breaks its scheme, or null when it holds. Reads the scheme first, from bank_identifier_schemes: an account scheme is read by read_bank_account_identifier() (ISO 7064 mod 97-10 for an IBAN, the 3-7-1 weighted sum for an ABA routing number, …), a BIC by the shape of ISO 9362, an ABA routing number by its weighted sum. A scheme whose check this release does not hold answers null: its value is stored as written. Never refuses a value for not being an IBAN.';

revoke execute on function ekwo.bank_identifier_problem(text, text) from public, anon;
grant execute on function ekwo.bank_identifier_problem(text, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. The columns
-- ---------------------------------------------------------------------------

alter table ekwo.bank_accounts
  add column if not exists bank_scheme     text references ekwo.bank_identifier_schemes (code),
  add column if not exists bank_identifier text;

alter table ekwo.contacts
  add column if not exists account_scheme     text references ekwo.bank_identifier_schemes (code),
  add column if not exists account_identifier text,
  add column if not exists bank_scheme        text references ekwo.bank_identifier_schemes (code),
  add column if not exists bank_identifier    text;

alter table ekwo.bank_transactions
  add column if not exists counterpart_account_scheme     text references ekwo.bank_identifier_schemes (code),
  add column if not exists counterpart_account_identifier text;

alter table ekwo.documents
  add column if not exists payee_account_scheme     text references ekwo.bank_identifier_schemes (code),
  add column if not exists payee_account_identifier text;

-- `bank_accounts.account_scheme` is older than the list and was free text: its
-- reference is `not valid`, so a row somebody wrote by hand does not stop this
-- file, and every write from here on is judged.
alter table ekwo.bank_accounts
  add constraint bank_accounts_account_scheme_listed
  foreign key (account_scheme) references ekwo.bank_identifier_schemes (code) not valid;

-- Each reference has its index, as every foreign key of the schema does.
create index if not exists bank_accounts_account_scheme_idx on ekwo.bank_accounts (account_scheme);
create index if not exists bank_accounts_bank_scheme_idx on ekwo.bank_accounts (bank_scheme);
create index if not exists contacts_account_scheme_idx on ekwo.contacts (account_scheme);
create index if not exists contacts_bank_scheme_idx on ekwo.contacts (bank_scheme);
create index if not exists bank_transactions_counterpart_account_scheme_idx
  on ekwo.bank_transactions (counterpart_account_scheme);
create index if not exists documents_payee_account_scheme_idx on ekwo.documents (payee_account_scheme);

-- Every existing value was written as what its column was named after. The
-- guards of a posted or merged row judge a person's edit, not this backfill,
-- which changes no fact: the triggers of the four tables wait until it ends.
alter table ekwo.bank_accounts disable trigger user;
alter table ekwo.contacts disable trigger user;
alter table ekwo.bank_transactions disable trigger user;
alter table ekwo.documents disable trigger user;

update ekwo.bank_accounts
   set bank_scheme = 'bic', bank_identifier = bic
 where bic is not null and bank_identifier is null;

update ekwo.contacts
   set account_scheme = 'iban', account_identifier = iban
 where iban is not null and account_identifier is null;

update ekwo.contacts
   set bank_scheme = 'bic', bank_identifier = bic
 where bic is not null and bank_identifier is null;

-- A statement imported by import_bank_statement() kept, in `raw`, whether its
-- reader recognised an IBAN: a counterpart it did not is an account number.
update ekwo.bank_transactions
   set counterpart_account_scheme =
         case when raw #>> '{counterparty,account,kind}' = 'other' then 'account-number' else 'iban' end,
       counterpart_account_identifier = counterpart_iban
 where counterpart_iban is not null and counterpart_account_identifier is null;

-- A sales document took its payee from the company's default account whatever
-- its scheme: the scheme of the account it came from, where one matches.
update ekwo.documents d
   set payee_account_scheme = coalesce(
         (select b.account_scheme
            from ekwo.bank_accounts b
           where b.company_id = d.company_id
             and b.account_identifier = d.payee_iban
             and b.account_scheme is not null
           limit 1),
         'iban'),
       payee_account_identifier = d.payee_iban
 where d.payee_iban is not null and d.payee_account_identifier is null;

-- A value written before this file into payee_iban or counterpart_iban that
-- is no IBAN stays where it was, for the clients that read it there; the pair
-- beside it says what it is, and every write from here on keeps the old
-- column for an IBAN alone.

alter table ekwo.bank_accounts enable trigger user;
alter table ekwo.contacts enable trigger user;
alter table ekwo.bank_transactions enable trigger user;
alter table ekwo.documents enable trigger user;

alter table ekwo.bank_accounts
  add constraint bank_accounts_bank_identifier_whole check ((bank_scheme is null) = (bank_identifier is null));
alter table ekwo.contacts
  add constraint contacts_account_identifier_whole check ((account_scheme is null) = (account_identifier is null)),
  add constraint contacts_bank_identifier_whole check ((bank_scheme is null) = (bank_identifier is null));
alter table ekwo.bank_transactions
  add constraint bank_transactions_counterpart_account_whole
  check ((counterpart_account_scheme is null) = (counterpart_account_identifier is null));
alter table ekwo.documents
  add constraint documents_payee_account_whole
  check ((payee_account_scheme is null) = (payee_account_identifier is null));

comment on column ekwo.bank_accounts.bank_scheme is
  'The scheme bank_identifier is written in: a code of bank_identifier_schemes that identifies an institution — bic, aba, sort-code, bsb, ifsc, … Null together with bank_identifier.';
comment on column ekwo.bank_accounts.bank_identifier is
  'The bank that keeps the account, in the scheme bank_scheme names. Holds the BIC as bic did when the scheme is bic.';
comment on column ekwo.bank_accounts.bic is
  'Deprecated by bank_scheme and bank_identifier, and mirrored with them: the BIC when bank_scheme is bic, null otherwise. Still readable and writable; a write here writes the pair.';

comment on column ekwo.contacts.account_scheme is
  'The scheme account_identifier is written in: a code of bank_identifier_schemes that identifies an account — iban, aba-routing-account, bsb-account, ifsc-account, … Null together with account_identifier.';
comment on column ekwo.contacts.account_identifier is
  'The account this party pays from or is paid into, in the scheme account_scheme names. Read by contact_candidates() to recognise the party on a statement line.';
comment on column ekwo.contacts.bank_scheme is
  'The scheme bank_identifier is written in: a code of bank_identifier_schemes that identifies an institution. Null together with bank_identifier.';
comment on column ekwo.contacts.bank_identifier is
  'The bank that keeps this party''s account, in the scheme bank_scheme names.';
comment on column ekwo.contacts.iban is
  'Deprecated by account_scheme and account_identifier, and mirrored with them: the account when its scheme is iban, null otherwise. Still readable and writable; a write here writes the pair.';
comment on column ekwo.contacts.bic is
  'Deprecated by bank_scheme and bank_identifier, and mirrored with them: the BIC when bank_scheme is bic, null otherwise. Still readable and writable; a write here writes the pair.';

comment on column ekwo.bank_transactions.counterpart_account_scheme is
  'The scheme counterpart_account_identifier is written in, as the statement gave it: a code of bank_identifier_schemes that identifies an account. Null together with counterpart_account_identifier.';
comment on column ekwo.bank_transactions.counterpart_account_identifier is
  'The account on the other side of the line, in the scheme counterpart_account_scheme names. Compared with contacts.account_identifier to recognise who paid.';
comment on column ekwo.bank_transactions.counterpart_iban is
  'Deprecated by counterpart_account_scheme and counterpart_account_identifier, and mirrored with them: the account when its scheme is iban, null otherwise. Still readable and writable; a write here writes the pair.';

comment on column ekwo.documents.payee_account_scheme is
  'The scheme payee_account_identifier is written in (EN 16931 BT-84 carries an identifier, not an IBAN): a code of bank_identifier_schemes that identifies an account. A sales document without one takes the company''s default bank account, with its scheme. Null together with payee_account_identifier.';
comment on column ekwo.documents.payee_account_identifier is
  'The account the document asks to be paid into, EN 16931 BT-84 "Payment account identifier", in the scheme payee_account_scheme names.';
comment on column ekwo.documents.payee_iban is
  'Deprecated by payee_account_scheme and payee_account_identifier, and mirrored with them: BT-84 when its scheme is iban, null otherwise. Still readable and writable; a write here writes the pair.';

-- ---------------------------------------------------------------------------
-- 4. One fact, two names: the mirror
-- ---------------------------------------------------------------------------

create or replace function ekwo.mirror_bank_identifier()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  -- The old column, the two new ones, and the scheme the old one means.
  c_old    constant text := tg_argv[0];
  c_scheme constant text := tg_argv[1];
  c_value  constant text := tg_argv[2];
  c_means  constant text := tg_argv[3];
  v_row    jsonb := to_jsonb(new);
  v_was    jsonb;
  v_old    text := v_row ->> c_old;
  v_scheme text := v_row ->> c_scheme;
  v_value  text := v_row ->> c_value;
  v_old_moved  boolean;
  v_pair_moved boolean;
begin
  if tg_op = 'UPDATE' then
    v_was := to_jsonb(old);
    v_old_moved  := v_old is distinct from v_was ->> c_old;
    v_pair_moved := v_scheme is distinct from v_was ->> c_scheme
                 or v_value is distinct from v_was ->> c_value;
  else
    v_old_moved  := v_old is not null;
    v_pair_moved := v_scheme is not null or v_value is not null;
  end if;

  if v_old_moved and v_pair_moved then
    -- Both were written: they have to say one thing.
    if (v_scheme is not distinct from c_means and v_value is not distinct from v_old)
       or (v_old is null and v_scheme is distinct from c_means) then
      return new;
    end if;
    raise exception 'bank_identifier_disagrees: % says %, and %/% say %/%; write one of them.',
      c_old, coalesce(v_old, 'null'), c_scheme, c_value, coalesce(v_scheme, 'null'), coalesce(v_value, 'null')
      using errcode = '23514';
  elsif v_old_moved then
    if v_old is not null then
      v_row := v_row || jsonb_build_object(c_scheme, c_means, c_value, v_old);
    elsif v_scheme is not distinct from c_means then
      v_row := v_row || jsonb_build_object(c_scheme, null, c_value, null);
    end if;
  elsif v_pair_moved then
    v_row := v_row || jsonb_build_object(c_old,
      case when v_scheme is not distinct from c_means then v_value end);
  else
    return new;
  end if;
  new := jsonb_populate_record(new, v_row);
  return new;
end;
$$;

comment on function ekwo.mirror_bank_identifier() is
  'Holds a deprecated column (iban, bic, counterpart_iban, payee_iban) and the scheme and value that replace it saying one thing. Its arguments: the old column, the scheme column, the value column, and the scheme the old column means. A write to the old column writes the pair in that scheme; a write to the pair writes the old column when the scheme is that one and clears it otherwise; a write to both that disagrees is refused, bank_identifier_disagrees. The pattern of companies.vat_period and company_filing_periods.';

revoke execute on function ekwo.mirror_bank_identifier() from public, anon, authenticated, service_role;

create trigger bank_accounts_bic_mirror
  before insert or update of bic, bank_scheme, bank_identifier on ekwo.bank_accounts
  for each row execute function ekwo.mirror_bank_identifier('bic', 'bank_scheme', 'bank_identifier', 'bic');

create trigger contacts_iban_mirror
  before insert or update of iban, account_scheme, account_identifier on ekwo.contacts
  for each row execute function ekwo.mirror_bank_identifier('iban', 'account_scheme', 'account_identifier', 'iban');

create trigger contacts_bic_mirror
  before insert or update of bic, bank_scheme, bank_identifier on ekwo.contacts
  for each row execute function ekwo.mirror_bank_identifier('bic', 'bank_scheme', 'bank_identifier', 'bic');

create trigger bank_transactions_counterpart_mirror
  before insert or update of counterpart_iban, counterpart_account_scheme, counterpart_account_identifier
  on ekwo.bank_transactions
  for each row execute function ekwo.mirror_bank_identifier(
    'counterpart_iban', 'counterpart_account_scheme', 'counterpart_account_identifier', 'iban');

-- Named after documents_default_payee_iban so that it fires after it: a before
-- trigger fires in the order of its name.
create trigger documents_payee_mirror
  before insert or update of payee_iban, payee_account_scheme, payee_account_identifier on ekwo.documents
  for each row execute function ekwo.mirror_bank_identifier(
    'payee_iban', 'payee_account_scheme', 'payee_account_identifier', 'iban');

-- ---------------------------------------------------------------------------
-- 5. The payee of a sales document keeps the scheme of its account
-- ---------------------------------------------------------------------------

create or replace function ekwo.documents_default_payee_iban()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
declare
  v_scheme text;
  v_value  text;
begin
  if new.payee_iban is null and new.payee_account_identifier is null
     and new.doc_type::text like 'sale%' then
    select coalesce(b.account_scheme, case when b.iban is not null then 'iban' end),
           coalesce(b.account_identifier, b.iban)
      into v_scheme, v_value
      from ekwo.companies c
      join ekwo.bank_accounts b on b.id = c.default_bank_account_id
     where c.id = new.company_id;
    if v_value is not null then
      -- A free-text account written before the list had a scheme is an account number.
      new.payee_account_scheme := coalesce(v_scheme, 'account-number');
      new.payee_account_identifier := v_value;
    end if;
  end if;
  return new;
end;
$$;

comment on function ekwo.documents_default_payee_iban() is
  'A sales document with no payee account takes the company''s default bank account into payee_account_scheme and payee_account_identifier (BT-84), with the scheme it is written in; documents_payee_mirror then writes payee_iban when that scheme is iban. A purchase document never does: the payee there is somebody else.';

-- ---------------------------------------------------------------------------
-- 6. Recognising who paid reads the new value
--
-- The latest definitions are read back from the catalogue and written again
-- with one change each, so nothing else of them moves. A definition that no
-- longer carries the text replaced stops this file rather than being skipped.
-- ---------------------------------------------------------------------------

do $$
declare
  v_fn   record;
  v_def  text;
  v_new  text;
begin
  for v_fn in
    select p.oid, p.proname
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'ekwo'
       and p.proname in ('contact_candidates', 'suggest_contacts', 'confirm_contact', 'suggest_duplicate_contacts')
  loop
    v_def := pg_get_functiondef(v_fn.oid);
    if v_fn.proname = 'contact_candidates' then
      v_new := replace(replace(v_def,
        'c.iban is not null', 'coalesce(c.account_identifier, c.iban) is not null'),
        'account_key(c.iban)', 'account_key(coalesce(c.account_identifier, c.iban))');
    elsif v_fn.proname = 'suggest_duplicate_contacts' then
      v_new := replace(v_def, 'account_key(c.iban) as iban', 'account_key(coalesce(c.account_identifier, c.iban)) as iban');
    else
      v_new := replace(v_def, 'v_tx.counterpart_iban',
        'coalesce(v_tx.counterpart_account_identifier, v_tx.counterpart_iban)');
    end if;
    if v_new = v_def then
      raise exception 'an_account_is_a_scheme_and_a_value: % no longer reads the account it was written against.', v_fn.proname;
    end if;
    execute v_new;
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. A statement line keeps the scheme its file gave the counterpart
--
-- `import_bank_statement()` wrote whatever account the file carried into
-- `counterpart_iban`, IBAN or not. It now writes the pair: `iban` where the
-- reader of the file recognised one, the reader's own scheme where it is a
-- code of `bank_identifier_schemes`, and `account-number` otherwise — the
-- mirror then fills `counterpart_iban` for an IBAN alone. Rewritten from the
-- catalogue, as above.
-- ---------------------------------------------------------------------------

do $$
declare
  v_oid oid := 'ekwo.import_bank_statement(uuid, jsonb, jsonb, uuid)'::regprocedure;
  v_def text := pg_get_functiondef(v_oid);
  v_new text;
begin
  v_new := replace(v_def,
    'amount, currency_code, description, counterpart_name, counterpart_iban, reference,',
    'amount, currency_code, description, counterpart_name, counterpart_account_scheme, counterpart_account_identifier, reference,');
  v_new := replace(v_new,
    $old$upper(regexp_replace(k.line #>> '{counterparty,account,value}', '\s', '', 'g')),
             k.bank_reference,$old$,
    $new$case
               when nullif(upper(regexp_replace(k.line #>> '{counterparty,account,value}', '\s', '', 'g')), '') is null then null
               when k.line #>> '{counterparty,account,kind}' = 'iban' then 'iban'
               when exists (select 1 from ekwo.bank_identifier_schemes s
                             where s.code = k.line #>> '{counterparty,account,scheme}'
                               and s.identifies = 'account')
                 then k.line #>> '{counterparty,account,scheme}'
               else 'account-number'
             end,
             nullif(upper(regexp_replace(k.line #>> '{counterparty,account,value}', '\s', '', 'g')), ''),
             k.bank_reference,$new$);
  if v_new = v_def or position('counterpart_account_identifier' in v_new) = 0
     or position('counterpart_iban, reference' in v_new) > 0 then
    raise exception 'an_account_is_a_scheme_and_a_value: import_bank_statement no longer writes the counterpart it was written against.';
  end if;
  execute v_new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 8. The header publishes the pair (BT-84), the old columns kept first
-- ---------------------------------------------------------------------------

do $$
declare
  v_def text := pg_get_viewdef('ekwo.document_header'::regclass, false);
begin
  v_def := regexp_replace(v_def, ';\s*$', '');
  -- The view's own join to the seller's default account is reused, not repeated.
  if position('seller_bank' in v_def) = 0 then
    raise exception 'an_account_is_a_scheme_and_a_value: document_header no longer joins the seller''s bank account.';
  end if;
  v_def := regexp_replace(v_def, '\n\s*FROM (\(*)((ekwo\.)?documents d)',
    E',\n    CASE WHEN d.payee_account_identifier IS NOT NULL THEN d.payee_account_scheme'
    || E' WHEN d.payee_iban IS NOT NULL THEN ''iban''::text'
    || E' ELSE COALESCE(seller_bank.account_scheme, CASE WHEN seller_bank.iban IS NOT NULL THEN ''iban''::text END) END AS payee_account_scheme,'
    || E'\n    COALESCE(d.payee_account_identifier, d.payee_iban, seller_bank.account_identifier, seller_bank.iban) AS payee_account_identifier,'
    || E'\n    seller_bank.bank_scheme AS payee_bank_scheme,'
    || E'\n    seller_bank.bank_identifier AS payee_bank_identifier'
    || E'\n   FROM \\1\\2');
  if position('payee_account_identifier' in v_def) = 0 then
    raise exception 'an_account_is_a_scheme_and_a_value: document_header was not extended.';
  end if;
  execute 'create or replace view ekwo.document_header with (security_invoker = true) as ' || v_def;
end;
$$;

grant select on table ekwo.document_header to authenticated, service_role;

comment on column ekwo.document_header.payee_account_scheme is
  'The scheme of payee_account_identifier (BT-84): the document''s own, else the company''s default bank account''s. payee_iban beside it is the same account when that scheme is iban.';
comment on column ekwo.document_header.payee_account_identifier is
  'EN 16931 BT-84, the payment account identifier, in the scheme payee_account_scheme names.';
comment on column ekwo.document_header.payee_bank_scheme is
  'The scheme of payee_bank_identifier, the bank of the company''s default account (BT-86 when it is bic).';
comment on column ekwo.document_header.payee_bank_identifier is
  'The bank of the company''s default account, in the scheme payee_bank_scheme names.';
