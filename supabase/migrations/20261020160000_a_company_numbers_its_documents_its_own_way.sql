-- Ekwo OS — a company numbers its documents its own way.
--
-- A number has been the country's until now: `numbering_rules()` read the
-- pattern of the pack (`country_defaults.number_format`), and `{CODE}` printed
-- the code of the journal that drew it. A company that has always numbered
-- its invoices `FAC-2026-0001`, or wants six digits, or one series that does
-- not restart each year, could not say so.
--
-- **Two columns, both nullable; null keeps the pack.**
--
--   `companies.number_format` — the company's pattern, in the grammar of the
--     pack's (`{CODE}`, `{YYYY}` or `{YY}`, `{MM}`, `{N…}`). It must carry
--     `{CODE}`: every journal of a company counts on its own, so a pattern
--     without the journal in it would print the same number twice, once per
--     journal.
--   `journals.number_prefix` — what `{CODE}` prints for that journal. The
--     journal's code stays what it is: the pack, the imports and the exports
--     know a journal by its code, and only the number changes.
--
-- `numbering_rules()` answers the company's pattern before the pack's, so
-- every reader of the pattern — drawing a number, reading one back, giving
-- one back when a document returns to draft — follows it without being
-- touched. The four functions that print `{CODE}` print the prefix instead.
--
-- **Changing the pattern on the way keeps one series.** The counter is held
-- per journal and per year when the pattern carries the year, under year 0
-- when it does not. A change between the two would start a counter at 1 in
-- the middle of a year. `companies_number_format_carries()` copies, for each
-- journal, the last number of the series it leaves into the one it enters, so
-- the next document continues at the next number: no hole where the law
-- forbids one, no number drawn twice. Changing only the prefix or the width
-- keeps the same counter and needs nothing. The unique index on
-- `entries (company_id, number)` stays the last word.
--
-- **A prefix belongs to one journal.** Two journals printing the same prefix
-- would print the same numbers from their own counters:
-- `journals_number_prefix_is_its_own()` refuses it (`number_prefix_taken`),
-- against the prefixes and the codes of the other journals.
--
-- **Who may write them** is who may write the row: `company.write` for the
-- company, `settings.write` for a journal. No grant changes. Both tables are
-- on the audit trail, so a change of numbering is recorded with who made it.

alter table companies
  add column if not exists number_format text;

alter table companies
  add constraint companies_number_format_not_blank
  check (btrim(number_format) <> '');

alter table journals
  add column if not exists number_prefix text;

alter table journals
  add constraint journals_number_prefix_shape
  check (number_prefix = btrim(number_prefix)
         and number_prefix <> ''
         and length(number_prefix) <= 20
         and number_prefix !~ '[{}]');

comment on column companies.number_format is
  'This company''s pattern of a document number, in the grammar of country_defaults.number_format: {CODE}, {YYYY} or {YY}, {MM}, {N...}. Carries {CODE}. Null keeps the pattern of the country pack.';
comment on column journals.number_prefix is
  'What {CODE} prints in the numbers this journal draws. Null prints the journal''s code. The code itself is unchanged.';

-- ---------------------------------------------------------------------------
-- The company's pattern first
-- ---------------------------------------------------------------------------

-- A third answer, the pack's own pattern, so that the trigger below and a
-- screen that offers the company's pattern beside the pack's read it here and
-- nowhere else: this stays the only function that reads the pack's rules.
-- The signature changes, so the function is dropped and created again; its
-- callers name its columns, and none of them is a view.
drop function if exists numbering_rules(uuid);
create function numbering_rules(
  p_company_id uuid,
  out number_format text,
  out numbering_gapless boolean,
  out pack_number_format text
)
language sql
stable
as $$
  select coalesce(c.number_format, d.number_format), coalesce(d.numbering_gapless, false), d.number_format
    from companies c
    left join country_defaults d on d.country = c.fiscal_country
   where c.id = p_company_id;
$$;
comment on function numbering_rules(uuid) is
  'The pattern of a company''s document numbers — its own, or its country''s — whether the law forbids a hole, and the country''s pattern alone. The only function that reads the pack''s numbering.';

-- ---------------------------------------------------------------------------
-- A pattern the company writes is one that can number
-- ---------------------------------------------------------------------------

create or replace function companies_number_format_is_valid()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  -- Null keeps the pack; a blank one is the check constraint's to name.
  if new.number_format is null or btrim(new.number_format) = '' then
    return new;
  end if;
  if position('{CODE}' in new.number_format) = 0 then
    raise exception 'number_format_without_code: % carries no {CODE}. Each journal counts on its own, so the journal has to be in the number, or two journals would print the same one.',
      new.number_format
      using errcode = '23514';
  end if;
  -- Rendered once, for nothing: format_number() names a missing counter or a
  -- token it does not know.
  perform format_number(new.number_format, 'X', current_date, 1);
  return new;
end;
$$;
comment on function companies_number_format_is_valid() is
  'Refuses a company number pattern that does not carry {CODE}, carries no counter or names a token outside the grammar.';

drop trigger if exists companies_number_format_is_valid on companies;
create trigger companies_number_format_is_valid
  before insert or update of number_format on companies
  for each row execute function companies_number_format_is_valid();

-- ---------------------------------------------------------------------------
-- One series across a change of pattern
--
-- Definer: `journal_sequences` is written by the counters and by nobody by
-- hand. The caller has already been judged by the policy that let the
-- update of `companies` through.
-- ---------------------------------------------------------------------------

create or replace function companies_number_format_carries()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pack      text;
  v_old       text;
  v_new       text;
  v_old_years boolean;
  v_new_years boolean;
  v_journal   record;
  v_last      integer;
  v_year      smallint;
begin
  select r.pack_number_format into v_pack from numbering_rules(new.id) r;
  v_old := coalesce(old.number_format, v_pack);
  v_new := coalesce(new.number_format, v_pack);
  v_old_years := coalesce(v_old ~ '\{(YYYY|YY)\}', false);
  v_new_years := coalesce(v_new ~ '\{(YYYY|YY)\}', false);
  if v_old_years = v_new_years then
    return new;  -- the same counters go on
  end if;

  for v_journal in select j.id from journals j where j.company_id = new.id loop
    if v_old_years then
      -- Into one series: it goes on from the last number of the latest year.
      select s.last_number into v_last
        from journal_sequences s
       where s.journal_id = v_journal.id and s.year <> 0
       order by s.year desc
       limit 1;
      if v_last is not null then
        insert into journal_sequences (journal_id, year, last_number)
        values (v_journal.id, 0, v_last)
        on conflict (journal_id, year)
          do update set last_number = greatest(journal_sequences.last_number, excluded.last_number);
      end if;
    else
      -- Into a series per year: this year, and the year of the journal's
      -- latest numbered entry where that is another, go on from the single
      -- series; the years after start at 1, with the year in the number.
      select s.last_number into v_last
        from journal_sequences s
       where s.journal_id = v_journal.id and s.year = 0;
      if v_last is not null then
        for v_year in
          select extract(year from current_date)::smallint
          union
          select extract(year from max(e.entry_date))::smallint
            from entries e
           where e.journal_id = v_journal.id and e.number is not null
          having max(e.entry_date) is not null
        loop
          insert into journal_sequences (journal_id, year, last_number)
          values (v_journal.id, v_year, v_last)
          on conflict (journal_id, year)
            do update set last_number = greatest(journal_sequences.last_number, excluded.last_number);
        end loop;
      end if;
    end if;
  end loop;
  return new;
end;
$$;
comment on function companies_number_format_carries() is
  'When a company''s number pattern starts or stops carrying the year, carries each journal''s last number into the counter the new pattern reads, so the series goes on without a hole or a repeat.';

drop trigger if exists companies_number_format_carries on companies;
create trigger companies_number_format_carries
  after update of number_format on companies
  for each row
  when (old.number_format is distinct from new.number_format)
  execute function companies_number_format_carries();

-- ---------------------------------------------------------------------------
-- A prefix belongs to one journal
-- ---------------------------------------------------------------------------

create or replace function journals_number_prefix_is_its_own()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_mine  text := coalesce(new.number_prefix, new.code);
  v_other text;
begin
  select j.code into v_other
    from journals j
   where j.company_id = new.company_id
     and j.id <> new.id
     -- The journal of the same code is this one, or the row an upsert is
     -- about to update: the unique key on the code judges that, not this.
     and j.code <> new.code
     and coalesce(j.number_prefix, j.code) = v_mine
   limit 1;
  if v_other is not null then
    raise exception 'number_prefix_taken: journal % already prints % in its numbers. Two journals with one prefix would print the same numbers from their own counters.',
      v_other, v_mine
      using errcode = '23505';
  end if;
  return new;
end;
$$;
comment on function journals_number_prefix_is_its_own() is
  'Refuses a journal whose number prefix (or code, where it has none) is what another journal of the company already prints.';

drop trigger if exists journals_number_prefix_is_its_own on journals;
create trigger journals_number_prefix_is_its_own
  before insert or update of number_prefix, code on journals
  for each row execute function journals_number_prefix_is_its_own();

-- ---------------------------------------------------------------------------
-- The four functions that print {CODE} print the journal's prefix
--
-- Republished as they were, with `coalesce(j.number_prefix, j.code)` where
-- they read `j.code` for the number.
-- ---------------------------------------------------------------------------

create or replace function next_entry_number(p_journal_id uuid, p_date date)
returns text
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_code    text;
  v_company uuid;
  v_format  text;
  v_period  smallint;
  v_number  integer;
begin
  select coalesce(j.number_prefix, j.code), j.company_id into v_code, v_company from journals j where j.id = p_journal_id;
  if v_code is null or not may_know_of_company(v_company) then
    raise exception 'unknown_journal: journal % does not exist', p_journal_id;
  end if;

  if not is_installer() and not has_capability(v_company, 'entries.post') then
    raise exception 'not_allowed: drawing a number in this company needs entries.post'
      using errcode = '42501';
  end if;

  select number_format into v_format from numbering_rules(v_company);
  if v_format is null or v_format = '' then
    raise exception 'no_number_format: the country pack of this company declares no documents.number_format, and there is no default to fall back on';
  end if;

  -- A pattern that carries the year restarts with it; one that does not is a
  -- single series, kept under the period that is not a year.
  v_period := case when v_format ~ '\{(YYYY|YY)\}'
                   then extract(year from p_date)::smallint
                   else 0::smallint end;

  insert into journal_sequences (journal_id, year, last_number)
  values (p_journal_id, v_period, 1)
  on conflict (journal_id, year)
    do update set last_number = journal_sequences.last_number + 1
  returning last_number into v_number;

  return format_number(v_format, v_code, p_date, v_number);
end;
$$;

create or replace function unpost_refusal(p_document_id uuid)
returns text
language plpgsql
stable
as $$
declare
  v_doc     documents%rowtype;
  v_entry   entries%rowtype;
  v_what    text;
  v_other   text;
  v_day     date;
  v_filing  record;
  v_format  text;
  v_gapless boolean;
  v_code    text;
  v_period  smallint;
  v_last    integer;
begin
  select * into v_doc from documents where id = p_document_id;
  if not found then
    return format('unknown_document: document %s does not exist', p_document_id);
  end if;
  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);

  if not is_installer() and not has_capability(v_doc.company_id, 'documents.post') then
    return 'not_allowed: putting a posted document back to draft in this company needs documents.post';
  end if;

  if v_doc.state <> 'posted' then
    return format('document_not_posted: %s is %s, and only a posted document goes back to draft', v_what, v_doc.state);
  end if;

  if v_doc.doc_type not in ('sale_invoice', 'purchase_invoice', 'sale_credit_note', 'purchase_credit_note') then
    return format('document_not_accountable: a %s books nothing, so there is no posting to take back', v_doc.doc_type);
  end if;

  if posted_edit_policy(v_doc.company_id) <> 'unpost_if_untouched' then
    return format(
      'posted_edit_reversal_only: the law of this company''s country keeps a posted document as it was posted — its pack declares reversal_only, or says nothing, which reads the same — so %s does not go back to draft. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what);
  end if;

  if v_doc.sent_at is not null then
    return format('document_sent: %s was sent on %s, and a number a customer holds is kept. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what, v_doc.sent_at::date);
  end if;
  if coalesce(v_doc.peppol_status, '') not in ('', 'none') or v_doc.peppol_message_id is not null then
    return format('document_sent: %s left on Peppol (%s), and a number a customer holds is kept. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what, coalesce(nullif(v_doc.peppol_status, ''), v_doc.peppol_message_id));
  end if;

  select * into v_entry from entries where id = v_doc.entry_id;
  if not found then
    return format('unknown_entry: the entry of %s is not visible to you', v_what);
  end if;

  if v_doc.amount_paid <> 0
     or exists (select 1 from entry_lines l where l.entry_id = v_entry.id and l.matched_amount > 0) then
    return format('document_paid: %s is settled by %s already. Undo that matching first with unreconcile() — the money it records came in and stays.',
      v_what, v_doc.amount_paid);
  end if;

  select coalesce(c.number, c.id::text) into v_other
    from documents c
   where c.reversed_document_id = v_doc.id and c.state = 'posted'
   limit 1;
  if found then
    return format('document_already_credited: %s is credited by %s, which names it. Undo that credit note first, or leave both as they are.',
      v_what, v_other);
  end if;

  select coalesce(e.number, e.id::text) into v_other
    from entries e
   where e.document_id = v_doc.id and e.id <> v_entry.id
   limit 1;
  if found then
    return format('document_has_history: %s is named by entry %s beside its own — a tax that fell due on collection and was taken back, an exchange difference — and that stays. Undo it with cancel_document(), which issues the credit note that names it.',
      v_what, v_other);
  end if;

  -- The day it is booked on and every tax point of its lines, asked the
  -- question posting asks: the lock date, the tax lock date, a closed year.
  for v_day in
    select v_entry.entry_date
    union
    select l.tax_point_date from entry_lines l
     where l.entry_id = v_entry.id and l.tax_point_date is not null
     order by 1
  loop
    begin
      perform assert_period_open(v_doc.company_id, v_day, true);
    exception when sqlstate '55006' then
      return format('document_period_closed: %s is booked or taxed on %s, which is no longer open (%s). Undo it with cancel_document() on a date that is.',
        v_what, v_day, sqlerrm);
    end;

    select f.report_code, f.period_start, f.period_end, f.state into v_filing
      from tax_filings f
     where f.company_id = v_doc.company_id
       and f.state not in ('draft', 'ready', 'superseded')
       and v_day between f.period_start and f.period_end
     order by f.period_start
     limit 1;
    if found then
      return format('document_declared: %s falls in the declaration %s of %s to %s, which is %s. Undo it with cancel_document(), which the next declaration carries.',
        v_what, v_filing.report_code, v_filing.period_start, v_filing.period_end, v_filing.state);
    end if;
  end loop;

  -- Where the law forbids a hole, only the last number drawn goes back.
  select r.number_format, r.numbering_gapless into v_format, v_gapless
    from numbering_rules(v_doc.company_id) r;
  if v_gapless then
    select coalesce(j.number_prefix, j.code) into v_code from journals j where j.id = v_entry.journal_id;
    v_period := case when v_format ~ '\{(YYYY|YY)\}'
                     then extract(year from v_entry.entry_date)::smallint
                     else 0::smallint end;
    select s.last_number into v_last
      from journal_sequences s
     where s.journal_id = v_entry.journal_id and s.year = v_period;
    if v_last is null or v_entry.number is distinct from format_number(v_format, v_code, v_entry.entry_date, v_last) then
      return format('document_not_last_number: %s is not the last number journal %s drew — %s came after it — and this country forbids a hole in the sequence. Undo it with cancel_document(), which issues the credit note that names it.',
        coalesce(v_entry.number, v_entry.id::text), v_code,
        case when v_last is null then 'another'
             else format_number(v_format, v_code, v_entry.entry_date, v_last) end);
    end if;
  end if;

  return null;
end;
$$;

create or replace function unpost_document(p_document_id uuid)
returns documents
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc     documents%rowtype;
  v_entry   entries%rowtype;
  v_refusal text;
  v_format  text;
  v_code    text;
  v_period  smallint;
  v_last    integer;
  v_is_last boolean;
begin
  select * into v_doc from documents where id = p_document_id for update;
  if not found or not may_know_of_company(v_doc.company_id) then
    raise exception 'unknown_document: document % does not exist', p_document_id;
  end if;

  -- Definer: the caller is asked here, before anything is read on their behalf.
  if not is_installer() and not has_capability(v_doc.company_id, 'documents.post') then
    raise exception 'not_allowed: putting a posted document back to draft in this company needs documents.post'
      using errcode = '42501';
  end if;

  select * into v_entry from entries where id = v_doc.entry_id for update;

  -- The counter is held until the transaction ends, so that "the last number
  -- drawn" is still true when it is given back.
  if found then
    select r.number_format into v_format from numbering_rules(v_doc.company_id) r;
    select coalesce(j.number_prefix, j.code) into v_code from journals j where j.id = v_entry.journal_id;
    v_period := case when v_format ~ '\{(YYYY|YY)\}'
                     then extract(year from v_entry.entry_date)::smallint
                     else 0::smallint end;
    select s.last_number into v_last
      from journal_sequences s
     where s.journal_id = v_entry.journal_id and s.year = v_period
       for update;
  end if;

  v_refusal := unpost_refusal(p_document_id);
  if v_refusal is not null then
    raise exception '%', v_refusal
      using errcode = case split_part(v_refusal, ':', 1)
                        when 'not_allowed' then '42501'
                        when 'document_period_closed' then '55006'
                        when 'document_declared' then '55006'
                        else 'P0001'
                      end;
  end if;

  v_is_last := v_last is not null
               and v_entry.number = format_number(v_format, v_code, v_entry.entry_date, v_last);

  insert into document_unpostings (company_id, document_id, doc_type, entry_id, entry_number,
                                   journal_id, entry_date, number_returned)
  values (v_doc.company_id, v_doc.id, v_doc.doc_type, v_entry.id, v_entry.number,
          v_entry.journal_id, v_entry.entry_date, v_is_last);

  -- Back to what it was before post_document(): what posting derived goes,
  -- what was keyed stays.
  update documents
     set state = 'draft',
         entry_id = null,
         number = case when number is not distinct from v_entry.number then null else number end,
         accounting_date = case when accounting_date is not distinct from document_date
                                then null else accounting_date end,
         tax_point_date = case when tax_point_date is not distinct from
                                    tax_point_of(company_id, document_date, delivery_date, null)
                               then null else tax_point_date end,
         seller_territory_code     = null,
         buyer_territory_code      = null,
         supply_territory_resolved = null
   where id = v_doc.id
  returning * into v_doc;

  -- Its lines and their analytic split go with it, by the foreign keys.
  delete from entries where id = v_entry.id;

  if v_is_last then
    update journal_sequences
       set last_number = last_number - 1
     where journal_id = v_entry.journal_id and year = v_period and last_number = v_last;
  end if;

  return v_doc;
end;
$$;

create or replace function entries_guard_posted()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
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

  -- An entry moved into a company the writer may not know of: nothing below
  -- is read for it.
  if tg_op = 'UPDATE' then
    perform assert_writes_into_known_company(new.company_id);
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
      -- The journal of the entry's own company, or none: the counter of a
      -- journal of another company is not read, and the foreign key refuses
      -- the entry as it refuses a journal nobody holds.
      select coalesce(j.number_prefix, j.code) into v_code from journals j
       where j.id = new.journal_id and j.company_id = new.company_id;
      v_period := case when v_format ~ '\{(YYYY|YY)\}'
                       then extract(year from new.entry_date)::smallint
                       else 0::smallint end;
      select s.last_number into v_last
        from journal_sequences s
       where s.journal_id = new.journal_id and s.year = v_period and v_code is not null;

      if v_last is not null and new.number = format_number(v_format, v_code, new.entry_date, v_last) then
        return new;  -- drawn from the counter, a moment ago, by this transaction
      end if;

      -- A number chosen by hand: on the draft beforehand, or in this statement.
      if v_gapless and not (auth.uid() is not null and has_capability(new.company_id, 'entries.import')) then
        raise exception 'entry_posted_by_hand: % is not the number the counter of this journal delivered, and this country forbids a hole in the sequence. An entry is posted by post_entry(), which draws it; books that already have numbers are brought in by whoever holds entries.import.',
          new.number
          using errcode = '55006';
      end if;
      if v_code is not null then
        perform catch_up_journal_sequence(new.journal_id, new.entry_date, new.number);
      end if;
    end if;
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' then
    if not exists (select 1 from companies c where c.id = old.company_id) then
      return old;
    end if;
    -- The entry of a document unpost_document() has just put back to draft,
    -- recorded in this transaction, and which no document points at any more.
    if exists (
         select 1 from document_unpostings u
          where u.entry_id = old.id
            and u.transaction_id = txid_current())
       and not exists (select 1 from documents d where d.entry_id = old.id) then
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
$function$;

revoke execute on function numbering_rules(uuid) from public, anon;
grant  execute on function numbering_rules(uuid) to authenticated, service_role;
revoke execute on function companies_number_format_is_valid() from public, anon, authenticated, service_role;
revoke execute on function companies_number_format_carries() from public, anon, authenticated, service_role;
revoke execute on function journals_number_prefix_is_its_own() from public, anon, authenticated, service_role;
