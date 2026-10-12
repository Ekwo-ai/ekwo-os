-- Ekwo OS — what a proven pack was proven on, in the database that applies it.
--
-- `20261011192741` let a pack say it is `proven`, and `certification.evidence`
-- in its manifest says on what: one entry per scope, with the kind of filing,
-- the financial year, the result and one plain sentence. The status reached
-- `country_packs`; the evidence stopped at the seed header and at
-- `ekwo pack describe`, which reads a clone of the repository. An application
-- or an agent that reads the installation saw the word `proven` and nothing
-- that said which statements were reproduced and which were not tested — and
-- what a proof did not cover is half of what it says.
--
-- `country_packs.evidence` brings it here, in the order the pack declares it.
--
-- Additive: one column, defaulting to an empty list, no backfill. The value is
-- the pack's, and only the seed of a pack that carries evidence writes it, so
-- the seeds of every other country keep running on a schema from before this
-- file. Writing the evidence of a country in a migration would put a country
-- back into the core.

alter table country_packs
  add column if not exists evidence jsonb not null default '[]'::jsonb;

comment on column country_packs.evidence is
  'What a proven pack was proven on, in the pack''s own order: [{scope, result, fiscal_year, filing, summary, checked_on}]. `result` is one of reproduced, partly_reproduced, not_tested. An entry names the kind of filing and never the company. Written by the generated seed of a pack that carries evidence; empty otherwise.';

-- No object is created and no function is added, so there is nothing to grant
-- and nothing to revoke: a column added to a table is reachable by whoever
-- could already select that table, under the policies it already has.
