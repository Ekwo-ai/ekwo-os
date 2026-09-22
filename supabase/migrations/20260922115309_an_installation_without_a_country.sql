-- Ekwo OS — an installation is not in a country; its companies are.
--
-- `instance.country` was `not null` because the installation used to be set up
-- *for* one country: `ekwo init` created the first company in the same run and
-- wrote its country on the instance row. It never meant more than that. The
-- seeds of every pack are loaded whatever it says, `create_company()` takes a
-- country per company, and nothing in the schema reads the column — a firm
-- keeping the books of companies in two countries has had one installation
-- for both since the first release.
--
-- `ekwo init --no-company` installs the schema, the packs and the first
-- administrator and creates no company, so there is no country to write down,
-- and inventing one would be a default nobody chose. The column becomes
-- nullable. The format check stays: a country, when there is one, is still two
-- capital letters, and a null passes a check by definition.
--
-- `init_instance()` is unchanged: `upper(null)` is null, and the row now takes
-- it. An installation set up with a company keeps the country of that company,
-- as before.

alter table instance alter column country drop not null;

comment on column instance.country is
  'The country of the first company, when `ekwo init` created one with the installation. Null for an installation set up without a company. Informative: every company carries its own country, and nothing reads this one to decide anything.';
