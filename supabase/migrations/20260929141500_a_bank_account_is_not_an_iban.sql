-- Ekwo OS — a bank account is not an IBAN.
--
-- `bank_accounts.iban` names the European answer to a question every country
-- answers differently. The United States identifies an account by an ABA
-- routing number and an account number, the United Kingdom by a sort code and
-- an account number, Australia by a BSB, India by an IFSC, Mexico by a CLABE,
-- Japan by a bank code, a branch code and an account number. An installation
-- that asks its administrator for an IBAN first asks half the world for
-- something it does not have.
-- `20260917090000_a_counterparty_that_learns.sql` said so and left the columns
-- for somebody's next migration. This is that migration, and it is additive:
--
-- * `country_defaults.bank_account_scheme` — the scheme a country's banks use,
--   declared by the pack (`bank.account_scheme` in `pack.json`). Null where a
--   pack says nothing, and a null is read as a free-text account number, never
--   as an IBAN. The vocabulary is the registry of `@ekwo-ai/core`
--   (`BANK_ACCOUNT_SCHEMES`); it is not a check constraint here, because a
--   scheme is added by a pack and a reader, not by a migration.
-- * `bank_accounts.account_scheme` and `bank_accounts.account_identifier` —
--   which scheme an account is written in, and the identifier itself in the
--   canonical form that scheme gives it (its parts, in order, one space
--   between them). The identifier is the natural key of an account in a
--   company.
--
-- `bank_accounts.iban` stays, and stays true: it holds the identifier when the
-- scheme is `iban` and is null otherwise. Everything that reads it today keeps
-- working; an installation that upgrades has every existing account backfilled
-- as an IBAN, which is what it was.

alter table country_defaults
  add column if not exists bank_account_scheme text;

comment on column country_defaults.bank_account_scheme is
  'How a bank of this country identifies an account: iban, aba-routing-account, sort-code-account, bsb-account, ifsc-account, clabe, zengin, transit-institution-account. From the pack. Null where the pack declares none, which clients read as a free-text account number and never as an IBAN.';

alter table bank_accounts
  add column if not exists account_scheme     text,
  add column if not exists account_identifier text;

comment on column bank_accounts.account_scheme is
  'The scheme account_identifier is written in, as the country pack names it. Null on a free-text account number.';
comment on column bank_accounts.account_identifier is
  'What identifies the account at its bank, in the canonical form of its scheme: the parts in order, one space between them. An IBAN is one such identifier and has its own column too, kept for what already reads it.';

-- Every account that exists was entered as an IBAN.
update bank_accounts
   set account_scheme     = 'iban',
       account_identifier = iban
 where iban is not null
   and account_identifier is null;

create unique index if not exists bank_accounts_company_identifier_idx
  on bank_accounts (company_id, account_identifier) where account_identifier is not null;

-- ---------------------------------------------------------------------------
-- The two columns say one thing
--
-- A client that still writes `iban` gets the new columns filled; a client that
-- writes an identifier in the `iban` scheme gets `iban` filled. Nothing else is
-- derived: a routing number never lands in a column called iban.
-- ---------------------------------------------------------------------------

create or replace function bank_accounts_read_identifier()
returns trigger
language plpgsql
as $$
begin
  if new.iban is not null and new.account_identifier is null then
    new.account_identifier := new.iban;
    new.account_scheme := coalesce(new.account_scheme, 'iban');
  end if;
  if new.account_scheme = 'iban' and new.iban is null then
    new.iban := new.account_identifier;
  end if;
  if new.account_scheme is distinct from 'iban' and new.iban is not null
     and new.account_identifier is distinct from new.iban then
    raise exception 'bank_account_scheme: iban is set and account_scheme is %, so the two disagree.',
      coalesce(new.account_scheme, 'null');
  end if;
  return new;
end;
$$;

create trigger bank_accounts_read_identifier
  before insert or update of iban, account_scheme, account_identifier on bank_accounts
  for each row execute function bank_accounts_read_identifier();

comment on function bank_accounts_read_identifier() is
  'Keeps iban, account_scheme and account_identifier saying one thing: an IBAN fills the identifier, an identifier of the iban scheme fills iban, and no other scheme ever writes iban.';

revoke execute on function bank_accounts_read_identifier() from public;

-- ---------------------------------------------------------------------------
-- What a sales document asks a customer to pay into
--
-- `documents.payee_iban` cites BT-84 of EN 16931, the *payment account
-- identifier*, which is not an IBAN. A company whose account is a routing
-- number and an account number now fills it too.
-- ---------------------------------------------------------------------------

create or replace function documents_default_payee_iban()
returns trigger
language plpgsql
as $$
declare
  v_payee text;
begin
  if new.payee_iban is null and new.doc_type::text like 'sale%' then
    select coalesce(b.iban, b.account_identifier) into v_payee
      from companies c
      join bank_accounts b on b.id = c.default_bank_account_id
     where c.id = new.company_id;
    new.payee_iban := v_payee;
  end if;
  return new;
end;
$$;

comment on function documents_default_payee_iban() is
  'A sales document with no payee account takes the company''s default bank account, whatever scheme it is written in. A purchase document never does: the payee there is somebody else.';
