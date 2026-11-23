-- Ekwo — the `crm` module: the amount of a deal holds the decimals of its currency.
--
-- The socle made its money columns bare `numeric` in
-- `20261123203000_an_amount_holds_the_decimals_of_its_currency.sql`: the
-- decimals of an amount are those of its currency, decided by
-- `ekwo.round_amount()`, and no longer cut to two by the type of a column.
-- A deal names its currency, and its amount now keeps the decimals that
-- currency has: three for a dinar, none for a yen.
--
-- No view, trigger or generated column reads the column, so the change is the
-- type alone, and rewrites nothing on disk.

alter table crm.deals alter column amount type numeric;
