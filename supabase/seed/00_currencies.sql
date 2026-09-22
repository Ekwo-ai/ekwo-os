-- Ekwo OS — currencies. ISO 4217, the handful a European ledger meets, and the
-- five the seventeen member States of OHADA keep their books in.
--
-- The code and the decimals are those of ISO 4217 list one, as SIX
-- Financial Information publishes it on behalf of the maintenance agency
-- (https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml,
-- edition of 17 September 2026). Both CFA francs, the Comorian franc and the
-- Guinean franc have no minor unit there; the Congolese franc has two.

insert into currencies (code, name, symbol, decimal_places) values
  ('EUR', 'Euro',                 E'€', 2),
  ('USD', 'US dollar',            '$',       2),
  ('GBP', 'Pound sterling',       E'£', 2),
  ('CHF', 'Swiss franc',          'CHF',     2),
  ('SEK', 'Swedish krona',        'kr',      2),
  ('DKK', 'Danish krone',         'kr',      2),
  ('NOK', 'Norwegian krone',      'kr',      2),
  ('PLN', 'Polish zloty',         E'z\u0142', 2),
  ('CZK', 'Czech koruna',         E'Kč', 2),
  ('CAD', 'Canadian dollar',      '$',       2),
  ('JPY', 'Japanese yen',         E'¥', 0),
  ('XOF', 'CFA franc BCEAO',      'F CFA',   0),
  ('MXN', 'Mexican peso',         '$',       2),
  ('XAF', 'CFA franc BEAC',       'F CFA',   0),
  ('KMF', 'Comorian franc',       'CF',      0),
  ('GNF', 'Guinean franc',        'FG',      0),
  ('CDF', 'Congolese franc',      'FC',      2),
  ('AUD', 'Australian dollar',    '$',       2),
  ('SGD', 'Singapore dollar',     '$',       2),
  ('NZD', 'New Zealand dollar',   '$',       2),
  ('HKD', 'Hong Kong dollar',     E'HK$',    2),
  ('TWD', 'New Taiwan dollar',    E'NT$',    2),
  ('KRW', 'South Korean won',     E'₩',      0),
  ('AED', 'UAE dirham',           E'د.إ', 2),
  ('THB', 'Thai baht',            E'฿', 2),
  ('VND', 'Vietnamese dong',      E'₫', 0)
on conflict (code) do nothing;
