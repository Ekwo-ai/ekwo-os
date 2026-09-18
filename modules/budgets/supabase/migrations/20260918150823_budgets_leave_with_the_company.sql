-- Ekwo module `budgets` — its tables leave with the company.
--
-- The socle writes an archive of one company from a registry of tables, and
-- refuses to write one while a table that belongs to a company is
-- unclassified. A module answers for its own through `<schema>.archive_tables()`,
-- looked up by the socle the way `can_disable()` is — a function in this schema
-- and not rows in a table of the socle, because this migration may be applied
-- on a socle that does not have that table yet.
--
-- A budget is a plan the company wrote against its own chart and its own
-- financial years. It posts nothing, and it is still the company's.
--
-- `load_order` is relative to this module; the socle places every module after
-- its own tables.

create or replace function budgets.archive_tables()
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
    ('budgets'::text, 'exported'::text, null::text, null::text, null::text, 1),
    ('lines',         'exported',       null,       null,       null,       2);
$$;

comment on function budgets.archive_tables() is
  'What an archive of one company does with each table of this module. Read by `public.company_archive_tables()`.';

revoke execute on function budgets.archive_tables() from public, anon;
grant execute on function budgets.archive_tables() to authenticated, service_role;
