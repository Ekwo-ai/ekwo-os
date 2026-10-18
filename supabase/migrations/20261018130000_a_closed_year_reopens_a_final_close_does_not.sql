-- Ekwo OS — a closed year can be reopened; a final close cannot.
--
-- Decision of 18 October 2026, rewriting decision 0031: the ordinary close is
-- reversible, as a lock date is, and a final close is not, as the clôture
-- définitive some laws require is not.
--
-- **The ordinary close stops refusing a year that has been built on.**
-- `reopen_fiscal_year()` refused once the year after held a posted entry
-- (`next_fiscal_year_in_use`). The reason it gave — the result stands on the
-- balance sheet every later year reads — is true and is no reason to refuse:
-- the close writes no opening entry in the year after (decision 0031, "the
-- close writes no à-nouveaux"), because the reports read the ledger from the
-- beginning. So the year after holds nothing that came from this close.
-- Reopened, corrected and closed again, the year writes a new closing entry
-- from its own movements; the year after reads the new result on its balance
-- sheet without an entry of its own, and when nothing changed nothing moves
-- there. There is no opening to reverse and rewrite, and the simplest correct
-- mechanism is to write none. A test closes, books the year after, reopens,
-- corrects and closes again, and reads both balance sheets.
--
-- An opening the year after carries for another reason — `opening_balance()`,
-- books taken over from another system on that day — is that system's figure
-- and a person's entry. It is not touched here, as it was not before.
--
-- **A later year that is closed still refuses, under its own name.** A year
-- whose successor is closed is reopened after its successor, as close refuses
-- a year whose successor is already closed (`later_fiscal_year_closed`). The
-- two rules keep the closed years a run from the first one, which is what a
-- lock date is: moving it back opens every year after the new date, and here
-- that is one `reopen_fiscal_year()` per year, latest first, each one audited.
-- Allowing the earlier one alone would leave an open year under a closed one,
-- which no close could produce and nothing else in the schema expects.
--
-- **The final close is a state of its own.** `fiscal_years.finally_closed_at`,
-- set by `close_fiscal_year_finally()` on a year already closed, never cleared.
-- `fiscal_years_guard_final()` refuses for everybody — the installer and
-- `service_role` included, whatever setting the session raised — any change to
-- a finally closed year: its flag, its dates, the stamp itself, and deleting
-- it. `reopen_fiscal_year()` refuses it first, by name
-- (`fiscal_year_finally_closed`). A year is finally closed only after every
-- closed year before it, so the finally closed years are a run from the first
-- one too, and nothing before a finally closed year can be reopened.
--
-- **Whether a country requires it, and by when, is the pack's.**
-- `country_defaults.final_close_due`, a closed vocabulary of one word for now,
-- with the article behind it, compiled from `defaults.final_close` of the pack:
--
--   * `before_next_fiscal_year_ends` — the close that freezes the year is
--     carried out at the latest before the following year ends.
--
-- Null is a country whose pack says nothing: the final close is offered and
-- never asked for. `fiscal_year_final_close()` reads the column for one year
-- and gives the day it is due by. Neither function names a country.
--
-- Attachments are not affected: a piece is not a change of the books
-- (decision 0069), and a finally closed year takes one as a closed year does.

-- ---------------------------------------------------------------------------
-- 1. The state, and the country's word
-- ---------------------------------------------------------------------------

alter table fiscal_years
  add column if not exists finally_closed_at timestamptz;

alter table fiscal_years
  add constraint fiscal_years_final_is_closed
    check (finally_closed_at is null or is_closed);

comment on column fiscal_years.finally_closed_at is
  'When the year was finally closed by close_fiscal_year_finally(). Null for a year that is open or under an ordinary close. Once set, the year is never reopened, its dates never move and the stamp is never cleared — by anybody.';

alter table country_defaults
  add column if not exists final_close_due             text,
  add column if not exists final_close_legal_reference text,
  add column if not exists final_close_source_key      text;

alter table country_defaults
  add constraint country_defaults_final_close_due_known
    check (final_close_due is null or final_close_due in ('before_next_fiscal_year_ends'));

comment on column country_defaults.final_close_due is
  'Whether this country requires a final close of every fiscal year, and by when: before_next_fiscal_year_ends, or null where the pack says nothing and the final close is offered without being asked for. fiscal_year_final_close() is the function that reads it.';
comment on column country_defaults.final_close_legal_reference is
  'The article that requires the final close, as the pack cites it.';
comment on column country_defaults.final_close_source_key is
  'Key of the entry in the pack''s source register where that article is read.';

-- ---------------------------------------------------------------------------
-- 2. The guard
-- ---------------------------------------------------------------------------

create or replace function fiscal_years_guard_final()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    if old.finally_closed_at is not null then
      raise exception 'fiscal_year_finally_closed: % was finally closed on %; it is not deleted',
        old.name, old.finally_closed_at
        using errcode = '55006';
    end if;
    return old;
  end if;

  -- A finally closed year moves no more, whoever asks and whatever setting the
  -- session raised: a setting any session may raise is not what makes a close
  -- final.
  if old.finally_closed_at is not null then
    if new.is_closed is distinct from old.is_closed
       or new.closed_at is distinct from old.closed_at
       or new.finally_closed_at is distinct from old.finally_closed_at
       or new.start_date is distinct from old.start_date
       or new.end_date is distinct from old.end_date
       or new.company_id is distinct from old.company_id then
      raise exception 'fiscal_year_finally_closed: % was finally closed on %; it is not reopened and does not change',
        old.name, old.finally_closed_at
        using errcode = '55006';
    end if;
    return new;
  end if;

  if new.finally_closed_at is null then
    return new;
  end if;

  if coalesce(current_setting('ekwo.final_close', true), '') = 'on' then
    if is_installer() or has_capability(new.company_id, 'year_end.close') then
      return new;
    end if;
    raise exception 'not_allowed: closing or re-opening a financial year needs year_end.close'
      using errcode = '42501';
  end if;

  raise exception 'fiscal_year_close_not_a_column: finally_closed_at is set by close_fiscal_year_finally()'
    using errcode = '55006';
end;
$$;

comment on function fiscal_years_guard_final() is
  'Keeps a final close final. Refuses, for everybody, any change to a finally closed year — is_closed, closed_at, finally_closed_at, its dates — and deleting it; and refuses setting finally_closed_at anywhere but in close_fiscal_year_finally(), for a caller holding year_end.close.';

revoke execute on function fiscal_years_guard_final() from public, anon, authenticated, service_role;

create trigger fiscal_years_guard_final
  before update or delete on fiscal_years
  for each row execute function fiscal_years_guard_final();

-- ---------------------------------------------------------------------------
-- 3. reopen_fiscal_year — whatever the year after holds, unless it is final
-- ---------------------------------------------------------------------------

create or replace function reopen_fiscal_year(p_fiscal_year_id uuid)
returns jsonb
language plpgsql
as $$
declare
  v_year      fiscal_years%rowtype;
  v_original  entries%rowtype;
  v_reversal  entries%rowtype;
  v_reversed  uuid[] := '{}';
begin
  select * into v_year from fiscal_years where id = p_fiscal_year_id for update;
  if not found then
    raise exception 'unknown_fiscal_year: fiscal year % does not exist', p_fiscal_year_id;
  end if;
  if v_year.finally_closed_at is not null then
    raise exception 'fiscal_year_finally_closed: % was finally closed on %; a final close is not reopened',
      v_year.name, v_year.finally_closed_at
      using errcode = '55006';
  end if;
  if not v_year.is_closed then
    raise exception 'fiscal_year_not_closed: % is already open', v_year.name;
  end if;

  -- Entries posted in a later year are no reason to refuse: the close wrote
  -- nothing there, and the later year reads this one's result from the ledger.
  -- A later year that is closed is reopened first, as close_fiscal_year()
  -- refuses a year whose successor is closed.
  if exists (
    select 1 from fiscal_years f
     where f.company_id = v_year.company_id
       and f.start_date > v_year.end_date
       and f.is_closed
  ) then
    raise exception 'later_fiscal_year_closed: a year after % is closed; reopen it first', v_year.name;
  end if;

  -- The flag first: the reversals are dated inside the year being re-opened,
  -- and the period guard would refuse them while it is closed.
  perform set_config('ekwo.closing_fiscal_year', 'on', true);
  update fiscal_years
     set is_closed = false,
         closed_at = null
   where id = p_fiscal_year_id;
  perform set_config('ekwo.closing_fiscal_year', 'off', true);

  for v_original in
    select e.*
      from entries e
     where e.company_id = v_year.company_id
       and e.state = 'posted'
       and e.kind in ('closing', 'appropriation')
       and e.fiscal_year_id = p_fiscal_year_id
       and e.reversed_entry_id is null
       and not exists (
         select 1 from entries r where r.reversed_entry_id = e.id and r.state = 'posted'
       )
     order by e.entry_date, e.number
  loop
    -- A reversal carries the kind of what it undoes: it belongs to the same
    -- report exclusion, and a closing entry undone by a `normal` one would
    -- reappear in the income statement on its own.
    perform set_config('ekwo.year_end_entry', 'on', true);
    insert into entries (company_id, journal_id, fiscal_year_id, entry_date,
                         description, state, reversed_entry_id, currency_code, kind)
    values (v_original.company_id, v_original.journal_id, v_original.fiscal_year_id,
            v_original.entry_date, 'Reversal of ' || v_original.number, 'draft',
            v_original.id, v_original.currency_code, v_original.kind)
    returning * into v_reversal;
    perform set_config('ekwo.year_end_entry', 'off', true);

    insert into entry_lines (entry_id, company_id, account_id, sequence, name,
                             debit, credit, contact_id, date_maturity, currency_code)
    select v_reversal.id, l.company_id, l.account_id, l.sequence, l.name,
           l.credit, l.debit, l.contact_id, l.date_maturity, l.currency_code
      from entry_lines l
     where l.entry_id = v_original.id
     order by l.sequence;

    perform post_entry(v_reversal.id);
    v_reversed := v_reversed || v_reversal.id;
  end loop;

  return jsonb_build_object(
    'fiscal_year_id', p_fiscal_year_id,
    'reversal_entry_ids', to_jsonb(v_reversed)
  );
end;
$$;

comment on function reopen_fiscal_year(uuid) is
  'Undoes an ordinary close: reverses the appropriation and closing entries it wrote and clears is_closed, whatever a later year holds — the close wrote nothing there, and the later year reads the result from the ledger. Refused for a year under a final close (fiscal_year_finally_closed), for everybody, and while a later year is closed (later_fiscal_year_closed), which is reopened first.';

-- ---------------------------------------------------------------------------
-- 4. close_fiscal_year_finally — the close that is not undone
-- ---------------------------------------------------------------------------

create or replace function close_fiscal_year_finally(p_fiscal_year_id uuid)
returns jsonb
language plpgsql
as $$
declare
  v_year fiscal_years%rowtype;
  v_at   timestamptz;
begin
  select * into v_year from fiscal_years where id = p_fiscal_year_id for update;
  if not found then
    raise exception 'unknown_fiscal_year: fiscal year % does not exist', p_fiscal_year_id;
  end if;
  -- The capability first, in the words the close uses: a refusal that told a
  -- viewer whether the year is closed would answer a question they may ask
  -- elsewhere, and a silent update of no row would answer nothing.
  if not (is_installer() or has_capability(v_year.company_id, 'year_end.close')) then
    raise exception 'not_allowed: closing or re-opening a financial year needs year_end.close'
      using errcode = '42501';
  end if;
  if v_year.finally_closed_at is not null then
    raise exception 'fiscal_year_finally_closed: % was finally closed on %', v_year.name, v_year.finally_closed_at
      using errcode = '55006';
  end if;
  if not v_year.is_closed then
    raise exception 'fiscal_year_not_closed: % is open; close it with close_fiscal_year() before closing it finally',
      v_year.name;
  end if;

  -- Final years are a run from the first one, so that nothing before a final
  -- year can be reopened and change what it carries forward.
  if exists (
    select 1 from fiscal_years f
     where f.company_id = v_year.company_id
       and f.start_date < v_year.start_date
       and f.is_closed
       and f.finally_closed_at is null
  ) then
    raise exception 'earlier_fiscal_year_not_final: a year before % is closed and not finally closed; close it finally first',
      v_year.name;
  end if;

  perform set_config('ekwo.final_close', 'on', true);
  update fiscal_years
     set finally_closed_at = now()
   where id = p_fiscal_year_id
  returning finally_closed_at into v_at;
  perform set_config('ekwo.final_close', 'off', true);
  if v_at is null then
    raise exception 'not_allowed: changing a financial year of this company needs settings.write'
      using errcode = '42501';
  end if;

  return jsonb_build_object(
    'fiscal_year_id', p_fiscal_year_id,
    'finally_closed_at', v_at
  );
end;
$$;

comment on function close_fiscal_year_finally(uuid) is
  'Closes a closed fiscal year for good: sets finally_closed_at, after which reopen_fiscal_year() refuses it for everybody and nothing about the year changes. Refused on an open year (fiscal_year_not_closed), on a year already final, and while a closed year before it is not final. Needs year_end.close. Whether the country requires it is fiscal_year_final_close().';

-- ---------------------------------------------------------------------------
-- 5. fiscal_year_final_close — what the country asks of one year
-- ---------------------------------------------------------------------------

create or replace function fiscal_year_final_close(p_fiscal_year_id uuid)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'fiscal_year_id', y.id,
    'is_closed', y.is_closed,
    'finally_closed_at', y.finally_closed_at,
    'required', d.final_close_due is not null,
    'due', d.final_close_due,
    -- The following year's last day, once that year exists: before it, the
    -- day the rule names is not known.
    'due_date', case d.final_close_due
                  when 'before_next_fiscal_year_ends' then (
                    select n.end_date from fiscal_years n
                     where n.company_id = y.company_id
                       and n.start_date = y.end_date + 1)
                end,
    'legal_reference', d.final_close_legal_reference,
    'source_key', d.final_close_source_key
  )
    from fiscal_years y
    join companies c on c.id = y.company_id
    left join country_defaults d on d.country = c.country
   where y.id = p_fiscal_year_id;
$$;

comment on function fiscal_year_final_close(uuid) is
  'Whether the country of the company requires a final close of this fiscal year, by when (due, and due_date once the following year exists), under which article, and whether it was done. Read from country_defaults.final_close_due, which the pack writes; null where the pack says nothing.';

-- ---------------------------------------------------------------------------
-- 6. The audit trail
-- ---------------------------------------------------------------------------

-- The stamp only ever goes from null to a time, so both words name one act.
create trigger fiscal_years_audit_final_close after update on fiscal_years
  for each row execute function audit_state_change(
    '{"watch":"finally_closed_at","true":"fiscal_year_finally_closed","false":"fiscal_year_finally_closed","key":"name","fields":["start_date","end_date"]}');

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

revoke execute on function close_fiscal_year_finally(uuid) from public, anon;
grant execute on function close_fiscal_year_finally(uuid) to authenticated, service_role;
revoke execute on function fiscal_year_final_close(uuid) from public, anon;
grant execute on function fiscal_year_final_close(uuid) to authenticated, service_role;
