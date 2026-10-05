-- Ekwo OS — the declared day of the lines already written.
--
-- `20261005160858` added `entry_lines.declared_on` and the trigger that writes
-- it on every line from now on. This file fills it on every line written
-- before, with the same rule — `declared_on_of(tax_point_date, entry_date)` —
-- then makes the column `not null` and builds the index a return reads.
--
-- **Most of these lines belong to posted entries**, and `entry_lines_guard_posted`
-- refuses any change to such a line but the matching. A backfill is the one
-- writer it has to let through, so the guard is lifted here, by its name, for
-- the one statement that writes the column, and put back in the same
-- transaction: no other session sees the table without it. Lifted with it,
-- also by name:
--
--   * `entry_lines_set_updated_at` — a derived column filled in is not an
--     edit of the line, and `updated_at` keeps the day somebody last wrote it;
--   * `entry_lines_refresh_totals` — the totals of an entry do not move when
--     a date is added to its lines, and recomputing them line by line is the
--     slow part of an update of the whole table;
--   * `entry_lines_set_declared_on` — the statement writes the rule itself, once
--     per line, from the entry it has already joined.
--
-- `entry_lines_guard_period` stays on and has nothing to say: it guards the
-- amounts, the accounts and the boxes of a line in a locked period, and none
-- of them moves.
--
-- The rule is the one every return already applied, so a return, a frozen
-- filing and `filing_drift()` answer after this file exactly what they
-- answered before it. `tests/declared_on.test.ts` books the golden year of
-- every pack on the schema as it was, upgrades it with these files, and
-- compares to the cent.

alter table entry_lines disable trigger entry_lines_guard_posted;
alter table entry_lines disable trigger entry_lines_set_updated_at;
alter table entry_lines disable trigger entry_lines_refresh_totals;
alter table entry_lines disable trigger entry_lines_set_declared_on;

update entry_lines l
   set declared_on = declared_on_of(l.tax_point_date, e.entry_date)
  from entries e
 where e.id = l.entry_id
   and l.declared_on is distinct from declared_on_of(l.tax_point_date, e.entry_date);

alter table entry_lines enable trigger entry_lines_guard_posted;
alter table entry_lines enable trigger entry_lines_set_updated_at;
alter table entry_lines enable trigger entry_lines_refresh_totals;
alter table entry_lines enable trigger entry_lines_set_declared_on;

alter table entry_lines alter column declared_on set not null;

-- The period of a return, read through an index. Partial: a return reads the
-- lines that name a box, and those are a fraction of the ledger.
create index entry_lines_declared_on_idx
  on entry_lines (company_id, declared_on)
  where declaration_box is not null;

comment on index entry_lines_declared_on_idx is
  'The lines of one company that name a declaration box, by the day they count for a return: how vat_return() and filings_touched_since() reach one period without reading the history of the company.';
