-- Ekwo — the `contracts` module: a value finer than its currency is refused.
--
-- The socle refuses an amount finer than its currency where a caller writes
-- it as it is (`20261124090000_an_amount_finer_than_its_currency_is_refused.sql`):
-- `ekwo.assert_amount_of_currency()` compares the amount with
-- `ekwo.round_amount()` of itself, in the currency `ekwo.rounding_of()`
-- names, and raises `amount_finer_than_currency` — it never rounds. This
-- module attaches the socle's trigger to the amounts it takes from a caller:
-- the total value of a contract, in the currency the contract names.
--
-- An update judges only the amounts it changes, and no row written before is
-- read: the trigger is created and nothing is validated retroactively.

do $$
begin
  if to_regprocedure('ekwo.amounts_of_currency_guard()') is null then
    raise exception 'socle_too_old: the contracts module needs socle migration 20261124090000 (amounts_of_currency_guard). Run ekwo migrate first.';
  end if;
end;
$$;

create or replace trigger contracts_amounts_of_currency
  after insert or update on contracts.contracts
  for each row execute function ekwo.amounts_of_currency_guard(
    'company_id', 'total_value:currency_code');
