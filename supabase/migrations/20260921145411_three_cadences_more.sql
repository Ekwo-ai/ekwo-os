-- Ekwo OS — three cadences more: two months, four months, six months.
--
-- `declaration_period` said it would grow this way: "a country that files on
-- another adds a value here rather than a word of its own somewhere else". The
-- first pack outside the three cadences of Europe's periodic returns was
-- Ireland, whose Act makes the taxable period two months for everybody; the
-- four-monthly and six-monthly periods are the next ones a small filer is
-- authorised onto there and elsewhere. Each is a whole number of months,
-- anchored on the first of January like the three before them.
--
-- Its own file: a new enum value cannot be used in the transaction that added
-- it, and the next migration writes the functions that read them. The values
-- are placed in the order of their length, so that sorting on the type reads
-- from the shortest cadence to the longest, as it did with three.

alter type declaration_period add value if not exists 'bimonth' after 'month';
alter type declaration_period add value if not exists 'four_month' after 'quarter';
alter type declaration_period add value if not exists 'half_year' after 'four_month';

comment on type declaration_period is
  'How often a declaration is filed: month, bimonth, quarter, four_month, half_year, year. Each is a whole number of months anchored on 1 January — a bimonth is January–February, March–April and so on. A country that files on another adds a value here rather than a word of its own somewhere else.';
