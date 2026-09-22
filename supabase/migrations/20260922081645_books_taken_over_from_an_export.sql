-- Ekwo OS — books taken over from whatever kept them before.
--
-- Somebody who wants to try Ekwo on their own books arrives with them: a FEC,
-- an export of journal items, a trial balance saved from a spreadsheet. Until
-- this migration the only way in was one function per act — `opening_balance()`
-- for the balances, a draft and `post_entry()` for each entry — called by
-- whoever wrote the loop, with nothing to say that the loop had run to the end.
-- A file of three thousand entries that stops at the one thousand and first is
-- the worst outcome an import has: books that look complete and are not.
--
-- So an import is **one call**, `import_books()`, and one transaction. It
-- takes the books as a reader of `packages/formats/` returns them, with every
-- account code already translated into this company's chart by the caller —
-- the correspondence is a decision of the user's, proposed and saved on their
-- side, and never guessed here — and it writes all of them or none:
--
--   * the fiscal years the entries fall in, where asked to, as years of the
--     same length and on the same day as the ones the company has;
--   * the parties the lines name, found by their code or their name, or
--     created;
--   * every entry as a draft, then posted by `post_entry()`, which is the only
--     way an entry is posted and the one that numbers it;
--   * the balances of a trial balance, through `opening_balance()`, which posts
--     through `post_entry()` in its turn.
--
-- **A rehearsal is the same call.** `p_dry_run` runs every one of those steps
-- and rolls them back, the way `rehearse_post_document()` does, so what it
-- answers is what the import would write and a refusal is the one the import
-- would give — a locked period, a capability the caller lacks, an unknown
-- account. Nothing about a rehearsal is computed a second way.
--
-- **Imported history carries no tax.** A line comes with an account and an
-- amount, and not with the tax that produced it: the file has no such thing to
-- give. So the entries of an import feed the ledger, the trial balance and the
-- statements, and no box of a VAT return. A declaration of a period that was
-- kept elsewhere was filed from where it was kept.
--
-- **The same files twice are refused.** `book_imports` keeps one row per
-- import with the checksum of what was read, unique per company: an import
-- that is repeated after a dropped connection finds the first one and writes
-- nothing, rather than doubling the books.

-- ---------------------------------------------------------------------------
-- 1. What was imported
-- ---------------------------------------------------------------------------

create table if not exists book_imports (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references companies(id) on delete cascade,
  source       text not null,
  checksum     text not null,
  file_names   text[] not null default '{}',
  entry_count  integer not null,
  line_count   integer not null,
  first_number text,
  last_number  text,
  opening_number text,
  created_by   uuid default auth.uid(),
  created_at   timestamptz not null default now(),
  constraint book_imports_source_named check (source ~ '^[a-z0-9][a-z0-9.-]{0,39}$'),
  constraint book_imports_checksum_named check (checksum ~ '^sha256:[0-9a-f]{64}$'),
  constraint book_imports_counts check (entry_count >= 0 and line_count >= 0)
);

comment on table book_imports is
  'One row per set of books taken over by import_books(): which reader, the checksum of the files, how many entries and lines, and the numbers they were posted under. The same files twice in one company are refused by the unique checksum.';
comment on column book_imports.source is
  'The reader the files were read with — fec, trial-balance, journal-items, journal-report — as the caller named it.';
comment on column book_imports.checksum is
  'sha256 of the files read, in the order given, as the caller computed it. Unique per company, which is what refuses the same import twice.';
comment on column book_imports.first_number is
  'Number of the first entry the import posted, and last_number of the last: the range to read, or to reverse, afterwards.';
comment on column book_imports.opening_number is
  'Number of the opening entry the import posted through opening_balance(), when the files carried a trial balance.';

create unique index if not exists book_imports_company_checksum_idx on book_imports (company_id, checksum);

alter table book_imports enable row level security;

create policy book_imports_select on book_imports
  for select using (company_id = any ((select companies_with_capability('entries.read'))::uuid[]));
create policy book_imports_insert on book_imports
  for insert with check (company_id = any ((select companies_with_capability('entries.post'))::uuid[]));

grant select, insert on table book_imports to authenticated, service_role;

-- A company leaves with the record of how its history arrived.
insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('book_imports', 'exported', 65, null, null,
   'Which files the history of the company was taken over from, and the entries each posted.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 2. The fiscal year a date falls in, opened on the company's own rhythm
--
-- A company has a first year from `create_company()`. The year before it, or
-- after it, is the same length and starts on the same day of the same month:
-- that is the only thing the books themselves say about how the company counts
-- its years, and it is the one thing read here. Where the company has no year
-- at all there is nothing to align on, and the caller is refused.
-- ---------------------------------------------------------------------------

create or replace function import_fiscal_year_for(p_company_id uuid, p_date date)
returns uuid
language plpgsql
as $$
declare
  v_found  uuid;
  v_anchor date;
  v_start  date;
  v_id     uuid;
begin
  v_found := fiscal_year_at(p_company_id, p_date);
  if v_found is not null then
    return v_found;
  end if;

  select f.start_date into v_anchor
    from fiscal_years f
   where f.company_id = p_company_id
   order by f.start_date
   limit 1;
  if v_anchor is null then
    raise exception 'no_fiscal_year: the company has no fiscal year to align a new one on; open one first'
      using errcode = '55006';
  end if;

  v_start := v_anchor + make_interval(years => extract(year from p_date)::integer - extract(year from v_anchor)::integer);
  while v_start > p_date loop
    v_start := v_start - interval '1 year';
  end loop;
  while v_start + interval '1 year' <= p_date loop
    v_start := v_start + interval '1 year';
  end loop;

  insert into fiscal_years (company_id, name, start_date, end_date)
  values (p_company_id, 'FY' || extract(year from v_start)::integer::text, v_start,
          (v_start + interval '1 year' - interval '1 day')::date)
  returning id into v_id;
  return v_id;
end;
$$;

comment on function import_fiscal_year_for(uuid, date) is
  'The fiscal year a date falls in, opened when there is none as a year of the same length and on the same first day as the company''s earliest one. Called by import_books() when the caller asks for years to be opened.';

-- ---------------------------------------------------------------------------
-- 3. import_books
-- ---------------------------------------------------------------------------

create or replace function import_books(
  p_company_id            uuid,
  p_books                 jsonb,
  p_dry_run               boolean default false,
  p_open_years            boolean default false,
  p_allow_result_accounts boolean default false
)
returns jsonb
language plpgsql
volatile
security invoker
as $$
declare
  v_checksum   text := p_books ->> 'checksum';
  v_source     text := p_books ->> 'source';
  v_previous   book_imports;
  v_result     jsonb;
  v_contacts   jsonb := '{}'::jsonb;
  v_contact    jsonb;
  v_contact_id uuid;
  v_created    integer := 0;
  v_found      integer := 0;
  v_entry      jsonb;
  v_draft      entries;
  v_journal    uuid;
  v_date       date;
  v_missing    text;
  v_years      jsonb := '[]'::jsonb;
  v_year       uuid;
  v_entries    integer := 0;
  v_lines      integer := 0;
  v_first      text;
  v_last       text;
  v_opening    jsonb := p_books -> 'opening';
  v_opening_id uuid;
  v_opening_no text;
  v_debit      numeric := 0;
  v_credit     numeric := 0;
  v_journals   jsonb;
begin
  if not exists (select 1 from companies c where c.id = p_company_id) then
    raise exception 'unknown_company: %', p_company_id using errcode = 'no_data_found';
  end if;
  -- Row level security is what refuses; this is what says why.
  if not coalesce(is_installer(), false) then
    if not coalesce(has_capability(p_company_id, 'entries.write'), false)
       or not coalesce(has_capability(p_company_id, 'entries.post'), false) then
      raise exception 'not_allowed: importing books into this company needs entries.write and entries.post'
        using errcode = '42501';
    end if;
  end if;
  if v_source is null or v_checksum is null then
    raise exception 'invalid_books: the books name no source or no checksum — expected them as the importer builds them';
  end if;
  if jsonb_typeof(coalesce(p_books -> 'entries', '[]'::jsonb)) <> 'array' then
    raise exception 'invalid_books: entries must be a list';
  end if;
  if jsonb_array_length(coalesce(p_books -> 'entries', '[]'::jsonb)) = 0
     and (v_opening is null or jsonb_typeof(v_opening) = 'null') then
    raise exception 'import_empty: the files hold no entry and no balance; there is nothing to import';
  end if;

  select * into v_previous from book_imports b
   where b.company_id = p_company_id and b.checksum = v_checksum;
  if found then
    raise exception 'import_already_done: these files were imported on % (% entries, % to %). Importing them again would count every amount twice',
      to_char(v_previous.created_at, 'YYYY-MM-DD'), v_previous.entry_count,
      coalesce(v_previous.first_number, '—'), coalesce(v_previous.last_number, '—')
      using errcode = '23505';
  end if;

  begin
    -- 1. The years. Each date that falls in none is refused by name, or opened
    --    when the caller asked for it.
    for v_date in
      select distinct d::date from (
        select e ->> 'date' as d from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) e
        union
        select v_opening ->> 'date' where v_opening is not null and jsonb_typeof(v_opening) <> 'null'
      ) dates
      where d is not null
      order by 1
    loop
      if fiscal_year_at(p_company_id, v_date) is null then
        if not p_open_years then
          raise exception 'import_outside_fiscal_year: % falls in no fiscal year of this company. Open that year, or ask the import to open the years it needs',
            v_date
            using errcode = '55006';
        end if;
        v_year := import_fiscal_year_for(p_company_id, v_date);
        select v_years || jsonb_build_object('name', f.name, 'start_date', f.start_date::text, 'end_date', f.end_date::text)
          into v_years from fiscal_years f where f.id = v_year;
      end if;
    end loop;

    -- 2. The parties: by the code the source gave them, then by their name,
    --    or created. A party the file names once is still one party.
    for v_contact in select value from jsonb_array_elements(coalesce(p_books -> 'contacts', '[]'::jsonb)) loop
      v_contact_id := null;
      if nullif(v_contact ->> 'auxiliary_code', '') is not null then
        select c.id into v_contact_id from contacts c
         where c.company_id = p_company_id and c.auxiliary_code = v_contact ->> 'auxiliary_code'
         order by c.created_at limit 1;
      end if;
      if v_contact_id is null then
        select c.id into v_contact_id from contacts c
         where c.company_id = p_company_id and lower(c.name) = lower(v_contact ->> 'name')
         order by c.created_at limit 1;
      end if;
      if v_contact_id is null then
        insert into contacts (company_id, name, contact_type, auxiliary_code,
                              vat_number, registration_number, email, country)
        values (p_company_id, v_contact ->> 'name',
                coalesce(v_contact ->> 'contact_type', 'other')::contact_type,
                nullif(v_contact ->> 'auxiliary_code', ''),
                nullif(v_contact ->> 'vat_number', ''),
                nullif(v_contact ->> 'registration_number', ''),
                nullif(v_contact ->> 'email', ''),
                nullif(upper(v_contact ->> 'country'), ''))
        returning id into v_contact_id;
        v_created := v_created + 1;
      else
        v_found := v_found + 1;
      end if;
      v_contacts := v_contacts || jsonb_build_object(v_contact ->> 'key', v_contact_id);
    end loop;

    -- 3. The accounts every line names, all of them, before anything is
    --    written: one refusal that lists them is worth more than the first.
    select string_agg(distinct code, ', ' order by code) into v_missing
      from (
        select l ->> 'account_code' as code
          from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) e,
               jsonb_array_elements(e -> 'lines') l
        union
        select l ->> 'account_code'
          from jsonb_array_elements(coalesce(v_opening -> 'lines', '[]'::jsonb)) l
      ) wanted
     where not exists (select 1 from accounts a where a.company_id = p_company_id and a.code = wanted.code);
    if v_missing is not null then
      raise exception 'unknown_account: % % not in the chart of this company. Map each to an account of the chart',
        v_missing, case when v_missing like '%,%' then 'are' else 'is' end
        using errcode = 'no_data_found';
    end if;

    -- 4. The entries, each a draft and then posted by post_entry().
    for v_entry in select value from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) loop
      select j.id into v_journal from journals j
       where j.company_id = p_company_id and j.code = v_entry ->> 'journal_code';
      if v_journal is null then
        raise exception 'unknown_journal: % is not a journal of this company', v_entry ->> 'journal_code'
          using errcode = 'no_data_found';
      end if;

      insert into entries (company_id, journal_id, entry_date, number, reference, description, state, currency_code)
      select p_company_id, v_journal, (v_entry ->> 'date')::date,
             nullif(v_entry ->> 'number', ''),
             nullif(v_entry ->> 'reference', ''),
             nullif(v_entry ->> 'description', ''),
             'draft', c.currency_code
        from companies c where c.id = p_company_id
      returning * into v_draft;

      insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit,
                               contact_id, currency_code, amount_currency, date_maturity)
      select v_draft.id, p_company_id, a.id, (l.ordinality * 10)::integer,
             nullif(l.value ->> 'label', ''),
             coalesce((l.value ->> 'debit')::numeric, 0),
             coalesce((l.value ->> 'credit')::numeric, 0),
             case when l.value ->> 'contact_key' is null then null
                  else (v_contacts ->> (l.value ->> 'contact_key'))::uuid end,
             nullif(l.value ->> 'currency_code', ''),
             nullif(l.value ->> 'amount_currency', '')::numeric,
             nullif(l.value ->> 'date_maturity', '')::date
        from jsonb_array_elements(v_entry -> 'lines') with ordinality l
        join accounts a on a.company_id = p_company_id and a.code = l.value ->> 'account_code';

      v_draft := post_entry(v_draft.id);
      v_entries := v_entries + 1;
      v_lines := v_lines + jsonb_array_length(v_entry -> 'lines');
      v_debit := v_debit + v_draft.total_debit;
      v_credit := v_credit + v_draft.total_credit;
      v_first := coalesce(v_first, v_draft.number);
      v_last := v_draft.number;
    end loop;

    -- 5. The balances, as the opening entry of the year they open.
    if v_opening is not null and jsonb_typeof(v_opening) <> 'null' then
      v_year := fiscal_year_at(p_company_id, (v_opening ->> 'date')::date);
      if (select f.start_date from fiscal_years f where f.id = v_year) <> (v_opening ->> 'date')::date then
        raise exception 'opening_not_first_day: an opening balance is dated on the first day of a fiscal year, and % is not; the year it falls in starts on %',
          v_opening ->> 'date', (select f.start_date from fiscal_years f where f.id = v_year);
      end if;
      v_opening_id := opening_balance(
        p_company_id, v_year,
        (select jsonb_agg(jsonb_build_object(
                  'account_code', l ->> 'account_code',
                  'debit', l ->> 'debit',
                  'credit', l ->> 'credit',
                  'label', coalesce(nullif(l ->> 'label', ''), 'Opening balance'),
                  'contact_id', case when l ->> 'contact_key' is null then null
                                     else v_contacts ->> (l ->> 'contact_key') end))
           from jsonb_array_elements(v_opening -> 'lines') l),
        p_allow_result_accounts);
      select e.number into v_opening_no from entries e where e.id = v_opening_id;
      v_lines := v_lines + jsonb_array_length(v_opening -> 'lines');
    end if;

    select coalesce(jsonb_agg(jsonb_build_object('journal_code', j.code, 'entries', n) order by j.code), '[]'::jsonb)
      into v_journals
      from (select e ->> 'journal_code' as code, count(*) as n
              from jsonb_array_elements(coalesce(p_books -> 'entries', '[]'::jsonb)) e
             group by 1) per
      join journals j on j.company_id = p_company_id and j.code = per.code;

    insert into book_imports (company_id, source, checksum, file_names, entry_count, line_count,
                              first_number, last_number, opening_number)
    values (p_company_id, v_source, v_checksum,
            coalesce((select array_agg(value) from jsonb_array_elements_text(coalesce(p_books -> 'file_names', '[]'::jsonb))), '{}'),
            v_entries, v_lines, v_first, v_last, v_opening_no);

    v_result := jsonb_build_object(
      'dry_run', p_dry_run,
      'source', v_source,
      'entries', v_entries,
      'lines', v_lines,
      'total_debit', v_debit::text,
      'total_credit', v_credit::text,
      'first_number', v_first,
      'last_number', v_last,
      'opening_number', v_opening_no,
      'journals', v_journals,
      'contacts_created', v_created,
      'contacts_found', v_found,
      'fiscal_years_opened', v_years
    );

    if p_dry_run then
      -- The way out of the block that undoes everything done inside it. A
      -- variable is not part of the transaction, so the answer survives.
      raise exception using errcode = 'EKW01', message = 'rehearsal';
    end if;
  exception
    when sqlstate 'EKW01' then
      null;
  end;

  return v_result;
end;
$$;

comment on function import_books(uuid, jsonb, boolean, boolean, boolean) is
  'Takes over books read from another system, whole or not at all: the fiscal years they need (p_open_years), their parties, every entry posted through post_entry() and a trial balance through opening_balance(). Account codes arrive already translated into the company''s chart. p_dry_run does all of it and rolls it back, so the answer and the refusals are the real ones. The same files twice are refused (import_already_done).';

revoke execute on all functions in schema public from public;

revoke execute on function import_fiscal_year_for(uuid, date) from public, anon;
grant execute on function import_fiscal_year_for(uuid, date) to authenticated, service_role;
revoke execute on function import_books(uuid, jsonb, boolean, boolean, boolean) from public, anon;
grant execute on function import_books(uuid, jsonb, boolean, boolean, boolean) to authenticated, service_role;
