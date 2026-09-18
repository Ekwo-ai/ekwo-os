-- Ekwo OS — an entry is posted by post_entry(), a document by post_document().
--
-- The two guards published this morning freeze what is posted. They looked at
-- the way *out* of `posted` and let the way *in* alone, on the ground that the
-- transition is one statement of `post_entry()`. It is — and it is also one
-- statement of anybody's. Established as the `accountant` preset, which holds
-- `entries.post`, under row level security, on a balanced draft:
--
--     update entries set state = 'posted', number = 'HAND/1' where id = …
--
-- went through. What stood in the way was two check constraints (a posted
-- entry has a number and balances), the capability, and the lock of the
-- period as `entries_guard_period` reads it. What did not: the number was
-- chosen by hand, in a country whose law forbids a hole in the sequence and
-- where `post_entry()` refuses exactly that by name (`numbering_gapless`);
-- `posted_at` and `fiscal_year_id` stayed null; an entry with no line at all
-- balances at zero and was accepted; the period was not asked the stricter
-- question `post_entry()` asks. And the guard of this morning then froze the
-- result for good.
--
-- The same on a document: `update documents set state = 'posted', entry_id = …`
-- pointing at an entry that is legitimately posted and is *not* the one the
-- document produced — an entry keyed by hand, say — went through, because
-- `document_posted_without_entry` only asked that the entry be posted.
--
-- **Judged on facts, not on a flag.** The obvious fix is a transaction-local
-- setting that `post_entry()` raises and the guard reads. It does not hold: a
-- custom setting is writable by any session that can run `set_config`, so the
-- flag would say "post_entry is running" for whoever said so first — and
-- `post_entry()` runs as its caller, so there is no privilege behind which to
-- hide it. What `post_entry()` *produces*, on the other hand, is all on the
-- row and in the counter, and can be checked there whoever wrote it:
--
--   * `posted_at` is set, and `fiscal_year_id`, where there is one, is the year
--     the date falls in;
--   * the entry has at least one line (`entry_empty`);
--   * the period is open, asked the way `post_entry()` asks it;
--   * **the number was drawn, not chosen**, wherever the rule applies: in a
--     country that numbers without a hole, for a caller who does not hold
--     `entries.import`, the number has to be the last one the counter of its
--     journal delivered. `next_entry_number()` advances that counter in the
--     same statement and holds its row until the transaction ends, and a number
--     already used is refused by `entries_company_number_idx` — so "equal to
--     the last delivered, and unique" *is* "just drawn". Elsewhere a number
--     chosen by hand is what `post_entry()` allows too, and the guard then
--     brings the counter up to it, as the function does.
--
-- A row that satisfies all of that is, fact for fact, the row `post_entry()`
-- writes, and is let through whoever wrote it: a rule about facts cannot refuse
-- the facts, and nothing is lost by it. `post_entry()` is unchanged, and so are
-- the seven functions that call it; `import_company()` switches the guard off
-- for a load, as before.
--
-- The cost is said plainly: the conditions of `post_entry()` are now read in
-- two places, the function and the guard. `tests/posted_by_hand.test.ts` walks
-- every refusal of the function beside the same attempt by hand, so that a
-- condition added to one and not to the other fails a test.
--
-- For a document the facts are on two rows: the entry names this document
-- (`entries.document_id`, written by `post_document()` when it builds it, and
-- frozen with the entry), the document is booked on its entry's day, and it
-- carries the number it had, or its entry's. `document_posted_by_hand`
-- otherwise.

-- ---------------------------------------------------------------------------
-- 1. The guard of an entry, asking at the transition what post_entry() leaves
--
-- `20260918161538` as it was, with the transition judged. It is written in the
-- trigger and not in a function beside it: a function nobody may call is a
-- function the grants have no honest line for.
-- ---------------------------------------------------------------------------

create or replace function entries_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_moved   text[];
  v_format  text;
  v_gapless boolean;
  v_code    text;
  v_period  smallint;
  v_last    integer;
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
    if tg_op = 'UPDATE' and new.state = 'posted' then
      if new.posted_at is null then
        raise exception 'entry_posted_by_hand: entry % would be posted with no instant it was posted at. An entry is posted by post_entry() and by nothing else.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;
      -- Null is what post_entry() itself writes where it finds no year — a company
      -- that has not opened one, or a caller who cannot read `fiscal_years`, which
      -- is a machine key today. A year that is *named* has to be the right one.
      if new.fiscal_year_id is not null
         and new.fiscal_year_id is distinct from fiscal_year_at(new.company_id, new.entry_date) then
        raise exception 'entry_posted_by_hand: entry % would be posted outside the financial year its date falls in. An entry is posted by post_entry() and by nothing else.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;

      if not exists (select 1 from entry_lines l where l.entry_id = new.id) then
        raise exception 'entry_empty: entry % has no lines', new.id;
      end if;

      perform assert_period_open(new.company_id, new.entry_date, true);

      select r.number_format, r.numbering_gapless into v_format, v_gapless
        from numbering_rules(new.company_id) r;
      select j.code into v_code from journals j where j.id = new.journal_id;
      v_period := case when v_format ~ '\{(YYYY|YY)\}'
                       then extract(year from new.entry_date)::smallint
                       else 0::smallint end;
      select s.last_number into v_last
        from journal_sequences s
       where s.journal_id = new.journal_id and s.year = v_period;

      if v_last is not null and new.number = format_number(v_format, v_code, new.entry_date, v_last) then
        return new;  -- drawn from the counter, a moment ago, by this transaction
      end if;

      -- A number chosen by hand: on the draft beforehand, or in this statement.
      if v_gapless and not (auth.uid() is not null and has_capability(new.company_id, 'entries.import')) then
        raise exception 'entry_posted_by_hand: % is not the number the counter of this journal delivered, and this country forbids a hole in the sequence. An entry is posted by post_entry(), which draws it; books that already have numbers are brought in by whoever holds entries.import.',
          new.number
          using errcode = '55006';
      end if;
      perform catch_up_journal_sequence(new.journal_id, new.entry_date, new.number);
    end if;
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

-- ---------------------------------------------------------------------------
-- 2. The guard of a document, asking whose entry it is
--
-- `20260918161204` as it was; the transition reads the entry instead of only
-- finding it.
-- ---------------------------------------------------------------------------

create or replace function documents_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  -- What may still move once the state has left `draft`. A closed list: a
  -- column that is not named here is frozen, including one that does not
  -- exist yet.
  c_still_moves constant text[] := array[
    'amount_paid', 'amount_residual', 'payment_state',
    'sent_at', 'peppol_status', 'peppol_message_id',
    'updated_at'
  ];
  v_moved text[];
  v_entry entries%rowtype;
begin
  if tg_op = 'INSERT' then
    if new.state <> 'draft' then
      raise exception 'document_born_posted: a document is written as a draft and posted by post_document(). One that is already % arrives with a company being loaded, by import_company(), and in no other way.',
        new.state
        using errcode = '55006';
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if old.state = 'draft'
       or not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    raise exception 'document_posted: % % was issued and cannot be deleted. It is undone by a credit note that names it.',
      old.doc_type, coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  if old.state = 'draft' then
    -- The one transition that produces an entry has to have produced one.
    if new.state = 'posted' then
      select e.* into v_entry from entries e where e.id = new.entry_id and e.state = 'posted';
      if not found then
        raise exception 'document_posted_without_entry: % has no posted entry. A document is posted by post_document(), which builds its entry and posts it first.',
          coalesce(new.number, new.id::text)
          using errcode = '55006';
      end if;
      -- What post_document() leaves behind, read on the two rows: the entry
      -- was built for this document and for no other, the document is booked
      -- on the day its entry is, and it is numbered as it was — or, where it
      -- had no number, as its entry.
      if v_entry.document_id is distinct from new.id
         or new.accounting_date is distinct from v_entry.entry_date
         or new.number is distinct from coalesce(old.number, v_entry.number) then
        raise exception 'document_posted_by_hand: % is not what post_document() writes — its entry % was not built for it, or is not booked on its day, or did not give it its number. A document is posted by post_document() and by nothing else.',
          coalesce(new.number, new.id::text), coalesce(v_entry.number, v_entry.id::text)
          using errcode = '55006';
      end if;
    end if;
    return new;
  end if;

  if new.state is distinct from old.state then
    raise exception 'document_posted: % % is % and stays so. It is undone by a credit note that names it, never by changing its state to %.',
      old.doc_type, coalesce(old.number, old.id::text), old.state, new.state
      using errcode = '55006';
  end if;

  select array_agg(n.key order by n.key)
    into v_moved
    from jsonb_each(to_jsonb(new)) n
    join jsonb_each(to_jsonb(old)) o on o.key = n.key
   where n.value is distinct from o.value
     and n.key <> all (c_still_moves);

  if v_moved is not null then
    raise exception 'document_posted: % % was issued and keeps its % (%). What produced an entry does not change after it; credit it and issue another.',
      old.doc_type, coalesce(old.number, old.id::text),
      case when array_length(v_moved, 1) = 1 then 'value of' else 'values of' end,
      array_to_string(v_moved, ', ')
      using errcode = '55006';
  end if;

  if new.amount_paid is distinct from old.amount_paid
     and new.amount_paid is distinct from document_amount_paid(new.id) then
    raise exception 'document_amount_paid_is_derived: % has been settled by %, which is what its matching says. The figure is never keyed.',
      coalesce(old.number, old.id::text), document_amount_paid(new.id)
      using errcode = '55006';
  end if;

  if new.payment_state is distinct from old.payment_state
     and new.amount_paid is not distinct from old.amount_paid then
    raise exception 'document_payment_state_is_derived: the settlement of % follows from what was matched against it, and is never keyed.',
      coalesce(old.number, old.id::text)
      using errcode = '55006';
  end if;

  return new;
end;
$$;

comment on function documents_guard_posted() is
  'Once a document has left draft: its state does not change, it is not deleted, and no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id. Refuses document_posted, by name, to everybody. Becoming posted is held to what post_document() writes — a posted entry built for this document, booked on its day, that gave it its number — document_posted_by_hand otherwise; and nobody inserts a document that is already posted (document_born_posted).';

comment on function entries_guard_posted() is
  'Once an entry has left draft: it is not deleted, its state does not change and no column moves (entry_posted); nobody inserts one that is already posted (entry_born_posted). Becoming posted is held to what post_entry() produces, read on the row and in the counter — an instant it was posted at, no financial year but the one its date falls in, at least one line, an open period, and, where the country numbers without a hole and the caller does not hold entries.import, the number the counter of its journal has just delivered: entry_posted_by_hand otherwise.';
