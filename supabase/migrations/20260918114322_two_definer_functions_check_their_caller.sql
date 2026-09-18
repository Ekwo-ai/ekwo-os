-- Ekwo OS — two definer functions checked nobody.
--
-- Both were found by `tests/client_preset.test.ts`, which calls every volatile
-- function a signed-in person may execute, as a guest of the company, and
-- compares the whole database before and after. Two of them returned quietly.
--
-- **`catch_up_journal_sequence()`.** It is SECURITY DEFINER because
-- `journal_sequences` has a select policy and no other, and its header said
-- "the caller has already been checked by `post_entry()`". That is true of the
-- call `post_entry()` makes and of no other: the function is executable by
-- `authenticated`, takes a journal id, and advanced the counter of that
-- journal to whatever number it was handed — for a member who only reads, and
-- for somebody who is not a member of the company at all. `greatest()` kept it
-- from going backwards, so what it allowed was a hole: the next entry of that
-- journal numbered 9999 after 0042, in a country whose law forbids exactly
-- that. It is the sentence `next_entry_number()` was given a guard for on 11
-- September — "a way to burn numbers in somebody else's journal" — left open
-- on the function beside it.
--
-- It now asks what `next_entry_number()` asks, in the same words: the
-- installer, or `entries.post` on the company of the journal. Whoever posts an
-- imported entry holds it, since posting is what calls this. Revoking EXECUTE
-- instead was not possible: `post_entry()` runs as its caller.
--
-- **`touch_api_key()`.** Called by `use_api_key()`, which is definer, so the
-- inner call runs as the owner and needs no grant of its own. It had one
-- anyway, from the default privileges of the schema, and stamped
-- `last_used_at` on any key whose id it was given. The id is not secret the
-- way the key is, but "this key has not been used for a year" is the signal an
-- operator withdraws keys on, and anybody signed in could reset it. Nobody but
-- `use_api_key()` has a reason to call it, so nobody else may.

create or replace function catch_up_journal_sequence(p_journal_id uuid, p_date date, p_number text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_company uuid;
  v_format  text;
  v_period  smallint;
  v_counter integer;
begin
  select j.company_id into v_company from journals j where j.id = p_journal_id;
  if v_company is null then
    return;
  end if;

  if not is_installer() and not has_capability(v_company, 'entries.post') then
    raise exception 'not_allowed: moving a counter in this company needs entries.post'
      using errcode = '42501';
  end if;

  select number_format into v_format from numbering_rules(v_company);
  v_counter := number_counter(v_format, p_number);
  if v_counter is null then
    return;
  end if;

  v_period := case when v_format ~ '\{(YYYY|YY)\}'
                   then extract(year from p_date)::smallint
                   else 0::smallint end;

  insert into journal_sequences (journal_id, year, last_number)
  values (p_journal_id, v_period, v_counter)
  on conflict (journal_id, year)
    do update set last_number = greatest(journal_sequences.last_number, excluded.last_number);
end;
$$;

comment on function catch_up_journal_sequence(uuid, date, text) is
  'Advances the counter of a journal to the counter inside a number that was written by hand, so the next automatic number continues the series. Definer, because nobody writes `journal_sequences` directly — and guarded like `next_entry_number()`: the installer, or entries.post on the company of the journal.';

revoke execute on function touch_api_key(uuid) from public, anon, authenticated;
