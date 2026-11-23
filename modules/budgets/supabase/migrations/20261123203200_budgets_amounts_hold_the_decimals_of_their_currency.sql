-- Ekwo — the `budgets` module: its amounts hold the decimals of their currency.
--
-- The socle made its money columns bare `numeric` in
-- `20261123203000_an_amount_holds_the_decimals_of_its_currency.sql`: the
-- decimals of an amount are those of its currency, decided by
-- `ekwo.round_amount()`, and no longer cut to two by the type of a column.
-- A budget line is compared with the ledger, so it holds what the ledger
-- holds: a three-decimal currency budgets to the thousandth.
--
-- No view, trigger or generated column reads the column, so the change is the
-- type alone, and rewrites nothing on disk.

alter table budgets.lines alter column amount type numeric;
