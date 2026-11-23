-- Ekwo — the `contracts` module: the value of a contract holds the decimals of its currency.
--
-- The socle made its money columns bare `numeric` in
-- `20261123203000_an_amount_holds_the_decimals_of_its_currency.sql`: the
-- decimals of an amount are those of its currency, decided by
-- `ekwo.round_amount()`, and no longer cut to two by the type of a column.
-- The value a contract states follows: a contract in a three-decimal
-- currency keeps its thousandths.
--
-- No view, trigger or generated column reads the column, so the change is the
-- type alone, and rewrites nothing on disk.

alter table contracts.contracts alter column total_value type numeric;
