-- Ekwo OS — a bank account keeps the profile of its CSV statements.
--
-- A statement exported as CSV says nothing about its own lay-out: which
-- column is the date, the amount, the balance, how a date and a number are
-- written. `@ekwo-ai/csv-statement` reads it with a profile that says so, and
-- until now every caller had to give that profile at every import, so each
-- surface kept it where it could — a file beside the exports, the memory of
-- one person in one browser.
--
-- The lay-out belongs to the bank's export, so it belongs to the account the
-- file is of. `bank_accounts.statement_profile` holds it: the
-- `CsvStatementProfile` of `@ekwo-ai/csv-statement`, as JSON, as that package
-- describes it. The core writes it when an import given a profile succeeds,
-- and reads it when a CSV is imported without one; a person or an agent may
-- also set or clear it on the account. Null is an account whose CSV lay-out
-- nobody has described yet, which is every account until somebody does.
--
-- Additive: one nullable column, no default, no check — the reader checks a
-- profile when it reads a file with it. The policies of `bank_accounts` apply
-- to it as they apply to the rest of the row.

alter table bank_accounts
  add column if not exists statement_profile jsonb;

comment on column bank_accounts.statement_profile is
  'How the CSV statements of this account are laid out: the CsvStatementProfile of @ekwo-ai/csv-statement (delimiter, date format, decimal mark, which column says what). Written by the core when a CSV import given a profile succeeds, or set on the account; read when a CSV is imported without one. Optional: null until somebody describes the lay-out, and never used by the other statement formats.';
