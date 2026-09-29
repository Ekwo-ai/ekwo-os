-- Ekwo module `assets` — its tables leave with the company.
--
-- The socle writes an archive of one company from a registry of tables, and
-- refuses to write one while a table that belongs to a company is
-- unclassified. A module answers for its own through `<schema>.archive_tables()`,
-- looked up by the socle the way `can_disable()` is — a function in this schema
-- and not rows in a table of the socle, because this migration may be applied
-- on a socle that does not have that table yet.
--
-- All three tables travel. The register and the schedule are the company's,
-- and a depreciation line points at the entry it posted: left behind, the
-- ledger would arrive with entries tagged `assets` that nothing explains.
-- `category_templates` and `country_rules` are reference data of the
-- installation and belong to no company.
--
-- `load_order` is relative to this module; the socle places every module after
-- its own tables.

create or replace function assets.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('assets'::text,       'exported'::text, null::text, null::text, null::text, 1),
    ('depreciation_lines', 'exported',       null,       null,       null,       2),
    ('disposals',          'exported',       null,       null,       null,       3);
$$;

comment on function assets.archive_tables() is
  'What an archive of one company does with each table of this module. Read by `public.company_archive_tables()`.';

revoke execute on function assets.archive_tables() from public, anon;
grant execute on function assets.archive_tables() to authenticated, service_role;
