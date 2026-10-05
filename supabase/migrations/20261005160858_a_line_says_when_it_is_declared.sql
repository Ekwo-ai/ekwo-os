-- Ekwo OS — a ledger line says on which day it counts for a return.
--
-- A tax return asks one question of the ledger: which lines fall inside this
-- period? Until now the answer was worked out at every read, as
-- `coalesce(l.tax_point_date, e.entry_date) between …` — the tax point of the
-- line where the posting engine worked one out, the date of its entry
-- otherwise. That expression spans two tables, so no index can serve it, and
-- a return of one quarter read every declaration line the company had ever
-- written before setting aside those outside the quarter. `docs/load.md`
-- measured it: 86 000 lines read for the ten boxes of one quarter, and a cost
-- that grows with every year kept.
--
-- This file stores the answer on the line, as `entry_lines.declared_on`. The
-- rule does not change by a day: the column holds what the expression above
-- answers today, and `declared_on_of()` is that expression, written once.
--
-- **Who writes it.** Nobody types it. `entry_lines_set_declared_on` derives it
-- before every insert, and before every update that touches what it is
-- derived from — the tax point, the entry the line belongs to, or the column
-- itself, so a value written by hand on a draft is replaced by the rule's.
-- On a posted line `entry_lines_guard_posted` answers first and refuses the
-- change by name, as for every other column: triggers of one table fire in
-- the order of their names, and this one is named to come after the guards.
-- Every path that writes a line is covered by the same trigger: `post_document()`,
-- `settle_cash_basis_tax()` (which writes the day a waiting tax falls due as
-- the tax point of its transfer, and so as its `declared_on`), `post_payment()`,
-- `reverse_entry()`, `post_module_entry()`, an entry keyed by hand, books
-- taken over by `import_books()`. A trigger rather than a column written in
-- each of those functions, because a writer added tomorrow is covered without
-- anybody remembering to.
--
-- The entry's date is the other half of the rule, and it can move while the
-- entry is a draft. `entries_declared_on_follows` carries such a move to the
-- lines of the entry. A posted entry keeps its date, by `entries_guard_posted()`.
--
-- **On every line.** The column is filled on every ledger line, a line that
-- names no declaration box included: `filing_tax_movements()` reads the tax
-- lines of a period whether or not they carry a box, and the same day answers
-- for both. `20261005160859` fills the lines already written and makes the
-- column `not null`, which is the guarantee that a line carrying a
-- `declaration_box` always has one.
--
-- `import_company()` switches the triggers of the tables it fills off while
-- it loads, so it brings `declared_on` with the archive and checks it against
-- the rule afterwards (`20261005160900`).

alter table entry_lines add column declared_on date;

comment on column entry_lines.declared_on is
  'The day this line counts for a tax return: its tax_point_date where the posting engine worked one out, the date of its entry otherwise (declared_on_of()). Written by the trigger entry_lines_set_declared_on on every insert and on every change of what it derives from — never typed: a value written by hand on a draft is replaced by the rule''s, and on a posted line refused by entry_lines_guard_posted. The period of a return is read on this column, through declared_lines().';

-- ---------------------------------------------------------------------------
-- The rule, once
-- ---------------------------------------------------------------------------

create or replace function declared_on_of(p_tax_point_date date, p_entry_date date)
returns date
language sql
immutable
as $$
  select coalesce(p_tax_point_date, p_entry_date);
$$;

comment on function declared_on_of(date, date) is
  'The day a ledger line counts for a tax return: the tax point the posting engine wrote on the line, or the date of its entry where the line carries none. The one statement of that rule: the trigger that writes entry_lines.declared_on, its backfill and import_company() all call it.';

revoke execute on function declared_on_of(date, date) from public, anon;
grant execute on function declared_on_of(date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Written on the line
-- ---------------------------------------------------------------------------

create or replace function entry_lines_set_declared_on()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_entry_date date;
begin
  select e.entry_date into v_entry_date from entries e where e.id = new.entry_id;
  -- No entry: the foreign key refuses the row, by its own name.
  new.declared_on := declared_on_of(new.tax_point_date, v_entry_date);
  return new;
end;
$$;

comment on function entry_lines_set_declared_on() is
  'Writes entry_lines.declared_on from the rule of declared_on_of(), before every insert of a line and every update of its tax point, of its entry or of the column itself. Definer, so the date of the entry is read whoever the caller is.';

create trigger entry_lines_set_declared_on
  before insert or update of tax_point_date, entry_id, declared_on on entry_lines
  for each row execute function entry_lines_set_declared_on();

revoke execute on function entry_lines_set_declared_on() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- And moved with the date of a draft
-- ---------------------------------------------------------------------------

create or replace function entries_declared_on_follows()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update entry_lines l
     set declared_on = declared_on_of(l.tax_point_date, new.entry_date)
   where l.entry_id = new.id;
  return null;
end;
$$;

comment on function entries_declared_on_follows() is
  'Carries a new date of an entry to the declared_on of its lines that have no tax point of their own. Only a draft changes its date: a posted entry keeps it, by entries_guard_posted().';

create trigger entries_declared_on_follows
  after update of entry_date on entries
  for each row
  when (old.entry_date is distinct from new.entry_date)
  execute function entries_declared_on_follows();

revoke execute on function entries_declared_on_follows() from public, anon, authenticated, service_role;

-- Rule 6 of supabase/migrations/README.md: a function created here comes out
-- closed to PUBLIC; the grants above, by name, are what opens it.
revoke execute on all functions in schema public from public;
