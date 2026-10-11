-- Ekwo OS — a ledger line names a declaration box its tax posting writes.
--
-- Reported by Pieterjan Muller on 11 October 2026 (issue #88).
--
-- `entry_lines.declaration_box` and `box_amount` are what `vat_return()` sums.
-- `post_document()` copies them from the tax posting that produced the line,
-- and `settle_cash_basis_tax()` from the posting a waiting tax falls due on.
-- But a draft line is written under `entries.write` (`20260913083216`), and
-- nothing tied the box to the tax: a member could key an entry by hand with
-- any box and any amount, with no tax at all, and `post_entry()` posted it as
-- it was. `vat_return()` then kept the line in the box it named — a line with
-- no posting behind it is read as "on this form, in the box it says" — so a
-- hand-written figure landed in a declaration without a tax rule ever being
-- applied to it.
--
-- **The rule.** `entry_lines_box_from_posting()`, before every insert of a
-- line and every update of its box, its tax, its `tax_line` or its
-- `posting_type`: a line that names a box names a tax, and a posting of that
-- tax writes that box on that side — a `tax` posting for a tax line, a `base`
-- or `tax_on_base` posting otherwise, and the line's own `posting_type` when
-- it states one. Anything else is `declaration_box_without_posting`.
--
-- Every writer of the schema already writes such a line, because each copies
-- the box from the posting it is reading: `post_document()`,
-- `settle_cash_basis_tax()`. One writer copies it from another line instead:
-- `reverse_entry()` mirrors a posted entry, box included, and the posting may
-- have changed since — a pack upgrade renumbers a box — so the mirror of a
-- line already in the ledger is accepted for the box that line carries. A box
-- that was right when it was posted is undone in the box it was posted in.
--
-- Nothing else writes a box: `post_payment()`, the year-end functions,
-- `post_module_entry()`, `import_books()` and the demo company write lines
-- without one. `import_company()` switches the user triggers of the tables it
-- fills off for the load, and restores a ledger as it was exported. The
-- installer passes, as it passes every guard of this schema: it owns the
-- table and could switch the trigger off.
--
-- **What is not done.** The box is not derived for a line keyed by hand that
-- names a tax and no box: the amount a box receives carries the sign of the
-- form and the share of `box_factor_percent`, which depend on the kind of
-- document a hand-written entry does not have. Such a line stays out of the
-- return, as it always did. And the lines already in a ledger are not
-- rewritten: a posted entry does not move, and a box written by hand before
-- this file is still read where it was written.

create or replace function entry_lines_box_from_posting()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.declaration_box is null or is_installer() then
    return new;
  end if;
  if tg_op = 'UPDATE'
     and new.declaration_box is not distinct from old.declaration_box
     and new.tax_id is not distinct from old.tax_id
     and new.tax_line is not distinct from old.tax_line
     and new.posting_type is not distinct from old.posting_type then
    return new;
  end if;

  -- A posting of the line's tax that writes this box on this side.
  if new.tax_id is not null and exists (
       select 1 from tax_postings tp
        where tp.tax_id = new.tax_id
          and tp.company_id = new.company_id
          and tp.declaration_box = new.declaration_box
          and case when new.tax_line then tp.posting_type = 'tax'
                   else tp.posting_type in ('base', 'tax_on_base') end
          and (new.posting_type is null or tp.posting_type = new.posting_type)) then
    return new;
  end if;

  -- The mirror of a line already in the ledger, in the box that line carries.
  if exists (
       select 1 from entries r
         join entry_lines o on o.entry_id = r.reversed_entry_id and o.company_id = r.company_id
        where r.id = new.entry_id
          and r.company_id = new.company_id
          and o.tax_id is not distinct from new.tax_id
          and o.tax_line is not distinct from new.tax_line
          and o.declaration_box = new.declaration_box) then
    return new;
  end if;

  raise exception 'declaration_box_without_posting: line % names box %, and %. A box is written by the tax posting that produces the line.',
    new.sequence, new.declaration_box,
    case when new.tax_id is null then 'no tax'
         else 'no posting of its tax writes that box on the ' || case when new.tax_line then 'tax' else 'base' end || ' side' end
    using errcode = '23514';
end;
$$;

comment on function entry_lines_box_from_posting() is
  'Refuses a ledger line whose declaration box is not one its tax posting writes: a line naming a box names a tax, and a posting of that tax writes that box — a tax posting for a tax line, a base or tax_on_base posting otherwise, of the line''s own posting_type when it states one — or the line mirrors, in a reversal, a line of the entry it reverses that carries the same box. declaration_box_without_posting otherwise. Fires on insert and on a change of the box, the tax, tax_line or posting_type; the installer passes.';

create trigger entry_lines_box_from_posting
  before insert or update of declaration_box, tax_id, tax_line, posting_type on entry_lines
  for each row execute function entry_lines_box_from_posting();

-- ---------------------------------------------------------------------------
-- Grants
--
-- A trigger body, callable by nobody.
-- ---------------------------------------------------------------------------

revoke execute on function entry_lines_box_from_posting() from public, anon, authenticated, service_role;
