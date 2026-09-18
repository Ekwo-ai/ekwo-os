-- Ekwo OS — a posted entry is immutable, in an open period too.
--
-- The schema has said so from the first day, in comments, in the description
-- of the audit trail — "a posted entry is immutable and is corrected by a
-- reversal, so what is recorded is the act of posting and never the lines" —
-- and in every design decision that leans on it. What enforced it was
-- `entries_guard_period`, and that guards a *locked* period. In an open one,
-- established under row level security as a member holding `entries.write`:
--
--   * the lines of a posted entry could be deleted, all of them;
--   * the entry itself could be deleted;
--   * its state could be set back to `draft`, after which it is an ordinary
--     draft and anything goes;
--   * an amount on its own was refused — by `entries_posted_is_balanced`, a
--     check that the entry still balances, which two amounts changed together
--     satisfy.
--
-- The audit trail records the posting and deliberately not the lines, on the
-- ground that they cannot change. So a change to them was not only possible,
-- it left no trace.
--
-- Same shape as `20260918161204` for the document, for the same reason and
-- with the same absence of an exemption. Once an entry has left `draft`:
--
--   * it is not deleted and its state does not change. A posted entry is
--     undone by a reversal — a second entry naming it in `reversed_entry_id` —
--     which is what `reopen_fiscal_year()` already does;
--   * no column of it moves but `updated_at`. `total_debit` and `total_credit`
--     are derived from lines that no longer move;
--   * its lines take no insert and no delete, and keep every column but the
--     two the matching writes — `matching_number` and `matched_amount` — which
--     is the exception `entry_lines_guard_period` has made for a locked period
--     since the first migration: matching is not a change to the accounts.
--
-- Closed lists again: a column added later is frozen the day it is added.
--
-- **Every path of the schema that writes an entry was read before this was
-- written**, because a guard nobody is exempt from has to be one nobody needs
-- an exemption from. They all do the same thing: insert a `draft`, insert its
-- lines, call `post_entry()`.
--
--   * `post_document()`, `post_payment()`, `post_module_entry()` — which is how
--     every module reaches the ledger —, `opening_balance()`,
--     `settle_cash_basis_tax()`, `settle_filing()`: a draft, its lines,
--     `post_entry()`. Nothing is touched afterwards.
--   * `close_fiscal_year()`: the same, twice; its one `delete from entries` is
--     of the closing entry it has just created as a draft and found nothing to
--     put in.
--   * `reconcile()` books an exchange difference as a new entry, and
--     `unreconcile()` undoes it with a **mirror** naming it in
--     `reversed_entry_id` — it never deletes or edits the first.
--     `reopen_fiscal_year()` does the same for the entries of a close.
--   * `reconciliations_refresh_lines()` writes `matched_amount` and
--     `matching_number` on posted lines: the closed list below.
--   * `entries_refresh_totals()` rewrote `total_debit` and `total_credit` on
--     every write of a line, whatever the state. The lines of a posted entry
--     no longer move, so it now acts on drafts.
--
-- So the reversal is already how this schema undoes an entry, everywhere it
-- does; what was missing is that nothing made it the *only* way.
--
-- **Nobody is born posted**, as for a document and for the same reason: an
-- entry inserted with a state that is not `draft`, or a line inserted under
-- one, is `entry_born_posted` for everybody, the installer included. Books
-- kept elsewhere arrive through `import_company()`, which switches the
-- triggers of the tables it fills off by name for the time of the load and
-- needs no exemption here. What it loads is still judged by what no switch
-- turns off — `entries_posted_is_balanced`, `entries_posted_has_number` — and
-- is frozen afterwards like everything else. The period guards are triggers
-- and are off during a load with the rest: an archive brings closed years with
-- it, and whether a loaded entry may sit in one is the import's question.
--
-- **The guards are `security definer`**, for the reason found on the document:
-- asked under the caller's row level security, "is the company still there?"
-- is answered *no row* by whoever cannot read `companies`, and that answer let
-- a delete through. Unlike the guard of a document line they are not named
-- to fire first: the older guards of these two tables — who may post, what a
-- module tag may become, which period is locked — refuse more precisely what
-- they refuse, and keep answering first where they do.
--
-- `draft` to `posted` is `post_entry()`'s one statement on a row that is still
-- a draft, and passes untouched. The cascade of a company being deleted passes
-- for the reason it does on a document: the company's row is already gone.
-- The period guards stay exactly as they are and keep their own job — a draft
-- dated in a locked period is theirs to refuse, not this file's.

create or replace function entries_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_moved text[];
begin
  if tg_op = 'INSERT' then
    if new.state <> 'draft' then
      raise exception 'entry_born_posted: an entry is written as a draft and posted by post_entry(). One that is already % arrives with a company being loaded, by import_company(), and in no other way.',
        new.state
        using errcode = '55006';
    end if;
    return new;
  end if;

  if old.state = 'draft' then
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'entry_posted: entry % is % and cannot be deleted. A posted entry is undone by a reversal that names it.',
      coalesce(old.number, old.id::text), old.state
      using errcode = '55006';
  end if;

  if new.state is distinct from old.state then
    raise exception 'entry_posted: entry % is % and stays so. A posted entry is undone by a reversal that names it, never by changing its state to %.',
      coalesce(old.number, old.id::text), old.state, new.state
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     -- `is_balanced` is generated, and not yet computed in a `before` trigger.
     and n.key not in ('updated_at', 'is_balanced');

  if v_moved is not null then
    raise exception 'entry_posted: entry % was posted and keeps its % (%). A posted entry is undone by a reversal that names it.',
      coalesce(old.number, old.id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function entries_guard_posted() is
  'Once an entry has left draft: it is not deleted, its state does not change and no column moves. Refuses entry_posted, by name, to everybody, and entry_born_posted to whoever inserts one that is already posted: that arrives only with a company loaded by import_company(). The period guards keep their own job.';

create trigger entries_guard_posted
  before insert or update or delete on entries
  for each row execute function entries_guard_posted();

revoke execute on function entries_guard_posted() from public, anon, authenticated, service_role;

create or replace function entry_lines_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  -- What the matching writes, and nothing else. `balance` is generated from
  -- two columns that are frozen, and is not yet computed when a `before`
  -- trigger reads the new row.
  c_still_moves constant text[] := array['matching_number', 'matched_amount', 'balance', 'updated_at'];
  v_state  entry_state;
  v_number text;
  v_moved  text[];
begin
  -- The entry the line is leaving, where it is leaving one: a line does not
  -- walk out of a posted entry into a draft.
  select e.state, e.number into v_state, v_number
    from entries e where e.id = coalesce(old.entry_id, new.entry_id);
  if found and v_state = 'draft' and tg_op = 'UPDATE' and new.entry_id is distinct from old.entry_id then
    select e.state, e.number into v_state, v_number from entries e where e.id = new.entry_id;
  end if;

  if not found or v_state = 'draft' then
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'entry_posted: line % of entry % was posted and cannot be deleted. A posted entry is undone by a reversal that names it.',
      old.sequence, coalesce(v_number, old.entry_id::text)
      using errcode = '55006';
  end if;

  if tg_op = 'INSERT' then
    raise exception 'entry_posted: entry % was posted with the lines it has, and takes no other. A posted entry is undone by a reversal that names it.',
      coalesce(v_number, new.entry_id::text)
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> all (c_still_moves);

  if v_moved is not null then
    raise exception 'entry_posted: line % of entry % was posted and keeps its % (%). A posted entry is undone by a reversal that names it.',
      old.sequence, coalesce(v_number, old.entry_id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;
  return new;
end;
$$;

comment on function entry_lines_guard_posted() is
  'Once an entry has left draft, its lines are the lines that were posted: no insert, no delete, and no column changed but the two the matching writes, matching_number and matched_amount. Refuses entry_posted, by name, to everybody.';

create trigger entry_lines_guard_posted
  before insert or update or delete on entry_lines
  for each row execute function entry_lines_guard_posted();

revoke execute on function entry_lines_guard_posted() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The totals of a posted entry are not recomputed
--
-- `20260911120400` as it was, acting on drafts only. The lines of a posted
-- entry do not move, so there is nothing to recompute; and a trigger that
-- restates the totals of a posted entry from its lines is the mechanism by
-- which a changed line used to become a changed entry.
-- ---------------------------------------------------------------------------

create or replace function entries_refresh_totals()
returns trigger
language plpgsql
as $$
declare
  v_entry_id uuid := coalesce(new.entry_id, old.entry_id);
begin
  update entries e
     set total_debit  = coalesce(s.debit, 0),
         total_credit = coalesce(s.credit, 0)
    from (
      select sum(l.debit) as debit, sum(l.credit) as credit
        from entry_lines l
       where l.entry_id = v_entry_id
    ) s
   where e.id = v_entry_id
     and e.state = 'draft';
  return null;
end;
$$;

comment on function entries_refresh_totals() is
  'Keeps the totals of a draft entry in step with its lines. A posted entry keeps the totals it was posted, or loaded, with.';
