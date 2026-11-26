-- Ekwo OS — the installation names the currency its rates are against.
--
-- An instance-wide row of `currency_rates` (no `company_id`) has always been
-- "units of the currency for one unit of the instance reference currency",
-- and no column named that currency (decision 0097). Nothing wrote those rows
-- through the API and nothing read them, so the gap cost nothing. A published
-- series now fills them (`ekwo rates fetch`), and a series quotes against its
-- own base: turning its quotes into rows needs the currency the rows are in,
-- written down once, where the rows of every run can be checked against it.
--
-- One nullable column on the instance row. Null on every existing
-- installation: nothing is guessed — not from the country of the first
-- company, which says nothing about the installation (20260922115309), and
-- not from a pack. The operator names it the first time they fetch rates.
--
-- Additive: no reader changes, no data is rewritten, the oldest schema a
-- client reads stays where it is.

alter table ekwo.instance
  add column reference_currency char(3) references ekwo.currencies(code);

comment on column ekwo.instance.reference_currency is
  'The currency the instance-wide rows of currency_rates (company_id null) are against: their rate is units of currency_code for one unit of this currency. Null until the operator names it, the first time `ekwo rates fetch` runs; changing it once rows exist would leave those rows in a base nothing names, so the command refuses to.';

comment on column ekwo.currency_rates.rate is
  'Units of currency_code for one unit of the base the row is in: with company_id set, that company''s currency; without, instance.reference_currency.';
comment on column ekwo.currency_rates.source is
  'Where the rate comes from: the name of a published series (ecb, written by `ekwo rates fetch`), or free text for a rate typed by hand.';
